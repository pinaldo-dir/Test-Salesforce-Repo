import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor'
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import OWC_delete_file_header_label from '@salesforce/label/c.OWC_delete_file_header_label'
import OWC_file_name_header_label from '@salesforce/label/c.OWC_file_name_header_label'
import deleteMultipleFiles from '@salesforce/apex/OWCMultipleFileDeleteController.deleteMultipleFiles';

export default class OWCMultipleFileUploadDetailsCmp extends LightningElement {
    @api uploadcontractdoc = []
    @api uploadContractDocSize
    @track smallDevice 
    @track mediumDevice
    @track largeDevice
    @api fileName
    @api isFileDeleted = false
    @api isSelectedFileDeleted = false
    @api contentId
    @api isFormPreviewMode = false

    customLabelValues = {
        OWC_delete_file_header_label,
        OWC_file_name_header_label
    }

    get contractDocSize(){
        return this.uploadContractDocSize > 0;
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
        console.log('called');
        if(this.isSelectedFileDeleted === true){
            const docIndex = this.uploadcontractdoc.findIndex(doc => doc.documentId === this.contentId);
            this.deleteExtraFiles();
            this.uploadcontractdoc.splice(docIndex, 1);
            this.uploadContractDocSize = this.uploadcontractdoc.length;
            this.handleUploadedFilesDataFromChild();
        }
    }

    @track contentVersionIds = []
    deleteExtraFiles(){
        this.contentVersionIds.push(this.contentId);
        deleteMultipleFiles({ contentVersionIds : JSON.stringify(this.contentVersionIds) })
           .then(result => {
               if(result){
                
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
    }

    deleteUploadDoc(event){
        const contentId = event.target.value
        console.log('contentId::',contentId);
        this.contentId = contentId
        const fileName = this.uploadcontractdoc.filter(doc => doc.documentId === contentId)
        console.log('fileName::',fileName);

        if(fileName.length > 0){
            console.log('fileName ::: ', JSON.stringify(fileName))
            this.isFileDeleted = true
            this.fileName = fileName[0].name
        }
        else{
            this.isFileDeleted = false
        }
    }


    @api 
    getDocInfos(strString, isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode
        if(strString != undefined || strString != null){
            this.uploadcontractdoc.length = 0
        this.isSelectedFileDeleted = false
        this.uploadcontractdoc = strString;
        }
        this.uploadContractDocSize = this.uploadcontractdoc.length
        if(this.uploadContractDocSize > 0){
            this.detectDevice();
        }
        this.handleUploadedFilesDataFromChild();
    }

    @api
    getDocData(strString, isFilesDeleted){
        console.log('strString:', JSON.stringify(strString));
        this.isSelectedFileDeleted = false
        // if(strString.recordId === this.uploadcontractdoc)
        if(strString != undefined || strString != null){
            for(var i=0;i<strString.length;i++){
                console.log('MMM');
                console.log(i);
                if(isFilesDeleted === true){
                    this.uploadcontractdoc.length = 0
                }
               //// else if(this.uploadcontractdoc.some(uploadDoc => uploadDoc.recordId === //strString[i].recordId)){
                else{
                    
                    this.uploadcontractdoc.push(strString[i]);
                }
            }
            console.log(this.uploadcontractdoc);
        }
        this.uploadContractDocSize = this.uploadcontractdoc.length
        if(this.uploadContractDocSize > 0){
            this.detectDevice();
        }
        this.handleUploadedFilesDataFromChild();
    }

    handleUploadedFilesDataFromChild(){
        const selectEvent = new CustomEvent('uploaddocumentevent', {
            detail: {
                uploadcontractdoc : this.uploadcontractdoc,
                isSelectedFileDeleted : this.isSelectedFileDeleted
            }
        });
        console.log('event doc:', JSON.stringify(this.uploadcontractdoc));
        this.dispatchEvent(selectEvent);
    }

    detectDevice (){
        switch(FORM_FACTOR) {
            case 'Large':
                this.largeDevice = 'LargeDeviceDetect'
                return 'LargeDeviceDetect';
            case 'Medium':
                this.mediumDevice = 'MediumDeviceDetect'
                return 'MediumDeviceDetect';
            case 'Small':
                this.smallDevice = 'SmallDeviceDetect'
                return 'SmallDeviceDetect';
            default:
        }
    }

    get largeDeviceDetect(){
        return this.largeDevice === 'LargeDeviceDetect'
    }

    get mediumDeviceDetect(){
        return this.mediumDevice === 'MediumDeviceDetect'
    }

    get smallDeviceDetect(){
        return this.smallDevice === 'SmallDeviceDetect'
    }
}