import { LightningElement,track,api,wire } from 'lwc';
import employerData from '@salesforce/apex/owcNewWageIntakeFormController.employerData';

export default class OwcNewWageIntakeForm extends LightningElement {
    
    @api selectedAccount;
    isAccountID = false
    @api recordId;
    @api employerName;
    @api NAICScode;
    @track isValid = true;

    handleAccountSelection(event){

        this.selectedAccount = event.detail;
        console.log(' recordId::',this.recordId);
        console.log("the selected record id is"+event.detail);
        if(this.selectedAccount != null){
            this.isAccountID = true
            console.log('handleAccountSelection if part',this.isAccountID);
        }else if(this.selectedAccount == null || this.selectedAccount == undefined){
            this.isAccountID = false
            console.log('handleAccountSelection else part',this.isAccountID);
        }
        
    }

    @wire(employerData,{
        employerId: '$recordId'
    })
    wiredemployerData({ error, data }) {
        console.log('$currentrecordid::',this.recordId)
        if (data) {
            console.log('Employeer Data::',data);
            this.employerName = data.Name;
            this.NAICScode = data.NAICS_Code__c;
            if(this.NAICScode == null){
                this.isValid = false;
            }
            else{
                this.isValid = true;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }


    closeModal(){
        var url = window.location.href;
        var value = url.substring(0,url.lastIndexOf('/') + 1);
        // console.log('720 value: ', value);
        window.history.back();
        return false;
    }

    handleUpdatedAccountSelection(event){
        this.selectedAccount = event.detail;
        console.log(' recordId::',this.recordId);
        console.log("the selected record id is"+event.detail);
        if(this.selectedAccount != null){
            this.isAccountID = true
            console.log('handleUpdatedAccountSelection if part',this.isAccountID);
        }else if(this.selectedAccount == null || this.selectedAccount == undefined){
            this.isAccountID = false
            console.log('handleUpdatedAccountSelection else part',this.isAccountID);
        }
    }

}