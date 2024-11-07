import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import getCurrentUserDetails from '@salesforce/apex/OWCClaimantEmployeeInfoController.getCurrentUserDetails';
import getAccountDetails from '@salesforce/apex/OWCGarmentFormController.getRelatedAccount';
import verifyAddressByUSPS from '@salesforce/apex/OWCAddressCheckerUSPS.verifyAddressByUSPS';
import { radioOptions, customLabelValues, uspsRadioOption,acceptedFileFormat } from 'c/owcUtils';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import intakeOrigin from '@salesforce/apex/OWCGarmentFormController.intakeOrigin';
import mainMethod from '@salesforce/apex/OWCGarmentFormController.mainMethod';
import empDetails from '@salesforce/apex/OWCGarmentFormController.empDetails'
import { NavigationMixin } from 'lightning/navigation';
import employerData from '@salesforce/apex/OWCGarmentFormController.employerData';
import { CloseActionScreenEvent } from 'lightning/actions';



import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class OWCGarmentIntakeForm extends LightningElement {
     
    acceptedFormats = acceptedFileFormat
    @api recordId;
    
    @api isAdditionalClaimDocUpload = false
    @api isaccountid
    @api isFormPreviewMode = false
    @api isHelpText = false
    @api helpText
    @api submitclaim
    @track isLoading = false;
    @api countryCodeyourselfHomePhone
    @api countryCodeyourselfCellPhone
    @api countryCodeValue
    isCountryCodeChecked = false;
    @api isPicklistChanged = false
    @api accountId
    customLabelValues = customLabelValues
    intakeOriginList
    intakeOrigin
    caseRecDate
    @api workLocationZipCode
    @api currentrecordid
    @track claimentId
    @track isBirthdate = false
    @track isCaseRecDate = false
    @track isYourselfEmailNotValid = false

    options = radioOptions

    // Language Interpreter Section Attributes
    @api isPrefferedLanguage = false
    @api isOtherPrefferedLanguage = false
    @api needLanguageInterpreter
    @api prefferedLanguageSelection
    @api otherPrefferedLanguage
    @api isRenderedCallback = false
    @api getPicklistValues = []

    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    // Claimant/Employee Section Attributes
    @api employerName
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
    @api isMultipleRequiredCheck = false
    @api ValidationMsg = ''
    @api OWCPrefferedLanguageAssistantDatas
    @api additonalClaimDocSize

    @api statePicklistValues;

    @api claimantEmployeeSectionDetails

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

    @api uspsRadioOption = uspsRadioOption
    @track date
    @track dockingDate
    @track empId

    @track name;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.name = data.fields.Name.value;
            console.log('Current User Name:::',this.name);
        }
    }

    // @wire(employerData,{
    //     employerId: this.currentrecordid
    // })
    // wiredemployerData({ error, data }) {
    //     console.log('$currentrecordid::',this.currentrecordid)
    //     if (data) {
    //         console.log('Employeer Data::',data);
    //         this.employerName = data.Name
    //         this.error = undefined;
    //     } else if (error) {
    //         this.error = error;
    //     }
    // }


    @wire(employerData,{
        employerId: '$recordId'
    })
    wiredemployerData({ error, data }) {
        console.log('$currentrecordid::',this.recordId)
        if (data) {
            console.log('Employeer Data::',data);
            this.employerName = data.Name
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(intakeOrigin)
    wiredIntakeOrigin({ error, data }) {
        if (data) {
            console.log('Intake Data::',data);
            this.intakeOriginList = data
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(empDetails)
    wiredempDetails({error,data}){
        if(data){
            console.log('Emp List::',JSON.stringify(data))
        }else{
            this.error =  error;
        }
    }

    @wire(getAccountDetails,{
        recordId: '$recordId'
    })
    wiredgetAccountDetails({ error, data }) {
        console.log('$currentrecordid::',this.recordId)
        if (data) {
            console.log('Account :: ' ,data)
            this.yourselfFirstName = data.FirstName
            this.yourselfLastName = data.LastName
            this.yourselfMiddleName = data.MiddleName
            this.yourselfBirthDate = data.PersonBirthdate
            this.yourselfCellPhone = data.PersonMobilePhone
            this.yourselfHomePhone = data.PersonHomePhone
            this.yourselfEmail = data.PersonEmail
            this.yourselfStreetAddress = data.ShippingStreet
            this.yourselfCity = data.ShippingCity
            this.yourselfState = data.ShippingState
            this.yourselfZipCode = data.ShippingPostalCode
            this.claimentId = data.Id
            console.log('Account FirstName:: ' ,data.FirstName)
            console.log('emp Name::',this.employerName)
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
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

        var today = new Date();
        this.dockingDate=today.toISOString();
        console.log(today.toISOString())

    // getAccountDetails({recordId: '$recordId'})
    // .then(data => {
    //     console.log('Account :: ' ,data)
    //         // this.yourselfFirstName = data.FirstName
    //         // this.yourselfLastName = data.LastName
    //         // this.yourselfMiddleName = data.MiddleName
    //         // this.yourselfBirthDate = data.PersonBirthdate
    //         // this.yourselfCellPhone = data.PersonMobilePhone
    //         // this.yourselfHomePhone = data.PersonHomePhone
    //         // this.yourselfEmail = data.PersonEmail
    //         // this.yourselfStreetAddress = data.ShippingStreet
    //         // this.yourselfCity = data.ShippingCity
    //         // this.yourselfState = data.ShippingState
    //         // this.yourselfZipCode = data.ShippingPostalCode
    //         // this.claimentId = data.Id
    //         console.log('Account FirstName:: ' ,data.FirstName)
    //         console.log('emp Name::',this.employerName)
        
    // })
    // .catch(error => {
    //     this.error = error;
    // });
     console.log("AccId"+this.accountId);
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
    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data, error }){
        if(data){
            console.log('data:', JSON.stringify(data));
            this.statePicklistValues = data[0].statePicklist;
            this.countryCodeValue = data[0].owcCountryCodeList;
            this.OWCPrefferedLanguageAssistantDatas = data[0].languageAssitantPrefferedLanguages;
            this.countryCodeyourselfCellPhone = '+1';
            this.countryCodeyourselfHomePhone = '+1';
            this.yourselfState = 'CA';
                }
        else if(error){
            this.error = error;
        }
    }

    handleLastNameFocus(){
        let yourselfLastName = this.template.querySelector('[data-id="yourselfLastName"]');
        if(yourselfLastName.value.trim() == undefined || yourselfLastName.value.trim() == null || yourselfLastName.value.trim() == ''){
            yourselfLastName.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
        }
        else{
            yourselfLastName.setCustomValidity("");
        }
        yourselfLastName.reportValidity();
}

handleFirstNameFocus(){
let yourselfFirstName = this.template.querySelector('[data-id="yourselfFirstName"]');
        if(yourselfFirstName.value.trim() == undefined || this.yourselfFirstName.trim() == '' || this.yourselfFirstName.trim() == null){
            yourselfFirstName.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
        }
        else{
            yourselfFirstName.setCustomValidity("");
        }
        yourselfFirstName.reportValidity();
}

handleHomePhoneFocus(){
let yourselfHomePhone = this.template.querySelector('[data-id="yourselfHomePhone"]');
        if(yourselfHomePhone.value.trim() == undefined || yourselfHomePhone.value.trim() == null || yourselfHomePhone.value.trim() == ''){
            yourselfHomePhone.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
        }
        else{
            yourselfHomePhone.setCustomValidity("");
        }
        yourselfHomePhone.reportValidity();
}

handleCellPhoneFocus(){
let isCellPhoneEntered = this.template.querySelector('[data-id="isCellPhoneEntered"]');
        if(isCellPhoneEntered.value.trim() == undefined || isCellPhoneEntered.value.trim() == null || isCellPhoneEntered.value.trim() == ''){
            isCellPhoneEntered.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
        }
        else{
            isCellPhoneEntered.setCustomValidity("");
        }
        isCellPhoneEntered.reportValidity();
}

handleBirthDateFocus(){
let yourselfBirthDate = this.template.querySelector('[data-id="yourselfBirthDate"]');
var inputBirthDate
let today = new Date(); 
if(yourselfBirthDate.value != null){
    inputBirthDate = new Date(yourselfBirthDate.value.toString());
}
else{
    inputBirthDate = yourselfBirthDate.value;
}
        if(yourselfBirthDate.value == undefined || yourselfBirthDate.value == null || yourselfBirthDate.value == ''){
            yourselfBirthDate.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isBirthdate = true;
        }
        else if(inputBirthDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            yourselfBirthDate.setCustomValidity(customLabelValues.OWC_invalid_claimant_birthdate_error_msg);
            this.isBirthdate = true;
        }
        else{
            yourselfBirthDate.setCustomValidity("");
            this.isBirthdate = false;
        }
        yourselfBirthDate.reportValidity();
}


handleCaseRecDateFocus(){
    let caseRecDate = this.template.querySelector('[data-id="caseRecDate"]');
    var inputBirthDate
    let today = new Date(); 
    const tomorrow = new Date(today)
    tomorrow.setDate(tomorrow.getDate() + 1)
    if(caseRecDate.value != null){
        inputBirthDate = new Date(caseRecDate.value.toString());
    }
    else{
        inputBirthDate = caseRecDate.value;
    }
            if(caseRecDate.value == undefined || caseRecDate.value == null || caseRecDate.value == ''){
                caseRecDate.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                this.isCaseRecDate = true;
            }
            else if(inputBirthDate.setHours(0,0,0,0) >= tomorrow.setHours(0,0,0,0)){
                caseRecDate.setCustomValidity("Case Received Date should be less than tomorrow's date");
                this.isCaseRecDate = true;
            }
            else{
                caseRecDate.setCustomValidity("");
                this.isCaseRecDate = false;
            }
            caseRecDate.reportValidity();
    }

    handleIntakeOriginFocus(){
        let intakeOrigin = this.template.querySelector('[data-id="intakeOrigin"]');
                if(intakeOrigin.value.trim() == undefined || this.intakeOrigin.trim() == '' || this.intakeOrigin.trim() == null){
                    intakeOrigin.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    intakeOrigin.setCustomValidity("");
                }
                intakeOrigin.reportValidity();
        }

handleZipCodeFocus(){
    const yourselfZipCode = this.template.querySelector('[data-id="yourselfZipCode"');
    if(yourselfZipCode.value === undefined || yourselfZipCode.value === null || yourselfZipCode.value.trim() === ''){
        yourselfZipCode.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
    }
    else if(yourselfZipCode.value.match(this.zipCodeRegrex)){
        yourselfZipCode.setCustomValidity('')
    }
    else{
        yourselfZipCode.setCustomValidity(customLabelValues.OWC_invalid_zipcode_msg)
    }
    yourselfZipCode.reportValidity()
}


handleOtherLanguageFocus(){
    let otherPrefferedLanguage = this.template.querySelector('[data-id="otherPrefferedLanguage"]');
            if(otherPrefferedLanguage.value.trim() == undefined || otherPrefferedLanguage.value.trim() == null || otherPrefferedLanguage.value.trim() == ''){
                otherPrefferedLanguage.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            }
            else{
                otherPrefferedLanguage.setCustomValidity("");
            }
            otherPrefferedLanguage.reportValidity();
}

preliminarySectionValidityChecker(ids, values){
    let id = ids
    let value = values
    console.log('yourselfFirstNameValue:', value);
    const val = value == undefined || value == null ? '' : value
    if(val.trim() == ""){
        id.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
        id.reportValidity();
        return true;
    }
}

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

preliminarySectionBirthdayValidityChecker(ids, values){
    let id = ids
    let value = values
    var inputDate
    var today = new Date();
    if(value != null){
        inputDate = new Date(value.toString());
    }
    else{
        inputDate = value;
    }
    if(value == null || value == undefined || value == ''){
        id.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
        id.reportValidity();
    return true;
    }
    else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
        id.setCustomValidity('Please select past date.');
        id.reportValidity();
    return true;
    }
}

    regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    regExpPhone = /^[0-9]{10}$/ ;
    zipCodeRegrex = /^\d{5}(?:[-\s]\d{4})?$/; //^[0-9]{5}(?:[0-9]{4})?$/;
    urlAddressChekerRegrex = /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$/;

    handleSuccessWithCurrentAddress(event){
        // Reset above all radio button in datatable
        var inputTemplate = this.template.querySelectorAll('[data-id="radioInputId"]');
            for(var i=0; i < inputTemplate.length; i++){
                this.selectedAddressIndex === undefined ? '' : inputTemplate[this.selectedAddressIndex].checked = false
            }
            this.selectedAddressIndex = undefined
        const succesWithCurrentAddress = event.target.checked;
        console.log('event ::: ', succesWithCurrentAddress);
        this.succesWithCurrentAddress = succesWithCurrentAddress
        this.isRenderedCallback = false;
    }

    handleAdditionalClaimDoc(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.addtionalClaimDocs = uploadedFiles;
        if(uploadedFiles != null){
            this.isAdditionalClaimDocUpload = false
            this.additonalClaimDocSize = this.addtionalClaimDocs.length
            this.template.querySelector('c-owc-Multiple-File-Upload-Details-Cmp').getDocData(this.addtionalClaimDocs);
            this.isRenderedCallback = false
            this.showToast('Success!',this.toastFileUploadMsg,'success');
        }
        else{
            this.isAdditionalClaimDocUpload = true
        }
        // alert("No. of files uploaded : " + JSON.stringify(uploadedFiles));
    }

    handleAdditonalClaimDocEvent(event){
        console.log('event.detail:', JSON.stringify(event.detail));
        this.addtionalClaimDocs = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.additonalClaimDocSize = this.addtionalClaimDocs.length
    }
    
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
                        // case "yourselfFirstName":
                        //     this.yourselfFirstName = event.detail.value;
                        //     this.handleFirstNameFocus();
                        //     console.log('yourselfFirstName :::', this.yourselfFirstName);
                        //     break;
                        // case "yourselfLastName":            
                        //     this.yourselfLastName = event.detail.value;
                        //     this.handleLastNameFocus();
                        //     console.log('yourselfLastName :::', this.yourselfLastName);
                        //     break;
                        // case "yourselfMiddleName":
                        //     this.yourselfMiddleName = event.detail.value;
                        //     console.log('yourselfMiddleName :::', this.yourselfMiddleName);
                        //     break;
                        // case "yourselfHomePhone":
                        //     this.yourselfHomePhone = event.target.value;
                        //     // this.handleYourselfHomePhoneFocus();
                        //     this.handleYourselfHomePhoneValidation();
                        //     this.handleRequiredSetValidation();
                        //     console.log('yourselfHomePhone :::', this.yourselfHomePhone);
                        //     break;
                        // case "yourselfCellPhone":
                        //     this.yourselfCellPhone = event.target.value;
                        //     // this.handleYourselfCellPhoneFocus();
                        //     this.handleYourselfCellPhoneValidation();
                        //     this.handleRequiredSetValidation();
                        //     console.log('yourselfCellPhone :::', this.yourselfCellPhone);
                        //     break;
                        // case "countryCodeyourselfCellPhone":
                        //     this.countryCodeyourselfCellPhone = event.target.value;
                        //     console.log('countryCodeyourselfCellPhone :::', this.countryCodeyourselfCellPhone);
                        //     break;
                        // case "countryCodeyourselfHomePhone":
                        //     this.countryCodeyourselfHomePhone = event.target.value;
                        //     console.log('countryCodeyourselfHomePhone :::', this.countryCodeyourselfHomePhone);
                        //     break;
                        // case "cellPhoneEntered":
                        //     this.isCellPhoneEntered = event.target.checked;
                        //     console.log('isCellPhoneEntered :::', this.isCellPhoneEntered);
                        //     break;
                        // case "yourselfBirthDate":
                        //     this.yourselfBirthDate = event.target.value;
                        //     this.handleBirthDateFocus();
                        //     console.log('yourselfBirthDate :::', this.yourselfBirthDate);
                        //     break;
                        // case "yourselfEmail":
                        //     this.yourselfEmail = event.target.value;
                        //     // this.handleYourselfEmailFocus();
                        //     this.handleRequiredSetValidation();
                        //     this.handleYourselfEmailValidation();
                        //     console.log('yourselfEmail :::', this.yourselfEmail);
                        //     break;
                        // case "yourselfStreetAddress":
                        //     this.yourselfStreetAddress = event.target.value;
                        //     console.log('yourselfStreetAddress :::', this.yourselfStreetAddress);
                        //     break;
                        // case "yourselfCity":
                        //     this.yourselfCity = event.target.value;
                        //     console.log('yourselfCity :::', this.yourselfCity);
                        //     break;
                        // case "yourselfState":
                        //     this.yourselfState = event.target.value;
                        //     this.isPicklistChanged = true
                        //     // this.handleStatePicklistBlur();
                        //     console.log('yourselfState :::', this.yourselfState);
                        //     break;
                        // case "yourselfZipCode":
                        //     this.yourselfZipCode = event.target.value;
                        //     if(event.target.value.length >= 5 && this.yourselfZipCode.includes('-')){
                        //         this.template.querySelector('[data-id="yourselfZipCode"]').value = event.target.value;
                        //     }
                        //     else if(event.target.value.length === 6){
                        //         this.template.querySelector('[data-id="yourselfZipCode"]').value = event.target.value.replace(/(\d{5})/, "$1-");
                        //     }
                        //     this.yourselfZipCode = event.target.value;
                        //     console.log('yourselfZipCode :::', event.target.value);
                        //     this.handleZipCodeFocus();
                        //     break;
                        case "needLanguageInterpreter":
                            this.needLanguageInterpreter = event.target.value;
                            //this.handleLanguageInterpreterFocus();
                            if(this.needLanguageInterpreter === "Yes"){
                                this.isPrefferedLanguage = true
                            }
                            else{
                                this.isPrefferedLanguage = false
                                this.isOtherPrefferedLanguage = false
                            }
                            console.log('needLanguageInterpreter :::', this.needLanguageInterpreter);
                            break;
                        case "prefferedLanguageSelection":
                            this.prefferedLanguageSelection = event.target.value;
                            if(this.prefferedLanguageSelection === 'Other'){
                                this.isOtherPrefferedLanguage = true
                            }
                            else if(event.target.value === this.OWCPrefferedLanguageAssistantDatas[0].label){
                                this.prefferedLanguageSelection = undefined
                                this.isOtherPrefferedLanguage = false
                            }
                            else{
                                this.isOtherPrefferedLanguage = false
                            }
                            console.log('prefferedLanguageSelection :::', this.prefferedLanguageSelection);
                            break;
                        case "otherPrefferedLanguage":
                            this.otherPrefferedLanguage = event.target.value;
                            this.handleOtherLanguageFocus();
                            console.log('otherPrefferedLanguage :::', this.otherPrefferedLanguage);
                            break;
                            
                        case "caseRecDate":
                            this.caseRecDate = event.target.value;
                            this.handleCaseRecDateFocus()
                            console.log('caseRecDate :::', this.caseRecDate);
                            break;
                        // case "workLocationZipCode":
                        //     this.workLocationZipCode = event.target.value;
                        //     console.log('workLocationZipCode :::', this.workLocationZipCode);
                        //     break;    
                        case "intakeOrigin":
                            this.intakeOrigin = event.target.value;
                            this.handleIntakeOriginFocus()
                            console.log('intakeOrigin :::', this.intakeOrigin);
                            break;
        }
    }

    
    

    @api
    handleClaimantEvent(){
        return  { 
            yourselfFirstName : this.yourselfFirstName,
            yourselfLastName : this.yourselfLastName,
            yourselfMiddleName : this.yourselfMiddleName,
            yourselfHomePhone : this.yourselfHomePhone,
            yourselfHomePhone : this.yourselfHomePhone,
            yourselfCellPhone : this.yourselfCellPhone,
            countryCodeyourselfCellPhone : this.countryCodeyourselfCellPhone,
            countryCodeyourselfHomePhone : this.countryCodeyourselfHomePhone,
            cellPhoneEntered : this.cellPhoneEntered,
            isCellPhoneEntered : this.isCellPhoneEntered,
            yourselfBirthDate : this.yourselfBirthDate,
            yourselfEmail : this.yourselfEmail,
            yourselfStreetAddress : this.yourselfStreetAddress,
            yourselfCity : this.yourselfCity,
            yourselfState : this.yourselfState,
            yourselfZipCode : this.yourselfZipCode,
            needLanguageInterpreter : this.needLanguageInterpreter,
            isPrefferedLanguage : this.isPrefferedLanguage,
            isOtherPrefferedLanguage : this.isOtherPrefferedLanguage,
            prefferedLanguageSelection : this.prefferedLanguageSelection,
            otherPrefferedLanguage : this.otherPrefferedLanguage,
            caseRecDate : this.caseRecDate,
            //workLocationZipCode : this.workLocationZipCode,
            intakeOrigin : this.intakeOrigin,
            dockingDate : this.dockingDate,
            name : this.name,
            recordId : this.currentrecordid,
            employerName : this.employerName,
            isAdditionalClaimDocUpload : this.isAdditionalClaimDocUpload,
            additonalClaimDocSize : this.additonalClaimDocSize,
         }
    }

   

    
    handleYourselfCellPhoneValidation(){
        let yourselfCellPhone = this.template.querySelector('[data-id="yourselfCellPhone"]');
        if(yourselfCellPhone.value === undefined || yourselfCellPhone.value === null || yourselfCellPhone.value === ''){
            this.isYourselfCellPhoneNotValid = false
        }
        else{
            if(yourselfCellPhone.value.match(this.regExpPhone)){
                yourselfCellPhone.setCustomValidity("");
                this.isYourselfCellPhoneNotValid = false
                yourselfCellPhone.reportValidity();
            }
            else{
                yourselfCellPhone.setCustomValidity(customLabelValues.OWC_invalid_phone_msg);
                this.isYourselfCellPhoneNotValid = true
                yourselfCellPhone.reportValidity();
            }
        } 
    }

    handleYourselfHomePhoneValidation(){
        let yourselfHomePhone = this.template.querySelector('[data-id="yourselfHomePhone"]');
        if(yourselfHomePhone.value === undefined || yourselfHomePhone.value === null || yourselfHomePhone.value === ''){
            this.isYourselfHomePhoneNotValid = false
        }
        else{
            if(yourselfHomePhone.value.match(this.regExpPhone)){
                yourselfHomePhone.setCustomValidity("");
                this.isYourselfHomePhoneNotValid = false
                yourselfHomePhone.reportValidity();
            }
            else{
                yourselfHomePhone.setCustomValidity(customLabelValues.OWC_invalid_phone_msg);
                this.isYourselfHomePhoneNotValid = true
                yourselfHomePhone.reportValidity()
            }
        }
    }

    handleYourselfEmailValidation(){
        let yourselfEmail = this.template.querySelector('[data-id="yourselfEmail"]');
        if(yourselfEmail.value === undefined || yourselfEmail.value === null || yourselfEmail.value === ''){
            this.isYourselfEmailNotValid = false
        }
        else{
            if(yourselfEmail.value.match(this.regExpEmailformat)){
                yourselfEmail.setCustomValidity("");
                this.isYourselfEmailNotValid = false
                yourselfEmail.reportValidity();
            } 
            else{
                yourselfEmail.setCustomValidity(customLabelValues.OWC_invalid_email_msg);
                this.isYourselfEmailNotValid = true
                yourselfEmail.reportValidity();
            }
        }
    }


    handleRequiredSetValidation(){
        let yourselfCellPhone = this.template.querySelector('[data-id="yourselfCellPhone"]');
        let yourselfHomePhone = this.template.querySelector('[data-id="yourselfHomePhone"]');
        let yourselfEmail = this.template.querySelector('[data-id="yourselfEmail"]');
        let yourselfCellPhoneCondition = (yourselfCellPhone.value === undefined || yourselfCellPhone.value === null || yourselfCellPhone.value === '');
        let yourselfHomePhoneCondition = (yourselfHomePhone.value === undefined || yourselfHomePhone.value === null || yourselfHomePhone.value === '');
        let yourselfEmailCondition = (yourselfEmail.value === undefined || yourselfEmail.value === null || yourselfEmail.value === '');
        if(yourselfCellPhoneCondition && yourselfHomePhoneCondition && yourselfEmailCondition){
            this.isRequiredSet = true;
            this.isMultipleRequiredCheck = true
            this.ValidationMsg = customLabelValues.OWC_claimant_employee_required_msg
            return true;
        }
        else{
            this.isMultipleRequiredCheck = false
            return false
        }
    }

    isFirstName = false
    isLastName = false
    isHomePhone = false
    isCellPhone = false
    isBirthdate = false
    isZipCode = false
    isCellPhoneValid = false
    isHomePhoneValid = false
    isValidationSet = false
    isCaseRecDate = false
    isIntakeOrigin = false


    @api
    handleFormSubmit(event){
            // let yourselfFirstName = this.template.querySelector('[data-id="yourselfFirstName"]');
            // let yourselfFirstNameValue = this.yourselfFirstName
            // let yourselfLastName = this.template.querySelector('[data-id="yourselfLastName"]');
            // let yourselfLastNameValue = this.yourselfLastName
            // let yourselfBirthDate = this.template.querySelector('[data-id="yourselfBirthDate"]');
            // let yourselfBirthDateValue = this.yourselfBirthDate
            // let yourselfZipCode = this.template.querySelector('[data-id="yourselfZipCode"]');
            // let yourselfZipCodeValue = this.yourselfZipCode
            // let yourselfCellPhone = this.template.querySelector('[data-id="yourselfCellPhone"]');
            // let yourselfCellPhoneValue = this.yourselfCellPhone
            // let yourselfHomePhone = this.template.querySelector('[data-id="yourselfHomePhone"]');
            // let yourselfHomePhoneValue = this.yourselfHomePhone
            // let yourselfEmail = this.template.querySelector('[data-id="yourselfEmail]');
            // let yourselfEmailValue = this.yourselfEmail
            let caseRecDate = this.template.querySelector('[data-id="caseRecDate"]');
            let caseRecDateValue = this.caseRecDate
            let intakeOrigin = this.template.querySelector('[data-id="intakeOrigin"]');
            let intakeOriginValue = this.intakeOrigin

            
            
            // this.isFirstName = this.preliminarySectionValidityChecker(yourselfFirstName, yourselfFirstNameValue);
            // this.isLastName = this.preliminarySectionValidityChecker(yourselfLastName, yourselfLastNameValue);
            // this.handleBirthDateFocus();
            // this.isZipCode = this.preliminarySectionValidityChecker(yourselfZipCode, yourselfZipCodeValue);
            // this.isCellPhoneValid = this.phoneValidityChecker(yourselfCellPhone, yourselfCellPhoneValue);
            //this.isHomePhoneValid = this.phoneValidityChecker(yourselfHomePhone, yourselfHomePhoneValue);
            this.isIntakeOrigin = this.preliminarySectionValidityChecker(intakeOrigin, intakeOriginValue);

            // this.handleYourselfCellPhoneValidation();
            // this.handleYourselfHomePhoneValidation();
            // this.handleYourselfEmailValidation();
            this.handleCaseRecDateFocus(); 
            //this.isValidationSet = this.handleRequiredSetValidation();

            // if(yourselfZipCode.value.trim() == null || yourselfZipCode.value.trim() == undefined || yourselfZipCode.value.trim() == ''){
            //     this.isZipCodeValid = true
            //     yourselfZipCode.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            //     yourselfZipCode.reportValidity()
            // }
            // else if(yourselfZipCode.value.trim() != null || yourselfZipCode.value.trim() != undefined || yourselfZipCode.value.trim() != ''){
            //     const yourselfZipCode = this.template.querySelector('[data-id="yourselfZipCode"]');
            //     if(yourselfZipCode.value.match(this.zipCodeRegrex)){
            //         yourselfZipCode.setCustomValidity("");
            //         this.isZipCodeValid = false
            //         yourselfZipCode.reportValidity()
            //     }
            //     else{
            //         yourselfZipCode.setCustomValidity(customLabelValues.OWC_invalid_zipcode_msg);
            //         this.isZipCodeValid = true
            //         yourselfZipCode.reportValidity()
            //     }                
            // }
            // else{
            //     this.isZipCodeValid = false
            // }


            // this.isFirstName === true ? yourselfFirstName.focus() : ''
            // this.isLastName === true ? yourselfLastName.focus() : ''
            // this.isBirthdate === true ? yourselfBirthDate.focus() : ''
            this.isCaseRecDate === true ? caseRecDate.focus() : ''
            this.isIntakeOrigin === true ? intakeOrigin.focus() : ''
            // this.isValidationSet === true || this.isYourselfCellPhoneNotValid === true ? yourselfCellPhone.focus() : ''
            // this.isValidationSet === true || this.isYourselfHomePhoneNotValid === true ? yourselfHomePhone.focus() : ''
            // this.isValidationSet === true || this.isYourselfEmailNotValid === true ? yourselfEmail.focus() : ''
            // this.isZipCodeValid === true ? yourselfZipCode.focus() : ''
            // this.isZipCode === true ? yourselfZipCode.focus() : ''
            
            if( this.isCaseRecDate === true || this.isIntakeOrigin === true){
                const validateEvent = new CustomEvent('claimantvaliditychecker', {
                    detail: {
                        isValidityTrue : true
                    }
                });
                this.dispatchEvent(validateEvent);
            }
            else{
                this.handleSubmit();
            }
        
    }

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
    }

    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        console.log('helpTextValue:', JSON.stringify(helpTextValue));
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    renderedCallback(){
        if(this.isRenderedCallback === true && this.yourselfState != undefined){
            this.template.querySelector('[data-id="yourselfState"]').value = this.yourselfState
        }

        if(this.isRenderedCallback === true && this.uspsCurrentAddressCheck === true){
            this.template.querySelector('[data-id="uspsCurrentAddressCheck"]').checked = 'Yes'
        }
        if(this.isRenderedCallback === true && this.needLanguageInterpreter != undefined){
            this.template.querySelector('[data-id="needLanguageInterpreter"]').value = this.needLanguageInterpreter
        }
        if(this.isRenderedCallback === true && this.prefferedLanguageSelection != undefined && this.isPrefferedLanguage === true){
            this.template.querySelector('[data-id="prefferedLanguageSelection"]').value = this.prefferedLanguageSelection
        }
        if(this.isRenderedCallback === true && this.yourselfBirthDate != null){
            this.template.querySelector('[data-id="yourselfBirthDate"]').value = this.yourselfBirthDate
        }
        this.isRenderedCallback = false;
    }

    

    handleSubmit(event){
        this.isLoading = true;
        //const redirectUrl = `${window.location.origin}/lightning/r/Account/${this.recordId}/view`;
        mainMethod({
            inTakeData : JSON.stringify(this.handleClaimantEvent()),
            claimentId : this.claimentId,
            addDocData : JSON.stringify(this.addtionalClaimDocs)})
            .then(result => {
                if(Boolean(result)){
                    this.showToast('Success', 'Record has been successfully created.', 'success');
                    this.isLoading = false;
                    const redirectUrl = `${window.location.origin}/lightning/r/Account/${result}/view`;
                    window.open(redirectUrl, '_self');
                }
                console.log('Result:::',result)
            })
            .catch(error => {
                this.error = error;
                // this.showToast('Error!', error.body.message, 'error')
            }); 
    }

    handelCancel(event){
        const redirectUrl = `${window.location.origin}/lightning/r/Account/${this.recordId}/view`;
        window.open(redirectUrl, '_self');
    }

}