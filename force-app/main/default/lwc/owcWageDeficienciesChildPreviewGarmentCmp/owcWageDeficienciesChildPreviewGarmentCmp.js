import { LightningElement, api ,track, wire } from 'lwc';
import { radioOptions, acceptedFileFormat, customLabelValues } from 'c/owcUtils';
import severancePayOfferedOptions from '@salesforce/apex/OwcWageDeficiencies.fetchseverancePayOfferedOption';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class OwcWageDeficienciesChildContainerCmp extends LightningElement {
    @track fileNames = '';
    @track filesUploaded = [];

    options = radioOptions
    @api salaryratelist
    @api multiplehourlyrate
    @api hourlyratelist
    @api minimumwage
    @api userworkedhours
    @api stateratelist;
    @api isfarmlabour;
    // Attributes
    @api isRenderedCallback = false;
    @api isFormPreviewMode = false;
    @api sectionid;
    @api paidbycheck;
    @api noticebeforequit
    @api werewagespaid
    @api quitdatevalue
    @api finalpaymentdate;
    // Attributes
    @api severancePayOfferedOptions
    @api claimPeriodStartDate;
    @api claimPeriodEndDate;
    @api notPaidForWork = false;
    @api wageDeficiencyPreviewDetail;
    @api showOneHourlyRateTemplate = false;
    @api hourlyRateList;
    @api hourlyRate = 0;
    @api isOneHourlyRate = false;
    @api isLocalMinimumWage = false;
    @api isStateMinimumWage = false;
    @api isFirstOptionTrue;
    @api noOvertimePaid = false;
    @api isSecondOptionTrue = false;
    @api noSickLeavePaid = false;
    @api isThirdOptionTrue = false;
    @api notPaidForVacationTime = false;
    @api isFourthOptionTrue = false;
    @api notPaidForHoliday = false;
    @api isFifthOptionTrue = false;
    @api notAllowedBathBreak = false;
    @api isSixthOptionTrue = false;
    @api notAllowedMealBreak = false;
    @api isSeventhOptionTrue = false;
    @api notAllowedForHeatRest = false;
    @api isEightOptionTrue = false;
    @api notPaidSeverancePay = false;
    @api isNinethOptionTrue = false;
    @api deniedShareTips = false;
    @api isTenthOptionTrue = false;
    @api deniedBusinessCost = false;
    @api isEleventhOptionTrue = false;
    @api deniedPaymentMilega = false;
    @api isTwelveOptionTrue = false;
    @api paycheckDeduction = false;
    @api isThirteenthOptionTrue = false;
    @api deniedPayrollInfo = false;
    @api isFouteenOptionTrue = false;
    @api deniedPersonnelFile = false;
    @api isFifteenOptionTrue = false;
    @api employerDeniedWork = false;
    @api isSixteenOptionTrue = false;
    @api productionBonus = false;
    @api isSeventeenOptionTrue = false;
    @api reportedToWork = false;
    @api garmentWageClaim = false
    @api isEighteenOptionTrue = false;
    @api isNinteenOptionTrue = false;
    @api holidayPay;
    @api isHolidayPay = false;
    @api isHolidayPayClaim = false;
    @api serverancePay;
    @api isSeverancePay = false;
    @api explainProdBonus;
    @api additionalClaimEarn;
    @api anotherClaimExplain;
    @api paystubstatement;
    @api heatrecovery
    @api isHeatRestDef = false;
    @api minimumrates
    @api staterate
    @api isLoading = false;
    @api paidbreaks;

    // Additional Section attributes
    @api isWrittenStatement = false;
    @api isLatePayroll = false;
    @api isInsufficientFund = false;
    @api isWaitingTime = false;
    @api beggingDatePayroll;
    @api endingDatePayroll;
    @api empstatementprovided;

    // Other workLocation attributes
    @api localMinimumWage;
    @api stateMinimumWage;
    @api minimumWage;
    @api dischargeddate;
    @api otherworkcity;
    @api paystubsickrecord;

    // Minimum wage Attribute
    @api minimumwagezipcode;
    @api minimumhiredate;
    @api stateminwagerate;

    @api workNotPaidDetails = [];
    @api powdetails;
    @api isnotidentifyemployer
    
    @api renderWorkedNotPaidSection = [];
    @api workedNotPaidSectionDetails = []
    @api workedNotPaidSectionValues = ''
    @api isNotChangedCurrentStep = false
    @api deleteWorkedNotPaidSection
    @api workedNotPaidSectionDataAfterDelete = []
    @api isWorkedNotPaidSectionDeleted = false
    @api claimPoolTips
    @api claimTipReceived
    @api iwcinfoobj;
    @api isSeverancePayTrue = false;
    @api iswagedefpreview;
    flag = 0
    flag1 = 1

    @track isRenderWorkedNotPaidSection = true

    @api get isClaimHeading(){
        return this.isHeatRestDef === true || this.isWrittenStatement === true || this.isLatePayroll === true || this.paidbycheck === true || this.showWaitingTimeClaim === true || this.isFirstOptionTrue === true || this.isSecondOptionTrue === true || this.isThirdOptionTrue === true || this.isFourthOptionTrue === true || this.isFifthOptionTrue === true || this.isSixthOptionTrue === true || this.isSeventhOptionTrue === true || this.isEightOptionTrue === true || this.isNinethOptionTrue === true || this.isTenthOptionTrue === true || this.isEleventhOptionTrue === true || this.isTwelveOptionTrue === true || this.isThirteenthOptionTrue === true || this.isFouteenOptionTrue === true || this.anotherClaimExplain !== undefined
    }

    @wire(severancePayOfferedOptions)
    wiredfetchdata({ data,error}) {
            if(data){
                this.severancePayOfferedOptions = data;
            }else{
                this.errorMsg = error;
            }
    }

    repeatClaim(){
        this.isRenderWorkedNotPaidSection = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderWorkedNotPaidSection.push({ heading : this.customLabelValues.OWC_regular_wages_claim_heading, button : true, sectionId : this.flag1 })
        this.isRenderWorkedNotPaidSection = true
    }

    handleWageDefDeleteEvent(event){
        const workNotPaidInformationSectionData = event.detail.InfoObj
        this.workedNotPaidSectionDataAfterDelete.push(workNotPaidInformationSectionData)
    }

    handleSectionDelete(event){
        var flag1 = 1
        const workNotPaidInfoAfterDelete = []
        this.isRenderWorkedNotPaidSection = false
        this.workedNotPaidSectionDataAfterDelete.length = 0
        this.deleteWorkNotPaidSectionId = event.currentTarget.name
        const workNotPaidSectionDetails = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate')
        for (let i = 0; i < workNotPaidSectionDetails.length; i++){
            workNotPaidSectionDetails[i].handleWageDeficienciesSectionData()
        }
        const deleteSectionDataIndex = this.workedNotPaidSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteWorkNotPaidSectionId)
        this.workedNotPaidSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        const deletedSectionIndex = this.renderWorkedNotPaidSection.findIndex(sec => sec.sectionId === this.deleteWorkNotPaidSectionId)
        this.renderWorkedNotPaidSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderWorkedNotPaidSection.length ;i++){
            flag1 = 1 + i
            if(this.renderWorkedNotPaidSection[i].heading === this.customLabelValues.OWC_claim_information){
                workNotPaidInfoAfterDelete.push(this.renderWorkedNotPaidSection[i])
            }
            else{
                workNotPaidInfoAfterDelete.push({ heading : this.customLabelValues.OWC_regular_wages_claim_heading, button : true, sectionId : flag1 })
            }
        }
        this.renderWorkedNotPaidSection.length = 0
        for (var i of workNotPaidInfoAfterDelete){
            this.renderWorkedNotPaidSection.push(i)
        }
        this.flag1 = this.renderWorkedNotPaidSection.length
        this.isRenderWorkedNotPaidSection = true
        this.isWorkedNotPaidSectionDeleted = true
        this.showToast('Success!',this.customLabelValues.OWC_deleteSection_msg,'success')
    }

    // Accepted formats for File Upload Section
    get acceptedFormats() {
        return acceptedFileFormat;
    }

    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    customLabelValues = customLabelValues    

    connectedCallback(){
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
            console.log( error.body.message );
        });
        console.log('paidbycheck ::: ', this.paidbycheck)

        this.paymentOfWagesDetails = this.powdetails
        this.empstatementprovided === 'No' ? this.handleWrittenStatement() : this.violationTypeVariablesForWrittenStatement !== undefined ? this.violationTypeVariablesForWrittenStatement.length = 0 : ''
        this.heatrecovery === 'No' ? this.isHeatRestDef = true : this.isHeatRestDef = false;
        this.isEightOptionTrue === true || this.heatrecovery === 'No' ? '' : this.restClaimCaseIssueData !== undefined ? this.restClaimCaseIssueData.length = 0 : ''
        this.werewagespaid === true ? this.isLatePayroll = true : this.isLatePayroll = false
        this.isLatePayroll === true ? this.handleLatePayrollServerCall() : ''
        
    }

    @api get showWaitingTimeClaim(){
        return this.isnotidentifyemployer === 'No';
    }

    async callHolidayServer(){
        try{
            await this.getAllVilationTypeVariablesForHolidayPay('HP1');
        }catch (error){
            console.log('error', error);
        }
    }

    async callSeverancePayIssue(){
        try{
            await this.getAllVilationTypeVariablesForSeverancePay('SP1');
        }catch (error){
            console.log('error', error);
        }
    }

    @api isSectionHide = false;
    handleWageHourlyNoData(event){
        this.isSectionHide = event.detail.isSectionHide
    }

    async handleLatePayrollServerCall(){
        try{
            await this.getAllVilationTypeVariablesForLatePayroll('20');
        }catch (error){
            console.log('error', error);
        }
    }
    async handleWrittenStatement(){
        try{
            await this.getAllVilationTypeVariablesForWrittenStatement('PE12');
        }catch (error){
            console.log('error', error);
        }
    }

   

    async handleDeniedBusinessCostCall(){
        try{
            await this.getAllVilationTypeVariablesForBusinessCost('17');
        }catch (error){
            console.log('error', error);
        }
    }

    @api violationTypeVariablesForHolidayPay;
    @api isHolidayPays = false;
    getAllVilationTypeVariablesForHolidayPay(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForHolidayPay !== undefined){
                 }
                 else{
                    this.violationTypeVariablesForHolidayPay = result;
                 }
            }
        })
        .catch(error => {
            
        })
    }

    @api violationTypeVariablesForSeverancePay;
    @api isSeverancePays = false;
    getAllVilationTypeVariablesForSeverancePay(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    if(result[i].dataType === 'Date'){
                        result[i].dateFormat = true;
                    }
                    else if(result[i].dataType === 'Currency'){
                        result[i].currencyFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForSeverancePay !== undefined){
                 }
                 else{
                    this.violationTypeVariablesForSeverancePay = result;
                    this.violationTypeVariablesForSeverancePay.length > 0 ? this.isSeverancePays = true : this.isSeverancePays = false;
                 }
            }
        })
        .catch(error => {
            
        })
    }

    @api violationTypeVariablesForLatePayroll
    getAllVilationTypeVariablesForLatePayroll(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    if(result[i].dataType === 'Date'){
                        result[i].dateFormat = true;
                    }
                    else if(result[i].dataType === 'Currency'){
                        result[i].currencyFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForLatePayroll !== undefined){
                 }
                 else{
                    this.violationTypeVariablesForLatePayroll = result;
                    this.violationTypeVariablesForLatePayroll.length > 0 ? this.isLatePayroll = true : this.isLatePayroll = false;
                 }
            }
        })
        .catch(error => {
            
        })
    }
    @api violationTypeVariablesForWrittenStatement;
    getAllVilationTypeVariablesForWrittenStatement(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    if(result[i].dataType === 'Date'){
                        result[i].dateFormat = true;
                    }
                    else if(result[i].dataType === 'Currency'){
                        result[i].currencyFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForWrittenStatement !== undefined){
                 }
                 else{
                    this.violationTypeVariablesForWrittenStatement = result;
                    this.violationTypeVariablesForWrittenStatement.length > 0 ? this.isWrittenStatement = true : this.isWrittenStatement = false;
                 }
                 this.empstatementprovided === 'No' ? this.isWrittenStatement = true : this.isWrittenStatement = false
            }
        })
        .catch(error => {
            
        })
    }

    @api violationTypeVariablesForBusinessCost;
    @api isBusinessCost = false;
    getAllVilationTypeVariablesForBusinessCost(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    if(result[i].dataType === 'Date'){
                        result[i].dateFormat = true;
                    }
                    else if(result[i].dataType === 'Currency'){
                        result[i].currencyFormat = true;
                    }
                    else if(result[i].dataType === 'Decimal' || result[i].dataType === 'Integer'){
                        result[i].numberFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForBusinessCost !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForBusinessCost = result;
                    this.violationTypeVariablesForBusinessCost.length > 0 ? this.isBusinessCost = true : this.isBusinessCost = false;
                 }
            }
        })
        .catch(error => {
            
        })
    }

    async handlePersonalFileCall(){
        try{
            await this.getAllVilationTypeVariablesForPersonalInfo('015');
        }catch (error){
            console.log('error', error);
        }
    }

    async handleProductionBonusCall(){
        try{
            await this.getAllVilationTypeVariablesForProductionBonus('016');
        }catch (error){
            console.log('error', error);
        }
    }

    @api violationTypeVariablesForProductionBonus;
    @api isProductionBonus = false;
    getAllVilationTypeVariablesForProductionBonus(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    if(result[i].dataType === 'Date'){
                        result[i].dateFormat = true;
                    }
                    else if(result[i].dataType === 'Currency'){
                        result[i].currencyFormat = true;
                    }
                    else if(result[i].dataType === 'Decimal' || result[i].dataType === 'Integer'){
                        result[i].numberFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForProductionBonus !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForProductionBonus = result;
                    this.violationTypeVariablesForProductionBonus.length > 0 ? this.isProductionBonus = true : this.isProductionBonus = false;
                 }
                // this.violationTypeVariablesForProductionBonus = result;
            }
        })
        .catch(error => {
            
        })
    }

    @api violationTypeVariablesForPersonalFile;
    @api isPersonalFile = false;
    getAllVilationTypeVariablesForPersonalInfo(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                this.violationTypeVariablesForPersonalFile = result;
            }
        })
        .catch(error => {
            
        })
    }

    async handlePayRollInfoCall(){
        try{
            await this.getAllVilationTypeVariablesForPayRollInfo('014');
        }catch (error){
            console.log('error', error);
        }
    }

    @api violationTypeVariablesForPayRoll;
    @api isPayRollInfo = false;
    getAllVilationTypeVariablesForPayRollInfo(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    if(result[i].dataType === 'Date'){
                        result[i].dateFormat = true;
                    }
                    else if(result[i].dataType === 'Currency'){
                        result[i].currencyFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                }
                 if(this.violationTypeVariablesForPayRoll !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForPayRoll = result;
                    this.violationTypeVariablesForPayRoll.length > 0 ? this.isPayRollInfo = true : this.isPayRollInfo = false;
                 }
            }
        })
        .catch(error => {
            
        })
    }

    async handlePayCheckCall(){
        try{
            await this.getAllVilationTypeVariablesForPayCheck('013');
        }catch (error){
            console.log('error', error);
        }
    }

    @api violationTypeVariablesForPayCheck;
    @api isPayCheck = false;
    getAllVilationTypeVariablesForPayCheck(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    if(result[i].dataType === 'Date'){
                        result[i].dateFormat = true;
                    }
                    else if(result[i].dataType === 'Currency'){
                        result[i].currencyFormat = true;
                    }
                    else if(result[i].dataType === 'Decimal' || result[i].dataType === 'Integer'){
                        result[i].numberFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForPayCheck !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForPayCheck = result;
                    this.violationTypeVariablesForPayCheck.length > 0 ? this.isPayCheck = true : this.isPayCheck = false;
                 }
            }
        })
        .catch(error => {
            
        })
    }

    async handleServerCall(){
        try{
            await this.getAllVilationTypeVariablesForStateDifferentHour('4');
        }catch (error){
            console.log('error', error);
        }
    }

    
    @api violationTypeVariablesForVacationTime
    @api isVacationTime = false;
    getAllVilationTypeVariablesForStateDifferentHour(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    if(result[i].dataType === 'Date'){
                        result[i].dateFormat = true;
                    }
                    else if(result[i].dataType === 'Currency'){
                        result[i].currencyFormat = true;
                    }
                    else if(result[i].dataType === 'Decimal' || result[i].dataType === 'Integer'){
                        result[i].numberFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].name === 'VTV0093' ? result[i].helpText = true : result[i].helpText = false
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForVacationTime !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForVacationTime = result;
                    this.violationTypeVariablesForVacationTime.length > 0 ? this.isVacationTime = true : this.isVacationTime = false;
                 }
                 (this.dischargeddate !== undefined || this.dischargeddate !== null) ? this.violationTypeVariablesForVacationTime.forEach( element => element.name === 'VTV0091' ? element.value = this.dischargeddate : '') : ''
                 (this.quitdatevalue !== undefined || this.quitdatevalue !== null) ? this.violationTypeVariablesForVacationTime.forEach( element => element.name === 'VTV0091' ? element.value = this.quitdatevalue : '') : ''
            }
        })
        .catch(error => {
            
        })
    }

    async getAllDataForShareTips(){
        try{
            await this.getAllVilationTypeVariablesForShareTips('10');
        }catch (error){
            console.log('error', error);
        }
    }

    @api violationTypeVariablesForShareTips;
    @api isShareTips = false;
    getAllVilationTypeVariablesForShareTips(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                for(var i=0; i<result.length; i++){
                    if(result[i].dataType === 'Date'){
                        result[i].dateFormat = true;
                    }
                    else if(result[i].dataType === 'Currency'){
                        result[i].currencyFormat = true;
                    }
                    else if(result[i].dataType === 'Decimal' || result[i].dataType === 'Integer'){
                        result[i].numberFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForShareTips !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForShareTips = result;
                    this.violationTypeVariablesForShareTips.length > 0 ? this.isShareTips = true : this.isShareTips = false;
                 }
            }
        })
        .catch(error => {
            
        })
    }

    @api payrollDemandDate;
    @api employerResponse;
    @api personalFileDemandDate;
    @api personalEmployerResponse;

    @api unreimbursedDoc;
    @api isUnreimbursedUpload = false;
    @api unreimbursedDocSize;
    handleunreimbursedDoc(event){
        const uploadedFiles = event.detail.files;
        this.unreimbursedDoc = uploadedFiles;
        if(uploadedFiles != null){
            this.isUnreimbursedUpload = false
            this.unreimbursedDocSize = this.unreimbursedDoc.length
            this.template.querySelector('[data-id="unreimbursedDocId"]').getDocData(this.unreimbursedDoc);
            this.isRenderedCallback = false
            this.showToast('Success!',this.toastFileUploadMsg,'success');
        }
        else{
            this.isUnreimbursedUpload = true
        }
    }

    handleUnreimbursedDocEvent(event){
        this.unreimbursedDoc = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.unreimbursedDocSize = this.unreimbursedDoc.length
    }

    @api explainBonus;
    @api isExplain = false;

    isDateAcceptable = false;
    isclaimPeriodStartDate = false;
    isclaimPeriodEndDate = false;

    // Toast msg
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    handleWorkNotPaidValidityEvent(event){
        this.isNotChangedCurrentStep = val.currentStep
    }

    handleWageDefValidityEvent(){
        const selectEvent = new CustomEvent('wagedeficiencieschildvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isNotChangedCurrentStep = false;
        this.dispatchEvent(selectEvent);
    }

    handleOverTimeParentValidityCheck(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    handleSickLeaveParentValidityCheck(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    handleRestBreakParentValidityCheck(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    handleMealBreakParentValidityCheck(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    handleRestClaimParentValidityCheck(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    handleMileageClaimParentValidityCheck(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    handleFundClaimParentValidityCheck(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    handlePayClaimParentValidityCheck(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    handleEmployerWorkedValidity(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    handleWaitingValidityEvent(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    @api overTimeCaseIssueObj
    @api overTimeDetails
    @api renderOverTimeSection
    handleOverTimeParentInfo(event){
        const overTimeDetails = event.detail.overTimeDetails;
        const renderOverTimeSection = event.detail.renderOverTimeSection;
        const vtCaseIssueObj = event.detail.vtCaseIssueObj;
        this.overTimeCaseIssueObj = vtCaseIssueObj;
        this.overTimeDetails = overTimeDetails;
        this.renderOverTimeSection = renderOverTimeSection;
    }
    
    @api sickLeaveDetails
    @api renderSickLeaveSection
    @api sickLeaveCaseIssueData
    handleSickLeaveParentInfo(event){
        const sickLeaveDetails = event.detail.sickLeaveDetails;
        const renderSickLeaveSection = event.detail.renderSickLeaveSection;
        const sickLeaveCaseIssueData = event.detail.vtCaseIssueObj;
        this.sickLeaveCaseIssueData = sickLeaveCaseIssueData;
        this.sickLeaveDetails = sickLeaveDetails;
        this.renderSickLeaveSection = renderSickLeaveSection;
    }

    @api restBreakDetails
    @api renderRestBreakSection
    @api restBreakCaseIssueData;
    handleReatBreakParentInfo(event){
        const restBreakDetails = event.detail.restBreakDetails;
        const renderRestBreakSection = event.detail.renderRestBreakSection;
        const restBreakCaseIssueData = event.detail.vtCaseIssueObj;
        this.restBreakCaseIssueData = restBreakCaseIssueData;
        this.restBreakDetails = restBreakDetails;
        this.renderRestBreakSection = renderRestBreakSection;
    }
    
    @api mealBreakDetails
    @api renderMealBreakSection
    @api mealBreakCaseIssueData;
    handleMealBreakParentInfo(event){
        const mealBreakDetails = event.detail.mealBreakDetails;
        const renderMealBreakSection = event.detail.renderMealBreakSection;
        const mealBreakCaseIssueData = event.detail.vtCaseIssueObj
        this.mealBreakCaseIssueData = mealBreakCaseIssueData;
        this.mealBreakDetails = mealBreakDetails;
        this.renderMealBreakSection = renderMealBreakSection;
    }
    
    @api restClaimDetails
    @api renderRestClaimSection
    @api restClaimCaseIssueData
    handleRestClaimParentInfo(event){
        const restClaimDetails = event.detail.restClaimDetails;
        const renderRestClaimSection = event.detail.renderRestClaimSection;
        const restClaimCaseIssueData = event.detail.vtCaseIssueObj;
        this.restClaimCaseIssueData = restClaimCaseIssueData;
        this.restClaimDetails = restClaimDetails;
        this.renderRestClaimSection = renderRestClaimSection;
    }
    
    @api mileageClaimDetails;
    @api renderMilegaClaimSection;
    @api mileageClaimCaseIssueData;
    handleMileageClaimParentInfo(event){
        const mileageClaimDetails = event.detail.mileageClaimDetails;
        const renderMilegaClaimSection = event.detail.renderMilegaClaimSection;
        const mileageClaimCaseIssueData = event.detail.vtCaseIssueObj;
        this.mileageClaimCaseIssueData = mileageClaimCaseIssueData;
        this.mileageClaimDetails = mileageClaimDetails;
        this.renderMilegaClaimSection = renderMilegaClaimSection;
    }
    
    @api fundClaimDetails;
    @api renderFundClaimSection;
    @api fundClaimCaseIssueData;
    handleFundClaimParentInfo(event){
        const fundClaimDetails = event.detail.fundClaimDetails;
        const renderFundClaimSection = event.detail.renderFundClaimSection;
        const fundClaimCaseIssueData = event.detail.vtCaseIssueObj;
        this.fundClaimCaseIssueData = fundClaimCaseIssueData;
        this.fundClaimDetails = fundClaimDetails;
        this.renderFundClaimSection = renderFundClaimSection;
    }
    
    @api payClaimDetails;
    @api renderPayClaimSection;
    @api payClaimCaseIssueData;
    handlePayClaimParentInfo(event){
        const payClaimDetails = event.detail.payClaimDetails;
        const renderPayClaimSection = event.detail.renderPayClaimSection;
        const payClaimCaseIssueData = event.detail.vtCaseIssueObj;
        this.payClaimCaseIssueData = payClaimCaseIssueData;
        this.payClaimDetails = payClaimDetails;
        this.renderPayClaimSection = renderPayClaimSection;
    }
    
    @api garmentEmpDetails
    handleGaremtEmpParentInfo(event){
        //const garmentEmpDetails = event.detail.garmentEmpDetails;
        this.garmentEmpDetails = event.detail;
    }

    @api employerWorkedDetails
    @api employerWorkedCaseIssueObj
    handleEmployerInfoEvent(event){
        const employerWorkedDetails = event.detail.employerWorkedObj;
        this.employerWorkedDetails = employerWorkedDetails;
        const employerWorkedCaseIssueObj = event.detail.vtCaseIssueObj
        this.employerWorkedCaseIssueObj = employerWorkedCaseIssueObj;
    }

    @api waitingTimeDetails
    @api waitingTimeCaseIssueObj
    handleWaitingInfoCustomEvent(event){
        const waitingTimeDetails = event.detail.waitingInfoObj;
        this.waitingTimeDetails = waitingTimeDetails;
        const waitingTimeCaseIssueObj = event.detail.vtCaseIssueObj
        this.waitingTimeCaseIssueObj = waitingTimeCaseIssueObj; 
    }

    @api
    handleWageDeficienciesParentData(){

        if(this.isnotidentifyemployer === 'No'){
            this.template.querySelector('c-owc-Waiting-Time-Claim').handleWaitingTimeParent();
        }

        if(this.notPaidForWork === true && this.isFirstOptionTrue === true){
            const temp = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate');
            for(var i=0; i<temp.length; i++){
                temp[i].handleWageDeficienciesParent();
            }
        }

        if(this.paidbycheck === true){
            const temp = this.template.querySelectorAll('c-owc-Insufficient-Fund-Claim-Container');
            for(var i=0; i<temp.length; i++){
                temp[i].handleSickLeaveTimeParent();
            }
        }

        if(this.noOvertimePaid === true && this.isSecondOptionTrue === true){
            this.template.querySelector('c-owc-Over-Time-Or-Double-Time-Container-Def').handleOverTimeOrDoubleTimeParent();
        }

        if(this.noSickLeavePaid === true && this.isThirdOptionTrue === true){
            this.template.querySelector('c-owc-Not-Paid-Sick-Leave-Container').handleSickLeaveTimeParent();
        }

        if(this.notAllowedBathBreak === true && this.isSixthOptionTrue === true){
            this.template.querySelector('c-owc-Not-Allowed-Rest-Break-Container').handleSickLeaveTimeParent();
        }

        if(this.notAllowedMealBreak === true && this.isSeventhOptionTrue === true){
            this.template.querySelector('c-owc-Not-Allowed-For-Meal-Break-Container').handleSickLeaveTimeParent();
        }

        if((this.notAllowedForHeatRest === true && this.isEightOptionTrue === true) || this.isHeatRestDef === true){
            this.template.querySelector('c-owc-Not-Allowed-Heat-Rest-Container').handleSickLeaveTimeParent();
        }

        if(this.deniedPaymentMilega === true && this.isTwelveOptionTrue === true){
            this.template.querySelector('c-owc-Denied-Milega-Pay-Container').handleSickLeaveTimeParent();
        }


        if(this.reportedToWork === true && this.isEighteenOptionTrue === true){
            this.template.querySelector('c-owc-Reporting-Time-Pay-Claim-Container').handleSickLeaveTimeParent();
        }
        if(this.garmentWageClaim === true && this.isNinteenOptionTrue === true){
            this.template.querySelector('c-O-W-C-Garment-Employee-Option-Cmp').owcGaremntEmpDataForParent();
        }

        if(this.employerDeniedWork === true && this.isSixteenOptionTrue === true){
            this.template.querySelector('c-owc-Employer-Worked-Defined').handleEmployerWorkedParent();
        }

        this.isNotChangedCurrentStep === true ? this.handleWageDefValidityEvent() : this.wageDeficienciesParentObj();

    }

    @api workNotPaidvtCaseIssue
    @api workNotPaidvtCaseIssueList
    dataList = []
    workNotPaidvtList = []
    @api workNotPaidData;
    handleWageDeficienciesInforEvent(event){
        const result = event.detail;
        const workNotPaidDetails = result.InfoObj;
        const violationTypeCaseIssue = result.caseIssue;
        this.workNotPaidvtCaseIssue = violationTypeCaseIssue
        this.workedNotPaidSectionValues = workNotPaidDetails
        this.dataList.push(this.workedNotPaidSectionValues)
        this.workNotPaidvtList.push(this.workNotPaidvtCaseIssue);
        this.workNotPaidvtCaseIssue.length = 0
        this.workNotPaidvtCaseIssueList = this.workNotPaidvtList;
        this.workNotPaidData = this.dataList;
    }

    @api
    wageDeficienciesParentObj(){
        this.prepareVtCaseIssueJSON()
        const details = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate')
        for (let i = 0; i < details.length; i++){
            details[i].handleWageDeficienciesParentInfoData();
        }
        const selectEvent = new CustomEvent('wagedeficienciescustomobjevent', {
            detail:{
                wageDefInfoObj: this.wageDefInfoObj(),
                vtCaseIssues : this.vtCaseIssueList
            }
        });
        this.dispatchEvent(selectEvent);
    }

    @api
    handleWageDefSectionData(){
        this.prepareVtCaseIssueJSON()
        const selectEvent = new CustomEvent('wagedefsectiondeleteevent', {
            detail:{
                wageDefInfoObj: this.wageDefInfoObj(),
                vtCaseIssues : this.vtCaseIssueList
            }
        });
        this.dispatchEvent(selectEvent);
    }

    @api vtCaseIssueList = [];
    @api vtCaseIssues = [];

    prepareVtCaseIssueJSON(){

        if(this.workNotPaidvtList !== undefined && this.workNotPaidvtList.length > 0){
            for(var i=0; i<this.workNotPaidvtList.length; i++){
                var childCaseIssueList = []
                var vtId;
                if(this.workNotPaidvtList[i].violationTypeVariablesForOneHourlyRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForOneHourlyRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForOneHourlyRate.length; j++){
                            vtId = this.workNotPaidvtList[i].violationTypeVariablesForOneHourlyRate[j].violationTypeId;
                            childCaseIssueList.push(this.workNotPaidvtList[i].violationTypeVariablesForOneHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : vtId , "violationVariables": childCaseIssueList})
                    }
                }

                var workPaidSalaryList = []
                var salaryVtId;
                if(this.workNotPaidvtList[i].violationTypeVariablesForOneSalaryRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForOneSalaryRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForOneSalaryRate.length; j++){
                            salaryVtId = this.workNotPaidvtList[i].violationTypeVariablesForOneSalaryRate[j].violationTypeId;
                            workPaidSalaryList.push(this.workNotPaidvtList[i].violationTypeVariablesForOneSalaryRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : salaryVtId , "violationVariables": workPaidSalaryList})
                    }
                } 

                var workedPaidDifferentList = [];
                var differentId;
                if(this.workNotPaidvtList[i].violationTypeVariablesForDifferentHourlyRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForDifferentHourlyRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForDifferentHourlyRate.length; j++){
                            differentId = this.workNotPaidvtList[i].violationTypeVariablesForDifferentHourlyRate[j].violationTypeId;
                            workedPaidDifferentList.push(this.workNotPaidvtList[i].violationTypeVariablesForDifferentHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : differentId , "violationVariables": workedPaidDifferentList})
                    }
                } 

                var workPaidDifferentPieceRateList = []
                var pieceRateId = []
                if(this.workNotPaidvtList[i].violationTypeVariablesForDifferentPieceRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForDifferentPieceRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForDifferentPieceRate.length; j++){
                            pieceRateId = this.workNotPaidvtList[i].violationTypeVariablesForDifferentPieceRate[j].violationTypeId;
                            workPaidDifferentPieceRateList.push(this.workNotPaidvtList[i].violationTypeVariablesForDifferentPieceRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : pieceRateId , "violationVariables": workPaidDifferentPieceRateList})
                    }
                }

                var onePieceRateList = []
                var onePieceRateId
                if(this.workNotPaidvtList[i].violationTypeVariablesForOnePieceRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForOnePieceRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForOnePieceRate.length; j++){
                            onePieceRateId = this.workNotPaidvtList[i].violationTypeVariablesForOnePieceRate[j].violationTypeId;
                            onePieceRateList.push(this.workNotPaidvtList[i].violationTypeVariablesForOnePieceRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : onePieceRateId , "violationVariables": onePieceRateList})
                    }
                }

                var unknownPieceRateList = []
                var unknownPieceRateId
                if(this.workNotPaidvtList[i].violationTypeVariablesForUnknownPieceRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForUnknownPieceRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForUnknownPieceRate.length; j++){
                            unknownPieceRateId = this.workNotPaidvtList[i].violationTypeVariablesForUnknownPieceRate[j].violationTypeId;
                            unknownPieceRateList.push(this.workNotPaidvtList[i].violationTypeVariablesForUnknownPieceRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : unknownPieceRateId , "violationVariables": unknownPieceRateList})
                    }
                }

                var knownPieceRateList = []
                var knownPieceRateId
                if(this.workNotPaidvtList[i].violationTypeVariablesForknownPieceRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForknownPieceRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForknownPieceRate.length; j++){
                            knownPieceRateId = this.workNotPaidvtList[i].violationTypeVariablesForknownPieceRate[j].violationTypeId;
                            knownPieceRateList.push(this.workNotPaidvtList[i].violationTypeVariablesForknownPieceRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : knownPieceRateId , "violationVariables": knownPieceRateList})
                    }
                }


                var commissionRateList = []
                var commissionRateId
                if(this.workNotPaidvtList[i].violationTypeVariablesForCommissionRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForCommissionRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForCommissionRate.length; j++){
                            commissionRateId = this.workNotPaidvtList[i].violationTypeVariablesForCommissionRate[j].violationTypeId;
                            commissionRateList.push(this.workNotPaidvtList[i].violationTypeVariablesForCommissionRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : commissionRateId , "violationVariables": commissionRateList})
                    }
                }

                var commsiionRateUploadList = []
                var commissionRateUploadId
                if(this.workNotPaidvtList[i].violationTypeVariablesForCommissionRateUpload !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForCommissionRateUpload.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForCommissionRateUpload.length; j++){
                            commissionRateUploadId = this.workNotPaidvtList[i].violationTypeVariablesForCommissionRateUpload[j].violationTypeId;
                            commsiionRateUploadList.push(this.workNotPaidvtList[i].violationTypeVariablesForCommissionRateUpload[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : commissionRateUploadId , "violationVariables": commsiionRateUploadList})
                    }
                }

                var localWageHourChildList = []
                var localWageHourId
                if(this.workNotPaidvtList[i].violationTypeVariablesForLocalWageDifferentHourlyRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForLocalWageDifferentHourlyRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForLocalWageDifferentHourlyRate.length; j++){
                            localWageHourId = this.workNotPaidvtList[i].violationTypeVariablesForLocalWageDifferentHourlyRate[j].violationTypeId;
                            localWageHourChildList.push(this.workNotPaidvtList[i].violationTypeVariablesForLocalWageDifferentHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : localWageHourId , "violationVariables": localWageHourChildList})
                    }
                }

                var localWageOneHourRateList = []
                var localWageOneHourRateId
                if(this.workNotPaidvtList[i].violationTypeVariablesForLocalWageOneHourlyRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForLocalWageOneHourlyRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForLocalWageOneHourlyRate.length; j++){
                            localWageOneHourRateId = this.workNotPaidvtList[i].violationTypeVariablesForLocalWageOneHourlyRate[j].violationTypeId;
                            localWageOneHourRateList.push(this.workNotPaidvtList[i].violationTypeVariablesForLocalWageOneHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : localWageOneHourRateId , "violationVariables": localWageOneHourRateList})
                    }
                }

                var localWageOneSalaryRateList = []
                var localWageOneSalaryRateId
                if(this.workNotPaidvtList[i].violationTypeVariablesForLocalWageOneSalaryRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForLocalWageOneSalaryRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForLocalWageOneSalaryRate.length; j++){
                            localWageOneSalaryRateId = this.workNotPaidvtList[i].violationTypeVariablesForLocalWageOneSalaryRate[j].violationTypeId;
                            localWageOneSalaryRateList.push(this.workNotPaidvtList[i].violationTypeVariablesForLocalWageOneSalaryRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : localWageOneSalaryRateId , "violationVariables": localWageOneSalaryRateList})
                    }
                }

                var stateWageOneHourlyRateList = []
                var stateWageOneHourlyRateId
                if(this.workNotPaidvtList[i].violationTypeVariablesForStateWageOneHourlyRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForStateWageOneHourlyRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForStateWageOneHourlyRate.length; j++){
                            stateWageOneHourlyRateId = this.workNotPaidvtList[i].violationTypeVariablesForStateWageOneHourlyRate[j].violationTypeId;
                            stateWageOneHourlyRateList.push(this.workNotPaidvtList[i].violationTypeVariablesForStateWageOneHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : stateWageOneHourlyRateId , "violationVariables": stateWageOneHourlyRateList})
                    }
                }

                

                var stateWageOneSalaryRateList = []
                var stateWageOneSalaryRateListId
                if(this.workNotPaidvtList[i].violationTypeVariablesForStateWageOneSalaryRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForStateWageOneSalaryRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForStateWageOneSalaryRate.length; j++){
                            stateWageOneSalaryRateListId = this.workNotPaidvtList[i].violationTypeVariablesForStateWageOneSalaryRate[j].violationTypeId;
                            stateWageOneSalaryRateList.push(this.workNotPaidvtList[i].violationTypeVariablesForStateWageOneSalaryRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : stateWageOneSalaryRateListId , "violationVariables": stateWageOneSalaryRateList})
                    }
                }

                var stateWageDifferentHourlyRateList = []
                var stateWageDifferentHourlyRateId
                if(this.workNotPaidvtList[i].violationTypeVariablesForStateWageDifferentHourlyRate !== undefined){
                    if(this.workNotPaidvtList[i].violationTypeVariablesForStateWageDifferentHourlyRate.length > 0){
                        for(var j=0; j<this.workNotPaidvtList[i].violationTypeVariablesForStateWageDifferentHourlyRate.length; j++){
                            stateWageDifferentHourlyRateId = this.workNotPaidvtList[i].violationTypeVariablesForStateWageDifferentHourlyRate[j].violationTypeId;
                            stateWageDifferentHourlyRateList.push(this.workNotPaidvtList[i].violationTypeVariablesForStateWageDifferentHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : stateWageDifferentHourlyRateId , "violationVariables": stateWageDifferentHourlyRateList})
                    }
                }

                

            }
        }

        if(this.fundClaimCaseIssueData !== undefined && this.fundClaimCaseIssueData.length > 0){
            for(var i=0; i<this.fundClaimCaseIssueData.length; i++){
                for(var i=0; i<this.fundClaimCaseIssueData.length; i++){
                    var insufficientFund = []
                    var insufficientFundId
                    if(this.fundClaimCaseIssueData[i].violationTypeVariablesForInsufficientFunds !== undefined){
                        if(this.fundClaimCaseIssueData[i].violationTypeVariablesForInsufficientFunds.length > 0){
                            for(var j=0; j<this.fundClaimCaseIssueData[i].violationTypeVariablesForInsufficientFunds.length; j++){
                                insufficientFundId = this.fundClaimCaseIssueData[i].violationTypeVariablesForInsufficientFunds[j].violationTypeId;
                                insufficientFund.push(this.fundClaimCaseIssueData[i].violationTypeVariablesForInsufficientFunds[j]);
                            }
                            this.vtCaseIssueList.push({ "violationTypeId" : insufficientFundId , "violationVariables": insufficientFund})
                        }
                    }

                    var insufficientFund11 = []
                    var insufficientFund11Id
                    if(this.fundClaimCaseIssueData[i].violationTypeVariableForNS11 !== undefined){
                        if(this.fundClaimCaseIssueData[i].violationTypeVariableForNS11.length > 0){
                            for(var j=0; j<this.fundClaimCaseIssueData[i].violationTypeVariableForNS11.length; j++){
                                insufficientFund11Id = this.fundClaimCaseIssueData[i].violationTypeVariableForNS11[j].violationTypeId;
                                insufficientFund11.push(this.fundClaimCaseIssueData[i].violationTypeVariableForNS11[j]);
                            }
                            this.vtCaseIssueList.push({ "violationTypeId" : insufficientFund11Id , "violationVariables": insufficientFund11})
                        }
                    }

                    var NS12 = []
                    var NS12Id
                    if(this.fundClaimCaseIssueData[i].violationTypeVariableForNS12 !== undefined){
                        if(this.fundClaimCaseIssueData[i].violationTypeVariableForNS12.length > 0){
                            for(var j=0; j<this.fundClaimCaseIssueData[i].violationTypeVariableForNS12.length; j++){
                                NS12Id = this.fundClaimCaseIssueData[i].violationTypeVariableForNS12[j].violationTypeId;
                                NS12.push(this.fundClaimCaseIssueData[i].violationTypeVariableForNS12[j]);
                            }
                            this.vtCaseIssueList.push({ "violationTypeId" : NS12Id , "violationVariables": NS12})
                        }
                    }

                }
            }
        }
        if(this.overTimeCaseIssueObj !== undefined && this.overTimeCaseIssueObj.length > 0){

            for(var i=0; i<this.overTimeCaseIssueObj.length; i++){
                var oneHourlyList = []
                var oneHourlyId
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourly !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourly.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourly.length; j++){
                            oneHourlyId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourly[j].violationTypeId;
                            oneHourlyList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourly[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : oneHourlyId , "violationVariables": oneHourlyList})
                    }
                } 

                var salaryRateList = []
                var salaryRateId
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRate !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRate.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRate.length; j++){
                            salaryRateId = this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRate[j].violationTypeId;
                            salaryRateList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : salaryRateId , "violationVariables": salaryRateList})
                    }
                }

                var oneHourlyRecList = []
                var oneHourlyRecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourlyRec !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourlyRec.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourlyRec.length; j++){
                            oneHourlyRecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourlyRec[j].violationTypeId;
                            oneHourlyRecList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourlyRec[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : oneHourlyRecId , "violationVariables": oneHourlyRecList})
                    }
                } 

                var salaryRateRecList = []
                var salaryRateRecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRateRec !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRateRec.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRateRec.length; j++){
                            salaryRateRecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRateRec[j].violationTypeId;
                            salaryRateRecList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRateRec[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : salaryRateRecId , "violationVariables": salaryRateRecList})
                    }
                }

                var additionalClaimList = []
                var additonalClaimId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForAdditional !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForAdditional.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForAdditional.length; j++){
                            additonalClaimId = this.overTimeCaseIssueObj[i].violationTypeVariablesForAdditional[j].violationTypeId;
                            additionalClaimList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForAdditional[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : additonalClaimId , "violationVariables": additionalClaimList})
                    }
                }

                var OneHourlyRecsList = []
                var OneHourlyRecsId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourlyRecs !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourlyRecs.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourlyRecs.length; j++){
                            OneHourlyRecsId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourlyRecs[j].violationTypeId;
                            OneHourlyRecsList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourlyRecs[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : OneHourlyRecsId , "violationVariables": OneHourlyRecsList})
                    }
                } 

                var salaryRateRecsList = []
                var salaryRateRecsId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRateRecs !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRateRecs.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRateRecs.length; j++){
                            salaryRateRecsId = this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRateRecs[j].violationTypeId;
                            salaryRateRecsList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForSalaryRateRecs[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : salaryRateRecsId , "violationVariables": salaryRateRecsList})
                    }
                }
            }
        }
        if(this.sickLeaveCaseIssueData !== undefined && this.sickLeaveCaseIssueData.length > 0){
            for(var i=0; i<this.sickLeaveCaseIssueData.length; i++){

                var oneHourlyRateList = []
                var oneHourlyRateId;
                if(this.sickLeaveCaseIssueData[i].violationTypeVariablesForOneHourly !== undefined){
                    if(this.sickLeaveCaseIssueData[i].violationTypeVariablesForOneHourly.length > 0){
                        for(var j=0; j<this.sickLeaveCaseIssueData[i].violationTypeVariablesForOneHourly.length; j++){
                            oneHourlyRateId = this.sickLeaveCaseIssueData[i].violationTypeVariablesForOneHourly[j].violationTypeId;
                            oneHourlyRateList.push(this.sickLeaveCaseIssueData[i].violationTypeVariablesForOneHourly[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : oneHourlyRateId , "violationVariables": oneHourlyRateList})
                    }
                } 

                var sl20List = []
                var sl20Id;
                if(this.sickLeaveCaseIssueData[i].violationTypeVariableForSL20 !== undefined){
                    if(this.sickLeaveCaseIssueData[i].violationTypeVariableForSL20.length > 0){
                        for(var j=0; j<this.sickLeaveCaseIssueData[i].violationTypeVariableForSL20.length; j++){
                            sl20Id = this.sickLeaveCaseIssueData[i].violationTypeVariableForSL20[j].violationTypeId;
                            sl20List.push(this.sickLeaveCaseIssueData[i].violationTypeVariableForSL20[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : sl20Id , "violationVariables": sl20List})
                    }
                } 

                var differentHourlyRateList = []
                var differentHourlyId;
                if(this.sickLeaveCaseIssueData[i].violationTypeVariablesForDifferentHourly !== undefined){
                    if(this.sickLeaveCaseIssueData[i].violationTypeVariablesForDifferentHourly.length > 0){
                        for(var j=0; j<this.sickLeaveCaseIssueData[i].violationTypeVariablesForDifferentHourly.length; j++){
                            differentHourlyId = this.sickLeaveCaseIssueData[i].violationTypeVariablesForDifferentHourly[j].violationTypeId;
                            differentHourlyRateList.push(this.sickLeaveCaseIssueData[i].violationTypeVariablesForDifferentHourly[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : differentHourlyId , "violationVariables": differentHourlyRateList})
                    }
                }

                var oneHourlyAllowList = []
                var oneHourlyAllowId;
                if(this.sickLeaveCaseIssueData[i].violationTypeVariablesForOneHourlyAllow !== undefined){
                    if(this.sickLeaveCaseIssueData[i].violationTypeVariablesForOneHourlyAllow.length > 0){
                        for(var j=0; j<this.sickLeaveCaseIssueData[i].violationTypeVariablesForOneHourlyAllow.length; j++){
                            oneHourlyAllowId = this.sickLeaveCaseIssueData[i].violationTypeVariablesForOneHourlyAllow[j].violationTypeId;
                            oneHourlyAllowList.push(this.sickLeaveCaseIssueData[i].violationTypeVariablesForOneHourlyAllow[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : oneHourlyAllowId , "violationVariables": oneHourlyAllowList})
                    }
                } 

                var differentHourlyAllowList = []
                var differentHourlyAllowId;
                if(this.sickLeaveCaseIssueData[i].violationTypeVariablesForDifferentHourlyAllow !== undefined){
                    if(this.sickLeaveCaseIssueData[i].violationTypeVariablesForDifferentHourlyAllow.length > 0){
                        for(var j=0; j<this.sickLeaveCaseIssueData[i].violationTypeVariablesForDifferentHourlyAllow.length; j++){
                            differentHourlyAllowId = this.sickLeaveCaseIssueData[i].violationTypeVariablesForDifferentHourlyAllow[j].violationTypeId;
                            differentHourlyAllowList.push(this.sickLeaveCaseIssueData[i].violationTypeVariablesForDifferentHourlyAllow[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : differentHourlyAllowId , "violationVariables": differentHourlyAllowList})
                    }
                }
            }
        }
        if(this.restBreakCaseIssueData !== undefined && this.restBreakCaseIssueData.length > 0){
            for(var i=0; i<this.restBreakCaseIssueData.length; i++){
                var oneHourlyBreakRateList = []
                var oneHourlyBreakRateId;
                if(this.restBreakCaseIssueData[i].violationTypeVariablesForOneHourlyRate !== undefined){
                    if(this.restBreakCaseIssueData[i].violationTypeVariablesForOneHourlyRate.length > 0){
                        for(var j=0; j<this.restBreakCaseIssueData[i].violationTypeVariablesForOneHourlyRate.length; j++){
                            oneHourlyBreakRateId = this.restBreakCaseIssueData[i].violationTypeVariablesForOneHourlyRate[j].violationTypeId;
                            oneHourlyBreakRateList.push(this.restBreakCaseIssueData[i].violationTypeVariablesForOneHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : oneHourlyBreakRateId , "violationVariables": oneHourlyBreakRateList})
                    }
                } 

                var breakSalaryRateList = []
                var breakSalaryRateId
                if(this.restBreakCaseIssueData[i].violationTypeVariablesForOneSalaryRate !== undefined){
                    if(this.restBreakCaseIssueData[i].violationTypeVariablesForOneSalaryRate.length > 0){
                        for(var j=0; j<this.restBreakCaseIssueData[i].violationTypeVariablesForOneSalaryRate.length; j++){
                            breakSalaryRateId = this.restBreakCaseIssueData[i].violationTypeVariablesForOneSalaryRate[j].violationTypeId;
                            breakSalaryRateList.push(this.restBreakCaseIssueData[i].violationTypeVariablesForOneSalaryRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : breakSalaryRateId , "violationVariables": breakSalaryRateList})
                    }
                }
            }
        }
        if(this.mealBreakCaseIssueData !== undefined && this.mealBreakCaseIssueData.length > 0){
            for(var i=0; i<this.mealBreakCaseIssueData.length; i++){

                var mealOneHourlyRateList = []
                var mealOneHourlyRateId;
                if(this.mealBreakCaseIssueData[i].violationTypeVariablesForOneHourlyRate !== undefined){
                    if(this.mealBreakCaseIssueData[i].violationTypeVariablesForOneHourlyRate.length > 0){
                        for(var j=0; j<this.mealBreakCaseIssueData[i].violationTypeVariablesForOneHourlyRate.length; j++){
                            mealOneHourlyRateId = this.mealBreakCaseIssueData[i].violationTypeVariablesForOneHourlyRate[j].violationTypeId;
                            mealOneHourlyRateList.push(this.mealBreakCaseIssueData[i].violationTypeVariablesForOneHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : mealOneHourlyRateId , "violationVariables": mealOneHourlyRateList})
                    }
                } 

                var mealOneSalaryRateList = []
                var mealOneSalaryRateId;
                if(this.mealBreakCaseIssueData[i].violationTypeVariablesForOneSalaryRate !== undefined){
                    if(this.mealBreakCaseIssueData[i].violationTypeVariablesForOneSalaryRate.length > 0){
                        for(var j=0; j<this.mealBreakCaseIssueData[i].violationTypeVariablesForOneSalaryRate.length; j++){
                            mealOneSalaryRateId = this.mealBreakCaseIssueData[i].violationTypeVariablesForOneSalaryRate[j].violationTypeId;
                            mealOneSalaryRateList.push(this.mealBreakCaseIssueData[i].violationTypeVariablesForOneSalaryRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : mealOneSalaryRateId , "violationVariables": mealOneSalaryRateList})
                    }
                }
            }
        }
        if(this.restClaimCaseIssueData !== undefined && this.restClaimCaseIssueData.length > 0){
            for(var i=0; i<this.restClaimCaseIssueData.length; i++){

                var restClaimOneHourlyRateList = []
                var restClaimOneHourlyRateId
                if(this.restClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate !== undefined){
                    if(this.restClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate.length > 0){
                        for(var j=0; j<this.restClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate.length; j++){
                            restClaimOneHourlyRateId = this.restClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate[j].violationTypeId;
                            restClaimOneHourlyRateList.push(this.restClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : restClaimOneHourlyRateId , "violationVariables": restClaimOneHourlyRateList})
                    }
                } 

                var restClaimSalaryRateList = []
                var restClaimSalaryRateId
                if(this.restClaimCaseIssueData[i].violationTypeVariablesForOneSalaryRate !== undefined){
                    if(this.restClaimCaseIssueData[i].violationTypeVariablesForOneSalaryRate.length > 0){
                        for(var j=0; j<this.restClaimCaseIssueData[i].violationTypeVariablesForOneSalaryRate.length; j++){
                            restClaimSalaryRateId = this.restClaimCaseIssueData[i].violationTypeVariablesForOneSalaryRate[j].violationTypeId;
                            restClaimSalaryRateList.push(this.restClaimCaseIssueData[i].violationTypeVariablesForOneSalaryRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : restClaimSalaryRateId , "violationVariables": restClaimSalaryRateList})
                    }
                }
            }
        }
        if(this.mileageClaimCaseIssueData !== undefined && this.mileageClaimCaseIssueData.length > 0){
            for(var i=0; i<this.mileageClaimCaseIssueData.length; i++){
                var mileageOneHourlyRateList = []
                var mileageOneHourlyRateId
                if(this.mileageClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate !== undefined){
                    if(this.mileageClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate.length > 0){
                        for(var j=0; j<this.mileageClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate.length; j++){
                            mileageOneHourlyRateId = this.mileageClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate[j].violationTypeId;
                            mileageOneHourlyRateList.push(this.mileageClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : mileageOneHourlyRateId , "violationVariables": mileageOneHourlyRateList})
                    }
                } 
            }
        }

        
        if(this.payClaimCaseIssueData !== undefined && this.payClaimCaseIssueData.length > 0){
            for(var i=0; i<this.payClaimCaseIssueData.length; i++){
                var oneHourlyRepList = []
                var oneHourlyRepId
                if(this.payClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate !== undefined){
                    if(this.payClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate.length > 0){
                        for(var j=0; j<this.payClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate.length; j++){
                            oneHourlyRepId = this.payClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate[j].violationTypeId;
                            oneHourlyRepList.push(this.payClaimCaseIssueData[i].violationTypeVariablesForOneHourlyRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : oneHourlyRepId , "violationVariables": oneHourlyRepList})
                    }
                }
                
                var salaryRateRepList = []
                var salaryRateRepId
                if(this.payClaimCaseIssueData[i].violationTypeVariablesForOneSalaryRate !== undefined){
                    if(this.payClaimCaseIssueData[i].violationTypeVariablesForOneSalaryRate.length > 0){
                        for(var j=0; j<this.payClaimCaseIssueData[i].violationTypeVariablesForOneSalaryRate.length; j++){
                            salaryRateRepId = this.payClaimCaseIssueData[i].violationTypeVariablesForOneSalaryRate[j].violationTypeId;
                            salaryRateRepList.push(this.payClaimCaseIssueData[i].violationTypeVariablesForOneSalaryRate[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : salaryRateRepId , "violationVariables": salaryRateRepList})
                    }
                } 
            }
        }

        var shareTipsList = []
        var shareTipsId
        if(this.violationTypeVariablesForShareTips !== undefined && this.violationTypeVariablesForShareTips.length > 0){
            for(var i=0; i<this.violationTypeVariablesForShareTips.length; i++){
                shareTipsId = this.violationTypeVariablesForShareTips[i].violationTypeId;
                shareTipsList.push(this.violationTypeVariablesForShareTips[i]);
            }
            this.vtCaseIssueList.push({ "violationTypeId" : shareTipsId , "violationVariables": shareTipsList})
        }

        if(this.waitingTimeCaseIssueObj !== undefined && this.waitingTimeCaseIssueObj !== null){
            var waitingOneList = []
            var waitingOneId
            if(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeOne !== undefined){
                if(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeOne.length > 0){
                    for(var j=0; j<this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeOne.length; j++){
                        waitingOneId = this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeOne[j].violationTypeId;
                        waitingOneList.push(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeOne[j]);
                    }
                    this.vtCaseIssueList.push({ "violationTypeId" : waitingOneId , "violationVariables": waitingOneList})
                }
            } 

            var waitingTwoList = []
            var waitingTwoId
            if(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeTwo !== undefined){
                if(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeTwo.length > 0){
                    for(var j=0; j<this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeTwo.length; j++){
                        waitingTwoId = this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeTwo[j].violationTypeId;
                        waitingTwoList.push(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeTwo[j]);
                    }
                    this.vtCaseIssueList.push({ "violationTypeId" : waitingTwoId , "violationVariables": waitingTwoList})
                }
            }

            var waitingThreeList = []
            var waitingThreeId
            if(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeThree !== undefined){
                if(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeThree.length > 0){
                    for(var j=0; j<this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeThree.length; j++){
                        waitingThreeId = this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeThree[j].violationTypeId;
                        waitingThreeList.push(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeThree[j]);
                    }
                    this.vtCaseIssueList.push({ "violationTypeId" : waitingThreeId , "violationVariables": waitingThreeList})
                }
            }

            var waitingFourList = []
            var waitingFourId
            if(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeFour !== undefined){
                if(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeFour.length > 0){
                    for(var j=0; j<this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeFour.length; j++){
                        waitingFourId = this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeFour[j].violationTypeId;
                        waitingFourList.push(this.waitingTimeCaseIssueObj.violationTypeVariablesForWaitingTimeFour[j]);
                    }
                    this.vtCaseIssueList.push({ "violationTypeId" : waitingFourId , "violationVariables": waitingFourList})
                }
            }
        }

        var businessCostList = []
        var businessCostId
        if(this.violationTypeVariablesForBusinessCost !== undefined && this.violationTypeVariablesForBusinessCost.length > 0){
            for(var i=0; i<this.violationTypeVariablesForBusinessCost.length; i++){
                businessCostId = this.violationTypeVariablesForBusinessCost[i].violationTypeId;
                businessCostList.push(this.violationTypeVariablesForBusinessCost[i]);
            }
            this.vtCaseIssueList.push({ "violationTypeId" : businessCostId , "violationVariables": businessCostList})
        }

        var payCheckList = []
        var payCheckId
        if(this.violationTypeVariablesForPayCheck !== undefined && this.violationTypeVariablesForPayCheck.length > 0){
            for(var i=0; i<this.violationTypeVariablesForPayCheck.length; i++){
                payCheckId = this.violationTypeVariablesForPayCheck[i].violationTypeId;
                payCheckList.push(this.violationTypeVariablesForPayCheck[i]);
            }
            this.vtCaseIssueList.push({ "violationTypeId" : payCheckId , "violationVariables": payCheckList})
        }

        var payRollList = []
        var payRollId
        if(this.violationTypeVariablesForPayRoll !== undefined && this.violationTypeVariablesForPayRoll.length > 0){
            for(var i=0; i<this.violationTypeVariablesForPayRoll.length; i++){
                payRollId = this.violationTypeVariablesForPayRoll[i].violationTypeId;
                payRollList.push(this.violationTypeVariablesForPayRoll[i]);
            }
            this.vtCaseIssueList.push({ "violationTypeId" : payRollId , "violationVariables": payRollList})
        }

        var latePayrollList = []
        var latePayrollId
        if(this.violationTypeVariablesForLatePayroll !== undefined && this.violationTypeVariablesForLatePayroll.length > 0){
            for(var i=0; i<this.violationTypeVariablesForLatePayroll.length; i++){
                latePayrollId = this.violationTypeVariablesForLatePayroll[i].violationTypeId;
                latePayrollList.push(this.violationTypeVariablesForLatePayroll[i]);
            }
            this.vtCaseIssueList.push({ "violationTypeId" : latePayrollId , "violationVariables": latePayrollList})
        }

        var holidayPayList = []
        var holidayPayId
        if(this.violationTypeVariablesForHolidayPay !== undefined && this.violationTypeVariablesForHolidayPay.length > 0){
            for(var i=0; i<this.violationTypeVariablesForHolidayPay.length; i++){
                holidayPayId = this.violationTypeVariablesForHolidayPay[i].violationTypeId;
                holidayPayList.push(this.violationTypeVariablesForHolidayPay[i]);
            }
            this.vtCaseIssueList.push({ "violationTypeId" : holidayPayId , "violationVariables": holidayPayList})
        }

        var severancePayList = []
        var severancePayId
        if(this.violationTypeVariablesForSeverancePay !== undefined && this.violationTypeVariablesForSeverancePay.length > 0){
            for(var i=0; i<this.violationTypeVariablesForSeverancePay.length; i++){
                severancePayId = this.violationTypeVariablesForSeverancePay[i].violationTypeId;
                severancePayList.push(this.violationTypeVariablesForSeverancePay[i]);
            }
            this.vtCaseIssueList.push({ "violationTypeId" : severancePayId , "violationVariables": severancePayList})
        }

        var personalFileList = []
        var personalFileId
        if(this.violationTypeVariablesForPersonalFile !== undefined && this.violationTypeVariablesForPersonalFile.length > 0){
            for(var i=0; i<this.violationTypeVariablesForPersonalFile.length; i++){
                personalFileId = this.violationTypeVariablesForPersonalFile[i].violationTypeId;
                personalFileList.push(this.violationTypeVariablesForPersonalFile[i]);
            }
            this.vtCaseIssueList.push({ "violationTypeId" : personalFileId , "violationVariables": personalFileList})
        }

        if(this.employerWorkedCaseIssueObj !== undefined && this.employerWorkedCaseIssueObj !== null){
            var employerOneHourlhyRateList = []
            var employerOneHourlyRateId
            if(this.employerWorkedCaseIssueObj.violationTypeVariablesForOneHourlyRate !== undefined){
                if(this.employerWorkedCaseIssueObj.violationTypeVariablesForOneHourlyRate.length > 0){
                    for(var j=0; j<this.employerWorkedCaseIssueObj.violationTypeVariablesForOneHourlyRate.length; j++){
                        employerOneHourlyRateId = this.employerWorkedCaseIssueObj.violationTypeVariablesForOneHourlyRate[j].violationTypeId;
                        employerOneHourlhyRateList.push(this.employerWorkedCaseIssueObj.violationTypeVariablesForOneHourlyRate[j]);
                    }
                    this.vtCaseIssueList.push({ "violationTypeId" : employerOneHourlyRateId , "violationVariables": employerOneHourlhyRateList})
                }
            } 

            var employerLocalWageList = []
            var employerLocalWageId
            if(this.employerWorkedCaseIssueObj.violationTypeVariablesForOneHourlyForMin !== undefined){
                if(this.employerWorkedCaseIssueObj.violationTypeVariablesForOneHourlyForMin.length > 0){
                    for(var j=0; j<this.employerWorkedCaseIssueObj.violationTypeVariablesForOneHourlyForMin.length; j++){
                        employerLocalWageId = this.employerWorkedCaseIssueObj.violationTypeVariablesForOneHourlyForMin[j].violationTypeId;
                        employerLocalWageList.push(this.employerWorkedCaseIssueObj.violationTypeVariablesForOneHourlyForMin[j]);
                    }
                    this.vtCaseIssueList.push({ "violationTypeId" : employerLocalWageId , "violationVariables": employerLocalWageList})
                }
            }

            var employerSS12List = []
            var employerSS12Id
            if(this.employerWorkedCaseIssueObj.violationTypeVariablesForSS12 !== undefined){
                if(this.employerWorkedCaseIssueObj.violationTypeVariablesForSS12.length > 0){
                    for(var j=0; j<this.employerWorkedCaseIssueObj.violationTypeVariablesForSS12.length; j++){
                        employerSS12Id = this.employerWorkedCaseIssueObj.violationTypeVariablesForSS12[j].violationTypeId;
                        employerSS12List.push(this.employerWorkedCaseIssueObj.violationTypeVariablesForSS12[j]);
                    }
                    this.vtCaseIssueList.push({ "violationTypeId" : employerSS12Id , "violationVariables": employerSS12List})
                }
            }

            var employerStateWageList = []
            var employerStateWageId
            if(this.employerWorkedCaseIssueObj.violationTypeVariablesForSalaryRate !== undefined){
                if(this.employerWorkedCaseIssueObj.violationTypeVariablesForSalaryRate.length > 0){
                    for(var j=0; j<this.employerWorkedCaseIssueObj.violationTypeVariablesForSalaryRate.length; j++){
                        employerStateWageId = this.employerWorkedCaseIssueObj.violationTypeVariablesForSalaryRate[j].violationTypeId;
                        employerStateWageList.push(this.employerWorkedCaseIssueObj.violationTypeVariablesForSalaryRate[j]);
                    }
                    this.vtCaseIssueList.push({ "violationTypeId" : employerStateWageId , "violationVariables": employerStateWageList})
                }
            }
        }

        var productionBonusList = []
        var productionBonusId
        if(this.violationTypeVariablesForProductionBonus !== undefined && this.violationTypeVariablesForProductionBonus.length > 0){
            for(var i=0; i<this.violationTypeVariablesForProductionBonus.length; i++){
                productionBonusId = this.violationTypeVariablesForProductionBonus[i].violationTypeId;
                productionBonusList.push(this.violationTypeVariablesForProductionBonus[i]);
            }
            this.vtCaseIssueList.push({ "violationTypeId" : productionBonusId , "violationVariables": productionBonusList})
        } 

        var vacationTypeList = []
        var vacationTypeListId
        if(this.violationTypeVariablesForVacationTime !== undefined && this.violationTypeVariablesForVacationTime.length > 0){
            if(this.violationTypeVariablesForVacationTime.length > 0){
                for(var j=0; j<this.violationTypeVariablesForVacationTime.length; j++){
                    vacationTypeListId = this.violationTypeVariablesForVacationTime[j].violationTypeId;
                    vacationTypeList.push(this.violationTypeVariablesForVacationTime[j]);
                }
                this.vtCaseIssueList.push({ "violationTypeId" : vacationTypeListId , "violationVariables": vacationTypeList})
            }
        }
    }

    wageDefInfoObj(){
        return {
            sectionId : this.sectionid,
            claimPeriodStartDate : this.claimPeriodStartDate,
            claimPeriodEndDate : this.claimPeriodEndDate,
            notPaidForWork : this.notPaidForWork,
            showOneHourlyRateTemplate : this.showOneHourlyRateTemplate,
            isOneHourlyRate : this.isOneHourlyRate,
            isLocalMinimumWage : this.isLocalMinimumWage,
            isStateMinimumWage : this.isStateMinimumWage,
            isFirstOptionTrue : this.isFirstOptionTrue,
            workNotPaidData : this.workNotPaidData,
            renderWorkedNotPaidSection : this.renderWorkedNotPaidSection,
            noOvertimePaid : this.noOvertimePaid,
            isSecondOptionTrue : this.isSecondOptionTrue,
            overTimeDetails : this.overTimeDetails,
            renderOverTimeSection : this.renderOverTimeSection,
            noSickLeavePaid : this.noSickLeavePaid,
            isThirdOptionTrue : this.isThirdOptionTrue,
            sickLeaveDetails : this.sickLeaveDetails,
            renderSickLeaveSection : this.renderSickLeaveSection,
            notPaidForVacationTime : this.notPaidForVacationTime,
            isFourthOptionTrue : this.isFourthOptionTrue,
            notPaidForHoliday : this.notPaidForHoliday,
            isFifthOptionTrue : this.isFifthOptionTrue,
            notAllowedBathBreak : this.notAllowedBathBreak,
            isSixthOptionTrue : this.isSixthOptionTrue,
            restBreakDetails : this.restBreakDetails,
            renderRestBreakSection : this.renderRestBreakSection,
            notAllowedMealBreak : this.notAllowedMealBreak,
            isSeventhOptionTrue : this.isSeventhOptionTrue,
            mealBreakDetails : this.mealBreakDetails,
            renderMealBreakSection : this.renderMealBreakSection,
            notAllowedForHeatRest : this.notAllowedForHeatRest,
            isEightOptionTrue : this.isEightOptionTrue,
            restClaimDetails : this.restClaimDetails,
            renderRestClaimSection : this.renderRestClaimSection,
            notPaidSeverancePay : this.notPaidSeverancePay,
            deniedShareTips : this.deniedShareTips,
            isTenthOptionTrue : this.isTenthOptionTrue,
            deniedBusinessCost : this.deniedBusinessCost,
            isEleventhOptionTrue : this.isEleventhOptionTrue,
            deniedPaymentMilega : this.deniedPaymentMilega,
            isTwelveOptionTrue : this.isTwelveOptionTrue,
            mileageClaimDetails : this.mileageClaimDetails,
            renderMilegaClaimSection : this.renderMilegaClaimSection,
            paycheckDeduction : this.paycheckDeduction,
            isThirteenthOptionTrue  : this.isThirteenthOptionTrue,
            deniedPayrollInfo : this.deniedPayrollInfo,
            isFouteenOptionTrue : this.isFouteenOptionTrue,
            deniedPersonnelFile : this.deniedPersonnelFile,
            isFifteenOptionTrue : this.isFifteenOptionTrue,
            employerDeniedWork : this.employerDeniedWork,
            isSixteenOptionTrue : this.isSixteenOptionTrue,
            fundClaimDetails : this.fundClaimDetails,
            renderFundClaimSection : this.renderFundClaimSection,
            productionBonus : this.productionBonus,
            isSeventeenOptionTrue : this.isSeventeenOptionTrue,
            reportedToWork : this.reportedToWork,
            isEighteenOptionTrue : this.isEighteenOptionTrue,
            payClaimDetails : this.payClaimDetails,
            renderPayClaimSection : this.renderPayClaimSection,
            garmentWageClaim : this.garmentWageClaim,
            isNinteenOptionTrue : this.isNinteenOptionTrue,
            garmentEmpDetails : this.garmentEmpDetails,
            isEmployeeWorkedDateValid : this.isEmployeeWorkedDateValid,
            vacationTimeClaimDetails : this.vacationTimeClaimDetails,
            isVacationTimeClaimUpload : this.isVacationTimeClaimUpload,
            vacationTimeClaimSize : this.vacationTimeClaimSize,
            violationTypeVariablesForVacationTime : this.violationTypeVariablesForVacationTime,
            isVacationTime : this.isVacationTime,
            isHolidayPay : this.isHolidayPay,
            holidayPay : this.holidayPay  ,
            serverancePay : this.serverancePay,
            isSeverancePay : this.isSeverancePay,
            claimPoolTips : this.claimPoolTips,
            claimTipReceived : this.claimTipReceived,
            violationTypeVariablesForPayCheck : this.violationTypeVariablesForPayCheck,
            violationTypeVariablesForPayRoll : this.violationTypeVariablesForPayRoll,
            isPayRollInfo : this.isPayRollInfo,
            isPayCheck : this.isPayCheck,
            paidbycheck : this.paidbycheck,
            violationTypeVariablesForPersonalFile : this.violationTypeVariablesForPersonalFile,
            isPersonalFile : this.isPersonalFile,
            violationTypeVariablesForProductionBonus : this.violationTypeVariablesForProductionBonus,
            isProductionBonus : this.isProductionBonus,
            explainProdBonus : this.explainProdBonus,
            additionalClaimEarn : this.additionalClaimEarn,
            violationTypeVariablesForBusinessCost : this.violationTypeVariablesForBusinessCost,
            isBusinessCost : this.isBusinessCost,
            unreimbursedDoc : this.unreimbursedDoc,
            isUnreimbursedUpload : this.isUnreimbursedUpload,
            unreimbursedDocSize : this.unreimbursedDocSize,
            isExplain : this.isExplain,
            anotherClaimExplain : this.anotherClaimExplain,
            explainBonus : this.explainBonus,
            employerWorkedDetails : this.employerWorkedDetails,
            severancePayOffered : this.severancePayOffered,
            violationTypeVariablesForShareTips : this.violationTypeVariablesForShareTips,
            endingDatePayroll : this.endingDatePayroll,
            beggingDatePayroll : this.beggingDatePayroll,
            quitdate : this.quitdate,
            noticebeforequit : this.noticebeforequit,
            payrollDemandDate : this.payrollDemandDate,
            employerResponse : this.employerResponse,
            personalFileDemandDate : this.personalFileDemandDate,
            personalEmployerResponse : this.personalEmployerResponse,
            violationTypeVariablesForWrittenStatement : this.violationTypeVariablesForWrittenStatement,
            violationTypeVariablesForLatePayroll : this.violationTypeVariablesForLatePayroll,
            waitingTimeDetails : this.waitingTimeDetails,
            isnotidentifyemployer : this.isnotidentifyemployer,
            dischargeddate : this.dischargeddate,
            contentVersionIds : this.contentVersionIds,
            quitdatevalue : this.quitdatevalue,
            violationTypeVariablesForSeverancePay : this.violationTypeVariablesForSeverancePay,
            violationTypeVariablesForHolidayPay : this.violationTypeVariablesForHolidayPay,
            isHolidayPays : this.isHolidayPays,
            isWrittenStatement : this.isWrittenStatement,
            isHeatRestDef : this.isHeatRestDef,
            werewagespaid : this.werewagespaid,
            isLatePayroll : this.isLatePayroll,
            flag : this.flag
        }
    }

    @api strString1
    // Child method for this section
    @api
    handleWageDeficienciesChildData(strString, isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode
        this.wageDeficiencyPreviewDetail = strString
        this.claimPeriodStartDate = strString.claimPeriodStartDate
        this.claimPeriodEndDate = strString.claimPeriodEndDate
        this.notPaidForWork = strString.notPaidForWork
        this.showOneHourlyRateTemplate = strString.showOneHourlyRateTemplate
        this.isOneHourlyRate = strString.isOneHourlyRate
        this.isLocalMinimumWage = strString.isLocalMinimumWage
        this.isStateMinimumWage = strString.isStateMinimumWage
        this.isFirstOptionTrue = strString.isFirstOptionTrue
        this.workNotPaidData = strString.workNotPaidData
        this.isWrittenStatement = strString.isWrittenStatement
        this.isHeatRestDef = strString.isHeatRestDef

        this.violationTypeVariablesForSeverancePay = strString.violationTypeVariablesForSeverancePay
        this.isSeverancePays = strString.isSeverancePays
        this.strString1 = strString.renderWorkedNotPaidSection
        this.renderWorkedNotPaidSection.length = 0
        this.isRenderWorkedNotPaidSection = true
        if(this.strString1 !== undefined || this.strString1 !== null || this.strString1 !== ''){
            for(let i = 0;i < this.strString1.length;i++){
                this.isRenderWorkedNotPaidSection = false
                this.renderWorkedNotPaidSection.push(this.strString1[i])
            }
        }
        this.violationTypeVariablesForHolidayPay = strString.violationTypeVariablesForHolidayPay,
        this.isHolidayPays = strString.isHolidayPays,
        this.flag1 = this.renderWorkedNotPaidSection.length
        this.isRenderWorkedNotPaidSection = true
        this.noOvertimePaid = strString.noOvertimePaid
        this.isSecondOptionTrue = strString.isSecondOptionTrue
        this.overTimeDetails = strString.overTimeDetails
        this.renderOverTimeSection = strString.renderOverTimeSection
        this.noSickLeavePaid = strString.noSickLeavePaid
        this.isThirdOptionTrue = strString.isThirdOptionTrue
        this.sickLeaveDetails = strString.sickLeaveDetails
        this.renderSickLeaveSection = strString.renderSickLeaveSection
        this.isFourthOptionTrue = strString.isFourthOptionTrue
        this.notPaidForVacationTime = strString.notPaidForVacationTime
        this.notPaidForHoliday = strString.notPaidForHoliday
        this.isFifthOptionTrue = strString.isFifthOptionTrue
        this.notAllowedBathBreak = strString.notAllowedBathBreak
        this.isSixthOptionTrue = strString.isSixthOptionTrue
        this.restBreakDetails = strString.restBreakDetails
        this.renderRestBreakSection = strString.renderRestBreakSection
        this.notAllowedMealBreak = strString.notAllowedMealBreak
        this.paidbycheck = this.paidbycheck !== undefined ? this.paidbycheck : strString.paidbycheck
        this.werewagespaid = this.werewagespaid !== undefined ? this.werewagespaid : strString.werewagespaid
        this.isLatePayroll = this.werewagespaid === true ? this.isLatePayroll = true : this.isLatePayroll = false
        this.isSeventhOptionTrue = strString.isSeventhOptionTrue
        this.mealBreakDetails = strString.mealBreakDetails
        this.renderMealBreakSection = strString.renderMealBreakSection
        this.notAllowedForHeatRest = strString.notAllowedForHeatRest
        this.isEightOptionTrue = strString.isEightOptionTrue
        this.restClaimDetails = strString.restClaimDetails
        this.renderRestClaimSection = strString.renderRestClaimSection
        this.notPaidSeverancePay = strString.notPaidSeverancePay
        this.isNinethOptionTrue = strString.isNinethOptionTrue
        this.deniedShareTips = strString.deniedShareTips
        this.isTenthOptionTrue = strString.isTenthOptionTrue
        this.deniedBusinessCost = strString.deniedBusinessCost
        this.isEleventhOptionTrue = strString.isEleventhOptionTrue
        this.deniedPaymentMilega = strString.deniedPaymentMilega
        this.isTwelveOptionTrue = strString.isTwelveOptionTrue
        this.mileageClaimDetails = strString.mileageClaimDetails
        this.renderMilegaClaimSection = strString.renderMilegaClaimSection
        this.paycheckDeduction = strString.paycheckDeduction
        this.isThirteenthOptionTrue = strString.isThirteenthOptionTrue
        this.deniedPayrollInfo = strString.deniedPayrollInfo
        this.isFouteenOptionTrue = strString.isFouteenOptionTrue
        this.deniedPersonnelFile = strString.deniedPersonnelFile
        this.isFifteenOptionTrue = strString.isFifteenOptionTrue
        this.employerDeniedWork = strString.employerDeniedWork
        this.isSixteenOptionTrue = strString.isSixteenOptionTrue
        this.fundClaimDetails = strString.fundClaimDetails
        this.renderFundClaimSection = strString.renderFundClaimSection
        this.productionBonus = strString.productionBonus
        this.isSeventeenOptionTrue = strString.isSeventeenOptionTrue
        this.reportedToWork = strString.reportedToWork
        this.isEighteenOptionTrue = strString.isEighteenOptionTrue
        this.payClaimDetails = strString.payClaimDetails
        this.renderPayClaimSection = strString.renderPayClaimSection
        this.garmentWageClaim = strString.garmentWageClaim
        this.isNinteenOptionTrue = strString.isNinteenOptionTrue
        this.garmentEmpDetails = strString.garmentEmpDetails
        this.isEmployeeWorkedDateValid = this.isEmployeeWorkedDateValid === true ? true : strString.isEmployeeWorkedDateValid;
        this.vacationTimeClaimDetails = strString.vacationTimeClaimDetails
        this.isVacationTimeClaimUpload = this.quitDate === true || this.DishargedDate === true ? strString.isVacationTimeClaimUpload : ''
        this.vacationTimeClaimSize = strString.vacationTimeClaimSize
        this.violationTypeVariablesForVacationTime = strString.violationTypeVariablesForVacationTime
        this.isVacationTime = this.isVacationTime === true ? true : false;
        this.isHolidayPay = strString.isHolidayPay
        this.holidayPay = strString.holidayPay 
        this.isSeverancePay = strString.isSeverancePay
        this.serverancePay = strString.serverancePay
        this.claimPoolTips = strString.claimPoolTips,
        this.claimTipReceived = strString.claimTipReceived   
        this.violationTypeVariablesForPayCheck = strString.violationTypeVariablesForPayCheck
        this.isPayCheck = strString.isPayCheck   
        this.violationTypeVariablesForPayRoll = strString.violationTypeVariablesForPayRoll
        this.isPayRollInfo = strString.isPayRollInfo 
        this.violationTypeVariablesForPersonalFile = strString.violationTypeVariablesForPersonalFile,
        this.isPersonalFile = strString.isPersonalFile
        this.violationTypeVariablesForProductionBonus = strString.violationTypeVariablesForProductionBonus,
        this.isProductionBonus = strString.isProductionBonus
        this.explainProdBonus = strString.explainProdBonus
        this.additionalClaimEarn = strString.additionalClaimEarn
        this.isExplain = strString.isExplain
        this.violationTypeVariablesForBusinessCost = strString.violationTypeVariablesForBusinessCost,
        this.isBusinessCost = strString.isBusinessCost,
        this.unreimbursedDoc = strString.unreimbursedDoc,
        this.isUnreimbursedUpload = strString.isUnreimbursedUpload,
        this.unreimbursedDocSize = strString.unreimbursedDocSize,
        this.anotherClaimExplain = strString.anotherClaimExplain
        this.explainBonus = strString.explainBonus
        this.employerWorkedDetails = strString.employerWorkedDetails
        this.severancePayOffered = strString.severancePayOffered
        this.violationTypeVariablesForShareTips = strString.violationTypeVariablesForShareTips
        this.endingDatePayroll = strString.endingDatePayroll
        this.beggingDatePayroll = strString.beggingDatePayroll
        this.waitingTimeDetails = strString.waitingTimeDetails
        this.quitdate = (this.quitdate !== undefined || this.quitdate !== null) ? this.quitdate : strString.quitdate,
        this.payrollDemandDate = strString.payrollDemandDate
        this.employerResponse = strString.employerResponse
        this.personalFileDemandDate = strString.personalFileDemandDate
        this.personalEmployerResponse = strString.personalEmployerResponse
        this.violationTypeVariablesForWrittenStatement = strString.violationTypeVariablesForWrittenStatement,
        this.noticebeforequit = strString.noticebeforequit,
        this.violationTypeVariablesForLatePayroll = strString.violationTypeVariablesForLatePayroll
        this.dischargeddate = this.dischargeddate !== undefined || this.dischargeddate !== null ? this.dischargeddate : strString.dischargeddate
        this.flag = strString.flag,
        this.quitdatevalue = this.quitdatevalue !== undefined || this.quitdatevalue !== null ? this.quitdatevalue : strString.quitdatevalue
        this.contentVersionIds = strString.contentVersionIds
        this.isnotidentifyemployer = (this.isnotidentifyemployer === undefined || this.isnotidentifyemployer === null) ? strString.isnotidentifyemployer : this.isnotidentifyemployer
        this.isRenderedCallback = true;
    }

    @api paymentOfWagesDetails
    @api
    handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
        this.paymentOfWagesDetails = paymentOfWagesDetails;
        this.isFormPreviewMode = isFormPreviewMode;
        const temp = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate');
        if(temp.length > 0){
            for(var i=0; i<temp.length; i++){
                temp[i].handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
            }
        } 
    }

    @api toastFileUploadMsg = customLabelValues.OWC_fileupload_success_toast_msg
    @api toastFileDeleteMsg = customLabelValues.OWC_multiple_file_delete_toast_msg


    @api isHelpText = false;
    @api helpText;
    @api issickleavehelptext = false;

    // Helptext
    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === 'regularClaimHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_regular_claim_helptext;
        }
        else if(learnMoreName === 'sickLeaveOptionHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_sick_leave_helptext;
            this.issickleavehelptext = true;
        }
        else if(learnMoreName === 'otOrDtClaimHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_OT_DT_claim_helptext;
        }
        else if(learnMoreName === 'multiFileUploadHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_multiplefileupload_helptext;
        }
        else if(learnMoreName === 'waitingTimeHelpTextForThree'){
            this.isHelpText = true;
            this.helpText = 'Your daily rate of pay can be determined by multiplying your hourly rate times the number of hours worked per day or dividing a  salary rate by the number of days worked per pay period. For commision or piece rate employment, use average daily rates.'
        }
        else if(learnMoreName === 'waitingTimeHelpText'){
            this.isHelpText = true;
            this.helpText = "Your daily rate of pay can be determined by multiplying your hourly rate times the number of hours worked per day or dividing a  salary rate by the number of days worked per pay period. For commision or piece rate employment, use average daily rates."
        }
        else if(learnMoreName === "deniedPayroll"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_denied_payroll_helptext;
        }
        else if(learnMoreName === 'deniedPersonalFile'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_denied_personnel_file_label;
        }
        else if(learnMoreName === "vacationTimeTotalHourHelpMsg"){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_vacation_time_final_rate;
        }
        else if(learnMoreName === 'vacationTimeClaim'){
            this.isHelpText = true;
            this.isdlse55Available = null;
            this.helpText = customLabelValues.OWC_typically_worked_vacationtimeclaims_helptext;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        }
        else if(learnMoreName === "unreimbursedBusiness"){
            this.isHelpText = true;
            this.isdlse55Available = null;
            this.helpText = customLabelValues.OWC_typically_worked_unreimbursed_business_helptext;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        } 
        else if(learnMoreName === 'deniedPaymentText'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_mileage_denied_helptext;
        }   
        else if(learnMoreName === "listedClaimHelptext"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_select_one_checkbox_label;
        }
        else if(learnMoreName === 'productionBonus'){
            this.isHelpText = true;
            this.helpText = 'Examples of a Production Bonus are $100 for staying until end of season; $2 for each day worked X 100 days; 1% of earnings for pieces produced.';
        }    
        else if(learnMoreName === 'paymentDenied'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_business_denied_helptext;
        }
    }
  
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    @api vacationTimeClaimDetails
    @api isVacationTimeClaimUpload = false;
    @api vacationTimeClaimSize;

    handleVacationTimeClaimDoc(event){
        const uploadedFiles = event.detail.files;
        this.vacationTimeClaimDetails = uploadedFiles;
        if(uploadedFiles != null){
            this.isVacationTimeClaimUpload = false
            this.vacationTimeClaimSize = this.vacationTimeClaimDetails.length
            this.template.querySelector('[data-id="vacationTimeClaimId"]').getDocData(this.vacationTimeClaimDetails);
            this.isRenderedCallback = false
            this.showToast('Success!',this.toastFileUploadMsg, 'success');
        }
        else{
            this.isVacationTimeClaimUpload = true
        }
    }

    handleVacationTimeClaimEvent(event){
        this.vacationTimeClaimDetails = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.vacationTimeClaimSize = this.vacationTimeClaimDetails.length
    } 
  
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    @api quitDate = false;
    @api DishargedDate = false;
    @api isEmployeeWorkedDateValid = false;
    @api
    handleEmpStatusValue(quitDate, DishargedDate){
        this.quitDate = quitDate;
        this.DishargedDate = DishargedDate;
        if(quitDate === true || DishargedDate === true){
            this.isEmployeeWorkedDateValid = true;
        }
        else{
            this.isEmployeeWorkedDateValid = false;
        }
    }

    renderedCallback(){
        if(this.isRenderedCallback === true && (this.vacationTimeClaimDetails  !== undefined || this.unreimbursedDoc !== undefined) && (this.vacationTimeClaimSize > 0 || this.unreimbursedDocSize > 0) ){
            const templateArray = this.template.querySelectorAll('c-owc-Multiple-File-Upload-Details-Cmp')
            for (let i = 0; i < templateArray.length; i++){
                if(templateArray[i].name === 'vacationTimeClaimId'){
                        templateArray[i].getDocInfos(this.vacationTimeClaimDetails, this.isFormPreviewMode);
                }
                else if(templateArray[i].name === 'unreimbursedDocId'){
                        templateArray[i].getDocInfos(this.unreimbursedDoc, this.isFormPreviewMode);
                }
            }
        }

        if(this.isRenderedCallback === true && this.isHolidayPayClaim === true && this.isSeverancePays === true){
            this.callHolidayServer();
        }
        if(this.isRenderedCallback === true && this.isSeverancePayTrue === true && this.isSeverancePays === true){
            this.callSeverancePayIssue();
        }
        if(this.isRenderedCallback === true && this.werewagespaid !== undefined && this.isLatePayroll === true){
            this.handleLatePayrollServerCall();
        }
        if((this.quitdate !== undefined || this.dischargeddate !== undefined) && this.notPaidForVacationTime === true && this.isRenderedCallback === true){
            this.handleServerCall();
            this.isEmployeeWorkedDateValid = true;
        }
        if(this.isWorkedNotPaidSectionDeleted === true){
            const wageDefDetails = this.workedNotPaidSectionDataAfterDelete
            const wageDefSectionDetails = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate')
            for (let i = 0; i < wageDefSectionDetails.length; i++){
                wageDefSectionDetails[i].handleWageDeficienciesChild(wageDefDetails[i])
            }
            this.isWorkedNotPaidSectionDeleted = false
        }
        if(this.noOvertimePaid === true && this.isSecondOptionTrue === true){
            this.template.querySelector('c-owc-Over-Time-Or-Double-Time-Container-Def').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.noSickLeavePaid === true && this.isThirdOptionTrue === true){
            this.template.querySelector('c-owc-Not-Paid-Sick-Leave-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.notAllowedBathBreak === true && this.isSixthOptionTrue === true){
            this.template.querySelector('c-owc-Not-Allowed-Rest-Break-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.notAllowedMealBreak === true && this.isSeventhOptionTrue === true){
            this.template.querySelector('c-owc-Not-Allowed-For-Meal-Break-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if((this.notAllowedForHeatRest === true && this.isEightOptionTrue === true)){
            this.template.querySelector('c-owc-Not-Allowed-Heat-Rest-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.employerDeniedWork === true && this.employerWorkedDetails !== undefined){
            this.template.querySelector('c-owc-Employer-Worked-Defined').handleEmployerWorkedChild(this.employerWorkedDetails, this.isFormPreviewMode);
        }
        if(this.isnotidentifyemployer === 'No' && this.waitingTimeDetails !== undefined){
            this.template.querySelector('c-owc-Waiting-Time-Claim').handleWaitingInfoChild(this.waitingTimeDetails, this.isFormPreviewMode);
        }
        if(this.reportedToWork === true && this.isEighteenOptionTrue === true){
            this.template.querySelector('c-owc-Reporting-Time-Pay-Claim-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.garmentWageClaim === true && this.isNinteenOptionTrue === true){
            this.template.querySelector('c-O-W-C-Garment-Employee-Option-Cmp').owcGarmentEmpDataForChild(this.garmentEmpDetails, this.isFormPreviewMode);
        }
        if(this.noOvertimePaid === true && this.overTimeDetails !== undefined){
            this.template.querySelector('c-owc-Over-Time-Or-Double-Time-Container-Def').overTimeParentInfoSectionChild(this.overTimeDetails, this.renderOverTimeSection, this.isFormPreviewMode);
        }
        if(this.noSickLeavePaid === true && this.sickLeaveDetails !== undefined){
            this.template.querySelector('c-owc-Not-Paid-Sick-Leave-Container').overTimeParentInfoSectionChild(this.sickLeaveDetails, this.renderSickLeaveSection, this.isFormPreviewMode);
        }
        if(this.notAllowedBathBreak === true && this.restBreakDetails !== undefined){
            this.template.querySelector('c-owc-Not-Allowed-Rest-Break-Container').overTimeParentInfoSectionChild(this.restBreakDetails, this.renderRestBreakSection, this.isFormPreviewMode);
        }
        if(this.notAllowedMealBreak === true && this.mealBreakDetails !== undefined){
            this.template.querySelector('c-owc-Not-Allowed-For-Meal-Break-Container').overTimeParentInfoSectionChild(this.mealBreakDetails, this.renderMealBreakSection, this.isFormPreviewMode);
        }
        if((this.notAllowedForHeatRest === true && this.restClaimDetails !== undefined)){
            this.template.querySelector('c-owc-Not-Allowed-Heat-Rest-Container').overTimeParentInfoSectionChild(this.restClaimDetails, this.renderRestClaimSection, this.isFormPreviewMode);
        }
        
        if(this.deniedPaymentMilega === true && this.mileageClaimDetails !== undefined){
            this.template.querySelector('c-owc-Denied-Milega-Pay-Container').overTimeParentInfoSectionChild(this.mileageClaimDetails, this.renderMilegaClaimSection, this.isFormPreviewMode);
        }
        if(this.paidbycheck === true && this.fundClaimDetails !== undefined){
            this.template.querySelector('c-owc-Insufficient-Fund-Claim-Container').overTimeParentInfoSectionChild(this.fundClaimDetails, this.renderFundClaimSection, this.isFormPreviewMode);
        }
        if(this.reportedToWork === true && this.payClaimDetails !== undefined){
            this.template.querySelector('c-owc-Reporting-Time-Pay-Claim-Container').overTimeParentInfoSectionChild(this.payClaimDetails, this.renderPayClaimSection, this.isFormPreviewMode);
        }
        if(this.isRenderedCallback === true){
            const workNotPaidData = this.workNotPaidData
            const details = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate')
            for (let i = 0; i < details.length; i++){
                details[i].handleWageDeficienciesChild(workNotPaidData[i],this.isFormPreviewMode)
            }
            this.workNotPaidData = []
        }
        
        if(this.employerDeniedWork === true && this.isSixteenOptionTrue === true){
            this.template.querySelector('c-owc-Employer-Worked-Defined').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        this.isRenderedCallback = false;
    }
}