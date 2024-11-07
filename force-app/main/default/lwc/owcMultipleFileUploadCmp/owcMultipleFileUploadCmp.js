import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
export default class OwcMultipleFileUploadCmp extends LightningElement {
    @api myRecordId;
    @api isFileDetailsVisible = false
    @api isFileDeleted = false
    @api uploadcontractdoc = []
    @api uploadContractDocSize
    @api isSelectedFileDeleted = false
    @api contentId
    @api label

    get acceptedFormats() {
        return ['.pdf', '.png', '.docx', '.csv', '.xls'];
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

    @api
    getUploadedFilesDetail(){
        const selectEvent = new CustomEvent('multiplefilesevent', {
            detail: this.uploadcontractdoc
        });
        this.dispatchEvent(selectEvent);
    }

    @api
    getUploadedFilesDetailFromParent(fileDetails){
        if(this.uploadContractDoc != undefined || this.uploadContractDoc != null){
            this.uploadContractDoc.length = 0
        }
        
        this.isFileDetailsVisible = false
        for(var i=0; i<fileDetails.length; i++){
            this.uploadcontractdoc.push(fileDetails[i])
        }
        this.isFileDetailsVisible = true
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        for(var i=0; i < uploadedFiles.length; i++){
            this.uploadcontractdoc.push(uploadedFiles[i])
        }
        uploadedFiles.length > 0 ? this.isFileDetailsVisible = true : this.isFileDetailsVisible = false
    }

    deleteUploadDoc(event){
        const contentId = event.target.value
        this.contentId = contentId
        const fileName = this.uploadcontractdoc.filter(doc => doc.documentId === contentId)
        if(fileName.length > 0){
            console.log('fileName ::: ', JSON.stringify(fileName))
            this.isFileDeleted = true
            this.fileName = fileName[0].name
        }
        else{
            this.isFileDeleted = false
        }
    }

    get contractDocSize(){
        return this.uploadContractDocSize > 0;
    }

    handleDeleteMsg(event){
        const isClosedHelpText = event.detail.isClosedHelpText
        this.isFileDeleted = isClosedHelpText
        this.isSelectedFileDeleted = event.detail.isFileDeleted
        this.handleFileDeleted()
    }

    handleUndeleteMsg(event){
        const isClosedHelpText = event.detail.isClosedHelpText
        this.isFileDeleted = isClosedHelpText
        this.isSelectedFileDeleted = event.detail.isFileDeleted
        this.handleFileDeleted()
    }

    handleCloseModal(event){
        const isClosedHelpText = event.detail.isClosedHelpText
        this.isFileDeleted = isClosedHelpText
    }

    handleFileDeleted(){
        if(this.isSelectedFileDeleted === true){
            const docIndex = this.uploadcontractdoc.findIndex(doc => doc.documentId === this.contentId);
            this.uploadcontractdoc.splice(docIndex, 1);
            this.uploadContractDocSize = this.uploadcontractdoc.length;
            // this.handleUploadedFilesDataFromChild();
        }
    }
}