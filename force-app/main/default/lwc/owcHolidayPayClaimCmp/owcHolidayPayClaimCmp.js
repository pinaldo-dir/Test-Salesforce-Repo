import { LightningElement, api, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
export default class OwcHolidayPayClaimCmp extends LightningElement {

    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    customLabelValues = customLabelValues;
    @api isHelpText= false;
    @api helpText;
    // Help text 
    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === "hourlyRateMsg"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_holiday_rate_helptextmsg;
        }
    }
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }

handleChange (event){
    
}
}