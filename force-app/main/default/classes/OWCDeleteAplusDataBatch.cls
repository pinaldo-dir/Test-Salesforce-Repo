/**
 * @File Name          : OnlineClaimDraftDeleteBatch.cls
 * @Test Class         : 
 * @Description        : Delete all the Aplus Data records from the org. 
 * 
 * */
public class OWCDeleteAplusDataBatch implements Database.Batchable<sObject>{
        
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT ID 
            FROM Attachments_Data__c 
        ]);
    }
    public void execute(Database.BatchableContext BC, List<Attachments_Data__c> aPlusDatas){
        delete aPlusDatas;
    }
    
    public void finish(Database.BatchableContext BC){
    }
}