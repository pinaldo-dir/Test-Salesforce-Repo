public with sharing class WBSecondaryApprovalController {

    public WBSecondaryApprovalController() {
        System.debug('________________WBSecondaryApprovalController________________');
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
        List<DIR_Employee__c> internalEmpInfo = new List<DIR_Employee__c> ([SELECT Id, Name, Active__c, User__c, User__r.Id, User__r.Name
        FROM DIR_Employee__c WHERE User__r.Id =: userId and Active__c =: true]);

        return internalEmpInfo;
    }

    @AuraEnabled(cacheable=true)
    public static List<WarrantPaymentRecordListWrapper> getWarrantsCaseDetails(String apxWbRecId){
        System.debug('>>>>>>>>>>>>>>> getWarrants---apxWbRecId >>>>>>>>>>>>>'+apxWbRecId);
        List<WarrantPaymentRecordListWrapper> warrantWblist = new List<WarrantPaymentRecordListWrapper>();
        List<Warrant_Batch__c> wbWarrantList = new List<Warrant_Batch__c>([SELECT Id, Name, Reviewed_By__c, Reviewed_By__r.Name, Status__c, 
        (SELECT Id, Name, Warrant_Number__c, Amount__c, Status__c, Status_Comment__c, Status_Date__c, Disbursement_Type__c, 
        Approved_By__c, Approved_Warrant__c, Approved_Date__c, Not_Approved_Comments__c, Office_Account__c, 
        Case_Number__c, Case__r.Id, Case__r.Name, Case__r.Cash_Balance_on_Case__c, Case__r.Deposited_Funds__c, Case__r.Funds_Drawn_on_Deposits__c, 
        RecordTypeId, Payee__r.Id, Payee__r.Name, Secondary_Approver__c, Secondary_Approval_Date__c
        FROM Warrant__r) FROM Warrant_Batch__c WHERE Id=:apxWbRecId]);
        System.debug('>>>>>>>>>> GetWarrantsCaseDetails --- wbWarrantList >>>>>>>>>>'+wbWarrantList);
        System.debug('>>>>>>>>>> GetWarrantsCaseDetails --- Related Warrants >>>>>>>>>>'+wbWarrantList[0].Warrant__r);
       
        WarrantPaymentRecordListWrapper warrantWrapper = new WarrantPaymentRecordListWrapper();
        warrantWrapper.warrantBatch = wbWarrantList;
        warrantWrapper.warrantList = wbWarrantList[0].Warrant__r;
        //warrantPmtRecWrapper.paymentRecList = paymentRecDetailList;
        warrantWblist.add(warrantWrapper);
        System.debug('>>>>>>>>>> GetWarrantsCaseDetails --- Wrapper List >>>>>>>>>>'+warrantWblist);

        return warrantWblist;
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
    public static Boolean updatedWarrants(List<Warrant__c> wrForUpdate, List<Warrant_Batch__c> wbForUpdate, String wbLink){
        System.debug('############# update Warrants #############');
        Boolean updatedRec = false;
        try{
            System.debug('Update through Apex Batch');
            updatedRec = true;
            System.enqueueJob(new WarrantUpdateQable(wbForUpdate, wrForUpdate, wbLink));
        }
        catch(DmlException e){
            System.debug('Error updating account: '+e);
            updatedRec = false;
        }
        return updatedRec;
    }

    /*
    @AuraEnabled
    public static Boolean updatedWarrantBatch(List<Warrant_Batch__c> wbForUpdate){
        System.debug('############# update Warrant Batch #############');
        Boolean updatedRec = false;
        try{
            UPDATE wbForUpdate;
            System.debug('Update wbForUpdate');
            System.debug(wbForUpdate);
            updatedRec = true;
        }
        catch(DmlException e){
            System.debug('Error updating account: '+e);
            updatedRec = false;
        }
        return updatedRec;
    }
    */
    
}