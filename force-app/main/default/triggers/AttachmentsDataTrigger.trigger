trigger AttachmentsDataTrigger on Attachments_Data__c (after insert, after update) {
	if (Trigger.isAfter){
        if(Trigger.isUpdate){
            AttachmentsDataTriggerHandler.afterUpdateAttachmentsDataTriggerHandler(Trigger.New, Trigger.OldMap);
        }
        if(Trigger.isInsert){
            AttachmentsDataTriggerHandler.afterInsertAttachmentsDataTriggerHandler(Trigger.New);
        }
    }  
}