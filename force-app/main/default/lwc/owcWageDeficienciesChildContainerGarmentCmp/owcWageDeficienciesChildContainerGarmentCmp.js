import { LightningElement, api ,track, wire } from 'lwc';
import { radioOptions, acceptedFileFormat, customLabelValues } from 'c/owcUtils';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
import { loadStyle } from 'lightning/platformResourceLoader'; 
import deleteMultipleFiles from '@salesforce/apex/OWCMultipleFileDeleteController.deleteMultipleFiles';
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OwcWageDeficienciesChildContainerGarmentCmp extends LightningElement {
    @track fileNames = '';
    @api is_wage_def_garment_claim;
    @track filesUploaded = [];
    @api paidbreaks;
    @api chequereplaced;
    options = radioOptions
    @api salaryratelist
    @api multiplehourlyrate
    @api hourlyratelist
    @api minimumwage
    @api userworkedhours
    @api stateratelist;
    @api isRenderedCallback = false;
    @api isFormPreviewMode = false;
    @api sectionid;
    @api paidbycheck;
    @api noticebeforequit
    @api werewagespaid
    @api quitdatevalue
    @api finalpaymentdate;
    @api isfarmlabour;
    @api is_domestic_worker;
    @api isNinteenOptionTrue = false
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
    @api isEighteenOptionTrue = false;
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

    @api isWrittenStatement = false;
    @api isLatePayroll = false;
    @api isInsufficientFund = false;
    @api isWaitingTime = false;
    @api beggingDatePayroll;
    @api endingDatePayroll;
    @api empstatementprovided;

    @api dischargeddate;
    @api otherworkcity;
    @api paystubsickrecord;

    @api minimumwagezipcode;
    @api minimumhiredate;

    @api workNotPaidDetails = [];
    @api powdetails;
    @api isnotidentifyemployer
    
    @api renderWorkedNotPaidSection = [];
    @api workedNotPaidSectionDetails = []
    @api workedNotPaidSectionValues = ''
    @api isChanged = false
    @api deleteWorkedNotPaidSection
    @api workedNotPaidSectionDataAfterDelete = []
    @api isWorkedNotPaidSectionDeleted = false
    @api claimPoolTips
    @api claimTipReceived
    @api iwcinfoobj;
    @api isSeverancePayTrue = false;
    @api iswagedefpreview;
    @api wageclaimsubmit;
    flag = 0
    flag1 = 1
    @api garmentWageClaim = false
    @track isRenderWorkedNotPaidSection = true

    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data,error}) {
            if(data){
                this.severancePayOfferedOptions = data[0].owcSeverancePayOfferedOptions;
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
        const workNotPaidSectionDetails = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate-Garment')
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
        });
        this.paymentOfWagesDetails = this.powdetails
        this.empstatementprovided === 'No' ? this.handleWrittenStatement() : this.violationTypeVariablesForWrittenStatement !== undefined ? this.violationTypeVariablesForWrittenStatement.length = 0 : ''
        this.heatrecovery === 'No' ? this.isHeatRestDef = true : this.isHeatRestDef = false;
        this.isEightOptionTrue === true || this.heatrecovery === 'No' ? '' : this.restClaimCaseIssueData !== undefined ? this.restClaimCaseIssueData.length = 0 : ''
        this.werewagespaid === true ? this.isLatePayroll = true : this.isLatePayroll = false
        this.isLatePayroll === true ? this.handleLatePayrollServerCall() : ''
        
    }

    @api get paidByCheck(){
        return this.paidbycheck === true
    }

    @api get showWaitingTimeClaim(){
        return this.isnotidentifyemployer === 'No';
    }

    async callHolidayServer(){
        try{
            await this.getAllVilationTypeVariablesForHolidayPay('HP1');
        }catch (error){
            
        }
    }

    async callSeverancePayIssue(){
        try{
            await this.getAllVilationTypeVariablesForSeverancePay('SP1');
        }catch (error){
            
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
            
        }
    }
    async handleWrittenStatement(){
        try{
            await this.getAllVilationTypeVariablesForWrittenStatement('PE12');
        }catch (error){
            
        }
    }

   

    async handleDeniedBusinessCostCall(){
        try{
            await this.getAllVilationTypeVariablesForBusinessCost('17');
        }catch (error){
            
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
                    result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
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
                    result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
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
            
        }
    }

    async handleProductionBonusCall(){
        try{
            await this.getAllVilationTypeVariablesForProductionBonus('016');
        }catch (error){
            
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
                    result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
                    result[i].value = '';
                }
                 if(this.violationTypeVariablesForProductionBonus !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForProductionBonus = result;
                    this.violationTypeVariablesForProductionBonus.length > 0 ? this.isProductionBonus = true : this.isProductionBonus = false;
                 }
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
                    else if(result[i].dataType === 'Decimal' || result[i].dataType === 'Integer'){
                        result[i].numberFormat = true;
                    }
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
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
                    result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
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
                    result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
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
                    result[i].label === null || result[i].label === undefined ? result[i].isShow = false : result[i].isShow = true;
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
    @api totalAmountPaid;
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            case "payrollDemandDate":
                this.payrollDemandDate = event.target.value;
                break;
            case "totalAmountPaid":
                this.totalAmountPaid = event.target.value;
                break;
            case "employerResponse":
                this.employerResponse = event.target.value;
                break;
            case "personalFileDemandDate":
                this.personalFileDemandDate = event.target.value;
                break;
            case "personalEmployerResponse":
                this.personalEmployerResponse = event.target.value;
                break;
            case "anotherClaimExplain":
                this.anotherClaimExplain = event.target.value;
                break;
            case "explainProdBonus":
                this.explainProdBonus = event.target.value;
                break;
            case "beggingDatePayroll":
                this.beggingDatePayroll = event.target.value;
                break;
            case "endingDatePayroll":
                this.endingDatePayroll = event.target.value;
                break;
            case "explainBonus":
                this.explainBonus = event.target.value;
                break;
            case "claimPeriodStartDate":
                this.claimPeriodStartDate = event.target.value;
                break;
            case "claimPeriodEndDate":
                this.claimPeriodEndDate = event.target.value;
                break;
            case "notPaidForWork":
                this.notPaidForWork = event.target.checked;
                if(this.notPaidForWork === true){
                    this.isSpinner = true;
                    this.isFirstOptionTrue = true;
                    this.renderWorkedNotPaidSection.push({ heading : this.customLabelValues.OWC_claim_information, button : false, sectionId : 1 });
                    this.isRenderWorkedNotPaidSection = true;
                    //this.hideSpinner();
                }
                else{
                    this.isFirstOptionTrue = false;
                    this.isRenderWorkedNotPaidSection = false;
                    this.renderWorkedNotPaidSection.length = 0;
                    this.isFirstOptionTrue = false;
                    this.isRenderWorkedNotPaidSection = false;
                }
                break;
            case "noOvertimePaid":
                this.noOvertimePaid = event.target.checked;
                if(this.noOvertimePaid === true){
                    this.isSecondOptionTrue = true;
                }
                else{
                    this.isSecondOptionTrue = false;
                    this.overTimeDetails = undefined;
                    this.renderOverTimeSection = undefined
                }
                break;
            case "noSickLeavePaid":
                this.noSickLeavePaid = event.target.checked;
                if(this.noSickLeavePaid === true){
                    this.isThirdOptionTrue = true;
                }
                else{
                    this.isThirdOptionTrue = false;
                    this.sickLeaveDetails = undefined;
                    this.renderSickLeaveSection = undefined;
                }
                break;
            case "notPaidForVacationTime":
                this.notPaidForVacationTime = event.target.checked;
                if(this.notPaidForVacationTime === true){
                    this.isFourthOptionTrue = true;
                    if(this.quitDate === true || this.DishargedDate === true){
                        this.isEmployeeWorkedDateValid = true
                        this.handleServerCall();
                    }
                    else{
                        this.isEmployeeWorkedDateValid = false;
                    }
                }
                else{
                    this.isFourthOptionTrue = false;
                    this.vacationTimeClaimSize = 0;
                    this.isVacationTimeClaimUpload = false;
                    this.vacationTimeClaimDetails = [];
                    this.violationTypeVariablesForVacationTime = undefined;
                }
                break;
            case "notPaidForHoliday":
                this.notPaidForHoliday = event.target.checked;
                if(this.notPaidForHoliday === true){
                    this.isFifthOptionTrue = true;
                    this.isHolidayPay = true;
                }
                else{
                    this.isHolidayPayClaim = false;
                    this.isFifthOptionTrue = false;
                    this.isHolidayPay = false;
                    this.holidayPay = undefined;
                }
                break;
            case 'holidayPay':
                this.holidayPay = event.target.value;
                if(this.holidayPay === this.options[0].value){
                    this.isHolidayPayClaim = true;
                    this.callHolidayServer();
                }else{
                    this.isHolidayPayClaim = false;
                }
                break;
            case "notAllowedBathBreak":
                this.notAllowedBathBreak = event.target.checked;
                if(this.notAllowedBathBreak === true){
                    this.isSixthOptionTrue = true;
                }
                else{
                    this.isSixthOptionTrue = false;
                    this.restBreakDetails = undefined;
                }
                break;
            case "notAllowedMealBreak":
                this.notAllowedMealBreak = event.target.checked;
                if(this.notAllowedMealBreak === true){
                    this.isSeventhOptionTrue = true;
                }
                else{
                    this.isSeventhOptionTrue = false;
                    this.mealBreakDetails = undefined;
                    this.renderMealBreakSection = undefined;
                }
                break;
            case "notAllowedForHeatRest":
                this.notAllowedForHeatRest = event.target.checked;
                if(this.notAllowedForHeatRest === true){
                    this.isEightOptionTrue = true;
                }
                else{
                    this.isEightOptionTrue = false;
                    this.restClaimDetails = undefined;
                    this.renderRestClaimSection = undefined;
                }
                break;
            case "notPaidSeverancePay":
                this.notPaidSeverancePay = event.target.checked;
                if(this.notPaidSeverancePay === true){
                    this.isNinethOptionTrue = true;
                    this.isSeverancePay = true;
                }
                else{
                    this.isNinethOptionTrue = false;
                    this.isSeverancePay = false;
                    this.serverancePay = undefined;
                    this.severancePayOffered = undefined;
                }
                break;
            case 'severancePayOffered':
                this.severancePayOffered = event.target.value;
                break;
            case "serverancePay":
                this.serverancePay = event.target.value;
                if(this.serverancePay === this.options[0].value){
                    this.isSeverancePayTrue = true;
                    this.callSeverancePayIssue();
                } else{
                    this.isSeverancePayTrue = false;
                }
                break;
            case "claimPoolTips":
                this.claimPoolTips = event.target.value;
                break;
            case "claimTipReceived":
                this.claimTipReceived = event.target.value;
                break;
            case "deniedShareTips":
                this.deniedShareTips = event.target.checked;
                if(this.deniedShareTips === true){
                    this.isTenthOptionTrue = true;
                    this.getAllDataForShareTips();
                }
                else{
                    this.isTenthOptionTrue = false;
                    this.claimTipReceived = undefined;
                    this.claimPoolTips = undefined;
                    this.violationTypeVariablesForShareTips = undefined;
                }
                break;
            case "deniedBusinessCost":
                this.deniedBusinessCost = event.target.checked;
                if(this.deniedBusinessCost === true){
                    this.isEleventhOptionTrue = true;
                    this.handleDeniedBusinessCostCall();
                }
                else{
                    this.isEleventhOptionTrue = false;
                    this.violationTypeVariablesForBusinessCost = undefined;
                    this.unreimbursedDocSize = 0;
                    this.unreimbursedDoc = undefined;
                }
                break;
            case "deniedPaymentMilega":
                this.deniedPaymentMilega = event.target.checked;
                if(this.deniedPaymentMilega === true){
                    this.isTwelveOptionTrue = true;
                }
                else{
                    this.isTwelveOptionTrue = false;
                    this.mileageClaimDetails = undefined;
                    this.renderMilegaClaimSection = undefined;
                }
                break;
            case "paycheckDeduction":
                this.paycheckDeduction = event.target.checked;
                if(this.paycheckDeduction === true){
                    this.isThirteenthOptionTrue = true;
                    this.handlePayCheckCall();
                }
                else{
                    this.isThirteenthOptionTrue = false;
                    this.isPayCheck = false;
                    this.violationTypeVariablesForPayCheck = undefined;
                }
                break;
            case "deniedPayrollInfo":
                this.deniedPayrollInfo = event.target.checked;
                if(this.deniedPayrollInfo === true){
                    this.isFouteenOptionTrue = true;
                    this.handlePayRollInfoCall();
                }
                else{
                    this.isFouteenOptionTrue = false;
                    this.isPayRollInfo = false;
                    this.violationTypeVariablesForPayRoll = undefined;
                }
                break;
            case "deniedPersonnelFile":
                this.deniedPersonnelFile = event.target.checked;
                if(this.deniedPersonnelFile === true){
                    this.isFifteenOptionTrue = true;
                    this.handlePersonalFileCall();
                }
                else{
                    this.isFifteenOptionTrue = false;
                    this.violationTypeVariablesForPersonalFile = undefined;
                    this.isPersonalFile = false;
                }
                break;
            case "employerDeniedWork":
                this.employerDeniedWork = event.target.checked;
                if(this.employerDeniedWork === true){
                    this.isLoading = true;
                    this.isSixteenOptionTrue = true;
                }
                else{
                    this.isSixteenOptionTrue = false;
                    this.splitShiftDetails = undefined;
                }
                break;
            case "productionBonus":
                this.productionBonus = event.target.checked;
                if(this.productionBonus === true){
                    this.isSeventeenOptionTrue = true;
                    this.handleProductionBonusCall();
                }
                else{
                    this.isSeventeenOptionTrue = false;
                    this.violationTypeVariablesForProductionBonus = undefined;
                    this.explainProdBonus = null;
                    this.additionalClaimEarn = undefined;
                    this.explainBonus = null;
                    this.isExplain = false;
                }
                break;
            case "reportedToWork":
                this.reportedToWork = event.target.checked;
                if(this.reportedToWork === true){
                    this.isEighteenOptionTrue = true;
                }
                else{
                    this.isEighteenOptionTrue = false;
                    this.payClaimDetails = undefined;
                    this.renderPayClaimSection = undefined;
                }
                break;
            case "garmentWageClaim":
                this.garmentWageClaim = event.target.checked;
                if(this.garmentWageClaim === true){
                    this.isNinteenOptionTrue = true;
                }
                else{
                    this.isNinteenOptionTrue = false;
                    this.garmentEmpDetails = undefined;
                    //this.renderPayClaimSection = undefined;
                }
            break;
            case "additionalClaimEarn":
                this.additionalClaimEarn = event.target.value;
                if(this.additionalClaimEarn === this.options[0].value){
                    this.isExplain = true;
                }
                else{
                    this.isExplain = false;
                }
                break;
        }
    

        if(this.violationTypeVariablesForLatePayroll !== undefined){
            for(var i=0; i<this.violationTypeVariablesForLatePayroll.length; i++){
                this.violationTypeVariablesForLatePayroll[i].name === event.target.name ? this.violationTypeVariablesForLatePayroll[i].value = event.target.value : ''
            }
        }


        if(this.violationTypeVariablesForBusinessCost !== undefined){
            for(var i=0; i<this.violationTypeVariablesForBusinessCost.length; i++){
                this.violationTypeVariablesForBusinessCost[i].name === event.target.name ? this.violationTypeVariablesForBusinessCost[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForProductionBonus !== undefined){
            for(var i=0; i<this.violationTypeVariablesForProductionBonus.length; i++){
                this.violationTypeVariablesForProductionBonus[i].name === event.target.name ? this.violationTypeVariablesForProductionBonus[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForVacationTime !== undefined){
            for(var i=0; i<this.violationTypeVariablesForVacationTime.length; i++){
                this.violationTypeVariablesForVacationTime[i].name === event.target.name ? this.violationTypeVariablesForVacationTime[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForShareTips !== undefined){
            for(var i=0; i<this.violationTypeVariablesForShareTips.length; i++){
                this.violationTypeVariablesForShareTips[i].name === event.target.name ? this.violationTypeVariablesForShareTips[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForPayCheck !== undefined){
            for(var i=0; i<this.violationTypeVariablesForPayCheck.length; i++){
                this.violationTypeVariablesForPayCheck[i].name === event.target.name ? this.violationTypeVariablesForPayCheck[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForPayRoll !== undefined){
            for(var i=0; i<this.violationTypeVariablesForPayRoll.length; i++){
                this.violationTypeVariablesForPayRoll[i].name === event.target.name ? this.violationTypeVariablesForPayRoll[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForPersonalFile !== undefined){
            for(var i=0; i<this.violationTypeVariablesForPersonalFile.length; i++){
                this.violationTypeVariablesForPersonalFile[i].name === event.target.name ? this.violationTypeVariablesForPersonalFile[i].value = event.target.value : ''
            }
        }

    }

    @api unreimbursedDoc = [];
    @api isUnreimbursedUpload = false;
    @api unreimbursedDocSize;
    @api totalUnremburisedFiles = []
    handleunreimbursedDoc(event){
        const uploadedFiles = event.detail.files;
        for(var i=0; i<uploadedFiles.length; i++){
            this.totalUnremburisedFiles.push(uploadedFiles[i]);
        }
        if(this.totalUnremburisedFiles.length <= 10){
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
        else{
            this.deleteExtraFiles(uploadedFiles);
            this.handleUnrembusedFileLimit(uploadedFiles);
            this.showToast('Error!', this.customLabelValues.OWC_file_size_error,'error');
        }
    }

    handleUnrembusedFileLimit(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            for(var j=0; j<this.totalUnremburisedFiles.length; j++){
                if(uploadedFiles[i].documentId === this.totalUnremburisedFiles[j].documentId){
                    this.totalUnremburisedFiles.splice(j , 1)
                }
            }
        }
    }

    updateUnrembusedFileVariables(){
        if(this.unreimbursedDoc !== undefined && this.unreimbursedDoc.length > 0){
            this.totalUnremburisedFiles.length = 0;
            this.totalUnremburisedFiles = this.unreimbursedDoc;
        }
    }

    handleUnreimbursedDocEvent(event){
        this.unreimbursedDoc = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.updateUnrembusedFileVariables();
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.unreimbursedDocSize = this.unreimbursedDoc.length
    }

    @api explainBonus;
    @api isExplain = false;

    isDateAcceptable = false;
    isclaimPeriodStartDate = false;
    isclaimPeriodEndDate = false;

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    handleWorkNotPaidValidityEvent(event){
        this.isChanged = val.currentStep
    }

    handleWageDefValidityEvent(){
        const selectEvent = new CustomEvent('wagedeficiencieschildvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isChanged = false;
        this.dispatchEvent(selectEvent);
    }

    handleOverTimeParentValidityCheck(event){
        this.isChanged = event.detail.currentStep;
    }

    handleSplitShiftValidity(event){
        this.isChanged = event.detail.currentStep;
    }

    handleSickLeaveParentValidityCheck(event){
        this.isChanged = event.detail.currentStep;
    }

    handleRestBreakParentValidityCheck(event){
        this.isChanged = event.detail.currentStep;
    }

    handleMealBreakParentValidityCheck(event){
        this.isChanged = event.detail.currentStep;
    }

    handleRestClaimParentValidityCheck(event){
        this.isChanged = event.detail.currentStep;
    }

    handleMileageClaimParentValidityCheck(event){
        this.isChanged = event.detail.currentStep;
    }

    handleFundClaimParentValidityCheck(event){
        this.isChanged = event.detail.currentStep;
    }

    handlePayClaimParentValidityCheck(event){
        this.isChanged = event.detail.currentStep;
    }

    handleEmployerWorkedValidity(event){
        this.isChanged = event.detail.currentStep;
    }

    handleWaitingValidityEvent(event){
        this.isChanged = event.detail.currentStep;
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

    @api splitShiftCaseIssueObj
    @api splitShiftDetails
    @api renderSplitShiftSectionData
    handleSplitShiftInfoEvent(event){
        const splitShiftDetails = event.detail.splitShiftDetails;
        const renderSplitShiftSectionData = event.detail.renderSplitShiftSectionData;
        const vtCaseIssueObj = event.detail.vtCaseIssueObj;
        this.splitShiftCaseIssueObj = vtCaseIssueObj;
        this.splitShiftDetails = splitShiftDetails;
        this.renderSplitShiftSectionData = renderSplitShiftSectionData;
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

    @api isShowClaimHeading = false;
    @api
    handleWageDeficienciesParentData(){

        if(this.isnotidentifyemployer === 'No'){
            this.template.querySelector('c-owc-Waiting-Time-Claim-Garment').handleWaitingTimeParent();
        }

        if(this.notPaidForWork === true && this.isFirstOptionTrue === true){
            const temp = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate-Garment');
            for(var i=0; i<temp.length; i++){
                temp[i].handleWageDeficienciesParent();
            }
        }

        if(this.paidbycheck === true){
            const temp = this.template.querySelectorAll('c-owc-Insufficient-Fund-Claim-Garment-Container');
            for(var i=0; i<temp.length; i++){
                temp[i].handleSickLeaveTimeParent();
            }
        }

        if(this.noOvertimePaid === true && this.isSecondOptionTrue === true){
            this.template.querySelector('c-owc-Over-Time-Or-Double-Time-Garment-Def').handleOverTimeOrDoubleTimeParent();
        }

        if(this.noSickLeavePaid === true && this.isThirdOptionTrue === true){
            this.template.querySelector('c-owc-Not-Paid-Sick-Leave-Garment-Container').handleSickLeaveTimeParent();
        }

        if(this.notAllowedBathBreak === true && this.isSixthOptionTrue === true){
            this.template.querySelector('c-owc-Not-Allowed-Rest-Break-Garment-Container').handleSickLeaveTimeParent();
        }

        if(this.notAllowedMealBreak === true && this.isSeventhOptionTrue === true){
            this.template.querySelector('c-owc-Not-Allowed-For-Meal-Break-Garment-Container').handleSickLeaveTimeParent();
        }

        if((this.notAllowedForHeatRest === true && this.isEightOptionTrue === true) || this.isHeatRestDef === true){
            this.template.querySelector('c-owc-Not-Allowed-Heat-Rest-Garment-Container').handleSickLeaveTimeParent();
        }

        if(this.deniedPaymentMilega === true && this.isTwelveOptionTrue === true){
            this.template.querySelector('c-owc-Denied-Milega-Pay-Garment-Container').handleSickLeaveTimeParent();
        }


        if(this.reportedToWork === true && this.isEighteenOptionTrue === true){
            this.template.querySelector('c-owc-Reporting-Time-Pay-Claim-Garment-Container').handleSickLeaveTimeParent();
        }
        if(this.garmentWageClaim === true && this.isNinteenOptionTrue === true){
            this.template.querySelector('c-O-W-C-Garment-Employee-Option-Cmp').owcGaremntEmpDataForParent();
        }

        if(this.employerDeniedWork === true && this.isSixteenOptionTrue === true){
            this.template.querySelector('c-owc-Split-Shift-Premium-Garment-Container').handleSickLeaveTimeParent();
        }

        if(this.deniedPersonnelFile === true || this.employerDeniedWork === true || this.productionBonus === true || this.reportedToWork === true || this.garmentWageClaim === true || this.isHeatRestDef === true || this.isWrittenStatement === true || this.isLatePayroll === true || this.paidbycheck === true || this.showWaitingTimeClaim === true || this.isFirstOptionTrue === true || this.isSecondOptionTrue === true || this.isThirdOptionTrue === true || this.isFourthOptionTrue === true || this.isFifthOptionTrue === true || this.isSixthOptionTrue === true || this.isSeventhOptionTrue === true || this.isEightOptionTrue === true || this.isNinethOptionTrue === true || this.isTenthOptionTrue === true || this.isEleventhOptionTrue === true || this.isTwelveOptionTrue === true || this.isThirteenthOptionTrue === true || this.isFouteenOptionTrue === true || this.anotherClaimExplain !== undefined){
            this.isShowClaimHeading = true
        }
        else{
            this.isShowClaimHeading = false
        }
        this.isChanged === true ? this.handleWageDefValidityEvent() : this.wageDeficienciesParentObj();

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
        // Boolean(this.vtCaseIssueList) && this.vtCaseIssueList.length > 0 ? this.vtCaseIssueList.length = 0 : '';
        this.prepareVtCaseIssueJSON()
        const selectEvent = new CustomEvent('wagedeficienciescustomobjevent', {
            detail:{
                wageDefInfoObj: this.wageDefInfoObj(),
                vtCaseIssues : this.vtCaseIssueList,
                overTimeCaseIssueObj : this.overTimeCaseIssueObj
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
                vtCaseIssues : this.vtCaseIssueList,
                overTimeCaseIssueObj : this.overTimeCaseIssueObj
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
        
        if(this.splitShiftCaseIssueObj !== undefined && this.splitShiftCaseIssueObj.length > 0){
            for(var i=0; i<this.splitShiftCaseIssueObj.length; i++){
                var splitCaseList = []
                var splitCaseId;
                if(this.splitShiftCaseIssueObj[i].violationTypeVariablesForOneHourlyForMin !== undefined){
                    if(this.splitShiftCaseIssueObj[i].violationTypeVariablesForOneHourlyForMin.length > 0){
                        for(var j=0; j<this.splitShiftCaseIssueObj[i].violationTypeVariablesForOneHourlyForMin.length; j++){
                            splitCaseId = this.splitShiftCaseIssueObj[i].violationTypeVariablesForOneHourlyForMin[j].violationTypeId;
                            splitCaseList.push(this.splitShiftCaseIssueObj[i].violationTypeVariablesForOneHourlyForMin[j]);
                        }
                        this.vtCaseIssueList.push({ "violationTypeId" : splitCaseId , "violationVariables": splitCaseList})
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

        var writtenList = []
        var writtenIssueId
        if(this.violationTypeVariablesForWrittenStatement !== undefined && this.violationTypeVariablesForWrittenStatement.length > 0){
            for(var i=0; i<this.violationTypeVariablesForWrittenStatement.length; i++){
                writtenIssueId = this.violationTypeVariablesForWrittenStatement[i].violationTypeId;
                writtenList.push(this.violationTypeVariablesForWrittenStatement[i]);
            }
            this.vtCaseIssueList.push({ "violationTypeId" : writtenIssueId , "violationVariables": writtenList})
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
                this.violationTypeVariablesForSeverancePay[i].name === 'VTV2352' ? this.violationTypeVariablesForSeverancePay[i].value = this.totalAmountPaid !== undefined ? this.totalAmountPaid : '' : ''
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
            isNinteenOptionTrue : this.isNinteenOptionTrue,
            garmentEmpDetails : this.garmentEmpDetails,
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
            garmentWageClaim : this.garmentWageClaim,
            renderPayClaimSection : this.renderPayClaimSection,
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
            totalAmountPaid : this.totalAmountPaid,
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
            isShowClaimHeading : this.isShowClaimHeading,
            paidbycheck : this.paidbycheck,
            werewagespaid : this.werewagespaid,
            isLatePayroll : this.isLatePayroll,
            splitShiftDetails : this.splitShiftDetails,
            renderSplitShiftSectionData : this.renderSplitShiftSectionData,
            totalVacationFiles : this.totalVacationFiles,
            totalUnremburisedFiles : this.totalUnremburisedFiles,
            isSeverancePayTrue : this.isSeverancePayTrue,
            flag : this.flag
        }
    }

    @api strString1
    @api
    handleWageDeficienciesChildData(strString, isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode
        this.wageDeficiencyPreviewDetail = strString
        this.claimPeriodStartDate = strString.claimPeriodStartDate
        this.claimPeriodEndDate = strString.claimPeriodEndDate
        this.notPaidForWork = strString.notPaidForWork
        this.showOneHourlyRateTemplate = strString.showOneHourlyRateTemplate
        this.isOneHourlyRate = strString.isOneHourlyRate
        this.isFirstOptionTrue = strString.isFirstOptionTrue
        this.workNotPaidData = strString.workNotPaidData
        this.isWrittenStatement = strString.isWrittenStatement
        this.isHeatRestDef = strString.isHeatRestDef
        this.isNinteenOptionTrue = strString.isNinteenOptionTrue
        this.garmentWageClaim = strString.garmentWageClaim
        this.garmentEmpDetails = strString.garmentEmpDetails
        this.isShowClaimHeading = strString.isShowClaimHeading
        this.violationTypeVariablesForSeverancePay = strString.violationTypeVariablesForSeverancePay
        this.isSeverancePays = strString.isSeverancePays
        this.strString1 = strString.renderWorkedNotPaidSection
        this.paidbycheck = this.paidbycheck !== undefined ? this.paidbycheck : strString.paidbycheck
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
        this.werewagespaid = this.werewagespaid !== undefined ? this.werewagespaid : strString.werewagespaid
        this.isLatePayroll = this.werewagespaid === true ? this.isLatePayroll = true : this.isLatePayroll = false
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
        this.isEmployeeWorkedDateValid = this.isEmployeeWorkedDateValid === true ? true : false;
        this.vacationTimeClaimDetails = strString.vacationTimeClaimDetails === undefined ? [] : strString.vacationTimeClaimDetails;
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
        this.unreimbursedDoc = strString.unreimbursedDoc === undefined ? [] : strString.unreimbursedDoc,
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
        this.totalAmountPaid = strString.totalAmountPaid
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
        this.splitShiftDetails = strString.splitShiftDetails
        this.renderSplitShiftSectionData = strString.renderSplitShiftSectionData
        this.totalVacationFiles = strString.totalVacationFiles
        this.totalUnremburisedFiles = strString.totalUnremburisedFiles
        this.isSeverancePayTrue = strString.isSeverancePayTrue
        this.isRenderedCallback = true;
    }

    @api paymentOfWagesDetails
    @api
    handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
        this.paymentOfWagesDetails = paymentOfWagesDetails;
        this.isFormPreviewMode = isFormPreviewMode;
        const temp = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate-Garment');
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

    handleHelpText(event){
        const hpt = event.target.name;
        if(hpt === 'reportHp'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_report_hpt;
        }
        else if(hpt === 'reportGarmentEmp'){
            this.isHelpText = true;
            this.helpText = customLabelValues.owc_garmentEmpHelpText;            
        }
        else if(hpt === 'checkDecHp'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_pay_hp;
        }
        else if(hpt === 'shareHp'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_share_hpt;
        }
        else if(hpt === 'sevHelp'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_hpt;
        }
        else if(hpt === 'vacationHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_vacation_helpText;
        }
        else if(hpt === 'regularClaimHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_regular_claim_helptext;
        }
        else if(hpt === 'sickLeaveOptionHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_sick_leave_helptext;
            this.issickleavehelptext = true;
        }
        else if(hpt === 'otOrDtClaimHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_OT_DT_claim_helptext;
        }
        else if(hpt === 'multiFileUploadHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_multiplefileupload_helptext;
        }
        else if(hpt === "deniedPayroll"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_denied_payroll_helptext;
        }
        else if(hpt === 'deniedPersonalFile'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_denied_personnel_file_label;
        }
        else if(hpt === "vacationTimeTotalHourHelpMsg"){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_vacation_time_final_rate;
        }
        else if(hpt === 'vacationTimeClaim'){
            this.isHelpText = true;
            this.isdlse55Available = null;
            this.helpText = customLabelValues.OWC_typically_worked_vacationtimeclaims_helptext;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        }
        else if(hpt === "unreimbursedBusiness"){
            this.isHelpText = true;
            this.isdlse55Available = null;
            this.helpText = customLabelValues.OWC_typically_worked_unreimbursed_business_helptext;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        } 
        else if(hpt === 'deniedPaymentText'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_mileage_denied_helptext;
        }   
        else if(hpt === "listedClaimHelptext"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_select_one_checkbox_label;
        }
        else if(hpt === 'productionBonus'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_production_bonus_helptext;
        }    
        else if(hpt === 'paymentDenied'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_business_denied_helptext;
        }
        else if(hpt === 'holidayHelpText'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_holiday_helptext;
        }
        else if(hpt === 'restBreakHelpText'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_rest_break_helptext;
        }
        else if(hpt === 'mealBreakHelp'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_meal_help;
        }
        else if(hpt === 'heatHelp'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_heat_help;
        }
    }
  
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    @api vacationTimeClaimDetails = []
    @api isVacationTimeClaimUpload = false;
    @api vacationTimeClaimSize;
    @api totalVacationFiles = []

    @track contentVersionIds = []
    deleteExtraFiles(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            this.contentVersionIds.push(uploadedFiles[i].documentId);
        }
        deleteMultipleFiles({ contentVersionIds : JSON.stringify(this.contentVersionIds) })
           .then(result => {
               if(result){
                   
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
    }

    @api get isVacationFileUpload(){
        return this.vacationTimeClaimDetails.length >= 10 
    }

    @api get isUnremburisedFileUpload(){
        return this.unreimbursedDoc.length >= 10;
    }

    @track contentVersionIds = []
    deleteExtraFiles(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            this.contentVersionIds.push(uploadedFiles[i].documentId);
        }
        deleteMultipleFiles({ contentVersionIds : JSON.stringify(this.contentVersionIds) })
           .then(result => {
               if(result){
                   
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
    }

    handleVacationTimeClaimDoc(event){
        const uploadedFiles = event.detail.files;
        for(var i=0; i<uploadedFiles.length; i++){
            this.totalVacationFiles.push(uploadedFiles[i]);
        }
        if(this.totalVacationFiles.length <= 10){
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
        else{
            this.deleteExtraFiles(uploadedFiles);
            this.handleFileLimit(uploadedFiles);
            this.showToast('Error!', this.customLabelValues.OWC_file_size_error,'error');
        }
    }

    handleFileLimit(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            for(var j=0; j<this.totalVacationFiles.length; j++){
                if(uploadedFiles[i].documentId === this.totalVacationFiles[j].documentId){
                    this.totalVacationFiles.splice(j , 1)
                }
            }
        }
    }

    updateVacationFileVariables(){
        if(this.vacationTimeClaimDetails !== undefined && this.vacationTimeClaimDetails.length > 0){
            this.totalVacationFiles.length = 0;
            this.totalVacationFiles = this.vacationTimeClaimDetails;
        }
    }

    handleVacationTimeClaimEvent(event){
        this.vacationTimeClaimDetails = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.updateVacationFileVariables();
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
        if(this.isRenderedCallback === true && this.werewagespaid !== undefined && this.isLatePayroll === true){
            this.handleLatePayrollServerCall();
        }
        if(this.isRenderedCallback === true && this.isHolidayPayClaim === true && this.isSeverancePays === true){
            this.callHolidayServer();
        }
        if(this.isRenderedCallback === true && this.isSeverancePayTrue === true && this.isSeverancePays === true){
            this.callSeverancePayIssue();
        }
        if((this.quitdate !== undefined || this.dischargeddate !== undefined) && this.notPaidForVacationTime === true && this.isRenderedCallback === true){
            this.handleServerCall();
            this.isEmployeeWorkedDateValid = true;
        }
        if(this.isWorkedNotPaidSectionDeleted === true){
            const wageDefDetails = this.workedNotPaidSectionDataAfterDelete
            const wageDefSectionDetails = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate-Garment')
            for (let i = 0; i < wageDefSectionDetails.length; i++){
                wageDefSectionDetails[i].handleWageDeficienciesChild(wageDefDetails[i])
            }
            this.isWorkedNotPaidSectionDeleted = false
        }
        if(this.noOvertimePaid === true && this.isSecondOptionTrue === true){
            this.template.querySelector('c-owc-Over-Time-Or-Double-Time-Garment-Def').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.noSickLeavePaid === true && this.isThirdOptionTrue === true){
            this.template.querySelector('c-owc-Not-Paid-Sick-Leave-Garment-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.notAllowedBathBreak === true && this.isSixthOptionTrue === true){
            this.template.querySelector('c-owc-Not-Allowed-Rest-Break-Garment-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.notAllowedMealBreak === true && this.isSeventhOptionTrue === true){
            this.template.querySelector('c-owc-Not-Allowed-For-Meal-Break-Garment-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if((this.notAllowedForHeatRest === true && this.isEightOptionTrue === true)){
            this.template.querySelector('c-owc-Not-Allowed-Heat-Rest-Garment-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.employerDeniedWork === true && this.isSixteenOptionTrue === true){
            this.template.querySelector('c-owc-Split-Shift-Premium-Garment-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.employerDeniedWork === true && this.splitShiftDetails !== undefined){
            this.template.querySelector('c-owc-Split-Shift-Premium-Garment-Container').handleSplitShiftChildInfo(this.splitShiftDetails, this.renderSplitShiftSectionData, this.isFormPreviewMode);
        }
        if(this.isnotidentifyemployer === 'No' && this.waitingTimeDetails !== undefined){
            this.template.querySelector('c-owc-Waiting-Time-Claim-Garment').handleWaitingInfoChild(this.waitingTimeDetails, this.isFormPreviewMode);
        }
        if(this.reportedToWork === true && this.isEighteenOptionTrue === true){
            this.template.querySelector('c-owc-Reporting-Time-Pay-Claim-Garment-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.garmentWageClaim === true && this.isNinteenOptionTrue === true){
            console.log('garmentEmpDetails::::',this.garmentEmpDetails);
            console.log('isNinteenOptionTrue::::',this.isNinteenOptionTrue);
            console.log('garmentWageClaim::::',this.garmentWageClaim);
            this.template.querySelector('c-O-W-C-Garment-Employee-Option-Cmp').owcGarmentEmpDataForChild(this.garmentEmpDetails, this.isFormPreviewMode);
        }
        if(this.noOvertimePaid === true && this.overTimeDetails !== undefined){
            this.template.querySelector('c-owc-Over-Time-Or-Double-Time-Garment-Def').overTimeParentInfoSectionChild(this.overTimeDetails, this.renderOverTimeSection, this.isFormPreviewMode);
        }
        if(this.noSickLeavePaid === true && this.sickLeaveDetails !== undefined){
            this.template.querySelector('c-owc-Not-Paid-Sick-Leave-Garment-Container').overTimeParentInfoSectionChild(this.sickLeaveDetails, this.renderSickLeaveSection, this.isFormPreviewMode);
        }
        if(this.notAllowedBathBreak === true && this.restBreakDetails !== undefined){
            this.template.querySelector('owc-Not-Allowed-Rest-Break-Container').overTimeParentInfoSectionChild(this.restBreakDetails, this.renderRestBreakSection, this.isFormPreviewMode);
        }
        if(this.notAllowedMealBreak === true && this.mealBreakDetails !== undefined){
            this.template.querySelector('c-owc-Not-Allowed-For-Meal-Break-Garment-Container').overTimeParentInfoSectionChild(this.mealBreakDetails, this.renderMealBreakSection, this.isFormPreviewMode);
        }
        if((this.notAllowedForHeatRest === true && this.restClaimDetails !== undefined)){
            this.template.querySelector('c-owc-Not-Allowed-Heat-Rest-Garment-Container').overTimeParentInfoSectionChild(this.restClaimDetails, this.renderRestClaimSection, this.isFormPreviewMode);
        }
        
        if(this.deniedPaymentMilega === true && this.mileageClaimDetails !== undefined){
            this.template.querySelector('c-owc-Denied-Milega-Pay-Garment-Container').overTimeParentInfoSectionChild(this.mileageClaimDetails, this.renderMilegaClaimSection, this.isFormPreviewMode);
        }
        if(this.paidbycheck === true && this.fundClaimDetails !== undefined){
            this.template.querySelector('c-owc-Insufficient-Fund-Claim-Garment-Container').overTimeParentInfoSectionChild(this.fundClaimDetails, this.renderFundClaimSection, this.isFormPreviewMode);
        }
        if(this.reportedToWork === true && this.payClaimDetails !== undefined){
            this.template.querySelector('c-owc-Reporting-Time-Pay-Claim-Garment-Container').overTimeParentInfoSectionChild(this.payClaimDetails, this.renderPayClaimSection, this.isFormPreviewMode);
        }
        if(this.isRenderedCallback === true){
            const workNotPaidData = this.workNotPaidData
            const details = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate-Garment')
            for (let i = 0; i < details.length; i++){
                details[i].handleWageDeficienciesChild(workNotPaidData[i],this.isFormPreviewMode)
            }
            this.workNotPaidData = []
        }
        this.isRenderedCallback = false;
    }
}