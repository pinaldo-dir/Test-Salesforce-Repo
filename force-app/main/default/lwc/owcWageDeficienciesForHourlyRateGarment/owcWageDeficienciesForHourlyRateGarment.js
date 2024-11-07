import { LightningElement, api, track, wire } from 'lwc';
import { radioOptions, acceptedFileFormat, customLabelValues } from 'c/owcUtils';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import insertUploadedFiles from '@salesforce/apex/OWCMultipleFileUploadController.insertUploadedFiles';
const MAX_FILE_SIZE = 25000000;  ///20MB in Bytes
const CHUNK_SIZE = 750000;
let fileSize=0;

export default class OwcWageDeficienciesForHourlyRateGarment extends LightningElement {
    @track fileNames = '';
    @track filesUploaded = [];

    @api sectionid;
    @api violationTypeVariablesForOneHourlyRate;
    @api violationTypeVariablesForOneSalaryRate;
    @api violationTypeVariablesForDifferentHourlyRate;
    @api violationTypeVariablesForOnePieceRate;
    @api violationTypeVariablesForDifferentPieceRate;
    @api violationTypeVariablesForUnknownPieceRate;
    @api violationTypeVariablesForCommissionRateUpload;
    @api violationTypeVariablesForCommissionRate;
    @api isCommissionAgreementUpload = false;
    @api paymentOfWagesDetails
    @api isOneHourlyRatePOW = false;
    @api isSalaryRatePOW = false;
    @api isRenderedCallback = false;
    @api isOnePieceRatePOW = false;
    @api isDifferentPieceRatePOW = false;
    @api isDifferentHourPOW = false;
    @api isPieceRateUnknown = false;
    @api iswagedefpreview;
    @api isNotCommissionAgreementUpload = false;
    @api minimumWageRate;
    @api wageclaimsubmit;
    @api minimumwagerate
    @api stateminimumwagerate;
    @api localminimumwagerate;
    @api salaryratelist
    @api multiplehourlyrate
    @api hourlyratelist
    @api isRenderOption = false
    @api otherworkcity;
    @api totalSalaryOwed;
    @api minimumrates;
    @api staterate;
    @api isspinner;
    @api isLoading = false;
    @api owedBalanceValue;
    @api paidbreaks;
    @api heatrecovery;
    @track showSpinner = false;
    //Import custom labels
    customLabelValues = customLabelValues

    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

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

        this.isLoading = this.isspinner;
        this.paymentOfWagesDetails = this.paymentofwagedetails

        console.log('hourlyratelist ::: ', JSON.stringify(this.hourlyratelist))
        console.log('salaryratelist ::: ', JSON.stringify(this.salaryratelist))
        console.log('multiplehourlyrate ::: ', JSON.stringify(this.multiplehourlyrate))
        // console.log('checked ::: ', this.minimumWageRate)
        this.isonehourlyrate = true;
        this.islocalminimumwage = true;
        this.isstateminimumwage = true;
        this.showSpinner = true;
        this.handleServerCall();
        // this.handleServerCall();
        // new Promise(
        //     (resolve,reject) => {
        //         setTimeout(()=> {
        //             this.handleServerCall();
        //             resolve();
        //         }, 0);
        //     }).then(
        //         () => this.showSpinner = false
        //     )
          
