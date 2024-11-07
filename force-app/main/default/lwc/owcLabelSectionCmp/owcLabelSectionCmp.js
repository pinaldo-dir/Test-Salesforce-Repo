import { LightningElement ,api,track,wire} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { radioOptions, acceptedFileFormat } from 'c/owcUtils';
import OWC_Info_For_RN from '@salesforce/label/c.OWC_Info_For_RN';
import OWC_Garments_Description from '@salesforce/label/c.OWC_Garments_Description';
import OWC_Make_Garments from '@salesforce/label/c.OWC_Make_Garments';
import OWC_Delivery_Address from '@salesforce/label/c.OWC_Delivery_Address';
import OWC_Delivery_Company from '@salesforce/label/c.OWC_Delivery_Company';
import OWC_Person_Visit from '@salesforce/label/c.OWC_Person_Visit';
import OWC_WorkingWithLabel from '@salesforce/label/c.OWC_WorkingWithLabel';
import OWC_IfSpokeWhatSay from '@salesforce/label/c.OWC_IfSpokeWhatSay';
import OWC_Found_Mistake from '@salesforce/label/c.OWC_Found_Mistake';
import OWC_OvertimeToCorrectMistake from '@salesforce/label/c.OWC_OvertimeToCorrectMistake';
import OWC_OvertimeToMeetDeadline from '@salesforce/label/c.OWC_OvertimeToMeetDeadline';
import OWC_Label_Priority from '@salesforce/label/c.OWC_Label_Priority';
import OWC_WorkOnSpecificLabel from '@salesforce/label/c.OWC_WorkOnSpecificLabel';
import OWC_WorkOnLabel from '@salesforce/label/c.OWC_WorkOnLabel';
import OWC_Start_Date from '@salesforce/label/c.OWC_Start_Date';
import OWC_End_Date from '@salesforce/label/c.OWC_End_Date';
import OWC_provideThePerc from '@salesforce/label/c.OWC_provideThePerc';
import OWC_label_info_heading from '@salesforce/label/c.OWC_label_info_heading';
import OWC_Info_For_RNHelpText from '@salesforce/label/c.OWC_Info_For_RNHelpText';
import OWC_LableNameAndRNHelpText from '@salesforce/label/c.OWC_LableNameAndRNHelpText';
import OWC_Garment_SewedSample from '@salesforce/label/c.OWC_Garment_SewedSample';
import OWC_Person_Name from '@salesforce/label/c.OWC_Person_Name';
import OWC_Apart_FromSupervisorCheck from '@salesforce/label/c.OWC_Apart_FromSupervisorCheck';
import OWC_pastdate_error_msg from '@salesforce/label/c.OWC_pastdate_error_msg';
import OWC_validdate_error_ms from '@salesforce/label/c.OWC_validdate_error_ms';
import OWC_hepttext_header from '@salesforce/label/c.OWC_hepttext_header';
import OWC_startdate_error_msg from '@salesforce/label/c.OWC_startdate_error_msg';
import OWC_date_format_label from '@salesforce/label/c.OWC_date_format_label';
import OWC_fileupload_success_toast_msg from '@salesforce/label/c.OWC_fileupload_success_toast_msg';
import OWC_multiple_file_delete_toast_msg from '@salesforce/label/c.OWC_multiple_file_delete_toast_msg';
import OWC_label_delete_button from '@salesforce/label/c.OWC_label_delete_button';
import { ShowToastEvent } from 'lightning/platformShowToastEvent' 
import OWC_Yes from '@salesforce/label/c.OWC_Yes';
import OWC_select_picklist_label from '@salesforce/label/c.OWC_select_picklist_label';
import OWC_RnUploadDoc from '@salesforce/label/c.OWC_RnUploadDoc';
	

import OWC_No from '@salesforce/label/c.OWC_No';
import OWC_multiplefileupload_helptext from '@salesforce/label/c.OWC_multiplefileupload_helptext';
import OWC_learnmore_button from '@salesforce/label/c.OWC_learnmore_button';
//import fetchMetaData from '@salesforce/apex/OWCLabelInfoController.fetchMetaData'
import fetchMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData'
import OWC_date_placeholder from '@salesforce/label/c.OWC_date_placeholder'


