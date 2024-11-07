import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';

export default class OwcOverTimeOrDoubleTimeDef extends LightningElement {
    // Attributes
    @api renderOverTimeSection = [{ heading : customLabelValues.OWC_overtime_pay_claim_heading_label, button : false, sectionId : 1 }]
    @api overTimeDetails = []
    @api overTimeSectionValues
    @api isNotChangedCurrentStep = false
    @api isrenderedCallback = false;
    @api userworkedhours
    @api iswagedefpreview
    @api isfarmlabour
    @api is_domestic_worker;
    // @api thirdcomponentrender = false
    @api deleteOverTimeSection
    @api overTimeSectionDataAfterDelete = []
    @api isOverTimeSectionDeleted = false
    @api powdetails
    flag = 0
    flag1 = 1

    // Accepted formats for File Upload Section
    get acceptedFormats() {
        return acceptedFileFormat;
    }

    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    @track isrenderOverTimeSection = true
    @api isFormPreviewMode = false

    // This method is called on add more section
    addMoreOverTimeSection(){
        this.isrenderOverTimeSection = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderOverTimeSection.push({ heading : customLabelValues.OWC_overtime_another_pay_claim_heading, button : true, sectionId : this.flag1 })
        this.isrenderOverTimeSection = true
    }

    // This is used to get the all section JSON inputs
    handleEmployerSectionDeletedData(event){
        const overTimeInfoSectionData = event.detail
        this.overTimeSectionDataAfterDelete.push(overTimeInfoSectionData)
    }

