import { LightningElement,api,wire,track } from 'lwc';
import { radioOptions, customLabelValues } from 'c/owcUtils';
import fetchMap from '@salesforce/apex/OwcInfoSection.getIndustry';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import subIndustryCat from '@salesforce/apex/OwcInfoSection.getnaics';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';

export default class IndustryInfoCmp extends LightningElement {                 
    @track isAttributeRequired = true;
    @api isIndustrySpec = false; //boolean var for industry sub selection
    @api isHouseDomesticWorker = false; //boolean var for house domestic worker
    @api isHousePersonalAttendent = false;//boolean var for house personal attendent
    @api isFacilityPersonalAttendent = false; // boolean var for facility personal attendent
    @api isFarmLaborContractors = false;  // boolean var to store wheather the industry matches the required industry or not
    @api isYouFarmLaborer = false; // boolean var use to store the answer of the person
    @api isHeatRecPeriod = false; //boolean var for heat Recovery period
    @api isSelectedSubIndustry = false;
    @api value = [];
    @api industryMapdata;
    @api industryMap;
    @api selectedValues=[];
    @api selectedIndustry;
    @api isIndustrySelected
    @api selectedOption;
    @api farmWorker;
    @api heatRecovery;
    @api separateHeatRecovery;
    @api writtenReqDate;
    @api statementDate;
    @api empStatementProvided;
    @api isEmployerProvideStatement = false;
    @api domesticWorkType;
    @api domesticWorkHome;
    @api domesticRegisteredNurse;
    @api domesticLiveInWorkHome;
    @api domesticSentByHomeAgency;
    @api personalAttendentWorkType;
    @api personalAttendentWorkHome;
    @api personalAttendentRegisteredNurse;
    @api personalAttendentLiveInWorkHome;
    @api personalAttendentSentByHomeAgency;
    @api facilityPersonalAttendentWorkType;
    @api facilityWorkResidential;
    @api facilityAttendentRegisteredNurse;
    @api isRenderedCallback = false
    @api isDomesticWorkInHome = false;
    @api isSuccessor = false;
    @api isCarWash = false;
    @api successorBusinessName;
    @api successorStreetAddress;
    @api successorCity;
    @api successorState;
    @api successorZipCode;
    @api successorBusinessPhone;
    @api successorEmail;
    @api successorVehicleLicense;
    @api successorWebsite;
    @api isLabelsInfo = false;
    @api islabelPercPerDay = false;
    @api isPublicHouseKeeping = false;
    @api owcClaiment;
    @api claimUserInfo;
    @api listOfDuties;
    @api OtherIndividualConstructionTrades
    @api isCSLBShow = false
    @api paidBreaks
    // HelpText Attributes
    @api isHelpText = false
    @api helpText
    @api isNotChangedCurrentStep = false
    @api thirdcomponentrender = false
    @api rateOfCompensation
    @api isRateOfCompensation = false
    @api isFormPreviewMode = false;

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
    

