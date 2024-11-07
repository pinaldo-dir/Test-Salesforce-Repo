import { LightningElement ,api, wire, track } from 'lwc';
import updateRelatedPartyAddress from '@salesforce/apex/OWCAddressCheckerUSPS.updateRelatedPartyAddress';
import getRelatedPartyAddress from '@salesforce/apex/OWCAddressCheckerUSPS.getRelatedPartyAddress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
export default class OWCUSPSAddressChecker extends LightningElement {
    @api recordId;
    @api address = [];
    @track message;

      // Toast msg
 showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
    }
    updateRecordView(recordId) {
        updateRecord({fields: { Id: recordId }});
    }

    connectedCallback(){
        const queryString = window.location.href;
        const urlList = queryString.split('/')
        // const urlParams = new URLSearchParams(queryString);
        console.log('recordId ::: ', urlList);
        this.recordId = urlList[6];
        this.getUSPSAddressData();
    }

    @track columns = [{
        label: 'Street Address',
        fieldName: 'Address2',
        type: 'text',
        sortable: true
    },
    {
        label: 'City',
        fieldName: 'City',
        type: 'text',
        sortable: true
    },
    {
        label: 'State',
        fieldName: 'State',
        type: 'text',
        sortable: true
    },
    {
        label: 'Zip Code',
        fieldName: 'Zip5',
        type: 'text',
        sortable: true
    }
];

@api showDataTable = false;
@api isLoading = false;
@api noRecordFound = false;
// @api get showDataTable(){
//     return this.address.length > 0
// }

    getUSPSAddressData(){
        this.isLoading = true;
        getRelatedPartyAddress({
            recordId : this.recordId
        })
           .then(result => {
               if(result){
                    console.log('result:', result);
                    // this.address = result.Address;
                    this.message = result.message;
                    if(this.message === 'Success'){
                        for(var i=0; i<result.Address.length; i++){
                            // result.Address[i].id = i;
                            this.address.push(result.Address[i]);
                            this.address.length > 0 ? this.showDataTable = true : false;
                            this.isLoading = false;
                        }
                        console.log('address ::: ', this.address);
                    } else{
                        this.isLoading = false;
                        this.noRecordFound = true;
                    }
                    
               }
           })
           .catch(error => {
            this.isLoading = false;
               console.log('Error: ', error);
           })
    }

    @api selectedRecords;
    // Trigger when row select 
    selectedRows(event){
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();  
        console.log('selectedRecords are ',selectedRecords);
        this.selectedRecords = selectedRecords;
    }

    handleUpdate(event){
        var selected = this.selectedRecords || '';
        if(selected == ''){
            this.showToast('Error','Please select the record first to proceed.','error');
            return;
        }
        this.isLoading = true;
        updateRelatedPartyAddress({
            selectedRecords : JSON.stringify(this.selectedRecords[0]),
            recordId : this.recordId
        })
           .then(result => {
            this.isLoading = false;
               if(result){
                    console.log('result:', result);
                    if(result === true){
                        this.showToast('Success','Record has been successfully updated.','success');
                    }
               }
           })
           .catch(error => {
            this.isLoading = false;
               console.log('Error: ', error);
           })
    }
//     @track columns = [{
//         label: 'Account name',
//         fieldName: 'Name',
//         type: 'text',
//         sortable: true
//     },
//     {
//         label: 'Type',
//         fieldName: 'Type',
//         type: 'text',
//         sortable: true
//     },
//     {
//         label: 'Annual Revenue',
//         fieldName: 'AnnualRevenue',
//         type: 'Currency',
//         sortable: true
//     },
//     {
//         label: 'Phone',
//         fieldName: 'Phone',
//         type: 'phone',
//         sortable: true
//     },
//     {
//         label: 'Website',
//         fieldName: 'Website',
//         type: 'url',
//         sortable: true
//     },
//     {
//         label: 'Rating',
//         fieldName: 'Rating',
//         type: 'test',
//         sortable: true
//     }
// ];

// @track error;
// @track accList ;
// @wire(verifyAddressByUSPS)
// verifyAddressByUSPS({
    
// }) {
//     if (data) {
//         this.accList = data;
//     } else if (error) {
//         this.error = error;
//     }
// }
}