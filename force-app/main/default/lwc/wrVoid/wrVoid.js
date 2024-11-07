import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import User_Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/WRVoidController.getUserInfo';
import getWarrantsCaseDetails from '@salesforce/apex/WRVoidController.getWarrantsCaseDetails';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Warrant_Object from '@salesforce/schema/Warrant__c';
import StatusComment_Field from '@salesforce/schema/Warrant__c.Status_Comment__c';
import Status_Field from '@salesforce/schema/Warrant__c.Status__c';
import updateWRandPRstatus from '@salesforce/apex/WRVoidController.updateWRandPRstatus';
import updatedWarrantBatch from '@salesforce/apex/WRVoidController.updatedWarrantBatch';
import getWarrantBatchDetails from '@salesforce/apex/WRVoidController.getWarrantBatchDetails';
//import updatePendCashBalOnCase from '@salesforce/apex/WBVoidController.updatePendCashBalOnCase';

const FIELDS = ['Warrant__c.Status__c'];

export default class wrVoid extends LightningElement {
    //Variable for Status bar
    @api recordId;
    @track wrVoided = false;
    @track wrCanceled = false;
    @track wrStopped = false;
    @track currStatus;
    @track error;

    //Variables for voiding
    @track isModalOpen = false;
    @track userDetails;
    @track selWrStatusOpts = [];
    @track doNotAllowUserVoid = true;

    @track recordTypeInfo;
    @track rtid_Warrant;
    @track rtid_WarrantApproved;
    @track rtid_MasterDefault;

    @track wrStatus;
    @track wrStatusOpts;
    @track wrStatusCmt;
    //@track showStatusCmt = false;
    @track wrData = [];
    @track pendingUpdated = false;
    @track buttonsDisabled = false;
    @track insuffData = false;
    @track updatedWRDetails;
    @track wbId;
    @track WBlink = '<div style="font: bold 16px Arial; margin: 10px 0;">Warrant Batch => Void Warrant Successful <br> The link to the Warrant Batch is: </div>';
    @track sfdcBaseURL;
    @track apxUpdCMlist;

