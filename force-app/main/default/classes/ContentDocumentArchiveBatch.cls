global without sharing class ContentDocumentArchiveBatch implements Database.Batchable<SObject> {

    //ID of Case as parameter
    global final list<string> listDIR= new list<string>();

    //default constructor
    global ContentDocumentArchiveBatch(){
        
    }
    
    global ContentDocumentArchiveBatch(list<DIR_Case__c> listDIR) {
        
        for (DIR_Case__c dirCase : listDIR) {
            this.listDIR.add(dirCase.Id);
        }
        //this.listDIR.addall((new Map<id,SObject>(listDIR)).keySet());
        //this.listDIR = listDIR;

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
         System.debug('ContentDocumentArchive Batch start');
        return Database.getQueryLocator([Select Id, File_Name__c, APlus_Json__c,
                                         ( Select Id, ContentDocument.title, ContentDocumentId, LinkedEntityId, ShareType, Visibility From ContentDocumentLinks ) 
                                         FROM Attachments_New__c
                                         WHERE related_id__c IN:listDIR AND Archive__c = false]);
    }

    
    global void execute(Database.BatchableContext c, List<sObject> scope)
    {

        List<Attachments_New__c> objBList = (List<Attachments_New__c>)scope;
        List<OWCServiceUtility.attachmentPlusWrapperObj> objClist = new List<OWCServiceUtility.attachmentPlusWrapperObj>();
        //List<ContentDocumentLink> conLink = new List<ContentDocumentLink>();
        List<ContentDocument> conDocumentList = new List<ContentDocument>();
        System.debug('Attachments_New__c');
        for(Attachments_New__c attach: objBList){
            attach.Archive__c = true;
            
            //update Attachment+data fileName
            List<OWCServiceUtility.attachmentPlusWrapperObj> attPlusObj;
            if(String.isNotBlank(attach.APlus_Json__c)){
                attPlusObj = (List<OWCServiceUtility.attachmentPlusWrapperObj>) JSON.deserialize(attach.APlus_Json__c, List<OWCServiceUtility.attachmentPlusWrapperObj>.class);
            }
            
            if(attPlusObj != null && attPlusObj.size() > 0){
                for(OWCServiceUtility.attachmentPlusWrapperObj attachData : attPlusObj){
                    if((attachData.fieldName == 'File_Name') && (!attachData.value.startsWithIgnoreCase('!Archived!-'))){
                        attachData.value =  '!Archived!-' + attachData.value; 
                    }
                    objClist.add(attachData);
                }
            }
            //Serialize the JSON list and assign it to APlus_Json__c field
            attach.APlus_Json__c = JSON.serialize(objClist);
            System.debug('attach' + attach.Archive__c);
            for(ContentDocumentLink con: attach.ContentDocumentLinks){
                System.debug('content document title' +  con.ContentDocument.title);
                if( !con.ContentDocument.title.startsWithIgnoreCase('!Archived!-'))
                {
                    ContentDocument conDocument = new ContentDocument();
                    conDocument.id = con.ContentDocument.id;
                    conDocument.title = '!Archived!-' + con.ContentDocument.title;
                    conDocumentList.add(conDocument);
                }
               
            }
        }
        update objBList;
        //update objCList;
        update conDocumentList;
        
    }
    
    global void finish(Database.BatchableContext info)
    {  
        System.debug('ContentDocumentArchive Batch Finish');
        AsyncApexJob job = [Select Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                            CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, 
                            TotalJobItems from AsyncApexJob where Id = :info.getJobId()];
        
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
        mail.setSubject('Content Document Archive Batch - ' + job.Status);
        mail.setHtmlBody(html);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
}