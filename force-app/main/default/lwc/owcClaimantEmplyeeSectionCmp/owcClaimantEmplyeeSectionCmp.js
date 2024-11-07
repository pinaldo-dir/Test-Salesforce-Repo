import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import getCurrentUserDetails from '@salesforce/apex/OWCClaimantEmployeeInfoController.getCurrentUserDetails';
import verifyAddressByUSPS from '@salesforce/apex/OWCAddressCheckerUSPS.verifyAddressByUSPS';
import { radioOptions, customLabelValues, uspsRadioOption } from 'c/owcUtils';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
// import getPicklistValues from '@salesforce/apex/OwcPreliminarySectionController.getPicklistValues';
// import getStatePicklistData from '@salesforce/apex/OwcCommunitySelfRegisterCtrl.initializeComponent';
//import OWC_required_field_error_msg from '@salesforce/apex/OwcPreliminarySectionController.OWC_required_field_error_msg';
// import getRepAdvocateTypeMetaData from '@salesforce/apex/OwcPreliminarySectionController.getRepAdvocateTypeMetaData';
// import getIndividualRepPhoneTypeMetaData from '@salesforce/apex/OwcPreliminarySectionController.getIndividualRepPhoneTypeMetaData';
// import getIndividualRepClaimantRelationship from '@salesforce/apex/OwcPreliminarySectionController.getIndividualRepClaimantRelationship';
// import getPreliminaryCovidClaimValues from '@salesforce/apex/OwcPreliminarySectionController.getPreliminaryCovidClaimValues';
// import custom labels for preliminary wage claim section 

export default class OwcClaimantEmplyeeSectionCmp extends LightningElement {
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

    customLabelValues = customLabelValues

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
    @api yourselfFirstName
    @api yourselfLastName
    @api yourselfMiddleName
    @api yourselfHomePhone
    @api yourselfCellPhone
    @api yourselfAlternatePhone
    @api yourselfAlternateContact
    @api isCellPhoneEntered
    @api isHomePhoneEntered
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
    
        getCurrentUserDetails({})
           .then(result => {
               if(result){
                   console.log('result ::: ', JSON.stringify(result));
                   if(this.submitclaim === 'Yourself'){
                    this.yourselfFirstName != null ? this.yourselfFirstName = this.yourselfFirstName : this.yourselfFirstName = result.firstName
                    this.yourselfLastName != null ? this.yourselfLastName = this.yourselfLastName : this.yourselfLastName = result.lastName
                    this.yourselfMiddleName != null ? this.yourselfMiddleName = this.yourselfMiddleName : this.yourselfMiddleName = result.middleName
                    this.yourselfBirthDate != null ? this.yourselfBirthDate = this.yourselfBirthDate : this.yourselfBirthDate = result.birthDate
                    this.yourselfCellPhone != null ? this.yourselfCellPhone = this.yourselfCellPhone : this.yourselfCellPhone = result.cellPhone
                    this.yourselfHomePhone != null ? this.yourselfHomePhone = this.yourselfHomePhone : this.yourselfHomePhone = result.homePhone
                    this.yourselfAlternatePhone != null ? this.yourselfAlternatePhone = this.yourselfAlternatePhone : this.yourselfAlternatePhone = result.alternatePhone
                    this.yourselfAlternateContact != null ? this.yourselfAlternateContact = this.yourselfAlternateContact : this.yourselfAlternateContact = result.alternateContact
                    this.yourselfEmail != null ? this.yourselfEmail = this.yourselfEmail : this.yourselfEmail = result.email
                    this.yourselfStreetAddress != null ? this.yourselfStreetAddress = this.yourselfStreetAddress : this.yourselfStreetAddress = result.streetAddress
                    this.yourselfCity != null ? this.yourselfCity = this.yourselfCity : this.yourselfCity = result.city;
                    this.yourselfState != null ? this.yourselfState = this.yourselfState : result.state == null ? this.yourselfState = '' : this.yourselfState = result.state;
                    //result.city != null ? this.yourselfCity = this.yourselfCity : this.yourselfCity = result.city 
                 //    result.state === null ? this.template.querySelector('[data-id="yourselfState"]').value = 'CA' : this.template.querySelector('[data-id="yourselfState"]').value = result.state
                 this.yourselfZipCode != null ? this.yourselfZipCode = this.yourselfZipCode : this.yourselfZipCode = result.zipCode
                }
                else{
                    this.yourselfState = '';
                }
               }
           })
           .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
               console.log('Error: ', error);
           })
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

