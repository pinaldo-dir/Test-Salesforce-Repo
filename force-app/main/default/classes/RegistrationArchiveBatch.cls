global without sharing class RegistrationArchiveBatch implements Database.Batchable<ContentDocumentLink>, Iterable<ContentDocumentLink>, Iterator<ContentDocumentLink>{
    
    public String query;
  	public Integer i;
    public List<ContentDocumentLink> cdlList;
    
    public RegistrationArchiveBatch(String q) {
        
        this.query = q;
        System.debug('Query:' + q);
        cdlList =  Database.query(q);
        i = 0;
    }
    
    public Iterator<ContentDocumentLink> Iterator(){
        return this;
    }
    
    public boolean hasNext() {
        if(cdlList.size() <= i)
            return false;
        else
            return true;
    }
    
    public ContentDocumentLink next() {
        i++;
        return cdlList[i-1];
    }
    
    global Iterable<ContentDocumentLink> start(Database.BatchableContext info){
       	/*
        String query = 'SELECT Id, LINkedEntityId, LINkedEntity.name, ContentDocumentId , ContentDocument.title FROM ContentDocumentLink' + 
			' WHERE LINkedEntityId IN (SELECT Id FROM License_Registration__c WHERE Status__c IN (\'Approved\', \'Closed\', \'Closed - Denied\', \'Closed - Duplicate\', \'Closed - INactive\', \'Closed - Rejected\', \'Closed - Revoked\', \'Closed_Suspended\', \'Closed - Withdrawn\', \'Closed - Renewed\', \'Expired\' )' +  
			' AND RecordType.Name IN (\'Car Wash\', \'Child Performer Services\', \'EntertaINment Work\', \'Farm Labor Contractor\', \'Garment Manufacturers AND Contractors\', \'Janitorial\', \'Permit to Employ MINors\', \'Talent Agency\'))'; 
		*/
        return new RegistrationArchiveBatch(query);
    }
    
    global void execute(Database.BatchableContext info, List<ContentDocumentLink> scopeX){
        List<ContentDocumentLink> objList = (List<ContentDocumentLink>)scopeX;
        List<ContentDocument> conDocumentList = new List<ContentDocument>();
        
        System.debug('RegistrationArchiveBatch');     
        for(ContentDocumentLink con : objList){
            
            if( !con.ContentDocument.title.startsWithIgnoreCase('!Archived!-'))
                {
                    ContentDocument conDocument = new ContentDocument();
                    conDocument.id = con.ContentDocumentId;
                    conDocument.title = '!Archived!-' + con.ContentDocument.title;
                    conDocumentList.add(conDocument);
                }
        }  
        update conDocumentList;
    }
    
    global void finish(Database.BatchableContext info) {
        System.debug('RegistrationArchiveBatch Finish');
        //Chains ContentDocumentArchiveBatch to update Aplus records, and Content Document Title.
        //Database.executeBatch(new ContentDocumentArchiveBatch(scopex));
        
        
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
        mail.setSubject('Registration Archive Batch - ' + job.Status);
        mail.setHtmlBody(html);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}