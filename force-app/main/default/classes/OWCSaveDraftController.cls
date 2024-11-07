/*Name: OWCSaveDraftController
* Description: This class is used to update the online claim draft record
* Primary Record: Online Claim Draft
* Related Records: Case Management
*/ 
public with sharing class OWCSaveDraftController {
    @AuraEnabled
    public static wrapperMsgObj createOWCJSONResponse(String onlineClaimDetails, String sectionId, String recordId){
        try {
            System.debug('onlineClaimDetails ::: '+onlineClaimDetails);
            System.debug('sectionId ::: '+sectionId);
            System.debug('recordId ::: '+recordId);
            wrapperMsgObj wrapperObj = new wrapperMsgObj();
            // Update the draft record if recordId is not null. Else create the new one.
            if(String.isNotBlank(recordId)){ 
                Online_Claim_Draft__c owcClaimDraftObj = [SELECT Id, CreatedById, Draft_JSON__c 
                                                          FROM Online_Claim_Draft__c WHERE
                                                          CreatedById =: userInfo.getUserId()
                                                          AND Id =: recordId LIMIT 1];
                owcClaimDraftObj.Draft_JSON__c = onlineClaimDetails; 
                owcClaimDraftObj.Section_Id__c = sectionId;
                wrapperObj.darftId = recordId;
                wrapperObj.toastMsg = 'Your Draft has been successfully updated.';
                update owcClaimDraftObj;
            }
            else{
                Online_Claim_Draft__c claimDraftObj = new Online_Claim_Draft__c();
                claimDraftObj.Draft_JSON__c = onlineClaimDetails;
                claimDraftObj.Section_Id__c = sectionId;
                
                wrapperObj.toastMsg = 'Your Draft has been successfully created.';
                insert claimDraftObj;
                wrapperObj.darftId = claimDraftObj.Id;
            }
            return wrapperObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Online_Claim_Draft__c getOWCJSONResponse(String recordId){
        try {
            Online_Claim_Draft__c owcClaimDraftList = [SELECT Id, CreatedById, Draft_JSON__c, Section_Id__c
                                                       FROM Online_Claim_Draft__c WHERE
                                                       CreatedById =: userInfo.getUserId()
                                                       AND Id =: recordId LIMIT 1];
            return owcClaimDraftList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
    @AuraEnabled
    public static Online_Claim_Draft__c getOWCSubmittedJSONResponse(String caseId){
        try{
            Online_Claim_Draft__c owcClaimDraftList = [SELECT Id, CreatedById, Draft_JSON__c, Section_Id__c
                                                       FROM Online_Claim_Draft__c WHERE
                                                       CreatedById =: userInfo.getUserId()
                                                       AND Case_Management__c =: caseId LIMIT 1];
            return owcClaimDraftList;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 
    */
    public class wrapperMsgObj{
        @AuraEnabled
        public String toastMsg{get;set;}
        @AuraEnabled
        public String darftId{get;set;}
    }
}