import { LightningElement, api,wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { radioOptions, customLabelValues, acceptedFileFormat } from 'c/owcUtils';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import owcFrequencyMetaData from '@salesforce/apex/OWCPaymentOfWagesController.fetchFrequencyMetaData';
import paymentTypeOptions from '@salesforce/apex/OWCPaymentOfWagesController.fetchOptionsMetaData';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcDifferentHourRateAdditional extends LightningElement {
     //Store the value of Amount paid different hour
    @api paidAmountDifferentHourAdditional //Store the value of Amount paid different hour additional section
    @api promisedAmountDifferentHourAdditional //Store the value of Amount promised different hour additional section
    @api forActivityAdditional
    @api differentHourlyRateBegDateAdditional
    @api differentHourlyRateEndDateAdditional
    @api sectionid
    @api differenthouradditonalheading
    @api deletebutton
    @api sectionId
    @api paymentWagesDetailPreview
    
    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`
    
    intRegrex =  /^\$?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{1,2})?$/; //Pattern to check the number value
    //Regrex Expression for phone number
    regExpPhone = /^((\\+[1-9]{1,4}[ \\-]*)|(\\([0-9]{2,3}\\)[ \\-]*)|([0-9]{2,4})[ \\-]*)*?[0-9]{3,4}?[ \\-]*[0-9]{3,4}?$/;
    customLabelValues = customLabelValues // stores all the custom labels which we are importing from owcUtils
    YesOrNoOptions = radioOptions //stores the yes and no options which we are importing from owcUtils
    
    //ConnectedCall back Method 
        connectedCallback(){
            // don’t forget to load static resources in connectedCallback . 
            Promise.all([ loadStyle(this, OWCStyleSheet ) ])
            .then(() => {
                console.log( 'Files loaded' );
            })
            .catch(error => {
                this.showToast('Error!', error.body.message, 'error')
                console.log( error.body.message );
        });
        }
    
    
        //Handle Change method
        handleChange(event){
            // let hourlyRateBegDate = this.template.querySelector('[data-id="hourlyRateBegDate"]');
            // let hourlyRateEndDate = this.template.querySelector('[data-id="hourlyRateEndDate"]');
            event.preventDefault();
            this.isRenderedCallback = false 
            switch ( event.target.name ) {  
                    
                case "differentHourlyRateBegDateAdditional":
                    this.differentHourlyRateBegDateAdditional = event.target.value;
                    this.differentHourlyRateBegDateAdditional === null ? this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]').value = '' : ''
                    this.handlePOWDateValidity(this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]'), this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]'), this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]').value, this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]').value)
                    console.log('differentHourlyRateBegDateAdditional ::: ', this.differentHourlyRateBegDateAdditional);
                break;
                case "differentHourlyRateEndDateAdditional":
                    this.differentHourlyRateEndDateAdditional = event.target.value;
                    this.differentHourlyRateEndDateAdditional === null ? this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]').value = '' : ''
                    this.handlePOWDateValidity(this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]'), this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]'), this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]').value, this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]').value)
                    console.log('differentHourlyRateEndDateAdditional ::: ', this.differentHourlyRateEndDateAdditional);
                break;
                case "paidAmountDifferentHourAdditional":            
                    this.paidAmountDifferentHourAdditional = event.target.value;
                    this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountDifferentHourAdditional"]'),this.template.querySelector('[data-id="promisedAmountDifferentHourAdditional"]'))
                    this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidAmountDifferentHourAdditional"]'))
                    console.log('paidAmountDifferentHourAdditional ::: ', this.paidAmountDifferentHourAdditional);
                break;
                case "promisedAmountDifferentHourAdditional":            
                    this.promisedAmountDifferentHourAdditional = event.target.value;
                    this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountDifferentHourAdditional"]'),this.template.querySelector('[data-id="promisedAmountDifferentHourAdditional"]'))
                    this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedAmountDifferentHourAdditional"]'))
                    console.log('promisedAmountDifferentHourAdditional ::: ', this.promisedAmountDifferentHourAdditional);
                break;
                case "forActivityAdditional":
                this.forActivityAdditional = event.target.value;                    
                this.handleforActivityFocusAdditional()
                console.log('forActivityAdditional ::: ', this.forActivityAdditional);
            break; 
                
                                     
            }  
       
        }
    
        @api
        handleDifferentHourAddSectionData(){
            const selectEvent = new CustomEvent('differenthouradditionaldeleteevent', {
                detail: {     
                    sectionId : this.sectionid,            
                    paidAmountDifferentHourAdditional : this.paidAmountDifferentHourAdditional,
                    promisedAmountDifferentHourAdditional : this.promisedAmountDifferentHourAdditional,
                    forActivityAdditional : this.forActivityAdditional,
                    differentHourlyRateBegDateAdditional : this.differentHourlyRateBegDateAdditional,
                    differentHourlyRateEndDateAdditional : this.differentHourlyRateEndDateAdditional,   
                }
            });
            this.dispatchEvent(selectEvent);
        }
        //Evnt for handling all the data
        handleEvent(){
            const selectEvent = new CustomEvent('differenthouradditionalevent', {
                detail: {
                    paidAmountDifferentHourAdditional : this.paidAmountDifferentHourAdditional,
                    promisedAmountDifferentHourAdditional : this.promisedAmountDifferentHourAdditional,
                    forActivityAdditional : this.forActivityAdditional,
                    differentHourlyRateBegDateAdditional : this.differentHourlyRateBegDateAdditional,
                    differentHourlyRateEndDateAdditional : this.differentHourlyRateEndDateAdditional,                   
    
                }
            });
            this.dispatchEvent(selectEvent);
        }
    
        isempPaymentType = false
        isuploadLabel = false
        ispaidSepartly = false
        @api isAgreementRequired = false
        @api ValidationMsg = ''
        isCommissionDoc = false
    
        
        /* Define attribute to store the boolean values for Different Hourly rate */
        
        isNotAdditionalPaidAmountDifferentHour = false
        isNotAdditionalPromisedAmountDifferentHour = false
        isDNotAdditionalHourRateDateAcceptable = false
        isAdditionalPaidOrPromisedAmountDifferent = false

    
     
        //Custom Event
        
    
        /* This method is used to check all types of validation on the date fields. */
        handlePOWDateValidity(startDateId, endDateId, startDate, endDate){
            var startDateId = startDateId
            var endDateId = endDateId
            var startDate = startDate
            var endDate = endDate
            var today = new Date();
    
            startDate !== '' ? startDate = new Date(startDate.toString()) : ''
    
            endDate !== '' ? endDate = new Date(endDate.toString()) : ''
            if(startDate === '' && endDate === ''){
                startDateId.setCustomValidity('')
                endDateId.setCustomValidity('')
                startDateId.reportValidity();
                endDateId.reportValidity();
                return false;
            }
    
            else if((startDate === '' && endDate !== '') || (startDate !== '' && endDate === '')){
                startDateId.setCustomValidity(customLabelValues.Owc_fillBothDate_Fields)
                endDateId.setCustomValidity(customLabelValues.Owc_fillBothDate_Fields)
                startDateId.reportValidity();
                endDateId.reportValidity();
                return true;
            }
            
            // Check startDate is greater than today's date
            else if(startDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
                startDateId.setCustomValidity(customLabelValues.OWC_pastdate_error_msg)
                startDateId.reportValidity()
                return true;
            }
    
            // Check endDate is greater than today's date
            else if(endDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
                endDateId.setCustomValidity(customLabelValues.OWC_pastdate_error_msg)
                endDateId.reportValidity()
                return true;
            }
    
            // check startDate is greater than endDate
            else if(startDate > endDate){
                startDateId.setCustomValidity(customLabelValues.OWC_begdate_error_msg)
                endDateId.setCustomValidity(customLabelValues.OWC_enddate_error_msg)
                endDateId.reportValidity()
                startDateId.reportValidity()
                return true;
            }
    
            else{
                startDateId.setCustomValidity('')
                endDateId.setCustomValidity('')
                startDateId.reportValidity();
                endDateId.reportValidity();
                return false;
            }
    
        }
        /* This method is used to verify at least one of two required fields is populated */
        handleRequiredSetValidation(FirstId,SecondId){
            let paidAmountPerHourMissing = (FirstId.value === undefined || FirstId.value === null || FirstId.value.trim() === '')
            let promisedAmountPerHourMissing = (SecondId.value === undefined || SecondId.value === null || SecondId.value.trim() === '')
            if(paidAmountPerHourMissing && promisedAmountPerHourMissing){
                FirstId.setCustomValidity(customLabelValues.OWC_Paid_or_Promised);
                SecondId.setCustomValidity(customLabelValues.OWC_Paid_or_Promised);
                FirstId.reportValidity()
                SecondId.reportValidity()
                console.log('Paid or promised',this.customLabelValues.OWC_Paid_or_Promised)
                return true;
            }
            else{
                FirstId.setCustomValidity('');
                SecondId.setCustomValidity('');
                FirstId.reportValidity();
                SecondId.reportValidity();
                return false
            }
        }
        /* This method is used to check all the amount fields validation */
        handlePOWAmountValidity(fieldId){
                if(fieldId.value == undefined || fieldId.value == null || fieldId.value.trim() == ''){
                    fieldId.setCustomValidity("");
                    fieldId.reportValidity();
                    return false;
                }
                else if(fieldId.value.match(this.intRegrex)){
                    fieldId.setCustomValidity("");
                    fieldId.reportValidity()
                    return false;
                }
                else{
                    fieldId.setCustomValidity(customLabelValues.OWC_EnterValidAmount);
                    fieldId.reportValidity();
                    return true;
                }
            }
    
        /* This method is used to fire the custom event if any validation occurs on this section
        ** This event is handled by parent component i.e onlineWageClaimContainer.cmp
        */
        handleCustomValidityEvent(){
            const selectEvent = new CustomEvent('differenthouradditionalvalidityevent', {
                detail: {
                    currentStep : true
                }
            });
            this.dispatchEvent(selectEvent);
        }
        
        /**
         *  Delete Method
         */
        @api
         handleDifferentHourAdditionalDelete(event){
            event.preventDefault()
            console.log('sectionId in child ::: ', this.sectionid)
            const selectEvent = new CustomEvent('customdifferenthouradddeleteevent', {
                detail: {
                    sectionId : this.sectionid
                }
            });
            this.dispatchEvent(selectEvent);
        }
        /* This method is called from parent component when user click on continue button on this section. */
        @api 
        owcDifferentHourAdditionalFromParent(){ 
            
                    const paidAmountDifferentHourAdditionalId = this.template.querySelector('[data-id="paidAmountDifferentHourAdditional"]');
                    const promisedAmountDifferentHourAdditionalId = this.template.querySelector('[data-id="promisedAmountDifferentHourAdditional"]');
                    this.isNotAdditionalPaidAmountDifferentHour = this.handlePOWAmountValidity(paidAmountDifferentHourAdditionalId);
                    this.isNotAdditionalPromisedAmountDifferentHour = this.handlePOWAmountValidity(promisedAmountDifferentHourAdditionalId)
                    this.isAdditionalPaidOrPromisedAmountDifferent = this.handleRequiredSetValidation(paidAmountDifferentHourAdditionalId,promisedAmountDifferentHourAdditionalId)
    
        
                    let differentHourlyRateBegDateAdditionalId = this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]');
                    let differentHourlyRateEndDateAdditionalId = this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]');
                    this.isDNotAdditionalHourRateDateAcceptable = this.handlePOWDateValidity(differentHourlyRateBegDateAdditionalId, differentHourlyRateEndDateAdditionalId, differentHourlyRateBegDateAdditionalId.value, differentHourlyRateEndDateAdditionalId.value);                         
               
    
                // Add focus to the validation field
                this.isNotAdditionalPaidAmountDifferentHour === true ? paidAmountDifferentHourAdditionalId.focus() : ''
                this.isNotAdditionalPromisedAmountDifferentHour === true ? promisedAmountDifferentHourAdditionalId.focus() : ''
                this.isDNotAdditionalHourRateDateAcceptable === true ? differentHourlyRateBegDateAdditional.focus() : '' 
                this.isAdditionalPaidOrPromisedAmountDifferent === true ? paidAmountDifferentHourAdditionalId.focus() & promisedAmountDifferentHourAdditionalId.focus() : '' 
        
           
    
            return (this.isNotAdditionalPaidAmountDifferentHour === true 
                || this.isNotAdditionalPromisedAmountDifferentHour === true 
                || this.isAdditionalPaidOrPromisedAmountDifferent === true
                || this.isDNotAdditionalHourRateDateAcceptable === true ) ? this.handleCustomValidityEvent() : this.handleEvent();    
        }
    
        //Method for importing comp values from parent comp
        @api 
        owcDifferentHourAdditionalFromForChild(strString, isFormPreviewMode){
            this.paymentWagesDetailPreview = strString
            this.isFormPreviewMode = isFormPreviewMode
    
            console.log('Additional Section Data ',JSON.stringify(strString))
            console.log('Different Hour Preview ::',this.isFormPreviewMode)
    
            this.paidAmountDifferentHourAdditional = strString.paidAmountDifferentHourAdditional
            this.promisedAmountDifferentHourAdditional = strString.promisedAmountDifferentHourAdditional
            this.forActivityAdditional = strString.forActivityAdditional
            this.differentHourlyRateBegDateAdditional = strString.differentHourlyRateBegDateAdditional
            this.differentHourlyRateEndDateAdditional = strString.differentHourlyRateEndDateAdditional
            
            
    
            this.isRenderedCallback = true
        }
     
    
      
        //Validity checker method
        paymentOfWagesValidityChecker(ids, values){
            let id = ids
            let value = values
            console.log('Value:', value);
            const val = value == undefined || value == null ? '' : value
            if(val.trim() == ""){
                id.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                id.reportValidity();
                return true;
            } 
        }
    
       
        showToast(toastMsg) {
            const event = new ShowToastEvent({
                variant: 'success',
                message: toastMsg,
            });
            this.dispatchEvent(event);
        }
       
        handleHelpText(event){
            const learnMoreName = event.target.name;
            if(learnMoreName === 'multiFileUploadHelpText'){
                this.isHelpText = true;
                this.helpText = customLabelValues.OWC_multiplefileupload_helptext;
            }
            else if(learnMoreName === "ProvideComissionRate"){
                this.isHelpText = true;
                this.helpText = customLabelValues.OWC_payement_commission_agreement_helptext;
            }
            
        }
      
        handleHelpTextEvent(event){
            const helpTextValue = event.detail;
            console.log('helpTextValue:', JSON.stringify(helpTextValue));
            this.isHelpText = helpTextValue.isClosedHelpText
        }
    
}