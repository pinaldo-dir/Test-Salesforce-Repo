import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';

export default class OwcInsufficientFundClaimGarmentContainer extends LightningElement {
     // Attributes
     @api renderFundClaimSection = [{ heading : customLabelValues.OWC_insufficient_fund_claim_heading, button : false, sectionId : 1 }]
     @api fundClaimDetails = []
     @api fundClaimSectionValues
     @api isNotChangedCurrentStep = false
     @api isrenderedCallback = false;
     // @api thirdcomponentrender = false
     @api deleteFundClaimSection
     @api fundClaimSectionDataAfterDelete = []
     @api isFundClaimSectionDeleted = false
     @api paidbycheck;
     flag = 0
     flag1 = 1
     @api iswagedefpreview;
 
     // Accepted formats for File Upload Section
     get acceptedFormats() {
         return acceptedFileFormat;
     }
 
     // Formatted date Label
     @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`
 
     @track isrenderFundClaimSection = true
     @api isFormPreviewMode = false
 
     // This method is called on add more section
     addMoreSickLeaveSection(){
         this.isrenderFundClaimSection = false
         const flag1 = this.flag1 + 1
         this.flag1 = flag1
         this.renderFundClaimSection.push({ heading : customLabelValues.OWC_another_insufficient_fund_claim_heading, button : true, sectionId : this.flag1 })
         this.isrenderFundClaimSection = true
     }
 
     // This is used to get the all section JSON inputs
     handleEmployerSectionDeletedData(event){
         const fundClaimInfoSectionData = event.detail
         this.fundClaimSectionDataAfterDelete.push(fundClaimInfoSectionData)
     }
 
     // This method is called on delete the section
     handleSectionDelete(event){
         var flag1 = 1
         const restBreakInfoAfterDelete = []
         this.isrenderFundClaimSection = false
         this.fundClaimSectionDataAfterDelete.length = 0
         this.deleteFundClaimSectionId = event.currentTarget.name
         const fundClaimSectionDelete = this.template.querySelectorAll('c-owc-Insufficient-Fund-Claim-Garment-Child')
         for (let i = 0; i < fundClaimSectionDelete.length; i++){
             fundClaimSectionDelete[i].handleFundClaimSectionData()
         }
         const deleteSectionDataIndex = this.fundClaimSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteFundClaimSectionId)
         // const employerTemp = this.template.querySelectorAll('c-owc-Insufficient-Fund-Claim-Garment-Child')
         // employerTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
         this.fundClaimSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
         console.log('fundClaimSectionDataAfterDelete ::: ', JSON.stringify(this.fundClaimSectionDataAfterDelete));
         const deletedSectionIndex = this.renderFundClaimSection.findIndex(sec => sec.sectionId === this.deleteFundClaimSectionId)
         this.renderFundClaimSection.splice(deletedSectionIndex, 1);
         for(let i = 0; i < this.renderFundClaimSection.length ;i++){
             flag1 = 1 + i
             if(this.renderFundClaimSection[i].heading === customLabelValues.OWC_insufficient_fund_claim_heading){
                 restBreakInfoAfterDelete.push(this.renderFundClaimSection[i])
             }
             else{
                 restBreakInfoAfterDelete.push({ heading : customLabelValues.OWC_another_insufficient_fund_claim_heading, button : true, sectionId : flag1 })
             }
         }
         this.renderFundClaimSection.length = 0
         for (var i of restBreakInfoAfterDelete){
             this.renderFundClaimSection.push(i)
         }
         // this.renderFundClaimSection = restBreakInfoAfterDelete
         this.flag1 = this.renderFundClaimSection.length
         this.isrenderFundClaimSection = true
         this.isFundClaimSectionDeleted = true
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
         console.log('preview in suff con ::: ', this.iswagedefpreview)
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
         this.fundClaimSectionValues = result.restClaimInfoObj
         const vtCaseIssueObj = result.vtCaseIssueObj;
         this.vtCaseIssueObj = vtCaseIssueObj
         this.caseIssueList.push(this.vtCaseIssueObj)
         
         // this.fundClaimDetails.length = 0
         this.fundClaimDetails.push(this.fundClaimSectionValues)
         console.log('fundClaimDetails :::: ', JSON.stringify(this.fundClaimDetails))
         console.log('fundClaimSectionValues:', JSON.stringify(this.fundClaimSectionValues));
         const selectEvent = new CustomEvent('fundclaimparentinfoevent', {
             detail: {
                 fundClaimDetails : this.fundClaimDetails,
                 renderFundClaimSection : this.renderFundClaimSection,
                 vtCaseIssueObj : this.caseIssueList
             }
         });
         this.isNotChangedCurrentStep = false;
         this.dispatchEvent(selectEvent);
     }
 
     handleOverTimeParentInfoData(){
         const selectEvent = new CustomEvent('fundclaimparentinfoevent', {
             detail: {
                 fundClaimDetails : this.fundClaimDetails,
                 renderFundClaimSection : this.renderFundClaimSection,
                 vtCaseIssueObj : this.caseIssueList
             }
         });
         this.isNotChangedCurrentStep = false;
         this.dispatchEvent(selectEvent);
     }
 
     overTimeContainerValidityCheck(){
         const selectEvent = new CustomEvent('fundclaimparentvalidityevent', {
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
         const overTimeTemplate = this.template.querySelectorAll('c-owc-Insufficient-Fund-Claim-Garment-Child');
         for(var i=0; i<overTimeTemplate.length; i++){
             overTimeTemplate[i].handleOverTimeParentData();
         }
 
         this.isNotChangedCurrentStep === true ? this.overTimeContainerValidityCheck() : this.handleOverTimeParentInfoData(); 
     }
 
     data
     @api 
     overTimeParentInfoSectionChild(strString, strString1,isFormPreviewMode){
         console.log('overTimeData in parent child insuff ::: ', JSON.stringify(strString));
         this.isFormPreviewMode = isFormPreviewMode
         this.data = strString
         this.renderFundClaimSection.length = 0
         this.isrenderFundClaimSection = true
         if(strString1 != undefined || strString1 != null || strString1 != ''){
             for(let i = 0;i < strString1.length;i++){
                 this.isrenderFundClaimSection = false
                 this.renderFundClaimSection.push(strString1[i])
             }
         }
         this.flag1 = this.renderFundClaimSection.length
         this.isrenderFundClaimSection = true
         this.isrenderedCallback = true
         
     }
 
     renderedCallback(){
         if(this.isrenderedCallback === true){
             const fundClaimDetails = this.data
             console.log('overTime data in Child', this.data)
             const details = this.template.querySelectorAll('c-owc-Insufficient-Fund-Claim-Garment-Child')
             for (let i = 0; i < details.length; i++){
             details[i].handleOverTimeChildData(fundClaimDetails[i],this.isFormPreviewMode)
         }
     }
         this.isrenderedCallback = false;
         if(this.isFundClaimSectionDeleted === true){
             const fundClaimDetails = this.fundClaimSectionDataAfterDelete
             const fundClaimSectionDelete = this.template.querySelectorAll('c-owc-Insufficient-Fund-Claim-Garment-Child')
             for (let i = 0; i < fundClaimSectionDelete.length; i++){
                 fundClaimSectionDelete[i].handleOverTimeChildData(fundClaimDetails[i])
             }
             this.isFundClaimSectionDeleted = false
         }
     }
 }