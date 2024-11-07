import { LightningElement, api, track, wire } from 'lwc';
import { radioOptions, customLabelValues,acceptedFileFormat } from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'  
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import getCurrentUserDetails from '@salesforce/apex/OWCClaimantEmployeeInfoController.getCurrentUserDetails';
import deleteMultipleFiles from '@salesforce/apex/OWCMultipleFileDeleteController.deleteMultipleFiles';
//import insertUploadedFiles from '@salesforce/apex/OWCMultipleFileUploadController.insertUploadedFiles';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { getRecord } from 'lightning/uiRecordApi';
const MAX_FILE_SIZE = 25000000;  ///20MB in Bytes
const CHUNK_SIZE = 750000;
let fileSize=0;

export default class OwcPreliminaryGarmentSectionCmp extends LightningElement {
    
    error;
    stack;
    errorCallback(error, stack) {
        this.error = error;
    }
    showLoadingSpinner = false;
    @track fileNames = '';
    @track filesUploaded = [];

    @api encryptedToken = 'OWC Form';
    @api countryCodeValue
    @api countryCodeindividualRepPhone
    @api countryCodelawfirmRepStatePhone
    @api isFormPreviewMode = false
    
    // @api toastFileUploadMsg = customLabelValues.OWC_fileupload_success_toast_msg
    // @api toastFileDeleteMsg = customLabelValues.OWC_multiple_file_delete_toast_msg
    isRenderedCallback = false
    @api claimantDetails

    @api claimantConfirmUploadDoc = []
    @api isClaimantConfirmUpload = false;
    @api claimantConfirmDocSize = ''
    // @api uploadFileSize
    @track submitWageClaimPicklistData
    @track covid19ClaimPicklistData
    @track repAdvocateTypePicklistValue
    @track individualRepPhoneTypePicklistValue
    @track individualRepClaimantRelationshipPicklist
    @track preliminaryCovidClaimPicklistData
    @track isMultipleRequiredCheck = false
    @api isIndividualStatePicklist = false
    @api isLawFirmStatePicklist = false
    @api isOrganizationStatePicklist = false

    @track ValidationMsg
    // @track uploadUnionContractDocument
    // @api isCoverSheetDocRequired = false
    // @api isFileUploaded = false

    // HelpText Attributes
    @api isHelpText = false
    @api helpText
    // Preliminary Section Attributes
    @api isYourself = false
    // @api isUnionContractCovered
    @api isEmployeeFilingWageClaim
    @api isRepresentative
    @api isEmployeeFilingWageClaimOther
    @api WageClaimSubmit
    // // @api unionContractCovering
    // @api coversheetDocument
    // @api filingWageClaim
    @api specifyFilingWageClaim
    // @api isFilingWageClaim
    // @api covid19Claim
    // @api specifyOtherReason

    // Claimant/Employee Section Attributes
    @api yourselfFirstName
    @api yourselfLastName
    @api yourselfMiddleName
    @api yourselfHomePhone
    @api yourselfCellPhone
    @api isCellPhoneEntered
    @api yourselfBirthDate
    @api yourselfEmail
    @api yourselfStreetAddress
    @api yourselfCity
    @api yourselfState
    @api yourselfZipCode
    isAttributeRequired = true
    @track isYourselfAdvocate = true;

    // Representative Section Attributes
    @api representativeAdvocateType
    @api isIndividualRepresentation = false
    @api isLawFirmRepresentation = false
    @api isOrganizationRepresentation = false

    // Individual Representative Section Attributes
    @api individualRepFirstName
    @api individualRepLastName
    @api individualRepZipCode
    @api individualRepStreetAddress
    @api individualRepCity
    @api individualRepState
    @api individualRepEmail
    @api individualRepWebsite
    @api individualRepPhone
    @api individualRepPhoneType
    @api individualRepClaimantRelationship
    

    // Law Firm Representative Section Attributes
    @api lawfirmRepBusinessName
    @api lawfirmRepAttorney
    @api lawfirmRepStreetAddress
    @api lawfirmRepCity
    @api lawfirmRepState
    @api lawfirmRepStatePhone
    @api lawfirmRepEmail
    @api lawfirmRepWebsite
    @api lawFirmRepZipCode

    // Organization Representative Section Attributes
    @api organizationRepBusinessName
    @api organizationRepAttorney
    @api organizationRepStreetAddress
    @api organizationRepCity
    @api organizationRepState
    @api organizationRepPhone
    @api organizationRepEmail
    @api organizationRepWebsite
    @api organizationRepZipCode

    // Language Interpreter Section Attributes
    @api isPrefferedLanguage = false
    @api isOtherPrefferedLanguage = false
    @api needLanguageInterpreter
    @api prefferedLanguageSelection
    @api otherPrefferedLanguage
    @api getPicklistValues = []
    @api statusOptions
    @api advocateAssitance
    @api isAdvocateAssist = false

    // USPS Address attributes
    // USPS Address attributes
    @api uspsCurrentAddressCheck = false
    @api isUSPSAddressErrorTemplate = false;
    @api isUSPSAddressSuccessTemplate = false;
    @api uspsAddress
    @api isUSPSAddressCheck = false;
    @api selectedAddressIndex
    @api succesWithCurrentAddress = false
    @api isChecked = false
    @api isUpspProceedAddress = false
    @api isUspsCurrentAddress = false
    @api isUSPSAddressInvalid = false;
    @api isUPSPAddressValid = false;
    @api addressJson
    @api uspsProceedAddress
    @api uspsAddressJSONList = []
    NotProceed = false;
    @api isUSPSNotMatched = false;
    @api isButtonResetable = false
    @api isErrorFocus = false;
    @api isSuccessFocus = false;
    @api isLoading = false;

    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

@api isClaimantConfirmation = false
    @api isLoaded = false;

    resetIndividualRepAdvocateTemplate(){
        this.individualRepFirstName = ''
        this.individualRepLastName = ''
        this.individualRepZipCode = ''
        this.individualRepStreetAddress = ''
        this.individualRepCity = ''
        this.individualRepState = ''
        this.individualRepEmail = ''
        this.individualRepWebsite = ''
        this.individualRepPhone = ''
        this.individualRepPhoneType = ''
        this.individualRepClaimantRelationship = ''
    }

    resetLawFirmRepAdvocateTemplate(){
        this.lawfirmRepBusinessName = ''
        this.lawfirmRepAttorney = ''
        this.lawfirmRepStreetAddress = ''
        this.lawfirmRepCity = ''
        this.lawfirmRepState = ''
        this.lawfirmRepStatePhone = ''
        this.lawfirmRepEmail = ''
        this.lawfirmRepWebsite = ''
        this.lawFirmRepZipCode = ''
    }

    resetOrganizationRepAdvocateTemplate(){
        this.organizationRepBusinessName = ''
        this.organizationRepAttorney = ''
        this.organizationRepStreetAddress = ''
        this.organizationRepCity = ''
        this.organizationRepState = ''
        this.organizationRepPhone = ''
        this.organizationRepEmail = ''
        this.organizationRepWebsite = ''
        this.organizationRepZipCode = ''
    }



