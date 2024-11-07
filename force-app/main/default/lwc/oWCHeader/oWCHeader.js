import { LightningElement, api, track, wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
// Import static resources
import HeaderCaGov from '@salesforce/resourceUrl/HeaderCaGov';
import HeaderCaBear from '@salesforce/resourceUrl/HeaderCaBear';

export default class OWCHeader extends LightningElement {


    @api isLargeDevice = false
    @api isMediumDevice = false;
    @api isSmallDevice = false;
    @api HeaderCaGov 
    @api HeaderCaBear

    HeaderCaGov = HeaderCaGov
    HeaderCaBear = HeaderCaBear


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

        // Detect Logged in device
        switch(FORM_FACTOR) {
            case 'Large':
                this.isLargeDevice = true;
                break;
            case 'Medium':
                this.isMediumDevice = true;
                break;
            case 'Small':
                this.isSmallDevice = true;
                break;
        }
    }

}