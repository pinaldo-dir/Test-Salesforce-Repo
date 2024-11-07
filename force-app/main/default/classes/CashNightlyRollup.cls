/*
Runs nightly, scheduled by the ScheduleCashNightlyRollupFromCP class, q.v.

This is a failsafe and a catch-up for older records that the Phase 2 updated automation may not hit. It may turn out we don't need this after a while.

1) Finds Cases with the most recently modified deposited Case Payments and Warrants where the Nightly_Rollup__c == FALSE.
2) Then queries for all the CPs and Warrants under each case.
3) Updates the Nightly_Rollup__c field to TRUE on a max of 500 CPs and 500 Warrants under each case.
4) This update then triggers the Case Payment flow and Warrant flow to update the Warrants_Pending__c, Funds_Drawn_On_Deposits__c,
    and Deposited_Funds__c fields on each respective case.

Updating CP.Nightly_Rollup__c and Warr.Nightly_Rollup__c on all child records records would sometimes hit the flow limit error,
    and calling those flows for each record was redundant since the flows sum all the child CPs and Warrants under each Case anyway.
    By limiting to 20 records, we may redundantly process the same case over several nights, but that's better than never updating
    any records when the flow limit is reached.
*/

global without sharing class CashNightlyRollup implements Database.Batchable<sObject>, Database.Stateful{

    Set<Id> caseIdSet = new Set<Id>();
    List<Case_Payment__c> cpList = new List<Case_Payment__c>();
    List<Warrant__c> warrantList = new List<Warrant__c>();


    global CashNightlyRollup(){

        cpList.addAll([SELECT Case__c, Nightly_Rollup__c
                        FROM Case_Payment__c
                        WHERE Nightly_Rollup__c = FALSE
                            AND Deposited__c = TRUE
                            AND Case__r.Assigned_Deputy__c != NULL
                            AND (NOT ((Case__r.Closure_Disposition__c = 'Dismissed - Other' OR Case__r.Closure_Disposition__c = 'Other')
                                AND Case__r.Closure_Disposition_Other_Reason__c = NULL))
                        ORDER BY LastModifiedDate DESC
                        LIMIT 500]);
        
        warrantList.addAll([SELECT Case__c, Status__c, Amount__c, Nightly_Rollup__c
                                FROM Warrant__c
                                WHERE Nightly_Rollup__c = FALSE
                                    AND Case__r.Assigned_Deputy__c != NULL
                                    AND (NOT ((Case__r.Closure_Disposition__c = 'Dismissed - Other' OR Case__r.Closure_Disposition__c = 'Other')
                                        AND Case__r.Closure_Disposition_Other_Reason__c = NULL))
                                ORDER BY LastModifiedDate DESC
                                LIMIT 500]);

        for(Case_Payment__c cp : cpList){
            caseIdSet.add(cp.Case__c);
        }
        for(Warrant__c warrant : warrantList){
            if(warrant.Case__c != null || warrant.Case__c != ''){ //Warrant__c.Case__c is only a lookup field.
                caseIdSet.add(warrant.Case__c);
            }
        }
    }


    global Database.QueryLocator start(Database.BatchableContext info){

        //LIMIT 750 here, but because of possible dupes, there could be much fewer than 750.
        return Database.getQueryLocator(
            'SELECT Id, Name, Warrants_Pending__c, Funds_Drawn_On_Deposits__c, Deposited_Funds__c, LastModifiedDate '
                + 'FROM DIR_Case__c '
                + 'WHERE Id IN :caseIdSet '
                + 'ORDER BY LastModifiedDate DESC '
                + 'LIMIT 750'
        );

    }

    global void execute(Database.BatchableContext info, List<sObject> scope){
        // System.debug('80 scope: ' + scope);

        List<DIR_Case__c> dirCases = (List<DIR_Case__c>)scope;
        List<Case_Payment__c> cpsToUpdate = new List<Case_Payment__c>();
        List<Warrant__c> warrantsToUpdate = new List<Warrant__c>();
        List<DIR_Case__c> casesToUpdate = new List<DIR_Case__c>();

        for(DIR_Case__c dirCase : dirCases){
            // System.debug('86 dirCase: ' + dirCase);

            //We technically only have to update one CP to trigger the CP flow to rollup CP amounts to the case. Limiting 20 here will prevent CP flow limit errors, although
            // it could mean we process the same case over multiple runs of this rollup code.

            //Running this query outside the dirCases loop, as would be best practice, results in frequent 'invalid query locator' errors.
            for(Case_Payment__c cp : [SELECT Id, Name, Case__c, Nightly_Rollup__c FROM Case_Payment__c WHERE Nightly_Rollup__c = FALSE AND Case__c = :dirCase.Id LIMIT 20]){
				cp.Nightly_Rollup__c = TRUE;
				cpsToUpdate.add(cp);
			}    

            //There's no Warrant flow, so we need to roll up those amounts to the Case here.
            Decimal sumOfPrintedWarrants = 0.00;
            Decimal sumOfPendingWarrants = 0.00;

            //Running this query outside the dirCases loop, as would be best practice, results in frequent 'invalid query locator' errors.
            for(Warrant__c warrant : [SELECT Id, Name, Nightly_Rollup__c, Status__c, Amount__c FROM Warrant__c WHERE Case__c = :dirCase.Id]){
                if(warrant.Nightly_Rollup__c == FALSE){
                    warrant.Nightly_Rollup__c = TRUE;
                    warrantsToUpdate.add(warrant);
                }

                if(warrant.Amount__c != NULL){
                    if(warrant.Status__c == 'Printed' || warrant.Status__c == 'UWF Allocation'){
                        sumOfPrintedWarrants += warrant.Amount__c;
                    }else if(warrant.Status__c == 'New' || warrant.Status__c == 'Pending Approval' || warrant.Status__c == 'Not Approved' || 
                            warrant.Status__c == 'Approved' || warrant.Status__c == 'Secondary Approval Needed'){
                        sumOfPendingWarrants += warrant.Amount__c;
                    }
                }
            }

            dirCase.Funds_Drawn_On_Deposits__c = sumOfPrintedWarrants;
            dirCase.Warrants_Pending__c = sumOfPendingWarrants;
            casesToUpdate.add(dirCase);

        }

        List<Trigger_Settings__c> triggerSettings = [SELECT Id, Name, Is_Active__c
                                                        FROM Trigger_Settings__c
                                                        WHERE Is_Active__c = TRUE];
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = FALSE;
        }
        update triggerSettings;

        update cpsToUpdate;
        update warrantsToUpdate;
        update casesToUpdate;

        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = TRUE;
        }
        update triggerSettings;
    }

    global void finish(Database.BatchableContext info){

        AsyncApexJob job = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                            FROM AsyncApexJob
                            WHERE Id = :info.getJobId()];
        
        sendJobCompleteEmail(job);
     }


     private void sendJobCompleteEmail(AsyncApexJob job) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {job.CreatedBy.Email};

        String body = ''
            + '<div style="font: bold 16px Arial; margin: 10px 0;">AsyncApexJob:</div>'
            + '<table style="font: normal 12px verdana;" border="1" cellpadding="5" cellspacing="0" width="100%">'
            + '     <tr style="font-weight: bold">'
            + '         <td>Total Job Items</td>'
            + '         <td>Job Items Processed</td>'
            + '         <td>Number of Errors</td>'
            + '         <td>Apex Class Id'
            + '         <td>Status</td>'
            + '         <td>Job Type</td>'
            + '         <td>Domain</td>'
            + '         <td>Created By</td>'
            + '         <td>Created Date</td>'
            + '         <td>Completed Date</td>'
            + '     </tr>'
            + '     <tr>'
            + '         <td>' + job.TotalJobItems + '</td>'
            + '         <td>' + job.JobItemsProcessed + '</td>'
            + '         <td>' + job.NumberOfErrors + '</td>'
            + '         <td>' + job.ApexClassId + '</td>'
            + '         <td>' + job.Status + '</td>'
            + '         <td>' + job.JobType + '</td>'
            + '         <td>' + URL.getOrgDomainUrl().toExternalForm() + '</td>'
            + '         <td>' + job.CreatedBy.Name + '</td>'
            + '         <td>' + job.CreatedDate + '</td>'
            + '         <td>' + job.CompletedDate + '</td>'
            + '     </tr>'
            + '</table>'
            + '<br/>';
        
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov', 'schandrasekar@dir.ca.gov'});
        mail.setSubject('CashNightlyRollup Status - ' + job.Status);
        mail.setHtmlBody(body);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}