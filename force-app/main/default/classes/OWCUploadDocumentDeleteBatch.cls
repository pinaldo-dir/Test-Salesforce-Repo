global class OWCUploadDocumentDeleteBatch implements Database.Batchable<sObject>{
    public String success = 'success';
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Share_Point_Item_Id__c,Sharepoint_File_Status__c,Sharepoint_File_Upload_Error__c FROM Attachments_New__c WHERE Share_Point_Item_Id__c != null AND Sharepoint_File_Status__c = '+ '\'' + success+ '\'' ;
        return Database.getQueryLocator(query);
    } 
    global void execute(Database.BatchableContext BC, List<Attachments_New__c> attachPlusRecords){
        
        Set<Id> attachIdSet = new Set<Id>();
        for(Attachments_New__c attachObj : attachPlusRecords){
            attachIdSet.add(attachObj.Id);
        } 
        //get all contentDocumentIds to delete
        List<ContentDocumentLink> conDocIds = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: attachIdSet];
        //List of ContentDocumentId
        List<Id> contentDocIdToDelete = new List<Id>();
        for(ContentDocumentLink conDocLinkObj : conDocIds){
            contentDocIdToDelete.add(conDocLinkObj.ContentDocumentId);
        }
        
        Database.delete(contentDocIdToDelete) ;
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('finish');
    }
}