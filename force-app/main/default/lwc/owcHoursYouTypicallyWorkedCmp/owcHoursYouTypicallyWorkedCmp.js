import { LightningElement, api, track, wire } from 'lwc'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { radioOptions, acceptedFileFormat, customLabelValues } from 'c/owcUtils'
import OWC_Yes from '@salesforce/label/c.OWC_Yes'
import OWC_No from '@salesforce/label/c.OWC_No'
import { loadStyle } from 'lightning/platformResourceLoader'  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet'  // Import static resource
import OWC_multiplefileupload_helptext from '@salesforce/label/c.OWC_multiplefileupload_helptext'
//import insertUploadedFiles from '@salesforce/apex/OWCMultipleFileUploadController.insertUploadedFiles';
import deleteMultipleFiles from '@salesforce/apex/OWCMultipleFileDeleteController.deleteMultipleFiles';
const MAX_FILE_SIZE = 20971520;  ///20MB in Bytes
const CHUNK_SIZE = 750000;
let fileSize=0;
export default class OwcHoursYouTypicallyWorkedCmp extends LightningElement {
    showLoadingSpinner = false;
    @track fileNames = '';
    @track filesUploaded = [];

    @api isRenderTimeCalendar = false;
    @api isSameWeekDaysAndHours = false
    @api isDaysOrWeekVaried = false
    @api isRestPeriodNotfourHours = false
    @api isMealPeriodNotProvide = false
    @api isWorkMissedDueToIllness = false
    @api isWorkMissedReason = false
    @api isCompanyHolidayOther = false
    @api isHelpText = false
    @api isOverTimeSheetUploaded = false
    @api isSelectedFileDeleted = false
    @api workweekvalue
    // @api isVacationTimeClaimUpload = false
    // @api isUnreimbursedUpload = false
    @api isFormPreviewMode = false
    isworkMissedReasonvalue = false
    isnumberOfWorkingSaturday = false
    isnumberOfWorkingSunday = false
    isworkRestPeriod = false
    isexplainRestPeriod = false
    isworkMealPeriod = false
    isexplainMealPeriod = false
    isworkMissedDuetoIllnessvalue = false
    isexplainMissedWork  = false
    isavailableSickLeave = false
    isisdaysMissed = false
    iswhyDaysMissed = false
    iscompanyHolidaySelection = false
    isotherHolidaySelection = false
    // @api isdlse55Available = false
    @api specifyTypicalyyworked
    @api numberOfWorkingSaturday
    @api numberOfWorkingSunday
    @api workRestPeriod
    @api explainRestPeriod
    @api workMealPeriod
    @api explainMealPeriod
    @api workMissedDuetoIllness
    @api explainMissedWork
    @api companyHolidaySelection
    @api otherHolidaySelection
    @api overTimeSheet = []
    @api uploadOverTimeSheetSize
    @api workMissedReason
    @api availableSickLeave
    @api daysMissed
    @api whyDaysMissed
    @api vacationTimeClaimDetails
    @api vacationTimeClaimSize
    @api paystubSickLeave
    // @api unreimbursedDoc
    // @api unreimbursedDocSize
    @api HoursYouWorkedDetails
    @api isMultipleFileUploadHelpText
    @api toastFileUploadMsg = customLabelValues.OWC_fileupload_success_toast_msg
    @api toastFileDeleteMsg = customLabelValues.OWC_multiple_file_delete_toast_msg
    @api selectedHolidayOptions = [];

    // Creating workHoliday list in companyHoliday
    workedHoliday = customLabelValues.OWC_typically_worked_newyear_holiday
    @api companyHoliday = this.workedHoliday.split(';');

    // Phone Regrex
    regExpPhone = /^(0|[1-5][0-5]*)$/ ;

    // creting list of selected selectedHolidayOptions
    get selectedValues() {
        return this.selectedHolidayOptions.join(',');
    }


    get showCalendarPreview(){
        return this.timeEntriesDetail !== undefined && (this.timeEntriesDetail.filter(item=>item.totalHours!='')).length >0
    }

    //companyHolidaySelection checkbox options
    get comapnyHolidayOptions() {
        return [
            { label: this.companyHoliday[0], value: this.companyHoliday[0] },
            { label: this.companyHoliday[1], value: this.companyHoliday[1] },
            { label: this.companyHoliday[2], value: this.companyHoliday[2] },
            { label: this.companyHoliday[3], value: this.companyHoliday[3] },
            { label: this.companyHoliday[4], value: this.companyHoliday[4] },
            { label: this.companyHoliday[5], value: this.companyHoliday[5] },
            { label: this.companyHoliday[6], value: this.companyHoliday[6] },
            { label: this.companyHoliday[7], value: this.companyHoliday[7] }
        ];
    }

    // specifyTypicalyyworked radio options
    options = [
        {'label': customLabelValues.OWC_typicallyworked_sameworkinghours, 'value': customLabelValues.OWC_typicallyworked_sameworkinghours},
        {'label': customLabelValues.OWC_typicallyworked_perweek, 'value': customLabelValues.OWC_typicallyworked_perweek}
    ];

    //Yes or No options
    restPeriodOptions = radioOptions

    // Uploaded file accepted formats
    acceptedFormats = acceptedFileFormat;

    //Store All Custom label
    customLabelValues = customLabelValues

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

    @api isWorkWeekHelpText = false;
    // Handle Help text
    handleHelpText(event){
        const learnMoreName = event.target.name;
        this.isHelpText = true;
         if(learnMoreName === 'dlseForm55'){
            this.helpText = null
            this.isdlse55Available = true;
            this.isWorkWeekHelpText = false;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        }
        else if(learnMoreName === 'workweekAndWorkDaysHelptext'){
            this.helpText = null
            this.isdlse55Available = false;
            this.isWorkWeekHelpText = true;
        }
        
    }

