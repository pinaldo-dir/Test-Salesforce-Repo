public class OWCOnlineClaimThirdPartyAPIService {
    public static String employee_RelatedParty_RecordType_Id = OWCConstants.EMPLOYEE_RELATED_PARTY_RECORD_TYPE_ID;
    public static String claimant_RelatedParty_RecordType_Id = OWCConstants.CLAIMANT_RELATED_PARTY_RECORD_TYPE_ID;
    public static String employer_RelatedParty_RecordType_Id = OWCConstants.EMPLOYER_RELATED_PARTY_RECORD_TYPE_ID;
    public static String advocate_RelatedParty_RecordType_Id = OWCConstants.ADVOCATE_RELATED_PARTY_RECORD_TYPE_ID;
    public static String person_Account_RecordType_Id = OWCConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
    public static String business_Account_RecordType_Id = OWCConstants.BUSINESS_ACCOUNT_RECORD_TYPE_ID;
    public static String law_Firm_Account_RecordType_Id = OWCConstants.LAW_FIRM_ACCOUNT_RECORD_TYPE_ID;
    public static OWCOnlineClaimFormValidatorService.ValidatorResponseWrapper wrapperResponse;
    
    /*************
    * @method prepareRelatedPartyForLawFirmRepresentative 
    * @descirption: Use to prepare the Related Party data for Law Firm Representative 
    * @param claimantDataMap: map object to hold the LawFirm Representative section data
    * @return Related Party record
    ********/
    //Prepate Representative Data (LawFirm) (Related_Party)
    public static Related_Party__c prepareRelatedPartyForLawFirmRepresentative(Map<String, object> claimantDataMap) {
        System.debug('claimantDataMap::::'+claimantDataMap);
        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.validateClaimantAdvocateData(claimantDataMap);
        Related_Party__c relatedParty = new Related_Party__c();
        relatedParty.Business_Name__c  = String.isNotBlank((String) claimantDataMap.get('lawfirmRepBusinessName')) ? (String) claimantDataMap.get('lawfirmRepBusinessName') : (String) claimantDataMap.get('lawfirmRepAttorney');
        relatedParty.Phone__c = (String) claimantDataMap.get('lawfirmRepStatePhone');
        //relatedParty.Cell_Phone__c = (String) claimantDataMap.get('yourselfCellPhone');
        //relatedParty.Birthdate__c  = String.isNotBlank((String) claimantDataMap.get('yourselfBirthDate')) ? Date.valueOf((String) claimantDataMap.get('yourselfBirthDate')) : null;
        relatedParty.Email__c = (String) claimantDataMap.get('lawfirmRepEmail');
        relatedParty.Street_Address__c = (String) claimantDataMap.get('lawfirmRepStreetAddress');
        relatedParty.City__c = (String) claimantDataMap.get('lawfirmRepCity');
        relatedParty.State__c = (String) claimantDataMap.get('lawfirmRepState');
        if((String)claimantDataMap.get('countryCodelawfirmRepStatePhone') != null){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String)claimantDataMap.get('countryCodelawfirmRepStatePhone'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
        }
        
        String zipCode = (String) claimantDataMap.get('lawFirmRepZipCode');
        if(String.isNotBlank(zipCode) ){
            relatedParty.Zip_Code__c = zipCode;
        }
        relatedParty.Role__c = 'Advocate';
        relatedParty.RecordTypeId = advocate_RelatedParty_RecordType_Id;
        return relatedParty;
    }
    
    //Prepate Employer Data (Account)
    
    public static List<Related_Party__c> prepareEmployerData(List<object> employerData, Address__c location, List<ContentDocumentLink> documentLinks, Online_claim__c onlineClaim,Dir_Case__c cm, List<Related_Party__c> additinalPersonList) {
        //Check for validation
        System.debug('employerData >>>:::: '+employerData);
        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.validateEmployerData(employerData);
        System.debug('Result fieldValidationError '+OnlineWageClaimThirdPartyAPIController.fieldValidationError);
        Boolean employerCreated = false;
        List<Related_Party__c> employerList = new List<Related_Party__c>();
        for(Object obj: employerData) {
            Map<String, Object> employerMap = (Map<String, Object>) obj;
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_Employer_Business_Type__mdt.getAll().values(), (String)employerMap.get('representativeEmployerType'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
            //lets check the Employer Name should not be empty
            if( (employerMap.get('individualLastName') != null && String.isNotBlank((String)employerMap.get('individualLastName')))
               || (employerMap.get('OtherIndividualBusinessName') != null && String.isNotBlank((String)employerMap.get('OtherIndividualBusinessName')))
              ) 
            {
                Related_Party__c employer = new Related_Party__c();
                if(!employerCreated){
                    //lets create the defendant related party
                    employer.Role__c = 'Defendant'; 
                    //covid details
                    cm.COVID_19__c = String.isNotBlank((String) employerMap.get('covid19Claim')) && (String) employerMap.get('covid19Claim') == 'Yes' ? (String) employerMap.get('covid19Claim') : 'No';
                    if(employerMap.get('isEmployeeFilingWageClaimOther') != null && (Boolean) employerMap.get('isEmployeeFilingWageClaimOther')){
                        cm.Covid_Other_Reason__c = (String) employerMap.get('specifyOtherReason');
                    }
                    employerCreated = true;
                } else {
                    employer.Role__c = 'Defendant - Successor'; 
                }
                
                if((String)employerMap.get('representativeEmployerType') == 'Individual/Sole Proprietor'){
                    employer.First_Name__c = (String)employerMap.get('individualFirstName');
                    employer.Last_Name__c = (String)employerMap.get('individualLastName');
                    employer.Street_Address__c = (String)employerMap.get('individualStreetAddress');
                    employer.City__c = (String)employerMap.get('individualCity');
                    employer.State__c = (String)employerMap.get('individualState');
                    String zipCode = (String)employerMap.get('individualZipCode');
                    if(String.isNotBlank(zipCode) ){
                        employer.Zip_Code__c = zipCode;
                    }
                    
                    employer.Phone__c = (String)employerMap.get('individualBusinessPhone');
                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String)employerMap.get('countryCodeindividualBusinessPhone'), false);
                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                        return null;
                    }
                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String)employerMap.get('countryCodeindividualCellPhone'), false);
                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                        return null;
                    }
                    employer.Email__c = (String)employerMap.get('individualEmail');
                    
                    employer.RecordTypeId = employer_RelatedParty_RecordType_Id;
                    employer.Number_of_employees__c = (String) employerMap.get('additionalTotalEmployees') != null ? (Integer.valueOf((String) employerMap.get('additionalTotalEmployees'))) : null;
                    
                    // populate other location  data
                    location.Address__c = (String)employerMap.get('individualStreetAddress');
                    location.City__c = (String)employerMap.get('individualCity');
                    location.State__c = (String)employerMap.get('individualState');
                    location.Zip_Code__c = zipCode;
                }
                else if((String)employerMap.get('representativeEmployerType') == 'Corporation'){
                    system.debug('Corporation');
                    employer.Business_Name__c = (String)employerMap.get('OtherIndividualBusinessName');
                    employer.Street_Address__c = (String)employerMap.get('OtherIndividualStreetAddress');
                    employer.City__c = (String)employerMap.get('OtherIndividualCity');
                    employer.State__c = (String)employerMap.get('OtherIndividualState');
                    String zipCode = (String)employerMap.get('OtherIndividualZipCode');
                    if(String.isNotBlank(zipCode) ){
                        employer.Zip_Code__c = zipCode;
                    }
                    employer.Phone__c = (String)employerMap.get('OtherIndividualPhone');
                    employer.Email__c = (String)employerMap.get('OtherIndividualEmail');
                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String)employerMap.get('countryCodeOtherIndividualPhone'), false);
                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                        return null;
                    }
                    //employer.Website = (String) employerMap.get('OtherIndividualWebsite');
                    employer.RecordTypeId = employer_RelatedParty_RecordType_Id;
                    //lets check for the Existing Employer
                    //Account existingAccount = OWCServiceUtility.getDuplicateAccount(employer);
                    /*
if(existingAccount == null){
// populate location record data
location.Address__c = (String)employerMap.get('individualStreetAddress');
location.City__c = (String)employerMap.get('individualCity');
location.State__c = (String)employerMap.get('individualState');
location.Zip_Code__c = (String)employerMap.get('individualZipCode');
}else{
return existingAccount;
}
*/
                }
                else {
                    system.debug('other business');
                    employer.Business_Name__c = (String)employerMap.get('OtherIndividualBusinessName');
                    employer.Street_Address__c = (String)employerMap.get('OtherIndividualStreetAddress');
                    employer.City__c = (String)employerMap.get('OtherIndividualCity');
                    employer.State__c = (String)employerMap.get('OtherIndividualState');
                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String)employerMap.get('countryCodeOtherIndividualPhone'), false);
                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                        return null;
                    }
                    String zipCode = (String)employerMap.get('OtherIndividualZipCode');
                    if(String.isNotBlank(zipCode) ){
                        /* Fix for keep the hypen in Zip Code
if(zipCode.contains('-')){
zipCode = zipCode.replace('-', '');
}	*/
                        employer.Zip_Code__c = zipCode;
                    }
                    employer.Phone__c = (String)employerMap.get('OtherIndividualPhone');
                    employer.Email__c = (String)employerMap.get('OtherIndividualEmail');
                    //employer.Website = (String) employerMap.get('OtherIndividualWebsite');
                    employer.RecordTypeId = employer_RelatedParty_RecordType_Id;
                    //lets check for the Existing Employer
                    //Account existingAccount = OWCServiceUtility.getDuplicateAccount(employer);
                    /*
if(existingAccount == null){
// populate location record data
location.Address__c = (String)employerMap.get('individualStreetAddress');
location.City__c = (String)employerMap.get('individualCity');
location.State__c = (String)employerMap.get('individualState');
location.Zip_Code__c = (String)employerMap.get('individualZipCode');
}else{
return existingAccount;
}
*/
                }
                
                // Lets check if Employer changed name 
                if(employerMap.get('isEmployerChangedName') != null && (Boolean)employerMap.get('isEmployerChangedName') == true){
                    if(employerMap.get('employerNameChangedDetails') != null){
                        Map<String, Object> changedEmployerMap = (Map<String, Object>) employerMap.get('employerNameChangedDetails');
                        Related_Party__c employerParty = parseEmployerDataValues(changedEmployerMap);
                        if(employerParty != null){
                            employerParty.Role__c = 'Defendant - Successor';
                            employerList.add(employerParty);
                        }
                    }
                }
                
                // Lets check if Employer changed After employment aka SuccessorDetails 
                if(employerMap.get('isEmployerChangedNameAfterEmployement') != null && (Boolean)employerMap.get('isEmployerChangedNameAfterEmployement') == true){
                    if(employerMap.get('successorDetails') != null){
                        Map<String, Object> successorEmployerMap = (Map<String, Object>) employerMap.get('successorDetails');
                        if(successorEmployerMap.get('successorDetails') != null){
                            List<object> successorData = new List<object>();
                            successorData = (List<object>) successorEmployerMap.get('successorDetails');
                            for(Object successorObj: successorData) {
                                Map<String, Object> successorMap = (Map<String, Object>) successorObj;
                                if((String) successorMap.get('ownershipOfCompRelated') != null){
                                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_Successor_Ownership_Type__mdt.getAll().values(), (String) successorMap.get('ownershipOfCompRelated'), false);
                                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                                        return null;
                                    }
                                }
                                if(successorMap.get('employerNameAfterEmployementDetails') != null){
                                    Map<String, Object> changedEmployerMap = (Map<String, Object>) successorMap.get('employerNameAfterEmployementDetails'); 
                                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_Employer_Business_Type__mdt.getAll().values(), (String)changedEmployerMap.get('representativeEmployerType'), false);
                                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                                        return null;
                                    }
                                    Related_Party__c employerParty = parseEmployerDataValues(changedEmployerMap);
                                    if(employerParty != null){
                                        employerParty.Role__c = 'Defendant - Successor';
                                        employerList.add(employerParty);
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Lets check if other employees also filing wage claims 
                if((String) employerMap.get('filingWageClaim') != null){
                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCPreliminaryCovid19Claim__mdt.getAll().values(), (String) employerMap.get('filingWageClaim'), false);
                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                        return null;
                    }
                }
                
                // Lets check if employer specify covid19 claim
                if((String) employerMap.get('specifyFilingWageClaim') != null){
                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCPreliminarySpecifyCovidClaim__mdt.getAll().values(), (String) employerMap.get('specifyFilingWageClaim'), false);
                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                        return null;
                    }
                }
                
                // Lets check how employer track working hours values
                if((String) employerMap.get('owcWorkRecordList') != null){
                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_WorkRecorded__mdt.getAll().values(), (String) employerMap.get('owcWorkRecordList'), false);
                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                        return null;
                    }
                }
                
                // Lets check if employer still in business
                if((String) employerMap.get('additionalEmpBusiness') != null){
                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCPreliminaryCovid19Claim__mdt.getAll().values(), (String) employerMap.get('additionalEmpBusiness'), false);
                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                        return null;
                    }
                }
                
                //Responsible person for loss
                if(employerMap.get('mileageClaimDetails') != null){	
                    try{
                        List<object> mileageClaimDetailsList = (List<object>)employerMap.get('mileageClaimDetails');
                        if(mileageClaimDetailsList != null){
                            for(Object personObj: mileageClaimDetailsList) { 	    
                                Related_Party__c additinalPerson = new Related_Party__c();
                                Map<String, Object> mileageClaimDetailsMap = (Map<String, Object>) personObj;
                                additinalPerson.First_Name__c =  mileageClaimDetailsMap.get('additinalPersonFirstName') != null ?
                                    (String) mileageClaimDetailsMap.get('additinalPersonFirstName') : null;
                                additinalPerson.Last_Name__c = mileageClaimDetailsMap.get('additinalPersonLastName') != null ?
                                    (String) mileageClaimDetailsMap.get('additinalPersonLastName') : null;
                                additinalPerson.RecordTypeId = employer_RelatedParty_RecordType_Id;
                                additinalPerson.Role__c = 'Defendant - Manager';
                                if(String.isNotBlank(additinalPerson.First_Name__c) || String.isNotBlank(additinalPerson.Last_Name__c)){
                                    additinalPersonList.add(additinalPerson);
                                }
                            }
                        }
                        //OCEmailServiceUtility.sendTestEmail(json.serialize(mileageClaimDetailsList));
                    }
                    
                    catch(exception ex){
                        system.debug('Error OWCOnlineClaimFormService: ' +ex.getStackTraceString() +' message: '+ex.getMessage());
                    }
                    
                }
                employerList.add(employer);
            }
            
        }
        return employerList;
    }
    
    //prepare the Related Party Data
    public static Related_Party__c prepareRelatedParty(Map<String, object> claimantDataMap){
        //Check for validation
        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.validateClaimantData(claimantDataMap);
        system.debug('claimantDataMap: '+Json.serialize(claimantDataMap));
        Related_Party__c relatedParty = new Related_Party__c();
        relatedParty.First_Name__c = (String) claimantDataMap.get('yourselfFirstName');
        relatedParty.Middle_Name__c = (String) claimantDataMap.get('yourselfMiddleName');
        relatedParty.Last_Name__c = (String) claimantDataMap.get('yourselfLastName');
        relatedParty.Home_Phone__c = (String) claimantDataMap.get('yourselfHomePhone');
        relatedParty.Mobile_Phone__c = (String) claimantDataMap.get('yourselfCellPhone');
        // As per OWC_439, The Phone field should auto-populate with either the Mobile Phone or Home Phone values,
        //  if both values are entered, Mobile Phone should populate into the Phone field.
        if(String.isNotBlank(relatedParty.Mobile_Phone__c)){
            relatedParty.Phone__c = relatedParty.Mobile_Phone__c;
        }else if(String.isNotBlank(relatedParty.Home_Phone__c)){
            relatedParty.Phone__c = relatedParty.Home_Phone__c;
        }
        if(String.isNotBlank((String) claimantDataMap.get('yourselfBirthDate'))){
            String claimantBirthDate = ((String) claimantDataMap.get('yourselfBirthDate')).replaceAll('/', '-');
            relatedParty.Birthdate__c = Date.valueOf(claimantBirthDate);
        }
        //relatedParty.Birthdate__c  = String.isNotBlank((String) claimantDataMap.get('yourselfBirthDate')) ? Date.valueOf((String) claimantDataMap.get('yourselfBirthDate')) : null;
        relatedParty.Email__c = (String) claimantDataMap.get('yourselfEmail');
        relatedParty.Street_Address__c = (String) claimantDataMap.get('yourselfStreetAddress');
        relatedParty.City__c = (String) claimantDataMap.get('yourselfCity');
        relatedParty.State__c = (String) claimantDataMap.get('yourselfState');
        String zipCode = (String)claimantDataMap.get('yourselfZipCode');
        try {
            Boolean opt_out_Status = claimantDataMap.get('isCellPhoneEntered') != null ? (Boolean)claimantDataMap.get('isCellPhoneEntered') : false; 
            relatedParty.SMS_Opt_Out__c = opt_out_Status;
        } catch(Exception ex){
            system.debug('error: '+ex.getMessage());
        }
        
        if(String.isNotBlank(zipCode) ){
            /* Fix for keep the hypen in Zip Code
if(zipCode.contains('-')){
zipCode = zipCode.replace('-', '');
}	*/
            relatedParty.Zip_Code__c = zipCode;
        }
        relatedParty.Role__c = 'Claimant';
        relatedParty.RecordTypeId = claimant_RelatedParty_RecordType_Id;
        return relatedParty;
    }
    //prepare Other Work Location mapping on Case Record
    public static Dir_Case__c populateOtherWorkLocation(Map<String, object> otherLocWorkInfoData, Dir_Case__c cm, Related_Party__c employerRecord){
        
        //Map<String, object> otherLocWorkInfoMap = (Map<String, object>) ot*thirdparty*pageherLocWorkInfoData.get('otherLocWorkInfo'); 
        System.debug('countryCode ::::: '+otherLocWorkInfoData);
        if(String.isNotBlank((String) otherLocWorkInfoData.get('workLocationBusinessAddress')) && ((String) otherLocWorkInfoData.get('workLocationBusinessAddress') == 'Yes') || (String) otherLocWorkInfoData.get('workLocationBusinessAddress') == 'sí'){
        //if(otherLocWorkInfoData.get('isBusinessAddressDifferent') != null && (Boolean)otherLocWorkInfoData.get('isBusinessAddressDifferent')){
        	//Validate other work location zipcode
            if(String.isNotBlank((String) otherLocWorkInfoData.get('otherBusinessZipCode'))){
                String zipCode = (String) otherLocWorkInfoData.get('otherBusinessZipCode');
                zipCode = zipCode.replace('-', '');
                if(zipCode.length() == 5 || zipCode.length() == 9){
                    
                }
                else{
                    OnlineWageClaimThirdPartyAPIController.fieldValidationError = ThirdPartyErrorMsgConstants.OTHERLOCATION_ZIPCODE_ERROR_MSG;
                }
            }
            else if(String.isBlank((String) otherLocWorkInfoData.get('otherBusinessZipCode'))){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = ThirdPartyErrorMsgConstants.OTHERLOCATION_ZIPCODE_REQUIRED_MSG;
            }
            cm.WorkAddressDifferent__c = 'Yes';
            cm.Address_Where_Worked_Street__c  = (String)otherLocWorkInfoData.get('otherBusinessStreetAddress');
            cm.Address_Where_Worked_City__c = (String)otherLocWorkInfoData.get('otherBusinessCity');
            cm.Address_Where_Worked_State__c = (String)otherLocWorkInfoData.get('otherBusinessState');
            cm.Address_Where_Worked_Zip__c = (String)otherLocWorkInfoData.get('otherBusinessZipCode');
            
            //add for Other phone
            //cm.phone = otherLocWorkInfoMap.get('otherBusinessPhone') != null ? (String)otherLocWorkInfoMap.get('otherBusinessPhone') : '';
            if(String.isNotBlank((String)otherLocWorkInfoData.get('countryCode'))){
                wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String)otherLocWorkInfoData.get('countryCode'), false);
                if(wrapperResponse != null && wrapperResponse.isValid == false){
                    OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                    return null;
                }
            }
            
            // populate other location  data
            employerRecord.Other_Street_Address__c = (String)otherLocWorkInfoData.get('otherBusinessStreetAddress');
            employerRecord.Other_City__c = (String)otherLocWorkInfoData.get('otherBusinessCity');
            employerRecord.Other_State__c = (String)otherLocWorkInfoData.get('otherBusinessState');
            employerRecord.Other_Zip_Code__c = (String)otherLocWorkInfoData.get('otherBusinessZipCode');
        } 
        else{
            cm.WorkAddressDifferent__c = 'No';
            OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
            return null;
            
        }
        
        
        return cm;
    }
    
    
    //prepare Final Wages Data on Case Record
    public static Dir_Case__c populateFinalWagesData(Map<String, object> finalWagesMap, Dir_Case__c cm,Online_claim__c onlineClaim) {
        if(finalWagesMap == null){
            return cm;
        }
        
        String str = (String)finalWagesMap.get('hireDate');
        if(String.isNotBlank(str)){
            OWCThirdPartyValidationCheckerController.dateFormatChecker(str, ThirdPartyErrorMsgConstants.HIRE_DATE_ERROR_MSG);
            if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                return null;
            }
        }
        
        onlineClaim.Date_of_Hire__c = String.isNotBlank(str)? date.valueOf(str) : null;
        onlineClaim.Name_of_person_who_hired_you__c = (String) finalWagesMap.get('nameOfPersonWhoHiredYou');
        if(String.isNotBlank((String) finalWagesMap.get('howWereYourWagesPaid'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCWagesPaidType__mdt.getAll().values(), (String)finalWagesMap.get('howWereYourWagesPaid'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
        }
        
        onlineClaim.How_were_your_wages_paid__c =  (String) finalWagesMap.get('howWereYourWagesPaid');
        onlineClaim.Any_Paycheck_bounce__c = finalWagesMap.get('isChequeBounce') != null ? (Boolean) finalWagesMap.get('isChequeBounce') : null;
        onlineClaim.Check_replaced__c = (String) finalWagesMap.get('chequeReplaced');	
        String chequeReplacedDate = (String)finalWagesMap.get('chequeReplacedDate');
        onlineClaim.Check_replaced_Date__c = String.isNotBlank(chequeReplacedDate) ? date.valueOf(chequeReplacedDate) : null;
        if(String.isNotBlank((String) finalWagesMap.get('wereWagesPaid'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCEmployementStatusAndFinalWageOptions__mdt.getAll().values(), (String) finalWagesMap.get('wereWagesPaid'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
        }
        onlineClaim.Wages_always_paid_on_the_payday__c = (String) finalWagesMap.get('wereWagesPaid');
        if(String.isNotBlank((String) finalWagesMap.get('statementReceived'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCEmployementStatusAndFinalWageOptions__mdt.getAll().values(), (String) finalWagesMap.get('statementReceived'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
        }
        if(String.isNotBlank((String) finalWagesMap.get('payStubSickRecord'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCEmployementStatusAndFinalWageOptions__mdt.getAll().values(), (String) finalWagesMap.get('payStubSickRecord'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
        }
        if(String.isNotBlank((String) finalWagesMap.get('stillIdentifiedEmp'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCEmployementStatusAndFinalWageOptions__mdt.getAll().values(), (String) finalWagesMap.get('stillIdentifiedEmp'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
        }
        if(String.isNotBlank((String) finalWagesMap.get('selectAnyOne'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(owcQuitDateDischargeDate__mdt.getAll().values(), (String) finalWagesMap.get('selectAnyOne'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
        }
        if(String.isNotBlank((String)finalWagesMap.get('noticeBeforeQuiting'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCEmployementStatusAndFinalWageOptions__mdt.getAll().values(), (String)finalWagesMap.get('noticeBeforeQuiting'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
        }
        if(String.isNotBlank((String)finalWagesMap.get('receivedFinalPayment'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCEmployementStatusAndFinalWageOptions__mdt.getAll().values(), (String)finalWagesMap.get('receivedFinalPayment'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
        }
        if(String.isNotBlank((String)finalWagesMap.get('receivedFinalPayment2'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCEmployementStatusAndFinalWageOptions__mdt.getAll().values(), (String)finalWagesMap.get('receivedFinalPayment2'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return null;
            }
        }
        onlineClaim.Received_Itemized_Wage_Statements__c =  String.isNotBlank((String) finalWagesMap.get('statementReceived')) ? (String) finalWagesMap.get('statementReceived') : null;
        String stillIdentifiedEmp = (String) finalWagesMap.get('stillIdentifiedEmp'); 
        
        if(String.isNotBlank(stillIdentifiedEmp)){
            onlineClaim.ES_Still_Working_for_Employer__c = stillIdentifiedEmp;
            if(stillIdentifiedEmp == 'No'){
                //Quit Job Section
                String quitDate = (String)finalWagesMap.get('quitDate');
                String dischargedDate = (String)finalWagesMap.get('dischargedDate');
                if(String.isNotBlank(quitDate)){
                    OWCThirdPartyValidationCheckerController.dateFormatChecker(quitDate, ThirdPartyErrorMsgConstants.EMPLOYEMENT_QUIT_DATE_ERROR_MSG);
                    if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                        return null;
                    }
                }
                
                if(String.isNotBlank(dischargedDate)){
                    OWCThirdPartyValidationCheckerController.dateFormatChecker(dischargedDate, ThirdPartyErrorMsgConstants.EMPLOYEMENT_DISHCHARGED_DATE_ERROR_MSG);
                    if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                        return null;
                    }
                }

                if(String.isNotBlank(quitDate)){
                    cm.X72_Hour_Notice__c = (String)finalWagesMap.get('noticeBeforeQuiting');
                    cm.Quit_Discharged_Date__c = String.isNotBlank(quitDate)? date.valueOf(quitDate) : null;
                    onlineClaim.Discharged_Date__c = cm.Quit_Discharged_Date__c;
                }
                else if(String.isNotBlank(dischargedDate)){
                    onlineClaim.Discharged_Date__c = String.isNotBlank(dischargedDate)? date.valueOf(dischargedDate) : null;
                    cm.Quit_Discharged_Date__c = onlineClaim.Discharged_Date__c;
                    onlineClaim.Person_who_discharged_you__c = (String)finalWagesMap.get('personNameWhoDischargeYou');
                    onlineClaim.Received_all_your_wages_owed__c = (String)finalWagesMap.get('personNameWhoDischargeYou');
                    cm.Final_Wages_Received__c = (String)finalWagesMap.get('receivedFinalPayment');
                    if(String.isNotBlank(cm.Final_Wages_Received__c)){
                        String isreceivedFinalPayment = (String)finalWagesMap.get('noticeBeforeQuiting');
                        
                        if(isreceivedFinalPayment == 'Yes'){
                            String final_Payment_Date = (String)finalWagesMap.get('final_Payment_Date');
                            cm.Final_Payment_Date__c = String.isNotBlank(final_Payment_Date)? date.valueOf(final_Payment_Date) : null;
                            onlineClaim.Wage_received_date__c = cm.Final_Payment_Date__c;
                        }
                    }
                }
            }
        }
        return cm;
    }
    
    //prepare Industry Data on Case Record
    public static void populateIndustryData(Map<String, object> industryDataMap, Related_Party__c employer, Dir_Case__c cm, Online_claim__c onlineClaim){
        if(industryDataMap == null){
            return;
        }
        
        OWCThirdPartyValidationCheckerController.dateFormatChecker((String) industryDataMap.get('writtenReqDate'), ThirdPartyErrorMsgConstants.INDUSTRY_INVALID_WRITTEN_DATE_ERROR_MSG);
        OWCThirdPartyValidationCheckerController.dateFormatChecker((String) industryDataMap.get('statementDate'), ThirdPartyErrorMsgConstants.INDUSTRY_INVALID_STATEMENT_DATE_ERROR_MSG);
        if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
            OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
        }
        wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWCPrimaryIndustrySelection__mdt.getAll().values(), (String)industryDataMap.get('selectedIndustry'), true);
        if(wrapperResponse != null && wrapperResponse.isValid == false){
            OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
            return;
        }
        system.debug('industry...');
        String industry = String.isNotBlank((String) industryDataMap.get('selectedIndustry')) ? (String) industryDataMap.get('selectedIndustry') : null;  
        String subIndustry = String.isNotBlank((String) industryDataMap.get('selectedOption')) ? (String) industryDataMap.get('selectedOption') : null;
        List<OWCPrimaryIndustrySelection__mdt> primaryIndustryData = OWCPrimaryIndustrySelection__mdt.getAll().values();
        for(OWCPrimaryIndustrySelection__mdt mdtObj : primaryIndustryData){
            if(mdtObj.Value__c == industry){
                industry = mdtObj.Mapped_Value__c;
            }
        }
        onlineClaim.Industry_Detail__c = industry;
        system.debug('industry...: '+industry);
        system.debug('subIndustry...: '+subIndustry);
        //get the NAICS Code by sub-industry
        List<NAICS_Code__c> naicsCodes = [SELECT Id, Name, NAICS_Title__c, Level__c FROM NAICS_Code__c
                                          WHERE NAICS_Title__c =: industry order by IWC_Corder__c desc NULLS LAST];
        System.debug('naicsCodes ::: '+naicsCodes);
        if(naicsCodes != null && naicsCodes.size() >0){
            employer.NAICS_Code__c = naicsCodes[0].Id; 
            //get the Low-wage type by NAICS code
            /*
            List<BOFE_Low_Wage_Industry__c> lowWages = [SELECT Id, Name, Active__c, Industry__c FROM BOFE_Low_Wage_Industry__c
                                                        WHERE Name =: naicsCodes[0].Name];
            if(lowWages != null && lowWages.size() >0) {
                //cm.PAGA_entered_Industry__c = lowWages[0].Industry__c;
            }
			*/
        }
    }
    
    //prepare Work Location Data
    public static void prepareWorkLocationRecord(){
        
    }
    //Prepare Case Role Data (Case Role)
    public static Case_Role__c prepareCaseRole(String caseId, String accountId, String type, String recordTypeId) {
        System.debug('caseId ::: '+caseId+ ' accountId ::: '+accountId+' type ::: '+type+' recordTypeId ::: '+recordTypeId);
        Case_Role__c caseRole = new Case_Role__c(
            Case__c = caseId,
            Entity__c = accountId, 
            Role__c = type,
            recordTypeId = recordTypeId
        );
        return caseRole;
    }
    //prepare the uploaded documents
    public static void prepareUploadedDocuments(List<Object> uploadedDocMap, List<ContentDocumentLink> documentLinks){
        if(uploadedDocMap == null){
            return;
        }
        for(Object obj: uploadedDocMap) {
            Map<String, Object> docMap = (Map<String, Object>) obj;
            if(String.isNotBlank((String)docMap.get('documentId'))){
                system.debug('document Id: '+(String)docMap.get('documentId'));
                ContentDocumentLink link = new ContentDocumentLink(
                    //linkedEntityId = cm.Id;
                    contentDocumentId = (String)docMap.get('documentId')
                );
                documentLinks.add(link);
            }
        }
    }
    //prepare the uploaded documents
    public static void prepareUploadedDocumentsTest(List<Object> uploadedDocMap, List<ContentDocumentLink> documentLinks){
        ContentDocumentLink link = new ContentDocumentLink(
            //linkedEntityId = cm.Id;
            contentDocumentId = '068r0000004Jk8gAAC'
        );
        documentLinks.add(link);
    }
    
    public static void prepareCaseRecord(Dir_Case__c dirCase){
        dirCase.Intake_Origin__c = 'Online';
        dirCase.Referred_From__c = OnlineWageClaimContainerController.referred_From;
        
        //get Current Time as per Org Time Zone
        DateTime currenTime = System.now();//getTimeInOrgTimeZone(System.now());
        dirCase.VIP_Date_Time_Submitted__c = currenTime;
        dirCase.Date_Case_Received__c = OWCOnlineClaimFormService.nextBusinessDate();
        /*
        // Get the default business hours
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        // Find whether the time is within the default business hours
        Boolean isWithin= BusinessHours.isWithin(bh.id, currenTime);
        //lets set the next business datetime if current time is outside of business hours
        if(isWithin){
            dirCase.Date_Case_Received__c = currenTime.dateGMT();
        }
        else{
            Datetime nextStart = BusinessHours.nextStartDate(bh.id, currenTime);
            nextStart = nextStart;//OWCOnlineClaimFormService.getTimeInOrgTimeZone(nextStart);
            dirCase.Date_Case_Received__c = nextStart.dateGMT();
        }
        */
        //populate Date of Docketing if claimantConfirm true
        System.debug('check ::: '+OnlineWageClaimContainerController.claimantConfirm);
        if(OnlineWageClaimContainerController.claimantConfirm)	dirCase.Date_of_Docket__c  = dirCase.Date_Case_Received__c;
    } 
    public static String orgTimeZoneKey ;
    //get Current Time as per Org Time Zone
    public static DateTime getTimeInOrgTimeZone(DateTime timeInGMT){
        DateTime timeInOrgZone ;
        if(String.isBlank(orgTimeZoneKey)){
            orgTimeZoneKey = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
        }
        // Get the Org time zone
        Timezone tz = Timezone.getTimeZone(orgTimeZoneKey); 
        Integer timeZoneOffset = tz.getOffset(timeInGMT);
        //Convert timeZoneOffset milleseconds to minutes
        /*
timeZoneOffset = timeZoneOffset/(1000*60);
timeInOrgZone = timeInGMT.addMinutes(timeZoneOffset);
*/
        return timeInOrgZone;
    }
    
    public static void parseWageDetails(List<object> wageDetailsList, List<ContentDocumentLink> documentLinks){
        if(wageDetailsList != null){
            for(Object obj: wageDetailsList) {
                Map<String, Object> wageDetailsMap = (Map<String, Object>) obj;
                if(wageDetailsMap.containsKey('unreimbursedDoc') && wageDetailsMap.get('unreimbursedDoc') != null
                   &&  wageDetailsMap.get('unreimbursedDoc')  != '')
                {
                    List<Object>  uploadedDocList = (List<Object>) wageDetailsMap.get('unreimbursedDoc');
                    if(uploadedDocList != null){
                        OWCOnlineClaimFormService.prepareUploadedDocuments(uploadedDocList, documentLinks);
                        system.debug('documentLinks unreimbursedDoc upload...'+documentLinks.size());
                    }
                }
                if(wageDetailsMap.containsKey('vacationTimeClaimDetails') && wageDetailsMap.get('vacationTimeClaimDetails') != null
                   &&  wageDetailsMap.get('vacationTimeClaimDetails')  != '')
                { 
                    List<Object>  uploadedDocList = (List<Object>) wageDetailsMap.get('vacationTimeClaimDetails');
                    if(uploadedDocList != null){
                        OWCOnlineClaimFormService.prepareUploadedDocuments(uploadedDocList, documentLinks);
                        system.debug('documentLinks unreimbursedDoc upload...'+documentLinks.size());
                    }
                }
            }
        }
        
    }
    
    private static Related_Party__c parseEmployerDataValues(Map<String, Object> employerMap){
        System.debug('parseEmployerDataValues:::'+employerMap);
        Related_Party__c employer = new Related_Party__c();
        //lets check the Employer Name should not be empty
        if( (employerMap.get('individualLastName') != null && String.isNotBlank((String)employerMap.get('individualLastName'))) || (employerMap.get('OtherIndividualBusinessName') != null && String.isNotBlank((String)employerMap.get('OtherIndividualBusinessName')))) 
        {
            
            if((String)employerMap.get('representativeEmployerType') == 'Individual/Sole Proprietor'){
                system.debug('Individual/Sole Proprietor');	
                employer.First_Name__c = (String)employerMap.get('individualFirstName');
                employer.Last_Name__c = (String)employerMap.get('individualLastName');
                employer.Street_Address__c = (String)employerMap.get('individualStreetAddress');
                employer.City__c = (String)employerMap.get('individualCity');
                employer.State__c = (String)employerMap.get('individualState');
                wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String)employerMap.get('countryCodeindividualBusinessPhone'), false);
                if(wrapperResponse != null && wrapperResponse.isValid == false){ OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;return null;}
                wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String)employerMap.get('countryCodeindividualCellPhone'), false);
                if(wrapperResponse != null && wrapperResponse.isValid == false){OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;return null;}
                String zipCode = (String)employerMap.get('individualZipCode');
                if(String.isNotBlank(zipCode) ){
                    
                    employer.Zip_Code__c = zipCode;
                }
                
                employer.Phone__c = (String)employerMap.get('individualBusinessPhone');
                employer.Email__c = (String)employerMap.get('individualEmail');
                
                employer.RecordTypeId = employer_RelatedParty_RecordType_Id;
                //employer.Website = (String) employerMap.get('individualRepWebsite'); 
                System.debug('additionalTotalEmployees ::: '+employerMap.get('additionalTotalEmployees'));
                employer.Number_of_employees__c = (String) employerMap.get('additionalTotalEmployees') != null ? (Integer.valueOf((String) employerMap.get('additionalTotalEmployees'))) : null;
                
                return employer;
                
            }
            else if((String)employerMap.get('representativeEmployerType') == 'Corporation'){
                system.debug('Corporation');
                employer.Business_Name__c = (String)employerMap.get('OtherIndividualBusinessName');
                employer.Street_Address__c = (String)employerMap.get('OtherIndividualStreetAddress');
                employer.City__c = (String)employerMap.get('OtherIndividualCity');
                employer.State__c = (String)employerMap.get('OtherIndividualState');
                String zipCode = (String)employerMap.get('OtherIndividualZipCode');
                if(String.isNotBlank(zipCode) ){
                    
                    employer.Zip_Code__c = zipCode;
                }
                employer.Phone__c = (String)employerMap.get('OtherIndividualPhone');
                employer.Email__c = (String)employerMap.get('OtherIndividualEmail');
                wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String)employerMap.get('countryCodeOtherIndividualPhone'), false);
                if(wrapperResponse != null && wrapperResponse.isValid == false){
                    OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                    return null;
                }
                //employer.Website = (String) employerMap.get('OtherIndividualWebsite');
                employer.RecordTypeId = employer_RelatedParty_RecordType_Id;
                return employer;
            }
            else {
                system.debug('other business');
                employer.Business_Name__c = (String)employerMap.get('OtherIndividualBusinessName');
                employer.Street_Address__c = (String)employerMap.get('OtherIndividualStreetAddress');
                employer.City__c = (String)employerMap.get('OtherIndividualCity');
                employer.State__c = (String)employerMap.get('OtherIndividualState');
                wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OWC_CountryCode__mdt.getAll().values(), (String)employerMap.get('countryCodeOtherIndividualPhone'), false);
                if(wrapperResponse != null && wrapperResponse.isValid == false){
                    OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                    return null;
                }
                String zipCode = (String)employerMap.get('OtherIndividualZipCode');
                if(String.isNotBlank(zipCode) ){
                    
                    employer.Zip_Code__c = zipCode;
                }
                employer.Phone__c = (String)employerMap.get('OtherIndividualPhone');
                employer.Email__c = (String)employerMap.get('OtherIndividualEmail');
                //employer.Website = (String) employerMap.get('OtherIndividualWebsite');
                employer.RecordTypeId = employer_RelatedParty_RecordType_Id;
                return employer;
            }
        }
        return null;
    }
    
    public static void labelDetailsValidationCheck(Map<String, object> responseModelMap){
        System.debug('labelDetailsValidationCheck::::'+responseModelMap);
        List<Object> labelDetails = (List<Object>) responseModelMap.get('labelDetails');
        for(Object labelObj : labelDetails){
            Map<String, Object> labelMap = (Map<String, Object>) labelObj;
            if(String.isNotBlank((String) labelMap.get('labelStartDate'))){
                OWCThirdPartyValidationCheckerController.dateFormatChecker((String) labelMap.get('labelStartDate'), ThirdPartyErrorMsgConstants.LABEL_START_DATE_ERROR_MSG);
                if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                    OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                }
            }
            
            if(String.isNotBlank((String) labelMap.get('labelEndDate'))){
                OWCThirdPartyValidationCheckerController.dateFormatChecker((String) labelMap.get('labelEndDate'), ThirdPartyErrorMsgConstants.LABEL_END_DATE_ERROR_MSG);
                if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                    OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                }
            }
        }
    }
    
    public static void paymentOfWagesMap(Map<String, object> responseModelMap){
        if(String.isNotBlank((String) responseModelMap.get('hourlyRateBegDate'))){
            OWCThirdPartyValidationCheckerController.dateFormatChecker((String) responseModelMap.get('hourlyRateBegDate'), ThirdPartyErrorMsgConstants.POW_HOURLY_RATE_START_DATE_ERROR_MSG);
            if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('hourlyRateEndDate'))){
            OWCThirdPartyValidationCheckerController.dateFormatChecker((String) responseModelMap.get('hourlyRateEndDate'), ThirdPartyErrorMsgConstants.POW_HOURLY_RATE_END_DATE_ERROR_MSG);
            if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('differentHourlyRateBegDate'))){
            OWCThirdPartyValidationCheckerController.dateFormatChecker((String) responseModelMap.get('differentHourlyRateBegDate'), ThirdPartyErrorMsgConstants.POW_DIFFER_HOURLY_RATE_START_DATE_ERROR_MSG);
            if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('differentHourlyRateEndDate'))){
            OWCThirdPartyValidationCheckerController.dateFormatChecker((String) responseModelMap.get('differentHourlyRateEndDate'), ThirdPartyErrorMsgConstants.POW_DIFFER_HOURLY_RATE_END_DATE_ERROR_MSG);
            if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('eachPayRateBegDate'))){
            OWCThirdPartyValidationCheckerController.dateFormatChecker((String) responseModelMap.get('eachPayRateBegDate'), ThirdPartyErrorMsgConstants.POW_SALARY_HOURLY_RATE_START_DATE_ERROR_MSG);
            if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('eachPayRateEndDate'))){
            OWCThirdPartyValidationCheckerController.dateFormatChecker((String) responseModelMap.get('eachPayRateEndDate'), ThirdPartyErrorMsgConstants.POW_SALARY_HOURLY_RATE_END_DATE_ERROR_MSG);
            if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('pieceRateBegDate'))){
            OWCThirdPartyValidationCheckerController.dateFormatChecker((String) responseModelMap.get('pieceRateBegDate'), ThirdPartyErrorMsgConstants.POW_PIECE_RATE_START_DATE_ERROR_MSG);
            if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('pieceRateEndDate'))){
            OWCThirdPartyValidationCheckerController.dateFormatChecker((String) responseModelMap.get('pieceRateEndDate'), ThirdPartyErrorMsgConstants.POW_PIECE_RATE_END_DATE_ERROR_MSG);
            if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('frequencyOfEachDay'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(OwcFrequencyOption__mdt.getAll().values(), (String) responseModelMap.get('frequencyOfEachDay'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return;
            }
        }
        
        //Check picklist for Per unit
        if(String.isNotBlank((String) responseModelMap.get('perUnitPaymentOfWages'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(Owc_pOWagesPerUnitOption__mdt.getAll().values(), (String) responseModelMap.get('perUnitPaymentOfWages'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return;
            }
        }
        
        if(responseModelMap.get('salaryRateAdditionalDetails') != null){
            List<Object> salaryRateAdditional = (List<Object>) responseModelMap.get('salaryRateAdditionalDetails');
            System.debug('salaryRateAdditional:::'+salaryRateAdditional);
            for(Object salaryObj : salaryRateAdditional){
                Map<String, Object> employerMap = (Map<String, Object>) salaryObj;
                if(String.isNotBlank((String) employerMap.get('frequencyOfEachDayAdditional'))){
                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(Owc_pOWagesPerUnitOption__mdt.getAll().values(), (String) employerMap.get('frequencyOfEachDayAdditional'), false);
                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                        return;
                    }
                }
                
                if(String.isNotBlank((String) employerMap.get('eachPayRateBegDateAdditional'))){
                    OWCThirdPartyValidationCheckerController.dateFormatChecker((String) employerMap.get('eachPayRateBegDateAdditional'), ThirdPartyErrorMsgConstants.POW_SALARY_HOURLY_RATE_START_DATE_ERROR_MSG);
                    if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                    }
                }
                
                if(String.isNotBlank((String) employerMap.get('eachPayRateEndDateAdditional'))){
                    OWCThirdPartyValidationCheckerController.dateFormatChecker((String) employerMap.get('eachPayRateEndDateAdditional'), ThirdPartyErrorMsgConstants.POW_SALARY_HOURLY_RATE_END_DATE_ERROR_MSG);
                    if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                    }
                }
            }
        }
        
        if(responseModelMap.get('pieceRateAdditionalDetails') != null){
            List<Object> pieceRateAdditional = (List<Object>) responseModelMap.get('pieceRateAdditionalDetails');
            for(Object pieceObj : pieceRateAdditional){
                Map<String, Object> employerMap = (Map<String, Object>) pieceObj;
                if(String.isNotBlank((String) employerMap.get('perUnitPaymentOfWagesAdditional'))){
                    wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(Owc_pOWagesPerUnitOption__mdt.getAll().values(), (String) employerMap.get('perUnitPaymentOfWagesAdditional'), false);
                    if(wrapperResponse != null && wrapperResponse.isValid == false){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                        return;
                    }
                }
                
                if(String.isNotBlank((String) employerMap.get('pieceRateBegDateAdditional'))){
                    OWCThirdPartyValidationCheckerController.dateFormatChecker((String) employerMap.get('pieceRateBegDateAdditional'), ThirdPartyErrorMsgConstants.POW_PIECE_RATE_START_DATE_ERROR_MSG);
                    if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                    }
                }
                
                if(String.isNotBlank((String) employerMap.get('pieceRateEndDateAdditional'))){
                    OWCThirdPartyValidationCheckerController.dateFormatChecker((String) employerMap.get('pieceRateEndDateAdditional'), ThirdPartyErrorMsgConstants.POW_PIECE_RATE_END_DATE_ERROR_MSG);
                    if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                    }
                }
            }
        }
        
        if(responseModelMap.get('hourlyAdditionalDetails') != null){
            List<Object> hourlyAdditionalDetails = (List<Object>) responseModelMap.get('hourlyAdditionalDetails');
            for(Object hourlyAddObj : hourlyAdditionalDetails){
                Map<String, Object> hourlyObjMap = (Map<String, Object>) hourlyAddObj;
                
                if(String.isNotBlank((String) hourlyObjMap.get('hourlyRateBegDateAdditional'))){
                    OWCThirdPartyValidationCheckerController.dateFormatChecker((String) hourlyObjMap.get('hourlyRateBegDateAdditional'), ThirdPartyErrorMsgConstants.POW_HOURLY_RATE_START_DATE_ERROR_MSG);
                    if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                    }
                }
                
                if(String.isNotBlank((String) hourlyObjMap.get('hourlyRateEndDateAdditional'))){
                    OWCThirdPartyValidationCheckerController.dateFormatChecker((String) hourlyObjMap.get('hourlyRateEndDateAdditional'), ThirdPartyErrorMsgConstants.POW_HOURLY_RATE_END_DATE_ERROR_MSG);
                    if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                    }
                }
            }
        }
        
        if(responseModelMap.get('differentHourAdditionalDetails') != null){
            List<Object> differentHourAdditionalDetails = (List<Object>) responseModelMap.get('differentHourAdditionalDetails');
            for(Object diffHourlyObj : differentHourAdditionalDetails){
                Map<String, Object> diffHourlyMap = (Map<String, Object>) diffHourlyObj;
                
                if(String.isNotBlank((String) diffHourlyMap.get('differentHourlyRateBegDateAdditional'))){
                    OWCThirdPartyValidationCheckerController.dateFormatChecker((String) diffHourlyMap.get('differentHourlyRateBegDateAdditional'), ThirdPartyErrorMsgConstants.POW_DIFFER_HOURLY_RATE_START_DATE_ERROR_MSG);
                    if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                    }
                }
                
                if(String.isNotBlank((String) diffHourlyMap.get('differentHourlyRateEndDateAdditional'))){
                    OWCThirdPartyValidationCheckerController.dateFormatChecker((String) diffHourlyMap.get('differentHourlyRateEndDateAdditional'), ThirdPartyErrorMsgConstants.POW_DIFFER_HOURLY_RATE_END_DATE_ERROR_MSG);
                    if(String.isNotBlank(OnlineWageClaimThirdPartyAPIController.fieldMissingMsg)){
                        OnlineWageClaimThirdPartyAPIController.fieldValidationError = OnlineWageClaimThirdPartyAPIController.fieldMissingMsg;
                    }
                }
            }
        }
    }
    
    public static void workweekAndWorkDaysCheck(Map<String, object> responseModelMap){
        if(String.isNotBlank((String) responseModelMap.get('EmpFollowSatToSun'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(Owc_workWeek_YesOrNoOption__mdt.getAll().values(), (String) responseModelMap.get('EmpFollowSatToSun'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('EmpDefinedWorkweek'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(Owc_workWeekOption__mdt.getAll().values(), (String) responseModelMap.get('EmpDefinedWorkweek'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('EmpFollowMidnightToMidnight'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(Owc_workWeek_YesOrNoOption__mdt.getAll().values(), (String) responseModelMap.get('EmpFollowMidnightToMidnight'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return;
            }
        }
    }
    
    public static void demograhicInfoCheck(Map<String, object> responseModelMap){
        if(String.isNotBlank((String) responseModelMap.get('DemographicGenderIdentity'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(owc_demographic_gender__mdt.getAll().values(), (String) responseModelMap.get('DemographicGenderIdentity'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('DemographicRace'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(owc_demographic_race__mdt.getAll().values(), (String) responseModelMap.get('DemographicRace'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return;
            }
        }
        
        if(String.isNotBlank((String) responseModelMap.get('DemographicSexualOrientation'))){
            wrapperResponse = OWCOnlineClaimFormValidatorService.validateValuesByMetadata(owc_demographic_sexual_orientation__mdt.getAll().values(), (String) responseModelMap.get('DemographicSexualOrientation'), false);
            if(wrapperResponse != null && wrapperResponse.isValid == false){
                OnlineWageClaimThirdPartyAPIController.fieldValidationError = wrapperResponse.message;
                return;
            }
        }
    }
}