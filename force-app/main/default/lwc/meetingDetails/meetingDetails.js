import { LightningElement,track,api } from 'lwc';
import owc_Case_Number from '@salesforce/label/c.owc_Case_Number';
import OWC_Meeting from '@salesforce/label/c.OWC_Meeting';
import OWC_Type from '@salesforce/label/c.OWC_Type';
import OWC_case_status_label from '@salesforce/label/c.OWC_case_status_label';
import OWC_date_time from '@salesforce/label/c.OWC_date_time';
import getMeetingDetails from '@salesforce/apex/MeetingDetailsController.getMeetingDetails';
import { radioOptions, customLabelValues } from 'c/owcUtils';

const actions = [
    { label: 'Show details', name: 'show_details' }
];
const columns = [owc_Case_Number,OWC_Meeting,OWC_date_time,OWC_Type, OWC_case_status_label];
    
export default class MeetingDetails extends LightningElement {

    customLabelValues = {
        owc_Case_Number,
        OWC_Meeting,
        OWC_Type,
        OWC_case_status_label,
        OWC_date_time
    }

    // Import custom labels
    customLabelValues = customLabelValues
    @track meetings = [];
    @track currentMeeting = {};
    isRendered = false;
    columns = columns;
    showModal = false;
    @api meetingId;
    @api passCode;
    @api meetings = [];
    @api videoURL;
    connectedCallback(){
        getMeetingDetails()
        .then(response=>{
            
            if(response.records != undefined){
                const data = [...response.records].map(record=>{
                    var options = { year: 'numeric', month: 'numeric', day: 'numeric' };
                    let startDate = new Date(record.Meeting_Start_Date__c).toLocaleString("en-US",options);
                    return {
                        ...record,
                        audioTelePhone: Boolean(record.Audio_telephone__c) ? record.Audio_telephone__c : '',
                        videoURL: Boolean(record.Video_Meeting_URL__c) ? record.Video_Meeting_URL__c : '',
                        meetingInfo: Boolean(record.Video_Meeting_Information__c) ? record.Video_Meeting_Information__c : '',
                        caseName: record.Case__c!= undefined?record.Case__r.Case_Number__c:'',
                        rtName: record.RecordType.Name,
                        location: record.WCA_Office__r!=undefined?record.WCA_Office__r.Office_Address_Formula__c:'',
                        mdt: record.Calendar_Date_Time_Start__c.indexOf('-') >0? startDate+' '+record.Meeting_Start_Time_OC__c : record.Calendar_Date_Time_Start__c
                    }
                });
                this.meetings = data;
                console.log('Meetings ::: ::: ', JSON.stringify(this.meetings));
            }else{
                // SOME TOAST MESSAGE HERE
            }
        })
        .catch(errors=>{

        })
    }

    handleClick = event =>{
        const recordId = event.target.name;
        this.meetings.forEach(meeting=>{
            if(meeting.Id === recordId){
                this.currentMeeting = meeting;        
            }
        })
        
        this.showModal = true;

    }

    handleClose = event =>{
        this.showModal = false;
    }

    renderedCallback(){
        if(!this.isRendered){
            this.isRendered = true;
            const style = document.createElement('style');
            style.innerText = `.slds-table thead th{
                color: #000 !important;
            }`;
            this.template.querySelector('.styleContainer').appendChild(style);
        }
    }

    // handleSendSMS(){
    //     sendSMS()
    //     .then(response=>{
    //         console.log(response);
    //     })
    //     .catch(errors=>{
    //         console.log(errors);
    //     })
    // }
}