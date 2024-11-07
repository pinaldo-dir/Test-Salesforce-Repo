import { LightningElement, track,api,wire } from 'lwc';
import getStatePicklistData from '@salesforce/apex/OwcCommunitySelfRegisterCtrl.initializeComponent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import verifyRecaptcha from '@salesforce/apex/OwcCommunitySelfRegisterCtrl.verifyCaptcha';
import { radioOptions, customLabelValues, acceptedFileFormat } from 'c/owcUtils';
import createUser from '@salesforce/apex/OwcCommunitySelfRegisterCtrl.createUser'
import { loadStyle } from 'lightning/platformResourceLoader'; // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet'; // Import static resource
import changedUserLanguage from '@salesforce/apex/OWCContainerController.changedUserLanguage';
import getUserCurrentLanguage from '@salesforce/apex/OWCContainerController.getUserCurrentLanguage';
import getLanguagesData from '@salesforce/apex/OWCContainerController.getLanguagesData';
import OWC_Confirm_Email from '@salesforce/label/c.OWC_Confirm_Email';
import OWC_Email_Not_Match from '@salesforce/label/c.OWC_Email_Not_Match';
import OWC_Enter_Valid_Phone from '@salesforce/label/c.OWC_Enter_Valid_Phone';
import OWC_Enter_Valid_Email from '@salesforce/label/c.OWC_Enter_Valid_Email';
import OWC_Required_Field from '@salesforce/label/c.OWC_Required_Field';
import OWC_recaptcha_msg from '@salesforce/label/c.OWC_recaptcha_msg';
import OWC_email_already_exist from '@salesforce/label/c.OWC_email_already_exist';
import userId from '@salesforce/user/Id';
import pubsub from 'c/pubsub' ;
import OWC_ChangeLanguage_Label from '@salesforce/label/c.OWC_ChangeLanguage_Label';

export default class OwcCommunitySelfRegister extends LightningElement {
    @api firstName;
    @api middleName;
    @api lastName;
    @api phone;
    @api email;
    @api userName;
    @api address1;
    @api address2;
    @api state;
    @api city;
    @api postalCode;
    @api errorMessage;
    @api isRegisterWithoutAddress = false;
    @api captchaResponse;
    @api isError = false;
    @api ValidationMsg = '';
    @api isSpinner = false;
    @api isRecaptchaSuccess = false;
    @api publicKey = '';
    userId = userId
    @api communityLanguage;
    @api isNotGuestUser = false
    OWC_ChangeLanguage_Label = OWC_ChangeLanguage_Label
    selectedLanguage
    @api languagesOptions = [];
    @api isRenderedCallback = false
    
