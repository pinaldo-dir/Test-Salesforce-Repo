import { LightningElement, api, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader'  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet'  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityBasePath from '@salesforce/community/basePath';
import pubsub from 'c/pubsub' ;

import OWC_submitted_claim_label from '@salesforce/label/c.OWC_submitted_claim_label';
import owc_Case_Number from '@salesforce/label/c.owc_Case_Number';
import OWC_pdf_link from '@salesforce/label/c.OWC_pdf_link';
import OWC_no_record_error from '@salesforce/label/c.OWC_no_record_error';
import OWC_claim_summary from '@salesforce/label/c.OWC_claim_summary';
import OWC_claimant_name_label from '@salesforce/label/c.OWC_claimant_name_label';
import OWC_employer_name_label from '@salesforce/label/c.OWC_employer_name_label';
import OWC_submitted_date from '@salesforce/label/c.OWC_submitted_date';
import OWC_status_label from '@salesforce/label/c.OWC_status_label';
import OWC_case_status1 from '@salesforce/label/c.OWC_case_status1';
import OWC_case_name from '@salesforce/label/c.OWC_case_name';
import OWC_case_details_label from '@salesforce/label/c.OWC_case_details_label';
import OWC_assigned_deputy from '@salesforce/label/c.OWC_assigned_deputy';
import OWC_office_address from '@salesforce/label/c.OWC_office_address';
import OWC_case_closed_label from '@salesforce/label/c.OWC_case_closed_label';
import getSubmittedCaseRecords from '@salesforce/apex/OWCCaseManagementController.getSubmittedCaseRecords';
import getCaseDetails from '@salesforce/apex/OWCCaseManagementController.getCaseDetails';
export default class OWCSubmittedCaseManagementCmp extends LightningElement {
    @api message = false;
    @api isPopUp = false
    @api isSpinner = false;
    @api submittedCaseRecords
    @api isSubmittedRecord = false
    @api caseDetail;
    communityBasePath = communityBasePath

    customLabelValues = {
        OWC_case_closed_label,
        OWC_submitted_claim_label,
        owc_Case_Number,
        OWC_case_status1,
        OWC_case_name,
        OWC_case_details_label,
        OWC_office_address,
        OWC_assigned_deputy,
        OWC_claim_summary,
        OWC_pdf_link,
        OWC_no_record_error,
        OWC_claimant_name_label,
        OWC_employer_name_label,
        OWC_submitted_date,
        OWC_status_label
    }

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
                    //this.submittedCaseRecords = result
                    if(result.length > 0){
                        this.isSubmittedRecord = true;
                        const data = [...result].map(record=>{
                    
                            console.log(record.CreatedDate);
                            return {
                                ...record
                                //mdt: startDate+' '+record.Meeting_Start_Time__c
                            }
                        });
                        this.submittedCaseRecords = data;
                    }
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
           
    }
    handlePopUp(event){
        const recordId = event.target.name;
        getCaseDetails({
            recordId : recordId
        })
           .then(result => {
               if(result){
                    console.log('result :::: ', JSON.stringify(result));
                    this.caseDetail = result;
                    this.isPopUp = true;
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
    closeModal(event){
        
        this.isPopUp = false;
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