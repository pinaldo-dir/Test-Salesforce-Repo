import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import searchAccounts from '@salesforce/apex/CashCustomLookupController.searchAccounts';
import cmIconLightning from '@salesforce/resourceUrl/cmIconLightning';
import CASE_PAYMENT__C from '@salesforce/schema/Case_Payment__c';
import queryCase from '@salesforce/apex/CashDmlMethods.queryCase';
import queryLiableParties from '@salesforce/apex/CashDmlMethods.queryLiableParties';
import queryPPs from '@salesforce/apex/CashDmlMethods.queryPPs';
import queryCIs from '@salesforce/apex/CashDmlMethods.queryCIs';
import createCaseIssueWrapperList from '@salesforce/apex/CashCaseIssueWrapper.createCaseIssueWrapperList';
import queryJudgments from '@salesforce/apex/CashDmlMethods.queryJudgments';
import createJudgmentWrapperList from '@salesforce/apex/CashJudgmentWrapper.createJudgmentWrapperList';
import saveAllocations from '@salesforce/apex/CashSaveAllocations.saveAllocations';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import USER_ID from '@salesforce/user/Id';

export default class CashPartyToPartyPayments extends NavigationMixin(LightningElement) {
    
    currentPageReference;
    @wire(CurrentPageReference) setCurrentPageReference(currentPageReference){
        this.currentPageReference = currentPageReference;
    }

    connectedCallback(){
        document.title = "Party to Party Payment";
    }

    cmIcon = cmIconLightning;

    get caseId() {
        return (!this.currentPageReference) ? null : this.currentPageReference.state.c__caseId;
    }
    
    allLpArray = [];
    allJpArray = [];

    
    @track amountRemainingToAllocate = '';
    allocationCurrentDisplayValues = new Map(); //Holds whatever allocation amounts are on screen at any given time. Used to calculate Amount Remaining to Allocate.
                                                // Key = caseIssueId:inputFieldName, Value = negative of amount input
    @track debounce = false;
    get buttonsDisabled(){  // Post Payment button should only be enabled if amountRemainingToAllocateIsZero and all required fields are satisfied AND the Post Payment button
                            //  has not been clicked (i.e., debounce = true) TODO: verify/port similar validation setup in CPA
        return !(this.paymentAmountEntered && this.dateReceivedEntered && this.payorEntered && this.poboEntered && this.amountRemainingToAllocateIsZero && this.userProfileName != 'BOFE User') || this.debounce;
    }
    @track inputFieldsDisabled = true; //User shouldn't be able to input or change any data if POBO === 'ALL'.
    @track backToCaseButtonDisabled = false;
    
    cpRecordTypeName = '';
    cpRecordTypeId = '';
    casePaymentRecordTypeValues;
    
    @wire(getObjectInfo, { objectApiName: CASE_PAYMENT__C })
    cpObjectInfo({data, error}) {
        if(data) {
            this.casePaymentRecordTypeValues = Object.values(data.recordTypeInfos);
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashPartyToPartyPayments.js.cpObjectInfo: ' + JSON.stringify(error.body.message),
                /* message: JSON.stringify(error.body.message) + '❌Return to {0} record detail.',
                messageData: [{url: '/' + this.casePaymentId,
                               label: this.casePayment.Name}], */
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            /* window.open('mailto:mteixeira@dir.ca.gov');
            setTimeout(function(){
                window.location.replace('/' + this.casePaymentId)
            },6000
            ) */
        }
    }
    
    userProfileName;
    @wire(getRecord, {recordId: USER_ID, fields: [PROFILE_NAME_FIELD]})
    userDetails({error, data}) {
        if(data){
            this.userProfileName = data.fields.Profile.value.fields.Name.value;
        }else if(error){
        }
    }

    case;
    receipt = {
        Created_Via_PartyToPartyLWC__c: true,
        Status__c: 'New', // TODO: maybe another status would make more sense here, since the CP will be a 'Posted' status.
        Bank_Location__c: 'Not Applicable',
        Party_to_Party_Payment__c: false,
        Payor__c: '',
        Date_Received__c: '',
        Office_Unit__c: '',
        Senior_Deputy__c: '',
        Payment_Exchange__c: 'Party to Party',
        Payment_Amount__c: 0,
        Payment_Type__c: '',
        Deduction_Amount__c: 0,
        Instrument_Number__c: 'Party to Party'
    };
    casePayment = {
        Case__c: '',
        RecordTypeId: '',
        Payment_Plan__c: '',
        Deduction_Payment__c: false,
        Payment_Amount__c: 0,
        Certified_Mail_Tracking_Numbers__c: '',
        Status__c: 'Posted'
    };
    
