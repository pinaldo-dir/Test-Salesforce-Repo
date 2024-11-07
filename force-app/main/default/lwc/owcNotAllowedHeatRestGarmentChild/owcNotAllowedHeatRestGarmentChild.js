import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';

export default class OwcNotAllowedHeatRestGarmentChild extends LightningElement {
     // Attributes
     @api sectionid;
     @api additionalName;
     @api isFormPreviewMode = false;
     @api powdetails
     @api iswagedefpreview
     @api 
 
     // Import custom label values
     customLabelValues = customLabelValues;
 
     // Formatted date Label
     @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`
     
     // Connected Callback method load on doinit
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
 
         this.powdetails !== undefined || this.powdetails !== null ? this.paymentOfWagesDetails = this.powdetails : ''
         this.handleHourlyRateOption();
     }
 
     @api paymentOfWagesDetails
     @api isShowServerResponse = false;
     @api
     handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
         console.log('Payment detail in child 12::: ', JSON.stringify(paymentOfWagesDetails));
         this.paymentOfWagesDetails = paymentOfWagesDetails;
         this.handleHourlyRateOption();
         this.paymentOfWagesDetails !== undefined ? this.isShowServerResponse = true : this.isShowServerResponse = false;
         this.isFormPreviewMode = isFormPreviewMode;
     }
 
     @api violationTypeVariablesForOneHourlyRate;
     @api isOneHourlyRatePOW = false;
     @api isSalaryRatePOW = false;
     @api violationTypeVariablesForOneSalaryRate;
     async handleHourlyRateOption(){
         try{
             await this.getAllVilationTypeVariablesForOneHourRateRec('81');
         }catch (error){
             console.log('error', error);
         }
         // if(this.paymentOfWagesDetails.HourlyOptionValue === true){
         //     try{
         //         await this.getAllVilationTypeVariablesForOneHourRateRec('81');
         //     }catch (error){
         //         console.log('error', error);
         //     }
         // }
         // else{
         //     this.isOneHourlyRatePOW = false;
         //     this.violationTypeVariablesForOneHourlyRate = undefined;
         // }
         // if(this.paymentOfWagesDetails.salaryRateOptionValue === true){
         //     try{
         //         await this.getAllVilationTypeVariablesForSalaryRateRec('83');
         //     }catch (error){
         //         console.log('error', error);
         //     }
         // }
         // else{
         //     this.isSalaryRatePOW = false;
         //     this.violationTypeVariablesForOneSalaryRate = undefined;
         // }
     }
 
     getAllVilationTypeVariablesForOneHourRateRec(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     if(result[i].dataType === 'Date'){
                         result[i].dateFormat = true;
                     }
                     else if(result[i].dataType === 'Currency'){
                         result[i].currencyFormat = true;
                     }
                     else if(result[i].dataType === 'Decimal' || result[i].dataType === 'Integer'){
                         result[i].numberFormat = true;
                     }
                     else{
                         result[i].inputFormat = true;
                     }
                     result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
                     result[i].name === 'VTV0081' ? result[i].helpText = true : result[i].helpText = false;
                     result[i].value = '';
                 }
                 // Check the datatype of the input fields
 
                  console.log('wage def result ::: ', JSON.stringify(result));
                  if(this.violationTypeVariablesForOneHourlyRate !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOneHourlyRate = result;
                     this.violationTypeVariablesForOneHourlyRate.length > 0 ? this.isOneHourlyRatePOW = true : this.isOneHourlyRatePOW = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     getAllVilationTypeVariablesForSalaryRateRec(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     if(result[i].dataType === 'Date'){
                         result[i].dateFormat = true;
                     }
                     else if(result[i].dataType === 'Currency'){
                         result[i].currencyFormat = true;
                     }
                     else{
                         result[i].inputFormat = true;
                     }
                     result[i].name === 'VTV0081' ? result[i].helpText = true : result[i].helpText = false;
                     result[i].value = '';
                 }
                  console.log('wage def result ::: ', JSON.stringify(result));
                  if(this.violationTypeVariablesForOneSalaryRate !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOneSalaryRate = result;
                     this.violationTypeVariablesForOneSalaryRate.length > 0 ? this.isSalaryRatePOW = true : this.isSalaryRatePOW = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @api
     handleRestClaimSectionData(){
         const selectEvent = new CustomEvent('overtimesectiondeleteevent', {
             detail: this.restClaimInfoObj()},
         );
         this.dispatchEvent(selectEvent);
     }
 
     // This method is used to take the input values from the end user.c/hideSpinnerCmp
     handleChange(event){
         event.preventDefault();
         this.isRenderedCallback = false
         switch ( event.target.name ) {
             
         }
         if(this.violationTypeVariablesForOneHourlyRate !== undefined){
             for(var i=0; i<this.violationTypeVariablesForOneHourlyRate.length; i++){
                 this.violationTypeVariablesForOneHourlyRate[i].name === event.target.name ? this.violationTypeVariablesForOneHourlyRate[i].value = event.target.value : ''
             }
         }
         if(this.violationTypeVariablesForOneSalaryRate !== undefined){
             for(var i=0; i<this.violationTypeVariablesForOneSalaryRate.length; i++){
                 this.violationTypeVariablesForOneSalaryRate[i].name === event.target.name ? this.violationTypeVariablesForOneSalaryRate[i].value = event.target.value : ''
             }
         }
     }
 
     handleWageDefValidityEvent(){
         const selectEvent = new CustomEvent('overtimedefchildvalidityevent', {
             detail: {
                 currentStep : true
             }
         });
         this.dispatchEvent(selectEvent);
     }
 
     isNameValid = false
     // This method is used to collect the parent component data.
     @api
     handleOverTimeParentData(){
         // Validity check fotr this section
         
         this.isNameValid === true ? this.handleWageDefValidityEvent() : this.handleOverTimeParentInfo();
     }
 
     @api
     handleOverTimeParentInfo(){
         const selectEvent = new CustomEvent('overtimecustominfoevent', {
             detail:{
                 restClaimInfoObj : this.restClaimInfoObj(),
                 vtCaseIssueObj : this.vtCaseIssueObj()
             }
         });
         this.dispatchEvent(selectEvent);
     }
 
     @api 
     vtCaseIssueObj(){
         return{
             violationTypeVariablesForOneHourlyRate : this.violationTypeVariablesForOneHourlyRate,
             // violationTypeVariablesForOneSalaryRate : this.violationTypeVariablesForOneSalaryRate
         }
     }
     @api
     restClaimInfoObj(){
         return {
             sectionId : this.sectionid,
             violationTypeVariablesForOneHourlyRate : this.violationTypeVariablesForOneHourlyRate,
             isOneHourlyRatePOW : this.isOneHourlyRatePOW,
             isSalaryRatePOW : this.isSalaryRatePOW,
             violationTypeVariablesForOneSalaryRate : this.violationTypeVariablesForOneSalaryRate
         }
     }
 
     @api
     handleOverTimeChildData(strString, isFormPreviewMode){
         console.log('strString in overtime sub child ::: ', JSON.stringify(strString));
         this.violationTypeVariablesForOneHourlyRate = strString.violationTypeVariablesForOneHourlyRate,
         this.isOneHourlyRatePOW = strString.isOneHourlyRatePOW,
         this.isSalaryRatePOW = strString.isSalaryRatePOW,
         this.violationTypeVariablesForOneSalaryRate = strString.violationTypeVariablesForOneSalaryRate
     }
 
     renderedCallback(){
         if(this.paymentOfWagesDetails !== undefined && this.isShowServerResponse === true){
             this.handleHourlyRateOption();
             this.isShowServerResponse = false;
         }
     }
 
     @api isHelpText= false;
     @api helpText;
     // Help text 
     handleHelpText(event){
         const learnMoreName = event.target.name;
         if(learnMoreName === "hourlyRateMsg"){
             this.isHelpText = true;
             this.helpText = this.customLabelValues.OWC_hourly_rate_pay_helptext_heat_rest;
         }
     }
     handleHelpTextEvent(event){
         const helpTextValue = event.detail;
         this.isHelpText = helpTextValue.isClosedHelpText
     }
 }