import Owc_fillBothDate_Fields from '@salesforce/label/c.Owc_fillBothDate_Fields';
import OWC_begdate_error_msg from '@salesforce/label/c.OWC_begdate_error_msg'
import OWC_enddate_error_msg from '@salesforce/label/c.OWC_enddate_error_msg'
import OWC_required_field_error_msg from '@salesforce/label/c.OWC_required_field_error_msg'
import OWC_Other from '@salesforce/label/c.OWC_Other'
import OWC_Delivery_Comp_Name from '@salesforce/label/c.OWC_Delivery_Comp_Name'




export default class OwcLabelSectionCmp extends LightningElement {
    @api islabelPercPerDay = false;
    @api isMoreThanOne;
    @api labelGarmentDescription;
    @api labelGarmentsDuration;
    @api labelGarmentDelAdd;
    @api labelGarmentDelAddCompName;
    @api labelPersonVisit;
    @api labelTheyWereWorking;
    @api labelWhatTheySay;
    @api labelWhatIfMistakFound;
    @api labelWorkOverTime;
    @api labelWorkOverTimeDeadline;
    @api labelPriority;
    @api labelPercPerDay;
    @api labelPercProvided;
    @api labelStartDate;
    @api labelEndDate;
    @api namePersonVisit;
    @api sampleOfGarment;
    @api isRenderedCallback = false;
    @api isFileUploaded = false;
    @api garmentLabelOptions;
    // HelpText Attributes
    @api isHelpText = false
    @api helpText
    @api labelheading
    @api uploadLabelSection
    @api uploadRNDocument;
    @api uploadFileSize;
    @api toastFileUploadMsg = OWC_fileupload_success_toast_msg
    @api toastFileDeleteMsg = OWC_multiple_file_delete_toast_msg

    @api deletebutton
    @api sectionid
    @api Other
    @api isOther = false
    @api labelName
    @api superVisorCheck
    @track isSuperVisorCheck = false

    @api isFormPreviewMode = false
    @api labelSectionDetails

    islabelGarmentDescription = false;
    islabelGarmentsDuration = false;
    islabelPercPerDayValChecker = false;

    get acceptedFormats() {
        return acceptedFileFormat;
    }

    get showLabelFields(){
        return Boolean(this.labelName)
    }

    customLabelValues = { 
        OWC_multiplefileupload_helptext,
        OWC_learnmore_button, 
        OWC_label_delete_button, 
        OWC_Info_For_RN,
        OWC_Garments_Description,
        OWC_Make_Garments,
        OWC_Delivery_Address,
        OWC_Delivery_Company,
        OWC_Person_Visit,
        OWC_WorkingWithLabel,
        OWC_IfSpokeWhatSay,
        OWC_Found_Mistake,
        OWC_OvertimeToCorrectMistake,
        OWC_OvertimeToMeetDeadline,
        OWC_Label_Priority,
        OWC_WorkOnSpecificLabel,
        OWC_WorkOnLabel,
        OWC_Start_Date,
        OWC_End_Date,
        OWC_provideThePerc,
        OWC_label_info_heading,
        OWC_Info_For_RNHelpText,
        OWC_Garment_SewedSample,
        OWC_Person_Name,
        OWC_Apart_FromSupervisorCheck,
        OWC_hepttext_header,
        OWC_date_placeholder,
        Owc_fillBothDate_Fields,
        OWC_pastdate_error_msg,
        OWC_begdate_error_msg,
        OWC_enddate_error_msg,
        OWC_date_format_label,
        OWC_select_picklist_label,
        OWC_required_field_error_msg,
        OWC_Other,
        OWC_LableNameAndRNHelpText,
        OWC_RnUploadDoc,
        OWC_Delivery_Comp_Name,
    }

    @api dateFormatLabel = `(${OWC_date_format_label})`
    

    @wire(fetchMetaData)
    fetchMetaData({ data,error}) {
            if(data){
                this.garmentLabelOptions = data[0].owcLabelSectionOptions;
            }else{
                this.errorMsg = error;
            }
    } 

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
    //Yes or No PickList
    options = radioOptions

    handleLabelDelete(event){
        event.preventDefault()
        const selectEvent = new CustomEvent('customlabeldeleteevent', {
            detail: {
                sectionId : this.sectionid
            }
        });
        this.dispatchEvent(selectEvent);
    }

