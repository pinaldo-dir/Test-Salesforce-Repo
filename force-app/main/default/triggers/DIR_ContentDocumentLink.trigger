trigger DIR_ContentDocumentLink on ContentDocumentLink (before delete, after insert) {
    if(Label.runRegistrationTrigger=='true'){
        //stop trigger execution if document Link record is creating from CreateFileWebService
        if(CreateFileWebService.stopTriggerFromCreateFileWebService) return;
        if(trigger.isBefore && trigger.isDelete && A_Plus_Controller.isNotAplusMode){
            DIR_ContentDocumentLinkTriggerHandler.onBeforeDelete(trigger.oldMap);
        }
        
        if(trigger.isAfter && trigger.isInsert){
            
            DIR_ContentDocumentLinkTriggerHandler.onAfterInsert(trigger.newMap);
            //SharePoint File Upload
            ContentDocumentLinkHandler.uploadFilesOnSharePoint(Trigger.New);
        }
    }
}