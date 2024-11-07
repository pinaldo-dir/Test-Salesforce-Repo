trigger DIR_AttachmentsNew on Attachments_New__c (before insert, after insert,before delete,before update, after update) {
    
    
    
    if(Trigger.isBefore  && Trigger.isInsert){
        //Populate the ReletedId of aPlus Object in CaseManagent Lookup
        DIR_AttachmentsNewTriggerHandler.onBeforeInsert(Trigger.New);
    }
    
    if(Trigger.isBefore  && Trigger.isUpdate){
        if(AttachmentsTriggerHandler.runBeforeUpdate){
            AttachmentsTriggerHandler.runBeforeUpdate = false;
            AttachmentsTriggerHandler.beforeUpdateAttachmentsHandler(Trigger.NewMap, Trigger.OldMap);
        }
        
    }
    
    if(Trigger.isBefore  && Trigger.isdelete){
        if(A_Plus_Controller.isNotAplusMode){
            DIR_AttachmentsNewTriggerHandler.onBeforeDelete(trigger.oldMap); 
        }
    }
    if (Trigger.isAfter){
        if(Trigger.isUpdate){
            if(AttachmentsTriggerHandler.runAfterUpdate){
                AttachmentsTriggerHandler.runAfterUpdate = false; 
                AttachmentsTriggerHandler.afterUpdateAttachmentsHandler(Trigger.NewMap, Trigger.OldMap);
                AttachmentsTriggerHandler.updateAttachmentRecord(Trigger.NewMap, Trigger.OldMap);
                //Move file on MuleSoft
                AttachmentsTriggerHandler.moveFileOnSharePoint(Trigger.New,Trigger.oldMap);
            }
        }
    }
    
}