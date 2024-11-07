import { LightningElement, api, wire } from 'lwc';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import verifyAddressByUSPS from '@salesforce/apex/OWCAddressCheckerUSPS.verifyAddressByUSPS';
// Custom Labels
import OWC_worklocation_heading from '@salesforce/label/c.OWC_worklocation_heading';
import OWC_worklocation_businessaddress from '@salesforce/label/c.OWC_worklocation_businessaddress';
import OWC_worklocation_reportedaddress from '@salesforce/label/c.OWC_worklocation_reportedaddress';
import OWC_select_picklist_label from '@salesforce/label/c.OWC_select_picklist_label';
import OWC_street_address from '@salesforce/label/c.OWC_street_address';
import OWC_city from '@salesforce/label/c.OWC_city';
import OWC_state from '@salesforce/label/c.OWC_state';
import OWC_required_field_error_msg from '@salesforce/label/c.OWC_required_field_error_msg';
import OWC_zipcode from '@salesforce/label/c.OWC_zipcode';
import OWC_invalid_phone_msg from '@salesforce/label/c.OWC_invalid_phone_msg'
import OWC_empinfo_Phone from '@salesforce/label/c.OWC_empinfo_Phone';
import OWC_save_as_draft_label from '@salesforce/label/c.OWC_save_as_draft_label';
import {loadStyle} from 'lightning/platformResourceLoader';  // Run time style loader
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import {radioOptions, customLabelValues, acceptedFileFormat } from 'c/owcUtils';
import OWC_address_proceed from '@salesforce/label/c.OWC_address_proceed';
import OWC_usps_continue_address from '@salesforce/label/c.OWC_usps_continue_address';
import OWC_usps_response_error_header from '@salesforce/label/c.OWC_usps_response_error_header';
import OWC_suggested_response_label from '@salesforce/label/c.OWC_suggested_response_label';
import OWC_error_response_label from '@salesforce/label/c.OWC_error_response_label';
import OWC_action_label from '@salesforce/label/c.OWC_action_label';
import OWC_ApproximateLocation from '@salesforce/label/c.OWC_ApproximateLocation';
import OWC_invalid_zipcode_msg from '@salesforce/label/c.OWC_invalid_zipcode_msg';

export default class OwcOtherWorkLocationSectionCmp extends LightningElement {

    @api workLocationBusinessAddress
    @api isBusinessAddressDifferent = false
    @api otherBusinessStreetAddress
    @api otherBusinessCity
    @api approximateLocation
    @api otherBusinessState
    @api countryCode
    @api otherBusinessZipCode
    @api otherBusinessPhone
    @api countryCodeValue
    @api isClaimantAdvocate = false
    // @api isPicklistChanged = false
    isRenderedCallback = false
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
    // isCountryCodeChecked = false;
    @api isUSPSNotMatched = false;
    @api isButtonResetable = false
    @api isErrorFocus = false;
    @api isSuccessFocus = false;
    @api isLoading = false
    @api isPrevious = false

    customLabelValues = {
        OWC_action_label,
        OWC_select_picklist_label,
        OWC_suggested_response_label,
        OWC_error_response_label,
        OWC_usps_response_error_header,
        OWC_usps_continue_address,
        OWC_address_proceed,
        OWC_worklocation_heading,
        OWC_worklocation_businessaddress,
        OWC_worklocation_reportedaddress,
        OWC_street_address,
        OWC_city,
        OWC_state,
        OWC_zipcode,
        OWC_ApproximateLocation,
        OWC_empinfo_Phone,
        OWC_save_as_draft_label,
        OWC_invalid_zipcode_msg
    }
    
    @api statePicklistValues;

