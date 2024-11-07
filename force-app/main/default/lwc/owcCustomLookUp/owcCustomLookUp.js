import {  api, LightningElement, track, wire  } from 'lwc';
import lookUp from '@salesforce/apex/owcNewWageIntakeFormController.search';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'First Name', fieldName: 'FirstName' },
    { label: 'Middle Name', fieldName: 'MiddleName' },
    { label: 'Last Name', fieldName: 'LastName' },
    { label: 'Email', fieldName: 'PersonEmail', type: 'email' },
    { label: 'Birthdate', fieldName: 'PersonBirthdate' , type : 'date'}
    // { label: 'Phone', fieldName: 'phone', type: 'phone' },
    // { label: 'Balance', fieldName: 'amount', type: 'currency' },
    // { label: 'CloseAt', fieldName: 'closeAt', type: 'date' },
];

export default class OwcCustomLookUp extends LightningElement {

    columns = columns;
    @api objName;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Search';
    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;
    searchTerm;
    AccountData 
    modalContainer = false
    selectedId
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    // @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName'})
    // wiredRecords({ error, data }) {
    //     if (data) {
    //         this.error = undefined;
    //         this.AccountData = ''
    //         let rows = JSON.parse( JSON.stringify( data ) );
    //         console.log( 'Rows are ' + JSON.stringify( rows ) );            
                
    //         for ( let i = 0; i < rows.length; i++ ) {  

    //             let dataParse = rows[ i ];

    //             if ( dataParse.PersonBirthdate ) {
                    
    //                 let dt = new Date( dataParse.PersonBirthdate );
    //                 dataParse.PersonBirthdate = new Intl.DateTimeFormat( 'en-US' ).format( dt );
                
    //             }
    //         }
    //         this.AccountData = rows
    //         this.records = data
    //     } else if (error) {
    //         this.error = error;
    //         this.records = undefined;
    //     }
    // }

    
    connectedCallback(){
        lookUp({searchTerm : '', myObject : 'Account'})
        .then(data => {
            if(data){
                this.error = undefined;
                let rows = JSON.parse( JSON.stringify( data ) );
                console.log( 'Rows are ' + JSON.stringify( rows ) );            
                    
                for ( let i = 0; i < rows.length; i++ ) {  
    
                    let dataParse = rows[ i ];
    
                    if ( dataParse.PersonBirthdate ) {
                        
                        let dt = new Date( dataParse.PersonBirthdate );
                        dataParse.PersonBirthdate = new Intl.DateTimeFormat( 'en-US' ).format( dt );
                    
                    }
                }
                this.AccountData = rows
                this.records = data
            }
            
        })
        .catch(error => {
            this.error = error;
            this.records = undefined;
        });        
    } 

    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }
    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }
    onSelect(event) {
        this.selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  this.selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        this.modalContainer = false
         // Creates the event with the data.
        // const selectedEvent = new CustomEvent("progressvaluechange", {
        //     detail: this.progressValue
        // });
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

   

    handleRemovePill() {
        this.isValueSelected = false;
        this.selectedId = null
        const selectedEvent = new CustomEvent("updatelookupselected", {
            detail: this.selectedId
        });
        this.dispatchEvent(selectedEvent);
    }

    onChange(event) {
        this.searchTerm = event.target.value;
        console.log('searchTerm::: '+ this.searchTerm);
        lookUp({
            searchTerm : this.searchTerm, myObject : 'Account'            
        })
        .then(data =>{
            this.error = undefined;
            let rows = JSON.parse( JSON.stringify( data ) );
            console.log( 'onChange Rows are ' + JSON.stringify( rows ) );            
                
            for ( let i = 0; i < rows.length; i++ ) {  

                let dataParse = rows[ i ];

                if ( dataParse.PersonBirthdate ) {
                    
                    let dt = new Date( dataParse.PersonBirthdate );
                    dataParse.PersonBirthdate = new Intl.DateTimeFormat( 'en-US' ).format( dt );
                
                }
            }
            this.AccountData = rows
            this.records = data
        })
        .catch(error =>{
            this.error = error;
            console.log('CustomLook up else part',error)
        })
    }

    onShowAllResult(event){
        this.modalContainer = true
    }

    closeModalAction(){
        this.modalContainer=false;
       }

}