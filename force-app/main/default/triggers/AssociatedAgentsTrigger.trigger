trigger AssociatedAgentsTrigger on Associated_Agents__c (before insert, after insert) {
    if(trigger.isBefore ){
        if(trigger.isInsert){
            AssociatedAgentsTriggerHandler.beforeInsertOperation(trigger.new);
        }
    }
    else if(trigger.isAfter){ 
        if(trigger.isInsert){
            if(AssociatedAgentsTriggerHandler.isFirstTime){
                AssociatedAgentsTriggerHandler.isFirstTime = false;
                AssociatedAgentsTriggerHandler.afterInsertOperation(trigger.new);
            }            
        }
    }
    
}