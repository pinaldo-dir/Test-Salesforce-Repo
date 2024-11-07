import { api, LightningElement } from 'lwc';
import pubsub from 'c/pubsub' ;
//import getOWCSubmittedJSONResponse from '@salesforce/apex/OWCSaveDraftController.getOWCSubmittedJSONResponse';
export default class OwcFormPreviewCmp extends LightningElement {
    @api message = false;
    @api isSpinner = false;
    @api isFormPreviewMode = false
    @api isrenderedCallback = false
    @api isClaimantEmployee = false
    @api isIndustryInfoDetails = false
    @api isEmployerDetails = false
    @api isSuccessorDetails = false
    @api isOtherWorkLocation = false
    @api isEmployeeStatusAndFinalWages = false
    @api isPaymentOfWagesDetails = false
    @api isDemoGraphicData = false
    @api isHoursYouTypicallyWorkedDetails = false
    @api isWorkWeekAndWorkDaysDetails = false
    @api isWageDeficiencyDetails = false
    @api isLabelSectionDetails = false
    @api isCetAndAuthDetails = false
    @api claimantEmployeeValues
    @api industryInfoDataValues
    @api employeesDetails
    @api renderEmpSection
    @api successorDetails
    @api otherLocWorkInfo
    @api employeeStatusAndFinalClaimDetails
    @api paymentOfWagesDetails
    @api hoursYouTypicallyWorkedDetails
    @api workWeekAndWorkDaysDetails
    @api wageDeficiencyDetails
    @api labelDetails
    @api certAndAuthDetails
    @api isClaimantAdvocate = false
    @api isClaimantGarment = false
    @api recordId
    @api renderWageDefSection;
    @api finalpaymentdate
    @api stateratelist
    @api staterate
    @api minimumrates
    @api paystubsickrecord
    @api iwcinfoobj
    @api isnotidentifyemployer
    @api powdetails
    @api heatrecovery
    @api empstatementprovided
    @api stateminwagerate
    @api paystubstatement
    @api userworkedhours
    @api otherworkcity
    @api minimumwage
    @api salaryratelist
    @api multiplehourlyrate
    @api hourlyratelist
    @api noticebeforequit
    @api werewagespaid
    @api quitdatevalue
    @api paidbycheck
    @api dischargeddate
    @api minimumhiredate
    @api minimumwagezipcode
    @api issalaryrateselected
    @api isonehourlyrateselected

    @api isPreviewClaimantGarment = false
    @api isPreviewClaimantAdvocate = false

    
    connectedCallback(){
        let message = {
            "message" : false
        }
        pubsub.fire('spinnerevent', message );

        // Get caseManagement recordId from the URL
        // const currentCommunityUrl = window.location.search
        // console.log('currentCommunityUrl1 ::: '+currentCommunityUrl)
        // const urlParams = new URLSearchParams(currentCommunityUrl);
        // const recordId = urlParams.get('recordId')
        // this.recordId = recordId || '';
        // if(this.recordId !== undefined && this.recordId !== null && this.recordId !== ''){
        //     getOWCSubmittedJSONResponse({
        //         caseId : this.recordId
        //     })
        //        .then(result => {
        //            if(result){
        //                 console.log(result);
        //                 const finalResult = JSON.parse(result.Draft_JSON__c.replace(/&quot;/g,'"'));
        //                 if(finalResult.claimantEmployeeValues.WageClaimSubmit === 'Yourself' && finalResult.industryInfoDataValues.isLabelsInfo === true ){
        //                     this.isPreviewClaimantGarment = true;
        //                     this.isPreviewClaimantAdvocate = false;
        //                 }
        //                 else if(finalResult.claimantEmployeeValues.WageClaimSubmit === 'Representative' && finalResult.industryInfoDataValues.isLabelsInfo === true){
        //                     this.isPreviewClaimantAdvocate = true;
        //                     this.isPreviewClaimantGarment = false;
        //                 }
        //                 this.getFormDetails(finalResult, true, this.isPreviewClaimantGarment, this.isPreviewClaimantAdvocate);
        //            }
        //        })
        //        .catch(error => {
        //            console.log('Error: ', error);
        //        })
        // }
    }

