import { LightningElement } from 'lwc';
import OWC_Online_Wage_Claim from '@salesforce/label/c.OWC_Online_Wage_Claim'
import OWC_OnlineWageClaimWelcomPartI from '@salesforce/label/c.OWC_OnlineWageClaimWelcomPartI'
import OWC_OnlineWageClaimWelcomPartII from '@salesforce/label/c.OWC_OnlineWageClaimWelcomPartII'
import OWC_OnlineWageClaimLiPartI from '@salesforce/label/c.OWC_OnlineWageClaimLiPartI'
import OWC_OnlineWageClaimLiPartII from '@salesforce/label/c.OWC_OnlineWageClaimLiPartII'
import OWC_OnlineWageClaimLiPartIII from '@salesforce/label/c.OWC_OnlineWageClaimLiPartIII'
import OWC_OnlineWageClaimLiPartIV from '@salesforce/label/c.OWC_OnlineWageClaimLiPartIV'
import OWC_OnlineWageClaimLiPartV from '@salesforce/label/c.OWC_OnlineWageClaimLiPartV'
import OWC_OnlineWageClaimLiPartVI from '@salesforce/label/c.OWC_OnlineWageClaimLiPartVI'
import OWC_OnlineWageClaimLiPart from '@salesforce/label/c.OWC_OnlineWageClaimLiPart'
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcPlaceholderCmp extends LightningElement {
    customlabelValue = {
        OWC_OnlineWageClaimLiPart,
        OWC_Online_Wage_Claim,
        OWC_OnlineWageClaimWelcomPartI,
        OWC_OnlineWageClaimWelcomPartII,
        OWC_OnlineWageClaimLiPartI,
        OWC_OnlineWageClaimLiPartII,
        OWC_OnlineWageClaimLiPartIII,
        OWC_OnlineWageClaimLiPartIV,
        OWC_OnlineWageClaimLiPartV,
        OWC_OnlineWageClaimLiPartVI,
    }

    connectedCallback(){
        // don’t forget to load static resources in connectedCallback . 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
            console.log( 'Files loaded' );
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error')
            console.log( error.body.message );
    });
    }
}