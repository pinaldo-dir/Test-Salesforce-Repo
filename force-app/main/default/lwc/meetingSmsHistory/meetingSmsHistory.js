import { LightningElement,api,track } from 'lwc';
import getSMSDetails from '@salesforce/apex/SMSHistoryController.getSMSDetails';
export default class MeetingSmsHistory extends LightningElement {
    @api recordId;

    @track details;
    @track caseRoleDetails;
    isRendered = false;
    activeSection = 'A';
    isLoaded = false;
    showCmp = false;
    connectedCallback(){
        getSMSDetails({recordId:this.recordId})
        .then(response=>{
            console.log(JSON.parse(JSON.stringify(response)));
            this.details = response.records;
            this.caseRoleDetails = response.caseRoleSMS;
            if((response.records != undefined && Object.keys(response.records).length>0) || (response.caseRoleSMS!=undefined && Object.keys(response.caseRoleSMS).length>0)){
                this.showCmp = true;
            }
            
            this.isLoaded = true;
        })
        .catch(errors=>{
            console.log(JSON.parse(JSON.stringify(errors)));
            this.isLoaded = true;
        })
    }

    get meetings(){
				console.log(JSON.parse(JSON.stringify(this.details)));
				console.log(JSON.parse(JSON.stringify(this.caseRoleDetails)));
				let allMeetings = [];
				
				if(this.details!= undefined && Object.keys(this.details).length>0){
						Object.keys(this.details).forEach(meeting=>{
								if(allMeetings.indexOf(meeting)=== -1){
									allMeetings.push(meeting);		
								}
						})
				}
				if(this.caseRoleDetails!= undefined && Object.keys(this.caseRoleDetails).length>0){
						Object.keys(this.caseRoleDetails).forEach(meeting=>{
								if(allMeetings.indexOf(meeting)=== -1){
									allMeetings.push(meeting);		
								}
						}) 
				} 
				console.log('allMeetings',JSON.parse(JSON.stringify(allMeetings)));
        return allMeetings;
    }

    renderedCallback(){
        if(!this.isRendered){
            this.isRendered = true;
            const style = document.createElement('style');
            style.innerText = `.slds-is-open>.slds-accordion__content {
                overflow: visible;
                visibility: visible;
                opacity: 1;
                height: auto;
                border: 1px solid;
                padding: 8px;
            }`;
            this.template.querySelector('.styleContainer').appendChild(style);
        }
    }

    
}