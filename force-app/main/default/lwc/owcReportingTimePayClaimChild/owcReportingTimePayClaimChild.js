import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
export default class OwcReportingTimePayClaimChild extends LightningElement {
    // Attributes
    @api sectionid;
    @api additionalName;
    @api isFormPreviewMode = false;
    @api iswagedefpreview
    @api iwcinfoobj

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

    @api getAllVilationTypeVariablesForOneHourRate;
    @api isOneHourlyRatePOW = false;
    @api isSalaryRatePOW = false;
    @api violationTypeVariablesForOneSalaryRate;
    async handleHourlyRateOption(){
        try{
            await this.getAllVilationTypeVariablesForOneHourRateRec('181');
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
                    result[i].value = '';
                    result[i].name === 'VTV1004' ? result[i].isHide = true : result[i].isHide = false;
                }
                
                 if(this.violationTypeVariablesForOneHourlyRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForOneHourlyRate = result;
                    this.violationTypeVariablesForOneHourlyRate.length > 0 ? this.isOneHourlyRatePOW = true : this.isOneHourlyRatePOW = false;
                 }
                 this.iwcinfoobj.iwcOrderNumber !== undefined ? this.violationTypeVariablesForOneHourlyRate.forEach( element => element.name === 'VTV1004' ? element.value = this.iwcinfoobj.iwcOrderNumber : '' ) : ''
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

    @api paymentOfWagesDetails
    @api isShowServerResponse = false;
    @api
    handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
        console.log('Payment detail in child 11::: ', JSON.stringify(paymentOfWagesDetails));
        this.paymentOfWagesDetails = paymentOfWagesDetails;
        this.handleHourlyRateOption();
        this.paymentOfWagesDetails !== undefined ? this.isShowServerResponse = true : this.isShowServerResponse = false;
        this.isFormPreviewMode = isFormPreviewMode;
    }

