import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
export default class OwcSplitShiftPremiumChild extends LightningElement {
    // Attributes
    @api sectionid;
    @api additionalName;
    @api isFormPreviewMode = false;
    @api heading2 = ''
    @api iwcinfoobj
    @api iswagedefpreview

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
    }

    @api paymentOfWagesDetails
    @api isShowServerResponse = false;
    @api
    handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
        console.log('Payment detail in child 12::: ', JSON.stringify(paymentOfWagesDetails));
        this.paymentOfWagesDetails = paymentOfWagesDetails;
        this.callOneHourlyRateApplied();
        this.paymentOfWagesDetails !== undefined ? this.isShowServerResponse = true : this.isShowServerResponse = false;
        this.isFormPreviewMode = isFormPreviewMode;
    }

    @api violationTypeVariablesForOneHourlyRate;
    @api isOneHourlyRatePOW = false;
    @api isSalaryRatePOW = false;
    @api violationTypeVariablesForOneSalaryRate;
    
    async callOneHourlyRateApplied(){
        try{
            await this.getAllVilationTypeVariablesForOneHourRateForMin('1112');
        }catch (error){
            console.log('error', error);
        }
    }

    @api violationTypeVariablesForOneHourlyForMin
    @api isOneHourlyForMin = false;
    getAllVilationTypeVariablesForOneHourRateForMin(queryCode){
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
                    result[i].name === 'VTV1757' ? result[i].isHide = true : result[i].isHide = false;
                    result[i].value = '';
                }
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForOneHourlyForMin !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForOneHourlyForMin = result;
                    this.violationTypeVariablesForOneHourlyForMin.length > 0 ? this.isOneHourlyForMin = true : this.isOneHourlyForMin = false;
                 }
                 this.iwcinfoobj.iwcOrderNumber !== undefined ? this.violationTypeVariablesForOneHourlyForMin.forEach( element => element.name === 'VTV1757' ? element.value = this.iwcinfoobj.iwcOrderNumber : '' ) : ''
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }


    @api isHelpText= false;
    @api helpText;
    // Help text 
    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === "hourlyRateMsg"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_hourly_rate_pay_helptext;
        }
    }
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    
    @api
    handleSplitShiftSectionData(){
        const selectEvent = new CustomEvent('splitshiftectiondeleteevent', {
            detail: this.splitShiftInfoObj()},
        );
        this.dispatchEvent(selectEvent);
    }

    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            
        }
        if(this.violationTypeVariablesForOneHourlyForMin !== undefined){
            for(var i=0; i<this.violationTypeVariablesForOneHourlyForMin.length; i++){
                this.violationTypeVariablesForOneHourlyForMin[i].name === event.target.name ? this.violationTypeVariablesForOneHourlyForMin[i].value = event.target.value : ''
            }
        }
    }
    
    handleWageDefValidityEvent(){
        const selectEvent = new CustomEvent('splitshiftdefchildvalidityevent', {
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
        // Validity check fotr this section

        let startDate = this.template.querySelector('[data-id="VTV1758"]');
        let endDate = this.template.querySelector('[data-id="VTV1759"]');
        let regularRatePay = this.template.querySelector('[data-id="VTV1760"]');
        let numberOfWorkdays = this.template.querySelector('[data-id="VTV1761"]');
        let amountNotPaid = this.template.querySelector('[data-id="VTV1763"]');

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
    handleSplitShiftParentInfo(){
        const selectEvent = new CustomEvent('splitshiftcustominfoevent', {
            detail:{
                splitShiftInfoObj : this.splitShiftInfoObj(),
                vtCaseIssueObj : this.vtCaseIssueObj()
            }
        });
        this.dispatchEvent(selectEvent);
    }

    @api 
    vtCaseIssueObj(){
        return{
            violationTypeVariablesForOneHourlyForMin : this.violationTypeVariablesForOneHourlyForMin,
        }
    }

    @api
    splitShiftInfoObj(){
        return {
            sectionId : this.sectionid,
            violationTypeVariablesForOneHourlyForMin : this.violationTypeVariablesForOneHourlyForMin,
            isOneHourlyForMin : this.isOneHourlyForMin,
            isSalaryRatePOW : this.isSalaryRatePOW,
            iwcinfoobj : this.iwcinfoobj
        }
    }

    @api
    handleOverTimeChildData(strString, isFormPreviewMode){
        console.log('strString in overtime sub child ::: ', JSON.stringify(strString));
        this.violationTypeVariablesForOneHourlyForMin = strString.violationTypeVariablesForOneHourlyForMin,
        this.isOneHourlyForMin = strString.isOneHourlyForMin,
        this.isSalaryRatePOW = strString.isSalaryRatePOW,
        this.violationTypeVariablesForOneSalaryRate = strString.violationTypeVariablesForOneSalaryRate
        this.iwcinfoobj = this.iwcinfoobj === undefined ? strString.iwcinfoobj : this.iwcinfoobj
    }

    renderedCallback(){
        if(this.paymentOfWagesDetails !== undefined && this.isShowServerResponse === true){
            this.callOneHourlyRateApplied();
            this.isShowServerResponse = false;
        }
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