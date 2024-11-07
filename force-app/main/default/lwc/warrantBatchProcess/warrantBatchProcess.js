import { LightningElement, wire, api, track } from 'lwc';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getWarrantBatchDetails from '@salesforce/apex/WarrantBatchProcessController.getWarrantBatchDetails';



const FIELDS = ['Warrant_Batch__c.Status__c'];

export default class WarrantBatchProcess extends NavigationMixin(LightningElement) {

    //@api recordId;
    @track record;
    @track wbData;
    @track wbName;
    @track wbLink;
    @track errormsg;
    @track currStatus;
    @track status_New;
    @track status_Pending;
    @track status_UnderRev;
    @track status_RevComp;
    @track status_Printed;
    @track status_Void;
    @track sfdcBaseURL;

    SubmitApprovalBtn = false;
    voidBtn = false;
    approvalBtn = false;
    secApprovalBtn = false;
    printBtn = false;
    updatePrintBtn = false;
    isModalOpen = false;

    currentPageReference;
    @wire(CurrentPageReference) setCurrentPageReference(currentPageReference){
        this.currentPageReference = currentPageReference;
    }

    get recordId(){
        return (!this.currentPageReference) ? null : this.currentPageReference.state.c__warrantBatchId;
    }

    //Get Warrant Batch Details
    @wire (getWarrantBatchDetails, {apxWbRecId:'$recordId'})
    WBdetails({error,data}){
        if(data){
            console.log("@ wire WBdata ==> ");
            console.log(data);
            this.wbData = JSON.parse(JSON.stringify(data[0]));
            this.wbName = this.wbData.Name;
            this.sfdcBaseURL  = window.location.origin;
            this.wbLink = this.sfdcBaseURL + '/' + this.wbData.Id + '\r\n';
        }
    };

    @wire (getRecord, {recordId: '$recordId', fields: FIELDS }) wbCurrStatus({data, error}){
        if (data){
            this.record = JSON.parse(JSON.stringify(data));
            this.errormsg = undefined;
            console.log("RECORD STATUS =================> ");
            console.log(this.record);
            console.log(this.record.fields.Status__c.value);
            this.currStatus = this.record.fields.Status__c.value;
            console.log("CURRENT STATUS ================> "+this.currStatus);
            
            if(this.currStatus == "New"){
                this.status_New = this.currStatus;
                console.log("status_New ================> "+this.currStatus);
            }
            else if(this.currStatus == "Pending Approval"){
                this.status_Pending = this.currStatus;
                console.log("status_Pending ================> "+this.currStatus);
            }
            else if(this.currStatus == "Under Review"){
                this.status_UnderRev = this.currStatus;
                console.log("status_UnderRev ================> "+this.currStatus);
            }
            else if(this.currStatus == "Review Complete"){
                this.status_RevComp = this.currStatus;
                console.log("status_RevComp ================> "+this.currStatus);
            }
            else if(this.currStatus == "Printed"){
                this.status_Printed = this.currStatus;
                console.log("status_Printed ================> "+this.currStatus);
            }
            else if(this.currStatus == "Void"){
                this.status_Void = this.currStatus;
                console.log("status_Void ================> "+this.currStatus);
            }
            
        }
        else if(error){
            this.errormsg = error;
            this.record = undefined;
        }

    }

    clickedSubmitButton;
    clickedVoidButton;
    clickedApprovalButton;
    clickedSecApprovalButton;
    clickedPrintButton;
    clickedUpdatePrintButton;

    handleSubmitClick(event){
        this.clickedSubmitButton = event.target.label;
        console.log(this.clickedSubmitButton);
        this.SubmitApprovalBtn = true;
        this.isModalOpen = true;
    }

    handleApprovalClick(event){
        this.clickedApprovalButton = event.target.label;
        console.log(this.clickedApprovalButton);
        this.approvalBtn = true;
        this.isModalOpen = true;
    }

    handleSecApprovalClick(event){
        this.clickedSecApprovalButton = event.target.label;
        console.log(this.clickedSecApprovalButton);
        this.secApprovalBtn = true;
        this.isModalOpen = true;
    }

    handlePrintClick(event){
        this.clickedPrintButton = event.target.label;
        console.log(this.clickedPrintButton);
        this.printBtn = true;
        this.isModalOpen = true;
    }

    handleUpdatePrintClick(event){
        this.clickedUpdatePrintButton = event.target.label;
        console.log(this.clickedUpdatePrintButton);
        this.updatePrintBtn = true;
        this.isModalOpen = true;
    }

    handleVoidClick(event){
        this.clickedVoidButton = event.target.label;
        console.log(this.clickedVoidButton);
        this.voidBtn = true;
        this.isModalOpen = true;
    }
   
    closeModal() {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = false;
        this.SubmitApprovalBtn = false;
        this.voidBtn = false;
        this.approvalBtn = false;
        this.secApprovalBtn = false;
        this.printBtn = false;
        this.updatePrintBtn = false;
        //location.reload();
    }

    handleClick(event) {
        this.clickedButtonLabel = event.target.label;
    }

    handleStepBlur(event) {
        const stepIndex = event.detail.index;
    }

}