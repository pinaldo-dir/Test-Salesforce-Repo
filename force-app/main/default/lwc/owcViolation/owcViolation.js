import { LightningElement ,api,wire, track} from 'lwc';
import loadCase from '@salesforce/apex/OwcVioltaionController.LoadCase'
import violationType from '@salesforce/apex/OwcVioltaionController.ViolationsTypes'
import addViolation from '@salesforce/apex/OwcVioltaionController.addViolation'
import SearchedViolationsTypes from '@salesforce/apex/OwcVioltaionController.SearchedViolationsTypes'
import caseIssue from '@salesforce/apex/OwcVioltaionController.caseIssue'
import liabilities from '@salesforce/apex/OwcVioltaionController.Liabilities'
import saveVarValues from '@salesforce/apex/OwcVioltaionController.saveVarValues'
import Finalize from '@salesforce/apex/OwcVioltaionController.Finalize'
import { CurrentPageReference } from "lightning/navigation";
import { loadStyle } from 'lightning/platformResourceLoader';
import NoHeader from '@salesforce/resourceUrl/NoHeader';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Liable_Party__c';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import OWCViolationStyle from '@salesforce/resourceUrl/OWCViolationStyle'  // Import static resource

//Basis_for_Liability__c
export default class OwcViolation  extends NavigationMixin (LightningElement) {
    @track items = [];
    recordTypeId = '';
    @track value = '';

    @wire(getPicklistValuesByRecordType, { objectApiName: ACCOUNT_OBJECT, recordTypeId: '$recordTypeId' })
    wiredRecordtypeValues({data, error}){
        if(data){
            const Res = data.picklistFieldValues.Basis_for_Liability__c.values
            for(let i=0; i<Res.length; i++) {
                this.items = [...this.items ,{value: Res[i].value , label: Res[i].label}];                                   
            }  
        }
        if(error){
            // console.log('ERROR',error);
        }
    }

    get liabOptions() {
        return this.items;
    }

    @track caseNumber;
    @track recId;
    @track dirData;
    @track violationTypes;
    @track ViolationId;
    @track error;
    @track vtMapping;
    @track selectedTypes = [];
    @track restId;
    @track selectedTypesSize;
    @track displaySelectedTypesSection = false;
    @track desDisplay = false;
    @track searched = false;
    @track counter = 0;
    @track searchViolationsTypes;
    @track selectedTypesIndex;
    @track paramStr = '';
    @track hasBofeViolationType = false;
    @track hasBofeNullValues = false;
    @track isLiablityAssigned = false;
    @track assignLiabilitiesButtonActive = false;
    @track isSecondPage = false;
    @track loadSpinner = false;
    @track Liabilities;
    @track varA;
    @track varW;
    @track varIW;
    @track uId = 0;
    @track TotalAmount = 0;
    @track TotalWages = 0;
    @track TotalInterestWages = 0;
    @track naicsCode;
    @track dlseProgram;
    @track employerIndustry;
    @track recordTypeText;
    @track recordType;
    @track iCInformationAB5;
    @track totalNumberofMisclassifiedEmployees;
    @track isValid = true;
    @track showAutoAddedVtModal = false;
    @track nameOfAutoAddedVt = '';
    @track nameOfManuallyAddedVt = '';
    @track selectedCitation = 'Single Citation One Number';
    @track selectedAll;
    @track liabSelect;
    @track isLiabSelected = false;
    @track propVisible = false;
    @track caseRectype;

    value = 'Single Citation One Number';

    get options() {
        return [
            { label: 'Single Citation One Number', value: 'Single Citation One Number' },
            { label: 'Separate Citations Multiple Citation Numbers', value: 'Separate Citations Multiple Citation Numbers' },
        ];
    }

