import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader'  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet'  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityBasePath from '@salesforce/community/basePath';
import pubsub from 'c/pubsub' ;
import { customLabelValues } from 'c/owcUtils';
import getDraftRecords from '@salesforce/apex/OnlineWageClaimDraftController.getDraftRecords';
export default class OnlineWageClaimDraftCmp extends LightningElement {
    @api message = false;
    @api isSpinner = false;
    @api draftRecords
    @api isDraftRecord = false

    // Import custom labels
    customLabelValues = customLabelValues
    communityBasePath = communityBasePath

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
        getDraftRecords({
            
        })
           .then(result => {
               if(result){
                    console.log(result);
                    this.draftRecords = result
                    // var options = { year: 'numeric', month: 'numeric', day: 'numeric' };
                    // //let startDate = new Date(this.draftRecords.lastModifiedDate).toLocaleString("en-US",options);
                    // for(var i=0; i<this.draftRecords.length; i++){
                    //     this.draftRecords.lastModifiedDate = new Date(this.draftRecords.lastModifiedDate).toLocaleString("en-US",options);
                    // }
                    if(this.draftRecords.length > 0){
                        this.isDraftRecord = true;
                    }
               }
           })
           .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
               console.log('Error: ', error);
           })
           
    }

    handleOWCForm(event){
        var recordId = event.currentTarget.getAttribute('name')
        console.log('recordId ::: '+this.communityBasePath)
        var url = this.communityBasePath + '/new-online-claim?recordId=' + recordId;
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