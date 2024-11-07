import { LightningElement, api, track, wire} from 'lwc';
import User_Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/RequestCourtPayeeWarrantsLWCcontroller.getUserInfo';
import getInternalEmployeeInfo from '@salesforce/apex/RequestCourtPayeeWarrantsLWCcontroller.getInternalEmployeeInfo';
import getPayeeDetails from '@salesforce/apex/RequestCourtPayeeWarrantsLWCcontroller.getPayeeDetails';
import insertWB from '@salesforce/apex/RequestCourtPayeeWarrantsLWCcontroller.insertWarrantBatch';
//import insertWrsUpdatePrs from '@salesforce/apex/RequestCourtPayeeWarrantsLWCcontroller.insertWrsUpdatePrs';
import insertWR from '@salesforce/apex/RequestCourtPayeeWarrantsLWCcontroller.insertWarrants';
import updatePR from '@salesforce/apex/RequestCourtPayeeWarrantsLWCcontroller.updatePaymentRecord';
import sendEmailToController from '@salesforce/apex/RequestCourtPayeeWarrantsLWCcontroller.sendEmailToController';
import oaOwnerId from '@salesforce/apex/RequestCourtPayeeWarrantsLWCcontroller.getOAowner';
//import updatePendCashBalOnCase from '@salesforce/apex/RequestWarrantsLWCcontroller.updatePendCashBalOnCase';

export default class RequestCourtPayeeWarrantsLWC extends LightningElement {
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
    @track strPayeelist = [];
    @track officeAccountUndefined = false;

    @track uniqueCaseIds;
    @track uniqueJudgmentIds;
    @track uniqueLiabilityIds;
    @track uniqueOfficeAccIds = [];
    @track numberOfPayeeSelected;
    @track numberOfOfficeAccount;
    @track numberOfCases;
    @track casePayeeCashBalDetail = [];
    @track oaOwnerIdDetails;

    @track buttonsDisabled = true;
    @track warrantBatchArrayList = [];
    @track wbListInserted;
    @track payeeWithRightData = [];
    @track uniquePayeeWithErrData;
    @track wbSuccess;
    @track wbFailed;
    

    @track warrantsArrayList = [];
    @track warrantsJPandLPArrayList = [];
    @track warrantListInserted;
    @track wrSuccess;
    @track wrFailed;

    @track allPRsFromRightPayee = [];
    @track prListToUpdate = [];
    @track updatedPRs;
    @track prSuccess;
    @track prFailed;
    @track cmSuccess;
    @track cmFailed;

    @track sfdcBaseURL;
    @track wbId = 'a2jr00000014xSrAAI';
    @track subject = 'Warrant Batch Created';
    @track body = '<div style="font: bold 16px Arial; margin: 10px 0;">The link to the Warrant Batch is: </div>';
    @track toSend = 'schandrasekar@dir.ca.gov, mteixeira@dir.ca.gov';
    @track emailSentSuccess;
    @track emailSentFailed;

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
                    if (this.InternalEmpDetails[m].Name === this.InternalEmpDetails[m].User__r.Name){
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
        if (this.payeeListViewIds === undefined){
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
            userProfileName === "System Administrator" || userProfileName === "System Administrator LTD")){
            this.allowUserRequest = true;
            console.log("Check allowUserRequest true");
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
        if(payeeDetails.length > 10){
            console.log("Adjust the hieght of the div");
            //document.getElementById("payeeDetailId").style.height = "400px";
        }
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

            console.log('************At least one Payment Record Exist to request warrant************');
            if(payeeDetails[i].Payment_Records__r == undefined){
                this.noPRinPayee = true;
                payeeNoPR.push(payeeDetails[i].Name);
            }
            else{
                console.log('************Warrant Amount************');
                for(let j=0; j<payeeDetails[i].Payment_Records__r.length; j++){
                    
                    var paymentAmount = payeeDetails[i].Payment_Records__r[j].Payment_Amount__c;
                    console.log("paymentAmount");
                    console.log(typeof paymentAmount);
                    console.log(paymentAmount);
                    console.log("warrantAmount");
                    console.log(typeof warrantAmount);
                    console.log(warrantAmount);
                    if(paymentAmount >= 0.00 || paymentAmount >= 0){
                        warrantAmount = warrantAmount + paymentAmount;
                    }
                    
                    else{
                        pmtAmtNullPR.push(payeeDetails[i].Payment_Records__r[j].Name);
                        payeeNullAmtPR.push(payeeDetails[i].Name);
                        this.paymentAmountNull = true;
                    }
                    
                    //************Office Account Check***********
                    console.log('************Office Account Check************');
                    //var officeDetail = {};
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
                        this.officeAccountUndefined = true;
                        this.prHasNoOA = true;
                        payeePmtRecNoOA.push(payeeDetails[i].Name);
                    }
                }
            }
            console.log("Calculated Warrant Amount")
            console.log(warrantAmount);
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
        var payeeDetailsWB = this.strPayeelist;
        console.log(payeeDetailsWB);

