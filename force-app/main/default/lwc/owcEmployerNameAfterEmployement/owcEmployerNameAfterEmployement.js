import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
//Apex Class 
import verifyAddressByUSPS from '@salesforce/apex/OWCAddressCheckerUSPS.verifyAddressByUSPS';
import OWC_preliminary_office_locator_link from '@salesforce/label/c.OWC_preliminary_office_locator_link';
import OWC_preliminary_office_locator_dlse_wage_for from '@salesforce/label/c.OWC_preliminary_office_locator_dlse_wage_for';
import fetchOwcEmployerBussiness from '@salesforce/apex/OwcBusinessController.fetchOwcEmployerBussiness';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import owcWorkRecordList from '@salesforce/apex/OwcBusinessController.fetchOwcWorkRecorded';	
// import custom labels for Claim Filed Against (Employer Information) section
import OWC_invalid_email_msg from '@salesforce/label/c.OWC_invalid_email_msg';
import OWC_invalid_phone_msg from '@salesforce/label/c.OWC_invalid_phone_msg';
import OWC_preliminary_covid19_claim from '@salesforce/label/c.OWC_preliminary_covid19_claim';
import OWC_invalid_zipcode_msg from '@salesforce/label/c.OWC_invalid_zipcode_msg';
import OWC_employee_additional_bank from '@salesforce/label/c.OWC_employee_additional_bank'
import OWC_employee_additional_whopaidyou from '@salesforce/label/c.OWC_employee_additional_whopaidyou'
import OWC_employee_additional_personinchargename from '@salesforce/label/c.OWC_employee_additional_personinchargename'
import OWC_first_name from '@salesforce/label/c.OWC_first_name';
import OWC_last_name from '@salesforce/label/c.OWC_last_name';
import OWC_street_address from '@salesforce/label/c.OWC_street_address';
import OWC_city from '@salesforce/label/c.OWC_city';
import OWC_zipcode from '@salesforce/label/c.OWC_zipcode';
import OWC_email from '@salesforce/label/c.OWC_email';
import OWC_website from '@salesforce/label/c.OWC_website';
import OWC_lawfirm_representative_businessname from '@salesforce/label/c.OWC_lawfirm_representative_businessname';
import OWC_state from '@salesforce/label/c.OWC_state';
import OWC_businessname from '@salesforce/label/c.OWC_businessname';
import OWC_empinfo_ClaimField from '@salesforce/label/c.OWC_empinfo_ClaimField';
import OWC_empinfo_EmpBusinessType from '@salesforce/label/c.OWC_empinfo_EmpBusinessType';
import OWC_empinfo_explain from '@salesforce/label/c.OWC_empinfo_explain';
import OWC_empinfo_BusinessPhone from '@salesforce/label/c.OWC_empinfo_BusinessPhone';
import OWC_empinfo_VehicleLicense from '@salesforce/label/c.OWC_empinfo_VehicleLicense';
import OWC_empinfo_Phone from '@salesforce/label/c.OWC_empinfo_Phone';
import OWC_empinfo_ConstructionTrades from '@salesforce/label/c.OWC_empinfo_ConstructionTrades';
import OWC_empinfo_Uploaddoc from '@salesforce/label/c.OWC_empinfo_Uploaddoc';
import OWC_empinfo_Addimage from '@salesforce/label/c.OWC_empinfo_Addimage';
import OWC_ContractionTrade_Helptext from '@salesforce/label/c.OWC_ContractionTrade_Helptext';
import OWC_UploadDocument_Helptext from '@salesforce/label/c.OWC_UploadDocument_Helptext';
import OWC_AddImage_HelpText from '@salesforce/label/c.OWC_AddImage_HelpText';
import OWC_individual_required_helptext from '@salesforce/label/c.OWC_individual_required_helptext';
import OWC_required_field_error_msg from '@salesforce/label/c.OWC_required_field_error_msg';
import OWC_Additional_Info from '@salesforce/label/c.OWC_Additional_Info';
import OWC_NameOfPersonInChage from '@salesforce/label/c.OWC_NameOfPersonInChage';
import OWC_EnterName_HelpText from '@salesforce/label/c.OWC_EnterName_HelpText';
import OWC_JobTitle_PersonInCharge from '@salesforce/label/c.OWC_JobTitle_PersonInCharge';
import OWC_WhoPaidYou from '@salesforce/label/c.OWC_WhoPaidYou';
import OWC_DifferentPerson from '@salesforce/label/c.OWC_DifferentPerson';
import OWC_WorkRecord from '@salesforce/label/c.OWC_WorkRecord';
import OWC_SignTimeCard from '@salesforce/label/c.OWC_SignTimeCard';
import OWC_SomeoneElseName from '@salesforce/label/c.OWC_SomeoneElseName';
import OWC_TotalEmployees from '@salesforce/label/c.OWC_TotalEmployees';
import OWC_BestGuess_HelpText from '@salesforce/label/c.OWC_BestGuess_HelpText';
import OWC_EmpBusiness from '@salesforce/label/c.OWC_EmpBusiness';
import OWC_CompEmployed from '@salesforce/label/c.OWC_CompEmployed';
import OWC_ChangeOrSold from '@salesforce/label/c.OWC_ChangeOrSold';
import OWC_Bankruptcy from '@salesforce/label/c.OWC_Bankruptcy';
import OWC_ShowTost from '@salesforce/label/c.OWC_ShowTost';
import OWC_CellPhone from '@salesforce/label/c.OWC_CellPhone';
import OWC_employee_reuired_field_error_msg from '@salesforce/label/c.OWC_employee_reuired_field_error_msg';
import OWC_fileupload_success_toast_msg from '@salesforce/label/c.OWC_fileupload_success_toast_msg';
import OWC_multiple_file_delete_toast_msg from '@salesforce/label/c.OWC_multiple_file_delete_toast_msg';
import OWC_preliminary_union_contract_covering from '@salesforce/label/c.OWC_preliminary_union_contract_covering';
import OWC_preliminary_upload_document from '@salesforce/label/c.OWC_preliminary_upload_document';
import OWC_url_address from '@salesforce/label/c.OWC_url_address';
import OWC_preliminary_coversheet_mailing_document from '@salesforce/label/c.OWC_preliminary_coversheet_mailing_document';
import OWC_learnmore_button from '@salesforce/label/c.OWC_learnmore_button';
import OWC_filing_wage_claim from '@salesforce/label/c.OWC_filing_wage_claim';	
import OWC_multiplefileupload_helptext from '@salesforce/label/c.OWC_multiplefileupload_helptext';
import OWC_preliminary_coversheet_helptext from '@salesforce/label/c.OWC_preliminary_coversheet_helptext';
import OWC_empinfo_empName from '@salesforce/label/c.OWC_empinfo_empName';
import OWC_Yes from '@salesforce/label/c.OWC_Yes';
import OWC_No from '@salesforce/label/c.OWC_No';
import OWC_employer_delete_button from '@salesforce/label/c.OWC_employer_delete_button';
import OWC_preliminary_specify_one from '@salesforce/label/c.OWC_preliminary_specify_one';
import OWC_select_picklist_label from '@salesforce/label/c.OWC_select_picklist_label';
import OWC_preliminary_specify_other_reason from '@salesforce/label/c.OWC_preliminary_specify_other_reason';
import OWC_urladdress_error_msg from '@salesforce/label/c.OWC_urladdress_error_msg';
import OWC_preliminary_local_office_mail_label from '@salesforce/label/c.OWC_preliminary_local_office_mail_label';
import OWC_union_contract_options_label from '@salesforce/label/c.OWC_union_contract_options_label';
import OWC_invalid_url_msg from '@salesforce/label/c.OWC_invalid_url_msg';
import OWC_employee_additional_bank_incharge_name from '@salesforce/label/c.OWC_employee_additional_bank_incharge_name';
import OWC_employee_additional_bank_claimrelated_action from '@salesforce/label/c.OWC_employee_additional_bank_claimrelated_action';
import OWC_employee_additional_employeer_changed_name from '@salesforce/label/c.OWC_employee_additional_employeer_changed_name';
import OWC_successorinfo_WhenYouJoinComp from '@salesforce/label/c.OWC_successorinfo_WhenYouJoinComp';
import Owc_Ending from '@salesforce/label/c.Owc_Ending';
import OWC_successorinfo_HireDate from '@salesforce/label/c.OWC_successorinfo_HireDate';
import OWC_date_format_label from '@salesforce/label/c.OWC_date_format_label';
export default class OwcEmployerNameChangedCmp extends LightningElement {
    @api deletebutton
    // @api toastFileUploadMsg = OWC_fileupload_success_toast_msg 
    // @api toastFileDeleteMsg = OWC_multiple_file_delete_toast_msg
    isRenderedCallback = false
    @api unionUploadDocSize
    @api uploadAdditionalFileSize
    @api uploadPayStubImageFileSize
    @api isMultipleRequiredCheck = false
    @api employeesectionheader
    @api claimantadvocate
    @api isclaimantgarment
    @api isChecked = false
    @api claimantRelatedRoleActions

    // Upload PayStub Images Attributes
    @api uploadPayStubImages
    @api getPicklistValues = []

