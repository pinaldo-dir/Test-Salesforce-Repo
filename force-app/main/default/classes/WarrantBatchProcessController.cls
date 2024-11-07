public with sharing class WarrantBatchProcessController {
    
    @AuraEnabled(cacheable=true)
    public static List<Warrant_Batch__c> getWBid(String apxWbName){
        System.debug('>>>>>>>>>>>>>>> getWBid---apxWbName >>>>>>>>>>>>>'+apxWbName);
        List<Warrant_Batch__c> wbNameIdList = new List<Warrant_Batch__c>([SELECT Id, Name, Status__c FROM Warrant_Batch__c WHERE Name=:apxWbName WITH SECURITY_ENFORCED]);
        System.debug('>>>>>>>>>>>>>>> getWBid --- wbNameIdList >>>>>>>>>>>>>>>'+wbNameIdList);
        return wbNameIdList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Warrant_Batch__c> getWarrantBatchDetails(String apxWbRecId){
        System.debug('>>>>>>>>>>>>>>> getWarrantBatchDetails---apxWbRecId >>>>>>>>>>>>>'+apxWbRecId);
        List<Warrant_Batch__c> wbWarrantList = new List<Warrant_Batch__c>([SELECT Id, Name, Status__c, Batch_Total__c, Void_Reason__c, OwnerId, Requesting_Cashier__c
        FROM Warrant_Batch__c WHERE Id=:apxWbRecId]);
        System.debug('>>>>>>>>>>>>>>> WB & WR Details >>>>>>>>>>>>>'+wbWarrantList);
        return wbWarrantList;
    }
    
}