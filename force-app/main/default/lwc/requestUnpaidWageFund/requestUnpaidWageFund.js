import { LightningElement, api, wire, track} from 'lwc';
import User_Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/RequestUnpaidWageFundController.getUserInfo';
import getInternalEmployeeInfo from '@salesforce/apex/RequestUnpaidWageFundController.getInternalEmployeeInfo';
import getPayeeDetails from '@salesforce/apex/RequestUnpaidWageFundController.getPayeeDetails';
import getBOFECaseDetails from '@salesforce/apex/RequestUnpaidWageFundController.getBOFECaseDetails';
//import getWCAOfficeAccountDetails from '@salesforce/apex/RequestUnpaidWageFundController.getWCAOfficeAccountDetails'; 
import getWCAOfficeDetails from '@salesforce/apex/RequestUnpaidWageFundController.getWCAOfficeDetails'; 
import getWCACaseDetails from '@salesforce/apex/RequestUnpaidWageFundController.getWCACaseDetails';
import oaOwnerId from '@salesforce/apex/RequestUnpaidWageFundController.getOAowner';
import getUwfAccountID from '@salesforce/apex/RequestUnpaidWageFundController.getuwfAccountID';
import insertWB from '@salesforce/apex/RequestUnpaidWageFundController.insertWarrantBatch';
import sendEmailToController from '@salesforce/apex/RequestUnpaidWageFundController.sendEmailToController';
import insertUWFCaseRole from '@salesforce/apex/RequestUnpaidWageFundController.insertUWFCaseRole';
import insertUWFPayee from '@salesforce/apex/RequestUnpaidWageFundController.insertUWFPayee';
import insertWrsUpdatePrs from '@salesforce/apex/RequestUnpaidWageFundController.insertWrsUpdatePrs';

export default class RequestUnpaidWageFund extends LightningElement {

    @track forUWF = true;
    @track getPayeeBtnDisabled = true;
    @track reqUWFwrBtnDisabled = true;
    @track valSelPayeeBtnDisabled = true;

    @track InternalEmpDetails;
    @track currIntEmpId;
    @track currIntEmpEmailId;
    @track userDetails;
    @wire (getInternalEmployeeInfo, {userId: User_Id})
    checkUser({error,data}){
        if(data){
            console.log('__________________ Inside getInternalEmployeeInfo __________________');
            console.log(data);
            this.InternalEmpDetails = JSON.parse(JSON.stringify(data));
            console.log(this.InternalEmpDetails);
            for (var m=0; m<this.InternalEmpDetails.length; m++){
                if (this.InternalEmpDetails[m].Name == this.InternalEmpDetails[m].User__r.Name){
                    this.currIntEmpId = this.InternalEmpDetails[m].Id;
                    this.currIntEmpEmailId = this.InternalEmpDetails[m].Email__c;
                }
            }
            console.log(this.currIntEmpId);

            getUserInfo ({userId: User_Id})
            .then(result =>{
                console.log('<=== User Info: ===> ');
                this.userDetails = JSON.parse(JSON.stringify(result));
                console.log(this.userDetails);
                this.checkUserPermission(this.userDetails);
            })  
        }
        else if(error){
            console.log(error);
            this.errormsg = error;
            console.log('@ wire this.errormsg ==> '+this.errormsg);
        }
    }

    @track currUserReviewing;
    @track allowUserRequest = true;
    checkUserPermission(userDetails){
        console.log('__________________ Inside checkUserPermission __________________');
        //Check if User has permission to Request for Warrants
        this.currUserReviewing = userDetails[0].Assignee.Name;
        console.log('currUserReviewing ==> '+this.currUserReviewing);
        var userProfileName;
        var userPermissionNames = [];
        for (var i=0; i<userDetails.length; i++){
            if (userDetails[i].PermissionSet.hasOwnProperty('Profile')){
                userProfileName = userDetails[i].PermissionSet.Profile.Name;
            }
            else{
                userPermissionNames.push(userDetails[i].PermissionSet.Name);
            }
        }
        console.log('Profile ===> ');
        console.log(userProfileName);
        console.log('Permissions ===> ');
        console.log(userPermissionNames);
        if (this.currIntEmpId != null && (userPermissionNames.includes('Cashiering_Disbursing') || 
            userProfileName == 'System Administrator' || userProfileName == 'System Administrator LTD')){
            this.allowUserRequest = true;
            console.log('Chech allowUserRequest true');
            //Load the page here
        }
        else{
            this.allowUserRequest = false;
            console.log('Chech allowUserRequest false');
        }
    }

    get caseOptions() {
        return [
            { label: 'Select One', value: 'Select One' },
            { label: 'BOFE Cases', value: 'BOFE' },
            { label: 'WCA Cases', value: 'WCA' },
        ];
    }

    resetValuesOnChange(){
        this.payeesExist = false;
        this.getPayeeBtnDisabled = true;
        this.reqUWFwrBtnDisabled = true;
        this.valSelPayeeBtnDisabled = true;
        this.payeeOAerror = false;
        this.rctHoldDateisFuture = false;
        this.payeeNoCashBalance = false;
        this.payeeNoDirOffice = false;
        this.paymentAmtisNull = false;
        this.noPRinPayee = false;
        this.officeAccountUndefined = false;
        this.errorMessage = false;
        this.warningMessage = false;
        this.successMessage = false;
        this.unsuccessMessage = false;
        this.nonBofeCaseExist = false;
        this.proceedRequestWB = false;
        this.cannotProceedReqWB = false;
        this.gettingPayees = false;
        this.validatePayees = false;
        this.uwfPassed = false;
        this.uwfFailed = false;
        this.validCasesWBRequest = [];
        this.nonBofeCases = [];
        this.listOfEnteredCaseNames = [];
        this.casePayeeDetails = [];
        this.allPayeesInEnteredCases = [];
        this.payeeIDs = [];
        this.payeeSerialNo = 0;
        this.payeeWithRightData = [];
        this.selOffice = [];
        this.selectedPayeeDetails = [];   
    }

    @track optValue = 'Select One';
    @track isBofe = false;
    @track isWca = false;
    @track selectOpt = false;
    @track officeAccList = [];
    @track officeList = [];
    @track wcaOffAcc = [];
    @track wcaOffice = [];
    handleChange(event) {
        console.log('_______ handleChange _______');
        this.resetValuesOnChange();
        this.optValue = event.detail.value;
        console.log('Case Option');
        console.log(this.optValue);
        if (this.optValue == 'BOFE'){
            this.isBofe = true;
            this.isWca = false;
            this.selectOpt = false;
        }
        else if(this.optValue == 'WCA'){ 
            /*
            getWCAOfficeAccountDetails()
            .then(result =>{
                console.log('<=== Office Account List ===>');
                this.officeAccList = JSON.parse(JSON.stringify(result));
                console.log('this.officeAccList');
                console.log(this.officeAccList);
                for(let i = 0; i < this.officeAccList.length; i++) {
                    this.wcaOffAcc[i] = {};
                    this.wcaOffAcc[i].label = this.officeAccList[i].Office__r.Name;
                    this.wcaOffAcc[i].value = this.officeAccList[i].Name;
                } 
                console.log('this.wcaOffAcc');
                console.log(this.wcaOffAcc);
                console.log('JSON.parse(JSON.stringify(this.wcaOffAcc))');
                console.log(JSON.parse(JSON.stringify(this.wcaOffAcc)));
                this.isBofe = false;
                this.isWca = true;
                this.selectOpt = false;
            })
            .catch(error =>{
                console.log('Error while getting Office list');
            })
            */

            getWCAOfficeDetails()
            .then(result =>{
                console.log('<=== Office List ===>');
                this.officeList = JSON.parse(JSON.stringify(result));
                console.log('this.officeList');
                console.log(this.officeList);
                for(let i = 0; i < this.officeList.length; i++) {
                    //console.log('Inside for Loop');
                    //console.log(this.officeList[i]);
                    this.wcaOffice[i] = {};
                    this.wcaOffice[i].label = this.officeList[i].Name;
                    this.wcaOffice[i].value = this.officeList[i].Name;
                } 
                console.log('this.wcaOffice');
                console.log(this.wcaOffice);
                console.log('JSON.parse(JSON.stringify(this.wcaOffice))');
                console.log(JSON.parse(JSON.stringify(this.wcaOffice)));
                this.isBofe = false;
                this.isWca = true;
                this.selectOpt = false;
            })
            .catch(error =>{
                console.log('Error while getting Office list');
            })
        }
        else{
            this.isBofe = false;
            this.isWca = false;
            this.selectOpt = true;
        }
    }