    @api isShowClaimHeading = false;
    @api
    getFormDetails(formDetails, isFormPreviewMode, isClaimantGarment, isClaimantAdvocate, renderWageDefSection){
        
        this.isClaimantGarment = isClaimantGarment
        this.isClaimantAdvocate = isClaimantAdvocate
        this.isFormPreviewMode = isFormPreviewMode
        this.renderWageDefSection = renderWageDefSection
        console.log('formDetails ::: ', JSON.stringify(formDetails))
        this.claimantEmployeeValues = formDetails.claimantEmployeeValues
        this.industryInfoDataValues = formDetails.industryInfoDataValues
        this.employeesDetails = formDetails.employeesDetails
        this.renderEmpSection = formDetails.renderEmpSection
        this.otherLocWorkInfo = formDetails.otherLocWorkInfo
        this.employeeStatusAndFinalClaimDetails = formDetails.employeeStatusAndFinalClaimDetails
        this.paymentOfWagesDetails = formDetails.paymentOfWagesDetails
        this.hoursYouTypicallyWorkedDetails = formDetails.hoursYouTypicallyWorkedDetails
        this.workWeekAndWorkDaysDetails = formDetails.workWeekAndWorkDaysDetails
        this.wageDeficiencyDetails = formDetails.wageDeficiencyDetails
        this.isShowClaimHeading = this.wageDeficiencyDetails[0].isShowClaimHeading === undefined || this.wageDeficiencyDetails[0].isShowClaimHeading === false ? false : true
        console.log('isShowClaimHeading ::: ', this.isShowClaimHeading);
        this.labelDetails = formDetails.labelDetails
        this.certAndAuthDetails = formDetails.certAndAuthDetails
        this.claimantEmployeeValues != null ? this.isClaimantEmployee = true : this.isClaimantEmployee = false
        this.industryInfoDataValues != null ? this.isIndustryInfoDetails = true : this.isIndustryInfoDetails = false
        this.employeesDetails != null ? this.isEmployerDetails = true : this.isEmployerDetails = false
        if(Boolean(this.claimantEmployeeValues) && (this.claimantEmployeeValues.WageClaimSubmit === "Yourself")){
            this.demoGraphicInfoData = formDetails.demoGraphicInfoData;
            this.isDemoGraphicData = true;
        }
        else{
            this.isDemoGraphicData = false;
        }
        this.otherLocWorkInfo != null ? this.isOtherWorkLocation = true : this.isOtherWorkLocation = false
        this.employeeStatusAndFinalClaimDetails != null ? this.isEmployeeStatusAndFinalWages = true : this.isEmployeeStatusAndFinalWages = false
        this.paymentOfWagesDetails != null ? this.isPaymentOfWagesDetails = true : this.isPaymentOfWagesDetails = false
        this.hoursYouTypicallyWorkedDetails.isUnreimbursedUpload === false && this.hoursYouTypicallyWorkedDetails.isVacationTimeClaimUpload === false && this.hoursYouTypicallyWorkedDetails.isSameWeekDaysAndHours === false && this.hoursYouTypicallyWorkedDetails.isDaysOrWeekVaried === false ? this.isHoursYouTypicallyWorkedDetails = false : this.isHoursYouTypicallyWorkedDetails = true
        this.handleWorkWeekAndDaysCheck(this.workWeekAndWorkDaysDetails);
        // (this.workWeekAndWorkDaysDetails.EmpFollowSatToSun != undefined || this.workWeekAndWorkDaysDetails.EmpFollowSatToSun != null) && (this.workWeekAndWorkDaysDetails.EmpFollowMidnightToMidnight != null || this.workWeekAndWorkDaysDetails.EmpFollowMidnightToMidnight != undefined) ? this.isWorkWeekAndWorkDaysDetails = true : this.isWorkWeekAndWorkDaysDetails = false
        this.handleWageDeficienciesCheck(this.wageDeficiencyDetails);
        // this.wageDeficiencyDetails.claimPeriodStartDate != undefined && this.wageDeficiencyDetails.claimPeriodStartDate != undefined ? this.isWageDeficiencyDetails = false : this.isWageDeficiencyDetails = true
        // this.labelDetails.labelInformationSectionValues != '' ? this.isLabelSectionDetails = true : this.isLabelSectionDetails = false
        this.isClaimantAdvocate === true ? this.handleLabelDetailsCheck(this.labelDetails.labelInformationSectionValues) : ''
        this.certAndAuthDetails.isAuthorizationRelease === false && this.certAndAuthDetails.isAdditionalClaimDocUpload === false ? this.isCetAndAuthDetails = false : this.isCetAndAuthDetails = true
        this.isrenderedCallback = true
    }