    customLabelValues = customLabelValues
    options = radioOptions

    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === "yourselfCellPhoneHelpText"){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_claimant_employee_cellphone_helptext;
        }
        else if(learnMoreName === "yourselfEmailHelpText"){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_claimant_employee_email_helptext;
        }
        else if(learnMoreName === "representativeAdvocateTypeHelpText"){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_representative_advocatetype_helptext;
        }
        else if(learnMoreName === "multiFileUploadHelpText"){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_multiplefileupload_helptext;
        }
        else if(learnMoreName === "coversheetDocumentHelpText"){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_preliminary_coversheet_helptext;
        }
        else if(learnMoreName === 'yourselfZipCodeHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_yourself_zipcode_helptext;
        }
        else if(learnMoreName === 'submittedWageClaim'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_yourself_submit_label;
        }
    }

    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    getIndividualClaimantInfo(){
        getCurrentUserDetails({})
    .then(result => {
        if(result){
            if(this.WageClaimSubmit === 'Representative' && this.isIndividualRepresentation === true){
            //  this.individualRepFirstName === null || this.individualRepFirstName === undefined || this.individualRepFirstName === '' ? this.individualRepFirstName = result.firstName : this.individualRepFirstName = this.individualRepFirstName;
            //  this.individualRepLastName === null || this.individualRepLastName === undefined || this.individualRepLastName === '' ? this.individualRepLastName = result.lastName : this.individualRepLastName = this.individualRepLastName;
            //  this.individualRepStreetAddress === null || this.individualRepStreetAddress === undefined || this.individualRepStreetAddress === '' ? this.individualRepStreetAddress = result.streetAddress : this.individualRepStreetAddress = this.individualRepStreetAddress;
            //  this.individualRepCity === null || this.individualRepCity === undefined || this.individualRepCity === '' ? this.individualRepCity = result.city : this.individualRepCity = this.individualRepCity;
            //  this.individualRepState === null || this.individualRepState === undefined || this.individualRepState === '' ? result.state == null ? this.individualRepState = 'CA' : this.individualRepState = result.state : this.individualRepState = this.individualRepState;
            //  this.individualRepZipCode === null || this.individualRepZipCode === undefined || this.individualRepZipCode === '' ? this.individualRepZipCode = result.zipCode : this.individualRepZipCode = this.individualRepZipCode;
            //  this.individualRepPhone === null || this.individualRepPhone === undefined || this.individualRepPhone === '' ? this.individualRepPhone = result.phone : this.individualRepPhone = this.individualRepPhone;
            //  this.individualRepEmail === null || this.individualRepEmail === undefined || this.individualRepEmail === '' ? this.individualRepEmail = result.email : this.individualRepEmail = this.individualRepEmail;
            //  this.individualRepWebsite === null || this.individualRepWebsite === undefined || this.individualRepWebsite === '' ? this.individualRepWebsite = result.website : this.individualRepWebsite = this.individualRepWebsite;
         }
        }
    })
    .catch(error => {
    })
    }
    
    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data, error }){
        if(data){
            this.statePicklistValues = data[0].statePicklist;
            this.submitWageClaimPicklistData = data[0].wageClaimSubmitYourselfOrBehalf;
            this.preliminaryCovidClaimPicklistData = data[0].preliminaryCovidClaimValues;
            this.repAdvocateTypePicklistValue = data[0].representativeAdvocateType;
            this.individualRepPhoneTypePicklistValue = data[0].individualRepresentativePhoneType;
            this.covid19ClaimPicklistData = data[0].covid19WageClaim;
            this.individualRepClaimantRelationshipPicklist = data[0].individualRepresentativeClaimantRelationShip;
            this.prefferedLanguageSelectionData = data[0].languageAssitantPrefferedLanguages;
            this.statusOptions = data[0].owcYesOrNoPicklistOption;
            this.countryCodeValue = data[0].owcCountryCodeList;
            this.countryCodeindividualRepPhone = '+1';
            this.countryCodelawfirmRepStatePhone = '+1';
            // this.template.querySelector('[data-id="yourselfState"]').value = 'CA';
        }
        else if(error){
            this.error = error;
        }
    }

    connectedCallback(){
        
        // don’t forget to load static resources in connectedCallback . 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
        })
        .catch(error => {
    });
    }

    resetClaimantEmployeeTemplate(){
    this.yourselfFirstName = ''
    this.yourselfLastName = ''
    this.yourselfMiddleName = ''
    this.yourselfHomePhone = ''
    this.yourselfCellPhone = ''
    this.isCellPhoneEntered = ''
    this.yourselfBirthDate = ''
    this.yourselfEmail = ''
    this.yourselfStreetAddress = ''
    this.yourselfCity = ''
    this.yourselfState = ''
    this.yourselfZipCode = ''
    }

    
    handleRepresentativeAdvocateType(){
        let representativeAdvocateType = this.template.querySelector('[data-id="representativeAdvocateType"]');
                if(representativeAdvocateType.value === undefined || representativeAdvocateType.value === null || representativeAdvocateType.value === ''){
                    representativeAdvocateType.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                    this.isNotRepresentativeAdvocateType = true;
                }
                else{
                    representativeAdvocateType.setCustomValidity("");
                    this.isNotRepresentativeAdvocateType = false;
                }
                representativeAdvocateType.reportValidity();
    }

    handleIndividualWebsiteFocus(){
        const individualRepWebsite = this.template.querySelector('[data-id="individualRepWebsite"');
        if(individualRepWebsite.value === undefined || individualRepWebsite.value === null || individualRepWebsite.value.trim() === ''){
            individualRepWebsite.setCustomValidity('')
            individualRepWebsite.reportValidity()
            return false;
        }
        else if(individualRepWebsite.value.match(this.urlAddressChekerRegrex)){
            individualRepWebsite.setCustomValidity('')
            individualRepWebsite.reportValidity()
            return false;
        }
        else{
            individualRepWebsite.setCustomValidity(customLabelValues.OWC_urladdress_error_msg)
            individualRepWebsite.reportValidity()
            return true;
        }
    }

    handleUrlAddressFocus(event){
        const urlAddress = this.template.querySelector('[data-id="urlAddress"');
        if(urlAddress.value === undefined || urlAddress.value === null || urlAddress.value.trim() === ''){
            urlAddress.setCustomValidity('')
        }
        else if(urlAddress.value.match(this.urlAddressChekerRegrex)){
            urlAddress.setCustomValidity('')
        }
        else{
            urlAddress.setCustomValidity(customLabelValues.OWC_urladdress_error_msg)
        }
        urlAddress.reportValidity()
    }

    handleIndividualFirstNameFocus(event){
        let individualRepFirstName = this.template.querySelector('[data-id="individualRepFirstName"]');
                if(individualRepFirstName.value.trim() == undefined || individualRepFirstName.value.trim() == null || individualRepFirstName.value.trim() == ''){
                    individualRepFirstName.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    individualRepFirstName.setCustomValidity("");
                }
                individualRepFirstName.reportValidity();
    }

    handleIndividualLastNameFocus(event){
        let individualRepLastName = this.template.querySelector('[data-id="individualRepLastName"]');
                if(individualRepLastName.value.trim() == undefined || individualRepLastName.value.trim() == null || individualRepLastName.value.trim() == ''){
                    individualRepLastName.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    individualRepLastName.setCustomValidity("");
                }
                individualRepLastName.reportValidity();
    }

    handleLawFirmBusinessNameFocus(event){
        let lawfirmRepBusinessName = this.template.querySelector('[data-id="lawfirmRepBusinessName"]');
        if(lawfirmRepBusinessName.value === null || lawfirmRepBusinessName.value === undefined || lawfirmRepBusinessName.value === ''){
            lawfirmRepBusinessName.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
        }
        else{
            lawfirmRepBusinessName.setCustomValidity('');
        }
        lawfirmRepBusinessName.reportValidity();
    }

    handleAttorneyNameFocus(event){
        const lawfirmRepAttorney = this.template.querySelector('[data-id="lawfirmRepAttorney"]');
        if(lawfirmRepAttorney.value === null || lawfirmRepAttorney.value === undefined || lawfirmRepAttorney.value === ''){
            lawfirmRepAttorney.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
        }
        else{
            lawfirmRepAttorney.setCustomValidity('');
        }
        lawfirmRepAttorney.reportValidity();
    }

    handleLawFirmRepStateFocus(event){
        const lawfirmRepStatePhone = event.target.value
        if(lawfirmRepStatePhone.trim() != null || lawfirmRepStatePhone.trim() != undefined || lawfirmRepStatePhone.trim() != ''){
            this.isMultipleRequiredCheck = false
            this.ValidationMsg = customLabelValues.OWC_lawfirm_representative_requiredmsg
        }
        else{
            this.isMultipleRequiredCheck = true
        }
    }

    handleLawFirmWebsiteFocus(){
        const lawfirmRepWebsite = this.template.querySelector('[data-id="lawfirmRepWebsite"');
        if(lawfirmRepWebsite.value === undefined || lawfirmRepWebsite.value === null || lawfirmRepWebsite.value.trim() === ''){
            lawfirmRepWebsite.setCustomValidity('')
            lawfirmRepWebsite.reportValidity()
            return false;
        }
        else if(lawfirmRepWebsite.value.match(this.urlAddressChekerRegrex)){
            lawfirmRepWebsite.setCustomValidity('')
            lawfirmRepWebsite.reportValidity()
            return false;
        }
        else{
            lawfirmRepWebsite.setCustomValidity(customLabelValues.OWC_urladdress_error_msg)
            lawfirmRepWebsite.reportValidity()
            return true;
        }
    }

    handleLawFirmRepEmailFocus(event){
        const lawfirmRepEmail = this.template.querySelector('[data-id="lawfirmRepEmail"]');
        if(lawfirmRepEmail.value.trim() != null || lawfirmRepEmail.value.trim() != undefined || lawfirmRepEmail.value.trim() != ''){
            if(lawfirmRepEmail.value != '' && lawfirmRepEmail.value.match(this.regExpEmailformat)){
                let lawfirmRepEmail = this.template.querySelector('[data-id="lawfirmRepEmail"]');
                lawfirmRepEmail.setCustomValidity('');
                lawfirmRepEmail.reportValidity();
            }
            else{
                let lawfirmRepEmail = this.template.querySelector('[data-id="lawfirmRepEmail"]');
                this.islawfirmRepEmailValid = true
                lawfirmRepEmail.setCustomValidity(customLabelValues.OWC_invalid_email_msg)
                lawfirmRepEmail.reportValidity();
            }
        }
        else{
            this.isMultipleRequiredCheck = true
        }
    }

    handleOrganizationRepBusinessFocus(event){
        const organizationRepBusinessName = event.target.value
        if(organizationRepBusinessName.trim() != null || organizationRepBusinessName.trim() != undefined || organizationRepBusinessName.trim() != ''){
            this.isMultipleRequiredCheck = false
            this.ValidationMsg = customLabelValues.OWC_lawfirm_representative_requiredmsg
        }
        else{
            this.isMultipleRequiredCheck = true
        }
    }

    handleOrganizationRepAttorneyFocus(event){
        const organizationRepAttorney = event.target.value
        if(organizationRepAttorney.trim() != null || organizationRepAttorney.trim() != undefined || organizationRepAttorney.trim() != ''){
            this.isMultipleRequiredCheck = false
            this.ValidationMsg = customLabelValues.OWC_lawfirm_representative_requiredmsg
        }
        else{
            this.isMultipleRequiredCheck = true
        }
    }

    handleOrganizationRepPhoneFocus(event){
        const organizationRepPhone = event.target.value
        if(organizationRepPhone.trim() != null || organizationRepPhone.trim() != undefined || organizationRepPhone.trim() != ''){
            this.isMultipleRequiredCheck = false
            this.ValidationMsg = customLabelValues.OWC_lawfirm_representative_requiredmsg
        }
        else{
            this.isMultipleRequiredCheck = true
        }
    }

    handleOrganizationRepEmailFocus(event){
        const organizationRepEmail = event.target.value
        if(organizationRepEmail.trim() != null || organizationRepEmail.trim() != undefined || organizationRepEmail.trim() != ''){
            if(this.organizationRepEmail != '' && this.organizationRepEmail.match(this.regExpEmailformat)){
                let organizationRepEmail = this.template.querySelector('[data-id="organizationRepEmail"]');
                organizationRepEmail.setCustomValidity('');
                organizationRepEmail.reportValidity();
            }
            else{
                let organizationRepEmail = this.template.querySelector('[data-id="organizationRepEmail"]');
                this.isorganizationRepEmailValid = true
                organizationRepEmail.setCustomValidity(customLabelValues.OWC_invalid_email_msg)
                organizationRepEmail.reportValidity();
            }
        }
        else{
            this.isMultipleRequiredCheck = true
        }
    }

    handleOrganizationRepStreetAddressFocus(event){
        let organizationRepStreetAddress = this.template.querySelector('[data-id="organizationRepStreetAddress"]');
                if(organizationRepStreetAddress.value.trim() == undefined || organizationRepStreetAddress.value.trim() == null || organizationRepStreetAddress.value.trim() == ''){
                    organizationRepStreetAddress.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    organizationRepStreetAddress.setCustomValidity("");
                }
                organizationRepStreetAddress.reportValidity();
    }

    handleOrganizationRepCityFocus(event){
        let organizationRepCity = this.template.querySelector('[data-id="organizationRepCity"]');
                if(organizationRepCity.value.trim() == undefined || organizationRepCity.value.trim() == null || organizationRepCity.value.trim() == ''){
                    organizationRepCity.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    organizationRepCity.setCustomValidity("");
                }
                organizationRepCity.reportValidity();
    }

    handleOrganizationRepStateFocus(event){
        let organizationRepState = this.template.querySelector('[data-id="organizationRepState"]');
                if(organizationRepState.value.trim() == undefined || organizationRepState.value.trim() == null || organizationRepState.value.trim() == ''){
                    organizationRepState.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    organizationRepState.setCustomValidity("");
                }
                organizationRepState.reportValidity();
    }

    handleOrganizationRepZipCodeFocus(event){
        const organizationRepZipCode = this.template.querySelector('[data-id="organizationRepZipCode"');
        if(organizationRepZipCode.value === undefined || organizationRepZipCode.value === null || organizationRepZipCode.value.trim() === ''){
            organizationRepZipCode.setCustomValidity('')
        }
        else if(organizationRepZipCode.value.match(this.zipCodeRegrex)){
            organizationRepZipCode.setCustomValidity('')
        }
        else{
            organizationRepZipCode.setCustomValidity(customLabelValues.OWC_invalid_zipcode_msg)
        }
        organizationRepZipCode.reportValidity()
    }

    // handleOtherReasonFocus(event){
    //     let specifyOtherReason = this.template.querySelector('[data-id="specifyOtherReason"]');
    //             if(specifyOtherReason.value.trim() == undefined || specifyOtherReason.value.trim() == null || specifyOtherReason.value.trim() == ''){
    //                 specifyOtherReason.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
    //             }
    //             else{
    //                 specifyOtherReason.setCustomValidity("");
    //             }
    //             specifyOtherReason.reportValidity();
    // }

    handleSubmitWageClaimPicklistFocus(event){
        let submitWageClaim = this.template.querySelector('[data-id="submitWageClaim"]');
                if(submitWageClaim.value === undefined || submitWageClaim.value === null || submitWageClaim.value === ''){
                    submitWageClaim.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    submitWageClaim.setCustomValidity("");
                }
                submitWageClaim.reportValidity();
    }

    handleIndividualStreetAddressFocus(event){
        let individualRepStreetAddress = this.template.querySelector('[data-id="individualRepStreetAddress"]');
                if(individualRepStreetAddress.value.trim() == undefined || individualRepStreetAddress.value.trim() == null || individualRepStreetAddress.value.trim() == ''){
                    individualRepStreetAddress.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    individualRepStreetAddress.setCustomValidity("");
                }
                individualRepStreetAddress.reportValidity();
    }

    handleIndividualRepCityFocus(event){
        let individualRepCity = this.template.querySelector('[data-id="individualRepCity"]');
                if(individualRepCity.value.trim() == undefined || individualRepCity.value.trim() == null || individualRepCity.value.trim() == ''){
                    individualRepCity.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    individualRepCity.setCustomValidity("");
                }
                individualRepCity.reportValidity();
    }

    handleIndividualRepStateFocus(event){
        let individualRepState = this.template.querySelector('[data-id="individualRepState"]');
                if(individualRepState.value.trim() == undefined || individualRepState.value.trim() == null || individualRepState.value.trim() == ''){
                    individualRepState.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    individualRepState.setCustomValidity("");
                }
                individualRepState.reportValidity();
    }

    handleIndividualRepZipCodeFocus(event){
        const individualRepZipCode = this.template.querySelector('[data-id="individualRepZipCode"');
        if(individualRepZipCode.value === undefined || individualRepZipCode.value === null || individualRepZipCode.value.trim() === ''){
            individualRepZipCode.setCustomValidity('')
        }
        else if(individualRepZipCode.value.match(this.zipCodeRegrex)){
            individualRepZipCode.setCustomValidity('')
        }
        else{
            individualRepZipCode.setCustomValidity(customLabelValues.OWC_invalid_zipcode_msg)
        }
        individualRepZipCode.reportValidity()
    }

    handleLawFirmStreetAddressFocus(event){
        let lawfirmRepStreetAddress = this.template.querySelector('[data-id="lawfirmRepStreetAddress"]');
                if(lawfirmRepStreetAddress.value.trim() == undefined || lawfirmRepStreetAddress.value.trim() == null || lawfirmRepStreetAddress.value.trim() == ''){
                    lawfirmRepStreetAddress.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    lawfirmRepStreetAddress.setCustomValidity("");
                }
                lawfirmRepStreetAddress.reportValidity();
    }

    handleLawFirmCityFocus(event){
        let lawfirmRepCity = this.template.querySelector('[data-id="lawfirmRepCity"]');
                if(lawfirmRepCity.value.trim() == undefined || lawfirmRepCity.value.trim() == null || lawfirmRepCity.value.trim() == ''){
                    lawfirmRepCity.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    lawfirmRepCity.setCustomValidity("");
                }
                lawfirmRepCity.reportValidity();
    }

    handleLawFirmStateFocus(event){
        let lawfirmRepState = this.template.querySelector('[data-id="lawfirmRepState"]');
                if(lawfirmRepState.value.trim() == undefined || lawfirmRepState.value.trim() == null || lawfirmRepState.value.trim() == ''){
                    lawfirmRepState.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    lawfirmRepState.setCustomValidity("");
                }
                lawfirmRepState.reportValidity();
    }

    handleLawFirmRepZipCodeFocus(event){
        const lawFirmRepZipCode = this.template.querySelector('[data-id="lawFirmRepZipCode"');
        if(lawFirmRepZipCode.value === undefined || lawFirmRepZipCode.value === null || lawFirmRepZipCode.value.trim() === ''){
            lawFirmRepZipCode.setCustomValidity('')
        }
        else if(lawFirmRepZipCode.value.match(this.zipCodeRegrex)){
            lawFirmRepZipCode.setCustomValidity('')
        }
        else{
            lawFirmRepZipCode.setCustomValidity(customLabelValues.OWC_invalid_zipcode_msg)
        }
        lawFirmRepZipCode.reportValidity()
    }

    handleIndividualRepPhoneFocus(event){
        let individualRepPhone = this.template.querySelector('[data-id="individualRepPhone"]');
        if(individualRepPhone.value == undefined || individualRepPhone.value == null || individualRepPhone.value.trim() == ''){
            individualRepPhone.setCustomValidity('');
        }
        else if(individualRepPhone.value.match(this.regExpPhone)){
                individualRepPhone.setCustomValidity('');
            }
            else{
                individualRepPhone.setCustomValidity(customLabelValues.OWC_invalid_phone_msg)
            }
            individualRepPhone.reportValidity();
    }

    handleYourselfEmailFocus(event){
        if(this.individualRepEmail == undefined || this.individualRepEmail == null || this.individualRepEmail.trim() == ''){
        }
        else{
            if(this.individualRepEmail.match(this.regExpEmailformat)){
                let individualRepEmail = this.template.querySelector('[data-id="individualRepEmail"]');
                individualRepEmail.setCustomValidity('');
                individualRepEmail.reportValidity();
            }
            else{
                let individualRepEmail = this.template.querySelector('[data-id="individualRepEmail"]');
                individualRepEmail.setCustomValidity(customLabelValues.OWC_invalid_email_msg)
                individualRepEmail.reportValidity();
            }
        }
    }

    handleIndividualRepPhoneTypeFocus(event){
        let individualRepPhoneType = this.template.querySelector('[data-id="individualRepPhoneType"]');
                if(individualRepPhoneType.value == undefined || individualRepPhoneType.value == null || individualRepPhoneType.value == ''){
                    individualRepPhoneType.setCustomValidity('');
                }
                else{
                    individualRepPhoneType.setCustomValidity("");
                }
                individualRepPhoneType.reportValidity();
    }
    
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            case "advocateAssitance":
                const advocateAssitance = event.target.value;
                this.advocateAssitance = advocateAssitance;
                if(this.advocateAssitance === this.statusOptions[1].value){
                    this.isAdvocateAssist = true;
                }
                else{
                    this.isAdvocateAssist = false;
                    this.isRepresentative = false
                    this.isYourselfAdvocate = false
                    this.isIndividualRepresentation = false
                    this.isLawFirmRepresentation = false
                    this.isOrganizationRepresentation = false
                    this.representativeAdvocateType = undefined
                    this.resetIndividualRepAdvocateTemplate()
                    this.resetLawFirmRepAdvocateTemplate()
                    this.resetOrganizationRepAdvocateTemplate()
                }
                break;
                case "uspsCurrentAddressCheck":
                    const uspsCurrentAddressCheck = event.target.checked;
                    this.uspsCurrentAddressCheck = uspsCurrentAddressCheck;
                    break;
            // Preliminary Section Input Handler
            case "isClaimantConfirmation":
                const isClaimantConfirmation = event.target.checked;
                this.isClaimantConfirmation = isClaimantConfirmation;
                this.claimantConfirmUploadDoc = []
                this.claimantConfirmDocSize = ''
                // this.isClaimantConfirmUpload = true
                break;
            case "wageClaimSubmitForYourselfOrBehalf":            
                const submittedWageClaim = event.target.value
                //this.handleSubmitWageClaimPicklistFocus();
                if(submittedWageClaim === 'Yourself'){
                    this.isYourself = true
                    this.isRepresentative = false
                    this.isYourselfAdvocate = true
                    this.isIndividualRepresentation = false
                    this.isLawFirmRepresentation = false
                    this.isOrganizationRepresentation = false
                    this.representativeAdvocateType = undefined
                    this.resetIndividualRepAdvocateTemplate()
                    this.resetLawFirmRepAdvocateTemplate()
                    this.resetOrganizationRepAdvocateTemplate()
                }
                else if(submittedWageClaim === 'Representative'){
                    this.isRepresentative = true
                    this.isYourself = false
                    this.isYourselfAdvocate = false
                    this.isAdvocateAssist = false;
                    this.representativeAdvocateType = undefined
                    this.resetIndividualRepAdvocateTemplate()
                    this.resetLawFirmRepAdvocateTemplate()
                    this.resetOrganizationRepAdvocateTemplate()
                    this.isIndividualRepresentation = false
                    this.isLawFirmRepresentation = false
                    this.isOrganizationRepresentation = false
                }
                else if(submittedWageClaim === null){
                    this.isRepresentative = false
                    this.isAdvocateAssist = false;
                    this.isYourself = false
                    this.WageClaimSubmit = this.submitWageClaimPicklistData[0].label;
                    this.isIndividualRepresentation = false
                    this.isLawFirmRepresentation = false
                    this.isOrganizationRepresentation = false
                    this.representativeAdvocateType = undefined
                    this.isYourselfAdvocate = true;
                }
                else{
                    this.isRepresentative = false
                    this.isYourself = false
                }
                this.WageClaimSubmit = submittedWageClaim
                break;

            case "representativeAdvocateType":
                this.representativeAdvocateType = event.target.value;
                this.WageClaimSubmit === 'Yourself' ? '' : this.handleRepresentativeAdvocateType();
                if(this.representativeAdvocateType === 'Individual'){
                    this.isIndividualRepresentation = true
                    this.isLawFirmRepresentation = false
                    this.isOrganizationRepresentation = false
                    this.getIndividualClaimantInfo();
                    this.individualRepState === '' || this.individualRepState === null || this.individualRepState === undefined ? this.individualRepState = 'CA' : this.individualRepState = this.individualRepState
                    this.WageClaimSubmit === 'Yourself' ? this.resetLawFirmRepAdvocateTemplate() : ''
                    this.WageClaimSubmit === 'Yourself' ? this.resetOrganizationRepAdvocateTemplate() : ''
                }
                else if(this.representativeAdvocateType === 'Law Firm / Organization'){
                    this.isIndividualRepresentation = false
                    this.isLawFirmRepresentation = true
                    this.isOrganizationRepresentation = false
                    this.lawfirmRepState === '' || this.lawfirmRepState === null || this.lawfirmRepState === undefined ? this.lawfirmRepState = 'CA' : this.lawfirmRepState = this.lawfirmRepState
                    this.WageClaimSubmit === 'Yourself' ? this.resetIndividualRepAdvocateTemplate() : ''
                    this.WageClaimSubmit === 'Yourself' ? this.resetOrganizationRepAdvocateTemplate() : ''
                }
                else if(this.representativeAdvocateType === 'Organization'){
                    this.isIndividualRepresentation = false
                    this.isLawFirmRepresentation = false
                    this.isOrganizationRepresentation = true
                    this.organizationRepState === '' || this.organizationRepState === null || this.organizationRepState === undefined ? this.organizationRepState = 'CA' : this.organizationRepState = this.organizationRepState
                    this.WageClaimSubmit === 'Yourself' ? this.resetIndividualRepAdvocateTemplate() : ''
                    this.WageClaimSubmit === 'Yourself' ? this.resetLawFirmRepAdvocateTemplate() : ''
                }
                else if(this.representativeAdvocateType === this.repAdvocateTypePicklistValue[0].label){
                    this.isIndividualRepresentation = false
                    this.isLawFirmRepresentation = false
                    this.isOrganizationRepresentation = false
                    this.representativeAdvocateType = undefined;
                }
                else{
                    this.isIndividualRepresentation = false
                    this.isLawFirmRepresentation = false
                    this.isOrganizationRepresentation = false
                }
                break;
            case "individualRepFirstName":
                this.individualRepFirstName = event.target.value;
                this.handleIndividualFirstNameFocus();
                break;
            case "individualRepLastName":
                this.individualRepLastName = event.target.value;
                this.handleIndividualLastNameFocus();
                break;
            case "individualRepStreetAddress":
                this.individualRepStreetAddress = event.target.value;
                break;
            case "individualRepCity":
                this.individualRepCity = event.target.value;
                break;
            case "individualRepState":
                this.individualRepState = event.target.value
                this.isIndividualStatePicklist = true
                this.isOrganizationStatePicklist = false
                this.isLawFirmStatePicklist = false
                break;
            case "individualRepZipCode":
                this.individualRepZipCode = event.target.value;
                if(event.target.value.length >= 5 && this.individualRepZipCode.includes('-')){
                    this.template.querySelector('[data-id="individualRepZipCode"]').value = event.target.value;
                }
                else if(event.target.value.length === 6){
                    this.template.querySelector('[data-id="individualRepZipCode"]').value = event.target.value.replace(/(\d{5})/, "$1-");
                }
                this.individualRepZipCode = event.target.value;
                this.handleIndividualRepZipCodeFocus();
                break;
            case "individualRepPhone":
                this.individualRepPhone = event.target.value;
                this.handleIndividualRepPhoneFocus();
                break;
            case "individualRepPhoneType":
                this.handleIndividualRepPhoneTypeFocus();
                this.individualRepPhoneType = event.target.value;
                break;
            case "individualRepEmail":
                this.individualRepEmail = event.target.value;
                this.handleIndividualEmailFocus();
                break;
            case "individualRepWebsite":
                this.individualRepWebsite = event.target.value;
                this.handleIndividualWebsiteFocus();
                break;
            case "individualRepClaimantRelationship":
                if(event.target.value === this.individualRepClaimantRelationshipPicklist[0].label){
                    this.individualRepClaimantRelationship = undefined;
                }
                else{
                    this.individualRepClaimantRelationship = event.target.value;
                }
                break;
            case "lawfirmRepBusinessName":
                this.lawfirmRepBusinessName = event.target.value.trim();
                this.lawfirmRepBusinessName !== '' || this.lawfirmRepAttorney !== '' ? this.isFieldSetValid = false : this.isFieldSetValid = true
                break;
            case "lawfirmRepAttorney":
                this.lawfirmRepAttorney = event.target.value.trim();
                this.lawfirmRepBusinessName !== '' || this.lawfirmRepAttorney !== '' ? this.isFieldSetValid = false : this.isFieldSetValid = true
                break;
            case "lawfirmRepStreetAddress":
                this.lawfirmRepStreetAddress = event.target.value;
                break;
            case "lawfirmRepCity":
                this.lawfirmRepCity = event.target.value;
                break;
            case "lawfirmRepState":
                this.lawfirmRepState = event.target.value;
                this.isLawFirmStatePicklist = true
                this.isOrganizationStatePicklist = false
                this.isIndividualStatePicklist = false
                break;
            case "lawfirmRepStatePhone":
                this.lawfirmRepStatePhone = event.target.value;
                break;
            case "lawFirmRepZipCode":
                this.lawFirmRepZipCode = event.target.value;
                if(event.target.value.length >= 5 && this.lawFirmRepZipCode.includes('-')){
                    this.template.querySelector('[data-id="lawFirmRepZipCode"]').value = event.target.value;
                }
                else if(event.target.value.length === 6){
                    this.template.querySelector('[data-id="lawFirmRepZipCode"]').value = event.target.value.replace(/(\d{5})/, "$1-");
                }
                this.lawFirmRepZipCode = event.target.value;
                this.handleLawFirmRepZipCodeFocus()
                break;
            case "lawfirmRepEmail":
                this.lawfirmRepEmail = event.target.value;
                this.handleLawFirmRepEmailFocus()
                break;
            case "lawfirmRepWebsite":
                this.lawfirmRepWebsite = event.target.value;
                this.handleLawFirmWebsiteFocus();
                break;
            case "organizationRepBusinessName":
                this.organizationRepBusinessName = event.target.value;
                this.handleOrganizationRepBusinessFocus()
                break;
            case "organizationRepAttorney":
                this.organizationRepAttorney = event.target.value;
                this.handleOrganizationRepAttorneyFocus()
                break;
            case "organizationRepStreetAddress":
                this.organizationRepStreetAddress = event.target.value;
                this.handleOrganizationRepStreetAddressFocus()
                break;
            case "organizationRepCity":
                this.organizationRepCity = event.target.value;
                this.handleOrganizationRepCityFocus()
                break;
            case "organizationRepState":
                this.organizationRepState = event.target.value;
                this.handleLawFirmStateFocus()
                this.isOrganizationStatePicklist = true
                this.isLawFirmStatePicklist = false
                this.isIndividualStatePicklist = false
                break;
            case "organizationRepPhone":
                this.organizationRepPhone = event.target.value;
                this.handleOrganizationRepPhoneFocus()
                break;
            case "organizationRepZipCode":
                this.organizationRepZipCode = event.target.value;
                if(event.target.value.length >= 5 && this.organizationRepZipCode.includes('-')){
                    this.template.querySelector('[data-id="organizationRepZipCode"]').value = event.target.value;
                }
                else if(event.target.value.length === 6){
                    this.template.querySelector('[data-id="organizationRepZipCode"]').value = event.target.value.replace(/(\d{5})/, "$1-");
                }
                this.organizationRepZipCode = event.target.value;
                this.handleOrganizationRepZipCodeFocus()
                break;
            case "organizationRepEmail":
                this.organizationRepEmail = event.target.value;
                this.handleOrganizationRepEmailFocus()
                break;
            case "organizationRepWebsite":
                this.organizationRepWebsite = event.target.value;
                break;
            case "unionContractCovering":
                this.unionContractCovering = event.target.value;
                if(this.unionContractCovering === customLabelValues.OWC_Yes){
                    this.isUnionContractCovered = true
                }
                else{
                    this.isUnionContractCovered = false
                }
                break;
            case "urlAddress":
                this.urlAddress = event.target.value;
                break;
            case "coversheetDocument":
                this.coversheetDocument = event.target.value;
                break;
            case "filingWageClaim":
                this.filingWageClaim = event.target.value;
                break;
            case "specifyFilingWageClaim":
                this.specifyFilingWageClaim = event.target.value;
                if(this.specifyFilingWageClaim === 'Other – please explain'){
                    this.isEmployeeFilingWageClaimOther = true
                }
                else{
                    this.isEmployeeFilingWageClaimOther = false
                }
                break;
            case "covid19Claim":
                this.covid19Claim = event.target.value;
                if(this.covid19Claim === customLabelValues.OWC_Yes){
                    this.isEmployeeFilingWageClaim = true
                    this.isEmployeeFilingWageClaimOther = false
                }
                else{
                    this.isEmployeeFilingWageClaim = false
                    this.isEmployeeFilingWageClaimOther = false
                } 
                break;
            case "specifyOtherReason":
                this.specifyOtherReason = event.target.value;
                break;
            case "countryCodeindividualRepPhone":
                this.countryCodeindividualRepPhone = event.target.value;
                break;
            case "countryCodelawfirmRepStatePhone":
                this.countryCodelawfirmRepStatePhone = event.target.value;
                break;
            
        }
    }

    handleIndividualEmailFocus(event){
        if(this.individualRepEmail == undefined || this.individualRepEmail == null || this.individualRepEmail.trim() == ''){

        }
        else{
            if(this.individualRepEmail.match(this.regExpEmailformat)){
                let individualRepEmail = this.template.querySelector('[data-id="individualRepEmail"]');
                individualRepEmail.setCustomValidity('');
                individualRepEmail.reportValidity();
            }
            else{
                let individualRepEmail = this.template.querySelector('[data-id="individualRepEmail"]');
                this.isIndividualPhone = true
                individualRepEmail.setCustomValidity(customLabelValues.OWC_invalid_email_msg)
                individualRepEmail.reportValidity();
            }
        }
    }

   

    isNotRepresentativeAdvocateType = false

    phoneValidityChecker(ids, values){
        let id = ids
        let value = values
        if(value == undefined || value == null || value == ''){
            return false;
        }
        else{
            if(value.match(this.regExpPhone)){
                id.setCustomValidity('');
                id.reportValidity();
                return false
            }
            else{
                id.setCustomValidity(customLabelValues.OWC_invalid_phone_msg);
                id.reportValidity();
                return true
            }
        }
    }
    
    preliminarySectionValidityChecker(ids, values){
        let id = ids
        let value = values
        const val = value == undefined || value == null ? '' : value
        if(val.trim() == ""){
            id.setCustomValidity('');
            id.reportValidity();
            return false;
        }
    }

    resetRepIndividualSection(){
        individualRepFirstName = ''
        individualRepLastName = ''
        individualRepZipCode = ''
        individualRepStreetAddress = ''
        individualRepCity = ''
        individualRepState = ''
        individualRepEmail = ''
        individualRepWebsite = ''
        individualRepPhone = ''
        individualRepPhoneType = ''
        individualRepClaimantRelationship = ''
    }

    get showCurrentAddressTemplate(){
        return this.isUSPSAddressErrorTemplate === true || this.isUSPSAddressSuccessTemplate === true
    }

    get advocateUSPSAddressCheck(){
        return this.isIndividualRepresentation === true || this.isLawFirmRepresentation === true || this.isOrganizationRepresentation === true
    }
    
    
    handlePreliminaryEvent(){
        if(this.isYourself === true || this.isIndividualRepresentation === true || this.isLawFirmRepresentation === true || this.isOrganizationRepresentation === true){
            this.template.querySelector('c-owc-Claimant-Emplyee-Garment-Section-Cmp').handleClaimantEvent();
        }
        const selectEvent = new CustomEvent('claimantemployeecustomevent', {
            detail: { 
                sectionId : "1",
                countryCodeindividualRepPhone : this.countryCodeindividualRepPhone,
                countryCodelawfirmRepStatePhone : this.countryCodelawfirmRepStatePhone,
                claimantConfirmUploadDoc : this.claimantConfirmUploadDoc,
                isClaimantConfirmUpload : this.isClaimantConfirmUpload,
                claimantConfirmDocSize : this.claimantConfirmDocSize,
                isClaimantConfirmation : this.isClaimantConfirmation,
                claimantDetails : this.claimantDetails,
                isIndividualStatePicklist : this.isIndividualStatePicklist,
                isLawFirmStatePicklist : this.isLawFirmStatePicklist,
                isOrganizationStatePicklist : this.isOrganizationStatePicklist,
                uploadUnionContractDocument : this.uploadUnionContractDocument,
                yourselffname : this.yourselfFirstName,
                yourselflname : this.yourselfLastName,
                yourselfMiddleName : this.yourselfMiddleName,
                WageClaimSubmit : this.WageClaimSubmit, 
                isYourself : this.isYourself,
                isRepresentative : this.isRepresentative,
                yourselfhomephone : this.yourselfHomePhone,
                yourselfcellphone : this.yourselfCellPhone,
                cellphoneentered : this.isCellPhoneEntered,
                yourselfbirthdate : this.yourselfBirthDate,
                yourselfemail : this.yourselfEmail,
                yourselfstreetaddress : this.yourselfStreetAddress,
                yourselfcity : this.yourselfCity,
                yourselfstate : this.yourselfState,
                yourselfzipCode : this.yourselfZipCode,
                representativeAdvocateType : this.representativeAdvocateType,
                isLawFirmRepresentation : this.isLawFirmRepresentation,
                isOrganizationRepresentation : this.isOrganizationRepresentation,
                isIndividualRepresentation : this.isIndividualRepresentation,
                individualRepFirstName : this.individualRepFirstName,
                individualRepLastName : this.individualRepLastName,
                individualRepStreetAddress : this.individualRepStreetAddress,
                individualRepCity : this.individualRepCity,
                individualRepState : this.individualRepState ,//|| this.template.querySelector('[data-id="individualRepState"]').value,
                individualRepZipCode : this.individualRepZipCode,
                individualRepPhone : this.individualRepPhone,
                individualRepPhoneType : this.individualRepPhoneType,
                individualRepEmail : this.individualRepEmail,
                individualRepWebsite : this.individualRepWebsite,
                individualRepClaimantRelationship : this.individualRepClaimantRelationship,
                lawfirmRepBusinessName : this.lawfirmRepBusinessName,
                lawfirmRepAttorney : this.lawfirmRepAttorney,
                lawfirmRepStreetAddress : this.lawfirmRepStreetAddress,
                lawfirmRepCity : this.lawfirmRepCity,
                lawfirmRepState : this.lawfirmRepState ,//|| this.template.querySelector('[data-id="lawfirmRepState"]').value,
                lawfirmRepStatePhone : this.lawfirmRepStatePhone,
                lawFirmRepZipCode : this.lawFirmRepZipCode,
                lawfirmRepEmail : this.lawfirmRepEmail,
                lawfirmRepWebsite : this.lawfirmRepWebsite,
                organizationRepBusinessName : this.organizationRepBusinessName,
                organizationRepAttorney : this.organizationRepAttorney,
                organizationRepStreetAddress : this.organizationRepStreetAddress,
                organizationRepCity : this.organizationRepCity,
                organizationRepState : this.organizationRepState,// || this.template.querySelector('[data-id="organizationRepState"]').value,
                organizationRepPhone : this.organizationRepPhone,
                organizationRepZipCode : this.organizationRepZipCode,
                organizationRepEmail : this.organizationRepEmail,
                organizationRepWebsite : this.organizationRepWebsite,
                needLanguageInterpreter : this.needLanguageInterpreter,
                isPrefferedLanguage : this.isPrefferedLanguage,
                prefferedLanguageSelection : this.prefferedLanguageSelection,
                otherPrefferedLanguage : this.otherPrefferedLanguage,
                isOtherPrefferedLanguage : this.isOtherPrefferedLanguage,
                advocateAssitance : this.advocateAssitance,
                isAdvocateAssist : this.isAdvocateAssist,
                isFileInserted : this.isFileInserted,
                contentVersionIds : this.contentVersionIds,
                totalUploadFiles : this.totalUploadFiles,
                flag : this.flag
                // isFileUploaded : this.isFileUploaded
             }
       });
      this.dispatchEvent(selectEvent);
    }

    isFirstName = false
    isLastName = false
    isHomePhone = false
    isCellPhone = false
    isBirthdate = false
    isZipCode = false
    isIndividualFirstName = false
    isLawFirmBusinessName = false
    isReasonOther = false
    isWageClaimSubmit = false
    isYourselfEmail = false
    isIndividualStreetAddress = false
    isIndividualRepCity = false
    isIndividualRepState = false
    isIndividualRepZipCode = false
    isLawFirmStreetAddress = false
    isLawFirmCity = false
    isLawFirmState = false
    isLawFirmZipCode = false
    isOrgStreetAddress = false
    isOrgCity = false
    isOrgState = false
    isOrgZipCode = false
    isOrganizationBusinessName = false
    isUnionContractCoveredDoc = false
    isIndividualPhone = false
    isIndividualRepPhoneType = false
    isindividualRepPhone = false
    isOtherPrefferedLanguage = false
    isCellPhoneValid = false
    isHomePhoneValid = false
    isYourselfEmailValid = false
    isIndividualRepPhoneValid = false
    islawfirmRepEmailValid = false
    isorganizationRepEmailValid = false
    isLawFirmPhoneValid = false
    isOrganizationPhoneValid = false
    isZipCodeValid = false
    isIndividualZipCode = false
    isLawFirmZipCodeValid = false
    isOrganizationRepZipCodeValid = false
    isurlAddressValid = false
    isIndividualLastName = false
    isIndividualWebsiteValid = false
    @api isFieldSetValid = false;
    @api fieldSetMsg
    @api isWebsiteAddressCorrect = false
    // Store Regular Expression
    regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    regExpPhone = /^[0-9]{10}$/ ;
    zipCodeRegrex = /^\d{5}(?:[-\s]\d{4})?$/; //^[0-9]{5}(?:[0-9]{4})?$/;
    urlAddressChekerRegrex = /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$/;

    @api isValidityTrue = false

    handleClaimantValidityCheck(event){
        const isValidityTrue = event.detail.isValidityTrue
        this.isValidityTrue = isValidityTrue
    }

    handleClaimantDetails(event){
        const claimantDetails = event.detail
        this.claimantDetails = claimantDetails
    }

    handleUSPSAddressMatch(event){
        const currentStep = event.detail.currentStep;
        const validateEvent = new CustomEvent('matchuspscustomevent', {
            detail: {
                currentStep : currentStep
            }
        });
        this.dispatchEvent(validateEvent);
        this.handlePreliminaryEvent();
    }

    @api isClaimantConfirmationRequiredMsg = false;
    NotProceed = false;
    
    @api 
    owcClaimantEmployeeDataForParent(){
        // (this.claimantConfirmUploadDoc !== undefined && this.claimantConfirmUploadDoc !== null && this.claimantConfirmUploadDoc.length > 0) ? this.handleSaveFiles() : ''
        // if((this.isClaimantConfirmation === true) && (this.isIndividualRepresentation === true || this.isLawFirmRepresentation === true || this.isOrganizationRepresentation === true)){
        //     if(this.claimantConfirmUploadDoc === '' || this.claimantConfirmUploadDoc.length === 0){
        //         const individualRepClaimantRelationship = this.template.querySelector('[data-id="individualRepClaimantRelationship"]');
        //         const lawfirmRepWebsite = this.template.querySelector('[data-id="lawfirmRepWebsite"]');
        //         this.isClaimantConfirmationRequiredMsg = true;
        //         if(individualRepClaimantRelationship !== undefined){
        //             this.isClaimantConfirmationRequiredMsg === true ? individualRepClaimantRelationship.focus() : '';
        //         }
        //         if(lawfirmRepWebsite !== undefined){
        //             this.isClaimantConfirmationRequiredMsg === true ? lawfirmRepWebsite.focus() : '';
        //         }
        //         if(this.isClaimantConfirmationRequiredMsg === true){
        //             const validateEvent = new CustomEvent('validityevent', {
        //                 detail: {
        //                     currentStep : true
        //                 }
        //             });
        //             this.dispatchEvent(validateEvent);
        //         }
        //     }
        // }
        
        // if(this.WageClaimSubmit === null || this.WageClaimSubmit === undefined){
        //     let submitWageClaim = this.template.querySelector('[data-id="submitWageClaim"]');
        //     let submitWageClaimValue = this.submitWageClaim
        //     this.isWageClaimSubmit = this.preliminarySectionValidityChecker(submitWageClaim, submitWageClaimValue);

        //     this.isWageClaimSubmit === true ? submitWageClaim.focus() : ''

        //     if(this.isWageClaimSubmit === true){
        //         const validateEvent = new CustomEvent('validityevent', {
        //             detail: {
        //                 currentStep : true
        //             }
        //         });
        //         this.dispatchEvent(validateEvent);
        //     }
        // }
        // this.isYourselfAdvocate === false && this.WageClaimSubmit === 'Representative' ? this.handleRepresentativeAdvocateType() : ''
        //     if(this.isNotRepresentativeAdvocateType === true){
        //         const validateEvent = new CustomEvent('validityevent', {
        //             detail: {
        //                 currentStep : true
        //             }
        //         });
        //         this.dispatchEvent(validateEvent);
        //     }
        // if(this.isEmployeeFilingWageClaim === true && this.isEmployeeFilingWageClaimOther === true){
        //     let specifyOtherReason = this.template.querySelector('[data-id="specifyOtherReason"]');
        //     let specifyOtherReasonValue = this.specifyOtherReason
        //     this.isReasonOther = this.preliminarySectionValidityChecker(specifyOtherReason, specifyOtherReasonValue);
        //     this.isReasonOther === true ? specifyOtherReason.focus() : ''
        //     if(this.isReasonOther === true){
        //         const validateEvent = new CustomEvent('validityevent', {
        //             detail: {
        //                 currentStep : true
        //             }
        //         });
        //         this.dispatchEvent(validateEvent);
        //     }
        // }
        if(this.isYourself === true){
            this.template.querySelector('c-owc-Claimant-Emplyee-Garment-Section-Cmp').handleClaimantEmployeeParent(false);
            if(this.isValidityTrue === true){
                const validateEvent = new CustomEvent('validityevent', {
                    detail: {
                        currentStep : true
                    }
                });
                this.isValidityTrue = false
                this.dispatchEvent(validateEvent);
            }
        }
        if(this.isIndividualRepresentation === true){
            this.template.querySelector('c-owc-Claimant-Emplyee-Garment-Section-Cmp').handleClaimantEmployeeParent();
            let individualRepEmail = this.template.querySelector('[data-id="individualRepEmail"]');
            let individualRepPhoneType = this.template.querySelector('[data-id="individualRepPhoneType"]');
                let individualRepFirstName = this.template.querySelector('[data-id="individualRepFirstName"]');
                let individualRepFirstNameValue = this.individualRepFirstName
                let individualRepLastName = this.template.querySelector('[data-id="individualRepLastName"]');
                let individualRepLastNameValue = this.individualRepLastName
                let individualRepZipCode = this.template.querySelector('[data-id="individualRepZipCode"]');
                let individualRepZipCodeValue = this.individualRepZipCode
                let individualRepPhone = this.template.querySelector('[data-id="individualRepPhone"]');
                let individualRepPhoneValue = this.individualRepPhone
                this.isIndividualLastName = this.preliminarySectionValidityChecker(individualRepLastName, individualRepLastNameValue);
                this.isIndividualFirstName = this.preliminarySectionValidityChecker(individualRepFirstName, individualRepFirstNameValue);
                this.isIndividualRepCity = this.preliminarySectionValidityChecker(individualRepPhone, individualRepPhoneValue);
                this.isIndividualRepPhoneValid = this.phoneValidityChecker(individualRepPhone, individualRepPhoneValue);
                
                if(individualRepZipCode.value.trim() == null || individualRepZipCode.value.trim() == undefined || individualRepZipCode.value.trim() == ''){
                    
                }
                else if(individualRepZipCode.value.trim() != null || individualRepZipCode.value.trim() != undefined || individualRepZipCode.value.trim() != ''){
                    const individualRepZipCode = this.template.querySelector('[data-id="individualRepZipCode"]');
                    if(individualRepZipCode.value.match(this.zipCodeRegrex)){
                        individualRepZipCode.setCustomValidity("");
                        this.isIndividualZipCode = false
                        individualRepZipCode.reportValidity()
                    }
                    else{
                        individualRepZipCode.setCustomValidity(customLabelValues.OWC_invalid_zipcode_msg);
                        this.isIndividualZipCode = true
                        individualRepZipCode.reportValidity()
                    }                
                }
                else{
                    this.isIndividualZipCode = false
                }

                if((this.individualRepPhone == undefined || this.individualRepPhone == null || this.individualRepPhone.trim() == '') && (this.individualRepEmail == undefined || this.individualRepEmail == null || this.individualRepEmail.trim() == '')){
                    this.isIndividualPhone = true
                    this.isMultipleRequiredCheck = true
                    this.ValidationMsg = customLabelValues.OWC_individual_rep_phonetype_helptext
                }
                else{
                    this.isMultipleRequiredCheck = false
                    this.isIndividualPhone = false
                }
                if((this.individualRepPhone == undefined || this.individualRepPhone == null || this.individualRepPhone.trim() == '') && (this.individualRepPhoneType == undefined || this.individualRepPhoneType == null || this.individualRepPhoneType.trim() == '')){
                    this.isIndividualRepPhoneType = false
                    this.isindividualRepPhone = false
                }
                else{
                    if(this.individualRepPhone != undefined || this.individualRepPhone != null || this.individualRepPhone.trim() != ''){
                        let individualRepPhoneType = this.template.querySelector('[data-id="individualRepPhoneType"]');
                        let individualRepPhoneTypeValue = this.individualRepPhoneType
                        this.isIndividualRepPhoneType = this.preliminarySectionValidityChecker(individualRepPhoneType, individualRepPhoneTypeValue);
                    }
                    if(this.individualRepPhoneType != undefined || this.individualRepPhoneType != null || this.individualRepPhoneType != ''){
                        let individualRepPhone = this.template.querySelector('[data-id="individualRepPhone"]');
                        let individualRepPhoneValue = this.individualRepPhone
                        this.isindividualRepPhone = this.preliminarySectionValidityChecker(individualRepPhone, individualRepPhoneValue);
                    }
                }
                if(this.individualRepEmail == undefined || this.individualRepEmail == null || this.individualRepEmail.trim() == ''){

                }
                else{
                    if(this.individualRepEmail.match(this.regExpEmailformat)){
                        let individualRepEmail = this.template.querySelector('[data-id="individualRepEmail"]');
                        individualRepEmail.setCustomValidity('');
                        individualRepEmail.reportValidity();
                    }
                    else{
                        let individualRepEmail = this.template.querySelector('[data-id="individualRepEmail"]');
                        this.isIndividualPhone = true
                        individualRepEmail.setCustomValidity(customLabelValues.OWC_invalid_email_msg)
                        individualRepEmail.reportValidity();
                    }
                }
                const individualRepWebsite = this.template.querySelector('[data-id="individualRepWebsite"');
                this.isIndividualWebsiteValid = this.handleIndividualWebsiteFocus();

                this.isIndividualWebsiteValid === true ? individualRepWebsite.focus() : ''
                this.isIndividualPhone === true ? individualRepEmail.focus() : ''
                this.isIndividualRepPhoneType === true ? individualRepPhoneType.focus() : ''
                this.isIndividualZipCode === true ? individualRepZipCode.focus() : ''
                this.isIndividualRepCity === true ? individualRepPhone.focus() : ''
                this.isIndividualLastName === true ? individualRepLastName.focus() : ''
                this.isIndividualFirstName === true ? individualRepFirstName.focus() : ''
                
                // if( (this.isIndividualRepPhoneType === true || this.isindividualRepPhone === true) || this.isIndividualPhone === true || this.isIndividualFirstName === true || this.isIndividualLastName === true || this.isIndividualStreetAddress === true || this.isIndividualRepState === true || this.isIndividualRepCity === true || this.isIndividualRepZipCode === true || this.isIndividualRepPhoneValid === true || this.isIndividualZipCode === true || this.isValidityTrue === true || this.isIndividualWebsiteValid === true)
                if( (this.isIndividualRepPhoneType === true || this.isindividualRepPhone === true) || this.isIndividualPhone === true ||  this.isIndividualRepState === true || this.isIndividualRepCity === true || this.isIndividualRepZipCode === true || this.isIndividualRepPhoneValid === true || this.isIndividualZipCode === true || this.isValidityTrue === true || this.isIndividualWebsiteValid === true){
                    const validateEvent = new CustomEvent('validityevent', {
                        detail: {
                            currentStep : true
                        }
                    });
                    this.isValidityTrue = false
                    this.dispatchEvent(validateEvent);
                }
        }
        else if(this.isLawFirmRepresentation === true || this.isOrganizationRepresentation === true){
            this.template.querySelector('c-owc-Claimant-Emplyee-Garment-Section-Cmp').handleClaimantEmployeeParent();
            let lawfirmRepBusinessName = this.template.querySelector('[data-id="lawfirmRepBusinessName"]');
            let lawfirmRepAttorney = this.template.querySelector('[data-id="lawfirmRepAttorney"]');
            let lawFirmRepZipCode = this.template.querySelector('[data-id="lawFirmRepZipCode"]');
            let lawfirmRepEmail = this.template.querySelector('[data-id="lawfirmRepEmail"]');
            let lawfirmRepWebsite = this.template.querySelector('[data-id="lawfirmRepWebsite"]');

            if((lawfirmRepBusinessName.value === undefined || lawfirmRepBusinessName.value === null || lawfirmRepBusinessName.value === '') && (lawfirmRepAttorney.value === undefined || lawfirmRepAttorney.value === null || lawfirmRepAttorney.value === '')){
                this.isFieldSetValid = true;
                this.fieldSetMsg = this.customLabelValues.OWC_lawfirm_custom_msg;
            }
            else{
                this.isFieldSetValid = false;
            }

            // Check Law firm website address validation
            this.isWebsiteAddressCorrect = this.handleLawFirmWebsiteFocus();
            // Validation for Law Firm / Organization Zipcode
            if(lawFirmRepZipCode.value.trim() == null || lawFirmRepZipCode.value.trim() == undefined || lawFirmRepZipCode.value.trim() == ''){
                    
            }
            else if(lawFirmRepZipCode.value.trim() != null || lawFirmRepZipCode.value.trim() != undefined || lawFirmRepZipCode.value.trim() != ''){
                const lawFirmRepZipCode = this.template.querySelector('[data-id="lawFirmRepZipCode"]');
                if(lawFirmRepZipCode.value.match(this.zipCodeRegrex)){
                    lawFirmRepZipCode.setCustomValidity("");
                    this.isLawFirmZipCode = false
                    lawFirmRepZipCode.reportValidity()
                }
                else{
                    lawFirmRepZipCode.setCustomValidity(customLabelValues.OWC_invalid_zipcode_msg);
                    this.isLawFirmZipCode = true
                    lawFirmRepZipCode.reportValidity()
                }                
            }
            else{
                this.isLawFirmZipCode = false
            }

            // Validation for Law Firm / Organization Email
            if(lawfirmRepEmail.value.trim() == null || lawfirmRepEmail.value.trim() == undefined || lawfirmRepEmail.value.trim() == ''){
                    
            }
            else if(lawfirmRepEmail.value.trim() != null || lawfirmRepEmail.value.trim() != undefined || lawfirmRepEmail.value.trim() != ''){
                const lawfirmRepEmail = this.template.querySelector('[data-id="lawfirmRepEmail"]');
                if(lawfirmRepEmail.value.match(this.regExpEmailformat)){
                    lawfirmRepEmail.setCustomValidity("");
                    this.islawfirmRepEmailValid = false
                    lawfirmRepEmail.reportValidity()
                }
                else{
                    lawfirmRepEmail.setCustomValidity(customLabelValues.OWC_invalid_email_msg);
                    this.islawfirmRepEmailValid = true
                    lawfirmRepEmail.reportValidity()
                }                
            }
            else{
                this.islawfirmRepEmailValid = false
            }

            this.isFieldSetValid === true ? lawfirmRepBusinessName.focus() : ''
            this.isLawFirmZipCode === true ? lawFirmRepZipCode.focus() : ''
            this.islawfirmRepEmailValid === true ? lawfirmRepEmail.focus() : ''
            this.isWebsiteAddressCorrect === true ? lawfirmRepWebsite.focus() : ''

            if( this.lawFirmRepZipCode === true || this.islawfirmRepEmailValid === true || this.isWebsiteAddressCorrect === true){
                const validateEvent = new CustomEvent('validityevent', {
                                detail: {
                                    currentStep : true
                                }
                            });
                            this.isValidityTrue = false
                            this.dispatchEvent(validateEvent);
            }
        }
        this.handlePreliminaryEvent();
    }

    @api preliminarySectionDetails
    
    @api 
    owcClaimantEmployeeInfoForChild(strString, isFormPreviewMode){
        this.preliminarySectionDetails = strString
        
        if(Boolean(strString)){
            this.countryCodeindividualRepPhone = strString.countryCodeindividualRepPhone
            this.countryCodelawfirmRepStatePhone = strString.countryCodelawfirmRepStatePhone
            this.isFormPreviewMode = isFormPreviewMode
            this.claimantConfirmUploadDoc = (strString.claimantConfirmUploadDoc) ? strString.claimantConfirmUploadDoc : [],
            this.isClaimantConfirmUpload = strString.isClaimantConfirmUpload,
            this.claimantConfirmDocSize = strString.claimantConfirmDocSize,
            this.isClaimantConfirmation = strString.isClaimantConfirmation
            this.isIndividualStatePicklist = strString.isIndividualStatePicklist
            this.isLawFirmStatePicklist = strString.isLawFirmStatePicklist
            this.isOrganizationStatePicklist = strString.isOrganizationStatePicklist
            this.claimantDetails = strString.claimantDetails
            this.WageClaimSubmit = strString.WageClaimSubmit
            this.isYourself = strString.isYourself
            this.isRepresentative = strString.isRepresentative
            this.yourselfFirstName = strString.yourselffname
            this.yourselfLastName = strString.yourselflname
            this.yourselfMiddleName = strString.yourselfMiddleName
            this.yourselfHomePhone = strString.yourselfhomephone
            this.yourselfCellPhone = strString.yourselfcellphone
            this.isCellPhoneEntered = strString.cellphoneentered
            this.yourselfBirthDate = strString.yourselfbirthdate
            this.yourselfEmail = strString.yourselfemail
            this.yourselfStreetAddress = strString.yourselfstreetaddress
            this.yourselfCity = strString.yourselfcity
            this.yourselfState = strString.yourselfstate
            this.yourselfZipCode = strString.yourselfzipCode
            this.representativeAdvocateType = strString.representativeAdvocateType
            this.isIndividualRepresentation = strString.isIndividualRepresentation
            this.isOrganizationRepresentation = strString.isOrganizationRepresentation
            this.isLawFirmRepresentation = strString.isLawFirmRepresentation
            this.individualRepFirstName = strString.individualRepFirstName
            this.individualRepLastName = strString.individualRepLastName
            this.individualRepStreetAddress = strString.individualRepStreetAddress
            this.individualRepCity = strString.individualRepCity
            this.individualRepState = strString.individualRepState
            this.individualRepZipCode = strString.individualRepZipCode
            this.individualRepPhone = strString.individualRepPhone
            this.individualRepPhoneType = strString.individualRepPhoneType
            this.individualRepEmail = strString.individualRepEmail
            this.individualRepWebsite = strString.individualRepWebsite
            this.individualRepClaimantRelationship = strString.individualRepClaimantRelationship
            this.lawfirmRepBusinessName = strString.lawfirmRepBusinessName
            this.lawfirmRepAttorney = strString.lawfirmRepAttorney
            this.lawfirmRepStreetAddress = strString.lawfirmRepStreetAddress
            this.lawfirmRepCity = strString.lawfirmRepCity
            this.lawfirmRepState = strString.lawfirmRepState
            this.lawfirmRepStatePhone = strString.lawfirmRepStatePhone
            this.lawFirmRepZipCode = strString.lawFirmRepZipCode
            this.lawfirmRepEmail = strString.lawfirmRepEmail
            this.lawfirmRepWebsite = strString.lawfirmRepWebsite
            this.organizationRepBusinessName = strString.organizationRepBusinessName
            this.organizationRepAttorney = strString.organizationRepAttorney
            this.organizationRepStreetAddress = strString.organizationRepStreetAddress
            this.organizationRepCity = strString.organizationRepCity
            this.organizationRepState = strString.organizationRepState
            this.organizationRepPhone = strString.organizationRepPhone
            this.organizationRepZipCode = strString.organizationRepZipCode
            this.organizationRepEmail = strString.organizationRepEmail
            this.organizationRepWebsite = strString.organizationRepWebsite
            this.needLanguageInterpreter = strString.needLanguageInterpreter
            this.isPrefferedLanguage = strString.isPrefferedLanguage
            this.prefferedLanguageSelection = strString.prefferedLanguageSelection
            this.otherPrefferedLanguage = strString.otherPrefferedLanguage
            this.isOtherPrefferedLanguage = strString.isOtherPrefferedLanguage
            this.advocateAssitance = strString.advocateAssitance
            this.isAdvocateAssist = strString.isAdvocateAssist
            this.flag = strString.flag,
            this.contentVersionIds = strString.contentVersionIds
            this.totalUploadFiles = strString.totalUploadFiles
            this.isRenderedCallback = true
        }else{
            this.isRenderedCallback = false
        }
        
        
        
    }

    renderedCallback(){
        if(this.isRenderedCallback === false && this.representativeAdvocateType === 'Individual' && this.isIndividualStatePicklist === false){
            this.template.querySelector('[data-id="individualRepState"]').value = 'CA';
        }
        if(this.isRenderedCallback === false && this.representativeAdvocateType === 'Law Firm / Organization' && this.isLawFirmStatePicklist === false){
            this.template.querySelector('[data-id="lawfirmRepState"]').value = 'CA';
            // this.lawfirmRepState = 'CA';
        }
        if(this.isRenderedCallback === false && this.representativeAdvocateType === 'Organization' && this.isOrganizationStatePicklist === false){
            this.template.querySelector('[data-id="organizationRepState"]').value = 'CA';
            // this.organizationRepState = 'CA';
        }
        
        if(this.isRenderedCallback === true && this.individualRepState != undefined && this.isIndividualRepresentation === true){
            this.template.querySelector('[data-id="individualRepState"]').value = this.individualRepState
        }
        if(this.isRenderedCallback === true && this.isYourself === true && this.advocateAssitance != undefined){
            this.template.querySelector('[data-id="advocateAssitance"]').value = this.advocateAssitance
        }
        
        if(this.isRenderedCallback === true && this.lawfirmRepState != undefined && this.isLawFirmRepresentation === true){
            this.template.querySelector('[data-id="lawfirmRepState"]').value = this.lawfirmRepState
        }
        if(this.isRenderedCallback === true && this.organizationRepState != undefined && this.isOrganizationRepresentation === true){
            this.template.querySelector('[data-id="organizationRepState"]').value = this.organizationRepState
        }
        if(this.isRenderedCallback === true && (this.isYourself === true || this.isIndividualRepresentation === true || this.isLawFirmRepresentation === true || this.isOrganizationRepresentation === true)){
            this.template.querySelector('c-owc-Claimant-Emplyee-Garment-Section-Cmp').handleClaimantChild(this.claimantDetails, this.isFormPreviewMode)
        }
        
        if(this.isRenderedCallback === true && this.isYourself === true && this.WageClaimSubmit != undefined){
            this.template.querySelector('[data-id="submitWageClaim"]').value = this.WageClaimSubmit
        }
        if(this.isRenderedCallback === true && this.representativeAdvocateType !== undefined && this.representativeAdvocateType !== null){
            this.template.querySelector('[data-id="representativeAdvocateType"]').value = this.representativeAdvocateType
        }
        // if(this.isRenderedCallback === true && this.individualRepPhoneType !== undefined){
        //     this.template.querySelector('[data-id="individualRepPhoneType"]').value = this.individualRepPhoneType
        // }
        // if(this.isRenderedCallback === true && this.individualRepClaimantRelationship != undefined){
        //     this.template.querySelector('[data-id="individualRepClaimantRelationship"]').value = this.individualRepClaimantRelationship
        // }
        // if(this.isRenderedCallback === true && this.claimantConfirmUploadDoc !== '' && this.isClaimantConfirmUpload === false){
        //     this.template.querySelector('c-owc-Multiple-File-Upload-Details-Cmp').getDocInfos(this.claimantConfirmUploadDoc, this.isFormPreviewMode )
        // }
        this.isRenderedCallback = false;
    }

     // Accepted Format for uploading files
     get acceptedFormats() {
        return acceptedFileFormat;
    }

    @api fileData = []

    handleOnDrop(event){
        const files = event.target.files;
    }

    @track contentVersionIds = []
    deleteExtraFiles(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            this.contentVersionIds.push(uploadedFiles[i].documentId);
        }
        deleteMultipleFiles({ contentVersionIds : JSON.stringify(this.contentVersionIds) })
           .then(result => {
               if(result){
                   
               }
           })
           .catch(error => {
           })
    }

    @api get isFileUploadDisabled(){
        return this.claimantConfirmUploadDoc.length >= 10 && this.isRenderedCallback === false;
    }

    @api totalUploadFiles = [];
    // @api errorFileSize = `You have only ${this.claimantConfirmUploadDoc.length} file size space.`
    @api toastFileUploadMsg = customLabelValues.OWC_fileupload_success_toast_msg
    @api toastFileDeleteMsg = customLabelValues.OWC_multiple_file_delete_toast_msg
    // Union Contract covered document handler
    handleClaimantConfirmUploadDoc(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        
        for(var i=0; i<uploadedFiles.length; i++){
            this.totalUploadFiles.push(uploadedFiles[i]);
        }
        if(this.totalUploadFiles.length <= 10){
            this.claimantConfirmUploadDoc = uploadedFiles;
            if(this.claimantConfirmUploadDoc != null){
                this.isClaimantConfirmUpload = false;
                this.isClaimantConfirmationRequiredMsg = false;
                this.claimantConfirmDocSize = this.claimantConfirmUploadDoc.length;
                this.template.querySelector('[data-id="claimantConfirmUploadId"]').getDocData(this.claimantConfirmUploadDoc, false);
                this.isRenderedCallback = false;
                this.showToast(customLabelValues.OWC_success_label, this.toastFileUploadMsg,'success');
            }
            else{
                this.isClaimantConfirmUpload = true
            }
        }
        else{
            this.deleteExtraFiles(uploadedFiles);
            this.handleFileLimit(uploadedFiles);
            this.showToast('Error!', this.customLabelValues.OWC_file_size_error,'error');
        }
        
    }

    handleFileLimit(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            for(var j=0; j<this.totalUploadFiles.length; j++){
                if(uploadedFiles[i].documentId === this.totalUploadFiles[j].documentId){
                    this.totalUploadFiles.splice(j , 1)
                }
            }
        }
    }

    updateFileVariables(){
        if(this.claimantConfirmUploadDoc !== undefined && this.claimantConfirmUploadDoc.length > 0){
            this.totalUploadFiles.length = 0;
            this.totalUploadFiles = this.claimantConfirmUploadDoc;
        }
    }

    // Union Contract event handler for multiple file upload cmp
    handleClaimantConfirmUploadEventDoc(event){
        this.claimantConfirmUploadDoc = event.detail.uploadcontractdoc
        this.updateFileVariables();
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ?  this.showToast(customLabelValues.OWC_success_label, this.toastFileDeleteMsg,'success') : ''
        this.claimantConfirmDocSize = this.claimantConfirmUploadDoc.length
    }

    handleSaveAsDraft(){
        this.handlePreliminaryEvent();
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "1"
            }
        });
        this.dispatchEvent(validateEvent);
    }

    // LWC Toast Function
    // Toast msg
    showToast(title, message, variant) {
       const event = new ShowToastEvent({
           title: title,
           message: message,
           variant: variant
       });
       this.dispatchEvent(event);
   }

}