import { LightningElement, api, track, wire} from 'lwc';
import User_Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/WBSecondaryApprovalController.getUserInfo';
import getInternalEmployeeInfo from '@salesforce/apex/WBSecondaryApprovalController.getInternalEmployeeInfo';
import getWarrantsCaseDetails from '@salesforce/apex/WBSecondaryApprovalController.getWarrantsCaseDetails';
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';
import Warrant_Object from '@salesforce/schema/Warrant__c';
import updatedWarrants from '@salesforce/apex/WBSecondaryApprovalController.updatedWarrants';
//import updatedWarrantBatch from '@salesforce/apex/WBSecondaryApprovalController.updatedWarrantBatch';

export default class WarrantApproval extends LightningElement {
    @api getwbid;
    //@track wbDetails;
    //@api voidReason;
    @track userDetails;
    @track wbDetails;
    @track wrDetails;
    @track strWBlist = 'Test';
    @track allowUserApprove;
    @track startRevWr = false;
    @track currUserReviewing;
    @track currIntEmpId;
    @track currWRid;
    @track wrReadytoApprove = true;
    @track wrListtoSecApprove = [];
    value = '';
    @track notApprovedTxt;
    @track approvalsUpdated = false;
    @track approvalsNotUpdated = false;
    @track wbApprovalUpdated = false;
    @track wbApprovalNotUpdated = false;
    @track sameApprover = false;

    @track totalWarrants = 0;
    @track totalPage = 0;
    @track page = 1;
    @track pageSize = 1;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pagination = false;
    @track prevPageBtn = true;
    @track nextPageBtn = false;
    @track pageDataItem = [];
    @track bulkReview = false;
    @track currentRevWrDetails;
    @track currAppRadBtnValue;
    @track currNotAppTxtValue;
    @track reasonNotApproved = true;
    @track undefinedNotAppCmt = true;
    @track finalWrrantUpd = false;
    @track allWRapproved = true;

    @track todayDate;
    @track recordTypeInfo;
    @track rtid_Warrant;
    @track rtid_WarrantApproved;
    @track rtid_MasterDefault;
    @track buttonsDisabled = false;
    @track updatedWBDetails;
    //@track updatedWRDetails;
    @track apxUpdWRlist;
    @track apxUpdWBlist;
    @track WBlink = '<div style="font: bold 16px Arial; margin: 10px 0;"> WB & WRs are Approved  => Succeeded. <br> The link to the Warrant Batch is: </div>';
    @track sfdcBaseURL;
    get approvalOptions(){
        return [
            {label: 'Yes', value: 'true'},
            {label: 'No', value: 'false'}
        ];
    }

    @wire(getObjectInfo, {objectApiName:Warrant_Object})
    warrantObjectInfo({error,data}){
        if(data){
            console.log("=========== Inside Record Type Infos ===========");
            console.log("data");
            console.log(data);
            var recordTypes;
            recordTypes = data.recordTypeInfos;
            this.recordTypeInfo = Object.values(recordTypes);
            console.log("record type infos")
            console.log(this.recordTypeInfo);
            for (var n=0; n<this.recordTypeInfo.length; n++){
                if (this.recordTypeInfo[n].name == "Warrant"){
                    this.rtid_Warrant = this.recordTypeInfo[n].recordTypeId;
                    console.log("Record Type is Warrant ==> ");
                    console.log(this.rtid_Warrant);
                }
                else if (this.recordTypeInfo[n].name == "Warrant Approved"){
                    this.rtid_WarrantApproved = this.recordTypeInfo[n].recordTypeId;
                    console.log("Record Type is Warrant Approved ==> ");
                    console.log(this.rtid_WarrantApproved);
                }
                else if (this.recordTypeInfo[n].name == "Master"){
                    this.rtid_MasterDefault = this.recordTypeInfo[n].recordTypeId;
                    console.log("Record Type is Master ==> ");
                    console.log(this.rtid_MasterDefault);
                }
            }
        }
    };

    @wire(getUserInfo,{userId: User_Id}) userData({error,data}){
        if(data){
            console.log("<=== User Info: ===> ");
            this.userDetails = data;
            console.log(this.userDetails);
            this.checkUserPermission(this.userDetails); 
        }
    };

