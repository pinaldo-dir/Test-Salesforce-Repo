import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
export default class OwcNotPaidSickLeaveChild extends LightningElement {
    // Attributes
    @api sectionid;
    @api additionalName;
    @api isFormPreviewMode = false;
    @api isNotPaid = false;
    @api isNotAllowedSickLeave = false;
    @api isAllowedSickLeave = false
    @api sickLeaveClaim;
    @api POWDetails;
    @api paystubsickrecord;
    @api isSL20Trigger = false;
    @api sickLeaveDate;
    @api isAllowedMissingBegEndDate = false
    @api isAllowedMissingSickLeaveHours = false
    @api isNotAllowedMissingBegEndDate = false
    @api isNotAllowedMissingSickLeaveHours = false
    @api isMissingSickLeaveSelection = false



    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({data,error}){
        if(data){
            this.options = data[0].owcSickLeaveOptions;
        }else{
            this.errorMsg = error;
        }
    }

    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    // Import custom labels
    customLabelValues = customLabelValues
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

    async handleSL20Trigger(){
        try{
            await this.getViolationTypeVariableForSL20('314');
        }catch (error){
            console.log('error', error);
        }
    }

    @api violationTypeVariableForSL20;
    getViolationTypeVariableForSL20(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                this.violationTypeVariableForSL20 = result;
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api options;

    @api
    handlePOWDetails(POWDetails, isFormPreviewMode){
        console.log('Payment detail in child ::: ', JSON.stringify(POWDetails));
        this.POWDetails = POWDetails;
        this.isFormPreviewMode = isFormPreviewMode;
    }

    @api
    handleSickLeaveSectionData(){
        const selectEvent = new CustomEvent('overtimesectiondeleteevent', {
            detail: this.sickLeaveInfoObj()},
        );
        this.dispatchEvent(selectEvent);
    }

    // This method is used to take the input values from the end user.c/hideSpinnerCmp
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            case "sickLeaveDate":
                this.sickLeaveDate = event.target.value;
                break;
            case "sickLeaveClaim":
                this.sickLeaveClaim = event.target.value;
                this.isMissingSickLeaveSelection = true;
                if(this.sickLeaveClaim === this.options[1].value){
                    this.handleFirstOption();
                    this.violationTypeVariablesForOneHourlyAllow = undefined;
                    this.isOneHourlyAllow = false;
                    this.isAllowedSickLeave = true;
                    this.isNotAllowedSickLeave = false
                    this.isMissingSickLeaveSelection = false
                }
                else if(this.sickLeaveClaim === this.options[2].value){
                    this.violationTypeVariablesForOneHourly = undefined;
                    this.isOneHourly = false;
                    this.handleSecondOption();
                    this.isNotAllowedSickLeave = true
                    this.isAllowedSickLeave = false
                    this.isMissingSickLeaveSelection = false
                }
                else{
                    this.violationTypeVariablesForOneHourly = undefined;
                    this.isOneHourly = false;
                    this.violationTypeVariablesForOneHourlyAllow = undefined;
                    this.isOneHourlyAllow = false;
                    this.isMissingSickLeaveSelection = true
                    this.isAllowedSickLeave = false
                    this.isNotAllowedSickLeave = false
                }
                // if(this.sickLeaveClaim === this.options[0].value){
                //     this.isOneHourly = false;
                //     this.violationTypeVariablesForOneHourly = undefined;
                //     this.isDifferentHourly = false;
                //     this.violationTypeVariablesForDifferentHourly = undefined;
                //     this.isOneHourlyAllow = false;
                //     this.violationTypeVariablesForOneHourlyAllow = undefined;
                //     this.isDifferentHourlyAllow = false;
                //     this.violationTypeVariablesForDifferentHourlyAllow = undefined;
                //     this.isNotPaid = false;
                //     this.isNotAllowedSickLeave = false;
                // }
                // else if(this.sickLeaveClaim === this.options[1].value){
                //     this.isNotPaid = true;
                //     this.isNotAllowedSickLeave = false;
                // }
                // else if(this.sickLeaveClaim === this.options[2].value){
                //     this.isNotPaid = false;
                //     this.isNotAllowedSickLeave = true;
                // }
                // else{
                //     this.isNotPaid = false;
                //     this.isNotAllowedSickLeave = false;
                // }
                // this.handleServerCall();
                break;
        }
        if(this.violationTypeVariablesForOneHourly !== undefined && this.sickLeaveClaim === this.options[1].value){
            let allowedstartendDateId = this.template.querySelector('[data-id="VTV0087"]');
            let allowedhowmanyleavehours = this.template.querySelector('[data-id="VTV0085"]');
            for(var i=0; i<this.violationTypeVariablesForOneHourly.length; i++){
                this.violationTypeVariablesForOneHourly[i].name === event.target.name ? this.violationTypeVariablesForOneHourly[i].value = event.target.value : ''
            }
            this.isAllowedMissingBegEndDate = this.handleRequiredField(allowedstartendDateId)
            this.isAllowedMissingSickLeaveHours = this.handleRequiredField(allowedhowmanyleavehours)

        }
        if(this.violationTypeVariablesForDifferentHourly !== undefined){
            for(var i=0; i<this.violationTypeVariablesForDifferentHourly.length; i++){
                this.violationTypeVariablesForDifferentHourly[i].name === event.target.name ? this.violationTypeVariablesForDifferentHourly[i].value = event.target.value : ''
            }
        }
        if(this.violationTypeVariablesForOneHourlyAllow !== undefined && this.sickLeaveClaim === this.options[2].value){
            let notallowedstartendDateId = this.template.querySelector('[data-id="VTV2113"]');
            let notallowedhowmanyleavehours = this.template.querySelector('[data-id="VTV2111"]');
            for(var i=0; i<this.violationTypeVariablesForOneHourlyAllow.length; i++){
                this.violationTypeVariablesForOneHourlyAllow[i].name === event.target.name ? this.violationTypeVariablesForOneHourlyAllow[i].value = event.target.value : ''
            }
            this.isNotAllowedMissingSickLeaveHours = this.handleRequiredField(notallowedhowmanyleavehours)
            this.isNotAllowedMissingBegEndDate = this.handleRequiredField(notallowedstartendDateId)


            
        }
        if(this.violationTypeVariablesForDifferentHourlyAllow !== undefined){
            for(var i=0; i<this.violationTypeVariablesForDifferentHourlyAllow.length; i++){
                this.violationTypeVariablesForDifferentHourlyAllow[i].name === event.target.name ? this.violationTypeVariablesForDifferentHourlyAllow[i].value = event.target.value : ''
            }
        }
    }

    @api isOneHourly = false;
    @api violationTypeVariablesForOneHourly;
    @api isDifferentHourly = false;
    @api violationTypeVariablesForDifferentHourly;
    @api isOneHourlyAllow = false;
    @api violationTypeVariablesForOneHourlyAllow;
    @api isDifferentHourlyAllow = false;
    @api violationTypeVariablesForDifferentHourlyAllow;
    @api iswagedefpreview;

    async handleFirstOption(){
        try{
            await this.getAllVilationTypeVariableForOneHourly('311');
        }catch (error){
            console.log('error', error);
        }
    }

    async handleSecondOption(){
        try{
            await this.getAllVilationTypeVariableForOneHourlyAllow('321');
        }catch (error){
            console.log('error', error);
        }
    }
    async handleServerCall(){
        if(this.isNotPaid === true && this.POWDetails.HourlyOptionValue === true){
            try{
                await this.getAllVilationTypeVariableForOneHourly('311');
            }catch (error){
                console.log('error', error);
            }
        }
        else{
            this.isOneHourly = false;
            this.violationTypeVariablesForOneHourly = undefined;
        }
        if(this.isNotPaid === true && this.POWDetails.differentHourOptionValue === true){
            try{
                await this.getAllVilationTypeVariableForDifferentHourly('312');
            }catch (error){
                console.log('error', error);
            }
        }
        else{
            this.isDifferentHourly = false;
            this.violationTypeVariablesForDifferentHourly = undefined;
        }
        if(this.isNotAllowedSickLeave === true && this.POWDetails.HourlyOptionValue === true){
            try{
                await this.getAllVilationTypeVariableForOneHourlyAllow('321');
            }catch (error){
                console.log('error', error);
            }
        }
        else{
            this.isOneHourlyAllow = false;
            this.violationTypeVariablesForOneHourlyAllow = undefined;
        }
        if(this.isNotAllowedSickLeave === true && this.POWDetails.differentHourOptionValue === true){
            try{
                await this.getAllVilationTypeVariableForDifferentHourlyAllow('322');
            }catch (error){
                console.log('error', error);
            }
        }
        else{
            this.isDifferentHourlyAllow = false;
            this.violationTypeVariablesForDifferentHourlyAllow = undefined;
        }
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
                    else if(result[i].dataType === 'Decimal' || result[i].dataType === 'Integer'){
                        result[i].numberFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
                    result[i].name === 'VTV0087' ? result[i].helpText = true : result[i].helpText = false;
                    result[i].name === 'VTV0087' || result[i].name === 'VTV0085' ? this.isAllowedSickLeave = true : '';
                    result[i].dataType === 'Currency' ? result[i].value = 0 : result[i].value = '';

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

    getAllVilationTypeVariableForDifferentHourly(queryCode){
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
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForDifferentHourly !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForDifferentHourly = result;
                    this.violationTypeVariablesForDifferentHourly.length > 0 ? this.isDifferentHourly = true : this.isDifferentHourly = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    getAllVilationTypeVariableForOneHourlyAllow(queryCode){
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
                    result[i].name === 'VTV2113' ? result[i].helpText = true : result[i].helpText = false
                    result[i].name === 'VTV2113' || result[i].name === 'VTV2111' ? this.isNotAllowedSickLeave = true : ''
                    result[i].dataType === 'Currency' ? result[i].value = 0 : result[i].value = '';

                }
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForOneHourlyAllow !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForOneHourlyAllow = result;
                    this.violationTypeVariablesForOneHourlyAllow.length > 0 ? this.isOneHourlyAllow = true : this.isOneHourlyAllow = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    getAllVilationTypeVariableForDifferentHourlyAllow(queryCode){
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
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForDifferentHourlyAllow !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForDifferentHourlyAllow = result;
                    this.violationTypeVariablesForDifferentHourlyAllow.length > 0 ? this.isDifferentHourlyAllow = true : this.isDifferentHourlyAllow = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }



    handleRequiredField(FieldId){
        if( FieldId.value === undefined || FieldId.value === null || FieldId.value.trim() === '' ||  FieldId.value.trim() === '$0.00') {
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
        let allowedstartendDateId = this.template.querySelector('[data-id="VTV0087"]');
        let allowedhowmanyleavehours = this.template.querySelector('[data-id="VTV0085"]');
        let notallowedstartendDateId = this.template.querySelector('[data-id="VTV2113"]');
        let notallowedhowmanyleavehours = this.template.querySelector('[data-id="VTV2111"]');
        let nosickleaveSelected = this.template.querySelector('[data-id="sickLeaveClaim"]')


        if(this.isAllowedSickLeave === true || this.sickLeaveClaim === this.options[1].value){
            this.isAllowedMissingBegEndDate = this.handleRequiredField(allowedstartendDateId)
            this.isAllowedMissingSickLeaveHours =this.handleRequiredField(allowedhowmanyleavehours)
            this.isMissingSickLeaveSelection = false
        }
        else if(this.isNotAllowedSickLeave === true || this.sickLeaveClaim === this.options[2].value){
            this.isNotAllowedMissingBegEndDate = this.handleRequiredField(notallowedstartendDateId)
            this.isNotAllowedMissingSickLeaveHours = this.handleRequiredField(notallowedhowmanyleavehours)
            this.isMissingSickLeaveSelection = false
        }
        else if(this.sickLeaveClaim === this.options[0].valued){
            this.isMissingSickLeaveSelection = this.handleRequiredField(nosickleaveSelected)

        }



        if(this.isNameValid === true || this.isMissingSickLeaveSelection === true || this.isAllowedMissingBegEndDate === true || this.isAllowedMissingSickLeaveHours === true || this.isNotAllowedMissingBegEndDate === true || this.isNotAllowedMissingSickLeaveHours === true){
            this.handleWageDefValidityEvent();
        }
    }

    @api
    handleOverTimeParentInfo(){
        const selectEvent = new CustomEvent('overtimecustominfoevent', {
            detail: {
                sickLeaveInfoObj : this.sickLeaveInfoObj() ,
                vtCaseIssueObj : this.vtCaseIssueObj()
            }
        });
        this.dispatchEvent(selectEvent);
    }

    @api 
    vtCaseIssueObj(){
        return {
            violationTypeVariablesForOneHourly : this.violationTypeVariablesForOneHourly,
            // violationTypeVariablesForDifferentHourly : this.violationTypeVariablesForDifferentHourly,
            violationTypeVariablesForOneHourlyAllow : this.violationTypeVariablesForOneHourlyAllow,
            // violationTypeVariablesForDifferentHourlyAllow : this.violationTypeVariablesForDifferentHourlyAllow,
            violationTypeVariableForSL20 : this.violationTypeVariableForSL20
        }
    }

    @api
    sickLeaveInfoObj(){
        return {
            sectionId : this.sectionid,
            isNotPaid : this.isNotPaid,
            isNotAllowedSickLeave : this.isNotAllowedSickLeave,
            sickLeaveClaim : this.sickLeaveClaim,
            isOneHourly : this.isOneHourly,
            violationTypeVariablesForOneHourly : this.violationTypeVariablesForOneHourly,
            isDifferentHourly : this.isDifferentHourly,
            violationTypeVariablesForDifferentHourly : this.violationTypeVariablesForDifferentHourly,
            isOneHourlyAllow : this.isOneHourlyAllow,
            violationTypeVariablesForOneHourlyAllow : this.violationTypeVariablesForOneHourlyAllow,
            isDifferentHourlyAllow : this.isDifferentHourlyAllow,
            violationTypeVariablesForDifferentHourlyAllow : this.violationTypeVariablesForDifferentHourlyAllow,
            paystubsickrecord : this.paystubsickrecord,
            violationTypeVariableForSL20 : this.violationTypeVariableForSL20,
            sickLeaveDate : this.sickLeaveDate,

        }
    }

    @api
    handleOverTimeChildData(strString, isFormPreviewMode){
        console.log('strString in overtime sub child ::: ', JSON.stringify(strString));
        this.isNotPaid = strString.isNotPaid;
        this.paystubsickrecord = strString.paystubsickrecord
        this.isNotAllowedSickLeave = strString.isNotAllowedSickLeave;
        this.sickLeaveClaim = strString.sickLeaveClaim
        this.isOneHourly = strString.isOneHourly;
        this.violationTypeVariablesForOneHourly = strString.violationTypeVariablesForOneHourly
        this.isDifferentHourly = strString.isDifferentHourly;
        this.violationTypeVariablesForDifferentHourly = strString.violationTypeVariablesForDifferentHourly
        this.isOneHourlyAllow = strString.isOneHourlyAllow;
        this.violationTypeVariablesForOneHourlyAllow = strString.violationTypeVariablesForOneHourlyAllow
        this.isDifferentHourlyAllow = strString.isDifferentHourlyAllow;
        this.violationTypeVariablesForDifferentHourlyAllow = strString.violationTypeVariablesForDifferentHourlyAllow
        this.violationTypeVariableForSL20 = strString.violationTypeVariableForSL20,
        this.sickLeaveDate = strString.sickLeaveDate
     
    }

    @api isHelpText= false;
    @api helpText;
    // Help text 
    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === "oneHourlyHelpMsg"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_sick_leave_help_msg;
        }
    }
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    renderedCallback(){

    }
}