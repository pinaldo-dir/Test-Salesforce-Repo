/*Name: OnlineWageClaimThirdPartyAPIController
* Description: This class is used to create the Online Claim records based on the input provided by the Third party org from
* the external system.
* Primary Record: Case Management
* Related Records: Accounts, Related Party, Case Role, Case Issue, Claim
*/ 
public class OnlineWageClaimThirdPartyAPIController {
    public static Boolean isConfirm = false; //Initially set to false.
    public static String communityUserId;
    public static User userRec;
    public static Map<String, object> additionalParams;
    public static String fieldValidationError;
    public static String person_Account_RecordType_Id = OWCConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
    public static String wca_Case_RecordType_Id = OWCConstants.WCA_CASE_RECORD_TYPE_ID;
    public static String pre_Docketing_Case_RecordType_Id = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
    public static String wca_Case_Role_RecordType_Id = OWCConstants.WCA_CASE_ROLE_RECORD_TYPE_ID;
    public static String integrationUserId = OWCConstants.INTEGRATION_USER_ID;
    public static String garment_Case_RecordType_Id = OWCConstants.Garment_CASE_RECORD_TYPE_ID;
    public static Dir_Case__c cm;
    public static Online_claim__c onlineClaim;
    public static Account employeeRecord;
    public static List<Related_Party__c> relatedPartyList;
    public static Account representativeRecord;
    public static Case_Role__c  caseRole;
    public static Address__c otherLocation; 
    public static Address__c businessLocation;
    public Static List<ContentDocumentLink> documentLinks;
    public Static List<Object> uploadedDocList ;
    public static Map<String, Object> responseModelMap;
    public static Map<String, Object> demoGraphicData;
    public static boolean isGarmentDutyFollowed = false;
    public static String referred_From;
    public static Boolean claimantConfirm = false ;
    public static string applicantType ;
    public static Map<String, object> responseWrapper;
    public static String claimantZipCode ;
    public static String defendantZipCode;
    public static String otherLocationZipCode;
    public static List<Related_Party__c> additinalPersonList;
    public static String garment_Office_Los_Angeles = OWCConstants.Garment_Office_Los_Angeles;
    public static String fieldMissingMsg = '';
    public static String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    public static String phoneRegex = '[0-9]{10}';
    public static String urlRegex = '^((http|https)://)??(www[.])??([a-zA-Z0-9]|-)+?([.][a-zA-Z0-9(-|/|=|?)??]+?)+?$';
    public static String integerRegex = '([0-9]+)';
    public static String thirdPartyJson;
    public static OWCOnlineClaimFormValidatorService.ValidatorResponseWrapper wrapperResponse;
    @AuraEnabled
    public static String onlineClaimSubmit(String onlineClaimDetails){
        
        cm = new Dir_Case__c();
        additinalPersonList = new List<Related_Party__c>();
        cm.OWC_JSON__c = onlineClaimDetails;
        onlineClaim = new Online_claim__c();
        relatedPartyList = new List<Related_Party__c>();
        List<Related_Party__c>  employerRecordList = new List<Related_Party__c> ();
        documentLinks = new List<ContentDocumentLink>();
        uploadedDocList = new List<object>();
        responseModelMap = new Map<String, Object>();
        demoGraphicData = new Map<String, Object>();
        businessLocation = new Address__c(); 
        
        try {
            thirdPartyJson = onlineClaimDetails;
            Map<String, object> responseWrapper = OWCServiceUtility.getdeserializeUntypedMap (onlineClaimDetails);
            //Step1 prepare the Employer Data
            List<object> employerData = new List<object>();
            employerData = (List<object>) responseWrapper.get('employeesDetails');
            System.debug('employerData >>>>> '+employerData);
            employerRecordList = OWCOnlineClaimThirdPartyAPIService.prepareEmployerData(employerData, businessLocation, documentLinks,onlineClaim,cm,additinalPersonList);
            if(String.isNotBlank(fieldValidationError)){
                OnlineWageClaimThirdPartyWebService.fieldValidationError = fieldValidationError;
                return null;
            }
            Related_Party__c employerRecord = new Related_Party__c ();
            if(employerRecordList != null && employerRecordList.size() >0){
                //check the Defendant employer that should be closer to last record.
                for(Integer i = employerRecordList.size() - 1; i >= 0; i--){
                    if(employerRecordList[i].Role__c == 'Defendant'){
                        employerRecord = employerRecordList[i];
                        break;
                    }
                }
                //employerRecord = employerRecordList[0];
                String partyName ;
                if(String.isNotBlank(employerRecord.First_Name__c)){
                    partyName = employerRecord.First_Name__c;
                } 
                if(String.isNotBlank(employerRecord.Last_Name__c)){
                    if(String.isNotBlank(partyName)){
                        partyName += ' '+ employerRecord.Last_Name__c;
                    } else{
                        partyName = employerRecord.Last_Name__c;
                    }
                }
                if(employerRecord != null)  {
                    if(String.isNotBlank(employerRecord.Business_Name__c) || String.isNotBlank(partyName)){
                        if(String.isNotBlank(employerRecord.Zip_Code__c)){
                            defendantZipCode = employerRecord.Zip_Code__c;
                        }
                    }
                }   
                cm.Related_Party_Employer_Name__c = String.isNotBlank(employerRecord.Business_Name__c) ? employerRecord.Business_Name__c : partyName;
                //Claim Filed Against (Employer Information) Onlinc Claim mapping...
                //add Employer records to List
                relatedPartyList.addAll(employerRecordList); 
            }
            
            Boolean isLabelsInfo = false;
            //populate the Industry section date on Case and Account
            responseModelMap = (Map<String, object>) responseWrapper.get('industryInfoDataValues');
            if(employerRecordList != null && employerRecordList.size() >0){
                OWCOnlineClaimThirdPartyAPIService.populateIndustryData(responseModelMap,employerRecord,cm, onlineClaim);
            }
            if(String.isNotBlank(fieldValidationError)){
                OnlineWageClaimThirdPartyWebService.fieldValidationError = fieldValidationError;
                return null;
            }
            if(responseModelMap != null){
                if(responseModelMap.get('isGarmentDutyFollow') != null && (String) responseModelMap.get('isGarmentDutyFollow') == 'Yes'){
                    isGarmentDutyFollowed = true;
                }
                else{
                    isGarmentDutyFollowed = false;
                }
                
                if(responseModelMap.get('isLabelsInfo') != null && (boolean) responseModelMap.get('isLabelsInfo')){
                    isLabelsInfo = true;
                }
            }
            
            responseModelMap.clear();
            
            //Get the Claimant Information section Data
            responseModelMap = (Map<String, object>) responseWrapper.get('claimantEmployeeValues');
            
            //Check for claimant Cell Phone
            if((String) responseModelMap.get('representativeAdvocateType') != null){
                wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCRepresentationAdvocateType__mdt.getAll().values(), (String) responseModelMap.get('representativeAdvocateType'), false);
                if(wrapperResponse != null && wrapperResponse.isValid == false){
                    OnlineWageClaimThirdPartyWebService.fieldValidationError = wrapperResponse.message;
                    return null;
                }
            }
            
            Map<String, object> claimantDataMap = new Map<String, object>();
            //Step2 Prepare the Claimant Data
            claimantDataMap = (Map<String, object>) responseModelMap.get('claimantDetails');
            
            //Check for claimant Cell Phone
            if((String) claimantDataMap.get('countryCodeyourselfCellPhone') != null){
                wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String) claimantDataMap.get('countryCodeyourselfCellPhone'), false);
                if(wrapperResponse != null && wrapperResponse.isValid == false){
                    OnlineWageClaimThirdPartyWebService.fieldValidationError = wrapperResponse.message;
                    return null;
                }
            }
            
            //Check for claimant home Phone
            if((String) claimantDataMap.get('countryCodeyourselfHomePhone') != null){
                wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String) claimantDataMap.get('countryCodeyourselfHomePhone'), false);
                if(wrapperResponse != null && wrapperResponse.isValid == false){
                    OnlineWageClaimThirdPartyWebService.fieldValidationError = wrapperResponse.message;
                    return null;
                }
            }
            
            //Check for claimant preferred language
            if((Boolean) claimantDataMap.get('isPrefferedLanguage') == true && (String) claimantDataMap.get('prefferedLanguageSelection') != null){
                wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCPrefferedLanguageAssistantData__mdt.getAll().values(), (String) claimantDataMap.get('prefferedLanguageSelection'), false);
                if(wrapperResponse != null && wrapperResponse.isValid == false){
                    OnlineWageClaimThirdPartyWebService.fieldValidationError = wrapperResponse.message;
                    return null;
                }
            }
            
            //check for the Applicant Type
            applicantType = (String) responseModelMap.get('WageClaimSubmit');
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCPreliminaryWageClaimSubmit__mdt.getAll().values(), applicantType, false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyWebService.fieldValidationError = wrapperResponse.message;
                return null;
            }
            if(isGarmentDutyFollowed && applicantType != 'Yourself'){
                cm.Applicant_Type__c = 'Representative Garment';
            }else if(isGarmentDutyFollowed && applicantType == 'Yourself'){
                cm.Applicant_Type__c = 'Claimant Garment';
            } else {
                cm.Applicant_Type__c = applicantType;
            }
            
            onlineClaim.Applicant_Type__c = (String) responseModelMap.get('WageClaimSubmit');
            additionalParams = (Map<String, object>) responseWrapper.get('additionalParams');
            if(additionalParams != null && String.isBlank((String) additionalParams.get('communityUserId'))){
                OnlineWageClaimThirdPartyWebService.fieldValidationError = ThirdPartyErrorMsgConstants.COMMUNITY_USER_ID_MSG;
                return null;
            }
            else if(additionalParams != null && String.isNotBlank((String) additionalParams.get('communityUserId'))){
                communityUserId = (String) additionalParams.get('communityUserId');
                List<User> userObj = [SELECT Id, accountId FROM User WHERE Id =: communityUserId];
                if(userObj != null && userObj.size() > 0){
                    //populate the Online_Claim_Account__c 
                    userRec = [SELECT Id, accountId FROM User WHERE Id =: communityUserId];
                    if(String.isNotBlank(userRec.accountId)){
                        cm.Online_Claim_Account__c = userRec.accountId;
                    }
                }
                else{
                    OnlineWageClaimThirdPartyWebService.fieldValidationError = ThirdPartyErrorMsgConstants.COMMUNITY_USER_ID_MSG;
                	return null;
                }
            }
            
            //populate the Claimant Demographic Information on case management record
            if(responseWrapper.get('demoGraphicInfoData') != null){
                demoGraphicData = (Map<String, object>) responseWrapper.get('demoGraphicInfoData');
                OWCOnlineClaimThirdPartyAPIService.demograhicInfoCheck(demoGraphicData);
                if(String.isNotBlank(fieldValidationError)){
                    OnlineWageClaimThirdPartyWebService.fieldValidationError = fieldValidationError;
                    return null;
                }
                if(demoGraphicData.get('DemographicGenderIdentity') != null || demoGraphicData.get('DemographicGenderIdentity') != ''){
                    if(demoGraphicData.get('isGenderOther') == true){
                        cm.Gender_Identity__c = (demoGraphicData.get('GenderOther') != null || demoGraphicData.get('GenderOther') != '') ? (String) demoGraphicData.get('GenderOther') : '';
                    }
                    else if(demoGraphicData.get('isGenderOther') == false){
                        cm.Gender_Identity__c = (String) demoGraphicData.get('DemographicGenderIdentity');
                    }
                }
                if(demoGraphicData.get('DemographicSexualOrientation') != null || demoGraphicData.get('DemographicSexualOrientation') != ''){
                    if(demoGraphicData.get('isSexualOrientationOther') == true){
                        cm.Sexual_Orientation__c = (demoGraphicData.get('SexualOrientationOther') != null || demoGraphicData.get('SexualOrientationOther') != '') ? (String) demoGraphicData.get('SexualOrientationOther') : '';
                    }
                    else if(demoGraphicData.get('isSexualOrientationOther') == false){
                        cm.Sexual_Orientation__c = (String) demoGraphicData.get('DemographicSexualOrientation');
                    }
                }
                if(demoGraphicData.get('DemographicRace') != null || demoGraphicData.get('DemographicRace') != ''){
                    if(demoGraphicData.get('isDemographicRaceOther') == true){
                        cm.Race__c = (demoGraphicData.get('DemographicRaceOther') != null || demoGraphicData.get('DemographicRaceOther') != '') ? (String) demoGraphicData.get('DemographicRaceOther') : '';
                    }
                    else if(demoGraphicData.get('isDemographicRaceOther') == false){
                        cm.Race__c = (String) demoGraphicData.get('DemographicRace');
                    }
                }
                if(demoGraphicData.get('DemographicEthnicOrigin') != null || demoGraphicData.get('DemographicEthnicOrigin') != ''){
                    if(demoGraphicData.get('isDemographicEthnicOriginOther') == true){
                        cm.Ancestry_Ethnic_Origin__c = (demoGraphicData.get('DemographicEthnicOriginOther') != null || demoGraphicData.get('DemographicEthnicOriginOther') != '') ? (String) demoGraphicData.get('DemographicEthnicOriginOther') : '';
                    }
                    else if(demoGraphicData.get('isDemographicEthnicOriginOther') == false){
                        cm.Ancestry_Ethnic_Origin__c = (String) demoGraphicData.get('DemographicEthnicOrigin');
                    }
                }
                if(demoGraphicData.get('DemographicEthnicity') != null || demoGraphicData.get('DemographicEthnicity') != ''){
                    cm.Ethnicity__c = (String) demoGraphicData.get('DemographicEthnicity');
                }
            }
            
            //Create Related Party for Claimant
            if(claimantDataMap != null){
                System.debug('response ::: Yourself');
                //employeeRecord = OWCOnlineClaimThirdPartyAPIService.prepareDataForClaimantEmployeeValues(claimantDataMap);
                //Create the Related Party for the Claimant Section Data
                Related_Party__c  claimantRelatedParty = new Related_Party__c ();
                claimantRelatedParty = OWCOnlineClaimThirdPartyAPIService.prepareRelatedParty(claimantDataMap);
                if(String.isNotBlank(fieldValidationError)){
                    System.debug('fieldValidationError2 ::: '+fieldValidationError);
                    OnlineWageClaimThirdPartyWebService.fieldValidationError = fieldValidationError;
                    return null;
                }
                claimantZipCode = claimantRelatedParty.Zip_Code__c;
                cm.Interpreter_Needed__c = claimantDataMap.get('needLanguageInterpreter') != null && claimantDataMap.get('needLanguageInterpreter') == 'Yes' ? (String) claimantDataMap.get('needLanguageInterpreter') : 'No';
                cm.Language__c = (String) claimantDataMap.get('prefferedLanguageSelection'); 
                claimantRelatedParty.Interpreter_Language__c = (String) claimantDataMap.get('prefferedLanguageSelection'); 
                if(String.isNotBlank(userRec.accountId)){
                    claimantRelatedParty.Community_User_Account__c = userRec.accountId;
                }
                
                relatedPartyList.add(claimantRelatedParty);
                system.debug('claimantRelatedParty: '+claimantRelatedParty);
                if(claimantRelatedParty != null)    {
                    cm.Related_Party_Employee_Email__c = claimantRelatedParty.Email__c;
                    String fullName = prepareFullName(claimantRelatedParty.First_Name__c, claimantRelatedParty.Middle_Name__c,
                                                      claimantRelatedParty.Last_Name__c);
                    if(String.isNotBlank(fullName)){
                        cm.Claimant_Name_in_Text__c = fullName;
                    }
                }
            }
            
            System.debug('response ::: Representative: ' +(String) responseModelMap.get('representativeAdvocateType'));
            //Create Related Party for Advocate
            Related_Party__c  representativeRelatedParty = new Related_Party__c ();
            /*if((String) responseModelMap.get('representativeAdvocateType') == 'Individual'){
referred_From = 'Representative - Individual';
//representativeRecord = OWCOnlineClaimThirdPartyAPIService.prepareDataForIndividualRepresentative(responseModelMap);
representativeRelatedParty = OWCOnlineClaimThirdPartyAPIService.prepareRelatedPartyForIndividualRepresentative(responseModelMap);
//cm.Contact_Person__c = representativeRelatedParty.Name;
if(representativeRelatedParty != null){
String fullName = prepareFullName(representativeRelatedParty.First_Name__c, representativeRelatedParty.Middle_Name__c,
representativeRelatedParty.Last_Name__c);
if(String.isNotBlank(fullName)){
cm.Advocate_Name_in_Text__c = fullName;
}
}
if(representativeRelatedParty != null)  {
if(applicantType == 'Representative'){
if(String.isNotBlank(userRec.accountId)){
representativeRelatedParty.Community_User_Account__c = userRec.accountId;
}
}
cm.Related_Party_Advocate_Email__c = representativeRelatedParty.Email__c;
relatedPartyList.add(representativeRelatedParty);
}
}*/
            
            if(String.isNotBlank((String) responseModelMap.get('representativeAdvocateType')) && (String) responseModelMap.get('representativeAdvocateType') == 'Law Firm / Organization'){
                referred_From = 'Representative - Law Firm / Organization';
                //representativeRecord = OWCOnlineClaimThirdPartyAPIService.prepareDataForLawFirmRepresentative(responseModelMap);
                representativeRelatedParty = OWCOnlineClaimThirdPartyAPIService.prepareRelatedPartyForLawFirmRepresentative(responseModelMap);
                if(String.isNotBlank(fieldValidationError)){
                    System.debug('fieldValidationError3 ::: '+fieldValidationError);
                    OnlineWageClaimThirdPartyWebService.fieldValidationError = fieldValidationError;
                    return null;
                }
                if(representativeRelatedParty != null){
                    cm.Advocate_Name_in_Text__c = representativeRelatedParty.Business_Name__c ;
                }
                //cm.Contact_Person__c = representativeRelatedParty.Name;
                if(representativeRelatedParty != null)  {
                    if(applicantType == 'Representative'){
                        if(String.isNotBlank(userRec.accountId)){
                            representativeRelatedParty.Community_User_Account__c = userRec.accountId;
                        }
                    }
                    cm.Related_Party_Advocate_Email__c = representativeRelatedParty.Email__c;
                    relatedPartyList.add(representativeRelatedParty);
                }
            }
            else if(String.isBlank((String) responseModelMap.get('representativeAdvocateType'))){
                OnlineWageClaimThirdPartyWebService.fieldValidationError = ThirdPartyErrorMsgConstants.ADVOCATE_TYPE_ERROR_MSG;
                return null;
            }
            
           if(applicantType == 'Representative') {
                //For Claimant Confirmation
                cm.RecordTypeId = pre_Docketing_Case_RecordType_Id;
                cm.Status__c = 'Not Confirmed';
                isConfirm = responseModelMap.get('isClaimantConfirmation') != null ? (Boolean) responseModelMap.get('isClaimantConfirmation') : false;
               System.debug('isConfirm :::: '+isConfirm);
            }
            if(claimantDataMap !=null){
                claimantDataMap.clear();
            }
            //lets clear the map
            responseModelMap.clear();
            
            //lets check the validation for label section
            responseModelMap = (Map<String, object>) responseWrapper.get('labelDetails');
            OWCOnlineClaimThirdPartyAPIService.labelDetailsValidationCheck(responseModelMap);
            if(String.isNotBlank(fieldValidationError)){
                OnlineWageClaimThirdPartyWebService.fieldValidationError = fieldValidationError;
                return null;
            }
            //lets clear the map
            responseModelMap.clear();
            
            //lets check for the work location id different from the Business Address
            if(responseWrapper.containsKey('otherLocWorkInfo')){
                //populate the Other Work location address on Case
                responseModelMap = (Map<String, object>) responseWrapper.get('otherLocWorkInfo');
                if(String.isNotBlank((String) responseModelMap.get('workLocationBusinessAddress')) && ((String) responseModelMap.get('workLocationBusinessAddress') == 'Yes') || (String) responseModelMap.get('workLocationBusinessAddress') == 'sí'){
                //if(responseModelMap.get('isBusinessAddressDifferent') != null && (Boolean)responseModelMap.get('isBusinessAddressDifferent')){
                    System.debug('I am in other block.'+responseModelMap);
                    cm = OWCOnlineClaimThirdPartyAPIService.populateOtherWorkLocation(responseModelMap, cm, employerRecord);
                    if(String.isNotBlank(onlineClaim.Address_Where_Worked_Zip__c)){
                        otherLocationZipCode = onlineClaim.Address_Where_Worked_Zip__c;
                    }
                    
                } 
                else if(String.isBlank((String) responseModelMap.get('workLocationBusinessAddress'))){
                    OnlineWageClaimThirdPartyAPIController.fieldValidationError = ThirdPartyErrorMsgConstants.OTHERLOCATION_WORKADDRESS_REQUIRED_MSG;
                }
                else{
                    cm.WorkAddressDifferent__c = 'No';                    
                }
                if(String.isNotBlank(fieldValidationError)){
                    OnlineWageClaimThirdPartyWebService.fieldValidationError = fieldValidationError;
                    return null;
                }
            }
            else{
                cm.WorkAddressDifferent__c = 'No';
                cm.Work_Location__c = businessLocation.Id;
                //create the Work Location record
                
            }
            
            //lets clear the map
            responseModelMap.clear();
            //populate the Final Wages data on Case
            responseModelMap = (Map<String, object>) responseWrapper.get('employeeStatusAndFinalClaimDetails');
            
            cm = OWCOnlineClaimThirdPartyAPIService.populateFinalWagesData(responseModelMap, cm, onlineClaim);
            if(String.isNotBlank(fieldValidationError)){
                OnlineWageClaimThirdPartyWebService.fieldValidationError = fieldValidationError;
                return null;
            }
            //lets clear the map
            if(responseModelMap != null)    responseModelMap.clear();
            //Lets check the validation for payment of wages picklist
            responseModelMap = (Map<String, object>) responseWrapper.get('paymentOfWagesDetails');
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(responseModelMap);
            if(String.isNotBlank(fieldValidationError)){
                OnlineWageClaimThirdPartyWebService.fieldValidationError = fieldValidationError;
                return null;
            }
            //lets clear the map
            if(responseModelMap != null)    responseModelMap.clear();
            
            //Lets check the validation for workweek and workdays picklist
            responseModelMap = (Map<String, object>) responseWrapper.get('workWeekAndWorkDaysDetails');
            OWCOnlineClaimThirdPartyAPIService.workweekAndWorkDaysCheck(responseModelMap);
            if(String.isNotBlank(fieldValidationError)){
                OnlineWageClaimThirdPartyWebService.fieldValidationError = fieldValidationError;
                return null;
            }
            //lets clear the map
            if(responseModelMap != null)    responseModelMap.clear();
            
            //populate the Other fields on CM record
            OWCOnlineClaimThirdPartyAPIService.prepareCaseRecord(cm); 
            
            //Add new condition for claimant garment to assign Los Angeles garment office to case.
            if(isGarmentDutyFollowed){
                //cm.Office__c = garment_Office_Los_Angeles;
            }
            else{
                cm.Office_Location_Zip_Code__c = OWCServiceUtility.validateOfficeAssignment(claimantZipCode, defendantZipCode, otherLocationZipCode);
            }
            /*else if(String.isNotBlank(otherLocationZipCode)){
                if(defendantZipCode != null && defendantZipCode == claimantZipCode){
                    cm.Office_Location_Zip_Code__c = claimantZipCode;
                } else{
                    if(OWCServiceUtility.getOfficeLocationByZIPCode(otherLocationZipCode)){
                        cm.Office_Location_Zip_Code__c = otherLocationZipCode;
                    } else{
                        cm.Office_Location_Zip_Code__c = claimantZipCode;
                    }
                }
            } 
            else{
                cm.Office_Location_Zip_Code__c = claimantZipCode;
            }*/
            cm.Employer__c = null;
            cm.Intake_Origin__c = '3rd Party API';
            cm.Referred_From__c = 'Other';
            //Populate third party name
            Map<String, object> additionalParams = (Map<String, object>) responseWrapper.get('additionalParams');
            if(additionalParams != null && String.isNotBlank((String) additionalParams.get('thirdPartySource'))){
                cm.Referred_From_Other__c = (String) additionalParams.get('thirdPartySource');
            }
            if(additionalParams != null && String.isNotBlank((String) additionalParams.get('communityUserId'))){
                communityUserId = (String) additionalParams.get('communityUserId');
                List<User> users = [SELECT Id, Username, AccountId FROM User where Id =: communityUserId];
                if(users != null && users.size() > 0){
                    if(String.isBlank(users[0].AccountId)){
                        OnlineWageClaimThirdPartyWebService.fieldValidationError = ThirdPartyErrorMsgConstants.COMMUNITY_USER_ID_MSG;
                        return null;
                    }
                }
            }
            //Create the Records in salesforce
            insert cm;
            
            //populate Case on Related Parties
            if(additinalPersonList != null){
                for(Related_Party__c rp: additinalPersonList){
                    relatedPartyList.add(rp);
                }
            }
            if(relatedPartyList.size() >0 ) {
                for(Related_Party__c rp: relatedPartyList){
                    rp.Case_Management__c = cm.Id; 
                    if(String.isNotBlank(userRec.accountId)){
                        rp.Community_User_Account__c = userRec.accountId;
                    }
                }
                //insert relatedPartyList;
                createRelatedPartyRecords(Json.serialize(relatedPartyList));
            }
            
           /* for(Related_Party__c rp: relatedPartyList){
                system.debug('rp.Phone__c:' +rp.Phone__c);
                if(rp.Role__c == 'Claimant' && String.isNotBlank(rp.Phone__c)){
                    //String smsStatus = SendTextMessage.sendSMS(rp.Id, 'related_party__c', rp.Phone__c, 'Claim Confirmation');
                    //Task tsk = new task(description = smsStatus );
                    //insert tsk;
                }
                
            }*/
            
            //Prepare case role records
            prepareCaseRole(communityUserId, cm.Id);
           	
            List<DIR_Case__c> cseList = [SELECT Id FROM DIR_Case__c WHERE Id = : cm.Id ];
            System.debug('Result of case ::: '+cseList);
            //Add generate PDF method
            generatePDF(cseList[0].Id, isConfirm);
            
            return cm.Id;
            
        } catch (Exception e) {
            //Create error log records
            new OWCServiceUtility().Log(e);
            return null;
        }
    }
    
    @future
    public static void prepareCaseRole(String communityUserId, String caseId){
        try{
            System.debug('communityUserId :::: :: >>> '+communityUserId);
            Id userAccount;
            if(String.isNotBlank(communityUserId)){
                userAccount = [SELECT Id, Username, AccountId FROM User where Id =: communityUserId LIMIT 1].AccountId;
            }
            
            System.debug('userAccount ::: '+userAccount);
            
            Case_Role__c caseRoleObj = new Case_Role__c();
            caseRoleObj.Case__c = caseId;
            caseRoleObj.Entity__c = userAccount;
            caseRoleObj.Role__c = 'Advocate';
            caseRoleObj.Case_Role_Status__c = 'Active';
            caseRoleObj.RecordTypeId = wca_Case_Role_RecordType_Id;
            insert caseRoleObj;
        }
        catch (Exception e) {
            new OWCServiceUtility().Log(e);
        }
    }
    
    @TestVisible @future
    private static void createRelatedPartyRecords(String relatedPartyJson){
        try{
            System.debug('relatedPartyJson ::: '+relatedPartyJson);
            if(String.isNotBlank(relatedPartyJson)){
                List<Related_Party__c> relatedParties = (List<Related_Party__c>)JSON.deserialize(relatedPartyJson, List<Related_Party__c>.class);
                if(relatedParties != null){
                    insert relatedParties;
                } 
            }
        }catch (Exception e) {
            new OWCServiceUtility().Log(e);
        }
        
    }
    
    public static string prepareFullName(String firstName, String middleName, String lastName){
        String fullName = '';
        try{
            if(String.isNotBlank(firstName)){
                fullName = firstName;
            }
            if(String.isNotBlank(middleName)){
                fullName += ' '+middleName;
            }
            if(String.isNotBlank(lastName)){
                fullName += ' '+lastName;
            }
            if(String.isNotBlank(fullName)){
                fullName = fullName.trim();
            }
        }catch (Exception e) {
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            throw new AuraHandledException(errorMessage+e.getStackTraceString());
        }
        return fullName;
    }
    @TestVisible
    private static Dir_Case__c createCaseRecord(Map<String, object> claimantSectionData) {
        Dir_Case__c cm = new Dir_Case__c();
        System.debug('cm ::: '+cm);
        return cm;
    }
    
    //Validate claimant Advocate (Law Firm/Organization) data
    public static String validateClaimantAdvocateData(Map<String, object> claimantDataMap){
        //Check the wageClaimSubmit attribute value in JSON
        System.debug('claimantDataMap::::'+claimantDataMap);
        if(String.isBlank((String) claimantDataMap.get('WageClaimSubmit'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIM_SUBMITTER_ERROR_MSG;
        }
        
        if(String.isBlank((String) claimantDataMap.get('representativeAdvocateType'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.ADVOCATE_TYPE_ERROR_MSG;
        }
        
        //Advocate Business Name and Attorney Name check
        if(String.isBlank((String) claimantDataMap.get('lawfirmRepBusinessName')) && String.isBlank((String) claimantDataMap.get('lawfirmRepAttorney'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.BUSINESS_OR_ATTORNEY_NAME_ERROR_MSG;
        }
        
        //Advocate ZipCode validation check
        if(String.isNotBlank((String) claimantDataMap.get('lawFirmRepZipCode'))){
            String zipCode = (String) claimantDataMap.get('lawFirmRepZipCode');
            zipCode = zipCode.replace('-', '');
            if(zipCode.length() == 5 || zipCode.length() == 9){
                
            }
            else{
                fieldMissingMsg = ThirdPartyErrorMsgConstants.ADVOCATE_ZIPCODE_ERROR_MSG;
            }
        }
        
        //Advocate Phone number validation check
        if(String.isNotBlank((String) claimantDataMap.get('lawfirmRepStatePhone')) && regexChecker(phoneRegex, (String) claimantDataMap.get('lawfirmRepStatePhone'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.ADVOCATE_PHONE_NUMBER_ERROR_MSG;
        }
        
        //Advocate Email validation check
        if(String.isNotBlank((String) claimantDataMap.get('lawfirmRepEmail')) && regexChecker(emailRegex, (String) claimantDataMap.get('lawfirmRepEmail'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.ADVOCATE_EMAIL_ERROR_MSG;
        }
        
        //Advocate website validation check
        if(String.isNotBlank((String) claimantDataMap.get('lawfirmRepWebsite')) && regexChecker(urlRegex, (String) claimantDataMap.get('lawfirmRepWebsite'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.ADVOCATE_WEBSITE_ERROR_MSG;
        }
        
        return fieldMissingMsg;
    }
    
    //Validate Caimant data
    public static String validateClaimantData(Map<String, object> claimantDataMap){
        //Claimant first name validation check
        if(String.isBlank((String) claimantDataMap.get('yourselfFirstName'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIMANT_FIRST_NAME_ERROR_MSG;
        }
        
        //Claimant last name validation check
        if(String.isBlank((String) claimantDataMap.get('yourselfLastName'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIMANT_LAST_NAME_ERROR_MSG;
        }
        
        //Claimant BirthDate validation check
        if(String.isBlank((String) claimantDataMap.get('yourselfBirthDate'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIMANT_BIRTHDATE_REQ_ERROR_MSG;
        }
        else if(String.isNotBlank((String) claimantDataMap.get('yourselfBirthDate'))){
            OWCThirdPartyValidationCheckerController.dateFormatChecker((String) claimantDataMap.get('yourselfBirthDate'), ThirdPartyErrorMsgConstants.CLAIMANT_INVALID_BIRTHDATE_ERROR_MSG);
            if(String.isNotBlank(fieldMissingMsg)){
                return fieldMissingMsg;
            }
            String claimantBirthDate = (String) claimantDataMap.get('yourselfBirthDate');
            System.debug('claimantBirthDate ::: '+Date.valueOf(claimantBirthDate));
            
            Date todayDate = Date.today();
            System.debug('today date ::: '+todayDate);
            if(Date.valueOf(claimantBirthDate) >= todayDate){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIMANT_BIRTHDATE_ERROR_MSG;
            }
        }
        
        //Claimant Zipcode validation check for 5 or 9 digits
        if(String.isBlank((String) claimantDataMap.get('yourselfZipCode'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIMANT_ZIPCODE_REQ_ERROR_MSG;
        }
        else if(String.isNotBlank((String) claimantDataMap.get('yourselfZipCode'))){
            String zipCode = (String) claimantDataMap.get('yourselfZipCode');
            zipCode = zipCode.replace('-', '');
            if(zipCode.length() == 5 || zipCode.length() == 9){
                
            }
            else{
                fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIMANT_ZIPCODE_ERROR_MSG;
            }
        }
        
        //Claimant Cell phone validation check
        if(String.isNotBlank((String) claimantDataMap.get('yourselfCellPhone')) && regexChecker(phoneRegex, (String) claimantDataMap.get('yourselfCellPhone'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIMANT_CELL_PHONE_ERROR_MSG;
        }
        
        //Claimant Home phone validation check
        if(String.isNotBlank((String) claimantDataMap.get('yourselfHomePhone')) && regexChecker(phoneRegex, (String) claimantDataMap.get('yourselfHomePhone'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIMANT_HOME_PHONE_ERROR_MSG;
        }
        
        //Claimant Email validation check
        if(String.isNotBlank((String) claimantDataMap.get('yourselfEmail')) && regexChecker(emailRegex, (String) claimantDataMap.get('yourselfEmail'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIMANT_EMAIL_ERROR_MSG;
        }
        
        //Claimant preffered language selection validation check
        if(((Boolean) claimantDataMap.get('isPrefferedLanguage')) && ((Boolean) claimantDataMap.get('isOtherPrefferedLanguage')) && String.isBlank((String) claimantDataMap.get('otherPrefferedLanguage'))){
            fieldMissingMsg = ThirdPartyErrorMsgConstants.CLAIMANT_OTHER_PREFFERED_ERROR_MSG;
        }
        
        return fieldMissingMsg;
    }
    
    //Validate Employer Data
    public static String validateEmployerData(List<object> employerData){
        System.debug('employerMap :>:>:> '+employerData);
        //Step1 prepare the Employer Data
        for(Object obj : employerData){
            Map<String, Object> employerMap = (Map<String, Object>) obj;
            
            //Individual/Employer type validation check 
            if(String.isBlank((String) employerMap.get('representativeEmployerType'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_TYPE_ERROR_MSG;
            }
            
            fieldMissingMsg = validateEmployerUnionDoc(employerMap);
            


            //Validate employer complained filed date
            if(String.isNotBlank((String) employerMap.get('complainFiledDate'))){
                OWCThirdPartyValidationCheckerController.dateFormatChecker((String) employerMap.get('complainFiledDate'), ThirdPartyErrorMsgConstants.EMPLOYER_INVALID_COMPLAINED_DATE_ERROR_MSG);
                if(String.isNotBlank(fieldMissingMsg)){
                    return fieldMissingMsg;
                }
            }
            
            //Validate employer start and enddate worked 
            if(String.isNotBlank((String) employerMap.get('startingDate'))){
                OWCThirdPartyValidationCheckerController.dateFormatChecker((String) employerMap.get('startingDate'), ThirdPartyErrorMsgConstants.EMPLOYER_INVALID_START_DATE_ERROR_MSG);
                if(String.isNotBlank(fieldMissingMsg)){
                    return fieldMissingMsg;
                }
            }
            
            if(String.isNotBlank((String) employerMap.get('endingDate'))){
                OWCThirdPartyValidationCheckerController.dateFormatChecker((String) employerMap.get('endingDate'), ThirdPartyErrorMsgConstants.EMPLOYER_INVALID_END_DATE_ERROR_MSG);
                if(String.isNotBlank(fieldMissingMsg)){
                    return fieldMissingMsg;
                }
            }
            
            //check for Union cover

            if(String.isBlank((String)employerMap.get('unionContractCovering'))){    
                    fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_UNION_COVER_ERROR_MSG;
            }

            //Check for union contact doc
            if((Boolean) employerMap.get('isUnionContractCovered')){
                if((Boolean) employerMap.get('isUrlAddress') && String.isBlank((String) employerMap.get('urlAddress'))){
                    fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_UNION_ADDRESS_ERROR_MSG;
                }
                else if((Boolean) employerMap.get('isMailToOfficeLocator')){
                    fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_UNION_OFFICE_LOCATOR_ERROR_MSG;
                }
            }
            
            //Check validation for covid19 claim
            if(String.isBlank((String) employerMap.get('covid19Claim'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_COVID_19_ERROR_MSG;
            }
            if((Boolean) employerMap.get('isEmployeeFilingWageClaim') && (Boolean) employerMap.get('isEmployeeFilingWageClaimOther') && String.isBlank((String) employerMap.get('specifyOtherReason'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_OTHER_COVID_19_ERROR_MSG;
            }
            
            //Validate employer business changed data
            Map<String, Object> employerBusinessChangedData = (Map<String, Object>) employerMap.get('employerNameChangedDetails');
            if(employerBusinessChangedData != null){
                fieldMissingMsg = validateEmployerUnionDoc(employerBusinessChangedData);    
            }    
            
            //Validate employer name changed details
            Map<String, Object> employerNameChangedDetails = (Map<String, Object>) employerMap.get('successorDetails');
            if(employerNameChangedDetails != null){
                List<Object> successorDetails = (List<Object>) employerNameChangedDetails.get('successorDetails');
                if(successorDetails != null && successorDetails.size() > 0){
                    for(Object successorObj : successorDetails){
                        Map<String, Object> successorMap = (Map<String, Object>) successorObj;
                        if(successorMap.get('employerNameAfterEmployementDetails') != null){
                            fieldMissingMsg = validateEmployerUnionDoc((Map<String, Object>) successorMap.get('employerNameAfterEmployementDetails'));
                        }
                    }
                }
            }
        }
        
        return fieldMissingMsg;
    }
    
    //Employer validation checks
    public static String validateEmployerUnionDoc(Map<String, Object> employerMap){
        //Check for employer type
        if(String.isNotBlank((String) employerMap.get('representativeEmployerType')) && (String) employerMap.get('representativeEmployerType') == 'Individual/Sole Proprietor'){
            //Employer first name validation check
            if(String.isBlank((String) employerMap.get('individualVehicleLicense')) && String.isBlank((String) employerMap.get('individualFirstName'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_FIRST_NAME_ERROR_MSG;
            }
            
            //Employer last name validation check
            if(String.isBlank((String) employerMap.get('individualLastName'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_LAST_NAME_ERROR_MSG;
            }
            
            //Employer street address validation check
            if(String.isBlank((String) employerMap.get('individualVehicleLicense')) && String.isBlank((String) employerMap.get('individualStreetAddress'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_STREET_ADDRESS_ERROR_MSG;
            }
            
            //Employer city validation check
            if(String.isBlank((String) employerMap.get('individualVehicleLicense')) && String.isBlank((String) employerMap.get('individualCity'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_CITY_ERROR_MSG;
            }
            
            //Employer state validation check
            if(String.isBlank((String) employerMap.get('individualVehicleLicense')) && String.isBlank((String) employerMap.get('individualState'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_STATE_ERROR_MSG;
            }
            
            //Employer zipcode validation check
            if(String.isBlank((String) employerMap.get('individualVehicleLicense')) && String.isBlank((String) employerMap.get('individualZipCode'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_ZIPCODE_REQ_ERROR_MSG;
            }
            else if(String.isNotBlank((String) employerMap.get('individualZipCode'))){
                String zipCode = (String) employerMap.get('individualZipCode');
                zipCode = zipCode.replace('-', '');
                if(zipCode.length() == 5 || zipCode.length() == 9){
                    
                }
                else{
                    fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_ZIPCODE_ERROR_MSG;
                }
            }
            
            //Employer Business Phone validation check
            if(String.isBlank((String) employerMap.get('individualVehicleLicense')) && String.isBlank((String) employerMap.get('individualBusinessPhone'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_BUSINESS_PHONE_ERROR_REQ_MSG;
            }
            else if(String.isNotBlank((String) employerMap.get('individualBusinessPhone')) && regexChecker(phoneRegex, (String) employerMap.get('individualBusinessPhone'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_BUSINESS_PHONE_ERROR_MSG;
            }
            
            //Employer cell phone validation check
            if(String.isBlank((String) employerMap.get('individualVehicleLicense')) && String.isBlank((String) employerMap.get('individualBusinessPhone'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_CELL_PHONE_REQ_ERROR_MSG;
            }
            else if(String.isNotBlank((String) employerMap.get('individualCellPhone')) && regexChecker(phoneRegex, (String) employerMap.get('individualCellPhone'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_CELL_PHONE_ERROR_MSG;
            }
            
            //Employer email format check
            if(String.isNotBlank((String) employerMap.get('individualEmail')) && regexChecker(emailRegex, (String) employerMap.get('individualEmail'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_EMAIL_ERROR_MSG;
            }
            
            //Employer website format check
            if(String.isNotBlank((String) employerMap.get('individualWebsite')) && regexChecker(urlRegex, (String) employerMap.get('individualWebsite'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_WEBSITE_ERROR_MSG;
            }
            
            //Number of employees format check
            if(String.isBlank((String) employerMap.get('individualVehicleLicense')) && String.isBlank((String) employerMap.get('additionalTotalEmployees'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_NO_OF_EMPLOYEES_REQ_ERROR_MSG;
            }
            else if(String.isNotBlank((String) employerMap.get('additionalTotalEmployees')) && regexChecker(integerRegex, (String) employerMap.get('additionalTotalEmployees'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_NO_OF_EMPLOYEES_ERROR_MSG;
            }
        }
        else{
            
            //Employer business name validation check
            if(String.isBlank((String) employerMap.get('OtherIndividualBusinessName'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_BUSINESS_NAME_ERROR_MSG;
            }
            
            //Employer street address validation check
            if(String.isBlank((String) employerMap.get('OtherIndividualVehicleLicense')) && String.isBlank((String) employerMap.get('OtherIndividualStreetAddress'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_STREET_ADDRESS_ERROR_MSG;
            }
            
            //Employer city validation check
            if(String.isBlank((String) employerMap.get('OtherIndividualVehicleLicense')) && String.isBlank((String) employerMap.get('OtherIndividualCity'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_CITY_ERROR_MSG;
            }
            
            //Employer state validation check
            if(String.isBlank((String) employerMap.get('OtherIndividualVehicleLicense')) && String.isBlank((String) employerMap.get('OtherIndividualState'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_STATE_ERROR_MSG;
            }
            
            //Employer zipcode validation check
            if(String.isBlank((String) employerMap.get('OtherIndividualVehicleLicense')) && String.isBlank((String) employerMap.get('OtherIndividualZipCode'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_ZIPCODE_REQ_ERROR_MSG;
            }
            else if(String.isNotBlank((String) employerMap.get('OtherIndividualZipCode'))){
                String zipCode = (String) employerMap.get('OtherIndividualZipCode');
                zipCode = zipCode.replace('-', '');
                if(zipCode.length() == 5 || zipCode.length() == 9){
                    
                }
                else{
                    fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_ZIPCODE_ERROR_MSG;
                }
            }
            
            //Employer Business phone validation check
            if(String.isBlank((String) employerMap.get('OtherIndividualVehicleLicense')) && String.isBlank((String) employerMap.get('OtherIndividualPhone'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_BUSINESS_PHONE_ERROR_REQ_MSG;
            }
            else if(String.isNotBlank((String) employerMap.get('OtherIndividualPhone')) && regexChecker(phoneRegex, (String) employerMap.get('OtherIndividualPhone'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_BUSINESS_PHONE_ERROR_MSG;
            }   
            //Employer email format check
            if(String.isNotBlank((String) employerMap.get('OtherIndividualEmail')) && regexChecker(emailRegex, (String) employerMap.get('OtherIndividualEmail'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_EMAIL_ERROR_MSG;
            }
            
            //Employer website format check
            if(String.isNotBlank((String) employerMap.get('OtherIndividualWebsite')) && regexChecker(urlRegex, (String) employerMap.get('OtherIndividualWebsite'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_WEBSITE_ERROR_MSG;
            }
            
            //Number of employees format check
            if(String.isBlank((String) employerMap.get('OtherIndividualVehicleLicense')) && String.isBlank((String) employerMap.get('additionalTotalEmployees'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_NO_OF_EMPLOYEES_REQ_ERROR_MSG;
            }
            else if(String.isNotBlank((String) employerMap.get('additionalTotalEmployees')) && regexChecker(integerRegex, (String) employerMap.get('additionalTotalEmployees'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_NO_OF_EMPLOYEES_ERROR_MSG;
            }
            
            //Employer don't explanation validation check 
            if((Boolean) employerMap.get('IsOther') && String.isBlank((String) employerMap.get('otherPleaseExplain'))){
                fieldMissingMsg = ThirdPartyErrorMsgConstants.EMPLOYER_EXPLANATION_ERROR_MSG;
            }
        }
        return fieldMissingMsg;
    }
    
    public static Boolean regexChecker(String regexPattern, String value){
        return !Pattern.matches(regexPattern, value);
    }
    
    //Method used to create PDF attachment
    //@future(Callout=true)
    public static void generatePDF(String caseRecordId, Boolean isConfirm){
        try{
            caseRecordId = caseRecordId.remove('"');
            OWCThirdPartyGeneratePDFBatch batch = new OWCThirdPartyGeneratePDFBatch(caseRecordId, isConfirm);
            if(!Test.isRunningTest()){
                Database.executeBatch(batch);
            }
            /*
            Pagereference pg = Page.OWCThirdPartyPDFPage;
            pg.getParameters().put('caseManagementId', caseRecordId);
            
            ContentVersion cont = new ContentVersion();
            cont.Description = 'Third Party';
            cont.Title = 'Wage Claim Summary Report';
            cont.PathOnClient = 'online_claim_summary.pdf';
            if(Test.isRunningTest()){
                cont.VersionData = blob.valueOf('Unit.Test'); 
            }
            else{
                cont.VersionData = pg.getContentAsPDF();
            }
            
            //cont.
            cont.Origin = 'H';
            System.debug('caseRecordId VersionData::: '+caseRecordId); 
            insert cont;  
            ContentVersion contentVersion_2 = [SELECT Id, Title,FileType, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = :cont.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caseRecordId.remove('"');
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            contentlink.Visibility = 'AllUsers';
            insert contentlink;
            system.debug('contentlink: '+contentlink);
            
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Test';
            cd.ContentVersionId = cont.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;
            //return contentlink;
            //
            List<DIR_Case__c> cseList = [SELECT Id,Name FROM DIR_Case__c WHERE Id = : caseRecordId ];
            System.debug('cseList in pdf method ::: '+cseList);
            System.debug('isConfirm in pdf method ::: '+isConfirm);
            //Send email confirmation notification to claimant if representative do not have the 
			//claimant confirmation document.
            if(!isConfirm){
                OCEmailServiceUtility.sendConfirmationEmailtoClaimant(cseList);
            }
            */
        }
        catch(Exception e){
            System.debug('Line Number ::: '+e.getLineNumber());
            System.debug('Error Msg ::: '+e.getMessage());
        }
    } 
    
    
    public static String todayDate(){
        Date todayDate = Date.today();
        return todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year();
    }
    
    public class serverResponseWrapper{
        @AuraEnabled
        public boolean isSuccess{get;set;}
        @AuraEnabled
        public String serverMsg{get;set;}
    }
}