    checkUserPermission(userDetails){
        console.log("=========== Inside checkUserPermission ===========");
        this.currUserReviewing = userDetails[0].Assignee.Name;
        console.log("currUserReviewing ==> "+this.currUserReviewing);
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
        if ((userPermissionNames.includes("Warrant_Batch_Approver")) || 
            (userProfileName == "System Administrator" || userProfileName == "System Administrator LTD")){
            this.allowUserApprove = true;
            console.log(this.allowUserApprove);
        }
        else{
            this.allowUserApprove = false;
            console.log(this.allowUserApprove);
        }
    }

    @wire(getInternalEmployeeInfo,{userId: User_Id}) intEmpData({error,data}){
        console.log("User_Id");
        console.log(User_Id);
        if(data){
            console.log("<=== Internal Employee Info: ===> ");
            this.InternalEmpDetails = data;
            console.log(this.InternalEmpDetails);
            for (var m=0; m<this.InternalEmpDetails.length; m++){
                if (this.InternalEmpDetails[m].Name == this.InternalEmpDetails[m].User__r.Name){
                    this.currIntEmpId = this.InternalEmpDetails[m].Id;
                }
            }
            console.log(this.currIntEmpId);
            
        }
    };

    @wire (getWarrantsCaseDetails, {apxWbRecId:'$getwbid'})
    warrantsCases({error,data}){
        if(data){
            console.log("Parent to Child ===> "+this.getwbid);
            console.log("@ wire data ==> "+data);
            this.strWBlist = JSON.stringify(data);
            //console.log("strWBlist ==> "+this.strWBlist)
            this.wbDetails = data[0].warrantBatch[0];
            console.log("wbDetails ==> ");
            console.log(this.wbDetails);
            this.wrDetails = data[0].warrantList;
            console.log("wrDetails ==> ");
            console.log(this.wrDetails);
        }
        else if(error){
            console.log(error);
            this.errormsg = error;
            console.log("@ wire this.errormsg ==> "+this.errormsg);
        }
    }

    handleBackClick(event){
        console.log("=========== Inside handleBackClick ===========");
        this.startRevWr = false;
        this.approvalsUpdated = false;
        this.approvalsNotUpdated = false;
    }

    handleAppRadBtnChange(event){
        if(event.target.value == "true"){
            this.currAppRadBtnValue = true;
        }
        else{
            this.currAppRadBtnValue = false;
        }
        console.log("=========== Inside handleAppRadBtnChange ===========");
        console.log(this.currAppRadBtnValue);
    }

    handleNotApproveTxtChange(event){
        this.currNotAppTxtValue = event.target.value;
        console.log("=========== Inside handleAppRadBtnChange ===========");
        console.log(this.currNotAppTxtValue);
        if(this.currNotAppTxtValue!=undefined){
            this.buttonsDisabled = false;
        }
    }

    //Review each Warrants
    handleRevEachWrClick(event){
        console.log("=========== Inside handleRevEachWrClick ===========");
        this.totalWarrants = 0;
        this.totalPage = 0;
        this.page = 1;
        this.startingRecord = 1;
        this.endingRecord = 0;
        this.bulkReview = false;
        this.finalWrrantUpd = false;
        this.wrListtoSecApprove = [];
        //Check if there are warrants pending for Approval
        console.log("Check if there are warrants pending for Approval");
        if(this.wrDetails.length == 0){
            this.wrReadytoApprove = false;
            this.startRevWr = false;
        }
        else{
            for (var i=0; i<this.wrDetails.length; i++){
                if(this.wrDetails[i].Status__c == "Secondary Approval Needed" && this.wrDetails[i].Amount__c >= 15000){
                    this.wrListtoSecApprove.push(this.wrDetails[i]);
                }
                else if(this.wrDetails[i].Status__c == "Secondary Approval Needed" || this.wrDetails[i].Status__c == "Not Approved"){
                    this.allWRapproved = false;
                }
            }
            this.wrListtoSecApprove = JSON.parse(JSON.stringify(this.wrListtoSecApprove));
            console.log(this.wrListtoSecApprove);

            if(this.wrListtoSecApprove.length == 0){
                this.wrReadytoApprove = false;
                this.startRevWr = false;
            }
            else{
                this.wrReadytoApprove = true;
                this.startRevWr = true;
            }
        }
        this.totalWarrants = this.wrListtoSecApprove.length;
        this.totalPage = this.wrListtoSecApprove.length;
        if(this.totalPage >= 1){
            this.pagination = true;
            this.pageDataItem = this.wrListtoSecApprove.slice(0,this.pageSize);
            this.currentRevWrDetails = this.pageDataItem[0];
            this.currAppRadBtnValue = this.currentRevWrDetails.Approved_Warrant__c;
            if(this.currentRevWrDetails.Not_Approved_Comments__c != undefined)
            {
                this.currNotAppTxtValue = this.currentRevWrDetails.Not_Approved_Comments__c;
                this.notApprovedTxt = true;
            }
            else{
                this.notApprovedTxt = false;
            }
            
            console.log("^^^^^^ PageDataItem ^^^^^^");
            console.log(this.pageDataItem[0]);
            console.log("^^^^^^ Not Approved text that Exists ^^^^^^");
            console.log(this.pageDataItem[0].Not_Approved_Comments__c);
            if(this.pageDataItem[0].Not_Approved_Comments__c == undefined){
                this.undefinedNotAppCmt = true;
            }
            else{
                this.undefinedNotAppCmt = false;
            }
            this.endingRecord = this.pageSize;
        }
        
    }

