import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';

export default class OwcSplitShiftPremiumGarmentContainer extends LightningElement {
    // Attributes
    @api renderSplitShiftSectionData = [{ heading : customLabelValues.OWC_split_shift_premium_claim_heading, button : false, sectionId : 1 }]
    @api splitShiftDetails = []
    @api splitShiftSectionValues
    @api isNotChangedCurrentStep = false
    @api isrenderedCallback = false;
    // @api thirdcomponentrender = false
    @api deleteSplitShiftSection
    @api splitShiftSectionDataAfterDelete = []
    @api isSplitShiftSectionDeleted = false
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

    @track isrenderSplitShiftSectionData = true
    @api isFormPreviewMode = false

    // This method is called on add more section
    addMoreSplitShiftSection(){
        this.isrenderSplitShiftSectionData = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderSplitShiftSectionData.push({ heading : customLabelValues.OWC_another_split_shift_claim, button : true, sectionId : this.flag1 })
        this.isrenderSplitShiftSectionData = true
    }

    // This is used to get the all section JSON inputs
    handleEmployerSectionDeletedData(event){
        const splitShiftInfoSectionData = event.detail
        this.splitShiftSectionDataAfterDelete.push(splitShiftInfoSectionData)
    }

    // This method is called on delete the section
    handleSectionDelete(event){
        var flag1 = 1
        const splitShiftInfoAfterDelete = []
        this.isrenderSplitShiftSectionData = false
        this.splitShiftSectionDataAfterDelete.length = 0
        this.deleteSplitShiftSectionId = event.currentTarget.name
        const splitShiftSectionDeleted = this.template.querySelectorAll('c-owc-Split-Shift-Premium-Garment-Child')
        for (let i = 0; i < splitShiftSectionDeleted.length; i++){
            splitShiftSectionDeleted[i].handleSplitShiftSectionData()
        }
        const deleteSectionDataIndex = this.splitShiftSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteSplitShiftSectionId)
        // const employerTemp = this.template.querySelectorAll('c-owc-Split-Shift-Premium-Garment-Child')
        // employerTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
        this.splitShiftSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        console.log('splitShiftSectionDataAfterDelete ::: ', JSON.stringify(this.splitShiftSectionDataAfterDelete));
        const deletedSectionIndex = this.renderSplitShiftSectionData.findIndex(sec => sec.sectionId === this.deleteSplitShiftSectionId)
        this.renderSplitShiftSectionData.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderSplitShiftSectionData.length ;i++){
            flag1 = 1 + i
            if(this.renderSplitShiftSectionData[i].heading === customLabelValues.OWC_split_shift_premium_claim_heading){
                splitShiftInfoAfterDelete.push(this.renderSplitShiftSectionData[i])
            }
            else{
                splitShiftInfoAfterDelete.push({ heading : customLabelValues.OWC_another_split_shift_claim, button : true, sectionId : flag1 })
            }
        }
        this.renderSplitShiftSectionData.length = 0
        for (var i of splitShiftInfoAfterDelete){
            this.renderSplitShiftSectionData.push(i)
        }
        // this.renderSplitShiftSectionData = splitShiftInfoAfterDelete
        this.flag1 = this.renderSplitShiftSectionData.length
        this.isrenderSplitShiftSectionData = true
        this.isSplitShiftSectionDeleted = true
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

    handleSplitShiftChildValidityEvent(event){
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
        const temp = this.template.querySelectorAll('c-owc-Split-Shift-Premium-Garment-Child');
        if(temp.length > 0){
            for(var i=0; i<temp.length; i++){
                temp[i].handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode);
            }
        }
    }

    @api vtCaseIssueObj;
    @api caseIssueList = []
    handleSplitShiftInfoEvent(event){
        const result = event.detail;
        const overTimeSectionData = result.splitShiftInfoObj
        const vtCaseIssueObj = result.vtCaseIssueObj;
        this.vtCaseIssueObj = vtCaseIssueObj
        this.caseIssueList.push(this.vtCaseIssueObj)
        console.log('overTimeSectionData', JSON.stringify(overTimeSectionData))
        this.splitShiftSectionValues = overTimeSectionData
        
        // this.splitShiftDetails.length = 0
        this.splitShiftDetails.push(this.splitShiftSectionValues)
        console.log('splitShiftDetails :::: ', JSON.stringify(this.splitShiftDetails))
        console.log('splitShiftSectionValues:', JSON.stringify(this.splitShiftSectionValues));
        const selectEvent = new CustomEvent('splitshiftparentinfoevent', {
            detail: {
                splitShiftDetails : this.splitShiftDetails,
                renderSplitShiftSectionData : this.renderSplitShiftSectionData,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    handleSplitShiftInfoData(){
        const selectEvent = new CustomEvent('splitshiftparentinfoevent', {
            detail: {
                splitShiftDetails : this.splitShiftDetails,
                renderSplitShiftSectionData : this.renderSplitShiftSectionData,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    overTimeContainerValidityCheck(){
        const selectEvent = new CustomEvent('splitshiftparentvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }
    // This method is used to send the data of the parent cmp
    @api
    handleSickLeaveTimeParent(){
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Split-Shift-Premium-Garment-Child');
        for(var i=0; i<overTimeTemplate.length; i++){
            overTimeTemplate[i].handleSplitShiftParentInfo();
        }

        this.isNotChangedCurrentStep === true ? this.overTimeContainerValidityCheck() : this.handleSplitShiftInfoData(); 
    }

    data
    @api 
    handleSplitShiftChildInfo(strString, strString1,isFormPreviewMode){
        console.log('overTimeData in parent child ::: ', JSON.stringify(strString));
        this.isFormPreviewMode = isFormPreviewMode
        this.data = strString
        this.renderSplitShiftSectionData.length = 0
        this.isrenderSplitShiftSectionData = true
        if(strString1 != undefined || strString1 != null || strString1 != ''){
            for(let i = 0;i < strString1.length;i++){
                this.isrenderSplitShiftSectionData = false
                this.renderSplitShiftSectionData.push(strString1[i])
            }
        }
        this.flag1 = this.renderSplitShiftSectionData.length
        this.isrenderSplitShiftSectionData = true
        this.isrenderedCallback = true
        
    }

    renderedCallback(){
        if(this.isrenderedCallback === false && this.paymentOfWagesDetails !== undefined){
            const temp = this.template.querySelectorAll('c-owc-Split-Shift-Premium-Garment-Child');
            if(temp.length > 0){
                for(var i=0; i<temp.length; i++){
                    temp[i].handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
                }
            }
        }
        if(this.isrenderedCallback === true){
            const splitShiftDetails = this.data
            console.log('overTime data in Child', this.data)
            const details = this.template.querySelectorAll('c-owc-Split-Shift-Premium-Garment-Child')
            for (let i = 0; i < details.length; i++){
            details[i].handleOverTimeChildData(splitShiftDetails[i],this.isFormPreviewMode)
        }
    }
        this.isrenderedCallback = false;
        if(this.isSplitShiftSectionDeleted === true){
            const splitShiftDetails = this.splitShiftSectionDataAfterDelete
            const splitShiftSectionDeleted = this.template.querySelectorAll('c-owc-Split-Shift-Premium-Garment-Child')
            for (let i = 0; i < splitShiftSectionDeleted.length; i++){
                splitShiftSectionDeleted[i].handleOverTimeChildData(splitShiftDetails[i])
            }
            this.isSplitShiftSectionDeleted = false
        }
    }
}