    @api
    handleLabelSectionData(){
        const selectEvent = new CustomEvent('labelsectiondeleteevent', {
            detail: {
                 sectionId : this.sectionid,
                 labelName : this.labelName,
                 labelGarmentDescription : this.labelGarmentDescription,
                 labelGarmentsDuration : this.labelGarmentsDuration,
                 isOther : this.isOther, 
                 Other : this.Other, 
                 labelGarmentDelAddCompName : this.labelGarmentDelAddCompName,
                 labelPersonVisit : this.labelPersonVisit,
                 labelTheyWereWorking : this.labelTheyWereWorking,
                 labelWhatTheySay : this.labelWhatTheySay,
                 labelWhatIfMistakFound : this.labelWhatIfMistakFound,
                 labelWorkOverTime : this.labelWorkOverTime,
                 labelWorkOverTimeDeadline : this.labelWorkOverTimeDeadline,
                 labelPriority : this.labelPriority,
                 labelStartDate : this.labelStartDate,
                 labelEndDate : this.labelEndDate,
                 islabelPercPerDay : this.islabelPercPerDay,
                 namePersonVisit : this.namePersonVisit,
                 sampleOfGarment : this.sampleOfGarment,
                 labelGarmentDelAdd : this.labelGarmentDelAdd,
                 labelPercPerDay : this.labelPercPerDay,
                 labelPercProvided : this.labelPercProvided,
                 uploadFileSize : this.uploadFileSize,
                 uploadRNDocument : this.uploadRNDocument,
                 uploadLabelSection : this.uploadLabelSection,
                 isFileUploaded : this.isFileUploaded,
                 superVisorCheck : this.superVisorCheck, 
                isSuperVisorCheck : this.isSuperVisorCheck,  
                  
            }            
        },
        );
        this.dispatchEvent(selectEvent);
    }

    @api
    handleLabelSectionEvent(){
        const selectEvent = new CustomEvent('labelsectioncustomevent', {
            detail: {
                sectionId : this.sectionid,
                labelName : this.labelName,
                labelGarmentDescription : this.labelGarmentDescription,
                labelGarmentsDuration : this.labelGarmentsDuration,
                isOther : this.isOther, 
                Other : this.Other, 
                labelGarmentDelAddCompName : this.labelGarmentDelAddCompName,
                labelPersonVisit : this.labelPersonVisit,
                labelTheyWereWorking : this.labelTheyWereWorking,
                labelWhatTheySay : this.labelWhatTheySay,
                labelWhatIfMistakFound : this.labelWhatIfMistakFound,
                labelWorkOverTime : this.labelWorkOverTime,
                labelWorkOverTimeDeadline : this.labelWorkOverTimeDeadline,
                labelPriority : this.labelPriority,
                labelStartDate : this.labelStartDate,
                labelEndDate : this.labelEndDate,
                islabelPercPerDay : this.islabelPercPerDay,
                namePersonVisit : this.namePersonVisit,
                sampleOfGarment : this.sampleOfGarment,
                labelGarmentDelAdd : this.labelGarmentDelAdd,
                labelPercPerDay : this.labelPercPerDay,
                labelPercProvided : this.labelPercProvided,
                uploadFileSize : this.uploadFileSize,
                uploadRNDocument : this.uploadRNDocument,
                uploadLabelSection : this.uploadLabelSection,
                isFileUploaded : this.isFileUploaded ,
                superVisorCheck : this.superVisorCheck, 
                isSuperVisorCheck : this.isSuperVisorCheck,   
            }            
        },
        );
        this.dispatchEvent(selectEvent);
    }

    handlelabelStartDateFocus(event){
        let labelStartDate = this.template.querySelector('[data-id="labelStartDate"]');
        let labelEndDate = this.template.querySelector('[data-id="labelEndDate"]');
        let id = labelStartDate
        let value = labelStartDate.value
        var inputStartDate
        var inputEndDate
        var today = new Date();
        if(value != null){
            inputStartDate = new Date(value.toString());
            inputEndDate = new Date(labelEndDate.value.toString())
        }
        else{
            inputStartDate = value;
            inputEndDate = labelEndDate.value;
        }
        if(inputStartDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(OWC_pastdate_error_msg);
            id.reportValidity();
        }
        else if(inputStartDate.setHours(0,0,0,0) > inputEndDate.setHours(0,0,0,0)){
            id.setCustomValidity(OWC_startdate_error_msg)
            labelEndDate.setCustomValidity(OWC_validdate_error_ms)
            id.reportValidity();
            labelEndDate.reportValidity()
        }
        else{
            id.setCustomValidity('');
            labelEndDate.setCustomValidity('')
            id.reportValidity();
            labelEndDate.reportValidity()
        }
        
    }

