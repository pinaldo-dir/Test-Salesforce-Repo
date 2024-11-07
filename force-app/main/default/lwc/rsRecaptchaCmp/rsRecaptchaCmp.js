import { LightningElement, track,api,wire } from 'lwc';
import verifyRecaptcha from '@salesforce/apex/RsCommunitySelfRegisterCtrl.verifyCaptcha';

export default class RsRecaptchaCmp extends LightningElement {
    @api publickey;
    //@api isRecaptchaSuccess = false;
    connectedCallback() {
        console.log('child adadad');
        var helper = this;
        document.addEventListener("grecaptchaVerified", function(e) {
            verifyRecaptcha({//TODO: map UI fields to sobject
                recaptchaResponse: e.detail.response})
                .then(result => {
                    
                    //document.dispatchEvent(new Event("grecaptchaReset"));
                    if(result.includes('Success')){
                        console.log('::in:',result);
                        const custEvent = new CustomEvent(
                            'callpasstoparent', {
                                detail: true
                            });
                        helper.dispatchEvent(custEvent);
                    } else{
                       const custEvent = new CustomEvent(
                        'callpasstoparent', {
                            detail: false 
                        });
                        helper.dispatchEvent(custEvent);
                    }
                    console.log('result',result);
                   // alert(result);
                })
                .catch(error => {
                    console.log('error',error);
                });
        });
    }
    
    renderedCallback() {
        console.log('rendered entry',this.isRecaptchaSuccess );
        var divElement = this.template.querySelector('div.recaptchaCheckbox');
        //valide values for badge: bottomright bottomleft inline
        var payload = {element: divElement, badge: 'bottomright'};
        document.dispatchEvent(new CustomEvent("grecaptchaRender", {"detail": payload}));
        console.log('rendered value',this.isRecaptchaSuccess );
    }

    doSubmit(event){
        console.log('child do submit');
        const custEvent = new CustomEvent(
            'callpasstoparent', {
                detail: true
            });
        this.dispatchEvent(custEvent);

    }
}