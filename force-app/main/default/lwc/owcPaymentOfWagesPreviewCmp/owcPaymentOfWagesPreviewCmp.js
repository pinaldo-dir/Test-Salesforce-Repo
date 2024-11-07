import { LightningElement,api,wire,track } from 'lwc';
import { radioOptions, customLabelValues} from 'c/owcUtils';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import owcFrequencyMetaData from '@salesforce/apex/OWCPaymentOfWagesController.fetchFrequencyMetaData';
import paymentTypeOptions from '@salesforce/apex/OWCPaymentOfWagesController.fetchOptionsMetaData';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcPaymentOfWagesPreviewCmp extends LightningElement {
    @api paymentWagesDetailPreview;
    @api isFormPreview = false
    @api ispreviewmode;
    @track value = []
    @track isOneHourlyRatePreview = false
    isRenderedCallback = false
    @api isCommissionReciptFileUpload 
    @api commissionReciptDocsSize 
    @api commissionReciptDocs
    @api isAgreementFileUpload 
    @api agreementDocsSize 
    @api agreementDocs 

    customLabelValues = customLabelValues // stores all the custom labels which we are importing from owcUtils
    YesOrNoOptions = radioOptions
    //ConnectedCall back Method 
    connectedCallback(){
        // don’t forget to load static resources in connectedCallback . 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
            console.log( 'Files loaded' );
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error')
            console.log( error.body.message );
    });
    }
    
    

    //Fetching Frequency List
    @wire(owcFrequencyMetaData)
    wiredfetchdata({ data,error}) {
            if(data){
                this.frequency_list_type = data;
                console.log('new list'+JSON.stringify(this.frequency_list_type));
            }else{
                this.errorMsg = error;
            }
    }
    //
    @wire(paymentTypeOptions)
    wiredOptiondata({ data,error}) {
            if(data){
                this.options = data;
                console.log('new list'+JSON.stringify(this.options));
                console.log('this.options[0].value',this.options[0].value);
            }else{
                this.errorMsg = error;
            }
    }

    //Fetching Units list
    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data, error }){
        if(data){
            console.log('data:', JSON.stringify(data));
            this.perUnitPaymentOfWagesValue = data[0].perUnitPaymentOfWages;
        }
        else if(error){
            this.error = error;
        }
    }


    /**Starting One Hour Additional Section Work here */
    @api renderOneHourlyAdditonalSection = []
    oneHourlyFlag = 0
    hourlyAddValues
   
    @api hourlyAdditionalSectionValues
    @api hourlyAdditionalDetails = []
    @api isOneHourlyAdditionalSection = false
    isHourlyAddSectionDeleted = false
    @api hourlyAddSectionDataAfterDelete = []
    // One Hour Section Validity event handler
    handleHourlyAddSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }

    //Add More One Hour Info
    addMoreHourly(){
        this.isOneHourlyAdditionalSection = false
        const oneHourlyFlag = this.oneHourlyFlag + 1
        this.oneHourlyFlag = oneHourlyFlag
        this.renderOneHourlyAdditonalSection.push({heading : this.customLabelValues.Owc_Additional, button : true, oneHourSectionId : this.oneHourlyFlag})
        this.isOneHourlyAdditionalSection = true
    }

    handleOneHourlyAddSectionInfoEvent(event){
        const hourlyAdditionalSectionData = event.detail
        this.hourlyAdditionalSectionValues = hourlyAdditionalSectionData
        this.hourlyAdditionalDetails.push(this.hourlyAdditionalSectionValues)
        console.log('hourlyAdditionalDetails :::: ', JSON.stringify(this.hourlyAdditionalDetails))
        console.log('hourlyAdditionalSectionValues:', JSON.stringify(this.hourlyAdditionalSectionValues))
    }

    handleOneHourlySectionDeletion(event){
        var oneHourlyFlag = 0
        const hourlyAddInfoAfterDelete = []
        this.isOneHourlyAdditionalSection = false
        this.hourlyAddSectionDataAfterDelete.length = 0
        this.deleteHourlyAddSectionId = event.detail.oneHourSectionId
        const hourlyAdditionalSectionDetails = this.template.querySelectorAll('c-owc-One-Hour-Additional-Cmp')
        for (let i = 0; i < hourlyAdditionalSectionDetails.length; i++){
            hourlyAdditionalSectionDetails[i].handleOneHourlyAddSectionData()
        }
        const deleteHourlyAddSectionDataIndex = this.hourlyAddSectionDataAfterDelete.findIndex(sec => sec.oneHourSectionId === this.deleteHourlyAddSectionId)
        console.log('deleteHourlyAddSectionDataIndex ::: ', deleteHourlyAddSectionDataIndex)
        this.hourlyAddSectionDataAfterDelete.splice(deleteHourlyAddSectionDataIndex, 1);
        console.log('After delete successor ::: ', JSON.stringify(this.hourlyAddSectionDataAfterDelete))
        const deletedSectionIndex = this.renderOneHourlyAdditonalSection.findIndex(sec => sec.oneHourSectionId === this.deleteHourlyAddSectionId)
        this.renderOneHourlyAdditonalSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderOneHourlyAdditonalSection.length ;i++){
            oneHourlyFlag = i + 1
            if(this.renderOneHourlyAdditonalSection[i].heading === this.customLabelValues.OWC_successoraddinfo_heading){
                hourlyAddInfoAfterDelete.push(this.renderOneHourlyAdditonalSection[i])
            }
            else{
                hourlyAddInfoAfterDelete.push({heading : this.customLabelValues.Owc_Additional, button : true, oneHourSectionId : oneHourlyFlag })
            }
        }
        this.renderOneHourlyAdditonalSection.length = 0
        for (var i of hourlyAddInfoAfterDelete){
            this.renderOneHourlyAdditonalSection.push(i)
        }
        this.oneHourlyFlag = this.renderOneHourlyAdditonalSection.length
        this.isOneHourlyAdditionalSection = true
        this.isHourlyAddSectionDeleted = true
        this.showToast('Success!',this.customLabelValues.OWC_section_delete_toastmsg,'success')
    }

    handleOneHourlySectionData(event){
        const hourlyAddInformationSectionData = event.detail
        this.hourlyAddSectionDataAfterDelete.push(hourlyAddInformationSectionData)
        console.log('hourlyAddInformationSectionData ::: ', JSON.stringify(this.hourlyAddSectionDataAfterDelete))
    }

 hourlyAdditionaldata;
 isRenderhourlyAdd

    handleOneHourlyAddSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }
    

    /**Starting Different Hour Additional Section Work here */
    @api renderDifferentHourAdditonalSection = []
    sFlag1 = 0
    differentHourAddValues
    
    @api differentHourAdditionalSectionValues
    @api differentHourAdditionalDetails = []
    isDifferentHourAdditionalInfoSection = false
    @api differentHourAddSectionDataAfterDelete =[]
    @api isDifferentHourAddSectionDeleted = false
    // Different Hour Section Validity event handler
    handleDifferentHourAddSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }

    //Add More Different Hour Info
    addMoreDifferentHour(){
        this.isDifferentHourAdditionalInfoSection = false
        const sFlag1 = this.sFlag1 + 1
        this.sFlag1 = sFlag1
        this.renderDifferentHourAdditonalSection.push({heading : this.customLabelValues.Owc_Additional, button : true, sectionId : this.sFlag1})
        this.isDifferentHourAdditionalInfoSection = true
    }

    handleDifferentHourAddSectionInfoEvent(event){
        const differentHourAdditionalSectionData = event.detail
        this.differentHourAdditionalSectionValues = differentHourAdditionalSectionData
        this.differentHourAdditionalDetails.push(this.differentHourAdditionalSectionValues)
        console.log('differentHourAdditionalDetails :::: ', JSON.stringify(this.differentHourAdditionalDetails))
        console.log('differentHourAdditionalSectionValues:', JSON.stringify(this.differentHourAdditionalSectionValues))
    }

    handleDifferentHourAdditionalSectionDelete(event){
        var sflag1 = 1
        const differentHourAddInfoAfterDelete = []
        this.isDifferentHourAdditionalInfoSection = false 
        this.differentHourAddSectionDataAfterDelete.length = 0
        this.deleteDifferentHourAddSectionId = event.detail.sectionId
        const differentHourAdditionalSectionDetails = this.template.querySelectorAll('c-Owc-Different-Hour-Rate-Additional')
        for (let i = 0; i < differentHourAdditionalSectionDetails.length; i++){
            differentHourAdditionalSectionDetails[i].handleDifferentHourAddSectionData()
        }
        const deleteDifferentHourAddSectionDataIndex = this.differentHourAddSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteDifferentHourAddSectionId)
        console.log('deleteDifferentHourAddSectionDataIndex ::: ', deleteDifferentHourAddSectionDataIndex)
        this.differentHourAddSectionDataAfterDelete.splice(deleteDifferentHourAddSectionDataIndex, 1);
        console.log('After delete successor ::: ', JSON.stringify(this.differentHourAddSectionDataAfterDelete))
        const deletedSectionIndex = this.renderDifferentHourAdditonalSection.findIndex(sec => sec.sectionId === this.deleteDifferentHourAddSectionId)
        this.renderDifferentHourAdditonalSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderDifferentHourAdditonalSection.length ;i++){
            sflag1 = 1 + i
            if(this.renderDifferentHourAdditonalSection[i].heading === this.customLabelValues.Owc_Additional){
                differentHourAddInfoAfterDelete.push(this.renderDifferentHourAdditonalSection[i])
            }
            else{
                differentHourAddInfoAfterDelete.push({heading : this.customLabelValues.Owc_Additional, button : true, sectionId : sflag1 })
            }
        }
        this.renderDifferentHourAdditonalSection.length = 0
        for (var i of differentHourAddInfoAfterDelete){
            this.renderDifferentHourAdditonalSection.push(i)
        }
        this.sFlag1 = this.renderDifferentHourAdditonalSection.length
        this.isDifferentHourAdditionalInfoSection = true
        this.isDifferentHourAddSectionDeleted = true
        this.showToast('Success!',this.customLabelValues.OWC_section_delete_toastmsg,'success')
    }

    handleDifferentHourAddSectionDeletedData(event){
        const differentHourAddInformationSectionData = event.detail
        this.differentHourAddSectionDataAfterDelete.push(differentHourAddInformationSectionData)
    }

 differentHourAdditionaldata;
 isRenderDifferentHourAdd
    
    handleDifferentAdditional(differentHourAdditionalvalue, differentHourAdditionalCount){
        this.differentHourAdditionaldata = differentHourAdditionalvalue
        this.differentHourAdditionalSectionValues = differentHourAdditionalvalue
        this.renderDifferentHourAdditonalSection.length = 0
        this.isDifferentHourAdditionalInfoSection = true
                for(let i = 0;i < differentHourAdditionalCount.length;i++){
            this.isDifferentHourAdditionalInfoSection = false
            this.renderDifferentHourAdditonalSection.push(differentHourAdditionalCount[i])
        }
        this.sFlag1 = this.renderDifferentHourAdditonalSection.length
        this.isDifferentHourAdditionalInfoSection = true
        this.isRenderDifferentHourAdd = true
    }

    handleHourlyAdditional(oneHourlyAdditionalvalue, OneHourlyAdditionalCount){
        this.oneHourlyAdditionalData = oneHourlyAdditionalvalue
        this.oneHourlyAdditionalSectionValues = oneHourlyAdditionalvalue
        this.renderOneHourlyAdditonalSection.length = 0
        this.isOneHourlyAdditionalSection = true
                for(let i = 0;i < OneHourlyAdditionalCount.length;i++){
            this.isOneHourlyAdditionalSection = false
            this.renderOneHourlyAdditonalSection.push(OneHourlyAdditionalCount[i])
        }
        this.oneHourlyFlag = this.renderOneHourlyAdditonalSection.length
        this.isOneHourlyAdditionalSection = true
        this.isRenderDifferentHourAdd = true
    }

    /**Starting Salary Rate Additional Section Work here */
    @api renderSalaryRateAdditonalSection = []
    salaryRateFlag = 0
    hourlyAddValues
   
    @api salaryRateAdditionalSectionValues
    @api salaryRateAdditionalDetails = []
    @api isSalaryRateAdditionalSection = false
    isSalaryRateAddSectionDeleted = false
    @api salaryRateAddSectionDataAfterDelete = []
    // Salary Rate Section Validity event handler
    salaryRateAddSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }

    //Add More Salary Rate Info
    addMoreSalaryRate(){
        this.isSalaryRateAdditionalSection = false
        const salaryRateFlag = this.salaryRateFlag + 1
        this.salaryRateFlag = salaryRateFlag
        this.renderSalaryRateAdditonalSection.push({heading : this.customLabelValues.Owc_Additional, button : true, salaryRateSectionId : this.salaryRateFlag})
        this.isSalaryRateAdditionalSection = true
    }

    handleSalaryRateAddSectionInfoEvent(event){
        const salaryRateAdditionalSectionData = event.detail
        this.salaryRateAdditionalSectionValues = salaryRateAdditionalSectionData
        this.salaryRateAdditionalDetails.push(this.salaryRateAdditionalSectionValues)
        console.log('salaryRateAdditionalDetails :::: ', JSON.stringify(this.salaryRateAdditionalDetails))
        console.log('salaryRateAdditionalSectionValues:', JSON.stringify(this.salaryRateAdditionalSectionValues))
    }

    handleSalaryRateSectionDeletion(event){
        var salaryRateFlag = 0
        const salaryRateAddInfoAfterDelete = []
        this.isSalaryRateAdditionalSection = false
        this.salaryRateAddSectionDataAfterDelete.length = 0
        this.deleteSalaryRateAddSectionId = event.detail.salaryRateSectionId
        const salaryRateAdditionalSectionDetails = this.template.querySelectorAll('c-owc-Salary-Rate-Additional-Cmp')
        for (let i = 0; i < salaryRateAdditionalSectionDetails.length; i++){
            salaryRateAdditionalSectionDetails[i].handleSalaryRateAddSectionData()
        }
        const deleteSalaryRateAddSectionDataIndex = this.salaryRateAddSectionDataAfterDelete.findIndex(sec => sec.salaryRateSectionId === this.deleteSalaryRateAddSectionId)
        console.log('deleteSalaryRateAddSectionDataIndex ::: ', deleteSalaryRateAddSectionDataIndex)
        this.salaryRateAddSectionDataAfterDelete.splice(deleteSalaryRateAddSectionDataIndex, 1);
        console.log('After delete Salary Rate ::: ', JSON.stringify(this.salaryRateAddSectionDataAfterDelete))
        const deletedSectionIndex = this.renderSalaryRateAdditonalSection.findIndex(sec => sec.salaryRateSectionId === this.deleteSalaryRateAddSectionId)
        this.renderSalaryRateAdditonalSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderSalaryRateAdditonalSection.length ;i++){
            salaryRateFlag = i + 1
            if(this.renderSalaryRateAdditonalSection[i].heading === this.customLabelValues.OWC_successoraddinfo_heading){
                salaryRateAddInfoAfterDelete.push(this.renderSalaryRateAdditonalSection[i])
            }
            else{
                salaryRateAddInfoAfterDelete.push({heading : this.customLabelValues.Owc_Additional, button : true, salaryRateSectionId : salaryRateFlag })
            }
        }
        this.renderSalaryRateAdditonalSection.length = 0
        for (var i of salaryRateAddInfoAfterDelete){
            this.renderSalaryRateAdditonalSection.push(i)
        }
        this.salaryRateFlag = this.renderSalaryRateAdditonalSection.length
        this.isSalaryRateAdditionalSection = true
        this.isSalaryRateAddSectionDeleted = true
        this.showToast('Success!',this.customLabelValues.OWC_section_delete_toastmsg,'success')
    }

    handleSalaryRateSectionData(event){
        const salaryRateAddInformationSectionData = event.detail
        this.salaryRateAddSectionDataAfterDelete.push(salaryRateAddInformationSectionData)
        console.log('salaryRateAddInformationSectionData ::: ', JSON.stringify(this.salaryRateAddSectionDataAfterDelete))
    }

 salaryRateAdditionaldata;
 isRenderSalaryRateAdd
   
    salaryRateAdditionalSectionValues
    handleSalaryRateAdditional(salaryRateAdditionalvalue, salaryRateAdditionalCount){
        this.salaryRateAdditionaldata = salaryRateAdditionalvalue
        this.salaryRateAdditionalSectionValues = salaryRateAdditionalvalue
        this.renderSalaryRateAdditonalSection.length = 0
        this.isSalaryRateAdditionalSection = true
        if(salaryRateAdditionalCount !== undefined || salaryRateAdditionalCount !== null)
        {
            for(var i = 0;i < salaryRateAdditionalCount.length;i++){
            this.isSalaryRateAdditionalSection = false
            this.renderSalaryRateAdditonalSection.push(salaryRateAdditionalCount[i])
           }
       }
        this.salaryRateFlag = this.renderSalaryRateAdditonalSection.length
        this.isSalaryRateAdditionalSection = true
        this.isRenderDifferentHourAdd = true
    }

    handleSalaryRateAddSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }

    /**Starting Piece Rate Additional Section Work here */
   @api renderPieceRateAdditonalSection = []
   pieceRateFlag = 0
   pieceRateAddValues
  
   @api pieceRateAdditionalSectionValues
   @api pieceRateAdditionalDetails = []
   @api isPieceRateAdditionalSection = false
   isPieceRateAddSectionDeleted = false
   @api pieceRateAddSectionDataAfterDelete = []
   // Piece Rate Section Validity event handler
   pieceRateAddSectionValidity(event){
       const val = event.detail
       this.isNotChangedCurrentStep = val.currentStep
       console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
   }

   //Add More Piece Rate Info
   addMorePieceRate(){
       this.isPieceRateAdditionalSection = false
       const pieceRateFlag = this.pieceRateFlag + 1
       this.pieceRateFlag = pieceRateFlag
       this.renderPieceRateAdditonalSection.push({heading : this.customLabelValues.Owc_Additional, button : true, pieceRateSectionId : this.pieceRateFlag})
       this.isPieceRateAdditionalSection = true
   }

   handlePieceRateAddSectionInfoEvent(event){
       const pieceRateAdditionalSectionData = event.detail
       this.pieceRateAdditionalSectionValues = pieceRateAdditionalSectionData
       this.pieceRateAdditionalDetails.push(this.pieceRateAdditionalSectionValues)
       console.log('pieceRateAdditionalDetails :::: ', JSON.stringify(this.pieceRateAdditionalDetails))
       console.log('pieceRateAdditionalSectionValues:', JSON.stringify(this.pieceRateAdditionalSectionValues))
   }

   handlePieceRateSectionDeletion(event){
       var pieceRateFlag = 0
       const pieceRateAddInfoAfterDelete = []
       this.isPieceRateAdditionalSection = false
       this.pieceRateAddSectionDataAfterDelete.length = 0
       this.deletePieceRateAddSectionId = event.detail.pieceRateSectionId
       const pieceRateAdditionalSectionDetails = this.template.querySelectorAll('c-owc-Piece-Rate-Additional-Cmp')
       for (let i = 0; i < pieceRateAdditionalSectionDetails.length; i++){
           pieceRateAdditionalSectionDetails[i].handlePieceRateAddSectionData()
       }
       const deletePieceRateAddSectionDataIndex = this.pieceRateAddSectionDataAfterDelete.findIndex(sec => sec.pieceRateSectionId === this.deletePieceRateAddSectionId)
       console.log('deletePieceRateAddSectionDataIndex ::: ', deletePieceRateAddSectionDataIndex)
       this.pieceRateAddSectionDataAfterDelete.splice(deletePieceRateAddSectionDataIndex, 1);
       console.log('After delete successor ::: ', JSON.stringify(this.pieceRateAddSectionDataAfterDelete))
       const deletedSectionIndex = this.renderPieceRateAdditonalSection.findIndex(sec => sec.pieceRateSectionId === this.deletePieceRateAddSectionId)
       this.renderPieceRateAdditonalSection.splice(deletedSectionIndex, 1);
       for(let i = 0; i < this.renderPieceRateAdditonalSection.length ;i++){
           pieceRateFlag = i + 1
           if(this.renderPieceRateAdditonalSection[i].heading === this.customLabelValues.OWC_successoraddinfo_heading){
               pieceRateAddInfoAfterDelete.push(this.renderPieceRateAdditonalSection[i])
           }
           else{
               pieceRateAddInfoAfterDelete.push({heading : this.customLabelValues.Owc_Additional, button : true, pieceRateSectionId : pieceRateFlag })
           }
       }
       this.renderPieceRateAdditonalSection.length = 0
       for (var i of pieceRateAddInfoAfterDelete){
           this.renderPieceRateAdditonalSection.push(i)
       }
       this.pieceRateFlag = this.renderPieceRateAdditonalSection.length
       this.isPieceRateAdditionalSection = true
       this.isPieceRateAddSectionDeleted = true
       this.showToast('Success!',this.customLabelValues.OWC_section_delete_toastmsg,'success')
   }

   handlePieceRateSectionData(event){
       const pieceRateAddInformationSectionData = event.detail
       this.pieceRateAddSectionDataAfterDelete.push(pieceRateAddInformationSectionData)
       console.log('pieceRateAddInformationSectionData ::: ', JSON.stringify(this.pieceRateAddSectionDataAfterDelete))
   }

