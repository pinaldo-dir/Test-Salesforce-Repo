import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
export default class OwcNotAllowedHeatRestChild extends LightningElement {
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
    isDateInvalid = false
    isRegularRateInvalid = false
    isNumberOfWorkdaysInvalid = false
    isAmountNotPaidInvalid = false
    // This method is used to collect the parent component data.
    @api
    handleOverTimeParentData(){
        // Validity check for this section
        let startDate = this.template.querySelector('[data-id="VTV0079"]');
        let endDate = this.template.querySelector('[data-id="VTV0080"]');
        let regularRatePay = this.template.querySelector('[data-id="VTV0081"]');
        let numberOfWorkdays = this.template.querySelector('[data-id="VTV0082"]');
        let amountNotPaid = this.template.querySelector('[data-id="VTV0083"]');

        this.isDateInvalid = this.handleDateValidity(startDate,endDate,startDate.value,endDate.value)
        this.isRegularRateInvalid = this.handleRequiredField(regularRatePay)
        this.isNumberOfWorkdaysInvalid = this.handleRequiredField(numberOfWorkdays)
        this.isAmountNotPaidInvalid = this.handleRequiredField(amountNotPaid)

        this.isDateInvalid === true ? (startDate.focus() && endDate.focus()) : ''
        this.isRegularRateInvalid === true ? regularRatePay.focus() : ''
        this.isNumberOfWorkdaysInvalid === true ? numberOfWorkdays.focus() : ''
        this.isAmountNotPaidInvalid === true ? amountNotPaid.focus() : ''


        if(this.isNameValid === true || this.isDateInvalid === true || this.isRegularRateInvalid === true || this.isNumberOfWorkdaysInvalid === true || this.isAmountNotPaidInvalid === true){
            this.handleWageDefValidityEvent();
        }
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



    /* This method is used to check all types of validation on the date fields. */
    handleDateValidity(startDateId, endDateId, startDate, endDate){
        var startDateId = startDateId
        var endDateId = endDateId
        var startDate = startDate
        var endDate = endDate
        var today = new Date();

        startDate !== '' ? startDate = new Date(startDate.toString()) : ''

        endDate !== '' ? endDate = new Date(endDate.toString()) : ''
        if(startDate === '' && endDate === ''){
            startDateId.setCustomValidity('This is a required field')
            endDateId.setCustomValidity('This is a required field')
            startDateId.reportValidity();
            endDateId.reportValidity();
            return true;
        }

        else if((startDate === '' && endDate !== '') || (startDate !== '' && endDate === '')){
            startDateId.setCustomValidity('Please fill both date fields.')
            endDateId.setCustomValidity('Please fill both date fields.')
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

    handleRequiredField(FieldId){
        if( FieldId.value.trim() === '' || FieldId.value === null || FieldId.value === undefined || FieldId.value.trim() === '$0.00') {
            FieldId.setCustomValidity('This is a required field')
            FieldId.reportValidity()
            return true;
        }
        else{
            FieldId.setCustomValidity('')
            FieldId.reportValidity()
            return false
        }
    }


}