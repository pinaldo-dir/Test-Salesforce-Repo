import { LightningElement,api, track,wire } from 'lwc';
import { customLabelValues} from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData'
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcWorkweekAndWorkdayGarmentCmp extends LightningElement {
    
    @track EmpFollowSatToSun;
    @track isEmpFollowSatToSun;
    @track EmpDefinedWorkweek;
    @track EmpFollowMidnightToMidnight;
    @track isEmpFollowMidnightToMidnight;
    @track BegDate;
    @track EndDate;
    @api WorkWeek_And_WorkDay_List;
    isRenderedCallback = false
    @api options;
    @api isFormPreviewMode = false
    @api EmpFollowSatToSunDetails
    
    @api get showWorkWeekHeading(){
        return (this.EmpFollowSatToSun !== undefined || this.EmpFollowMidnightToMidnight !== undefined) && this.isFormPreviewMode === true
    }

    customLabelValues = customLabelValues;

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

    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data,error}) {
            if(data){
                this.options = data[0].owcWorkWeekYesOrNoOptions;
                this.WorkWeek_And_WorkDay_List = data[0].owcWorkWeekAndWorkDays;
            }else{
                this.errorMsg = error;
            }
    } 

    @api workWeekValue = ''
    handleChange(event){
            event.preventDefault();
            this.isRenderedCallback = false
            switch ( event.target.name ) {    
                case "EmpFollowSatToSun":            
                     this.EmpFollowSatToSun = event.target.value
                    console.log('EmpFollowSatToSun:', this.EmpFollowSatToSun);
                    if(this.EmpFollowSatToSun === 'No'){
                        this.isEmpFollowSatToSun = true;
                    }
                    else{
                        //this.workWeekValue = 1;
                        this.isEmpFollowSatToSun = false;
                    }
                break;
                case "EmpDefinedWorkweek":
                    this.EmpDefinedWorkweek = event.target.value


                  
                    if(this.EmpDefinedWorkweek === this.WorkWeek_And_WorkDay_List[0].value){

                        this.workWeekValue = 1;
                    }
                    else if(this.EmpDefinedWorkweek === this.WorkWeek_And_WorkDay_List[1].value){
                        this.workWeekValue = 2;
                    }
                    else if(this.EmpDefinedWorkweek === this.WorkWeek_And_WorkDay_List[2].value){

                        this.workWeekValue = 3;
                    }
                    else if(this.EmpDefinedWorkweek === this.WorkWeek_And_WorkDay_List[3].value){
                        
                        this.workWeekValue = 4;
                    }
                    else if(this.EmpDefinedWorkweek === this.WorkWeek_And_WorkDay_List[4].value){
                         
                        this.workWeekValue = 5;
                    }
                    else if(this.EmpDefinedWorkweek === this.WorkWeek_And_WorkDay_List[5].value){
                         
                        this.workWeekValue = 6;
                    }
                    else if(this.EmpDefinedWorkweek === this.WorkWeek_And_WorkDay_List[6].value){
                         
                        this.workWeekValue = 7;
                    }
                    console.log('EmpDefinedWorkweek:::',this.EmpDefinedWorkweek);
                break;
                case "EmpFollowMidnightToMidnight":
                    this.EmpFollowMidnightToMidnight = event.target.value
                    console.log('EmpFollowMidnightToMidnight::',this.EmpFollowMidnightToMidnight);
                    if(this.EmpFollowMidnightToMidnight === 'No'){
                        this.isEmpFollowMidnightToMidnight = true;
                    }
                    else{
                        this.isEmpFollowMidnightToMidnight = false;
                    }
                break;
                case "BegDate":
                    this.BegDate = event.target.value
                    this.EndDate = this.BegDate;
                    console.log('BegDate::',this.BegDate); 
                break ; 
                // case "EndDate":
                //     this.EndDate = event.target.value
                //     console.log('EndDate::',this.EndDate);
                // break;                     
            }       
                
        }

        handleSaveAsDraft(){
            this.handleWorkweekAndWorkdayEvent();
            const validateEvent = new CustomEvent('owcdraftversionevent', {
                detail: {
                    isSaveAsDraft : true,
                    sectionId : "7"
                }
            });
            this.dispatchEvent(validateEvent);
        }

        handleEmpDefinedWorkweekFocus(){
            let EmpDefinedWorkweek = this.template.querySelector('[data-id="EmpDefinedWorkweek"]');            
                if(EmpDefinedWorkweek.value == undefined || EmpDefinedWorkweek.value == null || EmpDefinedWorkweek.value == ''){
                    EmpDefinedWorkweek.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    EmpDefinedWorkweek.setCustomValidity("");
                }
                EmpDefinedWorkweek.reportValidity();
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

            if(BegDate.value == null || BegDate.value == undefined || BegDate.value == ''){
                BegDate.setCustomValidity('')
                BegDate.reportValidity();
            }
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

        // @api get showWorkWeekHeading(){
        //     return this.EmpFollowSatToSun !== undefined || this.isEmpFollowSatToSun || 
        // }


    handleWorkweekAndWorkdayEvent(){  
            const selectEvent = new CustomEvent('workweekandworkdaycustomevent', {
                detail: {
                     EmpFollowSatToSun : this.EmpFollowSatToSun,
                     isEmpFollowSatToSun : this.isEmpFollowSatToSun,
                     EmpDefinedWorkweek : this.EmpDefinedWorkweek,
                     EmpFollowMidnightToMidnight : this.EmpFollowMidnightToMidnight,
                     isEmpFollowMidnightToMidnight : this.isEmpFollowMidnightToMidnight,
                     BegDate : this.BegDate,
                     EndDate : this.EndDate,  
                     workWeekValue : this.workWeekValue
                }
            });
            this.dispatchEvent(selectEvent);
        }  
        
        isEmpDefinedWorkweek = false;
        isBegDate = false;
        isEndDate = false;

        //Section validity Checker for the required fields     
    sectionValidityChecker(ids, values){
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

    //BegDate Validation with required and Past date
    begDateValidityChecker(ids, values){
        let id = ids
        let value = values
        var inputDate
        var today = new Date();
        if(value != null){
            inputDate = new Date(value.toString());
        }else{
            inputDate = value;
        }
        if(value == null || value == undefined || value == ''){
            id.setCustomValidity('')
            id.reportValidity();
        return false;
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            id.reportValidity();
        return true;
        }
    }

    //Pase Date validation for the non required date fields
    dateValidityChecker(ids, values){
        let id = ids
        let value = values
        var inputDate
        var today = new Date();
        if(value != null){
            inputDate = new Date(value.toString());
        }else{
            inputDate = value;
        }
        if(value == null || value == undefined || value == ''){
            id.setCustomValidity('')
            id.reportValidity();
        return false;
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity('Please select past date.');
            id.reportValidity();
        return true;
        }
    }
        
    isWorkweekAndWorkdayDateAcceptable = false;
        @api 
        owcWorkWeekAndWorkDayForParent(){
            // if(this.isEmpFollowSatToSun === true){
            //     let EmpDefinedWorkweek = this.template.querySelector('[data-id="EmpDefinedWorkweek"]');
            //     let EmpDefinedWorkweekValue = this.EmpDefinedWorkweek
            //     this.isEmpDefinedWorkweek = this.sectionValidityChecker(EmpDefinedWorkweek, EmpDefinedWorkweekValue);
            //     this.isEmpDefinedWorkweek === true ? EmpDefinedWorkweek.focus() : ''
            //     if(this.isEmpDefinedWorkweek === true ){
            //         const selectEvent = new CustomEvent('workweekandworkdayvalidityevent', {
            //             detail: { 
            //                 currentStep : true
            //             }
            //         });
            //         this.dispatchEvent(selectEvent);
            //     }
            //     else{
            //         this.handleWorkweekAndWorkdayEvent();
            //     }
            // }

            if(this.isEmpFollowMidnightToMidnight === true){
                if(this.BegDate == null || this.BegDate == undefined || this.BegDate == ''){
                    let BegDate = this.template.querySelector('[data-id="BegDate"]');
                            let BegDateValue = this.BegDate
                            this.isBegDate = this.begDateValidityChecker(BegDate, BegDateValue);
                            this.isBegDate === true ? BegDate.focus() : ''
                            if(this.isBegDate === true ){
                                const selectEvent = new CustomEvent('workweekandworkdayvalidityevent', {
                                    detail: { 
                                        currentStep : true
                                    }
                                });
                                this.dispatchEvent(selectEvent);
                            }
                            else{
                                this.handleWorkweekAndWorkdayEvent();
                            }
                }


            if(this.EndDate != null){
                let EndDate = this.template.querySelector('[data-id="EndDate"]');
                let EndDateValue = this.EndDate
                this.isEndDate = this.dateValidityChecker(EndDate, EndDateValue);
                this.isEndDate === true ? EndDate.focus() : ''
                if(this.isEndDate === true ){
                    const selectEvent = new CustomEvent('workweekandworkdayvalidityevent', {
                        detail: { 
                            currentStep : true
                        }
                    });
                    this.dispatchEvent(selectEvent);
                }
                else{
                    this.handleWorkweekAndWorkdayEvent();
                }
            }  
        }
        

                          
            this.handleWorkweekAndWorkdayEvent();
        }
    
        @api
        owcEmpStatusAndWagesDataForChild(strString,isFormPreviewMode){
            console.log('Details ::: ',JSON.stringify(strString))
            this.EmpFollowSatToSunDetails = strString
            this.isFormPreviewMode = isFormPreviewMode
            
            if(isNaN(strString.EmpFollowSatToSun)){
                this.template.querySelector('[data-id="EmpFollowSatToSun"]').value = strString.EmpFollowSatToSun
                this.EmpFollowSatToSun = strString.EmpFollowSatToSun
            }
            
                this.EmpDefinedWorkweek = strString.EmpDefinedWorkweek
        
            
            
            this.isEmpFollowSatToSun = strString.isEmpFollowSatToSun
            if(isNaN(strString.EmpFollowMidnightToMidnight)){
                this.template.querySelector('[data-id="EmpFollowMidnightToMidnight"]').value = strString.EmpFollowMidnightToMidnight
                this.EmpFollowMidnightToMidnight = strString.EmpFollowMidnightToMidnight
            }
            this.isEmpFollowMidnightToMidnight = strString.isEmpFollowMidnightToMidnight
            this.BegDate = strString.BegDate
            this.EndDate = strString.EndDate 
            this.workWeekValue = strString.workWeekValue
            
            this.isRenderedCallback = true
        }

        renderedCallback(){
            if(this.isEmpFollowSatToSun === true){
                if(this.EmpDefinedWorkweek != null && this.isRenderedCallback === true){
                    this.template.querySelector('[data-id="EmpDefinedWorkweek"]').value = this.EmpDefinedWorkweek
                }
            }
            if(this.isEmpFollowMidnightToMidnight === true){
                if(this.BegDate != null && this.isRenderedCallback === true){
                    this.template.querySelector('[data-id="BegDate"]').value = this.BegDate
                }
                if(this.EndDate != null && this.isRenderedCallback === true){
                    this.template.querySelector('[data-id="EndDate"]').value = this.EndDate
                }
            }
        }

        @api isHelpText = false;
        @api helpText;

        handleHelpText(event){
            const learnMoreName = event.target.name;
            this.isHelpText = true;
             if(learnMoreName === 'workweekHelptext'){
                this.isHelpText = true;
                this.helpText = this.customLabelValues.OWC_workweek_helptext;
            }
            else if(learnMoreName === 'WorkDaysHelptext'){
                this.isHelpText = true;
                this.helpText = this.customLabelValues.OWC_workdays_helptext;
            }
            
        }
    
        // Handle Help text Event
        handleHelpTextEvent(event){
            const helpTextValue = event.detail;
            this.isHelpText = helpTextValue.isClosedHelpText
        }
    
}