    ///clicking on previous button this method will be called
    previousHandler() {
        this.approvalsUpdated = false;
        this.approvalsNotUpdated = false;
        console.log("=========== Inside previousHandler ===========");
        console.log("Current Warrant Details => ");
        console.log(this.currentRevWrDetails);
        console.log(this.currAppRadBtnValue);
        console.log(this.currNotAppTxtValue);
        if(this.currIntEmpId == this.currentRevWrDetails.Approved_By__c){
            this.sameApprover = true;
        }
        else{
            this.sameApprover = false;
        }

        if(!this.sameApprover){
            if(this.currNotAppTxtValue == undefined && this.currAppRadBtnValue == false){
                this.reasonNotApproved = true;
            }
            else{
                this.reasonNotApproved = true;
            }

            console.log("* List of all warrants that needs to be approved *");
            console.log(this.wrListtoSecApprove);
            
            for (var i=0; i<this.wrListtoSecApprove.length; i++){
                if(this.currentRevWrDetails.Name == this.wrListtoSecApprove[i].Name){
                    if(this.currAppRadBtnValue != undefined){
                        this.wrListtoSecApprove[i].Approved_Warrant__c = this.currAppRadBtnValue;
                    }
                    if(this.currNotAppTxtValue != undefined){
                        this.wrListtoSecApprove[i].Not_Approved_Comments__c = this.currNotAppTxtValue;
                    }
                    else{
                        this.wrListtoSecApprove[i].Not_Approved_Comments__c = undefined;
                    }
                }
            }

            console.log("* List of updated warrants *");
            console.log(this.wrListtoSecApprove);

            this.currAppRadBtnValue = false;
            this.currNotAppTxtValue = " ";
            
            if (this.page > 1) {
                this.page = this.page - 1; //decrease page by 1
                this.displayRecordPerPage(this.page); 
                this.nextPageBtn = false;
                if(this.page==1){
                    this.prevPageBtn = true;
                } 
                else{
                    this.prevPageBtn = false;
                }
            }
            else{
                this.prevPageBtn = true;
                this.nextPageBtn = false;
            }
            this.currNotAppTxtValue = undefined;
        }   
    }