        //Javascript immutable strings
        for(let m=0; m<payeeDetailsWB.length; m++){
            console.log(m);
            console.log(payeeDetailsWB[m]);
            this.payeeWithRightData.push(payeeDetailsWB[m]);
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

        //Check Cash Balance on Case
        var payeeInsuffFund = [];
        console.log('_________Cash Balance on Case__________');
        if(this.payeeWithRightData.length > 0){
            for(let i=0; i<this.uniqueCaseIds.length; i++){
                var casePayeeBalDetail = {};
                console.log(this.uniqueCaseIds[i]);
                casePayeeBalDetail.caseId = this.uniqueCaseIds[i];
                var payeeAmtSum = 0;
                for(let j=0; j<this.payeeWithRightData.length; j++){
                    if(this.uniqueCaseIds[i] == this.payeeWithRightData[j].Case_Management__c){
                        payeeAmtSum =  Number(parseFloat(payeeAmtSum).toFixed(2)) + Number(parseFloat(this.payeeWithRightData[j].warrantAmount).toFixed(2));
                        casePayeeBalDetail.cashBalanceOnCase = this.payeeWithRightData[j].Case_Management__r.Cash_Balance_on_Case__c;
                        
                        if(this.payeeWithRightData[j].Case_Management__r.Warrants_Pending__c!=undefined){
                            casePayeeBalDetail.pendingBalanceOnCase = this.payeeWithRightData[j].Case_Management__r.Warrants_Pending__c;
                        }
                        else{
                            casePayeeBalDetail.pendingBalanceOnCase = 0.00;
                        }
                        
                    }
                    
                }
                casePayeeBalDetail.totalPayeeAmount = payeeAmtSum.toFixed(2);
                console.log(casePayeeBalDetail)
                this.casePayeeCashBalDetail.push(casePayeeBalDetail);

            }
            console.log("Case Payee Detail");
            console.log(this.casePayeeCashBalDetail);
            //this.casePayeeCashBalDetail = JSON.parse(JSON.stringify(casePayeeCashBalDetail));
    
            console.log("Check Cash Balance");
            for(let k=0; k<this.casePayeeCashBalDetail.length; k++){
                console.log(typeof(this.casePayeeCashBalDetail));
                console.log(this.casePayeeCashBalDetail[0]);
                var totalAvailCashBal = this.casePayeeCashBalDetail[k].cashBalanceOnCase - this.casePayeeCashBalDetail[k].pendingBalanceOnCase;
                console.log(totalAvailCashBal);
                if( Number(parseFloat(totalAvailCashBal).toFixed(2)) >= this.casePayeeCashBalDetail[k].totalPayeeAmount){
                    console.log("Cash Balance on case is verified");
                }
                else{
                    console.log("Cash balance on case is insufficient");
                    //Remove the Payees with insufficient balance on case
                    for(let m = this.payeeWithRightData.length -1; m>=0; m--){
                        console.log(this.payeeWithRightData[m].Case_Management__c);
                        console.log(this.casePayeeCashBalDetail[k].caseId);
                        if(this.payeeWithRightData[m].Case_Management__c == this.casePayeeCashBalDetail[k].caseId){
                            payeeInsuffFund.push(this.payeeWithRightData[m].Name);
                            console.log("Remove this Payee");
                            this.payeeWithRightData.splice(m,1);

                        }
                    }
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
        }
        
        console.log('List of eligible Payees');
        console.log(this.payeeWithRightData);
        if(this.payeeWithRightData.length > 0){
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

    createWarrantBatch(){
        console.log("=========== Inside createWarrantBatch ===========");
        this.buttonsDisabled = true;
        //Final check if there is any Payee left after screening for their right data
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
                        Request_Date__c : todayDate,
                        Requested_By__c : this.currIntEmpId,
                        WB_Instructions__c : 'Court'
                    };
                    console.log(warrantBatchList);
                    this.warrantBatchArrayList.push(warrantBatchList);
                }
                console.log('Warrant Batch List to be Inserted ======= ');
                console.log(this.warrantBatchArrayList);
                this.insertWarrantBatch();
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

    insertWarrantBatch(){
        console.log("=========== Inside insertWarrantBatch ===========");
        var apxInsertWBlist = this.warrantBatchArrayList;
        insertWB ({wbListToInsert: apxInsertWBlist})
        .then(result =>{
            console.log(result);
            this.wbListInserted = JSON.parse(JSON.stringify(result));
            if(this.wbListInserted.length>0){
                console.log("WB Ids Inserted");
                console.log(this.wbListInserted);
                this.wbSuccess = true;
                this.createWarrants();
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

    createWarrants(){
        console.log("=========== Inside createWarrants ===========");
        //Create the list of warrants to be inserted
        //var caseIds = [];
        var judgmentIds = [];
        for(let i=0; i<this.payeeWithRightData.length; i++){
            for(let j=0; j<this.payeeWithRightData[i].Payment_Records__r.length; j++){
                //Get the Judgment list
                judgmentIds.push(this.payeeWithRightData[i].Payment_Records__r[j].Judgment_Payment__r.Judgment__c);
            }
        }
        // Unique Judgment Id
        this.uniqueJudgmentIds = [...new Set(judgmentIds)];
        console.log("Unique Judgment IDs");
        console.log(this.uniqueJudgmentIds);
        
        for(let k=0; k<this.wbListInserted.length; k++){
            for(let l=0; l<this.payeeWithRightData.length; l++){
                for(let t=0; t<this.uniqueJudgmentIds.length; t++){
                    var WarrantAmtPerJudgment = 0;
                    var PaymentRecordMapJP = [];
                    //var Judgment_Payment = [];
                    for(let m=0; m<this.payeeWithRightData[l].Payment_Records__r.length; m++){
                        //Get the Warrant Amount per Judgment
                        if(this.uniqueJudgmentIds[t] == this.payeeWithRightData[l].Payment_Records__r[m].Judgment_Payment__r.Judgment__c){
                            WarrantAmtPerJudgment = WarrantAmtPerJudgment + this.payeeWithRightData[l].Payment_Records__r[m].Payment_Amount__c;
                            //Judgment_Payment.push(this.payeeWithRightData[l].Payment_Records__r[m].Judgment_Payment__r.Id);
                            PaymentRecordMapJP.push(this.payeeWithRightData[l].Payment_Records__r[m].Id);
                        }
                        
                    }
                    if(WarrantAmtPerJudgment > 0){
                        console.log("Warrant Amount is > 0");
                        console.log(this.payeeWithRightData[l].Id);
                        console.log(WarrantAmtPerJudgment);
                        console.log(this.payeeWithRightData[l].Case_Management__c);
                        console.log(this.wbListInserted[k].Id);
                        console.log(this.wbListInserted[k].Office_Account__c);
                        var warrantJPlist = {
                            Payee__c : this.payeeWithRightData[l].Id,
                            Amount__c : WarrantAmtPerJudgment,
                            Case__c : this.payeeWithRightData[l].Case_Management__c,
                            Status__c : 'New',
                            Warrant_Batch__c : this.wbListInserted[k].Id,
                            Office_Account__c : this.wbListInserted[k].Office_Account__c,
                            Disbursement_Type__c : 'Court Costs',
                            PaymentRecordMap : PaymentRecordMapJP
                        }
                        console.log("warrantJPlist Initialisation");
                        console.log(warrantJPlist);
                        this.warrantsJPandLPArrayList.push(warrantJPlist);
                    }
                }
            }
        }
        console.log("warrantsJPandLPArrayList");
        console.log(this.warrantsJPandLPArrayList);
        for(let n=0; n<this.warrantsJPandLPArrayList.length; n++){
            var warrantList = {
                Payee__c : this.warrantsJPandLPArrayList[n].Payee__c,
                Amount__c : this.warrantsJPandLPArrayList[n].Amount__c,
                Case__c : this.warrantsJPandLPArrayList[n].Case__c,
                Status__c : this.warrantsJPandLPArrayList[n].Status__c,
                Warrant_Batch__c : this.warrantsJPandLPArrayList[n].Warrant_Batch__c,
                Office_Account__c : this.warrantsJPandLPArrayList[n].Office_Account__c,
                Disbursement_Type__c : this.warrantsJPandLPArrayList[n].Disbursement_Type__c
            }

            console.log('Warrants to be inserted');
            this.warrantsArrayList.push(warrantList);
        }
        console.log(this.warrantsArrayList);
        
        /*
        var apxUpdatePRlist = this.allPRsFromRightPayee;
        var apxWrJudPmtList = this.warrantsJPandLPArrayList;
        insertWrsUpdatePrs({wrListToInsert: apxInsertWRlist, wrJParrayList: apxWrJudPmtList, prListToUpdate: apxUpdatePRlist})
        .then(result =>{
            console.log("Warrant Ids Inserted");
            this.sendEmailAboutWB();
        })
        .catch(error =>{
            this.wrFailed = true;
            console.log("Error while inserting Warrants & Processing Payment Record list to Update");
        })
        */

        var apxInsertWRlist = this.warrantsArrayList;
        insertWR({wrListToInsert: apxInsertWRlist})
        .then(result =>{
            console.log("Warrant Ids Inserted");
            this.warrantListInserted = JSON.parse(JSON.stringify(result));
            console.log(this.warrantListInserted);
            if(this.warrantListInserted.length > 0){
                for(let i=0; i<this.warrantListInserted.length; i++){
                    for(let j=0; j<this.warrantsJPandLPArrayList.length; j++){
                        if(this.warrantListInserted[i].Amount__c == this.warrantsJPandLPArrayList[j].Amount__c){
                            this.warrantsJPandLPArrayList[j].WarrantName = this.warrantListInserted[i].Name;
                            this.warrantsJPandLPArrayList[j].WarrantId = this.warrantListInserted[i].Id;
                        }
                    }
                }
                console.log("Warrants inserted to respectice Judgment Payment");
                console.log(this.warrantsJPandLPArrayList);
                this.wrSuccess = true;
                this.updateWRtoPR();
            }
            else{
                this.wrFailed = true;
            }
        })
        .catch(error =>{
            this.wrFailed = true;
            console.log("Error while inserting Warrants & Processing Payment Record list to Update");
        })
        
    }      
 
    updateWRtoPR(){
        console.log("=========== Inside updateWRtoPR ===========");
        //Create the list of Payment Records to be updated
        console.log(this.warrantsJPandLPArrayList);
        console.log(this.allPRsFromRightPayee);
        
        for(let l=0; l<this.allPRsFromRightPayee.length; l++){
            for(let m=0; m<this.warrantsJPandLPArrayList.length; m++){
                for(let n=0; n<this.warrantsJPandLPArrayList[m].PaymentRecordMap.length; n++){
                    console.log("Inside for loops PR, WR, JP");
                    if(this.warrantsJPandLPArrayList[m].PaymentRecordMap[n] == this.allPRsFromRightPayee[l].Id){
                        this.allPRsFromRightPayee[l].Warrant__c = this.warrantsJPandLPArrayList[m].WarrantId;
                        this.allPRsFromRightPayee[l].Batched_Under_Warrant__c = true;
                        this.prListToUpdate.push(this.allPRsFromRightPayee[l]);
                    }
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
            this.prSuccess = false;
            console.log("Error while updating Payment Records or while sending Email");
        })
    }

    sendEmailAboutWB(){
        console.log("=========== sendEmailAboutWB ===========");
        console.log(this.currIntEmpEmailId);
        this.toSend = this.toSend + ',' + this.currIntEmpEmailId;
        console.log(this.toSend);
        console.log(this.wbListInserted);
        var emailBody1;
        var emailBody2;
        
        for(let i=0; i<this.wbListInserted.length; i++){
            emailBody1 = this.sfdcBaseURL + '/' + this.wbListInserted[i].Id + '\r\n';
            emailBody2 = '<div style="font: bold 16px Arial; margin: 10px 0;">Warrants are created & Payment Records are updated successfully.</div>';
            this.body = this.body + emailBody1 + emailBody2;
        }
        console.log(this.body);

        sendEmailToController({body: this.body, toSend: this.toSend, subject: this.subject})
        .then( () => {
            //If response is ok
            console.log("Email Sent");
            this.emailSentSuccess = true;
            this.close();
            //window.location.replace(emailBody1);
        }).catch( error => {
            this.emailSentFailed = false;
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