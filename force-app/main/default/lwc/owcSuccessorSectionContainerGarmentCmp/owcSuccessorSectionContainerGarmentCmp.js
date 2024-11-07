import { LightningElement, api, track, wire } from 'lwc';
import { radioOptions, customLabelValues } from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcSuccessorSectionContainerGarmentCmp extends LightningElement {
    @api isclaimantgarment
    @api isemployernamechanged

    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    customLabelValues = customLabelValues
    sFlag1 = 1
    // Successor for another successor
    @api successorSectionDataAfterDelete = []

    handleSuccessorSectionDeletedData(event){
        const successorInformationSectionData = event.detail
        this.successorSectionDataAfterDelete.push(successorInformationSectionData)
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

    //Successor for another successor info
    @api renderSuccessorSection = [{ heading : customLabelValues.OWC_successoraddinfo_heading, button : false, sectionId : 1 }]
    @api successorSectionValues
    @api isSuccessorSectionDeleted = false
    @api successorDetails = []
    isRenderSuccessorInfoSection = true
    listOfLabelData = []
    
    get isRenderSuccessorInfoSection(){
        return this.isRenderSuccessorInfoSection === true && this.isLabelsInfo === true 
    }

    handleSuccessorSectionDelete(event){
                var sflag1 = 1
                const successorInfoAfterDelete = []
                this.isRenderSuccessorInfoSection = false
                this.isLabelsInfo = false 
                this.successorSectionDataAfterDelete.length = 0
                this.deleteSuccessorSectionId = event.detail.sectionId
                const successorSectionDetails = this.template.querySelectorAll('c-owc-Successor-Section-Garment-Cmp')
                for (let i = 0; i < successorSectionDetails.length; i++){
                    successorSectionDetails[i].handleSuccessorSectionData()
                }
                const deleteSuccessorSectionDataIndex = this.successorSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteSuccessorSectionId)
                console.log('deleteSuccessorSectionDataIndex ::: ', deleteSuccessorSectionDataIndex)
                this.successorSectionDataAfterDelete.splice(deleteSuccessorSectionDataIndex, 1);
                console.log('After delete successor ::: ', JSON.stringify(this.successorSectionDataAfterDelete))
                const deletedSectionIndex = this.renderSuccessorSection.findIndex(sec => sec.sectionId === this.deleteSuccessorSectionId)
                this.renderSuccessorSection.splice(deletedSectionIndex, 1);
                for(let i = 0; i < this.renderSuccessorSection.length ;i++){
                    sflag1 = 1 + i
                    if(this.renderSuccessorSection[i].heading === this.customLabelValues.OWC_successoraddinfo_heading){
                        successorInfoAfterDelete.push(this.renderSuccessorSection[i])
                    }
                    else{
                        successorInfoAfterDelete.push({heading : this.customLabelValues.OWC_anothersuccessor_heading, button : true, sectionId : sflag1 })
                    }
                }
                this.renderSuccessorSection.length = 0
                for (var i of successorInfoAfterDelete){
                    this.renderSuccessorSection.push(i)
                }
                this.sFlag1 = this.renderSuccessorSection.length
                this.isRenderSuccessorInfoSection = true
                this.isLabelsInfo = true 
                this.isSuccessorSectionDeleted = true
                this.showToast('Success!',this.customLabelValues.OWC_section_delete_toastmsg,'success')
            }

             //Add More Successsor Info
    addMoreSuccessor(){
        this.isRenderSuccessorInfoSection = false
        const sFlag1 = this.sFlag1 + 1
        this.sFlag1 = sFlag1
        this.renderSuccessorSection.push({heading : this.customLabelValues.OWC_anothersuccessor_heading, button : true, sectionId : this.sFlag1})
        this.isRenderSuccessorInfoSection = true
    }

    @api isNotChangedCurrentStep = false;
    handleSuccessorSectionEvent(event){
        if(this.isNotChangedCurrentStep === false){
            const successorSectionData = event.detail
            this.successorSectionValues = successorSectionData
            if(this.successorDetails.length === 0){
                this.successorDetails.push(this.successorSectionValues);
            }
            else{
                for(let i=0; i<this.successorDetails.length; i++){
                    if(this.successorDetails[i].sectionId === this.successorSectionValues.sectionId){
                        const index = this.successorDetails.findIndex( item => item.sectionId === this.successorSectionValues.sectionId);
                        this.successorDetails[index] = this.successorSectionValues;
                        this.successorSectionValues = null;
                    }
                }
                this.successorSectionValues !== null ? this.successorDetails.push(this.successorSectionValues): ''
            }
        }
        //const successorSectionData = event.detail
        //this.successorSectionValues = successorSectionData
        //this.successorSectionValues.length = 0
        //this.successorDetails.push(this.successorSectionValues)
        console.log('successorDetails :::: ', JSON.stringify(this.successorDetails))
        console.log('successorSectionValues:', JSON.stringify(this.successorSectionValues))
    }

 successordata;
 isRenderSuccessor
    
    handleSuccessor(successorvalue, successorCount){
        this.successordata = successorvalue
        this.successorSectionValues = successorvalue
        this.renderSuccessorSection.length = 0
        this.isRenderSuccessorInfoSection = true
        this.isLabelsInfo = true 
                for(let i = 0;i < successorCount.length;i++){
            this.isRenderSuccessorInfoSection = false
            this.renderSuccessorSection.push(successorCount[i])
        }
        this.sFlag1 = this.renderSuccessorSection.length
        this.isRenderSuccessorInfoSection = true
        this.isRenderSuccessor = true
    }

    handleSuccessorSectionValidity(event){
        const currentStep = event.detail.currentStep
        console.log('handleSuccessorSectionValidity ::::: ', currentStep)
        this.isNotChangedCurrentStep = currentStep
        console.log('isNotChangedCurrentStep ::: ', this.isNotChangedCurrentStep)
    }

    @api
    successorSectionDetailsFromParent(){
        const successorSectionDetails = this.template.querySelectorAll('c-owc-Successor-Section-Garment-Cmp')
            for (let i = 0; i < successorSectionDetails.length; i++){
                successorSectionDetails[i].owcSuccessorDataForParent()
                if(this.isNotChangedCurrentStep === true){
                    const selectEvent = new CustomEvent('successorsectionvalidityevent', {
                        detail: {
                            currentStep : true
                        }
                    });
                    this.isNotChangedCurrentStep = false
                    this.dispatchEvent(selectEvent);
                    return;
                }
            }
        
            const selectEvent = new CustomEvent('successorsectioninfoevent', {
                detail: {
                    labelDetails : this.labelDetails || '',
                    successorDetails : this.successorDetails || '',
                    // currentStep : this.currentStep|| '',
                    isNotChangedCurrentStep : this.isNotChangedCurrentStep|| '',
                    successorSectionValues : this.successorSectionValues || '',
                    renderSuccessorSection : this.renderSuccessorSection || '',
                    labelInformationSectionValues : this.labelInformationSectionValues || '',
                    renderLabelInformationSection : this.renderLabelInformationSection || '',
                }
            });
            this.dispatchEvent(selectEvent);
    }

    @api isFormPreviewMode = false
    @api
    successorSectionDetailsForChild(strString,isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode
        if(isNaN(strString.successorDetails)){
            this.handleSuccessor(strString.successorDetails, strString.renderSuccessorSection)
        }
        this.isRenderedCallback = true
    }

    renderedCallback(){
        if(this.isRenderSuccessor === true){
                    const successorDetails = this.successordata
                    const successorSectionDetails = this.template.querySelectorAll('c-owc-Successor-Section-Garment-Cmp')
                    for (let i = 0; i < successorSectionDetails.length; i++){
                        successorSectionDetails[i].owcSucessorInfoForChild(successorDetails[i],this.isFormPreviewMode)
                    }
                    this.isRenderSuccessor = false
                }
            if(this.isSuccessorSectionDeleted === true){
                const successorDetails = this.successorSectionDataAfterDelete
                const successorSectionDetails = this.template.querySelectorAll('c-owc-Successor-Section-Garment-Cmp')
                for (let i = 0; i < successorSectionDetails.length; i++){
                    successorSectionDetails[i].owcSucessorInfoForChild(successorDetails[i])
                }
                this.isSuccessorSectionDeleted = false
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

}