public with sharing class RsCommunityPayCreditConfirm {

    public static String transactionId;
    @TestVisible public static ChargentOrders__ChargentOrder__c ChargentOrder {get; set;}

    
    @AuraEnabled
    public static Boolean cancelButton(String coId) {

        ChargentOrders__ChargentOrder__c ChargentOrder;
        ChargentOrder = [SELECT Id, Registration__c FROM ChargentOrders__ChargentOrder__c WHERE Id =: coId];
        License_Registration__c lReg = [SELECT Id, Status__c FROM License_Registration__c WHERE Id =: ChargentOrder.Registration__c];
        lReg.Status__c = 'Pending Payment';
        update lReg;

        return True;
    }


    @AuraEnabled
    public static String getPaymentConfirm(String coId) {

        String errortype = '';
        String errorDisplay = ''; 
        String errormessage = '';
        
        ChargentOrders__ChargentOrder__c ChargentOrder;
        ChargentOrder = [SELECT Id, Registration__c, ChargentOrders__Payment_Method__c, ChargentOrders__Card_Type__c,ChargentOrders__Billing_First_Name__c, ChargentOrders__Card_Number__c,
            ChargentOrders__Billing_Last_Name__c, ChargentOrders__Card_Expiration_Month__c, ChargentOrders__Billing_Company__c,
            ChargentOrders__Card_Expiration_Year__c, ChargentOrders__Billing_Address__c, ChargentOrders__Card_Security_Code__c,
            ChargentOrders__Billing_Address_Line_2__c, ChargentOrders__Billing_Phone__c, ChargentOrders__Billing_City__c,
            ChargentOrders__Billing_Email__c, ChargentOrders__Billing_State__c , ChargentOrders__Billing_Zip_Postal__c,
            ChargentOrders__Billing_Country__c, ChargentOrders__Total__c
            FROM ChargentOrders__ChargentOrder__c WHERE Id =: coId];
        License_Registration__c lReg = [SELECT Id, Status__c FROM License_Registration__c WHERE Id =: ChargentOrder.Registration__c];

        try{
            ChargentOrders.TChargentOperations.TChargentResult ChargentResult = ChargentOrders.TChargentOperations.ChargeOrder_Click(ChargentOrder.Id);
          
            if (ChargentResult.Message.indexOf('Approved') < 0) {
                
                errortype = 'alert alert-danger';
                errorDisplay = 'block';
             
                //Below code added by Kavya Somashekar for req 170025
                //when the transaction fails get the errorcode from transaction's gatewayResponse feild(query)
                //capturing single ChargentOrders__Transaction__c rather than list of ChargentOrders__Transaction__c as we will ALWAYS have a transaction record created
                if(!Test.isRunningTest()){
                    transactionId = ChargentResult.TransactID;
                }
                
                ChargentOrders__Transaction__c tranRec = [SELECT ID,ChargentUserMessage__c,ChargentOrders__Gateway_ID__c,ChargentOrders__Response_Message__c,ChargentErrorCode__c,TransactionMessage__c,ChargentOrders__Gateway_Response__c
                                                            FROM ChargentOrders__Transaction__c 
                                                            WHERE Id=:transactionId LIMIT 1];
 
                //extract errorcode from Gateway_Response__c 
                //check if the substrings between needs to be added as custom labels  
                String errCode;
                
                if(!String.isBlank(tranRec.ChargentOrders__Gateway_Response__c)) {

                    errCode = tranRec.ChargentOrders__Gateway_Response__c.substringBetween('UMerrorcode=','&UMresult='); 
                    tranRec.ChargentErrorCode__c = errCode;
                    
                    //Get the user error message from the metadata based on error code
                    List<Chargent_Error_Code__mdt> usrMsg = new List<Chargent_Error_Code__mdt>([SELECT MasterLabel, Error_ID__c, Technical_Message__c,User_Message__c 
                                                                                            FROM Chargent_Error_Code__mdt 
                                                                                            WHERE Error_ID__c= :errCode]);
                    //populate transaction record fields from metadata
                    if(!usrMsg.isEmpty() && !String.isBlank(usrMsg[0].User_Message__c)) {
                    
                        errormessage = 'Error: '+usrMsg[0].User_Message__c;
                        tranRec.ChargentUserMessage__c = usrMsg[0].User_Message__c;
                        
                        if(!String.isBlank(usrMsg[0].Technical_Message__c)) {
                            tranRec.TransactionMessage__c = usrMsg[0].Technical_Message__c;                            
                        }                        
                        update tranRec;
                        
                    } else {
                        errormessage = 'Error: Payment failed!';                        
                    }
                                                                                            
                } else {
                    //Bug B-29618
                    if(tranRec.ChargentOrders__Gateway_ID__c == 'Chargent Error') {
                        errormessage = tranRec.ChargentOrders__Response_Message__c;                        
                    }
                }
                
            } else {
                return errormessage;
            }
            
        } catch(exception e){
            errortype = 'alert alert-danger';
            errorDisplay = 'block';
            errormessage = 'Error:'+e.getMessage();
            return errormessage;
        }      
        return errormessage;
    }   
}