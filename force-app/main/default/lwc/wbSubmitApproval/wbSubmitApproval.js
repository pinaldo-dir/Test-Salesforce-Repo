import { LightningElement, api, track, wire } from 'lwc';
import User_Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/WBSubmitApprovalController.getUserInfo';
import getInternalEmployeeInfo from '@salesforce/apex/WBSubmitApprovalController.getInternalEmployeeInfo';
import getWarrantsCaseDetails from '@salesforce/apex/WBSubmitApprovalController.getWarrantsCaseDetails';
import updateWBandWRstatus from '@salesforce/apex/WBSubmitApprovalController.updateWBandWRstatus';


//import User_Name from '@salesforce/schema/User.UserRole.Name';
//import User_Profile_Name from '@salesforce/schema/User.Profile.Name';

//import hasCashiering_Disbursing from '@salesforce/userPermission/Cashiering_Disbursing';
//import hasCashiering_Super_User from '@salesforce/userPermission/Cashiering_Super_User';

export default class WbSubmitApproval extends LightningElement {
    @api getwbid;
    @track wbName = "WB-Name";
    @track cashVerified;
    @track insuffCases;
    @track userAttested = false;
    @track canSubmitChange = true;
    @track userDetails;
    @track allowUserSubmit = false;
    @track strWBlist = 'Test';
    @track todayDate;
    @track pendingUpdated = false;
    @track buttonsDisabled = false;
    @track warrantNotEligible = false;
    @track WBstatus;
    @track WBlink = '<div style="font: bold 16px Arial; margin: 10px 0;">WB Submit for Approval => Succeeded. <br> The link to the Warrant Batch is: </div>';
    @track sfdcBaseURL;

