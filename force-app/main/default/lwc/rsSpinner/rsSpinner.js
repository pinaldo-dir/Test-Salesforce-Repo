import { LightningElement, track } from 'lwc';
import pubsub from 'c/pubsub' ; 
export default class RsSpinner extends LightningElement {
    @track message = true
    connectedCallback(){
        this.regiser();
    }
    regiser(){
        window.console.log('event registered ');
        pubsub.register('customspinnerevent', this.handleEvent.bind(this));
    }
    handleEvent(messageFromEvt){
        window.console.log('event handled ::: ',messageFromEvt);
        this.message = messageFromEvt.message
    }

    constructor(){
        super()
        this.isSpinner = false
    }
}