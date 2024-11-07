import { LightningElement, api, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
export default class OwcDeniedMilegaPayContainer extends LightningElement {
    // Attributes
    @api renderMilegaClaimSection = [{ heading : customLabelValues.OWC_milega_expense_claim, button : false, sectionId : 1 }]
    @api mileageClaimDetails = []
    @api mileageClaimSectionValues
    @api isNotChangedCurrentStep = false
    @api isrenderedCallback = false;
    // @api thirdcomponentrender = false
    @api deleteMileageClaimSection
    @api mileageClaimSectionDataAfterDelete = []
    @api isMileageClaimSectionDeleted = false
    flag = 0
    flag1 = 1
    @api iswagedefpreview;

    // Accepted formats for File Upload Section
    get acceptedFormats() {
        return acceptedFileFormat;
    }

    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    @track isrenderMilegaClaimSection = true
    @api isFormPreviewMode = false

    // This method is called on add more section
    addMoreSickLeaveSection(){
        this.isrenderMilegaClaimSection = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderMilegaClaimSection.push({ heading : customLabelValues.OWC_another_milega_expense_claim_label, button : true, sectionId : this.flag1 })
        this.isrenderMilegaClaimSection = true
    }

    // This is used to get the all section JSON inputs
    handleEmployerSectionDeletedData(event){
        const mileageSectiomInfoData = event.detail
        this.mileageClaimSectionDataAfterDelete.push(mileageSectiomInfoData)
    }

    // This method is called on delete the section
    handleSectionDelete(event){
        var flag1 = 1
        const restBreakInfoAfterDelete = []
        this.isrenderMilegaClaimSection = false
        this.mileageClaimSectionDataAfterDelete.length = 0
        this.deleteMileageClaimSectionId = event.currentTarget.name
        const mileageClaimSectionDelete = this.template.querySelectorAll('c-owc-Denied-Milega-Pay-Child')
        for (let i = 0; i < mileageClaimSectionDelete.length; i++){
            mileageClaimSectionDelete[i].handleMileageClaimSectionData()
        }
        const deleteSectionDataIndex = this.mileageClaimSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteMileageClaimSectionId)
        // const employerTemp = this.template.querySelectorAll('c-owc-Denied-Milega-Pay-Child')
        // employerTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
        this.mileageClaimSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        console.log('mileageClaimSectionDataAfterDelete ::: ', JSON.stringify(this.mileageClaimSectionDataAfterDelete));
        const deletedSectionIndex = this.renderMilegaClaimSection.findIndex(sec => sec.sectionId === this.deleteMileageClaimSectionId)
        this.renderMilegaClaimSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderMilegaClaimSection.length ;i++){
            flag1 = 1 + i
            if(this.renderMilegaClaimSection[i].heading === customLabelValues.OWC_milega_expense_claim){
                restBreakInfoAfterDelete.push(this.renderMilegaClaimSection[i])
            }
            else{
                restBreakInfoAfterDelete.push({ heading : customLabelValues.OWC_another_milega_expense_claim_label, button : true, sectionId : flag1 })
            }
        }
        this.renderMilegaClaimSection.length = 0
        for (var i of restBreakInfoAfterDelete){
            this.renderMilegaClaimSection.push(i)
        }
        // this.renderMilegaClaimSection = restBreakInfoAfterDelete
        this.flag1 = this.renderMilegaClaimSection.length
        this.isrenderMilegaClaimSection = true
        this.isMileageClaimSectionDeleted = true
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
        const result = event.detail;
        const overTimeSectionData = result.mileageClaimInfoObj;
        console.log('overTimeSectionData', JSON.stringify(overTimeSectionData))
        this.mileageClaimSectionValues = overTimeSectionData
        const vtCaseIssueObj = result.vtCaseIssueObj;
        this.vtCaseIssueObj = vtCaseIssueObj
        this.caseIssueList.push(this.vtCaseIssueObj)
        // this.mileageClaimDetails.length = 0
        this.mileageClaimDetails.push(this.mileageClaimSectionValues)
        console.log('mileageClaimDetails :::: ', JSON.stringify(this.mileageClaimDetails))
        console.log('mileageClaimSectionValues:', JSON.stringify(this.mileageClaimSectionValues));
        const selectEvent = new CustomEvent('mileageclaimparentinfoevent', {
            detail: {
                mileageClaimDetails : this.mileageClaimDetails,
                renderMilegaClaimSection : this.renderMilegaClaimSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    handleOverTimeParentInfoData(){
        const selectEvent = new CustomEvent('mileageclaimparentinfoevent', {
            detail: {
                mileageClaimDetails : this.mileageClaimDetails,
                renderMilegaClaimSection : this.renderMilegaClaimSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    overTimeContainerValidityCheck(){
        const selectEvent = new CustomEvent('mileageclaimparentvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    @api
    handleSickLeaveTimeParent(){
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Denied-Milega-Pay-Child');
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
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Denied-Milega-Pay-Child');
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
        this.renderMilegaClaimSection.length = 0
        this.isrenderMilegaClaimSection = true
        if(strString1 != undefined || strString1 != null || strString1 != ''){
            for(let i = 0;i < strString1.length;i++){
                this.isrenderMilegaClaimSection = false
                this.renderMilegaClaimSection.push(strString1[i])
            }
        }
        this.flag1 = this.renderMilegaClaimSection.length
        this.isrenderMilegaClaimSection = true
        this.isrenderedCallback = true
        
    }

    renderedCallback(){
        if(this.isrenderedCallback === true){
            const mileageClaimDetails = this.data
            console.log('overTime data in Child', this.data)
            const details = this.template.querySelectorAll('c-owc-Denied-Milega-Pay-Child')
            for (let i = 0; i < details.length; i++){
            details[i].handleOverTimeChildData(mileageClaimDetails[i],this.isFormPreviewMode)
        }
    }
        this.isrenderedCallback = false;
        if(this.isMileageClaimSectionDeleted === true){
            const mileageClaimDetails = this.mileageClaimSectionDataAfterDelete
            const mileageClaimSectionDelete = this.template.querySelectorAll('c-owc-Denied-Milega-Pay-Child')
            for (let i = 0; i < mileageClaimSectionDelete.length; i++){
                mileageClaimSectionDelete[i].handleOverTimeChildData(mileageClaimDetails[i])
            }
            this.isMileageClaimSectionDeleted = false
        }
    }
}