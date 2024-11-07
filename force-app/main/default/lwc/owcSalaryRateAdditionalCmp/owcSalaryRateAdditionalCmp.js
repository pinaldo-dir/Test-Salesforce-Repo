import { LightningElement, api,wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { radioOptions, customLabelValues} from 'c/owcUtils';
import owcFrequencyMetaData from '@salesforce/apex/OWCPaymentOfWagesController.fetchFrequencyMetaData';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcSalaryRateAdditionalCmp extends LightningElement {
      //Store the value of Amount paid different hour
      @api paidAmountForEachDayAdditional //Store the value of Amount paid different hour additional section
      @api promisedAmountForEachDayAdditional //Store the value of Amount promised different hour additional section
      @api frequencyOfEachDayAdditional
      @api eachPayRateBegDateAdditional
      @api eachPayRateEndDateAdditional
      @api salaryratesectionid
      @api differenthouradditonalheading
      @api deletebutton
      @api frequency_list_type //Store the value of frequency list
      
      // Formatted date Label
      @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`
      
      //Fetching Frequency List
    @wire(owcFrequencyMetaData)
    wiredfetchdata({ data,error}) {
            if(data){
                this.frequency_list_type = data;
                console.log('new list'+JSON.stringify(this.frequency_list_type));
            }else{
                this.errorMsg = error;
            }
    }
      
      
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
              event.preventDefault();
              this.isRenderedCallback = false 
              switch ( event.target.name ) {        
                  case "eachPayRateBegDateAdditional":
                      this.eachPayRateBegDateAdditional = event.target.value;
                      this.eachPayRateBegDateAdditional === null ? this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]').value = '' : ''
                      this.handlePOWDateValidity(this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]'), this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]'), this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]').value, this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]').value)
                      console.log('eachPayRateBegDateAdditional ::: ', this.eachPayRateBegDateAdditional);
                  break;
                  case "eachPayRateEndDateAdditional":
                      this.eachPayRateEndDateAdditional = event.target.value;
                      this.eachPayRateEndDateAdditional === null ? this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]').value = '' : ''
                      this.handlePOWDateValidity(this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]'), this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]'), this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]').value, this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]').value)
                      console.log('eachPayRateEndDateAdditional ::: ', this.eachPayRateEndDateAdditional);
                  break;
                  case "paidAmountForEachDayAdditional":            
                      this.paidAmountForEachDayAdditional = event.target.value;
                      this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountForEachDayAdditional"]'),this.template.querySelector('[data-id="promisedAmountForEachDayAdditional"]'))
                      this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidAmountForEachDayAdditional"]'))
                      console.log('paidAmountForEachDayAdditional ::: ', this.paidAmountForEachDayAdditional);
                  break;
                  case "promisedAmountForEachDayAdditional":            
                      this.promisedAmountForEachDayAdditional = event.target.value;
                      this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountForEachDayAdditional"]'),this.template.querySelector('[data-id="promisedAmountForEachDayAdditional"]'))
                      this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedAmountForEachDayAdditional"]'))
                      console.log('promisedAmountForEachDayAdditional ::: ', this.promisedAmountForEachDayAdditional);
                  break;
                  case "frequencyOfEachDayAdditional":
                  this.frequencyOfEachDayAdditional = event.target.value;                    
                  this.handleforActivityFocusAdditional()
                  console.log('frequencyOfEachDayAdditional ::: ', this.frequencyOfEachDayAdditional);
              break; 
                  
                                       
              }  
         
          }
      
          @api
          handleSalaryRateAddSectionData(){
              const selectEvent = new CustomEvent('salaryratedataafterdelete', {
                  detail: {     
                      salaryRateSectionId : this.salaryratesectionid,            
                      paidAmountForEachDayAdditional : this.paidAmountForEachDayAdditional,
                      promisedAmountForEachDayAdditional : this.promisedAmountForEachDayAdditional,
                      frequencyOfEachDayAdditional : this.frequencyOfEachDayAdditional,
                      eachPayRateBegDateAdditional : this.eachPayRateBegDateAdditional,
                      eachPayRateEndDateAdditional : this.eachPayRateEndDateAdditional,   
                  }
              });
              this.dispatchEvent(selectEvent);
          }
          //Evnt for handling all the data
          handleEvent(){
              const selectEvent = new CustomEvent('salaryrateadditionalevent', {
                  detail: {
                      paidAmountForEachDayAdditional : this.paidAmountForEachDayAdditional,
                      promisedAmountForEachDayAdditional : this.promisedAmountForEachDayAdditional,
                      frequencyOfEachDayAdditional : this.frequencyOfEachDayAdditional,
                      eachPayRateBegDateAdditional : this.eachPayRateBegDateAdditional,
                      eachPayRateEndDateAdditional : this.eachPayRateEndDateAdditional,                   
      
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
          
          isNotAdditionalPaidAmountSalaryRate = false
          isNotAdditionalPromisedAmountSalaryRate = false
          isAdditionalPaidOrPromisedAmountSalaryRate = false
          isDNotAdditionalSalaryRateDateAcceptable = false
      
       
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
              const selectEvent = new CustomEvent('salaryrateadditionalvalidityevent', {
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
           handleSalaryRateAdditionalDelete(event){
              event.preventDefault()
              console.log('salaryRateSectionId in child ::: ', this.salaryratesectionid)
              const selectEvent = new CustomEvent('customsalaryrateadddeleteevent', {
                  detail: {
                      salaryRateSectionId : this.salaryratesectionid
                  }
              });
              this.dispatchEvent(selectEvent);
          }
          /* This method is called from parent component when user click on continue button on this section. */
          @api 
          owcSalaryRateAdditionalFromParent(){ 
              
                      const paidAmountForEachDayAdditionalId = this.template.querySelector('[data-id="paidAmountForEachDayAdditional"]');
                      const promisedAmountForEachDayAdditionalId = this.template.querySelector('[data-id="promisedAmountForEachDayAdditional"]');
                      this.isNotAdditionalPaidAmountSalaryRate = this.handlePOWAmountValidity(paidAmountForEachDayAdditionalId);
                      this.isNotAdditionalPromisedAmountSalaryRate = this.handlePOWAmountValidity(promisedAmountForEachDayAdditionalId)
                      this.isAdditionalPaidOrPromisedAmountSalaryRate = this.handleRequiredSetValidation(paidAmountForEachDayAdditionalId,promisedAmountForEachDayAdditionalId)
      
          
                      let eachPayRateBegDateAdditionalId = this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]');
                      let eachPayRateEndDateAdditionalId = this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]');
                      this.isDNotAdditionalSalaryRateDateAcceptable = this.handlePOWDateValidity(eachPayRateBegDateAdditionalId, eachPayRateEndDateAdditionalId, eachPayRateBegDateAdditionalId.value, eachPayRateEndDateAdditionalId.value);                         
                 
      
                  // Add focus to the validation field
                  this.isNotAdditionalPaidAmountSalaryRate === true ? paidAmountForEachDayAdditionalId.focus() : ''
                  this.isNotAdditionalPromisedAmountSalaryRate === true ? promisedAmountForEachDayAdditionalId.focus() : ''
                  this.isAdditionalPaidOrPromisedAmountSalaryRate === true ? paidAmountForEachDayAdditionalId.focus() && promisedAmountForEachDayAdditionalId.focus() : ''
                  this.isDNotAdditionalSalaryRateDateAcceptable === true ? eachPayRateBegDateAdditional.focus() : '' 
          
             
      
              return (this.isNotAdditionalPaidAmountSalaryRate === true 
                  || this.isNotAdditionalPromisedAmountSalaryRate === true 
                  || this.isAdditionalPaidOrPromisedAmountSalaryRate === true
                  || this.isDNotAdditionalSalaryRateDateAcceptable === true ) ? this.handleCustomValidityEvent() : this.handleEvent();    
          }
      
          //Method for importing comp values from parent comp
          @api 
          owcSalaryRateAdditionalFromForChild(strString, isFormPreviewMode){
              this.paymentWagesDetailPreview = strString
              this.isFormPreviewMode = isFormPreviewMode
      
              console.log('Additional Section Data ',JSON.stringify(strString))
              console.log("Salary isFormMode:",this.isFormPreviewMode)
      
              this.paidAmountForEachDayAdditional = strString.paidAmountForEachDayAdditional
              this.promisedAmountForEachDayAdditional = strString.promisedAmountForEachDayAdditional
              this.frequencyOfEachDayAdditional = strString.frequencyOfEachDayAdditional
              this.eachPayRateBegDateAdditional = strString.eachPayRateBegDateAdditional
              this.eachPayRateEndDateAdditional = strString.eachPayRateEndDateAdditional
              
              
      
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