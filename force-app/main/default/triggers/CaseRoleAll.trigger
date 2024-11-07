Trigger CaseRoleAll on Case_Role__c (before insert, before update, after insert, after update, after delete) {

    if(Trigger_Settings__c.getInstance('CaseRoleAll').Is_Active__c){
        
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                caseRollMethods.applyLocation(Trigger.new);
                InsertAccountName(Trigger.new);
            }
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) {
                caseRollMethods.countDefs(Trigger.new);            
                caseRollMethods.createRelatedParty(Trigger.new);
                if(CaseRoleTriggerHandler.runAfterInsert){
                    CaseRoleTriggerHandler.afterInsertOperation(Trigger.newMap);
                    CaseRoleTriggerHandler.runAfterInsert = false;
                }
                // PT-000045:Consolidate Multiple Triggers Per Object
                if(!Test.isRunningTest()){
                GenerateFieldHistoryAction.runHandler();
                }
                
            }
            else if(Trigger.isUpdate) {
                //Only countdefs if update to case role is on Role or Status
                caseRollMethods.countDefs(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
                if(!Test.isRunningTest()){
                GenerateFieldHistoryAction.runHandler();
                }
            }
            else if(Trigger.isDelete){
                caseRollMethods.countDefs(Trigger.old);
            }
        }
    }
        
    public void InsertAccountName(List<Case_Role__c> newList){
        set<Id> idSet = new set<Id>();
        for(Case_Role__c cr : newList){
            if(!idSet.contains(cr.Entity__c)){
                idSet.add(cr.Entity__c);
            }
        }
        Map<Id, Account> accountMap = new Map<Id,Account>([SELECT Id, Name, firstName, lastName, IsPersonAccount FROM Account WHERE Id IN: idSet]);
        for(Case_Role__c cr : newList){
            if (accountMap.size() > 0){
                Account a = accountMap.get(cr.Entity__c);
                
                if(a.IsPersonAccount){
                    cr.Account_Name__c = a.firstName+' '+a.lastName;
                }
                else{
                    cr.Account_Name__c = a.Name;
                }
            }    
        }
            
    }

}