    /*
    get wcaOfficeAccOpts() {
        console.log('_______ wcaOfficeAccOpts _______');
        console.log(JSON.parse(JSON.stringify(this.wcaOffAcc)));
        return JSON.parse(JSON.stringify(this.wcaOffAcc));
    }
    */

    get wcaOfficeOpts() {
        console.log('_______ wcaOfficeOpts _______');
        console.log(JSON.parse(JSON.stringify(this.wcaOffice)));
        return JSON.parse(JSON.stringify(this.wcaOffice));
    }

    @track optOffice = 'Select Office';
    handleWcaOfficeChange(event) {
        console.log('__________________ Inside handleWcaOfficeChange __________________');
        this.resetValuesOnChange();
        this.getPayeeBtnDisabled = false;
        this.optOffice = event.detail.value;
        console.log('Office Option');
        console.log(this.optOffice);
    }

    @track enteredCaseNames;
    handleBofeCaseInputChange(event) {
        console.log('__________________ Inside handleBofeCaseInputChange __________________');
        this.resetValuesOnChange();
        this.getPayeeBtnDisabled = false;
        this.enteredCaseNames = event.detail.value;
        console.log('Entered Case Names');
        console.log(this.enteredCaseNames);
    }

    allSelected(event){
        let selectedRows = this.template.querySelectorAll('lightning-input');
        console.log('--------------allSelected--------------');
        console.log(selectedRows.length);
        this.payeeSelected = true;
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
            }
        }
        this.valSelPayeeBtnDisabled = false;
    }

    @track listOfEnteredCaseNames = [];
    @track casePayeeDetails = [];
    @track allPayeesInEnteredCases = [];
    @track sfdcBaseURL = window.location.origin;
    @track caseLink;
    @track payeeLink;
    @track payeeSerialNo = 0;
    @track payeesExist = false;
    @track payeeIDs = [];
    @track nonBofeCases = [];
    @track nonBofeCaseExist = false;
    @track gettingPayees = false;
    handleGetBOFEPayeesClick(event) {
        console.log('__________________ Inside handleGetBOFEPayeesClick __________________');
        this.getPayeeBtnDisabled = true;
        this.gettingPayees = true;
        //this.enteredCaseNames = 'CM-368386,CM-416655,CM-596445,CM-644909,CM-696816,CM-155007,CM-862742,CM-925963';
        this.enteredCaseNames = this.enteredCaseNames.replace(/\s+/g, '');
        this.listOfEnteredCaseNames = this.enteredCaseNames.split(',');
        console.log('List of entered Case Names');
        console.log(this.listOfEnteredCaseNames);
        getBOFECaseDetails({apxSelCaseName: this.listOfEnteredCaseNames})
        .then(result =>{
            console.log('<=== case payee list ===>');
            this.casePayeeDetails = JSON.parse(JSON.stringify(result));
            console.log('this.casePayeeDetails');
            console.log(this.casePayeeDetails);

            //Non BOFE Cases are excluded
            if(this.listOfEnteredCaseNames.length > this.casePayeeDetails.length){
                console.log('The entered non BOFE case(s) are excluded');
                for(let v = 0; v < this.listOfEnteredCaseNames.length; v++) {
                    var caseExist = false;
                    for(let w = 0; w < this.casePayeeDetails.length; w++){
                        if(this.listOfEnteredCaseNames[v] == this.casePayeeDetails[w].Name){
                            caseExist = true;
                        }
                    }
                    if(!caseExist){
                        this.nonBofeCaseExist = true;
                        this.nonBofeCases.push(this.listOfEnteredCaseNames[v])
                    }
                }
            }
            
            //Add Case Name, Case Link & Payee link to all Payees
            for(let i = 0; i < this.casePayeeDetails.length; i++) {
                var caseName = this.casePayeeDetails[i].Name;
                this.caseLink = this.sfdcBaseURL + '/' + this.casePayeeDetails[i].Id + '\r\n';
                //console.log(caseName);
                //console.log(this.caseLink);
                for(let j = 0; j < this.casePayeeDetails[i].Payees__r.length; j++){
                    //console.log(caseName);
                    //console.log(this.caseLink);
                    this.casePayeeDetails[i].Payees__r[j].caseName = caseName;
                    this.casePayeeDetails[i].Payees__r[j].caseLink = this.caseLink;
                    this.payeeLink = this.sfdcBaseURL + '/' + this.casePayeeDetails[i].Payees__r[j].Id + '\r\n';
                    this.casePayeeDetails[i].Payees__r[j].payeeLink = this.payeeLink;

                }
            }
            console.log('Added Payee link & Case link & Payee Serial Number');

            //Get all the valid Payee Details in one Array
            for(let k = 0; k < this.casePayeeDetails.length; k++) {
                for(let l = 0; l < this.casePayeeDetails[k].Payees__r.length; l++){
                    if((this.casePayeeDetails[k].Payees__r[l].Wage_Payable_Balance_New__c > 0 || this.casePayeeDetails[k].Payees__r[l].Wage_Interest_Payable_Balance__c > 0 ||
                        this.casePayeeDetails[k].Payees__r[l].Interest_Other_Payable_Balance__c > 0) && (this.casePayeeDetails[k].Payees__r[l].Payee_Type__c == 'Employee' ||
                        this.casePayeeDetails[k].Payees__r[l].Payee_Type__c == 'Employee - Net Wages') && this.casePayeeDetails[k].Payees__r[l].Payee_Name__c != 'DIR Accounting-Unpaid Wage Fund'){
                            this.payeeSerialNo = this.payeeSerialNo + 1;
                            //console.log('Payee Serial Number: ')
                            //console.log(this.payeeSerialNo);
                            this.casePayeeDetails[k].Payees__r[l].payeeSerialNo = this.payeeSerialNo;
                            this.allPayeesInEnteredCases.push(this.casePayeeDetails[k].Payees__r[l]);
                    }
                }
            }
            console.log('this.allPayeesInEnteredCases');
            console.log(this.allPayeesInEnteredCases);
            this.gettingPayees = false;
            this.groupCaseAndPayee();
        })
        .catch(error =>{
            console.log('Error while getting Payee details');
        })

    }

    @track selOffice = [];
    handleGetWCAPayeesClick(event) {
        console.log('__________________ Inside handleGetWCAPayeesClick __________________');
        this.getPayeeBtnDisabled = true;
        this.gettingPayees = true;
        //Get the Office ID list of the selected offices
        for(let q = 0; q < this.officeList.length; q++) {
            if(this.officeList[q].Name == this.optOffice){
                this.selOffice.push(this.officeList[q].Name);
            }

        } 
        console.log(this.selOffice);
        getWCACaseDetails({apxSelOffice: this.selOffice})
        .then(result =>{
            console.log('<=== WCA Case Payee List ===>');
            this.casePayeeDetails = JSON.parse(JSON.stringify(result));
            console.log('this.casePayeeDetails');
            console.log(this.casePayeeDetails);
            
            //Add Case Name, Case Link & Payee link to all Payees
            for(let i = 0; i < this.casePayeeDetails.length; i++) {
                var caseName = this.casePayeeDetails[i].Name;
                this.caseLink = this.sfdcBaseURL + '/' + this.casePayeeDetails[i].Id + '\r\n';
                //console.log(caseName);
                //console.log(this.caseLink);
                for(let j = 0; j < this.casePayeeDetails[i].Payees__r.length; j++){
                    //console.log(caseName);
                    //console.log(this.caseLink);
                    this.casePayeeDetails[i].Payees__r[j].caseName = caseName;
                    this.casePayeeDetails[i].Payees__r[j].caseLink = this.caseLink;
                    this.payeeLink = this.sfdcBaseURL + '/' + this.casePayeeDetails[i].Payees__r[j].Id + '\r\n';
                    this.casePayeeDetails[i].Payees__r[j].payeeLink = this.payeeLink;
                }
            }
            console.log('Added Payee link & Case link & Payee Serial Number');

            //Get all the Payee Details in one Array
            for(let k = 0; k < this.casePayeeDetails.length; k++) {
                for(let l = 0; l < this.casePayeeDetails[k].Payees__r.length; l++){
                    if((this.casePayeeDetails[k].Payees__r[l].Wage_Payable_Balance_New__c > 0 || this.casePayeeDetails[k].Payees__r[l].Wage_Interest_Payable_Balance__c > 0 ||
                        this.casePayeeDetails[k].Payees__r[l].Interest_Other_Payable_Balance__c > 0) && (this.casePayeeDetails[k].Payees__r[l].Payee_Type__c == 'Employee' ||
                        this.casePayeeDetails[k].Payees__r[l].Payee_Type__c == 'Employee - Net Wages')  && this.casePayeeDetails[k].Payees__r[l].Payee_Name__c != 'DIR Accounting-Unpaid Wage Fund'){
                            this.payeeSerialNo = this.payeeSerialNo + 1;
                            //console.log('Payee Serial Number: ')
                            //console.log(this.payeeSerialNo);
                            this.casePayeeDetails[k].Payees__r[l].payeeSerialNo = this.payeeSerialNo;
                            this.allPayeesInEnteredCases.push(this.casePayeeDetails[k].Payees__r[l]);
                    }
                }
            }
            console.log('this.allPayeesInEnteredCases');
            console.log(this.allPayeesInEnteredCases);
            this.gettingPayees = false;
            this.groupCaseAndPayee();
        })
        .catch(error =>{
            console.log('Error while getting Payee details');
        })

    }

    groupCaseAndPayee(){
        console.log('__________________ Inside groupCaseAndPayee __________________');
        if(this.allPayeesInEnteredCases == undefined || this.allPayeesInEnteredCases == null){
            this.errormsg = 'There is no valid Payees under this Case';
            this.payeesExist = false;
        }
        else{
            this.payeesExist = true;
            //Get the Array of Payee IDs
            for(let m = 0; m < this.allPayeesInEnteredCases.length; m++){
                this.payeeIDs.push(this.allPayeesInEnteredCases[m].Id);
            }
            console.log('Payee IDs');
            console.log(this.payeeIDs);
            this.calcualtePayeeAmt();
            //Group the Payees by Case for Listing
            console.log('Group the Payees by Case for Listing');
            let groupCasePayeeMap = new Map();
            this.allPayeesInEnteredCases.forEach(payee =>{
                if(groupCasePayeeMap.has(payee.caseName)){
                    groupCasePayeeMap.get(payee.caseName).payees.push(payee);
                }
                else{
                    let newPayee = {};
                    newPayee.caseName = payee.caseName;
                    newPayee.payees = [payee];
                    groupCasePayeeMap.set(payee.caseName, newPayee);

                }
            });
            console.log(groupCasePayeeMap);
            console.log(groupCasePayeeMap.values);
            //Iterate through the groupCasePayeeMap 
            console.log('Iterate through the groupCasePayeeMap');
            let itr = groupCasePayeeMap.values();
            let payeeArray = [];
            let payeeResult = itr.next();
            while(!payeeResult.done){
                payeeResult.value.rowspan = payeeResult.value.payees.length + 1;
                payeeArray.push(payeeArray.value);
                payeeResult = itr.next();
            }
            return payeeArray;
        }
    }

    @track payeePRnCaseDetails;
    @track payeeAmount = 0;
    calcualtePayeeAmt(){
        console.log('__________________ Inside calculatePayeeAmt __________________');
        console.log('Payee IDs');
        console.log(this.payeeIDs);
        getPayeeDetails({apxPayeeIds: this.payeeIDs})
        .then(result =>{
            console.log('<=== Payee & PR List ===>');
            this.payeePRnCaseDetails = JSON.parse(JSON.stringify(result));
            console.log('this.payeePRnCaseDetails');
            console.log(this.payeePRnCaseDetails);
            //Iterate through Payees & it's respective PRs to calculate the Payee Amount for each Payee
            for(let a = 0; a < this.payeePRnCaseDetails.length; a++) {
                this.payeeAmount = 0.00;
                if(this.payeePRnCaseDetails[a].Payment_Records__r.length > 0){
                    //console.log('Payee Amount should be zero');
                    //console.log(this.payeeAmount);
                    for(let b = 0; b < this.payeePRnCaseDetails[a].Payment_Records__r.length; b++){
                        //Payee Amount should be sum of Payment Amount of all Payment Records, that haven't been batched yet.
                        if(this.payeePRnCaseDetails[a].Payment_Records__r[b].Batched_Under_Warrant__c == false){
                            var paymentAmount = (this.payeePRnCaseDetails[a].Payment_Records__r[b].Payment_Amount__c).toFixed(2);
                            //console.log('Payment Amount in the Payment Record');
                            //console.log(paymentAmount);
                            this.payeeAmount = (Number(this.payeeAmount) + Number(paymentAmount)).toFixed(2);
                            //console.log('Payee Amount after each calculation');
                            //console.log(this.payeeAmount);
                            //console.log(typeof(this.payeeAmount));
                        }
                        
                    }
                    
                }
                //Iterate through the Payee list and add the Payee_Amount & PR details to this.allPayeesInEnteredCases 
                for(let c = 0; c < this.allPayeesInEnteredCases.length; c++){
                    if(this.allPayeesInEnteredCases[c].Id === this.payeePRnCaseDetails[a].Id){
                        //console.log('-------- Payee Amount fixed to 2 decimals --------');
                        //console.log(Number(this.payeeAmount).toFixed(2));
                        //console.log('Added Payee Amount to the payeePRnCaseDetails')
                        this.allPayeesInEnteredCases[c].Payee_Amount = Number(this.payeeAmount).toFixed(2);
                        this.allPayeesInEnteredCases[c].Payment_Records__r = this.payeePRnCaseDetails[a].Payment_Records__r;
                    }
                        
                }
                
            } 
            console.log('Payee, PR, Case details with Payee Amount on Payees');
            console.log(this.allPayeesInEnteredCases);
            this.valSelPayeeBtnDisabled = false;

        })
        .catch(error =>{
            console.log('Error while calculating Payee Amount');
        })
    }

    //Everytime when the checkbox is modified while selecting the Payees
    updateSelectedPayees(){
        console.log('__________________ Inside updateSelectedPayees __________________');
        this.valSelPayeeBtnDisabled = false;
    }

    @track selectedPayeeDetails = [];
    @track validatePayees = false;
    validateSelectedPayees(){
        console.log('__________________ Validate Selected Payees __________________');
        this.valSelPayeeBtnDisabled = true;
        this.validatePayees = true;
        console.log('Payee, PR, Case details with Payee Amount on Payees');
        console.log(this.allPayeesInEnteredCases);

        // Check if at least one or more Payees are Selected
        this.getSelectedPayees();
        console.log('Selected Payees');
        console.log(this.selectedPayees);

        // Get the Payee, PR & Case Details of the selected Payees
        for(let k = 0; k < this.selectedPayees.length; k++){
            for(let l = 0; l < this.allPayeesInEnteredCases.length; l++){
                if(this.selectedPayees[k].Id === this.allPayeesInEnteredCases[l].Id){
                    this.selectedPayeeDetails.push(this.allPayeesInEnteredCases[l]);
                }
            }
        }
        console.log('selectedPayeeDetails')
        console.log(this.selectedPayeeDetails);

        // Valid Payment Record exists and Warrant's haven't been issued already
        // The Receipt Hold Date is not in future
        // Payment Amount in Payment Records are not Null
        // List of Classes & Office Accounts
        // Payees with multiple office accounts (WCA)
        // Office Account in Payment Records cannot be undefined
        this.verifyValidPayeesAndPRs();

        //Get the Payee list with correct data
        this.getPayeeWithRightData();

        //Group Payees by Case
        this.groupCasePayeeWithRightData();

        // Cash Balance on the Case is sufficient
        this.checkCashBalanceOnCase();

        //After all validations succeeds enable request UWF Warrant Button
        //this.reqUWFwrBtnDisabled = false;
    }

    
    @track selectedPayees;
    @track payeeSelected = true;
    getSelectedPayees(){
        console.log('*********** getSelectedPayees ***********');
        this.selectedPayees = [];
        let selectedRows = this.template.querySelectorAll('lightning-input');
        // based on selected row getting values of the warrants
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].checked && selectedRows[i].type === 'checkbox') {
                //console.log(selectedRows[i].dataset);
                this.selectedPayees.push({
                    Name: selectedRows[i].value,
                    Id: selectedRows[i].dataset.id
                })
            }
        } 
        console.log('Selected Payees to Validate');
        console.log(this.selectedPayees);
        if(this.selectedPayees.length == 0){
            this.payeeSelected = false;
        }
        else{
            this.payeeSelected = true;
        }
    }
    
    @track payeeNoDirOffice = false;
    @track rctHoldDateisFuture = false;
    @track noPRinPayee = false;
    @track paymentAmtisNull = false;
    @track officeAccountUndefined = false;
    @track prHasNoOA = false;
    @track payee_PRnullPayAmt;
    @track payee_NoPR;
    @track payee_FutureRctHoldDate;
    @track payee_NoOffice;
    @track payee_PRwithNoOffAcc;
    @track uniqueCaseIds;
    @track numberOfCases;
    @track uniqueOfficeAccIds = [];
    @track numberOfOfficeAccount;
    verifyValidPayeesAndPRs(){
        console.log('__________________ Validate Payment Records & Receipt Hold Date __________________');
        var caseIds = [];
        var payeeWithFutureRCTHoldDate = [];
        var payeeWithNoPRs = [];
        var payeeWithoutOffice = [];
        var payeesWithNullAmtPR = [];
        var prsWithNullPayAmt = [];
        var prsOfficeAccIds = [];
        var payeePmtRecNoOA = [];
        var currDate = new Date();
        var day = currDate.getDate();
        var month = currDate.getMonth()+1;
        var year = currDate.getFullYear();
        var today = year + "-" + month + "-" + day;
        console.log(today);

        for(let m = 0; m < this.selectedPayeeDetails.length; m++){
            console.log('Inside Payee for Loop');
            //Get Array of Case Ids from all the Payees selected
            caseIds.push(this.selectedPayeeDetails[m].Case_Management__c);

            //************Check DIR Office in Payee************
            console.log('Check DIR Office in Payee');
            
            if(this.selectedPayeeDetails[m].DIR_Office__c == undefined){
                this.payeeNoDirOffice = true;
                payeeWithoutOffice.push(this.selectedPayeeDetails[m].Name);
            }

            //************Check Future Receipt Hold Date************
            console.log('Check Future Receipt Hold Date');
            var payeeRctHoldDate = this.selectedPayeeDetails[m].Latest_Receipt_Hold_Date__c;
            //console.log(payeeRctHoldDate);

            if(payeeRctHoldDate!=undefined){
                var payeeRctHoldDate = this.selectedPayeeDetails[m].Latest_Receipt_Hold_Date__c;
                var todayDate = new Date(today).getTime();
                var pRctHoldDate = new Date(payeeRctHoldDate).getTime();
                //console.log('Compare the Dates');
                if(pRctHoldDate > todayDate){
                    //console.log('Payee Rct Hold Date is in Future');
                    this.rctHoldDateisFuture = true;
                    payeeWithFutureRCTHoldDate.push(this.selectedPayeeDetails[m].Name);
                }
            }

            //************Check Payment Records Exists ************
            console.log('Check Payment Records Exists');
            console.log(this.selectedPayeeDetails[m].Payment_Records__r);
            if(this.selectedPayeeDetails[m].Payment_Records__r == undefined || this.selectedPayeeDetails[m].Payment_Records__r.length==0){
                console.log(this.selectedPayeeDetails[m].Name);
                payeeWithNoPRs.push(this.selectedPayeeDetails[m].Name);
                this.noPRinPayee = true;
            }
            else{
                console.log('~~~~~~~~~~~~~ Payment Records Exists ~~~~~~~~~~~');
                for(let n = 0; n < this.selectedPayeeDetails[m].Payment_Records__r.length; n++){
                    //console.log('Inside Payment Record for Loop');
                    //************Check Payment Amount in Payment Records are not null or zero ************
                    var paymentAmount = this.selectedPayeeDetails[m].Payment_Records__r[n].Payment_Amount__c;
                    if(paymentAmount == null || paymentAmount == 0 || paymentAmount == undefined){
                        prsWithNullPayAmt.push(this.selectedPayeeDetails[m].Payment_Records__r[n].Name);
                        payeesWithNullAmtPR.push(this.selectedPayeeDetails[m].Name);
                        this.paymentAmtisNull = true;
                    }
                    //************Office Account Check***********
                    else if(this.selectedPayeeDetails[m].Payment_Records__r[n].Payment_Amount__c > 0.00){
                        if(this.selectedPayeeDetails[m].Payment_Records__r[n].Liability_Payment__c != undefined || this.selectedPayeeDetails[m].Payment_Records__r[n].Liability_Payment__c != null){
                            if(this.selectedPayeeDetails[m].Payment_Records__r[n].Liability_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c != null){
                                this.officeAccountUndefined = false;
                                console.log('Office Account of Liability Payment');
                                prsOfficeAccIds.push(this.selectedPayeeDetails[m].Payment_Records__r[n].Liability_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c);
                            }
                        }
                        else if(this.selectedPayeeDetails[m].Payment_Records__r[n].Judgment_Payment__c != undefined || this.selectedPayeeDetails[m].Payment_Records__r[n].Judgment_Payment__c != null){
                            if(this.selectedPayeeDetails[m].Payment_Records__r[n].Judgment_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c != null){ 
                                this.officeAccountUndefined = false;
                                console.log('Office Account of Judgment Payment');
                                prsOfficeAccIds.push(this.selectedPayeeDetails[m].Payment_Records__r[n].Judgment_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c);
                            }
                        }
                        else{
                            console.log('Office Account Undefined');
                            this.officeAccountUndefined = true;
                            this.prHasNoOA = true;
                            payeePmtRecNoOA.push(this.selectedPayeeDetails[m].Name);
                        }
                    }
                    
                } //end of PR for loop
            } //end of else
            
        } //end of Payee for loop

        //Avoid the duplicates from the array of Payees or PRs & convert it to string
        console.log('Avoid the duplicates from the array of Payees or PRs & convert it to string');
        this.payee_PRnullPayAmt = [...new Set(payeesWithNullAmtPR)].toString();
        this.payee_NoPR = payeeWithNoPRs.toString();
        this.payee_FutureRctHoldDate = payeeWithFutureRCTHoldDate.toString();
        this.payee_NoOffice = payeeWithoutOffice.toString();
        this.payee_PRwithNoOffAcc = [...new Set(payeePmtRecNoOA)].toString();
        console.log(this.selectedPayeeDetails);

        //Total number of Cases
        console.log('_________Number of Cases__________');
        console.log(caseIds);
        this.uniqueCaseIds = [...new Set(caseIds)];
        console.log(this.uniqueCaseIds);
        console.log(typeof(this.uniqueCaseIds));
        this.numberOfCases = this.uniqueCaseIds.length;

        //Total number of Office Accounts
        console.log('_________Number of Office Accounts__________');
        console.log(prsOfficeAccIds);
        this.uniqueOfficeAccIds = [...new Set(prsOfficeAccIds)];
        console.log('Unique Office Accounts ==> '+ this.uniqueOfficeAccIds);
        this.numberOfOfficeAccount = this.uniqueOfficeAccIds.length;
        //this.numberOfOfficeAccount = 1;
        console.log('Number of Office Account = ' + this.numberOfOfficeAccount);
        if(this.numberOfOfficeAccount == 0 || this.numberOfOfficeAccount == null){
            this.prHasNoOA = true;
            return;
        }
        else if(this.numberOfOfficeAccount > 1){
            //this.reqUWFwrBtnDisabled = true;
            this.payeeOAerror = true;
            return;
        } 
        else if(this.numberOfOfficeAccount == 1){
            console.log("All Payees belong to same Office Account");
            //this.reqUWFwrBtnDisabled = false;
        }
        
        //Logic to verify the data & display warning/error/success message
        if(this.allowUserRequest==false || this.payeeOAerror == true){
            console.log('Error message should be seen');
            this.errorMessage = true;
            this.warningMessage = false;
            this.successMessage = false;
        }
        if((this.paymentAmountNull==true || this.noPRinPayee==true || this.payeeNoDirOffice==true || this.rctHoldDateisFuture==true || this.prHasNoOA==true || this.payeeNoCashBalance==true) && (this.allowUserRequest==true && this.payeeOAerror == false)){
            console.log('Warning message should be seen');
            this.errorMessage = false;
            this.warningMessage = true;
            this.successMessage = false;
            this.unsuccessMessage = false;
        }
        if(this.allowUserRequest==true && this.payeeOAerror == false && this.paymentAmountNull==false && this.noPRinPayee==false && this.payeeNoDirOffice==false && this.rctHoldDateisFuture==false && this.prHasNoOA==false && this.payeeNoCashBalance == false){
            console.log('Success message should be seen');
            this.errorMessage = false;
            this.warningMessage = false;
            //this.successMessage = true;
            this.unsuccessMessage = false;
        }
    }

    @track payeeWithRightData = [];
    @track uniquePayeeWithErrData;
    @track casesWithErrData = [];
    getPayeeWithRightData(){
        console.log('__________________ Inside getPayeeWithRightData __________________');
        console.log(this.selectedPayeeDetails);

        //Javascript immutable strings
        /*
        for(let k=0; k<this.selectedPayeeDetails.length; k++){
            console.log(this.selectedPayeeDetails[k]);
            //this.PayeeWithRightData.push(this.selectedPayeeDetails[k]);
        }
        */
        this.payeeWithRightData = Array.from(this.selectedPayeeDetails);

        console.log("All payee details");
        console.log(this.payeeWithRightData);
        console.log('Each error check Payee');
        console.log(this.payee_PRnullPayAmt);
        console.log(this.payee_NoPR);
        console.log(this.payee_FutureRctHoldDate);
        console.log(this.payee_NoOffice);
        console.log(this.payee_PRwithNoOffAcc);
        var strPayeeWithErrorData = "";
        if(this.paymentAmtisNull){
            if (strPayeeWithErrorData === ""){
                strPayeeWithErrorData = this.payee_PRnullPayAmt;
            }
            else{
                strPayeeWithErrorData = strPayeeWithErrorData + ',' + this.payee_PRnullPayAmt;
            }
        }
        if(this.noPRinPayee){
            if (strPayeeWithErrorData === ""){
                strPayeeWithErrorData = this.payee_NoPR;
            }
            else{
                strPayeeWithErrorData = strPayeeWithErrorData + ',' + this.payee_NoPR;
            }
        }
        if(this.payeeNoDirOffice){
            if (strPayeeWithErrorData === ""){
                strPayeeWithErrorData = this.payee_NoOffice;
            }
            else{
                strPayeeWithErrorData = strPayeeWithErrorData + ',' + this.payee_NoOffice;
            }
        }
        if(this.rctHoldDateisFuture){
            if (strPayeeWithErrorData === ""){
                strPayeeWithErrorData = this.payee_FutureRctHoldDate;
            }
            else{
                strPayeeWithErrorData = strPayeeWithErrorData + ',' + this.payee_FutureRctHoldDate;
            }
        }
        if(this.prHasNoOA){
            if (strPayeeWithErrorData === ""){
                strPayeeWithErrorData = this.payee_PRwithNoOffAcc;
            }
            else{
                strPayeeWithErrorData = strPayeeWithErrorData + ',' + this.payee_PRwithNoOffAcc;
            }
        }

        console.log("String - all payee with error data");
        console.log(strPayeeWithErrorData);
        var arrPayeeWithErrorData = strPayeeWithErrorData.split(',');
        console.log("Array all payee with error data");
        console.log(arrPayeeWithErrorData);
        this.uniquePayeeWithErrData = [...new Set(arrPayeeWithErrorData)];
        console.log("xxxxxxxxxxxxxxxxxx Cases that should be removed from creating warrants xxxxxxxxxxxxxxxxxx");
        console.log(this.uniquePayeeWithErrData);
        console.log("Payees with right data");
        console.log(this.payeeWithRightData);
        var casesWithError = [];

        for(let i = this.payeeWithRightData.length -1; i>=0; i--){
            //console.log("Inside Payee Details");
            //console.log(this.payeeWithRightData[i]);
            //console.log(this.payeeWithRightData[i].Name);
            var abort = false;
            for(let j = this.uniquePayeeWithErrData.length -1; j>=0 && !abort; j--){
                //console.log("Inside uniquePayeeWithErrData");
                if(this.payeeWithRightData[i].Name != undefined || this.uniquePayeeWithErrData[j] != undefined || this.uniquePayeeWithErrData[j] != ''){
                    //console.log('check undefined');
                    //console.log(this.payeeWithRightData[i].Name);
                    //console.log(this.uniquePayeeWithErrData[j]);
                    if(this.payeeWithRightData[i].Name == this.uniquePayeeWithErrData[j]){
                        //console.log(this.payeeWithRightData[i].Name);
                        //console.log(this.uniquePayeeWithErrData[j]);
                        console.log("Add Cases with error data Payees");
                        casesWithError.push(this.payeeWithRightData[i].caseName);
                        //console.log("Remove this Payee");
                        //this.payeeWithRightData.splice(i,1);
                        abort = true;
                    }
                }
            }
        }
        this.casesWithErrData = [...new Set(casesWithError)];
        console.log("Cases with error Payee data");
        console.log(this.casesWithErrData)

    }
    
    @track casePayeeWithWRamt = [];
    groupCasePayeeWithRightData(){
        console.log("=========== Inside groupCasePayeeWithRightData ===========");
        let groupSelCasePayeeMap = new Map();
        this.payeeWithRightData.forEach(payee =>{
            if(groupSelCasePayeeMap.has(payee.caseName)){
                groupSelCasePayeeMap.get(payee.caseName).payees.push(payee);
            }
            else{
                let selPayee = {};
                selPayee.caseName = payee.caseName;
                selPayee.payees = [payee];
                groupSelCasePayeeMap.set(payee.caseName, selPayee);
            }
        });
        console.log(groupSelCasePayeeMap);
        //Calculate WR Amount on Case & Cash Balance on Case
        groupSelCasePayeeMap.forEach((value, key) => {
            var wrAmtPerCase = 0;
            var caseID;
            var caseNumber;
            for(let c=0; c<value.payees.length; c++){
                caseID = value.payees[c].Case_Management__c;
                caseNumber = value.payees[c].Case_Management__r.Case_Number__c;
                wrAmtPerCase = (Number(wrAmtPerCase) + Number(value.payees[c].Payee_Amount)).toFixed(2);
            }
            this.casePayeeWithWRamt.push({caseName: value.caseName, caseId: caseID ,caseNumber: caseNumber, payees: value.payees, wrAmt: wrAmtPerCase});
        });
        console.log(this.casePayeeWithWRamt);
    }

    @track payeeNoCashBalance = false;
    @track uniqueCasesWithErr = [];
    @track proceedRequestWB = false;
    @track validCasesWBRequest = [];
    @track cannotProceedReqWB = false;
    checkCashBalanceOnCase(){
        console.log("=========== Inside checkCashBalanceOnCase ===========");
        console.log("List of Case Payee details with Cash Balance & Warrant Pending fields");
        console.log(this.casePayeeDetails);
        console.log("List of Cases, Payees & Warrant Amount per case on right Payees");
        console.log(this.casePayeeWithWRamt);
        var casePayeeNoSuffBal = [];
        for(let l=0; l<this.casePayeeWithWRamt.length; l++){
            for(let m=0; m<this.casePayeeDetails.length; m++){
                if(this.casePayeeWithWRamt[l].caseName == this.casePayeeDetails[m].Name){
                    if(this.casePayeeDetails[m].Warrants_Pending__c != undefined){
                        var totCashBal = Number(parseFloat(this.casePayeeDetails[m].Cash_Balance_on_Case__c).toFixed(2)) - Number(parseFloat(this.casePayeeDetails[m].Warrants_Pending__c).toFixed(2));
                    }
                    else{
                        var totCashBal = Number(parseFloat(this.casePayeeDetails[m].Cash_Balance_on_Case__c).toFixed(2));
                    }
                    
                    console.log(Number(parseFloat(this.casePayeeWithWRamt[l].wrAmt).toFixed(2)));
                    console.log(totCashBal.toFixed(2));
                    if(totCashBal.toFixed(2) < Number(parseFloat(this.casePayeeWithWRamt[l].wrAmt).toFixed(2))){
                        console.log('Remove the Case with insufficient cash balance');
                        casePayeeNoSuffBal.push(this.casePayeeWithWRamt[l]);
                    }
                }
            }  
        }
        console.log('All cases with right Payee details & WR Amount before Cash Balance verification');
        console.log(this.casePayeeWithWRamt);
        console.log('Cases with no sufficient Cash Balance');
        console.log(casePayeeNoSuffBal);

        var casesWithNoCashBal = [];
        for(let x =0; x<casePayeeNoSuffBal.length; x++){
            casesWithNoCashBal.push(casePayeeNoSuffBal[x].caseName);
            this.casesWithErrData.push(casePayeeNoSuffBal[x].caseName);        
        }
        this.uniqueCasesWithErr = [...new Set(this.casesWithErrData)];
        console.log('All Cases that needs to be deleted');
        console.log(this.uniqueCasesWithErr);

        
        //Remove all the cases with error payees & no cash balance
        for(let m = this.uniqueCasesWithErr.length-1; m>=0; m--){
            //console.log(this.uniqueCasesWithErr[m]);
            for(let n = this.casePayeeWithWRamt.length -1; n>=0; n--){
                //console.log(this.casePayeeWithWRamt[n].caseName);
                if(this.uniqueCasesWithErr[m] == this.casePayeeWithWRamt[n].caseName){
                    //console.log(this.uniqueCasesWithErr[m]);
                    //console.log(this.casePayeeWithWRamt[n].caseName);
                    this.casePayeeWithWRamt.splice(n,1);
                }
            }  
        }

        //Get valid case names
        if(this.casePayeeWithWRamt.length >= 1){
            this.proceedRequestWB = true;
            this.validatePayees = false;
            this.reqUWFwrBtnDisabled = false;
            for(let h=0; h<this.casePayeeWithWRamt.length; h++){
                this.validCasesWBRequest.push(this.casePayeeWithWRamt[h].caseName);
            }
        }
        else{
            this.cannotProceedReqWB = true;
            this.validatePayees = false;
            this.reqUWFwrBtnDisabled = true;
        }

        console.log('Cases & Payees that passed all validation and ready to be batched');
        console.log(this.casePayeeWithWRamt);
        console.log('casesWithNoCashBal');
        console.log(casesWithNoCashBal);

        //Check & display the error message for insufficient Cash Balance on case.
        if(casesWithNoCashBal.length>0){
            this.payeeNoCashBalance = true;
            this.payeeInsuffCashOnCase = casesWithNoCashBal.toString();
            console.log('payeeInsuffCashOnCase');
            console.log(this.payeeInsuffCashOnCase);
        }
        else{
            this.payeeNoCashBalance = false;
        }
        
    }

    @track oaOwnerIdDetails;
    @track warrantBatchArrayList = [];
    requestUWFWarrant(){
        console.log('__________________ Inside requestUWFWarrant __________________');
        this.reqUWFwrBtnDisabled = true;

        //Create Warrant Batches to be inserted
        console.log('WB needs to be created for Office Accounts');
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
                    WB_Instructions__c : "UWF"
                    
                };
                console.log(warrantBatchList);
                this.warrantBatchArrayList.push(warrantBatchList);
            }
            console.log('Warrant Batch List to be Inserted ======= ');
            console.log(this.warrantBatchArrayList);
            this.insertUWFwarrantBatch();
        })
        .catch(error =>{
            console.log("Error while getting Office Account Owner details");
        })
    }

    @track wbListInserted;
    @track wbSuccess;
    @track wbFailed;
    @track reqType;
    @track subject = 'Warrant Batch Created';
    @track body = '<div style="font: bold 16px Arial; margin: 10px 0;">New Warrant Batch for UWF is created and warrants are being added. <br> The link to the Warrant Batch is: </div>';
    @track wbURL = '<div style="font: bold 16px Arial; margin: 10px 0;">New Warrant Batch for UWF is created and warrants are being added. <br> The link to the Warrant Batch is: </div>';
    @track toSend = 'schandrasekar@dir.ca.gov';
    @track emailSentSuccess;
    @track emailSentFailed;
    insertUWFwarrantBatch(){
        //Insert Warrant Batch
        console.log('__________________ Inside insertUWFwarrantBatch __________________');
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
                this.reqType = 'reqUWFwr';
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

    sendEmailAboutWB(){
        console.log("=========== sendEmailAboutWB ===========");
        console.log(this.currIntEmpEmailId);
        this.toSend = this.toSend + ',' + this.currIntEmpEmailId;
        console.log(this.toSend);
        //console.log(this.wbListInserted);
        //console.log(this.body);
        sendEmailToController({body: this.body, toSend: this.toSend, subject: this.subject})
        .then(() => {
            //If response is ok
            console.log("Email Sent");
            this.emailSentSuccess = true;
            this.uwfCaseRolesPayeesCheck()
            //this.createWarrantsToBatch();
        }).catch( error => {
            this.emailSentFailed = true;
            console.log("Error while sending the Email");
        })
    }

    @track uwfAccId;
    uwfCaseRolesPayeesCheck(){
        console.log('__________________ Inside uwfCaseRolesPayeesCheck __________________');
        getUwfAccountID().then(result =>{
            console.log("<=== UWF Account ID ===>")
            console.log(result);
            this.uwfAccId = result[0].Id;
            console.log('UWF Account Id');
            console.log(this.uwfAccId);

            console.log('Case Payee Details with Case Roles and Payees');
            console.log(this.casePayeeDetails);

            console.log('Case Payee with Warrant Amount');
            console.log(this.casePayeeWithWRamt);

            //Include Case Role details && all unfiltered Payee details to casePayeeWithWRamt
            for(let x=0; x<this.casePayeeDetails.length; x++){
                for(let y=0; y<this.casePayeeWithWRamt.length; y++){
                    if(this.casePayeeDetails[x].Id == this.casePayeeWithWRamt[y].caseId){
                        this.casePayeeWithWRamt[y].caseRoles = this.casePayeeDetails[x].Case_Roles__r;
                        this.casePayeeWithWRamt[y].allPayees = this.casePayeeDetails[x].Payees__r;
                    }
                }
            }
            console.log('Case Payee with Warrant Amount and Case Roles');
            console.log(this.casePayeeWithWRamt);

            //Check for the existance of UWF Case Roles and UWF Payees
            for(let i=0; i<this.casePayeeWithWRamt.length; i++){
                this.casePayeeWithWRamt[i].uwfCRonCaseExist = false;
                this.casePayeeWithWRamt[i].uwfPayeeonCaseExist = false;
                var uwfCRExist = false;
                var uwfPayeeExist = false;
                for(let j = this.casePayeeWithWRamt[i].caseRoles.length -1; j>=0 && !uwfCRExist; j--){
                    if(this.casePayeeWithWRamt[i].caseRoles[j].Account_Name__c == 'DIR Accounting-Unpaid Wage Fund'){
                        this.casePayeeWithWRamt[i].uwfCRonCaseExist = true;
                        this.casePayeeWithWRamt[i].uwfCRid = this.casePayeeWithWRamt[i].caseRoles[j].Id;
                        this.casePayeeWithWRamt[i].uwfCRrole = this.casePayeeWithWRamt[i].caseRoles[j].Role__c;
                        uwfCRExist = true;
                    }
                }
                for(let k = this.casePayeeWithWRamt[i].allPayees.length -1; k>=0 && !uwfPayeeExist; k--){
                    if(this.casePayeeWithWRamt[i].allPayees[k].Payee_Name__c == 'DIR Accounting-Unpaid Wage Fund'){
                        this.casePayeeWithWRamt[i].uwfPayeeonCaseExist = true;
                        this.casePayeeWithWRamt[i].uwfPayeeId = this.casePayeeWithWRamt[i].allPayees[k].Id;
                        uwfPayeeExist = true;
                    }
                }
            }

            //Create new UWF Case Roles & UWF Payees on the missed Cases
            this.uwfCaseRolePayeeCreate();
            
        })
        .catch(error =>{
            console.log("DIR Accounting-Unpaid Wage Fund account doesn't exist");
        })

        
        
    }

    @track newCaseRoleArrList = [];
    @track newPayeeArrList = [];
    uwfCaseRolePayeeCreate(){
        console.log('__________________ Inside uwfCaseRolePayeeCreate __________________');
        console.log('Cases with UWF Case Roles && UWF Payees Exist or Not');
        console.log(this.casePayeeWithWRamt);
        for(let x=0; x<this.casePayeeWithWRamt.length; x++){
            //Case Role & Payee doesn't exist
            if(this.casePayeeWithWRamt[x].uwfCRonCaseExist == false && this.casePayeeWithWRamt[x].uwfPayeeonCaseExist == false){
                var newCRlist = {
                    Case__c : this.casePayeeWithWRamt[x].caseId,
                    Role__c : "State",
                    Case_Role_Status__c : "Active",
                    Entity__c : this.uwfAccId,
                    Account_Name__c : "DIR Accounting-Unpaid Wage Fund"
                };
                this.newCaseRoleArrList.push(newCRlist);
                var newPayeeList = {
                    Verification_Letter_Sent__c : true,
                    Status__c : "Verified",
                    Payee_Type__c : "UWF",
                    Case_Management__c : this.casePayeeWithWRamt[x].caseId,
                    Role__c : "State",
                    Factor__c : 100.00000
                };
                this.newPayeeArrList.push(newPayeeList);
            }
            //Case Role exist & Payee doesn't exist
            else if(this.casePayeeWithWRamt[x].uwfCRonCaseExist == true && this.casePayeeWithWRamt[x].uwfPayeeonCaseExist == false){
                //console.log('Case Role exist & Payee doesnot exist');
                var newPayeeList = {
                    Verification_Letter_Sent__c : true,
                    Status__c : "Verified",
                    Payee_Type__c : "UWF",
                    Case_Management__c : this.casePayeeWithWRamt[x].caseId,
                    Case_Role__c : this.casePayeeWithWRamt[x].uwfCRid,
                    Role__c : "State",
                    Factor__c : 100.00000
                };
                this.newPayeeArrList.push(newPayeeList);
            }
        }

        this.createWarrantsToBatch();
    }

    @track warrantsArrayList = [];
    @track allUWFPayeeExist = true;
    createWarrantsToBatch(){
        console.log('__________________ Inside createWarrantsToBatch __________________');
        console.log('Warrants needs to be created for each Cases');
        console.log(this.casePayeeWithWRamt)

        for(let k=0; k<this.wbListInserted.length; k++){
            console.log('Number of Case => Warrants');
            console.log(this.casePayeeWithWRamt.length);
            for(let l=0; l<this.casePayeeWithWRamt.length; l++){
                console.log("Warrant List for");
                console.log(this.casePayeeWithWRamt[l]);
                if(this.casePayeeWithWRamt[l].uwfPayeeonCaseExist == true){
                    var warrantList = {
                        Payee__c : this.casePayeeWithWRamt[l].uwfPayeeId,
                        Amount__c : this.casePayeeWithWRamt[l].wrAmt,
                        Case__c : this.casePayeeWithWRamt[l].caseId,
                        Status__c : 'New',
                        Case_Number__c: this.casePayeeWithWRamt[l].caseNumber,
                        Warrant_Batch__c : this.wbListInserted[k].Id,
                        Office_Account__c : this.wbListInserted[k].Office_Account__c,
                        Disbursement_Type__c : "Unpaid Wage Fund"
                    };
                    console.log(warrantList);
                    this.warrantsArrayList.push(warrantList);
                }
                else{
                    this.allUWFPayeeExist = false;
                    var warrantList = {
                        Payee__c : null,
                        Amount__c : this.casePayeeWithWRamt[l].wrAmt,
                        Case__c : this.casePayeeWithWRamt[l].caseId,
                        Status__c : 'New',
                        Case_Number__c: this.casePayeeWithWRamt[l].caseNumber,
                        Warrant_Batch__c : this.wbListInserted[k].Id,
                        Office_Account__c : this.wbListInserted[k].Office_Account__c,
                        Disbursement_Type__c : "Unpaid Wage Fund"
                    };
                    console.log(warrantList);
                    this.warrantsArrayList.push(warrantList);
                }
                
            }
        }
        console.log('Warrants to be inserted');
        console.log(this.warrantsArrayList);
        
        //Payment Records that needs to be updated
        //this.updatePRlist();

        //Get the array of Payee Names of which all PRs needs to be updated after Warrants are inserted
        this.updateFinalPayeelist();
    }

    /*
    @track allPRsToUpdate = [];
    updatePRlist(){
        console.log('__________________ Inside updatePRlist __________________');
        for(let a=0; a<this.casePayeeWithWRamt.length; a++){
            for(let b=0; b<this.casePayeeWithWRamt[a].payees.length; b++){
                for(let c=0; c<this.casePayeeWithWRamt[a].payees[b].Payment_Records__r.length; c++){
                    this.allPRsToUpdate.push(this.casePayeeWithWRamt[a].payees[b].Payment_Records__r[c]);
                }
            }
        }
        console.log('All PRs to Update after Warrants are inserted');
        console.log(this.allPRsToUpdate);

        //Check & format UWF Case Roles & Payees
        this.callQueuableClasses();
    }
    */

    @track finalListPayeeIDs = [];
    updateFinalPayeelist(){
        console.log('__________________ Inside updateFinalPayeelist __________________');
        for(let a=0; a<this.casePayeeWithWRamt.length; a++){
            for(let b=0; b<this.casePayeeWithWRamt[a].payees.length; b++){
                this.finalListPayeeIDs.push(this.casePayeeWithWRamt[a].payees[b].Id);
            }
        }
        console.log('Payees of which all PRs needs to be updated after Warrants are inserted');
        console.log(this.finalListPayeeIDs);

        //Check & format UWF Case Roles & Payees
        this.callQueuableClasses();
    }

    @track uwfPassed = false;
    @track uwfFailed = false;
    callQueuableClasses(){
        console.log('__________________ Inside callQueuableClasses __________________');
        console.log('New Case Roles that needs to be inserted');
        console.log(this.newCaseRoleArrList);
        console.log('New Payees that needs to be inserted');
        console.log(this.newPayeeArrList);
        console.log('Warrants to be inserted');
        console.log(this.warrantsArrayList);
        console.log('Payees of which all PRs needs to be updated after Warrants are inserted');
        console.log(this.finalListPayeeIDs);
        console.log('WB Link');
        console.log(this.wbURL);
        //console.log('All Payment Records that needs to be updated');
        //console.log(this.allPRsToUpdate);

        var apxInsertCRlist = this.newCaseRoleArrList;
        var apxInsertPayeelist = this.newPayeeArrList;
        var apxInsertWRlist = this.warrantsArrayList;
        var apxFinalPayeeIDs = this.finalListPayeeIDs;
        //var apxUpdatePRlist = this.allPRsToUpdate;

        if(apxInsertCRlist.length > 0){
            console.log('Insert UWF Case Role - Queueable');
            insertUWFCaseRole({crListToInsert: apxInsertCRlist, payeeListToInsert: apxInsertPayeelist, wrListToInsert: apxInsertWRlist, finalPayeeIds: apxFinalPayeeIDs, type: this.reqType, wbLink: this.wbURL})
            .then(result =>{
                console.log("Case Roles Inserted");
                this.uwfPassed = true;
            })
            .catch(error =>{
                console.log("Error while inserting UWF Case Roles");
                console.log(error);
                this.uwfFailed = true;
            })
        }
        
        else if(apxInsertCRlist.length == 0 && apxInsertPayeelist.length > 0){
            console.log('Insert UWF Payee - Queueable');
            insertUWFPayee({payeeListToInsert: apxInsertPayeelist, wrListToInsert: apxInsertWRlist, finalPayeeIds: apxFinalPayeeIDs, type: this.reqType, wbLink: this.wbURL})
            .then(result =>{
                console.log("UWF Payees Inserted");
                this.uwfPassed = true;
            })
            .catch(error =>{
                console.log("Error while inserting UWF Payees");
                console.log(error);
                this.uwfFailed = true;
            })
        }
        
        else if(apxInsertCRlist.length == 0 && apxInsertPayeelist.length == 0 && this.allUWFPayeeExist == true){
            console.log('Insert Warrants - Queueable');
            insertWrsUpdatePrs({wrListToInsert: apxInsertWRlist, finalPayeeIds: apxFinalPayeeIDs, type: this.reqType, wbLink: this.wbURL})
            .then(result =>{
                console.log("UWF Warrants Inserted");
                this.uwfPassed = true;
            })
            .catch(error =>{
                console.log("Error while inserting UWF Warrants");
                console.log(error);
                this.uwfFailed = true;
            })
        }
    }
}