    // HelpText Attributes
    @api isHelpText = false
    @api helpText
    // Different templates Attribute
    @api IsOther = false;
    @api IsIndividual  = false;
    @api IsOtherIndividual  = false;
    @api IsAdditionalInfo = false;
    @api isEmployerSellingAssets = false;
    @api isUnionDocumentFileUploaded = false;
    @api isFileUploadedAdditional = false;
    // Fetch list of Employer/Business Type Values from custom metadata Attribute
    @api Employer_Business_Type_List 
    @api employer_Business_Type = ''
    @api owcWorkRecordList_List
    @api owcWorkRecordList
    @api isEmpBusinessType
    // Please explain Attribute
    @api otherPleaseExplain
    //Individual section Attributes
    @api individualFirstName
    @api individualLastName
    @api individualStreetAddress
    @api individualCity
    @api individualState
    @api individualZipCode
    @api individualBusinessPhone
    @api individualCellPhone
    @api individualEmail
    @api individualVehicleLicense
    @api individualWebsite
    // other sections Attributes
    @api OtherIndividualBusinessName
    @api OtherIndividualStreetAddress
    @api OtherIndividualCity
    @api OtherIndividualState
    @api OtherIndividualZipCode
    @api OtherIndividualPhone
    @api OtherIndividualEmail
    @api OtherIndividualVehicleLicense
    @api OtherIndividualWebsite
    @api OtherIndividualConstructionTrades
    @api fileUploader
    @api representativeEmployerType
    // @api employer_Business_Type = ''
    //Error message Attribute
    @api errorMsg
    @api uploadUnionContractDocument
    @api uploadUnionContractDocumentadditional
    @api ValidationMsg;
    @api additionalName;
    @api additionalJobTitle;
    @api additionalDifferentPerson;
    @api additionalWorkRecord;
    @api additionalSignTimeCard;
    @api additionalSomeoneElse;
    @api additionalTotalEmployees;
    isadditionalTotalEmployees = false
    @api additionalEmpBusiness;
    @api additionalCompEmployed;
    @api additionalChangeOrSold;
    @api additionalBankruptcy;
    @api uploadAdditionalDocuments;
    @api additionalBankName
    @api additionalWHOPaidYou
    @api additionalPersonInchargeName
    @track isClaimantAdvocate = true

    // USPS Address attributes
    @api uspsCurrentAddressCheck = false
    @api isUSPSAddressErrorTemplate = false;
    @api isUSPSAddressSuccessTemplate = false;
    @api uspsAddress
    @api isUSPSAddressCheck = false;

    // Preliminary question Attribute
    @api specifyFilingWageClaim 
    @api covid19Claim 
    @api isEmployeeFilingWageClaimOther  = false
    @api specifyOtherReason 

    //Don't Know
    @track isDontKnow = false;
    @track empName;
    @api sectionid

    // Union Contract Covered
    @api unionContractCovering
    @api urlAddress
    @api isUnionContractCovered = false
    @api unionContractCovered
    @api coversheetDocument
    @api filingWageClaim
    // @api specifyFilingWageClaim
    // @api isEmployeeFilingWageClaimOther = false
    @api isCoverSheetDocRequired = false
    @api uploadedEmployerDocuments
    @api isEmployerDocUpload = false
    @api employerUploadDocSize
    @api uploadedEmployerAdditionalDocuments
    @api isEmployerAdditionalDoc = false
    @api employerAdditionalUploadDocSize
    @api isIndividualStatePicklist = false
    @api isOtherIndividualPicklist = false
    @api isRenderIndividualState = false
    @api isRenderOtherIndividualState = false
    @api preliminaryCovidClaimPicklistData
    @api ispreliminaryshown
    @api mailOfficeLocator
    @api isOfficeLocatorMail = false
    @api unionContractCoverOptions = unionContractCoverOptions
    @api isUnionContractDocumentUpload = false;
    @api isUrlAddress = false;
    @api isMailToOfficeLocator = false;
    @api employerChangedName
    @api isEmployerChangedName
    @api isRenderedPicklist = false
    @api employerBusinessTypeList
    @api startingDate
    @api endingDate
    @api isRenderPicklist = false
    @api countryCodeOtherIndividualPhone; 
    @api countryCodeindividualCellPhone;
    @api countryCodeindividualBusinessPhone; 
    @api IndividualFirstNamerequired = false;
    @api IndividualStreetAddressrequired = false;
    @api IndividualCityrequired = false;
    @api IndividualStaterequired = false;
    @api IndividualZipCoderequired = false;
    @api IndividualBusinessPhonerequired = false;
    @api OtherStreetAddressrequired = false
    @api OtherCityrequired = false
    @api OtherStaterequired = false
    @api OtherZipCoderequired = false
    @api OtherBusinessPhonerequired = false
    isempBusinessType = false
    isPleaseExplain = false
    isIndividualFirstName = false
    isIndividualLastName = false
    isIndividualLicensePlateNo = false
    isBusinessName = false
    isempBusinessType = false
    isUnionContractCoveredDoc = false
    isurlAddressValid = false
    isIndividualRequiredSet = false
    isOtherIndividualBusinessName = false
    isotherPleaseExplain = false
    isDontKnowEmpName = false
    isIndividualBusinessPhone = false
    isindividualCellPhone = false
    isIndividualZipCode = false
    isOtherIndividualZipCode = false
    isIndividualWebsite = false
    isOtherIndividualWebsite = false
    isOtherIndividualPhone = false
    isOtherIndividualEmail = false
    isDontKnowspecifyOtherReason = false

    @api isUSPSAddressInvalid = false;
    @api isUPSPAddressValid = false;
    @api addressJson
    @api uspsProceedAddress = false
    customLabelValues = customLabelValues
    @api statePicklistValues;
    options = radioOptions;
    @api isFormPreviewMode = false
    @api empBusinessTypeDetails
    @api isNotClaimantGarment = false
    regExpPhone = /^((\\+[1-9]{1,4}[ \\-]*)|(\\([0-9]{2,3}\\)[ \\-]*)|([0-9]{2,4})[ \\-]*)*?[0-9]{3,4}?[ \\-]*[0-9]{3,4}?$/;
    regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    zipCodeRegrex = /^\d{5}(?:[-\s]\d{4})?$/;
    urlAddressChekerRegrex = /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$/;

