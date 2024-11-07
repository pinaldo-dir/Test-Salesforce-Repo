import { LightningElement, api, track } from 'lwc';
import { acceptedFileFormat, customLabelValues } from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import deleteMultipleFiles from '@salesforce/apex/OWCMultipleFileDeleteController.deleteMultipleFiles';

export default class OwcCertificationAndAuthorizationGarmentCmp extends LightningElement {
    // CustomLabel values
    customLabelValues = customLabelValues;
    
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

     // Toast msg
     showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}