    // Handle Help text Event
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    // This method will run on clicking on draft 
    handleSaveAsDraft(){
        this.owcHoursYouWorkedForParent();
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "8"
            }
        });
        this.dispatchEvent(validateEvent);
    }

    //reset DaysOrWeekVaried Value
    resetDaysOrWeekVariedValue(){
        this.isOverTimeSheetUploaded = true
        this.overTimeSheet = ''
    }

    //reset SameWeekDaysAndHours Value
    resetSameWeekDaysAndHoursValue(){
        this.numberOfWorkingSaturday = ''
        this.numberOfWorkingSunday = ''
        this.workRestPeriod = undefined
        this.isRestPeriodNotfourHours = false
        this.explainRestPeriod = ''
        this.workMealPeriod = undefined
        this.isMealPeriodNotProvide = false
        this.explainMealPeriod = ''
        this.workMissedDuetoIllness = undefined
        this.isWorkMissedDueToIllness = false
        this.isWorkMissedReason = false
        this.explainMissedWork = ''
        this.workMissedReason = undefined
        this.availableSickLeave = null
        this.daysMissed = null
        this.whyDaysMissed = null
        this.selectedHolidayOptions = []
        this.isCompanyHolidayOther = false
        this.otherHolidaySelection = ''
    }
    
    // This method will handle event on change of every field
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            case "specifyTypicalyyworked":
                const specifyTypicalyyworked = event.target.value;
                if(specifyTypicalyyworked === customLabelValues.OWC_typicallyworked_sameworkinghours){
                    this.isSameWeekDaysAndHours = true;
                    this.isDaysOrWeekVaried = false
                    this.resetDaysOrWeekVariedValue()
                }
                else if(specifyTypicalyyworked === customLabelValues.OWC_typicallyworked_perweek){
                    this.isSameWeekDaysAndHours = false;
                    this.isDaysOrWeekVaried = true
                    this.resetSameWeekDaysAndHoursValue()
                }
                this.specifyTypicalyyworked = specifyTypicalyyworked
                console.log('this.specifyTypicalyyworked>>>>',this.specifyTypicalyyworked);
                console.log('this.isSameWeekDaysAndHours>>>>',this.isSameWeekDaysAndHours);
                console.log('this.isDaysOrWeekVaried>>>>',this.isDaysOrWeekVaried);
                break;
            case "numberOfWorkingSaturday":
                this.numberOfWorkingSaturday = event.target.value;
                console.log('this.numberOfWorkingSaturday>>>>',this.numberOfWorkingSaturday);
                
                this.handleNumberOfWorkingSaturdayFocus();
                break;
            case "numberOfWorkingSunday":
                this.numberOfWorkingSunday = event.target.value;
                console.log('this.numberOfWorkingSunday>>>>',this.numberOfWorkingSunday);
                this.handlenumberOfWorkingSundayfocus();
                break;
            case "workRestPeriod":
                this.workRestPeriod = event.target.value;
                console.log('this.workRestPeriod>>>>',this.workRestPeriod);
                this.handleWorkRestPeriodFocus();
                if(this.workRestPeriod === OWC_No){
                    this.isRestPeriodNotfourHours = true;
                }
                else{
                    this.isRestPeriodNotfourHours = false;
                }
                console.log('this.isRestPeriodNotfourHours>>>>',this.isRestPeriodNotfourHours);
                break;
            case "explainRestPeriod":
                this.explainRestPeriod = event.target.value;
                console.log('this.explainRestPeriod>>>>',this.explainRestPeriod);
                this.handleexplainRestPeriodfocus();
                break;
            case "paystubSickLeave":
                this.paystubSickLeave = event.target.value;
                console.log('this.paystubSickLeave>>>>',this.paystubSickLeave);
                this.handlepaystubSickLeavefocus();
                break;
            case "workMealPeriod":
                this.workMealPeriod = event.target.value;
                console.log('this.workMealPeriod>>>>',this.workMealPeriod);
                this.handleWorkMealPeriodFocus();
                if(this.workMealPeriod === OWC_No){
                    this.isMealPeriodNotProvide = true;
                }
                else{
                    this.isMealPeriodNotProvide = false;
                }
                console.log('this.isMealPeriodNotProvide>>>>',this.isMealPeriodNotProvide);
                break;
            case "explainMealPeriod":
                this.explainMealPeriod = event.target.value;
                console.log('this.explainMealPeriod>>>>',this.explainMealPeriod);
                this.handleexplainMealPeriodfocus();
                break;
            case "workMissedDuetoIllness":
                this.workMissedDuetoIllness = event.target.value;
                console.log('this.workMissedDuetoIllness>>>>',this.workMissedDuetoIllness);
                this.handleMissedWorkedFocus();
                if(this.workMissedDuetoIllness === OWC_Yes){
                    this.isWorkMissedDueToIllness = true;
                }
                else{
                    this.isWorkMissedDueToIllness = false;
                }
                console.log('this.isWorkMissedDueToIllness>>>>',this.isWorkMissedDueToIllness);
                break;
            case "explainMissedWork":
                this.explainMissedWork = event.target.value;
                console.log('this.explainMissedWork>>>>',this.explainMissedWork);
                this.handleexplainMissedWorkfocus();
                break;
            case "workMissedReason":
                this.workMissedReason = event.target.value;
                if(this.workMissedReason === OWC_Yes){
                    this.isWorkMissedReason = true;
                }
                else{
                    this.isWorkMissedReason = false;
                    this.whyDaysMissed = undefined;
                    this.daysMissed = undefined;
                }
                this.handleWorkMissedReasonFocus()
                console.log('this.workMissedReason>>>>',this.workMissedReason);
                console.log('this.isWorkMissedReason>>>>',this.isWorkMissedReason);
                break; 
            case "availableSickLeave":
                this.availableSickLeave = event.target.value;
                this.handleavailableSickLeavefocus();
                console.log('this.availableSickLeave>>>>',this.availableSickLeave);
                break;
            case "daysMissed":
                this.daysMissed = event.target.value;
                this.handledaysMissedfocus();
                console.log('this.daysMissed>>>>',this.daysMissed);
                break;        
            case "whyDaysMissed":
                this.whyDaysMissed = event.target.value;
                this.handlewhyDaysMissedfocus();
                console.log('this.whyDaysMissed>>>>',this.whyDaysMissed);
                break;
            case "companyHolidaySelection":
                this.companyHolidaySelection = event.target.value;
                this.handlecompanyHolidaySelectionfocus();
                this.selectedHolidayOptions = this.companyHolidaySelection;
                if(this.companyHolidaySelection.includes(this.companyHoliday[7])){
                    this.isCompanyHolidayOther = true
                }
                else{
                    this.isCompanyHolidayOther = false
                }
                console.log('this.companyHolidaySelection>>>>',this.companyHolidaySelection);
                console.log('this.isCompanyHolidayOther>>>>',this.isCompanyHolidayOther);
                break;
            case "otherHolidaySelection":
                this.otherHolidaySelection = event.target.value;
                console.log('this.otherHolidaySelection>>>>',this.otherHolidaySelection);
                break;
        }
    }

    // @api fileData = []

    // calculateFileSize(files){
    //     let i,j;
  
    //         if(this.fileData.length>0){
    //             console.log('sdsds');
    //                     this.fileData.splice(0,this.fileData.length);
    //                     fileSize = 0;
    //         }
    //         console.log(this.fileData);
    //         for(i=0;i<files.length;i++){
    //                 this.fileData.push(files[i]);
    //         }
    //         console.log(this.fileData);
  
    //         for(j=0;j<parseInt(this.fileData.length);j++){
    //                 fileSize = fileSize+parseInt(JSON.stringify(JSON.parse(this.fileData[j].size)));
    //         }
    //         console.log('????');
    //         console.log(fileSize);
  
    // }
    
    // @api isFileInserted = false;
    // @track flag = 0;
    // handleUploadOverTimeSheetChange(event){
    //     this.calculateFileSize(event.target.files);
    //     if(fileSize<MAX_FILE_SIZE){
    //     let files = event.target.files;
    //     for(var i=0; i<files.length; i++){
    //         this.flag += 1;
    //         files[i].recordId = this.flag;
    //     }
    //     this.handleUploadOverTimeSheet(files);
    //     console.log('selecred fiels ::: ',files);
    //     if (files.length > 0) {
    //            let filesName = '';
 
    //            for (let i = 0; i < files.length; i++) {
    //                    let file = files[i];
 
    //                    filesName = filesName + file.name + ',';
 
    //                    var flag=this;
    //                    let freader = new FileReader();
    //                    console.log('freader');
    //                    freader.onload = f => {
                          
    //                        let base64 = 'base64,';
    //                        let content = freader.result.indexOf(base64) + base64.length;
    //                        let fileContents = freader.result.substring(content);    
    //                        flag.filesUploaded.push({
    //                            Title: file.name,
    //                            VersionData: fileContents
    //                        });
    //                    };
    //                    console.log(freader);
    //                    console.log(JSON.stringify(this.filesUploaded));
    //                  //  console.log('check',freader.readAsDataURL(file));
    //                    freader.readAsDataURL(file);
                      
    //            }
              
    //                this.fileNames = filesName.slice(0, -1);
 
    //    }
    //    }
    //    else{
    //        this.showToast('File Size Limit Exceeded','Upload files of size less than 20MB','error');
    //    }
    // }

    // @track contentVersionIds;
    // handleSaveFiles() {
    //     this.showLoadingSpinner = true;
    //     insertUploadedFiles({
    //         uploadedFiles : this.filesUploaded,
    //         contentVersionId : this.contentVersionIds
    //     })
    //     .then(data => {
    //         this.showLoadingSpinner = false;
    //         this.contentVersionIds = data;
    //         this.fileNames = undefined;
    //     })
    //     .catch(error => {
            
    //     });
    // }
    // Handler of Overtime sheet upload
    @track contentVersionIds = []
    deleteExtraFiles(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            this.contentVersionIds.push(uploadedFiles[i].documentId);
        }
        deleteMultipleFiles({ contentVersionIds : JSON.stringify(this.contentVersionIds) })
           .then(result => {
               if(result){
                   
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
    }

    @api get isFileUploadDisabled(){
        return this.overTimeSheet.length >= 10 && this.isRenderedCallback === false;
    }

    @api totalUploadFiles = []

    handleFileLimit(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            for(var j=0; j<this.totalUploadFiles.length; j++){
                if(uploadedFiles[i].documentId === this.totalUploadFiles[j].documentId){
                    this.totalUploadFiles.splice(j , 1)
                }
            }
        }
    }

    updateFileVariables(){
        if(this.overTimeSheet !== undefined && this.overTimeSheet.length > 0){
            this.totalUploadFiles.length = 0;
            this.totalUploadFiles = this.overTimeSheet;
        }
    }

    handleUploadOverTimeSheet(event){
        const uploadedFiles = event.detail.files;
        
        for(var i=0; i<uploadedFiles.length; i++){
            this.totalUploadFiles.push(uploadedFiles[i]);
        }
        if(this.totalUploadFiles.length <= 10){
            this.overTimeSheet = uploadedFiles;
            if(uploadedFiles != null){
                this.isOverTimeSheetUploaded = false
                this.uploadOverTimeSheetSize = this.overTimeSheet.length
                this.template.querySelector('[data-id="overSheetDocId"]').getDocData(this.overTimeSheet);
                this.isRenderedCallback = false
                this.showToast('Success!',this.toastFileUploadMsg, 'success');
            }
            else{
                this.isOverTimeSheetUploaded = true
            }
        }
        else{
            this.deleteExtraFiles(uploadedFiles);
            this.handleFileLimit(uploadedFiles);
            this.showToast('Error!', this.customLabelValues.OWC_file_size_error,'error');
        }
    }

    // Handler of Overtime sheet Delete
    handleOverTimeSheetDoc(event){
        this.overTimeSheet = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.updateFileVariables();
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg, 'success') : '';
        this.uploadOverTimeSheetSize = this.overTimeSheet.length
    }

    // // Vacation Time Claim Upload Handler
    // handleVacationTimeClaimDoc(event){
    //     const uploadedFiles = event.detail.files;
    //     this.vacationTimeClaimDetails = uploadedFiles;
    //     if(uploadedFiles != null){
    //         this.isVacationTimeClaimUpload = false
    //         this.vacationTimeClaimSize = this.vacationTimeClaimDetails.length
    //         this.template.querySelector('[data-id="vacationTimeClaimId"]').getDocData(this.vacationTimeClaimDetails);
    //         this.isRenderedCallback = false
    //         this.showToast('Success!',this.toastFileUploadMsg, 'success');
    //     }
    //     else{
    //         this.isVacationTimeClaimUpload = true
    //     }
    // }

    // // Vacation Time Claim Delete Handler
    // handleVacationTimeClaimEvent(event){
    //     this.vacationTimeClaimDetails = event.detail.uploadcontractdoc
    //     this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
    //     this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
    //     this.vacationTimeClaimSize = this.vacationTimeClaimDetails.length
    // }

    // // Unreibursed doc handler
    // handleunreimbursedDoc(event){
    //     const uploadedFiles = event.detail.files;
    //     this.unreimbursedDoc = uploadedFiles;
    //     if(uploadedFiles != null){
    //         this.isUnreimbursedUpload = false
    //         this.unreimbursedDocSize = this.unreimbursedDoc.length
    //         this.template.querySelector('[data-id="unreimbursedDocId"]').getDocData(this.unreimbursedDoc);
    //         this.isRenderedCallback = false
    //         this.showToast('Success!',this.toastFileUploadMsg,'success');
    //     }
    //     else{
    //         this.isUnreimbursedUpload = true
    //     }
    // }

    // // Unreibursed doc delete handler
    // handleUnreimbursedDocEvent(event){
    //     this.unreimbursedDoc = event.detail.uploadcontractdoc
    //     this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
    //     this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
    //     this.unreimbursedDocSize = this.unreimbursedDoc.length
    // }

    //Checking validation of numberOfWorkingSaturday
    handleNumberOfWorkingSaturdayFocus(){
        let numberOfWorkingSaturday = this.template.querySelector('[data-id="numberOfWorkingSaturday"]');            
        if(numberOfWorkingSaturday.value == undefined || numberOfWorkingSaturday.value == null || numberOfWorkingSaturday.value.trim() == ''){
            numberOfWorkingSaturday.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isnumberOfWorkingSaturday = true
        }
        else if(numberOfWorkingSaturday.value.trim() != null || numberOfWorkingSaturday.value.trim() != undefined || numberOfWorkingSaturday.value.trim() != ''){
            const numberOfWorkingSaturday = this.template.querySelector('[data-id="numberOfWorkingSaturday"]');
            if(numberOfWorkingSaturday.value.match(this.regExpPhone)){
                numberOfWorkingSaturday.setCustomValidity("");
                this.isnumberOfWorkingSaturday = false
                this.isLawFirmZipCodeValid = false
                numberOfWorkingSaturday.reportValidity()
            }
            else{
                numberOfWorkingSaturday.setCustomValidity('Please enter valid value.');
                this.isLawFirmZipCodeValid = true
                this.isnumberOfWorkingSaturday = true
                numberOfWorkingSaturday.reportValidity()
            } 
        }
        numberOfWorkingSaturday.reportValidity();
    }

    //Checking validation of handlenumberOfWorkingSundayfocus
    handlenumberOfWorkingSundayfocus(){
        let numberOfWorkingSunday = this.template.querySelector('[data-id="numberOfWorkingSunday"]');            
        if(numberOfWorkingSunday.value == undefined || numberOfWorkingSunday.value == null || numberOfWorkingSunday.value.trim() == ''){
            numberOfWorkingSunday.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isnumberOfWorkingSunday = true
        }
        else if(numberOfWorkingSunday.value.trim() != null || numberOfWorkingSunday.value.trim() != undefined || numberOfWorkingSunday.value.trim() != ''){
            const numberOfWorkingSunday = this.template.querySelector('[data-id="numberOfWorkingSunday"]');
            if(numberOfWorkingSunday.value.match(this.regExpPhone)){
                numberOfWorkingSunday.setCustomValidity("");
                this.isLawFirmZipCodeValid = false
                this.isnumberOfWorkingSunday = false
                numberOfWorkingSunday.reportValidity()
            }
            else{
                numberOfWorkingSunday.setCustomValidity('Please enter valid value.');
                this.isLawFirmZipCodeValid = true
                this.isnumberOfWorkingSunday = true
                numberOfWorkingSunday.reportValidity()
            } 
        }
        numberOfWorkingSunday.reportValidity();
    }

    //Checking validation of explainMissedWork
    handleexplainMissedWorkfocus(){
        let explainMissedWork = this.template.querySelector('[data-id="explainMissedWork"]');            
        if(explainMissedWork.value == undefined || explainMissedWork.value == null || explainMissedWork.value.trim() == ''){
            explainMissedWork.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isworkMissedReason = true;
            this.isexplainMissedWork = true
        }
        else{
            explainMissedWork.setCustomValidity("");
            this.isworkMissedReason = false;
            this.isexplainMissedWork = false
        }
        explainMissedWork.reportValidity();
    }

    handleavailableSickLeavefocus(){
        let availableSickLeave = this.template.querySelector('[data-id="availableSickLeave"]');            
        if(availableSickLeave.value == undefined || availableSickLeave.value == null || availableSickLeave.value.trim() == ''){
            availableSickLeave.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
           this.isworkMissedReason = true;
            this.isavailableSickLeave = true
        }
        else{
            availableSickLeave.setCustomValidity("");
            this.isworkMissedReason = false;
            this.isavailableSickLeave = false
        }
        availableSickLeave.reportValidity();
    }

    @api numberInputRegrex = /^[0-9]*$/;

    handledaysMissedfocus(){
        let daysMissed = this.template.querySelector('[data-id="daysMissed"]');            
        if(daysMissed.value == undefined || daysMissed.value == null || daysMissed.value.trim() == ''){
            daysMissed.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isdaysMissed = true
        }
        else if(daysMissed.value.match(this.numberInputRegrex)){
            daysMissed.setCustomValidity('');
            this.isdaysMissed = false
        }
        else{
            daysMissed.setCustomValidity('Enter valid number.');
            this.isdaysMissed = true
        }
        daysMissed.reportValidity();
    }

    handlewhyDaysMissedfocus(){
        let whyDaysMissed = this.template.querySelector('[data-id="whyDaysMissed"]');            
        if(whyDaysMissed.value == undefined || whyDaysMissed.value == null || whyDaysMissed.value.trim() == ''){
            whyDaysMissed.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.iswhyDaysMissed = true
        }
        else{
            whyDaysMissed.setCustomValidity("");
            this.iswhyDaysMissed = false
        }
        whyDaysMissed.reportValidity();
    }

    //Checking validation of handleWorkRestPeriodFocus
    handleWorkRestPeriodFocus(){
        let workRestPeriod = this.template.querySelector('[data-id="workRestPeriod"]');            
        if(workRestPeriod.value == undefined || workRestPeriod.value == null || workRestPeriod.value.trim() == ''){
            workRestPeriod.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isworkRestPeriod = true
        }
        else{
            workRestPeriod.setCustomValidity("");
            this.isworkRestPeriod = false
        }
        workRestPeriod.reportValidity();
    }

    @api ispaystubSickLeave = false

    //Checking validation of handleexplainRestPeriodfocus
    handleexplainRestPeriodfocus(){
        let explainRestPeriod = this.template.querySelector('[data-id="explainRestPeriod"]');            
        if(explainRestPeriod.value == undefined || explainRestPeriod.value == null || explainRestPeriod.value.trim() == ''){
            explainRestPeriod.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isexplainRestPeriod = true
        }
        else{
            explainRestPeriod.setCustomValidity("");
            this.isexplainRestPeriod = false
        }
        explainRestPeriod.reportValidity();
    }
    handlepaystubSickLeavefocus(){
        let paystubSickLeave = this.template.querySelector('[data-id="paystubSickLeave"]');            
        if(paystubSickLeave.value == undefined || paystubSickLeave.value == null || paystubSickLeave.value.trim() == ''){
            paystubSickLeave.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.ispaystubSickLeave = true
        }
        else{
            paystubSickLeave.setCustomValidity("");
            this.ispaystubSickLeave = false
        }
        paystubSickLeave.reportValidity();
    }

    //Checking validation of handleWorkMealPeriodFocus
    handleWorkMealPeriodFocus(){
        let workMealPeriod = this.template.querySelector('[data-id="workMealPeriod"]');            
        if(workMealPeriod.value == undefined || workMealPeriod.value == null || workMealPeriod.value.trim() == ''){
            workMealPeriod.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isworkMealPeriod = true
        }
        else{
            workMealPeriod.setCustomValidity("");
            this.isworkMealPeriod = false
        }
        workMealPeriod.reportValidity();
    }

    //Checking validation of handleexplainMealPeriodfocus
    handleexplainMealPeriodfocus(){
        let explainMealPeriod = this.template.querySelector('[data-id="explainMealPeriod"]');            
        if(explainMealPeriod.value == undefined || explainMealPeriod.value == null || explainMealPeriod.value.trim() == ''){
            explainMealPeriod.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isexplainMealPeriod = true
        }
        else{
            explainMealPeriod.setCustomValidity("");
            this.isexplainMealPeriod = false
        }
        explainMealPeriod.reportValidity();
    }

    //Checking validation of handleMissedWorkedFocus
     handleMissedWorkedFocus(){
        let workMissedDuetoIllness = this.template.querySelector('[data-id="workMissedDuetoIllness"]');            
        if(workMissedDuetoIllness.value == undefined || workMissedDuetoIllness.value == null || workMissedDuetoIllness.value.trim() == ''){
            workMissedDuetoIllness.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isworkMissedDuetoIllnessvalue = true
        }
        else{
            workMissedDuetoIllness.setCustomValidity("");
            this.isworkMissedDuetoIllnessvalue = false
        }
        workMissedDuetoIllness.reportValidity();
    }

    //Checking validation of Missed worked reason 
    handleWorkMissedReasonFocus(){
        let workMissedReason = this.template.querySelector('[data-id="workMissedReason"]');            
        if(workMissedReason.value == undefined || workMissedReason.value == null || workMissedReason.value.trim() == ''){
            workMissedReason.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isworkMissedReasonvalue = true
        }
        else{
            workMissedReason.setCustomValidity("");
            this.isworkMissedReasonvalue = false
        }
        workMissedReason.reportValidity();
    }

    //Checking validation of companyHolidaySelection
    handlecompanyHolidaySelectionfocus(){

        let companyHolidaySelection = this.template.querySelector('[data-id="companyHolidaySelection"]');          
        if(companyHolidaySelection.value == undefined || companyHolidaySelection.value == null || companyHolidaySelection.value == '' || companyHolidaySelection.value == '--Select--'){
            companyHolidaySelection.setCustomValidity(customLabelValues.OWC_checkbox_group_error_msg);
            this.iscompanyHolidaySelection = true
        }else{
            companyHolidaySelection.setCustomValidity("");
            this.iscompanyHolidaySelection = false
        }
        companyHolidaySelection.reportValidity();
        // let companyHolidaySelection = this.template.querySelector('[data-id="companyHolidaySelection"]');            
        // if(companyHolidaySelection.value == undefined || companyHolidaySelection.value == null || companyHolidaySelection.value.trim() == ''){
        //     companyHolidaySelection.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
        //     this.iscompanyHolidaySelection = true
        // }
        // else{
        //     companyHolidaySelection.setCustomValidity("");
        //     this.iscompanyHolidaySelection = false
        // }
        // companyHolidaySelection.reportValidity();
    }

    //handleotherHolidaySelectionfocus
    handleotherHolidaySelectionfocus(){
        let otherHolidaySelection = this.template.querySelector('[data-id="otherHolidaySelection"]');            
        if(otherHolidaySelection.value == undefined || otherHolidaySelection.value == null || otherHolidaySelection.value.trim() == ''){
            otherHolidaySelection.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            this.isotherHolidaySelection = true
        }
        else{
            otherHolidaySelection.setCustomValidity("");
            this.isotherHolidaySelection = false
        }
        otherHolidaySelection.reportValidity();
    }

    // This Method store all the value of its component
    handleEvent(){
        const selectEvent = new CustomEvent('hoursyoutypicallyworkedevent', {
            detail: {
                workMissedReason : this.workMissedReason, 
                availableSickLeave : this.availableSickLeave,
                daysMissed : this.daysMissed,
                whyDaysMissed : this.whyDaysMissed,
                // unreimbursedDoc : this.unreimbursedDoc,
                // isUnreimbursedUpload : this.isUnreimbursedUpload,
                // unreimbursedDocSize : this.unreimbursedDocSize,
                // vacationTimeClaimDetails : this.vacationTimeClaimDetails,
                // vacationTimeClaimSize : this.vacationTimeClaimSize,
                // isVacationTimeClaimUpload : this.isVacationTimeClaimUpload,
                specifyTypicalyyworked : this.specifyTypicalyyworked,
                selectedHolidayOptions : this.selectedHolidayOptions,
                isSameWeekDaysAndHours : this.isSameWeekDaysAndHours,
                isDaysOrWeekVaried : this.isDaysOrWeekVaried,
                numberOfWorkingSaturday : this.numberOfWorkingSaturday,
                numberOfWorkingSunday : this.numberOfWorkingSunday,
                workRestPeriod : this.workRestPeriod,
                isRestPeriodNotfourHours : this.isRestPeriodNotfourHours,
                explainRestPeriod : this.explainRestPeriod,
                workMealPeriod : this.workMealPeriod,
                isMealPeriodNotProvide : this.isMealPeriodNotProvide,
                explainMealPeriod : this.explainMealPeriod, 
                workMissedDuetoIllness : this.workMissedDuetoIllness,
                isWorkMissedDueToIllness : this.isWorkMissedDueToIllness,
                isWorkMissedReason : this.isWorkMissedReason,
                explainMissedWork : this.explainMissedWork,
                companyHolidaySelection : this.companyHolidaySelection,
                isCompanyHolidayOther : this.isCompanyHolidayOther,
                otherHolidaySelection : this.otherHolidaySelection,
                overTimeSheet : this.overTimeSheet,
                isOverTimeSheetUploaded : this.isOverTimeSheetUploaded,
                uploadOverTimeSheetSize : this.uploadOverTimeSheetSize,
                timeEntriesDetail : this.timeEntriesDetail,
                paystubSickLeave : this.paystubSickLeave,
                contentVersionIds : this.contentVersionIds,
                totalUploadFiles : this.totalUploadFiles,
                flag : this.flag
            }
        });
        this.dispatchEvent(selectEvent);
    }

    // This Method make current step true
    handleCustomValidityEvent(){
        const selectEvent = new CustomEvent('hoursyoutypicallyworkedvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.dispatchEvent(selectEvent);
    }

    // This Method will check validation and also send value to parent
    @api
    owcHoursYouWorkedForParent(){
        if(this.isSameWeekDaysAndHours === true || this.isDaysOrWeekVaried === true){
            // this.handleNumberOfWorkingSaturdayFocus();
            // let numberOfWorkingSaturday = this.template.querySelector('[data-id="numberOfWorkingSaturday"]');
            // this.isnumberOfWorkingSaturday === true ? numberOfWorkingSaturday.focus() : ''
            // this.isnumberOfWorkingSaturday === true ? this.handleCustomValidityEvent() : this.handleEvent();
        
            // //numberOfWorkingSunday
            // this.handlenumberOfWorkingSundayfocus()
            // let numberOfWorkingSunday = this.template.querySelector('[data-id="numberOfWorkingSunday"]');
            // this.isnumberOfWorkingSunday === true ? numberOfWorkingSunday.focus() : ''
            // this.isnumberOfWorkingSunday === true ? this.handleCustomValidityEvent() : this.handleEvent();

            //workMissedReason
            this.handleWorkMissedReasonFocus();
            let workMissedReason = this.template.querySelector('[data-id="workMissedReason"]');
            this.isworkMissedReasonvalue === true ? workMissedReason.focus() : ''
            this.isworkMissedReasonvalue === true ? this.handleCustomValidityEvent() : this.handleEvent();

            //workMissedDuetoIllness
            // this.handleMissedWorkedFocus();
            // let workMissedDuetoIllness = this.template.querySelector('[data-id="workMissedDuetoIllness"]');
            // this.isworkMissedDuetoIllnessvalue === true ? workMissedDuetoIllness.focus() : ''
            // this.isworkMissedDuetoIllnessvalue === true ? this.handleCustomValidityEvent() : this.handleEvent();
            
            // this.handlepaystubSickLeavefocus();
            // let paystubSickLeave = this.template.querySelector('[data-id="paystubSickLeave"]');
            // this.ispaystubSickLeave === true ? paystubSickLeave.focus() : ''
            this.ispaystubSickLeave === true ? this.handleCustomValidityEvent() : this.handleEvent();
            //companyHolidaySelection            
            if(this.selectedHolidayOptions.length === 0){
                this.handlecompanyHolidaySelectionfocus();
                let companyHolidaySelection = this.template.querySelector('[data-id="companyHolidaySelection"]');
                this.iscompanyHolidaySelection === true ? companyHolidaySelection.focus() : ''
                this.iscompanyHolidaySelection === true ? this.handleCustomValidityEvent() : this.handleEvent();
                
            }

            // if(this.isRestPeriodNotfourHours === true){
            //     this.handleexplainRestPeriodfocus();
            //     let explainRestPeriod = this.template.querySelector('[data-id="explainRestPeriod"]');
            //     this.isexplainRestPeriod === true ? explainRestPeriod.focus() : ''
            //     this.isexplainRestPeriod === true ? this.handleCustomValidityEvent() : this.handleEvent();
            // }
    
            // if(this.isMealPeriodNotProvide === true){
            //     this.handleexplainMealPeriodfocus();
            //     let explainMealPeriod = this.template.querySelector('[data-id="explainMealPeriod"]');
            //     this.isexplainMealPeriod === true ? explainMealPeriod.focus() : ''
            //     this.isexplainMealPeriod === true ? this.handleCustomValidityEvent() : this.handleEvent();  
            // }
    
            // if(this.isWorkMissedDueToIllness === true){
            //     this.handleexplainMissedWorkfocus();
            //     let explainMissedWork = this.template.querySelector('[data-id="explainMissedWork"]');
            //     this.isexplainMissedWork === true ? explainMissedWork.focus() : ''

            //     this.handleavailableSickLeavefocus();
            //     let availableSickLeave = this.template.querySelector('[data-id="availableSickLeave"]');
            //     this.isavailableSickLeave === true ? availableSickLeave.focus() : ''
                
            //     this.isexplainMissedWork === true || this.isavailableSickLeave === true ? this.handleCustomValidityEvent() : this.handleEvent();
                
            // }
            
            if(this.isWorkMissedReason === true){
                this.handledaysMissedfocus();
                let daysMissed = this.template.querySelector('[data-id="daysMissed"]');
                this.isdaysMissed === true ? daysMissed.focus() : ''

                this.handlewhyDaysMissedfocus();
                let whyDaysMissed = this.template.querySelector('[data-id="whyDaysMissed"]');
                this.iswhyDaysMissed === true ? whyDaysMissed.focus() : ''
                
                this.isdaysMissed === true || this.iswhyDaysMissed === true ? this.handleCustomValidityEvent() : this.handleEvent();
                
            }
    
            if(this.isCompanyHolidayOther === true){
                this.handleotherHolidaySelectionfocus();
                let otherHolidaySelection = this.template.querySelector('[data-id="otherHolidaySelection"]');
                this.isotherHolidaySelection === true ? otherHolidaySelection.focus() : ''
                this.isotherHolidaySelection === true ? this.handleCustomValidityEvent() : this.handleEvent();
            }
            

            if(this.isSameWeekDaysAndHours === true){
                this.template.querySelector('c-owc-Hours-You-Typically-Calendar').getWeekDaysDetails();
            }
        }      
        this.handleEvent();
    }

    @api timeEntriesDetail;
    handleTimeEntriesDetails(event){
        const timeEntriesDetail = event.detail.timeEntriesDetailed;
        console.log('timeEntriesDetails ::: ', JSON.stringify(event.detail.timeEntriesDetailed));
        this.timeEntriesDetail = timeEntriesDetail;
    }

    // This Method will fetch values from parent component
    @api
    owcHoursYouWorkedForChild(strString, isFormPreviewMode ){
        this.HoursYouWorkedDetails = strString
        this.isFormPreviewMode = isFormPreviewMode        
        this.workMissedReason = strString.workMissedReason
        this.availableSickLeave = strString.availableSickLeave
        this.daysMissed = strString.daysMissed
        this.whyDaysMissed = strString.whyDaysMissed
        this.specifyTypicalyyworked = strString.specifyTypicalyyworked
        this.selectedHolidayOptions = strString.selectedHolidayOptions
        this.workRestPeriod = strString.workRestPeriod
        this.workMealPeriod = strString.workMealPeriod
        this.workMissedDuetoIllness = strString.workMissedDuetoIllness
        this.companyHolidaySelection = strString.companyHolidaySelection

        this.isSameWeekDaysAndHours = strString.isSameWeekDaysAndHours
        this.isDaysOrWeekVaried = strString.isDaysOrWeekVaried
        this.numberOfWorkingSaturday = strString.numberOfWorkingSaturday
        this.numberOfWorkingSunday = strString.numberOfWorkingSunday

        this.isRestPeriodNotfourHours = strString.isRestPeriodNotfourHours
        this.explainRestPeriod = strString.explainRestPeriod

        this.isMealPeriodNotProvide = strString.isMealPeriodNotProvide
        this.explainMealPeriod = strString.explainMealPeriod 

        this.isWorkMissedDueToIllness = strString.isWorkMissedDueToIllness
        this.isWorkMissedReason = strString.isWorkMissedReason
        this.explainMissedWork = strString.explainMissedWork

        this.isCompanyHolidayOther = strString.isCompanyHolidayOther
        this.otherHolidaySelection = strString.otherHolidaySelection

        this.isOverTimeSheetUploaded = strString.isOverTimeSheetUploaded
        this.totalUploadFiles = strString.totalUploadFiles === undefined ? [] : strString.totalUploadFiles

        this.overTimeSheet = strString.overTimeSheet === undefined ? [] : strString.overTimeSheet
        this.uploadOverTimeSheetSize = strString.uploadOverTimeSheetSize

        this.paystubSickLeave  = strString.paystubSickLeave
        this.flag = strString.flag,
        this.contentVersionIds = strString.contentVersionIds

        this.timeEntriesDetail = strString.timeEntriesDetail
        this.isRenderTimeCalendar === true ? this.isRenderTimeCalendar = false : this.isRenderTimeCalendar = true;
        // this.timeEntriesDetail = strString.timeEntriesDetail
        // this.isSameWeekDaysAndHours === true && strString.timeEntriesDetail.length > 0 ? this.template.querySelector('c-owc-Hours-You-Typically-Calendar').setTimeEntriesOnPrev() : '';
        // this.vacationTimeClaimDetails = strString.vacationTimeClaimDetails,
        // this.vacationTimeClaimSize = strString.vacationTimeClaimSize,
        // this.isVacationTimeClaimUpload = strString.isVacationTimeClaimUpload,

        // this.unreimbursedDoc = strString.unreimbursedDoc,
        // this.isUnreimbursedUpload = strString.isUnreimbursedUpload,
        // this.unreimbursedDocSize = strString.unreimbursedDocSize,

        //only upload files left.
        this.isRenderedCallback = true
    }

    // This Method will fetch values from parent component and store in fields
    renderedCallback(){
        if(this.isRenderedCallback === true && this.specifyTypicalyyworked != undefined && this.specifyTypicalyyworked != null){
            this.template.querySelector('[data-id="specifyTypicalyyworked"]').value = this.specifyTypicalyyworked
        }

        if(this.isRenderedCallback === true && this.workRestPeriod != undefined && this.workRestPeriod != null){
            this.template.querySelector('[data-id="workRestPeriod"]').value = this.workRestPeriod
        } 

        if(this.isRenderedCallback === true && this.workMealPeriod != undefined && this.workMealPeriod != null){
            this.template.querySelector('[data-id="workMealPeriod"]').value = this.workMealPeriod
        } 
        if(this.isRenderedCallback === true && this.workMissedDuetoIllness != undefined && this.workMissedDuetoIllness != null){
            this.template.querySelector('[data-id="workMissedDuetoIllness"]').value = this.workMissedDuetoIllness
        } 
        if(this.isRenderedCallback === true && this.workMissedReason != undefined && this.workMissedReason != null){
            this.template.querySelector('[data-id="workMissedReason"]').value = this.workMissedReason
        }
        if(this.isRenderedCallback === true && this.availableSickLeave != undefined && this.availableSickLeave != null){
            this.template.querySelector('[data-id="availableSickLeave"]').value = this.availableSickLeave
        }
        if(this.isRenderedCallback === true && this.daysMissed != undefined && this.daysMissed != null){
            this.template.querySelector('[data-id="daysMissed"]').value = this.daysMissed
        }
        if(this.isRenderedCallback === true && this.whyDaysMissed != undefined && this.whyDaysMissed != null){
            this.template.querySelector('[data-id="whyDaysMissed"]').value = this.whyDaysMissed
        }
        if(this.isRenderedCallback === true){
            const templateArray = this.template.querySelectorAll('c-owc-Multiple-File-Upload-Details-Cmp')
            for (let i = 0; i < templateArray.length; i++){
                if(templateArray[i].name === 'vacationTimeClaimId'){
                        templateArray[i].getDocInfos(this.vacationTimeClaimDetails, this.isFormPreviewMode);
                }
                else if(templateArray[i].name === 'unreimbursedDocId'){
                        templateArray[i].getDocInfos(this.unreimbursedDoc, this.isFormPreviewMode);
                }
                else if(templateArray[i].name === 'overSheetDocId' && this.isDaysOrWeekVaried === true){
                        templateArray[i].getDocInfos(this.overTimeSheet, this.isFormPreviewMode);
                }
            }
            this.isRenderedCallback = false
        }
        if(this.isRenderedCallback === true && this.companyHolidaySelection !== undefined && this.companyHolidaySelection !== null){
            this.template.querySelector('[data-id="companyHolidaySelection"]').value = this.companyHolidaySelection
        }
    }   
}