trigger Attachment on Attachment (after insert, after update, before delete, before insert, before update) {
	GenerateAttachmentsPlusAction.runHandler();
    
    if(Trigger.isAfter && Trigger.isInsert){
        OWCNintexAttachmentsConversion.convertAttachmentsintoFiles(Trigger.new);
    }
}