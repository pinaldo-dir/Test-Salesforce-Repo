trigger ContentDocumentLinkTrigger on ContentDocumentLink (after Insert, before Delete) {
    
    ContentDocumentLinkHandler handler = new ContentDocumentLinkHandler();
    //stop trigger execution if document Link record is creating from CreateFileWebService
    if(CreateFileWebService.stopTriggerFromCreateFileWebService) return;
    if(trigger.isInsert && trigger.isAfter){
        handler.onAfterInsert(Trigger.New, Trigger.NewMap);
        //SharePoint File Upload
        //ContentDocumentLinkHandler.uploadFilesOnSharePoint(Trigger.New);
        
        //handler.broadcastReg_attachment_counter(trigger.new, 'insert');
    }
     
    if(trigger.isDelete && trigger.isBefore){
        handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
        //handler.broadcastReg_attachment_counter(trigger.old, 'delete');
    }

}