pieceRateAdditionaldata;
isRenderPieceRateAdd
  
   pieceRateAdditionaldata
   pieceRateAdditionalSectionValues
   handlePieceRateAdditional(pieceRateAdditionalvalue, pieceRateAdditionalCount){
       this.pieceRateAdditionaldata = pieceRateAdditionalvalue
       this.pieceRateAdditionalSectionValues = pieceRateAdditionalvalue
       this.renderPieceRateAdditonalSection.length = 0
       this.isPieceRateAdditionalSection = true
               for(let i = 0;i < pieceRateAdditionalCount.length;i++){
           this.isPieceRateAdditionalSection = false
           this.renderPieceRateAdditonalSection.push(pieceRateAdditionalCount[i])
       }
       this.pieceRateFlag = this.renderPieceRateAdditonalSection.length
       this.isPieceRateAdditionalSection = true
       this.isRenderPieceRateAdd = true
   }

   handlePieceRateAddSectionValidity(event){
       const val = event.detail
       this.isNotChangedCurrentStep = val.currentStep
       console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
   }

    //Upload Document variables
    @api uploadFileSize;
    @api isFileUploaded = false
    @api toastFileUploadMsg = customLabelValues.OWC_fileupload_success_toast_msg
    @api toastFileDeleteMsg = customLabelValues.OWC_multiple_file_delete_toast_msg
    @api uploadUnionContractDocument
   
    
    handleCommissionReciptUpload(event) {
        // Get the list of uploaded files
        const uploadedCommissionFiles = event.detail.files;
        this.commissionReciptDocs = uploadedCommissionFiles;
        if(uploadedCommissionFiles != null){
            this.isCommissionReciptFileUpload = false;
            this.commissionReciptDocsSize = this.commissionReciptDocs.length;
            this.template.querySelector('[data-id="summaryDocId"]').getDocData(this.commissionReciptDocs);
            this.isRenderedCallback = false;
            this.showToast(this.toastFileUploadMsg);
        }
        else{
            this.isCommissionReciptFileUpload = true
        }
    }
   
    handleCommissionReciptDocsUpload(event){
        console.log('event.detail:', JSON.stringify(event.detail));
        this.commissionReciptDocs = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast(this.toastFileDeleteMsg) : ''
        this.commissionReciptDocsSize = this.commissionReciptDocs.length
    }

    handleAgreementUpload(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.agreementDocs = uploadedFiles;
        if(uploadedFiles != null){
            this.isAgreementFileUpload = false;
            this.agreementDocsSize = this.agreementDocs.length;
            this.template.querySelector('[data-id="additionalDocId"]').getDocData(this.agreementDocs);
            this.isRenderedCallback = false;
            this.showToast(this.toastFileUploadMsg);
        }
        else{
            this.isAgreementFileUpload = true
        }
    }
   
    handleAgreementDocsUpload(event){
        console.log('event.detail:', JSON.stringify(event.detail));
        this.agreementDocs = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast(this.toastFileDeleteMsg) : ''
        this.agreementDocsSize = this.agreementDocs.length
    }

    @api isDifferentHour = false
    @api isOneHourly = false
    @api isSalaryRate = false
    @api commissionRate = false

    @api 
    handlePreview(strString,isFormPreview){
        this.paymentWagesDetailPreview = strString
        this.value = strString.value 
        this.isFormPreview = isFormPreview

        this.isCommissionReciptFileUpload = strString.isCommissionReciptFileUpload
        this.commissionReciptDocsSize = strString.commissionReciptDocsSize
        this.commissionReciptDocs = strString.commissionReciptDocs
        this.isAgreementFileUpload = strString.isAgreementFileUpload
        this.agreementDocsSize = strString.agreementDocsSize
        this.agreementDocs = strString.agreementDocs

        this.handleHourlyAdditional(strString.hourlyAdditionalDetails, strString.renderOneHourlyAdditonalSection)
        this.handleDifferentAdditional(strString.differentHourAdditionalDetails, strString.renderDifferentHourAdditonalSection)
        this.handleSalaryRateAdditional(strString.salaryRateAdditionalDetails, strString.renderSalaryRateAdditonalSection)
        this.handlePieceRateAdditional(strString.pieceRateAdditionalDetails, strString.renderPieceRateAdditonalSection)

        if(strString.paidAmountPerHour !=null || strString.promisedAmountPerHour != null){ 
            this.isOneHourlyRatePreview = true
        }else{
            this.isOneHourlyRatePreview = false
        }

        if(strString.paidAmountPerHour !=null || strString.promisedAmountPerHour != null 
            || strString.hourlyRateBegDate != null){ 
            this.isOneHourly = true
        }else{
            this.isOneHourly = false
        }

        if(strString.paidAmountDifferentHour != null || strString.promisedAmountDifferentHour != null 
            || strString.forActivity != null || strString.differentHourlyRateBegDate != null){
                this.isDifferentHour = true
            }else{
                this.isDifferentHour = false
            }

        if(strString.paidAmountForEachDay != null || strString.promisedAmountForEachDay != null 
            || strString.frequencyOfEachDay != null || strString.eachPayRateBegDate != null){
                this.isSalaryRate = true
            }else{
                this.isSalaryRate = false
            }

        if(strString.paidCommissionRate != null || strString.promisedCommissionRate != null 
            || strString.commissionRateBegDate != null || strString.writtenCommission != null){
                this.commissionRate = true
            }else{
                this.commissionRate = false
            }
        console.log("Preview Value",this.isOneHourlyRatePreview)
        this.isRenderedCallback = true
    }

    //rendercallback 
    renderedCallback(){
        if(this.isRenderedCallback === true){
            const templateArray = this.template.querySelectorAll('c-owc-Multiple-File-Upload-Details-Cmp')
            for (let i = 0; i < templateArray.length; i++){
                if(templateArray[i].name === 'summaryDoc'){
                        templateArray[i].getDocInfos(this.commissionReciptDocs, this.ispreviewmode);
                }
                else if(templateArray[i].name === 'additionalDoc'){
                        templateArray[i].getDocInfos(this.agreementDocs, this.ispreviewmode);
                }
            }
        }

        if(this.isRenderedCallback === true && this.paymentWagesDetailPreview.isOneHourlyRate === true && this.isOneHourlyAdditionalSection === true){
            const hourlyAdditionalSectionDetails = this.template.querySelectorAll('c-owc-One-Hour-Additional-Cmp')
            console.log('hourlyAdditionalSectionDetails::',hourlyAdditionalSectionDetails.length)
            if(hourlyAdditionalSectionDetails.length > 0){
            for (var i = 0; i < hourlyAdditionalSectionDetails.length; i++){
                hourlyAdditionalSectionDetails[i].owcHourlyAdditionalFromForChild(this.oneHourlyAdditionalData[i],this.isFormPreview)
            }
            this.isRenderhourlyAdd = false
            }
        }    

        if(this.isRenderedCallback === true && this.paymentWagesDetailPreview.isDifferentHourRate === true && this.isRenderDifferentHourAdd === true){
            const differentHourAdditionalSectionDetails = this.template.querySelectorAll('c-Owc-Different-Hour-Rate-Additional')
            console.log('differentHourAdditionalSectionDetails::',differentHourAdditionalSectionDetails.length)
            if(differentHourAdditionalSectionDetails.length > 0){
                for (var i = 0; i < differentHourAdditionalSectionDetails.length; i++){
                    differentHourAdditionalSectionDetails[i].owcDifferentHourAdditionalFromForChild(this.differentHourAdditionaldata[i],this.isFormPreview)
                }
                this.isRenderDifferentHourAdd = false
            }
        }

        if(this.isRenderedCallback === true && this.paymentWagesDetailPreview.isSalaryRateForEachDay === true && this.isSalaryRateAdditionalSection === true){
            const salaryRateAdditionalSectionDetails = this.template.querySelectorAll('c-owc-Salary-Rate-Additional-Cmp')
            console.log('salaryRateAdditionalSectionDetails::',salaryRateAdditionalSectionDetails.length)
            if(salaryRateAdditionalSectionDetails.length > 0){
            for (var i = 0; i < salaryRateAdditionalSectionDetails.length; i++){
                salaryRateAdditionalSectionDetails[i].owcSalaryRateAdditionalFromForChild(this.salaryRateAdditionaldata[i],this.isFormPreview)
            }
            this.isRenderSalaryRateAdd = false
            }
        }

        if(this.isRenderedCallback === true && this.paymentWagesDetailPreview.isPieceRate === true && this.isPieceRateAdditionalSection === true){
            const pieceRateAdditionalSectionDetails = this.template.querySelectorAll('c-owc-Piece-Rate-Additional-Cmp')
            console.log('pieceRateAdditionalSectionDetails::',pieceRateAdditionalSectionDetails.length)
            if(pieceRateAdditionalSectionDetails.length > 0){
            for (var i = 0; i < pieceRateAdditionalSectionDetails.length; i++){
                pieceRateAdditionalSectionDetails[i].owcPieceRateAdditionalFromForChild(this.pieceRateAdditionaldata[i],this.isFormPreview)
            }
            this.isRenderPieceRateAdd = false
            }
        }

        this.isRenderedCallback = false
    } 
}