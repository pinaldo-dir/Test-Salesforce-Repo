import { LightningElement, api, track, wire} from 'lwc';
import User_Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/WBVoidController.getUserInfo';
import getWarrantsCaseDetails from '@salesforce/apex/WBVoidController.getWarrantsCaseDetails';
import updateWBandWRstatus from '@salesforce/apex/WBVoidController.updateWBandWRstatus';
//import updatePendCashBalOnCase from '@salesforce/apex/WBVoidController.updatePendCashBalOnCase';

export default class WbVoid extends LightningElement {
    @api getwbid;
    //@track wbDetails;
    @api voidReason;
    @track userDetails;
    @track strWBlist = 'Test';
    @track allowUserVoid;
    @track reasonEntered = true;
    @track pendingUpdated = false;
    @track buttonsDisabled = false;
    @track WBlink = '<div style="font: bold 16px Arial; margin: 10px 0;">Warrant Batch => Void Batch Successful <br> The link to the Warrant Batch is: </div>';
    @track sfdcBaseURL;

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
        if (userPermissionNames.includes("Cashiering_Disbursing") || userPermissionNames.includes("Warrant_Batch_Approver") || 
            userProfileName == "System Administrator" || userProfileName == "System Administrator LTD"){
            this.allowUserVoid = true;
        }
        else{
            this.allowUserVoid = false;
        }
    }

    @wire (getWarrantsCaseDetails, {apxWbRecId:'$getwbid'})
    warrantsCases({error,data}){
        if(data){
            console.log("Parent to Child ===> "+this.getwbid);
            console.log("@ wire data ==> "+data);
            this.strWBlist = JSON.stringify(data);
            console.log("strWBlist ==> "+this.strWBlist)
            //this.wbDetails = data[0];
            //console.log(this.wbDetails);
            //if(this.wbDetails == undefined || this.wbDetails == null){
             //   this.errormsg = "There is no Warrants under this Warrant Batch";
            //}
        }
        else if(error){
            console.log(error);
            this.errormsg = error;
            console.log("@ wire this.errormsg ==> "+this.errormsg);
        }
    }

    handleReasonChange(event){
        this.voidReason = event.target.value;
    }

    handleVoidSbmtClick(event){
        console.log("handleVoidSbmtClick");
        this.buttonsDisabled = true;
        if(this.voidReason==undefined || this.voidReason==null || this.voidReason==''){
            this.reasonEntered = false;
            this.buttonsDisabled = false;
        }
        else{
            this.reasonEntered = true;
            console.log(this.voidReason);
            var WbWrPrList = JSON.parse(this.strWBlist);
            console.log(WbWrPrList);
            var WBlist = WbWrPrList[0].warrantBatch[0];
            var WRlist = WbWrPrList[0].warrantList;
            var PRlist = WbWrPrList[0].paymentRecList;
            console.log(WBlist);
            console.log(WRlist);
            console.log(PRlist);

            console.log("Change the status & create a list of WB separately");
            console.log(WBlist);
            var apxUpdWBlist = [];
            var updWBlist = new Object();
            updWBlist.Id = WBlist.Id;
            updWBlist.Status__c = "Void";
            updWBlist.Void_Reason__c =  this.voidReason;
            apxUpdWBlist.push(updWBlist);
           
            console.log("Change the status & create a list of WR separately");
            console.log(WRlist);
            var apxUpdWRlist = [];
            var caseIds = [];
            var updCaselist = new Object();
            var newDate = new Date();
            this.todayDate = newDate.toLocaleString();
            for (var i=0; i<WRlist.length; i++){
                if(WRlist[i].Status__c == "Printed"){
                    console.log("Warrants has been Printed");
                    WRlist[i].Status__c = "Voided";
                    WRlist[i].Status_Comment__c = "Warrant batch void";
                    WRlist[i].Status_Date__c = this.todayDate;
                    //WRlist[i].Payee__c = null; //Payee should be there on voided/stopped/cancelled warrants for audit purpose.
                    apxUpdWRlist.push(WRlist[i]);
                }
                else{
                    console.log("Warrants has not been Printed");
                    WRlist[i].Status__c = "Voided";
                    WRlist[i].Status_Comment__c = "Warrant batch void";
                    WRlist[i].Status_Date__c = this.todayDate;
                    //WRlist[i].Payee__c = null; //Payee should be there on voided/stopped/cancelled warrants for audit purpose.
                    apxUpdWRlist.push(WRlist[i]);
                }
                //Get the case list
                //caseIds.push(WRlist[i].Case__c);
            }

            console.log("Change the status & create a list of PR separately");
            console.log(PRlist);
            var apxUpdPRlist = [];
            for (var j=0; j<PRlist.length; j++){
                PRlist[j].Warrant_Issued__c = false;
                PRlist[j].Batched_Under_Warrant__c = false;
                PRlist[j].Warrant__c = null;
                PRlist[j].Secondary_Payee__c = null;
                apxUpdPRlist.push(PRlist[j]);
            }

            console.log("Updated WB List");
            console.log(apxUpdWBlist);
            console.log("Updated WR List");
            console.log(apxUpdWRlist);
            console.log("Updated PR List");
            console.log(apxUpdPRlist);
            //console.log("Updated Case List");
            //console.log(apxUpdCMlist);

            this.sfdcBaseURL  = window.location.origin;
            var emailWB = this.sfdcBaseURL + '/' + apxUpdWBlist[0].Id + '\r\n';
            this.WBlink = this.WBlink + emailWB;
            console.log(this.WBlink);

            //Update the Warrant Batch & Warrants & Payment Records object
            updateWBandWRstatus({wbForUpdate: apxUpdWBlist, wrForUpdate: apxUpdWRlist, prForUpdate: apxUpdPRlist, wbLink: this.WBlink})
            .then(result =>{
                console.log("Result");
                console.log(result);
                if(result){
                    this.pendingUpdated = true;
                }
                else{
                    this.pendingUpdated = false;
                }
            })
            .catch(error =>{
                console.log("Error");
            })


            
        }
        
    }
}