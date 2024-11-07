import { LightningElement, api, track } from 'lwc';
import LR_for_support from '@salesforce/label/c.LR_for_support';
import LR_Labor_Commissioner_s_Office from '@salesforce/label/c.LR_Labor_Commissioner_s_Office';
import LR_footer_copyright from '@salesforce/label/c.LR_footer_copyright';
import LR_footer_copyright_label from '@salesforce/label/c.LR_footer_copyright_label';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class LICREGFooter extends LightningElement {

    
    customLabelValues = {
        LR_footer_copyright,
        LR_footer_copyright_label,
        LR_for_support,
        LR_Labor_Commissioner_s_Office
    }


    @api isLargeDevice = false;
    @api isMediumDevice = false;
    @api isSmallDevice = false;

    @api get isOtherDevice(){
        return this.isLargeDevice === true || this.isMediumDevice === true;
    }

    @track copyRightPolicy;

    connectedCallback() {
        let currentYear =  new Date().getFullYear();
        this.copyRightPolicy = `${this.customLabelValues.LR_footer_copyright} ${currentYear} ${this.customLabelValues.LR_footer_copyright_label}`;
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

    openContactInfo(event){
        window.open('https://www.dir.ca.gov/dlse/', '_blank', 'location=yes,height=570,width=520,scrollbars=yes,status=yes');
    }
}