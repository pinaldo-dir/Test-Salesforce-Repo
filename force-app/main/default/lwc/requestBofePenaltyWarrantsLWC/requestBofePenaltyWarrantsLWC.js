import { LightningElement, api, track, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import User_Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/RequestBofePenaltyWarrantController.getUserInfo';
import getInternalEmployeeInfo from '@salesforce/apex/RequestBofePenaltyWarrantController.getInternalEmployeeInfo';
import getPayeeDetails from '@salesforce/apex/RequestBofePenaltyWarrantController.getPayeeDetails';
import insertWB from '@salesforce/apex/RequestBofePenaltyWarrantController.insertWarrantBatch';
import insertWrsUpdatePrs from '@salesforce/apex/RequestBofePenaltyWarrantController.insertWrsUpdatePrs';
import sendEmailToController from '@salesforce/apex/RequestBofePenaltyWarrantController.sendEmailToController';
import oaOwnerId from '@salesforce/apex/RequestBofePenaltyWarrantController.getOAowner';
import getCaseDetails from '@salesforce/apex/RequestBofePenaltyWarrantController.getCaseDetails';

export default class RequestWarrantsLWC extends LightningElement {
    @api payeeListViewIds;
    @track currIntEmpId;
    @track currIntEmpEmailId;
    @track userDetails;
    @track currUserReviewing;
    
    @track allowUserRequest = true;
    @track payeeNotSelected = true;
    @track paymentAmountNull = false;
    @track noPRinPayee = false;
    @track rctHoldDateisFuture = false;
    @track payeeNoDirOffice = false;
    @track prHasNoOA = false;
    @track payeeNoCashBalance = false;
    @track payeeOAerror = false;
    @track nullPmtAmtPR;
    @track payeeWithNoPR;
    @track payeeWithFutureHoldDate;
    @track payeeWithoutOffice;
    @track payeeWithNoOA;
    @track payeeInsuffCashOnCase;
    @track errorMessage = false;
    @track warningMessage = false;
    @track successMessage = false;
    @track unsuccessMessage = false;
    @track officeAccountUndefined = false;

    @track strPayeelist = [];
    @track payeeWithRightData = [];

    @track uniqueCaseIds;
    @track uniqueOfficeAccIds = [];
    @track numberOfPayeeSelected;
    @track numberOfOfficeAccount;
    @track numberOfCases;
    @track casePayeeDetail = [];

    @track caseDetailList;
    @track caseDetailListUpdated;

    @track oaOwnerIdDetails;
    @track buttonsDisabled = true;
    @track warrantBatchArrayList = [];
    @track wbListInserted;
    @track uniquePayeeWithErrData;
    @track wbSuccess;
    @track wbFailed;

    @track warrantsArrayList = [];
    @track warrantListInserted;
    @track wrSuccess;
    @track wrFailed;

    @track allPRsFromRightPayee = [];
    @track prListToUpdate = [];
    @track updatedPRs;
    @track prSuccess;
    @track prFailed;

    @track sfdcBaseURL;
    @track wbId = 'a2jr00000014xSrAAI';
    @track subject = 'Warrant Batch Created';
    @track body = '<div style="font: bold 16px Arial; margin: 10px 0;">New Warrant Batch for BOFE Penalty is created and warrants are being added. <br> The link to the Warrant Batch is: </div>';
    @track wbURL = '<div style="font: bold 16px Arial; margin: 10px 0;">New Warrant Batch for BOFE Penalty is created and warrants are being added. <br> The link to the Warrant Batch is: </div>';
    @track toSend = 'schandrasekar@dir.ca.gov, mteixeira@dir.ca.gov';
    @track emailSentSuccess;
    @track emailSentFailed;
    @track reqType; 

    @wire (getPayeeDetails, {apxSelPayees: '$payeeListViewIds'})
    payeeDetails({error,data}){
        if(data){
            console.log("=========== Inside getPayeeDetails ===========");
            console.log(data);
            this.strPayeelist = JSON.parse(JSON.stringify(data));

            getInternalEmployeeInfo ({userId: User_Id})
            .then(result =>{
                console.log("<=== Internal Employee Info: ===> ");
                this.InternalEmpDetails = JSON.parse(JSON.stringify(result));
                console.log(this.InternalEmpDetails);
                for (var m=0; m<this.InternalEmpDetails.length; m++){
                    if (this.InternalEmpDetails[m].Name == this.InternalEmpDetails[m].User__r.Name){
                        this.currIntEmpId = this.InternalEmpDetails[m].Id;
                        this.currIntEmpEmailId = this.InternalEmpDetails[m].Email__c;
                    }
                }
                console.log(this.currIntEmpId);
            })

            getUserInfo ({userId: User_Id})
            .then(result =>{
                console.log("<=== User Info: ===> ");
                this.userDetails = JSON.parse(JSON.stringify(result));
                console.log(this.userDetails);
                this.checkUserPermission(this.userDetails);
            })  
        }
        else if(error){
            console.log(error);
            this.errormsg = error;
            console.log("@ wire this.errormsg ==> "+this.errormsg);
        }
    }

    checkUserPermission(userDetails){
        console.log("=========== Inside checkUserPermission ===========");
        this.currUserReviewing = userDetails[0].Assignee.Name;
        //Check if any Payees selected
        console.log("Type of payeeListViewIds ==> "+typeof(JSON.stringify(this.payeeListViewIds)));
        console.log(this.payeeListViewIds);
        if (this.payeeListViewIds == undefined){
            this.payeeNotSelected = true;
            this.errorMessage = true;
        }
        else{
            this.numberOfPayeeSelected = this.payeeListViewIds.length;
            this.payeeNotSelected = false;
        }
        //Check if User has permission to Request for Warrants
        console.log("currUserReviewing ==> "+this.currUserReviewing);
        //console.log(userDetails[0].PermissionSet.Profile.Name);
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
        console.log("Profile ===> ");
        console.log(userProfileName);
        console.log("Permissions ===> ");
        console.log(userPermissionNames);
        if (this.currIntEmpId != null && (userPermissionNames.includes("Cashiering_Disbursing") || 
            userProfileName == "System Administrator" || userProfileName == "System Administrator LTD")){
            this.allowUserRequest = true;
            console.log("Chech allowUserRequest true");
            this.verifyPayeePRdetails();
        }
        else{
            this.allowUserRequest = false;
            console.log("Chech allowUserRequest false");
        }
    }

    verifyPayeePRdetails(){
        console.log("=========== Inside verifyPayeePRdetails ===========");
        this.sfdcBaseURL  = window.location.origin;
        console.log(this.sfdcBaseURL);
        console.log(this.wbId);
        console.log(this.strPayeelist);
        if(this.strPayeelist == undefined || this.strPayeelist == null){
            this.errormsg = "There is no Payee details found";
        }
        var payeeDetails = this.strPayeelist;
        console.log(payeeDetails.length);
        var pmtAmtNullPR = [];
        var payeeNullAmtPR = [];
        var payeeNoPR = [];
        var payeeFutureRCTHoldDate = [];
        var payeeOfficeUndefined = [];
        var payeePmtRecNoOA = [];
        var officeAccIds = [];
        //var officeOwnerDetails = [];
        var caseIds = [];
        var todayDate = new Date();
        var day = todayDate.getDate();
        var month = todayDate.getMonth()+1;
        var year = todayDate.getFullYear();
        var today = year + "-" + month + "-" + day;
        console.log(today);

        for(let i=0; i<payeeDetails.length; i++){
            var warrantAmount = 0.00;
            console.log('@@@ Current Payee @@@');
            console.log(payeeDetails[i]);
            // Case Ids from all the Payee selected
            caseIds.push(payeeDetails[i].Case_Management__c);

            //************Subject to Garnish/Lien************
            console.log('************Subject to Garnish/Lien************');
            console.log(payeeDetails[i].Case_Management__r.Employer__r.Subject_to_Garnishment__c);
            console.log(payeeDetails[i].Case_Management__r.Employer__r.Subject_to_Lien__c);
            if(payeeDetails[i].Case_Management__r.Employer__r.Subject_to_Garnishment__c || payeeDetails[i].Case_Management__r.Employer__r.Subject_to_Lien__c){
                payeeDetails[i].payeeGarnishLien = true;
            }else{
                payeeDetails[i].payeeGarnishLien = false;
            }

            //************Check DIR Office in Payee************
            console.log('************Check DIR Office in Payee************');
            if(payeeDetails[i].Case_Management__r.Office__r.Office_Account__c == undefined){
                this.payeeNoDirOffice = true;
                payeeOfficeUndefined.push(payeeDetails[i].Name);
            }

            //************Check Latest Receipt Hold Date************
            console.log('^^^^^^^^^^^^^^^^^^^^^^^ Check Latest Receipt Hold Date ^^^^^^^^^^^^^^^^^^^^^^^^^');
            var payeeRctHoldDate = payeeDetails[i].Latest_Receipt_Hold_Date__c;
            console.log(payeeRctHoldDate);

            if(payeeRctHoldDate!=undefined){
                var payeeRctHoldDate = payeeDetails[i].Latest_Receipt_Hold_Date__c;
                let todayDate = new Date(today).getTime();
                let pRctHoldDate = new Date(payeeRctHoldDate).getTime();
                console.log('Compare the Dates');

                if(pRctHoldDate > todayDate){
                    console.log('Payee Rct Hold Date is in Future');
                    this.rctHoldDateisFuture = true;
                    payeeFutureRCTHoldDate.push(payeeDetails[i].Name);
                }
            }

            //************At least one Payment Record Exist to request warrant************
            console.log('************At least one Payment Record Exist to request warrant************');
            if(payeeDetails[i].Payment_Records__r == undefined){
                this.noPRinPayee = true;
                payeeNoPR.push(payeeDetails[i].Name);
            }
            else{
                for(let j=0; j<payeeDetails[i].Payment_Records__r.length; j++){
                    //************Warrant Amount************
                    console.log('************Warrant Amount************');
                    var paymentAmount = payeeDetails[i].Payment_Records__r[j].Payment_Amount__c;
                    console.log(paymentAmount);
                    if(paymentAmount >= 0.00 || paymentAmount >= 0){
                        warrantAmount = warrantAmount + paymentAmount;
                    }
                    else{
                        pmtAmtNullPR.push(payeeDetails[i].Payment_Records__r[j].Name);
                        console.log('Payment Amount Null')
                        payeeNullAmtPR.push(payeeDetails[i].Name);
                        this.paymentAmountNull = true;
                    }
                    
                    
                    //************Office Account Check***********
                    console.log('************Office Account Check************');
                    console.log('_____________________________________________');
                    console.log('Current Payee Details');
                    console.log(payeeDetails[i]);
                    console.log('Current Payemnt Record Details');
                    console.log(payeeDetails[i].Payment_Records__r[j]);
                    if(payeeDetails[i].Payment_Records__r[j].Payment_Amount__c > 0.00){
                        if(payeeDetails[i].Payment_Records__r[j].Liability_Payment__c != undefined || payeeDetails[i].Payment_Records__r[j].Liability_Payment__c != null){
                            if(payeeDetails[i].Payment_Records__r[j].Liability_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c != null){
                                this.officeAccountUndefined = false;
                                console.log('Office Account of Liability Payment');
                                officeAccIds.push(payeeDetails[i].Payment_Records__r[j].Liability_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c);
                            }
                        }
                        else if(payeeDetails[i].Payment_Records__r[j].Judgment_Payment__c != undefined || payeeDetails[i].Payment_Records__r[j].Judgment_Payment__c != null){
                            if(payeeDetails[i].Payment_Records__r[j].Judgment_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c != null){ 
                                this.officeAccountUndefined = false;
                                console.log('Office Account of Judgment Payment');
                                officeAccIds.push(payeeDetails[i].Payment_Records__r[j].Judgment_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c);
                            }
                        }
                        else{
                            console.log('Office Account Undefined');
                            this.officeAccountUndefined = true;
                            this.prHasNoOA = true;
                            payeePmtRecNoOA.push(payeeDetails[i].Name);
                        }
                    }
                }
            }
            if(paymentAmount >= 0.00 || paymentAmount >= 0){
                payeeDetails[i].warrantAmount = warrantAmount.toFixed(2);
            }
            else{
                payeeNullAmtPR.push(payeeDetails[i].Name);
                this.paymentAmountNull = true;
            }     
        }

        this.nullPmtAmtPR = [...new Set(payeeNullAmtPR)].toString();
        this.payeeWithNoPR = payeeNoPR.toString();
        this.payeeWithFutureHoldDate = payeeFutureRCTHoldDate.toString();
        this.payeeWithoutOffice = payeeOfficeUndefined.toString();
        this.payeeWithNoOA = [...new Set(payeePmtRecNoOA)].toString();
        console.log(payeeDetails);

        //Total number of Cases
        console.log('_________Number of Cases__________');
        console.log(caseIds);
        this.uniqueCaseIds = [...new Set(caseIds)];
        console.log(this.uniqueCaseIds);
        console.log(typeof(this.uniqueCaseIds));
        this.numberOfCases = this.uniqueCaseIds.length;

        //Total number of Office Accounts
        console.log('_________Number of Office Accounts__________');
        console.log(officeAccIds);
        this.uniqueOfficeAccIds = [...new Set(officeAccIds)];
        console.log('Unique Office Accounts ==> '+ this.uniqueOfficeAccIds);
        this.numberOfOfficeAccount = this.uniqueOfficeAccIds.length;
        console.log('Number of Office Account = ' + this.numberOfOfficeAccount);
        if(this.numberOfOfficeAccount == 0 || this.numberOfOfficeAccount == null){
            this.prHasNoOA = true;
            return;
        }
        else if(this.numberOfOfficeAccount > 1){
            this.buttonsDisabled = true;
            this.payeeOAerror = true;
            return;
        } 
        else if(this.numberOfOfficeAccount == 1){
            console.log("All Payees belong to same Office Account");
        }

        if(this.allowUserRequest==false || this.payeeNotSelected==true || this.payeeOAerror == true){
            console.log('Error message should be seen');
            this.errorMessage = true;
            this.warningMessage = false;
            this.successMessage = false;
        }
        if((this.paymentAmountNull==true || this.noPRinPayee==true || this.payeeNoDirOffice==true || this.rctHoldDateisFuture==true || this.prHasNoOA==true || this.payeeNoCashBalance==true) && (this.allowUserRequest==true && this.payeeNotSelected==false && this.payeeOAerror == false)){
            console.log('Warning message should be seen');
            this.errorMessage = false;
            this.warningMessage = true;
            this.successMessage = false;
            this.unsuccessMessage = false;
        }
        if(this.allowUserRequest==true && this.payeeNotSelected==false && this.payeeOAerror == false && this.paymentAmountNull==false && this.noPRinPayee==false && this.payeeNoDirOffice==false && this.rctHoldDateisFuture==false && this.prHasNoOA==false && this.payeeNoCashBalance == false){
            console.log('Success message should be seen');
            this.errorMessage = false;
            this.warningMessage = false;
            //this.successMessage = true;
            this.unsuccessMessage = false;
        }

        console.log('nullPmtAmtPR');
        console.log(this.nullPmtAmtPR);
        console.log('payeeWithNoPR');
        console.log(this.payeeWithNoPR);
        console.log('payeeWithFutureHoldDate');
        console.log(this.payeeWithFutureHoldDate);
        console.log('payeeWithoutOffice');
        console.log(this.payeeWithoutOffice);
        console.log('payeeWithNoOA');
        console.log(this.payeeWithNoOA);

        //Get the Payee list with correct data
        this.getPayeeWithRightData();
    }

    getPayeeWithRightData(){
        console.log("=========== Inside getPayeeWithRightData ===========");
        console.log(this.strPayeelist);

        //Javascript immutable strings
        for(let m=0; m<this.strPayeelist.length; m++){
            console.log(m);
            console.log(this.strPayeelist[m]);
            this.payeeWithRightData.push(this.strPayeelist[m]);
        }

        console.log("All payee details");
        console.log(this.payeeWithRightData);
        console.log('Each error check Payee');
        console.log(this.nullPmtAmtPR);
        console.log(this.payeeWithNoPR);
        console.log(this.payeeWithFutureHoldDate);
        console.log(this.payeeWithoutOffice);
        console.log(this.payeeWithNoOA);
        var strPayeeWithErrorData = "";
        if(this.paymentAmountNull){
            if (strPayeeWithErrorData === ""){
                strPayeeWithErrorData = this.nullPmtAmtPR;
            }
            else{
                strPayeeWithErrorData = strPayeeWithErrorData + ',' + this.nullPmtAmtPR;
            }
        }
        if(this.noPRinPayee){
            if (strPayeeWithErrorData === ""){
                strPayeeWithErrorData = this.payeeWithNoPR;
            }
            else{
                strPayeeWithErrorData = strPayeeWithErrorData + ',' + this.payeeWithNoPR;
            }
        }
        if(this.payeeNoDirOffice){
            if (strPayeeWithErrorData === ""){
                strPayeeWithErrorData = this.payeeWithoutOffice;
            }
            else{
                strPayeeWithErrorData = strPayeeWithErrorData + ',' + this.payeeWithoutOffice;
            }
        }
        if(this.rctHoldDateisFuture){
            if (strPayeeWithErrorData === ""){
                strPayeeWithErrorData = this.payeeWithFutureHoldDate;
            }
            else{
                strPayeeWithErrorData = strPayeeWithErrorData + ',' + this.payeeWithFutureHoldDate;
            }
        }
        if(this.prHasNoOA){
            if (strPayeeWithErrorData === ""){
                strPayeeWithErrorData = this.payeeWithNoOA;
            }
            else{
                strPayeeWithErrorData = strPayeeWithErrorData + ',' + this.payeeWithNoOA;
            }
        }

        console.log("String all payee with error data");
        console.log(strPayeeWithErrorData);
        var arrPayeeWithErrorData = strPayeeWithErrorData.split(',');
        console.log("Array all payee with error data");
        console.log(arrPayeeWithErrorData);
        this.uniquePayeeWithErrData = [...new Set(arrPayeeWithErrorData)];
        console.log("@ @ @ @ @ Payee that should be removed from creating warrants @ @ @ @ @");
        console.log(this.uniquePayeeWithErrData);
        console.log("Payees with right data");
        console.log(this.payeeWithRightData);

        for(let i = this.payeeWithRightData.length -1; i>=0; i--){
            console.log("Inside Payee Details");
            console.log(this.payeeWithRightData[i]);
            console.log(this.payeeWithRightData[i].Name);
            var abort = false;
            for(let j = this.uniquePayeeWithErrData.length -1; j>=0 && !abort; j--){
                console.log("Inside uniquePayeeWithErrData");
                if(this.payeeWithRightData[i].Name != undefined || this.uniquePayeeWithErrData[j] != undefined){
                    console.log('check undefined');
                    console.log(this.payeeWithRightData[i].Name);
                    console.log(this.uniquePayeeWithErrData[j]);
                    if(this.payeeWithRightData[i].Name == this.uniquePayeeWithErrData[j]){
                        console.log(this.payeeWithRightData[i].Name);
                        console.log(this.uniquePayeeWithErrData[j]);
                        console.log("Remove this Payee");
                        this.payeeWithRightData.splice(i,1);
                        abort = true;
                    }
                }
            }
        }

        console.log("Payees with correct data for which the Warrants needs to be created");
        console.log(this.payeeWithRightData);
        this.getCaseDetailsforBofePenalties();
    }

    getCaseDetailsforBofePenalties(){
        console.log("=========== Inside getCaseDetailsforBofePenalties ===========");
        getCaseDetails ({apxSelCases: this.uniqueCaseIds})
        .then(result =>{
            console.log("<=== caseDetailList ===> ");
            this.caseDetailList = JSON.parse(JSON.stringify(result));
            console.log(this.caseDetailList);
            console.log("<=== Calculate Warrant Amount per Case that's selected for BOFE Penalties ===>");
            this.calWRAmtandCashBal();
        })
        .catch(error =>{
            console.log("Error while getting Case, Case Role & Payee details");
        })

    }
    
    calWRAmtandCashBal(){
        console.log("=========== Inside calWRAmtandCashBal ===========");
        console.log("Updated caseDetailList");
        console.log(this.caseDetailList);

        //Calcualte Warrant Amount Per Case
        console.log("<=== Calculate Warrant Amount Per Case ===>");
        for(let l=0; l<this.caseDetailList.length; l++){
            var caseWRamt = 0.00;
            for(let m=0; m<this.payeeWithRightData.length; m++){
                if(this.caseDetailList[l].Id == this.payeeWithRightData[m].Case_Management__c){
                    console.log(typeof(Number(parseFloat(this.payeeWithRightData[m].warrantAmount).toFixed(2))));
                    console.log(typeof(Number(parseFloat(caseWRamt).toFixed(2))));
                    caseWRamt = Number(parseFloat(caseWRamt).toFixed(2)) + Number(parseFloat(this.payeeWithRightData[m].warrantAmount).toFixed(2));
                    console.log(caseWRamt);
                    console.log(typeof(caseWRamt));
                }
            }
            console.log(caseWRamt);
            this.caseDetailList[l].warrantAmount = caseWRamt.toFixed(2);
        }
        
        //Calculate Cash Balance on Case
        console.log("<=== Cash Balance on Case ===>");
        console.log("Updated caseDetailList");
        console.log(this.caseDetailList);
        var payeeInsuffFund = [];
        for(let n=0; n<this.caseDetailList.length; n++){

            if(this.caseDetailList[n].Warrants_Pending__c != undefined){
                var totalAvailCashBal = this.caseDetailList[n].Cash_Balance_on_Case__c - this.caseDetailList[n].Warrants_Pending__c;
            }
            else{
                var totalAvailCashBal = this.caseDetailList[n].Cash_Balance_on_Case__c;
            }
            
            if(Number(parseFloat(totalAvailCashBal).toFixed(2)) >= this.caseDetailList[n].warrantAmount){
                console.log("Cash Balance on case is verified");
                this.buttonsDisabled = false;
            }
            else{
                console.log("Cash Balance on case is not sufficient");
                for(let m = this.payeeWithRightData.length -1; m>=0; m--){
                    console.log(this.payeeWithRightData[m].Case_Management__c);
                    console.log(this.caseDetailList[n].Id);
                    if(this.payeeWithRightData[m].Case_Management__c == this.caseDetailList[n].Id){
                        payeeInsuffFund.push(this.payeeWithRightData[m].Name);
                        console.log("Remove the Payees & Case with insufficient cash balance");
                        this.payeeWithRightData.splice(m,1);
                    }
                }
                this.caseDetailList.splice(n,1);
            }
        }
        if(payeeInsuffFund.length > 0){
            this.payeeNoCashBalance = true;
            this.payeeInsuffCashOnCase = payeeInsuffFund.toString();
            console.log('payeeInsuffCashOnCase');
            console.log(this.payeeInsuffCashOnCase);
        }
        else{
            this.payeeNoCashBalance = false;
        }
        
        console.log('List of eligible Payees');
        console.log(this.payeeWithRightData);
        if(this.payeeWithRightData.length > 0 || this.caseDetailList.length > 0){
            var eligiblePayees = [];
            for(let x=0; x<this.payeeWithRightData.length; x++){
                eligiblePayees.push(this.payeeWithRightData[x].Name);
            }
            this.successMessage = true;
            this.buttonsDisabled = false;
            this.unsuccessMessage = false;
        }
        else{
            this.successMessage = false;
            this.buttonsDisabled = true;
            this.unsuccessMessage = true;
        }

    }

    createBOFEPenaltyWarrantBatch(){
        console.log("=========== Inside createBOFEPenaltyWarrantBatch ===========");
        this.buttonsDisabled = true;
        //Final check if there is any Payee left after screening for the right data
        console.log('Final check if there is any Payee left after screening for their right data');
        console.log(this.payeeWithRightData);
        if(this.payeeWithRightData.length > 0){
            for(let a=0; a<this.payeeWithRightData.length; a++){
                console.log(this.payeeWithRightData[a]);
                console.log(this.payeeWithRightData[a].Payment_Records__r);
                for(let b=0; b<this.payeeWithRightData[a].Payment_Records__r.length; b++){
                    console.log("PRs inside a Payee");
                    console.log(this.payeeWithRightData[a].Payment_Records__r[b]);
                    this.allPRsFromRightPayee.push(this.payeeWithRightData[a].Payment_Records__r[b]);
                }
            }
            console.log("List of all Payment Records from Payees with right data");
            console.log(this.allPRsFromRightPayee);
        
            //Create the list of the Warrant Batch, that needs to be inserted
            
            console.log("<=== Office Account Owner Details ===> ");
            oaOwnerId ({oaId: this.uniqueOfficeAccIds})
            .then(result =>{
                console.log("<=== Office Account Owner Details ===> ");
                this.oaOwnerIdDetails = result;
                console.log(this.oaOwnerIdDetails);
                var newDate = new Date();
                var todayDate = newDate.toISOString();
                console.log(todayDate);
                for(let i=0; i<this.oaOwnerIdDetails.length; i++){
                    console.log(this.oaOwnerIdDetails[i]);
                    var warrantBatchList = {
                        Status__c : 'New',
                        Office_Account__c : this.oaOwnerIdDetails[i].Id,
                        OwnerId : this.oaOwnerIdDetails[i].OwnerId,
                        Requested_By__c : this.currIntEmpId,
                        Request_Date__c : todayDate,
                        WB_Instructions__c : "BOFE Penalty"
                    };
                    console.log(warrantBatchList);
                    this.warrantBatchArrayList.push(warrantBatchList);
                }
                console.log('Warrant Batch List to be Inserted ======= ');
                console.log(this.warrantBatchArrayList);
                this.insertBOFEPenaltyWarrantBatch();
            })
            .catch(error =>{
                console.log("Error while getting Office Account Owner details");
            })
        }
        else{
            console.log('Error message should be seen');
            this.errorMessage = true;
            this.warningMessage = false;
            this.successMessage = false;
        }
    }

    insertBOFEPenaltyWarrantBatch(){
        //Insert Warrant Batch
        console.log("=========== Inside insertBOFEPenaltyWarrantBatch ===========");
        var apxInsertWBlist = this.warrantBatchArrayList;
        console.log(apxInsertWBlist);
        insertWB ({wbListToInsert: apxInsertWBlist})
        .then(result =>{
            console.log(result);
            this.wbListInserted = JSON.parse(JSON.stringify(result));
            if(this.wbListInserted.length>0){
                console.log("WB Ids Inserted");
                console.log(this.wbListInserted);
                this.wbSuccess = true;
                this.reqType = 'reqBOFEwr';
                var emailBody1 = this.sfdcBaseURL + '/' + this.wbListInserted[0].Id + '\r\n';
                var emailBody2 = '<div style="font: bold 16px Arial; margin: 10px 0;">An email confirmation will be sent, once all the Warrants are inserted successfully and the Payment Records are updated.</div>';
                this.body = this.body + emailBody1 + emailBody2;
                this.wbURL = this.wbURL + emailBody1;
                this.sendEmailAboutWB();
            }
            else{
                this.wbFailed = true;
            }
        })
        .catch(error =>{
            this.wbFailed = true;
            console.log("Error while creating or inserting Warrant Batch");
        })
    }

    createBOFEPenaltyWarrants(){
        console.log("=========== Inside createBOFEPenaltyWarrants ===========");
        //Create the list of warrants to be inserted
        console.log(this.payeeWithRightData);
        for(let k=0; k<this.wbListInserted.length; k++){
            for(let l=0; l<this.payeeWithRightData.length; l++){
                console.log(this.wbListInserted[k]);
                console.log(this.payeeWithRightData[l]);
                console.log("Check if the Office Account matches between the Payee & Warrant");
                console.log(this.wbListInserted[k].Office_Account__c);
                console.log(this.payeeWithRightData[l].Case_Management__r.Office__r.Office_Account__c);
                if(this.payeeWithRightData[l].Case_Management__r.Office__r.Office_Account__c == this.wbListInserted[k].Office_Account__c){
                    console.log("Office Account in Payee & Office Account is same");
                    if(this.payeeWithRightData[l].warrantAmount > 0){
                        console.log("Warrant Amount is > 0");
                        console.log(this.payeeWithRightData[l].Id);
                        console.log(this.payeeWithRightData[l].warrantAmount);
                        console.log(this.payeeWithRightData[l].Case_Management__c);
                        console.log(this.wbListInserted[k].Id);
                        console.log(this.wbListInserted[k].Office_Account__c);
                        var warrantList = {
                            Payee__c : this.payeeWithRightData[l].Id,
                            Amount__c : this.payeeWithRightData[l].warrantAmount,
                            Case__c : this.payeeWithRightData[l].Case_Management__c,
                            Case_Number__c: this.payeeWithRightData[l].Case_Management__r.Case_Number__c,
                            Status__c : 'New',
                            Warrant_Batch__c : this.wbListInserted[k].Id,
                            Office_Account__c : this.wbListInserted[k].Office_Account__c,
                            Disbursement_Type__c : "BOFE Penalty"
                        }
                        console.log("warrantList Initialisation");
                        console.log(warrantList);
                        this.warrantsArrayList.push(warrantList);
                    }
                } 
            }
        }
        
        console.log('Warrants to be inserted');
        console.log(this.warrantsArrayList);

        var apxInsertWRlist = this.warrantsArrayList;
        console.log("apxInsertWRlist");
        console.log(apxInsertWRlist);
        var apxUpdatePRlist = this.allPRsFromRightPayee;
        console.log("apxUpdatePRlist");
        console.log(apxUpdatePRlist);
        insertWrsUpdatePrs({wrListToInsert: apxInsertWRlist, prListToUpdate: apxUpdatePRlist, type: this.reqType, wbLink: this.wbURL})
        .then(result =>{
            console.log("Warrant Ids Inserted");
            this.close();
        })
        .catch(error =>{
            this.wrFailed = true;
            console.log("Error while inserting Warrants & Processing Payment Record list to Update");
        })

        /*
        var apxInsertWRlist = this.warrantsArrayList;
        insertWR({wrListToInsert: apxInsertWRlist})
        .then(result =>{
            console.log("Warrant Ids Inserted");
            this.warrantListInserted = JSON.parse(JSON.stringify(result));
            console.log(this.warrantListInserted);
            if(this.warrantListInserted.length > 0){
                this.wrSuccess = true;
                this.updateBOFEpenaltyWRtoPR();
            }
            else{
                this.wrFailed = true;
            }
        })
        .catch(error =>{
            this.wrFailed = true;
            console.log("Error while inserting Warrants & Processing Payment Record list to Update");
        })
        */
    }

    /*
    updateBOFEpenaltyWRtoPR(){
        console.log("=========== Inside updateWRtoPR ===========");
        //Create the list of Payment Records to be updated
        console.log(this.warrantListInserted);
        console.log(this.allPRsFromRightPayee);
        for(let i=0; i<this.warrantListInserted.length; i++){
            for(let j=0; j<this.allPRsFromRightPayee.length; j++){
                    if(this.warrantListInserted[i].Case_Number__c == this.allPRsFromRightPayee[j].Case_Number__c && this.allPRsFromRightPayee[j].Payment_Amount__c > 0){
                        this.allPRsFromRightPayee[j].Warrant__c = this.warrantListInserted[i].Id;
                        this.allPRsFromRightPayee[j].UWF_Payee__c = this.warrantListInserted[i].Payee__c;
                        this.allPRsFromRightPayee[j].Batched_Under_Warrant__c = true;
                        this.allPRsFromRightPayee[j].Disbursement_Type__c = "BOFE Penalty";
                        this.prListToUpdate.push(this.allPRsFromRightPayee[j]);
                    }
            }
        }
        console.log("Payment Record to be Updated");
        console.log(this.prListToUpdate);

        console.log("=========== Calling updatePaymentRecord ===========");
        var apxUpdatePRlist = this.prListToUpdate;
        updatePR({prListToUpdate: apxUpdatePRlist})
        .then(result =>{
            console.log("Payment Record Ids Updated");
            this.updatedPRs = JSON.parse(JSON.stringify(result));
            console.log(this.updatedPRs);
            if(this.updatedPRs.length > 0){
                this.prSuccess = true;
                this.sendEmailAboutWB();
            }
            else{
                this.prFailed = true;
            }
        })
        .catch(error =>{
            this.prFailed = true;
            console.log("Error while updating Payment Records or while sending Email");
        })
    }
    */

    sendEmailAboutWB(){
        console.log("=========== sendEmailAboutWB ===========");
        console.log(this.currIntEmpEmailId);
        this.toSend = this.toSend + ',' + this.currIntEmpEmailId;
        console.log(this.toSend);
        console.log(this.wbListInserted);
        console.log(this.body);
        sendEmailToController({body: this.body, toSend: this.toSend, subject: this.subject})
        .then(() => {
            //If response is ok
            console.log("Email Sent");
            this.emailSentSuccess = true;
            this.createBOFEPenaltyWarrants();
        }).catch( error => {
            this.emailSentFailed = true;
            console.log("Error while sending the Email");
        })
    }

    close(){
		setTimeout(
			function() {
				window.history.back();
			},
			1000
		);
	}
}