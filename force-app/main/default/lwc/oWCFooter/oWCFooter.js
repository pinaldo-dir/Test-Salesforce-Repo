import { LightningElement, api, track } from 'lwc';
import OWC_for_support from '@salesforce/label/c.OWC_for_support';
import OWC_Labor_Commissioner_s_Office from '@salesforce/label/c.OWC_Labor_Commissioner_s_Office';
import OWC_for_support_email from '@salesforce/label/c.OWC_for_support_email';
import OWC_email_address from '@salesforce/label/c.OWC_email_address';
import OWC_footer_copyright from '@salesforce/label/c.OWC_footer_copyright';
import OWC_footer_copyright_label from '@salesforce/label/c.OWC_footer_copyright_label';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class OWCFooter extends LightningElement {

    
    customLabelValues = {
        OWC_footer_copyright,
        OWC_footer_copyright_label,
        OWC_for_support,
        OWC_Labor_Commissioner_s_Office,
        OWC_for_support_email,
        OWC_email_address
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
        this.copyRightPolicy = `${this.customLabelValues.OWC_footer_copyright} ${currentYear} ${this.customLabelValues.OWC_footer_copyright_label}`;
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
        window.open('mailto:onlinewageclaim@dir.ca.gov', '_blank', 'location=yes,height=570,width=520,scrollbars=yes,status=yes');
    }
}