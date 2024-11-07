/*Name: OnlineWageClaimContainerController
* Description: This class is used to create the Online Claim records based on the input provided by the Users during the 
* submission of Online Claim form.
* Primary Record: Case Management
* Related Records: Accounts, Related Party, Case Role, Case Issue, Claim
*/ 
public without sharing class OnlineWageClaimContainerController  {
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
    public static List<Payment_of_wages__c> paymentofWagesList;
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
    @AuraEnabled
    public static wageClaimWrapper onlineClaimSubmit(String onlineClaimDetails, String sectionId, String draftRecordId, String vtCaseIssues){
        system.debug('vtCaseIssues: '+vtCaseIssues);
        /*
if(1 == 1 ){
OWCcaseIssueUtility.parseResponse(vtCaseIssues, 'a1B35000000ZT7AEAW');
//OCEmailServiceUtility.sendTestEmail(vtCaseIssues);
return null;
}       */
        
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
        Map<String, object> responseWrapper = OWCServiceUtility.getdeserializeUntypedMap (onlineClaimDetails);
        try {
            //Step1 prepare the Employer Data
            List<object> employerData = new List<object>();
            employerData = (List<object>) responseWrapper.get('employeesDetails');
            employerRecordList = OWCOnlineClaimFormService.prepareEmployerData(employerData, businessLocation, documentLinks,onlineClaim,cm,additinalPersonList);
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
                            defendantZipCode = employerRecord.Zip_Code__c.substring(0,5);
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
                OWCOnlineClaimFormService.populateIndustryData(responseModelMap,employerRecord,cm, onlineClaim);
            }
            
            
            if(responseModelMap != null){
                if(responseModelMap.get('isGarmentDutyFollow') != null && ((String) responseModelMap.get('isGarmentDutyFollow') == 'Yes' || (String) responseModelMap.get('isGarmentDutyFollow') == 'Sí')){
                    isGarmentDutyFollowed = true;
                }
                else{
                    isGarmentDutyFollowed = false;
                }
                
                System.debug('IsGarmentDuty :::: '+responseModelMap.get('isGarmentDutyFollow'));
                if(responseModelMap.get('isLabelsInfo') != null && (boolean) responseModelMap.get('isLabelsInfo')){
                    isLabelsInfo = true;
                }
                //Farm Labour
                onlineClaim.Were_you_working_as_a_farm_laborer__c =  responseModelMap.get('isYouFarmLaborer') != null ? 
                    (boolean) responseModelMap.get('isYouFarmLaborer') : null;
                onlineClaim.Did_you_receive_heat_recovery_periods__c = (String) responseModelMap.get('heatRecovery');
                onlineClaim.Did_you_paid_heat_recovery__c  = (String) responseModelMap.get('paidBreaks');
                onlineClaim.Request_a_written_rate_of_compensation__c = (boolean) responseModelMap.get('isRateOfCompensation');
                onlineClaim.Date_of_written_request__c = String.isNotBlank((String) responseModelMap.get('writtenReqDate')) ? 
                    Date.valueOf((String) responseModelMap.get('writtenReqDate')) : null;
                onlineClaim.Date_employer_provided_the_statement__c = String.isNotBlank((String) responseModelMap.get('statementDate')) ? 
                    Date.valueOf((String) responseModelMap.get('statementDate')) : null;
                onlineClaim.Employer_never_provided_the_statement__c = (String) responseModelMap.get('empStatementProvided');
                onlineClaim.Employee_Job_Duties__c = (String) responseModelMap.get('listOfDuties');
                
                //Domestic Worker
                if(responseModelMap.get('domesticWorkType') != null || responseModelMap.get('domesticWorkType') != ''){
                    onlineClaim.Type_of_Work_Performed__c = (String) responseModelMap.get('domesticWorkType');
                }
                if(responseModelMap.get('isDomesticWorkInHome') != null || responseModelMap.get('isDomesticWorkInHome') != ''){
                    onlineClaim.Did_you_work_in_the_home__c = (String) responseModelMap.get('isDomesticWorkInHome');
                }
                if(responseModelMap.get('domesticRegisteredNurse') != null || responseModelMap.get('domesticRegisteredNurse') != ''){
                    onlineClaim.Are_you_a_registered_nurse__c = (String) responseModelMap.get('domesticRegisteredNurse');
                }
                if(responseModelMap.get('domesticLiveInWorkHome') != null || responseModelMap.get('domesticLiveInWorkHome') != ''){
                    onlineClaim.Live_in_the_home_where_you_worked__c = (String) responseModelMap.get('domesticLiveInWorkHome');
                }
                if(responseModelMap.get('domesticSentByHomeAgency') != null || responseModelMap.get('domesticSentByHomeAgency') != ''){
                    onlineClaim.Were_you_sent_to_the_home_by_an_agency__c = (String) responseModelMap.get('domesticSentByHomeAgency');
                }
                //Personal Attendent
                if(responseModelMap.get('personalAttendentWorkType') != null || responseModelMap.get('personalAttendentWorkType') != ''){
                    onlineClaim.Type_of_Work_Performed__c = (String) responseModelMap.get('personalAttendentWorkType');
                }
                if(responseModelMap.get('personalAttendentWorkHome') != null || responseModelMap.get('personalAttendentWorkHome') != ''){
                    onlineClaim.Did_you_work_in_the_home__c = (String) responseModelMap.get('personalAttendentWorkHome');
                }
                if(responseModelMap.get('personalAttendentRegisteredNurse') != null || responseModelMap.get('personalAttendentRegisteredNurse') != ''){
                    onlineClaim.Are_you_a_registered_nurse__c = (String) responseModelMap.get('personalAttendentRegisteredNurse');
                }
                if(responseModelMap.get('personalAttendentLiveInWorkHome') != null || responseModelMap.get('personalAttendentLiveInWorkHome') != ''){
                    onlineClaim.Live_in_the_home_where_you_worked__c = (String) responseModelMap.get('personalAttendentLiveInWorkHome');
                }
                if(responseModelMap.get('personalAttendentSentByHomeAgency') != null || responseModelMap.get('personalAttendentSentByHomeAgency') != ''){
                    onlineClaim.Were_you_sent_to_the_home_by_an_agency__c = (String) responseModelMap.get('personalAttendentSentByHomeAgency');
                }
                //Facility Attendent
                if(responseModelMap.get('facilityPersonalAttendentWorkType') != null || responseModelMap.get('facilityPersonalAttendentWorkType') != ''){
                    onlineClaim.Type_of_Work_Performed__c = (String) responseModelMap.get('facilityPersonalAttendentWorkType');
                }
                if(responseModelMap.get('facilityWorkResidential') != null || responseModelMap.get('facilityWorkResidential') != ''){
                    onlineClaim.Did_you_work_in_the_home__c = (String) responseModelMap.get('facilityWorkResidential');
                }
                if(responseModelMap.get('facilityAttendentRegisteredNurse') != null || responseModelMap.get('facilityAttendentRegisteredNurse') != ''){
                    onlineClaim.Are_you_a_registered_nurse__c = (String) responseModelMap.get('facilityAttendentRegisteredNurse');
                }
                
            }
            
            
            //insert the Employer and Location
            /*Commented for Related Party
if(String.isBlank(employerRecord.Id)){
//System.debug('employerRecord.LastName ::: '+employerRecord.LastName);
//populate Owner Id
//employerRecord.ownerId = integrationUserId;
//employerRecord.Claim_User__c = UserInfo.getUserId();

}   

//populate Employer on Case 
cm.Employer__c = employerRecord.Id;

//populate the Entity on Location
businessLocation.Entity__c = employerRecord.Id;
if(String.isNotBlank(businessLocation.Entity__c))   insert businessLocation;

*/
            
            responseModelMap.clear();
            
            //Get the Claimant Information section Data
            responseModelMap = (Map<String, object>) responseWrapper.get('claimantEmployeeValues');
            Map<String, object> claimantDataMap = new Map<String, object>();
            //Step2 Prepare the Claimant Data
            claimantDataMap = (Map<String, object>) responseModelMap.get('claimantDetails');
            
            //check for the Applicant Type
            applicantType = (String) responseModelMap.get('WageClaimSubmit');
            if(isGarmentDutyFollowed && applicantType != 'Yourself'){
                cm.Applicant_Type__c = 'Representative Garment';
            }else if(isGarmentDutyFollowed && applicantType == 'Yourself'){
                cm.Applicant_Type__c = 'Claimant Garment';
            } else {
                cm.Applicant_Type__c = applicantType;
            }
            onlineClaim.Applicant_Type__c = (String) responseModelMap.get('WageClaimSubmit');
            //populate the Online_Claim_Account__c 
            User userRec = [SELECT Id, accountId FROM User WHERE Id =: UserInfo.getUserId()];
            if(String.isNotBlank(userRec.accountId)){
                cm.Online_Claim_Account__c = userRec.accountId;
            }
            
            //populate the Claimant Demographic Information on case management record
            if(responseWrapper.get('demoGraphicInfoData') != null){
                demoGraphicData = (Map<String, object>) responseWrapper.get('demoGraphicInfoData');
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
                //employeeRecord = OWCOnlineClaimFormService.prepareDataForClaimantEmployeeValues(claimantDataMap);
                //Create the Related Party for the Claimant Section Data
                Related_Party__c  claimantRelatedParty = new Related_Party__c ();
                claimantRelatedParty = OWCOnlineClaimFormService.prepareRelatedParty(claimantDataMap);
                
                if(String.isNotBlank(claimantRelatedParty.Zip_Code__c)){
                    claimantZipCode = claimantRelatedParty.Zip_Code__c.substring(0,5);
                }
                
                if(String.isNotBlank((String) claimantDataMap.get('needLanguageInterpreter'))){
                    if((String) claimantDataMap.get('needLanguageInterpreter') == 'Yes' || (String) claimantDataMap.get('needLanguageInterpreter') == 'Sí'){
                        cm.Interpreter_Needed__c = 'Yes';
                    }
                    else{
                        cm.Interpreter_Needed__c = 'No';
                    }
                }
                   
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
            if((String) responseModelMap.get('representativeAdvocateType') == 'Individual'){
                referred_From = 'Representative - Individual';
                //representativeRecord = OWCOnlineClaimFormService.prepareDataForIndividualRepresentative(responseModelMap);
                representativeRelatedParty = OWCOnlineClaimFormService.prepareRelatedPartyForIndividualRepresentative(responseModelMap);
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
            }
            
            else if((String) responseModelMap.get('representativeAdvocateType') == 'Law Firm / Organization'){
                referred_From = 'Representative - Law Firm / Organization';
                //representativeRecord = OWCOnlineClaimFormService.prepareDataForLawFirmRepresentative(responseModelMap);
                representativeRelatedParty = OWCOnlineClaimFormService.prepareRelatedPartyForLawFirmRepresentative(responseModelMap);
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
            else if((String) responseModelMap.get('representativeAdvocateType') == 'Organization'){
                referred_From = 'Representative - Organization';
                //representativeRecord = OWCOnlineClaimFormService.prepareDataForOrganizationRepresentative(responseModelMap);
                representativeRelatedParty = OWCOnlineClaimFormService.prepareRelatedPartyForOrganizationRep(responseModelMap);
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
            
            System.debug('isGarmentDutyFollowed :::: '+isGarmentDutyFollowed);            
            /*
if(isGarmentDutyFollowed){
cm.RecordTypeId = garment_Case_RecordType_Id;
}
else{
cm.RecordTypeId = wca_Case_RecordType_Id;
}	*/
            
            System.debug('Case Status 351 ::: '+cm.Status__c);
            if(applicantType == 'Yourself'){
                referred_From = 'Claimant';
                claimantConfirm = true;
                if(isGarmentDutyFollowed){
                    cm.Status__c = 'Resume';
                    cm.RecordTypeId = garment_Case_RecordType_Id;
                }else{
                    cm.RecordTypeId = wca_Case_RecordType_Id;
                    cm.Status__c = 'New';
                }
            }
            else if(applicantType == 'Representative') {
                //For Claimant Confirmation
                Boolean isConfirm = (Boolean) responseModelMap.get('isClaimantConfirmation');
                if(isConfirm != null && isConfirm){
                    claimantConfirm = true;
                    cm.Status__c = 'New';
                    if(isGarmentDutyFollowed){
                        cm.RecordTypeId = garment_Case_RecordType_Id;
                        cm.Office__c = garment_Office_Los_Angeles;
                    }
                    else{
                        cm.RecordTypeId = wca_Case_RecordType_Id;
                    }
                    //cm.RecordTypeId = wca_Case_RecordType_Id;
                    if(responseModelMap.containsKey('claimantConfirmUploadDoc') && responseModelMap.get('claimantConfirmUploadDoc') != null){
                        uploadedDocList = (List<Object>) responseModelMap.get('claimantConfirmUploadDoc');
                        if(uploadedDocList != null){
                            OWCOnlineClaimFormService.prepareUploadedDocuments(uploadedDocList, documentLinks);
                            //clear the docs list
                            uploadedDocList.clear();
                            system.debug('documentLinks: '+documentLinks);
                        }
                    }
                    
                }
                else{
                    cm.RecordTypeId = pre_Docketing_Case_RecordType_Id;
                    cm.Status__c = 'Not Confirmed';
                    /*
if(isGarmentDutyFollowed){
cm.RecordTypeId = garment_Case_RecordType_Id;
cm.Status__c = 'Resume';
}
else{

}	*/
                }
                /*
//Create the Related Party for the Claimant Section Data
if(claimantDataMap != null){
Related_Party__c  claimantRelatedParty = new Related_Party__c ();
claimantRelatedParty = OWCOnlineClaimFormService.prepareRelatedParty(claimantDataMap);
if(claimantRelatedParty != null){
cm.Related_Party_Employee_Email__c = claimantRelatedParty.Email__c;
String fullName = prepareFullName(claimantRelatedParty.First_Name__c, claimantRelatedParty.Middle_Name__c,
claimantRelatedParty.Last_Name__c);
if(String.isNotBlank(fullName)){
cm.Claimant_Name_in_Text__c = fullName;
}
relatedPartyList.add(claimantRelatedParty);
}
}
claimantDataMap.clear();    */
            }
            System.debug('Case Status 398 ::: '+cm.Status__c);
            if(claimantDataMap !=null){
                claimantDataMap.clear();
            }
            //lets clear the map
            responseModelMap.clear();
            //lets check for the work location id different from the Business Address
            if(responseWrapper.containsKey('otherLocWorkInfo')){
                //populate the Other Work location address on Case
                responseModelMap = (Map<String, object>) responseWrapper.get('otherLocWorkInfo');
                if(responseModelMap.get('isBusinessAddressDifferent') != null && (Boolean)responseModelMap.get('isBusinessAddressDifferent')){
                    cm = OWCOnlineClaimFormService.populateOtherWorkLocation(responseModelMap, cm, employerRecord);
                    OnlineClaim.Work_Address_Different__c = 'Yes';
                    onlineClaim.Address_Where_Worked_Street__c = (String) responseModelMap.get('otherBusinessStreetAddress');
                    onlineClaim.Address_Where_Worked_City__c = (String) responseModelMap.get('otherBusinessCity');
                    onlineClaim.Address_Where_Worked_State__c = (String) responseModelMap.get('otherBusinessState');
                    onlineClaim.Address_Where_Worked_Zip__c = (String) responseModelMap.get('otherBusinessZipCode');
                    if(String.isNotBlank(onlineClaim.Address_Where_Worked_Zip__c)){
                        otherLocationZipCode = onlineClaim.Address_Where_Worked_Zip__c.substring(0,5);
                    }
                    onlineClaim.Other_work_Location_Phone__c = (String) responseModelMap.get('otherBusinessPhone');
                    onlineClaim.Other_Work_Approximate_Location__c = (String) responseModelMap.get('approximateLocation');
                } else{
                    cm.WorkAddressDifferent__c = 'No';
                    //create the Work Location record
                    
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
            
            cm = OWCOnlineClaimFormService.populateFinalWagesData(responseModelMap, cm, onlineClaim);
            //lets clear the map
            if(responseModelMap != null)    responseModelMap.clear();
            //populte the Data for Workweek and Workday section
            responseModelMap = (Map<String, object>) responseWrapper.get('workWeekAndWorkDaysDetails');
            if(responseModelMap != null){
                onlineClaim.Employer_follows_the_standard_workweek__c = (String)responseModelMap.get('EmpFollowSatToSun');
                onlineClaim.Employer_defined_workweek__c = (String)responseModelMap.get('EmpDefinedWorkweek');
                onlineClaim.Employer_follows_the_standard_workday__c = (String)responseModelMap.get('EmpFollowMidnightToMidnight');
                onlineClaim.Employer_defined_workweek__c = (String)responseModelMap.get('EmpDefinedWorkweek');
                String BegDate = (String)responseModelMap.get('BegDate');
                onlineClaim.Defined_workday_start_time__c = BegDate;
                String EndDate = (String)responseModelMap.get('EndDate');
                onlineClaim.Defined_workday_start_time__c = EndDate;
            }
            if(responseModelMap != null )   responseModelMap.clear();
            

            
            //parse the paymentOfWagesDetails data 
            responseModelMap = (Map<String, object>) responseWrapper.get('paymentOfWagesDetails');
            Map<String,Object> paymentData = new Map<String,Object>();
            Payment_of_wages__c POWrecord = new Payment_of_wages__c();
            paymentofWagesList = new List<Payment_of_wages__c> ();
            if(responseModelMap != null && responseModelMap.containsKey('agreementDocs') && responseModelMap.get('agreementDocs') != null
               && responseModelMap.get('agreementDocs') != ''){
                   uploadedDocList = (List<Object>) responseModelMap.get('agreementDocs');
                   if(uploadedDocList != null){
                       OWCOnlineClaimFormService.prepareUploadedDocuments(uploadedDocList, documentLinks);
                       system.debug('documentLinks paymentOfWagesDetails upload...'+documentLinks.size());
                       //clear the docs list
                       uploadedDocList.clear();
                       system.debug('documentLinks: '+documentLinks);
                   }
               }
            if(responseModelMap != null){
               paymentofWagesList = OWCOnlineClaimFormService.preparePaymentOfWagesData(responseModelMap);
               cm = OWCOnlineClaimFormService.updatePOWonInitialClaim(responseModelMap, cm);
            }






            if(responseModelMap != null )   responseModelMap.clear();
            
            //populate the hours You Typically Worked data
            responseModelMap = (Map<String, object>) responseWrapper.get('hoursYouTypicallyWorkedDetails');
            if(responseModelMap != null){
                onlineClaim.Did_you_missed_Days_of_work__c = (String)responseModelMap.get('workMissedReason'); 
                onlineClaim.Number_of_days_missed__c = responseModelMap.get('daysMissed') != null ?
                    Integer.valueOf((String)responseModelMap.get('daysMissed')) : null; 
                onlineClaim.Reason_for_missed_work__c = (String)responseModelMap.get('whyDaysMissed'); 
                //onlineClaim.Holidays_you_did_not_work__c = (String)responseModelMap.get('selectedHolidayOptions');
                if((Boolean)responseModelMap.get('isCompanyHolidayOther')){
                    
                }
                
            }
            //prepare doc for overTimeSheet 
            if(responseModelMap != null && responseModelMap.containsKey('overTimeSheet') && responseModelMap.get('overTimeSheet') != null
               &&  responseModelMap.get('overTimeSheet')  != ''){
                   uploadedDocList = (List<Object>) responseModelMap.get('overTimeSheet');
                   if(uploadedDocList != null){
                       OWCOnlineClaimFormService.prepareUploadedDocuments(uploadedDocList, documentLinks);
                       system.debug('documentLinks overTimeSheet upload...'+documentLinks.size());
                       //clear the docs list
                       uploadedDocList.clear();
                   }
               }
            system.debug('documentLinks: '+documentLinks);
            
            //prepare doc for vacation Time Claim Details 
            if(responseModelMap != null && responseModelMap.containsKey('vacationTimeClaimDetails') && responseModelMap.get('vacationTimeClaimDetails') != null
               && responseModelMap.get('vacationTimeClaimDetails') != null){
                   uploadedDocList = (List<Object>) responseModelMap.get('vacationTimeClaimDetails');
                   if(uploadedDocList != null){
                       OWCOnlineClaimFormService.prepareUploadedDocuments(uploadedDocList, documentLinks);
                       //clear the docs list
                       uploadedDocList.clear();
                   }
               }
            
            //Create label section files
            responseModelMap = (Map<String, object>) responseWrapper.get('labelDetails');
            if(responseModelMap != null && responseModelMap.get('labelDetails') != null && responseModelMap.get('labelDetails') != ''){
                List<Object> labelSectionDetails = (List<Object>) responseModelMap.get('labelDetails');
                for(Object labelObj : labelSectionDetails){
                    Map<String, object> labelObjMap = (Map<String, object>) labelObj;
                    if(labelObjMap != null && labelObjMap.get('uploadRNDocument') != null && labelObjMap.get('uploadRNDocument') != ''){
                        uploadedDocList = (List<Object>) labelObjMap.get('uploadRNDocument');
                        if(uploadedDocList != null){
                            OWCOnlineClaimFormService.prepareUploadedDocuments(uploadedDocList, documentLinks);
                            system.debug('documentLinks paymentOfWagesDetails upload...'+documentLinks.size());
                            //clear the docs list
                            uploadedDocList.clear();
                            system.debug('documentLinks: '+documentLinks);
                        }
                    }
                }
            }
            
            if(responseModelMap != null )   responseModelMap.clear();
            
            //prepare Data for certAndAuth Details section
            responseModelMap = (Map<String, object>) responseWrapper.get('certAndAuthDetails');
            //prepare doc for Union Contract Details 
            
            if(responseModelMap != null && responseModelMap.containsKey('addtionalClaimDocs') && responseModelMap.get('addtionalClaimDocs') != null
               && responseModelMap.get('addtionalClaimDocs') != '')
            {
                
                uploadedDocList = (List<Object>) responseModelMap.get('addtionalClaimDocs');
                if(uploadedDocList != null){
                    OWCOnlineClaimFormService.prepareUploadedDocuments(uploadedDocList, documentLinks);
                    //clear the docs list
                    uploadedDocList.clear();
                }
            }
            //lets clear the map
            if(responseModelMap != null )   responseModelMap.clear();
            
            
            //get the wageDefDetails
            List<object> wageDetailsList = new List<object>();
            wageDetailsList = (List<object>) responseWrapper.get('wageDeficiencyDetails');
            OWCOnlineClaimFormService.parseWageDetails(wageDetailsList, documentLinks);
            
            system.debug('documentLinks: '+documentLinks);
            //populate the Other fields on CM record
            OWCOnlineClaimFormService.prepareCaseRecord(cm); 
            
            
            /*if(1 == 1 ){
OCEmailServiceUtility.sendTestEmail(onlineClaimDetails);
return null;
}       */
            
            //check for Office Location
            //claimantZipCode ;*Divya
            //defendantZipCode;
            //otherLocationZipCode;
            //Add new condition for claimant garment to assign Los Angeles garment office to case.
            if(isGarmentDutyFollowed){
                //cm.Office__c = garment_Office_Los_Angeles;
            }
            else{
                cm.Office_Location_Zip_Code__c = OWCServiceUtility.validateOfficeAssignment(claimantZipCode, defendantZipCode, otherLocationZipCode);
            }
            /*else if(defendantZipCode != claimantZipCode && defendantZipCode != otherLocationZipCode && claimantZipCode != otherLocationZipCode){
                //4.1 Check if zipcode is CA
                cm.Office_Location_Zip_Code__c = claimantZipCode;
            }
            else if(String.isNotBlank(otherLocationZipCode)){
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
            System.debug('Case Status 562 ::: '+cm.Status__c);
            //Create the Records in salesforce
            insert cm;
            onlineClaim.Case_Management__c = cm.Id;
            //insert onlineClaim;
            //
            //create the Initial Case Issues for the Wage Deficiences for the Claim
            if(vtCaseIssues != null && vtCaseIssues != ''){
                if(!isGarmentDutyFollowed && (applicantType == 'Yourself' || applicantType == 'Representative')){
                    OWCcaseIssueUtility.parseResponse(vtCaseIssues , cm.Id);
                }
            }



            if(paymentofWagesList.size() >0 ) {
                for(Payment_of_wages__c pw: paymentofWagesList){
                    pw.Case_Management__c = cm.Id; 
                }
                insert paymentofWagesList;
            }
            /*if(1 == 1){
throw new AuraHandledException('Vikas is working...8377922024');
}   */
            // Add newly created case management record to the JSON object No Need to attach CM record to Json record as Json record will delete at this point.
            //OWCSaveDraftController.createOWCJSONResponse(onlineClaimDetails, sectionId, draftRecordId, cm.Id);
            //System.debug('Case JSON ::: '+[SELECT Id from DIR_Case__c where Id =: cm.Id]);
            //generatePDF(cm.Id);
            //populate Case on Related Parties
            if(additinalPersonList != null){
                for(Related_Party__c rp: additinalPersonList){
                    relatedPartyList.add(rp);
                }
            }
            if(relatedPartyList.size() >0 ) {
                for(Related_Party__c rp: relatedPartyList){
                    rp.Case_Management__c = cm.Id; 
                }
                insert relatedPartyList;
                //createRelatedPartyRecords(Json.serialize(relatedPartyList));
            }
            
            for(Related_Party__c rp: relatedPartyList){
                system.debug('rp.Phone__c:' +rp.Phone__c);
                if(rp.Role__c == 'Claimant' && String.isNotBlank(rp.Phone__c)){
                    //String smsStatus = SendTextMessage.sendSMS(rp.Id, 'related_party__c', rp.Phone__c, 'Claim Confirmation');
                    //Task tsk = new task(description = smsStatus );
                    //insert tsk;
                }
                
            }
            /********************************************************************
* @depricated, as the case roles will not create
List<Case_Role__c> caseRolesToCreate = new List<Case_Role__c>();
caseRolesToCreate.add(
OWCOnlineClaimFormService.prepareCaseRole(cm.Id, employerRecord.Id, 'Defendand', wca_Case_Role_RecordType_Id)
);
if(applicantType == 'Yourself'){
caseRolesToCreate.add(
OWCOnlineClaimFormService.prepareCaseRole(cm.Id, employerRecord.Id, 'Claimant', wca_Case_Role_RecordType_Id)
);
} 
System.debug(' accountId ::: '+employerRecord.Id);
if(representativeRecord != null){
if(String.isNotBlank(representativeRecord.Id))  {
caseRolesToCreate.add(
OWCOnlineClaimFormService.prepareCaseRole(cm.Id, employerRecord.Id, 'Attorney Representative', wca_Case_Role_RecordType_Id)
);
}
}

//insert caseRolesToCreate;

************************************************************/
            
            //Delete Json Record when case is created if Draft record exist.
            if(String.isNotBlank(draftRecordId)){
                List<Online_Claim_Draft__c> jsonRecord = [SELECT id FROM Online_Claim_Draft__c WHERE Id =: draftRecordId];
                if(jsonRecord != null && jsonRecord.size() >0){
                    delete jsonRecord;
                }
            }
            wageClaimWrapper wcWrapper = new wageClaimWrapper();
            wcWrapper.isSuccess = true;
            wcWrapper.caseId = cm.Id;
            wcWrapper.documentLinks = documentLinks;
            return wcWrapper;
            //return cm.Id;
            
        } catch (Exception e) {
            wageClaimWrapper wcWrapper = new wageClaimWrapper();
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            List<DIR_Case__c> caseObj = [SELECT Id FROM DIR_Case__c WHERE Id =: cm.Id];
            if(caseObj != null && caseObj.size() > 0){
                //deleteCaseRecord(caseObj[0].Id);
                wcWrapper.caseId = caseObj[0].Id;
            }
            //Fix for OWC-1133
            //Create error log records
            new OWCServiceUtility().Log(e);
            wcWrapper.isSuccess = false;
            wcWrapper.documentLinks = documentLinks;
            wcWrapper.fullErrorMsg = errorMessage+e.getStackTraceString();
            wcWrapper.error = Label.owcWageClaimSubmitError;
            return wcWrapper;
        }
    }
    
    public class wageClaimWrapper{
        @auraenabled
        public List<ContentDocumentLink> documentLinks;
        @auraenabled
        public String caseId;
        @auraenabled
        public boolean isSuccess;
        @auraenabled
        public String error;
        @auraenabled
        public String fullErrorMsg;
    }
    private static void createDocumentLinks(List<String> ContentDocumentIdList, String documentLinksJson){
        try{
            List<ContentVersion> ContentVersionToUpdate = new List<ContentVersion>();
            for(ContentVersion contentVersion_2 : [SELECT Id, Title, ContentDocumentId 
                                                   FROM ContentVersion WHERE ContentDocumentId IN :ContentDocumentIdList])
            {
                contentVersion_2.title = contentVersion_2.title + '- Online Claim';
                Integer extraLength = contentVersion_2.title.length() - 80 ;
                if(extraLength > 0){
                    contentVersion_2.title = contentVersion_2.title.substring(extraLength);
                }
                ContentVersionToUpdate.add(contentVersion_2);
            }
            if(!Test.isRunningTest()){
                update ContentVersionToUpdate;
            }
            
            //create Document Links
            
            List<ContentDocumentLink> documentLinks = (List<ContentDocumentLink>)JSON.deserialize(documentLinksJson, List<ContentDocumentLink>.class);
            if(documentLinks != null && !Test.isRunningTest()){
                Database.insert(documentLinks, false);
            }
        }
        catch(Exception e){
            system.debug('e.getMessage(): '+e.getMessage());
            system.debug('Error line: '+e.getLineNumber());
            system.debug('Stack line: '+e.getStackTraceString());
            
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
    private static Dir_Case__c createCaseRecord(Map<String, object> claimantSectionData) {
        Dir_Case__c cm = new Dir_Case__c();
        System.debug('cm ::: '+cm);
        return cm;
    }
    
    //Method used to create PDF attachment
    @AuraEnabled
    public static wageClaimWrapper generatePDF(String caseRecordId, String documentLinks){
        
        /*System.debug('caseRecordId ::: '+caseRecordId); 
caseRecordId = caseRecordId.remove('"');
List<DIR_Case__c> cseList = [SELECT Id FROM DIR_Case__c WHERE Id = :caseRecordId ];
OCEmailServiceUtility.sendConfirmationEmailtoClaimant(cseList);*/
        wageClaimWrapper wcWrapper = new wageClaimWrapper();
        try{
            caseRecordId = caseRecordId.remove('"');
            Pagereference pg = Page.OnlineWageClaimPDFPage;
            pg.getParameters().put('caseManagementId', caseRecordId);
            
            ContentVersion cont = new ContentVersion();
            
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
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = : cont.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caseRecordId.remove('"');
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            contentlink.Visibility = 'AllUsers';
            insert contentlink;
            system.debug('contentlink: '+contentlink);
            
            List<DIR_Case__c> cseList = [SELECT Id FROM DIR_Case__c WHERE Id = :caseRecordId ];
            OCEmailServiceUtility.sendConfirmationEmailtoClaimant(cseList);
            
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Test';
            cd.ContentVersionId = cont.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;   
            
            List<ContentDocumentLink> contentDocs = (List<ContentDocumentLink>) JSON.deserialize(documentLinks, List<ContentDocumentLink>.class);
            System.debug('contentDocs ::: '+contentDocs);
            List<String> ContentDocumentIdList = new List<String>();
            for(ContentDocumentLink cdObj : contentDocs){
                ContentDocumentIdList.add(cdObj.contentDocumentId);
                cdObj.linkedEntityId = caseRecordId;
                cdObj.Visibility = 'AllUsers';
                system.debug('cd.linkedEntityId: '+cdObj.linkedEntityId);
                system.debug('cm.Id: '+caseRecordId);
            }
            
            //Fix Jira OWC-740
            createDocumentLinks(ContentDocumentIdList, Json.serialize(contentDocs));
            
            wcWrapper.isSuccess = true;
        }
        catch(Exception e){
            List<DIR_Case__c> caseObj = [SELECT Id FROM DIR_Case__c WHERE Id =: caseRecordId];
            if(caseObj != null && caseObj.size() > 0){
                //deleteCaseRecord(caseObj[0].Id);
                wcWrapper.caseId = caseObj[0].Id;
            }
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            //Create error log records
            new OWCServiceUtility().Log(e);
            wcWrapper.isSuccess = false;
            wcWrapper.fullErrorMsg = errorMessage+e.getStackTraceString();
            wcWrapper.error = Label.owcWageClaimSubmitError;
        }
        return wcWrapper;
    }
    
    @AuraEnabled
    public static void deleteCaseRecord(String caseRecordId, String draftRecordId){
        OWCServiceUtility.isDeletedErrorClaim = true;
        System.debug('recordId ::: '+caseRecordId);
        List<Online_Claim_Draft__c> draftObj = [SELECT Id, Name FROM Online_Claim_Draft__c WHERE Id =: draftRecordId];
        List<DIR_Case__c> caseObj = [SELECT Id FROM DIR_Case__c WHERE Id =: caseRecordId];
        if(caseObj != null && caseObj.size() > 0){
            delete caseObj[0];
        }
        if(draftObj != null && draftObj.size() > 0){
            delete draftObj[0];
        }
    }
    
    //Used to update the case record with the interview PDF
    @AuraEnabled
    public static serverResponseWrapper updateCaseRec(String onlineClaimDetails, String recordId){
        serverResponseWrapper serverWrapObj = new serverResponseWrapper();
        try{
            DIR_Case__c caseObj = [SELECT Id, Name, Case_Number__c, Garment_Interview_JSON__c
                                   FROM DIR_Case__c WHERE ID =: recordId limit 1];
            
            if(caseObj != null){
                caseObj.Garment_Interview_JSON__c = onlineClaimDetails;
                serverWrapObj.isSuccess = true;
                serverWrapObj.serverMsg = 'Success';
                update caseObj;
            }
            else{
                serverWrapObj.isSuccess = false;
                serverWrapObj.serverMsg = 'Failed';
            }
            return serverWrapObj;
        }
        catch (Exception e) {
            //new LogException().Module('LogException').log(e);
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            throw new AuraHandledException(errorMessage+e.getStackTraceString());
        }
    }    
    //Method used to create Interview PDF
    @AuraEnabled
    public static ContentDocumentLink generateInterviewPDF(String onlineClaimDetails, String recordId){
        DIR_Case__c caseObj = [SELECT Id, Name, Case_Number__c, Garment_Interview_JSON__c
                               FROM DIR_Case__c WHERE ID =: recordId limit 1];
        //OCEmailServiceUtility.sendTestEmail(caseObj.Garment_Interview_JSON__c);
        // Create Interview PDF title
        String interviewPDFTitle = 'Garment Interview' + '-' + caseObj.Case_Number__c + '-' + todayDate();
        
        Pagereference pg = Page.OWCGarmentInterviewPDFPage;
        pg.getParameters().put('caseManagementId', recordId);
        
        ContentVersion cont = new ContentVersion();
        
        cont.Title = interviewPDFTitle;
        cont.PathOnClient = 'online_claim_summary.pdf';
        if(Test.isRunningTest()){
            cont.VersionData = blob.valueOf('Unit.Test'); 
        }
        else{
            cont.VersionData = pg.getContentAsPDF();
        }
        
        //cont.
        cont.Origin = 'H';
        insert cont;  
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :cont.Id LIMIT 1];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = recordId;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
        system.debug('contentlink: '+contentlink);
        
        List<DIR_Case__c> cseList = [SELECT Id,Garment_Interview_JSON__c FROM DIR_Case__c WHERE Id = : recordId ];
        if(cseList.size() > 0 && String.isNotBlank(cseList[0].Garment_Interview_JSON__c)){
            cseList[0].Garment_Interview_JSON__c = '';
        }
        update cseList;
        //OCEmailServiceUtility.sendConfirmationEmailtoClaimant(cseList);
        
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Test';
        cd.ContentVersionId = cont.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
        return contentlink;
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