    handleLableEndDateFocus(){
        let labelEndDate = this.template.querySelector('[data-id="labelEndDate"]');
        let labelStartDate = this.template.querySelector('[data-id="labelStartDate"]');
        let id = labelEndDate
        let value = labelEndDate.value
        var inputStartDate
        var inputEndDate
        var today = new Date();
        if(value != null){
            inputEndDate = new Date(value.toString());
            inputStartDate = new Date(labelStartDate.value.toString())
        }
        else{
            inputEndDate = value;
            inputStartDate = inputStartDate.value;
        }
        if(inputEndDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(OWC_pastdate_error_msg);
            id.reportValidity();
        }
        else if(inputStartDate.setHours(0,0,0,0) > inputEndDate.setHours(0,0,0,0)){
            id.setCustomValidity(OWC_validdate_error_ms)
            labelStartDate.setCustomValidity(OWC_startdate_error_msg)
            labelStartDate.reportValidity()
            id.reportValidity();
        }
        else{
            labelStartDate.setCustomValidity('')
            labelStartDate.reportValidity()
            id.setCustomValidity('');
            id.reportValidity();
        }
        
        // let labelEndDate = this.template.querySelector('[data-id="labelEndDate"]');
        // let id = labelEndDate
        // let value = labelEndDate.value
        // var inputDate
        // var today = new Date();
        // if(value != null){
        //     inputDate = new Date(value.toString());
        // }
        // else{
        //     inputDate = value;
        // }
        // if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
        //     id.setCustomValidity(OWC_pastdate_error_msg);
        //     id.reportValidity();
        // }
        // else{
        //     id.setCustomValidity('');
        //     id.reportValidity();
        // }
    }

    isLabelStartDate = false
    isLabelEndDate = false
    isLabelDateAcceptable = false

    //labelGarmentDescription Focus
    handlelabelGarmentDescriptionFocus(){
        let labelGarmentDescription = this.template.querySelector('[data-id="labelGarmentDescription"]');
        if(labelGarmentDescription.value.trim() == undefined || this.labelGarmentDescription.trim() == '' || this.labelGarmentDescription.trim() == null){
            labelGarmentDescription.setCustomValidity(OWC_required_field_error_msg);
        }
        else{
            labelGarmentDescription.setCustomValidity("");
        }
        labelGarmentDescription.reportValidity();
    }

    //labelGarmentsDuration Focus
    handlelabelGarmentsDurationFocus(){
        let labelGarmentsDuration = this.template.querySelector('[data-id="labelGarmentsDuration"]');
        if(labelGarmentsDuration.value.trim() == undefined || this.labelGarmentsDuration.trim() == '' || this.labelGarmentsDuration.trim() == null){
            labelGarmentsDuration.setCustomValidity(OWC_required_field_error_msg);
        }
        else{
            labelGarmentsDuration.setCustomValidity("");
        }
        labelGarmentsDuration.reportValidity();
    }

