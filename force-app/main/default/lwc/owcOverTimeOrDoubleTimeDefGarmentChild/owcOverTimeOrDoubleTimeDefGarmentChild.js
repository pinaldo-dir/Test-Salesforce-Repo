import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import fetchYesOrNoOptions from '@salesforce/apex/OwcWorkweekAndWorkdayController.fetchYesOrNoOptions';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import StartDate from '@salesforce/schema/Contract.StartDate';

export default class OwcOverTimeOrDoubleTimeDefGarmentChild extends LightningElement {
     // Attributes
     @api sectionid;
     @api additionalName;
     @api isFormPreviewMode = false;
     @api options;
     @api claimDoubleTimeOnly;
     @api isDoubleTimeClaim = false;
     @api isRenderedCallback = false;
     @api userWorkedHours;
     @api sevenDayHours;
     @api weeklyHours;
     @api POWDetails;
     @api powdetails;
     @api owedDoubleTime;
     @api doubleTimeOwedValue;
     @api overtimeBalanceOwed;
     @api iswagedefpreview;
     @api overtimeAdditinalBalance;
     @api isfarmlabour;
     @api is_domestic_worker;
 
     // Imported Custom labels
     customLabelValues = customLabelValues
 
     @api get isAdditionalFieldsTrigger(){
         return this.isOneHourly === false && this.isOneHourlyRec === false && this.isSalaryRatePOWRec === false && this.isSalaryRatePOW === false && this.isOneHourlyRecs === false && this.isSalaryRatePOWRecs === false;
     }
 
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
         console.log('isfarmlabour ::: ', this.isfarmlabour);
         console.log('is_domestic_worker ::: ', this.is_domestic_worker)
         // this.POWDetails = this.powdetails
         
