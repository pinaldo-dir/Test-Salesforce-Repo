trigger Task_Trigger on Task (before insert, before update) {
    
	if(trigger.isBefore) {
        if(trigger.isInsert){
           NintexTaskTriggerHandler.onBeforeInsert(trigger.new);
        }
		DIR_TaskTriggerHandler.onBeforeUpsert(trigger.new, trigger.isInsert ? null : trigger.oldMap);
        
	}
	
}