    @wire(getLanguagesData,{})
    getLanguagesData({ error, data }) {
        if (data) {
            console.log('result in self ::: ', JSON.stringify(data))
            this.languagesOptions = data
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }
    passToParent(event){
        console.log('value:');
        this.isRecaptchaSuccess = event.detail;
        this.isError = false;
        this.ValidationMsg = '';
        //document.dispatchEvent(new Event("grecaptchaReset"));
        console.log('value:',this.isRecaptchaSuccess);
    }
    
    customLabels = {
        OWC_recaptcha_msg,
        OWC_Required_Field,
        OWC_Enter_Valid_Email,
        OWC_Email_Not_Match,
        OWC_Enter_Valid_Phone,
        OWC_Confirm_Email,
        OWC_email_already_exist
    }
    CustomLabelValues = customLabelValues
    // {
    //     FirstName : 'First Name',
    //     MiddleName : 'Middle Name',
    //     LastName : 'Last Name',
    //     // nickName: 'Nick Name',
    //     Email : 'Email',
    //     ConfirmEmail : 'Confirm Email',
    //     Phone: 'Cell Phone Number',
    //     Address1:'Address 1',
    //     Address2:'Address 2',
    //     State:'State',
    //     City:'City',
    //     PostalCode :'Postal Code',
    //     RegisterWithoutAddress :'Register without an address'
    // }

    isAddressRequired = false
    isPhoneRequired = false
    isUserNameCorrectFormat = false
    @api statePicklistValues = []

    
    @wire(getStatePicklistData)
    getStatePicklistData({ data, error }){
        if(data){
            this.statePicklistValues = data.stateList;
            // this.template.querySelector('[data-id="statePicklistId"]').value = 'CA';
            this.publicKey = data.publicKey;
            console.log(this.publicKey);
        }
        else if(error){
            this.error = error;
        }
    }

    handleChange(event){

    }


    regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    regExpPhone = /^((\\+[1-9]{1,4}[ \\-]*)|(\\([0-9]{2,3}\\)[ \\-]*)|([0-9]{2,4})[ \\-]*)*?[0-9]{3,4}?[ \\-]*[0-9]{3,4}?$/;
    zipCodeRegrex = /^[0-9]{5}(?:[0-9]{4})?$/;
    handlePhoneBlur(event){
        const phoneId = this.template.querySelector('[data-id="phoneId"');
        if(phoneId.value === undefined || phoneId.value === null || phoneId.value.trim() === ''){
            phoneId.setCustomValidity('')
        }
        else if(phoneId.value.match(this.regExpPhone)){
            phoneId.setCustomValidity('')
        }
        else{
            phoneId.setCustomValidity(this.customLabels.OWC_Enter_Valid_Phone)
        }
        phoneId.reportValidity()
    }

    handleFirstNameBlur(event){
        const firstName = this.template.querySelector('[data-id="firstName"');
        if(firstName.value === undefined || firstName.value === null || firstName.value.trim() === ''){
            firstName.setCustomValidity(this.customLabels.OWC_Required_Field)
        }
        else{
            firstName.setCustomValidity('')
        }
        firstName.reportValidity()
    }

    handleMiddleNameBlur(event){
        const lastName = this.template.querySelector('[data-id="lastName"');
        if(lastName.value === undefined || lastName.value === null || lastName.value.trim() === ''){
            lastName.setCustomValidity(this.customLabels.OWC_Required_Field)
        }
        else{
            lastName.setCustomValidity('')
        }
        lastName.reportValidity()
    }

    handleConfirmEmailBlur(event){
        const emailId = this.template.querySelector('[data-id="emailId"');
        const confirmEmailId = this.template.querySelector('[data-id="confirmEmailId"');
        if(emailId.value === undefined || emailId.value === null || emailId.value.trim() === ''){
            emailId.setCustomValidity(this.customLabels.OWC_Required_Field)
        }
        else if(emailId.value !== confirmEmailId.value){
            confirmEmailId.setCustomValidity(this.customLabels.OWC_Email_Not_Match)
        }
        else{
            emailId.setCustomValidity('')
            confirmEmailId.setCustomValidity('');
        }
        emailId.reportValidity()
        confirmEmailId.reportValidity()
    }

    handleEmailBlur(){
        const confirmEmailId = this.template.querySelector('[data-id="confirmEmailId"');
        const emailId = this.template.querySelector('[data-id="emailId"');
        if(confirmEmailId.value === undefined || confirmEmailId.value === null || confirmEmailId.value.trim() === ''){
            confirmEmailId.setCustomValidity(this.customLabels.OWC_Required_Field)
        }
        else if(emailId.value !== confirmEmailId.value){
            confirmEmailId.setCustomValidity(this.customLabels.OWC_Email_Not_Match)
        }
        else{
            confirmEmailId.setCustomValidity('');
        }
        confirmEmailId.reportValidity()
    }

    handleAddress1blur(event){
        const address1Id = this.template.querySelector('[data-id="address1Id"');
        if(address1Id.value === undefined || address1Id.value === null || address1Id.value.trim() === ''){
            address1Id.setCustomValidity(this.customLabels.OWC_Required_Field)
        }
        else{
            address1Id.setCustomValidity('')
        }
        address1Id.reportValidity()
    }

    handleAddress2blur(event){
        // const address2Id = this.template.querySelector('[data-id="address2Id"');
        // if(address2Id.value === undefined || address2Id.value === null || address2Id.value.trim() === ''){
        //     address2Id.setCustomValidity(this.customLabels.OWC_Required_Field)
        // }
        // else{
        //     address2Id.setCustomValidity('')
        // }
        // address2Id.reportValidity()
    }

    handleCityBlur(event){
        const cityId = this.template.querySelector('[data-id="cityId"');
        if(cityId.value === undefined || cityId.value === null || cityId.value.trim() === ''){
            cityId.setCustomValidity(this.customLabels.OWC_Required_Field)
        }
        else{
            cityId.setCustomValidity('')
        }
        cityId.reportValidity()
    }

    handleStatePicklistBlur(event){
        const statePicklistId = this.template.querySelector('[data-id="statePicklistId"');
        if(statePicklistId.value === undefined || statePicklistId.value === null || statePicklistId.value.trim() === ''){
            statePicklistId.setCustomValidity(this.customLabels.OWC_Required_Field)
        }
        else{
            statePicklistId.setCustomValidity('')
        }
        statePicklistId.reportValidity()
    }
    
    handleZipCodeBlur(event){
        // if(postalCodeId.value.trim() == null || postalCodeId.value.trim() == undefined || postalCodeId.value.trim() == ''){
        //     this.isAddressRequired = true
        //     postalCodeId.setCustomValidity(this.customLabels.OWC_Required_Field);
        //     postalCodeId.reportValidity()
        // }
        // else if(postalCodeId.value.trim() != null || postalCodeId.value.trim() != undefined || postalCodeId.value.trim() != ''){
        //     const postalCodeId = this.template.querySelector('[data-id="postalCodeId"]');
        //     if(postalCodeId.value.match(this.zipCodeRegrex)){
        //         postalCodeId.setCustomValidity("");
        //         this.isAddressRequired = false
        //         postalCodeId.reportValidity()
        //     }
        //     else{
        //         postalCodeId.setCustomValidity('Please enter valid ZipCode.');
        //         this.isAddressRequired = true
        //         postalCodeId.reportValidity()
        //     }                
        // }
        const postalCodeId = this.template.querySelector('[data-id="postalCodeId"');
        if(postalCodeId.value === undefined || postalCodeId.value === null || postalCodeId.value.trim() === ''){
            postalCodeId.setCustomValidity('')
        }
        else if(postalCodeId.value.match(this.zipCodeRegrex)){
            postalCodeId.setCustomValidity('')
        }
        else{
            postalCodeId.setCustomValidity('Please enter valid Zip Code.')
        }
        postalCodeId.reportValidity()
    }
    connectedCallback() {
        let message = {
            "message" : false
        }
        pubsub.fire('spinnerevent', message );
        if(this.userId != null){
            this.isNotGuestUser = true;
        }

        // const currentCommunityUrl = window.href.location;
        const queryString = window.location.search;

        const urlParams = new URLSearchParams(queryString);

        const urlLanguage = urlParams.get('language')
        this.communityLanguage = urlLanguage
        
        // const urlLanguage = currentCommunityUrl.substring(0, currentCommunityUrl.indexOf('?'));

        // getUserCurrentLanguage({})
        //    .then(result => {
        //        if(result){
        //            if(result === 'es'){
        //                console.log('result:', result);
        //                this.template.querySelector('[data-id="communityLanguage"]').value = 'Spanish';
        //            }
        //            else if(result === 'en_US'){
        //                this.template.querySelector('[data-id="communityLanguage"]').value = 'English';
        //            }
        //        }
        //    })
        //    .catch(error => {
        //        console.log('Error: ', error);
        //    })
        // console.log('child adadad');
        // don’t forget to load static resources in connectedCallback .
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
            console.log( 'Files loaded' );
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
            console.log( error.body.message );
    });
        var helper = this;
        document.addEventListener("grecaptchaVerified", function(e) {
            verifyRecaptcha({//TODO: map UI fields to sobject
                recaptchaResponse: e.detail.response})
                .then(result => {
                    //document.dispatchEvent(new Event("grecaptchaReset"));
                    if(result.includes('Success')){
                        console.log('===::in:',result);

                        
                        helper.isRecaptchaSuccess = true;
                        
                    } else{
                    }
                    console.log('result',result);
                   // alert(result);
                })
                .catch(error => {
                    this.showToast('Error!', error.body.message, 'error');
                    console.log('error',error);
                });
        });
    }
    renderedCallback() {
        console.log('rendered entry',this.isRecaptchaSuccess );
        var divElement = this.template.querySelector('div.recaptchaInvisible');
        //valide values for badge: bottomright bottomleft inline
        var payload = {element: divElement, badge: 'bottomright'};
        document.dispatchEvent(new CustomEvent("grecaptchaRender", {"detail": payload}));
        console.log('rendered value',this.isRecaptchaSuccess );

        if(this.communityLanguage !== undefined || this.communityLanguage !== null){
            this.communityLanguage ==='es' ? this.template.querySelector('[data-id="communityLanguage"]').value = 'Spanish' : this.template.querySelector('[data-id="communityLanguage"]').value = 'English'
        }
    }
    