    @wire(getInternalEmployeeInfo,{userId: User_Id}) intEmpData({error,data}){
        if(data){
            console.log("<=== Internal Employee Info: ===> ");
            this.InternalEmpDetails = data;
            console.log(this.InternalEmpDetails);
            for (var m=0; m<this.InternalEmpDetails.length; m++){
                if (this.InternalEmpDetails[m].Name == this.InternalEmpDetails[m].User__r.Name){
                    this.currIntEmpId = this.InternalEmpDetails[m].Id;
                    this.currIntEmpEmailId = this.InternalEmpDetails[m].Email__c;
                }
            }
            console.log(this.currIntEmpId);
        }
    };

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
        console.log(userDetails[2].Assignee.Name);
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
        if ((userPermissionNames.includes("Cashiering_Disbursing"))|| 
            (userProfileName == "System Administrator" || userProfileName == "System Administrator LTD")){
            this.allowUserSubmit = true;
        }
        else{
            this.allowUserSubmit = false;
        }
    }

    @wire (getWarrantsCaseDetails, {apxWbRecId:'$getwbid'})
    warrantsCases({error,data}){
        if(data){
            console.log("Parent to Child ===> "+this.getwbid);
            console.log("@ wire data ==> "+data);
            this.strWBlist = JSON.stringify(data);
            console.log("strWBlist ==> "+this.strWBlist);
            this.wrData = data[0].Warrant__r;
            console.log("@ wire this.wrData ==> ");
            console.log(this.wrData);
            this.checkCashBalanceOnCase(this.wrData);
            if(this.wrData == undefined || this.wrData == null){
                this.errormsg = "There are no Warrants under this Warrant Batch";
            }
        }
        else if(error){
            console.log(error);
            this.errormsg = error;
            console.log("@ wire this.errormsg ==> "+this.errormsg);
        }
    }

    checkCashBalanceOnCase(warrantCaseDetails){
        console.log("108 ********* Check Cash Balance on Case **********");
        console.log(warrantCaseDetails);
        var casesDetail = [];
        var uniqueCasesDetail = [];
        for(var wrIndex in warrantCaseDetails){
            var item = warrantCaseDetails[wrIndex].Case__r;
            casesDetail.push(item);
            uniqueCasesDetail.push(item);
        }
        console.log("117 ***** Array of Cases *****");
        console.log(casesDetail);

        for (var i=0; i<casesDetail.length; i++){
            var caseExist = 0;
            for (var j=0; j<uniqueCasesDetail.length; j++){
                if(casesDetail[i].Id == uniqueCasesDetail[j].Id && caseExist == 0){
                    //console.log("i = j, Increment caseExist");
                    caseExist = caseExist + 1;
                }
                else if(casesDetail[i].Id == uniqueCasesDetail[j].Id && caseExist != 0){
                    //console.log("Delete the uniqueCasesDetail");
                    uniqueCasesDetail.splice(j,1);
                }
            }
        }

        console.log("134 ***** Unique Array of Cases *****");
        console.log(uniqueCasesDetail);
        var wrCanSubmit = [];
        var wrCannotSubmit = [];
        var totalAvailCashBal;

        for (var i=0; i<uniqueCasesDetail.length; i++){
            var caseTotWrAmt = 0.00;
            var WarrantsGroup = [];
            
            for(var j=0; j<warrantCaseDetails.length; j++){
                console.log("caseTotWrAmt");
                console.log(typeof caseTotWrAmt);
                console.log(caseTotWrAmt);
                console.log("148 warrantCaseDetails[j].Amount__c");
                console.log(typeof warrantCaseDetails[j].Amount__c);
                console.log(warrantCaseDetails[j].Amount__c);
                console.log("154: ", warrantCaseDetails[j].Payee__r.Payee_Name__c);
                console.log("155: payee: ", warrantCaseDetails[j].Payee__r.Payee_Name__c + " " + warrantCaseDetails[j].Payee__r.Payee_Type__c);

                
                var eachWRamount = 0.00;
                if(typeof warrantCaseDetails[j].Amount__c == "string"){
                    eachWRamount = Number(Number(warrantCaseDetails[j].Amount__c).toFixed(2));
                }
                else{
                    eachWRamount = warrantCaseDetails[j].Amount__c
                }
                console.log("eachWRamount");
                console.log(typeof eachWRamount);
                console.log(eachWRamount);
                
                if(uniqueCasesDetail[i].Id == warrantCaseDetails[j].Case__r.Id){
                    console.log("167");
                    caseTotWrAmt = caseTotWrAmt + eachWRamount;
                    WarrantsGroup.push(warrantCaseDetails[j]);
                    console.log("170 WarrantsGroup[0]: ", WarrantsGroup[0]);

                }
            }

            //totalAvailCashBal =  Number(parseFloat(uniqueCasesDetail[i].Cash_Balance_on_Case__c).toFixed(2))
            //console.log(totalAvailCashBal);
          
            if(uniqueCasesDetail[i].Warrants_Pending__c != undefined){
                console.log("Not undefined");
                console.log(Number(parseFloat(uniqueCasesDetail[i].Cash_Balance_on_Case__c).toFixed(2)));
                console.log( Number(parseFloat(uniqueCasesDetail[i].Warrants_Pending__c).toFixed(2)));
                totalAvailCashBal =  Number(parseFloat(uniqueCasesDetail[i].Cash_Balance_on_Case__c).toFixed(2)) + caseTotWrAmt -  Number(parseFloat(uniqueCasesDetail[i].Warrants_Pending__c).toFixed(2));
                console.log("totalAvailCashBal");
                console.log(Number(totalAvailCashBal.toFixed(2)));
                console.log(typeof(Number(totalAvailCashBal.toFixed(2))));
                console.log("caseTotWrAmt");
                console.log(Number(caseTotWrAmt.toFixed(2)));
                console.log(typeof(Number(caseTotWrAmt.toFixed(2))));
            }
            else{
                console.log("undefined");
                totalAvailCashBal = Number(parseFloat(uniqueCasesDetail[i].Cash_Balance_on_Case__c).toFixed(2));
                console.log(totalAvailCashBal);
            }
            
            console.log("197 WarrantsGroup[0]: ", WarrantsGroup[0]);
            //If this is a Buyback Warrant, submit for approval regardless of the amount available on the Case
            if(WarrantsGroup[0].Payee__r.Payee_Name__c === 'Department of Industrial Relations' && WarrantsGroup[0].Payee__r.Payee_Type__c === 'Bank'){
                wrCanSubmit.push(WarrantsGroup);
            //otherwise, check available amount on the case
            }else{
                if (Number(totalAvailCashBal.toFixed(2)) >= Number(caseTotWrAmt.toFixed(2))){
                    console.log("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
                    console.log("Cash Balance for below Case")
                    console.log(totalAvailCashBal);
                    console.log("caseTotWrAmount");
                    console.log(caseTotWrAmt);
                    wrCanSubmit.push(WarrantsGroup);
                }else{
                    console.log("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                    console.log("Cash Balance for below Case")
                    console.log(totalAvailCashBal);
                    console.log("caseTotWrAmount");
                    console.log(caseTotWrAmt);
                    wrCannotSubmit.push(WarrantsGroup);
                }
            }
        }
        console.log("Warrants that Can be Submitted");
        console.log(wrCanSubmit);
        console.log("Warrants that Cannot be Submitted");
        console.log(wrCannotSubmit);

        var casesInsuff = [];
        var uniqueCasesInsuff = [];
        if (wrCannotSubmit.length > 0){
            this.cashVerified = false;
            
            for(var k=0; k<wrCannotSubmit.length; k++){
                for(var l=0; l<wrCannotSubmit[k].length; l++){
                    casesInsuff.push(wrCannotSubmit[k][l].Case__r.Name);
                    uniqueCasesInsuff.push(wrCannotSubmit[k][l].Case__r.Name);
                }
            }

            console.log("236 casesInsuff: ", casesInsuff);
            console.log("237 uniqueCasesInsuff: ", uniqueCasesInsuff);

            for (var m=0; m<casesInsuff.length; m++){
                var caseNameExist = 0;
                for (var n=0; n<uniqueCasesInsuff.length; n++){
                    if(casesInsuff[m] == uniqueCasesInsuff[n] && caseNameExist == 0){
                        caseNameExist = caseNameExist + 1;
                    }
                    else if(casesInsuff[m] == uniqueCasesInsuff[n] && caseNameExist != 0){
                        uniqueCasesInsuff.splice(n,1);
                    }
                }
            }
            this.insuffCases = uniqueCasesInsuff.toString();
        }
        else{
            this.cashVerified = true;
        }
        console.log("255 casesInsuff: ", casesInsuff);
        console.log("256 uniqueCasesInsuff: ", uniqueCasesInsuff);

    }

    clickedSubmitButton
    handleUpdSbmtClick(event){
        console.log("259 *********** Update records when Submitted *************");
        this.sfdcBaseURL  = window.location.origin;
        console.log(this.sfdcBaseURL);
        this.buttonsDisabled = true;
        var newDate = new Date();
        this.todayDate = newDate.toLocaleString();
        this.clickedSubmitButton = event.target.label;
        console.log(this.clickedSubmitButton);
        console.log("267 Changing the status of WB & WR goes here");
        if (this.userAttested){
            this.canSubmitChange = true;
            console.log("270 String WB & WR List");
            console.log(this.strWBlist);
            var WBnWRlist = JSON.parse(this.strWBlist);
            console.log("273 Change the status & create a list of WB & WR separately");
            console.log(WBnWRlist);
            WBnWRlist[0].Status__c = 'Pending Approval';
            var apxUpdWBlist = [];
            var updWBlist = new Object();
            updWBlist.Id = WBnWRlist[0].Id;
            updWBlist.Status__c = WBnWRlist[0].Status__c;
            updWBlist.Requesting_Cashier__c = this.currIntEmpId;
            updWBlist.Requesting_Cashier_Attest__c = true;
            updWBlist.Requesting_Cashier_Date__c = this.todayDate;
            apxUpdWBlist.push(updWBlist);
            var apxUpdWRlist = [];
            for (var i=0; i<WBnWRlist[0].Warrant__r.length; i++){
                if(WBnWRlist[0].Warrant__r[i].Status__c == "New"){
                    WBnWRlist[0].Warrant__r[i].Status__c = "Pending Approval";
                    WBnWRlist[0].Warrant__r[i].Status_Date__c = this.todayDate;
                    apxUpdWRlist.push(WBnWRlist[0].Warrant__r[i]);
                }
            }
            console.log("292 Updated WB List");
            console.log(apxUpdWBlist);
            console.log("294 Updated WR List");
            console.log(apxUpdWRlist);

            var emailWB = this.sfdcBaseURL + '/' + WBnWRlist[0].Id + '\r\n';
            this.WBlink = this.WBlink + emailWB;

            if(apxUpdWRlist.length > 0){
                updateWBandWRstatus({wbForUpdate: apxUpdWBlist, wrForUpdate: apxUpdWRlist, wbLink: this.WBlink})
                .then(result =>{
                    console.log("303 Result");
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
            else{
                this.warrantNotEligible = true;
            }
        }
        else{
            this.canSubmitChange = false;
        } 
        
    }

    WBstatus
    handleUserAttestWB(event){
        this.WBstatus = event.target.checked;
        if(this.WBstatus){
            this.userAttested = true;
            this.buttonsDisabled = false;
            this.canSubmitChange = true;
        }
        else{
            this.userAttested = false;
        }
        console.log(this.WBstatus);
        
    }
    /*
    get isUserEligible(){
        return hasCashiering_Disbursing;
    }
    */

}