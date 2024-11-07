import { LightningElement,api } from 'lwc';

export default class OwcCustomOutputField extends LightningElement {
    @api label;
    @api value;
    @api video;
    @api videourl;
    @api meetinginfo;

    connectedCallback(){
        console.log('meetinginfo ::: ',this.meetinginfo);
        console.log('passcode ::: ',this.passcode);
    }
}