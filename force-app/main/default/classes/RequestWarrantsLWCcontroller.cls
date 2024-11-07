public with sharing class RequestWarrantsLWCcontroller {
    public requestWarrantsLWCcontroller() {
        System.debug('________________requestWarrantsLWCcontroller________________');
    }

    @AuraEnabled(cacheable=true)
    public static List<PermissionSetAssignment> getUserInfo(String userId) {
        System.debug('>>>>>>>>>>>>>>>>>>>>>> User Info >>>>>>>>>>>>>>>>>>>>');
        List<PermissionSetAssignment> userProfilePermissionInfo = new List<PermissionSetAssignment> ([SELECT Id, PermissionSetId, PermissionSet.Name, 
        PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name 
        FROM PermissionSetAssignment WHERE AssigneeId =: userId]);

        return userProfilePermissionInfo;
    }

    @AuraEnabled(cacheable=true)
    public static List<DIR_Employee__c> getInternalEmployeeInfo(String userId) {
        System.debug('>>>>>>>>>>>>>>>>>>>>>> Internal Employee Info >>>>>>>>>>>>>>>>>>>>');
        List<DIR_Employee__c> internalEmpInfo = new List<DIR_Employee__c> ([SELECT Id, Name, Active__c, User__c, User__r.Id, User__r.Name, Email__c
        FROM DIR_Employee__c WHERE User__r.Id =: userId and Active__c =: true]);

        return internalEmpInfo;
    }

    @AuraEnabled(cacheable=true)
    public static List<Payee__c> getPayeeDetails(List<String> apxSelPayees){
        try {
            System.debug('>>>>>>>>>>>>>>> getPayeeDetails---apxSelPayees >>>>>>>>>>>>>'+apxSelPayees); 
            //List<PayeePaymentRecCaseListWrapper> payeePmtRecCaseList = new List<PayeePaymentRecCaseListWrapper>();
            List<Payee__c> payeeList = 
                new List<Payee__c>([SELECT Id, Name, Payee_Name__c, Case_Role__c, Factor__c, Payee_Type__c, Status__c, DIR_Office__c, Latest_Receipt_Hold_Date__c,
                                        Wage_Payable_Balance_New__c, Wage_Interest_Payable_Balance__c, Penalty_Payable_Balance_New__c, Interest_Other_Payable_Balance__c,
                                        
                                        Case_Management__c, Case_Management__r.Office__r.Office_Account__c, Case_Management__r.Cash_Balance_on_Case__c,
                                        Case_Management__r.Warrants_Pending__c, Case_Management__r.Employer__r.Subject_to_Garnishment__c,
                                        Case_Management__r.Name, Case_Management__r.Employer__r.Subject_to_Lien__c, 
                                        
                                        (SELECT Id, Name, Receipt_Hold_Date__c, Batched_Under_Warrant__c, Warrant__c, Payment_Amount__c,
                                            
                                            Liability_Payment__c, 
                                            Liability_Payment__r.Case_Payment__c,
                                            Liability_Payment__r.Case_Payment__r.Id,
                                            Liability_Payment__r.Case_Payment__r.Receipt__r.Status__c,
                                            Liability_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c,

                                            Judgment_Payment__c,
                                            Judgment_Payment__r.Case_Payment__c,
                                            Judgment_Payment__r.Case_Payment__r.Id,
                                            Judgment_Payment__r.Case_Payment__r.Receipt__r.Status__c,
                                            Judgment_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c

                                        FROM Payment_Records__r
                                        WHERE Warrant__c = null
                                            AND Warrant_Issued__c = false)

                                    FROM Payee__c
                                    WHERE Id IN :apxSelPayees]);
        
            System.debug('48 Payee list ==> ' + payeeList);
            
            return payeeList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Office_Account__c> getOAowner(List<String> oaId) {
        System.debug('>>>>>>>>>>>>>>>>>>>>>> Office Account Owner >>>>>>>>>>>>>>>>>>>>');
        System.debug('>>>>>>>>>>>>>>> getOAowner---oaId >>>>>>>>>>>>>'+oaId);
        List<Office_Account__c> oaOwnerId = new List<Office_Account__c> ([SELECT Id, Name, OwnerId
        FROM Office_Account__c WHERE Id IN : oaId]);

        return oaOwnerId;
    }

    @AuraEnabled
    public static List<Warrant_Batch__c> insertWarrantBatch(List<Warrant_Batch__c> wbListToInsert){
        try {
            List<Id> warrantBatchIds = new List<Id>();
            insert wbListToInsert;
            System.debug('wbListToInsert IDs ==> ' + wbListToInsert);
            for(Warrant_Batch__c wb : wbListToInsert){
                warrantBatchIds.add(wb.Id);
            }

            List<Warrant_Batch__c> warrantBatchList = [SELECT Id, Name, Office_Account__c
                                                FROM Warrant_Batch__c
                                                WHERE Id IN :warrantBatchIds WITH SECURITY_ENFORCED];

            return warrantBatchList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void insertWrsUpdatePrs(List<Warrant__c> wrListToInsert, List<Payment_Record__c> prListToUpdate, String type, String wbLink){
        System.debug('>>>>>>>>>>>>>>>>>>>>>> insertWrsUpdatePrs >>>>>>>>>>>>>>>>>>>>');
        /*String sWrInsertList = JSON.serialize(wrListToInsert);
        String sPrUpdateList = JSON.serialize(prListToUpdate);
        Database.executeBatch(new InsertWRandUpdatePRBatch(sWrInsertList, sPrUpdateList, wbLink), 1);*/
        System.debug('>>>>>>>>>>>>>>>>>>>>>> wbLink >>>>>>>>>>>>>>>>>>>>' +wbLink);
        System.enqueueJob(new WarrantInsertPRUpdateQable(wrListToInsert, prListToUpdate, type, wbLink));
    }

    /*
    @AuraEnabled
    public static List<Warrant__c> insertWarrants(List<Warrant__c> wrListToInsert){
        try {
            List<Id> warrantIds = new List<Id>();
            insert wrListToInsert;
            System.debug('wrListToInsert IDs ==> ' + wrListToInsert);
            for(Warrant__c wr : wrListToInsert){
                warrantIds.add(wr.Id);
            }

            List<Warrant__c> warrantsListDetail = [SELECT Id, Name, Payee__c
                                                FROM Warrant__c 
                                                WHERE Id IN :warrantIds WITH SECURITY_ENFORCED];

            return warrantsListDetail;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Id> updatePaymentRecord(List<Payment_Record__c> prListToUpdate){
        try {
            List<Id> paymentRecIds = new List<Id>();
            //update prListToUpdate;
            System.debug('prListToUpdate IDs ==> ' + prListToUpdate);
            for(Payment_Record__c pr : prListToUpdate){
                paymentRecIds.add(pr.Id);
            }
            return paymentRecIds;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    */

    @AuraEnabled(cacheable=true)
    public static void sendEmailToController(String body, String toSend, String subject){
        try{
            System.debug('Inside Sending Email Class Method');
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String[] toAddresses = new String[] {toSend};
            List<String> sendTo = toSend.split(',');
            mail.setToAddresses(sendTo);
            mail.setSubject(subject);
            mail.setHtmlBody('<h1>'+ body + '</h1>');
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            emails.add(mail);
            Messaging.sendEmail(emails);
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

}