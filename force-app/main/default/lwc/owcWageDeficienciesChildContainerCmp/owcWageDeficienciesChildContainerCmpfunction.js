import { LightningElement,api } from 'lwc';
import { radioOptions, acceptedFileFormat, customLabelValues } from 'c/owcUtils';

export function showToastMsg(message, variant){
    const evt = new ShowToastEvent({
        message: message,
        variant: variant,
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}

const Utils = (superclass) => class extends superclass {

    @api isHelpText = false;
    @api helpText;
    @api issickleavehelptext = false;
    
    handleHelpText(event) {
        const hpt = event.target.name;
        if(hpt === 'reportHp'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_report_hpt;
        }else if(hpt === 'reportGarmentEmp'){
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
}

export { Utils }