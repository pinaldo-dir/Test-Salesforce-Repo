public with sharing class WBSubmitApprovalController {
    public WBSubmitApprovalController() {
        System.debug('________________WBSubmitApprovalController________________');
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
    public static List<Warrant_Batch__c> getWarrantsCaseDetails(String apxWbRecId){
        System.debug('>>>>>>>>>>>>>>> getWarrants---apxWbRecId >>>>>>>>>>>>>'+apxWbRecId);
        List<Warrant_Batch__c> warrantsCasesList =
            new List<Warrant_Batch__c>([SELECT Id, Name, Status__c,
                                            (SELECT Id, Name, Warrant_Number__c, Amount__c, Status__c, Status_Date__c, Case_Number__c,
                                                    Case__r.Id, Case__r.Name, Case__r.Cash_Balance_on_Case__c, Case__r.Warrants_Pending__c,
                                                    Payee__r.Payee_Name__c, Payee__r.Payee_Type__c
                                                FROM Warrant__r)
                                            FROM Warrant_Batch__c WHERE Id=:apxWbRecId]);

        System.debug('>>>>>>>>>> GetWarrantsCaseDetails --- warranwarrantsCasesListtList >>>>>>>>>>'+warrantsCasesList);
        return warrantsCasesList;
    }

    @AuraEnabled
    public static Boolean updateWBandWRstatus(List<Warrant_Batch__c> wbForUpdate, List<Warrant__c> wrForUpdate, String wbLink){
        
        Boolean updatedRec = false;
        try{
            //UPDATE wbForUpdate;
            System.debug('Update was successful');
            updatedRec = true;
            System.enqueueJob(new WarrantUpdateQable(wbForUpdate, wrForUpdate, wbLink));
        }
        catch(DmlException e){
            System.debug('Error updating account: '+e);
            updatedRec = false;
        }


        /*
        try{
            UPDATE wrForUpdate;
            System.debug('Update was successful');
            updatedRec = true;
        }
        catch(DmlException e){
            System.debug('Error updating account: '+e);
            updatedRec = false;
        }
        */
        //Map<List<Warrant_Batch__c>, List<Warrant__c>> mapWBandWR = new Map<List<Warrant_Batch__c>, List<Warrant__c>>();
        //mapWBandWR.put(wbForUpdate, wrForUpdate);
        
        return updatedRec;
        
    }
    

}