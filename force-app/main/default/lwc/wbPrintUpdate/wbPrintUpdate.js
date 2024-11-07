import { LightningElement, api, track, wire} from 'lwc';
import User_Id from '@salesforce/user/Id';
import LOCALE from '@salesforce/i18n/locale';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import getUserInfo from '@salesforce/apex/WBPrintUpdateController.getUserInfo';
import getWarrantsDetails from '@salesforce/apex/WBPrintUpdateController.getWarrantsCaseDetails';
import updateWBandWRstatus from '@salesforce/apex/WBPrintUpdateController.updateWBandWRstatus';

export default class WbPrintUpdate extends LightningElement{
    @api getwbid;
    @api voidReason;
    @track userDetails;
    @track wrDetails;
    @track wbDetails;
    @track prDetails;

    @track strWBlist = 'Test';
    @track allowUserPrint;
    @track wrReadytoPrint;

    @track reasonEntered = true;
    @track warrantsPrinted = false;
    @track warrantsNotPrinted = false;
    @track printStatusUpdated = false;
    @track printStatusNotUpdated = false;
    @track buttonsDisabled = true;
    @track WBlink = '<div style="font: bold 16px Arial; margin: 10px 0;">Warrant Batch => Updated to Printed <br> The link to the Warrant Batch is: </div>';
    @track sfdcBaseURL;

    value = '';
    get options() {
        return [
            { label: 'Yes', value: 'true' },
            { label: 'No', value: 'false' }
        ];
    }

    @wire(getUserInfo,{userId: User_Id}) userData({error,data}){
        if(data){
            console.log("User Info: ===> ");
            this.userDetails = data;
            console.log(this.userDetails);
            this.checkUserPermission(this.userDetails);
           
        }
    };
    
    checkUserPermission(userDetails){
        console.log("********* Check User Permissions ***********");
        console.log(userDetails[0].Assignee.Name);
        var userProfileName;
        var userPermissionNames = [];
        for (var i=0; i<userDetails.length; i++){
            if (userDetails[i].PermissionSet.hasOwnProperty("Profile")){
                userProfileName = userDetails[i].PermissionSet.Profile.Name;
            }
            else{
                userPermissionNames.push(userDetails[i].PermissionSet.Name);
            }

        }
        console.log("Profile ============ ");
        console.log(userProfileName);
        console.log("Permissions ============ ");
        console.log(userPermissionNames);
        if (userPermissionNames.includes("Cashiering_Disbursing") || userProfileName == "System Administrator" || userProfileName == "System Administrator LTD"){
            this.allowUserPrint = true;
        }
        else{
            this.allowUserPrint = false;
        }
    }

    @wire (getWarrantsDetails, {apxWbRecId:'$getwbid'})
    warrantsCases({error,data}){
        if(data){
            console.log("Parent to Child ===> "+this.recordId);
            console.log("@ wire data ==> "+data);
            this.strWBlist = JSON.stringify(data);
            //console.log("strWBlist ==> "+this.strWBlist)
            this.wbDetails = data[0].warrantBatch[0];
            console.log("wbDetails ==> ");
            console.log(this.wbDetails);
            this.wrDetails = data[0].warrantList;
            console.log("wrDetails ==> ");
            console.log(this.wrDetails);
            this.prDetails = data[0].paymentRecList;
            console.log("prDetails ==> ");
            console.log(this.prDetails);
            this.checkWarrantStatustoPrint();
        }
        else if(error){
            console.log(error);
            this.errormsg = error;
            console.log("@ wire this.errormsg ==> "+this.errormsg);
        }
    }

