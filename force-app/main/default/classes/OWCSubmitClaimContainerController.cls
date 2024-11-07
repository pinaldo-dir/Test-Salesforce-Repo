/*Name: OWCSubmitClaimContainerController
* Description: This class is used to get the current user case management records whose status is 'Not Confirmed'.
* Primary Record: Case Management
*/ 
public with sharing class OWCSubmitClaimContainerController {
    @AuraEnabled
    public static DIR_Case__c getSubmitClaimConfirmation(Id recordId){
        try {
            System.debug('recordId ::: '+recordId);
            DIR_Case__c caseList = [SELECT ID, Status__c,CreatedById,Timer__c from DIR_Case__c WHERE Id =: recordId
                                  AND CreatedById =: userInfo.getUserId()
                                   ];
            System.debug('caseList ::: '+caseList);
            if(caseList != null && caseList.Status__c == 'Not Confirmed'){
                return caseList;
            }
            else{
                return null; 
            }
        } catch (Exception e) {
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            throw new AuraHandledException(errorMessage);
        }
    }
	
    @AuraEnabled
    public static boolean submitClaimantConfirmationRecords(List<String> contentIds,Id recordId){
        try {
            System.debug('contentVersionIds  ::: '+contentIds[0]);
            System.debug('recordId ::: '+recordId);
            // Get all contentVersion records
            List<ContentVersion> contentVersionRecs = [SELECT Id, contentDocumentId FROM ContentVersion WHERE Id IN: contentIds];
            // Create content DocumentLink List
            List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
            for(ContentVersion conObj : contentVersionRecs){
                ContentDocumentLink contentObj = new ContentDocumentLink();
                contentObj.linkedEntityId = recordId;
                contentObj.contentDocumentId = conObj.contentDocumentId;
                contentDocList.add(contentObj);
            }
            if(contentDocList.size() > 0){
                insert contentDocList;
            }
            
            DIR_Case__c caseList = [SELECT ID, Status__c,  CreatedById from DIR_Case__c WHERE Id =: recordId];
            caseList.Status__c = 'New';
            update caseList;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}