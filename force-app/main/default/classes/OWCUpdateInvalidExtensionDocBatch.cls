/*
* Class Name : OWCUpdateInvalidExtensionDocBatch
* Description : Used to update the .excel and .wordx document on sharepoint.
* Created Date : 05-09-2022
* Created By : Akash Som
*/
global class OWCUpdateInvalidExtensionDocBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public DateTime formattedFromDate; //'2022-08-12';
    public DateTime formattedToDate; //'2022-07-11';
    
    global OWCUpdateInvalidExtensionDocBatch(String fromDate, String toDate){
        Date fromDates = !Test.isRunningTest() ? Date.parse(fromDate) : System.today().addDays(-1);
        Date toDates = !Test.isRunningTest() ? Date.parse(toDate) : System.today().addDays(1);
        formattedFromDate = datetime.newInstance(fromDates.year(), fromDates.month(),fromDates.day());
        formattedToDate = datetime.newInstance(toDates.year(), toDates.month(),toDates.day());
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query= 'SELECT Id, CreatedDate, LastModifiedDate, Release_to_Public__c, Share_Point_Item_Id__c, Case_Management__c FROM Attachments_New__c';
        query += ' WHERE CreatedDate >=: formattedFromDate AND CreatedDate <=: formattedToDate';
        query += ' AND Release_to_Public__c = false';
        query += ' AND Share_Point_Item_Id__c != null';
        System.debug('query ::: '+query);
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Attachments_New__c> scope){
        System.debug('scope ::: '+scope);
        List<Attachments_New__c> attachToBeUpdated = new List<Attachments_New__c>();
        for(Attachments_New__c attObj : scope){
            deleteFileWrapper wrapperObj = new deleteFileWrapper();
            wrapperObj.aPlusId = attObj.Id;
            wrapperObj.sharePointDocumentId = attObj.Share_Point_Item_Id__c;
            Http http = new Http();
            HttpRequest moveRequest = new HttpRequest();
            moveRequest.setMethod('POST');
            moveRequest.setHeader('Accept', '*/*');
            moveRequest.setEndpoint('callout:SharePointNamedCred/api/createFile');
            moveRequest.setHeader('Content-Type', 'application/json');
            moveRequest.setHeader('client_id', '{!$Credential.UserName}');
            moveRequest.setHeader('client_secret', '{!$Credential.Password}');
            moveRequest.setTimeout(120000);
            moveRequest.setBody(json.serialize(wrapperObj));
            HttpResponse res = http.send(moveRequest);
            if(res.getStatusCode() == 201){
                attObj.Share_Point_Item_Id__c = '';
                attObj.Sharepoint_File_Status__c = '';
                attObj.Sharepoint_File_Upload_Error__c = '';
                attachToBeUpdated.add(attObj);
            }
        }
        if(attachToBeUpdated.size() > 0){
            update attachToBeUpdated;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        OWCUploadValidExtensionDocBatch scope = new OWCUploadValidExtensionDocBatch(formattedFromDate, formattedToDate);
        Database.executeBatch(scope,1);
    }
    
    public class deleteFileWrapper{
        public String aPlusId {get;set;}
        public String sharePointDocumentId {get;set;}
    }
}