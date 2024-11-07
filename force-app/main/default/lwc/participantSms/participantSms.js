import { LightningElement,api } from 'lwc';

export default class ParticipantSms extends LightningElement {
    @api details;
    @api meetingId;
    @api participantId;

    get messages(){
        return this.details[this.meetingId][this.participantId];
    }
}