    prepareUpdatedData(result){
        const tempList = JSON.parse(JSON.stringify(result));

        // const result = result.vtvWrapperList;
        for(var i=0; i<tempList.vtvWrapperList.length; i++){
            if(tempList.vtvWrapperList[i].vTypeVar.Data_Type__c === 'Date'){
                if(tempList.vtvWrapperList[i].vTypeVar.value__c === "" || tempList.vtvWrapperList[i].vTypeVar.value__c === undefined || tempList.vtvWrapperList[i].vTypeVar.value__c === null){
                    tempList.vtvWrapperList[i].vTypeVar.value__c = '';
                }else if(tempList.vtvWrapperList[i].vTypeVar.value__c !== undefined || tempList.vtvWrapperList[i].vTypeVar.value__c !== null){
                    let current_datetime = new Date((tempList.vtvWrapperList[i].vTypeVar.value__c));
                    const date = current_datetime.getFullYear() + "-" + (current_datetime.getMonth() + 1) + "-" + current_datetime.getDate();
                    tempList.vtvWrapperList[i].vTypeVar.value__c = '';
                    tempList.vtvWrapperList[i].vTypeVar.value__c = date;
                }
            }

            if(tempList.vtvWrapperList[i].dataType === 'Currency' || tempList.vtvWrapperList[i].dataType === 'Integer' || 
            tempList.vtvWrapperList[i].dataType === 'Decimal'){
                tempList.vtvWrapperList[i].dataType = 'Number';
            }
        }
        return tempList;
    }