    @track caseName = '';
    @track caseNumber = '';
    @track caseAssignedDeputyName = '';
    @track caseAssignedDeputyUrl = '';

    @wire(queryCase, {caseId: '$caseId'}) getCase({error, data}){

        if(data){
            this.case = data;
            this.caseName = data.Name;
            this.caseNumber = data.Case_Number__c;
            this.caseAssignedDeputyName = data.Assigned_Deputy__r.Name;
            this.caseAssignedDeputyUrl = '/' + data.Assigned_Deputy__c;
            
            this.receipt.Created_Via_PartyToPartyLWC__c = true; //TODO: new field, combine with data from Created_Via_PartyPaymentVFP__c?
            if(data.Office__r.Office_Number__c === 'WCA 633'){
                this.receipt.Office_Unit__c = 'WCA 6';    
            }else{
                this.receipt.Office_Unit__c = data.Office__r.Office_Number__c;
            }
            this.receipt.Senior_Deputy__c = data.Assigned_Deputy__r.Manager__c;            
            
            this.casePayment.Case__c = data.Id;
            
            if(this.casePaymentRecordTypeValues){                
                
                if(this.case.RecordType.Name.includes('BOFE') || this.case.RecordType.Name.includes('PASS')){
                    this.casePayment.RecordTypeId = this.casePaymentRecordTypeValues.find(cpRtValue => cpRtValue.name === 'BOFE').recordTypeId;
                }else if(this.case.RecordType.Name.includes('WCA') || this.case.RecordType.Name.includes('Garment')){
                    this.casePayment.RecordTypeId = this.casePaymentRecordTypeValues.find(cpRtValue => cpRtValue.name === 'WCA').recordTypeId;
                }else if(this.case.RecordType.Name.includes('PAGA')){
                    this.casePayment.RecordTypeId = this.casePaymentRecordTypeValues.find(cpRtValue => cpRtValue.name === 'PAGA').recordTypeId;
                }else if(this.case.RecordType.Name.includes('RCI')){
                    this.casePayment.RecordTypeId = this.casePaymentRecordTypeValues.find(cpRtValue => cpRtValue.name === 'RCI').recordTypeId;
                }else if(this.case.RecordType.Name.includes('Registration')){
                    this.casePayment.RecordTypeId = this.casePaymentRecordTypeValues.find(cpRtValue => cpRtValue.name === 'Registration').recordTypeId;
                }
            }
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashPartyToPartyPayments.js.getCase: ' + JSON.stringify(error.body.message),
                /* message: JSON.stringify(error.body.message) + '❌Return to {0} record detail.',
                messageData: [{url: '/' + this.casePaymentId,
                               label: this.casePayment.Name}], */
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            /* window.open('mailto:mteixeira@dir.ca.gov');
            setTimeout(function(){
                window.location.replace('/' + this.casePaymentId)
            },6000
            ) */
        }
    }

