public class ReceiptsGridController{
    
    @AuraEnabled
    public static List<RecordType> getRecTypeIds(){
        List<RecordType> recTypeList = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case_Payment__c'];
        return recTypeList;
    }
   
    @AuraEnabled
    public static Map<Id, Id> saveReceiptCaseServer(String receipts, String casePmts, Boolean isEdited){ 

        Map<Id, Id> receiptCaseId = new Map<Id, Id>();
        
        DIR_Employee__c dirEmpl = new DIR_Employee__c();

        try{
            dirEmpl = [SELECT Id, Name FROM DIR_Employee__c WHERE Position__c = 'Cashiering' AND User__c = :UserInfo.getUserId() LIMIT 1];
        }catch(Exception e){
            dirEmpl = null;
        }
        
        List<Receipt__c> deserializedPayment = (List<Receipt__c>)JSON.deserialize(receipts, List<Receipt__c>.class);
        System.debug('23 deserializedPayment: ' + deserializedPayment);
        List<Case_Payment__c> deserializedCases = (List<Case_Payment__c>)JSON.deserialize(casePmts, List<Case_Payment__c>.class);
        System.debug('25 deserializedCases: ' + deserializedCases);
        
        if(deserializedPayment != null && deserializedPayment.size() > 0){
            receiptCaseId = createRctCaseRecord(deserializedPayment, deserializedCases, isEdited);
        }
        return receiptCaseId;
    }
    
    private static Map<Id, Id> createRctCaseRecord(List<Receipt__c> receipts, List<Case_Payment__c> casePmts, Boolean isEdited) {
        Integer rctIndex;
        Integer caseIndex; 
        ID newRctId;
        Boolean deducVal;
        Map<Integer, Id> receiptMap = new Map<Integer, Id>();
        Map<Id, Id> rctCaseMap = new Map<Id, Id>();
        
        if(!isEdited){
            List<Receipt__c> receiptList = new List<Receipt__c> ();
            List<Case_Payment__c> caseList = new List<Case_Payment__c> ();
            for (Receipt__c eachReceipt : receipts) {
                receiptList.add(eachReceipt);
            }
            insert receiptList;

            //Match Deduction RCTs with their related Net RCTs and link them
            //TODO: the proper way to do this would be to match and link deduction and net receipts (with a new field?) on creation in the JS
            Boolean receiptsLinked = false;
            for(Receipt__c deductionReceipt : receiptList){
                for(Receipt__c netReceipt : receiptList){
                        // 1) Deduction RCTs' Receipt_Index__c are consistently 1 higher than their affiliated Net RCT's Receipt_Index__c
                    if(netReceipt.Receipt_Index__c + 1 == deductionReceipt.Receipt_Index__c &&
                        // 2) both RCT's Add_Deduction__c is TRUE (Both RCTs in each net/deduction pair will be TRUE. All other RCTs will be FALSE.)
                       netReceipt.Add_Deduction__c && deductionReceipt.Add_Deduction__c &&
                        // 3) both RCT's Gross_Amount__c are equal (Not necessarily unique.)
                       netReceipt.Gross_Amount__c == deductionReceipt.Gross_Amount__c &&
                        // 4) net RCT's Payment_Amount__c + deduction RCT's Deduction_Amount__c equal Gross_Amount__c (Not necessarily unique.)
                       netReceipt.Payment_Amount__c + deductionReceipt.Deduction_Amount__c == netReceipt.Gross_Amount__c &&
                        // 5) only the deductionReceipt.Payment_Type__c is 'Deduction'
                       netReceipt.Payment_Type__c != 'Deduction' && deductionReceipt.Payment_Type__c == 'Deduction' &&
                        // 6) deductionReceipt.Instrument_Number__c is always 'Deduction for ' + netReceipt.Instrument_Number__c (Not necessarily unique.)
                        deductionReceipt.Instrument_Number__c.contains(netReceipt.Instrument_Number__c)){
                           deductionReceipt.Net_Receipt__c = netReceipt.Id;
                           receiptsLinked = true;
                    }
                }
            }
            if(receiptsLinked){
                update receiptList;
            }
            
            for(Receipt__c receipt : receiptList){
                newRctId = receipt.Id;
                
                rctIndex = receipt.Receipt_Index__c.intValue();
                if(receipt.Deduction_Amount__c != 0 || receipt.Deduction_Amount__c != 0.0){
                    deducVal = true;
                }else{
                    deducVal = false;
                }
                receiptMap.put(rctIndex, newRctId);
                if(newRctId != null){
                    for(Case_Payment__c eachCase : casePmts){
                        caseIndex = eachCase.CP_Index__c.intValue();

                        if(rctIndex == caseIndex){
                            eachCase.Receipt__c = newRctId;
                            eachCase.Deduction_Payment__c = deducVal;
                            caseList.add(eachCase);
                        }
                    }
                }
            }
            System.debug('97 caseList: ' + caseList);
            insert caseList;
            
            Id newMapCaseId;
            Id rctIdOfCase;
            Integer total = 1;
            
            for(Case_Payment__c casePmt : caseList){
                newMapCaseId = casePmt.Id;
                rctIdOfCase = casePmt.Receipt__c;
                System.debug('107 loop #: ' + total + ' , Case_Payment ID: ' + newMapCaseId + ' , Receipt Id: ' + rctIdOfCase);
                total++;
                rctCaseMap.put(newMapCaseId,rctIdOfCase);
            }
        }
        return rctCaseMap;
    }
}