    handleLabelDetailsCheck(labelDetails){
        // var labelArray = Object.keys(labelDetails.labelDetails).some(detail => console.log('detail ::: ', JSON.stringify(detail)) )
        var checker = []
        if(Boolean(labelDetails)){
            for (var i=0; i<labelDetails.length; i++){
                for(var key in labelDetails[i]){
                    if(labelDetails[i].hasOwnProperty(key)){
                        console.log(key + " label-> " + labelDetails[i][key]);
                        if(key === 'labelheading'){
                            checker.push()
                        }
                        else if(labelDetails[i][key]){
                            checker.push('true');
                        }
                        else if(labelDetails[i][key] == false){
                            checker.push();
                        }
                    }
                }
            }
        }

        if(checker.length === 0){
            this.isLabelSectionDetails = false
        }
        else{
            this.isLabelSectionDetails = true
        }
    }

    handleWorkWeekAndDaysCheck(workWeekAndWorkDaysDetails){
        var checker = []
        for (var key in workWeekAndWorkDaysDetails) {
            if (workWeekAndWorkDaysDetails.hasOwnProperty(key)) {
                console.log(key + " -> " + workWeekAndWorkDaysDetails[key]);
                if(workWeekAndWorkDaysDetails[key]){
                    checker.push('true');
                }
                else if(workWeekAndWorkDaysDetails[key] == false){
                    checker.push('true');
                }
            }
        }
        if(checker.length === 0){
            this.isWorkWeekAndWorkDaysDetails = false
        }
        else{
            this.isWorkWeekAndWorkDaysDetails = true
        }
        // var check1 = Object.values(this.workWeekAndWorkDaysDetails).some(detail => detail === undefined)
        // var EmpFollowSatToSunCondition = (workWeekAndWorkDaysDetails.EmpFollowSatToSun != undefined || workWeekAndWorkDaysDetails.EmpFollowSatToSun != null || workWeekAndWorkDaysDetails.EmpFollowSatToSun != '');
        // var EmpFollowMidnightToMidnightCondition = (workWeekAndWorkDaysDetails.EmpFollowMidnightToMidnight != undefined || workWeekAndWorkDaysDetails.EmpFollowMidnightToMidnight != null || workWeekAndWorkDaysDetails.EmpFollowMidnightToMidnight != '');
        // if( EmpFollowSatToSunCondition || EmpFollowMidnightToMidnightCondition || check1){
        //     this.isWorkWeekAndWorkDaysDetails = true
        // }
        // else{
        //     this.isWorkWeekAndWorkDaysDetails = false
        // }
    }

    handleWageDeficienciesCheck(wageDeficiencyDetails){
        var checker = []
        for (var key in wageDeficiencyDetails) {
            if (wageDeficiencyDetails.hasOwnProperty(key)) {
                console.log(key + " -> " + wageDeficiencyDetails[key]);
                if(key == 'value' || key == 'value1'){
                    wageDeficiencyDetails[key].length === 0 ?  checker.push() : checker.push('true');
                }
                else if(wageDeficiencyDetails[key]){
                    checker.push('true');
                }
                else if(wageDeficiencyDetails[key] == false){
                    checker.push();
                }
                // else if(wageDeficiencyDetails[key].length === 0){
                //     checker.push();
                // }
            }
        }
        if(checker.length === 0){
            this.isWageDeficiencyDetails = false
        }
        else{
            this.isWageDeficiencyDetails = true
        }
        // var claimPeriodStartDateCondition = (wageDeficiencyDetails.claimPeriodStartDate != undefined || wageDeficiencyDetails.claimPeriodStartDate != null || wageDeficiencyDetails.claimPeriodStartDate != '');
        // var claimPeriodEndDateCondition = (wageDeficiencyDetails.claimPeriodEndDate != undefined || wageDeficiencyDetails.claimPeriodEndDate != null || wageDeficiencyDetails.claimPeriodEndDate != '');
        // var yourClaimCondition = wageDeficiencyDetails.yourClaim !== undefined ? wageDeficiencyDetails.yourClaim.length !== 0 : false
        // if(claimPeriodStartDateCondition || claimPeriodEndDateCondition || yourClaimCondition){
        //     this.isWageDeficiencyDetails = true
        // }
        // else{
        //     this.isWageDeficiencyDetails = false
        // }
    }

