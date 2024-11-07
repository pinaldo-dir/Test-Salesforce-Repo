trigger DIR_Employee on DIR_Employee__c (after update) {
if(Trigger_Settings__c.getInstance('DIR_EmployeeTrigger').Is_Active__c){    
    if (Trigger.isAfter){
        if(Trigger.isUpdate){
            
            //Update Deputy On Meeting
            DIREmployeeTriggerHandler.updateDeputyOnMeeting(trigger.new,trigger.oldMap);

        }
    }
}
}