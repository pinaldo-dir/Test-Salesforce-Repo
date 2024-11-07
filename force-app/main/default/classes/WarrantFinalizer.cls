public with sharing class WarrantFinalizer implements Finalizer {

    String wbURL;
    Map<String, List<Id>> qableJobIdMap;
    String errorMessage;
    String action;

    public WarrantFinalizer(String wbLink, Map<String, List<Id>> qJobIdMap, String actType, String errorMsg) {
        wbURL = wbLink;
        qableJobIdMap = qJobIdMap;
        errorMessage = errorMsg;
        action = actType;
    }

    public void execute(FinalizerContext fc){
        if(errorMessage == null || errorMessage == ''){

            if(action == 'Insert'){
                Id insertWrJobId = qableJobIdMap.get('Insert Warrants')[0];
                AsyncApexJob insertWrJob;
                if(!Test.isRunningTest()){
                    insertWrJob = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                                        CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                                                    FROM AsyncApexJob
                                                    WHERE Id = :insertWrJobId];
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(!Test.isRunningTest()){
                    mail.setToAddresses(new List<String>{insertWrJob.CreatedBy.Email});
                }else{
                    Id userId = UserInfo.getUserId();
                    User runningUser = [SELECT Email FROM User WHERE Id = :userId];
                    mail.setToAddresses(new List<String>{runningUser.Email});
                }

                mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov', 'schandrasekar@dir.ca.gov'});
                mail.setSubject('Warrants Inserted - Status' + fc.getResult());
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
                String body = ''
                + wbURL
                + '<div style="font: bold 16px Arial; margin: 10px 0;">AsyncApexJob:</div>'
                + '<table style="font: normal 12px verdana;" border="1" cellpadding="5" cellspacing="0" width="100%">'
                + '<tr style="font-weight: bold">'
                + '<td>Job</td>'
                + '<td>Status</td>'
                + '<td>Job Type</td>'
                + '<td>Created By</td>'
                + '<td>Created Date</td>'
                + '<td>Completed Date</td>'
                + '</tr>';
            
                List<Id> jobIds = new List<Id>();
                for(String jobListName : qableJobIdMap.keySet()){
                    for(Id jobId : qableJobIdMap.get(jobListName)){
                        jobIds.add(jobId);
                    }
                }
        
                List<AsyncApexJob> jobs = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                                    CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                                                FROM AsyncApexJob
                                                WHERE Id IN :jobIds];
                
                String table = '';
                for(String jobListName : qableJobIdMap.keySet()){
                    for(Id jobId : qableJobIdMap.get(jobListName)){
                        for(AsyncApexJob job : jobs){
                            if(job.Id == jobId){
                                table += (
                                    + '<tr>'
                                    + '<td><a href="' + baseURL + job.ApexClassId + '">' + jobListName + '</a></td>'
                                    + '<td>' + job.Status + '</td>'
                                    + '<td>' + job.JobType + '</td>'
                                    + '<td>' + job.CreatedBy.Name + '</td>'
                                    + '<td>' + job.CreatedDate + '</td>'
                                    + '<td>' + job.CompletedDate + '</td>'
                                    + '</tr>'
                                );
                            }
                        }
                    }
                }
                table += ('</table><br/>');

                body += table;
                    
                mail.setHtmlBody(body);
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                }
            }
            else if(action == 'Update'){
                Id updateWrJobId;
                if(qableJobIdMap.containsKey('Update Warrants')){
                    updateWrJobId = qableJobIdMap.get('Update Warrants')[0];
                }
                else if(qableJobIdMap.containsKey('Update Warrant Pending')){
                    updateWrJobId = qableJobIdMap.get('Update Warrant Pending')[0];
                }
                
                AsyncApexJob updateWrJob;
                if(!Test.isRunningTest()){
                    updateWrJob = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                                        CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                                                    FROM AsyncApexJob
                                                    WHERE Id = :updateWrJobId];
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(!Test.isRunningTest()){
                    mail.setToAddresses(new List<String>{updateWrJob.CreatedBy.Email});
                }else{
                    Id userId = UserInfo.getUserId();
                    User runningUser = [SELECT Email FROM User WHERE Id = :userId];
                    mail.setToAddresses(new List<String>{runningUser.Email});
                }

                mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov', 'schandrasekar@dir.ca.gov'});
                mail.setSubject('Warrants Updated - Status' + fc.getResult());
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
                String body = ''
                + wbURL
                + '<div style="font: bold 16px Arial; margin: 10px 0;">AsyncApexJob:</div>'
                + '<table style="font: normal 12px verdana;" border="1" cellpadding="5" cellspacing="0" width="100%">'
                + '<tr style="font-weight: bold">'
                + '<td>Job</td>'
                + '<td>Status</td>'
                + '<td>Job Type</td>'
                + '<td>Created By</td>'
                + '<td>Created Date</td>'
                + '<td>Completed Date</td>'
                + '</tr>';
            
                List<Id> jobIds = new List<Id>();
                for(String jobListName : qableJobIdMap.keySet()){
                    for(Id jobId : qableJobIdMap.get(jobListName)){
                        jobIds.add(jobId);
                    }
                }
        
                List<AsyncApexJob> jobs = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                                    CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                                                FROM AsyncApexJob
                                                WHERE Id IN :jobIds];
                
                String table = '';
                for(String jobListName : qableJobIdMap.keySet()){
                    for(Id jobId : qableJobIdMap.get(jobListName)){
                        for(AsyncApexJob job : jobs){
                            if(job.Id == jobId){
                                table += (
                                    + '<tr>'
                                    + '<td><a href="' + baseURL + job.ApexClassId + '">' + jobListName + '</a></td>'
                                    + '<td>' + job.Status + '</td>'
                                    + '<td>' + job.JobType + '</td>'
                                    + '<td>' + job.CreatedBy.Name + '</td>'
                                    + '<td>' + job.CreatedDate + '</td>'
                                    + '<td>' + job.CompletedDate + '</td>'
                                    + '</tr>'
                                );
                            }
                        }
                    }
                }
                table += ('</table><br/>');

                body += table;
                    
                mail.setHtmlBody(body);
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                }
            }
        }
        else{

            if(action == 'Insert'){
                Id insertWrJobId = qableJobIdMap.get('Insert Warrants')[0];
            
                AsyncApexJob insertWrJob;
                if(!Test.isRunningTest()){
                    insertWrJob = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                                        CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                                                    FROM AsyncApexJob
                                                    WHERE Id = :insertWrJobId];
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(!Test.isRunningTest()){
                    mail.setToAddresses(new List<String>{insertWrJob.CreatedBy.Email});
                }else{
                    Id userId = UserInfo.getUserId();
                    User runningUser = [SELECT Email FROM User WHERE Id = :userId];
                    mail.setToAddresses(new List<String>{runningUser.Email});
                }
                
                mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov', 'schandrasekar@dir.ca.gov'});
                mail.setSubject('Warrants Inserted - Status - ERROR');
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
                String body = ''
                + wbURL
                + '<div style="font: bold 16px Arial; margin: 10px 0;">AsyncApexJob:</div>'
                + '<table style="font: normal 12px verdana;" border="1" cellpadding="5" cellspacing="0" width="100%">'
                + '<tr style="font-weight: bold">'
                + '<td>Job</td>'
                + '<td>Status</td>'
                + '<td>Job Type</td>'
                + '<td>Created By</td>'
                + '<td>Created Date</td>'
                + '<td>Completed Date</td>'
                + '</tr>';
            
                List<Id> jobIds = new List<Id>();
                for(String jobListName : qableJobIdMap.keySet()){
                    for(Id jobId : qableJobIdMap.get(jobListName)){
                        jobIds.add(jobId);
                    }
                }
        
                List<AsyncApexJob> jobs = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                                    CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                                                FROM AsyncApexJob
                                                WHERE Id IN :jobIds];
                
                String table = '';
                for(String jobListName : qableJobIdMap.keySet()){
                    for(Id jobId : qableJobIdMap.get(jobListName)){
                        for(AsyncApexJob job : jobs){
                            if(job.Id == jobId){
                                table += (
                                    + '<tr>'
                                    + '<td><a href="' + baseURL + job.ApexClassId + '">' + jobListName + '</a></td>'
                                    + '<td>' + job.TotalJobItems + '</td>'
                                    + '<td>' + job.JobType + '</td>'
                                    + '<td>' + job.CreatedBy.Name + '</td>'
                                    + '<td>' + job.CreatedDate + '</td>'
                                    + '<td>' + job.CompletedDate + '</td>'
                                    + '</tr>'
                                );
                            }
                        }
                    }
                }
                table += ('</table><br/>');

                body += table;
                    
                mail.setHtmlBody(body);
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                }
            
            }
            else if(action == 'Update'){
                Id updateWrJobId;
                if(qableJobIdMap.containsKey('Update Warrants')){
                    updateWrJobId = qableJobIdMap.get('Update Warrants')[0];
                }
                else if(qableJobIdMap.containsKey('Update Warrant Pending')){
                    updateWrJobId = qableJobIdMap.get('Update Warrant Pending')[0];
                }
                //Id updateWrJobId = qableJobIdMap.get('Update Warrants')[0];
            
                AsyncApexJob updateWrJob;
                if(!Test.isRunningTest()){
                    updateWrJob = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                                        CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                                                    FROM AsyncApexJob
                                                    WHERE Id = :updateWrJobId];
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(!Test.isRunningTest()){
                    mail.setToAddresses(new List<String>{updateWrJob.CreatedBy.Email});
                }else{
                    Id userId = UserInfo.getUserId();
                    User runningUser = [SELECT Email FROM User WHERE Id = :userId];
                    mail.setToAddresses(new List<String>{runningUser.Email});
                }
                
                mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov', 'schandrasekar@dir.ca.gov'});
                mail.setSubject('Warrants Updated - Status - ERROR');
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';

                String body = ''
                + wbURL
                + '<div style="font: bold 16px Arial; margin: 10px 0;">AsyncApexJob:</div>'
                + '<table style="font: normal 12px verdana;" border="1" cellpadding="5" cellspacing="0" width="100%">'
                + '<tr style="font-weight: bold">'
                + '<td>Job</td>'
                + '<td>Status</td>'
                + '<td>Job Type</td>'
                + '<td>Created By</td>'
                + '<td>Created Date</td>'
                + '<td>Completed Date</td>'
                + '</tr>';
            
                List<Id> jobIds = new List<Id>();
                for(String jobListName : qableJobIdMap.keySet()){
                    for(Id jobId : qableJobIdMap.get(jobListName)){
                        jobIds.add(jobId);
                    }
                }
        
                List<AsyncApexJob> jobs = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                                    CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                                                FROM AsyncApexJob
                                                WHERE Id IN :jobIds];
                
                String table = '';
                for(String jobListName : qableJobIdMap.keySet()){
                    for(Id jobId : qableJobIdMap.get(jobListName)){
                        for(AsyncApexJob job : jobs){
                            if(job.Id == jobId){
                                table += (
                                    + '<tr>'
                                    + '<td><a href="' + baseURL + job.ApexClassId + '">' + jobListName + '</a></td>'
                                    + '<td>' + job.TotalJobItems + '</td>'
                                    + '<td>' + job.JobType + '</td>'
                                    + '<td>' + job.CreatedBy.Name + '</td>'
                                    + '<td>' + job.CreatedDate + '</td>'
                                    + '<td>' + job.CompletedDate + '</td>'
                                    + '</tr>'
                                );
                            }
                        }
                    }
                }
                table += ('</table><br/>');

                body += table;
                    
                mail.setHtmlBody(body);
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                }
            }
        }
    }
}