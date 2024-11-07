public class OWCOnlineClaimFormService {
    public static String employee_RelatedParty_RecordType_Id = OWCConstants.EMPLOYEE_RELATED_PARTY_RECORD_TYPE_ID;
    public static String claimant_RelatedParty_RecordType_Id = OWCConstants.CLAIMANT_RELATED_PARTY_RECORD_TYPE_ID;
    public static String employer_RelatedParty_RecordType_Id = OWCConstants.EMPLOYER_RELATED_PARTY_RECORD_TYPE_ID;
    public static String advocate_RelatedParty_RecordType_Id = OWCConstants.ADVOCATE_RELATED_PARTY_RECORD_TYPE_ID;
    public static String person_Account_RecordType_Id = OWCConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
    public static String business_Account_RecordType_Id = OWCConstants.BUSINESS_ACCOUNT_RECORD_TYPE_ID;
    public static String law_Firm_Account_RecordType_Id = OWCConstants.LAW_FIRM_ACCOUNT_RECORD_TYPE_ID;
    
    //Prepate Employee Data (Account)
    /*public static Account prepareDataForClaimantEmployeeValues(Map<String, object> claimantDataMap) {
        Boolean isAccountChanged  = false;
        Account updatedAccount = new Account();
        updatedAccount.firstName = (String) claimantDataMap.get('yourselfFirstName');
        updatedAccount.middleName = (String) claimantDataMap.get('yourselfMiddleName');
        updatedAccount.lastName = (String) claimantDataMap.get('yourselfLastName');
        updatedAccount.PersonHomePhone = (String) claimantDataMap.get('yourselfHomePhone');
        updatedAccount.Cell_Phone__c = (String) claimantDataMap.get('yourselfCellPhone');
        updatedAccount.PersonBirthdate = String.isNotBlank((String) claimantDataMap.get('yourselfBirthDate')) ? Date.valueOf((String) claimantDataMap.get('yourselfBirthDate')) : null;
        updatedAccount.PersonEmail = (String) claimantDataMap.get('yourselfEmail');
        updatedAccount.shippingStreet = (String) claimantDataMap.get('yourselfStreetAddress');
        updatedAccount.shippingCity = (String) claimantDataMap.get('yourselfCity');
        updatedAccount.shippingState = (String) claimantDataMap.get('yourselfState');
        updatedAccount.shippingPostalCode = (String) claimantDataMap.get('yourselfZipCode');
        
           
        //get the Community User 
        String communityAccountId = [SELECT Id, accountId FROM User
                                    WHERE Id =: UserInfo.getUserId()].accountId;
        Account claimantAccount = [SELECT Id,firstName,middleName,lastName,PersonHomePhone,Cell_Phone__c,PersonBirthdate,
                               PersonEmail,shippingStreet,shippingCity,shippingState,shippingPostalCode
                               FROM Account
                               WHERE Id =: communityAccountId];
        
        // For each fields in the Account
        for (String fieldAPI : OWCConstants.personAccountFieldsToCompare)
        {
            
            // Check whether new value != than old value for the same record
            if (claimantAccount.get(fieldAPI) != updatedAccount.get(fieldAPI) && updatedAccount.get(fieldAPI) != null)
            {
                claimantAccount.put(fieldAPI, updatedAccount.get(fieldAPI));
                isAccountChanged = true;
            }
        }
        
        //lets update if the Community Account id modified
        if(isAccountChanged)	update claimantAccount;
        
        return claimantAccount;
    }*/
    /*************
     * @method prepareRelatedPartyForIndividualRepresentative 
     * @descirption: Use to prepare the Related Party data for Individual Representative 
     * @param claimantDataMap: map object to hold the Individual Representative section data
     * @return Related Party record
     ********/
    //Prepate Representative Data (Individual/Advocate) (Account)
    public static Related_Party__c prepareRelatedPartyForIndividualRepresentative(Map<String, object> claimantDataMap) {
        Related_Party__c relatedParty = new Related_Party__c();
        relatedParty.First_Name__c = (String) claimantDataMap.get('individualRepFirstName');
        relatedParty.Last_Name__c = (String) claimantDataMap.get('individualRepLastName');
        relatedParty.Phone__c = (String) claimantDataMap.get('individualRepPhone');
        relatedParty.Mobile_Phone__c= (String) claimantDataMap.get('individualRepPhone');
        //relatedParty.Cell_Phone__c = (String) claimantDataMap.get('yourselfCellPhone');
        //relatedParty.Birthdate__c  = String.isNotBlank((String) claimantDataMap.get('yourselfBirthDate')) ? Date.valueOf((String) claimantDataMap.get('yourselfBirthDate')) : null;
        relatedParty.Email__c = (String) claimantDataMap.get('individualRepEmail');
        relatedParty.Street_Address__c = (String) claimantDataMap.get('individualRepStreetAddress');
        relatedParty.City__c = (String) claimantDataMap.get('individualRepCity');
        relatedParty.State__c = (String) claimantDataMap.get('individualRepState');
        String zipCode = (String) claimantDataMap.get('individualRepZipCode');

        try {
            Boolean opt_out_Status = claimantDataMap.get('isrepCellPhoneEntered') == true ? false : true;  
            relatedParty.SMS_Opt_Out__c = opt_out_Status;
        } catch(Exception ex){
            system.debug('error: '+ex.getMessage());
        }



        if(String.isNotBlank(zipCode) ){
            /*	Fix for keep the hypen in Zip Code
            if(zipCode.contains('-')){
                zipCode = zipCode.replace('-', '');
            }	*/
            relatedParty.Zip_Code__c = zipCode;
        }
        relatedParty.Role__c = 'Advocate';
        relatedParty.RecordTypeId = advocate_RelatedParty_RecordType_Id;
        return relatedParty;
    }
    
    /*************
     * @method prepareRelatedPartyForLawFirmRepresentative 
     * @descirption: Use to prepare the Related Party data for Law Firm Representative 
     * @param claimantDataMap: map object to hold the LawFirm Representative section data
     * @return Related Party record
     ********/
    //Prepate Representative Data (LawFirm) (Related_Party)
    public static Related_Party__c prepareRelatedPartyForLawFirmRepresentative(Map<String, object> claimantDataMap) {
        Related_Party__c relatedParty = new Related_Party__c();
        relatedParty.Business_Name__c  = String.isNotBlank((String) claimantDataMap.get('lawfirmRepBusinessName')) ? (String) claimantDataMap.get('lawfirmRepBusinessName') : (String) claimantDataMap.get('lawfirmRepAttorney');
        relatedParty.Phone__c = (String) claimantDataMap.get('lawfirmRepStatePhone');
        //relatedParty.Cell_Phone__c = (String) claimantDataMap.get('yourselfCellPhone');
        //relatedParty.Birthdate__c  = String.isNotBlank((String) claimantDataMap.get('yourselfBirthDate')) ? Date.valueOf((String) claimantDataMap.get('yourselfBirthDate')) : null;
        relatedParty.Email__c = (String) claimantDataMap.get('lawfirmRepEmail');
        relatedParty.Street_Address__c = (String) claimantDataMap.get('lawfirmRepStreetAddress');
        relatedParty.City__c = (String) claimantDataMap.get('lawfirmRepCity');
        relatedParty.State__c = (String) claimantDataMap.get('lawfirmRepState');
        String zipCode = (String) claimantDataMap.get('lawFirmRepZipCode');

        try {
            Boolean opt_out_Status = claimantDataMap.get('isorgCellPhoneEntered') == true ? false : true; 
            relatedParty.SMS_Opt_Out__c = opt_out_Status;
        } catch(Exception ex){
            system.debug('error: '+ex.getMessage());
        }


        if(String.isNotBlank(zipCode) ){
            /*Fix for keep the hypen in Zip Code
            if(zipCode.contains('-')){
                zipCode = zipCode.replace('-', '');
            }	*/
            relatedParty.Zip_Code__c = zipCode;
        }
        relatedParty.Role__c = 'Advocate';
        relatedParty.RecordTypeId = advocate_RelatedParty_RecordType_Id;
        return relatedParty;
    }
    
    /*************
     * @method prepareRelatedPartyForOrganizationRep 
     * @descirption: Use to prepare the Related Party data for Organization Representative 
     * @param claimantDataMap: map object to hold the Organization Representative section data
     * @return Related Party record
     ********/
    //Prepate Representative Data (Organization) (Related_Party)
    public static Related_Party__c prepareRelatedPartyForOrganizationRep(Map<String, object> claimantDataMap) {
        Related_Party__c relatedParty = new Related_Party__c();
        relatedParty.Business_Name__c  = (String) claimantDataMap.get('organizationRepBusinessName');
        relatedParty.Phone__c = (String) claimantDataMap.get('organizationRepPhone');
        relatedParty.Email__c = (String) claimantDataMap.get('organizationRepEmail');
        relatedParty.Street_Address__c = (String) claimantDataMap.get('organizationRepStreetAddress');
        relatedParty.City__c = (String) claimantDataMap.get('organizationRepCity');
        relatedParty.State__c = (String) claimantDataMap.get('organizationRepState');
        String zipCode = (String) claimantDataMap.get('organizationRepZipCode');
        
        try {
            Boolean opt_out_Status = claimantDataMap.get('isorgCellPhoneEntered') == true ? false : true;  
            relatedParty.SMS_Opt_Out__c = opt_out_Status;
        } catch(Exception ex){
            system.debug('error: '+ex.getMessage());
        }
        
        
        if(String.isNotBlank(zipCode) ){
            /* 	Fix for keep the hypen in Zip Code
            if(zipCode.contains('-')){
                zipCode = zipCode.replace('-', '');
            }	*/
            relatedParty.Zip_Code__c = zipCode;
        }
        //updatedAccount.Website = (String) claimantDataMap.get('organizationRepWebsite');
        relatedParty.Role__c = 'Advocate';
        relatedParty.RecordTypeId = advocate_RelatedParty_RecordType_Id;
        return relatedParty;
    }
    
    
    /******************************************
     * @method prepareDataForIndividualRepresentative : depricate because Representative will route to the Related Party 
     * record.
     * *************************************
     
    //Prepate Representative Data (Individual/Advocate) (Account)
    public static Account prepareDataForIndividualRepresentative(Map<String, object> claimantDataMap) {
        Boolean isAccountChanged  = false;
        Account updatedAccount = new Account();
        updatedAccount.firstName = (String) claimantDataMap.get('individualRepFirstName');
        updatedAccount.lastName = (String) claimantDataMap.get('individualRepLastName');
        //add phone type
        //updatedAccount.PersonHomePhone = (String) claimantDataMap.get('yourselfHomePhone');
        updatedAccount.Phone = (String) claimantDataMap.get('individualRepPhone');
        updatedAccount.PersonEmail = (String) claimantDataMap.get('individualRepEmail');
        updatedAccount.shippingStreet = (String) claimantDataMap.get('individualRepStreetAddress');
        updatedAccount.shippingCity = (String) claimantDataMap.get('individualRepCity');
        updatedAccount.shippingState = (String) claimantDataMap.get('individualRepState');
        updatedAccount.shippingPostalCode = (String) claimantDataMap.get('individualRepZipCode');
        updatedAccount.Website = (String) claimantDataMap.get('individualRepWebsite');
        updatedAccount.RecordTypeId = person_Account_RecordType_Id;
        
        //get the Community User 
        String communityAccountId = [SELECT Id, accountId FROM User
                                    WHERE Id =: UserInfo.getUserId()].accountId;
        Account claimantAccount = [SELECT Id,firstName,middleName,lastName,PersonHomePhone,Cell_Phone__c,PersonBirthdate,
                               PersonEmail,shippingStreet,shippingCity,shippingState,shippingPostalCode
                               FROM Account
                               WHERE Id =: communityAccountId];
        
        // For each fields in the Account
        for (String fieldAPI : OWCConstants.personAccountFieldsToCompare)
        {
            
            // Check whether new value != than old value for the same record
            if (claimantAccount.get(fieldAPI) != updatedAccount.get(fieldAPI) && updatedAccount.get(fieldAPI) != null)
            {
                claimantAccount.put(fieldAPI, updatedAccount.get(fieldAPI));
                isAccountChanged = true;
            }
        }
        
        //lets update if the Community Account id modified
        if(isAccountChanged)	update claimantAccount;
        return claimantAccount;
    }
	
    //Prepare Representative Data (Law Firm) (Account)
    public static Account prepareDataForLawFirmRepresentative(Map<String, object> claimantDataMap) {
        Boolean isAccountChanged  = false;
        Account updatedAccount = new Account();
        
        updatedAccount.Name = String.isNotBlank((String) claimantDataMap.get('lawfirmRepBusinessName')) ? (String) claimantDataMap.get('lawfirmRepBusinessName') : (String) claimantDataMap.get('lawfirmRepAttorney');
        //add phone type
        //updatedAccount.PersonHomePhone = (String) claimantDataMap.get('yourselfHomePhone');
        updatedAccount.Phone = (String) claimantDataMap.get('lawfirmRepStatePhone');
        updatedAccount.Email__c = (String) claimantDataMap.get('lawfirmRepEmail');
        updatedAccount.shippingStreet = (String) claimantDataMap.get('lawfirmRepStreetAddress');
        updatedAccount.shippingCity = (String) claimantDataMap.get('lawfirmRepCity');
        updatedAccount.shippingState = (String) claimantDataMap.get('lawfirmRepState');
        updatedAccount.shippingPostalCode = (String) claimantDataMap.get('lawFirmRepZipCode');
        updatedAccount.Website = (String) claimantDataMap.get('lawfirmRepWebsite');
        //updatedAccount.RecordTypeId = business_Account_RecordType_Id;
        
        //get the Community User 
        String communityAccountId = [SELECT Id, accountId FROM User
                                    WHERE Id =: UserInfo.getUserId()].accountId;
        Account claimantAccount = [SELECT Id,Name,firstName,middleName,lastName,PersonHomePhone,Cell_Phone__c,PersonBirthdate,
                               PersonEmail,shippingStreet,shippingCity,shippingState,shippingPostalCode
                               FROM Account
                               WHERE Id =: communityAccountId];
        
        // For each fields in the Account
        for (String fieldAPI : OWCConstants.personAccountFieldsToCompare)
        {
            
            // Check whether new value != than old value for the same record
            if (claimantAccount.get(fieldAPI) != updatedAccount.get(fieldAPI) && updatedAccount.get(fieldAPI) != null)
            {
                claimantAccount.put(fieldAPI, updatedAccount.get(fieldAPI));
                isAccountChanged = true;
            }
        }
        
        //lets update if the Community Account id modified
        if(isAccountChanged)	update claimantAccount;
        return claimantAccount;
    }
    
    //Prepate Representative Data (Organization) (Account)
    public static Account prepareDataForOrganizationRepresentative(Map<String, object> claimantDataMap) {
        Boolean isAccountChanged  = false;
        Account updatedAccount = new Account();
        updatedAccount.Name = (String) claimantDataMap.get('organizationRepBusinessName');
        //add phone type
        //updatedAccount.PersonHomePhone = (String) claimantDataMap.get('yourselfHomePhone');
        updatedAccount.Phone = (String) claimantDataMap.get('organizationRepPhone');
        updatedAccount.Email__c = (String) claimantDataMap.get('organizationRepEmail');
        updatedAccount.shippingStreet = (String) claimantDataMap.get('organizationRepStreetAddress');
        updatedAccount.shippingCity = (String) claimantDataMap.get('organizationRepCity');
        updatedAccount.shippingState = (String) claimantDataMap.get('organizationRepState');
        updatedAccount.shippingPostalCode = (String) claimantDataMap.get('organizationRepZipCode');
        updatedAccount.Website = (String) claimantDataMap.get('organizationRepWebsite');
        //claimantAccount.recordTypeId = business_Account_RecordType_Id;
        ,
        //get the Community User 
        String communityAccountId = [SELECT Id, accountId FROM User
                                    WHERE Id =: UserInfo.getUserId()].accountId;
        Account claimantAccount = [SELECT Id,firstName,middleName,lastName,PersonHomePhone,Cell_Phone__c,PersonBirthdate,
                               PersonEmail,shippingStreet,shippingCity,shippingState,shippingPostalCode
                               FROM Account
                               WHERE Id =: communityAccountId];
        
        // For each fields in the Account
        for (String fieldAPI : OWCConstants.personAccountFieldsToCompare)
        {
            
            // Check whether new value != than old value for the same record
            if (claimantAccount.get(fieldAPI) != updatedAccount.get(fieldAPI) && updatedAccount.get(fieldAPI) != null)
            {
                claimantAccount.put(fieldAPI, updatedAccount.get(fieldAPI));
                isAccountChanged = true;
            }
        }
        
        //lets update if the Community Account id modified
        if(isAccountChanged)	update claimantAccount;
        return claimantAccount;
    }

	***************************************************************************************************************
    */
    
    //Prepate Employer Data (Account)
    
    public static List<Related_Party__c> prepareEmployerData(List<object> employerData, Address__c location, List<ContentDocumentLink> documentLinks, Online_claim__c onlineClaim,Dir_Case__c cm, List<Related_Party__c> additinalPersonList) {
        Boolean employerCreated = false;
        List<Related_Party__c> employerList = new List<Related_Party__c>();
        //get the List of documents uploadedEmployerAdditionalDocuments
        List<object> uploadedDocList = new List<object>();
        for(Object obj: employerData) {
            Map<String, Object> employerMap = (Map<String, Object>) obj;
            //lets check the Employer Name should not be empty
            if( (employerMap.get('individualLastName') != null && String.isNotBlank((String)employerMap.get('individualLastName')))
               || (employerMap.get('OtherIndividualBusinessName') != null && String.isNotBlank((String)employerMap.get('OtherIndividualBusinessName')))
              ) 
            {
                  Related_Party__c employer = new Related_Party__c();
                  //employer.SMS_Opt_Out__c = true; //automatic opting out for defendant upon submission
                  if(!employerCreated){
                      //lets create the defendant related party
                      employer.Role__c = 'Defendant'; 
                      //covid details
                      cm.COVID_19__c = ((String) employerMap.get('covid19Claim') == 'Yes' || (String) employerMap.get('covid19Claim') == 'Sí') ? 'Yes' : 'No';
                      if(employerMap.get('isEmployeeFilingWageClaimOther') != null && (Boolean) employerMap.get('isEmployeeFilingWageClaimOther')){
                          cm.Covid_Other_Reason__c = (String) employerMap.get('specifyOtherReason');
                      }
                      //get the List of documents uploadedEmployerAdditionalDocuments
                      uploadedDocList = (List<object>) employerMap.get('uploadUnionContractDocument');
                      if(uploadedDocList != null){
                          prepareUploadedDocuments(uploadedDocList, documentLinks);
                          //clear the docs list
                          uploadedDocList.clear();
                      } 
                      employerCreated = true;
                  } else {
                      employer.Role__c = 'Defendant - Successor'; 
                  }
                
                //cm.Covid_Reason__c = (String) employerMap.get('specifyFilingWageClaim');
                
                if((String)employerMap.get('representativeEmployerType') == 'Individual/Sole Proprietor'){
                    system.debug('Individual/Sole Proprietor');	
                    employer.First_Name__c = (String)employerMap.get('individualFirstName');
                    employer.Last_Name__c = (String)employerMap.get('individualLastName');
                    employer.Street_Address__c = (String)employerMap.get('individualStreetAddress');
                    employer.City__c = (String)employerMap.get('individualCity');
                    employer.State__c = (String)employerMap.get('individualState');
                    String zipCode = (String)employerMap.get('individualZipCode');
                    if(String.isNotBlank(zipCode) ){
                        /* Fix for keep the hypen in Zip Code
                        if(zipCode.contains('-')){
                        zipCode = zipCode.replace('-', '');
                        }	*/
                        employer.Zip_Code__c = zipCode;
                    }
                    
                    employer.Phone__c = (String)employerMap.get('individualBusinessPhone');
                    employer.Mobile_Phone__c = (String)employerMap.get('individualCellPhone');
                    employer.Email__c = (String)employerMap.get('individualEmail');
                    
                    employer.RecordTypeId = employer_RelatedParty_RecordType_Id;
                    //employer.Website = (String) employerMap.get('individualRepWebsite'); 
                    System.debug('additionalTotalEmployees ::: '+employerMap.get('additionalTotalEmployees'));
                    employer.Number_of_employees__c = (String) employerMap.get('additionalTotalEmployees') != null ? (Integer.valueOf((String) employerMap.get('additionalTotalEmployees'))) : null;
                    
                    // populate other location  data
                    location.Address__c = (String)employerMap.get('individualStreetAddress');
                    location.City__c = (String)employerMap.get('individualCity');
                    location.State__c = (String)employerMap.get('individualState');
                    location.Zip_Code__c = zipCode;
                    /*. Commented By Vikas ; Based on discussion that Data is visisble on PDF 
onlineClaim.Union_contract_covering_your_employment__c = (String) employerMap.get('unionContractCovering');
onlineClaim.URL_address_for_Union_Contract__c = (String) employerMap.get('urlAddress');
onlineClaim.Are_other_employees_filing_a_claim_s__c = (String) employerMap.get('filingWageClaim'); 
onlineClaim.Filed_a_Retaliation_complaint__c = (String) employerMap.get('retaliationComplain');
String complainFiledDate = (String) employerMap.get('complainFiledDate');
onlineClaim.Retaliation_Complaint_Filed_Date__c = String.isNotBlank(complainFiledDate) ? 
Date.valueOf(complainFiledDate) : null;
onlineClaim.Retaliation_Complaint_Case_Number__c = (String) employerMap.get('complainCaseNumber');
onlineClaim.COVID_19_Claim__c = (String) employerMap.get('covid19Claim');	

onlineClaim.Filed_a_Retaliation_complaint__c = (String) employerMap.get('retaliationComplain');
onlineClaim.Person_in_charge__c = (String) employerMap.get('additionalName');
onlineClaim.Title_of_Person_in_Charge__c = (String) employerMap.get('additionalJobTitle');
onlineClaim.Who_paid_you__c = (String) employerMap.get('additionalWHOPaidYou');
onlineClaim.Work_Sched_Set_By__c = (String) employerMap.get('additionalDifferentPerson');
onlineClaim.Hours_recorded_by__c = (String) employerMap.get('owcWorkRecordList');
onlineClaim.Received_Time_Cards__c = (String) employerMap.get('additionalSignTimeCard');
onlineClaim.who_told_you_to_sign_the_time_card__c = (String) employerMap.get('signCardName');
onlineClaim.Who_recorded_your_work_hours__c = (String) employerMap.get('additionalSomeoneElse');
onlineClaim.Employer_Still_in_Business__c = (String) employerMap.get('additionalEmpBusiness');
onlineClaim.how_this_person_may_be_responsible__c = (String) employerMap.get('claimantRelatedRoleActions');

onlineClaim.Employer_selling_Assets_or_in_Bankruptcy__c = (String) employerMap.get('additionalBankruptcy');
onlineClaim.Bank_Name__c = (String) employerMap.get('additionalBankName');
onlineClaim.Employer_Changed_Business__c = (String) employerMap.get('employerChangedName');
onlineClaim.Employer_Changed_Name__c = (String) employerMap.get('employerChangedNameAfterEmployement');
onlineClaim.Work_with_same_co_worker__c = (String) employerMap.get('workWithSameWorokers');
onlineClaim.Ownership_Relation__c = (String) employerMap.get('ownershipOfCompRelated');

**********************************************/ 
                    //lets check for the Existing Employer
                    //Account existingAccount = OWCServiceUtility.getDuplicateAccount(employer);
                    /*
if(existingAccount == null){

}else{
return existingAccount;
}
*/
                }
                else if((String)employerMap.get('representativeEmployerType') == 'Corporation'){
                    system.debug('Corporation');
                    employer.Business_Name__c = (String)employerMap.get('OtherIndividualBusinessName');
                    employer.Street_Address__c = (String)employerMap.get('OtherIndividualStreetAddress');
                    employer.City__c = (String)employerMap.get('OtherIndividualCity');
                    employer.State__c = (String)employerMap.get('OtherIndividualState');
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
                else {
                    system.debug('other business');
                    employer.Business_Name__c = (String)employerMap.get('OtherIndividualBusinessName');
                    employer.Street_Address__c = (String)employerMap.get('OtherIndividualStreetAddress');
                    employer.City__c = (String)employerMap.get('OtherIndividualCity');
                    employer.State__c = (String)employerMap.get('OtherIndividualState');
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
                
                
                uploadedDocList = (List<object>) employerMap.get('uploadedEmployerAdditionalDocuments');
                if(uploadedDocList != null){
                    prepareUploadedDocuments(uploadedDocList, documentLinks);
                    //clear the docs list
                    uploadedDocList.clear();
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
                                if(successorMap.get('employerNameAfterEmployementDetails') != null){
                                   Map<String, Object> changedEmployerMap = (Map<String, Object>) successorMap.get('employerNameAfterEmployementDetails'); 
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
                
                //get the List of documents employerVerificationUploadDoc
                uploadedDocList = (List<object>) employerMap.get('employerVerificationUploadDoc');
                if(uploadedDocList != null){
                    prepareUploadedDocuments(uploadedDocList, documentLinks);
                    system.debug('documentLinks Employer Verification docs inside service cls.'+documentLinks.size());
                    //clear the docs list
                    uploadedDocList.clear();
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


    //prepare the Payment of Wages Data

    public static List<Payment_of_wages__c> preparePaymentOfWagesData(Map<String, object>  paymentMap){
        List<Payment_of_wages__c> paymentOfWagesList = new List<Payment_of_wages__c>();
        system.debug('paymentofwagesData: '+Json.serialize(paymentMap));

        if(paymentMap.get('isOneHourlyRate') != null && (Boolean)paymentMap.get('isOneHourlyRate') == true){
            Payment_of_wages__c hourlyPOW = new Payment_of_wages__c();
            hourlyPOW.Payment_type__c = 'One hourly rate';
            hourlyPOW.Per_period__c = 'Hour';
            hourlyPOW.Paid_amount__c = (String)paymentMap.get('paidAmountPerHour') != null ? Decimal.valueOf((String)paymentMap.get('paidAmountPerHour')) : null ;                
            hourlyPOW.Promised_amount__c = (String)paymentMap.get('promisedAmountPerHour') != null ? Decimal.valueOf((String)paymentMap.get('promisedAmountPerHour')) : null ;
            String startdate = (String)paymentMap.get('hourlyRateBegDate');
            String enddate = (String)paymentMap.get('hourlyRateEndDate');
            hourlyPOW.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
            hourlyPOW.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
            paymentOfWagesList.add(hourlyPOW);
        }     
        if(paymentMap.get('isDifferentHourRate') != null && (Boolean)paymentMap.get('isDifferentHourRate') == true){
            Payment_of_wages__c diffHourPOW = new Payment_of_wages__c();
            diffHourPOW.For_activity__c = (String)paymentMap.get('forActivity');
            diffHourPOW.Payment_type__c = 'Multiple hourly rate';
            diffHourPOW.Paid_amount__c = (String)paymentMap.get('paidAmountDifferentHour') != null ? Decimal.valueOf((String)paymentMap.get('paidAmountDifferentHour')) : null ;                
            diffHourPOW.Promised_amount__c = (String)paymentMap.get('promisedAmountDifferentHour') != null ? Decimal.valueOf((String)paymentMap.get('promisedAmountDifferentHour')) : null ;
            String startdate = (String)paymentMap.get('differentHourlyRateBegDate');
            String enddate = (String)paymentMap.get('differentHourlyRateEndDate');
            diffHourPOW.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
            diffHourPOW.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
            paymentOfWagesList.add(diffHourPOW);
        }
        if(paymentMap.get('isSalaryRateForEachDay') != null && (Boolean)paymentMap.get('isSalaryRateForEachDay') == true){
            Payment_of_wages__c salaryPOW = new Payment_of_wages__c();
            salaryPOW.Payment_type__c = 'Salary rate';
            salaryPOW.Paid_amount__c = (String)paymentMap.get('paidAmountForEachDay') != null ? Decimal.valueOf((String)paymentMap.get('paidAmountForEachDay')) : null ;                
            salaryPOW.Promised_amount__c = (String)paymentMap.get('promisedAmountForEachDay') != null ? Decimal.valueOf((String)paymentMap.get('promisedAmountForEachDay')) : null ;
            salaryPOW.Per_period__c = (String)paymentMap.get('frequencyOfEachDay');
            String startdate = (String)paymentMap.get('eachPayRateBegDate');
            String enddate = (String)paymentMap.get('eachPayRateEndDate');
            salaryPOW.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
            salaryPOW.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
            paymentOfWagesList.add(salaryPOW);
        }
        if(paymentMap.get('isCommissionRate') != null && (Boolean)paymentMap.get('isCommissionRate') == true){
            Payment_of_wages__c commissionPOW = new Payment_of_wages__c();
            commissionPOW.Payment_type__c = 'Commission rate';
            commissionPOW.Received_written_commission_aggreement__c = (String)paymentMap.get('writtenCommission');
            paymentOfWagesList.add(commissionPOW);
        }
        if(paymentMap.get('isPieceRate') != null && (Boolean)paymentMap.get('isPieceRate') == true){
            Payment_of_wages__c pieceratePOW = new Payment_of_wages__c();
            pieceratePOW.Payment_type__c = 'Piece rate';
            pieceratePOW.Paid_amount__c = (String)paymentMap.get('paidPieceRate') != null ? Decimal.valueOf((String)paymentMap.get('paidPieceRate')) : null ;                
            pieceratePOW.Promised_amount__c = (String)paymentMap.get('promisedPieceRate') != null ? Decimal.valueOf((String)paymentMap.get('promisedPieceRate')) : null ;
            pieceratePOW.Per_unit__c = (String)paymentMap.get('perUnitPaymentOfWages');
            String startdate = (String)paymentMap.get('pieceRateBegDate');
            String enddate = (String)paymentMap.get('pieceRateEndDate');
            pieceratePOW.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
            pieceratePOW.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
            pieceratePOW.Total_earned__c = (String)paymentMap.get('pieceRateTotalEarned') != null ? Decimal.valueOf((String)paymentMap.get('pieceRateTotalEarned')) : null ; 
            pieceratePOW.Total_paid__c = (String)paymentMap.get('pieceRateTotalPaid') != null ? Decimal.valueOf((String)paymentMap.get('pieceRateTotalPaid')) : null ; 
            pieceratePOW.Other_unit__c = (String)paymentMap.get('other');
            paymentOfWagesList.add(pieceratePOW);
        }
        if(paymentMap.get('isOneHourlyAdditionalSection') != null && (Boolean)paymentMap.get('isOneHourlyAdditionalSection') == true && paymentMap.get('hourlyAdditionalDetails') != null){
            List<object> hourlyAddList = (List<object>)paymentMap.get('hourlyAdditionalDetails');
            for(Object hourlyAddEntry : hourlyAddList) { 
                Map<String, Object> hourlyAddDetaillMap = (Map<String, Object>) hourlyAddEntry;
                Payment_of_wages__c hourlyPOWAdd  = new Payment_of_wages__c();
                hourlyPOWAdd.Payment_type__c = 'One hourly rate';
                hourlyPOWAdd.Per_period__c = 'Hour';
                hourlyPOWAdd.Paid_amount__c = (String)hourlyAddDetaillMap.get('paidAmountPerHourAdditional') != null ? Decimal.valueOf((String)hourlyAddDetaillMap.get('paidAmountPerHourAdditional')) : null ;                
                hourlyPOWAdd.Promised_amount__c = (String)hourlyAddDetaillMap.get('promisedAmountPerHourAdditional') != null ? Decimal.valueOf((String)hourlyAddDetaillMap.get('promisedAmountPerHourAdditional')) : null ;
                String startdate = (String)hourlyAddDetaillMap.get('hourlyRateBegDateAdditional');
                String enddate = (String)hourlyAddDetaillMap.get('hourlyRateEndDateAdditional');
                hourlyPOWAdd.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
                hourlyPOWAdd.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
                paymentOfWagesList.add(hourlyPOWAdd);
            }
            
        }
        if(paymentMap.get('isDifferentHourAdditionalInfoSection') != null && (Boolean)paymentMap.get('isDifferentHourAdditionalInfoSection') == true && paymentMap.get('differentHourAdditionalDetails') != null){
            List<object> diffHourPOWAddList = (List<object>)paymentMap.get('differentHourAdditionalDetails');
            for(Object diffHourPOWAddEntry : diffHourPOWAddList) { 
                Map<String, Object> diffHourPOWAddDetaillMap = (Map<String, Object>) diffHourPOWAddEntry;
                Payment_of_wages__c diffHourPOWAdd  = new Payment_of_wages__c();
                diffHourPOWAdd.For_activity__c = (String)diffHourPOWAddDetaillMap.get('forActivityAdditional');
                diffHourPOWAdd.Payment_type__c = 'Multiple hourly rate';
                diffHourPOWAdd.Paid_amount__c = (String)diffHourPOWAddDetaillMap.get('paidAmountDifferentHourAdditional') != null ? Decimal.valueOf((String)diffHourPOWAddDetaillMap.get('paidAmountDifferentHourAdditional')) : null ;                
                diffHourPOWAdd.Promised_amount__c = (String)diffHourPOWAddDetaillMap.get('promisedAmountDifferentHourAdditional') != null ? Decimal.valueOf((String)diffHourPOWAddDetaillMap.get('promisedAmountDifferentHourAdditional')) : null ;
                String startdate = (String)diffHourPOWAddDetaillMap.get('differentHourlyRateBegDateAdditional');
                String enddate = (String)diffHourPOWAddDetaillMap.get('differentHourlyRateEndDateAdditional');
                diffHourPOWAdd.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
                diffHourPOWAdd.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
                paymentOfWagesList.add(diffHourPOWAdd);
            }
            
        }
        if(paymentMap.get('isSalaryRateAdditionalSection') != null && (Boolean)paymentMap.get('isSalaryRateAdditionalSection') == true && paymentMap.get('salaryRateAdditionalDetails') != null){
            List<object> salaryPOWAddList = (List<object>)paymentMap.get('salaryRateAdditionalDetails');
            for(Object salaryPOWAddEntry : salaryPOWAddList) { 
                Map<String, Object> salaryPOWAddDetaillMap = (Map<String, Object>) salaryPOWAddEntry;
                Payment_of_wages__c salaryPOWAdd  = new Payment_of_wages__c();
                salaryPOWAdd.Payment_type__c = 'Salary rate';
                salaryPOWAdd.Paid_amount__c = (String)salaryPOWAddDetaillMap.get('paidAmountForEachDayAdditional') != null ? Decimal.valueOf((String)salaryPOWAddDetaillMap.get('paidAmountForEachDayAdditional')) : null ;                
                salaryPOWAdd.Promised_amount__c = (String)salaryPOWAddDetaillMap.get('promisedAmountForEachDayAdditional') != null ? Decimal.valueOf((String)salaryPOWAddDetaillMap.get('promisedAmountForEachDayAdditional')) : null ;
                salaryPOWAdd.Per_period__c = (String)salaryPOWAddDetaillMap.get('frequencyOfEachDayAdditional');
                String startdate = (String)salaryPOWAddDetaillMap.get('eachPayRateBegDateAdditional');
                String enddate = (String)salaryPOWAddDetaillMap.get('eachPayRateEndDateAdditional');
                salaryPOWAdd.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
                salaryPOWAdd.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
                paymentOfWagesList.add(salaryPOWAdd);
            }
            
        }
        if(paymentMap.get('isPieceRateAdditionalSection') != null && (Boolean)paymentMap.get('isPieceRateAdditionalSection') == true && paymentMap.get('pieceRateAdditionalDetails') != null){
            List<object> pieceratePOWAddList = (List<object>)paymentMap.get('pieceRateAdditionalDetails');
            for(Object pieceratePOWAddEntry : pieceratePOWAddList) { 
                Map<String, Object> piecerateOWAddDetaillMap = (Map<String, Object>) pieceratePOWAddEntry;
                Payment_of_wages__c pieceratePOWAdd  = new Payment_of_wages__c();
                pieceratePOWAdd.Payment_type__c = 'Piece rate';
                pieceratePOWAdd.Paid_amount__c = (String)piecerateOWAddDetaillMap.get('paidPieceRateAdditional') != null ? Decimal.valueOf((String)piecerateOWAddDetaillMap.get('paidPieceRateAdditional')) : null ;                
                pieceratePOWAdd.Promised_amount__c = (String)piecerateOWAddDetaillMap.get('promisedPieceRateAdditional') != null ? Decimal.valueOf((String)piecerateOWAddDetaillMap.get('promisedPieceRateAdditional')) : null ;
                pieceratePOWAdd.Per_unit__c = (String)piecerateOWAddDetaillMap.get('perUnitPaymentOfWagesAdditional');
                String startdate = (String)piecerateOWAddDetaillMap.get('pieceRateBegDateAdditional');
                String enddate = (String)piecerateOWAddDetaillMap.get('pieceRateEndDateAdditional');
                pieceratePOWAdd.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
                pieceratePOWAdd.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
                pieceratePOWAdd.Other_unit__c = (String)piecerateOWAddDetaillMap.get('otherAdditional');
                paymentOfWagesList.add(pieceratePOWAdd);
            }
            
        }
        return paymentOfWagesList;
    }

    //update Payment of wages from initial claim on Case record

    public static DIR_Case__c updatePOWonInitialClaim(Map<String, object>  paymentMap, DIR_Case__c cm){
        Payment_of_wages__c latestHourlyPOW = new Payment_of_wages__c();
        Payment_of_wages__c latestSalaryPOW = new Payment_of_wages__c();
        String latestHourlyEndDate;
        String latestSalaryEndDate;

        if(paymentMap.get('isOneHourlyRate') != null && (Boolean)paymentMap.get('isOneHourlyRate') == true){
            cm.Hourly_Employee__c = 'Yes';
            latestHourlyPOW.Per_period__c = 'Hour';
            latestHourlyPOW.Paid_amount__c = (String)paymentMap.get('paidAmountPerHour') != null ? Decimal.valueOf((String)paymentMap.get('paidAmountPerHour')) : null ;                
            latestHourlyPOW.Promised_amount__c = (String)paymentMap.get('promisedAmountPerHour') != null ? Decimal.valueOf((String)paymentMap.get('promisedAmountPerHour')) : null ;
            String startdate = (String)paymentMap.get('hourlyRateBegDate');
            String enddate = (String)paymentMap.get('hourlyRateEndDate');
            latestHourlyPOW.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
            latestHourlyPOW.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
        }     

        if(paymentMap.get('isDifferentHourRate') != null && (Boolean)paymentMap.get('isDifferentHourRate') == true){
            cm.Were_you_paid_more_than_one_hourly_rate__c = 'Yes';
        }

        if(paymentMap.get('isSalaryRateForEachDay') != null && (Boolean)paymentMap.get('isSalaryRateForEachDay') == true){
            cm.Promised_Fixed_Wages__c = 'Yes';
            latestSalaryPOW.Payment_type__c = 'Salary rate';
            latestSalaryPOW.Paid_amount__c = (String)paymentMap.get('paidAmountForEachDay') != null ? Decimal.valueOf((String)paymentMap.get('paidAmountForEachDay')) : null ;                
            latestSalaryPOW.Promised_amount__c = (String)paymentMap.get('promisedAmountForEachDay') != null ? Decimal.valueOf((String)paymentMap.get('promisedAmountForEachDay')) : null ;
            latestSalaryPOW.Per_period__c = (String)paymentMap.get('frequencyOfEachDay');
            String startdate = (String)paymentMap.get('eachPayRateBegDate');
            String enddate = (String)paymentMap.get('eachPayRateEndDate');
            latestSalaryPOW.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
            latestSalaryPOW.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
        }

        if(paymentMap.get('isCommissionRate') != null && (Boolean)paymentMap.get('isCommissionRate') == true){
            cm.Were_you_paid_by_COMMISION__c = 'Yes';
        }

        if(paymentMap.get('isPieceRate') != null && (Boolean)paymentMap.get('isPieceRate') == true){
            cm.Were_you_paid_by_PIECE_RATE__c = 'Yes';
        }

        if(paymentMap.get('isOneHourlyAdditionalSection') != null && (Boolean)paymentMap.get('isOneHourlyAdditionalSection') == true && paymentMap.get('hourlyAdditionalDetails') != null){
            List<object> hourlyAddList = (List<object>)paymentMap.get('hourlyAdditionalDetails');
            for(Object hourlyAddEntry : hourlyAddList) { 
                Map<String, Object> hourlyAddDetaillMap = (Map<String, Object>) hourlyAddEntry;
                Payment_of_wages__c hourlyPOWAdd  = new Payment_of_wages__c();
                hourlyPOWAdd.Payment_type__c = 'One hourly rate';
                hourlyPOWAdd.Per_period__c = 'Hour';
                hourlyPOWAdd.Paid_amount__c = (String)hourlyAddDetaillMap.get('paidAmountPerHourAdditional') != null ? Decimal.valueOf((String)hourlyAddDetaillMap.get('paidAmountPerHourAdditional')) : null ;                
                hourlyPOWAdd.Promised_amount__c = (String)hourlyAddDetaillMap.get('promisedAmountPerHourAdditional') != null ? Decimal.valueOf((String)hourlyAddDetaillMap.get('promisedAmountPerHourAdditional')) : null ;
                String startdate = (String)hourlyAddDetaillMap.get('hourlyRateBegDateAdditional');
                String enddate = (String)hourlyAddDetaillMap.get('hourlyRateEndDateAdditional');
                hourlyPOWAdd.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
                hourlyPOWAdd.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
                if(latestHourlyPOW.End_Date__c < hourlyPOWAdd.End_Date__c){
                    latestHourlyPOW = hourlyPOWAdd;
                }
            }
        }

        if(paymentMap.get('isSalaryRateAdditionalSection') != null && (Boolean)paymentMap.get('isSalaryRateAdditionalSection') == true && paymentMap.get('salaryRateAdditionalDetails') != null){
            List<object> salaryPOWAddList = (List<object>)paymentMap.get('salaryRateAdditionalDetails');
            for(Object salaryPOWAddEntry : salaryPOWAddList) { 
                Map<String, Object> salaryPOWAddDetaillMap = (Map<String, Object>) salaryPOWAddEntry;
                Payment_of_wages__c salaryPOWAdd  = new Payment_of_wages__c();
                salaryPOWAdd.Payment_type__c = 'Salary rate';
                salaryPOWAdd.Paid_amount__c = (String)salaryPOWAddDetaillMap.get('paidAmountForEachDayAdditional') != null ? Decimal.valueOf((String)salaryPOWAddDetaillMap.get('paidAmountForEachDayAdditional')) : null ;                
                salaryPOWAdd.Promised_amount__c = (String)salaryPOWAddDetaillMap.get('promisedAmountForEachDayAdditional') != null ? Decimal.valueOf((String)salaryPOWAddDetaillMap.get('promisedAmountForEachDayAdditional')) : null ;
                salaryPOWAdd.Per_period__c = (String)salaryPOWAddDetaillMap.get('frequencyOfEachDayAdditional');
                String startdate = (String)salaryPOWAddDetaillMap.get('eachPayRateBegDateAdditional');
                String enddate = (String)salaryPOWAddDetaillMap.get('eachPayRateEndDateAdditional');
                salaryPOWAdd.Start_Date__c = String.isNotBlank(startdate) ? date.valueOf(startdate) : null;
                salaryPOWAdd.End_Date__c = String.isNotBlank(enddate) ? date.valueOf(enddate) : null;
                if(latestSalaryPOW.End_Date__c < salaryPOWAdd.End_Date__c){
                    latestSalaryPOW = salaryPOWAdd;
                }
            }
            
        }
        cm.Fixed_Amount__c = latestSalaryPOW.Paid_amount__c;
        cm.Promised_Amount__c = latestSalaryPOW.Promised_amount__c;
        cm.Promised_Amount_Timing__c = latestSalaryPOW.Per_period__c;
        cm.Hourly_Amount__c = latestHourlyPOW.Paid_amount__c;
        cm.Hourly_Promised_Amount__c = latestHourlyPOW.Promised_amount__c;

        return cm;

    }


    //prepare the Related Party Data
    public static Related_Party__c prepareRelatedParty(Map<String, object> claimantDataMap){
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
        relatedParty.Birthdate__c  = String.isNotBlank((String) claimantDataMap.get('yourselfBirthDate')) ? Date.valueOf((String) claimantDataMap.get('yourselfBirthDate')) : null;
        relatedParty.Email__c = (String) claimantDataMap.get('yourselfEmail');
        relatedParty.Street_Address__c = (String) claimantDataMap.get('yourselfStreetAddress');
        relatedParty.City__c = (String) claimantDataMap.get('yourselfCity');
        relatedParty.State__c = (String) claimantDataMap.get('yourselfState');
        String zipCode = (String)claimantDataMap.get('yourselfZipCode');
        try {
            Boolean opt_out_Status = claimantDataMap.get('isCellPhoneEntered') == true ? false : true; 
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
        if(otherLocWorkInfoData.get('otherLocWorkInfo') != null){
            Map<String, object> otherLocWorkInfoMap = (Map<String, object>) otherLocWorkInfoData.get('otherLocWorkInfo'); 
            if(otherLocWorkInfoMap.get('isBusinessAddressDifferent') != null && (Boolean)otherLocWorkInfoMap.get('isBusinessAddressDifferent')){
                cm.WorkAddressDifferent__c = 'Yes';
                cm.Address_Where_Worked_Street__c  = (String)otherLocWorkInfoMap.get('otherBusinessStreetAddress');
                cm.Address_Where_Worked_City__c = (String)otherLocWorkInfoMap.get('otherBusinessCity');
                cm.Address_Where_Worked_State__c = (String)otherLocWorkInfoMap.get('otherBusinessState');
                cm.Address_Where_Worked_Zip__c = (String)otherLocWorkInfoMap.get('otherBusinessZipCode');
                //add for Other phone
                //cm.phone = otherLocWorkInfoMap.get('otherBusinessPhone') != null ? (String)otherLocWorkInfoMap.get('otherBusinessPhone') : '';
                
                // populate other location  data
                employerRecord.Other_Street_Address__c = (String)otherLocWorkInfoMap.get('otherBusinessStreetAddress');
                employerRecord.Other_City__c = (String)otherLocWorkInfoMap.get('otherBusinessCity');
                employerRecord.Other_State__c = (String)otherLocWorkInfoMap.get('otherBusinessState');
                employerRecord.Other_Zip_Code__c = (String)otherLocWorkInfoMap.get('otherBusinessZipCode');
            } else{
                cm.WorkAddressDifferent__c = 'No';
            }
        }
        return cm;
    }
    
    
    //prepare Final Wages Data on Case Record
    public static Dir_Case__c populateFinalWagesData(Map<String, object> finalWagesMap, Dir_Case__c cm,Online_claim__c onlineClaim) {
        if(finalWagesMap == null){
            return cm;
        }
        String str = (String)finalWagesMap.get('hireDate');
        onlineClaim.Date_of_Hire__c = String.isNotBlank(str)? date.valueOf(str) : null;
        onlineClaim.Name_of_person_who_hired_you__c = (String) finalWagesMap.get('nameOfPersonWhoHiredYou');
        onlineClaim.How_were_your_wages_paid__c =  (String) finalWagesMap.get('howWereYourWagesPaid');
        onlineClaim.Any_Paycheck_bounce__c = finalWagesMap.get('isChequeBounce') != null ? (Boolean) finalWagesMap.get('isChequeBounce') : null;
        onlineClaim.Check_replaced__c = (String) finalWagesMap.get('chequeReplaced');	
        String chequeReplacedDate = (String)finalWagesMap.get('chequeReplacedDate');
        onlineClaim.Check_replaced_Date__c = String.isNotBlank(chequeReplacedDate) ? date.valueOf(chequeReplacedDate) : null;
        onlineClaim.Wages_always_paid_on_the_payday__c = (String) finalWagesMap.get('wereWagesPaid');
        onlineClaim.Received_Itemized_Wage_Statements__c =  String.isNotBlank((String) finalWagesMap.get('statementReceived')) ? (String) finalWagesMap.get('statementReceived') : null;
        String stillIdentifiedEmp = (String) finalWagesMap.get('stillIdentifiedEmp'); 
        
        if(String.isNotBlank(stillIdentifiedEmp)){
            onlineClaim.ES_Still_Working_for_Employer__c = stillIdentifiedEmp;
            if(stillIdentifiedEmp == 'No'){
                //Quit Job Section
                String quitDate = (String)finalWagesMap.get('quitDate');
                String dischargedDate = (String)finalWagesMap.get('dischargedDate');
                
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
        system.debug('industry...');
        String industry = String.isNotBlank((String) industryDataMap.get('selectedIndustry')) ? (String) industryDataMap.get('selectedIndustry') : null;  
        String subIndustry = String.isNotBlank((String) industryDataMap.get('selectedOption')) ? (String) industryDataMap.get('selectedOption') : null;
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
        Date currenTime = Date.today();//getTimeInOrgTimeZone(System.now());
        dirCase.VIP_Date_Time_Submitted__c = currenTime;
        // Get the default business hours
        dirCase.Date_Case_Received__c = nextBusinessDate();
        System.debug('check ::: '+OnlineWageClaimContainerController.claimantConfirm);
        //populate Date of Docketing if claimantConfirm true
        if(OnlineWageClaimContainerController.claimantConfirm)	dirCase.Date_of_Docket__c  = dirCase.Date_Case_Received__c;
        
        
        //dirCase.FIRSubmittedDate__c = cbd.addBusinessDays(currenTime, 0);
        
        
        
    } 
    public static Date nextBusinessDate(){
        // Commented By AS per Jira OWC-1019 and use existing method
        DateTime currentTime = DateTime.now() ;
        system.debug('currentTime: '+currentTime);
        // Get the default business hours
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        Datetime nextStart = BusinessHours.nextStartDate(bh.id, currentTime);
        system.debug('nextStart: '+nextStart);
        return  Date.valueOf(nextStart);
        /*
        if(isWithin){
            system.debug('currentTime.dateGMT(): '+currentTime.dateGMT());
            return currentTime.dateGMT();
        }
        else{
            Datetime nextStart = BusinessHours.nextStartDate(bh.id, currentTime);
            nextStart = nextStart;//OWCOnlineClaimFormService.getTimeInOrgTimeZone(nextStart);
            system.debug('nextStart.dateGMT(): '+nextStart.dateGMT());
            return  nextStart.dateGMT();
        }
        */
    }
    public static String orgTimeZoneKey ;
    //get Current Time as per Org Time Zone // Not required Apex automatically take care of time according to GMT
    /*
    public static DateTime getTimeInOrgTimeZone(DateTime timeInGMT){
        DateTime timeInOrgZone ;
        if(String.isBlank(orgTimeZoneKey)){
            orgTimeZoneKey = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
        }
        // Get the Org time zone
        Timezone tz = Timezone.getTimeZone(orgTimeZoneKey); 
        Integer timeZoneOffset = tz.getOffset(timeInGMT);
        //Convert timeZoneOffset milleseconds to minutes
        
        timeZoneOffset = timeZoneOffset/(1000*60);
        timeInOrgZone = timeInGMT.addMinutes(timeZoneOffset);
        
        return timeInOrgZone;
    }
    */
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
        Related_Party__c employer = new Related_Party__c();
        //lets check the Employer Name should not be empty
        if( (employerMap.get('individualLastName') != null && String.isNotBlank((String)employerMap.get('individualLastName')))
           || (employerMap.get('OtherIndividualBusinessName') != null && String.isNotBlank((String)employerMap.get('OtherIndividualBusinessName')))
          ) 
        {
            
            if((String)employerMap.get('representativeEmployerType') == 'Individual/Sole Proprietor'){
                system.debug('Individual/Sole Proprietor');	
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
}