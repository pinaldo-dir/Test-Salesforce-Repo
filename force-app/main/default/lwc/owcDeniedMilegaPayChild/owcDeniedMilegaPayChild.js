import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
export default class OwcDeniedMilegaPayChild extends LightningElement {
    // Attributes
    @api sectionid;
    @api additionalName;
    @api isFormPreviewMode = false;
    @api isMoreThanOneCalendar = false;
    @api isRenderedCallback = false;
    @api msg;
    @api iswagedefpreview;

    radioOptions = radioOptions

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
        this.handleHourlyRateOption();
    }

    @api violationTypeVariablesForOneHourlyRate;
    @api isOneHourlyRatePOW = false;
    async handleHourlyRateOption(){
            try{
                await this.getAllVilationTypeVariablesForOneHourRateRec('012');
            }catch (error){
                console.log('error', error);
            }
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
                    result[i].name === 'VTV1261' ? result[i].isMileageRate = true : result[i].isMileageRate = false;
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

    @api
    handleMileageClaimSectionData(){
        const selectEvent = new CustomEvent('overtimesectiondeleteevent', {
            detail: this.mileageClaimInfoObj()},
        );
        this.dispatchEvent(selectEvent);
    }

    beggingDate;
    beggingDateId;
    endingDate;
    endingDateId;
    @api mileageReimbursement;
    @api mileageLog;
    @api numberOfMiles = 0;
    @api mileageRate = 0;
    // This method is used to take the input values from the end user.c/hideSpinnerCmp
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            case "mileageLog":
               this.mileageLog = event.target.value;
               console.log('mileageLog ::: ', this.mileageLog);
               break;
            case "mileageReimbursement":
                this.mileageReimbursement = event.target.value;
                console.log('mileageReimbursement ::: ', this.mileageReimbursement)
                break;
        }
        if(this.violationTypeVariablesForOneHourlyRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForOneHourlyRate.length; i++){
                this.violationTypeVariablesForOneHourlyRate[i].name === event.target.name ? this.violationTypeVariablesForOneHourlyRate[i].value = event.target.value : ''
                if(event.target.name === 'VTV1258'){
                    this.numberOfMiles = event.target.value;
                    this.CalculateTotalMileageAmount(this.numberOfMiles, this.mileageRate);
                }
                if(event.target.name === 'VTV1260'){
                    this.mileageRate = event.target.value;
                    this.CalculateTotalMileageAmount(this.numberOfMiles, this.mileageRate);
                }
                // Check claim placed after one calendar year
                if(event.target.name === 'VTV1256'){
                    this.beggingDate = event.target.value;
                    this.beggingDateId = this.violationTypeVariablesForOneHourlyRate[i].name;
                    // this.violationTypeVariablesForOneHourlyRate[i].dataType === 'Date' ? this.checkOneCalendarYearValidation(this.violationTypeVariablesForOneHourlyRate[i]) : ''
                }
                else if(event.target.name === 'VTV1257'){
                    this.endingDate = event.target.value;
                    this.endingDateId = this.violationTypeVariablesForOneHourlyRate[i].name;
                }
                
            }
            if((this.beggingDate !== undefined || this.beggingDate !== null) && (this.endingDate !== undefined || this.endingDate !== null)){
                var Difference_In_Days = this.getNumberOfDays(this.beggingDate, this.endingDate);
                if(Difference_In_Days > 365){
                    this.isMoreThanOneCalendar = true;
                    const beggingDateId = `[data-id="${this.beggingDateId}"]`;
                    this.template.querySelector(String(beggingDateId)).focus()
                    this.msg = this.customLabelValues.OWC_mileage_claim_span_year_msg;
                }
                else{
                    this.isMoreThanOneCalendar = false;
                }
            }
        }
    }

    CalculateTotalMileageAmount(numberOfMiles, MileageRate){
        if(numberOfMiles !== null && MileageRate !== null){
            this.template.querySelector('[data-id="mileageReimbursement"]').value = numberOfMiles * MileageRate;
        }
    }

    getNumberOfDays(start, end) {
        const date1 = new Date(start);
        const date2 = new Date(end);
    
        // One day in milliseconds
        const oneDay = 1000 * 60 * 60 * 24;
    
        // Calculating the time difference between two dates
        const diffInTime = date2.getTime() - date1.getTime();
    
        // Calculating the no. of days between two dates
        const diffInDays = Math.round(diffInTime / oneDay);
    
        return diffInDays;
    }

    // Check the validation if claim has been made for greater than one calendar year
    checkOneCalendarYearValidation(data){
        if(data !== undefined || data !== null){
            
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

    isDateUnacceptable = false
    isEnddDateUnacceptable = false
    isStartDateUnacceptable = false
    isNameValid = false
    isHowManyMilesMissing = false

    // This method is used to collect the parent component data.
    @api
    handleOverTimeParentData(){
        // Validity check fotr this section


        const   claimStartDate = this.template.querySelector('[data-id="VTV1256"]')
        const   claimEndDate = this.template.querySelector('[data-id="VTV1257"]')
        const   howManyMiles  = this.template.querySelector('[data-id="VTV1258"]')

       
        this.isStartDateUnacceptable = this.handleRequiredField(claimStartDate);
        this.isEnddDateUnacceptable = this.handleRequiredField(claimEndDate)
        this.isHowManyMilesMissing = this.handleRequiredField(howManyMiles);
        this.isDateUnacceptable = this.handlePOWDateValidity(claimStartDate, claimEndDate, claimStartDate.value, claimEndDate.value);


        this.isDateUnacceptable === true ? (this.claimEndDate.focus() && this.claimStartDate.focus()) : ''
        this.isEndDateUnacceptable === true ? this.claimEndDate.focus() : ''
        this.isStartDateUnacceptable === true ? this.claimStartDate.focus() : ''
        this.isHowManyMilesMissing === true ? this.howManyMiles.focus() : ''



        const beggingDateId = `[data-id="${this.beggingDateId}"]`;
        this.isMoreThanOneCalendar === true ? this.template.querySelector(String(beggingDateId)).focus() : ''
        
        if(this.isMoreThanOneCalendar === true || this.isDateUnacceptable === true || this.isStartDateUnacceptable === true || this.isEnddDateUnacceptable === true || this.isHowManyMilesMissing === true){
            this.handleWageDefValidityEvent();
        }
    }

    //Date validation
    handlePOWDateValidity(startDateId, endDateId, startDate, endDate){
        var startDateId = startDateId
        var endDateId = endDateId
        var startDate = startDate
        var endDate = endDate
        var today = new Date();

        startDate !== '' && startDate !== null && startDate !== undefined ? startDate = new Date(startDate.toString()) : ''

        endDate !== '' && endDate !== null && endDate !== undefined ? endDate = new Date(endDate.toString()) : ''


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

   //required field validation
    handleRequiredField(FieldId){
        if( FieldId.value === null || FieldId.value.trim() === '' || FieldId.value === undefined || FieldId.value.trim() === '$0.00') {
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


    @api
    handleOverTimeParentInfo(){
        const selectEvent = new CustomEvent('overtimecustominfoevent', {
            detail: {
                mileageClaimInfoObj : this.mileageClaimInfoObj(),
                vtCaseIssueObj : this.vtCaseIssueObj()
            }
        });
        this.dispatchEvent(selectEvent);
    }

    @api vtCaseIssueObj(){
        return {
            violationTypeVariablesForOneHourlyRate : this.violationTypeVariablesForOneHourlyRate,
        }
    }
    @api
    mileageClaimInfoObj(){
        return {
            sectionId : this.sectionid,
            violationTypeVariablesForOneHourlyRate : this.violationTypeVariablesForOneHourlyRate,
            isOneHourlyRatePOW : this.isOneHourlyRatePOW,
            mileageReimbursement : this.mileageReimbursement,
            mileageLog : this.mileageLog
        }
    }

    @api
    handleOverTimeChildData(strString, isFormPreviewMode){
        console.log('strString in overtime sub child ::: ', JSON.stringify(strString));
        this.violationTypeVariablesForOneHourlyRate = strString.violationTypeVariablesForOneHourlyRate
        this.isOneHourlyRatePOW = strString.isOneHourlyRatePOW
        this.mileageReimbursement = strString.mileageReimbursement,
        this.mileageLog = strString.mileageLog
        this.isRenderedCallback = true;
    }

    renderedCallback(){
        if(this.isRenderedCallback === true && this.mileageLog !== undefined){
            this.template.querySelector('[data-id="mileageLog"]').value = this.mileageLog;
        }
        if(this.isRenderedCallback === true && this.mileageReimbursement !== undefined){
            this.template.querySelector('[data-id="mileageReimbursement"]').value = this.mileageReimbursement;
        }
    }
}