//String firstName, String middleName, String lastName, String userName, String email, 
//String phone, String address1,String address2,String city,String state,String postalCode, String recaptchaResponse
    doSubmit(event){
        console.log('value: do submit recpatcha',this.isRecaptchaSuccess);
        document.dispatchEvent(new Event("grecaptchaExecute"));
        this.isError = false
        this.ValidationMsg = ''
        const isValidityCorrect = this.handleSelfRegistrationChecker();
        if(isValidityCorrect === false){
            
        }
        else{
            return;
        }
        
            this.phone = this.template.querySelector('[data-id="phoneId"').value.trim() || undefined;
            this.confirmEmail = this.template.querySelector('[data-id="confirmEmailId"').value.trim() || undefined;
            this.email = this.template.querySelector('[data-id="emailId"').value.trim() || undefined;
            this.firstName =this.template.querySelector('[data-id="firstName"').value.trim() || undefined;
            this.lastName = this.template.querySelector('[data-id="lastName"').value.trim() || undefined;
            this.middleName = this.template.querySelector('[data-id="middleName"').value.trim() || undefined;
            // this.captchaResponse = '';
        // console.log('entry in do submit');
        // console.log('firstName'+this.firstName);
        // console.log('middle'+this.middleName);
        // console.log('lat'+this.lastName);
        // // console.log('nickName'+this.nickName);
        // console.log('email'+this.email);
        // console.log('phone'+this.phone);
    
            if(this.isRecaptchaSuccess === true){
            this.isSpinner = true;
            createUser({firstName: this.firstName,middleName: this.middleName,lastName: this.lastName,
            email: this.email,confirmEmail: this.confirmEmail,phone:this.phone,})
            .then(result =>{
            console.log(JSON.stringify(result.errorMessage));
            if(!result.isError){
                console.log('Result::',result.pageName);
                const currentCommunityUrl = window.location.href
                            const communityUrl = currentCommunityUrl.substring(0, currentCommunityUrl.indexOf('s/')) + 's/'+result.pageName;
                            console.log('communityUrl:', communityUrl);
                            window.open(communityUrl,'_self');
                            this.isSpinner = false
                            this.isError = false
                            this.ValidationMsg = ''
            }
            else{
                this.isError = true
                this.isSpinner = false
                this.isRecaptchaSuccess = false; 
                result.errorMessage === 'User Email ID is already Exists.' || result.errorMessage === 'La solicitud no se puede procesar en este momento. Se ha avisado al administrador del sitio Web.' ? this.ValidationMsg = this.customLabels.OWC_email_already_exist : this.ValidationMsg = result.errorMessage
            }
            })
            .catch(error =>{
                this.showToast('Error!', error.body.message, 'error');
            this.isSpinner = false
            this.isRecaptchaSuccess = false;
            });
        } 
        else{
            console.log('state else ::: ', this.state)
            this.isError = true;
            this.isSpinner = false
            this.ValidationMsg = this.customLabels.OWC_recaptcha_msg;
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

    isFirstName = false
    isLastName = false
    isemailId = false
    isPhoneChecked = false
    isconfirmEmailId = false
    isEmailNotMatched = false
    handleSelfRegistrationChecker(){
        
        const phoneId = this.template.querySelector('[data-id="phoneId"');
        const firstName = this.template.querySelector('[data-id="firstName"');
        const lastName = this.template.querySelector('[data-id="lastName"');
        const emailId = this.template.querySelector('[data-id="emailId"');
        const confirmEmailId = this.template.querySelector('[data-id="confirmEmailId"');
        if(firstName.value === undefined || firstName.value === null || firstName.value.trim() === ''){
            this.isFirstName = true
            firstName.setCustomValidity(this.customLabels.OWC_Required_Field)
            firstName.reportValidity()
        }
        else{
            this.isFirstName = false
        }
    
        if(lastName.value === undefined || lastName.value === null || lastName.value.trim() === ''){
            this.isLastName = true
            lastName.setCustomValidity(this.customLabels.OWC_Required_Field)
            lastName.reportValidity()
        }
        else{
            this.isLastName = false
        }
        
        if(emailId.value === undefined || emailId.value === null || emailId.value.trim() === ''){
            this.isemailId = true
            emailId.setCustomValidity(this.customLabels.OWC_Required_Field)
            emailId.reportValidity()
        }
        else{
            if(emailId.value.match(this.regExpEmailformat)){
                this.isemailId = false
           }
           else{
                this.isemailId = true
                emailId.setCustomValidity(this.customLabels.OWC_Enter_Valid_Email)
                emailId.reportValidity()
           }
           
        }

        if(confirmEmailId.value === undefined || confirmEmailId.value === null || confirmEmailId.value.trim() === ''){
            this.isconfirmEmailId = true
            confirmEmailId.setCustomValidity(this.customLabels.OWC_Required_Field)
            confirmEmailId.reportValidity()
        }
        else{
            if(confirmEmailId.value.match(this.regExpEmailformat)){
                this.isconfirmEmailId = false
           }
           else{
                this.isconfirmEmailId = true
                confirmEmailId.setCustomValidity(this.customLabels.OWC_Enter_Valid_Email)
                confirmEmailId.reportValidity()
           }
        }

        if(confirmEmailId.value !== emailId.value){
            confirmEmailId.setCustomValidity(this.customLabels.OWC_Email_Not_Match);
            this.isEmailNotMatched = true;
            confirmEmailId.reportValidity();
        }
        else{
            confirmEmailId.setCustomValidity('');
            this.isEmailNotMatched = false;
            confirmEmailId.reportValidity();
        }

        if(phoneId.value.trim() == null || phoneId.value.trim() == undefined || phoneId.value.trim() == ''){
                    this.isPhoneChecked = false
                    phoneId.setCustomValidity('');
                    phoneId.reportValidity()
                 }
                else if(phoneId.value.trim() != null || phoneId.value.trim() != undefined || phoneId.value.trim() != ''){
                    const phoneId = this.template.querySelector('[data-id="phoneId"]');
                    if(phoneId.value.match(this.regExpPhone)){
                        phoneId.setCustomValidity("");
                        this.isPhoneChecked = false
                        phoneId.reportValidity()
                    }
                    else{
                        phoneId.setCustomValidity(this.customLabels.OWC_Enter_Valid_Phone);
                        this.isPhoneChecked = true
                        phoneId.reportValidity()
                    }                
                }

        if(this.isFirstName === true || this.isLastName === true || this.isemailId === true || this.isconfirmEmailId === true || this.isPhoneChecked === true || this.isEmailNotMatched === true){
            return true;
        }
        else{
            return false
        }
    }
    get langOptions() {
        return [
            { label: 'English', value: 'English' },
            { label: 'Spanish', value: 'Spanish' }
        ];
    }


    handleLanguageChange(event){
        this.isRenderedCallback = true
        const lang = event.detail.value;
        var currentCommunityUrl = window.location.href
        var communityUrl;
        if(lang === 'Spanish'){
            communityUrl = currentCommunityUrl.substring(0, currentCommunityUrl.indexOf('?')) + '?language=es'
        }
        else if(lang === 'English'){
            communityUrl = currentCommunityUrl.substring(0, currentCommunityUrl.indexOf('?')) + '?language=en_US'
        }
        window.open(communityUrl,'_self');
        // window.console.log('Event Fired ');
            // changedUserLanguage({
            //     selectedLanguage : this.selectedLanguage,
            //     communityId : this.communityId
            // })
            //    .then(result => {
            //        if(result){
            //             const currentCommunityUrl = window.location.href
            //             const communityUrl = currentCommunityUrl.substring(0, currentCommunityUrl.indexOf('?')) + '?language=en_US'
            //             console.log('communityUrl:', communityUrl);
            //             window.open(communityUrl,'_self');
            //        }
            //    })
            //    .catch(error => {
            //        console.log('Error: ', error);
            //    })
            
    }
}