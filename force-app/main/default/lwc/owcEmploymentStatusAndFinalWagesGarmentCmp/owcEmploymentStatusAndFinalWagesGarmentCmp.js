import { LightningElement, api,wire } from 'lwc';
import { radioOptions, customLabelValues} from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import { loadStyle } from 'lightning/platformResourceLoader';  
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';   
import OWCPaystubImage from '@salesforce/resourceUrl/OWCPaystubImage';

export default class OwcEmploymentStatusAndFinalWagesGarmentCmp extends LightningElement {
    @api personNameWhoDischargeYou
    @api EmpStatusAndWagesDetails
    @api nameOfPersonWhoHiredYou
    @api finalPaymentExplanation
    @api receivedFinalPayment2
    @api dischargedExplanation
    @api quitDateDischargeDate
    @api howWereYourWagesPaid
    @api receivedFinalPayment
    @api noticeBeforeQuiting
    @api customValidationMsg
    @api stillIdentifiedEmp
    @api chequeReplacedDate
    @api statementReceived
    @api isImageAvailable
    @api finalPaymentDate
    @api dischargedDate
    @api Paid_Type_List
    @api chequeReplaced
    @api statusOptions
    @api wereWagesPaid
    @api selectAnyOne
    @api Explanation
    @api whoPaidYou
    @api hireDate
    @api quitDate
    @api helpText
    @api options
    @api DateFS2
    @api paidByCheck = ''
    @api isDidntReceivedFinalPayment2 = false
    @api isDidntReceivedFinalPayment = false
    @api isCustomValidationVisible = false
    @api isreceivedFinalPayment2 = false
    @api isDishargedDateHeading = false
    @api isreceivedFinalPayment = false
    @api DischargeDateTemplate = false
    @api isstillIdentifiedEmp = false
    @api isFormPreviewMode = false
    @api isQuitDateHeading = false
    @api isChequeReplaced = false
    @api QuitDateTemplate = false
    @api isChequeBounce = false
    @api isHelpText = false
    @api isCheck = false
    @api isOther = false
    isreceivedFinalDischargePayment = false
    ispersonNameWhoDischargeYou = false
    isreceivedFinalQuitPayment = false
    isfinalPaymentExplanation = false
    isdischargedDatetemplate = false
    isdischargedExplanation = false
    ishowWereYourWagesPaid = false
    isquitDatetemplate = false
    isfinalPaymentDate = false
    isRenderedCallback = false
    isquitDateValue = false
    isselectAnyOne = false
    isExplanation = false
    isnoticeValue = false
    ishireDate = false
    isDateFS2 = false
    @api isPayStubRecord = false;
    @api payStubSickRecord;
    // Custom label values
    customLabelValues = customLabelValues
    // Radio group options
    options = radioOptions
    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`
    // This method will load static resources in connectedCallback.
    connectedCallback(){ 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
    });
    
    }
    // Toast message
    showToast(title, message, variant) {
       const event = new ShowToastEvent({
           title: title,
           message: message,
           variant: variant
       });
       this.dispatchEvent(event);
    }
    //For fetching the getOWCPreliminaryMetaData
    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data,error}) {
        if(data){
            this.Paid_Type_List = data[0].owcWagePaidTypes;
            this.statusOptions = data[0].owcYesOrNoPicklistOption;
            this.quitDateDischargeDate = data[0].owcQuitDateDischargeDate;
        }else{
            this.errorMsg = error;
        }
    }
    // This method will run on clicking on draft
    handleSaveAsDraft(){
        this.handleEmpStatusAndWagesEvent();
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "5"
            }
        });
        this.dispatchEvent(validateEvent);
    }
    //HireDate Validation with required and Past date
    hireDateValidityChecker(ids, values){
        let id = ids
        let value = values
        var inputDate
        var today = new Date();
        if(value != null){
            inputDate = new Date(value.toString());
        }else{
            inputDate = value;
        }
        if(value == null || value == undefined || value == ''){
            id.setCustomValidity('')
            id.reportValidity();
        return true;
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            id.reportValidity();
        return true;
        }
    }
    //Pase Date validation for the non required date fields
    dateValidityChecker(ids, values){
        let id = ids
        let value = values
        var inputDate
        var today = new Date();
        if(value != null){
            inputDate = new Date(value.toString());
        }else{
            inputDate = value;
        }
        if(value == null || value == undefined || value == ''){
            id.setCustomValidity('')
            id.reportValidity();
        return false;
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            id.reportValidity();
        return true;
        }
    }
    //Section validity Checker for the required fields  
    sectionValidityChecker(ids, values){
        let id = ids
        let value = values
        const val = value == undefined || value == null ? '' : value
        if(val.trim() == ""){
            id.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            id.reportValidity();
            return true;
        }
    }
    //Help Text handler
    handleHelpText(event){
        const learnMoreName = event.target.name;
        this.isHelpText = true;
        if(learnMoreName === "dateOfHireHelpText"){
            this.helpText = customLabelValues.OWC_Date_Of_Hire_helptext; 
            this.isImageAvailable = null
        }
        else if(learnMoreName === "statementReceivedHelpText"){
            this.helpText = '';
            this.isImageAvailable = OWCPaystubImage;
        }
        else if(learnMoreName === "dischargedDateHelpText"){
            this.helpText = customLabelValues.owc_dischargedDateHelpText;
            this.isImageAvailable = null
        }
    }
    //Handle Help Text
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }
    //Handle Change for storing the fields values in the variables
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {    
            case "howWereYourWagesPaid":            
                this.howWereYourWagesPaid = event.target.value
                //this.handleHowWereYourWagesPaidFocus()
                if(this.howWereYourWagesPaid === this.Paid_Type_List[1].value || this.howWereYourWagesPaid === this.Paid_Type_List[3].value){
                    this.isCheck = true;
                    this.isOther = false;
                    this.isChequeBounce = false;    
                    this.isChequeReplaced = false;
                    // this.template.querySelector('[data-id="paidByCheck"]').value = null;
                    this.Explanation = null
                    this.chequeReplaced = null
                    this.chequeReplacedDate = null
                }
                else if(this.howWereYourWagesPaid === this.Paid_Type_List[5].value){
                    this.isCheck = false;
                    this.isOther = true;
                    this.isChequeBounce = false;    
                    this.isChequeReplaced = false;
                    this.paidByCheck = null;
                    this.chequeReplaced = null
                    this.chequeReplacedDate = null
                }
                else{
                    this.isCheck = false;
                    this.isOther = false;
                    this.isChequeBounce = false;    
                    this.isChequeReplaced = false;
                    this.paidByCheck = null;
                    this.Explanation = null
                    this.chequeReplaced = null
                    this.chequeReplacedDate = null
                }
            break;
            case "hireDate":
                this.hireDate = event.target.value
                this.handleHireDateFocus();
            break;
            case "nameOfPersonWhoHiredYou":
                this.nameOfPersonWhoHiredYou = event.target.value
            break;
            case "payStubSickRecord":
                this.payStubSickRecord = event.target.value
            break;
            case "wereWagesPaid":
                this.wereWagesPaid = event.target.value
            break;
            case "paidByCheck":
                this.paidByCheck = event.target.value
                if(this.paidByCheck === customLabelValues.OWC_Yes){
                    this.isChequeBounce = true;    
                    this.isChequeReplaced = false;
                    this.chequeReplacedDate = null
                }else{
                    this.isChequeBounce = false;
                    this.isChequeReplaced = false;
                    this.chequeReplaced = null
                    this.chequeReplacedDate = null
                }
            break;
            case 'chequeReplaced':
                this.chequeReplaced = event.target.value
                if(this.chequeReplaced === customLabelValues.OWC_Yes){
                    this.isChequeReplaced = true;
                }else{
                    this.isChequeReplaced = false;
                    this.chequeReplacedDate = null
                }
            break;
            case 'chequeReplacedDate':
                this.chequeReplacedDate = event.target.value
                this.chequeReplacedDate != null ? this.handlechequeReplacedDateFocus() : ''
            break;
            case "Explanation":
                this.Explanation = event.target.value
                //this.handleExplanationFocus();
            break;
            case "statementReceived":
                if(event.target.value == this.statusOptions[0].label){
                    this.statementReceived = undefined
                }
                else{
                    this.statementReceived = event.target.value
                    this.statementReceived === this.statusOptions[1].value ? this.isPayStubRecord = true : this.isPayStubRecord = false;
                }
            break; 
            case "whoPaidYou":
                this.whoPaidYou = event.target.value
            break;
            case "stillIdentifiedEmp":
                this.stillIdentifiedEmp = event.target.value
                if(this.stillIdentifiedEmp == this.statusOptions[2].value){
                    this.isstillIdentifiedEmp = true;
                }
                else{
                    this.isstillIdentifiedEmp = false;
                    this.selectAnyOne = null
                    this.QuitDateTemplate = false;
                    this.DischargeDateTemplate =false;
                    this.isDischargeDateReset()
                    this.isQuitDateReset()
                }
            break;
            case "selectAnyOne":
                this.selectAnyOne = event.target.value
                //this.handleselectAnyOneFocus()
                if(this.selectAnyOne === this.quitDateDischargeDate[1].value){
                    this.QuitDateTemplate = false;
                    this.DischargeDateTemplate =true;
                    this.isQuitDateReset()
                }
                
                else if(this.selectAnyOne === this.quitDateDischargeDate[2].value){
                    this.QuitDateTemplate = true;
                    this.DischargeDateTemplate =false;
                    
                    this.isDischargeDateReset()
                }
                else{
                    this.QuitDateTemplate = false;
                    this.DischargeDateTemplate =false;
                }
            break;
            case "quitDate":
                this.quitDate = event.target.value
                this.quitDate != null ? this.isCustomValidationVisible = false : this.isCustomValidationVisible = true;
                this.quitDate != null ? this.handleQuitDateFocus() : ''
            break ; 
            case "noticeBeforeQuiting":
                this.noticeBeforeQuiting = event.target.value
                this.noticeBeforeQuiting != null ? this.isCustomValidationVisible = false : this.isCustomValidationVisible = false;
            break; 
            case "receivedFinalPayment":
                event.target.value != null ? this.isCustomValidationVisible = false : this.isCustomValidationVisible = true;
                if(event.target.value === 'No'){
                    this.receivedFinalPayment = event.target.value
                    this.isreceivedFinalPayment = false;
                    this.isDidntReceivedFinalPayment = true;
                    this.finalPaymentDate = null
                }
                else if(event.target.value === 'Yes'){
                    this.receivedFinalPayment = event.target.value
                    this.isreceivedFinalPayment = true;
                    this.isDidntReceivedFinalPayment = false;
                    this.finalPaymentExplanation = null
                }
                else{
                    this.receivedFinalPayment = undefined
                    this.isreceivedFinalPayment = false;
                    this.isDidntReceivedFinalPayment = false;
                    this.finalPaymentDate = null
                    this.finalPaymentExplanation = null
                }
            break;
            case "finalPaymentDate":
                this.finalPaymentDate = event.target.value
                this.finalPaymentDate != null ? this.isCustomValidationVisible = false : this.isCustomValidationVisible = true;
                this.handleFinalPaymentDateFocus();
            break; 
            case "dischargedDate":
                this.dischargedDate = event.target.value
                this.dischargedDate != null ? this.isCustomValidationVisible = false : this.isCustomValidationVisible = true;
                this.handleDischargedDateFocus();
            break; 
            case "personNameWhoDischargeYou":
                this.personNameWhoDischargeYou = event.target.value
                this.personNameWhoDischargeYou != null ? this.isCustomValidationVisible = false : this.isCustomValidationVisible = false;
            break; 
            case "receivedFinalPayment2":
                event.target.value != null ? this.isCustomValidationVisible = false : this.isCustomValidationVisible = true;
                if(event.target.value === 'No'){
                    this.receivedFinalPayment2 = event.target.value
                    this.isreceivedFinalPayment2 = false;
                    this.isDidntReceivedFinalPayment2 = true;
                    this.DateFS2 = null
                    
                }
                else if(event.target.value === 'Yes'){
                    this.receivedFinalPayment2 = event.target.value
                    this.isreceivedFinalPayment2 = true;
                    this.isDidntReceivedFinalPayment2 = false;
                    this.dischargedExplanation = null
                }
                else{
                    this.receivedFinalPayment2 = undefined
                    this.isreceivedFinalPayment2 = false;
                    this.isDidntReceivedFinalPayment2 = false;
                    this.DateFS2 = null
                    this.dischargedExplanation = null
                }
            break;
            case "finalPaymentExplanation":
                this.finalPaymentExplanation = event.target.value
                this.finalPaymentExplanation != null ? this.isCustomValidationVisible = false : this.isCustomValidationVisible = true;
                // this.handleFinalPaymentExplanationFocus();
            break; 
            case "DateFS2":
                this.DateFS2 = event.target.value
                this.DateFS2 != null ? this.isCustomValidationVisible = false : this.isCustomValidationVisible = true;
                this.handleDateFS2Focus();
            break; 
            case "dischargedExplanation":
                this.dischargedExplanation = event.target.value
                this.dischargedExplanation != null ? this.isCustomValidationVisible = false : this.isCustomValidationVisible = true;
                // this.handleDischargedExplanationFocus();
            break;     
        }     
    }
    //Quit Date Value Reset
    isQuitDateReset(){
        this.quitDate = null
        this.noticeBeforeQuiting = null
        this.receivedFinalPayment = null
        this.isreceivedFinalPayment = false;
        this.isDidntReceivedFinalPayment = false;
        this.finalPaymentDate = null
        this.finalPaymentExplanation = null
    }
    //Dishcharge Date Value Reset
    isDischargeDateReset(){
        this.dischargedDate = null
        this.personNameWhoDischargeYou = null
        this.receivedFinalPayment2 = null
        this.receivedFinalPayment2 = undefined
        this.isreceivedFinalPayment2 = false;
        this.isDidntReceivedFinalPayment2 = false;
        this.DateFS2 = null
        this.dischargedExplanation = null
    }
    //Hire Date Focus
    handleHireDateFocus(){
        var inputDate
        var today = new Date();
        let hireDate = this.template.querySelector('[data-id="hireDate"]');
        if(hireDate.value != null){
            inputDate = new Date(hireDate.value.toString());
        }else{
            inputDate = hireDate.value;
        }
        if(hireDate.value == null || hireDate.value == undefined || hireDate.value.trim() == ''){
            hireDate.setCustomValidity('')
            this.ishireDate = false;
            hireDate.reportValidity();
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            hireDate.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            this.ishireDate = true;
            hireDate.reportValidity();
        }
        else{
            hireDate.setCustomValidity('');
            this.ishireDate = false;
            hireDate.reportValidity();
        }
    }
    //How were your wages paid focus
    handleHowWereYourWagesPaidFocus(){
        let howWereYourWagesPaid = this.template.querySelector('[data-id="howWereYourWagesPaid"]');          
        if(howWereYourWagesPaid.value == undefined || howWereYourWagesPaid.value == null || howWereYourWagesPaid.value.trim() == ''){
            howWereYourWagesPaid.setCustomValidity('');
            this.ishowWereYourWagesPaid = false;
        }
        else{
            howWereYourWagesPaid.setCustomValidity("");
            this.ishowWereYourWagesPaid = false;
        }
        howWereYourWagesPaid.reportValidity();
    }
     //Select Any One
    handleselectAnyOneFocus(){
        let selectAnyOne = this.template.querySelector('[data-id="selectAnyOne"]');            
        if(selectAnyOne.value == undefined || selectAnyOne.value == null || selectAnyOne.value.trim() == ''){
            selectAnyOne.setCustomValidity('');
            this.isselectAnyOne = true;
        }
        else{
            selectAnyOne.setCustomValidity("");
            this.isselectAnyOne = false;
        }
        selectAnyOne.reportValidity();
    }
    //Explantion focus
    handleExplanationFocus(){
        let Explanation = this.template.querySelector('[data-id="Explanation"]');            
        if(Explanation.value == undefined || Explanation.value == null || Explanation.value.trim() == ''){
            Explanation.setCustomValidity('');
            this.isExplanation = false;
        }
        else{
            Explanation.setCustomValidity("");
            this.isExplanation = false;
        }
        Explanation.reportValidity();
    }
    //final Payment date focus
    handleFinalPaymentDateFocus(){
        var inputDate
        var today = new Date();
        let finalPaymentDate = this.template.querySelector('[data-id="finalPaymentDate"]');
        if(finalPaymentDate.value != null){
            inputDate = new Date(finalPaymentDate.value.toString());
        }else{
            inputDate = finalPaymentDate.value;
        }
        if(finalPaymentDate.value == null || finalPaymentDate.value == undefined || finalPaymentDate.value.trim() == ''){
            finalPaymentDate.setCustomValidity('')
            finalPaymentDate.reportValidity();
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            finalPaymentDate.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            finalPaymentDate.reportValidity();
        }
        else{
            finalPaymentDate.setCustomValidity('');
            finalPaymentDate.reportValidity();
        }
    }
    //final payment explantion focus     
    handleFinalPaymentExplanationFocus(){
        let finalPaymentExplanation = this.template.querySelector('[data-id="finalPaymentExplanation"]');            
        if(finalPaymentExplanation.value == undefined || finalPaymentExplanation.value == null || finalPaymentExplanation.value.trim() == ''){
            finalPaymentExplanation.setCustomValidity('');
        }
        else{
            finalPaymentExplanation.setCustomValidity("");
        }
        finalPaymentExplanation.reportValidity();
    } 
    //fieldset 2 date foucs 
    handleDateFS2Focus(){
        var inputDate
        var today = new Date();
        let DateFS2 = this.template.querySelector('[data-id="DateFS2"]');
        if(DateFS2.value != null){
            inputDate = new Date(DateFS2.value.toString());
        }else{
            inputDate = DateFS2.value;
        }
        if(DateFS2.value == null || DateFS2.value == undefined || DateFS2.value.trim() == ''){
            DateFS2.setCustomValidity('')
            DateFS2.reportValidity();
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            DateFS2.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            DateFS2.reportValidity();
        }
        else{
            DateFS2.setCustomValidity('');
            DateFS2.reportValidity();
        }
    }
    //Discharged expklanation focus
    handleDischargedExplanationFocus(){
        let dischargedExplanation = this.template.querySelector('[data-id="dischargedExplanation"]');            
        if(dischargedExplanation.value == undefined || dischargedExplanation.value == null || dischargedExplanation.value.trim() == ''){
            dischargedExplanation.setCustomValidity('');
        }
        else{
            dischargedExplanation.setCustomValidity("");
        }
        dischargedExplanation.reportValidity();
    } 
    //Quit date focus  
    handleQuitDateFocus(){
        var inputDate
        var today = new Date();
        let quitDate = this.template.querySelector('[data-id="quitDate"]');
        if(quitDate.value != null){
            inputDate = new Date(quitDate.value.toString());
        }else{
            inputDate = quitDate.value;
        }
        if(quitDate.value == null || quitDate.value == undefined || quitDate.value.trim() == ''){
            quitDate.setCustomValidity('')
            quitDate.reportValidity();
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            quitDate.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            quitDate.reportValidity();
        }
        else{
            quitDate.setCustomValidity('');
            quitDate.reportValidity();
        }
    } 
    //Dischanred date focus
    handleDischargedDateFocus(){
        var inputDate
        var today = new Date();
        let dischargedDate = this.template.querySelector('[data-id="dischargedDate"]');
        if(dischargedDate.value != null){
            inputDate = new Date(dischargedDate.value.toString());
        }else{
            inputDate = dischargedDate.value;
        }
        if(dischargedDate.value == null || dischargedDate.value == undefined || dischargedDate.value.trim() == ''){
            dischargedDate.setCustomValidity('')
            dischargedDate.reportValidity();
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            dischargedDate.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            dischargedDate.reportValidity();
        }
        else{
            dischargedDate.setCustomValidity('');
            dischargedDate.reportValidity();
        }
    }   
    //chequeReplacedDate date focus 
    handlechequeReplacedDateFocus(){
        var inputDate
        var today = new Date();
        let chequeReplacedDate = this.template.querySelector('[data-id="chequeReplacedDate"]');
        if(chequeReplacedDate.value != null){
            inputDate = new Date(chequeReplacedDate.value.toString());
        }else{
            inputDate = chequeReplacedDate.value;
        }
        if(chequeReplacedDate.value == null || chequeReplacedDate.value == undefined || chequeReplacedDate.value.trim() == ''){
            chequeReplacedDate.setCustomValidity('');
            this.ischequeReplacedDate = false;
            chequeReplacedDate.reportValidity();
        }else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            chequeReplacedDate.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            this.ischequeReplacedDate = true;
            chequeReplacedDate.reportValidity();
        }
        else{
            chequeReplacedDate.setCustomValidity('');
            this.ischequeReplacedDate = false;
            chequeReplacedDate.reportValidity();
        }
    }  
    // This Method store all the value of its component
    handleEmpStatusAndWagesEvent(){  
        const selectEvent = new CustomEvent('empstatusandfinalwagescustomevent', {
            detail: {
                QuitDateTemplate : this.QuitDateTemplate,
                DischargeDateTemplate : this.DischargeDateTemplate,
                hireDate : this.hireDate,
                nameOfPersonWhoHiredYou : this.nameOfPersonWhoHiredYou,
                wereWagesPaid : this.wereWagesPaid,
                howWereYourWagesPaid : this.howWereYourWagesPaid,
                isCheck : this.isCheck,
                paidByCheck : this.paidByCheck,
                isChequeBounce : this.isChequeBounce,
                chequeReplaced : this.chequeReplaced,
                isChequeReplaced:this.isChequeReplaced,
                chequeReplacedDate:this.chequeReplacedDate,
                isOther : this.isOther,
                Explanation : this.Explanation,    
                statementReceived : this.statementReceived,
                isPayStubRecord : this.isPayStubRecord,
                whoPaidYou : this.whoPaidYou,
                stillIdentifiedEmp : this.stillIdentifiedEmp,
                selectAnyOne : this.selectAnyOne,
                isstillIdentifiedEmp : this.isstillIdentifiedEmp,
                quitDate : this.quitDate,
                noticeBeforeQuiting : this.noticeBeforeQuiting,
                receivedFinalPayment : this.receivedFinalPayment,
                isreceivedFinalPayment : this.isreceivedFinalPayment,
                isDidntReceivedFinalPayment : this.isDidntReceivedFinalPayment,
                finalPaymentDate : this.finalPaymentDate,
                finalPaymentExplanation : this.finalPaymentExplanation,
                dischargedDate : this.dischargedDate,
                personNameWhoDischargeYou : this.personNameWhoDischargeYou,
                receivedFinalPayment2 : this.receivedFinalPayment2,
                isreceivedFinalPayment2 : this.isreceivedFinalPayment2,
                isDidntReceivedFinalPayment2 : this.isDidntReceivedFinalPayment2,
                DateFS2 : this.DateFS2,
                payStubSickRecord : this.payStubSickRecord,
                dischargedExplanation : this.dischargedExplanation,
            }
        });
        this.dispatchEvent(selectEvent);
    }
    // This Method make current step true
    handleCustomValidityEvent(){
        const selectEvent = new CustomEvent('empstatusandfinalwagesvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.dispatchEvent(selectEvent);
    }
    // This Method will check validation and also send value to parent
    @api
    owcEmpStatusAndWagesDataForParent(){
        this.handleHireDateFocus();
        let hireDate = this.template.querySelector('[data-id="hireDate"]');
        this.ishireDate === true ? hireDate.focus() : ''
        this.ishireDate === true ? this.handleCustomValidityEvent() : this.handleEmpStatusAndWagesEvent();
        
        
        if( this.QuitDateTemplate === true){
            let quitDateValue = this.template.querySelector('[data-id="quitDate"]');
            let noticeValue = this.template.querySelector('[data-id="noticeBeforeQuiting"]');
            if(quitDateValue.value === undefined || quitDateValue.value === null || quitDateValue.value.trim() === ''){
                this.isquitDateValue = false;
            }else{
                this.isquitDateValue = false;
            }
            if(noticeValue.value === undefined || noticeValue.value === null || noticeValue.value.trim() === ''|| noticeValue.value === '--Select--'){
                this.isnoticeValue = false;
            }else{
                this.isnoticeValue = false;
            }
            if(this.isquitDateValue === true ||  this.isnoticeValue === true  ) {
                this.handleCustomValidityEvent()
                this.customValidationMsg = customLabelValues.OWC_EmpStatusRequiredMsg 
                this.isCustomValidationVisible = false 
            }else{
                this.customValidationMsg = '' 
                this.isCustomValidationVisible = false
                this.handleEmpStatusAndWagesEvent();
            } 
        }
        if( this.DischargeDateTemplate === true){
            let dischargedDate = this.template.querySelector('[data-id="dischargedDate"]');

            if(dischargedDate.value === undefined || dischargedDate.value === null || dischargedDate.value.trim() === ''){
                this.isdischargedDate = false;
            }else{
                this.isdischargedDate = false;
            }
            if(this.isdischargedDate === true ) {
                this.handleCustomValidityEvent()
                this.customValidationMsg = customLabelValues.OWC_EmpStatusRequiredMsg 
                this.isCustomValidationVisible = false 
            }
            else{
                this.customValidationMsg = '' 
                this.isCustomValidationVisible = false
                this.handleEmpStatusAndWagesEvent();
            }     
        }    
        if(this.DischargeDateTemplate === true && this.dischargedDate != null){
            let dischargedDate = this.template.querySelector('[data-id="dischargedDate"]');
            let dischargedDateValue = this.dischargedDate
            this.isdischargedDatetemplate = this.hireDateValidityChecker(dischargedDate, dischargedDateValue);
            this.isdischargedDatetemplate === true ? dischargedDate.focus() : ''
            this.isdischargedDatetemplate === true ? this.handleCustomValidityEvent() : this.handleEmpStatusAndWagesEvent();
        }
        if(this.QuitDateTemplate === true && this.quitDate != null){
            let quitDate = this.template.querySelector('[data-id="quitDate"]');
            let quitDateValue = this.quitDate
            this.isquitDatetemplate = this.hireDateValidityChecker(quitDate, quitDateValue);
            this.isquitDatetemplate === true ? quitDate.focus() : ''
            this.isquitDatetemplate === true ? this.handleCustomValidityEvent() : this.handleEmpStatusAndWagesEvent();
        }
        // if(this.isDidntReceivedFinalPayment === true){
        //     let finalPaymentExplanation = this.template.querySelector('[data-id="finalPaymentExplanation"]');
        //     let finalPaymentExplanationValue = this.finalPaymentExplanation
        //     this.isfinalPaymentExplanation = this.sectionValidityChecker(finalPaymentExplanation, finalPaymentExplanationValue);
        //     this.isfinalPaymentExplanation === true ? finalPaymentExplanation.focus() : ''
        //     this.isfinalPaymentExplanation === true ? this.handleCustomValidityEvent() : this.handleEmpStatusAndWagesEvent();
        // }
        // if(this.isDidntReceivedFinalPayment2 === true){
        //     let dischargedExplanation = this.template.querySelector('[data-id="dischargedExplanation"]');
        //     let dischargedExplanationValue = this.dischargedExplanation
        //     this.isdischargedExplanation = this.sectionValidityChecker(dischargedExplanation, dischargedExplanationValue);
        //     this.isdischargedExplanation === true ? dischargedExplanation.focus() : ''
        //     this.isdischargedExplanation === true ? this.handleCustomValidityEvent() : this.handleEmpStatusAndWagesEvent();
        // }
        this.handleEmpStatusAndWagesEvent();
    }
    // This Method will fetch values from parent component
    @api
    owcEmpStatusAndWagesDataForChild(strString, isFormPreviewMode){
        this.EmpStatusAndWagesDetails = strString
        this.QuitDateTemplate =strString.QuitDateTemplate
        this.DischargeDateTemplate =strString.DischargeDateTemplate
        this.isFormPreviewMode = isFormPreviewMode
        this.nameOfPersonWhoHiredYou = strString.nameOfPersonWhoHiredYou
        this.wereWagesPaid = strString.wereWagesPaid
        this.howWereYourWagesPaid = strString.howWereYourWagesPaid
        this.isCheck = strString.isCheck
        this.paidByCheck = strString.paidByCheck 
        this.isChequeBounce = strString.isChequeBounce
        this.chequeReplaced = strString.chequeReplaced
        this.isChequeReplaced = strString.isChequeReplaced
        this.chequeReplacedDate = strString.chequeReplacedDate
        this.isOther = strString.isOther                     
        this.Explanation = strString.Explanation
        this.whoPaidYou = strString.whoPaidYou
        this.isstillIdentifiedEmp = strString.isstillIdentifiedEmp
        this.quitDate = strString.quitDate
        this.noticeBeforeQuiting = strString.noticeBeforeQuiting 
        this.receivedFinalPayment = strString.receivedFinalPayment
        this.isreceivedFinalPayment = strString.isreceivedFinalPayment
        this.isDidntReceivedFinalPayment = strString.isDidntReceivedFinalPayment
        this.finalPaymentDate = strString.finalPaymentDate
        this.finalPaymentExplanation = strString.finalPaymentExplanation
        this.dischargedDate = strString.dischargedDate
        this.personNameWhoDischargeYou = strString.personNameWhoDischargeYou
        this.receivedFinalPayment2 = strString.receivedFinalPayment2
        this.isreceivedFinalPayment2 = strString.isreceivedFinalPayment2
        this.isDidntReceivedFinalPayment2 = strString.isDidntReceivedFinalPayment2        
        this.DateFS2 = strString.DateFS2
        this.isPayStubRecord = strString.isPayStubRecord
        this.payStubSickRecord = strString.payStubSickRecord
        this.selectAnyOne = strString.selectAnyOne
        this.dischargedExplanation = strString.dischargedExplanation
        if(this.isFormPreviewMode === true){
            if(this.EmpStatusAndWagesDetails.quitDate != undefined || this.EmpStatusAndWagesDetails.noticeBeforeQuiting != undefined || this.EmpStatusAndWagesDetails.receivedFinalPayment != undefined || this.EmpStatusAndWagesDetails.finalPaymentDate != undefined || this.EmpStatusAndWagesDetails.finalPaymentExplanation != undefined){
                this.isQuitDateHeading = true
            }
            else{
                this.isQuitDateHeading = false
            }
            
            if(this.EmpStatusAndWagesDetails.dischargedDate != undefined || this.EmpStatusAndWagesDetails.personNameWhoDischargeYou != undefined || this.EmpStatusAndWagesDetails.receivedFinalPayment2 != undefined || this.EmpStatusAndWagesDetails.DateFS2 != undefined || this.EmpStatusAndWagesDetails.dischargedExplanation != undefined){
                this.isDishargedDateHeading = true
            }
            else{
                this.isDishargedDateHeading = false
            }
        }
        if(isNaN(strString.hireDate)){
            this.template.querySelector('[data-id="hireDate"]').value = strString.hireDate
            this.hireDate = strString.hireDate
        }
        if(isNaN(strString.howWereYourWagesPaid)){
            this.template.querySelector('[data-id="howWereYourWagesPaid"]').value = strString.howWereYourWagesPaid
        }
        if(isNaN(strString.statementReceived)){
                    this.template.querySelector('[data-id="statementReceived"]').value = strString.statementReceived
                    this.statementReceived = strString.statementReceived
        }
        console.log('Question 6 value>>>>>>>',strString.stillIdentifiedEmp);
        if(isNaN(strString.stillIdentifiedEmp)){
            this.template.querySelector('[data-id="stillIdentifiedEmp"]').value = strString.stillIdentifiedEmp
            this.stillIdentifiedEmp = strString.stillIdentifiedEmp
        }
        this.isRenderedCallback = true
    }
    // This Method will fetch values from parent component and store in fields
    renderedCallback(){
        if(this.isCheck === true){
            if(Boolean(this.paidByCheck) && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="paidByCheck"]').value = this.paidByCheck
            }
        }
        if(Boolean(this.payStubSickRecord) && this.isPayStubRecord === true){
            this.template.querySelector('[data-id="payStubSickRecord"]').value = this.payStubSickRecord
        }
        if(this.isChequeBounce === true){
            if(Boolean(this.chequeReplaced) && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="chequeReplaced"]').value = this.chequeReplaced
            }
        }
        if(this.isstillIdentifiedEmp === true){
            if(Boolean(this.quitDate) && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="quitDate"]').value = this.quitDate
            }
            if(Boolean(this.QuitDateTemplate) && Boolean(this.noticeBeforeQuiting) && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="noticeBeforeQuiting"]').value = this.noticeBeforeQuiting
            }
            if(Boolean(this.receivedFinalPayment) && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="receivedFinalPayment"]').value = this.receivedFinalPayment
            }
            if(Boolean(this.receivedFinalPayment2) && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="receivedFinalPayment2"]').value = this.receivedFinalPayment2
            }
        }
    }
}