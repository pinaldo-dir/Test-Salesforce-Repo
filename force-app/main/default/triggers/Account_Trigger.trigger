trigger Account_Trigger on Account (after update, after insert, before update, before insert) {
	if(trigger.isAfter && trigger.isUpdate) {
		Account_Methods.afterUpdate(trigger.new, trigger.oldMap);
	}
    
    if (trigger.isBefore && trigger.isInsert){
        Account_Methods.beforeInsert(trigger.new);
        OWCDuplicateAccountHanlder.sendDuplicateOnInsert(Trigger.new);
    }
    
    if (trigger.isBefore && trigger.isUpdate){
        Account_Methods.beforeUpdate(trigger.new, trigger.oldMap);  
        OWCDuplicateAccountHanlder.sendDuplicateOnUpdate(Trigger.new);
    }
    
    if (trigger.isAfter && trigger.isInsert){
        Account_Methods.afterInsert(trigger.new);
    }
    
}