    @track selectedPaymentExchange = 'PARTY TO PARTY';
    @track paymentExchangeOptions = [
        {label: 'Party to Party Payment', value: 'PARTY TO PARTY'},
        {label: 'Deduction Payment', value: 'DEDUCTION'}
    ];
    handlePaymentExchangeChange(event) {
        this.inputFieldsDisabled = false;
        this.selectedPaymentExchange = event.target.value;
        if(event.target.value === 'PARTY TO PARTY'){
            this.receipt.Party_to_Party_Payment__c = true;
            this.receipt.Payment_Exchange__c = 'Party to Party';
            this.receipt.Instrument_Number__c = 'Party to Party';
            // this.receipt.Payment_Amount__c = paymentAmount;
            
        }else{
            this.receipt.Payment_Type__c = 'Deduction';
            this.receipt.Payment_Exchange__c = 'Deduction'; //TODO: resolve this redundancy
            this.receipt.Instrument_Number__c = 'Deduction';
            this.casePayment.Deduction_Payment__c = true;
            // this.receipt.Deduction_Amount__c = paymentAmount;
            // rct.Payment_Amount__c = 0.00;
        }
    }

    
    /**
     * Handles the lookup selection change
     * @param {event} event `selectionchange` event emmitted by the lookup.
     * The event contains the list of selected ids.
     */
    // eslint-disable-next-line no-unused-vars
    @track selectedPayor = [];
    @track payorEntered = false;
    handleAccountLookupSelectionChange(event) {
        if(event.detail[0]){
            /* console.log('153 event.detail: ', event.detail);
            console.log('154 event.detail[0]: ', event.detail[0]); */
            /* this.checkForErrors(); */
            this.selectedPayor = event.detail[0];
            this.payorEntered = true;
            console.log(this.paymentAmountEntered, ' ', this.dateReceivedEntered, ' ', this.payorEntered, ' ', this.poboEntered, ' ', this.amountRemainingToAllocateIsZero)
            this.receipt.Payor__c = event.detail[0].id;
            /* console.log('204 selectedPayor: ', this.selectedPayor); */

        }else{
            this.selectedPayor = [];
            this.payorEntered = false;
            console.log(this.paymentAmountEntered, ' ', this.dateReceivedEntered, ' ', this.payorEntered, ' ', this.poboEntered, ' ', this.amountRemainingToAllocateIsZero)
            this.receipt.Payor__c = '';
            /* console.log('214 selectedPayor: ', this.selectedPayor); */
        }
    }
    /**
     * Handles the lookup search event.
     * Calls the server to perform the search and returns the resuls to the lookup.
     * @param {event} event `search` event emmitted by the lookup
     */
     handleAccountLookupSearch(event) {
        console.log('212 event.target: ', event.target);
        const lookupElement = event.target;
        console.log('214 event.detail: ', event.detail);
        // Call Apex endpoint to search for records and pass results to the lookup
        searchAccounts(event.detail)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleBlur(event){
        console.log('229 event.detail: ', event.detail);
    }

    @track certifiedMailTrackingNumbers = '';
    handleCertifiedMailTrackingNumbersChange(event){
        this.certifiedMailTrackingNumbers = event.target.value;
        this.casePayment.Certified_Mail_Tracking_Numbers__c = event.target.value;
    }

    @track allLiablePartyArray = [];
    @track allCaseRoleMap = new Map(); //Used to filter out Liable Parties that may be under the same Case Role
    @track poboOptions = [];
    @track selectedPobo = 'ALL'; //Holds Case Role ID (not Liable Party ID); or 'ALL' for showing all CIWs on page load.
    @track poboEntered = false;
    @wire(queryLiableParties, {caseId: '$caseId'}) getLiableParties({error, data}){
        let tempArray = [];
        if(data){
            this.allLiablePartyArray = data;
            data.forEach(liableParty => {
                this.allCaseRoleMap.set(liableParty.Case_Role__r.Id, liableParty.Case_Role__r);                
            });
            
            this.allCaseRoleMap.forEach(caseRole => {
                tempArray.push({value: caseRole.Id, label: caseRole.Case_Role_Account_Name__c, parent: caseRole.Entity__r.Id});
            });
            this.poboOptions = tempArray;
            this.filterPPs();

            if(this.allCiArray.length > 0 && this.allLiablePartyArray.length > 0) {
                this.createCIWs();
            }
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashPartyToPartyPayments.js.getLiableParties: ' + JSON.stringify(error.body.message),
                /* message: JSON.stringify(error.body.message) + '❌Return to {0} record detail.',
                messageData: [{url: '/' + this.casePaymentId,
                               label: this.casePayment.Name}], */
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            /* window.open('mailto:mteixeira@dir.ca.gov');
            setTimeout(function(){
                window.location.replace('/' + this.casePaymentId)
            },6000
            ) */
        }
    }
    

    @track allPpArray = [];
    @track ppSelection = 'NONE'; //Holds Payment Plan Id.
    @track ppOptions = [];
    @track ppBalanceDue = 0;
    @wire(queryPPs, {caseId: '$caseId'}) getPPs({error, data}){
        if(data){
            this.allPpArray = data;
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashPartyToPartyPayments.js.getPPs: ' + JSON.stringify(error.body.message),
                /* message: JSON.stringify(error.body.message) + '❌Return to {0} record detail.',
                messageData: [{url: '/' + this.casePaymentId,
                               label: this.casePayment.Name}], */
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            /* window.open('mailto:mteixeira@dir.ca.gov');
            setTimeout(function(){
                window.location.replace('/' + this.casePaymentId)
            },6000
            ) */

        }

        this.filterPPs();
    }

    filterPPs(){
        if(this.poboOptions.length !== 0){
            let tempArray = [];
            tempArray.push({label: 'None', value: 'NONE', balance: 0});
            if(this.selectedPobo !== 'ALL'){
                
                let index = this.poboOptions.findIndex(element => {
                    return element.value === this.selectedPobo;
                });
                
                this.allPpArray.forEach(pp => {
                    if(pp.Responsible_Party__c === this.poboOptions[index].parent){
                        tempArray.push({label: pp.Name, value: pp.Id, balance: pp.Payment_Plan_Balance__c})
                    }
                });
            }
            this.ppOptions = tempArray;
            this.ppSelection = 'NONE';
            this.ppBalanceDue = 0;

        }
    }

    handlePpChange(event){
        this.ppSelection = event.target.value;

        if(this.ppSelection === 'NONE'){
            this.casePayment.Payment_Plan__c = '';
        }else{
            this.casePayment.Payment_Plan__c = this.ppSelection;
        }
        
        let index = this.ppOptions.findIndex(element => {
            return element.value === this.ppSelection
        });
        this.ppBalanceDue = this.ppOptions[index].balance;
    }


    handlePoboChange(event){
        this.selectedPobo = event.target.value;
        this.inputFieldsDisabled = false;
        this.poboEntered = true;
        console.log(this.paymentAmountEntered, ' ', this.dateReceivedEntered, ' ', this.payorEntered, ' ', this.poboEntered, ' ', this.amountRemainingToAllocateIsZero)
        
        //Clear all input values to 'reset' Amount Remaining To Allocate.
        this.allocationCurrentDisplayValues.forEach((value, key) => {
            if(key !== 'paymentAmount'){
                this.allocationCurrentDisplayValues.delete(key);
            }
        });

        //filter Liabilities and Judgments/LPs JPs CIWs JWs by POBO
        this.createCIWs();
        this.createJWs();
        this.filterPPs();
    }


    @track paymentAmount = '';
    @track paymentAmountEntered = false;

    @track amountRemainingInitialValueShown = true;
    @track amountRemainingToAllocateIsZero = false;
    updateAmountRemainingToAllocate(event){ //TODO: rename this method as it now does more than just calculating the Amount Remaining To Allocate
        if(event){
            if(event.target.name === 'paymentAmount'){
                console.log('378 event.target.value: ', event.target.value);
                if(event.target.value && event.target.value >= 0.00){
                    this.paymentAmount = parseFloat(event.target.value); //Not sure why parseFloat() is needed here, when it doesn't seem to be needed just below, nor in cashCasePaymentAllocation.js
                    this.paymentAmountEntered = true;
                    console.log(this.paymentAmountEntered, ' ', this.dateReceivedEntered, ' ', this.payorEntered, ' ', this.poboEntered, ' ', this.amountRemainingToAllocateIsZero)
                    this.allocationCurrentDisplayValues.set('paymentAmount', parseFloat(event.target.value));
                    this.amountRemainingInitialValueShown = false;
                    this.amountRemainingToAllocate = 0;
                }else{ //payment amount was deleted, or invalid input
                    event.target.value = 0;
                    //clear any existing allocations
                    this.ciwArray.forEach(ciw => {
                        ciw.penaltyAllocation = 0;
                        ciw.wageAllocation = 0;
                        ciw.wageInterestAllocation = 0;
                        ciw.interestAllocation = 0;
                    });
                    this.jwArray.forEach(jw => {
                        jw.postHearingInterestAllocation = 0;
                        jw.postJudgmentInterestAllocation = 0;
                        jw.attorneyFeesAllocation = 0;
                        jw.filingFeesAllocation = 0;
                    });
                    this.paymentAmount = '';
                    this.paymentAmountEntered = false;
                    console.log(this.paymentAmountEntered, ' ', this.dateReceivedEntered, ' ', this.payorEntered, ' ', this.poboEntered, ' ', this.amountRemainingToAllocateIsZero)
                    this.amountRemainingInitialValueShown = true;
                    this.allocationCurrentDisplayValues = new Map();
                    this.amountRemainingToAllocate = '';
                }
            }else if(event.target.name.includes('Allocation') || event.target.name.includes('Amount') || event.target.name.includes('Fee')){
                if(event.target.value >= 0.00){
                    this.allocationCurrentDisplayValues.set(event.target.dataset.id + ':' + event.target.name, -event.target.value);
                    this.amountRemainingToAllocate = 0;
                }else{
                    event.target.value = 0;
                    this.allocationCurrentDisplayValues.set(event.target.dataset.id + ':' + event.target.name, 0.00);
                    this.amountRemainingToAllocate = 0;
                }
            }
            
            //Update allocation amounts in the CIWs and JWs.
            this.ciwArray.forEach(ciw => {
                if(ciw.thisCaseIssue.Id === event.target.dataset.id){
                    if(event.target.name === 'penaltyAllocation'){
                        if(event.target.value && event.target.value >= 0.00){
                            ciw.penaltyAllocation = event.target.value;
                        }else{
                            ciw.penaltyAllocation = 0;
                        }
                    }else if(event.target.name === 'wageAllocation'){
                        if(event.target.value && event.target.value >= 0.00){
                            ciw.wageAllocation = event.target.value;
                        }else{
                            ciw.wageAllocation = 0;
                        }
                    }else if(event.target.name === 'wageInterestAllocation'){
                        if(event.target.value && event.target.value >= 0.00){
                            ciw.wageInterestAllocation = event.target.value;
                        }else{
                            ciw.wageInterestAllocation = 0;
                        }
                    }else{ //"Interest Allocation"
                        if(event.target.value && event.target.value >= 0.00){
                            ciw.interestAllocation = event.target.value;
                        }else{
                            ciw.interestAllocation = 0;
                        }
                    }
                }
            });
            
            this.jwArray.forEach(jw => {
                if(jw.thisJudgment.Id === event.target.dataset.id){
                    if(event.target.name === 'postHearingInterestAllocation'){
                        if(event.target.value && event.target.value >= 0.00){
                            jw.postHearingInterestAllocation = event.target.value;
                        }else{
                            jw.postHearingInterestAllocation = 0;
                        }
                    }else if(event.target.name === 'postJudgmentInterestAllocation'){
                        if(event.target.value && event.target.value >= 0.00){
                            jw.postJudgmentInterestAllocation = event.target.value;
                        }else{
                            jw.postJudgmentInterestAllocation = 0;
                        }
                    }else if(event.target.name === 'attorneyFeesAllocation'){
                        if(event.target.value && event.target.value >= 0.00){
                            jw.attorneyFeesAllocation = event.target.value;
                        }else{
                            jw.attorneyFeesAllocation = 0;
                        }
                    }else{ //"Filing Fees"
                        if(event.target.value && event.target.value >= 0.00){
                            jw.filingFeesAllocation = event.target.value;
                        }else{
                            jw.filingFeesAllocation = 0;
                        }
                    }
                }
            });            
            
            /* this.amountRemainingToAllocate = 0; */ /* Cf. to cashCasePaymentAllocation.js, had to move this up in the logic to handle null or invalid Payment Amount input. */
            
            this.allocationCurrentDisplayValues.forEach((value, key) => {
                this.amountRemainingToAllocate += value;
            });
            this.amountRemainingToAllocate = Math.round(this.amountRemainingToAllocate * 100) / 100;

            if(this.amountRemainingToAllocate === 0 && this.paymentAmountEntered){
                this.amountRemainingToAllocateIsZero = true;
                console.log(this.paymentAmountEntered, ' ', this.dateReceivedEntered, ' ', this.payorEntered, ' ', this.poboEntered, ' ', this.amountRemainingToAllocateIsZero)
            }else{
                this.amountRemainingToAllocateIsZero = false;
                console.log(this.paymentAmountEntered, ' ', this.dateReceivedEntered, ' ', this.payorEntered, ' ', this.poboEntered, ' ', this.amountRemainingToAllocateIsZero)
            }
        }else{ //TODO: I suspect this else clause may not ever be hit
            this.amountRemainingToAllocateIsZero = false;
            console.log(this.paymentAmountEntered, ' ', this.dateReceivedEntered, ' ', this.payorEntered, ' ', this.poboEntered, ' ', this.amountRemainingToAllocateIsZero)

            if(this.paymentAmount){
                this.amountRemainingToAllocate = this.paymentAmount;
            }else{
                this.amountRemainingToAllocate = '';
            }
        }

    }

    get backToCaseButtonLabel(){
        if(this.case){
            return "B̲ack To " + this.case.Name;
        }
    }

    handleBackToCase(event){
        window.location.replace('/' + this.caseId);
    }

    @track renderCaseIssueWrapperTable = false;
    @track allCiArray = [];
    @track ciwArray = [];
    @wire(queryCIs, {caseId: '$caseId'}) getCIs({error, data}){
        if(data){
            this.allCiArray = data;
            if(this.allCiArray.length > 0 && this.allLiablePartyArray.length > 0) {
                this.createCIWs();
            }
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashPartyToPartyPayments.js.getCIs: ' + JSON.stringify(error.body.message),
                /* message: JSON.stringify(error.body.message) + '❌Return to {0} record detail.',
                messageData: [{url: '/' + this.casePaymentId,
                               label: this.casePayment.Name}], */
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            /* window.open('mailto:mteixeira@dir.ca.gov');
            setTimeout(function(){
                window.location.replace('/' + this.casePaymentId)
            },6000
            ) */

        }
    }
    
    
    async createCIWs(){
        //// TODO: moved this POBO assignment up above inside getCP(), verify it works
        /*
        This following if{} code block is the same in createCIWs(), but is needed here in case there are no CIs. The POBO should still be same on all LPs and JPs.        
        If a CP has been recommended or posted, set POBO combobox value to the POBO (Case Role Id) of an LP, or a JP if no LPs. This assumes all LPs have the
        same POBO, which they should.
        
        if(this.casePayment.Status__c === 'Allocations Recommended' || this.casePayment.Status__c === 'Posted'){
            if(this.allLpArray.length > 0){
                this.selectedPobo = this.allLpArray[0].Payment_On_Behalf_Of__r.Case_Role__c;
            }else{
                this.selectedPobo = this.allJpArray[0].Payment_On_Behalf_Of__r.Case_Role__c;
            }
        } */

        this.ciwArray = await createCaseIssueWrapperList({ciList: this.allCiArray, lpList: this.allLpArray, jpList: this.allJpArray,
                                                            liablePartyList: this.allLiablePartyArray, selectedPobo: this.selectedPobo});

        this.ciwArray.forEach(ciw => {
            if(ciw.wageAllocation > 0){
                this.allocationCurrentDisplayValues.set(ciw.thisCaseIssue.Id + ':wageAllocation', -ciw.wageAllocation);
            }
            if(ciw.wageInterestAllocation > 0){
                this.allocationCurrentDisplayValues.set(ciw.thisCaseIssue.Id + ':wageInterestAllocation', -ciw.wageInterestAllocation);
            }
            if(ciw.interestAllocation > 0){
                this.allocationCurrentDisplayValues.set(ciw.thisCaseIssue.Id + ':interestAllocation', -ciw.interestAllocation);
            }
            if(ciw.penaltyAllocation > 0){
                this.allocationCurrentDisplayValues.set(ciw.thisCaseIssue.Id + ':penaltyAllocation', -ciw.penaltyAllocation);
            }
        });

        this.updateAmountRemainingToAllocate();

        if(this.ciwArray.length === 0){
            this.renderCaseIssueWrapperTable = false;
        }else{
            this.renderCaseIssueWrapperTable = true;
        }
    }

    @track renderJudgmentWrapperTable = false;
    @track allJudgmentArray = [];
    @track allJudgmentPartyArray = []; //The Judgment Parties are currently derived from the Judgments. They could be gotten from the Liable Parties. Not sure it matters either way.
    @track jwArray = [];
    @wire(queryJudgments, {caseId: '$caseId'}) getJudgments({error, data}){
        if(data){
            this.allJudgmentArray = data;
            data.forEach(judgment => {
                if(judgment.Liability_Judgements__r){
                    this.allJudgmentPartyArray.push(...judgment.Liability_Judgements__r);
                }
            });
            if(this.allJudgmentArray.length > 0 && this.allJudgmentPartyArray.length > 0){
                this.createJWs();
            }
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashPartyToPartyPayments.js.getJudgments: ' + JSON.stringify(error.body.message),
                /* message: JSON.stringify(error.body.message) + '❌Return to {0} record detail.',
                messageData: [{url: '/' + this.casePaymentId,
                               label: this.casePayment.Name}], */
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            /* window.open('mailto:mteixeira@dir.ca.gov');
            setTimeout(function(){
                window.location.replace('/' + this.casePaymentId)
            },6000
            ) */

        }
    }

    async createJWs(){
        
        //// TODO: moved this POBO assignment up above inside getCP(), verify it works
        /*
        This following if{} code block is the same in createCIWs(), but is needed here in case there are no CIs. The POBO should still be same on all LPs and JPs.        
        If a CP has been recommended or posted, set POBO combobox value to the POBO (Case Role Id) of an LP, or a JP if no LPs. This assumes all LPs have the
        same POBO, which they should.

        if(this.casePayment.Status__c === 'Allocations Recommended' || this.casePayment.Status__c === 'Posted'){
            if(this.allLpArray.length > 0){ 
                this.selectedPobo = this.allLpArray[0].Payment_On_Behalf_Of__r.Case_Role__c;
            }else{
                this.selectedPobo = this.allJpArray[0].Payment_On_Behalf_Of__r.Case_Role__c;
            }
        } */
        this.jwArray = await createJudgmentWrapperList({judgmentList: this.allJudgmentArray, jpList: this.allJpArray,
                                                        judgmentPartyList: this.allJudgmentPartyArray, selectedPobo: this.selectedPobo});

        this.jwArray.forEach(jw => {
            if(jw.postHearingInterestAllocation > 0){
                this.allocationCurrentDisplayValues.set(jw.thisJudgment.Id + ':postHearingInterestAllocation', -jw.postHearingInterestAllocation);
            }
            if(jw.postJudgmentInterestAllocation > 0){
                this.allocationCurrentDisplayValues.set(jw.thisJudgment.Id + ':postJudgmentInterestAllocation', -jw.postJudgmentInterestAllocation);
            }
            if(jw.attorneyFeesAllocation > 0){
                this.allocationCurrentDisplayValues.set(jw.thisJudgment.Id + ':attorneyFeesAllocation', -jw.attorneyFeesAllocation);
            }
            if(jw.filingFeesAllocation > 0){
                this.allocationCurrentDisplayValues.set(jw.thisJudgment.Id + ':filingFeesAllocation', -jw.filingFeesAllocation);
            }

        });

        this.updateAmountRemainingToAllocate();

        if(this.jwArray.length === 0){
            this.renderJudgmentWrapperTable = false;
        }else{
            this.renderJudgmentWrapperTable = true;
        }
    }

    get todaysDate() {
        var now = new Date();
        var dd = String(now.getDate());
        if(dd.length === 1){
            dd = '0' + dd;
        }
        var mm = String(now.getMonth() + 1); //January is 0!
        if(mm.length === 1){
            mm = '0' + mm;
        }
        var yyyy = now.getFullYear();
        var today = yyyy + '-' + mm + '-' + dd;
        // var today = mm + '/' + dd + '/' + yyyy;
        return today;
    }

    @track dateReceivedEntered = true; //we set dateReceived to todaysDate on init
    @track dateReceived = this.todaysDate;
    handleDateReceivedChange(event){
        console.log('688 event.target.value: ', event.target.value);
        if(event.target.value){
            this.dateReceived = event.target.value;
            this.dateReceivedEntered = true;
            console.log(this.paymentAmountEntered, ' ', this.dateReceivedEntered, ' ', this.payorEntered, ' ', this.poboEntered, ' ', this.amountRemainingToAllocateIsZero)
        }else{ //dateReceived value cleared out or not valid
            this.dateReceived = this.todaysDate;
            this.dateReceivedEntered = false;
            console.log(this.paymentAmountEntered, ' ', this.dateReceivedEntered, ' ', this.payorEntered, ' ', this.poboEntered, ' ', this.amountRemainingToAllocateIsZero)
        }
    }



    @track popoverCaseId;
    @track popoverCiId;
    @track popoverCiAssessmentDescription;
    @track popoverCiStatus;
    @track popoverJId;
    @track popoverJType;
    @track popoverJPartyName;
    @track popoverJPartyUrl;
    @track popoverJCourtCaseNumber;
    @track popoverJCourtName;
    @track popoverJCourtUrl;

	@track left;
	@track top;
    @track mouseIsOverPopover;
    @track verticalScrollOffset;

	showPopoverFromLink(event){
        /* console.log('* showPopoverFromLink called.'); */
        this.verticalScrollOffset = window.scrollY;
        /* console.log('874 verticalScrollOffset: ', this.verticalScrollOffset); */
        /* console.log('875 event.currentTarget.dataset.popovercaseid: ', event.currentTarget.dataset.popovercaseid); */
        /* console.log('876 mouseisoverpopover: ', event.currentTarget.dataset.mouseisoverpopover); */
        this.mouseIsOverPopover = event.currentTarget.dataset.mouseisoverpopover;
		
        if(!this.popoverCaseId){
            this.popoverCaseId = event.currentTarget.dataset.popovercaseid;
            /* console.log('870 case: ', this.popoverCaseId); */
        }
        if(!this.popoverCiId){
            /* console.log('880 ci: ', this.popoverCiId); */
            this.popoverCiId = event.currentTarget.dataset.popoverciid;
            this.popoverCiAssessmentDescription = event.currentTarget.dataset.popoverassessmentdescription;
            this.popoverCiStatus = event.currentTarget.dataset.popovercistatus;
        }
        if(!this.popoverJId){
            this.popoverJId = event.currentTarget.dataset.popoverjid;
            this.popoverJType = event.currentTarget.dataset.popoverjtype;
            this.popoverJPartyName = event.currentTarget.dataset.popoverjpartyname;
            this.popoverJPartyUrl = event.currentTarget.dataset.popoverjpartyurl;
            this.popoverJCourtCaseNumber = event.currentTarget.dataset.popoverjcourtcasenumber;
            this.popoverJCourtName = event.currentTarget.dataset.popoverjcourtname;
            this.popoverJCourtUrl = event.currentTarget.dataset.popoverjcourturl;
        }
        if(!this.mouseIsOverPopover){
            if(this.popoverCaseId){
                this.left = event.clientX;
                this.top = event.clientY + this.verticalScrollOffset - 310;
                console.log('902 cm clientY: ', event.clientY);
                console.log('903 cm top: ', this.top);
            }else if(this.popoverCiId){
                this.left = event.clientX;
                this.top = event.clientY + this.verticalScrollOffset - 170;
                console.log('907 ci clientY: ', event.clientY);
                console.log('908 ci top: ', this.top);
            }else if(this.popoverJId){
                this.left = event.clientX;
                this.top = event.clientY + this.verticalScrollOffset - 180;
                console.log('912 j clientY: ', event.clientY);
                console.log('913 j top: ', this.top);
            }

        }
	}
    hidePopoverFromLink(event){
        console.log('** hidePopoverFromLink called.');
        console.log('81 mouseIsOverPopover: ', this.mouseIsOverPopover);

        setTimeout(() => {
            console.log('setTimeout called');
            console.log('87 setTimeout.mouseIsOverPopover', this.mouseIsOverPopover);

            if(!this.mouseIsOverPopover){
                this.popoverCaseId = "";
                this.popoverCiId = "";
                this.popoverJId = "";
            }
        }, 5); //5ms to give time for mouse to get on top of popover from link. TODO: adjust as needed.

        console.log('');
    }
    keepPopover(event){
        console.log('*** keepPopover called');
        this.mouseIsOverPopover = event.currentTarget.dataset.mouseisoverpopover;
        /* console.log('100 mouseIsOverPopover: ', this.mouseIsOverPopover); */
        
        /* if(!this.mouseIsOverPopover){ //TODO: doesn't seem to be needed currently.
            this.left = event.clientX;
            this.top = event.clientY;
        } */
        if(!this.popoverCaseId){
            this.popoverCaseId = event.currentTarget.dataset.caseid;
        }        
        if(!this.popoverCiId){
            this.popoverCiId = event.currentTarget.dataset.ciid;
        }
        if(!this.popoverJId){
            this.popoverJId = event.currentTarget.dataset.jid;
        }
    }
    losePopover(event){
        console.log('**** losePopover called');
        /* console.log('117 mouseIsOverPopover: ', this.mouseIsOverPopover); */
        setTimeout(() => {
            /* console.log('setTimeout called');
            console.log('120 setTimeout.mouseIsOverPopover', this.mouseIsOverPopover); */
            
            if(this.mouseIsOverPopover){
                this.mouseIsOverPopover = false;
                this.popoverCaseId = "";
                this.popoverCiId = "";
                this.popoverJId = "";
            }
        }, 0);
    }




    handlePostPartyPayment(event){
        this.whichButtonClicked = 'PostPartyPayment';
        /* this.buttonsDisabled = true; //Debounce */
        this.debounce = true;
        this.backToCaseButtonDisabled = true;
        this.inputFieldsDisabled = true;

        this.receipt.Date_Received__c = this.dateReceived;
        if(this.receipt.Payment_Exchange__c === 'Party to Party'){
            this.receipt.Payment_Amount__c = this.paymentAmount;
        }else{
            this.receipt.Payment_Amount__c = 0;
            this.receipt.Deduction_Amount__c = this.paymentAmount;
        }

        // if(this.ppSelection !== 'NONE'){
        //     this.casePayment.Payment_Plan__c = this.ppSelection;
        // }
        this.casePayment.Payment_Amount__c = this.paymentAmount;


        /* saveAllocations({receipt: this.receipt, casePayment: this.casePayment, whichButtonClicked: this.whichButtonClicked,
                cu1WrapperList: {}, caseIssueWrapperList: this.ciwArray, judgmentWrapperList: this.jwArray,
                allLiablePartyList: this.allLiablePartyArray, allJudgmentPartyList: this.allJudgmentPartyArray, recordsToDelete: {}}) */
        // not sure why cu1WrapperList can be {} but recordsToDelete needs [] to work
        saveAllocations({receipt: this.receipt, casePayment: this.casePayment, whichButtonClicked: this.whichButtonClicked,
                cu1WrapperList: {}, caseIssueWrapperList: this.ciwArray, judgmentWrapperList: this.jwArray,
                allLiablePartyList: this.allLiablePartyArray, allJudgmentPartyList: this.allJudgmentPartyArray, recordsToDelete: []})
            .then((result) => {
                window.location.replace('/' + this.caseId);
            })
            .catch((error) => { //TODO: maybe show link to create new SR?
                const evt = new ShowToastEvent({
                    title: 'Party To Party Payment Posting Error',
                    message: JSON.stringify(error.body.message),
                    /* message: JSON.stringify(error.body.message) + '❌Return to {0} record detail.',
                    messageData: [{url: '/' + this.casePaymentId,
                                   label: this.casePayment.Name}], */
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.backToCaseButtonDisabled = false;
            });
    }
}