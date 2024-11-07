import { LightningElement, api } from 'lwc';
import { customLabelValues, acceptedFileFormat } from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import getSubmitClaimConfirmation from '@salesforce/apex/OWCSubmitClaimContainerController.getSubmitClaimConfirmation';
import submitClaimantConfirmationRecords from '@salesforce/apex/OWCSubmitClaimContainerController.submitClaimantConfirmationRecords';
export default class OWCSubmitClaimConfirmationCmp extends LightningElement {
    @api istoastmessage = false ;
    @api uploadedDocuments;
    @api additonalClaimDocSize;
    @api recordId;
    @api isShowButton = false
    @api isSubmitClaimCmp = false;
    @api submitClaimCheckBox = false;
    @api additionalClaimDocs = false;
    @api isClaimantConfirmationRequiredMsg = false;
    @api isMultipleFileUploadSection = false;
    @api isSelectedFileDeleted = false
    @api isClaimantUploaded = false
    @api isSaveDisabled = false
    @api isSpinner = false;
    issubmitClaimCheckBoxDone = false;
    isuploadfileDone = false
    contentVersionIds = []
    @api toastFileUploadMsg = customLabelValues.OWC_fileupload_success_toast_msg
    @api toastFileDeleteMsg = customLabelValues.OWC_multiple_file_delete_toast_msg
    customLabelValues = customLabelValues
    acceptedFormats = acceptedFileFormat

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

        // Get reordId from the URL
        const currentCommunityUrl = window.location.search
        console.log('currentCommunityUrl1 ::: '+currentCommunityUrl)
        const urlParams = new URLSearchParams(currentCommunityUrl);
        const recordId = urlParams.get('recordId')
        this.recordId = recordId;
        getSubmitClaimConfirmation({  
            recordId : this.recordId,
        })
        .then(result => {
            if(result){
                if(result === true){
                    this.istoastmessage = true;
                }
                else{
                    this.istoastmessage = false;
                }
            }
        })
        .catch(error => {
            //this.showToast('Error!', error.body.message, 'error');
        }) 
    }
    
    closeModal(){
        this.isSubmitClaimCmp = false;
        this.istoastmessage = true;
    }

    closeToastModal(){
        this.isClaimantConfirmationRequiredMsg = false;
        this.istoastmessage = true;
    }

    handlePopUp(){
        this.isSubmitClaimCmp = true;
        this.istoastmessage = true;
        // Check if checkbox is false then hide the upload cmp
        this.isClaimantUploaded = false;
    }

    handleSave(){
        this.handlesubmitClaimCheckBoxFocus();
        if(this.uploadedDocuments === null || this.uploadedDocuments === undefined){
            this.isuploadfileDone = true;
            this.isClaimantConfirmationRequiredMsg = true
        }
        else{
            this.isuploadfileDone = false;
            this.isClaimantConfirmationRequiredMsg = false
        }
        if(this.issubmitClaimCheckBoxDone === true || this.isuploadfileDone === true ){
            this.handleCustomValidityEvent();
        }
        else{
            this.isSpinner = true;
            this.prepareContentVersionIds(this.uploadedDocuments);
            this.isSaveDisabled = true
            submitClaimantConfirmationRecords({
                contentIds : this.contentVersionIds,
                recordId : this.recordId
            })
            .then(result => {
                if(result === true){
                    this.isSubmitClaimCmp = false;
                    this.isSpinner = false;
                    this.showToast('Success', 'Record has been successfully updated.', 'success');
                    this.istoastmessage = false;
                }
            })
            .catch(error => {
                //this.showToast('Something went wrong', error.body.message, 'error');
                this.isSaveDisabled = false;
            })
        }
    }

    handleSubmitClaimCmpEvent(event){
        const SubmitClaimCmpValue = event.detail
        this.isSubmitClaimCmp = SubmitClaimCmpValue.isClosedSubmitClaimCmp
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleChange(event){
        event.preventDefault()
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            case "submitClaimCheckBox":
                const submitClaimCheckBox = event.target.checked
                this.submitClaimCheckBox = submitClaimCheckBox
                if(this.submitClaimCheckBox === true){
                    this.isClaimantUploaded = true;
                    this.isSaveDisabled = false;
                }
                else{
                    this.isClaimantUploaded = false;
                }
                this.handlesubmitClaimCheckBoxFocus();
            break;
        }
    }

    handlesubmitClaimCheckBoxFocus(){
        let submitClaimCheckBoxId = this.template.querySelector('[data-id="submitClaimCheckBoxId"]')
        if(submitClaimCheckBoxId.checked === false){
            submitClaimCheckBoxId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            submitClaimCheckBoxId.reportValidity()
            this.issubmitClaimCheckBoxDone = true
        }
        else if(submitClaimCheckBoxId.checked === true){
            submitClaimCheckBoxId.setCustomValidity('')
            submitClaimCheckBoxId.reportValidity()
            this.issubmitClaimCheckBoxDone = false
        }
    }

    handleUploadDocs(event) {
        const uploadedFiles = event.detail.files
        this.uploadedDocuments = uploadedFiles
        if(this.uploadedDocuments.length > 0){
            this.isSaveDisabled = false;
            this.isClaimantConfirmationRequiredMsg = false;
            this.isMultipleFileUploadSection = false
            this.additonalClaimDocSize = this.uploadedDocuments.length
            this.template.querySelector('c-owc-Multiple-File-Upload-Details-Cmp').getDocData(this.uploadedDocuments)
            this.isRenderedCallback = false
            this.showToast('Success!',this.toastFileUploadMsg,'success')
        }
        else{
            this.isClaimantConfirmationRequiredMsg = true;
            this.isMultipleFileUploadSection = true
        }
    }

    prepareContentVersionIds(contentVersions){
        this.contentVersionIds = [];
        for(var i=0; i<contentVersions.length; i++){
            this.contentVersionIds.push(contentVersions[i].contentVersionId);
        }
        return;
    } 

    handleCustomValidityEvent(){
        const selectEvent = new CustomEvent('validityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isValidityTrue = false
        this.dispatchEvent(selectEvent);
    }

    handleAdditonalClaimDocEvent(event){
        this.uploadedDocuments = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.additonalClaimDocSize = this.uploadedDocuments.length
    }

    handleOnlineFormDetails(){
        return {
            uploadedDocuments : this.uploadedDocuments,
            isMultipleFileUploadSection : this.isMultipleFileUploadSection,
            additonalClaimDocSize : this.additonalClaimDocSize,
            submitClaimCheckBox : this.submitClaimCheckBox,
        }
    }
}