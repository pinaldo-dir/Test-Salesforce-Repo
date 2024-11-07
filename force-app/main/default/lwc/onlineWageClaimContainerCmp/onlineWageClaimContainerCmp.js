import { LightningElement, api, wire, track } from 'lwc';
import { customLabelValues } from 'c/owcUtils';
import pubsub from 'c/pubsub' ; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityBasePath from '@salesforce/community/basePath';
import onlineClaimSubmit from '@salesforce/apex/OnlineWageClaimContainerController.onlineClaimSubmit';
import generatePDF from '@salesforce/apex/OnlineWageClaimContainerController.generatePDF';
import deleteCaseRecord from '@salesforce/apex/OnlineWageClaimContainerController.deleteCaseRecord';
import createOWCJSONResponse from '@salesforce/apex/OWCSaveDraftController.createOWCJSONResponse';
import getOWCJSONResponse from '@salesforce/apex/OWCSaveDraftController.getOWCJSONResponse';
import getMinimumWageRec from '@salesforce/apex/OWCWageDeficienciesController.getMinimumWageRec';
import getIWCInfo from '@salesforce/apex/OWCWageDeficienciesController.getIWCInfo';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';  // Run time style loader
import { NavigationMixin } from 'lightning/navigation';

import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
export default class OnlineWageClaimContainerCmp extends LightningElement {
    @track currentStep = '0';
    claimantEmployeeValues
    claimFiledSectionValues
    @api industryInfoDataValues
    @api isSpinner = false;
    @api isShowSpinner = false
    @api WageClaimSubmitVal
    @api isFirstCmpRender = false
    @api isThirdCmpRender = false
    @api isSecondCmpRender = false
    @api isFourthCmpRender = false
    @api isFifthCmpRender = false
    @api isSixthCmpRender = false
    @api isSeventhCmpRender = false
    @api isEighthCmpRender = false
    @api isNinethCmpRender = false
    @api isTenthCmpRender = false
    @api isEleventhCmpRender = false
    @api isTwelveCmpRender = false;
    @api isNotChangedCurrentStep = false
    @api employeesDetails = []
    @api isAdvocateGarment = false
    @api otherLocWorkInfo
    @api message = false;
    @api isOneHourlyRateSelected = false;
    @api isSalaryRateSelected = false;
    workWeekAndWorkDaysDetails
    successorDetails
    labelDetails
    wageDeficiencyDetails
    employeeStatusAndFinalClaimDetails
    certAndAuthDetails
    paymentOfWagesDetails
    renderEmpSection
    communityBasePath = communityBasePath
    draftJsonObj

    constructor() {
        super();
        
    }