        // console.log('minimumwagerate in connected ::: ', this.minimumwagerate)
        // { 'hourlyRate' : 0, 'beggingDate' : null, 'endingDate' : null }
        // this.minimumWageRate = this.localminimumwagerate !== null ? this.localminimumwagerate : this.stateminimumwagerate
        
    }

    @api get isonehourlyrate(){
        return this.isOneHourlyRatePOW === true || this.isLocalWageOneHourlyRatePOW === true || this.isStateWageOneHourlyRatePOW === true || this.isOnePieceRatePOW === true || this.isDifferentPieceRatePOW === true || this.isPieceRateUnknown === true ||this.isCommissionAgreementUpload === true || this.isNotCommissionAgreementUpload === true || this.isPieceRateknown === true
    }

    @api get islocalminimumwage(){
        return this.isLocalWageSalaryRatePOW === true || this.isSalaryRatePOW === true || this.isStateWageSalaryRatePOW === true
    }

    @api get isstateminimumwage(){
        return this.isDifferentHourPOW === true || this.isLocalWageDifferentHourPOW === true || this.isStateWageDifferentHourPOW === true
    }

    handleServerCall(){
        if(this.paymentOfWagesDetails.HourlyOptionValue === true){
            this.callOneHourlyRegular();
        }
        else{
            this.violationTypeVariablesForOneHourlyRate = undefined;
            this.isOneHourlyRatePOW = false;
        }
        if(this.paymentOfWagesDetails.salaryRateOptionValue === true){
            this.callSalaryRateRegular();
        }
        else{
            this.violationTypeVariablesForOneSalaryRate = undefined;
            this.isSalaryRatePOW = false;
        }
        if(this.paymentOfWagesDetails.differentHourOptionValue === true){
            this.callMultipleRateRegular();
        }
        else{
            this.violationTypeVariablesForDifferentHourlyRate = undefined;
            this.isDifferentHourPOW = false;
        }
        this.handleHourlyRateOption();
    }

    @track isRegularWage = false
    @track isStateWage = false
    @track isMinimumWage = false
    checkRateForOneHourly(){
        if(this.hourlyratelist !== undefined && this.hourlyratelist.length > 0){
            for(var i=0; i<this.hourlyratelist.length; i++){
                if(this.minimumrates !== undefined && this.minimumrates.length > 0){
                    for(var j=0; j<this.minimumrates.length; j++){
                        if(((this.hourlyratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.hourlyratelist[i].endingDate <= this.minimumrates[j].Effective_Date_To__c)) || ((this.hourlyratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.hourlyratelist[i].endingDate === null)) && (this.hourlyratelist[i].hourlyRate < this.minimumrates[j].Min_Wage_Rate__c)){
                            this.isMinimumWage = true;
                            break;
                        }
                        else{
                            this.isMinimumWage = false;
                        }
                    }
                }
                if(this.isMinimumWage === true){
                    break;
                }
            }
        }
        if(this.isMinimumWage === true){
            if(this.staterate === true){
                this.callOneHourlyState();
            }
            else{
                this.callOneHourlyLocal();
            }
        }
        else{
            this.callOneHourlyRegular();
        }
        this.isLoading = false;
        this.isspinner = false;
        this.hideSpinner();
    }

    async callOneHourlyState(){
        try{
            await this.getAllVilationTypeVariablesForStateOneHourRate('112');
        }catch (error){
            console.log('error', error);
        }
    }

    async callOneHourlyLocal(){
        try{
            await this.getAllVilationTypeVariablesForLocalOneHourRate('111');
        }catch (error){
            console.log('error', error);
        }
    }

    async callOneHourlyRegular(){
        try{
            await this.getAllVilationTypeVariablesForOneHourRate('11');
        }catch (error){
            console.log('error', error);
        }
    }

    @track isSalaryRegularWage = false
    @track isStateWage = false
    @track isSalaryMinimumWage = false
    checkRateForSalaryRate(){
        if(this.salaryratelist !== undefined && this.salaryratelist.length > 0){
            for(var i=0; i<this.salaryratelist.length; i++){
                if(this.minimumrates !== undefined && this.minimumrates.length > 0){
                    for(var j=0; j<this.minimumrates.length; j++){
                        if(((this.salaryratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.salaryratelist[i].endingDate <= this.minimumrates[j].Effective_Date_To__c)) || ((this.salaryratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.salaryratelist[i].endingDate === null)) && (this.salaryratelist[i].hourlyRate < this.minimumrates[j].Min_Wage_Rate__c)){
                            this.isSalaryMinimumWage = true;
                            break;
                        }
                        else{
                            this.isSalaryMinimumWage = false;
                        }
                    }
                }
                if(this.isSalaryMinimumWage === true){
                    break;
                }
            }
        }
        if(this.isSalaryMinimumWage === true){
            if(this.staterate === true){
                this.callSalaryRateState();
            }
            else{
                this.callSalaryRateLocal();
            }
        }
        else{
            this.callSalaryRateRegular();
        }
        this.isLoading = false;
        this.isspinner = false;
        this.hideSpinner();
    }

    async callSalaryRateState(){
        try{
            await this.getAllVilationTypeVariablesForStateSalaryRate('132');
        }catch (error){
            console.log('error', error);
        }
    }

    async callSalaryRateLocal(){
        try{
            await this.getAllVilationTypeVariablesForLocalSalaryRate('131');
        }catch (error){
            console.log('error', error);
        }
    }

    async callSalaryRateRegular(){
        try{
                await this.getAllVilationTypeVariablesForSalaryRate('13');
            }catch (error){
                console.log('error', error);
            }
    }

    @track isSalaryRegularWage = false
    @track isStateWage = false
    @track isMultipleMinimumWage = false
    checkRateForMultipleRate(){
        if(this.multiplehourlyrate !== undefined && this.multiplehourlyrate.length > 0){
            for(var i=0; i<this.multiplehourlyrate.length; i++){
                if(this.minimumrates !== undefined && this.minimumrates.length > 0){
                    for(var j=0; j<this.minimumrates.length; j++){
                        if(((this.multiplehourlyrate[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.multiplehourlyrate[i].endingDate <= this.minimumrates[j].Effective_Date_To__c)) || ((this.multiplehourlyrate[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.multiplehourlyrate[i].endingDate === null)) && (this.multiplehourlyrate[i].hourlyRate < this.minimumrates[j].Min_Wage_Rate__c)){
                            this.isMultipleMinimumWage = true;
                            break;
                        }
                        else{
                            this.isMultipleMinimumWage = false;
                        }
                    }
                }
                if(this.isMultipleMinimumWage === true){
                    break;
                }
            }
        }
        if(this.isMultipleMinimumWage === true){
            if(this.staterate === true){
                this.callMultipleRateState();
            }
            else{
                this.callMultipleRateLocal();
            }
        }
        else{
            this.callMultipleRateRegular();
        }
        this.isLoading = false;
        this.isspinner = false;
        this.hideSpinner();
    }

    hideSpinner(){
        const selectEvent = new CustomEvent('hidehourlyspinner', {
            detail: {
                isSpinner : this.isspinner
            }
        });
        this.dispatchEvent(selectEvent);
    }

    async callMultipleRateState(){
        try{
            await this.getAllVilationTypeVariablesForStateDifferentHour('122');
        }catch (error){
            console.log('error', error);
        }
    }

    async callMultipleRateLocal(){
        try{
            await this.getAllVilationTypeVariablesForLocalDifferentHour('121');
        }catch (error){
            console.log('error', error);
        }
    }

    async callMultipleRateRegular(){
        try{
            await this.getAllVilationTypeVariablesForDifferentHour('12');
        }catch (error){
            console.log('error', error);
        }
    }


    @api isStateWageOneHourlyRatePOW = false;
    @api violationTypeVariablesForStateWageOneHourlyRate
    @api isStateWageSalaryRatePOW = false;
    @api violationTypeVariablesForStateWageOneSalaryRate
    @api isStateWageDifferentHourPOW = false;
    @api isStateWageOneHourlyRateCallback = false;
    @api isStateWageSalaryRateCallback = false;
    @api violationTypeVariablesForStateWageDifferentHourlyRate
    async handleStateWageOption(){
        if(this.paymentOfWagesDetails.HourlyOptionValue === true && (this.hourlyratelist.filter( element => (element < this.stateminimumwagerate) && (element !== null))).length > 0 && this.violationTypeVariablesForStateWageOneHourlyRate === undefined){
            this.isStateWageOneHourlyRateCallback = false;
            
        }
        else{
            if((this.hourlyratelist.filter( element => (element < this.stateminimumwagerate) && (element !== null))).length > 0 && this.isStateWageOneHourlyRateCallback === false && this.violationTypeVariablesForStateWageOneHourlyRate !== undefined){
                this.isStateWageOneHourlyRatePOW = true
            }
            else{
                this.isStateWageOneHourlyRatePOW = false;
                this.violationTypeVariablesForStateWageOneHourlyRate = undefined;
            }
            this.isStateWageOneHourlyRateCallback = true;
        }
        if(this.paymentOfWagesDetails.salaryRateOptionValue === true && (this.salaryratelist.filter( element => (element < this.stateminimumwagerate) && (element !== null))).length > 0 && this.violationTypeVariablesForStateWageOneSalaryRate === undefined){
            this.isStateWageSalaryRateCallback = false;
            try{
                await this.getAllVilationTypeVariablesForStateSalaryRate('132');
            }catch (error){
                console.log('error', error);
            }
        }
        else{
            if((this.salaryratelist.filter( element => (element < this.stateminimumwagerate) && (element !== null))).length > 0 && this.isStateWageSalaryRateCallback === false && this.violationTypeVariablesForStateWageOneSalaryRate !== undefined){
                this.isStateWageSalaryRatePOW = true
            }
            else{
                this.isStateWageSalaryRatePOW = false;
                this.violationTypeVariablesForStateWageOneSalaryRate = undefined;
            }
            this.isStateWageSalaryRateCallback = true;
        }
        
        if(this.paymentOfWagesDetails.differentHourOptionValue === true && (this.multiplehourlyrate.filter( element => (element < this.stateminimumwagerate) && (element !== null))).length > 0 && this.violationTypeVariablesForStateWageDifferentHourlyRate === undefined){
            this.isStateWageDifferentHourCallback = false;
            try{
                await this.getAllVilationTypeVariablesForStateDifferentHour('122');
            }catch (error){
                console.log('error', error);
            }
        }
        else{
            if((this.multiplehourlyrate.filter( element => (element < this.stateminimumwagerate) && (element !== null))).length > 0 && this.isStateWageDifferentHourCallback === false && this.violationTypeVariablesForStateWageDifferentHourlyRate !== undefined){
                this.isStateWageDifferentHourPOW = true
            }
            else{
                this.isStateWageDifferentHourPOW = false;
                this.violationTypeVariablesForStateWageDifferentHourlyRate = undefined;
            }
            this.isStateWageDifferentHourCallback = true;
        }
        this.checkSectionData();
    }

    getAllVilationTypeVariablesForStateOneHourRate(queryCode){
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
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForStateWageOneHourlyRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForStateWageOneHourlyRate = result;
                    this.violationTypeVariablesForStateWageOneHourlyRate.length > 0 ? this.isStateWageOneHourlyRatePOW = true : this.isStateWageOneHourlyRatePOW = false;
                 }
                 this.isspinner = false;
            }
        })
        .catch(error => {
            this.isspinner = false;
            console.log('Error: ', error);
        })
    }

    getAllVilationTypeVariablesForStateSalaryRate(queryCode){
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
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForStateWageOneSalaryRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForStateWageOneSalaryRate = result;
                    this.violationTypeVariablesForStateWageOneSalaryRate.length > 0 ? this.isStateWageSalaryRatePOW = true : this.isStateWageSalaryRatePOW = false;
                 }
                 this.isspinner = false
            }
        })
        .catch(error => {
            this.isspinner = false
            console.log('Error: ', error);
        })
    }

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
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].value = '';
                }
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForStateWageDifferentHourlyRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForStateWageDifferentHourlyRate = result;
                    this.violationTypeVariablesForStateWageDifferentHourlyRate.length > 0 ? this.isStateWageDifferentHourPOW = true : this.isStateWageDifferentHourPOW = false;
                 }
                 this.isspinner = false
            }
        })
        .catch(error => {
            console.log('Error: ', error);
            this.isspinner = false
        })
    }

    @api isLocalWageOneHourlyRatePOW = false;
    @api violationTypeVariablesForLocalWageOneHourlyRate
    @api isLocalWageSalaryRatePOW = false;
    @api isLocalWageOneHourlyCallback = false;
    @api isLocalWageDifferentHourCallback = false
    @api isLocalWageSalaryRateCallback = false;
    @api violationTypeVariablesForLocalWageOneSalaryRate
    @api isLocalWageDifferentHourPOW = false;
    @api violationTypeVariablesForLocalWageDifferentHourlyRate
    async handleLocalWageOption(){
        if(this.paymentOfWagesDetails.HourlyOptionValue === true && (this.hourlyratelist.filter( element => (element < this.localminimumwagerate) && (element !== null))).length > 0 && this.violationTypeVariablesForLocalWageOneHourlyRate === undefined){
            this.isLocalWageOneHourlyCallback = false;
            try{
                await this.getAllVilationTypeVariablesForLocalOneHourRate('111');
            }catch (error){
                console.log('error', error);
            }
        }
        else{
            if((this.hourlyratelist.filter( element => (element > this.localminimumwagerate) && (element !== null))).length > 0 && this.isLocalWageOneHourlyCallback === false && this.violationTypeVariablesForLocalWageOneHourlyRate !== undefined){
                this.isLocalWageOneHourlyRatePOW = true
            }
            else{
                this.violationTypeVariablesForLocalWageOneHourlyRate = undefined;
                this.isLocalWageOneHourlyRatePOW = false;
            }
            this.isLocalWageOneHourlyCallback = true
        }
        if(this.paymentOfWagesDetails.salaryRateOptionValue === true && (this.salaryratelist.filter( element => (element < this.localminimumwagerate) && (element !== null))).length > 0 && this.violationTypeVariablesForLocalWageOneSalaryRate === undefined){
            this.isLocalWageSalaryRateCallback = false;
            try{
                await this.getAllVilationTypeVariablesForLocalSalaryRate('131');
            }catch (error){
                console.log('error', error);
            }
        }
        else{
            if((this.salaryratelist.filter( element => (element < this.localminimumwagerate) && (element !== null))).length > 0 && this.isLocalWageSalaryRateCallback === false && this.violationTypeVariablesForLocalWageOneSalaryRate !== undefined){
                this.isLocalWageSalaryRatePOW = true
            }
            else{
                this.isLocalWageSalaryRatePOW = false;
                this.violationTypeVariablesForLocalWageOneSalaryRate = undefined;
            }
            this.isLocalWageSalaryRateCallback = true;
        }
        
        if(this.paymentOfWagesDetails.differentHourOptionValue === true && (this.multiplehourlyrate.filter( element => (element < this.localminimumwagerate) && (element !== null))).length > 0 && this.violationTypeVariablesForLocalWageDifferentHourlyRate === undefined){
            this.isLocalWageDifferentHourCallback = false;
            try{
                await this.getAllVilationTypeVariablesForLocalDifferentHour('121');
            }catch (error){
                console.log('error', error);
            }
        }
        else{
            if((this.multiplehourlyrate.filter( element => (element < this.localminimumwagerate) && (element !== null))).length > 0 && this.isLocalWageDifferentHourCallback === false && this.violationTypeVariablesForLocalWageDifferentHourlyRate !== undefined){
                this.isLocalWageSalaryRatePOW = true
            }
            else{
                this.isLocalWageDifferentHourPOW = false;
                this.violationTypeVariablesForLocalWageDifferentHourlyRate = undefined;
            }
            this.isLocalWageDifferentHourCallback = true;
        }
    }

    getAllVilationTypeVariablesForLocalOneHourRate(queryCode){
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
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForLocalWageOneHourlyRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForLocalWageOneHourlyRate = result;
                    this.violationTypeVariablesForLocalWageOneHourlyRate.length > 0 ? this.isLocalWageOneHourlyRatePOW = true : this.isLocalWageOneHourlyRatePOW = false;
                 }
                 this.isspinner = false
            }
        })
        .catch(error => {
            this.isspinner = false
            console.log('Error: ', error);
        })
    }

    getAllVilationTypeVariablesForLocalSalaryRate(queryCode){
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
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForLocalWageOneSalaryRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForLocalWageOneSalaryRate = result;
                    this.violationTypeVariablesForLocalWageOneSalaryRate.length > 0 ? this.isLocalWageSalaryRatePOW = true : this.isLocalWageSalaryRatePOW = false;
                    this.otherworkcity !== undefined ? this.violationTypeVariablesForLocalWageOneSalaryRate.forEach( element => element.description === 'CITY WHERE LABOR WAS PERFORMED (with local MW higher than state MW)' ? element.value = this.otherworkcity : '' ) : ''
                    this.minimumWageRate !== undefined ? this.violationTypeVariablesForLocalWageOneSalaryRate.forEach( element => element.description === 'APPLICABLE $ LOCAL MW RATE PER HOUR' ? element.value = this.minimumWageRate : '' ) : ''
                 }
                 this.isspinner = false
            }
        })
        .catch(error => {
            console.log('Error: ', error);
            this.isspinner = false
        })
    }

    getAllVilationTypeVariablesForLocalDifferentHour(queryCode){
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
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForLocalWageDifferentHourlyRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForLocalWageDifferentHourlyRate = result;
                    this.violationTypeVariablesForLocalWageDifferentHourlyRate.length > 0 ? this.isLocalWageDifferentHourPOW = true : this.isLocalWageDifferentHourPOW = false;
                    this.otherworkcity !== undefined ? this.violationTypeVariablesForLocalWageDifferentHourlyRate.forEach( element => element.description === 'CITY WHERE LABOR WAS PERFORMED (with local MW higher than state MW)' ? element.value = this.otherworkcity : '' ) : ''
                 }
                 this.isspinner = false
            }
        })
        .catch(error => {
            console.log('Error: ', error);
            this.isspinner = false
        })
    }

    @api isHelpText= false;
    @api helpText;
    // Help text 
    handleHelpText(event){
        const learnMoreName = event.target.name;
        
        if(learnMoreName === 'pieceRateBalanceOwed'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_piece_rate_owed_helptext;
        }
        else if(learnMoreName === 'commissionRateBalanceOwed'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_commission_rate_owed_helptext;
        }
        else if(learnMoreName === "totalAmountOwed"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_total_owed_helptext;
        }
        else if(learnMoreName === "totalAmountOwedForSalary"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_total_owed_salary_helptext;
        }
        else if(learnMoreName === "totalAmountOwedForDifferent"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_different_owed_help_msg;
        }
    }
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }

    @api isOneHourlyRateCallback = false;
    @api isSalaryRateCallback = false;
    @api isMultipleRateCallback = false;
    @api isMinimumWageAppliedForOneHourly = false
    async handleHourlyRateOption(){
        if(((this.paidbreaks !== undefined || this.paidbreaks === 'No') || (this.heatrecovery !== undefined || this.heatrecovery === 'No')) && (this.paymentOfWagesDetails.isPieceRate === true && this.paymentOfWagesDetails.isProvidePriceRate === false) && (this.wageclaimsubmit === 'Representative')){
            this.isDifferentPieceRatePOW = false;
            this.violationTypeVariablesForDifferentPieceRate = undefined;
            this.isPieceRateUnknown = false;
            this.violationTypeVariablesForUnknownPieceRate = undefined;
            this.isOnePieceRatePOW = false;
            this.violationTypeVariablesForOnePieceRate = undefined;
            this.isPieceRateknown = true;
            try{
                await this.getAllVilationTypeVariablesForKnownPieceRate('154');
            }catch (error){
                console.log('error', error);
            }
        }
        else if(this.paymentOfWagesDetails.isPieceRate === true && this.paymentOfWagesDetails.pieceRateAdditionalDetails.length === 0 && this.violationTypeVariablesForOnePieceRate === undefined && this.paymentOfWagesDetails.isProvidePriceRate === false){
            this.isDifferentPieceRatePOW = false;
            this.violationTypeVariablesForDifferentPieceRate = undefined;
            this.isPieceRateUnknown = false;
            this.violationTypeVariablesForUnknownPieceRate = undefined;
            this.isPieceRateknown = false;
            this.violationTypeVariablesForknownPieceRate = undefined;
            try{
                await this.getAllVilationTypeVariablesOnePieceRate('151');
            }catch (error){
                console.log('error', error);
            }
        }

        else if(this.paymentOfWagesDetails.isPieceRate === true && this.paymentOfWagesDetails.pieceRateAdditionalDetails.length > 0 && this.paymentOfWagesDetails.isProvidePriceRate === false){
            this.isOnePieceRatePOW = false;
            this.violationTypeVariablesForOnePieceRate = undefined;
            this.isPieceRateUnknown = false;
            this.violationTypeVariablesForUnknownPieceRate = undefined;
            this.isPieceRateknown = false;
            this.violationTypeVariablesForknownPieceRate = undefined;
            try{
                await this.getAllVilationTypeVariablesDifferentPieceRate('152');
            }catch (error){
                console.log('error', error);
            }
        }
        else{
            this.isDifferentPieceRatePOW = false;
            this.violationTypeVariablesForDifferentPieceRate = undefined;
            this.isOnePieceRatePOW = false;
            this.violationTypeVariablesForOnePieceRate = undefined;
            this.isPieceRateknown = false;
            this.violationTypeVariablesForknownPieceRate = undefined;
        }
        
        if(this.paymentOfWagesDetails.isProvidePriceRate === true && this.paymentOfWagesDetails.isPieceRate === true){
            this.isPieceRateUnknown = true;
            this.isPieceRateknown = false;
            this.violationTypeVariablesForknownPieceRate = undefined;
            try{
                await this.getAllVilationTypeVariablesUnknownPieceRate('153');
            }catch (error){
                console.log('error', error);
            }
        }
        // else if(this.paymentOfWagesDetails.isProvidePriceRate === false && this.paymentOfWagesDetails.isPieceRate === true){
        //     this.isPieceRateknown = true;
        //     this.isPieceRateUnknown = false;
        //     this.violationTypeVariablesForUnknownPieceRate = undefined;
        //     try{
        //         await this.getAllVilationTypeVariablesForKnownPieceRate('154');
        //     }catch (error){
        //         console.log('error', error);
        //     }
        // }
        else{
            this.isPieceRateUnknown = false;
            this.violationTypeVariablesForUnknownPieceRate = undefined;
        }
        if(this.paymentOfWagesDetails.commissionRateOptionValue === true && (this.paymentOfWagesDetails.agreementDocs === undefined || this.paymentOfWagesDetails.agreementDocs.length === 0)){
            try{
                this.isCommissionAgreementUpload = false;
                this.violationTypeVariablesForCommissionRateUpload = undefined;
                await this.getAllVilationTypeVariablesForCommission('142');
            }catch (error){
                console.log('error', error);
            }
        }
        else if(this.paymentOfWagesDetails.isCommissionRate === true && this.paymentOfWagesDetails.writtenCommission === 'Yes' && this.paymentOfWagesDetails.agreementDocs !== undefined && this.paymentOfWagesDetails.agreementDocs.length > 0){
            this.isNotCommissionAgreementUpload = false;
            this.violationTypeVariablesForCommissionRate = undefined;
            try{
                await this.getAllVilationTypeVariablesForCommissionUpload('141');
            }catch (error){
                console.log('error', error);
            }
        }
        
        else{
            this.isCommissionAgreementUpload = false;
            this.violationTypeVariablesForCommissionRateUpload = undefined;
            this.isNotCommissionAgreementUpload = false;
            this.violationTypeVariablesForCommissionRate = undefined;
        }
    }

    getAllVilationTypeVariablesForCommission(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                this.isLoading = false;
                this.isspinner = false;
                this.hideSpinner();
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
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForCommissionRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForCommissionRate = result;
                    this.violationTypeVariablesForCommissionRate.length > 0 ? this.isNotCommissionAgreementUpload = true : this.isNotCommissionAgreementUpload = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    getAllVilationTypeVariablesForCommissionUpload(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                this.isLoading = false;
                this.isspinner = false;
                this.hideSpinner();
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
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForCommissionRateUpload !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForCommissionRateUpload = result;
                    this.violationTypeVariablesForCommissionRateUpload.length > 0 ? this.isCommissionAgreementUpload = true : this.isCommissionAgreementUpload = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    getAllVilationTypeVariablesForOneHourRate(queryCode){
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
                    // (result[i].value === undefined || result[i].value === null || result[i].value === '') ? result[i].isTempHide = true : result[i].isTempHide = false
                }
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForOneHourlyRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForOneHourlyRate = result;
                    this.violationTypeVariablesForOneHourlyRate.length > 0 ? this.isOneHourlyRatePOW = true : this.isOneHourlyRatePOW = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    getAllVilationTypeVariablesForSalaryRate(queryCode){
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
                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForOneSalaryRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForOneSalaryRate = result;
                    this.violationTypeVariablesForOneSalaryRate.length > 0 ? this.isSalaryRatePOW = true : this.isSalaryRatePOW = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    getAllVilationTypeVariablesForDifferentHour(queryCode){
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
                 console.log('wage def result different hour ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForDifferentHourlyRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForDifferentHourlyRate = result;
                    this.violationTypeVariablesForDifferentHourlyRate.length > 0 ? this.isDifferentHourPOW = true : this.isDifferentHourPOW = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    getAllVilationTypeVariablesOnePieceRate(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                this.isLoading = false;
                this.isspinner = false;
                this.hideSpinner();
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
                 console.log('wage def result different hour ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForOnePieceRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForOnePieceRate = result;
                    this.violationTypeVariablesForOnePieceRate.length > 0 ? this.isOnePieceRatePOW = true : this.isOnePieceRatePOW = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    getAllVilationTypeVariablesDifferentPieceRate(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                this.isLoading = false;
                this.isspinner = false;
                this.hideSpinner();
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
                 console.log('wage def result different hour ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForDifferentPieceRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForDifferentPieceRate = result;
                    this.violationTypeVariablesForDifferentPieceRate.length > 0 ? this.isDifferentPieceRatePOW = true : this.isDifferentPieceRatePOW = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api violationTypeVariablesForknownPieceRate;
    @api isPieceRateknown = false;
    getAllVilationTypeVariablesForKnownPieceRate(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                this.isLoading = false;
                this.isspinner = false;
                this.hideSpinner();
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

    getAllVilationTypeVariablesUnknownPieceRate(queryCode){
        getViolationTypeVariables({
            queryCode : queryCode
        })
        .then(result => {
            if(result){
                this.isLoading = false;
                this.isspinner = false;
                this.hideSpinner();
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
                 console.log('wage def result different hour ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForUnknownPieceRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForUnknownPieceRate = result;
                    this.violationTypeVariablesForUnknownPieceRate.length > 0 ? this.isPieceRateUnknown = true : this.isPieceRateUnknown = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    // @api fileData = []

    // calculateFileSize(files){
    //     let i,j;
  
    //         if(this.fileData.length>0){
    //             console.log('sdsds');
    //                     this.fileData.splice(0,this.fileData.length);
    //                     fileSize = 0;
    //         }
    //         console.log(this.fileData);
    //         for(i=0;i<files.length;i++){
    //                 this.fileData.push(files[i]);
    //         }
    //         console.log(this.fileData);
  
    //         for(j=0;j<parseInt(this.fileData.length);j++){
    //                 fileSize = fileSize+parseInt(JSON.stringify(JSON.parse(this.fileData[j].size)));
    //         }
    //         console.log('????');
    //         console.log(fileSize);
  
    // }
    
    // @api isFileInserted = false;
    // @track flag = 0;
    // handlecommissionSummaryDocChange(event){
    //     this.calculateFileSize(event.target.files);
    //     if(fileSize<MAX_FILE_SIZE){
    //     let files = event.target.files;
    //     for(var i=0; i<files.length; i++){
    //         this.flag += 1;
    //         files[i].recordId = this.flag;
    //     }
    //     this.handlecommissionSummaryDoc(files);
    //     console.log('selecred fiels ::: ',files);
    //     if (files.length > 0) {
    //            let filesName = '';
 
    //            for (let i = 0; i < files.length; i++) {
    //                    let file = files[i];
 
    //                    filesName = filesName + file.name + ',';
 
    //                    var flag=this;
    //                    let freader = new FileReader();
    //                    console.log('freader');
    //                    freader.onload = f => {
                          
    //                        let base64 = 'base64,';
    //                        let content = freader.result.indexOf(base64) + base64.length;
    //                        let fileContents = freader.result.substring(content);    
    //                        flag.filesUploaded.push({
    //                            Title: file.name,
    //                            VersionData: fileContents
    //                        });
    //                    };
    //                    console.log(freader);
    //                    console.log(JSON.stringify(this.filesUploaded));
    //                  //  console.log('check',freader.readAsDataURL(file));
    //                    freader.readAsDataURL(file);
                      
    //            }
              
    //                this.fileNames = filesName.slice(0, -1);
 
    //    }
    //    }
    //    else{
    //        this.showToast('File Size Limit Exceeded','Upload files of size less than 20MB','error');
    //    }
    // }

    // @track contentVersionIds;
    // handleSaveFiles() {
    //     this.showLoadingSpinner = true;
    //     insertUploadedFiles({
    //         uploadedFiles : this.filesUploaded,
    //         contentVersionId : this.contentVersionIds
    //     })
    //     .then(data => {
    //         this.showLoadingSpinner = false;
    //         this.contentVersionIds = data;
    //         this.fileNames = undefined;
    //     })
    //     .catch(error => {
            
    //     });
    // }

    @api commissionSummaryDoc;
    @api isCommissionSumUpload = false;
    @api commissionSummaryDocSize;
    // Unreibursed doc handler
    handlecommissionSummaryDoc(event){
        const uploadedFiles = event.detail.files;
        this.commissionSummaryDoc = uploadedFiles;
        if(uploadedFiles != null){
            this.isCommissionSumUpload = false
            this.commissionSummaryDocSize = this.commissionSummaryDoc.length
            this.template.querySelector('[data-id="commissionSummaryDocId"]').getDocData(this.commissionSummaryDoc);
            this.isRenderedCallback = false
            this.showToast('Success!',this.toastFileUploadMsg,'success');
        }
        else{
            this.isCommissionSumUpload = true
        }
    }

    // Unreibursed doc delete handler
    handlecommissionSummaryDocEvent(event){
        this.commissionSummaryDoc = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.commissionSummaryDocSize = this.commissionSummaryDoc.length
    }

    @api paymentofwagedetails
    @api isFormPreviewMode = false;
    @api totalOwed
    beggingDateId
    endingDateId
    beggingDateSalaryId
    endingDateSalaryId
    beggingDateDifferentId
    endingDateDifferentId
    beggindDateDifferentPieceRateId
    endingDateDifferentPieceRateId
    beggingDateOnePieceRateId
    endingDateOnePieceRateId
    beggingDateCommissionUpload
    endingDateCommissionUpload
    beggingDateCommissionNotUpload
    endingDateCommissionNotUpload
    beggingDateUnknownPieceRate 
    endingDateUnknownPieceRate

    @api totalDifferentOwed;
    // Attributes for Liquidatity damage
    @api liquidityDamageVtIssues = []
    @api liquidityDamageVtIssueObj;
    // Get values from the inputs
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        var totalHours;
        var totalAmount;
        event.target.name === 'commissionOwedValue' ? this.commissionOwedValue = event.target.value : this.commissionOwedValue = undefined;
        event.target.name === 'owedBalanceValue' ? this.owedBalanceValue = event.target.value : this.owedBalanceValue = undefined;
        event.target.name === 'totalOwed' ? this.totalOwed = event.target.value : this.totalOwed = undefined;
        event.target.name === 'totalSalaryOwed' ? this.totalSalaryOwed = event.target.value : this.totalSalaryOwed = undefined;
        event.target.name === 'totalDifferentOwed' ? this.totalDifferentOwed = event.target.value : this.totalDifferentOwed = undefined;
        if(this.violationTypeVariablesForOneHourlyRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForOneHourlyRate.length; i++){
                this.violationTypeVariablesForOneHourlyRate[i].name === event.target.name ? this.violationTypeVariablesForOneHourlyRate[i].value = event.target.value : ''
                // (isNaN(event.target.value)) ? this.violationTypeVariablesForOneHourlyRate[i].isTempHide = true : this.violationTypeVariablesForOneHourlyRate[i].isTempHide = false
                this.violationTypeVariablesForOneHourlyRate[i].description === 'TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD' ? totalHours = this.violationTypeVariablesForOneHourlyRate[i].value : ''
                this.violationTypeVariablesForOneHourlyRate[i].description === '$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD' ? totalAmount = this.violationTypeVariablesForOneHourlyRate[i].value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForOneHourlyRate))
            }
            this.liquidityDamageVtIssues.push({ 'totalHours' : totalHours, 'totalAmount' : totalAmount, 'minimumWageRateApplied' : this.minimumWageRate });
        }
        var salaryTotalAmount;
        var salaryTotalHours;
        if(this.violationTypeVariablesForOneSalaryRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForOneSalaryRate.length; i++){
                this.violationTypeVariablesForOneSalaryRate[i].name === event.target.name ? this.violationTypeVariablesForOneSalaryRate[i].value = event.target.value : ''
                this.violationTypeVariablesForOneSalaryRate[i].description === '$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD' ? salaryTotalAmount = this.violationTypeVariablesForOneSalaryRate[i].value : ''
                // this.violationTypeVariablesForOneSalaryRate[i].description === '$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD' ? totalAmount = this.violationTypeVariablesForOneSalaryRate[i].value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForOneSalaryRate))
            }
            this.liquidityDamageVtIssues.push({ 'totalHours' : totalHours, 'totalAmount' : salaryTotalAmount, 'minimumWageRateApplied' : this.minimumWageRate });
        }
        var differenetTotalAmount;
        var differentTotalHours;
        if(this.violationTypeVariablesForDifferentHourlyRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForDifferentHourlyRate.length; i++){
                this.violationTypeVariablesForDifferentHourlyRate[i].name === event.target.name ? this.violationTypeVariablesForDifferentHourlyRate[i].value = event.target.value : ''
                this.violationTypeVariablesForDifferentHourlyRate[i].description === '$ TOTAL AMOUNT OF REG WAGES EARNED (FOR **NON-OT** HRS WORKED) DURING CLAIM PERIOD' ? differenetTotalAmount = this.violationTypeVariablesForDifferentHourlyRate[i].value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForDifferentHourlyRate))
            }
            this.liquidityDamageVtIssues.push({ 'totalHours' : totalHours, 'totalAmount' : differenetTotalAmount, 'minimumWageRateApplied' : this.minimumWageRate });
        }
        if(this.violationTypeVariablesForDifferentPieceRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForDifferentPieceRate.length; i++){
                this.violationTypeVariablesForDifferentPieceRate[i].name === event.target.name ? this.violationTypeVariablesForDifferentPieceRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForDifferentPieceRate))
            }
        }
        if(this.violationTypeVariablesForOnePieceRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForOnePieceRate.length; i++){
                this.violationTypeVariablesForOnePieceRate[i].name === event.target.name ? this.violationTypeVariablesForOnePieceRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForOnePieceRate))
            }
        }
        if(this.violationTypeVariablesForCommissionRateUpload !== undefined){
            for(var i=0; i<this.violationTypeVariablesForCommissionRateUpload.length; i++){
                this.violationTypeVariablesForCommissionRateUpload[i].name === event.target.name ? this.violationTypeVariablesForCommissionRateUpload[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForCommissionRateUpload))
            }
        }
        if(this.violationTypeVariablesForCommissionRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForCommissionRate.length; i++){
                this.violationTypeVariablesForCommissionRate[i].name === event.target.name ? this.violationTypeVariablesForCommissionRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForCommissionRate))
            }
        }
        if(this.violationTypeVariablesForUnknownPieceRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForUnknownPieceRate.length; i++){
                this.violationTypeVariablesForUnknownPieceRate[i].name === event.target.name ? this.violationTypeVariablesForUnknownPieceRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForUnknownPieceRate))
            }
        }
        if(this.violationTypeVariablesForCommissionRateUpload !== undefined){
            for(var i=0; i<this.violationTypeVariablesForCommissionRateUpload.length; i++){
                this.violationTypeVariablesForCommissionRateUpload[i].name === event.target.name ? this.violationTypeVariablesForCommissionRateUpload[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForCommissionRateUpload))
            }
        }
        if(this.violationTypeVariablesForCommissionRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForCommissionRate.length; i++){
                this.violationTypeVariablesForCommissionRate[i].name === event.target.name ? this.violationTypeVariablesForCommissionRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForCommissionRate))
            }
        }
        if(this.violationTypeVariablesForLocalWageOneHourlyRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForLocalWageOneHourlyRate.length; i++){
                this.violationTypeVariablesForLocalWageOneHourlyRate[i].name === event.target.name ? this.violationTypeVariablesForLocalWageOneHourlyRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForLocalWageOneHourlyRate))
            }
        }
        if(this.violationTypeVariablesForLocalWageOneSalaryRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForLocalWageOneSalaryRate.length; i++){
                this.violationTypeVariablesForLocalWageOneSalaryRate[i].name === event.target.name ? this.violationTypeVariablesForLocalWageOneSalaryRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForLocalWageOneSalaryRate))
            }
        }
        if(this.violationTypeVariablesForLocalWageDifferentHourlyRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForLocalWageDifferentHourlyRate.length; i++){
                this.violationTypeVariablesForLocalWageDifferentHourlyRate[i].name === event.target.name ? this.violationTypeVariablesForLocalWageDifferentHourlyRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForLocalWageDifferentHourlyRate))
            }
        }
        if(this.violationTypeVariablesForStateWageOneHourlyRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForStateWageOneHourlyRate.length; i++){
                this.violationTypeVariablesForStateWageOneHourlyRate[i].name === event.target.name ? this.violationTypeVariablesForStateWageOneHourlyRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForStateWageOneHourlyRate))
            }
        }
        if(this.violationTypeVariablesForknownPieceRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForknownPieceRate.length; i++){
                this.violationTypeVariablesForknownPieceRate[i].name === event.target.name ? this.violationTypeVariablesForknownPieceRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForknownPieceRate))
            }
        }
        if(this.violationTypeVariablesForStateWageOneSalaryRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForStateWageOneSalaryRate.length; i++){
                this.violationTypeVariablesForStateWageOneSalaryRate[i].name === event.target.name ? this.violationTypeVariablesForStateWageOneSalaryRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForStateWageOneSalaryRate))
            }
        }
        if(this.violationTypeVariablesForStateWageDifferentHourlyRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForStateWageDifferentHourlyRate.length; i++){
                this.violationTypeVariablesForStateWageDifferentHourlyRate[i].name === event.target.name ? this.violationTypeVariablesForStateWageDifferentHourlyRate[i].value = event.target.value : ''
                console.log('Loop var ::: ', JSON.stringify(this.violationTypeVariablesForStateWageDifferentHourlyRate))
            }
        }
    }

    /* This method is used to check all types of validation on the date fields. */
    handlePOWDateValidity(startDateId, endDateId, startDate, endDate){
        var startDateId = startDateId
        var endDateId = endDateId
        var startDate = startDate
        var endDate = endDate
        var today = new Date();

        startDate !== '' ? startDate = new Date(startDate.toString()) : ''

        endDate !== '' ? endDate = new Date(endDate.toString()) : ''
        if(startDate === '' && endDate === ''){
            startDateId.setCustomValidity('')
            endDateId.setCustomValidity('')
            startDateId.reportValidity();
            endDateId.reportValidity();
            return false;
        }

        else if((startDate === '' && endDate !== '') || (startDate !== '' && endDate === '')){
            startDateId.setCustomValidity('Please fill both date field.')
            endDateId.setCustomValidity('Please fill both date field.')
            startDateId.reportValidity();
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

    workNotPaidValidityChecker(){
        const selectEvent = new CustomEvent('worknotpaidvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.dispatchEvent(selectEvent);
    }

    isDateAcceptable = false;
    isSalaryDateAcceptable = false;
    isDifferentSalaryDateAcceptable = false;
    isOnePieceDateAcceptable = false;
    isDifferentPieceDateAcceptable = false;
    isCommissionDateAcceptable = false;
    isUploadCommissionDateAcceptable = false;
    isUnknownDateAcceptable = false;
    // This method is used to check the validity of the input fields
    @api
    handleWageDeficienciesParent(){
        // if(this.isOneHourlyRatePOW === true){
        //     const beggingDateId = `[data-id="${this.violationTypeVariablesForOneHourlyRate[0].name}"]`;
        //     const endingDateId = `[data-id="${this.violationTypeVariablesForOneHourlyRate[1].name}"]`;
        //     const hourlyRateBeginningDate = this.template.querySelector(String(beggingDateId));
        //     const hourlyRateEndingDate = this.template.querySelector(String(endingDateId));
        //     this.isDateAcceptable = this.handlePOWDateValidity(hourlyRateBeginningDate, hourlyRateEndingDate, hourlyRateBeginningDate.value, hourlyRateEndingDate.value);

        //     this.isDateAcceptable === true ? endingDateId.focus() : ''
        // }

        // if(this.isDifferentHourPOW === true){
        //     const beggingDateId = `[data-id="${this.violationTypeVariablesForDifferentHourlyRate[3].name}"]`;
        //     const endingDateId = `[data-id="${this.violationTypeVariablesForDifferentHourlyRate[4].name}"]`;
        //     const hourlyRateBeginningDate = this.template.querySelector(String(beggingDateId));
        //     const hourlyRateEndingDate = this.template.querySelector(String(endingDateId));
        //     this.isDifferentSalaryDateAcceptable = this.handlePOWDateValidity(hourlyRateBeginningDate, hourlyRateEndingDate, hourlyRateBeginningDate.value, hourlyRateEndingDate.value);

        //     this.isDifferentSalaryDateAcceptable === true ? endingDateId.focus() : ''
        // }

        // if(this.isSalaryRatePOW === true){
        //     const beggingDateId = `[data-id="${this.violationTypeVariablesForOneSalaryRate[1].name}"]`;
        //     const endingDateId = `[data-id="${this.violationTypeVariablesForOneSalaryRate[2].name}"]`;
        //     const hourlyRateBeginningDate = this.template.querySelector(String(beggingDateId));
        //     const hourlyRateEndingDate = this.template.querySelector(String(endingDateId));
        //     this.isSalaryDateAcceptable = this.handlePOWDateValidity(hourlyRateBeginningDate, hourlyRateEndingDate, hourlyRateBeginningDate.value, hourlyRateEndingDate.value);

        //     this.isSalaryDateAcceptable === true ? endingDateId.focus() : ''
        // }

        // if(this.isOnePieceRatePOW === true){
        //     const beggingDateId = `[data-id="${this.violationTypeVariablesForOnePieceRate[1].name}"]`;
        //     const endingDateId = `[data-id="${this.violationTypeVariablesForOnePieceRate[2].name}"]`;
        //     const hourlyRateBeginningDate = this.template.querySelector(String(beggingDateId));
        //     const hourlyRateEndingDate = this.template.querySelector(String(endingDateId));
        //     this.isOnePieceDateAcceptable = this.handlePOWDateValidity(hourlyRateBeginningDate, hourlyRateEndingDate, hourlyRateBeginningDate.value, hourlyRateEndingDate.value);

        //     this.isOnePieceDateAcceptable === true ? endingDateId.focus() : ''
        // }

        // if(this.isDifferentPieceRatePOW === true){
        //     const beggingDateId = `[data-id="${this.violationTypeVariablesForDifferentPieceRate[0].name}"]`;
        //     const endingDateId = `[data-id="${this.violationTypeVariablesForDifferentPieceRate[2].name}"]`;
        //     const hourlyRateBeginningDate = this.template.querySelector(String(beggingDateId));
        //     const hourlyRateEndingDate = this.template.querySelector(String(endingDateId));
        //     this.isDifferentPieceDateAcceptable = this.handlePOWDateValidity(hourlyRateBeginningDate, hourlyRateEndingDate, hourlyRateBeginningDate.value, hourlyRateEndingDate.value);

        //     this.isDifferentPieceDateAcceptable === true ? endingDateId.focus() : ''
        // }

        // if(this.isCommissionAgreementUpload === true){
        //     const beggingDateId = `[data-id="${this.violationTypeVariablesForCommissionRateUpload[0].name}"]`;
        //     const endingDateId = `[data-id="${this.violationTypeVariablesForCommissionRateUpload[1].name}"]`;
        //     const hourlyRateBeginningDate = this.template.querySelector(String(beggingDateId));
        //     const hourlyRateEndingDate = this.template.querySelector(String(endingDateId));
        //     this.isDifferentPieceDateAcceptable = this.handlePOWDateValidity(hourlyRateBeginningDate, hourlyRateEndingDate, hourlyRateBeginningDate.value, hourlyRateEndingDate.value);

        //     this.isUploadCommissionDateAcceptable === true ? endingDateId.focus() : ''
        // }

        // if(this.isNotCommissionAgreementUpload === true){
        //     const beggingDateId = `[data-id="${this.violationTypeVariablesForCommissionRate[1].name}"]`;
        //     const endingDateId = `[data-id="${this.violationTypeVariablesForCommissionRate[4].name}"]`;
        //     const hourlyRateBeginningDate = this.template.querySelector(String(beggingDateId));
        //     const hourlyRateEndingDate = this.template.querySelector(String(endingDateId));
        //     this.isDifferentPieceDateAcceptable = this.handlePOWDateValidity(hourlyRateBeginningDate, hourlyRateEndingDate, hourlyRateBeginningDate.value, hourlyRateEndingDate.value);

        //     this.isCommissionDateAcceptable === true ? endingDateId.focus() : ''
        // }

        // if(this.isPieceRateUnknown === true){
        //     const beggingDateId = `[data-id="${this.violationTypeVariablesForUnknownPieceRate[1].name}"]`;
        //     const endingDateId = `[data-id="${this.violationTypeVariablesForUnknownPieceRate[2].name}"]`;
        //     const hourlyRateBeginningDate = this.template.querySelector(String(beggingDateId));
        //     const hourlyRateEndingDate = this.template.querySelector(String(endingDateId));
        //     this.isDifferentPieceDateAcceptable = this.handlePOWDateValidity(hourlyRateBeginningDate, hourlyRateEndingDate, hourlyRateBeginningDate.value, hourlyRateEndingDate.value);

        //     this.isUnknownDateAcceptable === true ? endingDateId.focus() : ''
        // }
        
        this.isUnknownDateAcceptable === true || this.isUploadCommissionDateAcceptable === true || this.isCommissionDateAcceptable === true || this.isDateAcceptable === true || this.isSalaryDateAcceptable === true || this.isDifferentSalaryDateAcceptable === true || this.isDifferentPieceDateAcceptable === true || this.isOnePieceDateAcceptable === true ? this.workNotPaidValidityChecker() : this.handleWageDeficienciesParentInfoData();
    }

    // This method is used to make the JSON object of the input variables
    @api
    handleWageDeficienciesParentInfoData(){
        const selectEvent = new CustomEvent('wagedeficienciesfirstoptionevent', {
            detail:{
                InfoObj : this.InfoObj(),
                caseIssue : this.violationCaseIssueObj()
            } 
        });
        this.dispatchEvent(selectEvent);
    }

    @api
    handleWageDeficienciesSectionData(){
        const selectEvent = new CustomEvent('wagedefsectiondeleteevent', {
            detail:{
                InfoObj : this.InfoObj(),
                caseIssue : this.violationCaseIssueObj()
            } 
        });
        this.dispatchEvent(selectEvent);
    }

    violationCaseIssueObj(){
        // this.violationTypeVariablesForOneHourlyRate !== undefined && this.violationTypeVariablesForOneHourlyRate.length > 0 ? this.violationTypeVariablesForOneHourlyRate.forEach(function (value) { this.violationCaseIssueObj.push(value) }) : '';
        // this.violationTypeVariablesForOneHourlyRate !== undefined && this.violationTypeVariablesForOneHourlyRate.length > 0 ? this.violationTypeVariablesForOneHourlyRate.forEach(function (value) { this.violationCaseIssueObj.push(value) }) : '';
        return{
            violationTypeVariablesForOneHourlyRate : this.violationTypeVariablesForOneHourlyRate,
            violationTypeVariablesForOneSalaryRate : this.violationTypeVariablesForOneSalaryRate,
            violationTypeVariablesForDifferentHourlyRate : this.violationTypeVariablesForDifferentHourlyRate,
            violationTypeVariablesForDifferentPieceRate : this.violationTypeVariablesForDifferentPieceRate,
            violationTypeVariablesForOnePieceRate : this.violationTypeVariablesForOnePieceRate,
            violationTypeVariablesForUnknownPieceRate : this.violationTypeVariablesForUnknownPieceRate,
            violationTypeVariablesForCommissionRate : this.violationTypeVariablesForCommissionRate,
            violationTypeVariablesForCommissionRateUpload : this.violationTypeVariablesForCommissionRateUpload,
            violationTypeVariablesForLocalWageDifferentHourlyRate : this.violationTypeVariablesForLocalWageDifferentHourlyRate,
            violationTypeVariablesForLocalWageOneHourlyRate : this.violationTypeVariablesForLocalWageOneHourlyRate,
            violationTypeVariablesForLocalWageOneSalaryRate : this.violationTypeVariablesForLocalWageOneSalaryRate,
            violationTypeVariablesForStateWageOneHourlyRate : this.violationTypeVariablesForStateWageOneHourlyRate,
            violationTypeVariablesForStateWageOneSalaryRate : this.violationTypeVariablesForStateWageOneSalaryRate,
            violationTypeVariablesForStateWageDifferentHourlyRate : this.violationTypeVariablesForStateWageDifferentHourlyRate,
            violationTypeVariablesForknownPieceRate : this.violationTypeVariablesForknownPieceRate 
            // liquidityDamageVtIssues : this.liquidityDamageVtIssues
        }
    }
    // This method is used to make the JSON obj
    InfoObj(){
        return {
            sectionId : this.sectionid,
            heatrecovery : this.heatrecovery,
            paidbreaks : this.paidbreaks,
            isonehourlyrate : this.isonehourlyrate,
            islocalminimumwage : this.islocalminimumwage,
            isstateminimumwage : this.isstateminimumwage,
            violationTypeVariablesForOneHourlyRate : this.violationTypeVariablesForOneHourlyRate,
            violationTypeVariablesForOneSalaryRate : this.violationTypeVariablesForOneSalaryRate,
            violationTypeVariablesForDifferentHourlyRate : this.violationTypeVariablesForDifferentHourlyRate,
            violationTypeVariablesForDifferentPieceRate : this.violationTypeVariablesForDifferentPieceRate,
            violationTypeVariablesForOnePieceRate : this.violationTypeVariablesForOnePieceRate,
            violationTypeVariablesForUnknownPieceRate : this.violationTypeVariablesForUnknownPieceRate,
            violationTypeVariablesForCommissionRate : this.violationTypeVariablesForCommissionRate,
            violationTypeVariablesForCommissionRateUpload : this.violationTypeVariablesForCommissionRateUpload,
            isOnePieceRatePOW : this.isOnePieceRatePOW,
            isPieceRateknown : this.isPieceRateknown,
            violationTypeVariablesForknownPieceRate : this.violationTypeVariablesForknownPieceRate,
            isDifferentPieceRatePOW : this.isDifferentPieceRatePOW,
            isOneHourlyRatePOW : this.isOneHourlyRatePOW,
            isSalaryRatePOW : this.isSalaryRatePOW,
            isDifferentHourPOW : this.isDifferentHourPOW,
            commissionOwedValue : this.commissionOwedValue,
            isPieceRateUnknown : this.isPieceRateUnknown,
            isCommissionAgreementUpload : this.isCommissionAgreementUpload,
            isNotCommissionAgreementUpload : this.isNotCommissionAgreementUpload,
            commissionSummaryDoc : this.commissionSummaryDoc,
            isCommissionSumUpload : this.isCommissionSumUpload,
            commissionSummaryDocSize : this.commissionSummaryDocSize,
            violationTypeVariablesForLocalWageDifferentHourlyRate : this.violationTypeVariablesForLocalWageDifferentHourlyRate,
            isLocalWageDifferentHourPOW : this.isLocalWageDifferentHourPOW,
            isLocalWageOneHourlyRatePOW : this.isLocalWageOneHourlyRatePOW,
            violationTypeVariablesForLocalWageOneHourlyRate : this.violationTypeVariablesForLocalWageOneHourlyRate,
            isLocalWageSalaryRatePOW : this.isLocalWageSalaryRatePOW,
            violationTypeVariablesForLocalWageOneSalaryRate : this.violationTypeVariablesForLocalWageOneSalaryRate,
            isStateWageOneHourlyRatePOW : this.isStateWageOneHourlyRatePOW,
            violationTypeVariablesForStateWageOneHourlyRate : this.violationTypeVariablesForStateWageOneHourlyRate,
            isStateWageSalaryRatePOW : this.isStateWageSalaryRatePOW,
            violationTypeVariablesForStateWageOneSalaryRate : this.violationTypeVariablesForStateWageOneSalaryRate,
            isStateWageDifferentHourPOW : this.isStateWageDifferentHourPOW,
            violationTypeVariablesForStateWageDifferentHourlyRate : this.violationTypeVariablesForStateWageDifferentHourlyRate,
            minimumWageRate : this.minimumWageRate,
            stateminimumwagerate : this.stateminimumwagerate,
            localminimumwagerate : this.localminimumwagerate,
            isSalaryRateCallback : this.isSalaryRateCallback,
            isMultipleRateCallback : this.isMultipleRateCallback,
            isOneHourlyRateCallback : this.isOneHourlyRateCallback,
            isLocalWageOneHourlyCallback : this.isLocalWageOneHourlyCallback,
            isStateWageOneHourlyRateCallback : this.isStateWageOneHourlyRateCallback,
            isLocalWageSalaryRateCallback : this.isLocalWageSalaryRateCallback,
            isLocalWageDifferentHourCallback : this.isLocalWageDifferentHourCallback,
            isStateWageDifferentHourCallback : this.isStateWageDifferentHourCallback,
            isStateWageSalaryRateCallback : this.isStateWageSalaryRateCallback,
            totalOwed : this.totalOwed,
            owedBalanceValue : this.owedBalanceValue,
            totalSalaryOwed : this.totalSalaryOwed,
            totalDifferentOwed : this.totalDifferentOwed,
            hourlyratelist : this.hourlyratelist,
            salaryratelist : this.salaryratelist,
            multiplehourlyrate : this.multiplehourlyrate,
            minimumrates : this.minimumrates,
            staterate : this.staterate,
            contentVersionIds : this.contentVersionIds,
            flag : this.flag
        }
    }

    @api isSectionHide = false;
    checkSectionData(){
        this.isOneHourlyRatePOW === true || this.isSalaryRatePOW === true || this.isDifferentHourPOW === true || this.isOnePieceRatePOW === true || this.isDifferentPieceRatePOW === true || this.isPieceRateUnknown === true || this.isCommissionAgreementUpload === true || this.isNotCommissionAgreementUpload === true || this.isLocalWageOneHourlyRatePOW === true 
        || this.isLocalWageSalaryRatePOW === true || this.isLocalWageDifferentHourPOW === true || this.isStateWageOneHourlyRatePOW === true || this.isStateWageSalaryRatePOW === true || this.isStateWageDifferentHourPOW === true ? this.isSectionHide = false : this.isSectionHide = true
        const selectEvent = new CustomEvent('wagehourlynodataevent', {
            detail:{
                isSectionHide : this.isSectionHide
            } 
        });
        this.dispatchEvent(selectEvent);
    }

    // This method is used to get values from the parent cmp
    @api
    handleWageDeficienciesChild(strString, isFormPreviewMode){
        console.log('strString in Hourly Section ::: ', JSON.stringify(strString));
        this.isFormPreviewMode = isFormPreviewMode
            this.sectionId = strString.sectionId
            this.heatrecovery = this.heatrecovery !== undefined ? this.heatrecovery : strString.heatrecovery
            this.paidbreaks = this.paidbreaks !== undefined ? this.paidbreaks : strString.paidbreaks
            this.isonehourlyrate = strString.isonehourlyrate
            this.islocalminimumwage = strString.islocalminimumwage
            this.isstateminimumwage = strString.isstateminimumwage
            this.violationTypeVariablesForOneHourlyRate = this.isOneHourlyRateCallback === true ? undefined : strString.violationTypeVariablesForOneHourlyRate
            this.violationTypeVariablesForOneSalaryRate = this.isSalaryRateCallback === true && undefined ? '' : strString.violationTypeVariablesForOneSalaryRate
            this.violationTypeVariablesForDifferentHourlyRate = this.isMultipleRateCallback === true ? undefined : strString.violationTypeVariablesForDifferentHourlyRate
            this.isOneHourlyRatePOW = this.isOneHourlyRateCallback === true ? this.isOneHourlyRatePOW : strString.isOneHourlyRatePOW
            this.isSalaryRatePOW = this.isSalaryRateCallback === true ? this.isSalaryRatePOW : strString.isSalaryRatePOW
            this.isDifferentHourPOW = this.isMultipleRateCallback === true ? this.isDifferentHourPOW : strString.isDifferentHourPOW
            this.violationTypeVariablesForDifferentPieceRate = strString.violationTypeVariablesForDifferentPieceRate
            this.violationTypeVariablesForOnePieceRate = strString.violationTypeVariablesForOnePieceRate
            this.isOnePieceRatePOW = strString.isOnePieceRatePOW
            this.isDifferentPieceRatePOW = strString.isDifferentPieceRatePOW
            this.isPieceRateUnknown = strString.isPieceRateUnknown
            this.commissionOwedValue = strString.commissionOwedValue
            this.isPieceRateknown = strString.isPieceRateknown,
            this.violationTypeVariablesForknownPieceRate = strString.violationTypeVariablesForknownPieceRate,
            this.isCommissionAgreementUpload = strString.isCommissionAgreementUpload
            this.isNotCommissionAgreementUpload = strString.isNotCommissionAgreementUpload
            this.violationTypeVariablesForUnknownPieceRate = strString.violationTypeVariablesForUnknownPieceRate
            this.violationTypeVariablesForCommissionRate = strString.violationTypeVariablesForCommissionRate
            this.violationTypeVariablesForCommissionRateUpload = strString.violationTypeVariablesForCommissionRateUpload
            this.commissionSummaryDoc = strString.commissionSummaryDoc,
            this.isCommissionSumUpload = strString.isCommissionSumUpload,
            this.commissionSummaryDocSize = strString.commissionSummaryDocSize,
            this.violationTypeVariablesForLocalWageDifferentHourlyRate = this.isLocalWageDifferentHourCallback === true ? undefined : strString.violationTypeVariablesForLocalWageDifferentHourlyRate
            this.isLocalWageDifferentHourPOW = this.isLocalWageDifferentHourCallback === true ? this.isLocalWageDifferentHourPOW : strString.isLocalWageDifferentHourPOW
            this.isLocalWageOneHourlyRatePOW = this.isLocalWageOneHourlyCallback === true ? this.isLocalWageOneHourlyRatePOW : strString.isLocalWageOneHourlyRatePOW
            this.violationTypeVariablesForLocalWageOneHourlyRate = this.isLocalWageOneHourlyCallback === true ? undefined : strString.violationTypeVariablesForLocalWageOneHourlyRate
            this.isLocalWageSalaryRatePOW = this.isLocalWageSalaryRateCallback === true ? this.isLocalWageSalaryRatePOW : strString.isLocalWageSalaryRatePOW
            this.violationTypeVariablesForLocalWageOneSalaryRate = this.isLocalWageSalaryRateCallback === true ? undefined : strString.violationTypeVariablesForLocalWageOneSalaryRate
            this.isStateWageOneHourlyRatePOW = this.isStateWageOneHourlyRateCallback === true ? this.isStateWageOneHourlyRatePOW : strString.isStateWageOneHourlyRatePOW
            this.violationTypeVariablesForStateWageOneHourlyRate = this.isStateWageOneHourlyRateCallback === true ? undefined : strString.violationTypeVariablesForStateWageOneHourlyRate
            this.isStateWageSalaryRatePOW = this.isStateWageSalaryRateCallback === true ? this.isStateWageSalaryRatePOW : strString.isStateWageSalaryRatePOW
            this.violationTypeVariablesForStateWageOneSalaryRate = this.isStateWageSalaryRateCallback === true ? undefined : strString.violationTypeVariablesForStateWageOneSalaryRate
            this.isStateWageDifferentHourPOW = this.isStateWageDifferentHourCallback === true ? this.isStateWageDifferentHourPOW : strString.isStateWageDifferentHourPOW
            this.violationTypeVariablesForStateWageDifferentHourlyRate = this.isStateWageDifferentHourCallback === true ? undefined : strString.violationTypeVariablesForStateWageDifferentHourlyRate
            this.minimumWageRate = strString.minimumWageRate
            this.stateminimumwagerate = strString.stateminimumwagerate
            this.localminimumwagerate = strString.localminimumwagerate
            this.isSalaryRateCallback = strString.isSalaryRateCallback,
            this.isMultipleRateCallback = strString.isMultipleRateCallback,
            this.isOneHourlyRateCallback = strString.isOneHourlyRateCallback,
            this.isLocalWageOneHourlyCallback = strString.isLocalWageOneHourlyCallback
            this.isStateWageOneHourlyRateCallback = strString.isStateWageOneHourlyRateCallback
            this.isLocalWageSalaryRateCallback = strString.isLocalWageSalaryRateCallback
            this.isLocalWageDifferentHourCallback = strString.isLocalWageDifferentHourCallback
            this.isStateWageDifferentHourCallback = strString.isStateWageDifferentHourCallback
            this.isStateWageSalaryRateCallback = strString.isStateWageSalaryRateCallback
            this.totalOwed = strString.totalOwed
            this.owedBalanceValue = strString.owedBalanceValue
            this.totalSalaryOwed = strString.totalSalaryOwed
            this.totalDifferentOwed = strString.totalDifferentOwed
            this.hourlyratelist = this.hourlyratelist === undefined ? strString.hourlyratelist : this.hourlyratelist
            this.salaryratelist = this.salaryratelist === undefined ? strString.salaryratelist : this.salaryratelist
            this.multiplehourlyrate = this.multiplehourlyrate === undefined ? strString.multiplehourlyrate : this.multiplehourlyrate
            this.minimumrates = this.minimumrates === undefined ? strString.minimumrates : this.minimumrates
            this.staterate = this.staterate === undefined ? strString.staterate : this.staterate
            this.flag = strString.flag,
            this.contentVersionIds = strString.contentVersionIds
            this.isRenderedCallback = true;
            this.isRenderOption = true;
    }

    renderedCallback(){
        if(this.isRenderedCallback === true && this.commissionSummaryDoc  !== undefined && this.commissionSummaryDocSize > 0 ){
            const templateArray = this.template.querySelectorAll('c-owc-Multiple-File-Upload-Details-Cmp')
            for (let i = 0; i < templateArray.length; i++){
                if(templateArray[i].name === 'commissionSummaryDocId'){
                        templateArray[i].getDocInfos(this.commissionSummaryDoc, this.iswagedefpreview);
                }
            }
        }
        if(this.isRenderedCallback === true){
            // this.handleServerCall()
        }
        this.isRenderedCallback = false;
    }
    
    // @api
    // handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
    //     console.log('Payemnt details in Sub child ::: ', JSON.stringify(paymentOfWagesDetails.HourlyOptionValue))
    //     this.isFormPreviewMode = isFormPreviewMode
    //     this.paymentOfWagesDetails = paymentOfWagesDetails
    // }
}