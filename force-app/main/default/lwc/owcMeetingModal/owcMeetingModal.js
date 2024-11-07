import { LightningElement,api} from 'lwc';

export default class LwcModalPopup extends LightningElement {
    @api meetingDetails;
    @api videoUrl;
    @api meetingInfo;

    connectedCallback(){
        console.log('Meeting detils ::: ', JSON.stringify(this.meetingDetails));
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    get isInPerson(){
        return this.meetingDetails.In_Person_Remote_Meeting__c == 'In Person';
    }

    get isVideoMeeting(){
        return this.meetingDetails.In_Person_Remote_Meeting__c == 'Video';
    }

    get isAudioTelePhone(){
        return this.meetingDetails.In_Person_Remote_Meeting__c == 'Phone/Remote';
    }

    get meetingStartDate(){
        var options = { year: 'numeric', month: 'numeric', day: 'numeric' };
        let startDate = new Date(this.meetingDetails.Meeting_Start_Date__c).toLocaleString("en-US",options);
        return startDate+' '+this.meetingDetails.Meeting_Start_Time__c;
    }
}