         this.userworkedhours !== undefined || this.userworkedhours !== null ? this.userWorkedHours = this.userworkedhours : this.userWorkedHours = ''
     }
 
     @api get isTempRender(){
         return this.isOneHourly === true || this.isSalaryRatePOW === true
     }
 
     @api get isTempRecRender(){
         return this.isOneHourlyRec === true || this.isSalaryRatePOWRec === true
     }
 
     @api get isTempRecsRender(){
         return this.isOneHourlyRecs === true || this.isSalaryRatePOWRecs === true
     }
     async handleAdditionalCall(){
         
     }
 
     @wire(getOWCPreliminaryMetaData)
     getOWCPreliminaryMetaData({data,error}){
         if(data){
             this.options = data[0].owcOverttimeOptions;
         }else{
             this.errorMsg = error;
         }
     }
 
     @wire(fetchYesOrNoOptions)
     wiredfetchYesOrNoData({ data,error}) {
             if(data){
                 
             }else{
                 this.errorMsg = error;
             }
     }
 
     @api
     handleOverTimeSectionData(){
         const selectEvent = new CustomEvent('overtimesectiondeleteevent', {
             detail: this.overTimeInfoObj()},
         );
         this.dispatchEvent(selectEvent);
     }
 
     @api isBothOverTime = false;
     @api isDoubleTimeOnly = false;
     
     @track otStartDate = null;
     @track otEndDate = null;
     @track ot19StartDate = null;
     @track ot19EndDate = null;
     @track dt10StartDate = null;
     @track dt10EndDate = null;
     @track ot10StartDate = null;
     @track ot10EndDate = null;
     @track dt15EndDate = null;
     @track dt15StartDate = null;
     @track ot28EndDate = null;
     @track ot28StartDate = null;
 
     // Reset variables 
     resetValues(){
         
     }
 
     // Reset all variables related to OT13, OT13.1, OT13.2, OT13.3, DT10
     resetDT10Variables(vtvDt1, vtvDt2, vtvDt3, vtvDt4, vtvDt5, isvtv1, isvtv2, isvtv3, isvtv4, isvtv5, isCase1, isCase2, isCase3, isCase4, isCase5){
         this.violationTypeVariablesForDt10 = vtvDt1;
         this.violationTypeVariablesForOt13 = vtvDt2;
         this.violationTypeVariablesForOt13_1 = vtvDt3;
         this.violationTypeVariablesForOt13_2 = vtvDt4;
         this.violationTypeVariablesForOt13_3 = vtvDt5;
         this.isCaseIssueDT10 = isvtv1;
         this.isCaseIssueOT13 = isvtv2;
         this.isCaseIssueOT13_1 = isvtv3;
         this.isCaseIssueOT13_2 = isvtv4;
         this.isCaseIssueOT13_3 = isvtv5;
         this.isDT10Issue = isCase1;
         this.isOT13Issue = isCase2;
         this.isOT13_1Issue = isCase3;
         this.isOT13_2Issue = isCase4;
         this.isOT13_3Issue = isCase5;
     }
 
     // Reset all variables related to OT13, OT13.1, OT13.2, OT13.3, OT10
     resetOT13Variables(vtvDt1, vtvDt2, vtvDt3, vtvDt4, vtvDt5, isvtv1, isvtv2, isvtv3, isvtv4, isvtv5, isCase1, isCase2, isCase3, isCase4, isCase5){
         this.violationTypeVariablesForOt10 = vtvDt1;
         this.violationTypeVariablesForOt13 = vtvDt2;
         this.violationTypeVariablesForOt13_1 = vtvDt3;
         this.violationTypeVariablesForOt13_2 = vtvDt4;
         this.violationTypeVariablesForOt13_3 = vtvDt5;
         this.isCaseIssueOT10 = isvtv1;
         this.isCaseIssueOT13 = isvtv2;
         this.isCaseIssueOT13_1 = isvtv3;
         this.isCaseIssueOT13_2 = isvtv4;
         this.isCaseIssueOT13_3 = isvtv5;
         this.isOT10Issue = isCase1;
         this.isOT13Issue = isCase2;
         this.isOT13_1Issue = isCase3;
         this.isOT13_2Issue = isCase4;
         this.isOT13_3Issue = isCase5;
     }
 
     // Reset all variables related to OT22, OT22.1, OT22.2, OT22.3, OT19
     resetOT22Variables(vtvDt1, vtvDt2, vtvDt3, vtvDt4, vtvDt5, isvtv1, isvtv2, isvtv3, isvtv4, isvtv5, isCase1, isCase2, isCase3, isCase4, isCase5){
         this.violationTypeVariablesForOt19 = vtvDt1;
         this.violationTypeVariablesForOt22 = vtvDt2;
         this.violationTypeVariablesForOt22_1 = vtvDt3;
         this.violationTypeVariablesForOt22_2 = vtvDt4;
         this.violationTypeVariablesForOt22_3 = vtvDt5;
         this.isCaseIssueOT19 = isvtv1;
         this.isCaseIssueOT22 = isvtv2;
         this.isCaseIssueOT22_1 = isvtv3;
         this.isCaseIssueOT22_2 = isvtv4;
         this.isCaseIssueOT22_3 = isvtv5;
         this.isOT19Issue = isCase1;
         this.isOT22Issue = isCase2;
         this.isOT22_1Issue = isCase3;
         this.isOT22_2Issue = isCase4;
         this.isOT22_3Issue = isCase5;
     }
 
     @api doubleTimeOwedValueDT16;
     @api doubleTimeOwedValueOT28;
     @api noOfDtTimeHours;
     @api noOfOtTimeHours;
     @api noOfOt19TimeHours;
     @api noOfDt19TimeHours;
     @api dt16TimeHours;
     @api ot29TimeHours;
 
     // This method is used to take the input values from the end user.c/hideSpinnerCmp
     handleChange(event){
         event.preventDefault();
         this.isRenderedCallback = false
         switch ( event.target.name ) {
             case "overtimeAdditinalBalance":
                 this.overtimeAdditinalBalance = event.target.value;
                 break;
             case "doubleTimeOwedValue":
                 this.doubleTimeOwedValue = event.target.value;
                 break;
             case "overtimeBalanceOwed":
                 this.overtimeBalanceOwed = event.target.value;
                 break;
             case "doubleTimeOwedValueDT16":
                 this.doubleTimeOwedValueDT16 = event.target.value;
                 break;
             case "doubleTimeOwedValueOT28":
                 this.doubleTimeOwedValueOT28 = event.target.value;
                 break;
             case "claimDoubleTimeOnly":
                 this.claimDoubleTimeOnly = event.target.value;
                 if(this.claimDoubleTimeOnly === this.options[1].value){
                     this.isDoubleTimeClaim = true;
                     this.isBothOverTime = false;
                     this.isDoubleTimeOnly = false;
                     this.violationTypeVariablesForAdditional = undefined;
                     this.isAdditonalCheck = false;
                     this.violationTypeVariablesForOneHourlyRecs = undefined;
                     this.isOneHourlyRecs = false;
                     this.resetDT10Variables(undefined, undefined,  undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                     this.resetOT13Variables(undefined, undefined,  undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                 }
                 else if((this.claimDoubleTimeOnly === this.options[3].value) || (this.claimDoubleTimeOnly === this.options[4].value)){
                     this.violationTypeVariablesForOneHourly = undefined;
                     this.isOneHourly = false;
                     this.isDoubleTimeClaim = false;
                     this.isBothOverTime = true;
                     this.isDoubleTimeOnly = false;
                     this.violationTypeVariablesForOneHourlyRecs = undefined;
                     this.isOneHourlyRecs = false;
                     this.resetDT10Variables(undefined, undefined,  undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                     this.resetOT22Variables(undefined, undefined, undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                 }
                 else if(this.claimDoubleTimeOnly === this.options[2].value){
                     this.violationTypeVariablesForOneHourly = undefined;
                     this.isOneHourly = false;
                     this.isDoubleTimeClaim = false;
                     this.isBothOverTime = false;
                     this.isDoubleTimeOnly = true;
                     this.violationTypeVariablesForAdditional = undefined;
                     this.isAdditonalCheck = false;
                     this.resetOT13Variables(undefined, undefined,  undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                     this.resetOT22Variables(undefined, undefined, undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                 }
                 else{
                     this.violationTypeVariablesForOneHourly = undefined;
                     this.isOneHourly = false;
                     this.isDoubleTimeClaim = false;
                     this.isBothOverTime = false;
                     this.isDoubleTimeOnly = false;
                     this.violationTypeVariablesForAdditional = undefined;
                     this.isAdditonalCheck = false;
                     this.violationTypeVariablesForOneHourlyRecs = undefined;
                     this.isOneHourlyRecs = false;
                     this.isOT28Issue = false;
                     this.isDT15Issue = false;
                     this.violationTypeVariablesForOt28 = undefined;
                     this.violationTypeVariablesForDt15 = undefined;
                     this.resetDT10Variables(undefined, undefined,  undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                     this.resetOT13Variables(undefined, undefined,  undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                     this.resetOT22Variables(undefined, undefined, undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                 }
                 this.handleServerCall();
                 break;
                 case "owedDoubleTime":
                     this.owedDoubleTime = event.target.value;
                     break;
         }
 
         if(this.violationTypeVariablesForDt15 !== undefined){
             let startDateId = this.template.querySelector('[data-id="VTV1633"]');
             let endDateId = this.template.querySelector('[data-id="VTV1634"]');
             let dt16HoursId = this.template.querySelector('[data-id="VTV1635"]');
             for(var i=0; i<this.violationTypeVariablesForDt15.length; i++){
                 if(event.target.name === 'VTV1635'){
                     this.violationTypeVariablesForDt15[i].name === event.target.name ? this.violationTypeVariablesForDt15[i].value = event.target.value : '';
                     this.dt16TimeHours = event.target.value;
                     this.checkDT16DecimalValidity(event.target.value, dt16HoursId);
                 }
                 else{
                     this.violationTypeVariablesForDt15[i].name === event.target.name ? this.violationTypeVariablesForDt15[i].value = event.target.value : '';
                     this.violationTypeVariablesForDt15[i].name === 'VTV1633' ? this.dt15StartDate = this.violationTypeVariablesForDt15[i].value : '';
                     this.violationTypeVariablesForDt15[i].name === 'VTV1634' ? this.dt15EndDate = this.violationTypeVariablesForDt15[i].value : '';
                 }
             }
             Boolean(this.dt15StartDate) || Boolean(this.dt15EndDate) ? this.checkClaimPeriod(this.dt15StartDate, this.dt15EndDate, startDateId, endDateId) : '';
             // this.checkCalendarYearForOT10(this.ot10StartDate, this.ot10EndDate);
         }
 
         if(this.violationTypeVariablesForOt28 !== undefined){
             let startDateId = this.template.querySelector('[data-id="VTV1499"]');
             let endDateId = this.template.querySelector('[data-id="VTV1500"]');
             let ot28HoursId = this.template.querySelector('[data-id="VTV1501"]');
             for(var i=0; i<this.violationTypeVariablesForOt28.length; i++){
                 if(event.target.name === 'VTV1501'){
                     this.violationTypeVariablesForOt28[i].name === event.target.name ? this.violationTypeVariablesForOt28[i].value = event.target.value : '';
                     this.noOfOT28HoursTime = event.target.value;
                     this.checkOT28DecimalValidity(event.target.value, ot28HoursId);
                 }
                 else{
                     this.violationTypeVariablesForOt28[i].name === event.target.name ? this.violationTypeVariablesForOt28[i].value = event.target.value : '';
                     this.violationTypeVariablesForOt28[i].name === 'VTV1499' ? this.ot28StartDate = this.violationTypeVariablesForOt28[i].value : '';
                     this.violationTypeVariablesForOt28[i].name === 'VTV1500' ? this.ot28EndDate = this.violationTypeVariablesForOt28[i].value : '';
                 }
             }
             Boolean(this.ot28StartDate) || Boolean(this.ot28EndDate) ? this.checkClaimPeriod(this.ot28StartDate, this.ot28EndDate, startDateId, endDateId) : '';
             // this.checkCalendarYearForOT10(this.ot10StartDate, this.ot10EndDate);
         }
 
         if(this.violationTypeVariablesForAdditional !== undefined){
             let startDateId = this.template.querySelector('[data-id="VTV1030"]');
             let endDateId = this.template.querySelector('[data-id="VTV1031"]');
             let dtHoursId = this.template.querySelector('[data-id="VTV1032"]');
             let otHoursId = this.template.querySelector('[data-id="VTV1029"]');
             for(var i=0; i<this.violationTypeVariablesForAdditional.length; i++){
                 if(event.target.name === 'VTV1032'){
                     this.violationTypeVariablesForAdditional[i].name === event.target.name ? this.violationTypeVariablesForAdditional[i].value = event.target.value : '';
                     this.noOfDtTimeHours = event.target.value;
                     this.checkDecimalValidity(event.target.value, dtHoursId);
                 }
                 else if(event.target.name === 'VTV1029'){
                     this.violationTypeVariablesForAdditional[i].name === event.target.name ? this.violationTypeVariablesForAdditional[i].value = event.target.value : '';
                     this.noOfOtTimeHours = event.target.value;
                     this.checkDecimalValidity(event.target.value, otHoursId);
                 }
                 else{
                     this.violationTypeVariablesForAdditional[i].name === event.target.name ? this.violationTypeVariablesForAdditional[i].value = event.target.value : '';
                     this.violationTypeVariablesForAdditional[i].name === 'VTV1030' ? this.ot10StartDate = this.violationTypeVariablesForAdditional[i].value : '';
                     this.violationTypeVariablesForAdditional[i].name === 'VTV1031' ? this.ot10EndDate = this.violationTypeVariablesForAdditional[i].value : '';
                 }
             }
             Boolean(this.ot10StartDate) || Boolean(this.ot10EndDate) ? this.checkClaimPeriod(this.ot10StartDate, this.ot10EndDate, startDateId, endDateId) : '';
             this.isfarmlabour != null && this.isfarmlabour === true ? this.checkCalendarYearForOT10(this.ot10StartDate, this.ot10EndDate) : this.resetValues();
         }
 
         if(this.violationTypeVariablesForOneHourly !== undefined){
             let startDateId = this.template.querySelector('[data-id="VTV1450"]');
             let endDateId = this.template.querySelector('[data-id="VTV1451"]');
             let ot19HourTimeId = this.template.querySelector('[data-id="VTV1452"]');
             for(var i=0; i<this.violationTypeVariablesForOneHourly.length; i++){
                 if(event.target.name === 'VTV1452'){
                     this.violationTypeVariablesForOneHourly[i].name === event.target.name ? this.violationTypeVariablesForOneHourly[i].value = event.target.value : '';
                     this.noOfOt19TimeHours = event.target.value;
                     this.checkOT19DecimalValidity(event.target.value, ot19HourTimeId);
                 }
                 else{
                     this.violationTypeVariablesForOneHourly[i].name === event.target.name ? this.violationTypeVariablesForOneHourly[i].value = event.target.value : '';
                     this.violationTypeVariablesForOneHourly[i].name === 'VTV1450' ? this.otStartDate = this.violationTypeVariablesForOneHourly[i].value : '';
                     this.violationTypeVariablesForOneHourly[i].name === 'VTV1451' ? this.otEndDate = this.violationTypeVariablesForOneHourly[i].value : '';
                 }
             }
             Boolean(this.otStartDate) || Boolean(this.otEndDate) ? this.checkClaimPeriod(this.otStartDate, this.otEndDate, startDateId, endDateId) : '';
             this.isfarmlabour != null && this.isfarmlabour === true ? this.checkCalendarYear(this.otStartDate, this.otEndDate) : this.resetValues();
         }
 
         if(this.violationTypeVariablesForOneHourlyRecs !== undefined){
             let startDateId = this.template.querySelector('[data-id="VTV0052"]');
             let endDateId = this.template.querySelector('[data-id="VTV0053"]');
             let dt19Id = this.template.querySelector('[data-id="VTV0054"]');
             for(var i=0; i<this.violationTypeVariablesForOneHourlyRecs.length; i++){
                 if(event.target.name === 'VTV0054'){
                     this.violationTypeVariablesForOneHourlyRecs[i].name === event.target.name ? this.violationTypeVariablesForOneHourlyRecs[i].value = event.target.value : '';
                     this.noOfDt19TimeHours = event.target.value;
                     this.checkDT19DecimalValidity(event.target.value, dt19Id);
                 }
                 else{
                     this.violationTypeVariablesForOneHourlyRecs[i].name === event.target.name ? this.violationTypeVariablesForOneHourlyRecs[i].value = event.target.value : '';
                     this.violationTypeVariablesForOneHourlyRecs[i].name === 'VTV0052' ? this.dt10StartDate = this.violationTypeVariablesForOneHourlyRecs[i].value : '';
                     this.violationTypeVariablesForOneHourlyRecs[i].name === 'VTV0053' ? this.dt10EndDate = this.violationTypeVariablesForOneHourlyRecs[i].value : '';
                 }
             }
             Boolean(this.dt10StartDate) || Boolean(this.dt10EndDate) ? this.checkClaimPeriod(this.dt10StartDate, this.dt10EndDate, startDateId, endDateId) : '';
             this.isfarmlabour != null && this.isfarmlabour === true ? this.checkCalendarYearForDT10(this.dt10StartDate, this.dt10EndDate) : this.resetValues();
         }
     }
 
     @track isOT28DecimalValid = false;
     checkOT28DecimalValidity(values, Ids){
         let decimalCheckRegex = /^(\d+(\.\d{0,2})?|\.?\d{1,2})$/;
         if(Boolean(values) && values.match(decimalCheckRegex)){
             Ids.setCustomValidity('');
             Ids.reportValidity();
             this.isOT28DecimalValid = false;
         }
         else if(Boolean(values)){
             Ids.setCustomValidity('Please enter valid decimal.');
             Ids.reportValidity();
             this.isOT28DecimalValid = true;
         }
         else{
             Ids.setCustomValidity('');
             Ids.reportValidity();
             this.isOT28DecimalValid = false;
         }
     }
 
     @track isDT16DecimalValid = false;
     checkDT16DecimalValidity(values, Ids){
         let decimalCheckRegex = /^(\d+(\.\d{0,2})?|\.?\d{1,2})$/;
         if(Boolean(values) && values.match(decimalCheckRegex)){
             Ids.setCustomValidity('');
             Ids.reportValidity();
             this.isDT16DecimalValid = false;
         }
         else if(Boolean(values)){
             Ids.setCustomValidity('Please enter valid decimal.');
             Ids.reportValidity();
             this.isDT16DecimalValid = true;
         }
         else{
             Ids.setCustomValidity('');
             Ids.reportValidity();
             this.isDT16DecimalValid = false;
         }
     }
 
     @track isDT19DecimalValid = false;
     checkDT19DecimalValidity(values, Ids){
         let decimalCheckRegex = /^(\d+(\.\d{0,2})?|\.?\d{1,2})$/;
         if(Boolean(values) && values.match(decimalCheckRegex)){
             Ids.setCustomValidity('');
             Ids.reportValidity();
             this.isDT19DecimalValid = false;
         }
         else if(Boolean(values)){
             Ids.setCustomValidity('Please enter valid decimal.');
             Ids.reportValidity();
             this.isDT19DecimalValid = true;
         }
         else{
             Ids.setCustomValidity('');
             Ids.reportValidity();
             this.isDT19DecimalValid = false;
         }
     }
 
     @track isOT19DecimalValid = false;
     checkOT19DecimalValidity(values, Ids){
         let decimalCheckRegex = /^(\d+(\.\d{0,2})?|\.?\d{1,2})$/;
         if(Boolean(values) && values.match(decimalCheckRegex)){
             Ids.setCustomValidity('');
             Ids.reportValidity();
             this.isOT19DecimalValid = false;
         }
         else if(Boolean(values)){
             Ids.setCustomValidity('Please enter valid decimal.');
             Ids.reportValidity();
             this.isOT19DecimalValid = true;
         }
         else{
             Ids.setCustomValidity('');
             Ids.reportValidity();
             this.isOT19DecimalValid = false;
         }
     }
 
     @track isDecimalValid = false;
     // Check validity for the decimal type fields
     checkDecimalValidity(values, Ids){
         let decimalCheckRegex = /^(\d+(\.\d{0,2})?|\.?\d{1,2})$/;
         if(Boolean(values) && values.match(decimalCheckRegex)){
             Ids.setCustomValidity('');
             Ids.reportValidity();
             this.isDecimalValid = false;
         }
         else if(Boolean(values)){
             Ids.setCustomValidity('Please enter valid decimal.');
             Ids.reportValidity();
             this.isDecimalValid = true;
         }
         else{
             Ids.setCustomValidity('');
             Ids.reportValidity();
             this.isDecimalValid = false;
         }
     }
 
     @track isClaimPeriodError = false;
     @track isEndDateReq = false;
     @track claimPeriodErrorMsg = '';
     // This method is used to check the claim period.
     checkClaimPeriod(startDate, endDate, startDateId, endDateId){
         if((startDate != null && startDate != '') && (endDate != null && endDate != '')){
             startDate = startDate.substring(0,4);
             endDate = endDate.substring(0,4);
             this.isEndDateReq = false;
             if(Number(startDate) != Number(endDate)){
                 startDateId.setCustomValidity(this.customLabelValues.OWC_claim_period_error_msg);
                 endDateId.setCustomValidity(this.customLabelValues.OWC_claim_period_error_msg);
                 this.isClaimPeriodError = true;
             }
             else{
                 startDateId.setCustomValidity('');
                 endDateId.setCustomValidity('');
                 this.isClaimPeriodError = false;
             }
             startDateId.reportValidity();
             endDateId.reportValidity();
         }
         else if((StartDate != null || StartDate != '') && (endDate == null || endDate == '')){
             endDateId.setCustomValidity(this.customLabelValues.OWC_claim_period_endDate_error_msg);
             this.isEndDateReq = true;
             this.isClaimPeriodError = false;
             endDateId.reportValidity();
         }
         else{
             endDateId.setCustomValidity('');
             endDateId.reportValidity();
             this.isEndDateReq = false;
             this.isClaimPeriodError = false;
         }
     }
 
     @track isCaseIssueOT13 = false;
     @track isCaseIssueOT13_1 = false;
     @track isCaseIssueOT13_2 = false;
     @track isCaseIssueOT13_3 = false;
     @track isCaseIssueOT10 = false;
     @track isCaseIssueDT10 = false;
     // Method to check the calendar year
     checkCalendarYearForOT10(startDate, endDate){
         startDate = startDate.substring(0,4);
         endDate = endDate.substring(0,4);
         if(Boolean(this.overtimeYearSelection)){
            if(Number(startDate) < 2019 && Number(endDate) < 2019){
                this.isCaseIssueOT13 = true;
                this.isCaseIssueOT13_1 = false;
                this.isCaseIssueOT13_2 = false;
                this.isCaseIssueOT13_3 = false;
                this.isCaseIssueOT10 = false;
                this.isCaseIssueDT10 = false;
            }
            else if(Number(startDate) == 2019 && Number(endDate) == 2019){
                this.isCaseIssueOT13 = false;
                this.isCaseIssueOT13_1 = true;
                this.isCaseIssueOT13_2 = false;
                this.isCaseIssueOT13_3 = false;
                this.isCaseIssueOT10 = false;
                this.isCaseIssueDT10 = false;
            }
            else if(Number(startDate) == 2020 && Number(endDate) == 2020){
                this.isCaseIssueOT13 = false;
                this.isCaseIssueOT13_1 = false;
                this.isCaseIssueOT13_2 = true;
                this.isCaseIssueOT13_3 = false;
                this.isCaseIssueOT10 = false;
                this.isCaseIssueDT10 = false;
            }
            else if(Number(startDate) == 2021 && Number(endDate) == 2021){
                this.isCaseIssueOT13 = false;
                this.isCaseIssueOT13_1 = false;
                this.isCaseIssueOT13_2 = false;
                this.isCaseIssueOT13_3 = true;
                this.isCaseIssueOT10 = false;
                this.isCaseIssueDT10 = false;
            }
            else if(Number(startDate) > 2021 && Number(endDate) > 2021){
                this.isCaseIssueOT13 = false;
                this.isCaseIssueOT13_1 = false;
                this.isCaseIssueOT13_2 = false;
                this.isCaseIssueOT13_3 = false;
                this.isCaseIssueOT10 = true;
                this.isCaseIssueDT10 = true;
            }
            this.generateCaseIssuesForOtOnly();
         }
     }
 
     checkCalendarYearForDT10(startDate, endDate){
         startDate = startDate.substring(0,4);
         endDate = endDate.substring(0,4);
         if(Boolean(this.overtimeYearSelection)){
            if(Number(startDate) < 2019 && Number(endDate) < 2019){
                this.isCaseIssueOT13 = true;
                this.isCaseIssueOT13_1 = false;
                this.isCaseIssueOT13_2 = false;
                this.isCaseIssueOT13_3 = false;
                this.isCaseIssueDT10 = false;
            }
            else if(Number(startDate) == 2019 && Number(endDate) == 2019){
                this.isCaseIssueOT13 = false;
                this.isCaseIssueOT13_1 = true;
                this.isCaseIssueOT13_2 = false;
                this.isCaseIssueOT13_3 = false;
                this.isCaseIssueDT10 = false;
            }
            else if(Number(startDate) == 2020 && Number(endDate) == 2020){
                this.isCaseIssueOT13 = false;
                this.isCaseIssueOT13_1 = false;
                this.isCaseIssueOT13_2 = true;
                this.isCaseIssueOT13_3 = false;
                this.isCaseIssueDT10 = false;
            }
            else if(Number(startDate) == 2021 && Number(endDate) == 2021){
                this.isCaseIssueOT13 = false;
                this.isCaseIssueOT13_1 = false;
                this.isCaseIssueOT13_2 = false;
                this.isCaseIssueOT13_3 = true;
                this.isCaseIssueDT10 = false;
            }
            else if(Number(startDate) > 2021 && Number(endDate) > 2021){
                this.isCaseIssueOT13 = false;
                this.isCaseIssueOT13_1 = false;
                this.isCaseIssueOT13_2 = false;
                this.isCaseIssueOT13_3 = false;
                this.isCaseIssueDT10 = true;
            }
            this.generateCaseIssuesForOtOnly();
         }
     }
 
     @track isCaseIssueOT22 = false;
     @track isCaseIssueOT22_1 = false;
     @track isCaseIssueOT22_2 = false;
     @track isCaseIssueOT22_3 = false;
     @track isCaseIssueOT19 = false;
     // Method to check the calendar year
     checkCalendarYear(startDate, endDate){
         startDate = startDate.substring(0,4);
         endDate = endDate.substring(0,4);
         if(Boolean(this.overtimeYearSelection)){
            if(Number(startDate) < 2019 && Number(endDate) < 2019){
                this.isCaseIssueOT22 = true;
                this.isCaseIssueOT22_1 = false;
                this.isCaseIssueOT22_2 = false;
                this.isCaseIssueOT22_3 = false;
                this.isCaseIssueOT19 = false;
            }
            else if(Number(startDate) == 2019 && Number(endDate) == 2019){
                this.isCaseIssueOT22 = false;
                this.isCaseIssueOT22_1 = true;
                this.isCaseIssueOT22_2 = false;
                this.isCaseIssueOT22_3 = false;
                this.isCaseIssueOT19 = false;
            }
            else if(Number(startDate) == 2020 && Number(endDate) == 2020){
                this.isCaseIssueOT22 = false;
                this.isCaseIssueOT22_1 = false;
                this.isCaseIssueOT22_2 = true;
                this.isCaseIssueOT22_3 = false;
                this.isCaseIssueOT19 = false;
            }
            else if(Number(startDate) == 2021 && Number(endDate) == 2021){
                this.isCaseIssueOT22 = false;
                this.isCaseIssueOT22_1 = false;
                this.isCaseIssueOT22_2 = false;
                this.isCaseIssueOT22_3 = true;
                this.isCaseIssueOT19 = false;
            }
            else if(Number(startDate) > 2021 && Number(endDate) > 2021){
                this.isCaseIssueOT22 = false;
                this.isCaseIssueOT22_1 = false;
                this.isCaseIssueOT22_2 = false;
                this.isCaseIssueOT22_3 = false;
                this.isCaseIssueOT19 = true;
            }
            this.generateCaseIssuesForOtOnly();
         }
     }
 
     async generateCaseIssuesForOtOnly(){
         if(this.isCaseIssueOT22 === true){
             try{
                 await this.getAllVilationTypeVariableForOT22('OT22');
             }catch (error){
                 console.log('error', error);
             }
         }
         else if(this.isCaseIssueOT22_1 === true){
             try{
                 await this.getAllVilationTypeVariableForOT22_1('22.1');
             }catch (error){
                 console.log('error', error);
             }
         }
         else if(this.isCaseIssueOT22_2 === true){
             try{
                 await this.getAllVilationTypeVariableForOT22_2('22.2');
             }catch (error){
                 console.log('error', error);
             }
         }
         else if(this.isCaseIssueOT22_3 === true){
             try{
                 await this.getAllVilationTypeVariableForOT22_3('22.3');
             }catch (error){
                 console.log('error', error);
             }
         }
         else if(this.isCaseIssueOT19 === true){
             try{
                 await this.getAllVilationTypeVariableForOT19('21');
             }catch (error){
                 console.log('error', error);
             }
         }
         else if(this.isCaseIssueOT13 === true){
             try{
                 await this.getAllVilationTypeVariableForOT13('OT13');
             }catch (error){
                 console.log('error', error);
             }
         }
         else if(this.isCaseIssueOT13_1 === true){
             try{
                 await this.getAllVilationTypeVariableForOT13_1('13.1');
             }catch (error){
                 console.log('error', error);
             }
         }
         else if(this.isCaseIssueOT13_2 === true){
             try{
                 await this.getAllVilationTypeVariableForOT13_2('13.2');
             }catch (error){
                 console.log('error', error);
             }
         }
         else if(this.isCaseIssueOT13_3 === true){
             try{
                 await this.getAllVilationTypeVariableForOT13_3('13.3');
             }catch (error){
                 console.log('error', error);
             }
         }
         else if(this.isCaseIssueOT10 === true){
             try{
                 await this.getAllVilationTypeVariableForOT10('212');
             }catch (error){
                 console.log('error', error);
             }
         }
         else if(this.isCaseIssueDT10 === true){
             try{
                 await this.getAllVilationTypeVariableForDT10('211');
             }catch (error){
                 console.log('error', error);
             }
         }
     }
 
     @api isOneHourly = false;
     @api violationTypeVariablesForOneHourly;
     @api isSalaryRatePOW = false;
     @api violationTypeVariablesForSalaryRate;
     @api isOneHourlyRec = false;
     @api violationTypeVariablesForOneHourlyRec;
     @api isSalaryRatePOWRec = false;
     @api violationTypeVariablesForSalaryRateRec;
     @api isOneHourlyRecs = false;
     @api violationTypeVariablesForOneHourlyRecs;
     @api isSalaryRatePOWRecs = false;
     @api userworkedhours;
     async handleServerCall(){
 
         if(this.isfarmlabour != null && this.isfarmlabour === true){
             if(this.isDoubleTimeClaim === true){
                 try{
                     await this.getAllVilationTypeVariableForOneHourly('21');
                 }catch (error){
                     console.log('error', error);
                 }
             }
             if(this.isBothOverTime === true){
                 try{
                     await this.getAllVilationTypeVariableForAdditional('212');
                 }catch (error){
                     console.log('error', error);
                 }
             }
             if(this.isDoubleTimeOnly === true){
                 try{
                     await this.getAllVilationTypeVariableForOneHourlyRecs('211');
                 }catch (error){
                     console.log('error', error);
                 }
             }
             this.violationTypeVariablesForDt15 = undefined;
             this.isDT15Issue = false;
             this.violationTypeVariablesForOt28 = undefined;
             this.isOT28Issue = false;
         }
         else if(this.is_domestic_worker != null && this.is_domestic_worker === true){
             if(this.isDoubleTimeClaim === true){
                 try{
                     await this.getAllVilationTypeVariableForOT28('OT28');
                 }catch (error){
                     console.log('error', error);
                 }
                 this.violationTypeVariablesForDt15 = undefined;
                 this.isDT15Issue = false;
             }
             else if(this.isBothOverTime === true || this.isDoubleTimeOnly === true){
                 try{
                     await this.getAllVilationTypeVariableForDT15('DT16');
                 }catch (error){
                     console.log('error', error);
                 }
                 this.violationTypeVariablesForOt28 = undefined;
                 this.isOT28Issue = false;
             }
             else{
                 this.violationTypeVariablesForDt15 = undefined;
                 this.isDT15Issue = false;
                 this.violationTypeVariablesForOt28 = undefined;
                 this.isOT28Issue = false;
             }
             this.resetOT13Variables(undefined, undefined,  undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                     this.resetDT10Variables(undefined, undefined,  undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                     this.resetOT22Variables(undefined, undefined, undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
         }
         else{
             if(this.isDoubleTimeClaim === true){
                 try{
                     await this.getAllVilationTypeVariableForOneHourly('21');
                 }catch (error){
                     console.log('error', error);
                 }
             }
             if(this.isBothOverTime === true){
                 try{
                     await this.getAllVilationTypeVariableForAdditional('212');
                 }catch (error){
                     console.log('error', error);
                 }
             }
             if(this.isDoubleTimeOnly === true){
                 try{
                     await this.getAllVilationTypeVariableForOneHourlyRecs('211');
                 }catch (error){
                     console.log('error', error);
                 }
             }
             this.violationTypeVariablesForDt15 = undefined;
             this.isDT15Issue = false;
             this.violationTypeVariablesForOt28 = undefined;
             this.isOT28Issue = false;
             this.resetOT13Variables(undefined, undefined,  undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                     this.resetDT10Variables(undefined, undefined,  undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
                     this.resetOT22Variables(undefined, undefined, undefined, undefined, undefined, false, false, false, false, false, false, false, false, false, false);
         }
     }
 
     @api isHelpText= false;
     @api helpText;
     // Help text 
     handleHelpText(event){
         const learnMoreName = event.target.name;
         if(learnMoreName === 'overtimeAdditinalBalanceHelpText'){
             this.isHelpText = true;
             this.helpText = this.customLabelValues.OWC_overtime_additinal_balance_helptext;
         }
         else if(learnMoreName === "overtimeRateBalanceOwed"){
             this.isHelpText = true;
             this.helpText = this.customLabelValues.OWC_overtime_balance_helptext;
         }
         else if(learnMoreName === 'overtimeDoubleRateBalanceOwed'){
             this.isHelpText = true;
             this.helpText = this.customLabelValues.OWC_overtime_dt_balance_helptext;
         }
     }
     handleHelpTextEvent(event){
         const helpTextValue = event.detail;
         this.isHelpText = helpTextValue.isClosedHelpText
     }
 
     @track violationTypeVariablesForDt15
     @track isDT15Issue = false;
     getAllVilationTypeVariableForDT15(queryCode){
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
                     result[i].name === 'VTV1688' ? '' : result[i].value = '';
                     result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
                 }
                 // Check the datatype of the input fields
 
                  if(this.violationTypeVariablesForDt15 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForDt15 = result;
                     this.violationTypeVariablesForDt15.length > 0 ? this.isDT15Issue = true : this.isDT15Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @track violationTypeVariablesForOt28
     @track isOT28Issue = false;
     getAllVilationTypeVariableForOT28(queryCode){
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
                     result[i].name === 'VTV1503' ? '' : result[i].value = '';
                     result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
                 }
                  if(this.violationTypeVariablesForOt28 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt28 = result;
                     this.violationTypeVariablesForOt28.length > 0 ? this.isOT28Issue = true : this.isOT28Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @track violationTypeVariablesForOt13
     @track isOT13Issue = false;
     getAllVilationTypeVariableForOT13(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     (result[i].name === 'VTV1611' || result[i].name === 'VTV1612') ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForOt13 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt13 = result;
                     this.violationTypeVariablesForOt13.length > 0 ? this.isOT13Issue = true : this.isOT13Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @track violationTypeVariablesForOt13_1
     @track isOT13_1Issue = false;
     getAllVilationTypeVariableForOT13_1(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     (result[i].name === 'VTV4343' || result[i].name === 'VTV4344') ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForOt13_1 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt13_1 = result;
                     this.violationTypeVariablesForOt13_1.length > 0 ? this.isOT13_1Issue = true : this.isOT13_1Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @track violationTypeVariablesForOt13_2
     @track isOT13_2Issue = false;
     getAllVilationTypeVariableForOT13_2(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     (result[i].name === 'VTV4382' || result[i].name === 'VTV4383') ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForOt13_2 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt13_2 = result;
                     this.violationTypeVariablesForOt13_2.length > 0 ? this.isOT13_2Issue = true : this.isOT13_2Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @track violationTypeVariablesForOt13_3
     @track isOT13_3Issue = false;
     getAllVilationTypeVariableForOT13_3(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     (result[i].name === 'VTV4421' || result[i].name === 'VTV4422') ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForOt13_3 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt13_3 = result;
                     this.violationTypeVariablesForOt13_3.length > 0 ? this.isOT13_3Issue = true : this.isOT13_3Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @track violationTypeVariablesForOt10
     @track isOT10Issue = false;
     getAllVilationTypeVariableForOT10(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     (result[i].name === 'VTV1034' || result[i].name === 'VTV1035') ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForOt10 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt10 = result;
                     this.violationTypeVariablesForOt10.length > 0 ? this.isOT10Issue = true : this.isOT10Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @track violationTypeVariablesForDt10
     @track isDT10Issue = false;
     getAllVilationTypeVariableForDT10(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     result[i].name === 'VTV0056' ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForDt10 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForDt10 = result;
                     this.violationTypeVariablesForDt10.length > 0 ? this.isDT10Issue = true : this.isDT10Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
 
     @api violationTypeVariablesForOt22;
     @api isOT22Issue = false;
     getAllVilationTypeVariableForOT22(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     //result[i].value === '{!input}' ? result[i].value = '' : result[i].value;
                     result[i].name === 'VTV0050' ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForOt22 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt22 = result;
                     this.violationTypeVariablesForOt22.length > 0 ? this.isOT22Issue = true : this.isOT22Issue = false;
                  }
                  console.log('violationTypeVariablesForOt22 :::::::>>>> ', JSON.stringify(this.violationTypeVariablesForOt22));
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @api violationTypeVariablesForOt22_1;
     @api isOT22_1Issue = false;
     getAllVilationTypeVariableForOT22_1(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     result[i].name === 'VTV4316' ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForOt22_1 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt22_1 = result;
                     this.violationTypeVariablesForOt22_1.length > 0 ? this.isOT22_1Issue = true : this.isOT22_1Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @api violationTypeVariablesForOt22_2;
     @api isOT22_2Issue = false;
     getAllVilationTypeVariableForOT22_2(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     result[i].name === 'VTV4355' ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForOt22_2 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt22_2 = result;
                     this.violationTypeVariablesForOt22_2.length > 0 ? this.isOT22_2Issue = true : this.isOT22_2Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @api violationTypeVariablesForOt22_3;
     @api isOT22_3Issue = false;
     getAllVilationTypeVariableForOT22_3(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     result[i].name === 'VTV4394' ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForOt22_3 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt22_3 = result;
                     this.violationTypeVariablesForOt22_3.length > 0 ? this.isOT22_3Issue = true : this.isOT22_3Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @api violationTypeVariablesForOt19;
     @api isOT19Issue = false;
     getAllVilationTypeVariableForOT19(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 for(var i=0; i<result.length; i++){
                     result[i].name === 'VTV1462' ? result[i].value = result[i].value : result[i].value = '';
                 }
                  if(this.violationTypeVariablesForOt19 !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOt19 = result;
                     this.violationTypeVariablesForOt19.length > 0 ? this.isOT19Issue = true : this.isOT19Issue = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     @api violationTypeVariablesForAdditional;
     @api isAdditonalCheck = false;
     getAllVilationTypeVariableForAdditional(queryCode){
         getViolationTypeVariables({
             queryCode : queryCode
         })
         .then(result => {
             if(result){
                 // Remove OT startDate and EndDate variables
                 
 
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
                     if((result[i].name === 'VTV1027') || (result[i].name === 'VTV1028') || (result[i].name === 'VTV1034') || (result[i].name === 'VTV1035')){
                         result[i].isHide = true;
                     }
                     else{
                         result[i].isHide = false;
                         (result[i].name === 'VTV1034') || (result[i].name === 'VTV1035') ? result[i].value = result[i].value : result[i].value = '';
                     }
                     result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
                     // result[i].name === 'VTV1027' || result[i].name === 'VTV1028' ? result[i].isHide = true : result[i].isHide = false;
                     
                 }
                 // Check the datatype of the input fields
 
                  console.log('wage def result ::: ', JSON.stringify(result));
                  if(this.violationTypeVariablesForAdditional !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForAdditional = result;
                     this.violationTypeVariablesForAdditional.length > 0 ? this.isAdditonalCheck = true : this.isAdditonalCheck = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     getAllVilationTypeVariableForOneHourlyRecs(queryCode){
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
                     if((result[i].name === 'VTV0056')){
                         result[i].isHide = true;
                     }
                     else{
                         result[i].isHide = false;
                         result[i].name === 'VTV0056' ? result[i].value = result[i].value : result[i].value = '';
                     }
                     result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
                 }
                 // Check the datatype of the input fields
 
                  console.log('wage def newArray ::: ', JSON.stringify(result));
                  if(this.violationTypeVariablesForOneHourlyRecs !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOneHourlyRecs = result;
                     this.violationTypeVariablesForOneHourlyRecs.length > 0 ? this.isOneHourlyRecs = true : this.isOneHourlyRecs = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     getAllVilationTypeVariableForOneHourly(queryCode){
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
                     result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
                     result[i].name === 'VTV1462' ? result[i].isHide = true : result[i].isHide = false
                     result[i].value === '{!input}' ? result[i].value = '' : result[i].value;
                     // result[i].name === 'VTV1462' ? result[i].isOutputText = true : result[i].isOutputText = false
                 }
                 // Check the datatype of the input fields
 
                  console.log('wage def result ::: ', JSON.stringify(result));
                  if(this.violationTypeVariablesForOneHourly !== undefined){
 
                  }
                  else{
                     this.violationTypeVariablesForOneHourly = result;
                     this.violationTypeVariablesForOneHourly.length > 0 ? this.isOneHourly = true : this.isOneHourly = false;
                  }
             }
         })
         .catch(error => {
             console.log('Error: ', error);
         })
     }
 
     handleWageDefValidityEvent(){
         const selectEvent = new CustomEvent('overtimedefchildvalidityevent', {
             detail: {
                 currentStep : true
             }
         });
         this.dispatchEvent(selectEvent);
     }
 
     @api
     handlePOWDetails(POWDetails, isFormPreviewMode){
         console.log('Payment detail in child ::: ', JSON.stringify(POWDetails));
         this.POWDetails = POWDetails;
         this.isFormPreviewMode = isFormPreviewMode;
     }
 
     isNameValid = false
     // This method is used to collect the parent component data.
     @api
     handleOverTimeParentData(){
        // Add focus on error fields
         let endDateId = this.template.querySelector('[data-id="VTV1451"]');
         let ot19EndDateId = this.template.querySelector('[data-id="VTV1031"]');
         let dt10endDateId = this.template.querySelector('[data-id="VTV0053"]');
         let dtHoursId = this.template.querySelector('[data-id="VTV1032"]');
         let otHoursId = this.template.querySelector('[data-id="VTV1029"]');
         let ot19HoursId = this.template.querySelector('[data-id="VTV1452"]');
         let dt19HoursId = this.template.querySelector('[data-id="VTV0054"]');
         let dt16HoursId = this.template.querySelector('[data-id="VTV1635"]');
         let ot28HoursId = this.template.querySelector('[data-id="VTV1501"]');
 
         // Add focus on endDate field if endDate is null.
         this.isEndDateReq === true && Boolean(endDateId) && Boolean(!endDateId.value) ? endDateId.focus() : ''
         this.isEndDateReq === true && Boolean(ot19EndDateId) && Boolean(!ot19EndDateId.value) ? ot19EndDateId.focus() : ''
         this.isEndDateReq === true && Boolean(dt10endDateId) && Boolean(!dt10endDateId.value) ? dt10endDateId.focus() : ''
 
         // Add focus on endDate field if claim period year is not same.
         this.isClaimPeriodError === true && Boolean(endDateId) && Boolean(endDateId.value) ? endDateId.focus() : ''
         this.isClaimPeriodError === true && Boolean(ot19EndDateId) && Boolean(ot19EndDateId.value) ? ot19EndDateId.focus() : ''
         this.isClaimPeriodError === true && Boolean(dt10endDateId) && Boolean(dt10endDateId.value) ? dt10endDateId.focus() : ''
 
         // Check validity for the OT10 decimal fields
         Boolean(this.noOfDtTimeHours) ? this.checkDecimalValidity(this.noOfDtTimeHours, dtHoursId) : '';
         Boolean(this.noOfOtTimeHours) ? this.checkDecimalValidity(this.noOfOtTimeHours, otHoursId) : '';
 
         // Add focus for the OT10 decimal fields
         this.isDecimalValid === true && Boolean(this.noOfOtTimeHours) ? otHoursId.focus() : '';
         this.isDecimalValid === true && Boolean(this.noOfDtTimeHours) ? dtHoursId.focus() : '';
 
         // Check validity for the OT19 decimal fields
         Boolean(this.noOfOt19TimeHours) ? this.checkOT19DecimalValidity(this.noOfOt19TimeHours, ot19HoursId) : '';
         this.isOT19DecimalValid === true && Boolean(this.noOfOt19TimeHours) ? ot19HoursId.focus() : '';
 
         // Check validity for DT19 decimal fields
         Boolean(this.noOfDt19TimeHours) ? this.checkDT19DecimalValidity(this.noOfDt19TimeHours, dt19HoursId) : '';
         this.isDT19DecimalValid === true && Boolean(this.noOfDt19TimeHours) ? dt19HoursId.focus() : '';
 
         // Check validity for DT16 decimal fields
         Boolean(this.dt16TimeHours) ? this.checkDT16DecimalValidity(this.dt16TimeHours, dt16HoursId) : '';
         this.isDT16DecimalValid === true && Boolean(this.dt16TimeHours) ? dt16HoursId.focus() : '';
 
         // Check validity for OT28 decimal fields
         Boolean(this.noOfOT28HoursTime) ? this.checkOT28DecimalValidity(this.noOfOT28HoursTime, ot28HoursId) : '';
         this.isOT28DecimalValid === true && Boolean(this.noOfOT28HoursTime) ? ot28HoursId.focus() : '';
 
         this.isOT28DecimalValid === true || this.isDT16DecimalValid === true || this.isDT19DecimalValid === true || this.isOT19DecimalValid === true || this.isDecimalValid === true || this.isEndDateReq === true || this.isClaimPeriodError === true ? this.handleWageDefValidityEvent() : this.handleOverTimeParentInfo();
     }
 
     @api
     handleOverTimeParentInfo(){
         (this.isfarmlabour != null && this.isfarmlabour === true && this.violationTypeVariablesForOneHourly != null) ? this.assignOT22CaseIssueValues() : '';
         (this.isfarmlabour != null && this.isfarmlabour === true && this.violationTypeVariablesForAdditional != null) ? this.assignOT13CaseIssueValues() : '';
         (this.isfarmlabour != null && this.isfarmlabour === true && this.violationTypeVariablesForOneHourlyRecs != null) ? this.assignDT10CaseIssueValues() : '';
         (Boolean(this.isfarmlabour) && this.isfarmlabour === false && this.violationTypeVariablesForOneHourly != null) || Boolean(!this.isfarmlabour) ? this.assignVtvVariablesForOneHourly() : this.violationTypeVariablesForOT10OneHourly = undefined;
         (Boolean(this.isfarmlabour) && this.isfarmlabour === false && this.violationTypeVariablesForAdditional != null) || Boolean(!this.isfarmlabour) ? this.assignVtvVariablesForAdditional() : this.violationTypeVariablesForAdditionalDT10 = undefined;
         (Boolean(this.isfarmlabour) && this.isfarmlabour === false && this.violationTypeVariablesForOneHourlyRecs != null) || Boolean(!this.isfarmlabour) ? this.assignVtvVariablesForOneHourlyRecs() : this.violationTypeVariablesForOneHourlyDt10 = undefined;
         const selectEvent = new CustomEvent('overtimecustominfoevent', {
             detail: {
                 overTimeInfoObj : this.overTimeInfoObj() ,
                 vtCaseIssueObj : this.vtCaseIssueObj()
             }
         });
         this.dispatchEvent(selectEvent);
     }
 
     @track violationTypeVariablesForOT10OneHourly;
     assignVtvVariablesForOneHourly(){
         if(Boolean(this.violationTypeVariablesForOneHourly)){
             this.violationTypeVariablesForOT10OneHourly = this.violationTypeVariablesForOneHourly;
         }
         else{
             this.violationTypeVariablesForOT10OneHourly = undefined;
         }
     }
 
     @track violationTypeVariablesForAdditionalDT10;
     assignVtvVariablesForAdditional(){
         if(Boolean(this.violationTypeVariablesForAdditional)){
             this.violationTypeVariablesForAdditionalDT10 = this.violationTypeVariablesForAdditional;
         }
         else{
             this.violationTypeVariablesForAdditionalDT10 = undefined;
         }
     }
 
     @track violationTypeVariablesForOneHourlyDt10
     assignVtvVariablesForOneHourlyRecs(){
         if(Boolean(this.violationTypeVariablesForOneHourlyRecs)){
             this.violationTypeVariablesForOneHourlyDt10 = this.violationTypeVariablesForOneHourlyRecs;
         }
         else{
             this.violationTypeVariablesForOneHourlyDt10 = undefined;
         }
     }
 
     assignDT10CaseIssueValues(){
         if(this.isCaseIssueOT13 === true && this.violationTypeVariablesForOt13 != null && this.isOT13Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt13.length; i++){
                 this.violationTypeVariablesForOt13[i].name === 'VTV1607' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0052' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1608' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0053' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1604' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0052' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1605' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0053' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1603' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0055' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1613' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0126' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1609' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0054' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
             }
             this.resetDT10Variables(undefined, this.violationTypeVariablesForOt13, undefined, undefined, undefined, false, true, false, false, false, false, true, false, false, false);
         }
         else if(this.isCaseIssueOT13_1 === true && this.violationTypeVariablesForOt13_1 != null && this.isOT13_1Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt13_1.length; i++){
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4340' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0052' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4341' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0053' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4337' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0052' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4338' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0053' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4336' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0055' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4345' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0126' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4342' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0054' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
             }
             this.resetDT10Variables(undefined, undefined, this.violationTypeVariablesForOt13_1, undefined, undefined, false, false, true, false, false, false, false, true, false, false);
         }
         else if(this.isCaseIssueOT13_2 === true && this.violationTypeVariablesForOt13_2 != null && this.isOT13_2Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt13_2.length; i++){
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4379' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0052' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4380' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0053' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4376' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0052' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4377' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0053' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4375' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0055' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4384' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0126' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4381' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0054' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
             }
             this.resetDT10Variables(undefined, undefined, undefined, this.violationTypeVariablesForOt13_2, undefined, false, false, false, true, false, false, false, false, true, false);
         }
         else if(this.isCaseIssueOT13_3 === true && this.violationTypeVariablesForOt13_3 != null && this.isOT13_3Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt13_3.length; i++){
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4418' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0052' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4419' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0053' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4415' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0052' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4416' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0053' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4414' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0055' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4423' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0126' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4420' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0054' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
             }
             this.resetDT10Variables(undefined, undefined, undefined, undefined, this.violationTypeVariablesForOt13_3, false, false, false, false, true, false, false, false, false, true);
         }
         else if(this.isCaseIssueDT10 === true && this.violationTypeVariablesForDt10 != null && this.isDT10Issue === true){
             for(var i=0; i<this.violationTypeVariablesForDt10.length; i++){
                 this.violationTypeVariablesForDt10[i].name === 'VTV0052' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0052' ? this.violationTypeVariablesForDt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForDt10[i].name === 'VTV0053' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0053' ? this.violationTypeVariablesForDt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForDt10[i].name === 'VTV0055' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0055' ? this.violationTypeVariablesForDt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForDt10[i].name === 'VTV0126' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0126' ? this.violationTypeVariablesForDt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForDt10[i].name === 'VTV0054' ? this.violationTypeVariablesForOneHourlyRecs.filter( item => item.name === 'VTV0054' ? this.violationTypeVariablesForDt10[i].value = item.value : '') : '';
             }
             this.resetDT10Variables(this.violationTypeVariablesForDt10, undefined,  undefined, undefined, undefined, true, false, false, false, false, true, false, false, false, false);
         }
     }
 
     assignOT13CaseIssueValues(){
         if(this.isCaseIssueOT13 === true && this.violationTypeVariablesForOt13 != null && this.isOT13Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt13.length; i++){
                 this.violationTypeVariablesForOt13[i].name === 'VTV1607' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1030' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1608' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1031' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1604' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1030' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1605' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1031' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1603' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1026' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1606' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1029' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1609' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1032' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13[i].name === 'VTV1613' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1033' ? this.violationTypeVariablesForOt13[i].value = item.value : '') : '';
             }
             this.resetOT13Variables(undefined, this.violationTypeVariablesForOt13, undefined, undefined, undefined, false, true, false, false, false, false, true, false, false, false);
         }
         else if(this.isCaseIssueOT13_1 === true && this.violationTypeVariablesForOt13_1 != null && this.isOT13_1Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt13_1.length; i++){
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4340' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1030' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4341' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1031' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4337' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1030' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4338' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1031' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4336' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1026' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4339' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1029' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4342' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1032' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_1[i].name === 'VTV4345' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1033' ? this.violationTypeVariablesForOt13_1[i].value = item.value : '') : '';
             }
             this.resetOT13Variables(undefined, undefined, this.violationTypeVariablesForOt13_1, undefined, undefined, false, false, true, false, false, false, false, true, false, false);
         }
         else if(this.isCaseIssueOT13_2 === true && this.violationTypeVariablesForOt13_2 != null && this.isOT13_2Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt13_2.length; i++){
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4379' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1030' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4380' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1031' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4376' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1030' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4377' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1031' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4375' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1026' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4378' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1029' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4381' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1032' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_2[i].name === 'VTV4384' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1033' ? this.violationTypeVariablesForOt13_2[i].value = item.value : '') : '';
             }
             this.resetOT13Variables(undefined, undefined, undefined, this.violationTypeVariablesForOt13_2, undefined, false, false, false, true, false, false, false, false, true, false);
         }
         else if(this.isCaseIssueOT13_3 === true && this.violationTypeVariablesForOt13_3 != null && this.isOT13_3Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt13_3.length; i++){
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4418' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1030' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4419' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1031' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4415' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1030' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4416' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1031' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4414' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1026' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4417' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1029' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4420' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1032' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt13_3[i].name === 'VTV4423' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1033' ? this.violationTypeVariablesForOt13_3[i].value = item.value : '') : '';
             }
             this.resetOT13Variables(undefined, undefined, undefined, undefined, this.violationTypeVariablesForOt13_3, false, false, false, false, true, false, false, false, false, true);
         }
         else if(this.isCaseIssueOT10 === true && this.violationTypeVariablesForOt10 != null && this.isOT10Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt10.length; i++){
                 this.violationTypeVariablesForOt10[i].name === 'VTV1030' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1030' ? this.violationTypeVariablesForOt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt10[i].name === 'VTV1031' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1031' ? this.violationTypeVariablesForOt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt10[i].name === 'VTV1027' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1030' ? this.violationTypeVariablesForOt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt10[i].name === 'VTV1028' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1031' ? this.violationTypeVariablesForOt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt10[i].name === 'VTV1026' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1026' ? this.violationTypeVariablesForOt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt10[i].name === 'VTV1029' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1029' ? this.violationTypeVariablesForOt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt10[i].name === 'VTV1032' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1032' ? this.violationTypeVariablesForOt10[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt10[i].name === 'VTV1033' ? this.violationTypeVariablesForAdditional.filter( item => item.name === 'VTV1033' ? this.violationTypeVariablesForOt10[i].value = item.value : '') : '';
             }
             this.resetOT13Variables(this.violationTypeVariablesForOt10, undefined,  undefined, undefined, undefined, true, false, false, false, false, true, false, false, false, false);
         }
     }
 
     assignOT22CaseIssueValues(){
         if(this.isCaseIssueOT22 === true && this.violationTypeVariablesForOt22 != null && this.isOT22Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt22.length; i++){
                 this.violationTypeVariablesForOt22[i].name === 'VTV0044' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1450' ? this.violationTypeVariablesForOt22[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22[i].name === 'VTV0045' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1451' ? this.violationTypeVariablesForOt22[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22[i].name === 'VTV0047' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1449' ? this.violationTypeVariablesForOt22[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22[i].name === 'VTV0046' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1452' ? this.violationTypeVariablesForOt22[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22[i].name === 'VTV0050' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1462' ? this.violationTypeVariablesForOt22[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22[i].name === 'VTV0048' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1453' ? this.violationTypeVariablesForOt22[i].value = item.value : '') : '';
             }
             this.resetOT22Variables(undefined, this.violationTypeVariablesForOt22, undefined, undefined, undefined, false, true, false, false, false, false, true, false, false, false);
         }
         else if(this.isCaseIssueOT22_1 === true && this.violationTypeVariablesForOt22_1 != null && this.isOT22_1Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt22_1.length; i++){
                 this.violationTypeVariablesForOt22_1[i].name === 'VTV4311' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1450' ? this.violationTypeVariablesForOt22_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_1[i].name === 'VTV4312' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1451' ? this.violationTypeVariablesForOt22_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_1[i].name === 'VTV4314' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1449' ? this.violationTypeVariablesForOt22_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_1[i].name === 'VTV4313' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1452' ? this.violationTypeVariablesForOt22_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_1[i].name === 'VTV4316' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1462' ? this.violationTypeVariablesForOt22_1[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_1[i].name === 'VTV4315' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1453' ? this.violationTypeVariablesForOt22_1[i].value = item.value : '') : '';
             }
             this.resetOT22Variables(undefined, undefined, this.violationTypeVariablesForOt22_1, undefined, undefined, false, false, true, false, false, false, false, true, false, false);
         }
         else if(this.isCaseIssueOT22_2 === true && this.violationTypeVariablesForOt22_2 != null && this.isOT22_2Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt22_2.length; i++){
                 this.violationTypeVariablesForOt22_2[i].name === 'VTV4350' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1450' ? this.violationTypeVariablesForOt22_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_2[i].name === 'VTV4351' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1451' ? this.violationTypeVariablesForOt22_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_2[i].name === 'VTV4353' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1449' ? this.violationTypeVariablesForOt22_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_2[i].name === 'VTV4352' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1452' ? this.violationTypeVariablesForOt22_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_2[i].name === 'VTV4355' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1462' ? this.violationTypeVariablesForOt22_2[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_2[i].name === 'VTV4354' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1453' ? this.violationTypeVariablesForOt22_2[i].value = item.value : '') : '';
             }
             this.resetOT22Variables(undefined, undefined, undefined, this.violationTypeVariablesForOt22_2, undefined, false, false, false, true, false, false, false, false, true, false);
         }
         else if(this.isCaseIssueOT22_3 === true && this.violationTypeVariablesForOt22_3 != null && this.isOT22_3Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt22_3.length; i++){
                 this.violationTypeVariablesForOt22_3[i].name === 'VTV4389' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1450' ? this.violationTypeVariablesForOt22_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_3[i].name === 'VTV4390' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1451' ? this.violationTypeVariablesForOt22_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_3[i].name === 'VTV4392' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1449' ? this.violationTypeVariablesForOt22_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_3[i].name === 'VTV4391' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1452' ? this.violationTypeVariablesForOt22_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_3[i].name === 'VTV4394' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1462' ? this.violationTypeVariablesForOt22_3[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt22_3[i].name === 'VTV4393' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1453' ? this.violationTypeVariablesForOt22_3[i].value = item.value : '') : '';
             }
             this.resetOT22Variables(undefined, undefined, undefined, undefined, this.violationTypeVariablesForOt22_3, false, false, false, false, true, false, false, false, false, true);
             
         }
         else if(this.isCaseIssueOT19 === true && this.violationTypeVariablesForOt19 != null && this.isOT19Issue === true){
             for(var i=0; i<this.violationTypeVariablesForOt19.length; i++){
                 this.violationTypeVariablesForOt19[i].name === 'VTV1450' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1450' ? this.violationTypeVariablesForOt19[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt19[i].name === 'VTV1451' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1451' ? this.violationTypeVariablesForOt19[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt19[i].name === 'VTV1449' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1449' ? this.violationTypeVariablesForOt19[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt19[i].name === 'VTV1452' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1452' ? this.violationTypeVariablesForOt19[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt19[i].name === 'VTV1462' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1462' ? this.violationTypeVariablesForOt19[i].value = item.value : '') : '';
                 this.violationTypeVariablesForOt19[i].name === 'VTV1453' ? this.violationTypeVariablesForOneHourly.filter( item => item.name === 'VTV1453' ? this.violationTypeVariablesForOt19[i].value = item.value : '') : '';
             }
             this.resetOT22Variables(this.violationTypeVariablesForOt19, undefined, undefined, undefined, undefined, true, false, false, false, false, true, false, false, false, false);
         }
     }
 
     @api
     vtCaseIssueObj(){
         return{
             sectionId : this.sectionid,
             violationTypeVariablesForOneHourly : this.violationTypeVariablesForOT10OneHourly,
             violationTypeVariablesForOneHourlyRecs : this.violationTypeVariablesForOneHourlyDt10,
             violationTypeVariablesForAdditional : this.violationTypeVariablesForAdditionalDT10,
             violationTypeVariablesForOt22 : this.violationTypeVariablesForOt22,
             violationTypeVariablesForOt22_1 : this.violationTypeVariablesForOt22_1,
             violationTypeVariablesForOt22_2 : this.violationTypeVariablesForOt22_2,
             violationTypeVariablesForOt22_3 : this.violationTypeVariablesForOt22_3,
             violationTypeVariablesForOt19 : this.violationTypeVariablesForOt19,
             violationTypeVariablesForOt10 : this.violationTypeVariablesForOt10,
             violationTypeVariablesForOt13 : this.violationTypeVariablesForOt13,
             violationTypeVariablesForOt13_1 : this.violationTypeVariablesForOt13_1,
             violationTypeVariablesForOt13_2 : this.violationTypeVariablesForOt13_2,
             violationTypeVariablesForOt13_3 : this.violationTypeVariablesForOt13_3,
             violationTypeVariablesForDt10 : this.violationTypeVariablesForDt10,
             violationTypeVariablesForDt15 : this.violationTypeVariablesForDt15,
             violationTypeVariablesForOt28 : this.violationTypeVariablesForOt28
         }
     }
 
     @api
     overTimeInfoObj(){
         return {
             sectionId : this.sectionid,
             isOT28Issue : this.isOT28Issue,
             isDT15Issue : this.isDT15Issue,
             violationTypeVariablesForOt28 : this.violationTypeVariablesForOt28,
             violationTypeVariablesForDt15 : this.violationTypeVariablesForDt15,
             doubleTimeOwedValue : this.doubleTimeOwedValue,
             claimDoubleTimeOnly : this.claimDoubleTimeOnly,
             isDoubleTimeClaim : this.isDoubleTimeClaim,
             isOneHourly : this.isOneHourly,
             violationTypeVariablesForOneHourly : this.violationTypeVariablesForOneHourly,
             isSalaryRatePOW : this.isSalaryRatePOW,
             isOneHourlyRec : this.isOneHourlyRec,
             isSalaryRatePOWRec : this.isSalaryRatePOWRec,
             isOneHourlyRecs : this.isOneHourlyRecs,
             violationTypeVariablesForOneHourlyRecs : this.violationTypeVariablesForOneHourlyRecs,
             isSalaryRatePOWRecs : this.isSalaryRatePOWRecs,
             violationTypeVariablesForAdditional : this.violationTypeVariablesForAdditional,
             isAdditonalCheck : this.isAdditonalCheck,
             owedDoubleTime : this.owedDoubleTime,
             overtimeBalanceOwed : this.overtimeBalanceOwed,
             overtimeAdditinalBalance : this.overtimeAdditinalBalance,
             otStartDate : this.otStartDate,
             otEndDate : this.otEndDate,
             ot19StartDate : this.ot19StartDate,
             ot19EndDate : this.ot19EndDate,
             ot10EndDate : this.ot10EndDate,
             ot10StartDate : this.ot10StartDate,
             isCaseIssueOT10 : this.isCaseIssueOT10,
             isCaseIssueOT13 : this.isCaseIssueOT13,
             isCaseIssueOT13_1 : this.isCaseIssueOT13_1,
             isCaseIssueOT13_2 : this.isCaseIssueOT13_2,
             isCaseIssueOT13_3 : this.isCaseIssueOT13_3,
             dt10EndDate : this.dt10EndDate,
             dt10StartDate : this.dt10StartDate,
             isCaseIssueDT10 : this.isCaseIssueDT10,
             doubleTimeOwedValueOT28 : this.doubleTimeOwedValueOT28,
             violationTypeVariablesForDt10 : this.violationTypeVariablesForDt10,
             violationTypeVariablesForOt10 : this.violationTypeVariablesForOt10,
             violationTypeVariablesForOt13 : this.violationTypeVariablesForOt13,
             violationTypeVariablesForOt13_1 : this.violationTypeVariablesForOt13_1,
             violationTypeVariablesForOt13_2 : this.violationTypeVariablesForOt13_2,
             violationTypeVariablesForOt13_3 : this.violationTypeVariablesForOt13_3,
             isCaseIssueOT22 : this.isCaseIssueOT22,
             isCaseIssueOT22_1 : this.isCaseIssueOT22_1,
             isCaseIssueOT22_2 : this.isCaseIssueOT22_2,
             isCaseIssueOT22_3 : this.isCaseIssueOT22_3,
             isCaseIssueOT19 : this.isCaseIssueOT19,
             violationTypeVariablesForOt22 : this.violationTypeVariablesForOt22,
             violationTypeVariablesForOt22_1 : this.violationTypeVariablesForOt22_1,
             violationTypeVariablesForOt22_2 : this.violationTypeVariablesForOt22_2,
             violationTypeVariablesForOt22_3 : this.violationTypeVariablesForOt22_3,
             violationTypeVariablesForOt19 : this.violationTypeVariablesForOt19,
             ot28EndDate : this.ot28EndDate,
             ot28StartDate : this.ot28StartDate,
             dt15EndDate : this.dt15EndDate,
             dt15StartDate : this.dt15StartDate,
             violationTypeVariablesForOt28 : this.violationTypeVariablesForOt28,
             violationTypeVariablesForDt15 : this.violationTypeVariablesForDt15,
             isfarmlabour : this.isfarmlabour,
             is_domestic_worker : this.is_domestic_worker,
             doubleTimeOwedValueDT16 : this.doubleTimeOwedValueDT16,
             overtimeYearSelection : this.overtimeYearSelection
         }
     }
 
     @api
     handleOverTimeChildData(strString, isFormPreviewMode){
         console.log('strString in overtime sub child ::: ', JSON.stringify(strString));
         this.claimDoubleTimeOnly = strString.claimDoubleTimeOnly
         this.isDoubleTimeClaim = strString.isDoubleTimeClaim
         this.isOneHourly = strString.isOneHourly;
         this.overtimeBalanceOwed = strString.overtimeBalanceOwed
         this.doubleTimeOwedValue = strString.doubleTimeOwedValue
         this.violationTypeVariablesForOneHourly = strString.violationTypeVariablesForOneHourly,
         this.isSalaryRatePOW = strString.isSalaryRatePOW,
         this.isOneHourlyRec = strString.isOneHourlyRec,
         this.isSalaryRatePOWRec = strString.isSalaryRatePOWRec,
         this.isOneHourlyRecs = strString.isOneHourlyRecs,
         this.violationTypeVariablesForOneHourlyRecs = strString.violationTypeVariablesForOneHourlyRecs,
         this.isSalaryRatePOWRecs = strString.isSalaryRatePOWRecs,
         this.violationTypeVariablesForAdditional = strString.violationTypeVariablesForAdditional
         this.isAdditonalCheck = strString.isAdditonalCheck
         this.owedDoubleTime = strString.owedDoubleTime
         this.overtimeAdditinalBalance = strString.overtimeAdditinalBalance
         this.otStartDate = strString.otStartDate,
         this.otEndDate = strString.otEndDate,
         this.ot19EndDate = strString.ot19EndDate
         this.ot19StartDate = strString.ot19StartDate
         this.isCaseIssueOT22 = strString.isCaseIssueOT22,
         this.isCaseIssueOT22_1 = strString.isCaseIssueOT22_1,
         this.isCaseIssueOT22_2 = strString.isCaseIssueOT22_2,
         this.isCaseIssueOT22_3 = strString.isCaseIssueOT22_3,
         this.isCaseIssueOT19 = strString.isCaseIssueOT19,
         this.violationTypeVariablesForOt22 = strString.violationTypeVariablesForOt22,
         this.violationTypeVariablesForOt22_1 = strString.violationTypeVariablesForOt22_1,
         this.violationTypeVariablesForOt22_2 = strString.violationTypeVariablesForOt22_2,
         this.violationTypeVariablesForOt22_3 = strString.violationTypeVariablesForOt22_3,
         this.violationTypeVariablesForOt19 = strString.violationTypeVariablesForOt19
         this.ot10EndDate = strString.ot10EndDate,
         this.ot10StartDate = strString.ot10StartDate,
         this.dt10EndDate = strString.dt10EndDate,
         this.dt10StartDate = strString.dt10StartDate,
         this.doubleTimeOwedValueDT16 = strString.doubleTimeOwedValueDT16
         this.isCaseIssueDT10 = strString.isCaseIssueDT10,
         this.violationTypeVariablesForDt10 = strString.violationTypeVariablesForDt10,
         this.isCaseIssueOT10 = strString.isCaseIssueOT10,
         this.isCaseIssueOT13 = strString.isCaseIssueOT13,
         this.isCaseIssueOT13_1 = strString.isCaseIssueOT13_1,
         this.isCaseIssueOT13_2 = strString.isCaseIssueOT13_2,
         this.isCaseIssueOT13_3 = strString.isCaseIssueOT13_3,
         this.violationTypeVariablesForOt10 = strString.violationTypeVariablesForOt10,
         this.violationTypeVariablesForOt13 = strString.violationTypeVariablesForOt13,
         this.violationTypeVariablesForOt13_1 = strString.violationTypeVariablesForOt13_1,
         this.violationTypeVariablesForOt13_2 = strString.violationTypeVariablesForOt13_2,
         this.violationTypeVariablesForOt13_3 = strString.violationTypeVariablesForOt13_3,
         this.isOT28Issue = strString.isOT28Issue,
         this.isDT15Issue = strString.isDT15Issue,
         this.violationTypeVariablesForOt28 = strString.violationTypeVariablesForOt28,
         this.violationTypeVariablesForDt15 = strString.violationTypeVariablesForDt15,
         this.ot28EndDate = strString.ot28EndDate,
         this.ot28StartDate = strString.ot28StartDate,
         this.dt15EndDate = strString.dt15EndDate,
         this.doubleTimeOwedValueOT28 = strString.doubleTimeOwedValueOT28
         this.dt15StartDate = strString.dt15StartDate
         this.overtimeYearSelection = strString.overtimeYearSelection
         this.violationTypeVariablesForOt28 = strString.violationTypeVariablesForOt28,
         this.violationTypeVariablesForDt15 = strString.violationTypeVariablesForDt15
         this.isfarmlabour = Boolean(this.isfarmlabour) ? this.isfarmlabour : strString.isfarmlabour,
         this.is_domestic_worker = Boolean(this.is_domestic_worker) ? this.is_domestic_worker : strString.is_domestic_worker,
         this.isRenderedCallback = true;
         if(Boolean(this.ot10EndDate) && Boolean(this.ot10StartDate)){
             this.isfarmlabour != null && this.isfarmlabour === true ? this.checkCalendarYearForOT10(this.ot10EndDate, this.ot10StartDate) : '';
         }
         if(Boolean(this.dt10StartDate) && Boolean(this.dt10EndDate)){
             this.isfarmlabour != null && this.isfarmlabour === true ? this.checkCalendarYearForDT10(this.dt10StartDate, this.dt10EndDate) : '';
         }
         if(Boolean(this.otStartDate) && Boolean(this.otEndDate)){
             this.checkCalendarYear(this.otStartDate, this.otEndDate);
         }
         if(Boolean(this.dt15StartDate) && Boolean(this.dt15EndDate)){
             this.isfarmlabour != null && this.isfarmlabour === true ? this.checkCalendarYearForDT10(this.dt15StartDate, this.dt15EndDate) : '';
         }
         if(Boolean(this.ot28StartDate) && Boolean(this.ot28EndDate)){
             this.checkCalendarYear(this.ot28StartDate, this.ot28EndDate);
         }
     }
 
     renderedCallback(){
         if(this.isRenderedCallback === true && this.claimDoubleTimeOnly != undefined){
             this.template.querySelector('[data-id="claimDoubleTimeOnly"]').value = this.claimDoubleTimeOnly;
         }
     }
 }