    connectedCallback(){
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
            console.log( 'Files loaded' );
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
            console.log( error.body.message );
        });
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
            this.otherBusinessState = 'CA'
            this.countryCode = '+1';
            console.log('countryCode:', this.countryCode);
        }
        else if(error){
            this.error = error;
        }
    }

    @api owcClaimentInfo(strString){
        console.log('owcClaimentInfoValue :::', strString);
        if(strString == "Yourself"){
            this.isClaimantAdvocate = true
        }else if(strString == "Representative"){
            this.isClaimantAdvocate = false
        }
    }

    options = radioOptions
    @api isWorkLocation = false;

    regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    regExpPhone = /^((\\+[1-9]{1,4}[ \\-]*)|(\\([0-9]{2,3}\\)[ \\-]*)|([0-9]{2,4})[ \\-]*)*?[0-9]{3,4}?[ \\-]*[0-9]{3,4}?$/;
    zipCodeRegrex = /^\d{5}(?:[-\s]\d{4})?$/;
    urlAddressChekerRegrex = /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$/;

    handleSaveAsDraft(){
        this.handleOtherWorkLocationParent();
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "4"
            }
        });
        this.dispatchEvent(validateEvent);
    }

    validateWorkLocationAddress(){
        let workLocationBusinessAddress = this.template.querySelector('[data-id="workLocationBusinessAddress"]');
        if(Boolean(workLocationBusinessAddress.value)){
            workLocationBusinessAddress.setCustomValidity("");
            this.isWorkLocation = false;
        }
        else{
            workLocationBusinessAddress.setCustomValidity(OWC_required_field_error_msg);
            this.isWorkLocation = true;
        }
        workLocationBusinessAddress.reportValidity();
    }
    
    handleOtherBusinessCityFocus(){
        let otherBusinessCity = this.template.querySelector('[data-id="otherBusinessCity"]');
        if(otherBusinessCity.value.trim() == undefined || otherBusinessCity.value.trim() == '' || otherBusinessCity.value.trim() == null){
            // otherBusinessCity.setCustomValidity(OWC_required_field_error_msg);
        }
        else{
            otherBusinessCity.setCustomValidity("");
        }
        otherBusinessCity.reportValidity();
    }
    handleOtherBusinessStateFocus(){
        let otherBusinessState = this.template.querySelector('[data-id="otherBusinessState"]');
        if(otherBusinessState.value.trim() == undefined || otherBusinessState.value.trim() == '' || otherBusinessState.value.trim() == null){
            // otherBusinessState.setCustomValidity(OWC_required_field_error_msg);
        }
        else{
            otherBusinessState.setCustomValidity("");
        }
        otherBusinessState.reportValidity();
    }
    handleOtherBusinessZipCodeFocus(){
        const otherBusinessZipCode = this.template.querySelector('[data-id="otherBusinessZipCode"');
        if(otherBusinessZipCode.value === undefined || otherBusinessZipCode.value === null || otherBusinessZipCode.value.trim() === ''){
            otherBusinessState.setCustomValidity(OWC_required_field_error_msg);
        }
        else if(otherBusinessZipCode.value.match(this.zipCodeRegrex)){
            otherBusinessZipCode.setCustomValidity('')
        }
        else{
            otherBusinessZipCode.setCustomValidity(OWC_invalid_zipcode_msg)
        }
        otherBusinessZipCode.reportValidity()
    }

    handleOtherBusinessPhoneFocus(){
        const otherBusinessPhone = this.template.querySelector('[data-id="otherBusinessPhone"');
        if(otherBusinessPhone.value.trim() == null || otherBusinessPhone.value.trim() == undefined || otherBusinessPhone.value.trim() == ''){
            this.isPhoneChecked = false
            // this.isCountryCodeChecked = false
            otherBusinessPhone.setCustomValidity('');
            otherBusinessPhone.reportValidity()
        }
        else if(otherBusinessPhone.value.trim() != null || otherBusinessPhone.value.trim() != undefined || otherBusinessPhone.value.trim() != ''){
            const otherBusinessPhone = this.template.querySelector('[data-id="otherBusinessPhone"]');
            if(otherBusinessPhone.value.match(this.regExpPhone)){
                otherBusinessPhone.setCustomValidity("");
                this.isPhoneChecked = false
                // this.handleCountryCodeFocus();
                otherBusinessPhone.reportValidity()
            }
            else{
                otherBusinessPhone.setCustomValidity(OWC_invalid_phone_msg);
                this.isPhoneChecked = true 
                otherBusinessPhone.reportValidity()
            }                
        }
    }

    // handleCountryCodeFocus(){
    //     const countryCode = this.template.querySelector('[data-id="countryCode"]');
    //     if(countryCode.value === undefined || countryCode.value === null || countryCode.value.trim() === '--Select--'){
    //         this.isCountryCodeChecked = true
    //         countryCode.setCustomValidity('Enter Code')
            
    //     }
    //     else{
    //         this.isCountryCodeChecked = false
    //         countryCode.setCustomValidity('')
    //     }
    //     countryCode.reportValidity()
    // }
    otherWorkLocationValidityChecker(ids, values){
        let id = ids
        let value = values
        console.log('yourselfFirstNameValue:', value);
        if(value == undefined && value == null || value.trim() == ""){
            id.setCustomValidity(OWC_required_field_error_msg);
            id.reportValidity();
            return true;
        }
    }

    handleOtherWorkLocationParent(){
        const selectEvent = new CustomEvent('otherworklocationevent', {
            detail: { 
                workLocationBusinessAddress : this.workLocationBusinessAddress,
                isBusinessAddressDifferent : this.isBusinessAddressDifferent,
                otherBusinessStreetAddress : this.otherBusinessStreetAddress,
                otherBusinessCity : this.otherBusinessCity,
                approximateLocation : this.approximateLocation,
                countryCode : this.countryCode,
                otherBusinessState : this.otherBusinessState,
                otherBusinessZipCode : this.otherBusinessZipCode,
                otherBusinessPhone : this.otherBusinessPhone,
                isClaimantAdvocate : this.isClaimantAdvocate,
                // isRenderedCallback : this.isRenderedCallback,
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

    isotherBusinessStreetAddress = false
    isotherBusinessCity = false
    isotherBusinessStateValue = false
    isotherBusinessZipCode = false
    isotherBusinessPhoneValue = false
    isZipCodeValid = false
    isPhoneChecked = false

    // get showCurrentAddressTemplate(){
    //     return this.isUSPSAddressErrorTemplate === true || this.isUSPSAddressSuccessTemplate === true
    // }

    // handleSuccessWithCurrentAddress(event){
    //     // Reset above all radio button in datatable
    //     var inputTemplate = this.template.querySelectorAll('[data-id="radioInputId"]');
    //         for(var i=0; i < inputTemplate.length; i++){
    //             this.selectedAddressIndex === undefined ? '' : inputTemplate[this.selectedAddressIndex].checked = false
    //         }
    //         this.selectedAddressIndex = undefined
    //     const succesWithCurrentAddress = event.target.checked;
    //     console.log('event ::: ', succesWithCurrentAddress);
    //     this.succesWithCurrentAddress = succesWithCurrentAddress
    //     this.isRenderedCallback = false;
    // }

    // updateAddressFieldsithUSPS(uspsAddress){
    //     this.otherBusinessStreetAddress = uspsAddress.Address2
    //     this.otherBusinessCity = uspsAddress.City
    //     this.template.querySelector('[data-id="otherBusinessState"]').value = uspsAddress.State
    //     this.otherBusinessState = uspsAddress.State
    //     this.otherBusinessZipCode = uspsAddress.Zip5
    // }

    
    // handleUSPSRadioChange(event){
    //     console.log('checked value is ::: ', event.target.checked);
    //     var inputTemplate = this.template.querySelectorAll('[data-id="radioInputId"]');
    //     this.succesWithCurrentAddress === true ? inputTemplate[inputTemplate.length - 1].checked = false : ''
    //     this.succesWithCurrentAddress = false;
    //     const objIndex = this.uspsAddressJSONList.findIndex((obj => obj.recId == event.target.value));
    //     this.selectedAddressIndex = objIndex;
    //     console.log('index ::: ', objIndex);
    //     this.updateAddressFieldsithUSPS(this.uspsAddressJSONList[objIndex])
    //     this.isRenderedCallback = false;
    // }
    

    // This method is used to check the USPS Address.
    // handleUSPSAddressChecker(){
    //     const addressJson = {
    //         address2 : this.otherBusinessStreetAddress,
    //         City : this.otherBusinessCity,
    //         state : this.otherBusinessState,
    //         zip5 : this.otherBusinessZipCode
    //     }
    //     verifyAddressByUSPS({
    //         addressJson : JSON.stringify(addressJson)
    //     })
    //     .then(result => {
    //         if(result){
    //             if(result.message == 'Success'){
    //                 this.uspsAddress = result.address;
    //                 this.uspsAddress.recId = '0'
    //                 this.uspsAddressJSONList.length = 0
    //                 this.uspsAddressJSONList.push(this.uspsAddress);
                    
    //                 this.isSuccessFocus = true;
    //                 this.isUSPSAddressErrorTemplate = false;
    //                 this.isUSPSAddressSuccessTemplate = true;

    //                 if(this.uspsAddressJSONList.length > 0){
    //                     this.isUSPSAddressCheck = true;
    //                 }
    //                 else{
    //                     this.isUSPSAddressCheck = false;
    //                 }
                    
    //             }
    //             else{
    //                 this.isUSPSAddressErrorTemplate = true;
    //                 this.isUSPSAddressSuccessTemplate = false;
    //                 this.isErrorFocus = true;
    //             }
                
    //             // Hide the spinner after usps server call
    //             this.isLoading = false;
    //             console.log('isLoading ::: ', this.isLoading)
                
    //             // Here we can match the USPS Server response with the user input address.
    //             if(this.uspsAddressJSONList.length === 1){
    //                 this.checkUSPSWithUserInputs();
    //             }  
                
    //         }
    //     })
    //     .catch(error => {
    //         console.log('Error: ', error);
    //         this.isLoading = false;
    //         this.showToast('Error!', error.body.message, 'error');
    //         this.isUSPSAddressErrorTemplate = false;
    //         this.isUSPSAddressSuccessTemplate = false;
    //     })
    // }

    NotProceed = false

    @api 
    otherWorkLocationDetailsFromParent(isPrevious){
        this.isPrevious = isPrevious
        this.validateWorkLocationAddress();
        if(this.isBusinessAddressDifferent === true){
            // let otherBusinessStreetAddress = this.template.querySelector('[data-id="otherBusinessStreetAddress"]');
            // let otherBusinessStreetAddressValue = this.otherBusinessStreetAddress
            let otherBusinessCity = this.template.querySelector('[data-id="otherBusinessCity"]');
            let otherBusinessCityValue = this.otherBusinessCity
            let otherBusinessState = this.template.querySelector('[data-id="otherBusinessState"]');
            let otherBusinessStateValue = otherBusinessState.value
            let otherBusinessZipCode = this.template.querySelector('[data-id="otherBusinessZipCode"]');
            let otherBusinessZipCodeValue = this.otherBusinessZipCode
           
            // this.isotherBusinessStreetAddress = this.otherWorkLocationValidityChecker(otherBusinessStreetAddress, otherBusinessStreetAddressValue);
            // this.isotherBusinessCity = this.otherWorkLocationValidityChecker(otherBusinessCity, otherBusinessCityValue);
            // this.isotherBusinessStateValue = this.otherWorkLocationValidityChecker(otherBusinessState, otherBusinessStateValue);
            this.isotherBusinessZipCode = this.otherWorkLocationValidityChecker(otherBusinessZipCode, otherBusinessZipCodeValue);
           
            if(otherBusinessZipCode.value.trim() == null || otherBusinessZipCode.value.trim() == undefined || otherBusinessZipCode.value.trim() == ''){
                this.isZipCodeValid = true
                otherBusinessZipCode.setCustomValidity(OWC_required_field_error_msg);
                otherBusinessZipCode.reportValidity()
            }
            else if(otherBusinessZipCode.value.trim() != null || otherBusinessZipCode.value.trim() != undefined || otherBusinessZipCode.value.trim() != ''){
                const otherBusinessZipCode = this.template.querySelector('[data-id="otherBusinessZipCode"]');
                if(otherBusinessZipCode.value.match(this.zipCodeRegrex)){
                    otherBusinessZipCode.setCustomValidity("");
                    this.isZipCodeValid = false
                    otherBusinessZipCode.reportValidity()
                }
                else{
                    otherBusinessZipCode.setCustomValidity(OWC_invalid_zipcode_msg);
                    this.isZipCodeValid = true
                    otherBusinessZipCode.reportValidity()
                }                
            }
            else{
                this.isZipCodeValid = false
            }
            //this.isotherBusinessPhoneValue = this.otherWorkLocationValidityChecker(otherBusinessPhone, otherBusinessPhoneValue);
            this.handleOtherBusinessPhoneFocus();
           
            // else if(!this.isZipCodeValid === true && (this.otherBusinessState !== null || this.otherBusinessState !== undefined) && (this.otherBusinessCity !== null || this.otherBusinessCity !== undefined) && (this.otherBusinessStreetAddress !== null || this.otherBusinessStreetAddress !== undefined)){
            //     if(this.uspsCurrentAddressCheck === false && (this.selectedAddressIndex === null || this.selectedAddressIndex === undefined) && this.succesWithCurrentAddress === false){
            //         this.isLoading = true;
            //         setInterval(this.handleUSPSAddressChecker(), 500);
            //         this.NotProceed = true
            //     }
            //     else if(this.uspsCurrentAddressCheck === true && this.succesWithCurrentAddress === true){
            //         this.NotProceed = false;
            //     }
            //  }

            //  if(this.selectedAddressIndex !== null && this.selectedAddressIndex !== undefined){
            //     this.resetTableRadioButton();
            //     if(this.isUSPSNotMatched === false){
            //         this.isLoading = true;
            //         setInterval(this.handleUSPSAddressChecker(), 500);
            //         this.NotProceed = true
            //         this.isButtonResetable = true;
            //     }
            //     else{
            //         this.NotProceed = false;
            //         this.isButtonResetable = false;
            //     }
            //  }
        }
        if(this.isWorkLocation === true || this.NotProceed === true  || this.isotherBusinessZipCode === true || this.isZipCodeValid === true || this.isPhoneChecked === true){
            const validateEvent = new CustomEvent('validityevent', {
                detail: {
                    currentStep : true
                }
            });
            this.dispatchEvent(validateEvent);
        }
        else{
            this.handleOtherWorkLocationParent();
        }
        this.handleOtherWorkLocationParent();
    }

    // checkUSPSWithUserInputs(){
    //     const uspsAddress = this.uspsAddress;
    //     if(this.otherBusinessStreetAddress === undefined || this.otherBusinessCity === undefined || this.otherBusinessState === undefined || this.otherBusinessZipCode === undefined){}
    //     else if(this.otherBusinessStreetAddress.toLowerCase() === uspsAddress.Address2.toLowerCase() && this.otherBusinessCity.toLowerCase() === uspsAddress.City.toLowerCase() && this.otherBusinessState.toLowerCase() === uspsAddress.State.toLowerCase() && this.otherBusinessZipCode.toLowerCase() === uspsAddress.Zip5.toLowerCase()){
    //         this.isUSPSAddressErrorTemplate = false;
    //         this.isUSPSAddressSuccessTemplate = false;
    //         this.uspsAddressJSONList.length = 0;
    //         this.selectedAddressIndex = undefined
    //         if(this.isPrevious === false){
    //             const validateEvent = new CustomEvent('matchuspscustomeventforlocation', {
    //                 detail: {
    //                     currentStep : false
    //                 }
    //             });
    //             this.dispatchEvent(validateEvent);
    //             this.handleOtherWorkLocationParent();
    //         }
    //     }
        
    // }

    // resetTableRadioButton(){
    //     const selectedAddressFromUSPS = this.uspsAddressJSONList[this.selectedAddressIndex];
    //     if(this.otherBusinessStreetAddress !== selectedAddressFromUSPS.Address2 || this.otherBusinessCity !== selectedAddressFromUSPS.City || this.otherBusinessState !== selectedAddressFromUSPS.State || this.otherBusinessZipCode !== selectedAddressFromUSPS.Zip5){
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

    

    @api isFormPreviewMode = false
    @api otherWorkLocationDetails
    @api showSectionHeading = false
    @api
    handleOtherWorkLocationChild(strString,isFormPreviewMode){
        //console.log('OtherWorkChilDataTesting:::',JSON.Stringify(strString))
        this.isFormPreviewMode = isFormPreviewMode
        this.otherWorkLocationDetails = strString
        // this.isRenderedCallback = strString.isRenderedCallback
        this.workLocationBusinessAddress = strString.workLocationBusinessAddress
        this.isBusinessAddressDifferent = strString.isBusinessAddressDifferent
        this.otherBusinessStreetAddress = strString.otherBusinessStreetAddress
        this.otherBusinessCity = strString.otherBusinessCity
        this.approximateLocation = strString.approximateLocation
        this.otherBusinessState = strString.otherBusinessState
        this.otherBusinessZipCode = strString.otherBusinessZipCode
        this.otherBusinessPhone = strString.otherBusinessPhone
        this.countryCode = strString.countryCode
        this.isClaimantAdvocate = strString.isClaimantAdvocate
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

    renderedCallback(){
        console.log('this.selectedAddressIndex ::: ', this.selectedAddressIndex)
        console.log('this.isRenderedCallback ::: ', this.isRenderedCallback)
        console.log('this.isBusinessAddressDifferent ::: ', this.isBusinessAddressDifferent)
        console.log('this.countryCode ::: ', this.countryCode)
        // if(this.isRenderedCallback === false && this.isBusinessAddressDifferent === true && (this.countryCode === '--Select--' || this.countryCode === undefined || this.countryCode ===null)){
        //     this.template.querySelector('[data-id="otherBusinessState"]').value = 'CA';
        //     console.log('otherBusinessState>>>>>>>',this.template.querySelector('[data-id="otherBusinessState"]').value);
        //     this.template.querySelector('[data-id="countryCode"]').value = '+1';
        //     console.log('countryCode>>>>>>>',this.template.querySelector('[data-id="countryCode"]').value);
        // }
        if(this.isRenderedCallback === true && this.otherBusinessState != undefined){
            this.template.querySelector('[data-id="otherBusinessState"]').value = this.otherBusinessState
        }
        if(this.isRenderedCallback === true && this.workLocationBusinessAddress != null){
            this.template.querySelector('[data-id="workLocationBusinessAddress"]').value = this.workLocationBusinessAddress
        }
        // if(this.isRenderedCallback === true && this.uspsProceedAddress === true && this.isBusinessAddressDifferent === true){
        //     this.template.querySelector('[data-id="uspsProceedAddress"]').checked = 'Yes'
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
        this.isRenderedCallback = false
    }

    updateAddressFieldsithUSPS(){
        this.otherBusinessStreetAddress = this.uspsAddress.Address2
        this.otherBusinessCity = this.uspsAddress.City
        this.template.querySelector('[data-id="otherBusinessState"]').value = this.uspsAddress.State
        this.otherBusinessState = this.uspsAddress.State
        this.otherBusinessZipCode = this.uspsAddress.Zip5
    }

    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ){
            case "uspsCurrentAddressCheck":
                const uspsCurrentAddressCheck = event.target.checked;
                this.uspsCurrentAddressCheck = uspsCurrentAddressCheck;
                console.log('this.uspsCurrentAddressCheck ::: ', this.uspsCurrentAddressCheck)
                break;
            case "workLocationBusinessAddress":
                this.workLocationBusinessAddress = event.target.value
                if(this.workLocationBusinessAddress === this.options[0].value){
                    this.isBusinessAddressDifferent = true
                }
                else{
                    this.isBusinessAddressDifferent = false
                    this.isUSPSAddressErrorTemplate = false;
                    this.isUSPSAddressSuccessTemplate = false;
                    this.uspsCurrentAddressCheck = false;
                    this.uspsProceedAddress = false;
                    this.handleResetBusinessAddress()
                }
                this.validateWorkLocationAddress();
                break;
            case "otherBusinessStreetAddress":
                this.otherBusinessStreetAddress = event.target.value
                // this.handleOtherBusinessStreetAddressFocus();
                console.log('otherBusinessStreetAddress:', this.otherBusinessStreetAddress);
                break;
                
            case "otherBusinessCity":
                this.otherBusinessCity = event.target.value
                this.handleOtherBusinessCityFocus();
                console.log('otherBusinessCity:', this.otherBusinessCity);
                break;
            case "approximateLocation":
                this.approximateLocation = event.target.value
                this.handleapproximateLocationFocus();
                console.log('approximateLocation:', this.approximateLocation);
                break;
            case "otherBusinessState":
                this.otherBusinessState = event.target.value
                this.handleOtherBusinessStateFocus();
                console.log('otherBusinessState:', this.otherBusinessState);
                break;
            case "otherBusinessZipCode":
                this.otherBusinessZipCode = event.target.value;
                if(event.target.value.length >= 5 && this.otherBusinessZipCode.includes('-')){
                    this.template.querySelector('[data-id="otherBusinessZipCode"]').value = event.target.value;
                }
                else if(event.target.value.length === 6){
                    this.template.querySelector('[data-id="otherBusinessZipCode"]').value = event.target.value.replace(/(\d{5})/, "$1-");
                }
                this.otherBusinessZipCode = event.target.value;
                console.log('otherBusinessZipCode :::', event.target.value);
                this.handleOtherBusinessZipCodeFocus();
                break;
                
                case "countryCode":
                    this.countryCode = event.target.value
                    console.log('countryCode:', this.countryCode);
                    break;
                    case "otherBusinessPhone":
                        this.otherBusinessPhone =  event.target.value
                        this.handleOtherBusinessPhoneFocus();
                        console.log('otherBusinessPhone:', this.otherBusinessPhone);
                        break;
        }
    }

    handleResetBusinessAddress(){
        this.otherBusinessStreetAddress = ''
        this.otherBusinessCity = ''
        this.approximateLocation = ''
        this.otherBusinessState = 'CA'
        this.otherBusinessZipCode = ''
        this.otherBusinessPhone = ''
        this.countryCode = '+1'
    }
}