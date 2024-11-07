import { LightningElement,api } from 'lwc';

export default class MeetingParticipantSms extends LightningElement {
    @api details; 
    @api caseRoleDetails;
    @api objKey;

    get participants(){
        return this.details && Object.keys(this.details).length>0 && (Object.keys(this.details)).indexOf(this.objKey)!==-1? Object.keys(this.details[this.objKey]):[];
    }

    get showCaseRoleSMS(){
        return this.caseRoleDetails[this.objKey] != undefined && this.caseRoleDetails[this.objKey].length >0;
    }

    get messages(){
        return this.caseRoleDetails[this.objKey];
    }
}