    // This method is called on delete the section
    handleSectionDelete(event){
        var flag1 = 1
        const overTimeInfoAfterDelete = []
        this.isrenderOverTimeSection = false
        this.overTimeSectionDataAfterDelete.length = 0
        this.deleteOverTimeSectionId = event.currentTarget.name
        const overTimeSectionDetails = this.template.querySelectorAll('c-owc-Over-Time-Or-Double-Time-Def-Child')
        for (let i = 0; i < overTimeSectionDetails.length; i++){
            overTimeSectionDetails[i].handleOverTimeSectionData()
        }
        const deleteSectionDataIndex = this.overTimeSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteOverTimeSectionId)
        // const employerTemp = this.template.querySelectorAll('c-owc-Over-Time-Or-Double-Time-Def-Child')
        // employerTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
        this.overTimeSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        console.log('overTimeSectionDataAfterDelete ::: ', JSON.stringify(this.overTimeSectionDataAfterDelete));
        const deletedSectionIndex = this.renderOverTimeSection.findIndex(sec => sec.sectionId === this.deleteOverTimeSectionId)
        this.renderOverTimeSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderOverTimeSection.length ;i++){
            flag1 = 1 + i
            if(this.renderOverTimeSection[i].heading === customLabelValues.OWC_overtime_pay_claim_heading_label){
                overTimeInfoAfterDelete.push(this.renderOverTimeSection[i])
            }
            else{
                overTimeInfoAfterDelete.push({ heading : customLabelValues.OWC_overtime_another_pay_claim_heading, button : true, sectionId : flag1 })
            }
        }
        this.renderOverTimeSection.length = 0
        for (var i of overTimeInfoAfterDelete){
            this.renderOverTimeSection.push(i)
        }
        // this.renderOverTimeSection = overTimeInfoAfterDelete
        this.flag1 = this.renderOverTimeSection.length
        this.isrenderOverTimeSection = true
        this.isOverTimeSectionDeleted = true
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

    @api paymentOfWagesDetails
    
    @api
    handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
        this.paymentOfWagesDetails = paymentOfWagesDetails
        console.log('Payment detail in child 0 ::: ', JSON.stringify(paymentOfWagesDetails));
        const temp = this.template.querySelectorAll('c-owc-Over-Time-Or-Double-Time-Def-Child');
        if(temp.length > 0){
            for(var i=0; i<temp.length; i++){
                temp[i].handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode);
            }
        }
    }

    handleOverTimeChildValidityEvent(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    @api vtCaseIssueObj
    @api caseIssueList = []
    handleOverTimeInfoEvent(event){
        if(this.isNotChangedCurrentStep === false){
            const result = event.detail;
            const overTimeSectionData = result.overTimeInfoObj
            this.overTimeSectionValues = overTimeSectionData
            const vtCaseIssueObj = result.vtCaseIssueObj;
            this.vtCaseIssueObj = vtCaseIssueObj
            if(this.overTimeDetails.length === 0){
                this.overTimeDetails.push(this.overTimeSectionValues);
            }
            else{
                for(let i=0; i<this.overTimeDetails.length; i++){
                    if(this.overTimeDetails[i].sectionId === this.overTimeSectionValues.sectionId){
                        const index = this.overTimeDetails.findIndex( item => item.sectionId === this.overTimeSectionValues.sectionId);
                        this.overTimeDetails[index] = this.overTimeSectionValues;
                        this.overTimeSectionValues = null;
                    }
                }
                this.overTimeSectionValues !== null ? this.overTimeDetails.push(this.overTimeSectionValues): ''
            }
            if(this.caseIssueList.length === 0){
                this.caseIssueList.push(this.vtCaseIssueObj);
            }
            else{
                for(let i=0; i<this.caseIssueList.length; i++){
                    if(this.caseIssueList[i].sectionId === this.vtCaseIssueObj.sectionId){
                        const index = this.caseIssueList.findIndex( item => item.sectionId === this.vtCaseIssueObj.sectionId);
                        this.caseIssueList[index] = this.vtCaseIssueObj;
                        this.vtCaseIssueObj = null;
                    }
                }
                this.vtCaseIssueObj !== null ? this.caseIssueList.push(this.vtCaseIssueObj): ''
            }
            this.handleOverTimeParentInfoData();
        }
        
    }

    handleOverTimeParentInfoData(){
        const selectEvent = new CustomEvent('overtimeparentinfoevent', {
            detail: {
                overTimeDetails : this.overTimeDetails,
                renderOverTimeSection : this.renderOverTimeSection,
                vtCaseIssueObj : this.caseIssueList
            }
        });
        this.dispatchEvent(selectEvent);
    }

    overTimeContainerValidityCheck(){
        const selectEvent = new CustomEvent('overtimedefparentvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }
    // This method is used to send the data of the parent cmp
    @api
    handleOverTimeOrDoubleTimeParent(){
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Over-Time-Or-Double-Time-Def-Child');
        for(var i=0; i<overTimeTemplate.length; i++){
            overTimeTemplate[i].handleOverTimeParentData();
        }

        if(this.isNotChangedCurrentStep === true){
            this.overTimeContainerValidityCheck();

        } 
    }

    @api
    handleOverTimeOrDoubleTimeParent2(){
        const overTimeTemplate = this.template.querySelectorAll('c-owc-Over-Time-Or-Double-Time-Def-Child');
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
        this.renderOverTimeSection.length = 0
        this.isrenderOverTimeSection = true
        if(strString1 != undefined || strString1 != null || strString1 != ''){
            for(let i = 0;i < strString1.length;i++){
                this.isrenderOverTimeSection = false
                this.renderOverTimeSection.push(strString1[i])
            }
        }
        this.flag1 = this.renderOverTimeSection.length
        this.isrenderOverTimeSection = true
        this.isrenderedCallback = true
        
    }

    renderedCallback(){
        if(this,this.isrenderedCallback === false && this.paymentOfWagesDetails !== undefined){
            const temp = this.template.querySelectorAll('c-owc-Over-Time-Or-Double-Time-Def-Child');
        if(temp.length > 0){
            for(var i=0; i<temp.length; i++){
                temp[i].handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
            }
        }
        }
        if(this.isrenderedCallback === true){
            const overTimeDetails = this.data
            console.log('overTime data in Child', this.data)
            const details = this.template.querySelectorAll('c-owc-Over-Time-Or-Double-Time-Def-Child')
            for (let i = 0; i < details.length; i++){
            details[i].handleOverTimeChildData(overTimeDetails[i],this.isFormPreviewMode)
        }
    }
        this.isrenderedCallback = false;
        if(this.isOverTimeSectionDeleted === true){
            const overTimeDetails = this.overTimeSectionDataAfterDelete
            const overTimeSectionDetails = this.template.querySelectorAll('c-owc-Over-Time-Or-Double-Time-Def-Child')
            for (let i = 0; i < overTimeSectionDetails.length; i++){
                overTimeSectionDetails[i].handleOverTimeChildData(overTimeDetails[i])
            }
            this.isOverTimeSectionDeleted = false
        }
    }
}