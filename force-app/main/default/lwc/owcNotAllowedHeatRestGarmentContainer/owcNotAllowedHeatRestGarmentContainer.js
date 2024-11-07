import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';

export default class OwcNotAllowedHeatRestGarmentContainer extends LightningElement {
     // Attributes
     @api renderRestClaimSection = [{ heading : customLabelValues.OWC_heat_rest_claim_heading_label, button : false, sectionId : 1 }]
     @api restClaimDetails = []
     @api restClaimSectionValues
     @api isNotChangedCurrentStep = false
     @api isrenderedCallback = false;
     // @api thirdcomponentrender = false
     @api deleteRestClaimSection
     @api restClaimSectionDataAfterDelete = []
     @api isRestClaimSectionDeleted = false
     @api powdetails
     @api iswagedefpreview
     flag = 0
     flag1 = 1
 
     // Accepted formats for File Upload Section
     get acceptedFormats() {
         return acceptedFileFormat;
     }
 
     // Formatted date Label
     @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`
 
     @track isrenderRestClaimSection = true
     @api isFormPreviewMode = false
 
     // This method is called on add more section
     addMoreSickLeaveSection(){
         this.isrenderRestClaimSection = false
         const flag1 = this.flag1 + 1
         this.flag1 = flag1
         this.renderRestClaimSection.push({ heading : customLabelValues.OWC_another_rest_claim_heading_label, button : true, sectionId : this.flag1 })
         this.isrenderRestClaimSection = true
     }
 
     // This is used to get the all section JSON inputs
     handleEmployerSectionDeletedData(event){
         const restClaimInfoSectionData = event.detail
         this.restClaimSectionDataAfterDelete.push(restClaimInfoSectionData)
     }
 
     // This method is called on delete the section
     handleSectionDelete(event){
         var flag1 = 1
         const restBreakInfoAfterDelete = []
         this.isrenderRestClaimSection = false
         this.restClaimSectionDataAfterDelete.length = 0
         this.deleteRestClaimSectionId = event.currentTarget.name
         const restClaimSectionDelete = this.template.querySelectorAll('c-owc-Not-Allowed-Heat-Rest-Garment-Child')
         for (let i = 0; i < restClaimSectionDelete.length; i++){
             restClaimSectionDelete[i].handleRestClaimSectionData()
         }
         const deleteSectionDataIndex = this.restClaimSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteRestClaimSectionId)
         // const employerTemp = this.template.querySelectorAll('c-owc-Not-Allowed-Heat-Rest-Garment-Child')
         // employerTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
         this.restClaimSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
         console.log('restClaimSectionDataAfterDelete ::: ', JSON.stringify(this.restClaimSectionDataAfterDelete));
         const deletedSectionIndex = this.renderRestClaimSection.findIndex(sec => sec.sectionId === this.deleteRestClaimSectionId)
         this.renderRestClaimSection.splice(deletedSectionIndex, 1);
         for(let i = 0; i < this.renderRestClaimSection.length ;i++){
             flag1 = 1 + i
             if(this.renderRestClaimSection[i].heading === customLabelValues.OWC_heat_rest_claim_heading_label){
                 restBreakInfoAfterDelete.push(this.renderRestClaimSection[i])
             }
             else{
                 restBreakInfoAfterDelete.push({ heading : customLabelValues.OWC_another_rest_claim_heading_label, button : true, sectionId : flag1 })
             }
         }
         this.renderRestClaimSection.length = 0
         for (var i of restBreakInfoAfterDelete){
             this.renderRestClaimSection.push(i)
         }
         // this.renderRestClaimSection = restBreakInfoAfterDelete
         this.flag1 = this.renderRestClaimSection.length
         this.isrenderRestClaimSection = true
         this.isRestClaimSectionDeleted = true
         this.showToast('Success!', this.customLabelValues.OWC_deleteSection_msg, 'success')
     }
 
     @api paymentOfWagesDetails
     @api
     handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
         this.paymentOfWagesDetails = paymentOfWagesDetails
         console.log('Payment detail in child 0 ::: ', JSON.stringify(paymentOfWagesDetails));
         const temp = this.template.querySelectorAll('c-owc-Not-Allowed-Heat-Rest-Garment-Child');
         if(temp.length > 0){
             for(var i=0; i<temp.length; i++){
                 temp[i].handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode);
             }
         }
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
         this.restClaimSectionValues = overTimeSectionData
         const vtCaseIssueObj = result.vtCaseIssueObj;
         this.vtCaseIssueObj = vtCaseIssueObj
         this.caseIssueList.push(this.vtCaseIssueObj)
         // this.restClaimDetails.length = 0
         this.restClaimDetails.push(this.restClaimSectionValues)
         console.log('restClaimDetails :::: ', JSON.stringify(result.vtCaseIssueObj))
         console.log('restClaimSectionValues:', JSON.stringify(this.restClaimSectionValues));
         const selectEvent = new CustomEvent('restclaimparentinfoevent', {
             detail: {
                 restClaimDetails : this.restClaimDetails,
                 renderRestClaimSection : this.renderRestClaimSection,
                 vtCaseIssueObj : this.caseIssueList
             }
         });
         this.isNotChangedCurrentStep = false;
         this.dispatchEvent(selectEvent);
     }
 
     handleOverTimeParentInfoData(){
         const selectEvent = new CustomEvent('restclaimparentinfoevent', {
             detail: {
                 restClaimDetails : this.restClaimDetails,
                 renderRestClaimSection : this.renderRestClaimSection,
                 vtCaseIssueObj : this.caseIssueList
             }
         });
         this.isNotChangedCurrentStep = false;
         this.dispatchEvent(selectEvent);
     }
 
     overTimeContainerValidityCheck(){
         const selectEvent = new CustomEvent('restclaimparentvalidityevent', {
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
         const overTimeTemplate = this.template.querySelectorAll('c-owc-Not-Allowed-Heat-Rest-Garment-Child');
         for(var i=0; i<overTimeTemplate.length; i++){
             overTimeTemplate[i].handleOverTimeParentData();
         }
 
         this.isNotChangedCurrentStep === true ? this.overTimeContainerValidityCheck() : this.handleOverTimeParentInfoData(); 
     }
 
     data
     @api 
     overTimeParentInfoSectionChild(strString, strString1,isFormPreviewMode){
         console.log('overTimeData in parent child ::: ', JSON.stringify(strString));
         this.isFormPreviewMode = isFormPreviewMode
         this.data = strString
         this.renderRestClaimSection.length = 0
         this.isrenderRestClaimSection = true
         if(strString1 != undefined || strString1 != null || strString1 != ''){
             for(let i = 0;i < strString1.length;i++){
                 this.isrenderRestClaimSection = false
                 this.renderRestClaimSection.push(strString1[i])
             }
         }
         this.flag1 = this.renderRestClaimSection.length
         this.isrenderRestClaimSection = true
         this.isrenderedCallback = true
         
     }
 
     renderedCallback(){
         if(this.isrenderedCallback === false && this.paymentOfWagesDetails !== undefined){
             const temp = this.template.querySelectorAll('c-owc-Not-Allowed-Heat-Rest-Garment-Child');
             if(temp.length > 0){
                 for(var i=0; i<temp.length; i++){
                     temp[i].handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
                 }
             }
         }
         if(this.isrenderedCallback === true){
             const restClaimDetails = this.data
             console.log('overTime data in Child', this.data)
             const details = this.template.querySelectorAll('c-owc-Not-Allowed-Heat-Rest-Garment-Child')
             for (let i = 0; i < details.length; i++){
             details[i].handleOverTimeChildData(restClaimDetails[i],this.isFormPreviewMode)
         }
     }
         this.isrenderedCallback = false;
         if(this.isRestClaimSectionDeleted === true){
             const restClaimDetails = this.restClaimSectionDataAfterDelete
             const restClaimSectionDelete = this.template.querySelectorAll('c-owc-Not-Allowed-Heat-Rest-Garment-Child')
             for (let i = 0; i < restClaimSectionDelete.length; i++){
                 restClaimSectionDelete[i].handleOverTimeChildData(restClaimDetails[i])
             }
             this.isRestClaimSectionDeleted = false
         }
     }
 }