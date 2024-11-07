import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
export default class OwcNotPaidSickLeaveContainer extends LightningElement {
    // Attributes
    @api renderSickLeaveSection = [{ heading : customLabelValues.OWC_sick_leave_claim_heading_label, button : false, sectionId : 1 }]
    @api sickLeaveDetails = []
    @api sickLeaveSectionValues
    @api isNotChangedCurrentStep = false
    @api isrenderedCallback = false;
    // @api thirdcomponentrender = false
    @api deleteSickLeaveSection
    @api sickLeaveSectionDataAfterDelete = []
    @api isSickLeaveSectionDeleted = false
    @api paystubsickrecord;
    flag = 0
    flag1 = 1
    @api iswagedefpreview;

    // Accepted formats for File Upload Section
    get acceptedFormats() {
        return acceptedFileFormat;
    }

    @api paymentOfWagesDetails
    @api
    handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
        this.paymentOfWagesDetails = paymentOfWagesDetails
        console.log('Payment detail in child 0 ::: ', JSON.stringify(paymentOfWagesDetails));
        const temp = this.template.querySelectorAll('c-owc-Not-Paid-Sick-Leave-Child');
        if(temp.length > 0){
            for(var i=0; i<temp.length; i++){
                temp[i].handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode);
            }
        }
    }

    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    @track isrenderSickLeaveSection = true
    @api isFormPreviewMode = false

    // This method is called on add more section
    addMoreSickLeaveSection(){
        this.isrenderSickLeaveSection = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderSickLeaveSection.push({ heading : customLabelValues.OWC_another_sick_leave_claim_heading, button : true, sectionId : this.flag1 })
        this.isrenderSickLeaveSection = true
    }

    // This is used to get the all section JSON inputs
    handleEmployerSectionDeletedData(event){
        const sickLeaveInfoSectionData = event.detail
        this.sickLeaveSectionDataAfterDelete.push(sickLeaveInfoSectionData)
    }

    // This method is called on delete the section
    handleSectionDelete(event){
        var flag1 = 1
        const sickLeaveInfoAfterDelete = []
        this.isrenderSickLeaveSection = false
        this.sickLeaveSectionDataAfterDelete.length = 0
        this.deleteSickLeaveSectionId = event.currentTarget.name
        const sickLeaveSectionDelete = this.template.querySelectorAll('c-owc-Not-Paid-Sick-Leave-Child')
        for (let i = 0; i < sickLeaveSectionDelete.length; i++){
            sickLeaveSectionDelete[i].handleSickLeaveSectionData()
        }
        const deleteSectionDataIndex = this.sickLeaveSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteSickLeaveSectionId)
        // const employerTemp = this.template.querySelectorAll('c-owc-Not-Paid-Sick-Leave-Child')
        // employerTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
        this.sickLeaveSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        console.log('sickLeaveSectionDataAfterDelete ::: ', JSON.stringify(this.sickLeaveSectionDataAfterDelete));
        const deletedSectionIndex = this.renderSickLeaveSection.findIndex(sec => sec.sectionId === this.deleteSickLeaveSectionId)
        this.renderSickLeaveSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderSickLeaveSection.length ;i++){
            flag1 = 1 + i
            if(this.renderSickLeaveSection[i].heading === customLabelValues.OWC_sick_leave_claim_heading_label){
                sickLeaveInfoAfterDelete.push(this.renderSickLeaveSection[i])
            }
            else{
                sickLeaveInfoAfterDelete.push({ heading : customLabelValues.OWC_another_sick_leave_claim_heading, button : true, sectionId : flag1 })
            }
        }
        this.renderSickLeaveSection.length = 0
        for (var i of sickLeaveInfoAfterDelete){
            this.renderSickLeaveSection.push(i)
        }
        // this.renderSickLeaveSection = sickLeaveInfoAfterDelete
        this.flag1 = this.renderSickLeaveSection.length
        this.isrenderSickLeaveSection = true
        this.isSickLeaveSectionDeleted = true
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

    @api vtCaseIssueObj
    @api caseIssueList = []
    handleOverTimeInfoEvent(event){
        const result = event.detail
        const overTimeSectionData = result.sickLeaveInfoObj
        console.log('overTimeSectionData', JSON.stringify(result.vtCaseIssueObj))
        this.sickLeaveSectionValues = overTimeSectionData
        const vtCaseIssueObj = result.vtCaseIssueObj;
        this.vtCaseIssueObj = vtCaseIssueObj
        this.caseIssueList.push(this.vtCaseIssueObj)
        // this.sickLeaveDetails.length = 0
        this.sickLeaveDetails.push(this.sickLeaveSectionValues)
        console.log('sickLeaveDetails :::: ', JSON.stringify(this.sickLeaveDetails))
        console.log('sickLeaveSectionValues:', JSON.stringify(this.sickLeaveSectionValues));
        const selectEvent = new CustomEvent('sickleaveparentinfoevent', {
            detail: {
                sickLeaveDetails : this.sickLeaveDetails,
                renderSickLeaveSection : this.renderSickLeaveSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    handleOverTimeParentInfoData(){
        const selectEvent = new CustomEvent('sickleaveparentinfoevent', {
            detail: {
                sickLeaveDetails : this.sickLeaveDetails,
                renderSickLeaveSection : this.renderSickLeaveSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    overTimeContainerValidityCheck(){
        const selectEvent = new CustomEvent('sickleaveparentvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }
    
    @api
    handleSickLeaveTimeParent(){
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Not-Paid-Sick-Leave-Child');
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
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Not-Paid-Sick-Leave-Child');
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
        this.renderSickLeaveSection.length = 0
        this.isrenderSickLeaveSection = true
        if(strString1 != undefined || strString1 != null || strString1 != ''){
            for(let i = 0;i < strString1.length;i++){
                this.isrenderSickLeaveSection = false
                this.renderSickLeaveSection.push(strString1[i])
            }
        }
        this.flag1 = this.renderSickLeaveSection.length
        this.isrenderSickLeaveSection = true
        this.isrenderedCallback = true
        
    }

    renderedCallback(){
        if(this.isrenderedCallback === false && this.paymentOfWagesDetails !== undefined){
            const temp = this.template.querySelectorAll('c-owc-Not-Paid-Sick-Leave-Child');
            if(temp.length > 0){
                for(var i=0; i<temp.length; i++){
                    temp[i].handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
                }
            }
        }
        if(this.isrenderedCallback === true){
            const sickLeaveDetails = this.data
            console.log('overTime data in Child', this.data)
            const details = this.template.querySelectorAll('c-owc-Not-Paid-Sick-Leave-Child')
            for (let i = 0; i < details.length; i++){
            details[i].handleOverTimeChildData(sickLeaveDetails[i],this.isFormPreviewMode)
        }
    }
        this.isrenderedCallback = false;
        if(this.isSickLeaveSectionDeleted === true){
            const sickLeaveDetails = this.sickLeaveSectionDataAfterDelete
            const sickLeaveSectionDelete = this.template.querySelectorAll('c-owc-Not-Paid-Sick-Leave-Child')
            for (let i = 0; i < sickLeaveSectionDelete.length; i++){
                sickLeaveSectionDelete[i].handleOverTimeChildData(sickLeaveDetails[i])
            }
            this.isSickLeaveSectionDeleted = false

        }
    }
}