    //clicking on next button this method will be called
    nextHandler() {
        this.approvalsUpdated = false;
        this.approvalsNotUpdated = false;
        console.log("=========== Inside nextHandler ===========");
        console.log("Current Warrant Details => ");
        console.log(this.currentRevWrDetails);
        console.log(this.currAppRadBtnValue);
        console.log(this.currNotAppTxtValue);

        if(this.currIntEmpId == this.currentRevWrDetails.Approved_By__c){
            this.sameApprover = true;
        }
        else{
            this.sameApprover = false;
        }

        if(!this.sameApprover){
            if(this.currNotAppTxtValue == undefined && this.currAppRadBtnValue == false && this.notApprovedTxt == false){
                this.reasonNotApproved = false;
            }
            else{
                this.reasonNotApproved = true;
            }
            
            if(this.reasonNotApproved){
                console.log("* List of all warrants that needs to be Secondary approved *");
                console.log(this.wrListtoSecApprove);
                
                for (var i=0; i<this.wrListtoSecApprove.length; i++){
                    if(this.currentRevWrDetails.Name == this.wrListtoSecApprove[i].Name){
                        if(this.currAppRadBtnValue != undefined){
                            this.wrListtoSecApprove[i].Approved_Warrant__c = this.currAppRadBtnValue;
                        }
                        if(this.currNotAppTxtValue != undefined && this.currAppRadBtnValue == false){
                            this.wrListtoSecApprove[i].Not_Approved_Comments__c = this.currNotAppTxtValue;
                        }
                        else{
                            this.wrListtoSecApprove[i].Not_Approved_Comments__c = undefined;
                        }
                    }
                }

                console.log("* List of updated warrants *");
                console.log(this.wrListtoSecApprove);
                
                if((this.page<this.totalPage) && this.page !== this.totalPage){
                    this.page = this.page + 1; //increase page by 1
                    this.displayRecordPerPage(this.page);    
                    this.prevPageBtn = false;
                    if(this.page==this.totalPage){
                        //this.nextPageBtn = true;
                    } 
                    else{
                        this.nextPageBtn = false;
                        this.finalWrrantUpd = false;
                    }     
                }
                else{
                    //this.nextPageBtn = true;
                    this.finalWrrantUpd = true;
                    this.prevPageBtn = false;
                }            
            }
            this.currNotAppTxtValue = undefined;
        }
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        console.log("=========== Inside displayRecordPerPage ===========");
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalWarrants) 
                            ? this.totalWarrants : this.endingRecord; 

        console.log("________ warrant list approve ________");
        console.log(this.wrListtoSecApprove);

        this.pageDataItem = this.wrListtoSecApprove.slice(this.startingRecord, this.endingRecord);
        this.currentRevWrDetails = this.pageDataItem[0];
        this.currAppRadBtnValue = this.currentRevWrDetails.Approved_Warrant__c;
        if(this.currentRevWrDetails.Not_Approved_Comments__c != undefined){
            this.currNotAppTxtValue = this.currentRevWrDetails.Not_Approved_Comments__c;
            this.notApprovedTxt = true;
        }
        else{
            this.notApprovedTxt = false;
        }
        console.log("^^^^^^ PageDataItem ^^^^^^");
        console.log(this.pageDataItem[0]);
        console.log("^^^^^^ Approved Check True or False ^^^^^^");
        console.log(this.pageDataItem[0].Approved_Warrant__c);
        console.log("^^^^^^ Not Approved text that Exists ^^^^^^");
        console.log(this.pageDataItem[0].Not_Approved_Comments__c);
        if(this.pageDataItem[0].Not_Approved_Comments__c == undefined && this.pageDataItem[0].Approved_Warrant__c == false){
            this.undefinedNotAppCmt = true;
        }
        else{
            this.undefinedNotAppCmt = false;
        }

