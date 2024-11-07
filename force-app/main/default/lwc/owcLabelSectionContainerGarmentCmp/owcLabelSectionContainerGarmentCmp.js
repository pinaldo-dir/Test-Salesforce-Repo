import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { radioOptions, customLabelValues } from 'c/owcUtils';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcLabelSectionContainerGarmentCmp extends LightningElement {
    customLabelValues = customLabelValues
    @api isFormPreviewMode = false

    ordinal_suffix_of(i) {
        var j = i % 10,
            k = i % 100;
        if (j == 1 && k != 11) {
            return i + OWC_ordinalsuffix_st;
        }
        if (j == 2 && k != 12) {
            return i + OWC_ordinalsuffix_nd;
        }
        if (j == 3 && k != 13) {
            return i + OWC_ordinalsuffix_rd;
        }
        return i + OWC_ordinalsuffix_th;
    }

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

   @api get disableAddMore(){
       return this.renderLabelInformationSection != null && this.renderLabelInformationSection.length == 15;
   }

    // Label for another label
    @api renderLabelInformationSection = [{ heading : customLabelValues.OWC_label_info_heading, button : false, sectionId : 1 }]
    @api labelInformationSectionValues
    @api labelSectionValues
    @api labelDetails = []
    @api isClaimantAdvocate = false
    isRenderLabelInformationSection = true
    @api isLabelSectionDeleted = false
    @api labelSectionDataAfterDelete = []
    sFlag1 = 1
    flag1 = 1

    get isRenderLabelInformationSection(){
        return this.isRenderLabelInformationSection === true && this.isLabelsInfo === true && this.isClaimantAdvocate === true
    }

    handleLabelSectionDeletedData(event){
        const labelInformationSectionData = event.detail
        console.log('handleLabelSectionDeletedData Data:::',JSON.stringify(labelInformationSectionData));
        this.labelSectionDataAfterDelete.push(labelInformationSectionData)
    }

    handleLabelSectionValidity(event){
        const currentStep = event.detail.currentStep
        console.log('handleLabelSectionValidity ::::: ', currentStep)
        this.isNotChangedCurrentStep = currentStep
        console.log('isNotChangedCurrentStep ::: ', this.isNotChangedCurrentStep)
    
    }
    
    handleLabelSectionDelete(event){
        var flag1 = 1
        const labelInfoAfterDelete = []
        this.isRenderLabelInformationSection = false
        this.isLabelsInfo = false        
        this.labelSectionDataAfterDelete.length = 0
        //this.deleteLabelSectionId = event.detail.sectionId
        this.deleteLabelSectionId = event.currentTarget.name
        console.log('Current Del Index::::',this.deleteLabelSectionId)
        const index = this.labelDetails.findIndex( item => item.sectionId === this.deleteLabelSectionId);
        this.labelDetails.splice(index, 1);
        const labelSectionDetails = this.template.querySelectorAll('c-owc-Label-Section-Garment-Cmp')
        
        for (let i = 0; i < labelSectionDetails.length; i++){
            labelSectionDetails[i].handleLabelSectionData()
            //console.log('Label Data:::',JSON.stringify(labelSectionDetails[i].handleLabelSectionData()));
        }
        const deleteSectionDataIndex = this.labelSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteLabelSectionId)
        const labelTemp = this.template.querySelectorAll('c-owc-Label-Section-Garment-Cmp')
        labelTemp[deleteSectionDataIndex].handleLabelSectionDeleteFiles(true)
        this.labelSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        console.log('labelSectionDataAfterDelete ::: ', JSON.stringify(this.labelSectionDataAfterDelete));
        const deletedSectionIndex = this.renderLabelInformationSection.findIndex(sec => sec.sectionId === this.deleteLabelSectionId)
        this.renderLabelInformationSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderLabelInformationSection.length ;i++){
            flag1 = 1 + i
            if(this.renderLabelInformationSection[i].heading === this.customLabelValues.OWC_label_info_heading){
                labelInfoAfterDelete.push(this.renderLabelInformationSection[i])
            }
            else{
                labelInfoAfterDelete.push({heading : this.customLabelValues.OWC_anotherlabel_heading, button : true, sectionId : flag1})
            }
        }
        console.log('renderLabelInformationSection ::: ', JSON.stringify(this.renderLabelInformationSection))
        this.renderLabelInformationSection.length = 0
        for (var i of labelInfoAfterDelete){
            this.renderLabelInformationSection.push(i)
        }
        this.flag1 = this.renderLabelInformationSection.length    
        
        this.isRenderLabelInformationSection = true
        this.isLabelsInfo = true 
        this.isClaimantAdvocate = true
        this.isLabelSectionDeleted = true
        console.log('checked ::: ', this.isLabelSectionDeleted)
        this.showToast('Success!',this.customLabelValues.OWC_section_delete_toastmsg,'success')
    }

    //Add More Label Info
    addMoreLabel(){
        this.isRenderLabelInformationSection = false
        this.isLabelsInfo = false 
        this.isClaimantAdvocate = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderLabelInformationSection.push({heading : this.customLabelValues.OWC_anotherlabel_heading, button : true, sectionId : this.flag1})
        this.isRenderLabelInformationSection = true
        this.isLabelsInfo = true 
        this.isClaimantAdvocate = true
    }

    handleLabelSectionEvent(event){
        // console.log('handleLabelSectionEvent');
        // const labelInformationSectionData = event.detail
        // this.labelDetails.push(labelInformationSectionData)
        // console.log('handleLabelSectionEvent:::',JSON.stringify(this.labelDetails));
        if(this.isNotChangedCurrentStep === false){
            const labelInformationSectionData = event.detail
            this.labelSectionValues = labelInformationSectionData
            if(this.labelDetails.length === 0){
                this.labelDetails.push(this.labelSectionValues);
            }
            else{
                for(let i=0; i<this.labelDetails.length; i++){
                    if(this.labelDetails[i].sectionId === this.labelSectionValues.sectionId){
                        const index = this.labelDetails.findIndex( item => item.sectionId === this.labelSectionValues.sectionId);
                        this.labelDetails[index] = this.labelSectionValues;
                        this.labelSectionValues = null;
                    }
                }
                this.labelSectionValues !== null ? this.labelDetails.push(this.labelSectionValues): ''
            
            }
        }
    }
  
   labelInformationdata
   isRenderLabelInfo
    
    handleLabelInformation(labelInformation, labelInformationCount){
        this.labelInformationdata = labelInformation
        this.labelInformationSectionValues = labelInformation
        this.renderLabelInformationSection.length = 0
        this.isRenderLabelInformationSection = true
        this.isLabelsInfo = true 
        this.isClaimantAdvocate = true
        if(Boolean(labelInformationCount)){
            for(let i = 0;i < labelInformationCount.length;i++){
                this.isRenderLabelInformationSection = false
                this.renderLabelInformationSection.push(labelInformationCount[i])
            }
        }
        this.flag1 = this.renderLabelInformationSection.length
        this.isRenderLabelInformationSection = true
        this.isRenderLabelInfo = true
    }

    handleSaveAsDraft(){
        const labelSectionDetails = this.template.querySelectorAll('c-owc-Label-Section-Garment-Cmp');
        for (let i = 0; i < labelSectionDetails.length; i++){
            labelSectionDetails[i].handleLabelSectionEvent()
        }
        const selectEvent = new CustomEvent('labelsectioninfoevent', {
            detail: {
                labelDetails : this.labelDetails,
                isNotChangedCurrentStep : this.isNotChangedCurrentStep,
                labelInformationSectionValues : this.labelInformationSectionValues,
                renderLabelInformationSection : this.renderLabelInformationSection,
            }
        });
        this.dispatchEvent(selectEvent);
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "10"
            }
        });
        this.dispatchEvent(validateEvent);
    }

    @api
    labelSectionFromParent(){
        const labelSectionDetails = this.template.querySelectorAll('c-owc-Label-Section-Garment-Cmp')
                for (let i = 0; i < labelSectionDetails.length; i++){
                    labelSectionDetails[i].owcLabelDataForParent()
                    if(this.isNotChangedCurrentStep === true){
                        const selectEvent = new CustomEvent('labelsectionvalidityevent', {
                            detail: {
                                currentStep : true
                            }
                        });
                        this.isNotChangedCurrentStep = false
                        this.dispatchEvent(selectEvent);
                        return;
                    }
                }
                const selectEvent = new CustomEvent('labelsectioninfoevent', {
                    detail: {
                        labelDetails : this.labelDetails,
                        isNotChangedCurrentStep : this.isNotChangedCurrentStep,
                        labelInformationSectionValues : this.labelInformationSectionValues,
                        renderLabelInformationSection : this.renderLabelInformationSection,
                    }
                });
                this.dispatchEvent(selectEvent);
    }

    @api
    labelSectionForChild(strString,isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode
        if(isNaN(strString.labelDetails)){
                this.handleLabelInformation(strString.labelDetails, strString.renderLabelInformationSection)
            }
    }

    renderedCallback(){
        if(this.isRenderLabelInfo === true){
            const labelDetails = this.labelInformationdata
            const labelSectionDetails = this.template.querySelectorAll('c-owc-Label-Section-Garment-Cmp')
            for (let i = 0; i < labelSectionDetails.length; i++){
                labelSectionDetails[i].owcLabelInfoForChild(labelDetails[i],this.isFormPreviewMode)
            }
            this.isRenderLabelInfo = false
        }
        if(this.isLabelSectionDeleted === true){
            const labelDetails = this.labelSectionDataAfterDelete
            console.log('In renderback')
            const labelSectionDetails = this.template.querySelectorAll('c-owc-Label-Section-Garment-Cmp')
            for (let i = 0; i < labelSectionDetails.length; i++){
                labelSectionDetails[i].owcLabelInfoForChild(labelDetails[i])
            }
            this.isLabelSectionDeleted = false
        }
    }

}