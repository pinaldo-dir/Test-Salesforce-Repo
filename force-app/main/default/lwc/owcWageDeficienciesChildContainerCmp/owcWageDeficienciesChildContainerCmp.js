import { LightningElement, api ,track, wire } from 'lwc';
import { radioOptions, acceptedFileFormat, customLabelValues } from 'c/owcUtils';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
import { loadStyle } from 'lightning/platformResourceLoader'; 
import deleteMultipleFiles from '@salesforce/apex/OWCMultipleFileDeleteController.deleteMultipleFiles';
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { Utils} from './owcWageDeficienciesChildContainerCmpfunction';
//import { handleHelpText } from './owcWageDeficienciesChildContainerCmpfunction';
export default class OwcWageDeficienciesChildContainerCmp extends Utils(LightningElement) {
    @track fileNames = '';
    @api is_wage_def_garment_claim
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
    @api garmentWageClaim = false;
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
    @api isNoOptionSelected = false;
    @api isRequiredField = false;
    flag = 0
    flag1 = 1
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
    get acceptedFormats() {
        return acceptedFileFormat;
    }
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`
    customLabelValues = customLabelValues    
    connectedCallback(){
        console.log('is_wage_def_garment_claim ::: ', this.is_wage_def_garment_claim)
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
        });
        this.paymentOfWagesDetails = this.powdetails
        this.empstatementprovided === 'No' ? this.handleWrittenStatement() : this.violationTypeVariablesForWrittenStatement !== undefined ? this.violationTypeVariablesForWrittenStatement.length = 0 : ''
        this.heatrecovery === 'No' ? this.notAllowedForHeatRest = true : this.notAllowedForHeatRest = false;
        this.heatrecovery === 'No' ? this.isEightOptionTrue = true : this.isEightOptionTrue = false;
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
                    result[i].name === "VTV0107" ? result[i].isRequiredField = false : result[i].isRequiredField = true;
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
                    result[i].name === 'VTV0095' || result[i].name === 'VTV0094' ? result[i].isRequiredField = true : ''
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
                    this.hideSpinner();
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
    @api isDateAcceptable = false;
    @api
    handleRequiredField(FieldId){
        var FieldId = FieldId
        if(FieldId.value == null || FieldId.value == undefined || FieldId.value.trim() == ''){
            FieldId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            FieldId.reportValidity();
            return true;
        }
        else{
            FieldId.setCustomValidity('');
            FieldId.reportValidity();
            return false
        }
    }

    /* This method is used to check all types of validation on the date fields. */
    handleDateValidity(startDateId, endDateId, startDate, endDate){
        var startDateId = startDateId
        var endDateId = endDateId
        var startDate = startDate
        var endDate = endDate
        var today = new Date();

        startDate !== '' ? startDate = new Date(startDate.toString()) : ''

        endDate !== '' ? endDate = new Date(endDate.toString()) : ''
        if(startDate === '' && endDate === ''){
            startDateId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            endDateId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            startDateId.reportValidity();
            endDateId.reportValidity();
            return true;
        }

        else if((startDate === '' && endDate !== '') || (startDate !== '' && endDate === '')){
            startDateId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            endDateId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            endDateId.reportValidity();
            return true;
        }
        
        // Check startDate is greater than today's date
        else if(startDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            startDateId.setCustomValidity(customLabelValues.OWC_pastdate_error_msg)
            startDateId.reportValidity()
            return true;
        }

        // Check endDate is greater than today's date
        else if(endDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            endDateId.setCustomValidity(customLabelValues.OWC_pastdate_error_msg)
            endDateId.reportValidity()
            return true;
        }

        // check startDate is greater than endDate
        else if(startDate > endDate){
            startDateId.setCustomValidity(customLabelValues.OWC_begdate_error_msg)
            endDateId.setCustomValidity(customLabelValues.OWC_enddate_error_msg)
            endDateId.reportValidity()
            startDateId.reportValidity()
            return true;
        }

        else{
            startDateId.setCustomValidity('')
            endDateId.setCustomValidity('')
            startDateId.reportValidity();
            endDateId.reportValidity();
            return false;
        }

    }
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
    @api garmentEmpDetails;
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
    handleGaremtEmpParentInfo(event){
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
        if(this.isLatePayroll === true){
            this.handleRequiredField(this.template.querySelector('[data-id="VTV4443"]') ) || this.handleRequiredField(this.template.querySelector('[data-id="VTV4444"]') ) ? this.isChanged = true : ''
            this.handleDateValidity(this.template.querySelector('[data-id="VTV4443"]'),this.template.querySelector('[data-id="VTV4444"]'),this.template.querySelector('[data-id="VTV4443"]').value, this.template.querySelector('[data-id="VTV4444"]').value ) ? this.isChanged = true : ''
        }
        if(this.notPaidForHoliday === true && this.isFifthOptionTrue === true){
            this.handleRequiredField(this.template.querySelector('[data-id="holidayPay"]') ) ? this.isChanged = true : ''
        }
        if(this.deniedBusinessCost === true && this.isEleventhOptionTrue === true){
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0106"]')) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0108"]')) ? this.isChanged = true : ''
            this.handleDateValidity(this.template.querySelector('[data-id="VTV0104"]'),this.template.querySelector('[data-id="VTV0105"]'),this.template.querySelector('[data-id="VTV0104"]').value,this.template.querySelector('[data-id="VTV0105"]').value) ? this.isChanged = true : ''
        }
        if(this.deniedPayrollInfo === true && this.isFouteenOptionTrue === true){
            this.handleRequiredField(this.template.querySelector('[data-id="payrollDemandDate"]') ) || this.handleRequiredField(this.template.querySelector('[data-id="employerResponse"]') ) ? this.isChanged = true : ''
        }
        if(this.deniedShareTips === true && this.isTenthOptionTrue === true){
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0100"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0101"]') ) ? this.isChanged = true : ''
            this.handleDateValidity(this.template.querySelector('[data-id="VTV0100"]'),this.template.querySelector('[data-id="VTV0101"]'),this.template.querySelector('[data-id="VTV0100"]').value, this.template.querySelector('[data-id="VTV0101"]').value ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0102"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0103"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="claimPoolTips"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="claimTipReceived"]') ) ? this.isChanged = true : ''
        }
        if(this.paycheckDeduction === true && this.isThirteenthOptionTrue === true){
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0096"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0097"]') ) ? this.isChanged = true : ''
            this.handleDateValidity(this.template.querySelector('[data-id="VTV0096"]'),this.template.querySelector('[data-id="VTV0097"]'),this.template.querySelector('[data-id="VTV0096"]').value, this.template.querySelector('[data-id="VTV0097"]').value ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0098"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0099"]') ) ? this.isChanged = true : ''
        }
        if(this.productionBonus === true && this.isSeventeenOptionTrue === true){
            this.handleDateValidity(this.template.querySelector('[data-id="VTV0057"]'),this.template.querySelector('[data-id="VTV0058"]'),this.template.querySelector('[data-id="VTV0057"]').value, this.template.querySelector('[data-id="VTV0058"]').value ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0059"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0060"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0061"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="additionalClaimEarn"]') ) ? this.isChanged = true : ''
        }
        if(this.notPaidForVacationTime === true && this.isFourthOptionTrue === true){
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0094"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="VTV0095"]') ) ? this.isChanged = true : ''
        }

        if(this.notPaidSeverancePay === true && this.isNinethOptionTrue === true)  {
            this.handleRequiredField(this.template.querySelector('[data-id="serverancePay"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="severancePayOffered"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="totalAmountPaid"]') ) ? this.isChanged = true : ''

        }
        if(this.deniedPersonnelFile === true && this.isFifteenOptionTrue === true){
            this.handleRequiredField(this.template.querySelector('[data-id="personalFileDemandDate"]') ) ? this.isChanged = true : ''
            this.handleRequiredField(this.template.querySelector('[data-id="personalEmployerResponse"]') ) ? this.isChanged = true : ''
        }

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
        if(this.employerDeniedWork === true && this.isSixteenOptionTrue === true){
            this.template.querySelector('c-owc-Split-Shift-Premium-Container').handleSickLeaveTimeParent();
        }
        if(this.deniedPersonnelFile === true || this.employerDeniedWork === true || this.productionBonus === true || this.reportedToWork === true || this.garmentWageClaim === true || this.isHeatRestDef === true || this.isWrittenStatement === true || this.isLatePayroll === true || this.paidbycheck === true || this.showWaitingTimeClaim === true || this.isFirstOptionTrue === true || this.isSecondOptionTrue === true || this.isThirdOptionTrue === true || this.isFourthOptionTrue === true || this.isFifthOptionTrue === true || this.isSixthOptionTrue === true || this.isSeventhOptionTrue === true || this.isEightOptionTrue === true || this.isNinethOptionTrue === true || this.isTenthOptionTrue === true || this.isEleventhOptionTrue === true || this.isTwelveOptionTrue === true || this.isThirteenthOptionTrue === true || this.isFouteenOptionTrue === true || (this.anotherClaimExplain != undefined && this.anotherClaimExplain != null && this.anotherClaimExplain.trim() != '')){
            this.isShowClaimHeading = true
            this.isNoOptionSelected = false
        }
        else{
            this.isShowClaimHeading = false
            this.isNoOptionSelected = true
        }

        if(this.isChanged === true || this.isNoOptionSelected === true ){
            this.handleWageDefValidityEvent();
        }
        else{

            if(this.isnotidentifyemployer === 'No'){
                this.template.querySelector('c-owc-Waiting-Time-Claim').handleEmployerParentInfo();
            } 

            if(this.notPaidForWork === true && this.isFirstOptionTrue === true){
                const temp = this.template.querySelectorAll('c-owc-Wage-Deficiencies-For-Hourly-Rate');
                for(var i=0; i<temp.length; i++){
                    temp[i].handleWageDeficienciesParentInfoData();
                }
            }

            if(this.paidbycheck === true){
                const temp = this.template.querySelectorAll('c-owc-Insufficient-Fund-Claim-Container');
                for(var i=0; i<temp.length; i++){
                    temp[i].handleSickLeaveTimeParent2();
                }
            }

            if(this.noOvertimePaid === true && this.isSecondOptionTrue === true){
                this.template.querySelector('c-owc-Over-Time-Or-Double-Time-Container-Def').handleOverTimeOrDoubleTimeParent2();
            }

            if(this.noSickLeavePaid === true && this.isThirdOptionTrue === true){
                this.template.querySelector('c-owc-Not-Paid-Sick-Leave-Container').handleSickLeaveTimeParent2();
            }

            if(this.notAllowedBathBreak === true && this.isSixthOptionTrue === true){
                this.template.querySelector('c-owc-Not-Allowed-Rest-Break-Container').handleSickLeaveTimeParent2();
            }

            if(this.notAllowedMealBreak === true && this.isSeventhOptionTrue === true){
                this.template.querySelector('c-owc-Not-Allowed-For-Meal-Break-Container').handleSickLeaveTimeParent2();
            }

            if((this.notAllowedForHeatRest === true && this.isEightOptionTrue === true) || this.isHeatRestDef === true){
                this.template.querySelector('c-owc-Not-Allowed-Heat-Rest-Container').handleSickLeaveTimeParent2();
            }

            if(this.deniedPaymentMilega === true && this.isTwelveOptionTrue === true){
                this.template.querySelector('c-owc-Denied-Milega-Pay-Container').handleSickLeaveTimeParent2();
            }

            if(this.reportedToWork === true && this.isEighteenOptionTrue === true){
                this.template.querySelector('c-owc-Reporting-Time-Pay-Claim-Container').handleSickLeaveTimeParent2();
            }
 
            if(this.garmentWageClaim === true && this.isNinteenOptionTrue === true){
                this.template.querySelector('c-O-W-C-Garment-Employee-Option-Cmp').owcGaremntEmpDataForParent();
            }

            if(this.employerDeniedWork === true && this.isSixteenOptionTrue === true){
                this.template.querySelector('c-owc-Split-Shift-Premium-Container').handleSickLeaveTimeParent2();
            }

            this.wageDeficienciesParentObj();
        }
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
            garmentWageClaim : this.garmentWageClaim,
            isEighteenOptionTrue : this.isEighteenOptionTrue,
            isNinteenOptionTrue : this.isNinteenOptionTrue,
            payClaimDetails : this.payClaimDetails,
            garmentEmpDetails : this.garmentEmpDetails,
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
            isNoOptionSelected : this.isNoOptionSelected,
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
        this.garmentWageClaim = strString.garmentWageClaim
        this.isEighteenOptionTrue = strString.isEighteenOptionTrue
        this.isNinteenOptionTrue = strString.isNinteenOptionTrue
        this.payClaimDetails = strString.payClaimDetails
        this.garmentEmpDetails = strString.garmentEmpDetails
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
        this.isNoOptionSelected = strString.isNoOptionSelected
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
        if(this.employerDeniedWork === true && this.isSixteenOptionTrue === true){
            this.template.querySelector('c-owc-Split-Shift-Premium-Container').handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.employerDeniedWork === true && this.splitShiftDetails !== undefined){
            this.template.querySelector('c-owc-Split-Shift-Premium-Container').handleSplitShiftChildInfo(this.splitShiftDetails, this.renderSplitShiftSectionData, this.isFormPreviewMode);
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
        this.isRenderedCallback = false;
    }
}