import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
export default class OwcNotAllowedRestBreakContainer extends LightningElement {
    // Attributes
    @api renderRestBreakSection = [{ heading : customLabelValues.OWC_rest_break_claim_heading_label, button : false, sectionId : 1 }]
    @api restBreakDetails = []
    @api restBreakSectionValues
    @api isNotChangedCurrentStep = false
    @api isrenderedCallback = false;
    // @api thirdcomponentrender = false
    @api deleteRestBreakSection
    @api restBreakSectionDataAfterDelete = []
    @api isRestBreakSectionDeleted = false
    flag = 0
    flag1 = 1
    @api iwcinfoobj
    @api iswagedefpreview

    // Accepted formats for File Upload Section
    get acceptedFormats() {
        return acceptedFileFormat;
    }

    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    @track isrenderRestBreakSection = true
    @api isFormPreviewMode = false

    // This method is called on add more section
    addMoreSickLeaveSection(){
        this.isrenderRestBreakSection = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderRestBreakSection.push({ heading : customLabelValues.OWC_another_rest_break_claim_heading_label, button : true, sectionId : this.flag1 })
        this.isrenderRestBreakSection = true
    }

    // This is used to get the all section JSON inputs
    handleEmployerSectionDeletedData(event){
        const restBreakInfoSectionData = event.detail
        this.restBreakSectionDataAfterDelete.push(restBreakInfoSectionData)
    }

    // This method is called on delete the section
    handleSectionDelete(event){
        var flag1 = 1
        const restBreakInfoAfterDelete = []
        this.isrenderRestBreakSection = false
        this.restBreakSectionDataAfterDelete.length = 0
        this.deleteRestBreakSectionId = event.currentTarget.name
        const restBreakSectionDelete = this.template.querySelectorAll('c-owc-Not-Allowed-Rest-Break-Child')
        for (let i = 0; i < restBreakSectionDelete.length; i++){
            restBreakSectionDelete[i].handleRestBreakSectionData()
        }
        const deleteSectionDataIndex = this.restBreakSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteRestBreakSectionId)
        // const employerTemp = this.template.querySelectorAll('c-owc-Not-Allowed-Rest-Break-Child')
        // employerTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
        this.restBreakSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        console.log('restBreakSectionDataAfterDelete ::: ', JSON.stringify(this.restBreakSectionDataAfterDelete));
        const deletedSectionIndex = this.renderRestBreakSection.findIndex(sec => sec.sectionId === this.deleteRestBreakSectionId)
        this.renderRestBreakSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderRestBreakSection.length ;i++){
            flag1 = 1 + i
            if(this.renderRestBreakSection[i].heading === customLabelValues.OWC_rest_break_claim_heading_label){
                restBreakInfoAfterDelete.push(this.renderRestBreakSection[i])
            }
            else{
                restBreakInfoAfterDelete.push({ heading : customLabelValues.OWC_another_rest_break_claim_heading_label, button : true, sectionId : flag1 })
            }
        }
        this.renderRestBreakSection.length = 0
        for (var i of restBreakInfoAfterDelete){
            this.renderRestBreakSection.push(i)
        }
        // this.renderRestBreakSection = restBreakInfoAfterDelete
        this.flag1 = this.renderRestBreakSection.length
        this.isrenderRestBreakSection = true
        this.isRestBreakSectionDeleted = true
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
    
    @api paymentOfWagesDetails
    @api
    handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
        this.paymentOfWagesDetails = paymentOfWagesDetails
        console.log('Payment detail in child 0 ::: ', JSON.stringify(paymentOfWagesDetails));
        const temp = this.template.querySelectorAll('c-owc-Not-Allowed-Rest-Break-Child');
        if(temp.length > 0){
            for(var i=0; i<temp.length; i++){
                temp[i].handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode);
            }
        }
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

    @api vtCaseIssueObj;
    @api caseIssueList = []
    handleOverTimeInfoEvent(event){
        const result = event.detail;
        const overTimeSectionData = result.restBreakInfoObj
        console.log('overTimeSectionData', JSON.stringify(overTimeSectionData))
        this.restBreakSectionValues = overTimeSectionData
        const vtCaseIssueObj = result.vtCaseIssueObj;
        this.vtCaseIssueObj = vtCaseIssueObj
        this.caseIssueList.push(this.vtCaseIssueObj)
        // this.restBreakDetails.length = 0
        this.restBreakDetails.push(this.restBreakSectionValues)
        console.log('restBreakDetails :::: ', JSON.stringify(this.restBreakDetails))
        console.log('restBreakSectionValues:', JSON.stringify(this.restBreakSectionValues));
        const selectEvent = new CustomEvent('restbreakparentinfoevent', {
            detail: {
                restBreakDetails : this.restBreakDetails,
                renderRestBreakSection : this.renderRestBreakSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    handleOverTimeParentInfoData(){

        const selectEvent = new CustomEvent('restbreakparentinfoevent', {
            detail: {
                restBreakDetails : this.restBreakDetails,
                renderRestBreakSection : this.renderRestBreakSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    overTimeContainerValidityCheck(){
        const selectEvent = new CustomEvent('restbreakparentvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    @api
    handleSickLeaveTimeParent(){
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Not-Allowed-Rest-Break-Child');
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
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Not-Allowed-Rest-Break-Child');
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
        this.renderRestBreakSection.length = 0
        this.isrenderRestBreakSection = true
        if(strString1 != undefined || strString1 != null || strString1 != ''){
            for(let i = 0;i < strString1.length;i++){
                this.isrenderRestBreakSection = false
                this.renderRestBreakSection.push(strString1[i])
            }
        }
        this.flag1 = this.renderRestBreakSection.length
        this.isrenderRestBreakSection = true
        this.isrenderedCallback = true
        
    }

    renderedCallback(){
        if(this.isrenderedCallback === false && this.paymentOfWagesDetails !== undefined){
            const temp = this.template.querySelectorAll('c-owc-Not-Allowed-Rest-Break-Child');
            if(temp.length > 0){
                for(var i=0; i<temp.length; i++){
                    temp[i].handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
                }
            }
        }
        if(this.isrenderedCallback === true){
            const restBreakDetails = this.data
            console.log('overTime data in Child', this.data)
            const details = this.template.querySelectorAll('c-owc-Not-Allowed-Rest-Break-Child')
            for (let i = 0; i < details.length; i++){
            details[i].handleOverTimeChildData(restBreakDetails[i],this.isFormPreviewMode)
        }
    }
        this.isrenderedCallback = false;
        if(this.isRestBreakSectionDeleted === true){
            const restBreakDetails = this.restBreakSectionDataAfterDelete
            const restBreakSectionDelete = this.template.querySelectorAll('c-owc-Not-Allowed-Rest-Break-Child')
            for (let i = 0; i < restBreakSectionDelete.length; i++){
                restBreakSectionDelete[i].handleOverTimeChildData(restBreakDetails[i])
            }
            this.isRestBreakSectionDeleted = false
        }
    }
}