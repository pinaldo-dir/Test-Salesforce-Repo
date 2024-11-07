import { LightningElement, api, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader'  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet'  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityBasePath from '@salesforce/community/basePath';
import pubsub from 'c/pubsub' ;
import { customLabelValues } from 'c/owcUtils';
import getSubmittedCaseRecords from '@salesforce/apex/OWCCaseManagementController.getSubmittedCaseRecords';
export default class OWCSubmittedCaseManagementCmp extends LightningElement {
    @api message = false;
    @api isSpinner = false;
    @api submittedCaseRecords
    @api isSubmittedRecord = false

    communityBasePath = communityBasePath

    // Import Custom Lables values
    customLabelValues = customLabelValues

    // ConnectedCallback call on page load
    connectedCallback(){
        // Use 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {})
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error')    
        })
        let message = {
            "message" : false
        }
        pubsub.fire('spinnerevent', message );
        getSubmittedCaseRecords({
            
        })
           .then(result => {
               if(result){
                    console.log('result :::: ', JSON.stringify(result));
                    this.submittedCaseRecords = result
                    if(this.submittedCaseRecords.length > 0){
                        this.isSubmittedRecord = true;
                    }
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
           
    }

    handleCaseManagement(event){
        var recordId = event.currentTarget.getAttribute('name')
        console.log('recordId ::: '+this.communityBasePath)
        var url = this.communityBasePath + '/submitted-claim' + '?recordId=' + recordId;
        window.open(url,'_self');
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