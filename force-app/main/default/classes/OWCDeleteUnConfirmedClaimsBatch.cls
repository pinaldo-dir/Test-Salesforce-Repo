/**
 * @File Name          : OWCDeleteUnConfirmedClaimsBatch.cls
 * @Test Class         : 
 * @Description        : Enhance current automated process to purge “Incomplete” online claim forms that are 180 days since ‘Last Modified date’.
 * @JIRA Reference     : https://propoint-technology.atlassian.net/browse/OWC-218
 * @Author             : Vikas Singh
 * @Last Modified By   : vikas@cloudsciencelabs.com
 * @Last Modified On   : 23/12/2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 **/
global class OWCDeleteUnConfirmedClaimsBatch implements Database.Batchable<sObject>{
    DateTime todayDate ;
    
    global OWCDeleteUnConfirmedClaimsBatch(Integer noOfDays){
        todayDate = System.now().addDays(-noOfDays);
    }
    //Fetching all the online claim Closed having lastmodifieddate less than 180 days 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([
            SELECT ID,Name,LastModifiedDate 
            FROM DIR_Case__c  
            WHERE Status__c = 'Closed' AND Intake_Origin__c = 'Online'  
            AND  Online_Claim_Account__c != null 
            AND Closure_Disposition__c = 'Not confirmed by Claimant' 
            AND LastModifiedDate <: todayDate 
        ]);
    }

    global void execute(Database.BatchableContext BC, List<DIR_Case__c>scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}