import { LightningElement, api, track, wire } from 'lwc';
import { radioOptions, acceptedFileFormat, customLabelValues } from 'c/owcUtils';
import severancePayOfferedOptions from '@salesforce/apex/OwcWageDeficiencies.fetchseverancePayOfferedOption';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OwcWaitingTimeClaimGarment extends LightningElement {
    @api powdetails;
    @api isnotidentifyemployer;
    @api dischargeddate;
    @api quitdatevalue;
    @api noticebeforequit;
    @api finalpaymentdate;
    @api iswagedefpreview;

    // Custom labels
    customLabelValues = customLabelValues;

    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    connectedCallback(){
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
            console.log( error.body.message );
        });
        console.log('powdetails ::: ', JSON.stringify(this.powdetails));
        this.handleWaitingTimeServerCalls();
    }

    @api isHelpText = false;
    @api helpText;
    // Helptext
    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === 'regularClaimHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_regular_claim_helptext;
        }
        else if(learnMoreName === 'sickLeaveOptionHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_sick_leave_helptext;
            this.issickleavehelptext = true;
        }
        else if(learnMoreName === 'otOrDtClaimHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_OT_DT_claim_helptext;
        }
        else if(learnMoreName === 'multiFileUploadHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_multiplefileupload_helptext;
        }
        else if(learnMoreName === 'waitingTimeHelpTextForThree'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_waiting_time_eleven_helptext;
        }
        else if(learnMoreName === 'waitingTimeHelpText'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_waiting_ten_helptext;
        }
        else if(learnMoreName === "deniedPayroll"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_denied_payroll_helptext;
        }
        else if(learnMoreName === 'deniedPersonalFile'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_denied_personnel_file_label;
        }
        else if(learnMoreName === "vacationTimeTotalHourHelpMsg"){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_vacation_time_final_rate;
        }
        else if(learnMoreName === 'vacationTimeClaim'){
            this.isHelpText = true;
            this.isdlse55Available = null;
            this.helpText = customLabelValues.OWC_typically_worked_vacationtimeclaims_helptext;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        }
        else if(learnMoreName === "unreimbursedBusiness"){
            this.isHelpText = true;
            this.isdlse55Available = null;
            this.helpText = customLabelValues.OWC_typically_worked_unreimbursed_business_helptext;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        } 
        else if(learnMoreName === 'deniedPaymentText'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_mileage_denied_helptext;
        }   
        else if(learnMoreName === "listedClaimHelptext"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_select_one_checkbox_label;
        }
        else if(learnMoreName === 'productionBonus'){
            this.isHelpText = true;
            this.helpText = 'Examples of a Production Bonus are $100 for staying until end of season; $2 for each day worked X 100 days; 1% of earnings for pieces produced.';
        }    
        else if(learnMoreName === 'paymentDenied'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_business_denied_helptext;
        }
    }
  
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    handleWaitingTimeServerCalls(){
        if(this.isnotidentifyemployer !== undefined && this.isnotidentifyemployer === 'No'){
            if(this.dischargeddate !== null){
                this.handleEmployementSecOne();
                this.isWaitingTimeOne = true;
                this.violationTypeVariablesForWaitingTimeTwo = undefined;
                this.isWaitingTimeTwo = false;
                this.violationTypeVariablesForWaitingTimeThree = undefined;
                this.isWaitingTimeThree = false;
                this.violationTypeVariablesForWaitingTimeFour = undefined;
                this.isWaitingTimeFour = false;
            }
            else if((this.quitdatevalue !== null) && this.noticebeforequit === true){
                this.handleEmployementSecTwo();
                this.isWaitingTimeTwo = true;
                this.violationTypeVariablesForWaitingTimeOne = undefined;
                this.isWaitingTimeOne = false;
                this.violationTypeVariablesForWaitingTimeThree = undefined;
                this.isWaitingTimeThree = false;
                this.violationTypeVariablesForWaitingTimeFour = undefined;
                this.isWaitingTimeFour = false;
            }
            else if((this.quitdatevalue !== null) && this.noticebeforequit === false){
                this.handleEmployementSecThree();
                this.isWaitingTimeThree = true;
                this.violationTypeVariablesForWaitingTimeOne = undefined;
                this.isWaitingTimeOne = false;
                this.violationTypeVariablesForWaitingTimeTwo = undefined;
                this.isWaitingTimeTwo = false;
                this.violationTypeVariablesForWaitingTimeFour = undefined;
                this.isWaitingTimeFour = false;
            }
            else if(this.dischargeddate === null || this.quitdatevalue === null){
                this.handleEmployementSecFour();
                this.isWaitingTimeFour = true;
                this.violationTypeVariablesForWaitingTimeOne = undefined;
                this.isWaitingTimeOne = false;
                this.violationTypeVariablesForWaitingTimeTwo = undefined;
                this.isWaitingTimeTwo = false;
                this.violationTypeVariablesForWaitingTimeThree = undefined;
                this.isWaitingTimeThree = false;
            }
        }
        else{
            this.violationTypeVariablesForWaitingTimeOne = undefined;
            this.isWaitingTimeOne = false;
            this.violationTypeVariablesForWaitingTimeTwo = undefined;
            this.isWaitingTimeTwo = false;
            this.violationTypeVariablesForWaitingTimeThree = undefined;
            this.isWaitingTimeThree = false;
            this.violationTypeVariablesForWaitingTimeFour = undefined;
            this.isWaitingTimeFour = false;
        }
    }

    async handleEmployementSecOne(){
        try{
            await this.getAllVilationTypeVariablesForEmpSecOne('WT10');
        }catch (error){
            console.log('error', error);
        }
    }

    async handleEmployementSecTwo(){
        try{
            await this.getAllVilationTypeVariablesForEmpSecTwo('WT11');
        }catch (error){
            console.log('error', error);
        }
    }

    async handleEmployementSecThree(){
        try{
            await this.getAllVilationTypeVariablesForEmpSecThree('WT12');
        }catch (error){
            console.log('error', error);
        }
    }

    async handleEmployementSecFour(){
        try{
            await this.getAllVilationTypeVariablesForEmpSecFour('WT13');
        }catch (error){
            console.log('error', error);
        }
    }

    @api violationTypeVariablesForWaitingTimeOne;
    @api isWaitingTimeOne = false
    getAllVilationTypeVariablesForEmpSecOne(queryCode){
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
                    result[i].name === 'VTV1016' ? result[i].helpText = true : result[i].helpText = false;
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForWaitingTimeOne !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForWaitingTimeOne = result;
                    this.violationTypeVariablesForWaitingTimeOne.length > 0 ? this.isWaitingTimeOne = true : this.isWaitingTimeOne = false;
                 }
                 this.dischargeddate !== undefined ? this.violationTypeVariablesForWaitingTimeOne.forEach( element => element.name === 'VTV1014' ? element.value = this.dischargeddate : '' ) : ''
                 this.violationTypeVariablesForWaitingTimeOne.length > 0 ? this.isWaitingTimeOne = true : this.isWaitingTimeOne = false;
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }
    
    @api violationTypeVariablesForWaitingTimeTwo;
    @api isWaitingTimeTwo = false
    getAllVilationTypeVariablesForEmpSecTwo(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    result[i].name === 'VTV1697' ? result[i].dataType = 'Date' : ''
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
                    result[i].name === 'VTV1696' ? result[i].helpText = true : result[i].helpText = false;
                    result[i].value = '';
                }

                 if(this.violationTypeVariablesForWaitingTimeTwo !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForWaitingTimeTwo = result;
                    this.violationTypeVariablesForWaitingTimeTwo.length > 0 ? this.isWaitingTimeTwo = true : this.isWaitingTimeTwo = false;
                    this.quitdatevalue !== undefined || this.quitdatevalue !== null ? this.violationTypeVariablesForWaitingTimeTwo.forEach( element => element.name === 'VTV1694' ? element.value = this.quitdatevalue : '' ) : ''
                    this.finalpaymentdate !== undefined || this.finalpaymentdate !== null ? this.violationTypeVariablesForWaitingTimeTwo.forEach( element => element.name === 'VTV1697' ? element.value = this.finalpaymentdate : '' ) : ''
                 }
                 this.finalpaymentdate !== undefined || this.finalpaymentdate !== null ? this.violationTypeVariablesForWaitingTimeTwo.forEach( element => element.name === 'VTV1697' ? element.value = this.finalpaymentdate : '' ) : ''
                 this.quitdatevalue !== undefined || this.quitdatevalue !== null ? this.violationTypeVariablesForWaitingTimeTwo.forEach( element => element.name === 'VTV1694' ? element.value = this.quitdatevalue : '' ) : ''
                 this.violationTypeVariablesForWaitingTimeTwo.length > 0 ? this.isWaitingTimeTwo = true : this.isWaitingTimeTwo = false;
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api violationTypeVariablesForWaitingTimeThree;
    @api isWaitingTimeThree = false
    getAllVilationTypeVariablesForEmpSecThree(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    result[i].name === 'VTV1706' ? result[i].dataType = 'Date' : ''
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
                    result[i].name === 'VTV1705' ? result[i].helpText = true : result[i].helpText = false
                    result[i].value = '';
                }

                 if(this.violationTypeVariablesForWaitingTimeThree !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForWaitingTimeThree = result;
                    this.violationTypeVariablesForWaitingTimeThree.length > 0 ? this.isWaitingTimeThree = true : this.isWaitingTimeThree = false;
                    this.quitdatevalue !== undefined || this.quitdatevalue !== null ? this.violationTypeVariablesForWaitingTimeThree.forEach( element => element.name === 'VTV1703' ? element.value = this.quitdatevalue : '' ) : ''
                    this.finalpaymentdate !== undefined || this.finalpaymentdate !== null ? this.violationTypeVariablesForWaitingTimeThree.forEach( element => element.name === 'VTV1706' ? element.value = this.finalpaymentdate : '' ) : ''
                 }
                 this.finalpaymentdate !== undefined || this.finalpaymentdate !== null ? this.violationTypeVariablesForWaitingTimeThree.forEach( element => element.name === 'VTV1706' ? element.value = this.finalpaymentdate : '' ) : ''
                 this.quitdatevalue !== undefined || this.quitdatevalue !== null ? this.violationTypeVariablesForWaitingTimeThree.forEach( element => element.name === 'VTV1703' ? element.value = this.quitdatevalue : '' ) : ''
                 this.violationTypeVariablesForWaitingTimeThree.length > 0 ? this.isWaitingTimeThree = true : this.isWaitingTimeThree = false;
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api violationTypeVariablesForWaitingTimeFour;
    @api isWaitingTimeFour = false
    getAllVilationTypeVariablesForEmpSecFour(queryCode){
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
                    reuslt[i].name === 'VTV1705' ? result[i].helpText = true : result[i].helpText = false
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForWaitingTimeFour !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForWaitingTimeFour = result;
                    this.violationTypeVariablesForWaitingTimeFour.length > 0 ? this.isWaitingTimeFour = true : this.isWaitingTimeFour = false;
                    // this.dischargeddate === true ? this.violationTypeVariablesForWaitingTimeFour.forEach( element => element.name === 'VTV1014' ? element.value = this.dischargeddate : '') : this.quitDate === true ? this.violationTypeVariablesForWaitingTimeFour.forEach( element => element.name === 'VTV1014' ? element.value = this.quitdatevalue : '') : ''
                 }
                 this.dischargeddate !== undefined || this.dischargeddate !== null ? this.violationTypeVariablesForWaitingTimeFour.forEach( element => element.name === 'VTV1014' ? element.value = this.dischargeddate : '')  : ''
                 this.quitdatevalue !== undefined || this.quitdatevalue !== null ? this.violationTypeVariablesForWaitingTimeFour.forEach( element => element.name === 'VTV1014' ? element.value = this.quitdatevalue : '') : ''
                 this.violationTypeVariablesForWaitingTimeFour.length > 0 ? this.isWaitingTimeFour = true : this.isWaitingTimeFour = false;
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api isNameValid = false;

    handleEmployerValidityEvent(){
        const selectEvent = new CustomEvent('waitingtimevalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.dispatchEvent(selectEvent);
    }
    // This method is used to send the values to the parent cmp
    @api
    handleWaitingTimeParent(){
        this.isNameValid === true ? this.handleEmployerValidityEvent() : this.handleEmployerParentInfo();
    }

    handleEmployerParentInfo(){
        const selectEvent = new CustomEvent('waitinginfoevent', {
            detail:{
                waitingInfoObj : this.waitingInfoObj() ,
                vtCaseIssueObj : this.vtCaseIssueObj()
            }
        });
        this.dispatchEvent(selectEvent);
    }
    
    @api
    vtCaseIssueObj(){
        return{
            violationTypeVariablesForWaitingTimeOne : this.violationTypeVariablesForWaitingTimeOne,
            violationTypeVariablesForWaitingTimeTwo : this.violationTypeVariablesForWaitingTimeTwo,
            violationTypeVariablesForWaitingTimeThree : this.violationTypeVariablesForWaitingTimeThree,
            violationTypeVariablesForWaitingTimeFour : this.violationTypeVariablesForWaitingTimeFour
        }
    }

    waitingInfoObj(){
        return {
            violationTypeVariablesForWaitingTimeOne : this.violationTypeVariablesForWaitingTimeOne,
            isWaitingTimeOne : this.isWaitingTimeOne,
            violationTypeVariablesForWaitingTimeTwo : this.violationTypeVariablesForWaitingTimeTwo,
            isWaitingTimeTwo : this.isWaitingTimeTwo,
            violationTypeVariablesForWaitingTimeThree : this.violationTypeVariablesForWaitingTimeThree,
            isWaitingTimeThree : this.isWaitingTimeThree,
            violationTypeVariablesForWaitingTimeFour : this.violationTypeVariablesForWaitingTimeFour,
            isWaitingTimeFour : this.isWaitingTimeFour,
            isnotidentifyemployer : this.isnotidentifyemployer,
            dischargeddate : this.dischargeddate,
            finalpaymentdate : this.finalpaymentdate,
            quitdatevalue : this.quitdatevalue,
            noticebeforequit : this.noticebeforequit
        }
    }
    // This method is used to take the values from the parent cmp.
    @api
    handleWaitingInfoChild(strString, isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode;
        this.violationTypeVariablesForWaitingTimeOne = this.isWaitingTimeOne === false ? undefined : strString.violationTypeVariablesForWaitingTimeOne
        this.isWaitingTimeOne = this.isWaitingTimeOne === false ? false : strString.isWaitingTimeOne
        this.violationTypeVariablesForWaitingTimeTwo = this.isWaitingTimeTwo === false ? undefined : strString.violationTypeVariablesForWaitingTimeTwo
        this.isWaitingTimeTwo = this.isWaitingTimeTwo === false ? false : strString.isWaitingTimeTwo
        this.violationTypeVariablesForWaitingTimeThree = this.isWaitingTimeThree === false ? undefined : strString.violationTypeVariablesForWaitingTimeThree
        this.isWaitingTimeThree = this.isWaitingTimeThree === false ? false : strString.isWaitingTimeThree
        this.violationTypeVariablesForWaitingTimeFour = this.isWaitingTimeFour === false ? undefined : strString.violationTypeVariablesForWaitingTimeFour
        this.isWaitingTimeFour = this.isWaitingTimeFour === false ? false : strString.isWaitingTimeFour
        
        this.finalpaymentdate = (this.finalpaymentdate === undefined || this.finalpaymentdate === null) ? strString.finalpaymentdate : this.finalpaymentdate
        this.isnotidentifyemployer = (this.isnotidentifyemployer === undefined || this.isnotidentifyemployer === null) ? strString.isnotidentifyemployer : ''
        this.dischargeddate = (this.dischargeddate === undefined || this.dischargeddate === null) ? strString.dischargeddate : this.dischargeddate
        this.quitdatevalue = (this.quitdatevalue === undefined || this.quitdatevalue === null) ? strString.quitdatevalue : this.quitdatevalue
        this.noticebeforequit = (this.noticebeforequit === undefined || this.noticebeforequit === null) ? strString.noticebeforequit : this.noticebeforequit
    }

    // This method is used to take the input values from the user.
    handleChange(event){
        switch ( event.target.name ) {
        }
        if(this.violationTypeVariablesForWaitingTimeOne !== undefined){
            for(var i=0; i<this.violationTypeVariablesForWaitingTimeOne.length; i++){
                this.violationTypeVariablesForWaitingTimeOne[i].name === event.target.name ? this.violationTypeVariablesForWaitingTimeOne[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForWaitingTimeTwo !== undefined){
            for(var i=0; i<this.violationTypeVariablesForWaitingTimeTwo.length; i++){
                this.violationTypeVariablesForWaitingTimeTwo[i].name === event.target.name ? this.violationTypeVariablesForWaitingTimeTwo[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForWaitingTimeThree !== undefined){
            for(var i=0; i<this.violationTypeVariablesForWaitingTimeThree.length; i++){
                this.violationTypeVariablesForWaitingTimeThree[i].name === event.target.name ? this.violationTypeVariablesForWaitingTimeThree[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForWaitingTimeFour !== undefined){
            for(var i=0; i<this.violationTypeVariablesForWaitingTimeFour.length; i++){
                this.violationTypeVariablesForWaitingTimeFour[i].name === event.target.name ? this.violationTypeVariablesForWaitingTimeFour[i].value = event.target.value : ''
            }
        }
    }

    // Renderedcallback
    renderedCallback(){

    }
}