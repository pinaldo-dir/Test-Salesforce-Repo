import { LightningElement, api, wire, track } from 'lwc';
//import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Warrant_Batch__c.Status__c'];

export default class WarrantBatchStatusIndicator extends LightningElement {
    @api recordId;
    @track wbVoid = false;
    @track wbUWFalloc = false;
    @track currStatus;
    @track error;

    /*
    currentPageReference;
    @wire(CurrentPageReference) setCurrentPageReference(currentPageReference){
        this.currentPageReference = currentPageReference;
    }

    get recordId(){
        return (!this.currentPageReference) ? null : this.currentPageReference.state.c__warrantBatchId;
    }
    */

    @wire (getRecord, {recordId: '$recordId', fields: FIELDS }) wbCurrStatus({error, data}){
        if (error){
            this.error = error;
            console.log(error);
        }
        else if (data){
            this.currStatus = data.fields.Status__c.value;
            console.log(data);
            console.log(this.currStatus);
            if(this.currStatus == "Void"){
                this.wbVoid = true;
                console.log(this.wbVoid);
            }
            else if(this.currStatus == "UWF Allocation"){
                this.wbUWFalloc = true;
            }
            else{
                this.wbVoid = false;
                this.wbUWFalloc = false;
                console.log(this.wbVoid);
            }
        }
    }

    /*
    get currStatus(){
        console.log("WB STATUS INDICATOR ==> "+this.wbCurrStatus.data);
        console.log(this.wbCurrStatus.data);
        if (this.wbCurrStatus.data != undefined){
            console.log(this.wbCurrStatus.data.fields.Status__c.value);
            if(this.wbCurrStatus.data.fields.Status__c.value == "Void"){
                this.wbVoid = true;
                console.log(this.wbVoid);
            }
            else{
                this.wbVoid = false;
                console.log(this.wbVoid);
            }
            return this.wbCurrStatus.data.fields.Status__c.value;
        }
    }
    */
}