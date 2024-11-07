/*

*/
global without sharing class DIRCaseArchiveBatch implements Database.Batchable<sObject>, Database.Stateful { 
    
    public list<DIR_Case__c> scope = new list<DIR_Case__c> ();
    public static Boolean dirCaseArchive = true;
    public String query;
    
    
    public DIRCaseArchiveBatch(String q) {
        
        this.query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){
        /*
        string q = 'SELECT Id, Archive__c from DIR_Case__c WHERE Status__c = \'Closed\'' +
            ' AND ' + 'Case_Closed_Date__c < LAST_N_DAYS:366' + ' AND ' + 'Total_Penalties_Balance_Due__c = 0.00' +
            ' AND ' + 'Total_Wages_Balance_Due__c = 0.00' + ' AND ' + 'Total_Interest_Balance_Due__c = 0.00';
		*/
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<sObject> scopeX){
        List<DIR_Case__c> objList = (List<DIR_Case__c>)scopeX;
        System.debug('DIRCaseArchiveBatchexecute');     
        for(DIR_Case__c ci : objList) {
            if(dirCaseArchive){
                ci.Archive__c = true;
            }
            
            scope.add(ci);
        }
        if(dirCaseArchive){
            update objList;
        }
        
    }
    
    global void finish(Database.BatchableContext info) {
        System.debug('DIRCaseArchive Batch Finish');
        //Chains ContentDocumentArchiveBatch to update Aplus records, and Content Document Title.
        Database.executeBatch(new ContentDocumentArchiveBatch(scope),100);
        
        
        AsyncApexJob job = [Select Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                            CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, 
                            TotalJobItems from AsyncApexJob where Id = :info.getJobId()];
        
        // Send an email to the Apex job's submitter notifying of job completion.
        sendJobCompleteEmail(job);
        
    }
   
    private void sendJobCompleteEmail(AsyncApexJob job) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {job.CreatedBy.Email};
            String html = ''
            + '<table style="font: normal 12px verdana;" border="1" cellpadding="5" cellspacing="0" width="100%">'
            + '<tr style="font-weight: bold">'
            + '<td>Total Job Items</td>'
            + '<td>Job Items Processed</td>'
            + '<td>Number of Errors</td>'
            + '<td>Status</td>'
            + '<td>Job Type</td>'
            + '<td>Created By</td>'
            + '<td>Created Date</td>'
            + '<td>Completed Date</td>'
            + '</tr>'
            + '<tr>'
            + '<td>' + job.TotalJobItems + '</td>'
            + '<td>' + job.JobItemsProcessed + '</td>'
            + '<td>' + job.NumberOfErrors + '</td>'
            + '<td>' + job.Status + '</td>'
            //+ '<td><a href="https://login.salesforce.com/' + job.ApexClassId + '">' + job.ApexClassId + '</a></td>'
            + '<td>' + job.JobType + '</td>'
            + '<td>' + job.CreatedBy.Name + '</td>'
            + '<td>' + job.CreatedDate + '</td>'
            + '<td>' + job.CompletedDate + '</td>'
            + '</tr>'
            + '</table>'
            + '<br/>';
        mail.setToAddresses(toAddresses);
        mail.setSubject('DIR Case Archive Batch - ' + job.Status);
        mail.setHtmlBody(html);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
}