import { LightningElement, api, track, wire } from 'lwc';
import OWC_file_delete_yes_button from '@salesforce/label/c.OWC_file_delete_yes_button';
import OWC_file_delete_no_button from '@salesforce/label/c.OWC_file_delete_no_button';
import OWC_filedelete_popup_header from '@salesforce/label/c.OWC_filedelete_popup_header';
import OWC_filedelete_confirmation_msg from '@salesforce/label/c.OWC_filedelete_confirmation_msg';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcMultipleFileDeleteCmp extends LightningElement {
    @api filename

    customLabelValues = {
        OWC_file_delete_yes_button,
        OWC_file_delete_no_button,
        OWC_filedelete_popup_header,
        OWC_filedelete_confirmation_msg
    }

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

    handleDeleteFile(event){
        const selectEvent = new CustomEvent('deletemsgevent', {
            detail: { 
                isClosedHelpText : false,
                isFileDeleted : true
             }
       });
      this.dispatchEvent(selectEvent);
    }

    handleCloseModal(){
        const selectEvent = new CustomEvent('undeletemsgevent', {
            detail: { 
                isClosedHelpText : false,
                isFileDeleted : false
             }
       });
      this.dispatchEvent(selectEvent);
    }

    closeModal(event){
        const selectEvent = new CustomEvent('closedmodalboxevent', {
            detail: { 
                isClosedHelpText : false,
             }
       });
      this.dispatchEvent(selectEvent);
    }
}