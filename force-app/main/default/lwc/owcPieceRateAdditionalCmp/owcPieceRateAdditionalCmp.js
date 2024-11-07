import { LightningElement, api,wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { radioOptions, customLabelValues} from 'c/owcUtils';
import owcFrequencyMetaData from '@salesforce/apex/OWCPaymentOfWagesController.fetchFrequencyMetaData';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcPieceRateAdditionalCmp extends LightningElement {
      //Store the value of Amount paid different hour
      @api paidPieceRateAdditional //Store the value of Amount paid different hour additional section
      @api promisedPieceRateAdditional //Store the value of Amount promised different hour additional section
      @api numberOfUnitsAdditional
      @api pieceRateBegDateAdditional
      @api pieceRateEndDateAdditional
      @api perUnitPaymentOfWagesAdditional
      @api otherAdditional
      @api isPerUnitOtherAdditional = false
      @api pieceratesectionid
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
      
    //Fetching Units list
    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data, error }){
        if(data){
            console.log('data:', JSON.stringify(data));
            this.perUnitPaymentOfWagesValue = data[0].perUnitPaymentOfWages;
        }
        else if(error){
            this.error = error;
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
                  case "pieceRateBegDateAdditional":
                      this.pieceRateBegDateAdditional = event.target.value;
                      this.pieceRateBegDateAdditional === null ? this.template.querySelector('[data-id="pieceRateBegDateAdditional"]').value = '' : ''
                      this.handlePOWDateValidity(this.template.querySelector('[data-id="pieceRateBegDateAdditional"]'), this.template.querySelector('[data-id="pieceRateEndDateAdditional"]'), this.template.querySelector('[data-id="pieceRateBegDateAdditional"]').value, this.template.querySelector('[data-id="pieceRateEndDateAdditional"]').value)
                      console.log('pieceRateBegDateAdditional ::: ', this.pieceRateBegDateAdditional);
                  break;
                  case "pieceRateEndDateAdditional":
                      this.pieceRateEndDateAdditional = event.target.value;
                      this.pieceRateEndDateAdditional === null ? this.template.querySelector('[data-id="pieceRateEndDateAdditional"]').value = '' : ''
                      this.handlePOWDateValidity(this.template.querySelector('[data-id="pieceRateBegDateAdditional"]'), this.template.querySelector('[data-id="pieceRateEndDateAdditional"]'), this.template.querySelector('[data-id="pieceRateBegDateAdditional"]').value, this.template.querySelector('[data-id="pieceRateEndDateAdditional"]').value)
                      console.log('pieceRateEndDateAdditional ::: ', this.pieceRateEndDateAdditional);
                  break;
                  case "paidPieceRateAdditional":            
                      this.paidPieceRateAdditional = event.target.value;
                      this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidPieceRateAdditional"]'))
                      console.log('paidPieceRateAdditional ::: ', this.paidPieceRateAdditional);
                  break;
                  case "promisedPieceRateAdditional":            
                      this.promisedPieceRateAdditional = event.target.value;
                      this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedPieceRateAdditional"]'))
                      console.log('promisedPieceRateAdditional ::: ', this.promisedPieceRateAdditional);
                  break;
                  case "numberOfUnitsAdditional":
                    this.numberOfUnitsAdditional = event.target.value;                    
                    this.handleforActivityFocusAdditional()
                    console.log('numberOfUnitsAdditional ::: ', this.numberOfUnitsAdditional);
                  break; 
                  case "perUnitPaymentOfWagesAdditional":            
                    this.perUnitPaymentOfWagesAdditional = event.target.value;
                    console.log('perUnitPaymentOfWagesAdditionalvalue>>>>>>>>>', this.perUnitPaymentOfWagesAdditional);
                      if(this.perUnitPaymentOfWagesAdditional == this.perUnitPaymentOfWagesValue[10].value){
                          this.isPerUnitOtherAdditional = true
                      }else{
                          this.isPerUnitOtherAdditional = false
                      }
                  break;
                  case "otherAdditional":            
                    this.otherAdditional = event.target.value;
                    this.handleotherAdditionalFocus()
                    console.log('otherAdditional ::: ', this.otherAdditional);
                 break; 
                                       
              }  
         
          }
      
          @api
          handlePieceRateAddSectionData(){
              const selectEvent = new CustomEvent('pieceratedataafterdelete', {
                  detail: {     
                      pieceRateSectionId : this.pieceratesectionid,            
                      paidPieceRateAdditional : this.paidPieceRateAdditional,
                      promisedPieceRateAdditional : this.promisedPieceRateAdditional,
                      numberOfUnitsAdditional : this.numberOfUnitsAdditional,
                      pieceRateBegDateAdditional : this.pieceRateBegDateAdditional,
                      pieceRateEndDateAdditional : this.pieceRateEndDateAdditional,
                      perUnitPaymentOfWagesAdditional : this.perUnitPaymentOfWagesAdditional, 
                      isPerUnitOtherAdditional : this.isPerUnitOtherAdditional,  
                      otherAdditional : this.otherAdditional, 
                  }
              });
              this.dispatchEvent(selectEvent);
          }
          //Evnt for handling all the data
          handleEvent(){
              const selectEvent = new CustomEvent('piecerateadditionalevent', {
                  detail: {
                      paidPieceRateAdditional : this.paidPieceRateAdditional,
                      promisedPieceRateAdditional : this.promisedPieceRateAdditional,
                      numberOfUnitsAdditional : this.numberOfUnitsAdditional,
                      pieceRateBegDateAdditional : this.pieceRateBegDateAdditional,
                      pieceRateEndDateAdditional : this.pieceRateEndDateAdditional, 
                      perUnitPaymentOfWagesAdditional : this.perUnitPaymentOfWagesAdditional,   
                      isPerUnitOtherAdditional : this.isPerUnitOtherAdditional,   
                      otherAdditional : this.otherAdditional,            
      
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
          
          isNotAdditionalPaidAmountPieceRate = false
          isNotAdditionalPromisedAmountPieceRate = false
          isDNotAdditionalPieceRateDateAcceptable = false
      
       
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
              const selectEvent = new CustomEvent('piecerateadditionalvalidityevent', {
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
           handlePieceRateAdditionalDelete(event){
              event.preventDefault()
              console.log('pieceRateSectionId in child ::: ', this.pieceratesectionid)
              const selectEvent = new CustomEvent('custompiecerateadddeleteevent', {
                  detail: {
                      pieceRateSectionId : this.pieceratesectionid
                  }
              });
              this.dispatchEvent(selectEvent);
          }
          /* This method is called from parent component when user click on continue button on this section. */
          @api 
          owcPieceRateAdditionalFromParent(){ 
              
                      const paidPieceRateAdditionalId = this.template.querySelector('[data-id="paidPieceRateAdditional"]');
                      const promisedPieceRateAdditionalId = this.template.querySelector('[data-id="promisedPieceRateAdditional"]');
                      this.isNotAdditionalPaidAmountPieceRate = this.handlePOWAmountValidity(paidPieceRateAdditionalId);
                      this.isNotAdditionalPromisedAmountPieceRate = this.handlePOWAmountValidity(promisedPieceRateAdditionalId)
      
          
                      let pieceRateBegDateAdditionalId = this.template.querySelector('[data-id="pieceRateBegDateAdditional"]');
                      let pieceRateEndDateAdditionalId = this.template.querySelector('[data-id="pieceRateEndDateAdditional"]');
                      this.isDNotAdditionalPieceRateDateAcceptable = this.handlePOWDateValidity(pieceRateBegDateAdditionalId, pieceRateEndDateAdditionalId, pieceRateBegDateAdditionalId.value, pieceRateEndDateAdditionalId.value);                         
                 
      
                  // Add focus to the validation field
                  this.isNotAdditionalPaidAmountPieceRate === true ? paidPieceRateAdditional.focus() : ''
                  this.isNotAdditionalPromisedAmountPieceRate === true ? promisedPieceRateAdditional.focus() : ''
                  this.isDNotAdditionalPieceRateDateAcceptable === true ? pieceRateBegDateAdditional.focus() : '' 
          
             
      
              return (this.isNotAdditionalPaidAmountPieceRate === true 
                  || this.isNotAdditionalPromisedAmountPieceRate === true 
                  || this.isDNotAdditionalPieceRateDateAcceptable === true ) ? this.handleCustomValidityEvent() : this.handleEvent();    
          }
      
          //Method for importing comp values from parent comp
          @api 
          owcPieceRateAdditionalFromForChild(strString, isFormPreviewMode){
              this.paymentWagesDetailPreview = strString
              this.isFormPreviewMode = isFormPreviewMode
      
              console.log('Additional Section Data ',JSON.stringify(strString))
      
              this.paidPieceRateAdditional = strString.paidPieceRateAdditional
              this.promisedPieceRateAdditional = strString.promisedPieceRateAdditional
              this.numberOfUnitsAdditional = strString.numberOfUnitsAdditional
              this.pieceRateBegDateAdditional = strString.pieceRateBegDateAdditional
              this.pieceRateEndDateAdditional = strString.pieceRateEndDateAdditional
              this.perUnitPaymentOfWagesAdditional = strString.perUnitPaymentOfWagesAdditional
              this.isPerUnitOtherAdditional = strString.isPerUnitOtherAdditional
              this.otherAdditional = strString.otherAdditional
              
              
      
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