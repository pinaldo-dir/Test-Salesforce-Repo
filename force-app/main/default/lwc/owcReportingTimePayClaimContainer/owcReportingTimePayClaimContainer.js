import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
export default class OwcReportingTimePayClaimContainer extends LightningElement {
    // Attributes
    @api renderPayClaimSection = [{ heading : customLabelValues.OWC_reporting_time_pay_claim_heading, button : false, sectionId : 1 }]
    @api payClaimDetails = []
    @api payClaimSectionValues
    @api isNotChangedCurrentStep = false
    @api isrenderedCallback = false;
    // @api thirdcomponentrender = false
    @api deletePayClaimSection
    @api payClaimSectionDataAfterDelete = []
    @api isPayClaimSectionDeleted = false
    flag = 0
    flag1 = 1
    @api iswagedefpreview
    @api iwcinfoobj;
    // Accepted formats for File Upload Section
    get acceptedFormats() {
        return acceptedFileFormat;
    }

    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    @track isrenderPayClaimSection = true
    @api isFormPreviewMode = false

    // This method is called on add more section
    addMoreSickLeaveSection(){
        this.isrenderPayClaimSection = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderPayClaimSection.push({ heading : customLabelValues.OWC_another_pay_time_claim_heading, button : true, sectionId : this.flag1 })
        this.isrenderPayClaimSection = true
    }

    // This is used to get the all section JSON inputs
    handleEmployerSectionDeletedData(event){
        const payClaimInfoSectionData = event.detail
        this.payClaimSectionDataAfterDelete.push(payClaimInfoSectionData)
    }

    // This method is called on delete the section
    handleSectionDelete(event){
        var flag1 = 1
        const restBreakInfoAfterDelete = []
        this.isrenderPayClaimSection = false
        this.payClaimSectionDataAfterDelete.length = 0
        this.deletePayClaimSectionId = event.currentTarget.name
        const payClaimSectionDelete = this.template.querySelectorAll('c-owc-Reporting-Time-Pay-Claim-Child')
        for (let i = 0; i < payClaimSectionDelete.length; i++){
            payClaimSectionDelete[i].handlePayClaimSectionData()
        }
        const deleteSectionDataIndex = this.payClaimSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deletePayClaimSectionId)
        // const employerTemp = this.template.querySelectorAll('c-owc-Reporting-Time-Pay-Claim-Child')
        // employerTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
        this.payClaimSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        console.log('payClaimSectionDataAfterDelete ::: ', JSON.stringify(this.payClaimSectionDataAfterDelete));
        const deletedSectionIndex = this.renderPayClaimSection.findIndex(sec => sec.sectionId === this.deletePayClaimSectionId)
        this.renderPayClaimSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderPayClaimSection.length ;i++){
            flag1 = 1 + i
            if(this.renderPayClaimSection[i].heading === customLabelValues.OWC_reporting_time_pay_claim_heading){
                restBreakInfoAfterDelete.push(this.renderPayClaimSection[i])
            }
            else{
                restBreakInfoAfterDelete.push({ heading : customLabelValues.OWC_another_pay_time_claim_heading, button : true, sectionId : flag1 })
            }
        }
        this.renderPayClaimSection.length = 0
        for (var i of restBreakInfoAfterDelete){
            this.renderPayClaimSection.push(i)
        }
        // this.renderPayClaimSection = restBreakInfoAfterDelete
        this.flag1 = this.renderPayClaimSection.length
        this.isrenderPayClaimSection = true
        this.isPayClaimSectionDeleted = true
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
        const overTimeSectionData = result.restClaimInfoObj
        console.log('overTimeSectionData', JSON.stringify(overTimeSectionData))
        this.payClaimSectionValues = overTimeSectionData
        const vtCaseIssueObj = result.vtCaseIssueObj;
        this.vtCaseIssueObj = vtCaseIssueObj
        this.caseIssueList.push(this.vtCaseIssueObj)
        // this.payClaimDetails.length = 0
        this.payClaimDetails.push(this.payClaimSectionValues)
        console.log('payClaimDetails :::: ', JSON.stringify(this.payClaimDetails))
        console.log('payClaimSectionValues:', JSON.stringify(this.payClaimSectionValues));
        const selectEvent = new CustomEvent('payclaimparentinfoevent', {
            detail: {
                payClaimDetails : this.payClaimDetails,
                renderPayClaimSection : this.renderPayClaimSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    handleOverTimeParentInfoData(){
        const selectEvent = new CustomEvent('payclaimparentinfoevent', {
            detail: {
                payClaimDetails : this.payClaimDetails,
                renderPayClaimSection : this.renderPayClaimSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    overTimeContainerValidityCheck(){
        const selectEvent = new CustomEvent('payclaimparentvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    @api
    handleSickLeaveTimeParent(){
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Reporting-Time-Pay-Claim-Child');
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
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Reporting-Time-Pay-Claim-Child');
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
        this.renderPayClaimSection.length = 0
        this.isrenderPayClaimSection = true
        if(strString1 != undefined || strString1 != null || strString1 != ''){
            for(let i = 0;i < strString1.length;i++){
                this.isrenderPayClaimSection = false
                this.renderPayClaimSection.push(strString1[i])
            }
        }
        this.flag1 = this.renderPayClaimSection.length
        this.isrenderPayClaimSection = true
        this.isrenderedCallback = true
        
    }

    @api paymentOfWagesDetails
    @api
    handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
        this.paymentOfWagesDetails = paymentOfWagesDetails
        console.log('Payment detail in child 0 ::: ', JSON.stringify(paymentOfWagesDetails));
        const temp = this.template.querySelectorAll('c-owc-Reporting-Time-Pay-Claim-Child');
        if(temp.length > 0){
            for(var i=0; i<temp.length; i++){
                temp[i].handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode);
            }
        }
    }

    renderedCallback(){
        if(this.isrenderedCallback === false && this.paymentOfWagesDetails !== undefined){
            const temp = this.template.querySelectorAll('c-owc-Reporting-Time-Pay-Claim-Child');
            if(temp.length > 0){
                for(var i=0; i<temp.length; i++){
                    temp[i].handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
                }
            }
        }
        if(this.isrenderedCallback === true){
            const payClaimDetails = this.data
            console.log('overTime data in Child', this.data)
            const details = this.template.querySelectorAll('c-owc-Reporting-Time-Pay-Claim-Child')
            for (let i = 0; i < details.length; i++){
            details[i].handleOverTimeChildData(payClaimDetails[i],this.isFormPreviewMode)
        }
    }
        this.isrenderedCallback = false;
        if(this.isPayClaimSectionDeleted === true){
            const payClaimDetails = this.payClaimSectionDataAfterDelete
            const payClaimSectionDelete = this.template.querySelectorAll('c-owc-Reporting-Time-Pay-Claim-Child')
            for (let i = 0; i < payClaimSectionDelete.length; i++){
                payClaimSectionDelete[i].handleOverTimeChildData(payClaimDetails[i])
            }
            this.isPayClaimSectionDeleted = false
        }
    }
}