import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
export default class OwcInsufficientFundClaimChild extends LightningElement {
    // Attributes
    @api sectionid;
    @api additionalName;
    @api isFormPreviewMode = false;
    @api paidbycheck;

    // Import custom label values
    customLabelValues = customLabelValues;
    @api iswagedefpreview;

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
        console.log('preview in suff child ::: ', this.iswagedefpreview)
        // this.chequereplaced === undefined || this.chequereplaced === 'No' ? this.createNS11() : ''
        this.collectVtVariables();
    }


    async collectVtVariables(){
        try{
            await this.getAllVilationTypeVariablesForInsufficientFund('NS101');
        }catch (error){
            console.log('error', error);
        }
    }

    async createNS11(){
        try{
            await this.getAllVilationTypeVariablesForInsufficientFund11('NS11');
        }catch (error){
            console.log('error', error);
        }
    }

    async createNS12(){
        try{
            await this.getAllVilationTypeVariablesForInsufficientFund12('NS12');
        }catch (error){
            console.log('error', error);
        }
    }

    @api violationTypeVariablesForInsufficientFunds;
    @api isOneHourlyRatePOW = false;
    getAllVilationTypeVariablesForInsufficientFund(queryCode){
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
                    result[i].name === 'VTV1019' ? result[i].isShowVt19 = true : result[i].isShowVt19 = false;
                    result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
                    result[i].value = '';
                }
                // Check the datatype of the input fields
                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForInsufficientFunds !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForInsufficientFunds = result;
                    this.violationTypeVariablesForInsufficientFunds.length > 0 ? this.isOneHourlyRatePOW = true : this.isOneHourlyRatePOW = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api violationTypeVariableForNS11;
    // @api isOneHourlyRatePOW = false;
    getAllVilationTypeVariablesForInsufficientFund11(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    
                    result[i].value = '';
                }
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariableForNS11 !== undefined){

                 }
                 else{
                    this.violationTypeVariableForNS11 = result;
                    // this.violationTypeVariableForNS11.length > 0 ? this.isOneHourlyRatePOW = true : this.isOneHourlyRatePOW = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api violationTypeVariableForNS12;
    // @api isOneHourlyRatePOW = false;
    getAllVilationTypeVariablesForInsufficientFund12(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    
                    result[i].value = '';
                }
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariableForNS12 !== undefined){

                 }
                 else{
                    this.violationTypeVariableForNS12 = result;
                    // this.violationTypeVariableForNS12.length > 0
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api
    handleFundClaimSectionData(){
        const selectEvent = new CustomEvent('overtimesectiondeleteevent', {
            detail: this.restClaimInfoObj()},
        );
        this.dispatchEvent(selectEvent);
    }

    @api beggingDate;
    @api endingDate;
    @api nonNegotiablecheckDate;
    @api noDays;
    // This method is used to take the input values from the end user.c/hideSpinnerCmp
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            case "additionalName":
                this.additionalName = event.target.value;
                
                break;
            case "nonNegotiablecheckDate":
                this.nonNegotiablecheckDate = event.target.value;
                break;
        }
        if(this.violationTypeVariablesForInsufficientFunds !== undefined){
            for(var i=0; i<this.violationTypeVariablesForInsufficientFunds.length; i++){
                this.violationTypeVariablesForInsufficientFunds[i].name === event.target.name ? this.violationTypeVariablesForInsufficientFunds[i].value = event.target.value : ''
                // if(event.target.name === 'VTV1021'){
                //     this.beggingDate = event.target.value;
                // } 
                // if(event.target.name === 'VTV1020'){
                //     this.endingDate = event.target.value;
                // }
                
                // if(this.beggingDate !== null && this.beggingDate !== undefined && this.endingDate !== null && this.endingDate !== undefined){
                //     this.noDays = this.getNumberOfDays(this.beggingDate, this.endingDate);
                //     console.log('Days ::: ', noDays);
                //     // else if(noDays === 0 || noDays === undefined || noDays === null){
                //     //     // this.violationTypeVariablesForInsufficientFunds = undefined;
                //     //     this.violationTypeVariableForNS11 = undefined;
                //     //     this.createNS12();
                //     // }
                // }
                // if((this.noDays > -30) || (this.chequereplaced === undefined || this.chequereplaced === 'No')){
                //     this.violationTypeVariableForNS12 = undefined;
                //     // this.violationTypeVariablesForInsufficientFunds = undefined;
                //     this.createNS11();
                // }
                // else{
                //     this.violationTypeVariableForNS11 = undefined;
                //     this.violationTypeVariableForNS12 = undefined;
                // }
            }
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
        
        if(this.isNameValid === true){
            this.handleWageDefValidityEvent();
        }
    }

    @api
    handleOverTimeParentInfo(){
        const selectEvent = new CustomEvent('overtimecustominfoevent', {
            detail : {
                restClaimInfoObj : this.restClaimInfoObj() ,
                vtCaseIssueObj : this.vtCaseIssueObj()
            }
        });
        this.dispatchEvent(selectEvent);
    }

    handleAssignValues(){
        for(var i=0; i<this.violationTypeVariablesForInsufficientFunds.length; i++){
            if(this.violationTypeVariableForNS11 !== undefined){
                if(this.violationTypeVariablesForInsufficientFunds[i].name === 'VTV1020'){
                    var index = this.violationTypeVariableForNS11.findIndex(item => item.name === 'VTV1210');
                    this.violationTypeVariableForNS11[index].value = this.violationTypeVariablesForInsufficientFunds[i].value;
                }
                else if(this.violationTypeVariablesForInsufficientFunds[i].name === 'VTV1019'){
                    var index = this.violationTypeVariableForNS11.findIndex(item => item.name === 'VTV1209');
                    this.violationTypeVariableForNS11[index].value = this.violationTypeVariablesForInsufficientFunds[i].value;
                }
                else if(this.violationTypeVariablesForInsufficientFunds[i].name === 'VTV1023'){
                    var index = this.violationTypeVariableForNS11.findIndex(item => item.name === 'VTV1211');
                    this.violationTypeVariableForNS11[index].value = this.violationTypeVariablesForInsufficientFunds[i].value;
                }
                else if(this.violationTypeVariablesForInsufficientFunds[i].name === 'VTV1024'){
                    var index = this.violationTypeVariableForNS11.findIndex(item => item.name === 'VTV1212');
                    this.violationTypeVariableForNS11[index].value = this.violationTypeVariablesForInsufficientFunds[i].value;
                }
                else if(this.violationTypeVariablesForInsufficientFunds[i].name === 'VTV1025'){
                    var index = this.violationTypeVariableForNS11.findIndex(item => item.name === 'VTV1214');
                    this.violationTypeVariableForNS11[index].value = this.violationTypeVariablesForInsufficientFunds[i].value;
                }
                else if(this.violationTypeVariablesForInsufficientFunds[i].name === 'VTV1022'){
                    var index = this.violationTypeVariableForNS11.findIndex(item => item.name === 'VTV1213');
                    this.violationTypeVariableForNS11[index].value = this.violationTypeVariablesForInsufficientFunds[i].value;
                }
            }
        }
        
    }
    @api 
    vtCaseIssueObj(){
        // if(this.violationTypeVariableForNS11 !== undefined && (this.chequereplaced === undefined || this.chequereplaced === 'No')){
        //     this.handleAssignValues();
        //     this.violationTypeVariablesForInsufficientFunds = undefined;
        // }
        // if(this.violationTypeVariableForNS12 !== undefined){
        //     this.violationTypeVariablesForInsufficientFunds = undefined;
        // }
        return{
            violationTypeVariablesForInsufficientFunds : this.violationTypeVariablesForInsufficientFunds,
            // violationTypeVariableForNS11 : this.violationTypeVariableForNS11,
            // violationTypeVariableForNS12 : this.violationTypeVariableForNS12
        }
    }

    @api
    restClaimInfoObj(){
        return {
            sectionId : this.sectionid,
            violationTypeVariablesForInsufficientFunds : this.violationTypeVariablesForInsufficientFunds,
            // violationTypeVariableForNS11 : this.violationTypeVariableForNS11,
            // violationTypeVariableForNS12 : this.violationTypeVariableForNS12,
            nonNegotiablecheckDate : this.nonNegotiablecheckDate,
            isOneHourlyRatePOW : this.isOneHourlyRatePOW,
            // chequereplaced : this.chequereplaced
        }
    }

    @api
    handleOverTimeChildData(strString, isFormPreviewMode){
        console.log('strString in overtime sub child ::: ', JSON.stringify(strString));
        this.violationTypeVariablesForInsufficientFunds = strString.violationTypeVariablesForInsufficientFunds
        // this.violationTypeVariableForNS11 = strString.violationTypeVariableForNS11
        // this.violationTypeVariableForNS12 = strString.violationTypeVariableForNS12
        this.isOneHourlyRatePOW = strString.isOneHourlyRatePOW
        this.nonNegotiablecheckDate = strString.nonNegotiablecheckDate
        // this.chequereplaced = strString.chequereplaced
    }

    renderedCallback(){

    }
}