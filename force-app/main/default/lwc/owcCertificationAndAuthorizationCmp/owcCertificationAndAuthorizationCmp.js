import { LightningElement, api, track } from 'lwc';
import { acceptedFileFormat, customLabelValues } from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
//import insertUploadedFiles from '@salesforce/apex/OWCMultipleFileUploadController.insertUploadedFiles';
import deleteMultipleFiles from '@salesforce/apex/OWCMultipleFileDeleteController.deleteMultipleFiles';
const MAX_FILE_SIZE = 25000000;  ///20MB in Bytes
const CHUNK_SIZE = 750000;
let fileSize=0;
export default class OwcCertificationAndAuthorizationCmp extends LightningElement {
    showLoadingSpinner = false;
    @track fileNames = '';
    @track filesUploaded = [];

    customLabelValues = customLabelValues

    @api isclaimantadvocate;
    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`
    // Accepted formats for File Upload Section
    acceptedFormats = acceptedFileFormat

    @api toastFileUploadMsg = customLabelValues.OWC_fileupload_success_toast_msg
    @api toastFileDeleteMsg = customLabelValues.OWC_multiple_file_delete_toast_msg
    @api isRenderedCallback = false
    @api isAuthorizationRelease = false
    @api addtionalClaimDocs
    @api isAdditionalClaimDocUpload = false
    @api additonalClaimDocSize
    @api isSelectedFileDeleted = false
    @api claimantName
    @api claimDate
    @api isReadOnlyCheckboxValue = false

    // HelpText Attributes
    @api isHelpText = false
    @api helpText

       placeHolderDatePrepare(processingDate){
        //add the TimeZone offset if the User TimeZone is behind the GMT.
        if(new Date().getTimezoneOffset() > 0) {
            processingDate = new Date(new Date(processingDate).getTime() + (new Date().getTimezoneOffset()+30) *60*1000);
        }
        console.log('result :: ', new Date(processingDate));
        processingDate = new Date(processingDate);
        var dd = processingDate.getUTCDate();
        var mm = processingDate.getUTCMonth() + 1;
        var yyyy = processingDate.getUTCFullYear();
        
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        
        if(mm<10) 
        {
            mm= '0'+mm;
        } 
        console.log('Expected Date ::: ', mm+'/'+dd+'/'+yyyy);
        return (mm+'/'+dd+'/'+yyyy);
    }

    //Section validity Checker for the required fields     
    sectionValidityChecker(ids, values){
        let id = ids
        let value = values
        console.log('Value:', value);
        const val = value == undefined || value == null ? '' : value
        if(val.trim() == ""){
            id.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            id.reportValidity();
            return true;
        }
    }

     //ClaimDate Validation with required and Past date
     claimDateValidityChecker(ids, values){
        let id = ids
        let value = values
        var inputDate
        var today = new Date();
        if(value != null){
            inputDate = new Date(value.toString());
        }else{
            inputDate = value;
        }
        if(value == null || value == undefined || value == ''){
            id.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            id.reportValidity();
        return true;
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            id.reportValidity();
        return true;
        }
    }

    // Continue Button
    handleNext(event){
        const selectEvent = new CustomEvent('continuetocertificationevent', {
            detail: { 
                isContinue : true
             }
       });
      this.dispatchEvent(selectEvent);
    }
/*
    handleclaimDateFocus(){
        var inputDate
        var today = new Date();
        let claimDate = this.template.querySelector('[data-id="claimDate"]');
        if(claimDate.value != null){
            inputDate = new Date(claimDate.value.toString());
        }else{
            inputDate = claimDate.value;
        }
        if(claimDate.value == null || claimDate.value == undefined || claimDate.value == ''){
            claimDate.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            claimDate.reportValidity();
            return true;
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            claimDate.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            claimDate.reportValidity();
            return true;
        }
        else{
            claimDate.setCustomValidity('');
            claimDate.reportValidity();
            return false;
        }
        }
*/


        handleclaimDateFocus(){
            var today = new Date();
            let d = today.getDate();
            let hour = today.getHours();
            this.claimDate = new Date();
            if (hour >= 17) {
                this.claimDate = today.toString(today.setDate(d + 1));
            }
            console.log('claimDate :: ',this.claimDate);  
            console.log('today :: ',today);
            console.log('hour :: ',hour);
            }

    //How were your wages paid focus    
    handleclaimantNameFocus(){
        let claimantName = this.template.querySelector('[data-id="claimantName"]');          
        if(claimantName.value == undefined || claimantName.value == null || claimantName.value == ''){
            claimantName.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            claimantName.reportValidity();
            return true;
        }
        else{
            claimantName.setCustomValidity("");
            claimantName.reportValidity();
            return false;
        }
    }

    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            case "authorizationToRelease":
                console.log('isAuthorizationRelease true ::: ', event.target.checked)
                const isAuthorizationRelease = event.target.checked
                this.isAuthorizationRelease = isAuthorizationRelease
                this.handleAuthorizedReleaseFocus();
            break;
            case "claimantName":
                this.claimantName = event.target.value
                this.handleclaimantNameFocus();
                console.log('claimantName:::',this.claimantName);
            break;
            case "claimDate":
                this.claimDate = event.target.value;
                // event.target.value !== null ? this.claimDate = new Date(this.placeHolderDatePrepare(event.target.value)) : this.claimDate = null;
                // this.claimDate !== null ? this.template.querySelector('[data-id="claimDate"]').value = this.claimDate : this.template.querySelector('[data-id="claimDate"]').value = null;
                this.handleclaimDateFocus();
                console.log('claimDate:::',this.claimDate);
            break;
        }
        
    }

    handleAuthorizedReleaseFocus(){
        let authorizationToReleaseId = this.template.querySelector('[data-id="authorizationToReleaseId"]');
        if(authorizationToReleaseId.checked === false){
            authorizationToReleaseId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            authorizationToReleaseId.reportValidity();
            return true;
        }
        else if(authorizationToReleaseId.checked === true){
            authorizationToReleaseId.setCustomValidity('');
            authorizationToReleaseId.reportValidity();
            return false;
        }
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

    isClaimantDate = false
    isClaimantName = false
    isAuthorizedRelease = false

    handleSaveAsDraft(){
        const selectEvent = new CustomEvent('certandauthinfoevent', {
            detail: { 
                isAuthorizationRelease : this.isAuthorizationRelease,
                addtionalClaimDocs : this.addtionalClaimDocs,
                isAdditionalClaimDocUpload : this.isAdditionalClaimDocUpload,
                claimantName :  this.claimantName,
                claimDate : this.claimDate,
                additonalClaimDocSize : this.additonalClaimDocSize
             }
       });
      this.dispatchEvent(selectEvent);
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "11"
            }
        });
        this.dispatchEvent(validateEvent);
    }

    @api
    certAndAuthInfoFromParent(){
        // this.handleSaveFiles();
        let authorizationToReleaseId = this.template.querySelector('[data-id="authorizationToReleaseId"]');
        if(authorizationToReleaseId.checked === false){
            authorizationToReleaseId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            authorizationToReleaseId.reportValidity();
            this.isAuthorizedRelease = true
        }
        else if(authorizationToReleaseId.checked === true){
            authorizationToReleaseId.setCustomValidity('');
            authorizationToReleaseId.reportValidity();
            this.isAuthorizedRelease = false
        }
       console.log('isAuthorizedRelease ::: ', this.isAuthorizedRelease);
        if(this.isAuthorizedRelease === true){
            const eventTarget = new CustomEvent('certificationvaliditycheker', {
                detail: {
                    currentStep : true
                }
            });
            this.dispatchEvent(eventTarget);
            return;
        }
    
        if(this.isAuthorizationRelease === true){
            this.isClaimantDate = this.handleclaimDateFocus();
            this.isClaimantName = this.handleclaimantNameFocus();
            if(this.isClaimantName === true){
                const validateEvent = new CustomEvent('certificationvaliditycheker', {
                    detail: {
                        currentStep : true
                    }
                });
                this.dispatchEvent(validateEvent);
                return;
            }
        }
        this.getCertificationData();
    }

    @api getCertificationData(){
        const selectEvent = new CustomEvent('certandauthinfoevent', {
            detail: { 
                isAuthorizationRelease : this.isAuthorizationRelease,
                addtionalClaimDocs : this.addtionalClaimDocs,
                isAdditionalClaimDocUpload : this.isAdditionalClaimDocUpload,
                claimantName :  this.claimantName,
                claimDate : this.claimDate,
                additonalClaimDocSize : this.additonalClaimDocSize,
                contentVersionIds : this.contentVersionIds,
                flag : this.flag
             }
       });
        this.dispatchEvent(selectEvent);
    }
@api isFormPreviewMode = false
@api certificationPreviewDetail

    @api
    certAndAuthInfoForChild(strString, isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode
        this.certificationPreviewDetail = strString
        console.log('strString ::: ', JSON.stringify(strString))
        this.isAuthorizationRelease = strString.isAuthorizationRelease
        this.addtionalClaimDocs = strString.addtionalClaimDocs 
        this.isAdditionalClaimDocUpload = strString.isAdditionalClaimDocUpload
        this.claimantName = strString.claimantName
        this.claimDate = strString.claimDate
        this.flag = strString.flag,
        this.contentVersionIds = strString.contentVersionIds
        this.totalUploadFiles = strString.totalUploadFiles === undefined ? [] : strString.totalUploadFiles
        this.isAuthorizationRelease === true ? this.template.querySelector('[data-id="authorizationToReleaseId"]').checked = 'Yes' : ''
        this.isAuthorizationRelease === true ? this.isReadOnlyCheckboxValue = false : this.isReadOnlyCheckboxValue = true;
        this.isRenderedCallback = true
        if(this.isRenderedCallback === true && this.addtionalClaimDocs !== undefined && this.addtionalClaimDocs.length > 0){
            this.template.querySelector('c-owc-Multiple-File-Upload-Details-Cmp').getDocInfos(this.addtionalClaimDocs, this.isFormPreviewMode)
        }
        this.isRenderedCallback = false;
    }

    renderedCallback(){
        
    }

    // @api fileData = []

    // calculateFileSize(files){
    //     let i,j;
  
    //         if(this.fileData.length>0){
    //             console.log('sdsds');
    //                     this.fileData.splice(0,this.fileData.length);
    //                     fileSize = 0;
    //         }
    //         console.log(this.fileData);
    //         for(i=0;i<files.length;i++){
    //                 this.fileData.push(files[i]);
    //         }
    //         console.log(this.fileData);
  
    //         for(j=0;j<parseInt(this.fileData.length);j++){
    //                 fileSize = fileSize+parseInt(JSON.stringify(JSON.parse(this.fileData[j].size)));
    //         }
    //         console.log('????');
    //         console.log(fileSize);
  
    // }
    
    // @api isFileInserted = false;
    // @track flag = 0;
    // handleAdditionalClaimDocChange(event){
    //     this.calculateFileSize(event.target.files);
    //     if(fileSize<MAX_FILE_SIZE){
    //     let files = event.target.files;
    //     for(var i=0; i<files.length; i++){
    //         this.flag += 1;
    //         files[i].recordId = this.flag;
    //     }
    //     this.handleAdditionalClaimDoc(files);
    //     console.log('selecred fiels ::: ',files);
    //     if (files.length > 0) {
    //            let filesName = '';
 
    //            for (let i = 0; i < files.length; i++) {
    //                    let file = files[i];
 
    //                    filesName = filesName + file.name + ',';
 
    //                    var flag=this;
    //                    let freader = new FileReader();
    //                    console.log('freader');
    //                    freader.onload = f => {
                          
    //                        let base64 = 'base64,';
    //                        let content = freader.result.indexOf(base64) + base64.length;
    //                        let fileContents = freader.result.substring(content);    
    //                        flag.filesUploaded.push({
    //                            Title: file.name,
    //                            VersionData: fileContents
    //                        });
    //                    };
    //                    console.log(freader);
    //                    console.log(JSON.stringify(this.filesUploaded));
    //                  //  console.log('check',freader.readAsDataURL(file));
    //                    freader.readAsDataURL(file);
                      
    //            }
              
    //                this.fileNames = filesName.slice(0, -1);
 
    //    }
    //    }
    //    else{
    //        this.showToast('File Size Limit Exceeded','Upload files of size less than 20MB','error');
    //    }
    // }

    // @track contentVersionIds;
    // handleSaveFiles() {
    //     this.showLoadingSpinner = true;
    //     insertUploadedFiles({
    //         uploadedFiles : this.filesUploaded,
    //         contentVersionId : this.contentVersionIds
    //     })
    //     .then(data => {
    //         this.showLoadingSpinner = false;
    //         this.contentVersionIds = data;
    //         this.fileNames = undefined;
    //     })
    //     .catch(error => {
            
    //     });
    // }

    @track contentVersionIds = []
    deleteExtraFiles(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            this.contentVersionIds.push(uploadedFiles[i].documentId);
        }
        deleteMultipleFiles({ contentVersionIds : JSON.stringify(this.contentVersionIds) })
           .then(result => {
               if(result){
                   
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
    }

    @api get isFileUploadDisabled(){
        return this.addtionalClaimDocs !== undefined && this.addtionalClaimDocs.length >= 10 && this.isRenderedCallback === false;
    }

    @api totalUploadFiles = []

    handleFileLimit(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            for(var j=0; j<this.totalUploadFiles.length; j++){
                if(uploadedFiles[i].documentId === this.totalUploadFiles[j].documentId){
                    this.totalUploadFiles.splice(j , 1)
                }
            }
        }
    }

    updateFileVariables(){
        if(this.addtionalClaimDocs !== undefined && this.addtionalClaimDocs.length > 0){
            this.totalUploadFiles.length = 0;
            this.totalUploadFiles = this.addtionalClaimDocs;
        }
    }

    // Multiple file upload component
    handleAdditionalClaimDoc(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        for(var i=0; i<uploadedFiles.length; i++){
            this.totalUploadFiles.push(uploadedFiles[i]);
        }
        if(this.totalUploadFiles.length <= 10){
            this.addtionalClaimDocs = uploadedFiles;
            if(uploadedFiles != null){
                this.isAdditionalClaimDocUpload = false
                this.additonalClaimDocSize = this.addtionalClaimDocs.length
                this.template.querySelector('c-owc-Multiple-File-Upload-Details-Cmp').getDocData(this.addtionalClaimDocs);
                this.isRenderedCallback = false
                this.showToast('Success!',this.toastFileUploadMsg,'success');
            }
            else{
                this.isAdditionalClaimDocUpload = true
            }
        }
        else{
            this.deleteExtraFiles(uploadedFiles);
            this.handleFileLimit(uploadedFiles);
            this.showToast('Error!', this.customLabelValues.OWC_file_size_error,'error');
        }
        
        // alert("No. of files uploaded : " + JSON.stringify(uploadedFiles));
    }

    handleAdditonalClaimDocEvent(event){
        console.log('event.detail:', JSON.stringify(event.detail));
        this.addtionalClaimDocs = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.updateFileVariables();
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.additonalClaimDocSize = this.addtionalClaimDocs.length
    }

    


    handleHelpText(event){
        const learnMoreName = event.target.name
        if(learnMoreName === "multiFileUploadHelpText"){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_multiplefileupload_helptext;
        }
    }

    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        console.log('helpTextValue:', JSON.stringify(helpTextValue));
        this.isHelpText = helpTextValue.isClosedHelpText
    }
}