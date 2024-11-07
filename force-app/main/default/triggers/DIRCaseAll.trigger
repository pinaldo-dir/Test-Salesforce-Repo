trigger DIRCaseAll on DIR_Case__c (after insert, after update,after delete, before insert, before update, before delete) {
    
    //Delete all records of aPlus records releted to CaseManagement
    if(trigger.isAfter && trigger.isDelete)  {
        DIRCaseTriggerHandler.deleteAllAplusRecoreds(Trigger.old);
       // OWCDeleteCMSharepoint.deleteAllAplusRecoreds(Trigger.old);
    }
    //All logic moved to DIRCaseTriggerHandler
    
    if(trigger.isBefore && trigger.isDelete && !OWCServiceUtility.isDeletedErrorClaim){
        
        DIRCaseTriggerHandler.validateBeforeCaseDelete(trigger.oldMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        List<DIR_Case__c> caseList = new List<DIR_Case__c>();
        for(DIR_Case__c c : trigger.new){
            if(c.Status__c != null && c.Status__c != trigger.oldMap.get(c.id).Status__c && c.Closed__c){
                caseList.add(c);
            }
        }
        if(caseList.size() > 0){
            DIRCaseTriggerHandler.updateClosedCaseAssignedHistory(caseList);
        }
    }
    // ldavala changes 06.20.2018 - added trigger.newMap to list of parameters
    DIRCaseTriggerHandler.triggerHandler(trigger.new, trigger.oldMap, trigger.newMap, trigger.isUpdate, trigger.isInsert, trigger.isBefore, trigger.isAfter);
   
}