    connectedCallback(){
        loadStyle(this, NoHeader),
        // Use 
        Promise.all([loadStyle(this, OWCViolationStyle)])
        .then(() => {})
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
        })

        loadCase({caseId: this.recId})
        .then(data => {
            if(data.length > 0){
                this.caseNumber = data[0].Case_Number__c;
                this.ViolationId = data[0].Violation_Type__c;
                this.caseRectype = data[0].RecordType.DeveloperName;
                this.dirData  = data;
                if(this.caseRectype == 'Garment' || this.caseRectype == 'RCI' || this.caseRectype =='Legacy_Garment_Case'){
                    this.propVisible = true;
                }
                this.onLoadCondCheck();
            }
            
        })
        .catch(error => {
            this.error = error;
            this.caseNumber = undefined;
        });        
        
        caseIssue({caseId: this.recId})
        .then(result => {
            //var result = [...response];
            for(let i = 0; i < result.length; i++){
                // if(result[i].dataType == 'date')
                // const updateVtList = this.prepareUpdatedData(result[i]);
                
                var currentItem = {...this.prepareUpdatedData(result[i])};
                currentItem.indexNumber = this.getUID();
                currentItem.a = 0;
                currentItem.b = 0;
                currentItem.c = 0;
                currentItem.amountPaidAP = 0;
                currentItem.amountEarnedAE = 0;
                this.selectedTypes.push([currentItem]);
                this.counter++;
                this.error = undefined;    
            }
            this.totalCalculation();
        })
        .catch(error => {
            this.error = error;
            // console.log('New Case Data',error);
        });

    }

    handleCitationChange(event){
        this.selectedCitation = event.detail.value;
        // console.log('this.selectedCitation',this.selectedCitation);
    }

    onLoadCondCheck(){
        for(let dDataItem of this.dirData){
            // console.log('onLoad dDataItem:',dDataItem);
            this.naicsCode = dDataItem.NAICS_Code__c;
            this.dlseProgram = dDataItem.DLSE_Program__c;
            this.employerIndustry = dDataItem.Employer_Industry__c;
            this.recordTypeText = dDataItem.Record_Type_Text__c;
            this.recordType = dDataItem.RecordType;
            this.iCInformationAB5 = dDataItem.IC_Determination__c;
            this.totalNumberofMisclassifiedEmployees = dDataItem.Total_Number_of_Misclassified_Employees__c;
        }
        
        if (this.dlseProgram == ''){
            this.isValid = false;
            this.showMessage('Please set the DLSE Program on the case record before adding any Case Issues.');
        }else if(this.employerIndustry == 'Not Specified' || this.naicsCode == null){
            this.isValid = false;
            this.showMessage('Please add the appropriate NAICS code to the employer’s account and verify that industry has been set correctly before adding any Case Issues.');
        }else if((this.iCInformationAB5 == 'AB5 Not 226.8' || this.iCInformationAB5 == 'AB5 Final') && this.totalNumberofMisclassifiedEmployees == '' ){
            this.isValid = false;
            this.showMessage('The deputy must enter the "total number of misclassifed employess');
        }else if(this.employerIndustry != 'Not Specified' && this.naicsCode != ''){
            this.isValid = true;
        }else if (this.employerIndustry == 'Not Specified' || this.naicsCode == ''){
            this.isValid = false;
            this.showMessage('Please add the appropriate NAICS code to the employer’s account and verify that industry has been set correctly before adding any Case Issues.');
        }else {
            this.isValid = true;
        }

        // if ((this.recordType.indexOf('BOFE') >= 0)) {
        //     if(this.employerIndustry != 'Not Specified' && this.dlseProgram != '' && this.naicsCode != '' 
        //         && ((this.iCInformationAB5 == 'AB5 Not 226.8' && this.totalNumberofMisclassifiedEmployees != '') || this.iCInformationAB5 != 'AB5 Not 226.8') 
        //         && ((this.iCInformationAB5 == 'AB5 Final' && this.totalNumberofMisclassifiedEmployees !='') || this.iCInformationAB5 != 'AB5 Final'))  {
        //         //window.location="/apex/NewViolation?id={!DIR_Case__c.Id}";
        //         this.isValid = true
        //     } else {
        //         if (this.dlseProgram == '')
        //             this.showMessage('Please set the DLSE Program on the case record before adding any Case Issues.');
        //         if (this.employerIndustry == 'Not Specified' || this.naicsCode == '')
        //             this.showMessage('Please add the appropriate NAICS code to the employer’s account and verify that industry has been set correctly before adding any Case Issues.');
        //         if ((this.iCInformationAB5 == 'AB5 Not 226.8' || this.iCInformationAB5 == 'AB5 Final') && this.totalNumberofMisclassifiedEmployees == '' )
        //             this.showMessage('The deputy must enter the "total number of misclassifed employess');
        //     }
        // } else if ((this.recordType.indexOf('WCA') >= 0)) {
        //     if(this.employerIndustry != 'Not Specified' && this.naicsCode != '') {
        //         this.isValid = true
        //     } else {
        //         if (this.employerIndustry == 'Not Specified' || this.naicsCode == '')
        //             this.showMessage('Please add the appropriate NAICS code to the employer’s account and verify that industry has been set correctly before adding any Case Issues.');
        //     }
        // } else {
        //     this.isValid = true
        // }
    }
    
    showMessage(Message){
        const evt = new ShowToastEvent({
            title: 'Info',
            message: Message,
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
            this.recId = currentPageReference?.state?.c__id;
       }
    }
    
    @wire(violationType,{caseId: '$recId'}) 
    WireViolationTypes({error, data}){
        if(data){
            this.violationTypes = data;
        }else{
            this.error = error;
            this.violationTypes = undefined;
        }
    }

    getUID(){
         return this.uId++;
    }


    doAddViolation(event){
        console.log('283 doAddViolation called');
        let autoAddLc3710_1 = false; //per SCR-906
        //this.recordTypeId = '012d00000019POuAAM';
        this.restId = event.currentTarget.dataset.id;
        this.save();

        addViolation({
            caseId: this.recId,
            violationId : this.restId
        })
        .then(result => {
            for(let vtv of result){

                /* Per SCR-906, if user adds LC 3722(a) or LC 3722(b), automatically add LC 3710.1 */
                if(vtv.vType.RecordType.DeveloperName.includes('BOFE') && vtv.vType.Violation_Type__c === 'BOFE 336' &&
                        (vtv.vType.Civil_Penalty_Section__c === 'LC 3722(a)' || vtv.vType.Civil_Penalty_Section__c === 'LC 3722(b)')){
                    this.autoAddLc3710_1 = true;
                    this.nameOfManuallyAddedVt = vtv.vType.Civil_Penalty_Section__c; 
                }

                vtv.indexNumber = this.getUID();
                vtv.a = 0;
                vtv.b = 0;
                vtv.c = 0;
                vtv.amountPaidAP = 0;
                vtv.amountEarnedAE = 0;
                for(let vV of vtv.vType.Violation_Type_Variables__r){
                    vV.value__c = '';
                }
                for(let vt of vtv.vtvWrapperList){
                    vt.vTypeVar.value__c  = vt.varValue;
                }
                for(let vTVar of vtv.vTypeVars){
                    vTVar.value__c  = '';
                }
                for(var i = 0; i < vtv.vtvWrapperList.length; i++){
                    if(vtv.vtvWrapperList[i].dataType !== null && (vtv.vtvWrapperList[i].dataType === 'Currency' || 
                            vtv.vtvWrapperList[i].dataType === 'Integer' || vtv.vtvWrapperList[i].dataType === 'Decimal')){
                        vtv.vtvWrapperList[i].dataType = 'Number';
                    }
                }
                this.counter++;
            }
            this.selectedTypes.push(result);
            this.totalCalculation();
            
            this.selectedTypesSize = result.length;
            if(this.selectedTypesSize > 0){
                this.displaySelectedTypesSection = true;
            }

            /* Per SCR-906, if user adds LC 3722(a) or LC 3722(b), automatically add LC 3710.1 */
            if(this.autoAddLc3710_1){
                addViolation({
                    caseId: this.recId,
                    violationId: 'LC 3710.1'
                })
                .then(result => {
                    for(let vtv of result){
                        this.nameOfAutoAddedVt = vtv.vType.Civil_Penalty_Section__c;
                        this.showAutoAddedVtModal = true;
                
                        vtv.indexNumber = this.getUID();
                        vtv.a = 0;
                        vtv.b = 0;
                        vtv.c = 0;
                        vtv.amountPaidAP = 0;
                        vtv.amountEarnedAE = 0;
                        for(let vV of vtv.vType.Violation_Type_Variables__r){
                            vV.value__c = '';
                        }
                        for(let vt of vtv.vtvWrapperList){
                            vt.vTypeVar.value__c  = vt.varValue;
                        }
                        for(let vTVar of vtv.vTypeVars){
                            vTVar.value__c  = '';
                        }
                        for(var i = 0; i < vtv.vtvWrapperList.length; i++){
                            if(vtv.vtvWrapperList[i].dataType !== null && (vtv.vtvWrapperList[i].dataType === 'Currency' || 
                                    vtv.vtvWrapperList[i].dataType === 'Integer' || vtv.vtvWrapperList[i].dataType === 'Decimal')){
                                vtv.vtvWrapperList[i].dataType = 'Number';
                            }
                        }
                        this.counter++;
                    }
                    this.selectedTypes.push(result);
                    this.totalCalculation();
                
                    this.selectedTypesSize = result.length;
                    if(this.selectedTypesSize > 0){
                        this.displaySelectedTypesSection  = true;
                    }
                    this.autoAddLc3710_1 = false;
                })                
            }
        })
        .catch(error => {
            this.error = error;
        })
    }


    /* 
    prepareDate(date){
        console.log('date ::: ', date);
    } */    
    
    
    //onSearch
    SearchCI(e) {
        var searchKey = e.target.value;
        var tempVar = '%'+searchKey+'%';

        SearchedViolationsTypes({
            caseId: this.recId,
            key : searchKey
        })
        .then(result =>{
            this.searchViolationsTypes = result;
        })
        .catch(error =>{
            this.error = error;
        })
        
        if(searchKey){
            this.searched = true;
        }else{
            this.searched = false;
        }
    }


    //onChange 
    valChanged(event){
        this.TotalWages = 0;
        const currentIndex = event.target.dataset.index;
        let selectedTypes = JSON.parse(JSON.stringify(this.selectedTypes));
        if(selectedTypes !== undefined){
            for(let i = 0; i < selectedTypes.length; i++){
                let currentSelected = selectedTypes[i];

                for(let selType of currentSelected){
                    if(Boolean(selType) && Boolean(selType.vType) && Boolean(selType.vType.Violation_Type_Variables__r)){
                        for(let vV of selType.vType.Violation_Type_Variables__r){
                            if(selType.indexNumber == event.target.dataset.index){
                                vV.Name == event.target.dataset.id ? vV.value__c =  event.target.value : '';
                            }
                        }
                    }

                    for(let vtv of selType.vtvWrapperList){
                        if(selType.indexNumber == event.target.dataset.index){
                            let tempVal = vtv.vTypeVar;
                            tempVal.Name == event.target.dataset.id ? tempVal.value__c = event.target.value : '';
                            tempVal.Name == event.target.dataset.id ? vtv.varValue = event.target.value : '';
                        }
                    }

                    for(let vTVar of selType.vTypeVars){
                        if(selType.indexNumber == event.target.dataset.index){
                            vTVar.Name == event.target.dataset.id  ? vTVar.value__c  = event.target.value : '';
                        }
                    }
                }
            }
        }
        this.selectedTypes = selectedTypes;
        this.totalCalculation();
    }
      
    //Remove
    doRemoveViolation(event){
        var varId = event.currentTarget.dataset.id;
        this.save();

        for(let i = 0; i < this.selectedTypes.length; i++){
            var selCounter = 0;

            for(let sel of this.selectedTypes[i]){
                if(sel.vType.Id == varId){
                    this.selectedTypesIndex = i;
                    this.selectedTypes[i].splice(sel.selCounter, 1);
                    selCounter++;
                    this.counter--;
                    this.totalCalculation();
                }
            }
        }
    }

    //SaveMethod
    save(){
        saveVarValues({valueString : this.paramStr})
        .then(result => {
            this.paramStr += result;
        })
        .catch(error => {
            this.error = error;
            // console.log('this.paramStr',error);
        });
    }

    @api vtv_48_value = 0;

    //TotalCalculation
    totalCalculation(){
        var totalAmount = 0; 
        var totalWages = 0;
        var totalInterestWages = 0;
        this.hasBofeViolationType = false;

        // Check for null fields on BOFE Violation Types
        for(let j = 0; j < this.selectedTypes.length; j++){
            for(let selType of this.selectedTypes[j]){
                
                if(selType.vType.RecordType.DeveloperName.includes('BOFE')){
                    this.hasBofeViolationType = true;
                    for(let vtv of selType.vtvWrapperList){
                        //is user input and value assigned
                        if(vtv.isUserInput && vtv.vTypeVar.value__c){
                            this.hasBofeNullValues = false;

                        //is user input and value not yet assigned
                        }else if(vtv.isUserInput && !vtv.vTypeVar.value__c){
                            this.hasBofeNullValues = true;
                            break;

                        //is not user input, fixed or null value
                        }else if(!vtv.isUserInput){
                            this.hasBofeNullValues = false;
                        }
                    }
                }

                if(this.hasBofeNullValues){
                    break;
                }
            }

            if(this.hasBofeNullValues){
                break;
            }
        }

        this.activateAssignLiabilitiesButton();

        for(let j = 0; j < this.selectedTypes.length; j++){
            
            for(let selType of this.selectedTypes[j]){
                var formulaStrA = String(selType.formula) === undefined ? '' : String(selType.formula);
                var formulaStrW = String(selType.wageformula) === undefined ? '' : String(selType.wageformula);
                var formulaStrIW = String(selType.wageinterestformula) === undefined ? '' : String(selType.wageinterestformula);
                var formulaStrAP = String(selType.amountPaidFormula) === undefined ? '' : String(selType.amountPaidFormula);
                var formulaStrAE = String(selType.amountEarnedFormula) === undefined ? '' : String(selType.amountEarnedFormula);
                var totalAP = 0;
                var totalAE = 0;
                var totalA = 0;
                var totalW = 0;
                var totalIW = 0;

                for(let vtv of selType.vtvWrapperList){
                    var vtvDataType = String(vtv.dataType);
                    var vtv48sId = 'VTV0048';
                    var sId = String(vtv.vtvName) || '';
                    if(vtv.vTypeVar.Name === 'VTV0048'){
                        this.vtv_48_value = Boolean(vtv.vTypeVar.value__c) ? vtv.vTypeVar.value__c : 0;
                    }
                    //String(formulaStrW).includes('VTV0048') ? (String(formulaStrW)).replace('VTV0048', this.vtv_48_value) : '';

                    var vtv48sVal = this.vtv_48_value;
                    var sVal = vtv.vTypeVar.value__c === undefined || vtv.vTypeVar.value__c === null ? '' : vtv.vTypeVar.value__c;
                    //vtv.vTypeVar.Name === 'VTV4315' ? '' : '';
                    sVal = sVal.replace(/^0+/, '');
                    if(vtvDataType == 'Currency' || vtvDataType == 'Decimal' || vtvDataType == 'Integer' || vtvDataType === 'Number'){

                        if(sVal !== undefined || sVal !== null){

                            while(sVal.includes(',') && sVal.indexOf(',') > -1){
                                sVal = sVal.replace(',', '');
                            }

                            if(isNaN(parseFloat(sVal))) sVal = 0;
                            
                            while((formulaStrA !== '' || formulaStrA !== undefined) && formulaStrA.indexOf(sId) > -1){
                                formulaStrA = formulaStrA.replace(sId, sVal);
                            }

                            while((formulaStrW != '' || formulaStrW !== undefined) && formulaStrW.indexOf(sId) > -1){
                                formulaStrW = (sId === 'VTV4315' && sVal === 0) ? formulaStrW.replace('*VTV4315', '') : formulaStrW.replace(sId, sVal);
                                formulaStrW = formulaStrW.replace(vtv48sId, vtv48sVal);
                            }

                            while((formulaStrIW != '' || formulaStrIW !== undefined) && formulaStrIW.indexOf(sId) > -1){
                                formulaStrIW = formulaStrIW.replace(sId, sVal);
                            }

                            while((formulaStrAP != '' || formulaStrAP !== undefined) && formulaStrAP.indexOf(sId) > -1){
                                formulaStrAP = formulaStrAP.replace(sId, sVal);
                            }

                            while((formulaStrAE != '' || formulaStrAE !== undefined) && formulaStrAE.indexOf(sId) > -1){
                                formulaStrAE = formulaStrAE.replace(sId, sVal);
                            }
                        }
                    }

                    if(sVal == '') sVal = '[No Value]';
                    this.paramStr  += selType.indexCounter+vtv.indexCounter+':'+sVal+'::';
                }
                var a;

                if(formulaStrA != 'undefined'){
                    totalA += eval(formulaStrA);
                    //var varValA = this.template.querySelector("lightning-input[data-id="+uIDa+"]");
                    a = eval(formulaStrA).toFixed(2);
                    if(isNaN(parseFloat(a))) a = 0;
                    selType.a = a;
                    totalAmount += parseFloat(a);
                }else{
                    a = 0;
                }

                selType.subTotalA = totalA;

                var w;

                if(formulaStrW != 'undefined'){
                    //formulaStrW.includes('VTV0048') ? formulaStrW.replace('VTV0048', 0) : ''
                    totalW += eval(formulaStrW);
                    //var varValW = this.template.querySelector("lightning-input[data-id="+uIDw+"]");
                    w = eval(formulaStrW).toFixed(2);

                    if(isNaN(parseFloat(w))) w = 0;

                    selType.b = w;
                    totalWages += parseFloat(w);
                }else{
                    w = 0;
                }
                selType.subTotalW = totalW;

                var iw;

                if(formulaStrIW != 'undefined'){
                    totalIW += eval(formulaStrIW);
                    //var varValW = this.template.querySelector("lightning-input[data-id="+uIDiw+"]");
                    iw = eval(formulaStrIW).toFixed(2);

                    if(isNaN(parseFloat(iw))) iw = 0;

                    selType.c = iw;
                    totalInterestWages += parseFloat(iw);
                }else{
                    iw = 0;
                }

                selType.subTotalIW = totalIW;
            
                var AP;

                if(formulaStrAP != 'undefined'){
                    AP = eval(formulaStrAP).toFixed(2);

                    if(isNaN(parseFloat(AP))) AP = 0;

                }else{
                    AP = 0;
                }
            
                var AE;
                if(formulaStrAE != 'undefined'){
                    AE = eval(formulaStrAE).toFixed(2);

                    if(isNaN(parseFloat(AE))) AE = 0;

                }else{
                    AE = 0;
                }

                selType.amountPaid = AP;
                selType.amountEarned = AE;
                this.paramStr += selType.indexCounter + 'TOTALW' + ':' + w + '::';
                this.paramStr += selType.indexCounter + 'TOTALIW' + ':' + iw + '::';
                this.paramStr += selType.indexCounter +' TOTALA' + ':' + a + '::';
                this.paramStr += selType.indexCounter + 'AMTP' + ':' + AP + '::';
                this.paramStr += selType.indexCounter + 'AMTE' + ':' + AE + '::';
            }
        }

        this.TotalAmount = totalAmount.toFixed(2);
        this.TotalWages = totalWages.toFixed(2);
        this.TotalInterestWages = totalInterestWages.toFixed(2);
    }

    //AssignLiabilities CheckBox
    assignLiabilities(event){
        this.validateCBValue = event.target.checked;

        if(this.validateCBValue === true){
            this.isLiablityAssigned = true;
        }else{
            this.isLiablityAssigned = false;
        }

        this.activateAssignLiabilitiesButton();
    }

    activateAssignLiabilitiesButton(){
        this.assignLiabilitiesButtonActive = this.isLiablityAssigned && !this.hasBofeNullValues && this.counter != 0;
    }

    //Handle Cancel
    handleCancel(){
        var url = window.location.href;
        var value = url.substring(0,url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }

    closeModal(){
        var url = window.location.href;
        var value = url.substring(0,url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }

    closeAutoAddedVtModal(){
        this.showAutoAddedVtModal = false;
    }

    //SecondStep
    GoToSecondStep(){
        this.isSecondPage = true;
        this.loadSpinner = false;
        liabilities({caseId: this.recId})
        .then(result => {
            this.Liabilities = result;
            for(let liab of result){ 
                this.recordTypeId = liab.thisLiabParty.RecordTypeId;
            }
            
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
        });
    }

    selectedAllOnchange(event){
        this.selectedAll = event.target.checked;
        let tempLiabList =  JSON.parse(JSON.stringify(this.Liabilities));
        for(let liab of tempLiabList ){
            if(this.selectedAll){
                liab.selected = event.target.checked;
            }else{
                liab.selected = false;
            }

            // if(liab.selected == true){
            //     this.isLiabSelected = true;
            // }else{
            //     this.isLiabSelected = false;
            // }
        }

        this.Liabilities = tempLiabList;
    }

    liabSelectedonChange(event){
        let tempLiabList =  JSON.parse(JSON.stringify(this.Liabilities));
        for(let liab of tempLiabList){
            if(liab.Name === event.target.dataset.id && liab.Affiliation === event.target.dataset.affiliation){
                liab.selected = event.target.checked;
            }

            // if(liab.selected == true){
            //     this.isLiabSelected = true;
            // }else{
            //     this.isLiabSelected = false;
            // }
        }
        this.Liabilities = tempLiabList;
    }

    //BackTo1stStep
    BackTo1stStep(){
        this.isSecondPage = false;
        this.loadSpinner = false;
        this.save();
    }

    handlePropData(event) {
        var tempLiabList =  JSON.parse(JSON.stringify(this.Liabilities));
        for(var liab of tempLiabList){
            if(liab.Name === event.target.dataset.id){
                liab.propShare = event.target.value;
            }
        }
        this.Liabilities = tempLiabList;
    }

    handleBasicLiability(event){
        var tempLiabList =  JSON.parse(JSON.stringify(this.Liabilities));
        for(var liab of tempLiabList){
            if(liab.Name === event.target.dataset.id){
                liab.thisLiabParty.Basis_for_Liability__c = event.target.value;
            }
        }
        this.Liabilities = tempLiabList;
    }

    rewriteSubquery(array) {
        if (array && !array.hasOwnProperty('records')) {
            var tempArray = array;
            array = {
                totalSize: tempArray.length,
                done: true,
                records: tempArray
            }
        }
        return array;
    };

    updateDateFormatForWrapper(value){
        for(var i = 0; i < value.length; i++){
            if((value[i].vTypeVar.Data_Type__c !== undefined || value[i].vTypeVar.Data_Type__c !== null) && value[i].vTypeVar.Data_Type__c === 'Date'){
                
                var s = (value[i].vTypeVar.value__c === undefined || value[i].vTypeVar.value__c === null) ? '' : value[i].vTypeVar.value__c.split('-');
            
                if(s.length == 3){
                    var newMonth= '';
                    if(s[1].length == 1){
                        newMonth = '0'+s[1];
                    }else{
                        newMonth = s[1];
                    }
                    
                    var newDate = newMonth+'/'+s[2]+'/'+s[0];
                    value[i].vTypeVar.value__c = newDate;
                    value[i].varValue = newDate;
                }
            }
        }
    }

    updateDateFormat(value){
        for(var i = 0; i < value.length; i++){
            if((value[i].Data_Type__c !== undefined || value[i].Data_Type__c !== null) && value[i].Data_Type__c === 'Date'){
    
                var s = (value[i].value__c === undefined || value[i].value__c === null) ? '' : value[i].value__c.split('-');
            
                if(s.length == 3){
                    var newMonth= '';
                    if(s[1].length == 1){
                        newMonth = '0'+s[1];
                    }else{
                        newMonth = s[1];
                    }
                    
                    var newDate = newMonth+'/'+s[2]+'/'+s[0];
                    value[i].value__c = newDate;
                }
            }
        }
    }

    Finalize(){
        if(this.Liabilities != null && this.Liabilities.length > 0){
            this.isLiabSelected = this.Liabilities.some(item => item.selected === true);
        }
        if(this.isLiabSelected == true){
            this.isSecondPage = false;
            this.loadSpinner = true;

            let finalArray = [];
            for(let i = 0; i < this.selectedTypes.length; i++){
                for(let selType of this.selectedTypes[i]){
                    this.updateDateFormat(selType.vTypeVars);
                    this.updateDateFormat(selType.vType);
                    this.updateDateFormatForWrapper(selType.vtvWrapperList);

                    selType.vType.Violation_Type_Variables__r =  this.rewriteSubquery(selType.vType.Violation_Type_Variables__r);

                    finalArray.push(selType);
                }
            }

            const selData = '{"ViolationTypeWrap":'+JSON.stringify(finalArray)+'}';
            
            const Liab = '{"LiabilityWrap":'+JSON.stringify(this.Liabilities)+'}';

            Finalize({
                caseId: this.recId,
                valueString : this.paramStr,
                SelTypesList:selData,
                LiabStringfy : Liab,
                SelectedCitation : this.selectedCitation,
            })
            .then(result => {
                const toastEvent = new ShowToastEvent({
                    title:'Success!',
                    message:'Record created successfully',
                    variant:'success'
                  });
                  this.dispatchEvent(toastEvent);
         
                  /*Start Navigation*/
                  this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recId,
                        objectApiName: 'DIR_Case__c',
                        actionName: 'view'
                    },
                 });
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                const toastEvent = new ShowToastEvent({
                    title:'Error!',
                    message:error.message,
                    variant:'error'
                  });
                this.dispatchEvent(toastEvent);
                this.loadSpinner = false;
            });

        }else{
            const evt = new ShowToastEvent({
                title: 'Error!',
                message: 'Please select Individual(s) Liable for these case issue(s)',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    // navigateToViewAccountPage() {
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__recordPage',
    //         attributes: {
    //             recordId: this.recId,
    //             objectApiName: 'DIR_Case__c',
    //             actionName: 'view'
    //         },
    //     });
    // }

}