    @api isMultipleFileUploadHelpText
    customLabelValues = {
        OWC_date_format_label,
        Owc_Ending,
        OWC_successorinfo_HireDate	,
        OWC_successorinfo_WhenYouJoinComp,
        OWC_employee_additional_employeer_changed_name,
        OWC_employee_additional_bank_claimrelated_action,
        OWC_employee_additional_bank_incharge_name,
        OWC_invalid_url_msg,
        OWC_union_contract_options_label,
        OWC_preliminary_local_office_mail_label,
        OWC_urladdress_error_msg,
        OWC_preliminary_specify_other_reason,
        OWC_preliminary_specify_one,
        OWC_Yes,
        OWC_No,
        OWC_preliminary_covid19_claim,
        OWC_preliminary_office_locator_link,
        OWC_preliminary_office_locator_dlse_wage_for,
        OWC_employer_delete_button,
        OWC_filing_wage_claim,
        OWC_learnmore_button,
        OWC_preliminary_coversheet_mailing_document,
        OWC_url_address,
        OWC_preliminary_upload_document,
        OWC_employee_additional_whopaidyou,
        OWC_employee_additional_personinchargename,
        OWC_employee_additional_bank,
        OWC_select_picklist_label,
        OWC_ShowTost,
        OWC_Additional_Info,
        OWC_NameOfPersonInChage,
        OWC_EnterName_HelpText,
        OWC_JobTitle_PersonInCharge,
        OWC_SomeoneElseName,
        OWC_WhoPaidYou,
        OWC_DifferentPerson,
        OWC_WorkRecord,
        OWC_SignTimeCard,
        OWC_CellPhone,
        OWC_TotalEmployees,
        OWC_BestGuess_HelpText,
        OWC_EmpBusiness,
        OWC_CompEmployed,
        OWC_ChangeOrSold,
        OWC_Bankruptcy,
        OWC_first_name,
        OWC_last_name,
        OWC_street_address,
        OWC_city,
        OWC_state,
        OWC_zipcode,
        OWC_email,
        OWC_website,
        OWC_lawfirm_representative_businessname,
        OWC_businessname,
        OWC_empinfo_ClaimField,
        OWC_empinfo_EmpBusinessType,
        OWC_empinfo_explain,
        OWC_CompEmployed,
        OWC_empinfo_BusinessPhone,
        OWC_empinfo_VehicleLicense,
        OWC_empinfo_Phone,
        OWC_empinfo_ConstructionTrades,
        OWC_empinfo_Uploaddoc,
        OWC_empinfo_Addimage,
        OWC_ContractionTrade_Helptext,
        OWC_UploadDocument_Helptext,
        OWC_AddImage_HelpText,
        OWC_required_field_error_msg,
        OWC_preliminary_union_contract_covering,
        OWC_empinfo_empName,
    }
    connectedCallback(){
        // don’t forget to load static resources in connectedCallback . 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
            console.log( 'Files loaded' );
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
            console.log( error.body.message );
    });
    
    
    if(this.isclaimantgarment === true){
        this.isRenderPicklist = true;
        const employerBusinessTypeList = JSON.parse(JSON.stringify(this.Employer_Business_Type_List))
        employerBusinessTypeList.splice(1,1)
        this.employerBusinessTypeList = employerBusinessTypeList
        console.log('cehck ::: ', JSON.stringify(employerBusinessTypeList))
        this.isClaimantAdvocate = false
    }
    }
    // Toast msg
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    @wire(fetchOwcEmployerBussiness)
    fetchOwcEmployerBussiness({ data, error }){
        if(data){
            this.Employer_Business_Type_List = data;
            console.log(' Employer_Business_Type_List in child :: ', JSON.stringify(data))
        }
        else if(error){

        }
    }

    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data, error }){
        if(data){
            console.log('Employer Picklist Options ::: ', JSON.stringify(data[0].owcBusineesTypeOptions));
            console.log('rendered Picklist ::: ', this.isRenderPicklist)
            this.covid19ClaimPicklistData = data[0].covid19WageClaim;
            this.statePicklistValues = data[0].statePicklist;
            this.preliminaryCovidClaimPicklistData = data[0].preliminaryCovidClaimValues;
            
            this.owcWorkRecordList_List = data[0].owcWorkedRecordedList;
            this.countryCodeValue = data[0].owcCountryCodeList;
            this.countryCodeOtherIndividualPhone = '+1';
            this.countryCodeindividualCellPhone = '+1';
            this.countryCodeindividualBusinessPhone = '+1';
            console.log('new list'+JSON.stringify(this.owcWorkRecordList_List));
            this.individualState = 'CA'
            this.OtherIndividualState = 'CA'
        }
        else if(error){
            this.error = error;
        }
    }

    @api get showIndividualSole(){
        return this.IsIndividual === true && this.isClaimantAdvocate === true
    }
    handleEmployer_Business_TypeFocus(){
        let employer_Business_Type = this.template.querySelector('[data-id="employer_Business_Type"]');          
        if(employer_Business_Type.value == undefined || employer_Business_Type.value == null || employer_Business_Type.value.trim() == '' || employer_Business_Type.value == '--Select--'){
            this.isMultipleRequiredCheck = true
            employer_Business_Type.setCustomValidity(OWC_required_field_error_msg);
        }else{
            this.isMultipleRequiredCheck = false
            employer_Business_Type.setCustomValidity("");
        }
        employer_Business_Type.reportValidity();
    }

    sectionValidityChecker(ids, values){
        let id = ids
        let value = values
        console.log('Value:', value);
        if(value == undefined && value == null || value.trim() == ""){
            id.setCustomValidity(OWC_required_field_error_msg);
            id.reportValidity();
            return true;
        }
    }

    handleEmailValidityChecker(values){
        const value = values
        if(value.value === undefined || value.value === null || value.value.trim() === ''){
            value.setCustomValidity('')
            value.reportValidity()
            return false;
        }
        else if(value.value.match(this.regExpEmailformat)){
            value.setCustomValidity('')
            value.reportValidity()
            return false;
        }
        else{
            value.setCustomValidity(OWC_invalid_email_msg)
            value.reportValidity()
            return true;
        }
    }

    handlePhoneValidityChecker(values){
        const value = values
        if(value.value.trim() == ''){
            value.setCustomValidity('');
            value.reportValidity()
            return false
        }
        else if(value.value.trim() != ''){
            if(value.value.match(this.regExpPhone)){
                value.setCustomValidity("");
                value.reportValidity()
                return false
            }
            else{
                value.setCustomValidity(OWC_invalid_phone_msg);
                value.reportValidity()
                return true
            }                
        }
    }

    handleIndividualWebsiteFocus(){
        const individualWebsite = this.template.querySelector('[data-id="individualWebsite"');
        if(individualWebsite.value === undefined || individualWebsite.value === null || individualWebsite.value.trim() === ''){
            individualWebsite.setCustomValidity('')
            individualWebsite.reportValidity()
            this.isIndivudualWebsite = false
        }
        else if(individualWebsite.value.match(this.urlAddressChekerRegrex)){
            individualWebsite.setCustomValidity('')
            individualWebsite.reportValidity()
            this.isIndivudualWebsite = false
        }
        else{
            individualWebsite.setCustomValidity(this.customLabelValues.OWC_urladdress_error_msg)
            individualWebsite.reportValidity()
            this.isIndivudualWebsite = true;
        }
    }

    handleIndividualLastNameFocus(){
        let individualLastName = this.template.querySelector('[data-id="individualLastName"]');
        if(individualLastName.value == null || individualLastName.value == undefined || individualLastName.value.trim() == ''){
            individualLastName.setCustomValidity(OWC_required_field_error_msg);
            this.isIndividualLastName = true;
        }
        else{
            individualLastName.setCustomValidity('')
            this.isIndividualLastName = false;
        }
        individualLastName.reportValidity();
    }

    updateAddressFieldsithUSPS(){
        if(this.IsIndividual === true && this.isClaimantAdvocate === true){
            this.individualStreetAddress = this.uspsAddress.Address2
            this.individualCity = this.uspsAddress.City
            this.template.querySelector('[data-id="individualState"]').value = this.uspsAddress.State
            this.individualState = this.uspsAddress.State
            this.individualZipCode = this.uspsAddress.Zip5
        }
        else if(this.IsOtherIndividual === true){
            this.OtherIndividualStreetAddress = this.uspsAddress.Address2
            this.OtherIndividualCity = this.uspsAddress.City
            this.template.querySelector('[data-id="OtherIndividualState"]').value = this.uspsAddress.State
            this.OtherIndividualState = this.uspsAddress.State
            this.OtherIndividualZipCode = this.uspsAddress.Zip5
        }
    }

    /* This method is used to take values from the input fields and assign to their respective attributes */
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false 
        switch ( event.target.name ) { 
            case "uspsProceedAddress":
            const uspsProceedAddress = event.target.checked;
            this.uspsProceedAddress = uspsProceedAddress;
            if(this.uspsProceedAddress === true){
                this.updateAddressFieldsithUSPS();
            }
            console.log('this.uspsProceedAddress ::: ', this.uspsProceedAddress)
            break;
        case "uspsCurrentAddressCheck":
            const uspsCurrentAddressCheck = event.target.checked;
            this.uspsCurrentAddressCheck = uspsCurrentAddressCheck;
            console.log('this.uspsCurrentAddressCheck ::: ', this.uspsCurrentAddressCheck)
            break;
            case "employer_Business_Type":
            this.representativeEmployerType = event.target.value;
            this.handleEmployer_Business_TypeFocus();
            console.log('representativeEmployerType:', this.representativeEmployerType);
            if(this.representativeEmployerType === "Other / I don't know"){
                //keeping fields null
                // this.otherPleaseExplain= null;
                this.isUSPSAddressSuccessTemplate = false;
                this.isUSPSAddressErrorTemplate = false;
                this.isIndividualStatePicklist = false
                this.isOtherIndividualPicklist = true
                //Open Selected Section
                this.IsOther = true;
                this.IsIndividual  = false;
                
                this.IsOtherIndividual = true;
                this.isEmpBusinessType = true;
                this.isDontKnow = false;
            }else if(this.representativeEmployerType === 'Individual/Sole Proprietor'){
                //keeping fields null
                this.isUSPSAddressSuccessTemplate = false;
                this.isUSPSAddressErrorTemplate = false;
                this.isIndividualStatePicklist = true
                this.isOtherIndividualPicklist = false
                this.individualFirstName = null;
                this.individualLastName = null;
                this.individualStreetAddress = null;
                this.individualCity = null;
                this.individualZipCode = null;
                this.individualState = 'CA';
                this.individualBusinessPhone = null;
                this.individualEmail = null;
                this.individualVehicleLicense = null;
                this.individualWebsite = null;
                //Open Selected Section
                this.IsOther = false;
                this.IsIndividual  = true;
                console.log('selected ::: ', this.IsIndividual )
                console.log('selected1 ::: ',this.isClaimantAdvocate)
                this.IsOtherIndividual = false;
                this.isEmpBusinessType = true;
                this.isDontKnow = false;
            }else if(this.representativeEmployerType === 'Corporation' || this.representativeEmployerType === 'General Partnership' || this.representativeEmployerType === 'LLC' ){                        
                //keeping fields null
                this.isUSPSAddressSuccessTemplate = false;
                this.isUSPSAddressErrorTemplate = false;
                this.isIndividualStatePicklist = false
                this.isOtherIndividualPicklist = true
                this.OtherIndividualBusinessName = null;
                this.OtherIndividualStreetAddress = null;
                this.OtherIndividualCity = null;
                this.OtherIndividualZipCode = null;
                this.OtherIndividualState = 'CA';
                this.OtherIndividualPhone = null;
                this.OtherIndividualEmail = null;
                this.OtherIndividualVehicleLicense = null;
                this.OtherIndividualWebsite = null;
                //Open Selected Section
                this.IsOther = false;
                this.IsIndividual  = false;
                this.IsOtherIndividual = true;
                this.isEmpBusinessType = true;
                this.isDontKnow = false;
            }else if(this.representativeEmployerType === "Don't Know"){
                //keeping fields null
                this.empName= null;
                this.isUSPSAddressSuccessTemplate = false;
                this.isUSPSAddressErrorTemplate = false;
                //Open Selected Section
                this.IsOther = false;
                this.IsIndividual  = false;
                this.isDontKnow = false;
                
                this.IsOtherIndividual = false;
                this.isEmpBusinessType = false;
            }else{
                //Closing all Section
                this.isUSPSAddressSuccessTemplate = false;
                this.isUSPSAddressErrorTemplate = false;
                this.IsOther = false;
                this.IsIndividual  = false;
                this.isDontKnow = false;
                this.IsOtherIndividual = false;
                this.isEmpBusinessType = false;
            }
        break;
        case "otherPleaseExplain":            
            this.otherPleaseExplain = event.detail.value.trim();
            this.handleOtherBusinessReasonFocus();
            console.log('otherPleaseExplain :::', this.otherPleaseExplain);
        break;
        case "empName":
            this.empName = event.target.value.trim();
            this.handleEmpNameDontKnowFocus();
            console.log('empName :::', this.empName);
        break;
        case "individualLastName":
            this.individualLastName = event.target.value.trim();
            this.handleIndividualLastNameFocus();
        break;
        case "individualFirstName":
            this.individualFirstName = event.target.value.trim();
            this.handleIndividualFirstNameFocus()
        break;
        case "individualStreetAddress":
            this.individualStreetAddress = event.target.value.trim();
            this.handleindividualStreetAddressFocus();
        break;
        case "individualCity":
            this.individualCity = event.target.value.trim();
            this.handleindividualCityFocus();
        break;
        case "individualState":
            this.individualState = event.target.value.trim();
            this.handleindividualStateFocus();
        break;
        case "individualZipCode":
            this.individualZipCode = event.target.value;
            if(event.target.value.length >= 5 && this.individualZipCode.includes('-')){
                this.template.querySelector('[data-id="individualZipCode"]').value = event.target.value;
            }
            else if(event.target.value.length === 6){
                this.template.querySelector('[data-id="individualZipCode"]').value = event.target.value.replace(/(\d{5})/, "$1-");
            }
            this.individualZipCode = event.target.value;
            this.handleIndividualZipCodeFocus();
        break;
        case "individualBusinessPhone":
            this.individualBusinessPhone = event.target.value.trim();
            this.handleIndividualBusinessPhoneFocus();
        break;
        case "individualCellPhone":
            this.individualCellPhone = event.target.value.trim();
            this.handleIndividualCellPhoneFocus();
        break;
        case "individualEmail":
            this.individualEmail = event.target.value.trim();
            this.handleIndividualEmailFocus();
        break;
        case "individualVehicleLicense":
            this.individualVehicleLicense = event.target.value.trim();
            if(this.individualVehicleLicense === null||this.individualVehicleLicense === ''){
                this.IndividualFirstNamerequired = false;
                this.IndividualStreetAddressrequired = false;
                this.IndividualCityrequired = false;
                this.IndividualStaterequired = false;
                this.IndividualZipCoderequired = false;
                this.IndividualBusinessPhonerequired = false;

            }else{
                this.IndividualFirstNamerequired = true;
            this.IndividualStreetAddressrequired = true;
            this.IndividualCityrequired = true;
            this.IndividualStaterequired = true;
            this.IndividualZipCoderequired = true;
            this.IndividualBusinessPhonerequired = true;
            }
            this.handleIndividualFirstNameFocus()
            this.handleindividualStreetAddressFocus()
            this.handleindividualCityFocus()
            this.handleindividualStateFocus()
            this.handleIndividualBusinessPhoneFocus()
            this.handleIndividualZipCodeFocus()
        break;
        case "individualWebsite":
            this.individualWebsite = event.target.value.trim();
            this.handleIndividualWebsiteFocus();
        break;
        case "OtherIndividualBusinessName":
            this.OtherIndividualBusinessName = event.target.value.trim();
            this.handleOtherIndividualBusinessNameFocus();
        break;
        case "OtherIndividualStreetAddress":
            this.OtherIndividualStreetAddress = event.target.value.trim();
            this.handleOtherIndividualStreetAddressfocus();
        break;
        case "OtherIndividualCity":
            this.OtherIndividualCity = event.target.value.trim();
            this.handleOtherIndividualCityfocus();
        break;
        case "OtherIndividualState":
            this.OtherIndividualState = event.target.value.trim();
            this.handleOtherIndividualStatefocus();
        break;
        case "OtherIndividualZipCode":
            this.OtherIndividualZipCode = event.target.value;
            if(event.target.value.length >= 5 && this.OtherIndividualZipCode.includes('-')){
                this.template.querySelector('[data-id="OtherIndividualZipCode"]').value = event.target.value;
            }
            else if(event.target.value.length === 6){
                this.template.querySelector('[data-id="OtherIndividualZipCode"]').value = event.target.value.replace(/(\d{5})/, "$1-");
            }
            this.OtherIndividualZipCode = event.target.value;
            this.handleOtherIndividualZipCodeFocus();
        break;
        case "OtherIndividualPhone":       
            this.OtherIndividualPhone = event.target.value.trim();
            this.handleOtherIndividualPhoneFocus();
        break;
        case "OtherIndividualEmail":
            this.OtherIndividualEmail = event.target.value.trim();
            this.handleOtherIndividualEmail();
        break;
        case "OtherIndividualVehicleLicense":
            this.OtherIndividualVehicleLicense = event.target.value.trim();
            if(this.OtherIndividualVehicleLicense === null||this.OtherIndividualVehicleLicense === ''||this.OtherIndividualVehicleLicense === undefined){
                this.OtherStreetAddressrequired = false;
                this.OtherCityrequired = false;
                this.OtherStaterequired = false;
                this.OtherZipCoderequired = false;
                this.OtherBusinessPhonerequired = false;

            }else{
                this.OtherStreetAddressrequired = true;
                this.OtherCityrequired = true;
                this.OtherStaterequired = true;
                this.OtherZipCoderequired = true;
                this.OtherBusinessPhonerequired = true;
            }
            this.handleOtherIndividualStreetAddressfocus();
            this.handleOtherIndividualCityfocus();
            this.handleOtherIndividualStatefocus();
            this.handleOtherIndividualZipCodeFocus();
            this.handleOtherIndividualPhoneFocus();
        break;
        case "OtherIndividualWebsite":
            this.OtherIndividualWebsite = event.target.value.trim();
            console.log('OtherIndividualWebsite :::', this.OtherIndividualWebsite);
            this.handleOtherIndividualWebsiteFocus();
        break;
        case "OtherIndividualConstructionTrades":
            this.OtherIndividualConstructionTrades = event.target.value.trim();
            console.log('OtherIndividualConstructionTrades :::', this.OtherIndividualConstructionTrades);
        break;
        case "countryCodeOtherIndividualPhone":
            this.countryCodeOtherIndividualPhone = event.target.value.trim();
            console.log('countryCodeOtherIndividualPhone : : :', this.countryCodeOtherIndividualPhone);
        break;
        case "countryCodeindividualCellPhone":
        this.countryCodeindividualCellPhone = event.target.value.trim();
        console.log('countryCodeindividualCellPhone : : :', this.countryCodeindividualCellPhone);
        break;
        case "countryCodeindividualBusinessPhone":
        this.countryCodeindividualBusinessPhone = event.target.value.trim();
        console.log('countryCodeindividualBusinessPhone : : :', this.countryCodeindividualBusinessPhone);
        break;
        case "additionalTotalEmployees":
            this.additionalTotalEmployees = event.target.value.trim();
            this.handleadditionalTotalEmployeesFocus();
        break;
        }
    }

    handleadditionalTotalEmployeesFocus(){
        let additionalTotalEmployees = this.template.querySelector('[data-id="additionalTotalEmployees"]');
        if(additionalTotalEmployees.value == null || additionalTotalEmployees.value == undefined || additionalTotalEmployees.value.trim() == ''){
            additionalTotalEmployees.setCustomValidity(OWC_required_field_error_msg);
            this.isadditionalTotalEmployees = true;
        }
        else{
            additionalTotalEmployees.setCustomValidity('')
            this.isadditionalTotalEmployees = false;
        }
        additionalTotalEmployees.reportValidity();
    }
    handleIndividualFirstNameFocus(){ 
        let individualFirstName = this.template.querySelector('[data-id="individualFirstName"]');  
        
            if(individualFirstName.value == undefined || individualFirstName.value == null || individualFirstName.value.trim() == ''){
                if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
                this.isIndividualFirstName = true
                individualFirstName.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isIndividualFirstName = false
                    individualFirstName.setCustomValidity("");
                    }
            }
            else{
                this.isIndividualFirstName = false
                individualFirstName.setCustomValidity("");
            }
            individualFirstName.reportValidity();
        
    }
    handleindividualStreetAddressFocus(){ 
        let individualStreetAddress = this.template.querySelector('[data-id="individualStreetAddress"]');  
       
            if(individualStreetAddress.value == undefined || individualStreetAddress.value == null || individualStreetAddress.value.trim() == ''){
                if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
                this.isindividualStreetAddress = true
                individualStreetAddress.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isindividualStreetAddress = false
                individualStreetAddress.setCustomValidity("");
                
                }
            }
            else{
                this.isindividualStreetAddress = false
                individualStreetAddress.setCustomValidity("");
            }
            individualStreetAddress.reportValidity();
        
    }
    handleOtherIndividualStreetAddressFocus(){ 
        let OtherIndividualStreetAddress = this.template.querySelector('[data-id="OtherIndividualStreetAddress"]');  
       
            if(OtherIndividualStreetAddress.value == undefined || OtherIndividualStreetAddress.value == null || OtherIndividualStreetAddress.value.trim() == ''){
                if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){        
                this.isOtherIndividualStreetAddress = true
                OtherIndividualStreetAddress.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isOtherIndividualStreetAddress = false
                    OtherIndividualStreetAddress.setCustomValidity("");
                }
            }
            else{
                this.isOtherIndividualStreetAddress = false
                OtherIndividualStreetAddress.setCustomValidity("");
            }
            OtherIndividualStreetAddress.reportValidity();
        
    }
    handleindividualCityFocus(){ 
        let individualCity = this.template.querySelector('[data-id="individualCity"]');  
        
            if(individualCity.value == undefined || individualCity.value == null || individualCity.value.trim() == ''){
                if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
                this.isindividualCity = true
                individualCity.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isindividualCity = false
                individualCity.setCustomValidity("");
                }
            }
            else{
                this.isindividualCity = false
                individualCity.setCustomValidity("");
            }
            individualCity.reportValidity();
        
    }
    handleOtherIndividualCityfocus(){ 
        let OtherIndividualCity = this.template.querySelector('[data-id="OtherIndividualCity"]');  
        
            if(OtherIndividualCity.value == undefined || OtherIndividualCity.value == null || OtherIndividualCity.value.trim() == ''){
                if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){        
                this.isOtherIndividualCity = true
                OtherIndividualCity.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isOtherIndividualCity = false
                OtherIndividualCity.setCustomValidity("");
                }
            }
            else{
                this.isOtherIndividualCity = false
                OtherIndividualCity.setCustomValidity("");
            }
            OtherIndividualCity.reportValidity();
        
    }
    handleindividualStateFocus(){ 
        let individualState = this.template.querySelector('[data-id="individualState"]');  
        
            if(individualState.value == undefined || individualState.value == null || individualState.value.trim() == ''){
                if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
                this.isindividualState = true
                individualState.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isindividualState = false
                individualState.setCustomValidity("");
                }
            }
            else{
                this.isindividualState = false
                individualState.setCustomValidity("");
            }
            individualState.reportValidity();
        
    }
    handleOtherIndividualStatefocus(){ 
        let OtherIndividualState = this.template.querySelector('[data-id="OtherIndividualState"]');  
        
            if(OtherIndividualState.value == undefined || OtherIndividualState.value == null || OtherIndividualState.value.trim() == ''){
                if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){        
                this.isOtherIndividualState = true
                OtherIndividualState.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isOtherIndividualState = false
                OtherIndividualState.setCustomValidity("");
                }
            }
            else{
                this.isOtherIndividualState = false
                OtherIndividualState.setCustomValidity("");
            }
            OtherIndividualState.reportValidity();
        
    }
    handleIndividualZipCodeFocus(){
        const individualZipCode = this.template.querySelector('[data-id="individualZipCode"');
        if(individualZipCode.value === undefined || individualZipCode.value === null || individualZipCode.value.trim() === ''){
            if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
            individualZipCode.setCustomValidity(OWC_required_field_error_msg)
            this.isIndividualZipCode = true
            }
            else{
                individualZipCode.setCustomValidity("")
            this.isIndividualZipCode = false
            
            }
        }
        else if(individualZipCode.value.match(this.zipCodeRegrex)){
            individualZipCode.setCustomValidity('')
            this.isIndividualZipCode = false
        }
        else{
            individualZipCode.setCustomValidity(OWC_invalid_zipcode_msg)
            this.isIndividualZipCode = true
        }
        individualZipCode.reportValidity()
    }
    handleOtherIndividualZipCodeFocus(){
        const OtherIndividualZipCode = this.template.querySelector('[data-id="OtherIndividualZipCode"');
        if(OtherIndividualZipCode.value === undefined || OtherIndividualZipCode.value === null || OtherIndividualZipCode.value.trim() === ''){
            if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){        
            OtherIndividualZipCode.setCustomValidity(OWC_required_field_error_msg)
            this.isOtherIndividualZipCode = true
            }
            else{
                OtherIndividualZipCode.setCustomValidity("")
                this.isOtherIndividualZipCode = false
            }
        }
        else if(OtherIndividualZipCode.value.match(this.zipCodeRegrex)){
            OtherIndividualZipCode.setCustomValidity('')
            this.isOtherIndividualZipCode = false
        }
        else{
            OtherIndividualZipCode.setCustomValidity(OWC_invalid_zipcode_msg)
            this.isOtherIndividualZipCode = true
        }
        OtherIndividualZipCode.reportValidity()
    }
    handleIndividualBusinessPhoneFocus(){
        const individualBusinessPhone = this.template.querySelector('[data-id="individualBusinessPhone"');
        if(individualBusinessPhone.value === undefined || individualBusinessPhone.value === null || individualBusinessPhone.value.trim() === ''){
            if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
                individualBusinessPhone.setCustomValidity(OWC_required_field_error_msg)
                this.isIndividualBusinessPhone = true
                }
                else{
                    individualBusinessPhone.setCustomValidity("")
                this.isIndividualBusinessPhone = false
                }
        }
        else if(individualBusinessPhone.value.match(this.regExpPhone)){
            individualBusinessPhone.setCustomValidity('')
            this.isIndividualBusinessPhone = false
        }
        else{
            individualBusinessPhone.setCustomValidity(OWC_invalid_phone_msg)
            this.isIndividualBusinessPhone = true
        }
        individualBusinessPhone.reportValidity()
    }
    get showCurrentAddressTemplate(){
        return this.isUSPSAddressErrorTemplate === true || this.isUSPSAddressSuccessTemplate === true
    }
    handleUSPSAddressChecker(){
        if(this.IsIndividual === true && this.isClaimantAdvocate === true){
            this.addressJson = {
                address2 : this.individualStreetAddress,
                City : this.individualCity,
                state : this.individualState,
                zip5 : this.individualZipCode
            }
        }
        else if(this.IsOtherIndividual === true){
            this.addressJson = {
                address2 : this.OtherIndividualStreetAddress,
                City : this.OtherIndividualCity,
                state : this.OtherIndividualState,
                zip5 : this.OtherIndividualZipCode
            }
        }
        verifyAddressByUSPS({
            addressJson : JSON.stringify(this.addressJson)
        })
           .then(result => {
               if(result){
                   if(result.message == 'Success'){
                    console.log('USPS response ::: ', JSON.stringify(result));
                       this.uspsAddress = result.address;
                       this.isUSPSAddressInvalid = false;
                       this.isUPSPAddressValid = true;
                       this.isUSPSAddressErrorTemplate = false;
                       this.isUSPSAddressSuccessTemplate = true;
                       if(this.uspsAddress != null){
                        this.isUSPSAddressCheck = true;
                    }
                    else{
                        this.isUSPSAddressCheck = false;
                    }
                    const uspsProceedAddress = this.template.querySelector('[data-id="uspsProceedAddress"]');
                       uspsProceedAddress.focus()
                   }
                   else{
                    console.log('USPS response ::: ', JSON.stringify(result));
                       this.isUSPSAddressInvalid = true;
                       this.isUPSPAddressValid = false;
                       this.isUSPSAddressErrorTemplate = true;
                       this.isUSPSAddressSuccessTemplate = false;
                       const uspsCurrentAddressCheck = this.template.querySelector('[data-id="uspsCurrentAddressCheck"]');
                       uspsCurrentAddressCheck.focus()
                   }
                    
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
    }

    /* This method is used to check the validation for all the fields. */
    @api
    handleEmployerNameChangedParent(){
        let empBusinessType = this.template.querySelector('[data-id="employer_Business_Type"]');
        if(empBusinessType.value == undefined || empBusinessType.value === null || empBusinessType.value === ''){
            let empBusinessType = this.template.querySelector('[data-id="employer_Business_Type"]');
            let empBusinessTypeValue = this.empBusinessType
            this.isempBusinessType = this.sectionValidityChecker(empBusinessType, empBusinessTypeValue);
            this.isempBusinessType === true ? empBusinessType.focus() : ''
            if(this.isempBusinessType === true ){
                const selectEvent = new CustomEvent('employernameafteremployementvakidityevent', {
                    detail: { 
                        currentStep : true
                    }
                });
                this.dispatchEvent(selectEvent);
                
            }
            else{
                this.handleEmployerNameChangedData();
            }
        }
        if(this.IsIndividual === true){
            const individualEmail = this.template.querySelector('[data-id="individualEmail"');
            const individualLastName = this.template.querySelector('[data-id="individualLastName"');
            const individualCellPhone = this.template.querySelector('[data-id="individualCellPhone"');
            const individualBusinessPhone = this.template.querySelector('[data-id="individualBusinessPhone"');
            const additionalTotalEmployees = this.template.querySelector('[data-id="additionalTotalEmployees"');
            this.handleadditionalTotalEmployeesFocus();
            this.isadditionalTotalEmployees === true ? additionalTotalEmployees.focus() : ''
            const individualFirstNameValue = this.individualFirstName == undefined || this.individualFirstName == null ? '' : this.individualFirstName.trim()
            const individualLastNameValue = this.individualLastName == undefined || this.individualLastName == null ? '' : this.individualLastName.trim()
            const individualVechicleLicenseValue = this.individualVehicleLicense == undefined || this.individualVehicleLicense == null ? '' : this.individualVehicleLicense.trim()
            if((individualFirstNameValue == '') && (individualLastNameValue == '') && (individualVechicleLicenseValue == '')){
                this.isIndividualRequiredSet = true
                this.isMultipleRequiredCheck = true
                this.ValidationMsg = OWC_employee_reuired_field_error_msg
            }
            else{
                this.isIndividualRequiredSet = false
                this.isMultipleRequiredCheck = false
            }

            if(this.individualBusinessPhone != undefined || this.individualBusinessPhone != null || this.individualBusinessPhone != ''){
                const individualBusinessPhone = this.template.querySelector('[data-id="individualBusinessPhone"');
                this.isIndividualBusinessPhone = this.handlePhoneValidityChecker(individualBusinessPhone);
            }
            else{
                this.isIndividualBusinessPhone = false
            }
            if(this.individualCellPhone != undefined || this.individualCellPhone != null || this.individualCellPhone != ''){
                const individualCellPhone = this.template.querySelector('[data-id="individualCellPhone"');
                this.isindividualCellPhone = this.handlePhoneValidityChecker(individualCellPhone);
            }
            else{
                this.isindividualCellPhone = false
            }
            if(this.individualEmail != undefined || this.individualEmail != null || this.individualEmail != ''){
                const individualEmail = this.template.querySelector('[data-id="individualEmail"');
                this.isindividualEmail = this.handleEmailValidityChecker(individualEmail);
            }
            else{
                this.isindividualEmail = false
            }

            const individualZipCode = this.template.querySelector('[data-id="individualZipCode"]');
            if(individualZipCode == undefined || individualZipCode == null){
                this.isIndividualZipCode = false
            }
            else if(individualZipCode.value.trim() == null || individualZipCode.value.trim() == undefined || individualZipCode.value.trim() == ''){
                this.isIndividualZipCode = false
                individualZipCode.setCustomValidity('');
                individualZipCode.reportValidity()
            }
            else if(individualZipCode.value.trim() != null || individualZipCode.value.trim() != undefined || individualZipCode.value.trim() != ''){
                const individualZipCode = this.template.querySelector('[data-id="individualZipCode"]');
                if(individualZipCode.value.match(this.zipCodeRegrex)){
                    individualZipCode.setCustomValidity("");
                    this.isIndividualZipCode = false
                    individualZipCode.reportValidity()
                }
                else{
                    individualZipCode.setCustomValidity(OWC_invalid_zipcode_msg);
                    this.isIndividualZipCode = true
                    individualZipCode.reportValidity()
                }                
            }
            else{
                this.isIndividualZipCode = false
            }

            const individualWebsite = this.template.querySelector('[data-id="individualWebsite"]');
            this.handleIndividualWebsiteFocus();
            this.handleIndividualLastNameFocus();
            this.isIndivudualWebsite === true ? individualWebsite.focus() : ''
            this.isIndividualLastName === true ? individualLastName.focus() : ''
            this.isindividualEmail === true ? individualEmail.focus() : ''
            this.isindividualCellPhone === true ? individualCellPhone.focus() : ''
            this.isIndividualBusinessPhone === true ? individualBusinessPhone.focus() : ''
            this.isIndividualZipCode === true ? individualZipCode.focus() : ''
            if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){
                if(this.individualFirstName === undefined ||
                    this.individualFirstName === null ||
                    this.individualFirstName === '' ||
                    this.individualStreetAddress === undefined ||
                    this.individualStreetAddress === null ||
                    this.individualStreetAddress === ''||
                    this.individualCity === undefined ||
                    this.individualCity === null ||
                    this.individualCity === ''||
                    this.individualState === undefined ||
                    this.individualState === null ||
                    this.individualState === ''||
                    this.individualZipCode === undefined ||
                    this.individualZipCode === null ||
                    this.individualZipCode === ''||
                    this.individualBusinessPhone === undefined ||
                    this.individualBusinessPhone === null ||
                    this.individualBusinessPhone === ''){
                    let individualFirstName = this.template.querySelector('[data-id="individualFirstName"]');
                    this.handleIndividualFirstNameFocus();
                    this.isIndividualFirstName === true ? individualFirstName.focus() : ''
                    let individualStreetAddress = this.template.querySelector('[data-id="individualStreetAddress"]');
                    this.handleindividualStreetAddressFocus();
                    this.isindividualStreetAddress === true ? individualStreetAddress.focus() : ''
                    let individualCity = this.template.querySelector('[data-id="individualCity"]');
                    this.handleindividualCityFocus();
                    this.isindividualCity === true ? individualCity.focus() : ''
                    let individualState = this.template.querySelector('[data-id="individualState"]');
                    this.handleindividualStateFocus();
                    this.isindividualState === true ? individualState.focus() : ''
                    let individualZipCode = this.template.querySelector('[data-id="individualZipCode"]');
                    this.handleIndividualZipCodeFocus();
                    this.isIndividualZipCode === true ? individualZipCode.focus() : ''
                    let individualBusinessPhone = this.template.querySelector('[data-id="individualBusinessPhone"]');
                    this.handleIndividualBusinessPhoneFocus();
                    this.isIndividualBusinessPhone === true ? individualBusinessPhone.focus() : ''
                }
                else{
                    this.isIndividualFirstName = false
                    this.isindividualStreetAddress = false
                    this.isindividualCity = false
                    this.isindividualState = false
                    //this.isIndividualZipCode = false
                    this.isIndividualBusinessPhone = false
                }
            }
            else{
                this.isIndividualFirstName = false
                this.isindividualStreetAddress = false
                this.isindividualCity = false
                this.isindividualState = false
                //this.isIndividualZipCode = false
                this.isIndividualBusinessPhone = false
            }
            if(this.isIndividualRequiredSet === true ||
                    this.isIndivudualWebsite === true ||
                    this.isIndividualBusinessPhone === true ||
                    this.isIndividualLastName === true ||
                    this.isindividualCellPhone === true ||
                    this.isindividualEmail === true ||
                    this.isIndividualFirstName === true ||
                    this.isindividualStreetAddress === true ||
                    this.isindividualCity === true ||
                    this.isadditionalTotalEmployees === true || 
                    this.isindividualState === true || this.isIndividualZipCode === true){
                const selectEvent = new CustomEvent('employernameafteremployementvakidityevent', {
                    detail: { 
                        currentStep : true
                    }
                });
                this.dispatchEvent(selectEvent);
                
            }
            else{
                this.handleEmployerNameChangedData();
            }
        }
        if(this.IsOtherIndividual === true){
            const OtherIndividualPhone = this.template.querySelector('[data-id="OtherIndividualPhone"');
            const OtherIndividualEmail = this.template.querySelector('[data-id="OtherIndividualEmail"');
            let OtherIndividualBusinessName = this.template.querySelector('[data-id="OtherIndividualBusinessName"]');
            let OtherIndividualBusinessNameValue = this.OtherIndividualBusinessName
            this.isOtherIndividualBusinessName = this.sectionValidityChecker(OtherIndividualBusinessName, OtherIndividualBusinessNameValue);
            
            const additionalTotalEmployees = this.template.querySelector('[data-id="additionalTotalEmployees"');
            this.handleadditionalTotalEmployeesFocus();
            this.isadditionalTotalEmployees === true ? additionalTotalEmployees.focus() : ''
            const OtherIndividualZipCode = this.template.querySelector('[data-id="OtherIndividualZipCode"]');
            if(OtherIndividualZipCode == undefined || OtherIndividualZipCode == null){
                this.isOtherIndividualZipCode = false
            }
            else if(OtherIndividualZipCode.value.trim() == null || OtherIndividualZipCode.value.trim() == undefined || OtherIndividualZipCode.value.trim() == ''){
                this.isOtherIndividualZipCode = false
                OtherIndividualZipCode.setCustomValidity('');
                OtherIndividualZipCode.reportValidity()
            }
            else if(OtherIndividualZipCode.value.trim() != null || OtherIndividualZipCode.value.trim() != undefined || OtherIndividualZipCode.value.trim() != ''){
                const OtherIndividualZipCode = this.template.querySelector('[data-id="OtherIndividualZipCode"]');
                if(OtherIndividualZipCode.value.match(this.zipCodeRegrex)){
                    OtherIndividualZipCode.setCustomValidity("");
                    this.isOtherIndividualZipCode = false
                    OtherIndividualZipCode.reportValidity()
                }
                else{
                    OtherIndividualZipCode.setCustomValidity(OWC_invalid_zipcode_msg);
                    this.isOtherIndividualZipCode = true
                    OtherIndividualZipCode.reportValidity()
                }                
            }
            else{
                this.isOtherIndividualZipCode = false
            }

            if(this.OtherIndividualPhone != undefined || this.OtherIndividualPhone != null || this.OtherIndividualPhone != ''){
                const OtherIndividualPhone = this.template.querySelector('[data-id="OtherIndividualPhone"');
                this.isOtherIndividualPhone = this.handlePhoneValidityChecker(OtherIndividualPhone);
            }
            else{
                this.isOtherIndividualPhone = false
            }

            if(this.OtherIndividualEmail != undefined || this.OtherIndividualEmail != null || this.OtherIndividualEmail != ''){
                const OtherIndividualEmail = this.template.querySelector('[data-id="OtherIndividualEmail"');
                this.isOtherIndividualEmail = this.handleEmailValidityChecker(OtherIndividualEmail);
            }
            else{
                this.isOtherIndividualEmail = false
            }

            const OtherIndividualWebsite = this.template.querySelector('[data-id="OtherIndividualWebsite"]');
            if(OtherIndividualWebsite == undefined || OtherIndividualWebsite == null){
                this.isOtherIndividualWebsite = false
            }
            else if(OtherIndividualWebsite.value.trim() == null || OtherIndividualWebsite.value.trim() == undefined || OtherIndividualWebsite.value.trim() == ''){
                this.isOtherIndividualWebsite = false
                OtherIndividualWebsite.setCustomValidity('');
                OtherIndividualWebsite.reportValidity()
            }
            else if(OtherIndividualWebsite.value.trim() != null || OtherIndividualWebsite.value.trim() != undefined || OtherIndividualWebsite.value.trim() != ''){
                const OtherIndividualWebsite = this.template.querySelector('[data-id="OtherIndividualWebsite"]');
                if(OtherIndividualWebsite.value.match(this.urlAddressChekerRegrex)){
                    OtherIndividualWebsite.setCustomValidity("");
                    this.isOtherIndividualWebsite = false
                    OtherIndividualWebsite.reportValidity()
                }
                else{
                    OtherIndividualWebsite.setCustomValidity(customLabelValues.OWC_urladdress_error_msg);
                    this.isOtherIndividualWebsite = true
                    OtherIndividualWebsite.reportValidity()
                }                
            }
            else{
                this.isOtherIndividualWebsite = false
            }
            this.isOtherIndividualEmail === true ? OtherIndividualEmail.focus() : ''
            this.isOtherIndividualPhone === true ? OtherIndividualPhone.focus() : ''
            this.isOtherIndividualZipCode === true ? OtherIndividualZipCode.focus() : ''
            this.isOtherIndividualBusinessName === true ? OtherIndividualBusinessName.focus() : ''
            this.isOtherIndividualWebsite === true ? OtherIndividualWebsite.focus() : ''
            if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){
                if(this.OtherIndividualStreetAddress === undefined ||
                    this.OtherIndividualStreetAddress === null ||
                    this.OtherIndividualStreetAddress === ''||
                    this.OtherIndividualCity === undefined ||
                    this.OtherIndividualCity === null ||
                    this.OtherIndividualCity === ''||
                    this.OtherIndividualState === undefined ||
                    this.OtherIndividualState === null ||
                    this.OtherIndividualState === ''||
                    this.OtherIndividualZipCode === undefined ||
                    this.OtherIndividualZipCode === null ||
                    this.OtherIndividualZipCode === ''||
                    this.OtherIndividualPhone === undefined ||
                    this.OtherIndividualPhone === null ||
                    this.OtherIndividualPhone === ''){
                    let OtherIndividualStreetAddress = this.template.querySelector('[data-id="OtherIndividualStreetAddress"]');
                    this.handleOtherIndividualStreetAddressFocus();
                    this.isOtherIndividualStreetAddress === true ? OtherIndividualStreetAddress.focus() : ''
                    let OtherIndividualCity = this.template.querySelector('[data-id="OtherIndividualCity"]');
                    this.handleOtherIndividualCityFocus();
                    this.isOtherIndividualCity === true ? OtherIndividualCity.focus() : ''
                    let OtherIndividualState = this.template.querySelector('[data-id="OtherIndividualState"]');
                    this.handleOtherIndividualStateFocus();
                    this.isOtherIndividualState === true ? OtherIndividualState.focus() : ''
                    let OtherIndividualZipCode = this.template.querySelector('[data-id="OtherIndividualZipCode"]');
                    this.handleOtherIndividualZipCodeFocus();
                    this.isOtherIndividualZipCode === true ? OtherIndividualZipCode.focus() : ''
                    let OtherIndividualPhone = this.template.querySelector('[data-id="OtherIndividualPhone"]');
                    this.handleOtherIndividualPhoneFocus();
                    this.isOtherIndividualPhone === true ? OtherIndividualPhone.focus() : ''
                }
                else{
                    this.isOtherIndividualStreetAddress = false
                    this.isOtherIndividualCity = false
                    this.isOtherIndividualState = false
                    //this.isOtherIndividualZipCode = false
                    this.isOtherIndividualPhone = false
                }
            }
            else{
                this.isOtherIndividualStreetAddress = false
                this.isOtherIndividualCity = false
                this.isOtherIndividualState = false
                //this.isOtherIndividualZipCode = false
                this.isOtherIndividualPhone = false
            }
            if(this.isOtherIndividualWebsite === true ||
                    this.isOtherIndividualBusinessName === true||
                    this.isOtherIndividualWebsite === true  ||
                    this.isOtherIndividualStreetAddress === true  ||
                    this.isOtherIndividualCity === true  ||
                    this.isOtherIndividualState === true  ||
                    this.isOtherIndividualZipCode === true ||
                    this.isOtherIndividualPhone === true ||
                    this.isOtherIndividualEmail === true){
                const selectEvent = new CustomEvent('employernameafteremployementvakidityevent', {
                    detail: { 
                        currentStep : true
                    }
                });
                this.dispatchEvent(selectEvent);
                
            }
            else{
                this.handleEmployerNameChangedData();
            }
        }
        if(this.IsOther === true){
            let otherPleaseExplain = this.template.querySelector('[data-id="otherPleaseExplain"]');
            let otherPleaseExplainValue = this.otherPleaseExplain
            this.isotherPleaseExplain = this.sectionValidityChecker(otherPleaseExplain, otherPleaseExplainValue);
            this.isotherPleaseExplain === true ? otherPleaseExplain.focus() : ''
            if(this.isotherPleaseExplain === true ){
                const selectEvent = new CustomEvent('employernameafteremployementvakidityevent', {
                    detail: { 
                        currentStep : true
                    }
                });
                this.dispatchEvent(selectEvent);
                
            }
            else{
                this.handleEmployerNameChangedData();
            }
        }
    }

    /* This method is used to send all fields values to its parent component */
    @api
    handleEmployerNameChangedData(){
        const selectEvent = new CustomEvent('employernameafteremployementevent', {
            detail : {
                additionalTotalEmployees : this.additionalTotalEmployees,
                IsIndividual : this.IsIndividual,
                isClaimantAdvocate : this.isClaimantAdvocate,
                isOtherIndividualPicklist : this.isOtherIndividualPicklist,
                isIndividualStatePicklist : this.isIndividualStatePicklist,
                IsOther : this.IsOther,
                representativeEmployerType : this.representativeEmployerType,
                otherPleaseExplain : this.otherPleaseExplain,
                showIndividualSole : this.showIndividualSole,
                individualFirstName : this.individualFirstName, 
                individualLastName : this.individualLastName,
                countryCodeOtherIndividualPhone : this.countryCodeOtherIndividualPhone,
                countryCodeindividualCellPhone : this.countryCodeindividualCellPhone,
                countryCodeindividualBusinessPhone : this.countryCodeindividualBusinessPhone,
                individualStreetAddress : this.individualStreetAddress,
                individualCity : this.individualCity,
                individualState : this.individualState,
                individualZipCode : this.individualZipCode,
                individualBusinessPhone : this.individualBusinessPhone,
                individualCellPhone : this.individualCellPhone,
                individualEmail : this.individualEmail,
                individualVehicleLicense : this.individualVehicleLicense,
                individualWebsite : this.individualWebsite,
                OtherIndividualBusinessName : this.OtherIndividualBusinessName,
                OtherIndividualStreetAddress : this.OtherIndividualStreetAddress,
                OtherIndividualCity : this.OtherIndividualCity, 
                OtherIndividualState : this.OtherIndividualState,
                OtherIndividualZipCode : this.OtherIndividualZipCode,
                OtherIndividualPhone : this.OtherIndividualPhone,
                OtherIndividualEmail : this.OtherIndividualEmail,
                OtherIndividualVehicleLicense : this.OtherIndividualVehicleLicense,
                OtherIndividualWebsite : this.OtherIndividualWebsite,
                OtherIndividualConstructionTrades : this.OtherIndividualConstructionTrades,
                IsOtherIndividual : this.IsOtherIndividual,
                IsIndividual : this.IsIndividual,
                specifyOtherReason : this.specifyOtherReason,
                empName : this.empName,
                isDontKnow : this.isDontKnow,
                isUSPSAddressInvalid : this.isUSPSAddressInvalid,
            isUPSPAddressValid : this.isUPSPAddressValid,
            uspsCurrentAddressCheck : this.uspsCurrentAddressCheck,
            isUSPSAddressErrorTemplate : this.isUSPSAddressErrorTemplate,
            isUSPSAddressSuccessTemplate : this.isUSPSAddressSuccessTemplate,
            uspsAddress : this.uspsAddress,
            isUSPSAddressCheck : this.isUSPSAddressCheck,
            uspsProceedAddress : this.uspsProceedAddress,
            IndividualFirstNamerequired : this.IndividualFirstNamerequired,
            IndividualStreetAddressrequired : this.IndividualStreetAddressrequired,
            IndividualCityrequired : this.IndividualCityrequired,
            IndividualStaterequired : this.IndividualStaterequired,
            IndividualZipCoderequired : this.IndividualZipCoderequired,
            IndividualBusinessPhonerequired : this.IndividualBusinessPhonerequired,
            OtherStreetAddressrequired : this.OtherStreetAddressrequired,
            OtherCityrequired : this.OtherCityrequired,
            OtherStaterequired : this.OtherStaterequired,
            OtherZipCoderequired : this.OtherZipCoderequired,
            OtherBusinessPhonerequired : this.OtherBusinessPhonerequired,
            }
        });
        this.dispatchEvent(selectEvent);
    }

    /* This method is used to retrieve values when user move from one component to another. */
    @api
    handleEmployerNameAfterEmployementChild(strString,isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode
    this.empBusinessTypeDetails = strString

    if(this.empBusinessTypeDetails.IsIndividual === true && this.empBusinessTypeDetails.isClaimantAdvocate === true){
        this.isNotClaimantGarment = true
    }
    if(isNaN(strString.representativeEmployerType)){
        this.template.querySelector('[data-id="employer_Business_Type"]').value = strString.representativeEmployerType
        this.representativeEmployerType = strString.representativeEmployerType
    }
    this.specifyOtherReason = strString.specifyOtherReason
    this.isOtherIndividualPicklist = strString.isOtherIndividualPicklist
    this.isIndividualStatePicklist = strString.isIndividualStatePicklist
    this.otherPleaseExplain = strString.otherPleaseExplain
    this.countryCodeOtherIndividualPhone = strString.countryCodeOtherIndividualPhone
    this.countryCodeindividualCellPhone = strString.countryCodeindividualCellPhone
    this.countryCodeindividualBusinessPhone = strString.countryCodeindividualBusinessPhone
    this.empName = strString.empName
    this.isDontKnow = strString.isDontKnow
    this.individualFirstName = strString.individualFirstName
    this.individualLastName = strString.individualLastName
    this.individualStreetAddress = strString.individualStreetAddress
    this.individualCity = strString.individualCity
    this.IsOther = strString.IsOther
    this.showIndividualSole = strString.showIndividualSole
    this.individualState = strString.individualState
    this.individualZipCode = strString.individualZipCode
    this.individualBusinessPhone = strString.individualBusinessPhone
    this.individualCellPhone = strString.individualCellPhone
    this.individualEmail = strString.individualEmail
    this.individualVehicleLicense = strString.individualVehicleLicense
    this.individualWebsite = strString.individualWebsite
    this.OtherIndividualBusinessName = strString.OtherIndividualBusinessName
    this.OtherIndividualStreetAddress = strString.OtherIndividualStreetAddress
    this.OtherIndividualCity = strString.OtherIndividualCity
    this.OtherIndividualState = strString.OtherIndividualState
    this.OtherIndividualZipCode = strString.OtherIndividualZipCode
    this.OtherIndividualPhone = strString.OtherIndividualPhone
    this.OtherIndividualEmail = strString.OtherIndividualEmail
    this.OtherIndividualVehicleLicense = strString.OtherIndividualVehicleLicense
    this.OtherIndividualWebsite = strString.OtherIndividualWebsite
    this.OtherIndividualConstructionTrades = strString.OtherIndividualConstructionTrades
    this.IsIndividual = strString.IsIndividual
    this.specifyOtherReason = strString.specifyOtherReason,
    this.IsOtherIndividual = strString.IsOtherIndividual
    this.startingDate = strString.startingDate
    this.endingDate = strString.endingDate
    this.isUSPSAddressInvalid = strString.isUSPSAddressInvalid
    this.isUPSPAddressValid = strString.isUPSPAddressValid
    this.uspsCurrentAddressCheck = strString.uspsCurrentAddressCheck
    this.isUSPSAddressErrorTemplate = strString.isUSPSAddressErrorTemplate
    this.isUSPSAddressSuccessTemplate = strString.isUSPSAddressSuccessTemplate
    this.uspsAddress = strString.uspsAddress
    this.isUSPSAddressCheck = strString.isUSPSAddressCheck
    this.uspsProceedAddress = strString.uspsProceedAddress
    this.IndividualFirstNamerequired = strString.IndividualFirstNamerequired
    this.IndividualStreetAddressrequired = strString.IndividualStreetAddressrequired
    this.IndividualCityrequired = strString.IndividualCityrequired
    this.IndividualStaterequired = strString.IndividualStaterequired
    this.IndividualZipCoderequired = strString.IndividualZipCoderequired
    this.IndividualBusinessPhonerequired = strString.IndividualBusinessPhonerequired
    this.OtherStreetAddressrequired = strString.OtherStreetAddressrequired
    this.OtherCityrequired = strString.OtherCityrequired
    this.OtherStaterequired = strString.OtherStaterequired
    this.OtherZipCoderequired = strString.OtherZipCoderequired
    this.OtherBusinessPhonerequired = strString.OtherBusinessPhonerequired
    this.additionalTotalEmployees = strString.additionalTotalEmployees
    this.isRenderedCallback = true
    }

    /* This method is used to set the picklist, radio group button values after component rendered. */
    renderedCallback(){
        if(this.isclaimantgarment === true && this.isRenderedPicklist === false){
            this.isRenderPicklist = true;
            const employerBusinessTypeList = JSON.parse(JSON.stringify(this.Employer_Business_Type_List))
            employerBusinessTypeList.splice(1,1)
            this.employerBusinessTypeList = employerBusinessTypeList
            console.log('cehck ::: ', JSON.stringify(employerBusinessTypeList))
            this.isClaimantAdvocate = false
            this.isRenderedPicklist = true
        }
        if(this.isRenderedCallback === true && this.isClaimantAdvocate === false && this.isRenderIndividualState === false){
            this.template.querySelector('[data-id="individualState"]').value = this.individualState
        }
        if(this.isRenderedCallback === true && this.OtherIndividualState != undefined && this.isOtherIndividualPicklist === true){
            this.template.querySelector('[data-id="OtherIndividualState"]').value = this.OtherIndividualState
        }
        if(this.isRenderedCallback === true && this.uspsCurrentAddressCheck === true && ((this.IsIndividual === true && this.isClaimantAdvocate === true) || this.IsOtherIndividual === true)){
            this.template.querySelector('[data-id="uspsCurrentAddressCheck"]').checked = 'Yes'
        }
        if(this.isRenderedCallback === true && this.uspsProceedAddress === true && ((this.IsIndividual === true && this.isClaimantAdvocate === true) || this.IsOtherIndividual === true)){
            this.template.querySelector('[data-id="uspsProceedAddress"]').checked = 'Yes'
        }
    }

    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === "ConstructionTradesHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_ContractionTrade_Helptext;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === "MultiFileUploadHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_UploadDocument_Helptext;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        }
        else if(learnMoreName === "AddImageHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_AddImage_HelpText;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === "additionalName"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_EnterName_HelpText;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === "bestGuess"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_BestGuess_HelpText;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === 'multiFileUploadHelpText1'){
            this.isHelpText = true;
            this.helpText = OWC_multiplefileupload_helptext;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === "coversheetDocumentHelpText"){
            this.isHelpText = true;
            this.helpText = OWC_preliminary_coversheet_helptext;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        }
    }
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        console.log('helpTextValue:', JSON.stringify(helpTextValue));
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    // Validation check on fields focus
    handleOtherBusinessReasonFocus(){
        let otherPleaseExplain = this.template.querySelector('[data-id="otherPleaseExplain"]');
        if(otherPleaseExplain.value == null || otherPleaseExplain.value == undefined || otherPleaseExplain.value.trim() == ''){
            otherPleaseExplain.setCustomValidity(OWC_required_field_error_msg);
        }
        else{
            otherPleaseExplain.setCustomValidity('')
        }
        otherPleaseExplain.reportValidity();
    }

    handleEmpNameDontKnowFocus(){
        let empName = this.template.querySelector('[data-id="empName"]');
        if(empName.value == null || empName.value == undefined || empName.value.trim() == ''){
            empName.setCustomValidity(OWC_required_field_error_msg);
        }
        else{
            empName.setCustomValidity('')
        }
        empName.reportValidity();
    }

    handleIndividualLastNameFocus(){
        let individualLastName = this.template.querySelector('[data-id="individualLastName"]');
        if(individualLastName.value == null || individualLastName.value == undefined || individualLastName.value.trim() == ''){
            individualLastName.setCustomValidity(OWC_required_field_error_msg);
            this.isIndividualLastName = true;
        }
        else{
            individualLastName.setCustomValidity('')
            this.isIndividualLastName = false;
        }
        individualLastName.reportValidity();
    }

    handleIndividualCellPhoneFocus(){
        const individualCellPhone = this.template.querySelector('[data-id="individualCellPhone"');
        if(individualCellPhone.value === undefined || individualCellPhone.value === null || individualCellPhone.value.trim() === ''){
            individualCellPhone.setCustomValidity('')
        }
        else if(individualCellPhone.value.match(this.regExpPhone)){
            individualCellPhone.setCustomValidity('')
        }
        else{
            individualCellPhone.setCustomValidity(OWC_invalid_phone_msg)
        }
        individualCellPhone.reportValidity()
    }

    handleIndividualEmailFocus(){
        const individualEmail = this.template.querySelector('[data-id="individualEmail"');
        if(individualEmail.value === undefined || individualEmail.value === null || individualEmail.value.trim() === ''){
            individualEmail.setCustomValidity('')
        }
        else if(individualEmail.value.match(this.regExpEmailformat)){
            individualEmail.setCustomValidity('')
        }
        else{
            individualEmail.setCustomValidity(OWC_invalid_email_msg)
        }
        individualEmail.reportValidity()
    }
    
    handleIndividualWebsiteFocus(){
        const individualWebsite = this.template.querySelector('[data-id="individualWebsite"');
        if(individualWebsite.value === undefined || individualWebsite.value === null || individualWebsite.value.trim() === ''){
            individualWebsite.setCustomValidity('')
            individualWebsite.reportValidity()
            this.isIndivudualWebsite = false
        }
        else if(individualWebsite.value.match(this.urlAddressChekerRegrex)){
            individualWebsite.setCustomValidity('')
            individualWebsite.reportValidity()
            this.isIndivudualWebsite = false
        }
        else{
            individualWebsite.setCustomValidity(this.customLabelValues.OWC_urladdress_error_msg)
            individualWebsite.reportValidity()
            this.isIndivudualWebsite = true;
        }
    }
    handleOtherIndividualBusinessNameFocus(){
        let OtherIndividualBusinessName = this.template.querySelector('[data-id="OtherIndividualBusinessName"]');          
        if(OtherIndividualBusinessName.value == undefined || OtherIndividualBusinessName.value == null || OtherIndividualBusinessName.value.trim() == ''){
            this.isMultipleRequiredCheck = true
            OtherIndividualBusinessName.setCustomValidity(OWC_required_field_error_msg);
        }
        else{
            this.isMultipleRequiredCheck = false
            OtherIndividualBusinessName.setCustomValidity("");
        }
        OtherIndividualBusinessName.reportValidity();
    }
    handleOtherIndividualPhoneFocus(){
        const OtherIndividualPhone = this.template.querySelector('[data-id="OtherIndividualPhone"');
        if(OtherIndividualPhone.value === undefined || OtherIndividualPhone.value === null || OtherIndividualPhone.value.trim() === ''){
            OtherIndividualPhone.setCustomValidity('')
        }
        else if(OtherIndividualPhone.value.match(this.regExpPhone)){
            OtherIndividualPhone.setCustomValidity('')
        }
        else{
            OtherIndividualPhone.setCustomValidity(OWC_invalid_phone_msg)
        }
        OtherIndividualPhone.reportValidity()
    }
    handleOtherIndividualEmail(){
        const OtherIndividualEmail = this.template.querySelector('[data-id="OtherIndividualEmail"');
        if(OtherIndividualEmail.value === undefined || OtherIndividualEmail.value === null || OtherIndividualEmail.value.trim() === ''){
            OtherIndividualEmail.setCustomValidity('')
        }
        else if(OtherIndividualEmail.value.match(this.regExpEmailformat)){
            OtherIndividualEmail.setCustomValidity('')
        }
        else{
            OtherIndividualEmail.setCustomValidity(OWC_invalid_email_msg)
        }
        OtherIndividualEmail.reportValidity()
    }
    handleOtherIndividualWebsiteFocus(){
        const OtherIndividualWebsite = this.template.querySelector('[data-id="OtherIndividualWebsite"');
        if(OtherIndividualWebsite.value === undefined || OtherIndividualWebsite.value === null || OtherIndividualWebsite.value.trim() === ''){
            OtherIndividualWebsite.setCustomValidity('')
        }
        else if(OtherIndividualWebsite.value.match(this.urlregex)){
            OtherIndividualWebsite.setCustomValidity('')
        }
        else{
            OtherIndividualWebsite.setCustomValidity(OWC_invalid_url_msg)
        }
        OtherIndividualWebsite.reportValidity()

    }
}