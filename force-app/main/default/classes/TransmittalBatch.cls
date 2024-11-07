global without sharing class TransmittalBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String cpIds;
    public Integer numberOfCps = 0;
    public Id transmittalId;
    
    public TransmittalBatch(String cpIds, Id transmittalId) {
        this.cpIds = cpIds;
        this.transmittalId = transmittalId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){ 

        //TODO: verify these filters, clean up extraneous filters
        return Database.getQueryLocator(
            'SELECT Id, Transmittal__c, Transmittal_Unit__c, Status__c, Case__c, Case__r.Id, Receipt__c, Receipt__r.Bank_Deposit_Date__c '
                + 'FROM Case_Payment__c '
                + 'WHERE Id IN ' + cpIds
        );
    }
    
    global void execute(Database.BatchableContext info, List<Case_Payment__c> queryScope){

        for(Case_Payment__c cp : queryScope){
            cp.Transmittal__c = transmittalId;
        }

        update queryScope;
        numberOfCps += queryScope.size();
    }
    
    global void finish(Database.BatchableContext info) {

        AsyncApexJob job = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                            FROM AsyncApexJob
                            WHERE Id = :info.getJobId()];
        
        sendJobCompleteEmail(job);
    }
    
    private void sendJobCompleteEmail(AsyncApexJob job) {

        Transmittal__c transmittal = [SELECT Id, Name
                                        FROM Transmittal__c
                                        WHERE Id = :transmittalId];


        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {job.CreatedBy.Email};
        
        String html = '<div style="font: bold 16px Arial; margin: 10px 0;">Your Transmittal Batch request is now complete.</div><br/>';
        
        String transmittalReportId;
        if(!Test.isRunningTest()){
            transmittalReportId = [SELECT Id, DeveloperName FROM Report WHERE DeveloperName = 'Transmittal_Report'][0].Id;
        }else{
            transmittalReportId = '00Or0000000z176EAA'; //not so fake report id just for the test
        }
        String transmittalUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + transmittal.Id;
        String transmittalReportUrl = URL.getSalesforceBaseUrl().toExternalForm() +
            '/lightning/r/Report/' + transmittalReportId + '/view?fv1=' + transmittal.Name; //"CCU Transmittal" report

        html += ('<div style="font: bold 16px Arial; margin: 10px 0;">Your Transmittal contains ' + numberOfCps + ' Case Payment(s).</div><br/>'
            + '<div style="font: bold 16px Arial; margin: 10px 0;">To view the CCU Transmittal report, ' 
                + 'click: <a href="' + transmittalReportUrl + '">CCU Transmittal report for ' + transmittal.Name + '</a>.</div><br/>'
            + '<div style="font: bold 16px Arial; margin: 10px 0;">To view the Transmittal record, '
                + 'click: <a href="' + transmittalUrl + '">' + transmittal.Name + '</a>.</div><br/><br/>');
    
        html += ('<div style="font: bold 16px Arial; margin: 10px 0;">AsyncApexJob:</div>'
            + '<table style="font: normal 12px verdana;" border="1" cellpadding="5" cellspacing="0" width="100%">'
                + '<tr style="font-weight: bold">'
                    + '<td>Total Job Items</td>'
                    + '<td>Job Items Processed</td>'
                    + '<td>Number of Errors</td>'
                    + '<td>Status</td>'
                    //+ '<td>Apex Class Id</td>'
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
            + '</table><br/>');
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov', 'schandrasekar@dir.ca.gov'});
        mail.setSubject('Transmittal Batch - ' + job.Status);
        mail.setHtmlBody(html);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}