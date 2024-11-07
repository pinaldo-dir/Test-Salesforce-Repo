import { LightningElement, api,wire,track } from 'lwc';
import { radioOptions, customLabelValues} from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import { loadStyle } from 'lightning/platformResourceLoader';  
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';   
import OWCPaystubImage from '@salesforce/resourceUrl/OWCPaystubImage';


export default class OWCGarmentEmployeeOptionCmp extends LightningElement {
    
    @track BegDate;
    @track EndDate;
    @track paidbypiecerate;
    isBegDate = false
    isEndDate = false
    isFormPreviewMode = false
    
    // Custom label values
    customLabelValues = customLabelValues
    // Radio group options
    options = radioOptions
    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`
    // This method will load static resources in connectedCallback.
    connectedCallback(){ 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
    });
    
    }
    // Toast message
    showToast(title, message, variant) {
       const event = new ShowToastEvent({
           title: title,
           message: message,
           variant: variant
       });
       this.dispatchEvent(event);
    }
   
    //Help Text handler
    handleHelpText(event){
        const learnMoreName = event.target.name;
        this.isHelpText = true;
        if(learnMoreName === "dateOfHireHelpText"){
            this.helpText = customLabelValues.OWC_Date_Of_Hire_helptext; 
            this.isImageAvailable = null
        }
    }
    //Handle Help Text
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }
    //Handle Change for storing the fields values in the variables
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {    
            
            case "BegDate":
                    this.BegDate = event.target.value
                    //this.EndDate = this.BegDate;
                    console.log('BegDate::',this.BegDate); 
                break ; 
            case "EndDate":
                this.EndDate = event.target.value
                console.log('EndDate::',this.EndDate);
            break;
            case "paidbypiecerate":
                this.paidbypiecerate = event.target.value
                console.log('paidbypiecerate::',this.paidbypiecerate);
            break;
              
                 
        }     
    }
    //Beg Date Focus
    handleBegDateFocus(){
        let BegDate = this.template.querySelector('[data-id="BegDate"]');
        let EndDate = this.template.querySelector('[data-id="EndDate"]');
        let id = BegDate
        let value = BegDate.value
        var inputStartDate
        var inputEndDate
        var today = new Date();
        
        if(value != null){
            inputStartDate = new Date(value.toString());
            inputEndDate = new Date(EndDate.value.toString())
        }
        else{
            inputStartDate = value;
            inputEndDate = EndDate.value;
        }

        // if(BegDate.value == null || BegDate.value == undefined || BegDate.value == ''){
        //     BegDate.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
        //     BegDate.reportValidity();
        // }
         if(inputStartDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            id.reportValidity();
        }else if(inputStartDate.setHours(0,0,0,0) > inputEndDate.setHours(0,0,0,0)){
            id.setCustomValidity(customLabelValues.OWC_begdate_error_msg)
            EndDate.setCustomValidity(customLabelValues.OWC_enddate_error_msg)
            id.reportValidity();
            EndDate.reportValidity();
        }else{
            id.setCustomValidity('');
            EndDate.setCustomValidity('')
            EndDate.reportValidity();
            id.reportValidity();
        }
    }

        //End Date Focus
    handleEndDateFocus(){
        let BegDate = this.template.querySelector('[data-id="BegDate"]');
        let EndDate = this.template.querySelector('[data-id="EndDate"]');
        let id = EndDate
        let value = EndDate.value
        var inputStartDate
        var inputEndDate
        var today = new Date();
        if(value != null){
            inputEndDate = new Date(value.toString());
            inputStartDate = new Date(BegDate.value.toString())
        }
        else{
            inputEndDate = value;
            inputStartDate = inputStartDate.value;
        }
        if(inputEndDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            id.reportValidity();
        }
        else if(inputStartDate.setHours(0,0,0,0) > inputEndDate.setHours(0,0,0,0)){
            id.setCustomValidity(customLabelValues.OWC_enddate_error_msg)
            BegDate.setCustomValidity(customLabelValues.OWC_begdate_error_msg)
            BegDate.reportValidity();
            id.reportValidity();
        }
        else{
            BegDate.setCustomValidity('');
            BegDate.reportValidity();
            id.setCustomValidity('');
            id.reportValidity();
        }
    }
    
    // This Method store all the value of its component
    handlegarmentEmpEvent(){  
        const selectEvent = new CustomEvent('garmentempinfoevent', {
            detail: {
                BegDate : this.BegDate,
                EndDate : this.EndDate,  
                paidbypiecerate : this.paidbypiecerate,
                
            }
        });
        this.dispatchEvent(selectEvent);
    }
    // This Method make current step true
    handleCustomValidityEvent(){
        const selectEvent = new CustomEvent('garmentempvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.dispatchEvent(selectEvent);
    }
    // This Method will check validation and also send value to parent
    @api
    owcGaremntEmpDataForParent(){
        // if(this.BegDate !== null || this.BegDate !== undefined || this.BegDate !== ''){
        //     let BegDate = this.template.querySelector('[data-id="BegDate"]');
        //             let BegDateValue = this.BegDate
        //             this.isBegDate = this.begDateValidityChecker(BegDate, BegDateValue);
        //             this.isBegDate === true ? BegDate.focus() : ''
        //             if(this.isBegDate === true ){
        //                 const selectEvent = new CustomEvent('garmentempvalidityevent', {
        //                     detail: { 
        //                         currentStep : true
        //                     }
        //                 });
        //                 this.dispatchEvent(selectEvent);
        //             }
        //             else{
        //                 this.handlegarmentEmpEvent();
        //             }
        // }

        // if(this.EndDate != null){
        //     let EndDate = this.template.querySelector('[data-id="EndDate"]');
        //     let EndDateValue = this.EndDate
        //     this.isEndDate = this.dateValidityChecker(EndDate, EndDateValue);
        //     this.isEndDate === true ? EndDate.focus() : ''
        //     if(this.isEndDate === true ){
        //         const selectEvent = new CustomEvent('garmentempvalidityevent', {
        //             detail: { 
        //                 currentStep : true
        //             }
        //         });
        //         this.dispatchEvent(selectEvent);
        //     }
        //     else{
        //         this.handlegarmentEmpEvent();
        //     }
        // } 
        
        this.handlegarmentEmpEvent();
    }
    // This Method will fetch values from parent component
    @api
    owcGarmentEmpDataForChild(strString, isFormPreviewMode){
        console.log('Emp Garment Data::',JSON.stringify(strString))
        console.log('Emp Garment isFormPreviewMode::',isFormPreviewMode)
        this.isFormPreviewMode = isFormPreviewMode

        if(Boolean(strString)){
            this.BegDate = strString.BegDate
            this.EndDate = strString.EndDate 
            this.paidbypiecerate = strString.paidbypiecerate
        }

        
        
        this.isRenderedCallback = true
    }
    // This Method will fetch values from parent component and store in fields
    renderedCallback(){
        if(this.BegDate != null && this.isRenderedCallback === true){
            this.template.querySelector('[data-id="BegDate"]').value = this.BegDate
        }
        if(this.EndDate != null && this.isRenderedCallback === true){
            this.template.querySelector('[data-id="EndDate"]').value = this.EndDate
        }
    }
}