    //labelPercPerDay Focus
    handlelabelPercPerDayFocus(){
        
        let labelPercProvided = this.template.querySelector('[data-id="labelPercProvided"]');
        if(labelPercProvided.value.trim() == undefined || this.labelPercProvided.trim() == '' || this.labelPercProvided.trim() == null){
            labelPercProvided.setCustomValidity(OWC_required_field_error_msg);
        }
        else if(labelPercProvided.value.trim() != null || labelPercProvided.value.trim() != undefined || labelPercProvided.value.trim() != ''){
            const labelPercProvided = this.template.querySelector('[data-id="labelPercProvided"]');
            if(labelPercProvided.value.match(this.regExpPhone) || labelPercProvided.value.match(this.regExp1)){
                labelPercProvided.setCustomValidity("");
                this.isLabelPercentValid = false
                labelPercProvided.reportValidity()
            }
            else{
                labelPercProvided.setCustomValidity('Please enter numeric values.');
                this.isLabelPercentValid = true
                labelPercProvided.reportValidity()
            } 
        }
        else{
            labelPercProvided.setCustomValidity("");
        }
        labelPercProvided.reportValidity();
    }
    
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {  
            // case "labelPercPerDay":            
            //     this.labelPercPerDay = event.detail.value;
            //     this.handlelabelPercPerDayFocus()
            //     console.log('labelPercPerDay :::',this.labelPercPerDay);
            //     if(this.labelPercPerDay === OWC_Yes) {
            //         this.islabelPercPerDay = true;
                    
            //     }else{
            //         this.islabelPercPerDay = false;
            //         this.labelPercProvided = '';
            //     }
            // break;
            
            case "uploadLabelSection":
                this.uploadLabelSection = event.detail.value;
                console.log('uploadLabelSection :::',this.uploadLabelSection);  
            break;
            case "labelName":
                this.labelName = event.detail.value.trim();
                console.log('labelName :::',this.labelName); 
                this.handelClearOnChange() 
            break;
            case "labelGarmentDescription":
                this.labelGarmentDescription = event.detail.value;
                this.handlelabelGarmentDescriptionFocus()
                console.log('labelGarmentDescription :::',this.labelGarmentDescription);  
            break;
            case "superVisorCheck":
                this.superVisorCheck = event.detail.value;
                console.log('superVisorCheck :::',this.superVisorCheck);
                if(this.superVisorCheck === this.options[0].value) {
                    this.isSuperVisorCheck = true;
                }else{
                    this.isSuperVisorCheck = false;
                    this.namePersonVisit = undefined;
                    this.labelPersonVisit = undefined;
                    this.labelTheyWereWorking = undefined;
                    this.labelWhatTheySay = undefined;
                    this.labelWhatIfMistakFound = undefined;
                }  
            break; 
            case "namePersonVisit":
                this.namePersonVisit = event.detail.value;
                console.log('namePersonVisit :::',this.namePersonVisit);  
            break;
            case "labelPercProvided":
                this.labelPercProvided = event.detail.value;
                this.handlelabelPercPerDayFocus();
                console.log('labelPercProvided :::',this.labelPercProvided);  
            break;
            case "labelGarmentsDuration":
                this.labelGarmentsDuration = event.detail.value;
                this.handlelabelGarmentsDurationFocus()
                if(this.labelGarmentsDuration === 'Other'){
                    this.isOther = true;
                }else{
                    this.isOther = false;
                }
                console.log('labelGarmentsDuration :::',this.labelGarmentsDuration);
            break;
            case "Other":
                this.Other = event.detail.value;
                console.log('Other :::',this.Other);
            break;    
            case "labelGarmentDelAdd":
                this.labelGarmentDelAdd = event.detail.value;
                console.log('labelGarmentDelAdd :::',this.labelGarmentDelAdd);
            break;
            case "labelGarmentDelAddCompName":
                this.labelGarmentDelAddCompName = event.detail.value;
                console.log('labelGarmentDelAddCompName :::',this.labelGarmentDelAddCompName);
            break;
            case "labelPersonVisit":
                this.labelPersonVisit = event.detail.value;
                console.log('labelPersonVisit :::',this.labelPersonVisit);
            break;
            case "labelTheyWereWorking":
                this.labelTheyWereWorking = event.detail.value;
                console.log('labelTheyWereWorking :::',this.labelTheyWereWorking);
            break;
            case "labelWhatTheySay":
                this.labelWhatTheySay = event.detail.value;
                console.log('labelWhatTheySay :::',this.labelWhatTheySay);
            break;
            case "labelWhatIfMistakFound":
                this.labelWhatIfMistakFound = event.detail.value;
                console.log('labelWhatIfMistakFound :::',this.labelWhatIfMistakFound);
            break;
            case "labelWorkOverTime":
                this.labelWorkOverTime = event.detail.value;
                console.log('labelWorkOverTime :::',this.labelWorkOverTime);
            break;
            case "labelWorkOverTimeDeadline":
                this.labelWorkOverTimeDeadline = event.detail.value;
                console.log('labelWorkOverTimeDeadline :::',this.labelWorkOverTimeDeadline);
            break;
            case "sampleOfGarment":
                this.sampleOfGarment = event.detail.value;
                console.log('sampleOfGarment :::',this.sampleOfGarment);
            break;
            case "labelPriority":
                this.labelPriority = event.detail.value;
                console.log('labelPriority :::',this.labelPriority);
            break;
            case "labelStartDate":
                this.labelStartDate = event.target.value;
                this.labelStartDate === null ? this.template.querySelector('[data-id="labelStartDate"]').value = '' : ''
                this.handleLabelDateValidity(this.template.querySelector('[data-id="labelStartDate"]'), this.template.querySelector('[data-id="labelEndDate"]'), this.template.querySelector('[data-id="labelStartDate"]').value, this.template.querySelector('[data-id="labelEndDate"]').value)
                console.log('labelStartDate ::: ', this.labelStartDate);
            break;    
            case "labelEndDate":
                this.labelEndDate = event.target.value;
                this.labelEndDate === null ? this.template.querySelector('[data-id="labelEndDate"]').value = '' : ''
                this.handleLabelDateValidity(this.template.querySelector('[data-id="labelStartDate"]'), this.template.querySelector('[data-id="labelEndDate"]'), this.template.querySelector('[data-id="labelStartDate"]').value, this.template.querySelector('[data-id="labelEndDate"]').value)
                console.log('labelEndDate ::: ', this.labelEndDate);
            break;
        }
    }

    handleLabelDateValidity(startDateId, endDateId, startDate, endDate){
        var startDateId = startDateId
        var endDateId = endDateId
        var startDate = startDate
        var endDate = endDate
        var today = new Date();

        console.log(new Date(startDate.toString()));
        startDate !== '' ? startDate = new Date(startDate.toString()) : ''

        endDate !== '' ? endDate = new Date(endDate.toString()) : ''
        if(startDate === '' && endDate === ''){
            startDateId.setCustomValidity(OWC_required_field_error_msg)
            endDateId.setCustomValidity(OWC_required_field_error_msg)
            startDateId.reportValidity();
            endDateId.reportValidity();
            return true;
        }

        else if(startDate === '' && endDate !== ''){
            startDateId.setCustomValidity(OWC_required_field_error_msg)
            startDateId.reportValidity();
            return true;
        }

        else if(startDate !== '' && endDate === ''){
            endDateId.setCustomValidity(OWC_required_field_error_msg)
            endDateId.reportValidity();
            return true;
        }
        
        // Check startDate is greater than today's date
        else if(startDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            startDateId.setCustomValidity(OWC_pastdate_error_msg)
            startDateId.reportValidity()
            return true;
        }

        // Check endDate is greater than today's date
        else if(endDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            endDateId.setCustomValidity(OWC_pastdate_error_msg)
            endDateId.reportValidity()
            return true;
        }

        // check startDate is greater than endDate
        else if(startDate > endDate){
            startDateId.setCustomValidity(OWC_begdate_error_msg)
            endDateId.setCustomValidity(OWC_enddate_error_msg)
            endDateId.reportValidity()
            startDateId.reportValidity()
            return true;
        }

        else{
            startDateId.setCustomValidity('')
            endDateId.setCustomValidity('')
            startDateId.reportValidity();
            endDateId.reportValidity();
            return false;
        }

    }
    
    handelClearOnChange(){
        this.labelGarmentsDuration = undefined;
        this.sampleOfGarment = undefined;
        this.isOther = false
        this.Other = undefined;
        this.superVisorCheck = undefined;
        this.isSuperVisorCheck = false

        this.labelGarmentDescription = undefined;
        this.labelGarmentDelAdd = undefined;
        this.labelGarmentDelAddCompName = undefined;
        this.labelPersonVisit = undefined;
        this.labelTheyWereWorking = undefined;
        this.labelWhatTheySay = undefined;
        this.labelWhatIfMistakFound = undefined;
        this.labelWorkOverTime = undefined;
        this.labelWorkOverTimeDeadline = undefined;
        this.labelPriority = undefined;
        this.labelStartDate = undefined;
        this.labelEndDate = undefined;
        this.islabelPercPerDay = false
        this.namePersonVisit = undefined;
        this.labelGarmentDelAdd = undefined;
        this.labelPercProvided = undefined;
        this.uploadRNDocument = undefined;
        this.isFileUploaded = false
        this.uploadFileSize = undefined;

        this.islabelGarmentDescription = false;
        this.islabelGarmentsDuration = false;
        this.islabelPercPerDayValChecker = false;
        this.isLabelDateAcceptable = false;
    }

    //Section validity Checker for the required fields     
    sectionValidityChecker(ids, values){
        let id = ids
        let value = values
        console.log('Value:', value);
        const val = value == undefined || value == null ? '' : value
        if(val.trim() == ""){
            id.setCustomValidity(OWC_required_field_error_msg);
            id.reportValidity();
            return true;
        }
    }

    

    @api 
    owcLabelDataForParent(){
        if(Boolean(this.showLabelFields) && this.showLabelFields === true){
            let labelGarmentDescription = this.template.querySelector('[data-id="labelGarmentDescription"]');
            let labelGarmentDescriptionValue = this.labelGarmentDescription
            this.islabelGarmentDescription = this.sectionValidityChecker(labelGarmentDescription, labelGarmentDescriptionValue);

            let labelGarmentsDuration = this.template.querySelector('[data-id="labelGarmentsDuration"]');
            let labelGarmentsDurationValue = this.labelGarmentsDuration
            this.islabelGarmentsDuration = this.sectionValidityChecker(labelGarmentsDuration, labelGarmentsDurationValue);    

            // let labelPercPerDay = this.template.querySelector('[data-id="labelPercPerDay"]');
            // let labelPercPerDayValue = this.labelPercPerDay
            // this.islabelPercPerDayValChecker = this.sectionValidityChecker(labelPercPerDay, labelPercPerDayValue);    

            
            let labelPercProvided = this.template.querySelector('[data-id="labelPercProvided"]');
            let labelPercProvidedValue = this.labelPercProvided
            //this.handleLabelPercentFocus();
            this.islabelPercPerDayValChecker = this.handleLabelPercentFocus(labelPercProvided, labelPercProvidedValue);  
            //this.isLabelPercentValid === true ? labelPercProvided.focus() : ''
            

            let labelStartDateId = this.template.querySelector('[data-id="labelStartDate"]');
            let labelEndDateId = this.template.querySelector('[data-id="labelEndDate"]');
            this.isLabelDateAcceptable = this.handleLabelDateValidity(labelStartDateId, labelEndDateId, labelStartDateId.value, labelEndDateId.value); 

            this.islabelGarmentDescription === true ? labelGarmentDescription.focus() : ''
            this.islabelGarmentsDuration === true ? labelGarmentsDuration.focus() : ''
            this.islabelPercPerDayValChecker === true ? labelPercPerDay.focus() : ''
            this.isLabelDateAcceptable === true ? labelStartDate.focus() : ''         

            console.log('Label Section Date validation', this.isLabelDateAcceptable  );
        }
        
        if(this.isLabelDateAcceptable === true  || this.islabelGarmentDescription === true
            || this.islabelGarmentsDuration === true || this.islabelPercPerDayValChecker === true){
            const selectEvent = new CustomEvent('labelsectionvalidity', {
                detail: {
                    currentStep : true
                }
        });
        this.dispatchEvent(selectEvent);
        return;
        }
        else{
            const selectEvent = new CustomEvent('labelsectionvalidity', {
                detail: {
                    currentStep : false
                }
        });
        this.dispatchEvent(selectEvent);
        }
        this.handleLabelSectionEvent();
    
    }

    regExpPhone = /^[1-9]\d*(\.\d+)?$/;
    regExp1 = /^(?!0+(?:\.0+)?$)\d?\d(?:\.\d\d?)?$/;
    isLabelPercentValid = false

    handleLabelPercentFocus(ids, values){
        let id = ids
        let labelPercProvided = values
        console.log('labelPercProvided:', labelPercProvided);
        const val = labelPercProvided == undefined || labelPercProvided == null ? '' : labelPercProvided
        if(val.trim() == ""){
            id.setCustomValidity(OWC_required_field_error_msg);
            id.reportValidity();
            return true;
        }
        else if(val.trim() != null || val.trim() != undefined || val.trim() != ''){
            const labelPercProvided = this.template.querySelector('[data-id="labelPercProvided"]');
            if(val.match(this.regExpPhone) || val.match(this.regExp1)){
                labelPercProvided.setCustomValidity("");                
                labelPercProvided.reportValidity();
                return false;
            }
            else{
                labelPercProvided.setCustomValidity('Please enter numeric values.');
                labelPercProvided.reportValidity()
                return true;
            } 
        }else{
            labelPercProvided.setCustomValidity('');
            labelPercProvided.reportValidity();
            return false;
        }
        
    }

    @api dateSection = false
    @api supervisorCheck =  false
    @api showSectionHeading = false;
    isSupervisorCheckSec = false;

    @api
    owcLabelInfoForChild(strString,isFormPreviewMode){
        this.labelSectionDetails = strString
        this.isFormPreviewMode  = isFormPreviewMode
        if(this.labelSectionDetails.labelStartDate != null || this.labelSectionDetails.labelEndDate != null){
            this.dateSection = true;
        }

        if(this.labelSectionDetails.namePersonVisit != null || this.labelSectionDetails.labelPersonVisit != null || this.labelSectionDetails.labelTheyWereWorking != null){
            this.supervisorCheck = true;
        }

        if(this.labelSectionDetails != null){
            this.showSectionHeading = true;
        }

        console.log('POP3 >>>>> ', JSON.stringify(strString))

        if(Boolean(strString.uploadLabelSection)  && Boolean(this.showLabelFields)){
            this.template.querySelector('[data-id="uploadLabelSection"]').value = strString.uploadLabelSection
            this.uploadLabelSection = strString.uploadLabelSection
        }
        this.labelGarmentsDuration = strString.labelGarmentsDuration
        this.sampleOfGarment = strString.sampleOfGarment
        this.labelName = strString.labelName
        this.isOther = strString.isOther 
        this.Other = strString.Other 
        this.superVisorCheck = strString.superVisorCheck
        this.isSuperVisorCheck = strString.isSuperVisorCheck

        this.labelGarmentDescription = strString.labelGarmentDescription
        this.labelGarmentDelAdd = strString.labelGarmentDelAdd
        this.labelGarmentDelAddCompName = strString.labelGarmentDelAddCompName
        this.labelPersonVisit = strString.labelPersonVisit
        this.labelTheyWereWorking = strString.labelTheyWereWorking
        this.labelWhatTheySay = strString.labelWhatTheySay
        this.labelWhatIfMistakFound = strString.labelWhatIfMistakFound
        this.labelWorkOverTime = strString.labelWorkOverTime
        this.labelWorkOverTimeDeadline = strString.labelWorkOverTimeDeadline
        this.labelPriority = strString.labelPriority
        this.labelStartDate = strString.labelStartDate
        this.labelEndDate = strString.labelEndDate
        this.islabelPercPerDay = strString.islabelPercPerDay
        this.namePersonVisit = strString.namePersonVisit
        this.labelGarmentDelAdd = strString.labelGarmentDelAdd
        this.labelPercProvided = strString.labelPercProvided
        this.uploadRNDocument = strString.uploadRNDocument
        this.isFileUploaded = strString.isFileUploaded
        this.uploadFileSize = strString.uploadFileSize
        this.isRenderedCallback = true

        
    }

   

    @api isMultipleFileUploadHelpText
    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === "RNHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_Info_For_RNHelpText;
            this.isMultipleFileUploadHelpText = this.customLabelValues.OWC_multiplefileupload_helptext
        }else if(learnMoreName === "LabelNameText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_LableNameAndRNHelpText;
            this.isMultipleFileUploadHelpText = '';
        }
    }

    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        console.log('helpTextValue:', JSON.stringify(helpTextValue));
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    // Multiple file upload component
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.uploadRNDocument = uploadedFiles;
        if(uploadedFiles != null){
            this.isFileUploaded = false
            this.uploadFileSize = this.uploadRNDocument.length
            this.template.querySelector('[data-id="additionalDocId"]').getDocData(this.uploadRNDocument);
          //  this.template.querySelector('c-owc-Multiple-File-Upload-Details-Cmp').getDocData(this.uploadRNDocument);
            this.isRenderedCallback = false
            this.showToast('Success!',this.toastFileUploadMsg, 'success');
        }
        else{
            this.isFileUploaded = true
        }
    }

    @api isSelectedFileDeleted = false
    
    handleUploadedDocData(event){
        console.log('event.detail:', JSON.stringify(event.detail));
        this.uploadRNDocument = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg, 'success') : ''
        this.uploadFileSize = this.uploadRNDocument.length
    }


    renderedCallback(){
        if(this.isRenderedCallback === true && this.uploadRNDocument != null){
            console.log('RESULT>>>>>>>',this.uploadRNDocument);
            
            this.template.querySelector('c-owc-Multiple-File-Upload-Details-Cmp').getDocInfos(this.uploadRNDocument, this.isFormPreviewMode);
        }

        if(this.isRenderedCallback === true && ((this.namePersonVisit != '' && this.namePersonVisit != null) 
            || (this.labelPersonVisit != '' && this.labelPersonVisit != null)
            || (this.labelTheyWereWorking != '' && this.labelTheyWereWorking != null) ) ){
            this.isSupervisorCheckSec = true;
            console.log('isSupervisorCheckSec::::'+this.isSupervisorCheckSec)
        }
    }

    @api
    handleLabelSectionDeleteFiles(isFilesDeleted){
        if(isFilesDeleted === true && this.showLabelFields === true ){
            this.template.querySelector('c-owc-Multiple-File-Upload-Details-Cmp').getDocData(this.uploadRNDocument, isFilesDeleted);
        }
    }
}