    connectedCallback(){
        window.scrollTo(0,0);
        this.regiser();
        // don’t forget to load static resources in connectedCallback .
        Promise.all([
          ]) 
        // Promise.all([ 
        //     loadStyle(this, JSPDF + '/bootstrap.min.css' ), 
        // loadScript(this, JSPDF +'/html2pdf.bundle.js') ])
        .then(() => {
            console.log( 'Files loaded' );
        })
        .catch(error => {
            console.log( error.body.message );
    });

    const currentCommunityUrl = window.location.search
    console.log('currentCommunityUrl1 ::: '+currentCommunityUrl)
    const urlParams = new URLSearchParams(currentCommunityUrl);
    const recordId = urlParams.get('recordId')
    this.recordId = recordId;
    console.log('currentCommunityUrl ::: '+recordId)
    if(recordId != null){
        getOWCJSONResponse({
            recordId : recordId
        })
           .then(result => {
               if(result){
                   console.log('result ::: ', JSON.stringify(result.Draft_JSON__c))
                    this.currentStep = result.Section_Id__c;    
                    const finalResult = JSON.parse(result.Draft_JSON__c.replace(/&quot;/g,'"').replaceAll(/&copy;/g,'©').replaceAll(/&amp;/g,'&').replaceAll(/&lt;/g,'<').replaceAll(/&gt;/g,'>').replaceAll(/&#39;/g,"'"));
                    this.claimantEmployeeValues = finalResult.claimantEmployeeValues
                    this.industryInfoDataValues = finalResult.industryInfoDataValues
                    this.employeesDetails = finalResult.employeesDetails
                    this.renderEmpSection = finalResult.renderEmpSection
                    //this.successorDetails = finalResult.successorDetails
                    this.otherLocWorkInfo = finalResult.otherLocWorkInfo
                    this.employeeStatusAndFinalClaimDetails = finalResult.employeeStatusAndFinalClaimDetails
                    this.paymentOfWagesDetails = finalResult.paymentOfWagesDetails
                    this.hoursYouTypicallyWorkedDetails = finalResult.hoursYouTypicallyWorkedDetails
                    this.workWeekAndWorkDaysDetails = finalResult.workWeekAndWorkDaysDetails
                    this.wageDeficiencyDetails = finalResult.wageDeficiencyDetails
                    this.labelDetails = finalResult.labelDetails
                    this.certAndAuthDetails = finalResult.certAndAuthDetails
                    
                    this.currentStep === "1" ? this.isFirstCmpRender = true : this.isFirstCmpRender = false
                    this.currentStep === "2" ? this.isSecondCmpRender = true : this.isSecondCmpRender = false
                    this.currentStep === "3" ? this.isThirdCmpRender = true : this.isThirdCmpRender = false
                    this.currentStep === "4" ? this.isFourthCmpRender = true : this.isFourthCmpRender = false
                    this.currentStep === "5" ? this.isFifthCmpRender = true : this.isFifthCmpRender = false
                    this.currentStep === "6" ? this.isSixthCmpRender = true : this.isSixthCmpRender = false
                    this.currentStep === "7" ? this.isSeventhCmpRender = true : this.isSeventhCmpRender = false
                    this.currentStep === "8" ? this.isEighthCmpRender = true : this.isEighthCmpRender = false
                    this.currentStep === "9" ? this.isNinethCmpRender = true : this.isNinethCmpRender = false
                    this.currentStep === "10" ? this.isTenthCmpRender = true : this.isTenthCmpRender = false
                    this.currentStep === "11" ? this.isEleventhCmpRender = true : this.isEleventhCmpRender = false
                    //this.currentStep === "12" ? this.isTwelveCmpRender = true : this.isTwelveCmpRender = false
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
    }
    
    }

    regiser(){
        console.log("event registerd", this.communityBasePath);
        pubsub.register('selectedmenuitem',this.handleEvent.bind(this));
    }
    @api messagepbsb

    handleEvent(messageFromEvt){
       const currentCommunityUrl = this.communityBasePath;
        if(messageFromEvt == 'Dashboard'){
            window.open(currentCommunityUrl, '_self')
        }
        else if(messageFromEvt == 'Submitted Claim'){
            window.open(currentCommunityUrl, '_self')
        }else if(messageFromEvt == 'Draft Claim'){
            window.open(currentCommunityUrl, '_self')
        }else {
               
        }
        
        this.messagepbsb = messageFromEvt;
    }

    customLabels = customLabelValues
    get isStepZero(){
        return this.currentStep === "0";
    }
    get isStepOne() {
        return this.currentStep === "1";
    }
    get isStepTwo() {
        return this.currentStep === "2";
    }
    get isStepThree() {
        return this.currentStep === "3";
    }
    get isStepFour(){
        return this.currentStep === "4"
    }
    get isStepFifth(){
        return this.currentStep === "5"
    }
    get isStepSixth(){
        return this.currentStep === "6"
    }
    get isStepSeventh(){
        return this.currentStep === "7"
    }
    get isStepEight(){
        return this.currentStep === "8"
    }
    get isStepNine(){
        return this.currentStep === "9"
    }
    get isStepTenth(){
        return this.currentStep === "10"
    }
    get isStepEleventh(){
        return this.currentStep === "11"
    }
    get isStepTwelve(){
        return this.currentStep === "12"
    }
    get isEnableNext() {
        return this.currentStep != "11";
    }
    get isEnablePrev() {
        return this.currentStep != "0";
    }
    get isEnableFinish() {
        return this.currentStep === "11";
    }
    get isEnablePreview(){
        return this.currentStep === "11";
    }
    @api isIndustryClickPrev = false;

    @api isHideButtons = false;
    handleNext(event){
        switch ( this.currentStep ) {  
            case "0":
                // this.isNotChangedCurrentStep = false;
                // this.template.querySelector('c-owc-Preliminary-Section-Cmp').owcClaimantEmployeeDataForParent();
                this.handlerCmpRenderFun("1", true, false, false, false, false, false, false, false, false, false, false, false)
            break;
            case "1":
                this.isNotChangedCurrentStep = false;
                this.template.querySelector('c-owc-Preliminary-Section-Cmp').owcClaimantEmployeeDataForParent();
                this.isNotChangedCurrentStep === true ? this.isNotChangedCurrentStep = false : this.handlerCmpRenderFun("2", false, true, false, false, false, false, false, false, false, false, false, false)
            break;
            case "2":
                this.isIndustryClickPrev = false;
                this.template.querySelector('c-industry-info-Cmp').owcInformationDataForParent()
           
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false
            }
            else if(this.isClaimantAdvocate === true){
                this.handlerCmpRenderFun("12", false, false, false, false, false, false, false, false, false, false, false, true)
            }
            else {
                this.handlerCmpRenderFun("3", false, false, true, false, false, false, false, false, false, false, false, false)
            }  
            break;
            case "3":
                this.template.querySelector('c-owc-Emp-Business-Type-Container-Cmp').owcEmpDataForContainerParent(false);
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false
            }
            else{
                this.handlerCmpRenderFun("4", false, false, false, true, false, false, false, false, false, false, false, false)
            }
            break;
            case "4":
                this.template.querySelector('c-owc-Other-Work-Location-Section-Cmp').otherWorkLocationDetailsFromParent(false);
                // this.template.querySelector('c-owc-Successor-Section-Container-Cmp').successorSectionDetailsFromParent();
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false
            }
            else if(this.claimantEmployeeValues.WageClaimSubmit === 'Representative' && this.industryInfoDataValues.isLabelsInfo === true){
                this.handlerCmpRenderFun("10", false, false, false, false, false, false, false, false, false, true, false, false)
            }
            else{
                this.handlerCmpRenderFun("5", false, false, false, false, true, false, false, false, false, false, false, false)
            }
            break;
            case "5":
                // this.template.querySelector('c-owc-Other-Work-Location-Section-Cmp').otherWorkLocationDetailsFromParent();
                this.template.querySelector('c-owc-Employment-Status-And-Final-Wages-Cmp').owcEmpStatusAndWagesDataForParent();
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false
            }
            else{
                this.handlerCmpRenderFun("6", false, false, false, false, false, true, false, false, false, false, false, false)
            }
            break;
            case "6":
                // this.template.querySelector('c-owc-Employment-Status-And-Final-Wages-Cmp').owcEmpStatusAndWagesDataForParent();
                this.template.querySelector('c-owc-Payment-Of-Wages-Cmp').owcPaymentOfWagesFromParent();
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false
            }
            else{
                this.handlerCmpRenderFun("7", false, false, false, false, false, false, true, false, false, false, false, false)
            }
            break;
            case "7":
                
                // this.template.querySelector('c-owc-Payment-Of-Wages-Cmp').owcPaymentOfWagesFromParent();
                this.template.querySelector('c-owc-Workweek-And-Workday-Cmp').owcWorkWeekAndWorkDayForParent();
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false
            }
            else{
                this.handlerCmpRenderFun("8", false, false, false, false, false, false, false, true, false, false, false, false)
            }
            break;
            case "8":
                this.template.querySelector('c-owc-Hours-You-Typically-Worked-Cmp').owcHoursYouWorkedForParent();
                // this.template.querySelector('c-owc-Hours-You-Typically-Worked-Cmp').owcHoursYouWorkedForParent();
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false
            }
            else{
                this.handlerCmpRenderFun("9", false, false, false, false, false, false, false, false, true, false, false, false)
            }
            break;
            case "9":
                this.template.querySelector('c-owc-Wage-Deficiencies-Cmp').owcwageDeficienciesFromParent();
                // this.template.querySelector('c-owc-Workweek-And-Workday-Cmp').owcWorkWeekAndWorkDayForParent();
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false
            }
            else if(this.claimantEmployeeValues.WageClaimSubmit === 'Yourself' || this.claimantEmployeeValues.WageClaimSubmit === 'Representative'){
                this.handlerCmpRenderFun("12", false, false, false, false, false, false, false, false, false, false, false, true)
            }
            else{
                this.handlerCmpRenderFun("11", false, false, false, false, false, false, false, false, false, false, true, false)
            }
            case "10":
                this.template.querySelector('c-owc-Label-Section-Container-Cmp').labelSectionFromParent();
            // this.template.querySelector('c-owc-Wage-Deficiencies-Cmp').owcwageDeficienciesFromParent();
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false
            }
            else{
                this.handlerCmpRenderFun("5", false, false, false, false, true, false, false, false, false, false, false, false)
            }
            break;
            case "12":
                this.template.querySelector('c-owc-Online-Demographic-Cmp').owcOnlineDemographicForParent();
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false;
            }
            else{ 
                if(this.isClaimantAdvocate === true){
                    this.isHideButtons = true
                    console.log('isHideButtons:::',this.isHideButtons)
                }
                else{
                    this.isHideButtons = false
                    console.log('isHideButtons:::',this.isHideButtons)
                }
                this.handlerCmpRenderFun("11", false, false, false, false, false, false, false, false, false, false, true, false)
            }
            break;
            }
    }

    handlePrev(event){
        event.preventDefault();
        switch ( this.currentStep ) {  
            case "12":
                this.template.querySelector('c-owc-Online-Demographic-Cmp').owcOnlineDemographicForParent();
                if(this.isClaimantAdvocate === true){
                    this.handlerCmpRenderFun("2", false, true, false, false, false, false, false, false, false, false, false, false)
                }
                else{
                    this.handlerCmpRenderFun("9", false, false, false, false, false, false, false, false, true, false, false, false)
                }
                break;
            case "11":
                if(this.claimantEmployeeValues.WageClaimSubmit === 'Yourself' || this.claimantEmployeeValues.WageClaimSubmit === 'Representative'){
                    this.handlerCmpRenderFun("12", false, false, false, false, false, false, false, false, false, false, false, true)
                    this.template.querySelector('c-owc-Certification-And-Authorization-Cmp').certAndAuthInfoFromParent();
                }
                else{
                    this.handlerCmpRenderFun("9", false, false, false, false, false, false, false, false, true, false, false, false)
                    this.template.querySelector('c-owc-Certification-And-Authorization-Cmp').certAndAuthInfoFromParent();
                }
                break;
            case "10":
                this.handlerCmpRenderFun("4", false, false, false, true, false, false, false, false, false, false, false, false)
                this.template.querySelector('c-owc-Label-Section-Container-Cmp').labelSectionFromParent();
                break;
            case "9":
                this.handlerCmpRenderFun("8", false, false, false, false, false, false, false, true, false, false, false, false)
                this.template.querySelector('c-owc-Wage-Deficiencies-Cmp').owcwageDeficienciesFromParent();
                break;
            case "8":
                this.handlerCmpRenderFun("7", false, false, false, false, false, false, true, false, false, false, false, false)
                this.template.querySelector('c-owc-Hours-You-Typically-Worked-Cmp').owcHoursYouWorkedForParent();
                break;
            case "7":
                this.handlerCmpRenderFun("6", false, false, false, false, false, true, false, false, false, false, false, false)
                this.template.querySelector('c-owc-Workweek-And-Workday-Cmp').owcWorkWeekAndWorkDayForParent();
                break;
            case "6":
                this.handlerCmpRenderFun("5", false, false, false, false, true, false, false, false, false, false, false, false)
                this.template.querySelector('c-owc-Payment-Of-Wages-Cmp').owcPaymentOfWagesFromParent();
                break;
            case "5":
                if(this.claimantEmployeeValues.WageClaimSubmit === 'Representative' && this.industryInfoDataValues.isLabelsInfo === true){
                    this.handlerCmpRenderFun("10", false, false, false, false, false, false, false, false, false, true, false, false)
                    this.template.querySelector('c-owc-Employment-Status-And-Final-Wages-Cmp').owcEmpStatusAndWagesDataForParent();
                }
                else{
                    this.handlerCmpRenderFun("4", false, false, false, true, false, false, false, false, false, false, false, false)
                    this.template.querySelector('c-owc-Employment-Status-And-Final-Wages-Cmp').owcEmpStatusAndWagesDataForParent();
                }
                break;
            case "4":
                this.handlerCmpRenderFun("3", false, false, true, false, false, false, false, false, false, false, false, false)
                this.template.querySelector('c-owc-Other-Work-Location-Section-Cmp').otherWorkLocationDetailsFromParent(true);
                break;
            case "3":
                this.handlerCmpRenderFun("2", false, true, false, false, false, false, false, false, false, false, false, false)
                this.template.querySelector('c-owc-Emp-Business-Type-Container-Cmp').owcEmpDataForContainerParent(true);
                break;
            case "2":
                this.handlerCmpRenderFun("1", true, false, false, false, false, false, false, false, false, false, false, false)
                this.isIndustryClickPrev = true;
                this.template.querySelector('c-industry-info-Cmp').owcInformationDataForParent();
                break;
            case "1":
                this.handlerCmpRenderFun("0", false, false, false, false, false, false, false, false, false, false, false, false)
                this.template.querySelector('c-owc-Preliminary-Section-Cmp').owcClaimantEmployeeDataForParent(); 
                break;
        }
    }
    handlerCmpRenderFun(currentStep, isFirstCmpRender, isSecondCmpRender, isThirdCmpRender, isFourthCmpRender, isFifthCmpRender, isSixthCmpRender, isSeventhCmpRender, isEighthCmpRender, isNinethCmpRender, isTenthCmpRender, isEleventhCmpRender, isTwelveCmpRender){
        this.currentStep = currentStep;
        this.isFirstCmpRender = isFirstCmpRender
        this.isThirdCmpRender = isThirdCmpRender
        this.isSecondCmpRender = isSecondCmpRender
        this.isFourthCmpRender = isFourthCmpRender
        this.isFifthCmpRender = isFifthCmpRender
        this.isSixthCmpRender = isSixthCmpRender
        this.isSeventhCmpRender = isSeventhCmpRender
        this.isEighthCmpRender = isEighthCmpRender
        this.isNinethCmpRender = isNinethCmpRender
        this.isTenthCmpRender = isTenthCmpRender
        this.isEleventhCmpRender = isEleventhCmpRender
        this.isTwelveCmpRender = isTwelveCmpRender
    }

    // Check the currentStep if usps address match with user inputs
    handleUSPSAddressMatch(event){
        const currentStep = event.detail.currentStep;
        console.log('USPS Cureent Step1 ::: ', currentStep);
        currentStep === false ? this.currentStep = "2" : ""
        currentStep === false ? this.isSecondCmpRender = true : ''
    }

    handleUSPSAddressMatchForEmployer(event){
        const currentStep = event.detail.currentStep;
        console.log('USPS Cureent Step2 ::: ', currentStep);
        currentStep === false ? this.currentStep = "4" : ''
        currentStep === false ? this.isFourthCmpRender = true : '';
    }

    handleUSPSAddressMatchForOtherWorkLocation(event){
        const currentStep = event.detail.currentStep;
        console.log('USPS Cureent Step3 ::: ', currentStep);
        currentStep === false ? this.currentStep = "5" : ''
        currentStep === false ? this.isFifthCmpRender = true : '';
    }

    
    handleCertAndAuthValidityCheker(event){
        const val = event.detail
        console.log('cert value ::: ', JSON.stringify(val))
        this.isNotChangedCurrentStep = val.currentStep
        // console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }

    handleIndustryInfoValidityChecker(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }
    // Certification And Authorization event handler
    handleCertAndAuthInfoEvent(event){
        const certAndAuthDetails = event.detail
        this.certAndAuthDetails = certAndAuthDetails
        console.log('certAndAuthDetails ::: ', JSON.stringify(certAndAuthDetails));
    }

    @api renderWageDefSection = []
    @api isShowClaimHeading;
    @api vtCaseIssues;
    @api demoGraphicInfoData;
    // Wage Deficienceis Info event handler
    handleWageDeficienciesInfoEvent(event){
        const wageDeficiencyDetails = event.detail
        this.wageDeficiencyDetails = wageDeficiencyDetails.wageDefDetails
        this.renderWageDefSection = event.detail.renderWageDefSection
        console.log('renderWageDefSection in parent cmp ::: ', JSON.stringify(this.wageDeficiencyDetails))
        this.isNotChangedCurrentStep = event.detail.isNotChangedCurrentStep
        this.vtCaseIssues = event.detail.vtCaseIssues;
        // this.renderWageDefSection.isShowClaimHeading
    }
    // Wage Deficiencies Validity event handler
    handleWageDeficienciesValidityEvent(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }

    // Demographic Data event handler
    handleDemoGraphicInfoData(event){
        const demoGraphicInfoData = event.detail;
        this.demoGraphicInfoData = demoGraphicInfoData;
        console.log('demoGraphicInfoData ::: ', JSON.stringify(this.demoGraphicInfoData));
    }

    // Label Section Validity event handler
    handleLabelValidityEvent(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }
    // Label Section Info event handler
    handleLabelSectionInfoEvent(event){
        const labelDetails = event.detail
        this.labelDetails = labelDetails
        console.log('labelDetails ::: ', JSON.stringify(labelDetails))
    }
    
    @api workWeekValue = ''
    // Work Week and Work Days event handler
    handleWorkWeekAndWorkDayDetails(event){
        const workWeekAndWorkDaysDetails = event.detail
        this.workWeekAndWorkDaysDetails = workWeekAndWorkDaysDetails
        this.workWeekAndWorkDaysDetails.workWeekValue !== undefined ? this.workWeekValue = this.workWeekAndWorkDaysDetails.workWeekValue : this.workWeekValue = ''
        console.log('workWeekAndWorkDaysDetails>>>>>>>>', JSON.stringify(this.workWeekAndWorkDaysDetails))
    }
    // Work Week and Work Days validity handler
    handleWorkWeekAndWorkDayValidityChekcer(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }

    @api userWorkedHours = 0;
    finalUserHoursList = []
    // Hours you typically event handler
    handleTypicallyHourWorkedEvent(event){
        const hoursYouTypicallyWorkedDetails = event.detail
        this.hoursYouTypicallyWorkedDetails = hoursYouTypicallyWorkedDetails
        var hours = 0;
        var minutes = 0;
        var hoursList;
        if(this.hoursYouTypicallyWorkedDetails.timeEntriesDetail !== undefined){
            for(var i=0; i<this.hoursYouTypicallyWorkedDetails.timeEntriesDetail.length; i++){
                hoursList = this.hoursYouTypicallyWorkedDetails.timeEntriesDetail[i].totalHours !== undefined || this.hoursYouTypicallyWorkedDetails.timeEntriesDetail[i].totalHours !== null || this.hoursYouTypicallyWorkedDetails.timeEntriesDetail[i].totalHours !== '' ? this.hoursYouTypicallyWorkedDetails.timeEntriesDetail[i].totalHours.split(' ') : ''
                if(hoursList !== undefined || hoursList.length > 0){
                    hoursList[0] !== undefined ? hours = Number(hoursList[0].replace('hr', '')) * 3600 : ''
                    hoursList[1] !== undefined ? minutes = Number(hoursList[1].replace('min', '')) * 60 : ''
                    this.finalUserHoursList.push(hours + minutes)
                }
            }
            this.finalUserHoursList.sort(function (a, b) {
                        return a - b;
                      });
            const userWorkingHours = Number(this.finalUserHoursList[this.finalUserHoursList.length - 1]);
            var hr = Math.floor(userWorkingHours/3600);
            var min = Math.floor(userWorkingHours%3600/60);
            this.userWorkedHours = Number(`${hr}.${min}`)
        }
    }
    // Hours you typically worked validity handler
    handleHoursYouTypicallyWorkedValidityEvent(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }
    handlepaymentofwagevaliditychecker(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }
    handleEmployeeStatusAndFinalWageValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }  
    @api _onehourlyRateList = [] 
    @api _multipleHourlyRateList = []
    @api _salaryRateList = []
    handlepaymentofwagesdetails(event){
        this._onehourlyRateList.length = 0
        this._multipleHourlyRateList.length = 0
        this._salaryRateList.length = 0
        // this._salaryRateList.push({ 'hourlyRate' : 0, 'beggingDate' : null, 'endingDate' : null })
        // this._multipleHourlyRateList.push({ 'hourlyRate' : 0, 'beggingDate' : null, 'endingDate' : null })
        // this._onehourlyRateList.push({ 'hourlyRate' : 0, 'beggingDate' : null, 'endingDate' : null })
        const paymentOfWagesDetails = event.detail
        this.paymentOfWagesDetails = paymentOfWagesDetails
        this._onehourlyRateList.push({ 'hourlyRate' : this.paymentOfWagesDetails.promisedAmountPerHour, 'beggingDate' : this.paymentOfWagesDetails.hourlyRateBegDate, 'endingDate' : this.paymentOfWagesDetails.hourlyRateEndDate });
        this._multipleHourlyRateList.push({ 'hourlyRate' : this.paymentOfWagesDetails.promisedAmountDifferentHour, 'beggingDate' : this.paymentOfWagesDetails.differentHourlyRateBegDate, 'endingDate' : this.paymentOfWagesDetails.differentHourlyRateEndDate })
        this._salaryRateList.push({ 'hourlyRate' : this.paymentOfWagesDetails.promisedAmountForEachDay, 'beggingDate' : this.paymentOfWagesDetails.eachPayRateBegDate, 'endingDate' : this.paymentOfWagesDetails.eachPayRateEndDate })
        console.log('details ::: ', JSON.parse(JSON.stringify(this.paymentOfWagesDetails)));
        this.paymentOfWagesDetails.hourlyAdditionalDetails.forEach( element => this._onehourlyRateList.push({ 'hourlyRate' : element.promisedAmountPerHourAdditional, 'beggingDate' : element.hourlyRateBegDateAdditional, 'endingDate' : element.hourlyRateEndDateAdditional }))
        this.paymentOfWagesDetails.differentHourAdditionalDetails.forEach( element => this._multipleHourlyRateList.push({ 'hourlyRate' : element.promisedAmountDifferentHourAdditional, 'beggingDate' : element.differentHourlyRateBegDateAdditional, 'endingDate' : element.differentHourlyRateEndDateAdditional }))
        this.paymentOfWagesDetails.salaryRateAdditionalDetails.forEach( element => this._salaryRateList.push({ 'hourlyRate' : this.paymentOfWagesDetails.promisedAmountForEachDayAdditional, 'beggingDate' : this.paymentOfWagesDetails.eachPayRateBegDateAdditional, 'endingDate' : this.paymentOfWagesDetails.eachPayRateEndDateAdditional }))
        // this.paymentOfWagesDetails.HourlyOptionValue === true ? this.isOneHourlyRateSelected = true : this.isOneHourlyRateSelected = false;
        // this.paymentOfWagesDetails.salaryRateOptionValue === true ? this.isSalaryRateSelected = true : this.isSalaryRateSelected = false;
        console.log('_onehourlyRateList ::: ', JSON.stringify(this._onehourlyRateList))
        console.log('_multipleHourlyRateList ::: ', JSON.stringify(this._multipleHourlyRateList))
        console.log('_salaryRateList ::: ', JSON.stringify(this._salaryRateList))
    }
    @api minimumHireDate;
    @api dischargedDate;
    @api paidByCheck;
    @api quitDateValue;
    @api wereWagesPaid;
    @api noticeBeforeQuiting;
    @api statementReceived;
    @api stillIdentifiedEmp;
    @api payStubSickRecord;
    @api finalPaymentDate;
    @api chequeReplaced;
    handleEmployeeStatusDetails(event){
        const employeeStatusAndFinalClaimDetails = event.detail
        console.log('employeeStatusAndFinalClaimDetails ::: ', JSON.stringify(employeeStatusAndFinalClaimDetails))
        this.employeeStatusAndFinalClaimDetails = employeeStatusAndFinalClaimDetails
        this.employeeStatusAndFinalClaimDetails.payStubSickRecord !== undefined && this.employeeStatusAndFinalClaimDetails.payStubSickRecord === 'No' ? this.payStubSickRecord = this.employeeStatusAndFinalClaimDetails.payStubSickRecord : this.payStubSickRecord = undefined
        this.employeeStatusAndFinalClaimDetails.hireDate !== undefined ? this.minimumHireDate = this.employeeStatusAndFinalClaimDetails.hireDate : ''
        this.employeeStatusAndFinalClaimDetails.dischargedDate !== undefined || this.employeeStatusAndFinalClaimDetails.dischargedDate !== null ? this.dischargedDate = this.employeeStatusAndFinalClaimDetails.dischargedDate : this.dischargedDate = undefined
        this.employeeStatusAndFinalClaimDetails.quitDate !== undefined || this.employeeStatusAndFinalClaimDetails.quitDate !== null ? this.quitDateValue = this.employeeStatusAndFinalClaimDetails.quitDate : this.quitDateValue = undefined
        this.employeeStatusAndFinalClaimDetails.statementReceived !== undefined ? this.statementReceived = this.employeeStatusAndFinalClaimDetails.statementReceived : ''
        this.employeeStatusAndFinalClaimDetails.isstillIdentifiedEmp !== undefined || this.employeeStatusAndFinalClaimDetails.stillIdentifiedEmp === 'No' ? this.stillIdentifiedEmp = this.employeeStatusAndFinalClaimDetails.stillIdentifiedEmp : this.stillIdentifiedEmp = undefined;
        this.employeeStatusAndFinalClaimDetails.finalPaymentDate !== null || this.employeeStatusAndFinalClaimDetails.finalPaymentDate !== undefined ? this.finalPaymentDate = this.employeeStatusAndFinalClaimDetails.finalPaymentDate : this.finalPaymentDate = null;
        this.employeeStatusAndFinalClaimDetails.chequeReplaced !== null || this.employeeStatusAndFinalClaimDetails.chequeReplaced !== undefined ? this.chequeReplaced = this.employeeStatusAndFinalClaimDetails.chequeReplaced : this.chequeReplaced = null;
        this.calculateMinimumWage(this.minimumWageZipCode, this.minimumHireDate)
        if(this.employeeStatusAndFinalClaimDetails.paidByCheck !== undefined && (this.employeeStatusAndFinalClaimDetails.paidByCheck === 'Yes' || this.employeeStatusAndFinalClaimDetails.paidByCheck === 'Sí')){
            this.paidByCheck = true;
        }
        else{
            this.paidByCheck = false;
        }
        if(this.employeeStatusAndFinalClaimDetails.noticeBeforeQuiting !== undefined && this.employeeStatusAndFinalClaimDetails.noticeBeforeQuiting === 'Yes'){
            this.noticeBeforeQuiting = true;
        }
        else{
            this.noticeBeforeQuiting = false;
        }
        if(this.employeeStatusAndFinalClaimDetails.wereWagesPaid !== undefined && this.employeeStatusAndFinalClaimDetails.wereWagesPaid === 'No'){
            this.wereWagesPaid = true;
        }
        else{
            this.wereWagesPaid = false;
        }
    }
    @api otherWorkCity = ''
    @api minimumRates;
    handleOtherWorkLocationInfo(event){
        const otherLocWorkInfo = event.detail
        this.otherLocWorkInfo = otherLocWorkInfo
        // check if user enter zipcode on this section
        this.otherLocWorkInfo.isBusinessAddressDifferent === true && this.otherLocWorkInfo.otherBusinessZipCode !== undefined ? this.minimumWageZipCode = this.otherLocWorkInfo.otherBusinessZipCode : this.minimumWageZipCode = ''
        this.otherLocWorkInfo.otherBusinessCity !== undefined || this.otherLocWorkInfo.otherBusinessCity !== null ? this.otherWorkCity = this.otherLocWorkInfo.otherBusinessCity : this.otherWorkCity = ''
        console.log('otherLocWorkInfo ::: ', JSON.stringify(otherLocWorkInfo))
    }

    @api stateRate
    @api stateRateList
    // Calculate Minimum wage based on the user zipcode inputs
    calculateMinimumWage(minimumwagezipcode, minimumhiredate){
        getMinimumWageRec({ 
            minimumwagezipcode : minimumwagezipcode,
            minimumhiredate : minimumhiredate
        })
           .then(result => {
               if(result){
                   console.log('getMinimumWageRec result ::: ', JSON.stringify(result))
                   this.stateRate = result.stateRate;
                   this.minimumRates = result.minimumRates;
                   this.stateRateList = result.stateWageList;
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
    }

    handleValidityEvent(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }
    handleIndustryInfoValidityEvent(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
    }
    handleOtherWorkLocationValidityEvent(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
    }  
    @api claimSubmitValue;
     // Claimant/Employee Section Event handler
    handleClaimantEmployeeChanged(event) {
        const claimantEmployeeData = event.detail;
        this.claimantEmployeeValues = claimantEmployeeData
        this.claimantEmployeeValues.WageClaimSubmit = claimantEmployeeData.WageClaimSubmit;
        console.log("WageClaimSubmit::::"+this.claimantEmployeeValues.WageClaimSubmit);
        console.log('claimantEmployeeValues:', JSON.stringify(this.claimantEmployeeValues));
        this.claimSubmitValue = this.claimantEmployeeValues.WageClaimSubmit;
    }   
    
    // Claim Filed Section Event Handler
    handleClaimFiledCustomEvent(event){
        const claimFiledSectionData = event.detail
        this.claimFiledSectionValues = claimFiledSectionData
        console.log('claimFiledSectionValues:', JSON.stringify(this.claimFiledSectionValues));
    }
    // This attribute is used to get the zipcode from Employer and other work location section
    @api minimumWageZipCode = '';
    handleEmployeeCustomEvent(event){
        const employeesDetails = event.detail
        this.employeesDetails = employeesDetails.employeesDetails
        this.renderEmpSection = event.detail.renderEmpSection
        this.isNotChangedCurrentStep = event.detail.isNotChangedCurrentStep
        this.employeesDetails[0].individualZipCode !== undefined ? this.minimumWageZipCode = this.employeesDetails[0].individualZipCode : this.minimumWageZipCode = this.employeesDetails[0].OtherIndividualZipCode;
        console.log('employeesDetails in parent:', JSON.stringify(this.employeesDetails));
        console.log('size ::: ', this.employeesDetails.length)
    }

    handleContinueToCert(event){
        const isContinue = event.detail.isContinue;
        if(isContinue !== undefined || isContinue !== null){
            if(isContinue === true){
                this.currentStep = '11'
                this.isClaimantAdvocate = false;
                this.isEnablePrev = false;
            }
        }
    }

    @api iwcInfoObj;
    getIWCInformation(selectedIndustry){
        console.log('selectedIndustry ::: ', selectedIndustry);
        getIWCInfo({
            selectedIndustry : selectedIndustry
        })
        .then(result => {
            if(result){
                console.log('IWC Info ::: ', JSON.stringify(result))
                this.iwcInfoObj = result;
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api empStatementProvided;
    @api heatRecovery;
    @api paidBreaks;
    @api isFarmLabour = false;
    @api isDomesticWorker = false;
    @api isWageDefGarmentClaim = false;
    // Industry Information Section handler
    handleIndustryInfoSectionData(event){
        const industryInfoData = event.detail
        this.industryInfoDataValues = industryInfoData;
        (this.industryInfoDataValues.isFarmLaborContractors != null && this.industryInfoDataValues.isFarmLaborContractors === true) ? this.isFarmLabour = true : this.isFarmLabour = false;
        (this.industryInfoDataValues.isHouseDomesticWorker != null && this.industryInfoDataValues.isHouseDomesticWorker === true) ? this.isDomesticWorker = true : this.isDomesticWorker = false;
        this.industryInfoDataValues.empStatementProvided !== undefined && this.industryInfoDataValues.empStatementProvided === 'No' ? this.empStatementProvided = this.industryInfoDataValues.empStatementProvided : this.empStatementProvided = undefined
        this.industryInfoDataValues.heatRecovery !== undefined && this.industryInfoDataValues.heatRecovery === 'No' ? this.heatRecovery = this.industryInfoDataValues.heatRecovery : this.heatRecovery = undefined
        if(this.claimantEmployeeValues.WageClaimSubmit === 'Yourself' && this.industryInfoDataValues.isLabelsInfo === true && this.industryInfoDataValues.isGarmentDutyFollow != 'No'){
            this.isClaimantAdvocate = true;
        }
        else if(this.claimantEmployeeValues.WageClaimSubmit === 'Representative' && this.industryInfoDataValues.isGarmentDutyFollow == 'No'){
            this.isClaimantAdvocate = false
        }
        else{
            this.isClaimantAdvocate = false
        }
        this.industryInfoDataValues.paidBreaks !== undefined || this.industryInfoDataValues.paidBreaks === 'No' ? this.paidBreaks = this.industryInfoDataValues.paidBreaks : this.paidBreaks = undefined
        this.isIndustryClickPrev === true ? this.isClaimantAdvocate = false : ''
        if(this.claimantEmployeeValues.WageClaimSubmit === 'Representative' && this.industryInfoDataValues.isLabelsInfo === true && this.industryInfoDataValues.isGarmentDutyFollow != 'No'){
            this.isWageDefGarmentClaim = true;
        }
        else{
            this.isWageDefGarmentClaim = false;
        }
        this.getIWCInformation(this.industryInfoDataValues.selectedOption);
        if(this.isClaimantAdvocate === true ){
            this.currentStep = '11'
        }
        console.log('POP 1  >>>>>>>', JSON.stringify(industryInfoData.isLabelsInfo));
        console.log('JSON response ::::: ', JSON.stringify(this.industryInfoDataValues));
    }
    handleClaimFieldEmpValidityEvent(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
    }
    get langOptions() {
        return [
            { label: 'English', value: 'English' },
            { label: 'Spanish', value: 'Spanish' }
        ];
    }
    // renderCallback run after template load into DOM
    renderedCallback(){   
        if(this.isFirstCmpRender === true){
            console.log('isFirstCmpRender:', this.claimantEmployeeValues);
            this.template.querySelector('c-owc-Preliminary-Section-Cmp').owcClaimantEmployeeInfoForChild(this.claimantEmployeeValues)
            
        }
        if(this.isThirdCmpRender === true && this.employeesDetails.length > 0){
            // this.isSecondCmpRender = true
            console.log('employeesDetails length ::: ', this.employeesDetails.length)
            this.template.querySelector('c-owc-Emp-Business-Type-Container-Cmp').owcEmployeesDataForChildCmp(this.employeesDetails, this.renderEmpSection );
            this.isThirdCmpRender = false
        }
        // if(this.isThirdCmpRender === true  && this.claimantEmployeeValues.WageClaimSubmit != null){
        //     console.log('WageClaimSubmitVal:', this.claimantEmployeeValues.WageClaimSubmit);
        //     this.template.querySelector('c-owc-Emp-Business-Type-Container-Cmp').owcClaimentInfo(this.claimantEmployeeValues.WageClaimSubmit, this.industryInfoDataValues.isLabelsInfo)
        //     this.isThirdCmpRender = false
        // }
        if(this.isSecondCmpRender === true && this.industryInfoDataValues != undefined){
            this.template.querySelector('c-industry-info-Cmp').owcIndustryInfoForChild(this.industryInfoDataValues)
            console.log('isSecondCmpRender:', JSON.stringify(this.industryInfoDataValues));
            //this.template.querySelector('c-industry-info-Cmp').owcClaimentInfo(this.claimantEmployeeValues.WageClaimSubmit)
                        
        }
        if(Boolean(this.demoGraphicInfoData) && this.isTwelveCmpRender === true ){
            this.template.querySelector('c-owc-Online-Demographic-Cmp').owcOnlineDemographicForChild(this.demoGraphicInfoData)
            this.isTwelveCmpRender = false
        }
        if(this.isFourthCmpRender === true && this.otherLocWorkInfo != null){
            this.template.querySelector('c-owc-Other-Work-Location-Section-Cmp').handleOtherWorkLocationChild(this.otherLocWorkInfo)
            this.isFourthCmpRender = false
        }
        if(this.isFifthCmpRender === true && this.employeeStatusAndFinalClaimDetails != null){
            this.template.querySelector('c-owc-Employment-Status-And-Final-Wages-Cmp').owcEmpStatusAndWagesDataForChild(this.employeeStatusAndFinalClaimDetails);
            this.isFifthCmpRender = false
        }
        if(this.isSixthCmpRender === true && this.paymentOfWagesDetails != null){
            this.template.querySelector('c-owc-Payment-Of-Wages-Cmp').owcPaymentOfWagesForChild(this.paymentOfWagesDetails);
            this.isSixthCmpRender = false
        }
        // if(this.isSixthCmpRender === true  && this.claimantEmployeeValues.WageClaimSubmit != null){
        //     // this.template.querySelector('c-owc-Payment-Of-Wages-Cmp').owcClaimentInfo(this.claimantEmployeeValues.WageClaimSubmit, this.industryInfoDataValues.isLabelsInfo)
            
        // }
        if(this.isEighthCmpRender === true && this.hoursYouTypicallyWorkedDetails != null){
            this.template.querySelector('c-owc-Hours-You-Typically-Worked-Cmp').owcHoursYouWorkedForChild(this.hoursYouTypicallyWorkedDetails);
            this.isEighthCmpRender = false
        }
        if(this.isSeventhCmpRender === true && this.workWeekAndWorkDaysDetails != null){
            console.log('workWeekAndWorkDaysDetails:', this.workWeekAndWorkDaysDetails);
            this.template.querySelector('c-owc-Workweek-And-Workday-Cmp').owcEmpStatusAndWagesDataForChild(this.workWeekAndWorkDaysDetails);
            this.isSeventhCmpRender = false
        }
        // if(this.isFourthCmpRender === true && this.successorDetails != null){
        //     this.template.querySelector('c-owc-Successor-Section-Container-Cmp').successorSectionDetailsForChild(this.successorDetails);
        //     this.isFourthCmpRender === false
        // }
        if(this.isTenthCmpRender === true && this.labelDetails != null){
            this.template.querySelector('c-owc-Label-Section-Container-Cmp').labelSectionForChild(this.labelDetails);
            this.isTenthCmpRender = false
        }
        if(this.isNinethCmpRender === true && (this.paymentOfWagesDetails !== null || this.paymentOfWagesDetails !== undefined)){
            this.template.querySelector('c-owc-Wage-Deficiencies-Cmp').handlepaymentofwagesdetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
        if(this.isNinethCmpRender === true && (this.employeeStatusAndFinalClaimDetails !== undefined)){
            this.template.querySelector('c-owc-Wage-Deficiencies-Cmp').handleEmpStatusValue(this.employeeStatusAndFinalClaimDetails.QuitDateTemplate, this.employeeStatusAndFinalClaimDetails.DischargeDateTemplate);
        }
        if(this.isNinethCmpRender === true && (this.wageDeficiencyDetails !== undefined || this.wageDeficiencyDetails !== null)){
            this.template.querySelector('c-owc-Wage-Deficiencies-Cmp').owcWageDeficienciesForChild(this.wageDeficiencyDetails, this.renderWageDefSection, this.isFormPreviewMode);
            this.isNinethCmpRender = false
        }
        if(this.isFormPreviewMode === true){
            this.template.querySelector('c-owc-Form-Preview-Cmp').getFormDetails(this.formDetailObj, this.isFormPreviewMode, this.isClaimantGarment, this.isClaimantAdvocate, this.renderWageDefSection);
        }
        // if(this.isPDFGenerate === true){
        //     var doc = new jsPDF();

        //     var template = this.template.querySelector('.c/owcLabelSectionContainerCmp')
        //     console.log('template ::: ', JSON.stringify(template))
        //     var specialElementHandlers = {
        //         '#editor': function (element, renderer) {
        //             return true;
        //         }
        //     };
            
        //     doc.fromHTML(template, 15, 15, {
        //         'width': 170,
        //             'elementHandlers': specialElementHandlers
        //     });
        //     doc.output("datauri");
        // }
        if(this.isEleventhCmpRender === true && this.certAndAuthDetails != undefined){
            this.template.querySelector('c-owc-Certification-And-Authorization-Cmp').certAndAuthInfoForChild(this.certAndAuthDetails);
            this.isEleventhCmpRender = false
        }
        
    }


    @api isClaimantGarment = false
    @api isClaimantAdvocate = false

    handleClaimantAdvocate(){
        // this.claimantEmployeeValues.WageClaimSubmit, this.industryInfoDataValues.isLabelsInfo
        if(this.claimantEmployeeValues.WageClaimSubmit === 'Yourself' && this.industryInfoDataValues.isLabelsInfo === true){
            this.isClaimantGarment = true
            this.isClaimantAdvocate = true
        }
        else if(this.claimantEmployeeValues.WageClaimSubmit === 'Representative' && this.industryInfoDataValues.isLabelsInfo === true){
            this.isClaimantGarment = false
            this.isClaimantAdvocate = false
        }
        return;
    }

    @track processingDraft = false;
    @track isNotToastShow;
    // Draft event handler
    handleSaveAsDraftEvent(event){
        console.log('isSaveAsDraft ::: ', JSON.stringify(event.detail))
        if(this.processingDraft === true){
            return;
        }
        else{
            this.processingDraft = true;
        }
        const isSaveAsDraft = event.detail.isSaveAsDraft
        const sectionId = event.detail.sectionId
        this.isNotToastShow = Boolean(event.detail.isNotToastShow) ? event.detail.isNotToastShow : false;
        // this.claimantEmployeeValues = event.detail.claimantEmployeeValues
        console.log('Draft Preliminary Data ::: ', JSON.stringify(this.claimantEmployeeValues))
        if(isSaveAsDraft === true){
            createOWCJSONResponse({
                onlineClaimDetails : JSON.stringify(this.handleOnlineFormDetails()),
                sectionId : sectionId,
                recordId : this.recordId
             })
           .then(result => {
               if(result){
                   this.processingDraft = false;
                   this.recordId = result.darftId;
                if(this.isNotToastShow == false && result.toastMsg === 'Your Draft has been successfully updated.'){
                    this.showToast('Success', this.customLabels.OWC_draft_update_toast_msg, 'success');
                   }
                   else if(this.isNotToastShow == false && result.toastMsg === 'Your Draft has been successfully created.'){
                    this.showToast('Success', this.customLabels.OWC_label_draft_create_msg, 'success');
                   }
               }
           })
           .catch(error => {
                this.processingDraft = false;
                this.showToast('Something went wrong', error.body.message, 'error');
                console.log('Error: ', error);
           })
        }
        else{
            isSaveAsDraft = false
        }
    }
    handleOnlineFormDetails(){
        // console.log('this.certAndAuthDetails ::: ',JSON.stringify(this.certAndAuthDetails))
        return {
            claimantEmployeeValues : this.claimantEmployeeValues,
            industryInfoDataValues : this.industryInfoDataValues,
            employeesDetails : this.employeesDetails,
            renderEmpSection : this.renderEmpSection,
            successorDetails : this.successorDetails,
            otherLocWorkInfo : this.otherLocWorkInfo,
            employeeStatusAndFinalClaimDetails : this.employeeStatusAndFinalClaimDetails,
            paymentOfWagesDetails : this.paymentOfWagesDetails,
            hoursYouTypicallyWorkedDetails : this.hoursYouTypicallyWorkedDetails,
            workWeekAndWorkDaysDetails : this.workWeekAndWorkDaysDetails,
            wageDeficiencyDetails : this.wageDeficiencyDetails,
            labelDetails : this.labelDetails,
            certAndAuthDetails : this.certAndAuthDetails,
            demoGraphicInfoData : this.demoGraphicInfoData
        }
        // this.claimDetails = formDetailObj;
    }

    @api formDetailObj
    @api isFormPreviewMode = false
    @api claimDetails
    @api isPDFGenerate = false

    // Toast msg
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    
    handleFormPreview(){
        this.template.querySelector('c-owc-Certification-And-Authorization-Cmp').getCertificationData();
        this.formDetailObj = this.handleOnlineFormDetails()
        console.log('formData ::: ', JSON.stringify(this.formDetailObj));
        this.handleClaimantAdvocate()
            if(this.isNotChangedCurrentStep === true){
                this.isNotChangedCurrentStep = false
            }
            else{
                this.isEleventhCmpRender = true
                this.isFormPreviewMode = true;
            }
        // this.template.querySelector('c-owc-Other-Work-Location-Section-Cmp').otherWorkLocationDetailsFromParent();
    }
 
    @api isClaimantConfirmationPopUp = false 
    @api isOkConfirmation
    @api isCancelConfirmation
    
    //Handle Claimant Confirmation Event
    handleClaimantConfirmationEvent(event){
        if(event.detail.isOk === true){
            this.isClaimantConfirmationPopUp = false;
            // this.isFormPreviewMode = true
            // this.isPDFGenerate = true
            this.formDetailObj = this.handleOnlineFormDetails()
            this.handleOnSubmitOperation();
        }
        else if(event.detail.isCancel === true){
            this.isClaimantConfirmationPopUp = false;
        }
    }

    // navigateToWebPage() {
    //     // Navigate to a URL
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__webPage',
    //         attributes: {
    //             url: 'http://salesforce.com'
    //         }
    //     },
    //     true // Replaces the current page in your browser history with the URL
    //   );
    // }

    handleOnSubmitOperation(){
        console.log('this.isNotChangedCurrentStep ::: ', this.isNotChangedCurrentStep)
        this.isClaimantAdvocate === false ? this.template.querySelector('c-owc-Certification-And-Authorization-Cmp').certAndAuthInfoFromParent() : ''
        if(this.isNotChangedCurrentStep === true){
            this.isNotChangedCurrentStep = false;
            return;
        }
        this.isShowSpinner = true;
        console.log('Final Case Issue JSON for submit ::: ', '{"caseIssues":' + JSON.stringify(this.vtCaseIssues) + '}');
        onlineClaimSubmit({
                onlineClaimDetails : JSON.stringify(this.handleOnlineFormDetails()),
                sectionId : '11',
                draftRecordId : this.recordId,
                vtCaseIssues : '{"caseIssues":' + JSON.stringify(this.vtCaseIssues) + '}'
            })
               .then(result => {
                   if(result.isSuccess){
                        this.handleGeneratePDF(result.caseId, result.documentLinks);
                   }
                   else if(Boolean(result) && !result.isSuccess && Boolean(result.caseId)){
                        //this.isShowSpinner = false;
                        // if(Boolean(result.caseId)){
                        //     this.deleteCaseRecord(result.caseId);
                        // }
                        // //Create draft record
                        // const errorDraftObj = {
                        //     detail: {
                        //         isSaveAsDraft : true,
                        //         sectionId : "11",
                        //         isNotToastShow : true
                        //     }
                        // }
                        // this.handleSaveAsDraftEvent(errorDraftObj);
                        // this.isShowErrorPrompt = true;
                        // this.navigateToWebPage();
                        // this.isModalOpen = true;
                        this.handleGeneratePDF(result.caseId, result.documentLinks, this.recordId);
                   }
                   else{
                    this.isShowSpinner = false;
                    this.isShowErrorPrompt = true;
                   }
               })
               .catch(error => {
                    this.isShowSpinner = false;
                    this.isShowErrorPrompt = true;
               })

               this.template.querySelector('c-owc-Certification-And-Authorization-Cmp').certAndAuthInfoForChild(this.certAndAuthDetails)
    }

    @api isModalOpen = false;

    handleGeneratePDF(caseRecordId, documentLinks, draftRecordId){
        console.log('documentLinks ::: ', JSON.stringify(documentLinks))
        generatePDF({
                     caseRecordId : JSON.stringify(caseRecordId),
                     documentLinks : JSON.stringify(documentLinks)
                })
           .then(result => {
               if(result.isSuccess){
                    this.isShowSpinner = false;
                    this.isModalOpen = true;
                    this.deleteCaseRecord('', draftRecordId);
               }
               else{
                    this.isShowSpinner = false;
                    if(Boolean(result) && Boolean(result.caseId)){
                        this.deleteCaseRecord(result.caseId, '');
                    }
                    //Create draft record
                    const errorDraftObj = {
                        detail: {
                            isSaveAsDraft : true,
                            sectionId : "11",
                            isNotToastShow : true
                        }
                    }
                    this.handleSaveAsDraftEvent(errorDraftObj);
                    this.isShowErrorPrompt = true;
               }
           })
           .catch(error => {
            this.isShowSpinner = false;
            //Delete case record
            console.log('Case RecordID ::: ', caseRecordId);
            if(Boolean(caseRecordId)){
                this.deleteCaseRecord(caseRecordId, '');
            }
            //Create draft record
            const errorDraftObj = {
                detail: {
                    isSaveAsDraft : true,
                    sectionId : "11",
                    isNotToastShow : true
                }
            }
            this.handleSaveAsDraftEvent(errorDraftObj);
            this.isShowErrorPrompt = true;
           })
    }

    @track isShowErrorPrompt = false;

    deleteCaseRecord(caseRecordId, draftRecordId){
        deleteCaseRecord({
            caseRecordId : caseRecordId,
            draftRecordId : draftRecordId
        })
        .then(result => {
        })
        .catch(error => {
        })
    }

    showToastError(result){
        const event = new ShowToastEvent({
            title: result.error,
            variant: 'error',
            message: '{0} {1} {2}',
            messageData: [
                'Please file your claim using the pdf forms at',
                {
                    url: 'https://www.dir.ca.gov/dlse/Wage_Claim_forms.html',
                    label: 'Wage Claim forms',
                },
                'so we can begin work on your claim.  We apologize for this inconvenience.'
            ],
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

    closeModal(event){
        const currentCommunityUrl = this.communityBasePath;
        console.log("currentCommunityUrl ::::: ", this.communityBasePath)
        window.open(currentCommunityUrl, '_self')
    }

    handleFinish(event){
        if(this.claimantEmployeeValues.WageClaimSubmit === 'Representative' && this.claimantEmployeeValues.isClaimantConfirmation === false){
            this.isClaimantConfirmationPopUp = true;
        }
        else{
            this.isClaimantConfirmationPopUp = false;
            // this.isFormPreviewMode = true
            // this.isPDFGenerate = true
            this.formDetailObj = this.handleOnlineFormDetails()
            // further operation perform onsubmit
            this.handleOnSubmitOperation();
        }
    }

    handleEditForm(event){
        this.isFormPreviewMode = false;
        this.claimantEmployeeValues.WageClaimSubmit === 'Yourself' && this.industryInfoDataValues.isLabelsInfo === true ? this.isClaimantAdvocate = true : this.isClaimantAdvocate = false;
        this.currentStep = "11";
        // this.isTwelveCmpRender = true
        this.template.querySelector('c-owc-Certification-And-Authorization-Cmp').certAndAuthInfoForChild(this.certAndAuthDetails)
    }
    
	
}