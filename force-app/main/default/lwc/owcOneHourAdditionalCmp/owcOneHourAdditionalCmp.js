import { LightningElement, api,wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { radioOptions, customLabelValues, acceptedFileFormat } from 'c/owcUtils';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import owcFrequencyMetaData from '@salesforce/apex/OWCPaymentOfWagesController.fetchFrequencyMetaData';
import paymentTypeOptions from '@salesforce/apex/OWCPaymentOfWagesController.fetchOptionsMetaData';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class OwcOneHourAdditionalCmp extends LightningElement {
    @api isLargeDevice = false;
    @api isMediumDevice = false;
    @api isSmallDevice = false;
      //Store the value of Amount paid different hour
      @api paidAmountPerHourAdditional //Store the value of Amount paid different hour additional section
      @api promisedAmountPerHourAdditional //Store the value of Amount promised different hour additional section
      @api forActivityAdditional
      @api hourlyRateBegDateAdditional
      @api hourlyRateEndDateAdditional
      @api hoursectionid
      @api differenthouradditonalheading
      @api deletebutton
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
            switch(FORM_FACTOR) {
                case 'Large':
                    this.isLargeDevice = true;
                    break;
                case 'Medium':
                    this.isMediumDevice = true;
                    break;
                case 'Small':
                    this.isSmallDevice = true;
                    break;
            }
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
                      
                  case "hourlyRateBegDateAdditional":
                      this.hourlyRateBegDateAdditional = event.target.value;
                      this.hourlyRateBegDateAdditional === null ? this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]').value = '' : ''
                      this.handlePOWDateValidity(this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]'), this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]'), this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]').value, this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]').value)
                      console.log('hourlyRateBegDateAdditional ::: ', this.hourlyRateBegDateAdditional);
                  break;
                  case "hourlyRateEndDateAdditional":
                      this.hourlyRateEndDateAdditional = event.target.value;
                      this.hourlyRateEndDateAdditional === null ? this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]').value = '' : ''
                      this.handlePOWDateValidity(this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]'), this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]'), this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]').value, this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]').value)
                      console.log('hourlyRateEndDateAdditional ::: ', this.hourlyRateEndDateAdditional);
                  break;
                  case "paidAmountPerHourAdditional":            
                      this.paidAmountPerHourAdditional = event.target.value;
                      this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountPerHourAdditional"]'),this.template.querySelector('[data-id="promisedAmountPerHourAdditional"]'))
                      this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidAmountPerHourAdditional"]'))
                      console.log('paidAmountPerHourAdditional ::: ', this.paidAmountPerHourAdditional);
                  break;
                  case "promisedAmountPerHourAdditional":            
                      this.promisedAmountPerHourAdditional = event.target.value;
                      this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountPerHourAdditional"]'),this.template.querySelector('[data-id="promisedAmountPerHourAdditional"]'))
                      this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedAmountPerHourAdditional"]'))
                      console.log('promisedAmountPerHourAdditional ::: ', this.promisedAmountPerHourAdditional);
                  break;
                  case "forActivityAdditional":
                  this.forActivityAdditional = event.target.value;                    
                  this.handleforActivityFocusAdditional()
                  console.log('forActivityAdditional ::: ', this.forActivityAdditional);
              break; 
                  
                                       
              }  
         
          }
      
          @api
          handleOneHourlyAddSectionData(){
              const selectEvent = new CustomEvent('onehourlydataafterdelete', {
                  detail: {     
                    oneHourSectionId : this.hoursectionid,            
                      paidAmountPerHourAdditional : this.paidAmountPerHourAdditional,
                      promisedAmountPerHourAdditional : this.promisedAmountPerHourAdditional,
                      forActivityAdditional : this.forActivityAdditional,
                      hourlyRateBegDateAdditional : this.hourlyRateBegDateAdditional,
                      hourlyRateEndDateAdditional : this.hourlyRateEndDateAdditional,   
                  }
              });
              this.dispatchEvent(selectEvent);
          }
          //Evnt for handling all the data
          handleEvent(){
              const selectEvent = new CustomEvent('onehourlyadditionalevent', {
                  detail: {
                      paidAmountPerHourAdditional : this.paidAmountPerHourAdditional,
                      promisedAmountPerHourAdditional : this.promisedAmountPerHourAdditional,
                      hourlyRateBegDateAdditional : this.hourlyRateBegDateAdditional,
                      hourlyRateEndDateAdditional : this.hourlyRateEndDateAdditional,                   
      
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
      
          
          /* Define attribute to store the boolean values for One Hourly rate */
          
          isNotAdditionalPaidAmountOneHour = false
          isNotAdditionalPromisedAmountOneHour = false
          isDNotAdditionalHourRateDateAcceptable = false
          isAdditionalPaidOrPromisedAmount = false
      
       
          //Custom Event
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
              const selectEvent = new CustomEvent('onehouradditionalvalidityevent', {
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
           handleOneHourAdditionalDelete(event){
              event.preventDefault()
              console.log('sectionId in child ::: ', this.hoursectionid)
              const selectEvent = new CustomEvent('customonehouradddeleteevent', {
                  detail: {
                    oneHourSectionId : this.hoursectionid
                  }
              });
              this.dispatchEvent(selectEvent);
          }
          /* This method is called from parent component when user click on continue button on this section. */
          @api 
          owcOneHourAdditionalFromParent(){ 
              
                      const paidAmountPerHourAdditionalId = this.template.querySelector('[data-id="paidAmountPerHourAdditional"]');
                      const promisedAmountPerHourAdditionalId = this.template.querySelector('[data-id="promisedAmountPerHourAdditional"]');
                      this.isNotAdditionalPaidAmountOneHour = this.handlePOWAmountValidity(paidAmountPerHourAdditionalId);
                      this.isNotAdditionalPromisedAmountOneHour = this.handlePOWAmountValidity(promisedAmountPerHourAdditionalId)
                      this.isAdditionalPaidOrPromisedAmount = this.handleRequiredSetValidation(paidAmountPerHourAdditionalId,promisedAmountPerHourAdditionalId)
      
          
                      let hourlyRateBegDateAdditionalId = this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]');
                      let hourlyRateEndDateAdditionalId = this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]');
                      this.isDNotAdditionalHourRateDateAcceptable = this.handlePOWDateValidity(hourlyRateBegDateAdditionalId, hourlyRateEndDateAdditionalId, hourlyRateBegDateAdditionalId.value, hourlyRateEndDateAdditionalId.value);                         
                 
      
                  // Add focus to the validation field
                  this.isNotAdditionalPaidAmountOneHour === true ? paidAmountPerHourAdditionalId.focus() : ''
                  this.isNotAdditionalPromisedAmountOneHour === true ? promisedAmountPerHourAdditionalId.focus() : ''
                  this.isDNotAdditionalHourRateDateAcceptable === true ? hourlyRateBegDateAdditional.focus() : '' 
                  this.isAdditionalPaidOrPromisedAmount === true ? paidAmountPerHourAdditionalId.focus() && promisedAmountPerHourAdditionalId.focus() : '';
          
             
      
              return (this.isNotAdditionalPaidAmountOneHour === true 
                  || this.isNotAdditionalPromisedAmountOneHour === true 
                  || this.isDNotAdditionalHourRateDateAcceptable === true 
                  || this.isAdditionalPaidOrPromisedAmount === true) ? this.handleCustomValidityEvent() : this.handleEvent();    
          }
      
          //Method for importing comp values from parent comp
          @api 
          owcHourlyAdditionalFromForChild(strString, isFormPreviewMode){
              this.paymentWagesDetailPreview = strString
              this.isFormPreviewMode = isFormPreviewMode
              console.log('Form Preview Mode',this.isFormPreviewMode)
      
              console.log('Additional Section Data ',JSON.stringify(strString))
              console.log('Additional Section Data isFormPreviewMode',this.isFormPreviewMode)
      
              this.paidAmountPerHourAdditional = strString.paidAmountPerHourAdditional
              this.promisedAmountPerHourAdditional = strString.promisedAmountPerHourAdditional
              this.hourlyRateBegDateAdditional = strString.hourlyRateBegDateAdditional
              this.hourlyRateEndDateAdditional = strString.hourlyRateEndDateAdditional
              
              if(strString.paidAmountPerHourAdditional !=null || strString.promisedAmountPerHourAdditional != null)
                { 
                    this.isOneHourlyRatePreview = true
                        } 
                else
                {
                    this.isOneHourlyRatePreview = false
                }
              console.log("isOneHourlyRatePreview",this.isOneHourlyRatePreview)
      
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