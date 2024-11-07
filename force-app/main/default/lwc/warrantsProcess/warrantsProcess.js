import { LightningElement, wire, track, api} from 'lwc';
import User_Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/WarrantsProcessController.getUserInfo';
import getWarrantsCaseDetails from '@salesforce/apex/WarrantsProcessController.getWarrantsCaseDetails';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Warrant_Object from '@salesforce/schema/Warrant__c';
import StatusComment_Field from '@salesforce/schema/Warrant__c.Status_Comment__c';
import Status_Field from '@salesforce/schema/Warrant__c.Status__c';
import updateWRandPRstatus from '@salesforce/apex/WarrantsProcessController.updateWRandPRstatus';
import updatedWarrantBatch from '@salesforce/apex/WarrantsProcessController.updatedWarrantBatch';
import getWarrantBatchDetails from '@salesforce/apex/WarrantsProcessController.getWarrantBatchDetails';
//import updatePendCashBalOnCase from '@salesforce/apex/WarrantsProcessController.updatePendCashBalOnCase';

export default class WarrantsProcess extends LightningElement {
    @api getwbid;
    @track userDetails;
    @track strWBlist = 'Test';
    @track allowUserVoid;

    @track showStatusCmt = false;
    @track showApproveForm = false;

    @track wrData = [];
    @track pageDataItem = [];
    @track errormsg = null;
    @track isModalOpen = false;
    @track wrStatusOpts;
    @track selWrStatusOpts = [];

    @track page = 1;
    @track pageSize = 10;
    @track totalPage = 0;
    @track totalRecCount = 0;
    @track startingRecord = 1;
    @track endingRecord = 0;

    @track selectedWarrants;
    @track wrStatus;
    @track wrStatusCmt;
    @track insuffData = false;
    @track noWrSelected = false;
    @track noWRselectedNext = true;
    @track noWRselectedPrev = true;
    @track sfdcBaseURL;
    @track wrLink;
    @track pendingUpdated = false;

    @track recordTypeInfo;
    @track rtid_Warrant;
    @track rtid_WarrantApproved;
    @track rtid_MasterDefault;

    @track pagination = false;
    @track prevPageBtn = true;
    @track nextPageBtn = false;
    @track buttonsDisabled = false;
    @track updatedWRDetails;
    @track selWRlist = [];
    @track wbToUpdate;
    @track WBlink = '<div style="font: bold 16px Arial; margin: 10px 0;">Warrant Void under Warrant Batch=> Successful <br> The link to the Warrant Batch is: </div>';
    @track sfdcBaseURL;

    //Approval radio button options
    appRadBtnValue = '';
    get approvalOptions(){
        return [
            {label: 'Yes', value: true},
            {label: 'No', value: false}
        ];
    }
    @track notApprovedTxt;

    //Get the salesforce base URL for the current page
    renderedCallback(){
        this.sfdcBaseURL = window.location.origin;
        console.log("Base URL");
        console.log(this.sfdcBaseURL);
    }

    //Check User Permission
    @wire(getUserInfo,{userId: User_Id}) userData({error,data}){
        if(data){
            console.log("User Info: warrantsProcess ===> ");
            this.userDetails = data;
            console.log(this.userDetails);
            this.checkUserPermission(this.userDetails); 
        }
    };
    