    @api
    handlePayClaimSectionData(){
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
            case this.violationTypeVariablesForOneHourlyRate[0].name:
                this.violationTypeVariablesForOneHourlyRate[0].value = event.target.value;
                break;
            case this.violationTypeVariablesForOneHourlyRate[1].name:
                this.violationTypeVariablesForOneHourlyRate[1].value = event.target.value;
                break;
            case this.violationTypeVariablesForOneHourlyRate[2].name:
                this.violationTypeVariablesForOneHourlyRate[2].value = event.target.value;
                break;
            case this.violationTypeVariablesForOneHourlyRate[3].name:
                this.violationTypeVariablesForOneHourlyRate[3].value = event.target.value;
                break;
            case this.violationTypeVariablesForOneHourlyRate[4].name:
                this.violationTypeVariablesForOneHourlyRate[4].value = event.target.value;
                break;
            case this.violationTypeVariablesForOneHourlyRate[5].name:
                this.violationTypeVariablesForOneHourlyRate[5].value = event.target.value;
                break;
            case this.violationTypeVariablesForOneSalaryRate[0].name:
                this.violationTypeVariablesForOneSalaryRate[0].value = event.target.value;
                break;
            case this.violationTypeVariablesForOneSalaryRate[1].name:
                this.violationTypeVariablesForOneSalaryRate[1].value = event.target.value;
                break;
            case this.violationTypeVariablesForOneSalaryRate[2].name:
                this.violationTypeVariablesForOneSalaryRate[2].value = event.target.value;
                break;
            case this.violationTypeVariablesForOneSalaryRate[3].name:
                this.violationTypeVariablesForOneSalaryRate[3].value = event.target.value;
                break;
            case this.violationTypeVariablesForOneSalaryRate[4].name:
                this.violationTypeVariablesForOneSalaryRate[4].value = event.target.value;
                break;
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
    isStartDateMissing = false
    isEndDateMissing = false
    isRegularHourRateMissing = false
    isTotalNumberPayHoursMissing = false
    isTotalAmountPaidMissing = false
    isNameValid = false
    // This method is used to collect the parent component data.
    @api
    handleOverTimeParentData(){
        // Validity check for this section

        let startDateId = this.template.querySelector('[data-id="VTV0062"]');
        let endDateId = this.template.querySelector('[data-id="VTV0063"]');
        let regularHourRateId = this.template.querySelector('[data-id="VTV0064"]');
        let totalNumberPayId = this.template.querySelector('[data-id="VTV0065"]');
        let totalAmountPayId = this.template.querySelector('[data-id="VTV0066"]');

        
        this.isStartDateMissing = this.handlePOWDateValidity(startDateId,endDateId,startDateId.value,endDateId.value)
        this.isEndDateMissing = this.handlePOWDateValidity(startDateId,endDateId,startDateId.value,endDateId.value)
        this.isRegularHourRateMissing = this.handleRequiredField(regularHourRateId)
        this.isTotalNumberPayHoursMissing = this.handleRequiredField(totalNumberPayId)
        this.isTotalAmountPaidMissing = this.handleRequiredField(totalAmountPayId)


        this.isStartDateMissing === true ? startDateId.focus() : ''
        this.isEndDateMissing === true ? endDateId.focus() : ''
        this.isRegularHourRateMissing === true ? regularHourRateId.focus() : ''
        this.isTotalNumberPayHoursMissing === true ? totalNumberPayId.focus() : ''
        this.isTotalAmountPaidMissing === true ? totalAmountPayId.focus() : ''

        
        if(this.isNameValid === true || this.isStartDateMissing === true || this.isEndDateMissing === true || this.isRegularHourRateMissing === true || this.isTotalNumberPayHoursMissing === true || this.isTotalAmountPaidMissing === true){
            this.handleWageDefValidityEvent();
        }
    }

    @api
    handleOverTimeParentInfo(){
        const selectEvent = new CustomEvent('overtimecustominfoevent', {
            detail:{
                restClaimInfoObj : this.restClaimInfoObj() ,
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
            violationTypeVariablesForOneSalaryRate : this.violationTypeVariablesForOneSalaryRate,
            iwcinfoobj : this.iwcinfoobj
        }
    }

    @api
    handleOverTimeChildData(strString, isFormPreviewMode){
        console.log('reportingTime details in child :::: ', JSON.stringify(strString));
        this.violationTypeVariablesForOneHourlyRate = strString.violationTypeVariablesForOneHourlyRate,
        this.isOneHourlyRatePOW = strString.isOneHourlyRatePOW,
        this.isSalaryRatePOW = strString.isSalaryRatePOW,
        this.violationTypeVariablesForOneSalaryRate = strString.violationTypeVariablesForOneSalaryRate
        this.iwcinfoobj = this.iwcinfoobj === undefined ? strString.iwcinfoobj : this.iwcinfoobj
    }

    renderedCallback(){
        if(this.paymentOfWagesDetails !== undefined && this.isShowServerResponse === true){
            this.handleHourlyRateOption();
            this.isShowServerResponse = false;
        }
    }
          /* This method is used to check all types of validation on the date fields. */
    handlePOWDateValidity(startDateId, endDateId, startDate, endDate){
            var startDateId = startDateId
            var endDateId = endDateId
            var startDate = startDate
            var endDate = endDate
            var today = new Date();
    
            startDate !== '' && startDate !== null && startDate !== undefined ? startDate = new Date(startDate.toString()) : ''
            endDate !== '' && endDate !== null && startDate !== undefined ? endDate = new Date(endDate.toString()) : ''

            if(startDate === '' && endDate === ''){
                startDateId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
                endDateId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
                startDateId.reportValidity();
                endDateId.reportValidity();
                return true;
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
    

    handleRequiredField(FieldId){
        var FieldId = FieldId
        if(FieldId.value == null || FieldId.value == undefined || FieldId.value.trim() == ''){
            FieldId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            FieldId.reportValidity();
            return true;
        }
        else{
            FieldId.setCustomValidity('');
            FieldId.reportValidity();
            return false
        }
    }

}