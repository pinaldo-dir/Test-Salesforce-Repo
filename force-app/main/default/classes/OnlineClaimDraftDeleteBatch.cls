/**
 * @File Name          : OnlineClaimDraftDeleteBatch.cls
 * @Test Class         : 
 * @Description        : Retain draft claims for 180 days from the last date edited by external user. 
 * @JIRA Reference     : https://propoint-technology.atlassian.net/browse/OWC-336
 * @Author             : Koshambee
 * @Group              : Cloud Science Lab
 * @Last Modified By   : koshambee@cloudsciencelabs.com
 * @Last Modified On   : 08/09/2021, 02:30:00 PM
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    08/09/2021, 02:30:00 PM   Koshambee     Initial Version
 **/

global class OnlineClaimDraftDeleteBatch implements Database.Batchable<sObject>{
    DateTime todayDate ;
    global OnlineClaimDraftDeleteBatch(Integer noOfDays){
        todayDate = System.today().addDays(-noOfDays);
    }
    //Fetching all the online claim Draft having lastmodifieddate less than 180 days 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT ID,Name,LastModifiedDate 
            FROM Online_Claim_Draft__c 
            WHERE LastModifiedDate <: todayDate
        ]);
    }
    global void execute(Database.BatchableContext BC, List<Online_Claim_Draft__c>scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}