import { LightningElement,api,track,wire} from 'lwc';
import changedUserLanguage from '@salesforce/apex/OWCContainerController.changedUserLanguage';
import getUserCurrentLanguage from '@salesforce/apex/OWCContainerController.getUserCurrentLanguage';
import getLanguagesData from '@salesforce/apex/OWCContainerController.getLanguagesData';
import userId from '@salesforce/user/Id';
import pubsub from 'c/pubsub' ;
import FORM_FACTOR from '@salesforce/client/formFactor';
import OWC_ChangeLanguage_Label from '@salesforce/label/c.OWC_ChangeLanguage_Label';
import { NavigationMixin } from 'lightning/navigation';
import { radioOptions, customLabelValues, uspsRadioOption } from 'c/owcUtils';

export default class OwcDashboardContainer extends NavigationMixin(LightningElement) {

    customLabelValues = customLabelValues;
    
    @api isLargeDevice = false;
    @api isMediumDevice = false;
    @api isSmallDevice = false;
  
    @api message = false;
    userId = userId
    @api isNotGuestUser = false
    OWC_ChangeLanguage_Label = OWC_ChangeLanguage_Label
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

        switch(FORM_FACTOR) {
            case 'Large':
                this.isLargeDevice = true;
                break;
            case 'Medium':
                this.isMediumDevice = true;
                break;
            case 'Small':
                this.isSmallDevice = true;
                break;
        }

        this.regiser();
        // let message = {
        //     "message" : false
        // }
        // pubsub.fire('customspinnerevent', message );
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

    
    regiser(){
        console.log("event registerd");
        pubsub.register('selectedmenuitem',this.handleEvent.bind(this));
    }

    @api get isBreadCrumbs(){
        return this.isLargeDevice === true || this.isMediumDevice === true
    }

    handleEvent(messageFromEvt){
       
        if(messageFromEvt == 'Dashboard'){
                          window.location.reload();
        }
        else if(messageFromEvt == 'Submitted Claim'){
                    const topDiv = this.template.querySelector('[data-id="submittedClaimLink"]');
                    topDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
        }else if(messageFromEvt == 'Draft Claim'){
                    const topDiv = this.template.querySelector('[data-id="draftclaim"]');
                    topDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
        }else {
                    const topDiv = this.template.querySelector('[data-id="meetingDetail"]');
                    topDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
        }
        
        this.messagepbsb = messageFromEvt;
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

    disconnectedCallback(){
        this.message = false;
    }

//function to navigate to New Online Claim Section
moveToNewClaim(){
    this.message = true;
    this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'new-online-claim',
            },
        });
}




}