    checkWarrantStatustoPrint(){
        console.log("=========== Inside checkWarrantStatustoPrint ===========");
        this.wrListtoUpdPrint = [];
        //Check if there are warrants pending for Approval
        console.log("Check if there are warrants Approved");
        if(this.wrDetails.length == 0){
            this.wrReadytoPrint = false;
        }
        else{
            for (var i=0; i<this.wrDetails.length; i++){
                if(this.wrDetails[i].Status__c == "Approved"){
                    this.wrListtoUpdPrint.push(this.wrDetails[i]);
                }
            }
            this.wrListtoUpdPrint = JSON.parse(JSON.stringify(this.wrListtoUpdPrint));
            console.log(this.wrListtoUpdPrint);
            if(this.wrListtoUpdPrint.length == 0){
                this.wrReadytoPrint = false;
            }
            else{
                this.wrReadytoPrint = true;
            }
        }
    }

    handlePrintRadioBtn(event){
        if(event.target.value == "true"){
            this.buttonsDisabled = false;
            this.warrantsPrinted = true;
            this.warrantsNotPrinted = false;
        }
        else{
            this.buttonsDisabled = true;
            this.warrantsNotPrinted = true;
            this.warrantsPrinted = false;
        }

    }

    updateWRStatusPrint(){
        console.log("=========== Inside updateWRStatusPrint ===========");
        this.buttonsDisabled = true;
        console.log("WB that needs to be updated");
        var apxUpdWBlist = [];
        console.log(this.wbDetails);
        var updWBlist = new Object();
        updWBlist.Id = this.wbDetails.Id;
        updWBlist.Status__c = "Printed";
        apxUpdWBlist.push(updWBlist);
        console.log("List of warrants that needs to be updated");
        var apxUpdWRlist = [];

        /*
        let dateTime= new Date().toUTCString(this.locale,{timeZone:this.timeZone});
        console.log("dateTime");
        console.log(dateTime);

        var localDate = new Date();
        console.log("localDate");
        console.log(localDate);
        var timezone = localDate.getTimezoneOffset();
        console.log("timezone"); 
        console.log(timezone);
        */

        var newDate = new Date();
        this.todayDate = newDate.toLocaleString();
        console.log("this.todayDate");
        console.log(this.todayDate);
        console.log(this.wrListtoUpdPrint);
        for(let k=0; k<this.wrListtoUpdPrint.length; k++){
            this.wrListtoUpdPrint[k].Status__c = "Printed";
            this.wrListtoUpdPrint[k].Status_Date__c = this.todayDate;
            this.wrListtoUpdPrint[k].Issue_Date__c = this.todayDate;
            apxUpdWRlist.push(this.wrListtoUpdPrint[k]);
        }

        console.log("List of Payment Records that needs to be updated");
        this.prListtoUpdWRissued = JSON.parse(JSON.stringify(this.prDetails));
        var apxUpdPRlist = [];
        for(let l=0; l<this.wrListtoUpdPrint.length; l++){
            for(let m=0; m<this.prListtoUpdWRissued.length; m++){
                if(this.wrListtoUpdPrint[l].Id == this.prListtoUpdWRissued[m].Warrant__r.Id){
                    console.log(this.prListtoUpdWRissued[m]);
                    this.prListtoUpdWRissued[m].Warrant_Issued__c = true;
                    apxUpdPRlist.push(this.prListtoUpdWRissued[m]);
                }
            }
        }


        console.log("Updated WB List");
        console.log(apxUpdWBlist);
        console.log("Updated WR List");
        console.log(apxUpdWRlist);
        console.log("Updated PR List");
        console.log(apxUpdPRlist);

        this.sfdcBaseURL  = window.location.origin;
        var emailWB = this.sfdcBaseURL + '/' + apxUpdWBlist[0].Id + '\r\n';
        this.WBlink = this.WBlink + emailWB;
        console.log(this.WBlink);

        
        updateWBandWRstatus({wbForUpdate: apxUpdWBlist, wrForUpdate: apxUpdWRlist, prForUpdate: apxUpdPRlist, wbLink: this.WBlink})
        .then(result =>{
            console.log("Result");
            console.log(result);
            if(result){
                this.printStatusUpdated = true;
            }
            else{
                this.printStatusNotUpdated = true;
            }
        })
        .catch(error =>{
            console.log("Error");
        })
        
    }
}