    @wire (getRecord, {recordId: '$recordId', fields: FIELDS }) wrCurrStatus({error, data}){
        console.log("getRecord ===> ");
        if (error){
            this.error = error;
            console.log(error);
        }
        else if (data){
            this.currStatus = data.fields.Status__c.value;
            console.log(data);
            console.log(this.currStatus);
            if(this.currStatus == "Voided"){
                this.wrVoided = true;
                console.log(this.wbVoid);
            }
            else if(this.currStatus == "Canceled"){
                this.wrCanceled = true;
            }
            else if(this.currStatus == "Stopped"){
                this.wrStopped = true;
            }
            else{
                this.wrVoided = false;
                this.wrCanceled = false;
                this.wrStopped = false;
                console.log(this.wrVoided);
            }
        }
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
            this.doNotAllowUserVoid = false;
        }
        else{
            this.doNotAllowUserVoid = true;
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
            console.log("=========== Inside statusPicklist ===========");
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

    wrStatusChange(event){
        console.log("=========== Inside wrStatusChange ===========");
        this.wrStatus = event.detail.value;
        console.log(this.wrStatus);
        console.log("=========== End of wrStatusChange ===========");
    }

    wrStatusCmtChange(event){
        this.wrStatusCmt = event.detail.value;
        console.log(this.wrStatusCmt);
    }

    @wire (getWarrantsCaseDetails, {apxWrRecId:'$recordId'})
    warrantRecords({error,data}){
        console.log("=========== Inside getWarrantsCaseDetails ===========");
        if(data){
            console.log("Parent to Child ===> "+this.recordId);
            console.log("@ wire data ==> "+data);
            this.strWBlist = JSON.stringify(data);
            //console.log("strResult ==> "+this.strWBlist);
            this.wrData = data[0].warrantList;
            console.log("Warrant Details");
            console.log(this.wrData);
            this.wbId = this.wrData[0].Warrant_Batch__c;
            console.log("Warrant Batch Id");
            console.log(this.wbId);
            console.log("=========== End of @wire getWarrantsCaseDetails ===========");
        }
        else if(error){
            console.log(error);
            this.errormsg = error;
            console.log("@ wire this.errormsg ==> "+this.errormsg);
        }
    }

    voidStopCancelWR(){
        this.isModalOpen = true;
    }

    handleUpdateStatusClick(event){
        console.log("=========== Inside handleUpdateStatusClick ===========");
        this.buttonsDisabled = true;
        console.log(this.wrStatus);
        this.pendingUpdated = false;
        var wrPrList = JSON.parse(this.strWBlist);
        var wrList = wrPrList[0].warrantList;
        var prList = wrPrList[0].paymentRecList;
        console.log(wrList);
        console.log(prList);

        if(this.wrStatus == undefined){
            this.insuffData = true;
        }
        else if(this.wrStatus == "Voided" || this.wrStatus == "Canceled" || this.wrStatus == "Stopped"){
            this.insuffData = false;
            console.log("Change the status & Update the warrant");
            var apxUpdWRlist = [];
            var caseIds = [];
            var newDate = new Date();
            this.todayDate = newDate.toLocaleString();
            for (var i=0; i<wrList.length; i++){
                wrList[i].Status__c = this.wrStatus;
                wrList[i].Status_Comment__c = this.wrStatusCmt;
                wrList[i].Status_Date__c = this.todayDate;
                wrList[i].RecordTypeId = this.rtid_Warrant;
                apxUpdWRlist.push(wrList[i]);
            }

            console.log("Payment Records of selected Warrants with details, ready to update");
            console.log(prList);
            var apxUpdPRlist = [];
            for (var j=0; j<prList.length; j++){
                prList[j].Warrant_Issued__c = false;
                prList[j].Batched_Under_Warrant__c = false;
                prList[j].Warrant__c = null;
                prList[j].Secondary_Payee__c = null;
                apxUpdPRlist.push(prList[j]);
            }
            console.log("Updated WR List");
            console.log(apxUpdWRlist);
            console.log("Updated PR List");
            console.log(apxUpdPRlist);
            this.apxUpdCMlist = apxUpdWRlist[0].Case__c;
            console.log("Updated Case List");
            console.log(this.apxUpdCMlist);

            //Update the Warrants & Payment Records object
            updateWRandPRstatus({wrForUpdate: apxUpdWRlist, prForUpdate: apxUpdPRlist})
            .then(result =>{
                console.log("=========== Inside updateWRandPRstatus ===========");
                console.log("Result");
                console.log(result);
                if(result && this.insuffData == false){
                    console.log("Warrants & Payment Records updated successfully. Check and update the status of Warrant Batch");
                    
                    getWarrantBatchDetails({apxWbRecId: this.wbId})
                    .then(wbDetails =>{
                        console.log("=========== Inside getWarrantBatchDetails ===========");
                        console.log("getWarrantBatchDetails Result");
                        console.log(wbDetails);
                        this.updatedWRDetails = wbDetails[0].Warrant__r;
                        console.log("All Warrants in the Warrant Batch");
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
                        
                        if(this.updatedWRDetails.length == totalWR && approvedWR >= 1 && pendAppWR ==0 && printedWR == 0){
                            this.apxUpdWBlist = [];
                            var updWBlist = new Object();
                            updWBlist.Id = wbDetails[0].Id;
                            updWBlist.Status__c = "Review Complete";
                            this.apxUpdWBlist.push(updWBlist);
                            console.log("Updated WB List");
                            console.log(this.apxUpdWBlist);
                            this.updateWarrantBatchStatus();
                        }
                        else if(this.updatedWRDetails.length == voidedWR){
                            this.apxUpdWBlist = [];
                            var updWBlist = new Object();
                            updWBlist.Id = wbDetails[0].Id;
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
                            updWBlist.Id = wbDetails[0].Id;
                            updWBlist.Reviewed_By__c = this.currIntEmpId;
                            updWBlist.Status__c = "Printed";
                            this.apxUpdWBlist.push(updWBlist);
                            console.log("Updated WB List");
                            console.log(this.apxUpdWBlist);
                            this.updateWarrantBatchStatus();
                        }
                    })
                    .catch(error =>{
                        console.log("Error");
                    })

                    //this.pendingUpdated = true;
                    //console.log("Pending Updated");
                    //console.log(this.pendingUpdated);
                }
                else{
                    this.pendingUpdated = false;
                }
                console.log("=========== End updateWRandPRstatus ===========");
            })
            .catch(error =>{
                console.log("Error");
            })
        }
    }

    updateWarrantBatchStatus(){
        console.log("=========== Inside updateWarrantBatchStatus ===========");
        console.log("Updated WB List");
        console.log(this.apxUpdWBlist);
        this.wbToUpdate = JSON.parse(JSON.stringify(this.apxUpdWBlist));
        console.log("this.wbToUpdate");
        console.log(this.wbToUpdate);
        this.sfdcBaseURL  = window.location.origin;
        var emailWB = this.sfdcBaseURL + '/' + this.wbToUpdate[0].Id + '\r\n';
        this.WBlink = this.WBlink + emailWB;
        console.log(this.WBlink);
        console.log("this.apxUpdCMlist");
        console.log(this.apxUpdCMlist);
        updatedWarrantBatch({wbForUpdate: this.wbToUpdate, caseIds: this.apxUpdCMlist, wbLink: this.WBlink})
        .then(result =>{
            console.log("=========== Inside updatedWarrantBatch ===========");
            console.log("Result");
            console.log(result);
            if(result){
                this.pendingUpdated = true;
                console.log("Pending Updated");
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