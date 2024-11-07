public class OWCCaseClosedOnTimerExpiredBatch implements Database.Batchable<sObject>{
    Integer noOfDays;
    public OWCCaseClosedOnTimerExpiredBatch(Integer expireDays){
        noOfDays = expireDays;
    }
	public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT ID,Name,LastModifiedDate 
            FROM DIR_Case__c  
            WHERE Status__c = 'Not Confirmed' AND Timer__c <=: noOfDays
        ]);
    }
    public void execute(Database.BatchableContext BC, List<DIR_Case__c> caseRecords){
        for(DIR_Case__c cse : caseRecords){
            cse.put('Status__c','Closed'); 
            cse.put('Case_Closed_Date__c', Date.today());
        }
        update caseRecords;
    }
    
    public void finish(Database.BatchableContext BC){
    }
}