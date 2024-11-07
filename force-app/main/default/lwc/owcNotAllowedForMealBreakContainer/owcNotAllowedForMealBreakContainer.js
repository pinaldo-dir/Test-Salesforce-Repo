import { LightningElement, api, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
export default class OwcNotAllowedForMealBreakContainer extends LightningElement {
    // Attributes
    @api renderMealBreakSection = [{ heading : customLabelValues.OWC_meal_break_claim_heading, button : false, sectionId : 1 }]
    @api mealBreakDetails = []
    @api mealBreakSectionValues
    @api isNotChangedCurrentStep = false
    @api isrenderedCallback = false;
    // @api thirdcomponentrender = false
    @api deleteMealBreakSection
    @api mealBreakSectionDataAfterDelete = []
    @api isMealBreakSectionDeleted = false
    flag = 0
    flag1 = 1
    @api iwcinfoobj
    @api iswagedefpreview;

    // Accepted formats for File Upload Section
    get acceptedFormats() {
        return acceptedFileFormat;
    }

    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    @track isrenderMealBreakSection = true
    @api isFormPreviewMode = false

    // This method is called on add more section
    addMoreSickLeaveSection(){
        this.isrenderMealBreakSection = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderMealBreakSection.push({ heading : customLabelValues.OWC_another_meal_break_claim_heading_label, button : true, sectionId : this.flag1 })
        this.isrenderMealBreakSection = true
    }

    // This is used to get the all section JSON inputs
    handleEmployerSectionDeletedData(event){
        const mealBreakInfoSectionData = event.detail
        this.mealBreakSectionDataAfterDelete.push(mealBreakInfoSectionData)
    }

    // This method is called on delete the section
    handleSectionDelete(event){
        var flag1 = 1
        const restBreakInfoAfterDelete = []
        this.isrenderMealBreakSection = false
        this.mealBreakSectionDataAfterDelete.length = 0
        this.deleteMealBreakSectionId = event.currentTarget.name
        const mealBreakSectionDelete = this.template.querySelectorAll('c-owc-Not-Allowed-Meal-Break-Child')
        for (let i = 0; i < mealBreakSectionDelete.length; i++){
            mealBreakSectionDelete[i].handleMealBreakSectionData()
        }
        const deleteSectionDataIndex = this.mealBreakSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteMealBreakSectionId)
        // const employerTemp = this.template.querySelectorAll('c-owc-Not-Allowed-Meal-Break-Child')
        // employerTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
        this.mealBreakSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        console.log('mealBreakSectionDataAfterDelete ::: ', JSON.stringify(this.mealBreakSectionDataAfterDelete));
        const deletedSectionIndex = this.renderMealBreakSection.findIndex(sec => sec.sectionId === this.deleteMealBreakSectionId)
        this.renderMealBreakSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderMealBreakSection.length ;i++){
            flag1 = 1 + i
            if(this.renderMealBreakSection[i].heading === customLabelValues.OWC_meal_break_claim_heading){
                restBreakInfoAfterDelete.push(this.renderMealBreakSection[i])
            }
            else{
                restBreakInfoAfterDelete.push({ heading : customLabelValues.OWC_another_meal_break_claim_heading_label, button : true, sectionId : flag1 })
            }
        }
        this.renderMealBreakSection.length = 0
        for (var i of restBreakInfoAfterDelete){
            this.renderMealBreakSection.push(i)
        }
        // this.renderMealBreakSection = restBreakInfoAfterDelete
        this.flag1 = this.renderMealBreakSection.length
        this.isrenderMealBreakSection = true
        this.isMealBreakSectionDeleted = true
        this.showToast('Success!', this.customLabelValues.OWC_deleteSection_msg, 'success')
    }

    // Imported Custom lable values
    customLabelValues = customLabelValues

    // Connected Callback method load on doinit
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

    handleOverTimeChildValidityEvent(event){
        if(event.detail.currentStep === true){
            this.isNotChangedCurrentStep = event.detail.currentStep;
        }
        else{
            this.isNotChangedCurrentStep = false;
        }
        
    }

    @api paymentOfWagesDetails
    @api
    handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
        this.paymentOfWagesDetails = paymentOfWagesDetails
        console.log('Payment detail in child 014 ::: ', JSON.stringify(paymentOfWagesDetails));
        const temp = this.template.querySelectorAll('c-owc-Not-Allowed-Meal-Break-Child');
        if(temp.length > 0){
            for(var i=0; i<temp.length; i++){
                temp[i].handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode);
            }
        }
    }

    @api vtCaseIssueObj;
    @api caseIssueList = []
    handleOverTimeInfoEvent(event){
        const result = event.detail;
        const overTimeSectionData = result.mealBreakInfoObj
        const vtCaseIssueObj = result.vtCaseIssueObj;
        this.vtCaseIssueObj = vtCaseIssueObj
        this.caseIssueList.push(this.vtCaseIssueObj)
        console.log('overTimeSectionData', JSON.stringify(overTimeSectionData))
        this.mealBreakSectionValues = overTimeSectionData
        
        // this.mealBreakDetails.length = 0
        this.mealBreakDetails.push(this.mealBreakSectionValues)
        console.log('mealBreakDetails :::: ', JSON.stringify(this.mealBreakDetails))
        console.log('mealBreakSectionValues:', JSON.stringify(this.mealBreakSectionValues));
        const selectEvent = new CustomEvent('mealbreakparentinfoevent', {
            detail: {
                mealBreakDetails : this.mealBreakDetails,
                renderMealBreakSection : this.renderMealBreakSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    handleOverTimeParentInfoData(){
        const selectEvent = new CustomEvent('mealbreakparentinfoevent', {
            detail: {
                mealBreakDetails : this.mealBreakDetails,
                renderMealBreakSection : this.renderMealBreakSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    overTimeContainerValidityCheck(){
        const selectEvent = new CustomEvent('mealbreakparentvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }
    
    @api
    handleSickLeaveTimeParent(){
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Not-Allowed-Meal-Break-Child');
        for(var i=0; i<overTimeTemplate.length; i++){
            overTimeTemplate[i].handleOverTimeParentData();
        }

        if(this.isNotChangedCurrentStep === true){
            this.overTimeContainerValidityCheck();
        }
    }

    // This method is used to send the data of the parent cmp
    @api
    handleSickLeaveTimeParent2(){
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Not-Allowed-Meal-Break-Child');
        for(var i=0; i<overTimeTemplate.length; i++){
            overTimeTemplate[i].handleOverTimeParentInfo();
        }
    }

    data
    @api 
    overTimeParentInfoSectionChild(strString, strString1,isFormPreviewMode){
        console.log('overTimeData in parent child ::: ', JSON.stringify(strString));
        this.isFormPreviewMode = isFormPreviewMode
        this.data = strString
        this.renderMealBreakSection.length = 0
        this.isrenderMealBreakSection = true
        if(strString1 != undefined || strString1 != null || strString1 != ''){
            for(let i = 0;i < strString1.length;i++){
                this.isrenderMealBreakSection = false
                this.renderMealBreakSection.push(strString1[i])
            }
        }
        this.flag1 = this.renderMealBreakSection.length
        this.isrenderMealBreakSection = true
        this.isrenderedCallback = true
        
    }

    renderedCallback(){
        if(this.isrenderedCallback === false && this.paymentOfWagesDetails !== undefined){
            const temp = this.template.querySelectorAll('c-owc-Not-Allowed-Meal-Break-Child');
            if(temp.length > 0){
                for(var i=0; i<temp.length; i++){
                    temp[i].handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
                }
            }
        }
        if(this.isrenderedCallback === true){
            const mealBreakDetails = this.data
            console.log('overTime data in Child', this.data)
            const details = this.template.querySelectorAll('c-owc-Not-Allowed-Meal-Break-Child')
            for (let i = 0; i < details.length; i++){
            details[i].handleOverTimeChildData(mealBreakDetails[i],this.isFormPreviewMode)
        }
    }
        this.isrenderedCallback = false;
        if(this.isMealBreakSectionDeleted === true){
            const mealBreakDetails = this.mealBreakSectionDataAfterDelete
            const mealBreakSectionDelete = this.template.querySelectorAll('c-owc-Not-Allowed-Meal-Break-Child')
            for (let i = 0; i < mealBreakSectionDelete.length; i++){
                mealBreakSectionDelete[i].handleOverTimeChildData(mealBreakDetails[i])
            }
            this.isMealBreakSectionDeleted = false
        }
    }
}