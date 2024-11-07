import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
export default class OwcNotAllowedMealBreakChild extends LightningElement {
    // Attributes
    @api sectionid;
    @api additionalName;
    @api isFormPreviewMode = false;
    @api heading2 = ''
    @api iwcinfoobj
    @api iswagedefpreview
    isrenderedCallback = true;

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
    @api isRequiredField = false
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
            await this.getAllVilationTypeVariablesForOneHourRateRec('71');
        }catch (error){
            console.log('error', error);
        }
        // if(this.paymentOfWagesDetails.HourlyOptionValue === true){
        //     try{
        //         await this.getAllVilationTypeVariablesForOneHourRateRec('71');
        //     }catch (error){
        //         console.log('error', error);
        //     }
        // }
        // else{
        //     this.isOneHourlyRatePOW = false;
        //     this.violationTypeVariablesForOneHourlyRate = undefined;
        // }
        // if(this.paymentOfWagesDetails.salaryRateOptionValue === true || this.paymentOfWagesDetails.differentHourOptionValue === true){
        //     this.paymentOfWagesDetails.salaryRateOptionValue === true ? this.heading2 = this.customLabelValues.OWC_salary_rate : this.paymentOfWagesDetails.differentHourOptionValue === true ? this.heading2 = this.customLabelValues.OWC_different_hourly_rate : ''
        //     try{
        //         await this.getAllVilationTypeVariablesForSalaryRateRec('73');
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
                    result[i].name === 'VTV1001' || result[i].name === 'VTV1000' ? result[i].isHide = true : result[i].isHide = false;
                    result[i].name === 'VTV0069' ? result[i].helpText = true : result[i].helpText = false;
                    result[i].label === 'What is your regular hourly rate of pay?' ? result[i].isRequiredField = false : result[i].isRequiredField = true;
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
                 this.iwcinfoobj.iwcOrderNumber !== undefined ? this.violationTypeVariablesForOneHourlyRate.forEach( element => element.name === 'VTV1000' ? element.value = this.iwcinfoobj.iwcOrderNumber : '' ) : ''
                 this.iwcinfoobj.iwcOrderNumber !== undefined ? this.violationTypeVariablesForOneHourlyRate.forEach( element => element.name === 'VTV1001' ? element.value = '11' : '' ) : ''
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
                    result[i].name === 'VTV0069' ? result[i].helpText = true : result[i].helpText = false
                    result[i].value = '';
                }
                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForOneSalaryRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForOneSalaryRate = result;
                    this.violationTypeVariablesForOneSalaryRate.length > 0 ? this.isSalaryRatePOW = true : this.isSalaryRatePOW = false;
                 }
                 this.iwcinfoobj.iwcOrderNumber !== undefined ? this.violationTypeVariablesForOneSalaryRate.forEach( element => element.name === 'VTV1669' || element.name === 'VTV1670' ? element.value = this.iwcinfoobj.iwcOrderNumber : '' ) : ''
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
    handleMealBreakSectionData(){
        const selectEvent = new CustomEvent('overtimesectiondeleteevent', {
            detail: this.mealBreakInfoObj()},
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

    isDateUnacceptable = false
    isStartDateUnacceptable = false;
    isEnddDateUnacceptable = false;
    isNumberOfWorkdaysMissing = false;
    isAdditionalPayMissing = false;
    isRegularHourlyRateMissing = false;
    isNameValid = false
    // This method is used to collect the parent component data.
    @api
    handleOverTimeParentData(){
        // Validity check fotr this section
        if(this.isOneHourlyRatePOW === true){

            const   claimStartDate = this.template.querySelector('[data-id="VTV0067"]')
            const   claimEndDate = this.template.querySelector('[data-id="VTV0068"]')
         //   const   hourlyratepay = this.template.querySelector('[data-id="VTV0069"]')
            const   numberofwrkdays = this.template.querySelector('[data-id="VTV0070"]')
            const   howmuchpay  = this.template.querySelector('[data-id="VTV0071"]')

           
            this.isStartDateUnacceptable = this.handleRequiredField(claimStartDate);
            this.isEnddDateUnacceptable = this.handleRequiredField(claimEndDate)
          //  this.isRegularHourlyRateMissing = this.handleRequiredField(hourlyratepay);
            this.isNumberOfWorkdaysMissing = this.handleRequiredField(numberofwrkdays);
            this.isAdditionalPayMissing = this.handleRequiredField(howmuchpay);
            this.isDateUnacceptable = this.handlePOWDateValidity(claimStartDate, claimEndDate, claimStartDate.value, claimEndDate.value);


            this.isDateUnacceptable === true ? (this.claimEndDate.focus() && this.claimStartDate.focus()) : ''
            this.isEndDateUnacceptable === true ? this.claimEndDate.focus() : ''
            this.isStartDateUnacceptable === true ? this.claimStartDate.focus() : ''
         //   this.isRegularHourlyRateMissing === true ? this.hourlyratepay.focus() : ''
            this.isNumberOfWorkdaysMissing === true ? this.numberofwrkdays.focus() : ''
            this.isAdditionalPayMissing === true ? this.howmuchpay.focus() : ''


        }
        
        if(this.isNameValid === true || this.isDateUnacceptable === true || this.isStartDateUnacceptable === true || this.isEnddDateUnacceptable === true  || this.isNumberOfWorkdaysMissing === true || this.isAdditionalPayMissing === true){
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
            detail:{
                mealBreakInfoObj : this.mealBreakInfoObj(),
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
    mealBreakInfoObj(){
        return {
            sectionId : this.sectionid,
            violationTypeVariablesForOneHourlyRate : this.violationTypeVariablesForOneHourlyRate,
            isOneHourlyRatePOW : this.isOneHourlyRatePOW,
            isSalaryRatePOW : this.isSalaryRatePOW,
            violationTypeVariablesForOneSalaryRate : this.violationTypeVariablesForOneSalaryRate,
            iwcinfoobj : this.iwcinfoobj
        }
    }

    @api
    handleOverTimeChildData(strString, isFormPreviewMode){
        console.log('strString in overtime sub child ::: ', JSON.stringify(strString));
        this.violationTypeVariablesForOneHourlyRate = strString.violationTypeVariablesForOneHourlyRate,
        this.isOneHourlyRatePOW = strString.isOneHourlyRatePOW,
        this.isSalaryRatePOW = strString.isSalaryRatePOW,
        this.violationTypeVariablesForOneSalaryRate = strString.violationTypeVariablesForOneSalaryRate
        this.iwcinfoobj = this.iwcinfoobj === undefined ? strString.iwcinfoobj : this.iwcinfoobj
    }

    renderedCallback(){
        if(this.isrenderedCallback){
            if(this.paymentOfWagesDetails !== undefined && this.isShowServerResponse === true){
                this.handleHourlyRateOption();
                this.isShowServerResponse = false;
            }

            this.isrenderedCallback = false;

        }
        
    }
}