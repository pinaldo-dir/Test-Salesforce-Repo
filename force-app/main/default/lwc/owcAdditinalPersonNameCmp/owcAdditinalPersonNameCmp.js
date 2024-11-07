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
    @api isadditionalpreview
    @api isMoreThanOneCalendar = false;
    @api isRenderedCallback = false;
    @api msg;

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
        console.log('isadditionalpreview in add preview ::: ', this.isadditionalpreview)
        // this.handleHourlyRateOption();
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
    @api claimantRelatedRoleActions;
    @api additinalPersonLastName;
    @api mileageLog;
    // This method is used to take the input values from the end user.c/hideSpinnerCmp
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            case "claimantRelatedRoleActions":
               this.claimantRelatedRoleActions = event.target.value;
               console.log('claimantRelatedRoleActions ::: ', this.claimantRelatedRoleActions);
               break;
            case "additinalPersonFirstName":
               this.additinalPersonFirstName = event.target.value;
               console.log('additinalPersonFirstName ::: ', this.additinalPersonFirstName);
               break;
            case "additinalPersonLastName":
                this.additinalPersonLastName = event.target.value;
                console.log('additinalPersonLastName ::: ', this.additinalPersonLastName)
                break;
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

    isNameValid = false
    // This method is used to collect the parent component data.
    @api
    handleOverTimeParentData(){
        // Validity check fotr this section
        // const beggingDateId = `[data-id="${this.beggingDateId}"]`;
        // this.isMoreThanOneCalendar === true ? this.template.querySelector(String(beggingDateId)).focus() : ''
        this.isMoreThanOneCalendar === true ? this.handleWageDefValidityEvent() : this.handleOverTimeParentInfo();
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
            additinalPersonLastName : this.additinalPersonLastName,
            additinalPersonFirstName : this.additinalPersonFirstName,
            claimantRelatedRoleActions : this.claimantRelatedRoleActions
        }
    }

    @api addittinalEmplyerDetails;
    @api
    handleOverTimeChildData(strString, isFormPreviewMode){
        console.log('isFormPreviewMode in add ::: ', isFormPreviewMode);
        this.addittinalEmplyerDetails = strString;
        this.isFormPreviewMode = isFormPreviewMode
        this.additinalPersonLastName = strString.additinalPersonLastName
        this.additinalPersonFirstName = strString.additinalPersonFirstName
        this.claimantRelatedRoleActions = strString.claimantRelatedRoleActions
        this.isRenderedCallback = true;
    }

    renderedCallback(){
    }
}