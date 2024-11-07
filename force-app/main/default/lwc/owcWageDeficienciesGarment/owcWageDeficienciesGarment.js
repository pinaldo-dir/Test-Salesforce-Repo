import { LightningElement, api, track, wire } from 'lwc';
import { radioOptions, acceptedFileFormat, customLabelValues } from 'c/owcUtils';
import severancePayOfferedOptions from '@salesforce/apex/OwcWageDeficiencies.fetchseverancePayOfferedOption';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
// import parseResponse from '@salesforce/apex/OWCcaseIssueUtility.parseResponse';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcWageDeficienciesGarment extends LightningElement {
    @api renderWageDefSection = [{ heading : customLabelValues.OWC_wage_deficiencies_heading, button : false, sectionId : 1 }];
    // Attributes
    @api is_wage_def_garment_claim
    @api isFormPreviewMode = false;
    @api isRenderedCallback = false;
    @track isRenderWageDef = true
    @api finalpaymentdate;
    @api otherworkcity
    @api userworkedhours
    @api heatrecovery;
    @api powdetails;
    @api isnotidentifyemployer;
    @api iwcinfoobj;
    @api paystubsickrecord;
    @api stateratelist;
    @api wageclaimsubmit;
    @api isfarmlabour;
    @api is_domestic_worker;

    // Minimum Wage ZipCode attribute
    @api minimumwagezipcode
    @api minimumhiredate
    @api dischargeddate
    @api salaryratelist
    @api multiplehourlyrate
    @api hourlyratelist
    @api minimumwage
    @api minimumrates
    @api staterate

    @api wageDefDetails = []
    @api wageDefSectionValues = []
    @api isNotChangedCurrentStep = false
    @api thirdcomponentrender = false
    @api deleteEmployerSection
    @api wageDefSectionDataAfterDelete = []
    @api isWageDefSectionDeleted = false
    @api paidbycheck;
    @api noticebeforequit
    @api werewagespaid
    @api quitdatevalue
    @api paystubstatement
    @api stateminwagerate
    @api empstatementprovided
    @api chequereplaced;
    @api paidbreaks;
    flag = 0
    flag1 = 1

    @api iswagedefpreview;

    // @api get isClaimHeading(){
    //     return this.isHeatRestDef === true || this.isWrittenStatement === true || this.isLatePayroll === true || this.paidbycheck === true || this.showWaitingTimeClaim === true || this.isFirstOptionTrue === true || this.isSecondOptionTrue === true || this.isThirdOptionTrue === true || this.isFourthOptionTrue === true || this.isFifthOptionTrue === true || this.isSixthOptionTrue === true || this.isSeventhOptionTrue === true || this.isEightOptionTrue === true || this.isNinethOptionTrue === true || this.isTenthOptionTrue === true || this.isEleventhOptionTrue === true || this.isTwelveOptionTrue === true || this.isThirteenthOptionTrue === true || this.isFouteenOptionTrue === true || this.anotherClaimExplain !== undefined
    // }
    
    @api isAddDefChanged = false;
    // Add more deficiencies handler
    addMoreDeficiencies(event){
        this.isRenderWageDef = false
        const flag1 = this.flag1 + 1
        this.flag1 = flag1
        this.renderWageDefSection.push({ heading : this.customLabelValues.OWC_another_wage_deficiencies_label, button : true, sectionId : this.flag1})
        this.isAddDefChanged = true;
        this.isRenderWageDef = true
    }

    @api isSpinner = false;
    // Hide spinner
    handleHideSpinnerCmp(event){
        const isSpinner = event.detail.isSpinner;
        this.isSpinner = isSpinner
    }

    // Handle section delete
    handleSectionDelete(event){
        var flag1 = 1
        const wageDeficienciesAfterDelete = []
        this.isRenderWageDef = false
        this.wageDefSectionDataAfterDelete.length = 0
        this.deleteWageDefSectionId = event.currentTarget.name
        const wageDefSectionDetails = this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Container-Garment-Cmp')
        for (let i = 0; i < wageDefSectionDetails.length; i++){
            wageDefSectionDetails[i].handleWageDefSectionData()
        }
        const deleteSectionDataIndex = this.wageDefSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteWageDefSectionId)
        // These two lines are used to delete the uploaded files data for the deleted sections.
        // const wageDefTemp = this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Container-Garment-Cmp')
        // wageDefTemp[deleteSectionDataIndex].handleEmployerSectionDeleteFiles(true)
        this.wageDefSectionDataAfterDelete.splice(deleteSectionDataIndex, 1);
        console.log('wageDefSectionDataAfterDelete ::: ', JSON.stringify(this.wageDefSectionDataAfterDelete));
        const deletedSectionIndex = this.renderWageDefSection.findIndex(sec => sec.sectionId === this.deleteWageDefSectionId)
        this.renderWageDefSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderWageDefSection.length ;i++){
            flag1 = 1 + i
            if(this.renderWageDefSection[i].heading === this.customLabelValues.OWC_wage_deficiencies_heading){
                wageDeficienciesAfterDelete.push(this.renderWageDefSection[i])
            }
            else{
                wageDeficienciesAfterDelete.push({ heading : this.customLabelValues.OWC_another_wage_deficiencies_label, button : true, sectionId : flag1 })
            }
        }
        this.renderWageDefSection.length = 0
        for (var i of wageDeficienciesAfterDelete){
            this.renderWageDefSection.push(i)
        }
        console.log('renderWageDefSection ::: ', JSON.stringify(this.renderWageDefSection))
        // this.renderWageDefSection = wageDeficienciesAfterDelete
        this.flag1 = this.renderWageDefSection.length
        this.isRenderWageDef = true
        this.isWageDefSectionDeleted = true
        this.showToast(this.customLabelValues.OWC_deleteSection_msg)
    }

    // Handle Save as Draft functionality
    handleSaveAsDraft(){
        this.owcwageDeficienciesFromParent();
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "9"
            }
        });
        this.dispatchEvent(validateEvent);
    }

    // Section delete event
    handleWageClaimDelete(event){
        const wageDefSectionDataAfterDelete = event.detail
        this.wageDefSectionDataAfterDelete.push(wageDefSectionDataAfterDelete)
        console.log('handleWageClaimDelete ::: ', JSON.stringify(this.wageDefSectionDataAfterDelete))
    }

    // Connected Callback
    connectedCallback(){
        // don’t forget to load static resources in connectedCallback . 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
            console.log( 'Files loaded' );
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
            console.log( error.body.message );
        });
        if((this.paidbreaks !== undefined && this.paidbreaks === 'No') || (this.heatrecovery !== undefined && this.heatrecovery === 'No')){
            this.handlePR21();
        }
        this.paystubsickrecord === 'No' ? this.handleSL20Trigger() : ''
        console.log('quitDate in parent wage ::: ', this.quitdatevalue)
    }

    async handleSL20Trigger(){
        try{
            await this.getViolationTypeVariableForSL20('314');
        }catch (error){
            console.log('error', error);
        }
    }

    @api violationTypeVariableForSL20;
    getViolationTypeVariableForSL20(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                this.violationTypeVariableForSL20 = result;
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    // Import custom labels from the utils cmp
    customLabelValues = customLabelValues;

    // Handle change method
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {
            case "claimPeriodStartDate":
                this.claimPeriodStartDate = event.target.value;
                console.log('claimPeriodStartDate ::: ', this.claimPeriodStartDate);
                break;
        }
    }

    @api violationTypeVariablesForknownPieceRate;
    @api isPieceRateknown = false;
    getAllVilationTypeVariablesForKnownPieceRate(queryCode){
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
                 console.log('wage def result different hour ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForknownPieceRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForknownPieceRate = result;
                    this.violationTypeVariablesForknownPieceRate.length > 0 ? this.isPieceRateknown = true : this.isPieceRateknown = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    async handlePR21(){
        try{
            await this.getAllVilationTypeVariablesForKnownPieceRate('154');
        }catch (error){
            console.log('error', error);
        }
    }
    

    prepareVtCaseIssues(){
        if(this.overTimeCaseIssueObj !== undefined && this.overTimeCaseIssueObj.length > 0){

            for(var i=0; i<this.overTimeCaseIssueObj.length; i++){
                var oneHourlyList = []
                var oneHourlyId
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt19 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt19.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt19.length; j++){
                            oneHourlyId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt19[j].violationTypeId;
                            oneHourlyList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt19[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : oneHourlyId , "violationVariables": oneHourlyList})
                    }
                } 

                var ot22RecordList = []
                var ot22RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22.length; j++){
                            ot22RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22[j].violationTypeId;
                            ot22RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : ot22RecId , "violationVariables": ot22RecordList})
                    }
                } 

                var ot22_1RecordList = []
                var ot22_1RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_1 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_1.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_1.length; j++){
                            ot22_1RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_1[j].violationTypeId;
                            ot22_1RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_1[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : ot22_1RecId , "violationVariables": ot22_1RecordList})
                    }
                } 

                var ot22_2RecordList = []
                var ot22_2RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_2 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_2.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_2.length; j++){
                            ot22_2RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_2[j].violationTypeId;
                            ot22_2RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_2[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : ot22_2RecId , "violationVariables": ot22_2RecordList})
                    }
                } 

                var ot22_3RecordList = []
                var ot22_3RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_3 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_3.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_3.length; j++){
                            ot22_3RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_3[j].violationTypeId;
                            ot22_3RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt22_3[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : ot22_3RecId , "violationVariables": ot22_3RecordList})
                    }
                } 

                var ot10RecordList = []
                var ot10RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt10 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt10.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt10.length; j++){
                            ot10RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt10[j].violationTypeId;
                            ot10RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt10[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : ot10RecId , "violationVariables": ot10RecordList})
                    }
                } 

                var ot13RecordList = []
                var ot13RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13.length; j++){
                            ot13RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13[j].violationTypeId;
                            ot13RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : ot13RecId , "violationVariables": ot13RecordList})
                    }
                } 

                var ot13_1RecordList = []
                var ot13_1RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_1 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_1.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_1.length; j++){
                            ot13_1RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_1[j].violationTypeId;
                            ot13_1RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_1[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : ot13_1RecId , "violationVariables": ot13_1RecordList})
                    }
                } 

                var ot13_2RecordList = []
                var ot13_2RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_2 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_2.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_2.length; j++){
                            ot13_2RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_2[j].violationTypeId;
                            ot13_2RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_2[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : ot13_2RecId , "violationVariables": ot13_2RecordList})
                    }
                } 

                var ot28RecordList = []
                var ot28RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt28 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt28.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt28.length; j++){
                            ot28RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt28[j].violationTypeId;
                            ot28RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt28[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : ot28RecId , "violationVariables": ot28RecordList})
                    }
                }
                
                var dt15RecordList = []
                var dt15RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForDt15 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForDt15.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForDt15.length; j++){
                            dt15RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForDt15[j].violationTypeId;
                            dt15RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForDt15[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : dt15RecId , "violationVariables": dt15RecordList})
                    }
                }
                
                var ot13_3RecordList = []
                var ot13_3RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_3 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_3.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_3.length; j++){
                            ot13_3RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_3[j].violationTypeId;
                            ot13_3RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOt13_3[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : ot13_3RecId , "violationVariables": ot13_3RecordList})
                    }
                } 

                var dt10RecordList = []
                var dt10RecId;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForDt10 !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForDt10.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForDt10.length; j++){
                            dt10RecId = this.overTimeCaseIssueObj[i].violationTypeVariablesForDt10[j].violationTypeId;
                            dt10RecordList.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForDt10[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : dt10RecId , "violationVariables": dt10RecordList})
                    }
                } 

                var dt10List = []
                var dt10Id;
                if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourly !== undefined){
                    if(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourly.length > 0){
                        for(var j=0; j<this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourly.length; j++){
                            dt10Id = this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourly[j].violationTypeId;
                            dt10List.push(this.overTimeCaseIssueObj[i].violationTypeVariablesForOneHourly[j]);
                        }
                        this.vtCaseIssues.push({ "violationTypeId" : dt10Id , "violationVariables": dt10List})
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
                        this.vtCaseIssues.push({ "violationTypeId" : additonalClaimId , "violationVariables": additionalClaimList})
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
                        this.vtCaseIssues.push({ "violationTypeId" : OneHourlyRecsId , "violationVariables": OneHourlyRecsList})
                    }
                } 
            }
        }
    }

    // Parent handler of this cmp
    @api 
    owcwageDeficienciesFromParent(){
        const details = this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Container-Garment-Cmp')
        for (let i = 0; i < details.length; i++){
            details[i].handleWageDeficienciesParentData()
        }
        // (this.vtCaseIssues != null && this.vtCaseIssues.length > 0) ? this.vtCaseIssues.length = 0 : '';
        this.prepareVtCaseIssues();
        var workPaidSalaryList = []
        var salaryVtId;
        if(this.violationTypeVariablesForknownPieceRate !== undefined){
            if(this.violationTypeVariablesForknownPieceRate.length > 0){
                for(var j=0; j<this.violationTypeVariablesForknownPieceRate.length; j++){
                    salaryVtId = this.violationTypeVariablesForknownPieceRate[j].violationTypeId;
                    workPaidSalaryList.push(this.violationTypeVariablesForknownPieceRate[j]);
                }
                this.vtCaseIssues.push({ "violationTypeId" : salaryVtId , "violationVariables": workPaidSalaryList})
            }
        } 

        var SL20list = []
        var SL20Id;
        if(this.violationTypeVariableForSL20 !== undefined){
            if(this.violationTypeVariableForSL20.length > 0){
                for(var j=0; j<this.violationTypeVariableForSL20.length; j++){
                    SL20Id = this.violationTypeVariableForSL20[j].violationTypeId;
                    SL20list.push(this.violationTypeVariableForSL20[j]);
                }
                this.vtCaseIssues.push({ "violationTypeId" : SL20Id , "violationVariables": SL20list})
            }
        } 
        console.log('vtCaseIssues ::: ', JSON.stringify(this.vtCaseIssues))
        // Call OwvViolationUtility methods
        // this.handleServer();
        const selectEvent = new CustomEvent('wagedeficienciesinfoevent', {
            detail: { 
                wageDefDetails : this.wageDefDetails,
                isNotChangedCurrentStep : this.isNotChangedCurrentStep,
                renderWageDefSection : this.renderWageDefSection,
                vtCaseIssues : this.vtCaseIssues
            }
        });
        this.isNotChangedCurrentStep = false
        this.dispatchEvent(selectEvent);
    }

    @api vtCaseIssueList = [];
    // Case Issue Calaculation in the continue button
    // handleServer(){  
    //     parseResponse({
    //         caseIssueJson : JSON.stringify(this.vtCaseIssues),
    //         caseId : ''
    //     })
    //     .then(result => {
    //         if(result){
    //             console.log('result2 :: ', JSON.stringify(result));
    //         }
    //     })
    //     .catch(error => {
    //         console.log('Error: ', error);
    //     })
    // }

    handleWageDeficienciesEvent(){
        const selectEvent = new CustomEvent('wagedeficienciesinfoevent', {
            detail: {
                
            }
        });
        this.dispatchEvent(selectEvent);
    }

    @api wageDefInfoData
    @api paymentOfWagesDetails

    // Handle Payment of Wages method
    @api
    handlepaymentofwagesdetails(paymentOfWagesDetails, isFormPreviewMode){
        this.paymentOfWagesDetails = paymentOfWagesDetails;
        this.isFormPreviewMode = isFormPreviewMode;
        const details = this.iswagedefpreview === true ? this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Preview-Garment-Cmp') : this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Container-Garment-Cmp');
        for(var i=0; i<details.length; i++){
            details[i].handlePOWDetails(this.paymentOfWagesDetails, this.isFormPreviewMode);
        }
    }

    // child handler
    @api 
    owcWageDeficienciesForChild(strString, strString1, isFormPreviewMode){
        console.log('Data ::: ', JSON.stringify(strString));
        this.isFormPreviewMode = isFormPreviewMode
        this.wageDefInfoData = strString
        strString1 != undefined || strString1 != null || strString1 != '' ? strString1.length > 0 ? this.renderWageDefSection.length = 0 : '' : ''
        //this.renderWageDefSection.length = 0
        this.isRenderWageDef = true
        if(strString1 != undefined || strString1 != null || strString1 != ''){
            for(let i = 0;i < strString1.length;i++){
                this.isRenderWageDef = false
                this.renderWageDefSection.push(strString1[i])
            }
        }
        this.flag1 = this.renderWageDefSection.length
        this.isRenderWageDef = true
        this.isRenderedCallback = true;
    }

    // Validity event checker for the child cmp
    handleWageDeficienciesValidityChecker(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
    }

    @api vtCaseIssues;
    @api overTimeCaseIssueObj;
    // Handle wage deficiencies Information event
    handleWageDeficienciesInfo(event){
        const result = event.detail;
        const wageDefInfoData = result.wageDefInfoObj
        this.overTimeCaseIssueObj = result.overTimeCaseIssueObj;
        console.log('wageDefInfoData', JSON.stringify(wageDefInfoData))
        this.wageDefSectionValues = wageDefInfoData
        
        this.wageDefDetails.length = 0
        this.wageDefDetails.push(result.wageDefInfoObj)
        this.vtCaseIssues = result.vtCaseIssues;
        console.log('wageDefDetails :::: ', JSON.stringify(result.vtCaseIssues))
        console.log('wageDefSectionValues:', JSON.stringify(this.wageDefSectionValues));
    }

     // Toast msg
     showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }


    @api get empWorkingDateValid(){
        return this.quitDate === true || this.DishargedDate === true;
    }

    @api quitDate
    @api DishargedDate
    // Get Employement and Status values from the parent component.
    @api
    handleEmpStatusValue(quitDate, DishargedDate){
        this.quitDate = quitDate;
        this.DishargedDate = DishargedDate;
        console.log('date in parent ::: ', quitDate);
        const temp = this.iswagedefpreview === true ? this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Preview-Garment-Cmp') : this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Container-Garment-Cmp');
        for(var i=0; i<temp.length; i++){
            temp[i].handleEmpStatusValue(this.quitDate, this.DishargedDate)
        }
    }

    // RenderedCallback call
    renderedCallback(){
        if(this.isAddDefChanged === true){
            const temp = this.iswagedefpreview === true ? this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Preview-Garment-Cmp') : this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Container-Garment-Cmp');
            for(var i=0; i<temp.length; i++){
                temp[i].handleEmpStatusValue(this.quitDate, this.DishargedDate)
            }
            this.isAddDefChanged = false;
        }
        if(this.isRenderedCallback === true && this.wageDefInfoData !== undefined){
                const employeesDetails = this.wageDefInfoData
                console.log('Wage wageDefInfoData in wageChild', this.wageDefInfoData)
                const details = this.iswagedefpreview === true ? this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Preview-Garment-Cmp') : this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Container-Garment-Cmp')
                    for (let i = 0; i < details.length; i++){
                    details[i].handleWageDeficienciesChildData(employeesDetails[i],this.isFormPreviewMode)
                }
        }
        this.isRenderedCallback = false

        if(this.isWageDefSectionDeleted === true){
            const wageDefDetails = this.wageDefSectionDataAfterDelete
            const wageDefSectionDetails = this.iswagedefpreview === true ? this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Preview-Garment-Cmp') : this.template.querySelectorAll('c-owc-Wage-Deficiencies-Child-Container-Garment-Cmp')
            for (let i = 0; i < wageDefSectionDetails.length; i++){
                wageDefSectionDetails[i].handleWageDeficienciesChildData(wageDefDetails[i])
            }
            this.isWageDefSectionDeleted = false
        }
    }
}