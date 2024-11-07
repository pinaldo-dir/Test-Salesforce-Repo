import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OWC_empinfo_ClaimField from '@salesforce/label/c.OWC_empinfo_ClaimField';
import OWC_AddEmployerInformation from '@salesforce/label/c.OWC_AddEmployerInformation';
import OWC_added_section_label from '@salesforce/label/c.OWC_added_section_label';
import OWC_save_as_draft_label from '@salesforce/label/c.OWC_save_as_draft_label';
import OWC_ordinalsuffix_nd from '@salesforce/label/c.OWC_ordinalsuffix_nd';
import OWC_ordinalsuffix_rd from '@salesforce/label/c.OWC_ordinalsuffix_rd';
import OWC_ordinalsuffix_th from '@salesforce/label/c.OWC_ordinalsuffix_th';
import OWC_ordinalsuffix_st from '@salesforce/label/c.OWC_ordinalsuffix_st';
import OWC_deleteSection_msg from '@salesforce/label/c.OWC_deleteSection_msg';   
import OWC_anotheremployer_heading from '@salesforce/label/c.OWC_anotheremployer_heading';
import OWC_employer_delete_button from '@salesforce/label/c.OWC_employer_delete_button';
import OWC_other_employers_add_to_claim from '@salesforce/label/c.OWC_other_employers_add_to_claim';
import OWC_AnotherEmployerNote from '@salesforce/label/c.OWC_AnotherEmployerNote';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcEmpBusinessGarmentTypeContainerCmp extends LightningElement {
    @api renderEmpSection = [{ heading : OWC_empinfo_ClaimField, button : false, sectionId : 1, isPreliminaryShown : true }]
    @api employeesDetails = []
    @api claimFiledSectionValues
    @api isNotChangedCurrentStep = false
    @api thirdcomponentrender = false
    @api deleteEmployerSection
    @api employerSectionDataAfterDelete = []
    @api isEmployerSectionDeleted = false
    flag = 0
    flag1 = 1

    @track isRenderEmpSection = true
    @api isFormPreviewMode = false
    @api isclaimantadvocate

    connectedCallback(){
        window.scrollTo(0,0);
        // don’t forget to load static resources in connectedCallback . 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
            console.log( 'Files loaded' );
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
            console.log( error.body.message );
    });
    console.log('isclaimantadvocate ::: ', this.isclaimantadvocate)
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
    
    customLabelValues = {
        OWC_AnotherEmployerNote,
        OWC_other_employers_add_to_claim,
        OWC_AddEmployerInformation,
        OWC_deleteSection_msg,
        OWC_anotheremployer_heading,
        OWC_save_as_draft_label,
        OWC_employer_delete_button
    }
    get isRenderEmpSection(){
        return this.isRenderEmpSection === true
    }


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

    addMoreSuccessor(){
        this.isRenderEmpSection = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderEmpSection.push({ heading : this.customLabelValues.OWC_anotheremployer_heading, button : true, sectionId : this.flag1, isPreliminaryShown : false})
        this.isRenderEmpSection = true
    }

    handleEmployerSectionDeletedData(event){
        const employerInformationSectionData = event.detail
        this.employerSectionDataAfterDelete.push(employerInformationSectionData)
    }


    handleSectionDelete(event){
        var flag1 = 1
        const employerInfoAfterDelete = []
        this.isRenderEmpSection = false
        this.employerSectionDataAfterDelete.length = 0
        this.deleteEmployerSectionId = event.currentTarget.name
        const index = this.employeesDetails.findIndex( item => item.sectionId === this.deleteEmployerSectionId);
        this.employeesDetails.splice(index, 1);
        const employerSectionDetails = this.template.querySelectorAll('c-owc-Emp-Business-Garment-Type')
        for (let i = 0; i < employerSectionDetails.length; i++){
            employerSectionDetails[i].handleEmployerSectionData()
        }
        const deleteSectionDataIndex = this.employerSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteEmployerSectionId)
        const employerTemp = this.template.querySelectorAll('c-owc-Emp-Business-Garment-Type')
        employerTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
        this.employerSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        console.log('employerSectionDataAfterDelete ::: ', JSON.stringify(this.employerSectionDataAfterDelete));
        const deletedSectionIndex = this.renderEmpSection.findIndex(sec => sec.sectionId === this.deleteEmployerSectionId)
        this.renderEmpSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderEmpSection.length ;i++){
            flag1 = 1 + i
            if(this.renderEmpSection[i].heading === OWC_empinfo_ClaimField){
                employerInfoAfterDelete.push(this.renderEmpSection[i])
            }
            else{
                employerInfoAfterDelete.push({ heading : this.customLabelValues.OWC_anotheremployer_heading, button : true, sectionId : flag1, isPreliminaryShown : false })
            }
        }
        this.renderEmpSection.length = 0
        for (var i of employerInfoAfterDelete){
            this.renderEmpSection.push(i)
        }
        // this.renderEmpSection = employerInfoAfterDelete
        this.flag1 = this.renderEmpSection.length
        this.isRenderEmpSection = true
        this.isEmployerSectionDeleted = true
        this.showToast(this.customLabelValues.OWC_deleteSection_msg)
    }

    handleSaveAsDraft(){
        const details = this.template.querySelectorAll('c-owc-Emp-Business-Garment-Type')
        for (let i = 0; i < details.length; i++){
            details[i].handleEvent()
        }
        const selectEvent = new CustomEvent('claimnatempoyeescustomevent', {
            detail: { 
                employeesDetails : this.employeesDetails,
                isNotChangedCurrentStep : this.isNotChangedCurrentStep,
                renderEmpSection : this.renderEmpSection
            }
        });
        this.isNotChangedCurrentStep = false
        this.dispatchEvent(selectEvent);
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "3"
            }
        });
        this.dispatchEvent(validateEvent);
    }

    @api 
    owcEmpDataForContainerParent(isPrevious){
        const details = this.template.querySelectorAll('c-owc-Emp-Business-Garment-Type')
        for (let i = 0; i < details.length; i++){
            details[i].owcEmpDataForParent(isPrevious)
        }
        console.log('details ::: ', details.length)
        const selectEvent = new CustomEvent('claimnatempoyeescustomevent', {
            detail: { 
                employeesDetails : this.employeesDetails,
                isNotChangedCurrentStep : this.isNotChangedCurrentStep,
                renderEmpSection : this.renderEmpSection
            }
        });
        this.isNotChangedCurrentStep = false
        this.dispatchEvent(selectEvent);
    }

    @api
    handleClaimFiledCustomEvent(event){
        if(this.isNotChangedCurrentStep === false){
            const claimFiledSectionData = event.detail
            this.claimFiledSectionValues = claimFiledSectionData
            if(this.employeesDetails.length === 0){
                this.employeesDetails.push(this.claimFiledSectionValues);
            }
            else{
                for(let i=0; i<this.employeesDetails.length; i++){
                    if(this.employeesDetails[i].sectionId === this.claimFiledSectionValues.sectionId){
                        const index = this.employeesDetails.findIndex( item => item.sectionId === this.claimFiledSectionValues.sectionId);
                        this.employeesDetails[index] = this.claimFiledSectionValues;
                        this.claimFiledSectionValues = null;
                    }
                }
                this.claimFiledSectionValues !== null ? this.employeesDetails.push(this.claimFiledSectionValues): ''
            }
        }
    }

    @api
    owcClaimentInfo(strString, isAdvocateGarment){
        console.log('Claimant Advocatr ::: ', isAdvocateGarment)
        if(strString === "Yourself" && isAdvocateGarment === true){
            this.isclaimantadvocate = true;
        }
    }

    data
    isRenderCallBack = false

    @api 
    owcEmployeesDataForChildCmp(strString, strString1,isFormPreviewMode){
        console.log('owcEmployeesDataForChildCmp ::: ', JSON.stringify(strString));
        this.isFormPreviewMode = isFormPreviewMode
        this.data = strString
        this.renderEmpSection.length = 0
        this.isRenderEmpSection = true
        if(Boolean(strString1)){
            for(let i = 0;i < strString1.length;i++){
                this.isRenderEmpSection = false
                this.renderEmpSection.push(strString1[i])
            }
        }
        this.isRenderEmpSection = true
        this.flag1 = this.renderEmpSection.length
        
        this.isRenderCallBack = true
        
    }

    @api 
    handleClaimFieldEmpValidityEvent(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
    }

    renderedCallback(){
        // if(this.isClaimantAdvocate === true){
        //     this.template.querySelector('c-owc-Emp-Business-Garment-Type').owcClaimentInfo(this.isClaimantAdvocate)
        // }
        if(this.isRenderCallBack === true){
            const employeesDetails = this.data
            console.log('employers data in EmpChild', this.data)
            const details = this.template.querySelectorAll('c-owc-Emp-Business-Garment-Type')
            for (let i = 0; i < details.length; i++){
            details[i].owcEmpDataForChild(employeesDetails[i],this.isFormPreviewMode)
        }
        this.isRenderCallBack = false
        }
        if(this.isEmployerSectionDeleted === true){
            const employerDetails = this.employerSectionDataAfterDelete
            const employerSectionDetails = this.template.querySelectorAll('c-owc-Emp-Business-Garment-Type')
            for (let i = 0; i < employerSectionDetails.length; i++){
                employerSectionDetails[i].owcEmpDataForChild(employerDetails[i])
            }
            this.isEmployerSectionDeleted = false
        }
        
    }
    handleUSPSAddressMatch(event){
        const currentStep = event.detail.currentStep;
        const validateEvent = new CustomEvent('matchuspscustomeventforemployees', {
            detail: {
                currentStep : currentStep
            }
        });
        this.dispatchEvent(validateEvent);
    }
// LWC File upload success Toast Function
showToast(toastMsg) {
    const event = new ShowToastEvent({
        variant: 'success',
        message: toastMsg,
    });
    this.dispatchEvent(event);
}
   

}