handleStreetAddressFocus(){
    let yourselfStreetAddress = this.template.querySelector('[data-id="yourselfStreetAddress"]');
            if(yourselfStreetAddress.value.trim() == undefined || this.yourselfStreetAddress.trim() == '' || this.yourselfStreetAddress.trim() == null){
                yourselfStreetAddress.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            }
            else{
                yourselfStreetAddress.setCustomValidity("");
            }
            yourselfStreetAddress.reportValidity();
 }

 handleCityFocus(){
    let yourselfCity = this.template.querySelector('[data-id="yourselfCity"]');
            if(yourselfCity.value.trim() == undefined || this.yourselfCity.trim() == '' || this.yourselfCity.trim() == null){
                yourselfCity.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            }
            else{
                yourselfCity.setCustomValidity("");
            }
            yourselfCity.reportValidity();
 }

 handleStateFocus(){
    let yourselfState = this.template.querySelector('[data-id="yourselfState"]');
            if(yourselfState.value.trim() == undefined || this.yourselfState.trim() == '' || this.yourselfState.trim() == null || this.yourselfState.value.trim() == 'N/A'){
                yourselfState.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            }
            else{
                yourselfState.setCustomValidity("");
            }
            yourselfState.reportValidity();
 }

 handleYourselfEmailFocus(){
    let yourselfEmail = this.template.querySelector('[data-id="yourselfEmail"]');
            if(yourselfEmail.value.trim() == undefined || this.yourselfEmail.trim() == '' || this.yourselfEmail.trim() == null){
                yourselfEmail.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            }
            else{
                yourselfEmail.setCustomValidity("");
            }
            yourselfEmail.reportValidity();
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

handleAlternatePhoneFocus(){
    let yourselfAlternatePhone = this.template.querySelector('[data-id="yourselfAlternatePhone"]');
            if(yourselfAlternatePhone.value.trim() == undefined || yourselfAlternatePhone.value.trim() == null || yourselfAlternatePhone.value.trim() == ''){
                yourselfAlternatePhone.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            }
            else{
                yourselfAlternatePhone.setCustomValidity("");
            }
            yourselfAlternatePhone.reportValidity();
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
        else if(Boolean(inputBirthDate) && inputBirthDate.getYear() < 0){
            yourselfBirthDate.setCustomValidity(customLabelValues.OWC_Invalid_BirthDate);
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

// handleYourselfHomePhoneFocus(event){
//     this.handleRequiredSetValidation();
//     // const yourselfHomePhone = event.target.value
//     // if(yourselfHomePhone.trim() == null || yourselfHomePhone.trim() == undefined || yourselfHomePhone.trim() == ''){
//     //     this.isMultipleRequiredCheck = false
//     //     this.ValidationMsg = customLabelValues.OWC_claimant_employee_required_msg
//     // }
//     // else if(yourselfHomePhone.trim() != null || yourselfHomePhone.trim() != undefined || yourselfHomePhone.trim() != ''){
//     //     const yourselfHomePhone = this.template.querySelector('[data-id="yourselfHomePhone"]');
//     //     if(this.yourselfHomePhone.match(this.regExpPhone)){
//     //         yourselfHomePhone.setCustomValidity("");
//     //     }
//     //     else{
//     //         yourselfHomePhone.setCustomValidity(customLabelValues.OWC_invalid_phone_msg);
//     //     }
//     //     yourselfHomePhone.reportValidity()
//     //     this.isMultipleRequiredCheck = true
//     // }
// }

// handleYourselfCellPhoneFocus(event){
//     this.handleRequiredSetValidation();
//     // const yourselfCellPhone = event.target.value
//     // if(yourselfCellPhone.trim() == null || yourselfCellPhone.trim() == undefined || yourselfCellPhone.trim() == ''){
//     //     this.isMultipleRequiredCheck = false
//     //     this.ValidationMsg = customLabelValues.OWC_claimant_employee_required_msg
//     // }
//     // else if(yourselfCellPhone.trim() != null || yourselfCellPhone.trim() != undefined || yourselfCellPhone.trim() != ''){
//     //     const yourselfCellPhone = this.template.querySelector('[data-id="yourselfCellPhone"]');
//     //     if(this.yourselfCellPhone.match(this.regExpPhone)){
//     //         yourselfCellPhone.setCustomValidity("");
//     //     }
//     //     else{
//     //         yourselfCellPhone.setCustomValidity(customLabelValues.OWC_invalid_phone_msg);
//     //     }
//     //     yourselfCellPhone.reportValidity()
//     //     this.isMultipleRequiredCheck = true
//     // }
// }

// handleYourselfEmailFocus(event){
//     this.handleRequiredSetValidation();
//     // if(this.individualRepEmail == undefined || this.individualRepEmail == null || this.individualRepEmail.trim() == ''){
//     // }
//     // else{
//     //     if(this.individualRepEmail.match(this.regExpEmailformat)){
//     //         let individualRepEmail = this.template.querySelector('[data-id="individualRepEmail"]');
//     //         individualRepEmail.setCustomValidity('');
//     //         individualRepEmail.reportValidity();
//     //     }
//     //     else{
//     //         let individualRepEmail = this.template.querySelector('[data-id="individualRepEmail"]');
//     //         individualRepEmail.setCustomValidity(customLabelValues.OWC_invalid_email_msg)
//     //         individualRepEmail.reportValidity();
//     //     }
//     // }
// }

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

stateValidityChecker(ids, values){
    let id = ids
    let value = values
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

    updateAddressFieldsithUSPS(uspsAddress){
        this.yourselfStreetAddress = uspsAddress.Address2
        this.yourselfCity = uspsAddress.City
        this.template.querySelector('[data-id="yourselfState"]').value = uspsAddress.State
        this.yourselfState = uspsAddress.State
        this.yourselfZipCode = uspsAddress.Zip5
    }

    
    handleUSPSRadioChange(event){
        //console.log('checked value is ::: ', event.target.checked);
        var inputTemplate = this.template.querySelectorAll('[data-id="radioInputId"]');
        this.succesWithCurrentAddress === true ? inputTemplate[inputTemplate.length - 1].checked = false : ''
        this.succesWithCurrentAddress = false;
        const objIndex = this.uspsAddressJSONList.findIndex((obj => obj.recId == event.target.value));
        this.selectedAddressIndex = objIndex;
        //console.log('index ::: ', objIndex);
        this.updateAddressFieldsithUSPS(this.uspsAddressJSONList[objIndex])
        this.isRenderedCallback = false;
    }
    
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
                // case "uspsProceedAddress":
                //     const uspsProceedAddress = event.target.value;
                //     this.uspsProceedAddress = uspsProceedAddress;
                // if(event.target.value === customLabelValues.OWC_address_proceed){
                //     this.isUpspProceedAddress = true
                //     this.isUspsCurrentAddress = false
                // }
                // else if(event.target.value === customLabelValues.OWC_usps_continue_address){
                //     this.isUpspProceedAddress = false
                //     this.isUspsCurrentAddress = true
                //     console.log('check address :::::: ', event.target.value + this.isUspsCurrentAddress)
                // }
                // else{
                //     this.isUpspProceedAddress = false
                //     this.isUspsCurrentAddress = false
                // }
                // break;
                
            // case "uspsCurrentAddressCheck":
            //     const uspsCurrentAddressCheck = event.target.checked;
            //     this.uspsCurrentAddressCheck = uspsCurrentAddressCheck;
            //     console.log('this.uspsCurrentAddressCheck ::: ', this.uspsCurrentAddressCheck)
            //     break;
                        case "yourselfFirstName":
                            this.yourselfFirstName = event.detail.value;
                            this.handleFirstNameFocus();
                            console.log('yourselfFirstName :::', this.yourselfFirstName);
                            break;
                        case "yourselfLastName":            
                            this.yourselfLastName = event.detail.value;
                            this.handleLastNameFocus();
                            console.log('yourselfLastName :::', this.yourselfLastName);
                            break;
                        case "yourselfMiddleName":
                            this.yourselfMiddleName = event.detail.value;
                            console.log('yourselfMiddleName :::', this.yourselfMiddleName);
                            break;
                        case "yourselfHomePhone":
                            this.yourselfHomePhone = event.target.value;
                            // this.handleYourselfHomePhoneFocus();
                            this.handleYourselfHomePhoneValidation();
                            //this.handleHomePhoneFocus();
                            // this.handleRequiredSetValidation();
                            console.log('yourselfHomePhone :::', this.yourselfHomePhone);
                            break;
                        case "isHomePhoneEntered":
                            this.isHomePhoneEntered = event.target.checked;
                            this.handleYourselfHomePhoneValidation();
                            break;
                        case "yourselfAlternatePhone":
                            this.yourselfAlternatePhone = event.target.value;  
                            this.handleYourselfAlternatePhoneValidation();          
                            break;       
                        case "yourselfAlternateContact":
                            this.yourselfAlternateContact = event.target.value; 
                            break; 
                        case "yourselfCellPhone":
                            this.yourselfCellPhone = event.target.value;
                            // this.handleYourselfCellPhoneFocus();
                            this.handleYourselfCellPhoneValidation();
                            // this.handleRequiredSetValidation();
                            //console.log('yourselfCellPhone :::', this.yourselfCellPhone);
                            break;
                        case "countryCodeyourselfCellPhone":
                            this.countryCodeyourselfCellPhone = event.target.value;
                            //console.log('countryCodeyourselfCellPhone :::', this.countryCodeyourselfCellPhone);
                            break;
                        case "countryCodeyourselfHomePhone":
                            this.countryCodeyourselfHomePhone = event.target.value;
                            //console.log('countryCodeyourselfHomePhone :::', this.countryCodeyourselfHomePhone);
                            break;
                        case "cellPhoneEntered":
                            this.isCellPhoneEntered = event.target.checked;
                            //console.log('isCellPhoneEntered :::', this.isCellPhoneEntered);
                            break;
                        case "yourselfBirthDate":
                            this.yourselfBirthDate = event.target.value;
                            this.handleBirthDateFocus();
                            //console.log('yourselfBirthDate :::', this.yourselfBirthDate);
                            break;
                        case "yourselfEmail":
                            this.yourselfEmail = event.target.value;
                            this.handleYourselfEmailValidation();
                            this.handleYourselfEmailFocus();
                            // this.handleRequiredSetValidation();
                            console.log('yourselfEmail :::', this.yourselfEmail);
                            break;
                        case "yourselfStreetAddress":
                            this.yourselfStreetAddress = event.target.value;
                            this.handleStreetAddressFocus();
                            //console.log('yourselfStreetAddress :::', this.yourselfStreetAddress);
                            break;
                        case "yourselfCity":
                            this.yourselfCity = event.target.value;
                            this.handleCityFocus();
                            //console.log('yourselfCity :::', this.yourselfCity);
                            break;
                        case "yourselfState":
                            this.yourselfState = event.target.value;
                            this.isPicklistChanged = true
                            this.handleStatePicklistBlur();
                            this.handleStateFocus();
                            //console.log('yourselfState :::', this.yourselfState);
                            break;
                        case "yourselfZipCode":
                            this.yourselfZipCode = event.target.value;
                            if(event.target.value.length >= 5 && this.yourselfZipCode.includes('-')){
                                this.template.querySelector('[data-id="yourselfZipCode"]').value = event.target.value;
                            }
                            else if(event.target.value.length === 6){
                                this.template.querySelector('[data-id="yourselfZipCode"]').value = event.target.value.replace(/(\d{5})/, "$1-");
                            }
                            this.yourselfZipCode = event.target.value;
                            console.log('yourselfZipCode :::', event.target.value);
                            this.handleZipCodeFocus();
                            break;
                        case "needLanguageInterpreter":
                            this.needLanguageInterpreter = event.target.value;
                            //this.handleLanguageInterpreterFocus();
                            if(this.needLanguageInterpreter === customLabelValues.OWC_Yes){
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
                            //console.log('otherPrefferedLanguage :::', this.otherPrefferedLanguage);
                            break;
        }
    }

    
    // get showCurrentAddressTemplate(){
    //     return this.isUSPSAddressErrorTemplate === true || this.isUSPSAddressSuccessTemplate === true
    // }

    // @api addressOption = { label: '', value: 'checkedAddress' }

    // handleUSPSAddressChecker(){
    //     const addressJson = {
    //                 address2 : this.yourselfStreetAddress,
    //                 City : this.yourselfCity,
    //                 state : this.yourselfState,
    //                 zip5 : this.yourselfZipCode
    //             }
    //             verifyAddressByUSPS({
    //                 addressJson : JSON.stringify(addressJson)
    //             })
    //             .then(result => {
    //                 if(result){
    //                     if(result.message == 'Success'){
    //                         this.uspsAddress = result.address;
    //                         this.uspsAddress.recId = '0'
    //                         this.uspsAddressJSONList.length = 0
    //                         this.uspsAddressJSONList.push(this.uspsAddress);
                            
    //                         this.isSuccessFocus = true;
    //                         this.isUSPSAddressErrorTemplate = false;
    //                         this.isUSPSAddressSuccessTemplate = true;

    //                         if(this.uspsAddressJSONList.length > 0){
    //                             this.isUSPSAddressCheck = true;
    //                         }
    //                         else{
    //                             this.isUSPSAddressCheck = false;
    //                         }
                            
    //                     }
    //                     else{
    //                         this.isUSPSAddressErrorTemplate = true;
    //                         this.isUSPSAddressSuccessTemplate = false;
    //                         this.isErrorFocus = true;
    //                     }

    //                     // Hide the spinner after usps server call
    //                     this.isLoading = false;
    //                     console.log('isLoading ::: ', this.isLoading)
                        
    //                     // Here we can match the USPS Server response with the user input address.
    //                     if(this.uspsAddressJSONList.length === 1 && this.isButtonResetable === false){
    //                         this.checkUSPSWithUserInputs();
    //                     }  
                        
    //                 }
    //             })
    //             .catch(error => {
    //                 console.log('Error: ', error);
    //                 this.isLoading = false;
    //                 this.showToast('Error!', error.body.message, 'error');
    //                 this.isUSPSAddressErrorTemplate = false;
    //                 this.isUSPSAddressSuccessTemplate = false;
    //             })
    // }

    @api
    handleClaimantEvent(){
        const selectEvent = new CustomEvent('claimantemployeecustomevent', {
            detail: { 
                yourselfFirstName : this.yourselfFirstName,
                yourselfLastName : this.yourselfLastName,
                yourselfMiddleName : this.yourselfMiddleName,
                yourselfHomePhone : this.yourselfHomePhone,
                isHomePhoneEntered : this.isHomePhoneEntered,
                yourselfAlternateContact : this.yourselfAlternateContact,
                yourselfAlternatePhone : this.yourselfAlternatePhone,
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
                // isUSPSAddressInvalid : this.isUSPSAddressInvalid,
                // isUPSPAddressValid : this.isUPSPAddressValid,
                // uspsCurrentAddressCheck : this.uspsCurrentAddressCheck,
                // isUSPSAddressErrorTemplate : this.isUSPSAddressErrorTemplate,
                // isUSPSAddressSuccessTemplate : this.isUSPSAddressSuccessTemplate,
                // uspsAddress : this.uspsAddress,
                // isUSPSAddressCheck : this.isUSPSAddressCheck,
                // uspsProceedAddress : this.uspsProceedAddress,
                // uspsAddressJSONList : this.uspsAddressJSONList,
                // isUpspProceedAddress  : this.isUpspProceedAddress,
                // isUspsCurrentAddress : this.isUspsCurrentAddress,
                // selectedAddressIndex : this.selectedAddressIndex,
                // succesWithCurrentAddress : this.succesWithCurrentAddress
             }
       });
      this.dispatchEvent(selectEvent);
    }

    @api 
    handleClaimantChild(strString, isFormPreviewMode){
        this.claimantEmployeeSectionDetails = strString
        this.isFormPreviewMode = isFormPreviewMode
        this.yourselfFirstName = strString.yourselfFirstName
        this.yourselfLastName = strString.yourselfLastName
        this.yourselfMiddleName = strString.yourselfMiddleName
        this.yourselfHomePhone = strString.yourselfHomePhone
        this.isHomePhoneEntered = strString.isHomePhoneEntered
        this.yourselfAlternateContact = strString.yourselfAlternateContact
        this.yourselfAlternatePhone = strString.yourselfAlternatePhone
        this.yourselfCellPhone = strString.yourselfCellPhone
        this.countryCodeyourselfCellPhone = strString.countryCodeyourselfCellPhone
        this.countryCodeyourselfHomePhone = strString.countryCodeyourselfHomePhone
        this.cellPhoneEntered = strString.cellPhoneEntered
        this.isCellPhoneEntered = strString.isCellPhoneEntered
        this.yourselfBirthDate = strString.yourselfBirthDate
        this.yourselfEmail = strString.yourselfEmail
        this.yourselfStreetAddress = strString.yourselfStreetAddress
        this.yourselfCity = strString.yourselfCity
        this.yourselfState = strString.yourselfState
        this.yourselfZipCode = strString.yourselfZipCode
        this.needLanguageInterpreter = strString.needLanguageInterpreter
        this.isPrefferedLanguage = strString.isPrefferedLanguage
        this.isOtherPrefferedLanguage = strString.isOtherPrefferedLanguage
        this.prefferedLanguageSelection = strString.prefferedLanguageSelection
        this.otherPrefferedLanguage = strString.otherPrefferedLanguage
        // this.isUSPSAddressInvalid = strString.isUSPSAddressInvalid
        // this.isUPSPAddressValid = strString.isUPSPAddressValid
        // this.uspsCurrentAddressCheck = strString.uspsCurrentAddressCheck
        // this.isUSPSAddressErrorTemplate = strString.isUSPSAddressErrorTemplate
        // this.isUSPSAddressSuccessTemplate = strString.isUSPSAddressSuccessTemplate
        // this.uspsAddress = strString.uspsAddress
        // this.isUSPSAddressCheck = strString.isUSPSAddressCheck
        // this.uspsProceedAddress = strString.uspsProceedAddress
        // this.uspsAddressJSONList = strString.uspsAddressJSONList
        // this.isUpspProceedAddress = strString.isUpspProceedAddress
        // this.isUspsCurrentAddress = strString.isUspsCurrentAddress  
        // this.selectedAddressIndex = strString.selectedAddressIndex
        // this.succesWithCurrentAddress = strString.succesWithCurrentAddress
        this.isRenderedCallback = true
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
    isYourselfCity = false
    isYourselfState = false
    isYourselfStreetAddress = false
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
    isAlternatePhoneValid = false
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
    isRequiredSet = false
    isValidationSet = false
    isYourselfCellPhoneNotValid = false

    handleYourselfCellPhoneValidation(){
        let yourselfCellPhone = this.template.querySelector('[data-id="yourselfCellPhone"]');
        if(yourselfCellPhone.value === undefined || yourselfCellPhone.value === null || yourselfCellPhone.value === ''){
            yourselfCellPhone.setCustomValidity("");
            this.isYourselfCellPhoneNotValid = false
            yourselfCellPhone.reportValidity();
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
        let isHomePhoneEntered = this.template.querySelector('[data-id="isHomePhoneEntered"]');
        console.log('isHomePhoneEntered2:::', isHomePhoneEntered.checked);
        if(isHomePhoneEntered.checked === true){
            this.isYourselfHomePhoneNotValid = false
            yourselfHomePhone.reportValidity();
        }
        else{
            if(yourselfHomePhone.value === undefined || yourselfHomePhone.value === null || yourselfHomePhone.value === ''){
                yourselfHomePhone.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                this.isYourselfHomePhoneNotValid = true
                yourselfHomePhone.reportValidity();
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
       
    }

    handleYourselfAlternatePhoneValidation(){
        let yourselfAlternatePhone = this.template.querySelector('[data-id="yourselfAlternatePhone"]');
        if(yourselfAlternatePhone.value === undefined || yourselfAlternatePhone.value === null || yourselfAlternatePhone.value === ''){
            yourselfAlternatePhone.setCustomValidity("");
            this.isYourselfAlternatePhoneNotValid = false
            yourselfAlternatePhone.reportValidity();
        }
        else{
            if(yourselfAlternatePhone.value.match(this.regExpPhone)){
                yourselfAlternatePhone.setCustomValidity("");
                this.isYourselfAlternatePhoneNotValid = false
                yourselfAlternatePhone.reportValidity();
            }
            else{
                yourselfAlternatePhone.setCustomValidity(customLabelValues.OWC_invalid_phone_msg);
                this.isYourselfAlternatePhoneNotValid = true
                yourselfAlternatePhone.reportValidity()
            }
        }
    }

    handleYourselfEmailValidation(){
        let yourselfEmail = this.template.querySelector('[data-id="yourselfEmail"]');
        if(yourselfEmail.value === undefined || yourselfEmail.value === null || yourselfEmail.value === ''){
            yourselfEmail.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isYourselfEmailNotValid = false
            yourselfEmail.reportValidity();
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

    @api isAdvocate = false;

    @api
    handleClaimantEmployeeParent(isAdvocate){
            this.isAdvocate = isAdvocate
            let yourselfFirstName = this.template.querySelector('[data-id="yourselfFirstName"]');
            let yourselfFirstNameValue = this.yourselfFirstName
            let yourselfLastName = this.template.querySelector('[data-id="yourselfLastName"]');
            let yourselfLastNameValue = this.yourselfLastName
            let yourselfBirthDate = this.template.querySelector('[data-id="yourselfBirthDate"]');
            let yourselfBirthDateValue = this.yourselfBirthDate
            let yourselfZipCode = this.template.querySelector('[data-id="yourselfZipCode"]');
            let yourselfZipCodeValue = this.yourselfZipCode
            let yourselfCellPhone = this.template.querySelector('[data-id="yourselfCellPhone"]');
            let yourselfCellPhoneValue = this.yourselfCellPhone
            let yourselfHomePhone = this.template.querySelector('[data-id="yourselfHomePhone"]');
            let yourselfHomePhoneValue = this.yourselfHomePhone
            let yourselfEmail = this.template.querySelector('[data-id="yourselfEmail"]');
            let yourselfEmailValue = this.yourselfEmail
            let yourselfAlternatePhone = this.template.querySelector('[data-id="yourselfAlternatePhone"]');
            let yourselfAlternatePhonevalue = this.yourselfAlternatePhone
            let yourselfStreetAddress = this.template.querySelector('[data-id="yourselfStreetAddress"]');
            let yourselfStreetAddressValue = this.yourselfStreetAddress
            let yourselfCity = this.template.querySelector('[data-id="yourselfCity"]');
            let yourselfCityValue = this.yourselfCity
            let yourselfState = this.template.querySelector('[data-id="yourselfState"]');
            let yourselfStateValue = this.yourselfState
            this.isFirstName = this.preliminarySectionValidityChecker(yourselfFirstName, yourselfFirstNameValue);
            this.isLastName = this.preliminarySectionValidityChecker(yourselfLastName, yourselfLastNameValue);
            this.isYourselfEmail = this.preliminarySectionValidityChecker(yourselfEmail, yourselfEmailValue);
            this.isYourselfStreetAddress = this.preliminarySectionValidityChecker(yourselfStreetAddress, yourselfStreetAddressValue);
            this.isYourselfCity = this.preliminarySectionValidityChecker(yourselfCity, yourselfCityValue);
            this.isYourselfState = this.stateValidityChecker(yourselfState, yourselfStateValue);
            this.handleBirthDateFocus();
            this.isZipCode = this.preliminarySectionValidityChecker(yourselfZipCode, yourselfZipCodeValue);
            this.isCellPhoneValid = this.phoneValidityChecker(yourselfCellPhone, yourselfCellPhoneValue);
            this.isHomePhoneValid = this.phoneValidityChecker(yourselfHomePhone, yourselfHomePhoneValue);
            this.isAlternatePhoneValid = this.phoneValidityChecker(yourselfAlternatePhone, yourselfAlternatePhonevalue);

            this.handleYourselfCellPhoneValidation();
            this.handleYourselfHomePhoneValidation();
            this.handleYourselfEmailValidation();
            this.handleYourselfAlternatePhoneValidation();
             
            //this.isValidationSet = this.handleRequiredSetValidation();

            if(yourselfZipCode.value.trim() == null || yourselfZipCode.value.trim() == undefined || yourselfZipCode.value.trim() == ''){
                this.isZipCodeValid = true
                yourselfZipCode.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                yourselfZipCode.reportValidity()
            }
            else if(yourselfZipCode.value.trim() != null || yourselfZipCode.value.trim() != undefined || yourselfZipCode.value.trim() != ''){
                const yourselfZipCode = this.template.querySelector('[data-id="yourselfZipCode"]');
                if(yourselfZipCode.value.match(this.zipCodeRegrex)){
                    yourselfZipCode.setCustomValidity("");
                    this.isZipCodeValid = false
                    yourselfZipCode.reportValidity()
                }
                else{
                    yourselfZipCode.setCustomValidity(customLabelValues.OWC_invalid_zipcode_msg);
                    this.isZipCodeValid = true
                    yourselfZipCode.reportValidity()
                }                
            }
            else{
                this.isZipCodeValid = false
            }

            let otherPrefferedLanguage = this.template.querySelector('[data-id="otherPrefferedLanguage"]');
            if(this.isPrefferedLanguage === true && this.isOtherPrefferedLanguage === true){
                let otherPrefferedLanguageValue = this.otherPrefferedLanguage
                this.isOtherPrefferedLanguages = this.preliminarySectionValidityChecker(otherPrefferedLanguage, otherPrefferedLanguageValue);
            }

            this.isFirstName === true ? yourselfFirstName.focus() : ''
            this.isLastName === true ? yourselfLastName.focus() : ''
            this.isBirthdate === true ? yourselfBirthDate.focus() : ''
            this.isYourselfEmail === true ? yourselfEmail.focus() : ''
            this.isYourselfStreetAddress === true ? yourselfStreetAddress.focus() : ''
            this.isYourselfCity === true ? yourselfCity.focus() : ''
            this.isYourselfState === true ? yourselfState.focus() : ''
            this.isValidationSet === true || this.isYourselfCellPhoneNotValid === true ? yourselfCellPhone.focus() : ''
            this.isValidationSet === true || this.isYourselfHomePhoneNotValid === true ? yourselfHomePhone.focus() : ''
            this.isYourselfAlternatePhoneNotValid === true ? yourselfAlternatePhone.focus() : ''
            this.isValidationSet === true || this.isYourselfEmailNotValid === true ? yourselfEmail.focus() : ''
            this.isZipCodeValid === true ? yourselfZipCode.focus() : ''
            this.isZipCode === true ? yourselfZipCode.focus() : ''
            this.isOtherPrefferedLanguages === true ? otherPrefferedLanguage.focus() : ''
            
            if(this.NotProceed === true || this.isYourselfState === true || this.isYourselfCity === true || this.isYourselfStreetAddress === true || this.isYourselfEmail === true || this.isFirstName === true || this.isLastName === true || this.isBirthdate === true || this.isZipCode === true || this.isValidationSet === true || this.isZipCodeValid === true || this.isOtherPrefferedLanguages === true || this.isYourselfCellPhoneNotValid === true || this.isYourselfHomePhoneNotValid === true || this.isYourselfAlternatePhoneNotValid === true || this.isYourselfEmailNotValid === true){
                const validateEvent = new CustomEvent('claimantvaliditychecker', {
                    detail: {
                        isValidityTrue : true
                    }
                });
                this.dispatchEvent(validateEvent);
            }
            // else if(this.isAdvocate === false){
            //     if(!this.isZipCodeValid === true && (this.yourselfState !== null || this.yourselfState !== undefined) && (this.yourselfCity !== null || this.yourselfCity !== undefined) && (this.yourselfStreetAddress !== null || this.yourselfStreetAddress !== undefined)){
            //         if(this.uspsCurrentAddressCheck === false && (this.selectedAddressIndex === null || this.selectedAddressIndex === undefined) && this.succesWithCurrentAddress === false){
            //             this.isLoading = true;
            //             setInterval(this.handleUSPSAddressChecker(), 500);
            //             this.NotProceed = true
            //         }
            //         else if(this.uspsCurrentAddressCheck === true && this.succesWithCurrentAddress === true){
            //             this.NotProceed = false;
            //         }
            //      }
    
            //      if(this.selectedAddressIndex !== null && this.selectedAddressIndex !== undefined){
            //         this.resetTableRadioButton();
            //         if(this.isUSPSNotMatched === false){
            //             this.isLoading = true;
            //             setInterval(this.handleUSPSAddressChecker(), 500);
            //             this.NotProceed = true
            //             this.isButtonResetable = true;
            //         }
            //         else{
            //             this.NotProceed = false;
            //             this.isButtonResetable = false;
            //         }
            //      }
            //     this.handleClaimantEvent();
            // }
            else{
                this.handleClaimantEvent();
            }
            
    }

    // checkUSPSWithUserInputs(){
    //     const uspsAddress = this.uspsAddress;
    //     if(this.yourselfStreetAddress === undefined || this.yourselfCity === undefined || this.yourselfState === undefined || this.yourselfZipCode === undefined ){}
    //     else{
    //         if(this.yourselfStreetAddress.toLowerCase() === uspsAddress.Address2.toLowerCase() && this.yourselfCity.toLowerCase() === uspsAddress.City.toLowerCase() && this.yourselfState.toLowerCase() === uspsAddress.State.toLowerCase() && this.yourselfZipCode.toLowerCase() === uspsAddress.Zip5.toLowerCase()){
    //             this.isUSPSAddressErrorTemplate = false;
    //             this.isUSPSAddressSuccessTemplate = false;
    //             this.uspsAddressJSONList.length = 0;
    //             this.selectedAddressIndex = undefined
    //             const validateEvent = new CustomEvent('matchuspscustomevent', {
    //                 detail: {
    //                     currentStep : false
    //                 }
    //             });
    //             this.dispatchEvent(validateEvent);
    //         }
    //         this.handleClaimantEvent();
    //     }
    // }

    // resetTableRadioButton(){
    //     const selectedAddressFromUSPS = this.uspsAddressJSONList[this.selectedAddressIndex];
    //     if(this.yourselfStreetAddress !== selectedAddressFromUSPS.Address2 || this.yourselfCity !== selectedAddressFromUSPS.City || this.yourselfState !== selectedAddressFromUSPS.State || this.yourselfZipCode !== selectedAddressFromUSPS.Zip5){
    //         this.isUSPSNotMatched = false;
    //         this.isUSPSAddressErrorTemplate = false;
    //         this.isUSPSAddressSuccessTemplate = false;
    //         this.uspsAddressJSONList.length = 0;
    //         this.selectedAddressIndex = undefined
    //     }
    //     else{
    //         this.isUSPSNotMatched = true;
    //     }
    // }

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
        else if(learnMoreName === 'yourselfAlternatePhoneHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_claimant_employee_alternate_phone_helptext;
        }
        else if(learnMoreName === 'yourselfAlternateContactHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_claimant_employee_alternate_contact_helptext;
        }
    }

    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        console.log('helpTextValue:', JSON.stringify(helpTextValue));
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    renderedCallback(){
        // if(this.isRenderedCallback === false && (this.countryCodeyourselfCellPhone === '--Select--' || this.countryCodeyourselfCellPhone === undefined || this.countryCodeyourselfCellPhone ===null || this.countryCodeyourselfHomePhone === '--Select--' || this.countryCodeyourselfHomePhone === undefined || this.countryCodeyourselfHomePhone ===null)){
        //     this.template.querySelector('[data-id="countryCodeyourselfCellPhone"]').value = '+1';
        //     console.log('countryCodeyourselfCellPhone>>>>>>>',this.template.querySelector('[data-id="countryCodeyourselfCellPhone"]').value);
        //     this.template.querySelector('[data-id="countryCodeyourselfHomePhone"]').value = '+1';
        //     console.log('countryCodeyourselfHomePhone>>>>>>>',this.template.querySelector('[data-id="countryCodeyourselfHomePhone"]').value);
        // }
        // // Add focus for checkbox when invalid address return from USPS
        // if(this.isRenderedCallback === false && this.isLoading === false && this.isErrorFocus === true && this.isUSPSAddressErrorTemplate === true){
        //     this.template.querySelector('[data-id="uspsCurrentAddressCheck"]').focus();
        //     this.isErrorFocus = false;
        // }

        // // Add focus for radio button
        // if(this.isRenderedCallback === false && this.isLoading === false && this.isUSPSAddressSuccessTemplate === true && this.isSuccessFocus === true){
        //     const inputTemplate = this.template.querySelectorAll('[data-id="radioInputId"]');
        //     inputTemplate[0].focus()
        //     this.isSuccessFocus = false;
        // }
        if(this.isRenderedCallback === true && this.yourselfState != undefined){
            this.template.querySelector('[data-id="yourselfState"]').value = this.yourselfState
        }

        if(this.isRenderedCallback === true && this.uspsCurrentAddressCheck === true){
            this.template.querySelector('[data-id="uspsCurrentAddressCheck"]').checked = 'Yes'
        }
        // if(this.isRenderedCallback === true && this.uspsAddressJSONList.length > 0 && this.isUSPSAddressSuccessTemplate === true && this.succesWithCurrentAddress === false){
        //     var inputTemplate = this.template.querySelectorAll('[data-id="radioInputId"]');
        //     for(var i=0; i < inputTemplate.length; i++){
        //         inputTemplate[this.selectedAddressIndex].checked = true;
        //     }
        // }
        // if(this.isRenderedCallback === true && this.succesWithCurrentAddress === true){
        //     var inputTemplate = this.template.querySelectorAll('[data-id="radioInputId"]');
        //     inputTemplate[inputTemplate.length - 1].checked = true;
        // }
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
}