    renderedCallback(){
        if(this.isrenderedCallback === true && this.isCetAndAuthDetails === true){
            this.template.querySelector('c-owc-Certification-And-Authorization-Cmp').certAndAuthInfoForChild(this.certAndAuthDetails,this.isFormPreviewMode);
        }
        if(this.isrenderedCallback === true && this.isWageDeficiencyDetails === true && this.wageDeficiencyDetails[0] !== undefined && this.wageDeficiencyDetails[0].isShowClaimHeading === true){
            this.template.querySelector('c-owc-Wage-Deficiencies-Cmp').owcWageDeficienciesForChild(this.wageDeficiencyDetails, this.renderWageDefSection,this.isFormPreviewMode);
        }
        if(this.isrenderedCallback === true && this.claimantEmployeeValues != null){
            this.template.querySelector('c-owc-Preliminary-Section-Cmp').owcClaimantEmployeeInfoForChild(this.claimantEmployeeValues, this.isFormPreviewMode)
        }
        if(this.isrenderedCallback === true && this.industryInfoDataValues != null){
            this.template.querySelector('c-industry-info-Cmp').owcIndustryInfoForChild(this.industryInfoDataValues, this.isFormPreviewMode)
        }
        if(this.isrenderedCallback === true && this.employeesDetails != null){
            this.template.querySelector('c-owc-Emp-Business-Type-Container-Cmp').owcEmployeesDataForChildCmp(this.employeesDetails, this.renderEmpSection, this.isFormPreviewMode );
        }
        if(this.isrenderedCallback === true && this.otherLocWorkInfo != null){
            this.template.querySelector('c-owc-Other-Work-Location-Section-Cmp').handleOtherWorkLocationChild(this.otherLocWorkInfo, this.isFormPreviewMode)
        }
        if(this.isrenderedCallback === true && this.employeeStatusAndFinalClaimDetails != null){
            this.template.querySelector('c-owc-Employment-Status-And-Final-Wages-Cmp').owcEmpStatusAndWagesDataForChild(this.employeeStatusAndFinalClaimDetails,this.isFormPreviewMode);
        }
        if(this.isrenderedCallback === true && this.isHoursYouTypicallyWorkedDetails === true){
            this.template.querySelector('c-owc-Hours-You-Typically-Worked-Cmp').owcHoursYouWorkedForChild(this.hoursYouTypicallyWorkedDetails,this.isFormPreviewMode);
        }
        if(this.isrenderedCallback === true && this.isWorkWeekAndWorkDaysDetails === true){
            this.template.querySelector('c-owc-Workweek-And-Workday-Cmp').owcEmpStatusAndWagesDataForChild(this.workWeekAndWorkDaysDetails,this.isFormPreviewMode);
        }
        if(this.isrenderedCallback === true && this.paymentOfWagesDetails != null){
            this.template.querySelector('c-owc-Payment-Of-Wages-Cmp').owcPaymentOfWagesForChild(this.paymentOfWagesDetails,this.isFormPreviewMode);
        }
        if(this.isrenderedCallback === true && Boolean(this.claimantEmployeeValues) && (this.claimantEmployeeValues.WageClaimSubmit === "Yourself")){
            this.template.querySelector('c-owc-Online-Demographic-Cmp').owcOnlineDemographicForChild(this.demoGraphicInfoData,this.isFormPreviewMode);
        }
        if(this.isrenderedCallback === true && this.isLabelSectionDetails === true ){
            this.template.querySelector('c-owc-Label-Section-Container-Cmp').labelSectionForChild(this.labelDetails,this.isFormPreviewMode);
        }
        if(this.isrenderedCallback === true){
            var template = this.template.innerHTML
            console.log('JSON ::: ', JSON.stringify(template))
        }
        this.isrenderedCallback === false;
    }

    
}