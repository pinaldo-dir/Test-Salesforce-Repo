import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import cpIconLightning from '@salesforce/resourceUrl/cpIconLightning';
import CASE_FIELD from '@salesforce/schema/Case_Payment__c.Case__c';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import hasCashieringDisbursingCustomPerms from '@salesforce/customPermission/Cashiering_Disbursing';
import hasCashieringSuperUserCustomPerms from '@salesforce/customPermission/Cashiering_Super_User';
import hasCashieringReceiptingCustomPerms from '@salesforce/customPermission/Cashiering_Receipting';
import queryCP from '@salesforce/apex/CashDmlMethods.queryCP';
import queryPPs from '@salesforce/apex/CashDmlMethods.queryPPs';
import queryCIs from '@salesforce/apex/CashDmlMethods.queryCIs';
import queryJudgments from '@salesforce/apex/CashDmlMethods.queryJudgments';
import queryPayees from '@salesforce/apex/CashDmlMethods.queryPayees';
import queryLiableParties from '@salesforce/apex/CashDmlMethods.queryLiableParties'; //also queries related Case Roles and Judgment Parties (Liability_Judgment__c)
import createCaseIssueWrapperList from '@salesforce/apex/CashCaseIssueWrapper.createCaseIssueWrapperList';
import createJudgmentWrapperList from '@salesforce/apex/CashJudgmentWrapper.createJudgmentWrapperList';
import createCu1WrapperList from '@salesforce/apex/CashCu1Wrapper.createCu1WrapperList';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import CASE_PAYMENT_OBJECT from '@salesforce/schema/Case_Payment__c';
import MailingInstructions from '@salesforce/schema/Case_Payment__c.Mailing_Instructions__c';
import PaymentClassification from '@salesforce/schema/Case_Payment__c.Payment_Classification__c';
import PaymentTerms from '@salesforce/schema/Case_Payment__c.Payment_Terms__c';
import saveAllocations from '@salesforce/apex/CashSaveAllocations.saveAllocations';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CashCasePaymentAllocation extends NavigationMixin(LightningElement) {

    currentPageReference;
    @wire(CurrentPageReference) setCurrentPageReference(currentPageReference){
        this.currentPageReference = currentPageReference;
    }

    connectedCallback(){
        document.title = "Case Payment Allocation";
    }

    cpIcon = cpIconLightning;
    fields = [CASE_FIELD];
    
    get casePaymentId() {
        return (!this.currentPageReference) ? null : this.currentPageReference.state.c__casePaymentId;
    }

    async readyToRender(){
        if(this.casePayment){
            return true;
        }
    }

    @track cpId = this.casePaymentId;
    
    allLpArray = [];
    allJpArray = [];
    
    @track amountRemainingToAllocate = '';
    allocationCurrentDisplayValues = new Map(); //Holds whatever allocation amounts are on screen at any given time. Used to calculate Amount Remaining to Allocate.
                                                // Key = caseIssueId:inputFieldName, Value = negative of amount input
    
    casePayment;

    get userHasCashieringDisbursingCustomPerms(){
        if(hasCashieringDisbursingCustomPerms){
            return hasCashieringDisbursingCustomPerms;
        }else{
            return false;
        }
    }
    get userHasCashieringSuperUserCustomPerms(){
        if(hasCashieringSuperUserCustomPerms){
            return hasCashieringSuperUserCustomPerms;
        }else{
            return false;
        }
    }
    get userHasCashieringReceiptingCustomPerms(){
        if(hasCashieringReceiptingCustomPerms){
            return hasCashieringReceiptingCustomPerms;
        }else{
            return false;
        }
    }

    @track poboComboboxDisabled = false; //POBO combobox disabled when CP.Status__c === 'Posted'
    @track ppComboboxDisabled = true; //PP combobox disabled if (POBO === 'ALL' && CP.Status__c === 'New') || CP.Status === 'Posted'.
    @track buttonsDisabled = true; //Recommend and Post buttons enabled if Amount Remaining to Allocate === 0 and CP.Status__c !== 'Posted'.
    @track backToCpButtonDisabled = false; //Button returning to CP detail should be disabled when clicked or when either Recommend or Post buttons clicked.
    @track inputFieldsDisabled = true; //TODO: Redundant with ppComboboxDisabled? User shouldn't be able to input or change any data if (POBO === 'ALL' && CP.Status === 'New')
                                        // || CP.Status === 'Posted'.


    get caseRtDevName(){
        if(this.casePayment){
            return this.casePayment.Case__r.RecordType.DeveloperName;
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

    get bothButtonsHidden(){
        if(this.casePayment && this.userProfileName){
            return !(
                this.userProfileName === 'BOFE User' ||
                this.userProfileName === 'WCA User' ||
                this.userProfileName === 'RCI User' ||
                this.userProfileName.includes('System Administrator') ||
                this.userHasCashieringSuperUserCustomPerms ||
                this.casePayment.Case__r.RecordType.DeveloperName === 'Registration'
            );
        }
    }

    get recommendButtonHidden(){
        return false;
        /* if(this.casePayment && this.userProfileName){
            return (
                this.casePayment.Case__r.RecordType.DeveloperName === 'PASS' && this.userProfileName === 'WCA User' ||
                this.casePayment.Case__r.RecordType.DeveloperName === 'PASS' && this.userProfileName === 'DIR Cashiering' ||
                this.casePayment.Case__r.RecordType.DeveloperName === 'RCI' && this.userProfileName === 'WCA User' && this.userHasCashieringDisbursingCustomPerms
            );
        } */
    }

    get postButtonHidden(){
        if(this.casePayment && this.userProfileName){
            return (this.userProfileName === 'BOFE User');
            /*return (
                this.casePayment.Case__r.RecordType.DeveloperName === 'BOFE_Closed' && this.userProfileName === 'PAGA Profile' ||
                this.casePayment.Case__r.RecordType.DeveloperName === 'BOFE_Closed' && this.userProfileName === 'BOFE User' ||
                this.casePayment.Case__r.RecordType.DeveloperName === 'BOFE_Investigation' && this.userProfileName === 'PAGA Profile' ||
                this.casePayment.Case__r.RecordType.DeveloperName === 'BOFE_Investigation' && this.userProfileName === 'BOFE User'
            );*/
            //return false;
        }
    }
    

    @wire(queryCP, {cpId: '$casePaymentId'}) getCP({error, data}){
        
        let tempLpArray = [];
        let tempJpArray = [];
        let tempCu1LpArray = [];

        if(data){
            console.log('139 data: ', data);
            /* if(!data.Payment_Plan__c){
                //Copy data to new object that is extensible, so we can add a Payment_Plan__c element if needed.
                // this.casePayment = Object.assign({}, data, {Payment_Plan__c: ''});
                // this.casePayment = Object.assign({}, data, {Payment_Plan__c: {value: '', writable: true}});
            }else{
                this.casePayment = data;
            } */

            this.casePayment = data;

            console.log('154 casePayment: ', this.casePayment);
            if(this.casePaymentStatusIsInvalid){ 
            //if(this.casePayment.Status__c === 'Posted' || this.casePaymentStatusIsInvalid || !this.casePayment.Deposited__c){
                this.poboComboboxDisabled = true;
                this.ppComboboxDisabled = true;
                this.buttonsDisabled = true;
                this.inputFieldsDisabled = true;
            }else{
                if(this.selectedPobo === 'ALL'){
                    this.ppComboboxDisabled = true;
                    this.buttonsDisabled = true;
                    this.inputFieldsDisabled = true;
                }
            }

            if(data.Liability_Payments__r){
                console.log('155 data.lps: ', data.Liability_Payments__r);
                [...data.Liability_Payments__r].forEach(lp => {
                    tempLpArray.push(lp);
                });
                this.allLpArray = tempLpArray;
                
                if(this.allLpArray[0].Payment_On_Behalf_Of__c){ //CPs with just one child Buyback LPs will have no POBO
                    this.selectedPobo = this.allLpArray[0].Payment_On_Behalf_Of__r.Case_Role__c;
                }

                if(this.casePayment.Status__c !== 'Posted' && !this.casePaymentStatusIsInvalid){ //LPs exist, and CP is not yet Posted.
                    this.ppComboboxDisabled = false;
                    this.inputFieldsDisabled = false;
                }

            }
            if(data.Judgment_Payments__r){
                [...data.Judgment_Payments__r].forEach(jp => {
                    tempJpArray.push(jp);
                });
                this.allJpArray = tempJpArray;

                if(this.selectedPobo === 'ALL' || this.selectedPobo === null){
                    this.selectedPobo = this.allJpArray[0].Payment_On_Behalf_Of__r.Case_Role__c; //JP.POBOs could technically be of any Liable Party or several, for now.
                                                                                                 // If we're unable to pull the selectedPobo from any LPs, like when there
                                                                                                 // aren't any, pull from any extant JPs.
                } 


                if(this.casePayment.Status__c !== 'Posted' && !this.casePaymentStatusIsInvalid){ //JPs exist, and CP is not yet Posted.
                    this.ppComboboxDisabled = false;
                    this.inputFieldsDisabled = false;
                }
            }
            
            this.createCU1Ws();
        
            console.log('213 data.pp: ', data.Payment_Plan__c);

            this.amountRemainingToAllocate = data.Payment_Amount__c;
            this.allocationCurrentDisplayValues.set('paymentAmount', data.Payment_Amount__c);
            if(data.Payment_Plan__c){
                this.ppSelection = data.Payment_Plan__c;
            }else{
                this.ppSelection = 'NONE';
            }
        }

        if(error){
            const evt = new ShowToastEvent({
                title: 'Case Payment Recommend/Post Initialization Error',
                message: JSON.stringify(error.body.message),
                /* message: JSON.stringify(error.body.message) + '❌Return to {0} record detail.',
                messageData: [{url: '/' + this.casePaymentId,
                               label: this.casePayment.Name}], */
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            this.backToCpButtonDisabled = false;
        }
    }

    @track refundAmountDetailsRequired = false;
    @track amtDueToDirExplanationRequired = false;
    @track otherAmountDetailsRequired = false;
    @track amountRemainingToAllocateIsZero = false;    
    updateAmountRemainingToAllocate(event){ //TODO: rename this method as it now does more than just calculating the Amount Remaining To Allocate
        if(event){
            console.log('215 event.target.name: ', event.target.name);
            console.log('216 event.target.value: ' , event.target.value);
            if(event.target.name.includes('Allocation') || event.target.name.includes('Amount') || event.target.name.includes('Fee') || (event.target.name.includes('amtDue') && event.target.name !== 'amtDueToDirExplanation')){
                if(event.target.value >= 0.00){
                    this.allocationCurrentDisplayValues.set(event.target.dataset.id + ':' + event.target.name, -event.target.value);
                }else{
                    this.allocationCurrentDisplayValues.set(event.target.dataset.id + ':' + event.target.name, 0.00);
                    event.target.value = 0;
                }
            }
            
            //Update allocation amounts in the CIWs, JWs, and CU1Ws
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
                    }else{
                        if(event.target.value && event.target.value >= 0.00){
                            jw.filingFeesAllocation = event.target.value;
                        }else{
                            jw.filingFeesAllocation = 0;
                        }
                    }
                }
            });
            
            this.cu1wArray.forEach(cu1w => {
                if(cu1w.typeIsPaymentClassification){
                    if(event.target.name === 'paymentClassification'){
                        cu1w.paymentClassificationPicklist = event.target.value ? event.target.value : '';
                    }
                    if(event.target.name === 'paymentClassificationSpecialInstructions'){
                        cu1w.paymentClassificationSpecialInstructions = event.target.value ? event.target.value : '';
                    }
                }else if(cu1w.typeIsPaymentTerms){
                    if(event.target.name === 'paymentTerms'){
                        if(event.target.value !== 'Other'){
                            this.isPaymentTermsOther = false;
                            cu1w.paymentTermsOtherExplanation = ''; //If Payment Terms is changed to something other than 'Other',
                                                                    // clear Payment Terms "Other" Explanation field in case it had been filled in before.
                            this.paymentTermsOtherExplanationEntered = false;
                        }
                        cu1w.paymentTermsPicklist = event.target.value ? event.target.value : '';
                    }
                    if(event.target.name === 'paymentTermsOtherExplanation'){
                        cu1w.paymentTermsOtherExplanation = event.target.value ? event.target.value : '';
                    }
                }else if(cu1w.typeIsFundsMailedToEmployee){
                    if(event.target.name === 'dateFundsMailedToEmployee'){
                        cu1w.fundsMailedToEmployeeDateString = event.target.value ? event.target.value : '';
                    }
                    if(event.target.name === 'mailingInstructions'){
                        cu1w.fundsMailedToEmployeeInstructionsPicklist = event.target.value ? event.target.value : '';
                    }
                }else if(cu1w.typeIsRefund){
                    if(event.target.name === 'refundAmount'){
                        if(event.target.value){
                            if(event.target.value > 0.00){
                                cu1w.refundAmount = event.target.value;
                                this.refundAmountDetailsRequired = true;
                            }else if(event.target.value == 0.00){
                                cu1w.refundAmount = event.target.value;
                                cu1w.refundAmountDetails = '';
                                this.refundAmountDetailsRequired = false;
                            }else{
                                cu1w.refundAmount = 0.00;
                                cu1w.refundAmountDetails = '';
                                this.refundAmountDetailsRequired = false;

                            }
                        }else{
                            cu1w.refundAmount = 0.00;
                            cu1w.refundAmountDetails = '';
                            this.refundAmountDetailsRequired = false;
                        }
                    }
                    if(event.target.name === 'refundDetails'){
                        cu1w.refundAmountDetails = event.target.value ? event.target.value : '';
                    }
                }else if(cu1w.typeIsAmtDueToDIR){
                    if(event.target.name === 'amtDueToDir'){
                        if(event.target.value){
                            if(event.target.value > 0.00){
                                cu1w.amtDueToDir = event.target.value;
                                this.amtDueToDirExplanationRequired = true;
                            }else if(event.target.value == 0.00){
                                cu1w.amtDueToDir = event.target.value;
                                cu1w.amtDueToDirExplanation = '';
                                this.amtDueToDirExplanationRequired = false;
                            }else{
                                cu1w.amtDueToDir = 0.00;
                                cu1w.amtDueToDirExplanation = '';
                                this.amtDueToDirExplanationRequired = false;
                            }
                        }else{
                            cu1w.amtDueToDir = 0.00;
                            cu1w.amtDueToDirExplanation = '';
                            this.amtDueToDirExplanationRequired = false;
                        }
                    }
                    if(event.target.name === 'amtDueToDirExplanation'){
                        cu1w.amtDueToDirExplanation = event.target.value ? event.target.value : '';
                    }
                }else if(cu1w.typeIsOther){
                    if(event.target.name === 'otherAmount'){
                        if(event.target.value){
                            if(event.target.value > 0.00){
                                cu1w.otherAmount = event.target.value;
                                this.otherAmountDetailsRequired = true;
                            }else if(event.target.value == 0.00){
                                cu1w.otherAmount = event.target.value;
                                cu1w.otherAmountDetails = '';
                                this.otherAmountDetailsRequired = false;
                            }else{
                                cu1w.otherAmount = 0.00;
                                cu1w.otherAmountDetails = '';
                                this.otherAmountDetailsRequired = false;
                            }
                        }else{
                            cu1w.otherAmount = 0.00;
                            cu1w.otherAmountDetails = '';
                            this.otherAmountDetailsRequired = false;
                        }
                    }
                    if(event.target.name === 'otherDetails'){
                        cu1w.otherAmountDetails = event.target.value ? event.target.value : '';
                    }
                }
            });

        }

        /* validation from https://www.salesforcepoint.com/2020/09/validate-lwc-input-data-how-to-add.html */
        /* const inputsAreValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                console.log('373 reportValidity: ', inputField.reportValidity());
                return validSoFar && inputField.checkValidity();
            }, true);

        if(inputsAreValid){
            console.log('378 inputsAreValid');

            this.amountRemainingToAllocate = 0;
    
            this.allocationCurrentDisplayValues.forEach((value, key) => {
                this.amountRemainingToAllocate += value;
            });
            this.amountRemainingToAllocate = Math.round(this.amountRemainingToAllocate * 100) / 100;
    
            if(this.amountRemainingToAllocate === 0){
                this.amountRemainingToAllocateIsZero = true;
                if(this.casePayment.Status__c === 'Posted'){
                    this.buttonsDisabled = true;
                }else{
                    if(this.isPaymentTermsOther === this.paymentTermsOtherExplanationEntered){
                        this.buttonsDisabled = false;
                    }else{
                        this.buttonsDisabled = true;
                    }
                }
            }else{
                this.amountRemainingToAllocateIsZero = false;
                this.buttonsDisabled = true;
            }

        }else{
            this.amountRemainingToAllocateIsZero = false;
            this.buttonsDisabled = true;
        } */

        this.amountRemainingToAllocate = 0;
    
        this.allocationCurrentDisplayValues.forEach((value, key) => {
            this.amountRemainingToAllocate += value;
        });
        this.amountRemainingToAllocate = Math.round(this.amountRemainingToAllocate * 100) / 100;

        if(this.amountRemainingToAllocate === 0){
            this.amountRemainingToAllocateIsZero = true;
            if(this.casePayment.Status__c === 'Posted'){
                this.buttonsDisabled = true;
            }else{
                if(this.isPaymentTermsOther === this.paymentTermsOtherExplanationEntered){
                    this.buttonsDisabled = false;
                }else{
                    this.buttonsDisabled = true;
                }
            }
        }else{
            this.amountRemainingToAllocateIsZero = false;
            this.buttonsDisabled = true;
        }



    }
    
    @wire(getObjectInfo, {objectApiName: CASE_PAYMENT_OBJECT})
    casePaymentObjectInfo;
    
    paymentClassificationOptions = [];
    @wire(getPicklistValues, {
        recordTypeId: '$casePaymentObjectInfo.data.defaultRecordTypeId',
        fieldApiName: PaymentClassification
    }) paymentClassificationPicklistValues({error, data}){
        if(data){
            let tempObj = { ...data.values[0], label: "", value: ""};
            let tempArray = [];
            tempArray.push(tempObj, ...data.values);
            this.paymentClassificationOptions = tempArray;
        }
        if(error){
                const evt = new ShowToastEvent({
                    title: 'Posting error',
                    message: 'cashCasePaymentAllocation.js.paymentClassificationPicklistValues: ' + JSON.stringify(error.body.message),
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

    paymentTermsOptions = [];
    @wire(getPicklistValues, {
        recordTypeId: '$casePaymentObjectInfo.data.defaultRecordTypeId',
        fieldApiName: PaymentTerms
    }) paymentTermsPicklistValues({error, data}){
        if(data){
            let tempObj = { ...data.values[0], label: "", value: "" };
            let tempArray = [];
            tempArray.push(tempObj, ...data.values);
            this.paymentTermsOptions = tempArray;
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashCasePaymentAllocation.js.paymentTermsPicklistValues: ' + JSON.stringify(error.body.message),
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

    @track isPaymentTermsOther = false;
    @track paymentTermsOtherExplanationEntered = false;
    handlePaymentTermsChange(event){
        if(event.target.name === 'paymentTerms'){
            if(event.target.value === 'Other'){
                this.isPaymentTermsOther = true;
            }else{
                this.isPaymentTermsOther = false;
                this.paymentTermsOtherExplanationEntered = false;
            }
        }else if(event.target.name === 'paymentTermsOtherExplanation')
            if(event.target.value !== null && event.target.value !== ''){
                this.paymentTermsOtherExplanationEntered = true;
            }else{
                this.paymentTermsOtherExplanationEntered = false;
            }
        this.updateAmountRemainingToAllocate(event);
    }

    mailingInstructionsOptions = [];
    @wire(getPicklistValues, {
        recordTypeId: '$casePaymentObjectInfo.data.defaultRecordTypeId',
        fieldApiName: MailingInstructions
    }) mailingInstructionsPicklistValues({error, data}){
        if(data){
            let tempObj = { ...data.values[0], label: "", value: ""};
            let tempArray = [];
            tempArray.push(tempObj, ...data.values);
            this.mailingInstructionsOptions = tempArray;
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashCasePaymentAllocation.js.mailingInstructionsPicklistValues: ' + JSON.stringify(error.body.message),
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


    @track allLiablePartyArray = [];
    @track allCaseRoleMap = new Map(); //Used to filter out Liable Parties that may be under the same Case Role
    @track poboOptions = [];
    @track selectedPobo = 'ALL'; //Holds Case Role ID (as opposed to Liable Party ID which the POBO lookup field on the LPs and JPs is); or 'ALL' for showing all CIWs on page load.
    @wire(queryLiableParties, {caseId: '$caseId'}) getLiableParties({error, data}){
        let tempArray = [];
        if(data){
            this.allLiablePartyArray = data;
            console.log('560 allLiablePartyArray: ', this.allLiablePartyArray);
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
            if(this.allLiablePartyArray.length > 0){
                this.createCU1Ws();
            }
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashCasePaymentAllocation.js.getLiableParties: ' + JSON.stringify(error.body.message),
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

        
    allPayeeArray = [];
    @wire(queryPayees, {caseId: '$caseId'}) getPayees({error, data}){
        if(data){
            this.allPayeeArray = data;
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashCasePaymentAllocation.js.getPayees: ' + JSON.stringify(error.body.message),
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
                message: 'cashCasePaymentAllocation.js.getPPs: ' + JSON.stringify(error.body.message),
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

            let index = this.ppOptions.findIndex(element => {
                return element.value === this.ppSelection
            });

            if(index > -1){
                this.ppBalanceDue = this.ppOptions[index].balance;
            }else{
                this.ppBalanceDue = 0;
            }            
        }
    }

    handlePpChange(event){
        if(event.target.value != this.ppSelection){
            this.ppSelection = event.target.value;
            console.log('742 ppSelection: ', this.ppSelection);

            let index = this.ppOptions.findIndex(element => {
                return element.value === this.ppSelection
            });
            this.ppBalanceDue = this.ppOptions[index].balance;
        }

        /* if(this.ppSelection === 'NONE'){
            this.casePayment.Payment_Plan__c = '';
        }else{
            this.casePayment.Payment_Plan__c = this.ppSelection;
        } */

        let index = this.ppOptions.findIndex(element => {
            return element.value === this.ppSelection
        });
        this.ppBalanceDue = this.ppOptions[index].balance;
    }
        
    handlePoboChange(event){
        this.selectedPobo = event.target.value;

        this.inputFieldsDisabled = false;
        this.ppComboboxDisabled = false;
        this.ppSelection = 'NONE';
        
        //Clear all input values to 'reset' Amount Remaining To Allocate.
        this.allocationCurrentDisplayValues.forEach((value, key) => {
            if(key !== 'paymentAmount'){
                this.allocationCurrentDisplayValues.delete(key);
            }
        });

        this.isPaymentTermsOther = false;

        //filter Liabilities and Judgments/LPs JPs CIWs JWs by POBO
        this.createCIWs();
        this.createJWs();
        this.createCU1Ws();
        this.filterPPs();
        console.log('610 selectedPobo: ', this.selectedPobo);
    }
    
    @track renderCaseIssueWrapperTable = false;
    @track allCiArray = [];
    @track ciwArray = [];
    @wire(queryCIs, {caseId: '$caseId'}) getCIs({error, data}){
        if(data){
            console.log('650 ci: ', data);
            this.allCiArray = data;
            /* console.log('652 allLiablePartyArray: ', this.allLiablePartyArray); */
            if(this.allCiArray.length > 0 && this.allLiablePartyArray.length > 0) {
                this.createCIWs();
            }
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashCasePaymentAllocation.js.getCIs: ' + JSON.stringify(error.body.message),
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
            console.log('705 data: ', data);
            this.allJudgmentArray = data;
            data.forEach(judgment => {
                if(judgment.Liability_Judgements__r){
                    this.allJudgmentPartyArray.push(...judgment.Liability_Judgements__r);
                }
            });
            if(this.allJudgmentArray.length > 0){
                if(this.allJudgmentPartyArray.length > 0){
                    this.createJWs();
                }else{
                    const judgmentId = this.allJudgmentArray[0].Id;
                    const judgmentName = this.allJudgmentArray[0].Name;
                    var messageString = 'One or more Judgments on this Case may be missing Judgment Parties';
                    var messageDataObj;
        
                    if(judgmentId && judgmentName){
                        messageString += ', possibly {0}';
                        messageDataObj = [{url: '/' + judgmentId,
                                            label: judgmentName}];
                    }
                    messageString += '.';
        
                    const evt = new ShowToastEvent({
                        title: 'Error determining Judgments for this Case or POBO.',
                        message: messageString,
                        messageData: messageDataObj,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                }
            }
        }
        if(error){
            const evt = new ShowToastEvent({
                title: 'Posting error',
                message: 'cashCasePaymentAllocation.js.getJudgments: ' + JSON.stringify(error.body.message),
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
        console.log('737 create JWs called');
        console.log('738 jparray: ', this.allJudgmentPartyArray);
        this.jwArray = await createJudgmentWrapperList({judgmentList: this.allJudgmentArray, jpList: this.allJpArray,
                                                        judgmentPartyList: this.allJudgmentPartyArray, selectedPobo: this.selectedPobo});  
                                                        
        console.log('741 jwArray.length: ', this.jwArray.length);

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
            console.log('765 renderjwtable: ', this.renderJudgmentWrapperTable);
        }
    }


    @track cu1wArray = [];
    async createCU1Ws(){
        
        console.log('881 allLiablePartyArray: ', this.allLiablePartyArray);
        this.cu1wArray = await createCu1WrapperList({lpList: this.allLpArray, liablePartyList: this.allLiablePartyArray, selectedPobo: this.selectedPobo});

        console.log('743 cu1wArray: ', this.cu1wArray);

        this.cu1wArray.forEach(cu1w => {
            /* if(this.selectedPobo !== 'ALL' && this.allLiablePartyArray.length > 0){
                // Updates cu1w.relevantPoboLiablePartyId if there are no pre-existing LPs, or if the POBO is changed during an allocation or subsequent re-allocation.
                cu1w.relevantPoboLiablePartyId = this.allLiablePartyArray.find(liableParty => liableParty.Case_Role__r.Id === this.selectedPobo).Id;
                console.log('749 cu1w.relevantPoboLiablePartyId: ', cu1w.relevantPoboLiablePartyId);
            } */

            if(cu1w.typeIsPaymentClassification){
                cu1w.paymentClassificationPicklist = this.casePayment.Payment_Classification__c;
                cu1w.paymentClassificationSpecialInstructions = this.casePayment.Special_Instructions__c;
            }
            if(cu1w.typeIsPaymentTerms){
                cu1w.paymentTermsPicklist = this.casePayment.Payment_Terms__c;
                cu1w.paymentTermsOtherExplanation = this.casePayment.Payment_Terms_Other__c;
                if(cu1w.paymentTermsPicklist === 'Other'){
                    this.isPaymentTermsOther = true;
                    if(cu1w.paymentTermsOtherExplanation !== '' || cu1w.paymentTermsOtherExplanation !== null){
                        this.paymentTermsOtherExplanationEntered = true;
                    }
                }
            }
            if(cu1w.typeIsFundsMailedToEmployee){
                cu1w.fundsMailedToEmployeeDateString = this.casePayment.Date_Funds_Mailed_to_Employee__c;  //TODO: toString()?
                cu1w.fundsMailedToEmployeeInstructionsPicklist = this.casePayment.Mailing_Instructions__c;
            }
            if(cu1w.typeIsRefund){
                this.allocationCurrentDisplayValues.set('Refund:refundAmount', -cu1w.refundAmount);
            }
            if(cu1w.typeIsAmtDueToDIR){
                this.allocationCurrentDisplayValues.set('Amounts Due to DIR:amtDueToDir', -cu1w.amtDueToDir);
            }
            if(cu1w.typeIsOther){
                this.allocationCurrentDisplayValues.set('Other:otherAmount', -cu1w.otherAmount);
            }
        });
        
        /* TODO: this is commented out because we're now matching pre-existing CU-1 LPs to CU1Ws on CU1W creation inside the CashCu1Wrapper class.
            Still concerned about allocationCurrentDisplayValues getting set correctly though.
        //Match existing LPs, of the CU1 types, to the related CU1Ws.
        this.allLpArray.forEach(lp => {
            if(lp.Payment_Applied_To__c === 'Refund Amount'){
                let index = this.cu1wArray.findIndex(element => element.cu1Type === 'Refund');
                this.cu1wArray[index].matchingLP = lp;
                this.cu1wArray[index].refundAmount = lp.Posted_Amount__c ? lp.Posted_Amount__c : lp.Recommended_Amount__c;
                this.cu1wArray[index].refundAmountDetails = lp.Refund_Amount_Details__c;

                this.allocationCurrentDisplayValues.set('Refund:refundAmount', -this.cu1wArray[index].refundAmount);

            }else if(lp.Payment_Applied_To__c === 'Amounts Due to DIR'){ 
                let index = this.cu1wArray.findIndex(element => element.cu1Type === 'Amounts Due to DIR');
                this.cu1wArray[index].matchingLP = lp;
                this.cu1wArray[index].amtDueToDirAmount = lp.Posted_Amount__c ? lp.Posted_Amount__c : lp.Recommended_Amount__c;
                this.cu1wArray[index].amtDueToDirExplanation = lp.Amounts_Due_to_DIR_Explanation__c	;

                this.allocationCurrentDisplayValues.set('Amounts Due to DIR:amtDueToDir', -this.cu1wArray[index].amtDueToDirAmount);

            }else if(lp.Payment_Applied_To__c === 'Other Amount'){
                let index = this.cu1wArray.findIndex(element => element.cu1Type === 'Other');
                this.cu1wArray[index].matchingLP = lp;
                this.cu1wArray[index].otherAmount = lp.Posted_Amount__c ? lp.Posted_Amount__c : lp.Recommended_Amount__c;
                this.cu1wArray[index].otherAmountDetails = lp.Other_Amount_Details__c;

                this.allocationCurrentDisplayValues.set('Other:otherAmount', -this.cu1wArray[index].otherAmount);
            }
        }); */

        this.updateAmountRemainingToAllocate();
    
    }

    get backToCasePaymentButtonLabel(){
        if(this.casePayment){
            return "B̲ack To " + this.casePayment.Name;
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
        console.log('* showPopoverFromLink called.');
        this.verticalScrollOffset = window.scrollY;
        console.log('874 verticalScrollOffset: ', this.verticalScrollOffset);
        console.log('875 event.currentTarget.dataset.popovercaseid: ', event.currentTarget.dataset.popovercaseid);
        console.log('876 mouseisoverpopover: ', event.currentTarget.dataset.mouseisoverpopover);
        this.mouseIsOverPopover = event.currentTarget.dataset.mouseisoverpopover;
		
        if(!this.popoverCaseId){
            this.popoverCaseId = event.currentTarget.dataset.popovercaseid;
            console.log('870 case: ', this.popoverCaseId);
        }
        if(!this.popoverCiId){
            console.log('880 ci: ', this.popoverCiId);
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



    
    get casePaymentName(){
        if(this.casePayment){
            return this.casePayment.Name;
        }
    }
    
    get caseName(){
        if(this.casePayment){
            return this.casePayment.Case__r.Name;
        }
    }

    get casePaymentStatus(){
        if(this.casePayment){
            return this.casePayment.Status__c;
        }
    }

    get casePaymentDeposited(){
        if(this.casePayment){
            return this.casePayment.Deposited__c;
        }
    }

    get casePaymentAmount(){
        if(this.casePayment){
            return this.casePayment.Payment_Amount__c;
        }
    }

    get isWcaCase(){
        if(this.casePayment){
            return this.casePayment.Case__r.RecordType.Name.includes('WCA') ||
                   this.casePayment.Case__r.RecordType.Name.includes('PASS');
        }
    }    
    
    get caseNumber(){
        if(this.casePayment){
            return this.casePayment.Case__r.Case_Number__c;
        }
    }

    get caseDirOfficeName(){
        if(this.casePayment){
            return this.casePayment.Case__r.Office__r.Name;
        }
    }

    get caseDirOfficeUrl(){
        if(this.casePayment){
            return '/' + this.casePayment.Case__r.Office__c;
        }
    }

    get rctName(){
        if(this.casePayment){
            return this.casePayment.Receipt__r.Name;
        }
    }

    get rctUrl(){
        if(this.casePayment){
            return "/" + this.casePayment.Receipt__c;
        }
    }

    get rctInstrumentNumber(){
        if(this.casePayment){
            return this.casePayment.Receipt__r.Instrument_Number__c;
        }
    }
    
    get rctDateReceived() {
        if(this.casePayment){
            return this.casePayment.Receipt__r.Date_Received__c;
        }
    }
    
    get rctHoldDate() {
        if(this.casePayment){
            return this.casePayment.Receipt__r.Hold_Date__c;
        }
    }
    
    get rctStatus() {
        if(this.casePayment){
            return this.casePayment.Receipt__r.Status__c;
        }
    }
    
    get rctPayorId() {
        if(this.casePayment){
            return this.casePayment.Receipt__r.Payor__c;
        }
    }

    get rctPayorUrl(){
        if(this.casePayment){
            return '/' + this.casePayment.Receipt__r.Payor__c;
        }
    }

    get rctPayorName(){
        if(this.casePayment && this.casePayment.Receipt__r.Payor__c && this.casePayment.Receipt__r.Payor__r.Name){
            return this.casePayment.Receipt__r.Payor__r.Name;
        }else{
            if(this.casePayment){
                const evt = new ShowToastEvent({
                    title: 'Receipt Payor Error',
                    /*message: JSON.stringify("Receipt's Payor Name not found. Please fix before attempting to allocate this Case Payment."),*/
                    message: 'Receipt {0} Payor Name not found. Please fix before attempting to allocate this Case Payment.',
                    messageData: [{url: '/' + this.casePayment.Receipt__c,
                                   label: this.casePayment.Receipt__r.Name}],
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                return "❗ERROR❗";
            }
        }
    }
    
    get caseAssignedDeputy() { //TODO: is this needed at all?
        if(this.casePayment){
            return this.casePayment.Case__r.Assigned_Deputy__c;
        }
    }

    get caseAssignedDeputyName() {
        if(this.casePayment){
            return this.casePayment.Case__r.Assigned_Deputy__r.Name;
        }
    }

    get caseAssignedDeputyUrl(){
        if(this.casePayment){
            return '/' + this.casePayment.Case__r.Assigned_Deputy__c;
            /* return window.location.origin + '/lightning/r/DIR_Employee__c/' + this.casePayment.Case__r.Assigned_Deputy__r.Id + '/view'; */ //TODO: can this be replaced with 
                                                                                            // this.casePayment.Case__r.Assigned_Deputy__c ? if so, remove from queryCP query.
        }
    }

    get caseEmployerName(){
        if(this.casePayment){
            return this.casePayment.Case__r.Employer__r.Name;
        }
    }

    get caseEmployerUrl(){
        if(this.casePayment){
            return '/' + this.casePayment.Case__r.Employer__c;
        }
    }
    
    get caseId() {
        if(this.casePayment){
            return this.casePayment.Case__c;
        }
    }

    get caseUrl(){
        if(this.casePayment){
            return '/' + this.casePayment.Case__c;
        }
    }

    get caseStatus(){
        if(this.casePayment){
            return this.casePayment.Case__r.Status__c;
        }
    }

    get casePaymentStatusIsInvalid(){
        if(this.casePayment){

            /* return this.casePayment.Receipt__r.Deposit_Account__c != '108' && //F For payments where the full amount is to be applied to BOFE Penalties--the "deposit" it directly to 108.
            (
                this.casePayment.Status__c === 'Posted' || //F
                this.casePayment.Status__c === 'Voided' || //F
                this.casePayment.Status__c === 'Corrective Entry' || //F
                this.casePayment.Status__c === 'Deposited-Returned' || //F
                this.casePayment.Status__c === 'Deposited-Returned Deduction' || //F
                (!this.casePayment.Deposited__c && this.casePayment.Payment_Exchange__c === 'Division Payment') //T && T
            ); */

            return this.casePayment.Status__c === 'Posted' || //F
            this.casePayment.Status__c === 'Voided' || //F
            this.casePayment.Status__c === 'Corrective Entry' ||  //F
            this.casePayment.Status__c === 'Deposited-Returned' || //F
            this.casePayment.Status__c === 'Deposited-Returned Deduction' /* || //F
            (!this.casePayment.Deposited__c && this.casePayment.Payment_Exchange__c === 'Division Payment' && this.casePayment.Receipt__r.Deposit_Account__c !== '108'); //T && T && F */

        }else{
            return true; 
        }
    }

    
    whichButtonClicked = '';
    recordsToDelete = [];
    handleRecommend(event){

        this.whichButtonClicked = 'Recommend';
        this.buttonsDisabled = true; //Debounce
        this.backToCpButtonDisabled = true;
        this.inputFieldsDisabled = true;
        this.poboComboboxDisabled = true;
        this.ppComboboxDisabled = true;

        //Any pre-existing LPs that are no longer matched to a CIW need to be deleted.
        //If any of those LPs have redundant JPs, those JPs need to be deleted.
        //Any pre-existing CU-1 LPs that are $0.00 or null need to be deleted.
        this.allLpArray.forEach(lp => {
            let lpIsDeletable = true;
            console.log('999 lp.Id: ', lp.Id);
            this.ciwArray.forEach(ciw => {
                console.log('1001 ciw: ', ciw);
                if((ciw.matchingWageLP && ciw.matchingWageLP.Id === lp.Id && ciw.wageAllocation > 0) ||
                    (ciw.matchingWageInterestLP && ciw.matchingWageInterestLP.Id === lp.Id && ciw.wageInterestAllocation > 0) ||
                    (ciw.matchingPenaltyLP && ciw.matchingPenaltyLP.Id === lp.Id && ciw.penaltyAllocation > 0)  ||
                    (ciw.matchingInterestLP && ciw.matchingInterestLP.Id === lp.Id && ciw.interestAllocation > 0)){
                        lpIsDeletable = false;
                        console.log('1007 lpIsDeletable: ', lpIsDeletable);
                }
            });
            
            this.cu1wArray.forEach(cu1w => {
                if((cu1w.matchingLp && cu1w.matchingLp.Id === lp.Id) &&
                    (cu1w.refundAmount > 0 || cu1w.amtDueToDir > 0 || cu1w.otherAmount > 0)){
                        lpIsDeletable = false;
                }
            });

            console.log('1018 lpIsDeletable: ', lpIsDeletable);
            if(lpIsDeletable){
                this.recordsToDelete.push(lp);

                this.allJpArray.forEach(jp => {
                    console.log('1023 jp: ', jp);
                    console.log('1024 lp.Id: ', lp.Id);
                    if(jp.Funds_Redundant_With__c && jp.Funds_Redundant_With__c === lp.Id){
                        console.log('1026 jp is deletable');
                        this.recordsToDelete.push(jp);
                    }
                    setTimeout(function(){}, 15000);
                })
            }
        });

        console.log('1034 recordsToDelete: ', this.recordsToDelete);

        //Any pre-existing JPs that are no longer matched to a JW need to be deleted.
        this.allJpArray.forEach(jp => {
            let jpIsDeletable = true;

            if(jp.Payment_Applied_To__c !== 'Judgment Amount'){ //Redundant JPs accounted for a few lines above along with their related LPs.
                this.jwArray.forEach(jw => {
                    if((jw.matchingPostHearingInterestJP && jw.matchingPostHearingInterestJP.Id === jp.Id && jw.postHearingInterestAllocation > 0) ||
                        (jw.matchingPostJudgmentInterestJP && jw.matchingPostJudgmentInterestJP.Id === jp.Id && jw.postJudgmentInterestAllocation > 0) ||
                        (jw.matchingAttorneyFeeJP && jw.matchingAttorneyFeeJP.Id === jp.Id & jw.attorneyFeesAllocation > 0) ||
                        (jw.matchingFilingFeeJP && jw.matchingFilingFeeJP.Id === jp.Id && jw.filingFeesAllocation > 0)){
                            jpIsDeletable = false;
                    }
                });
                console.log('1049 jpIsDeletable: ', jpIsDeletable);
                if(jpIsDeletable){
                    this.recordsToDelete.push(jp);
                }
            }
        });

        console.log('1056 recordsToDelete: ', this.recordsToDelete);


        saveAllocations({receipt: {}, casePayment: this.casePayment, whichButtonClicked: this.whichButtonClicked, ppIdString: this.ppSelection,
                cu1WrapperList: this.cu1wArray, caseIssueWrapperList: this.ciwArray, judgmentWrapperList: this.jwArray,
                allLiablePartyList: this.allLiablePartyArray, allJudgmentPartyList: this.allJudgmentPartyArray, recordsToDelete: this.recordsToDelete})
        // saveAllocations({receipt: {}, casePayment: this.casePayment, whichButtonClicked: this.whichButtonClicked,
        //         cu1WrapperList: this.cu1wArray, caseIssueWrapperList: this.ciwArray, judgmentWrapperList: this.jwArray,
        //         allLiablePartyList: this.allLiablePartyArray, allJudgmentPartyList: this.allJudgmentPartyArray})
            .then((result) => {
                console.log('handleRecommend.saveAllocations.then(result): ', result);
                window.location.replace('/' + this.casePaymentId);
                
                // window.open('/' + this.casePaymentId);
                // window.location.reload();
                // See https://www.salesforcecodecrack.com/2019/06/navigation-service-in-lightning-web.html and
                //  https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_navigate for examples of Lightning Navigation service.
            })
            .catch((error) => {  //TODO: maybe show link to create new SR?
                const evt = new ShowToastEvent({
                    title: 'Case Payment Recommending Error',
                    message: JSON.stringify(error.body.message),
                    // message: JSON.stringify(error.body.message) + '❌Return to {0} record detail.',
                    // messageData: [{url: '/' + this.casePaymentId,
                    //                label: this.casePayment.Name}],
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.backToCpButtonDisabled = false;
            });
    } 

    handlePost(event){

        this.whichButtonClicked = 'Post';
        this.buttonsDisabled = true; //Debounce
        this.backToCpButtonDisabled = true;
        this.inputFieldsDisabled = true;
        this.poboComboboxDisabled = true;
        this.ppComboboxDisabled = true;

        //Any pre-existing LPs that are no longer matched to a CIW need to be deleted.
        //If any of those LPs have redundant JPs, those JPs need to be deleted.
        //Any pre-existing CU-1 LPs that are $0.00 or null need to be deleted.
        this.allLpArray.forEach(lp => {
            let lpIsDeletable = true;
            console.log('1105 lp.Id: ', lp.Id);
            this.ciwArray.forEach(ciw => {
                console.log('1107 ciw: ', ciw);
                if((ciw.matchingWageLP && ciw.matchingWageLP.Id === lp.Id && ciw.wageAllocation > 0) ||
                    (ciw.matchingWageInterestLP && ciw.matchingWageInterestLP.Id === lp.Id && ciw.wageInterestAllocation > 0) ||
                    (ciw.matchingPenaltyLP && ciw.matchingPenaltyLP.Id === lp.Id && ciw.penaltyAllocation > 0)  ||
                    (ciw.matchingInterestLP && ciw.matchingInterestLP.Id === lp.Id && ciw.interestAllocation > 0)){
                        lpIsDeletable = false;
                        console.log('1113 lpIsDeletable: ', lpIsDeletable);
                }
            });
            
            this.cu1wArray.forEach(cu1w => {
                if((cu1w.matchingLp && cu1w.matchingLp.Id === lp.Id) &&
                    (cu1w.refundAmount > 0 || cu1w.amtDueToDir > 0 || cu1w.otherAmount > 0)){
                        lpIsDeletable = false;
                }
            });

            console.log('1124 lpIsDeletable: ', lpIsDeletable);
            if(lpIsDeletable){
                this.recordsToDelete.push(lp);

                this.allJpArray.forEach(jp => {
                    console.log('1129 jp: ', jp);
                    console.log('1130 lp.Id: ', lp.Id);
                    if(jp.Funds_Redundant_With__c && jp.Funds_Redundant_With__c === lp.Id){
                        console.log('1132 jp is deletable');
                        this.recordsToDelete.push(jp);
                    }
                    setTimeout(function(){}, 15000);
                })
            }
        });

        console.log('1140 recordsToDelete: ', this.recordsToDelete);

        //Any pre-existing JPs that are no longer matched to a JW need to be deleted.
        this.allJpArray.forEach(jp => {
            let jpIsDeletable = true;

            if(jp.Payment_Applied_To__c !== 'Judgment Amount'){
                this.jwArray.forEach(jw => {
                    if((jw.matchingPostHearingInterestJP && jw.matchingPostHearingInterestJP.Id === jp.Id && jw.postHearingInterestAllocation > 0) ||
                        (jw.matchingPostJudgmentInterestJP && jw.matchingPostJudgmentInterestJP.Id === jp.Id && jw.postJudgmentInterestAllocation > 0) ||
                        (jw.matchingAttorneyFeeJP && jw.matchingAttorneyFeeJP.Id === jp.Id & jw.attorneyFeesAllocation > 0) ||
                        (jw.matchingFilingFeeJP && jw.matchingFilingFeeJP.Id === jp.Id && jw.filingFeesAllocation > 0)){
                            jpIsDeletable = false;
                    }
                });
                console.log('1155 jpIsDeletable: ', jpIsDeletable);
                if(jpIsDeletable){
                    this.recordsToDelete.push(jp);
                }
            }
        });

        console.log('1162 recordsToDelete: ', this.recordsToDelete);

        saveAllocations({receipt: {}, casePayment: this.casePayment, whichButtonClicked: this.whichButtonClicked, ppIdString: this.ppSelection,
                cu1WrapperList: this.cu1wArray, caseIssueWrapperList: this.ciwArray, judgmentWrapperList: this.jwArray,
                allLiablePartyList: this.allLiablePartyArray, allJudgmentPartyList: this.allJudgmentPartyArray, recordsToDelete: this.recordsToDelete})
        /* saveAllocations({receipt: {}, casePayment: this.casePayment, whichButtonClicked: this.whichButtonClicked,
                cu1WrapperList: this.cu1wArray, caseIssueWrapperList: this.ciwArray, judgmentWrapperList: this.jwArray,
                allLiablePartyList: this.allLiablePartyArray, allJudgmentPartyList: this.allJudgmentPartyArray}) */ 
            .then((result) => {
                console.log('handlePost.saveAllocations.then(result): ', result);
                window.location.replace('/' + this.casePaymentId);

            })
            .catch((error) => { //TODO: maybe show link to create new SR?
                const evt = new ShowToastEvent({
                    title: 'Case Payment Posting Error',
                    message: JSON.stringify(error.body.message),
                    /* message: JSON.stringify(error.body.message) + '❌Return to {0} record detail.',
                    messageData: [{url: '/' + this.casePaymentId,
                                   label: this.casePayment.Name}], */
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.backToCpButtonDisabled = false;
            });
    }

    handleBackToCasePayment(event){
        this.buttonsDisabled = true; //Debounce
        this.backToCpButtonDisabled = true;
        window.location.replace('/' + this.casePaymentId);
        //TODO: try:
        //window.history.back();
    }
}