import { LightningElement,api } from 'lwc';

export default class SmsDetails extends LightningElement {
    @api sms;
    
    get smsClass(){
        return this.sms.sms.smagicinteract__Direction__c == 'OUT'?'outMessage':'inMessage';
    }

    get message(){
        return this.sms.sms.smagicinteract__SMSText__c;
    }

    get sentDate(){
        return this.sms.sms.CreatedDate;
    }
}