public class OWCThirdPartyValidationCheckerController {
    public static void validateMeetingAPIResponse(String caseNumber, String claimantLastName, String communityUserId){
        if(String.isNotBlank(caseNumber) && String.isNotBlank(communityUserId)){
            List<User> userObj = [SELECT Id, accountId FROM User WHERE Id =: communityUserId];
            List<DIR_Case__c> caseObj = [SELECT Id, Name, Case_Number__c, Online_Claim_Account__c FROM DIR_Case__c
                                   WHERE Case_Number__c =: caseNumber LIMIT 1];
            System.debug('userObj:::'+userObj);
            System.debug('caseObj::::'+caseObj);
            if(caseObj != null && caseObj.size() > 0){
                OWCThirdPartyFileUploadWebService.fieldValidationError = ThirdPartyErrorMsgConstants.caseNumberErrorMsg(caseNumber);
                return;
            }
            else if(userObj != null && userObj.size() > 0 && caseObj.size() > 0 && caseObj[0].Online_Claim_Account__c != userObj[0].accountId){
                OWCThirdPartyFileUploadWebService.fieldValidationError = ThirdPartyErrorMsgConstants.COMMUNITY_USER_ID_MSG;
                return;
            }
        }
        if(String.isBlank(communityUserId)){
            ThirdPartyMeetingDetailsWebService.fieldValidationError = ThirdPartyErrorMsgConstants.COMMUNITY_USER_ID_MSG;
            return;
        }
        else if(String.isNotBlank(communityUserId)){
            List<User> userObj = [SELECT Id, accountId FROM User WHERE Id =: communityUserId];
            if(userObj == null || userObj.size() == 0){
                ThirdPartyMeetingDetailsWebService.fieldValidationError = ThirdPartyErrorMsgConstants.COMMUNITY_USER_ID_MSG;
                return;
            }
        }
        if(String.isNotBlank(caseNumber)){
            List<DIR_Case__c> cases = [SELECT Id, Case_Number__c FROM DIR_Case__c WHERE Case_Number__c =: caseNumber];
            if(cases == null || cases.size() == 0){
                ThirdPartyMeetingDetailsWebService.fieldValidationError = ThirdPartyErrorMsgConstants.caseNumberErrorMsg(caseNumber);
                return;
            }
        }
        if(String.isNotBlank(claimantLastName)){
            List<Case_Role__c> caseRoles = [SELECT Id, Name, Case__c, Entity__c, Role__c FROM Case_Role__c 
                                            WHERE Role__c = 'Claimant' AND Entity__r.LastName =: claimantLastName];
            if(caseRoles == null || caseRoles.size() == 0){ 
                ThirdPartyMeetingDetailsWebService.fieldValidationError = ThirdPartyErrorMsgConstants.claimantLastNameErrorMsg(caseNumber, claimantLastName);
                return;
            }
        }
    }
    
    public static void validateCCAPIResponse(String caseNumber, String communityUserId){
        /**if( 1 == 1){
            return;
        }**/
        
        System.debug('caseNumber:::'+caseNumber);
        System.debug('Query:::'+ [SELECT Id, Name, Case_Number__c, Online_Claim_Account__c FROM DIR_Case__c ]);
        
        if(String.isNotBlank(caseNumber) && String.isNotBlank(communityUserId)){
            List<User> userObj = [SELECT Id, accountId FROM User WHERE Id =: communityUserId];
            DIR_Case__c caseObj = [SELECT Id, Name, Case_Number__c, Online_Claim_Account__c FROM DIR_Case__c
                                   WHERE Case_Number__c =: caseNumber LIMIT 1];
            if(userObj != null && userObj.size() > 0 && caseObj.Online_Claim_Account__c != userObj[0].accountId){
                OWCThirdPartyFileUploadWebService.fieldValidationError = ThirdPartyErrorMsgConstants.COMMUNITY_USER_ID_MSG;
                return;
            }
        }
        //Check whether community user id is valid or not
        if(String.isBlank(communityUserId)){
            OWCThirdPartyFileUploadWebService.fieldValidationError = ThirdPartyErrorMsgConstants.COMMUNITY_USER_ID_MSG;
            return;
        }
        else if(String.isNotBlank(communityUserId)){
            List<User> userObj = [SELECT Id, accountId FROM User WHERE Id =: communityUserId];
            if(userObj == null || userObj.size() == 0){
                OWCThirdPartyFileUploadWebService.fieldValidationError = ThirdPartyErrorMsgConstants.COMMUNITY_USER_ID_MSG;
                return;
            }
        }
        if(String.isNotBlank(caseNumber)){
            List<DIR_Case__c> cases = [SELECT Id, Case_Number__c FROM DIR_Case__c WHERE Case_Number__c =: caseNumber];
            System.debug('cases:::'+cases);
            if(cases == null || cases.size() == 0){
                OWCThirdPartyFileUploadWebService.fieldValidationError = ThirdPartyErrorMsgConstants.caseNumberErrorMsg(caseNumber);
                return;
            }
        }
    }
    
    public static void dateFormatChecker(String dateValue, String errorMsg){
        try{
            Date d = Date.valueOf(dateValue);            
        }
        catch(TypeException ex){
            OnlineWageClaimThirdPartyAPIController.fieldMissingMsg = errorMsg;
        }
    }
}