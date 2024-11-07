import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import getViolationTypeVariables from '@salesforce/apex/OWCWageDeficienciesController.getViolationTypeVariables';
export default class OwcEmployerWorkedDefined extends LightningElement {
    @api localminimumwagerate
    @api otherworkcity
    @api salaryratelist
    @api hourlyratelist
    @api multiplehourlyrate
    @api stateminimumwagerate
    @api isonehourlyrate = false;
    @api islocalminimumwage = false;
    @api isstateminimumwage = false;
    @api minimumWageRate
    @api iwcinfoobj
    @api minimumrates
    @api staterate
    @api stateratelist
    @api isloading
    @track showSpinner = true
    @api iswagedefpreview
    
    // Import custom label values
    customLabelValues = customLabelValues;

    // Formatted date Label
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    // Connected Callback method load on doinit
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
        this.isonehourlyrate = true;
        this.islocalminimumwage = true;
        this.isstateminimumwage = true
        this.showSpinner = this.isloading;
        console.log('salaryratelist ::: ', JSON.stringify(this.salaryratelist))
        console.log('localminimumwagerate ::: ', JSON.stringify(this.localminimumwagerate))
        console.log('hourlyratelist ::: ', JSON.stringify(this.hourlyratelist))
        console.log('multiplehourlyrate ::: ', JSON.stringify(this.multiplehourlyrate))
        console.log('stateratelist ::: ', JSON.stringify(this.stateratelist))
        console.log('minimumwagerate in connected ::: ', JSON.stringify(this.minimumrates))
        
        
        // this.minimumWageRate = this.localminimumwagerate === undefined || this.localminimumwagerate === null ? this.stateminimumwagerate : this.localminimumwagerate
    }

    @api paymentOfWagesDetails
    @api
    handlePOWDetails(paymentOfWagesDetails, isFormPreviewMode){
        this.paymentOfWagesDetails = paymentOfWagesDetails
        this.callOneHourlyRateApplied();
        // new Promise(
        //     (resolve,reject) => {
        //       setTimeout(()=> {
        //           this.handleServerCall();
        //           resolve();
        //       }, 1500);
        //   }).then(
        //       () => this.showSpinner = false
        //   );
        console.log('Payment detail employer child ::: ', JSON.stringify(paymentOfWagesDetails));
    }

    @api isOneHourlyRateCallback = false;

    handleServerCall(){
        if(this.paymentOfWagesDetails.HourlyOptionValue === true){
            this.checkRateForOneHourly();
            this.checkRateForOneHourlyApplied();
        }
        if(this.paymentOfWagesDetails.salaryRateOptionValue === true){
            this.checkRateForSalaryRate();
        }
        else if(this.paymentOfWagesDetails.differentHourOptionValue === true){
            this.checkRateForMultipleRate();
        }
        
        // Check for anytype of pay
        if(this.paymentOfWagesDetails.HourlyOptionValue === true){
            this.callAnyTypeOfPayForOneHourly();
        }
        else if(this.paymentOfWagesDetails.salaryRateOptionValue === true){
            this.callAnyTypeOfPayForSalary();
        }
        else if(this.paymentOfWagesDetails.differentHourOptionValue === true){
            this.callAnyTypeOfPayForMultiple();
        }
    }

    @track isSalaryMinimumWage = false
    checkRateForSalaryRate(){
        if(this.salaryratelist !== undefined && this.salaryratelist.length > 0){
            for(var i=0; i<this.salaryratelist.length; i++){
                if(this.minimumrates !== undefined && this.minimumrates.length > 0){
                    for(var j=0; j<this.minimumrates[i].length; j++){
                        if(((this.salaryratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.salaryratelist[i].endingDate <= this.minimumrates[j].Effective_Date_To__c)) || ((this.salaryratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.salaryratelist[i].endingDate === null))){
                            if(this.stateratelist !== undefined && this.stateratelist.length > 0){
                                for(var k=0; k<this.stateratelist[j].length; k++){
                                    if(((this.salaryratelist[i].beggingDate >= this.stateratelist[k].Effective_Date_From__c) && (this.salaryratelist[i].endingDate <= this.stateratelist[k].Effective_Date_To__c)) || ((this.salaryratelist[i].beggingDate >= this.stateratelist[k].Effective_Date_From__c) && (this.salaryratelist[i].endingDate === null)) && (this.stateratelist[k].Min_Wage_Rate__c > this.minimumrates[j].Min_Wage_Rate__c)){
                                        this.isSalaryMinimumWage = true;
                                        break;
                                    }
                                }
                            }
                            if(this.isSalaryMinimumWage === true){
                                break;
                            }
                        }
                    }
                }
                if(this.isSalaryMinimumWage === true){
                    break;
                }
            }
        }
        if(this.isSalaryMinimumWage === true){
            this.callLocalMinWage();
        }
        
    }
    @track isRegularWage = false
    @track isStateWage = false
    @track isMinimumWage = false
    checkRateForOneHourly(){
        if(this.hourlyratelist !== undefined && this.hourlyratelist.length > 0){
            for(var i=0; i<this.hourlyratelist.length; i++){
                if(this.minimumrates !== undefined && this.minimumrates.length > 0){
                    for(var j=0; j<this.minimumrates.length; j++){
                        if(((this.hourlyratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.hourlyratelist[i].endingDate <= this.minimumrates[j].Effective_Date_To__c)) || ((this.hourlyratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.hourlyratelist[i].endingDate === null)) && (this.hourlyratelist[i].hourlyRate > this.minimumrates[j].Min_Wage_Rate__c)){
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
            this.callOneHourlyRate();
        }
        else{
            // this.callOneHourlyRegular();
        }
        
        
    }

    @api isOneHourlyMinRate = false;
    checkRateForOneHourlyApplied(){
        if(this.hourlyratelist !== undefined && this.hourlyratelist.length > 0){
            for(var i=0; i<this.hourlyratelist.length; i++){
                if(this.minimumrates !== undefined && this.minimumrates.length > 0){
                    for(var j=0; j<this.minimumrates.length; j++){
                        if(((this.hourlyratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.hourlyratelist[i].endingDate <= this.minimumrates[j].Effective_Date_To__c)) || ((this.hourlyratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.hourlyratelist[i].endingDate === null)) && (this.hourlyratelist[i].hourlyRate <= this.minimumrates[j].Min_Wage_Rate__c)){
                            this.isOneHourlyMinRate = true;
                            break;
                        }
                        else{
                            this.isOneHourlyMinRate = false;
                        }
                    }
                }
                if(this.isOneHourlyMinRate === true){
                    break;
                }
            }
        }
        if(this.isOneHourlyMinRate === true){
            this.callOneHourlyRateApplied();
        }
        else{
            // this.callOneHourlyRegular();
        }
        
        
    }

    @track isAnyTypePayForOneHourly = false;
    callAnyTypeOfPayForOneHourly(){
        console.log('result of anytype1 ::: ', (JSON.stringify(this.stateratelist)))
        console.log('result of anytype2 ::: ', (JSON.stringify(this.minimumrates)))
        console.log('result of anytype3 ::: ', (JSON.stringify(this.hourlyratelist)))
        if(this.hourlyratelist !== undefined && this.hourlyratelist.length > 0){
            for(var i=0; i<this.hourlyratelist.length; i++){
                if(this.minimumrates !== undefined && this.minimumrates.length > 0){
                    for(var j=0; j<this.minimumrates[i].length; j++){
                        if(((this.hourlyratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.hourlyratelist[i].endingDate <= this.minimumrates[j].Effective_Date_To__c)) || ((this.hourlyratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.hourlyratelist[i].endingDate === null))){
                            if(this.stateratelist !== undefined && this.stateratelist.length > 0){
                                for(var k=0; k<this.stateratelist[j].length; k++){
                                    if(((this.hourlyratelist[i].beggingDate >= this.stateratelist[k].Effective_Date_From__c) && (this.hourlyratelist[i].endingDate <= this.stateratelist[k].Effective_Date_To__c)) || ((this.hourlyratelist[i].beggingDate >= this.stateratelist[k].Effective_Date_From__c) && (this.hourlyratelist[i].endingDate === null)) && (this.stateratelist[k].Min_Wage_Rate__c < this.minimumrates[j].Min_Wage_Rate__c)){
                                        this.isAnyTypePayForOneHourly = true;
                                        break;
                                    }
                                }
                            }
                            if(this.isAnyTypePayForOneHourly === true){
                                break;
                            }
                        }
                    }
                }
                if(this.isAnyTypePayForOneHourly === true){
                    break;
                }
            }
        }
        if(this.isAnyTypePayForOneHourly === true){
            this.callAnyTypeOfPay();
        }
        
        
    }

    @api isSalaryRateAnyTypePay = false;
    async callAnyTypeOfPayForSalary(){
        if(this.salaryratelist !== undefined && this.salaryratelist.length > 0){
            for(var i=0; i<this.salaryratelist.length; i++){
                if(this.minimumrates !== undefined && this.minimumrates.length > 0){
                    for(var j=0; j<this.minimumrates[i].length; j++){
                        if(((this.salaryratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.salaryratelist[i].endingDate <= this.minimumrates[j].Effective_Date_To__c)) || ((this.salaryratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.salaryratelist[i].endingDate === null))){
                            if(this.stateratelist !== undefined && this.stateratelist.length > 0){
                                for(var k=0; k<this.stateratelist[j].length; k++){
                                    if(((this.salaryratelist[i].beggingDate >= this.stateratelist[k].Effective_Date_From__c) && (this.salaryratelist[i].endingDate <= this.stateratelist[k].Effective_Date_To__c)) || ((this.salaryratelist[i].beggingDate >= this.stateratelist[k].Effective_Date_From__c) && (this.salaryratelist[i].endingDate === null)) && (this.stateratelist[k].Min_Wage_Rate__c < this.minimumrates[j].Min_Wage_Rate__c)){
                                        this.isSalaryRateAnyTypePay = true;
                                        break;
                                    }
                                }
                            }
                            if(this.isSalaryRateAnyTypePay === true){
                                break;
                            }
                        }
                    }
                }
                if(this.isSalaryRateAnyTypePay === true){
                    break;
                }
            }
        }
        if(this.isSalaryRateAnyTypePay === true){
            this.callAnyTypeOfPay();
        }
        
        
    }

    @api isMultipleRateAnyTypePay = false;
    async callAnyTypeOfPayForMultiple(){
        if(this.multiplehourlyrate !== undefined && this.multiplehourlyrate.length > 0){
            for(var i=0; i<this.multiplehourlyrate.length; i++){
                if(this.minimumrates !== undefined && this.minimumrates.length > 0){
                    for(var j=0; j<this.minimumrates[i].length; j++){
                        if(((this.multiplehourlyrate[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.multiplehourlyrate[i].endingDate <= this.minimumrates[j].Effective_Date_To__c)) || ((this.multiplehourlyrate[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.multiplehourlyrate[i].endingDate === null))){
                            if(this.stateratelist !== undefined && this.stateratelist.length > 0){
                                for(var k=0; k<this.stateratelist[j].length; k++){
                                    if(((this.multiplehourlyrate[i].beggingDate >= this.stateratelist[k].Effective_Date_From__c) && (this.multiplehourlyrate[i].endingDate <= this.stateratelist[k].Effective_Date_To__c)) || ((this.multiplehourlyrate[i].beggingDate >= this.stateratelist[k].Effective_Date_From__c) && (this.multiplehourlyrate[i].endingDate === null)) && (this.stateratelist[k].Min_Wage_Rate__c < this.minimumrates[j].Min_Wage_Rate__c)){
                                        this.isMultipleRateAnyTypePay = true;
                                        break;
                                    }
                                }
                            }
                            if(this.isMultipleRateAnyTypePay === true){
                                break;
                            }
                        }
                    }
                }
                if(this.isMultipleRateAnyTypePay === true){
                    break;
                }
            }
        }
        if(this.isMultipleRateAnyTypePay === true){
            this.callAnyTypeOfPay();
        }
        
    }

    @track isMultipleLocalPay = false
    checkRateForMultipleRate(){
        if(this.salaryratelist !== undefined && this.salaryratelist.length > 0){
            for(var i=0; i<this.salaryratelist.length; i++){
                if(this.minimumrates !== undefined && this.minimumrates.length > 0){
                    for(var j=0; j<this.minimumrates[i].length; j++){
                        if(((this.salaryratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.salaryratelist[i].endingDate <= this.minimumrates[j].Effective_Date_To__c)) || ((this.salaryratelist[i].beggingDate >= this.minimumrates[j].Effective_Date_From__c) && (this.salaryratelist[i].endingDate === null))){
                            if(this.stateratelist !== undefined && this.stateratelist.length > 0){
                                for(var k=0; k<this.stateratelist[j].length; k++){
                                    if(((this.salaryratelist[i].beggingDate >= this.stateratelist[k].Effective_Date_From__c) && (this.salaryratelist[i].endingDate <= this.stateratelist[k].Effective_Date_To__c)) || ((this.salaryratelist[i].beggingDate >= this.stateratelist[k].Effective_Date_From__c) && (this.salaryratelist[i].endingDate === null)) && (this.stateratelist[k].Min_Wage_Rate__c > this.minimumrates[j].Min_Wage_Rate__c)){
                                        this.isMultipleLocalPay = true;
                                        break;
                                    }
                                }
                            }
                            if(this.isMultipleLocalPay === true){
                                break;
                            }
                        }
                    }
                }
                if(this.isMultipleLocalPay === true){
                    break;
                }
            }
        }
        if(this.isMultipleLocalPay === true){
            this.callLocalMinWage();
        }
        
    }

    async callOneHourlyRate(){
        try{
            await this.getAllVilationTypeVariablesForOneHourRate('1111');
        }catch (error){
            console.log('error', error);
        }
    }

    async callOneHourlyRateApplied(){
        try{
            await this.getAllVilationTypeVariablesForOneHourRateForMin('1112');
        }catch (error){
            console.log('error', error);
        }
    }

    async callAnyTypeOfPay(){
        try{
            await this.getAllVilationTypeVariablesForSS12('1113');
        }catch (error){
            console.log('error', error);
        }
    }

    async callLocalMinWage(){
        try{
            await this.getAllVilationTypeVariablesForSalaryWage('1114');
        }catch (error){
            console.log('error', error);
        }
    }



    // async handleServerResponse(){
    //     if(this.localminimumwagerate !== undefined && this.stateminimumwagerate !== undefined && this.localminimumwagerate < this.stateminimumwagerate){
    //         if(this.paymentOfWagesDetails.salaryRateOptionValue === true || this.paymentOfWagesDetails.differentHourOptionValue === true){
    //             try{
    //                 await this.getAllVilationTypeVariablesForSalaryWage('1114');
    //             }catch (error){
    //                 console.log('error', error);
    //             }
    //         }
    //     }
    //     else if(this.localminimumwagerate !== undefined && this.stateminimumwagerate !== undefined && this.localminimumwagerate > this.stateminimumwagerate){
    //         if(this.paymentOfWagesDetails.salaryRateOptionValue === true || this.paymentOfWagesDetails.differentHourOptionValue === true){
    //             try{
    //                 await this.getAllVilationTypeVariablesForSS12('1113');
    //             }catch (error){
    //                 console.log('error', error);
    //             }
    //         }
    //     }
    //     else if(this.paymentOfWagesDetails.HourlyOptionValue === true && (this.hourlyratelist.filter( element => (element > this.minimumWageRate) && (element !== null))).length > 0){
    //         try{
    //             await this.getAllVilationTypeVariablesForOneHourRate('1111');
    //         }catch (error){
    //             console.log('error', error);
    //         }
    //     }
        
    //     else if(this.paymentOfWagesDetails.HourlyOptionValue === true && (this.hourlyratelist.filter( element => (element <= this.minimumWageRate) && (element !== null))).length > 0){
    //         try{
    //             await this.getAllVilationTypeVariablesForOneHourRateForMin('1112');
    //         }catch (error){
    //             console.log('error', error);
    //         }
    //     }
    //     else{
    //         this.violationTypeVariablesForOneHourlyRate = undefined;
    //         this.isOneHourlyRatePOW = false;
    //     }
    // }

    @api violationTypeVariablesForSS12
    @api isSS12Visible = false;
    getAllVilationTypeVariablesForSS12(queryCode){
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
                 if(this.violationTypeVariablesForSS12 !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForSS12 = result;
                    this.violationTypeVariablesForSS12.length > 0 ? this.isSS12Visible = true : this.isSS12Visible = false;
                 }
                 this.iwcinfoobj.iwcOrderNumber !== undefined ? this.violationTypeVariablesForSS12.forEach( element => element.name === 'VTV1834' ? element.value = this.iwcinfoobj.iwcOrderNumber : '' ) : ''
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }
    @api violationTypeVariablesForOneHourlyRate
    @api isOneHourlyRatePOW = false;
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
                    else{
                        result[i].inputFormat = true;
                    }
                    result[i].value = '';
                }
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForOneHourlyRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForOneHourlyRate = result;
                    this.violationTypeVariablesForOneHourlyRate.length > 0 ? this.isOneHourlyRatePOW = true : this.isOneHourlyRatePOW = false;
                 }
                 this.iwcinfoobj.iwcOrderNumber !== undefined ? this.violationTypeVariablesForOneHourlyRate.forEach( element => element.name === 'VTV1005' || element.name === 'VTV1757' ? element.value = this.iwcinfoobj.iwcOrderNumber : '' ) : ''
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api violationTypeVariablesForOneHourlyForMin
    @api isOneHourlyForMin = false;
    getAllVilationTypeVariablesForOneHourRateForMin(queryCode){
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
                    result[i].name === 'VTV1757' ? result[i].isHide = true : result[i].isHide = false;
                    result[i].value = '';
                }
                // Check the datatype of the input fields

                 console.log('wage def result ::: ', JSON.stringify(result));
                 if(this.violationTypeVariablesForOneHourlyForMin !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForOneHourlyForMin = result;
                    this.violationTypeVariablesForOneHourlyForMin.length > 0 ? this.isOneHourlyForMin = true : this.isOneHourlyForMin = false;
                 }
                 this.iwcinfoobj.iwcOrderNumber !== undefined ? this.violationTypeVariablesForOneHourlyForMin.forEach( element => element.name === 'VTV1757' ? element.value = this.iwcinfoobj.iwcOrderNumber : '' ) : ''
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }
    
    @api violationTypeVariablesForSalaryRate
    @api isSalaryWagePOW = false;
    getAllVilationTypeVariablesForSalaryWage(queryCode){
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
                 if(this.violationTypeVariablesForSalaryRate !== undefined){

                 }
                 else{
                    this.violationTypeVariablesForSalaryRate = result;
                    this.violationTypeVariablesForSalaryRate.length > 0 ? this.isSalaryWagePOW = true : this.isSalaryWagePOW = false;
                 }
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        })
    }

    @api isNameValid = false;

    handleEmployerValidityEvent(){
        const selectEvent = new CustomEvent('employerworkedvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.dispatchEvent(selectEvent);
    }
    // This method is used to send the values to the parent cmp
    @api
    handleEmployerWorkedParent(){
        this.isNameValid === true ? this.handleEmployerValidityEvent() : this.handleEmployerParentInfo();
    }

    handleEmployerParentInfo(){
        const selectEvent = new CustomEvent('employerinfoevent', {
            detail:{
                employerWorkedObj : this.employerWorkedObj() ,
                vtCaseIssueObj : this.vtCaseIssueObj()
            }
        });
        this.dispatchEvent(selectEvent);
    }
    
    @api
    vtCaseIssueObj(){
        return{
            // violationTypeVariablesForOneHourlyRate : this.violationTypeVariablesForOneHourlyRate,
            violationTypeVariablesForOneHourlyForMin : this.violationTypeVariablesForOneHourlyForMin,
            // violationTypeVariablesForSalaryRate : this.violationTypeVariablesForSalaryRate,
            // violationTypeVariablesForSS12 : this.violationTypeVariablesForSS12
        }
    }

    employerWorkedObj(){
        return {
            violationTypeVariablesForOneHourlyRate : this.violationTypeVariablesForOneHourlyRate,
            violationTypeVariablesForOneHourlyForMin : this.violationTypeVariablesForOneHourlyForMin,
            violationTypeVariablesForSalaryRate : this.violationTypeVariablesForSalaryRate,
            isOneHourlyRatePOW : this.isOneHourlyRatePOW,
            isOneHourlyForMin : this.isOneHourlyForMin,
            isSalaryWagePOW : this.isSalaryWagePOW,
            violationTypeVariablesForSS12 : this.violationTypeVariablesForSS12,
            isSS12Visible : this.isSS12Visible
        }
    }
    // This method is used to take the values from the parent cmp.
    @api
    handleEmployerWorkedChild(strString, isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode;
        this.violationTypeVariablesForOneHourlyRate = strString.violationTypeVariablesForOneHourlyRate,
        this.violationTypeVariablesForOneHourlyForMin = strString.violationTypeVariablesForOneHourlyForMin,
        this.violationTypeVariablesForSalaryRate = strString.violationTypeVariablesForSalaryRate,
        this.isOneHourlyRatePOW = strString.isOneHourlyRatePOW,
        this.isOneHourlyForMin = strString.isOneHourlyForMin,
        this.isSalaryWagePOW = strString.isSalaryWagePOW,
        this.violationTypeVariablesForSS12 = strString.violationTypeVariablesForSS12,
        this.isSS12Visible = strString.isSS12Visible
    }

    // This method is used to take the input values from the user.
    handleChange(event){
        switch ( event.target.name ) {
        }
        if(this.violationTypeVariablesForOneHourlyRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForOneHourlyRate.length; i++){
                this.violationTypeVariablesForOneHourlyRate[i].name === event.target.name ? this.violationTypeVariablesForOneHourlyRate[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForOneHourlyForMin !== undefined){
            for(var i=0; i<this.violationTypeVariablesForOneHourlyForMin.length; i++){
                this.violationTypeVariablesForOneHourlyForMin[i].name === event.target.name ? this.violationTypeVariablesForOneHourlyForMin[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForSalaryRate !== undefined){
            for(var i=0; i<this.violationTypeVariablesForSalaryRate.length; i++){
                this.violationTypeVariablesForSalaryRate[i].name === event.target.name ? this.violationTypeVariablesForSalaryRate[i].value = event.target.value : ''
            }
        }

        if(this.violationTypeVariablesForSS12 !== undefined){
            for(var i=0; i<this.violationTypeVariablesForSS12.length; i++){
                this.violationTypeVariablesForSS12[i].name === event.target.name ? this.violationTypeVariablesForSS12[i].value = event.target.value : ''
            }
        }
    }

    // Renderedcallback
    renderedCallback(){

    }
}