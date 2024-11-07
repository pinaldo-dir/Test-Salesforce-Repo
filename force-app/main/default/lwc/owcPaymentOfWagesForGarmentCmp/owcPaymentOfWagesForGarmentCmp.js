import { LightningElement,api,wire } from 'lwc';
import { radioOptions, customLabelValues, acceptedFileFormat } from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import owcFrequencyMetaData from '@salesforce/apex/OWCPaymentOfWagesController.fetchFrequencyMetaData';
import { loadStyle } from 'lightning/platformResourceLoader';
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';
import Owc_perHour from '@salesforce/label/c.Owc_perHour';
import Owc_Beginning  from '@salesforce/label/c.Owc_Beginning';
import Owc_Ending from '@salesforce/label/c.Owc_Ending';
import Owc_forActivity from '@salesforce/label/c.Owc_forActivity'
import Owc_ratePaid from '@salesforce/label/c.Owc_ratePaid'
import Owc_ratePromised from '@salesforce/label/c.Owc_ratePromised'
import Owc_perUnit from '@salesforce/label/c.Owc_perUnit'
import Owc_paidAtleasrMin from '@salesforce/label/c.Owc_paidAtleasrMin'
import Owc_lowestAmntPaid from '@salesforce/label/c.Owc_lowestAmntPaid'
import Owc_highestAmntPaid from '@salesforce/label/c.Owc_highestAmntPaid'
import OWC_save_as_draft_label from '@salesforce/label/c.OWC_save_as_draft_label'
import Owc_Additional from '@salesforce/label/c.Owc_Additional'
import Owc_oneHourlyAdditionalText from '@salesforce/label/c.Owc_oneHourlyAdditionalText'
import Owc_eachPayAdditionalText from '@salesforce/label/c.Owc_eachPayAdditionalText'
import Owc_noOfUnits from '@salesforce/label/c.Owc_noOfUnits'
import Owc_pieceOfRateText from '@salesforce/label/c.Owc_pieceOfRateText'

export default class OwcPaymentOfWagesForGarmentCmp extends LightningElement {
   
    @api lowAmntPaid
    @api highestAmntPaid
    @api payPerPeriod
    @api garmentOther
    @api paidAtleastMin
    @api recRestPeriod
    @api isRecRestPeriod = false
    @api paidSepartlyForRestPeriod
    isRenderedCallback = false  

    customlabels={
        OWC_save_as_draft_label,
        Owc_perHour,
        Owc_Beginning,
        Owc_Ending,
        Owc_forActivity,
        Owc_ratePaid,
        Owc_ratePromised,
        Owc_perUnit,
        Owc_paidAtleasrMin,
        Owc_lowestAmntPaid,
        Owc_highestAmntPaid,
        Owc_Additional,
        Owc_oneHourlyAdditionalText,
        Owc_eachPayAdditionalText,
        Owc_noOfUnits,
        Owc_pieceOfRateText,
    }

    @wire(owcFrequencyMetaData)
    wiredfetchdata({ data,error}) {
            if(data){
                this.frequency_list_type = data;
                console.log('new list'+JSON.stringify(this.frequency_list_type));
            }else{
                this.errorMsg = error;
            }
    }

