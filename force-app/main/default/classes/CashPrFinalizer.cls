public with sharing class CashPrFinalizer implements Finalizer {
    
    Id casePaymentId;
    String casePaymentName;
    Map<String, List<Id>> qableJobIdMap;
    String errorMessage;
    

    public CashPrFinalizer(Id cpId, String cpName, Map<String, List<Id>> qJobIdMap, String errorMsg) {
        casePaymentId = cpId;
        casePaymentName = cpName;
        qableJobIdMap = qJobIdMap;
        errorMessage = errorMsg;
    }

    public void execute(FinalizerContext fc){

        if(errorMessage == null || errorMessage == ''){

            Id createPrsQJobId = qableJobIdMap.get('Create PRs')[0];
            
            AsyncApexJob createPrsJob;
            if(!Test.isRunningTest()){
                createPrsJob = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                                    CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                                                FROM AsyncApexJob
                                                WHERE Id = :createPrsQJobId];
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(!Test.isRunningTest()){
                mail.setToAddresses(new List<String>{createPrsJob.CreatedBy.Email});
            }else{
                Id userId = UserInfo.getUserId();
                User runningUser = [SELECT Email FROM User WHERE Id = :userId];
                mail.setToAddresses(new List<String>{runningUser.Email});
            }

            mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov', 'schandrasekar@dir.ca.gov'});
            mail.setSubject('Case Payment ' + casePaymentName + ' Posting Status - ' + fc.getResult());
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
            String cpUrl = baseURL + casePaymentId;
            
            String body = ''
                + '<div style="font: bold 16px Arial; margin: 10px 0;">The Case Payment you posted, <a href="' + cpUrl + '">' + casePaymentName + '</a>, has been updated. '
                +       'Click or copy and paste this link into your browser:<br/><a href="'+ cpUrl  + '">' + cpUrl + '</a><br/><br/></div>'
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
        }else{

            Id createPrsQJobId = qableJobIdMap.get('Create PRs')[0];
            
            AsyncApexJob createPrsJob;
            if(!Test.isRunningTest()){
                createPrsJob = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                                    CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                                                FROM AsyncApexJob
                                                WHERE Id = :createPrsQJobId];
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(!Test.isRunningTest()){
                mail.setToAddresses(new List<String>{createPrsJob.CreatedBy.Email});
            }else{
                Id userId = UserInfo.getUserId();
                User runningUser = [SELECT Email FROM User WHERE Id = :userId];
                mail.setToAddresses(new List<String>{runningUser.Email});
            }
            
            mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov', 'schandrasekar@dir.ca.gov'});
            mail.setSubject('Case Payment ' + casePaymentName + ' Posting Status - ERROR');
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
            String cpUrl = baseURL + casePaymentId;
            
            String body = ''
                + '<div style="font: bold 16px Arial; margin: 10px 0;">Your attempt to post Case Payment <a href="' + cpUrl + '">' + casePaymentName + '</a> failed with error:<br/><br/>'
                + '"' + errorMessage + '"<br/><br/>'
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