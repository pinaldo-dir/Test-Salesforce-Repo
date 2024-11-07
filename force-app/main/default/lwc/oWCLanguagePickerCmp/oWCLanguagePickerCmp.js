import { LightningElement, api, wire } from 'lwc';
import changedUserLanguage from '@salesforce/apex/OWCContainerController.changedUserLanguage';
import getUserCurrentLanguage from '@salesforce/apex/OWCContainerController.getUserCurrentLanguage';
import getLanguagesData from '@salesforce/apex/OWCContainerController.getLanguagesData';
import userId from '@salesforce/user/Id';
import pubsub from 'c/pubsub' ;
import OWC_ChangeLanguage_Label from '@salesforce/label/c.OWC_ChangeLanguage_Label';

export default class OWCLanguagePickerCmp extends LightningElement {

    userId = userId
    @api isNotGuestUser = false
    OWC_ChangeLanguage_Label = `${OWC_ChangeLanguage_Label} English/Spanish`
    selectedLanguage
    languagesOptions = [];
    @api isRenderedCallback = false
    
    @wire(getLanguagesData,{})
    getLanguagesData({ error, data }) {
        if (data) {
            this.languagesOptions = data
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }

    connectedCallback(){
        let message = {
            "message" : false
        }
        pubsub.fire('spinnerevent', message );
        if(this.userId != null){
            this.isNotGuestUser = true;
        }
        getUserCurrentLanguage({})
           .then(result => {
               if(result){
                   if(result === 'es'){
                       console.log('result:', result);
                       this.template.querySelector('[data-id="communityLanguage"]').value = 'Spanish';
                   }
                   else if(result === 'en_US'){
                       this.template.querySelector('[data-id="communityLanguage"]').value = 'English';
                   }
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
    }

    // renderedCallback(){
    //     if(this.isRenderedCallback === true && this.template.querySelector('[data-id="communityLanguage"]').value == 'Spanish'){
    //         const currentCommunityUrl = window.location.href
    //         const communityUrl = currentCommunityUrl.substring(0, currentCommunityUrl.indexOf('?')) + '?language=es'
    //         console.log('communityUrl:', communityUrl);
    //         window.open(communityUrl,'_self');
    //         this.isRenderedCallback = false
    //        }
    //     if(this.isRenderedCallback === true && this.template.querySelector('[data-id="communityLanguage"]').value == 'English'){
    //         const currentCommunityUrl = window.location.href
    //         const communityUrl = currentCommunityUrl.substring(0, currentCommunityUrl.indexOf('?')) + '?language=en_US'
    //         console.log('communityUrl:', communityUrl);
    //         window.open(communityUrl,'_self');
    //         this.isRenderedCallback = false
    //        }
           
    // }

    get langOptions() {
        return [
            { label: 'English', value: 'English' },
            { label: 'Spanish', value: 'Spanish' }
        ];
    }


    handleLanguageChange(event){
        this.isRenderedCallback = true
        const lang = event.detail.value;
        if(lang === 'Spanish'){
            this.selectedLanguage = 'es'
        }
        else if(lang === 'English'){
            this.selectedLanguage = 'en_US'
        }
        window.console.log('Event Fired ');
            changedUserLanguage({
                selectedLanguage : this.selectedLanguage,
                communityId : this.communityId
            })
               .then(result => {
                   if(result){
                        const currentCommunityUrl = window.location.href
                        const communityUrl = currentCommunityUrl.substring(0, currentCommunityUrl.indexOf('?')) + '?language=en_US'
                        console.log('communityUrl:', communityUrl);
                        window.open(communityUrl,'_self');
                   }
               })
               .catch(error => {
                   console.log('Error: ', error);
               })
            
    }
}