        this.startingRecord = this.startingRecord + 1;
    }

    //Update all reviewed Warrants
    handleEndWarrantUpdate(){
        console.log("=========== Inside handleEndWarrantUpdate ===========");
        this.buttonsDisabled = true;
        this.approvalsUpdated = false;
        this.approvalsNotUpdated = false;
        
        console.log("List of warrants that needs to be updated");
        this.apxUpdWRlist = [];
        var newDate = new Date();
        this.todayDate = newDate.toLocaleString();
        console.log(this.wrListtoSecApprove);
        for(let k=0; k<this.wrListtoSecApprove.length; k++){
            if(this.wrListtoSecApprove[k].Approved_Warrant__c == true){
                this.wrListtoSecApprove[k].Status__c = "Approved";
                this.wrListtoSecApprove[k].Secondary_Approver__c = this.currIntEmpId;
                this.wrListtoSecApprove[k].Secondary_Approval_Date__c = this.todayDate;
                this.wrListtoSecApprove[k].Status_Date__c = this.todayDate;
                this.wrListtoSecApprove[k].RecordTypeId = this.rtid_WarrantApproved;
                if(this.wrListtoSecApprove[k].Secondary_Approver__c == this.wrListtoSecApprove[k].Approved_By__c){
                    console.log("Same Approver");
                    this.sameApprover = true;
                    //apxUpdWRlist.push(this.wrListtoSecApprove[k]);
                }
                else{
                    console.log("Not Same Approver");
                    console.log(this.wrListtoSecApprove[k]);
                    this.apxUpdWRlist.push(this.wrListtoSecApprove[k]);
                }
            }
            else if(this.wrListtoSecApprove[k].Approved_Warrant__c == false && this.wrListtoSecApprove[k].Not_Approved_Comments__c != undefined){
                this.wrListtoSecApprove[k].Status__c = "NotApproved";
                this.wrListtoSecApprove[k].Secondary_Approver__c = this.currIntEmpId;
                this.wrListtoSecApprove[k].Secondary_Approval_Date__c = this.todayDate;
                this.wrListtoSecApprove[k].Status_Date__c = this.todayDate;
                this.wrListtoSecApprove[k].RecordTypeId = this.rtid_WarrantApproved;
                if(this.wrListtoSecApprove[k].Secondary_Approver__c == this.wrListtoSecApprove[k].Approved_By__c){
                    console.log("Same Approver");
                    this.sameApprover = true;
                    //apxUpdWRlist.push(this.wrListtoSecApprove[k]);
                }
                else{
                    console.log("Not Same Approver");
                    console.log(this.wrListtoSecApprove[k]);
                    this.apxUpdWRlist.push(this.wrListtoSecApprove[k]);
                }
            }
            
        }

        console.log("Warrant Batch that needs to be updated");
        for(let n=0; n<this.wrListtoSecApprove.length; n++){
            if(this.wrListtoSecApprove[n].Approved_Warrant__c == false){
                this.allWRapproved = false;
                break;
            }
        }

        console.log("Updated WR List");
        console.log(this.apxUpdWRlist);

        console.log("Check if all Warrants are Approved/Void");
        var approvedWR = 0;
        var voidedWR = 0;
        var pendingWR = 0;
        var notApproved = 0;
        var secApproval = 0;
        console.log("secApproval" );
        console.log(secApproval);
        console.log("Warrant For loop" );
        console.log(this.wrDetails);
        for(let n=0; n<this.wrDetails.length; n++){
            console.log("wrDetails for loop" );
            var ifequal = 0;
            for(let p=0; p<this.wrListtoSecApprove.length; p++){
                console.log("wrListtoSecApprove for loop" );
                if(this.wrListtoSecApprove[p].Id == this.wrDetails[n].Id){
                    console.log("WR Id Equal" );
                    ifequal = 1;
                    if(this.wrListtoSecApprove[p].Status__c == "Approved"){
                        approvedWR = approvedWR + 1;
                    }
                    else if(this.wrListtoSecApprove[p].Status__c == "Voided"){
                        voidedWR = voidedWR + 1;
                    }
                    else if(this.wrListtoSecApprove[p].Status__c == "Pending Approval"){
                        pendingWR = pendingWR + 1;
                    }
                    else if(this.wrListtoSecApprove[p].Status__c == "Not Approved"){
                        notApproved = notApproved + 1;
                    }
                    else if(this.wrListtoSecApprove[p].Status__c == "Secondary Approval Needed"){
                        secApproval = secApproval + 1;
                    }
                }
            }
            if(ifequal == 0){
                console.log("WR Id Equal" );
                if(this.wrDetails[n].Status__c == "Approved"){
                    approvedWR = approvedWR + 1;
                }
                else if(this.wrDetails[n].Status__c == "Voided"){
                    voidedWR = voidedWR + 1;
                }
                else if(this.wrDetails[n].Status__c == "Pending Approval"){
                    pendingWR = pendingWR + 1;
                }
                else if(this.wrDetails[n].Status__c == "Not Approved"){
                    notApproved = notApproved + 1;
                }
                else if(this.wrDetails[n].Status__c == "Secondary Approval Needed"){
                    secApproval = secApproval + 1;
                }
            }
        }
        var revCompleteWR = approvedWR + voidedWR;
        var undReviewWR = notApproved + secApproval + pendingWR;
        var pendApprovalWR = pendingWR;
        var voidWB = voidedWR;
        console.log("revCompleteWR");
        console.log(revCompleteWR);
        if(this.wrDetails.length == revCompleteWR){
            console.log("Review Complete");
            this.apxUpdWBlist = [];
            console.log(this.wbDetails);
            var updWBlist = new Object();
            updWBlist.Id = this.wbDetails.Id;
            updWBlist.Status__c = "Review Complete";
            this.apxUpdWBlist.push(updWBlist);
            console.log("Updated WB List");
            console.log(this.apxUpdWBlist);
            //this.updateWarrantBatchStatus();
        }
        else if(undReviewWR > 0){
            console.log("Under Review");
            this.apxUpdWBlist = [];
            console.log(this.wbDetails);
            var updWBlist = new Object();
            updWBlist.Id = this.wbDetails.Id;
            updWBlist.Status__c = "Under Review";
            this.apxUpdWBlist.push(updWBlist);
            console.log("Updated WB List");
            console.log(this.apxUpdWBlist);
            //this.updateWarrantBatchStatus();
        }
        else if(this.wrDetails.length == pendApprovalWR){
            console.log("Pending Approval");
            this.apxUpdWBlist = [];
            console.log(this.wbDetails);
            var updWBlist = new Object();
            updWBlist.Id = this.wbDetails.Id;
            updWBlist.Status__c = "Pending Approval";
            this.apxUpdWBlist.push(updWBlist);
            console.log("Updated WB List");
            console.log(this.apxUpdWBlist);
            //this.updateWarrantBatchStatus();
        }
        else if(this.wrDetails.length == voidWB){
            console.log("Void");
            this.apxUpdWBlist = [];
            console.log(this.wbDetails);
            var updWBlist = new Object();
            updWBlist.Id = this.wbDetails.Id;
            updWBlist.Status__c = "Void";
            this.apxUpdWBlist.push(updWBlist);
            console.log("Updated WB List");
            console.log(this.apxUpdWBlist);
            //this.updateWarrantBatchStatus();
        }

        console.log("Updated WB List");
        console.log(this.apxUpdWBlist);

        this.updateWarrantStatus();
        
    }

    updateWarrantStatus(){
        console.log("Updated WR List");
        console.log(this.apxUpdWRlist);
        console.log("Updated WB List");
        console.log(this.apxUpdWBlist);
        this.sfdcBaseURL  = window.location.origin;
        var emailWB = this.sfdcBaseURL + '/' + this.apxUpdWBlist[0].Id + '\r\n';
        this.WBlink = this.WBlink + emailWB;
        console.log(this.WBlink);
        console.log("=========== Inside updateWarrantStatus ===========");
        updatedWarrants({wrForUpdate: this.apxUpdWRlist, wbForUpdate: this.apxUpdWBlist, wbLink: this.WBlink})
        .then(result =>{
            console.log("Result");
            console.log(result);
            if(result){
                this.approvalsUpdated = true;
            }
            else{
                this.approvalsNotUpdated = true;
            }
        })
        .catch(error =>{
            console.log("Error while updating Warrants");
        })
    }

    /*
    updateWarrantBatchStatus(){
        console.log("Updated WB List");
        console.log(this.apxUpdWBlist);
        console.log("=========== Inside updateWarrantBatchStatus ===========");
        updatedWarrantBatch({wbForUpdate: JSON.parse(JSON.stringify(this.apxUpdWBlist))})
        .then(result =>{
            console.log("result");
            console.log(result);
            if(result){
                this.wbApprovalUpdated = true;
            }
            else{
                this.wbApprovalNotUpdated = true;
            }
        })
        .catch(error =>{
            console.log("Error while updating Warrant Batch");
        })
    }
    */
    /*
    //Review Warrants in Bulk
    handleBlkRevWrClick(event){
        console.log("=========== Inside handleBlkRevWrClick ===========");
        this.buttonsDisabled = true;
        this.bulkReview = true;
        //Check if there are warrants pending for Approval
        console.log("Check if there are warrants pending for Secondary Approval");
        if(this.wrDetails.length == 0){
            this.wrReadytoApprove = false;
            this.startRevWr = false;
        }
        else{
            for (var i=0; i<this.wrDetails.length; i++){
                if(this.wrDetails[i].Status__c == "Pending Approval"){
                    this.wrListtoSecApprove.push(this.wrDetails[i]);
                }
            }
            console.log(this.wrListtoSecApprove);
            if(this.wrListtoSecApprove.length == 0){
                this.wrReadytoApprove = false;
                this.startRevWr = false;
            }
            else{
                this.wrReadytoApprove = true;
                this.startRevWr = true;
            }
        }
    }
    */

}