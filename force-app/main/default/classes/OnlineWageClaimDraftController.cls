public with sharing class OnlineWageClaimDraftController {
    @AuraEnabled
    public static List<owcDraftWrapper> getDraftRecords(){
        try {
            List<Online_Claim_Draft__c> owcDraftList ;
            owcDraftList = [SELECT Id, LastModifiedDate, Name, CreatedById, Draft_JSON__c, Section_Id__c, Case_Management__c
                            FROM Online_Claim_Draft__c WHERE CreatedById =: userInfo.getUserId()  
                            AND Case_Management__c = null Order by CreatedDate DESC];
            List<owcDraftWrapper> draftWrapperList = new List<owcDraftWrapper>();
            
            
            if(owcDraftList.size() > 0){
                for(Online_Claim_Draft__c owcObj : owcDraftList){
                    owcDraftWrapper draftWrapperObj = new owcDraftWrapper();
                    draftWrapperObj.recordId = owcObj.Id;
                    draftWrapperObj.draftName = owcObj.Name;
                    draftWrapperObj.lastModifiedDate = (owcObj.LastModifiedDate).format('MM/dd/yyyy');
                    draftWrapperList.add(draftWrapperObj);
                }
            } 
            System.debug('draftWrapperList ::: '+draftWrapperList);
            return draftWrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class owcDraftWrapper{
        @AuraEnabled
        public String draftName{get;set;}
        @AuraEnabled
        public String recordId{get;set;}
        @AuraEnabled
        public String lastModifiedDate{get;set;}
    }
}