import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OWC_hepttext_header from '@salesforce/label/c.OWC_hepttext_header';
import OWC_dlse_Part1 from '@salesforce/label/c.OWC_dlse_Part1';
import OWC_dlse_Part2 from '@salesforce/label/c.OWC_dlse_Part2';
import OWC_dlse_Part3 from '@salesforce/label/c.OWC_dlse_Part3';
import OWC_dlse_Part4 from '@salesforce/label/c.OWC_dlse_Part4';
import OWC_workweek_helptext from '@salesforce/label/c.OWC_workweek_helptext';
import OWC_workdays_helptext from '@salesforce/label/c.OWC_workdays_helptext';
import OWC_Demo_Instruct0 from '@salesforce/label/c.OWC_Demo_Instruct0';
import OWC_Demo_Instruct1 from '@salesforce/label/c.OWC_Demo_Instruct1';
import OWC_Demo_Instruct2 from '@salesforce/label/c.OWC_Demo_Instruct2';
import OWC_Demo_Instruct3 from '@salesforce/label/c.OWC_Demo_Instruct3';
import OWC_Demo_Instruct4 from '@salesforce/label/c.OWC_Demo_Instruct4';
import OWC_Demo_Race_1_text from '@salesforce/label/c.OWC_Demo_Race_1_text';
import OWC_Demo_Race_2_text from '@salesforce/label/c.OWC_Demo_Race_2_text';
import OWC_Demo_Race_3_text from '@salesforce/label/c.OWC_Demo_Race_3_text';
import OWC_helptext_cancelbutton from '@salesforce/label/c.OWC_helptext_cancelbutton';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
export default class OWCHelpTextCmp extends LightningElement {
    @api helptext;
    @api ismultiplefileuploadhelptext;
    @api isimage
    @api isdlseformhelptext;
    @api issickleavehelptext;
    @api isworkweekhelptext;
    @api isdemograhictext;
    @api isracedemoinfotext;

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

    customLabelValues = {
        OWC_Demo_Race_1_text,
        OWC_Demo_Race_2_text,
        OWC_Demo_Race_3_text,
        OWC_Demo_Instruct0,
        OWC_Demo_Instruct1,
        OWC_Demo_Instruct2,
        OWC_Demo_Instruct3,
        OWC_Demo_Instruct4,
        OWC_hepttext_header,
        OWC_helptext_cancelbutton,
        OWC_dlse_Part1,
        OWC_dlse_Part2,
        OWC_dlse_Part3,
        OWC_dlse_Part4,
        OWC_workdays_helptext,
        OWC_workweek_helptext
    }
    closeModal(event){
        const selectEvent = new CustomEvent('helptextevent', {
            detail: { 
                isClosedHelpText : false
             }
       });
      this.dispatchEvent(selectEvent);
    }
}