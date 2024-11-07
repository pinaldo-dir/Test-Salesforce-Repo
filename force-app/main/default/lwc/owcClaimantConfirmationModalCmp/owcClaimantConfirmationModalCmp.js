import { LightningElement, api } from 'lwc';
import OWC_helptext_cancelbutton from '@salesforce/label/c.OWC_helptext_cancelbutton';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OWC_Claimant_Confirmation from '@salesforce/label/c.OWC_Claimant_Confirmation';
import OWC_Ok from '@salesforce/label/c.OWC_Ok';
import OWC_Claimant_Confirmation_Body from '@salesforce/label/c.OWC_Claimant_Confirmation_Body';

import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcClaimantConfirmationModalCmp extends LightningElement {
    @api isPDFGenerate = false;
    @api isFormPreviewMode = false;
    @api isTwelveCmpRender = false
    connectedCallback(){
        // don’t forget to load static resources in connectedCallback. 
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
    customLabelValues = {
        OWC_helptext_cancelbutton,
        OWC_Ok,
        OWC_Claimant_Confirmation,
        OWC_Claimant_Confirmation_Body
    }
    handleCancel(){
        const selectEvent = new CustomEvent('claimantconfirmationevent', {
            detail: { 
                isCancel : true,
                isOk : false,
             }
       });
      this.dispatchEvent(selectEvent);
    }
    handleOk(){
        console.log('Click Ok');
        const selectEvent = new CustomEvent('claimantconfirmationevent', {
            detail: { 
                isOk : true,
                isCancel : false,
             }
       });
      this.dispatchEvent(selectEvent);
    }

}