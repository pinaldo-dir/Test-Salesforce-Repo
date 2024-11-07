public with sharing class WarrantsProcessController {
    
    @AuraEnabled(cacheable=true)
    public static List<PermissionSetAssignment> getUserInfo(String userId) {
        System.debug('>>>>>>>>>>>>>>>>>>>>>> User Info >>>>>>>>>>>>>>>>>>>>');
        List<PermissionSetAssignment> userProfilePermissionInfo = new List<PermissionSetAssignment> ([SELECT Id, PermissionSetId, PermissionSet.Name, 
        PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name 
        FROM PermissionSetAssignment WHERE AssigneeId =: userId]);

        return userProfilePermissionInfo;
    }
      
    @AuraEnabled(cacheable=true)
    public static List<WarrantPaymentRecordListWrapper> getWarrantsCaseDetails(String apxWbRecId){
        System.debug('>>>>>>>>>>>>>>> getWarrants---apxWbRecId >>>>>>>>>>>>>'+apxWbRecId);
        List<WarrantPaymentRecordListWrapper> warrantWbandPRlist = new List<WarrantPaymentRecordListWrapper>();
        List<Warrant_Batch__c> wbWarrantList = new List<Warrant_Batch__c>([SELECT Id, Name, Void_Reason__c, Status__c, 
        (SELECT Id, Name, Warrant_Number__c, Amount__c, Status__c, Status_Comment__c, Status_Date__c, Disbursement_Type__c, 
        Serial_Number__c, Approved_By__c, Approved_Warrant__c, Approved_Date__c, Not_Approved_Comments__c, Office_Account__c, 
        Case_Number__c, Case__r.Id, Case__r.Name, Case__r.Cash_Balance_on_Case__c, Case__r.Deposited_Funds__c, Case__r.Funds_Drawn_on_Deposits__c, 
        Case__r.Warrants_Pending__c, Payee__r.Id, Payee__r.Name 
        FROM Warrant__r) FROM Warrant_Batch__c WHERE Id=:apxWbRecId]);
        System.debug('>>>>>>>>>> GetWarrantsCaseDetails --- wbWarrantList >>>>>>>>>>'+wbWarrantList);
        System.debug('>>>>>>>>>> GetWarrantsCaseDetails --- Related Warrants >>>>>>>>>>'+wbWarrantList[0].Warrant__r);

        List<String> warrantIdList = new List<String>();
        for (Warrant__c wrList:wbWarrantList[0].Warrant__r) {
            warrantIdList.add(wrList.Id);
        }
        List<Payment_Record__c> paymentRecDetailList = new List<Payment_Record__c>([SELECT Id, Name, 
        Warrant__r.Id, Warrant__r.Name, Warrant_Issued__c from Payment_Record__c WHERE Warrant__r.Id=:warrantIdList]);
        System.debug('>>>>>>>>>> GetWarrantsCaseDetails --- Related Payment Records >>>>>>>>>>'+paymentRecDetailList);

        WarrantPaymentRecordListWrapper warrantPmtRecWrapper = new WarrantPaymentRecordListWrapper();
        warrantPmtRecWrapper.warrantBatch = wbWarrantList;
        warrantPmtRecWrapper.warrantList = wbWarrantList[0].Warrant__r;
        warrantPmtRecWrapper.paymentRecList = paymentRecDetailList;
        warrantWbandPRlist.add(warrantPmtRecWrapper);
        System.debug('>>>>>>>>>> GetWarrantsCaseDetails --- Wrapper List >>>>>>>>>>'+warrantWbandPRlist);

        return warrantWbandPRlist;
    }

     //wrapper class with @AuraEnabled and {get;set;} properties
     public class WarrantPaymentRecordListWrapper{
        @AuraEnabled
        public List<Warrant_Batch__c> warrantBatch{get;set;}
        @AuraEnabled
        public List<Warrant__c> warrantList{get;set;}
        @AuraEnabled
        public List<Payment_Record__c> paymentRecList{get;set;}
    }
    
    @AuraEnabled
    public static Boolean updateWRandPRstatus(List<Warrant__c> wrForUpdate, List<Payment_Record__c> prForUpdate){
        System.debug('------------------- WR, PR Update -------------------');
        Boolean updatedRec = false;
        
        try{
            UPDATE wrForUpdate;
            System.debug('WR Update was successful');
            updatedRec = true;
        }
        catch(DmlException e){
            System.debug('Error updating WR: '+e);
            updatedRec = false;
        }

        try{
            UPDATE prForUpdate;
            System.debug('PR Update was successful');
            updatedRec = true;
        }
        catch(DmlException e){
            System.debug('Error updating PR: '+e);
            updatedRec = false;
        }
        
        return updatedRec;
    }

    @AuraEnabled(cacheable=true)
    public static List<Warrant_Batch__c> getWarrantBatchDetails(String apxWbRecId){
        System.debug('>>>>>>>>>>>>>>> getWarrantBatchDetails---apxWbRecId >>>>>>>>>>>>>'+apxWbRecId);
        List<Warrant_Batch__c> wbWarrantList = new List<Warrant_Batch__c>([SELECT Id, Name, Status__c, 
        (SELECT Id, Name, Warrant_Number__c, Amount__c, Status__c FROM Warrant__r) FROM Warrant_Batch__c WHERE Id=:apxWbRecId]);
        System.debug('>>>>>>>>>>>>>>> WB & WR Details >>>>>>>>>>>>>'+wbWarrantList);
        return wbWarrantList;
    }
    
    @AuraEnabled
    public static Boolean updatedWarrantBatch(List<Warrant_Batch__c> wbForUpdate, List<Id> caseIds, String wbLink){
        System.debug('############# update Warrant Batch #############');
        Boolean updatedRec = false;
        try{
            UPDATE wbForUpdate;
            System.debug('Update wbForUpdate');
            System.debug(wbForUpdate);
            updatedRec = true;
            system.debug('!!!!!!!!!!!!!!!!!! Case - Warrants Pending !!!!!!!!!!!!!!!!!!');
            system.debug('Case Ids ==> ' + caseIds);

            List<DIR_Case__c> caseWarrantList =  new List<DIR_Case__c>([SELECT Id, Name, Cash_Balance_on_Case__c, Deposited_Funds__c, 
                                                                Funds_Drawn_on_Deposits__c, Warrants_Pending__c, 
                                                                (SELECT Id, Name, Warrant_Number__c, Amount__c, Status__c, Case__c, 
                                                                Case__r.Id, Case__r.Name FROM Warrants__r 
                                                                WHERE Status__c IN ('New','Pending Approval','Approved','Not Approved','Secondary Approval Needed','Printed')) 
                                                                FROM DIR_Case__c WHERE Id IN :caseIds]);
            System.debug('caseWarrantList =============> ' +caseWarrantList);

            Map<String, List<Id>> qJobIdMap = new Map<String, List<Id>>();
                
            //Call Warrant Pending Qable Class
            System.enqueueJob(new WarrantPendingUpdateQable(caseWarrantList, wbLink, qJobIdMap, 'Update'));
        }
        catch(DmlException e){
            System.debug('Error updating account: '+e);
            updatedRec = false;
        }
        return updatedRec;
    }

    /*
    @AuraEnabled
    public static Boolean updatePendCashBalOnCase(List<DIR_Case__c> caseForUpdate){
        System.debug('------------------- Case Update -------------------');
        Boolean updatedCaseRec = false;
        try{
            UPDATE caseForUpdate;
            System.debug('Case Update was successful');
            updatedCaseRec = true;
        }
        catch(DmlException e){
            System.debug('Error updating Case: '+e);
            updatedCaseRec = false;
        }
        return updatedCaseRec;
    }
    */
    
}