    intRegrex =  /^\$?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{1,2})?$/;
    regExpPhone = /^((\\+[1-9]{1,4}[ \\-]*)|(\\([0-9]{2,3}\\)[ \\-]*)|([0-9]{2,4})[ \\-]*)*?[0-9]{3,4}?[ \\-]*[0-9]{3,4}?$/;
    customLabelValues = customLabelValues
    YesOrNoOptions = radioOptions

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

    //Handle Change Starts here
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false 
        switch ( event.target.name ) {  
            case "lowAmntPaid":            
                    this.lowAmntPaid = event.target.value;
                    console.log('lowAmntPaid ::: ', this.lowAmntPaid);
                break; 
            case "highestAmntPaid":            
                this.highestAmntPaid = event.target.value;
                console.log('highestAmntPaid ::: ', this.highestAmntPaid);
            break; 
            case "payPerPeriod":            
                this.payPerPeriod = event.target.value;
                console.log('payPerPeriod ::: ', this.payPerPeriod);
            break; 
            case "garmentOther":            
                this.garmentOther = event.target.value;
                console.log('garmentOther ::: ', this.garmentOther);
            break; 
            case "paidAtleastMin":            
                this.paidAtleastMin = event.target.value;
                console.log('paidAtleastMin ::: ', this.paidAtleastMin);
            break; 
            case "recRestPeriod":
                    this.recRestPeriod = event.target.value;
                    console.log('recRestPeriod::',this.recRestPeriod);
                    if(this.recRestPeriod == 'Yes'){
                        this.isRecRestPeriod = true;
                    }else{
                        this.isRecRestPeriod =  false;
                        this.paidSepartlyForRestPeriod = null;
                    }
                break;
            case "paidSepartlyForRestPeriod":            
                this.paidSepartlyForRestPeriod = event.target.value;
                console.log('paidSepartlyForRestPeriod ::: ', this.paidSepartlyForRestPeriod);
            break;                         
        }  
    }
    //Handle Change Ends Here

    //Handle Focus Starts Here
    handlelowAmntPaidFocus(){
        const lowAmntPaid = this.template.querySelector('[data-id="lowAmntPaid"');
        if(lowAmntPaid.value === undefined || lowAmntPaid.value === null || lowAmntPaid.value.trim() === ''){
            lowAmntPaid.setCustomValidity('');
        }
        else if(lowAmntPaid.value.match(this.intRegrex)){
            lowAmntPaid.setCustomValidity('')
        }
        else{
            lowAmntPaid.setCustomValidity(customLabelValues.OWC_EnterValidAmount)
        }
        lowAmntPaid.reportValidity()
    }

    handlehighestAmntPaidFocus(){
        const highestAmntPaid = this.template.querySelector('[data-id="highestAmntPaid"');
        if(highestAmntPaid.value === undefined || highestAmntPaid.value === null || highestAmntPaid.value.trim() === ''){
            highestAmntPaid.setCustomValidity('');
        }
        else if(highestAmntPaid.value.match(this.intRegrex)){
            highestAmntPaid.setCustomValidity('')
        }
        else{
            highestAmntPaid.setCustomValidity(customLabelValues.OWC_EnterValidAmount)
        }
        highestAmntPaid.reportValidity()
    }

    handleReceiveRestPeriodFocus(){
        let recRestPeriod = this.template.querySelector('[data-id="recRestPeriod"]');
                if(recRestPeriod.value.trim() == undefined || recRestPeriod.value.trim() == null || recRestPeriod.value.trim() == ''){
                    recRestPeriod.setCustomValidity('customLabelValues.OWC_required_field_error_msg');
                }
                else{
                    recRestPeriod.setCustomValidity("");
                }
                recRestPeriod.reportValidity();
    }

    handlepaidSepartlyForRestPeriodFocus(){
        let paidSepartlyForRestPeriod = this.template.querySelector('[data-id="paidSepartlyForRestPeriod"]');            
        if(paidSepartlyForRestPeriod.value == undefined || paidSepartlyForRestPeriod.value == null || paidSepartlyForRestPeriod.value == ''){
            paidSepartlyForRestPeriod.setCustomValidity('');
        }
        else{
            paidSepartlyForRestPeriod.setCustomValidity("");
        }
        paidSepartlyForRestPeriod.reportValidity();
    }

    handlepaidAtleastMinFocus(){
        let paidAtleastMin = this.template.querySelector('[data-id="paidAtleastMin"]');
                if(paidAtleastMin.value.trim() == undefined || paidAtleastMin.value.trim() == null || paidAtleastMin.value.trim() == ''){
                    paidAtleastMin.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    paidAtleastMin.setCustomValidity("");
                }
                paidAtleastMin.reportValidity();
    }
    //Handle  Event
    @api
    handleEvent(){
        const selectEvent = new CustomEvent('powgarmentcustomevent', {
            detail: {
                lowAmntPaid :  this.lowAmntPaid,
                highestAmntPaid : this.highestAmntPaid, 
                payPerPeriod : this.payPerPeriod,
                garmentOther : this.garmentOther,
                paidAtleastMin : this.paidAtleastMin,
                recRestPeriod : this.recRestPeriod,
                isRecRestPeriod : this.isRecRestPeriod,
                paidSepartlyForRestPeriod : this.paidSepartlyForRestPeriod, 
            }
        });
        this.dispatchEvent(selectEvent);
    }

    //Validatity Checker
    paymentOfWagesSectionValidityChecker(ids, values){
        let id = ids
        let value = values
        console.log('Value:', value);
        const val = value == undefined || value == null ? '' : value
        if(val.trim() == ""){
            id.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            id.reportValidity();
            return true;
        }
    }

    islowAmntPaid = false
    ishighestAmntPaid = false
    ispaidAtleastMin = false
    isrecRestPeriod = false

    //Sending Values to Parent Cmp
    @api 
    owcPaymentOfWagesForGarmentFromParent(){
            const highestAmntPaid = this.template.querySelector('[data-id="highestAmntPaid"]');
                if(!(highestAmntPaid.value === undefined || highestAmntPaid.value === null || highestAmntPaid.value === '' )){
                if(highestAmntPaid.value.match(this.intRegrex)){
                highestAmntPaid.setCustomValidity("");
                this.ishighestAmntPaid = false
                highestAmntPaid.reportValidity()
                }
                else{
                    highestAmntPaid.setCustomValidity(customLabelValues.OWC_EnterValidAmount);
                    this.ishighestAmntPaid = true
                    highestAmntPaid.reportValidity()
                } 
            }

            const lowAmntPaid = this.template.querySelector('[data-id="lowAmntPaid"]');
            if(!(lowAmntPaid.value === undefined || lowAmntPaid.value === null || lowAmntPaid.value === '' )){
                if(lowAmntPaid.value.match(this.intRegrex)){
                lowAmntPaid.setCustomValidity("");
                this.islowAmntPaid = false
                lowAmntPaid.reportValidity()
                }
                else{
                    lowAmntPaid.setCustomValidity(customLabelValues.OWC_EnterValidAmount);
                    this.islowAmntPaid = true
                    lowAmntPaid.reportValidity()
                } 
            }

            let paidAtleastMin = this.template.querySelector('[data-id="paidAtleastMin"]');
            let paidAtleastMinValue = this.paidAtleastMin
            this.ispaidAtleastMin = this.paymentOfWagesSectionValidityChecker(paidAtleastMin, paidAtleastMinValue);
            this.ispaidAtleastMin === true ? paidAtleastMin.focus() : ''
            

            let recRestPeriod = this.template.querySelector('[data-id="recRestPeriod"]');
            let recRestPeriodValue = this.recRestPeriod
            this.isrecRestPeriod = this.paymentOfWagesSectionValidityChecker(recRestPeriod, recRestPeriodValue);
            this.isrecRestPeriod === true ? recRestPeriod.focus() : ''
            if(this.ishighestAmntPaid === true || this.islowAmntPaid === true || this.ispaidAtleastMin === true || this.isrecRestPeriod === true){
                const selectEvent = new CustomEvent('paymentofwagesforgarmentvalidityevent', {
                    detail: { 
                        currentStep : true
                    }
                });
                this.dispatchEvent(selectEvent);
                return;
            }
            else{
                this.handleEvent();
            }      

            this.handleEvent();
    }

    //Recieveing Value From Parent
    @api isFormPreviewMode = false

    @api 
    owcPaymentOfWagesForGarmentForChild(strString, isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode
        console.log("Garment data:::" ,JSON.stringify(strString))
        
        this.lowAmntPaid = strString.lowAmntPaid,
        this.highestAmntPaid = strString.highestAmntPaid,
        this.payPerPeriod = strString.payPerPeriod,
        this.garmentOther = strString.garmentOther,
        this.paidAtleastMin =  strString.paidAtleastMin,
        this.recRestPeriod = strString.recRestPeriod        
        this.isRecRestPeriod = strString.isRecRestPeriod
        this.paidSepartlyForRestPeriod = strString.paidSepartlyForRestPeriod 

        
        this.isRenderedCallback = true
    }


}