    customLabelValues = customLabelValues 
    
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    // Used to get the primary industry options from metadata
    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data, error }){
        if(data){
            this.industryMapdata = data[0].owcPrimaryIndustryOptions;
            }
        else if(error){
            this.showToast('Error!', error.body.message, 'error');
        }
    }

    //Yes or No PickList
    options = radioOptions 

    //FarmSection ValueReset
    restFarmLaborerSectionData(){
        this.isFarmLaborContractors = false
        this.farmWorker = ''
        this.isYouFarmLaborer = false
        this.heatRecovery = ''
        this.isHeatRecPeriod = false
        this.separateHeatRecovery = ''
        this.rateOfCompensation = ''
        this.isRateOfCompensation = false
        this.writtenReqDate = ''
        this.statementDate = ''
        this.empStatementProvided = ''
    }

    resetHouseDomesticWorkerSectionData(){
        this.isHouseDomesticWorker = false
        this.domesticWorkType = ''
        this.domesticWorkHome = ''
        this.isDomesticWorkInHome = false
        this.domesticLiveInWorkHome = ''
        this.domesticSentByHomeAgency = ''
        this.domesticRegisteredNurse = ''
    }

    resetHousePersonalAttendentSectionData(){
        this.isHousePersonalAttendent = false
        this.personalAttendentWorkType = ''
        this.personalAttendentWorkHome = ''
        this.personalAttendentRegisteredNurse = ''
        this.personalAttendentLiveInWorkHome = ''
        this.personalAttendentSentByHomeAgency = ''
    }
    
    resetFacilityPersonalAttendentSectionData(){
        this.isFacilityPersonalAttendent = false
        this.facilityPersonalAttendentWorkType = ''
        this.facilityWorkResidential = ''
        this.facilityAttendentRegisteredNurse = ''
    }

    @api selectedIndustry_es;
    @api selectedIndustryValue;
    @api isGarmentDutyFollow;
    
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) { 
            case 'isGarmentDutyFollow':
                this.isGarmentDutyFollow = event.target.value;
                var garmentDutyId = this.template.querySelector('[data-id="isGarmentDutyFollow"]');
                this.garmentDutyValidity(garmentDutyId, this.isGarmentDutyFollow);
                break; 
            case "OtherIndividualConstructionTrades":
                this.OtherIndividualConstructionTrades = event.target.value;
                console.log('OtherIndividualConstructionTrades ::: ', this.OtherIndividualConstructionTrades)
            break;
            case "paidBreaks":
                this.paidBreaks = event.target.value;
                console.log('paidBreaks ::: ', this.paidBreaks)
            break;
            case "rateOfCompensation":
                this.rateOfCompensation = event.target.value;
                console.log('rateOfCompensation ::: ', this.rateOfCompensation)
                if(this.rateOfCompensation === this.options[0].value){
                    this.isRateOfCompensation = true;
                }
                else{
                    this.isRateOfCompensation = false
                }
                break;
            case "industryInfoCategory":
                this.selectedIndustryValue = event.target.value;
                const selectedOption = (this.industryMapdata.filter( item => {
                    return (item.value === event.target.value);
                }));
                this.selectedIndustry = (Boolean(selectedOption) && selectedOption.length > 0) ? selectedOption[0].value2 : '';
                this.selectedIndustry_es = (Boolean(selectedOption) && selectedOption.length > 0) ? selectedOption[0].label : '';
                this.isIndustrySpec = true;
                this.isIndustrySelected = true
                this.isFarmLaborContractors = false;
                this.isHouseDomesticWorker = false;
                this.isHousePersonalAttendent = false;
                this.isFacilityPersonalAttendent = false;
                this.isSuccessor = false;
                this.isCarWash = false;
                this.isLabelsInfo = false;
                this.islabelPercPerDay = false;
                this.selectedValues=[];
                (this.selectedIndustry === 'Construction') ? this.isCSLBShow = true : this.isCSLBShow = false;
            
                if(this.selectedIndustry === "Agriculture") {
                        this.isSelectedSubIndustry = true;
                        this.isFarmLaborContractors = true;
                        this.isHouseDomesticWorker = false;
                        this.isFacilityPersonalAttendent = false;
                        this.isHousePersonalAttendent = false;
                        this.isSuccessor = false;
                        this.isCarWash = false;
                        this.islabelPercPerDay = false;
                        this.isLabelsInfo = false;
                        this.isPublicHouseKeeping = false;
                        this.resetHouseDomesticWorkerSectionData()
                        this.resetHousePersonalAttendentSectionData()
                        this.resetFacilityPersonalAttendentSectionData()
                        console.log("isFcl:::"+this.isFCL);
                }else if(this.selectedIndustry === "Private Households"){
                    this.isHouseDomesticWorker = true;
                    this.isSelectedSubIndustry = true;
                    this.isFarmLaborContractors = false;
                    this.isHousePersonalAttendent = false;
                    this.isSuccessor = false;
                    this.isCarWash = false;
                    this.isLabelsInfo = false;
                    this.islabelPercPerDay = false;
                    this.isPublicHouseKeeping = false;
                    this.restFarmLaborerSectionData()
                    this.resetHousePersonalAttendentSectionData()
                    this.resetFacilityPersonalAttendentSectionData()
                }else if(this.selectedIndustry === "Home Health Care Services"){
                    this.isFacilityPersonalAttendent = true;
                    this.isSelectedSubIndustry = true;
                    this.isHousePersonalAttendent = false;  
                    this.isHouseDomesticWorker = false;
                    this.isFarmLaborContractors = false; 
                    this.isCarWash = false;
                    this.isLabelsInfo = false;
                    this.isPublicHouseKeeping = false;
                    this.restFarmLaborerSectionData()
                    this.resetHouseDomesticWorkerSectionData()
                    this.resetHousePersonalAttendentSectionData()
                }else if(this.selectedIndustry === "Apparel Manufacturing"){
                    this.isSelectedSubIndustry = true;  
                    this.isLabelsInfo = true;
                    this.isCarWash = false;
                    this.isHousePersonalAttendent = false;
                    this.isHouseDomesticWorker = false;
                    this.isFarmLaborContractors = false;
                    this.isPublicHouseKeeping = false; 
                    this.restFarmLaborerSectionData()
                    this.resetHouseDomesticWorkerSectionData()
                    this.resetHousePersonalAttendentSectionData()
                    this.resetFacilityPersonalAttendentSectionData()
                }else if(this.selectedIndustry === "Other Residential Care Facilities"){
                    this.isSuccessor = false;
                    this.isLabelsInfo = false;
                    this.isCarWash = false;
                    this.isHousePersonalAttendent = false;
                    this.isSelectedSubIndustry = true;  
                    this.isHouseDomesticWorker = false;
                    this.isFarmLaborContractors = false; 
                    this.islabelPercPerDay = false;
                    this.isPublicHouseKeeping = true;
                    this.restFarmLaborerSectionData()
                    this.resetHouseDomesticWorkerSectionData()
                    this.resetHousePersonalAttendentSectionData()
                    this.resetFacilityPersonalAttendentSectionData()
                }else{
                    this.isSuccessor = false;
                    this.isLabelsInfo = false;
                    this.isCarWash = false;
                    this.isFacilityPersonalAttendent =false;
                    this.isSelectedSubIndustry = false;
                    this.isFarmLaborContractors = false;
                    this.isHouseDomesticWorker = false;
                    this.isHousePersonalAttendent = false;
                    this.isYouFarmLaborer=false;
                    this.isHeatRecPeriod = false;
                    this.islabelPercPerDay = false;
                    this.isPublicHouseKeeping = false;
                    this.restFarmLaborerSectionData()
                    this.resetHouseDomesticWorkerSectionData()
                    this.resetHousePersonalAttendentSectionData()
                    this.resetFacilityPersonalAttendentSectionData()
                }
                    break;
                    case "farmWorker":            
                        this.farmWorker = event.detail.value;
                        console.log('farmWorker :::', this.farmWorker);
                        if(this.farmWorker === this.options[0].value) {
                                this.isYouFarmLaborer = true;
                        }else if(this.farmWorker === this.options[1].value){
                                this.isYouFarmLaborer = false;
                                this.isHeatRecPeriod = false;
                                this.isEmployerProvideStatement = false;
                                this.isRateOfCompensation = false;
                                this.heatRecovery = null;
                                this.rateOfCompensation = null;
                                this.writtenReqDate = null;
                                this.empStatementProvided = null;
                                this.statementDate = null;
                        }
                    break;
                    case "heatRecovery":            
                        this.heatRecovery = event.detail.value;
                        console.log('heatRecovery :::', this.heatRecovery);
                        if(this.heatRecovery === this.options[0].value){
                            this.isHeatRecPeriod = true;
                            console.log("isHeatRecPeriod::"+this.isHeatRecPeriod);
                        }else{
                            this.isHeatRecPeriod = false;
                            console.log("isHeatRecPeriod::"+this.isHeatRecPeriod);
                        }
                    break;
                    case "separateHeatRecovery":            
                        this.separateHeatRecovery = event.detail.value;
                        console.log('separateHeatRecovery :::', this.separateHeatRecovery);
                    break;
                    case "writtenReqDate":            
                        this.writtenReqDate = event.detail.value;
                        this.handleWrittenRequestDate();
                        console.log('writtenReqDate :::', this.writtenReqDate);
                    break;
                    case "statementDate":            
                        this.statementDate = event.detail.value;
                        this.handleEmployerStatementDate();
                        console.log('statementDate :::', this.statementDate);
                    break;
                    case "empStatementProvided":            
                        this.empStatementProvided = event.detail.value;
                        if(this.empStatementProvided === this.options[0].value){
                            this.isEmployerProvideStatement = true;
                        }
                        else{
                            this.isEmployerProvideStatement = false;
                        }
                        console.log('empStatementProvided :::', this.empStatementProvided);
                    break; 
                    case "domesticWorkType":            
                        this.domesticWorkType = event.detail.value;
                        console.log('domesticWorkType :::', this.domesticWorkType);
                    break;
                    case "domesticWorkHome":            
                        this.domesticWorkHome = event.detail.value;
                        console.log('domesticWorkHome :::', this.domesticWorkHome);
                        if(this.domesticWorkHome === this.options[0].value){
                            this.isDomesticWorkInHome = true;
                        }else{

                            this.isDomesticWorkInHome = false;
                        }
                    break;
                    case "domesticRegisteredNurse":            
                        this.domesticRegisteredNurse = event.detail.value;
                        console.log('domesticRegisteredNurse :::', this.domesticRegisteredNurse);
                    break;
                    case "domesticLiveInWorkHome":            
                        this.domesticLiveInWorkHome = event.detail.value;
                        console.log('domesticLiveInWorkHome :::', this.domesticLiveInWorkHome);
                    break;
                    case "domesticSentByHomeAgency":            
                        this.domesticSentByHomeAgency = event.detail.value;
                        console.log('domesticSentByHomeAgency :::', this.domesticSentByHomeAgency);
                    break;
                    case "personalAttendentWorkType":            
                        this.personalAttendentWorkType = event.detail.value;
                        console.log('personalAttendentWorkType :::', this.personalAttendentWorkType);
                    break;
                    case "personalAttendentWorkHome":            
                        this.personalAttendentWorkHome = event.detail.value;
                        console.log('personalAttendentWorkHome :::', this.personalAttendentWorkHome);
                    break;
                    case "personalAttendentRegisteredNurse":            
                        this.personalAttendentRegisteredNurse = event.detail.value;
                        console.log('personalAttendentRegisteredNurse :::', this.personalAttendentRegisteredNurse);
                    break;
                    case "personalAttendentLiveInWorkHome":            
                        this.personalAttendentLiveInWorkHome = event.detail.value;
                        console.log('personalAttendentLiveInWorkHome :::', this.personalAttendentLiveInWorkHome);
                    break;
                    case "personalAttendentSentByHomeAgency":            
                        this.personalAttendentSentByHomeAgency = event.detail.value;
                        console.log('personalAttendentSentByHomeAgency :::', this.personalAttendentSentByHomeAgency);
                    break;
                    case "facilityPersonalAttendentWorkType":            
                        this.facilityPersonalAttendentWorkType = event.detail.value;
                        console.log('facilityPersonalAttendentWorkType :::', this.facilityPersonalAttendentWorkType);
                    break; 
                    case "facilityWorkResidential":            
                        this.facilityWorkResidential = event.detail.value;
                        console.log('facilityWorkResidential :::', this.facilityWorkResidential);
                    break;
                    case "facilityAttendentRegisteredNurse":            
                        this.facilityAttendentRegisteredNurse = event.detail.value;
                        console.log('facilityAttendentRegisteredNurse :::', this.facilityAttendentRegisteredNurse);
                    break;
                    case "listOfDuties":
                        this.listOfDuties = event.detail.value;
                        this.handleListOfDustiesFocus()
                        console.log('listOfDuties ::: ',this.listOfDuties);    
                    break;         

        }
    }

    garmentDutyValidity(ids, values){
        let id = ids
        let value = values
        console.log('Data:', value);
        if(value == undefined || value == null || value == ''){
            id.setCustomValidity(this.customLabelValues.OWC_required_field_error_msg);
            id.reportValidity();
            this.isGarmentDutyCheck = true;
        }
        else{
            id.setCustomValidity();
            id.reportValidity();
            this.isGarmentDutyCheck = false
        }
    }

    infoSectionValidityChecker(ids, values){
        let id = ids
        let value = values
        console.log('Data:', value);
        if(value == undefined || value == null || value == ''){
            id.setCustomValidity(this.customLabelValues.OWC_required_field_error_msg);
            id.reportValidity();
            return true;
        }
        else{
            return false
        }
    }

    isdomesticWorkType = false
    isdomesticWorkHome = false
    isdomesticRegisteredNurse = false
    isdomesticLiveInWorkHome = false
    isdomesticSentByHomeAgency = false
    ispersonalAttendentWorkType = false
    ispersonalAttendentWorkHome = false
    ispersonalAttendentRegisteredNurse = false
    ispersonalAttendentLiveInWorkHome = false
    ispersonalAttendentSentByHomeAgency = false
    isfacilityPersonalAttendentWorkType = false
    isfacilityWorkResidential = false
    isfarmWorker = false
    isheatRecovery = false
    isseparateHeatRecovery = false
    isselectedIndus = false
    isselectedSubIndus = false
    isfacilityAttendentRegisteredNurse = false
    isDutiesList = false
    iswrittenReqDate = false
    isstatementDate = false
    
    handleWrittenRequestDate(){
        let writtenReqDate = this.template.querySelector('[data-id="writtenReqDate"]');
        let id = writtenReqDate
        let value = writtenReqDate.value
        var inputDate
        var today = new Date();
        if(value != null){
            inputDate = new Date(value.toString());
            this.iswrittenReqDate = true;
        }
        else{
            inputDate = value;
            this.iswrittenReqDate = false;
        }
        if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            writtenReqDate.setCustomValidity(this.customLabelValues.OWC_pastdate_error_msg);
            this.iswrittenReqDate = true;
        }
        else{
            writtenReqDate.setCustomValidity('');
            this.iswrittenReqDate = false;
        }
        writtenReqDate.reportValidity();
    }

    handleEmployerStatementDate(){
        let statementDate = this.template.querySelector('[data-id="statementDate"]');
        let id = statementDate
        let value = statementDate.value
        var inputDate
        var today = new Date();
        if(value != null){
            inputDate = new Date(value.toString());
            this.isstatementDate = true;
        }
        else{
            inputDate = value;
            this.isstatementDate = false;
        }
        if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            statementDate.setCustomValidity(this.customLabelValues.OWC_pastdate_error_msg);
            this.isstatementDate = true;
        }
        else{
            statementDate.setCustomValidity('');
            this.isstatementDate = false;
        }
        statementDate.reportValidity();
    }

    handleWrittenOrStatementDateFocus(){
        // let statementDate = this.template.querySelector('[data-id="statementDate"]');
        // let statementDateValue = statementDate.value
        // this.industryInfoDatePickerValidityChecker(statementDate, statementDateValue);
        let statementDate = this.template.querySelector('[data-id="statementDate"]');
        let writtenReqDate = this.template.querySelector('[data-id="writtenReqDate"]');
        let id = statementDate
        let value = statementDate.value
        var inputStartDate
        var inputEndDate
        var today = new Date();
        if(value != null){
            inputEndDate = new Date(value.toString());
            inputStartDate = new Date(writtenReqDate.value.toString())
        }
        else{
            inputEndDate = value;
            inputStartDate = inputStartDate.value;
        }
        if(inputEndDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            statementDate.setCustomValidity(this.customLabelValues.OWC_pastdate_error_msg);
            statementDate.reportValidity();
        }
        if(inputStartDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            writtenReqDate.setCustomValidity(this.customLabelValues.OWC_pastdate_error_msg);
            writtenReqDate.reportValidity();
        }
        // else if(inputStartDate.setHours(0,0,0,0) > inputEndDate.setHours(0,0,0,0)){
        //     statementDate.setCustomValidity(this.customLabelValues.OWC_farmlabor_statementprovideddate_error_msg)
        //     writtenReqDate.setCustomValidity(this.customLabelValues.OWC_farmlabor_statementprovideddate_error_msg)
        //     statementDate.reportValidity();
        //     writtenReqDate.reportValidity();
        // }
        else{
            statementDate.setCustomValidity('');
            writtenReqDate.setCustomValidity('');
            statementDate.reportValidity();
            writtenReqDate.reportValidity();
        }
    }

    industryInfoDatePickerValidityChecker(ids, values){
        let id = ids
        let value = values
        var inputDate
        var today = new Date();
        if(value != null){
            inputDate = new Date(value.toString());
        }
        else{
            inputDate = value;
        }
        if(value == null || value == undefined || value == ''){
            id.setCustomValidity('')
            id.reportValidity();
        return false;
        }
        else if(inputDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(this.customLabelValues.OWC_pastdate_error_msg);
            id.reportValidity();
        return true;
        }
    }

    handleSaveAsDraft(){
        this.prepareIndustryJSONObj();
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "2"
            }
        });
        this.dispatchEvent(validateEvent);
    }

    prepareIndustryJSONObj(){
        return {
            sectionId : "2",
            isCSLBShow : this.isCSLBShow,
            paidBreaks : this.paidBreaks,
            isEmployerProvideStatement : this.isEmployerProvideStatement,
            OtherIndividualConstructionTrades : this.OtherIndividualConstructionTrades,
            selectedIndustry : this.selectedIndustry,
            isIndustrySpec : this.isIndustrySpec,
            isFarmLaborContractors : this.isFarmLaborContractors,
            selectedOption : this.selectedOption,
            rateOfCompensation : this.rateOfCompensation,
            isRateOfCompensation : this.isRateOfCompensation,
            farmWorker : this.farmWorker,
            isYouFarmLaborer : this.isYouFarmLaborer,
            isFacilityPersonalAttendent : this.isFacilityPersonalAttendent,
            heatRecovery : this.heatRecovery,
            isHeatRecPeriod : this.isHeatRecPeriod,
            separateHeatRecovery : this.separateHeatRecovery,
            writtenReqDate : this.writtenReqDate,
            statementDate : this.statementDate,
            empStatementProvided : this.empStatementProvided,
            domesticWorkType : this.domesticWorkType,
            isHouseDomesticWorker : this.isHouseDomesticWorker,
            isHousePersonalAttendent : this.isHousePersonalAttendent,
            domesticWorkHome : this.domesticWorkHome,
            isDomesticWorkInHome : this.isDomesticWorkInHome|| '',
            domesticRegisteredNurse : this.domesticRegisteredNurse,
            domesticLiveInWorkHome : this.domesticLiveInWorkHome,
            domesticSentByHomeAgency : this.domesticSentByHomeAgency,
            personalAttendentWorkType : this.personalAttendentWorkType,
            personalAttendentWorkHome : this.personalAttendentWorkHome,
            personalAttendentRegisteredNurse : this.personalAttendentRegisteredNurse,
            personalAttendentLiveInWorkHome : this.personalAttendentLiveInWorkHome,
            personalAttendentSentByHomeAgency : this.personalAttendentSentByHomeAgency,
            facilityPersonalAttendentWorkType : this.facilityPersonalAttendentWorkType,
            facilityWorkResidential : this.facilityWorkResidential,
            facilityAttendentRegisteredNurse : this.facilityAttendentRegisteredNurse,
            isLabelsInfo : this.isLabelsInfo,
            isPublicHouseKeeping : this.isPublicHouseKeeping,
            claimUserInfo : this.claimUserInfo,
            selectedOption_es : this.selectedOption_es,
            isClaimantAdvocate : this.isClaimantAdvocate,
            isClaimantGarment : this.isClaimantGarment,
            listOfDuties : this.listOfDuties,
            labelDetails : this.labelDetails,
            successorDetails : this.successorDetails,
            selectedIndustry_es : this.selectedIndustry_es,
            selectedIndustryValue : this.selectedIndustryValue,
            isGarmentDutyFollow : this.isGarmentDutyFollow,
            isNotChangedCurrentStep : this.isNotChangedCurrentStep|| '',
            successorSectionValues : this.successorSectionValues,
            renderSuccessorSection : this.renderSuccessorSection,
            labelInformationSectionValues : this.labelInformationSectionValues,
            renderLabelInformationSection : this.renderLabelInformationSection,
        }
    }

    handleinfoEvent(){
            
        const selectEvent = new CustomEvent('infoindustrycustomevent', {
            detail: this.prepareIndustryJSONObj()
        });
        this.dispatchEvent(selectEvent);
    }

    empStatementProvidedValue = false

    handleListOfDustiesFocus(event){
        const listOfDutiesValue = this.listOfDuties == undefined || this.listOfDuties == null ? '' : this.listOfDuties.trim()
        const DutiesList = this.template.querySelector('[data-id="listOfDuties"]');
        if(listOfDutiesValue == ''){
                DutiesList.setCustomValidity(this.customLabelValues.OWC_required_field_error_msg)  
            }
            else{
                DutiesList.setCustomValidity('')  
            }
            DutiesList.reportValidity()
    }
    
    isSuccessorDateAcceptable = false
    isWrittenRateRequiredCheck = false

    // handleWrittenRateValidityChecker(){
    //     let statementDate = this.template.querySelector('[data-id="statementDate"]');
    //     let empStatementProvided = this.template.querySelector('[data-id="empStatementProvided"]');
    //     if((statementDate.value === undefined || statementDate.value === null || statementDate.value === '') || (empStatementProvided.value === undefined || empStatementProvided.value === null || empStatementProvided .value === '')){
    //         empStatementProvided.setCustomValidity('Complete atleast one field.');
    //         statementDate.setCustomValidity('Complete atleast one field.');
    //         empStatementProvided.reportValidity();
    //         statementDate.reportValidity();
    //         return true
    //     }
    //     else{
    //         empStatementProvided.setCustomValidity('');
    //         statementDate.setCustomValidity('');
    //         empStatementProvided.reportValidity();
    //         statementDate.reportValidity();
    //         return false
    //     }
    // }
    @api isGarmentDutyCheck = false;

    @api 
    owcInformationDataForParent(){
        const listOfDutiesValue = this.listOfDuties == undefined || this.listOfDuties == null ? '' : this.listOfDuties.trim()
        //this.handleinfoEvent();
        if(this.isFarmLaborContractors === true && this.isRateOfCompensation === true){
            let writtenReqDate = this.template.querySelector('[data-id="writtenReqDate"]');
            let statementDate = this.template.querySelector('[data-id="statementDate"]');
            this.handleWrittenRequestDate();
            if(this.isEmployerProvideStatement === true){
                this.handleEmployerStatementDate();
            }
            
            this.iswrittenReqDate === true ? writtenReqDate.focus() : ''
            this.isstatementDate === true ? statementDate.focus() : ''
            
        }
        
        if(Boolean(this.isLabelsInfo) && this.isLabelsInfo === true){
            var garmentDutyId = this.template.querySelector('[data-id="isGarmentDutyFollow"]');
            if(Boolean(garmentDutyId.value)){
                garmentDutyId.setCustomValidity();
                garmentDutyId.reportValidity();
                this.isGarmentDutyCheck = false;
            }
            else{
                garmentDutyId.setCustomValidity(this.customLabelValues.OWC_required_field_error_msg);
                garmentDutyId.reportValidity();
                this.isGarmentDutyCheck = true;
            }
           // this.isGarmentDutyCheck = this.garmentDutyValidity(garmentDutyId, this.isGarmentDutyFollow);
            (Boolean(this.isGarmentDutyCheck) && this.isGarmentDutyCheck === true) ? garmentDutyId.focus() : this.isGarmentDutyCheck = false
        }
        
        if(listOfDutiesValue == ''){
                let DutiesList = this.template.querySelector('[data-id="listOfDuties"]');
                DutiesList.setCustomValidity(this.customLabelValues.OWC_required_field_error_msg)  
                DutiesList.reportValidity()
                this.isDutiesList = true
            }
            else{
                this.isDutiesList = false
            }

          //  this.isDutiesList === true ? DutiesList.focus() : this.isDutiesList = false
        
        (this.iswrittenReqDate === true || this.isstatementDate === true || this.isGarmentDutyCheck === true || this.isDutiesList === true) ? this.fireValidityEvent() : this.handleinfoEvent();
    }

    fireValidityEvent(){
        const selectEvent = new CustomEvent('infoindustryvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.dispatchEvent(selectEvent);
    }

    @api industryInfoSectionDetails

    @api
    owcIndustryInfoForChild(strString,isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode
        this.industryInfoSectionDetails = strString
        console.log('renderLabelInformationSection in renderBack ::: ', JSON.stringify(strString.renderLabelInformationSection))
        if(isNaN(strString.selectedIndustry)){
            this.template.querySelector('[data-id="industryInfoCategory"]').value = strString.selectedIndustry
            this.selectedIndustry = strString.selectedIndustry
        }
        this.isEmployerProvideStatement = strString.isEmployerProvideStatement
        this.isCSLBShow = strString.isCSLBShow
        this.rateOfCompensation = strString.rateOfCompensation
        this.isRateOfCompensation = strString.isRateOfCompensation
        this.isIndustrySpec =  strString.isIndustrySpec 
        this.isFarmLaborContractors =  strString.isFarmLaborContractors
        this.farmWorker =  strString.farmWorker
        this.isFacilityPersonalAttendent =  strString.isFacilityPersonalAttendent
        this.facilityPersonalAttendentWorkType =  strString.facilityPersonalAttendentWorkType
        this.facilityWorkResidential =  strString.facilityWorkResidential
        this.facilityAttendentRegisteredNurse = strString.facilityAttendentRegisteredNurse
        this.isHeatRecPeriod =  strString.isHeatRecPeriod
        this.heatRecovery =  strString.heatRecovery
        this.selectedIndustry_es = strString.selectedIndustry_es
        this.isGarmentDutyFollow = strString.isGarmentDutyFollow
        this.selectedIndustryValue = strString.selectedIndustryValue
        this.separateHeatRecovery =  strString.separateHeatRecovery
        this.isYouFarmLaborer =  strString.isYouFarmLaborer
        this.writtenReqDate =  strString.writtenReqDate
        this.statementDate =  strString.statementDate
        this.empStatementProvided =  strString.empStatementProvided
        this.domesticWorkType =  strString.domesticWorkType
        this.isHouseDomesticWorker =  strString.isHouseDomesticWorker
        this.isHousePersonalAttendent =  strString.isHousePersonalAttendent
        this.domesticWorkHome =  strString.domesticWorkHome
        this.isDomesticWorkInHome = strString.isDomesticWorkInHome
        this.domesticLiveInWorkHome =  strString.domesticLiveInWorkHome
        this.domesticRegisteredNurse =  strString.domesticRegisteredNurse
        this.domesticSentByHomeAgency =  strString.domesticSentByHomeAgency
        this.personalAttendentWorkType =  strString.personalAttendentWorkType
        this.personalAttendentWorkHome =  strString.personalAttendentWorkHome
        this.personalAttendentRegisteredNurse =  strString.personalAttendentRegisteredNurse
        this.personalAttendentLiveInWorkHome =  strString.personalAttendentLiveInWorkHome
        this.personalAttendentSentByHomeAgency =  strString.personalAttendentSentByHomeAgency
        this.OtherIndividualConstructionTrades = strString.OtherIndividualConstructionTrades
        this.isLabelsInfo =  strString.isLabelsInfo
        this.claimUserInfo =  strString.claimUserInfo
        this.selectedOption_es = strString.selectedOption_es
        this.isClaimantAdvocate =  strString.isClaimantAdvocate
        this.isClaimantGarment =  strString.isClaimantGarment
        this.listOfDuties =  strString.listOfDuties
        this.isPublicHouseKeeping = strString.isPublicHouseKeeping
        this.isNotChangedCurrentStep = strString.isNotChangedCurrentStep
        this.paidBreaks = strString.paidBreaks

        if(isNaN(strString.selectedOption)){
            console.log('selectedOption:', this.selectedOption);
            this.selectedValues=[];
            subIndustryCat({industryName : strString.selectedIndustry})
                .then(Data => {
                        console.log('Data', Data);
                        this.selectedValues = Data;
                })
            console.log('selectedValues:', JSON.stringify(this.selectedValues));
            this.selectedOption = strString.selectedOption;
        }
        // this.handleLabelInformation(strString.labelInformationSectionValues, strString.renderLabelInformationSection)
        // if(isNaN(strString.labelDetails)){
        //     this.handleLabelInformation(strString.labelDetails, strString.renderLabelInformationSection)
        // }
        // if(isNaN(strString.successorDetails)){
        //     this.handleSuccessor(strString.successorDetails, strString.renderSuccessorSection)
        // }
        this.isRenderedCallback = true

    }

    //@api isClaimantAdvocate = false
    @api isClaimantGarment = false

    @api
    owcClaimentInfo(strString){
        console.log('owcClaimentInfoValue :::', strString);
        if(strString == "Yourself"){
            this.isClaimantAdvocate = true
        }else if(strString == "Representative"){
            this.isClaimantAdvocate = false
        }
    }

    renderedCallback(){
            if(this.isRenderedCallback === true && this.isRateOfCompensation === true){
                this.rateOfCompensation ? this.template.querySelector('[data-id="rateOfCompensation"]').value = this.rateOfCompensation : ''
            }
            // if(this.selectedOption != undefined && this.isRenderedCallback === true){
            //     this.template.querySelector('[data-id="industrySubFields"]').value = this.selectedOption
            // }
            // else if(this.selectedValues != undefined && this.isRenderedCallback === true && this.selectedValues[0] != undefined){
            //     this.template.querySelector('[data-id="industrySubFields"]').value = this.selectedValues[0]
            // }
            if(this.isRenderedCallback === true && Boolean(this.isGarmentDutyFollow)){
                this.template.querySelector('[data-id="isGarmentDutyFollow"]').value = this.isGarmentDutyFollow
            }
            if(this.farmWorker && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="farmWorker"]').value = this.farmWorker
            }
            if(this.facilityWorkResidential && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="facilityWorkResidential"]').value = this.facilityWorkResidential
            }
            if(this.heatRecovery && this.isRenderedCallback === true && this.isYouFarmLaborer === true){
                this.template.querySelector('[data-id="heatRecovery"]').value = this.heatRecovery
            }
            if(this.paidBreaks && this.isRenderedCallback === true && this.isYouFarmLaborer === true){
                this.template.querySelector('[data-id="paidBreaks"]').value = this.paidBreaks
            }
            if(this.separateHeatRecovery && this.isRenderedCallback === true && this.isHeatRecPeriod === true){
                this.template.querySelector('[data-id="separateHeatRecovery"]').value = this.separateHeatRecovery
            }
            if(this.writtenReqDate && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="writtenReqDate"]').value = this.writtenReqDate
            }
            if(this.statementDate && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="statementDate"]').value = this.statementDate
            }
            if(this.empStatementProvided && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="empStatementProvided"]').value = this.empStatementProvided
            }
            if(this.domesticWorkHome && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="domesticWorkHome"]').value = this.domesticWorkHome
            }
            if(this.domesticRegisteredNurse && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="domesticRegisteredNurse"]').value = this.domesticRegisteredNurse
            }
            if(this.domesticLiveInWorkHome && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="domesticLiveInWorkHome"]').value = this.domesticLiveInWorkHome
            }
            if(this.domesticSentByHomeAgency && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="domesticSentByHomeAgency"]').value = this.domesticSentByHomeAgency
            }
            if(this.personalAttendentWorkHome && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="personalAttendentWorkHome"]').value = this.personalAttendentWorkHome
            }
            if(this.personalAttendentRegisteredNurse && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="personalAttendentRegisteredNurse"]').value = this.personalAttendentRegisteredNurse
            }
            if(this.personalAttendentLiveInWorkHome && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="personalAttendentLiveInWorkHome"]').value = this.personalAttendentLiveInWorkHome
            }
            if(this.personalAttendentSentByHomeAgency && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="personalAttendentSentByHomeAgency"]').value = this.personalAttendentSentByHomeAgency
            }
            if(this.facilityAttendentRegisteredNurse && this.isRenderedCallback === true){
                this.template.querySelector('[data-id="facilityAttendentRegisteredNurse"]').value = this.facilityAttendentRegisteredNurse
            }
            if(this.isRenderedCallback === true && this.isIndustrySpec === true && this.isLabelsInfo === true && this.isClaimantAdvocate === true){
                // this.template.querySelector('c-owc-Label-Section-Cmp').owcLabelDataForParent()
                // this.template.querySelector('c-owc-Successor-Section-Cmp').owcSuccessorDataForParent()
            }
            
            // if(this.isRenderSuccessor === true){
            //         const successorDetails = this.successordata
            //         const successorSectionDetails = this.template.querySelectorAll('c-owc-Successor-Section-Cmp')
            //         for (let i = 0; i < successorSectionDetails.length; i++){
            //             successorSectionDetails[i].owcSucessorInfoForChild(successorDetails[i])
            //         }
            //         this.isRenderSuccessor = false
            //     }
            // if(this.isSuccessorSectionDeleted === true){
            //     const successorDetails = this.successorSectionDataAfterDelete
            //     const successorSectionDetails = this.template.querySelectorAll('c-owc-Successor-Section-Cmp')
            //     for (let i = 0; i < successorSectionDetails.length; i++){
            //         successorSectionDetails[i].owcSucessorInfoForChild(successorDetails[i])
            //     }
            //     this.isSuccessorSectionDeleted = false
            // }
            
    }


    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === 'ConstructionTradesHelpText'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_ContractionTrade_Helptext;
        }
        else if(learnMoreName === "farmLaborerHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_industryinfo_farmlaborerhelptext;
        }
        else if(learnMoreName === "heatRecPeriodHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_industryinfo_heatrecoveryperiodshelptext;
        }
        else if(learnMoreName === "domesticWokerHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_industryinfo_domesticworkerhelptext;
        }else if(learnMoreName === "personalAttendentHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_industryinfo_personalattendenthelptext;
        }else if(learnMoreName === "facilityAttendentHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_industryinfo_facilitypersonalattendenthelptext;
        }else if(learnMoreName === "publicHousekeepingHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_industryinfo_publichousekeepinghelptext;
        }
    }

    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        console.log('helpTextValue:', JSON.stringify(helpTextValue));
        this.isHelpText = helpTextValue.isClosedHelpText
    }
    
    // handleFocus(evt){
    //             var dataId = evt.target.getAttribute('data-id');
    //             switch (dataId) {
    //                 case "listOfDuties":
    //                     let listOfDuties = this.template.querySelector('[data-id="listOfDuties"]');
    //                     if(listOfDuties.value == undefined || listOfDuties.value == null || listOfDuties.value == ''){
    //                         listOfDuties.setCustomValidity(this.customLabelValues.OWC_required_field_error_msg);
    //                     }
    //                     else{
    //                         listOfDuties.setCustomValidity("");
    //                     }
    //                     listOfDuties.reportValidity();
    //                 break;
    //             }
    // }

 

}