    checkUserPermission(userDetails){
        console.log("********* Check User Permissions - warrantsProcess ***********");
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

    //Record Type IDs details
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

    // to get the default record type id for the picklist
    @wire(getObjectInfo, { objectApiName: Warrant_Object })
    warrantsMetadata;

    // now get the Status__c picklist values
    @wire(getPicklistValues,
        {
            recordTypeId: '$warrantsMetadata.data.defaultRecordTypeId', 
            fieldApiName: Status_Field
        }
    )
    statusPicklist({error, data}){
        if(data){
            this.wrStatusOpts = data.values;
            console.log("Warrants Status Options")
            console.log(this.wrStatusOpts);
            for(let i = 0; i < this.wrStatusOpts.length; i++) {
                if(this.wrStatusOpts[i].value == 'Voided' || this.wrStatusOpts[i].value == 'Canceled' || this.wrStatusOpts[i].value == 'Stopped') {
                    this.selWrStatusOpts.push(this.wrStatusOpts[i]);
                    console.log(this.selWrStatusOpts);
                }
            }
        }
    };

    // now get the Status_Comment__c picklist values
    @wire(getPicklistValues,
        {
            recordTypeId: '$warrantsMetadata.data.defaultRecordTypeId', 
            fieldApiName: StatusComment_Field
        }
    )
    statusCommentPicklist;

    @wire (getWarrantsCaseDetails, {apxWbRecId:'$getwbid'})
    warrantRecords({error,data}){
        if(data){
            console.log("Parent to Child ===> "+this.getwbid);
            console.log("@ wire data ==> "+data);
            this.strWBlist = JSON.stringify(data);
            console.log("strResult ==> "+this.strWBlist);
            this.wrData = JSON.parse(JSON.stringify(data[0].warrantList));
            for(let i = 0; i < this.wrData.length; i++) {
                this.wrLink = this.sfdcBaseURL + '/' + this.wrData[i].Id + '\r\n';
                this.wrData[i].wrLink = this.wrLink;
            }
            console.log(this.wrData);
            this.totalRecCount = this.wrData.length;
            this.totalPage = Math.ceil(this.totalRecCount/this.pageSize);
            if(this.totalPage > 1){
                this.pagination = true;
            }
            this.pageDataItem = this.wrData.slice(0, this.pageSize);
            this.endingRecord = this.pageSize;
            if(this.wrData == undefined || this.wrData == null){
                this.errormsg = "There is no Warrants under this Warrant Batch";
            }
            this.errormsg = undefined;
            console.log("@ wire this.wrData ==> "+this.wrData);

            
        }
        else if(error){
            console.log(error);
            this.errormsg = error;
            console.log("@ wire this.errormsg ==> "+this.errormsg);
        }
    }

    //clicking on previous button this method will be called
    previousHandler() {
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
        
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);    
            this.prevPageBtn = false;
            if(this.page==this.totalPage){
                this.nextPageBtn = true;
            } 
            else{
                this.nextPageBtn = false;
            }     
        }
        else{
            this.nextPageBtn = true;
            this.prevPageBtn = false;
        }  
        
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecCount) 
                            ? this.totalRecCount : this.endingRecord; 

        this.pageDataItem = this.wrData.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }    

    allSelected(event){
        let selectedRows = this.template.querySelectorAll('lightning-input');
        
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
            }
        }
    }

    updateWarrantsHandler(){  
        this.selectedWarrants = [];
        let selectedRows = this.template.querySelectorAll('lightning-input');
        // based on selected row getting values of the warrants
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].checked && selectedRows[i].type === 'checkbox') {
                console.log(selectedRows[i].dataset);
                this.selectedWarrants.push({
                    Name: selectedRows[i].value,
                    Id: selectedRows[i].dataset.id
                })
            }
        } 
        console.log("Selected Warrants to Update");
        console.log(this.selectedWarrants);
        if(this.selectedWarrants.length == 0){
            this.noWrSelected = true;
        }
        else{
            this.noWrSelected = false;
            this.isModalOpen = true;
        }
    }

    wrStatusChange(event){
        this.wrStatus = event.detail.value;
        console.log(this.wrStatus);
        if(this.wrStatus == "Voided" || this.wrStatus == "Canceled" || this.wrStatus == "Stopped"){
            this.showStatusCmt = true;
            this.showApproveForm = false;
        }
        else if(this.wrStatus == "Approved" || this.wrStatus == "Not Approved"){
            this.showApproveForm = true;
            this.showStatusCmt = false;
        }
    }

    wrStatusCmtChange(event){
        this.wrStatusCmt = event.detail.value;
        console.log(this.wrStatusCmt);
    }

    handleAppRadBtnChange(event){
        this.appRadBtnValue = event.target.value;
    }

    handleNotApproveTxtChange(event){
        this.notApprovedTxt = event.target.value;
    }

    handleUpdateStatusClick(event){
        console.log("=========== Inside handleUpdateStatusClick ===========");
        this.buttonsDisabled = true;
        console.log(this.wrStatus);
        this.pendingUpdated = false;
        var WbWrPrList = JSON.parse(this.strWBlist);
        console.log(WbWrPrList);
        var WBlist = WbWrPrList[0].warrantBatch[0];
        var WRlist = WbWrPrList[0].warrantList;
        var PRlist = WbWrPrList[0].paymentRecList;
        console.log(WBlist);
        console.log(WRlist);
        console.log(PRlist);

        if(this.wrStatus == undefined){
            this.insuffData = true;
        }
        else if(this.wrStatus == "Voided" || this.wrStatus == "Canceled" || this.wrStatus == "Stopped"){
            this.insuffData = false;
            // Selected Warrant List with complete details 
            
            for (var i=0; i<WRlist.length; i++){
                for(var j=0; j<this.selectedWarrants.length; j++){
                    if(WRlist[i].Id == this.selectedWarrants[j].Id){
                        this.selWRlist.push(WRlist[i]);
                    }
                }
            }
            console.log("Selected Warrants with details, ready to update");
            console.log(this.selWRlist);
            console.log("Change the status & create a list of WR separately");
            var apxUpdWRlist = [];
            var caseIds = [];
            var newDate = new Date();
            this.todayDate = newDate.toLocaleString();
            for (var i=0; i<this.selWRlist.length; i++){
                this.selWRlist[i].Status__c = this.wrStatus;
                this.selWRlist[i].Status_Comment__c = this.wrStatusCmt;
                this.selWRlist[i].Status_Date__c = this.todayDate;
                this.selWRlist[i].RecordTypeId = this.rtid_Warrant;
                //this.selWRlist[i].Payee__c = null; //Payee should be there on voided/stopped/cancelled warrants for audit purpose.
                apxUpdWRlist.push(this.selWRlist[i]);
                //Get the case list
                caseIds.push(this.selWRlist[i].Case__c);
            }
            console.log(caseIds);
            this.uniqueCaseIds = [...new Set(caseIds)];
            console.log(this.uniqueCaseIds);

            //Update Case pending cash balance 
            this.apxUpdCMlist = [];
            var pendBal = 0.00;
            var totPendBal = 0.00;
            for(let m=0; m<this.uniqueCaseIds.length; m++){
                pendBal = 0.00;
                totPendBal = 0.00;
                for(let n=0; n<this.selWRlist.length; n++){
                    if(this.uniqueCaseIds[m] == this.selWRlist[n].Case__c){
                        if(this.selWRlist[n].Case__r.Warrants_Pending__c > 0){
                            totPendBal = this.selWRlist[n].Case__r.Warrants_Pending__c;
                        }
                        else{
                            totPendBal = 0.00;
                        }
                        
                        if(this.selWRlist[n].Status__c != "Printed" && this.selWRlist[n].Case__r.Warrants_Pending__c >= this.selWRlist[n].Amount__c){
                            pendBal = pendBal + this.selWRlist[n].Amount__c;
                        }
                    }
                }
                //Update the CM
                console.log(totPendBal);
                console.log(pendBal);
                var caseWRlist = {};
                caseWRlist.Id = this.uniqueCaseIds[m];
                if((totPendBal - pendBal).toFixed(2)>0.00){
                    caseWRlist.Warrants_Pending__c = (totPendBal - pendBal).toFixed(2);
                }
                else{
                    caseWRlist.Warrants_Pending__c = 0.00;
                }
                
                this.apxUpdCMlist.push(caseWRlist);
            }

            // Selected Payment Record List complete details
            var selPRlist = [];
            for (var i=0; i<PRlist.length; i++){
                for(var j=0; j<this.selectedWarrants.length; j++){
                    if(PRlist[i].Warrant__r.Id == this.selectedWarrants[j].Id){
                        selPRlist.push(PRlist[i]);
                    }
                }
            }
            console.log("Payment Recorde of selected Warrants with details, ready to update");
            console.log(selPRlist);
            console.log("Change the status & create a list of PR separately");
            console.log(PRlist);
            var apxUpdPRlist = [];
            for (var j=0; j<selPRlist.length; j++){
                selPRlist[j].Warrant_Issued__c = false;
                selPRlist[j].Batched_Under_Warrant__c = false;
                selPRlist[j].Warrant__c = null;
                apxUpdPRlist.push(selPRlist[j]);
            }

            console.log("Updated WR List");
            console.log(apxUpdWRlist);
            console.log("Updated PR List");
            console.log(apxUpdPRlist);
            console.log("Updated Case List");
            console.log(this.apxUpdCMlist);

            

            this.sfdcBaseURL  = window.location.origin;
            var emailWB = this.sfdcBaseURL + '/' + this.getwbid + '\r\n';
            this.WBlink = this.WBlink + emailWB;
            console.log(this.WBlink);

            //Update the Warrants & Payment Records object
            updateWRandPRstatus({wrForUpdate: apxUpdWRlist, prForUpdate: apxUpdPRlist})
            .then(WRandPRupdate =>{
                console.log("=========== Inside updateWRandPRstatus ===========");
                console.log("WRandPRupdate Result");
                console.log(WRandPRupdate);
                if(WRandPRupdate && this.insuffData == false){
                    console.log("Warrants updated successfully. Check and update the status of Warrant Batch");

                    getWarrantBatchDetails({apxWbRecId: this.getwbid})
                    .then(wbDetails =>{
                        console.log("=========== Inside getWarrantBatchDetails ===========");
                        console.log("wbDetails Result");
                        console.log(wbDetails);
                        this.updatedWBDetails = wbDetails[0];
                        console.log("wbDetails ==> ");
                        console.log(this.updatedWBDetails);
                        this.updatedWRDetails = wbDetails[0].Warrant__r;
                        console.log("wrDetails ==> ");
                        console.log(this.updatedWRDetails);

                        console.log("Check if all Warrants are Approved/Void");
                        var voidedWR = 0;
                        var pendAppWR = 0;
                        var approvedWR = 0;
                        var printedWR = 0;
                        var totalWR = 0;
                        for(let n=0; n<this.updatedWRDetails.length; n++){
                            if(this.updatedWRDetails[n].Status__c == "Voided" || this.updatedWRDetails[n].Status__c == "Canceled" || this.updatedWRDetails[n].Status__c == "Stopped"){
                                voidedWR = voidedWR + 1;
                            }
                            else if(this.updatedWRDetails[n].Status__c == "Approved"){
                                approvedWR = approvedWR + 1;
                            }
                            else if(this.updatedWRDetails[n].Status__c == "Printed"){
                                printedWR = printedWR + 1;
                            }
                            else{
                                pendAppWR = pendAppWR + 1;
                            }
                        }
                        totalWR = pendAppWR + voidedWR + approvedWR +printedWR;
                        console.log(pendAppWR);
                        console.log(voidedWR);
                        console.log(approvedWR);
                        console.log(printedWR);
                        
                        if(this.updatedWRDetails.length == totalWR && approvedWR >= 1 && pendAppWR ==0 && printedWR == 0){
                            this.apxUpdWBlist = [];
                            var updWBlist = new Object();
                            updWBlist.Id = this.getwbid;
                            updWBlist.Reviewed_By__c = this.currIntEmpId;
                            updWBlist.Status__c = "Review Complete";
                            this.apxUpdWBlist.push(updWBlist);
                            console.log("Updated WB List");
                            console.log(this.apxUpdWBlist);
                            this.updateWarrantBatchStatus();
                        }
                        else if(this.updatedWRDetails.length == voidedWR){
                            this.apxUpdWBlist = [];
                            var updWBlist = new Object();
                            updWBlist.Id = this.getwbid;
                            updWBlist.Reviewed_By__c = this.currIntEmpId;
                            updWBlist.Status__c = "Void";
                            updWBlist.Void_Reason__c = "No Valid Warrants";
                            this.apxUpdWBlist.push(updWBlist);
                            console.log("Updated WB List");
                            console.log(this.apxUpdWBlist);
                            this.updateWarrantBatchStatus();
                        }
                        else if(this.updatedWRDetails.length == totalWR && pendAppWR >= 1 && totalWR != (pendAppWR+voidedWR)){
                            this.apxUpdWBlist = [];
                            var updWBlist = new Object();
                            updWBlist.Id = wbDetails[0].Id;
                            updWBlist.Reviewed_By__c = this.currIntEmpId;
                            updWBlist.Status__c = "Under Review";
                            this.apxUpdWBlist.push(updWBlist);
                            console.log("Updated WB List");
                            console.log(this.apxUpdWBlist);
                            this.updateWarrantBatchStatus();
                        }
                        else if(totalWR == (pendAppWR+voidedWR)){
                            this.apxUpdWBlist = [];
                            var updWBlist = new Object();
                            updWBlist.Id = wbDetails[0].Id;
                            updWBlist.Reviewed_By__c = this.currIntEmpId;
                            updWBlist.Status__c = "Pending Approval";
                            this.apxUpdWBlist.push(updWBlist);
                            console.log("Updated WB List");
                            console.log(this.apxUpdWBlist);
                            this.updateWarrantBatchStatus();
                        }
                        else if(this.updatedWRDetails.length == totalWR && printedWR >= 1 && pendAppWR == 0 && approvedWR ==0){
                            this.apxUpdWBlist = [];
                            var updWBlist = new Object();
                            updWBlist.Id = this.getwbid;
                            updWBlist.Reviewed_By__c = this.currIntEmpId;
                            updWBlist.Status__c = "Printed";
                            this.apxUpdWBlist.push(updWBlist);
                            console.log("Updated WB List");
                            console.log(this.apxUpdWBlist);
                            this.updateWarrantBatchStatus();
                        }
                        
                    })
                    
                    this.noWRselectedPrev = true;
                    this.noWRselectedNext = true;

                    //component.find("checkboxSel").set("v.checked", false);
                }
                else{
                    this.pendingUpdated = false;
                }
            })
            .catch(error =>{
                console.log("Error");
            })
           
        }
        else if(this.wrStatus == "Approved" || this.wrStatus == "Not Approved"){
            this.insuffData = false;
            console.log("Not Approved Text");
            console.log(this.notApprovedTxt);
            console.log("Approve Radio Button");
            console.log(this.appRadBtnValue);
            if(this.appRadBtnValue == false){
                console.log("All Warrants selected are not Approved");
            }
            else if(this.appRadBtnValue == true){
                console.log("All Warrants selected are Approved");

            }
        }
    }

    updateWarrantBatchStatus(){
        console.log("Updated WB List");
        console.log(this.apxUpdWBlist);
        this.wbToUpdate = JSON.parse(JSON.stringify(this.apxUpdWBlist));
        console.log("this.wbToUpdate");
        console.log(this.WBlink);
        console.log("this.uniqueCaseIds");
        console.log(this.uniqueCaseIds);
        console.log("=========== Inside updateWarrantBatchStatus ===========");
        updatedWarrantBatch({wbForUpdate: this.wbToUpdate, caseIds: this.uniqueCaseIds, wbLink: this.WBlink})
        .then(result =>{
            console.log("=========== Inside updatedWarrantBatch ===========");
            if(result){
                console.log("Result");
                console.log(result);
                this.pendingUpdated = true;
                console.log("Pending Updated");
                console.log(this.pendingUpdated);
            }
            else{
                this.pendingUpdated = false;
            }
        })
        .catch(error =>{
            console.log("Error while updating Warrant Batch");
        })
    }

    closeModal() {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen track value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }
}