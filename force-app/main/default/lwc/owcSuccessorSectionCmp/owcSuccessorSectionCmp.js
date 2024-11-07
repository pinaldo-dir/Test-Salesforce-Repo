import { LightningElement,track,api ,wire} from 'lwc';
import { radioOptions } from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import OWC_empinfo_Phone from '@salesforce/label/c.OWC_empinfo_Phone';
import OWC_successor_info_estimation from '@salesforce/label/c.OWC_successor_info_estimation';
import OWC_successor_nameofperson_helptext from '@salesforce/label/c.OWC_successor_nameofperson_helptext';
import OWC_required_field_error_msg from '@salesforce/label/c.OWC_required_field_error_msg';
import OWC_empinfo_VehicleLicense from '@salesforce/label/c.OWC_empinfo_VehicleLicense';
import OWC_street_address from '@salesforce/label/c.OWC_street_address';
import OWC_city from '@salesforce/label/c.OWC_city';
import OWC_zipcode from '@salesforce/label/c.OWC_zipcode';
import OWC_email from '@salesforce/label/c.OWC_email';
import OWC_website from '@salesforce/label/c.OWC_website';
import OWC_state from '@salesforce/label/c.OWC_state';
import OWC_industryinfo_businessname from '@salesforce/label/c.OWC_industryinfo_businessname';
import OWC_successorinfo_HireDate from '@salesforce/label/c.OWC_successorinfo_HireDate';
import OWC_successorinfo_LastDate from '@salesforce/label/c.OWC_successorinfo_LastDate';
import OWC_successorinfo_WorkForThisComp from '@salesforce/label/c.OWC_successorinfo_WorkForThisComp';
import OWC_successorinfo_WorkWithSameCoWorkerComp from '@salesforce/label/c.OWC_successorinfo_WorkWithSameCoWorkerComp';
import OWC_successorinfo_BothCompOwnershipRelated from '@salesforce/label/c.OWC_successorinfo_BothCompOwnershipRelated';
import OWC_successorinfo_WhenYouJoinComp from '@salesforce/label/c.OWC_successorinfo_WhenYouJoinComp';
import OWC_successor_info_heading from '@salesforce/label/c.OWC_successor_info_heading';
import OWC_successor_morethanonecompany_info from '@salesforce/label/c.OWC_successor_morethanonecompany_info';
import OWC_successoraddinfo_nameofperson from '@salesforce/label/c.OWC_successoraddinfo_nameofperson';
import OWC_successoraddinfo_personincharge from '@salesforce/label/c.OWC_successoraddinfo_personincharge';
import OWC_successoraddinfo_whopaidyou from '@salesforce/label/c.OWC_successoraddinfo_whopaidyou';
import OWC_successoraddinfo_workschedule from '@salesforce/label/c.OWC_successoraddinfo_workschedule';
import OWC_successoraddinfo_workhours from '@salesforce/label/c.OWC_successoraddinfo_workhours';
import OWC_successoraddinfo_timecard from '@salesforce/label/c.OWC_successoraddinfo_timecard';
import OWC_successoraddinfo_workrecorded from '@salesforce/label/c.OWC_successoraddinfo_workrecorded';
import OWC_successoraddinfo_totalemployees from '@salesforce/label/c.OWC_successoraddinfo_totalemployees';
import OWC_successoraddinfo_heading from '@salesforce/label/c.OWC_successoraddinfo_heading';
import OWC_pastdate_error_msg from '@salesforce/label/c.OWC_pastdate_error_msg';
import OWC_select_picklist_label from '@salesforce/label/c.OWC_select_picklist_label';
import OWC_hiredate_error_msg from '@salesforce/label/c.OWC_hiredate_error_msg';
import OWC_hepttext_header from '@salesforce/label/c.OWC_hepttext_header';
import OWC_invalid_email_msg from '@salesforce/label/c.OWC_invalid_email_msg';
import OWC_invalid_phone_msg from '@salesforce/label/c.OWC_invalid_phone_msg';
import OWC_invalid_zipcode_msg from '@salesforce/label/c.OWC_invalid_zipcode_msg';
import OWC_lastdate_error_msg from '@salesforce/label/c.OWC_lastdate_error_msg';
import OWC_date_format_label from '@salesforce/label/c.OWC_date_format_label';
import OWC_learnmore_button from '@salesforce/label/c.OWC_learnmore_button';
import OWC_Yes from '@salesforce/label/c.OWC_Yes';
import OWC_No from '@salesforce/label/c.OWC_No';
import OWC_Additional_Info from '@salesforce/label/c.OWC_Additional_Info';
import OWC_successor_delete_button from '@salesforce/label/c.OWC_successor_delete_button';
import fetchHoursWorkedMetaData from '@salesforce/apex/OWCSuccessorInfoController.fetchHoursWorkedMetaData'
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData'
import owcWorkRecordList from '@salesforce/apex/OwcBusinessController.fetchOwcWorkRecorded';
import OWC_successor_employer_heading from '@salesforce/label/c.OWC_successor_employer_heading';
export default class OwcSuccessorSectionCmp extends LightningElement {

    @track isMoreThanOneCompany;
    @track moreThanOneComp;
    @api islabelsinfo;
    @track successorBusinessName;
    @track successorStreetAddress;
    @track successorCity;
    @track successorState;
    @track successorZipCode;
    @track successorBusinessPhone;
    @track successorEmail;
    @track successorVehicleLicense;
    @track successorWebsite;
    @track hireDate;
    @track lastDate;
    @track workForThisComp;
    @track workWithSameWorokers;
    @track ownershipOfCompRelated;
    @track nameOfPersonInCharge;
    @track jobTitleOfPersonInCharge;
    @track whoPaidYou;
    @track workSchedule;
    @track workHours;
    @track timeCard;
    @track workRecorded;
    @track totalEmployees;
    @api isHelpText = false;
    @api ownershipOptions;
    @api hoursWorkRecordedOptions;
    @api owcWorkRecordList_List

    @api successorheading
    @api deletebutton
    @api sectionid
    @api isFormPreviewMode = false;

    @api dateFormatLabel = `(${OWC_date_format_label})`
    
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
    customLabelValues = { 
        OWC_select_picklist_label, 
        OWC_successor_employer_heading, 
        OWC_successor_delete_button,
        OWC_learnmore_button,
        OWC_empinfo_Phone, 
        OWC_empinfo_VehicleLicense,  
        OWC_street_address,
        OWC_city,
        OWC_zipcode,
        OWC_email,
        OWC_website,
        OWC_state,
        OWC_industryinfo_businessname,
        OWC_successorinfo_HireDate,
        OWC_successorinfo_LastDate,
        OWC_successorinfo_WorkForThisComp,
        OWC_successorinfo_WorkWithSameCoWorkerComp,
        OWC_successorinfo_BothCompOwnershipRelated,
        OWC_successorinfo_WhenYouJoinComp,
        OWC_successor_info_heading,
        OWC_successor_morethanonecompany_info,
        OWC_successoraddinfo_nameofperson,
        OWC_successoraddinfo_personincharge,
        OWC_successoraddinfo_whopaidyou,
        OWC_successoraddinfo_workschedule,
        OWC_successoraddinfo_workhours,
        OWC_successoraddinfo_timecard,
        OWC_successoraddinfo_workrecorded,
        OWC_successoraddinfo_totalemployees,
        OWC_successoraddinfo_heading,
        OWC_hepttext_header,
        OWC_Additional_Info
    }

    //Yes or No PickList
    options = radioOptions

    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) {  
            case "moreThanOneComp":
                this.moreThanOneComp = event.detail.value;
                console.log('moreThanOneComp :::', this.moreThanOneComp);
                if(this.moreThanOneComp === OWC_Yes){

                    this.successorBusinessName = null;
                    this.successorStreetAddress = null;
                    this.successorCity = null;
                    this.successorState = null;
                    this.successorZipCode = null;
                    this.successorBusinessPhone = null;
                    this.successorEmail = null;
                    this.successorVehicleLicense = null;
                    this.successorWebsite = null;
                    this.isMoreThanOneCompany = true;
                }else{
                    this.isMoreThanOneCompany = false;
                }
            break;
            case "successorBusinessName":
                this.successorBusinessName = event.detail.value;
                console.log('successorBusinessName :::',this.successorBusinessName);  
            break;
            case "successorStreetAddress":
                this.successorStreetAddress = event.detail.value;
                console.log('successorStreetAddress :::',this.successorStreetAddress);
            break;
            case "successorCity":
                this.successorCity = event.detail.value;
                console.log('successorCity :::',this.successorCity);
            break;
            case "successorState":
                this.successorState = event.detail.value;
                console.log('successorState :::',this.successorState);
            break;
            case "successorZipCode":
                this.successorZipCode = event.detail.value;
                console.log('successorZipCode :::',this.successorZipCode);
            break;
            case "successorBusinessPhone":
                this.successorBusinessPhone = event.detail.value;
                console.log('successorBusinessPhone :::',this.successorBusinessPhone);
            break;
            case "successorEmail":
                this.successorEmail = event.detail.value;
                console.log('successorEmail :::',this.successorEmail);
            break;
            case "successorVehicleLicense":
                this.successorVehicleLicense = event.detail.value;
                console.log('successorVehicleLicense :::',this.successorVehicleLicense);
            break;
            case "successorWebsite":
                this.successorWebsite = event.detail.value;
                console.log('successorWebsite :::',this.successorWebsite);
            break;
            case "hireDate":
                this.hireDate = event.detail.value;
                console.log('hireDate :::',this.hireDate);
            break;
            case "lastDate":
                this.lastDate = event.detail.value;
                console.log('lastDate :::',this.lastDate);
            break;
            case "workForThisComp":
                this.workForThisComp = event.detail.value;
                console.log('workForThisComp :::',this.workForThisComp);
            break;
            case "workWithSameWorokers":
                this.workWithSameWorokers = event.detail.value;
                console.log('workWithSameWorokers :::',this.workWithSameWorokers);
            break;
            case "ownershipOfCompRelated":
                this.ownershipOfCompRelated = event.detail.value;
                console.log('ownershipOfCompRelated :::',this.ownershipOfCompRelated);
            break;
            case "nameOfPersonInCharge":
                this.nameOfPersonInCharge = event.detail.value;
                console.log('nameOfPersonInCharge :::',this.nameOfPersonInCharge);
            break;
            case "jobTitleOfPersonInCharge":
                this.jobTitleOfPersonInCharge = event.detail.value;
                console.log('jobTitleOfPersonInCharge :::',this.jobTitleOfPersonInCharge);
            break;
            case "whoPaidYou":
                this.whoPaidYou = event.detail.value;
                console.log('whoPaidYou :::',this.whoPaidYou);
            break;
            case "workSchedule":
                this.workSchedule = event.detail.value;
                console.log('workSchedule :::',this.workSchedule);
            break;
            case "workHours":
                this.workHours = event.detail.value;
                console.log('workHours :::',this.workHours);
            break;
            case "timeCard":
                this.timeCard = event.detail.value;
                console.log('timeCard :::',this.timeCard);
            break;
            case "workRecorded":
                this.workRecorded = event.detail.value;
                console.log('workRecorded :::',this.workRecorded);
            break;     
            case "totalEmployees":
                this.totalEmployees = event.detail.value;
                console.log('totalEmployees :::',this.totalEmployees);
            break; 
        }
    }

    handleSuccessorDelete(event){
        event.preventDefault()
        console.log('sectionId in child ::: ', this.sectionId)
        const selectEvent = new CustomEvent('customsuccessordeleteevent', {
            detail: {
                sectionId : this.sectionid
            }
        });
        this.dispatchEvent(selectEvent);
    }

    @api
    handleSuccessorSectionData(){
        const selectEvent = new CustomEvent('successorsectiondeleteevent', {
            detail: {     
                sectionId : this.sectionid,            
                 moreThanOneComp : this.moreThanOneComp,
                 isMoreThanOneCompany : this.isMoreThanOneCompany,
                 successorBusinessName : this.successorBusinessName,
                 successorStreetAddress : this.successorStreetAddress,
                 successorCity : this.successorCity,
                 successorState : this.successorState,
                 successorZipCode : this.successorZipCode,
                 successorBusinessPhone : this.successorBusinessPhone,
                 successorEmail : this.successorEmail,
                 successorVehicleLicense : this.successorVehicleLicense,
                 successorWebsite : this.successorWebsite,
                 hireDate : this.hireDate,
                 lastDate : this.lastDate,
                 workForThisComp : this.workForThisComp,
                 workWithSameWorokers : this.workWithSameWorokers,
                 ownershipOfCompRelated : this.ownershipOfCompRelated,
                 nameOfPersonInCharge : this.nameOfPersonInCharge,
                 jobTitleOfPersonInCharge : this.jobTitleOfPersonInCharge,
                 whoPaidYou : this.whoPaidYou,
                 workSchedule : this.workSchedule,
                 workHours : this.workHours,
                 timeCard : this.timeCard,
                 workRecorded : this.workRecorded,
                 totalEmployees : this.totalEmployees,
            }
        });
        this.dispatchEvent(selectEvent);
    }

    handleHireDateFocus(event){
        let hireDate = this.template.querySelector('[data-id="hireDate"]');
        let lastDate = this.template.querySelector('[data-id="lastDate"]');
        let id = hireDate
        let value = hireDate.value
        var inputStartDate
        var inputEndDate
        var today = new Date();
        if(value != null){
            inputStartDate = new Date(value.toString());
            inputEndDate = new Date(lastDate.value.toString())
        }
        else{
            inputStartDate = value;
            inputEndDate = lastDate.value;
        }
        if(inputStartDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(OWC_pastdate_error_msg);
            id.reportValidity();
        }
        else if(inputStartDate.setHours(0,0,0,0) > inputEndDate.setHours(0,0,0,0)){
            id.setCustomValidity(OWC_hiredate_error_msg)
            lastDate.setCustomValidity(OWC_lastdate_error_msg)
            id.reportValidity();
            lastDate.reportValidity();
        }
        else{
            id.setCustomValidity('');
            lastDate.setCustomValidity('')
            lastDate.reportValidity();
            id.reportValidity();
        }
        
    }

    @api employerNameAfterEmployementDetails
    @api isNotChangedCurrentStep = false

    // Event handler for Employer Name changed after employement
    handleEmployerNameAfterEmployement(event){
        this.employerNameAfterEmployementDetails = event.detail
        this.isNotChangedCurrentStep = false;
        console.log('employerNameAfterEmployementDetails ::: ', JSON.stringify(this.employerNameAfterEmployementDetails));
    }

    handleEmployerNameAfterEmployementValidity(event){
        this.isNotChangedCurrentStep = event.detail.currentStep
    }

    handleLastDateFocus(){
        let lastDate = this.template.querySelector('[data-id="lastDate"]');
        let hireDate = this.template.querySelector('[data-id="hireDate"]');
        let id = lastDate
        let value = lastDate.value
        var inputStartDate
        var inputEndDate
        var today = new Date();
        if(value != null){
            inputEndDate = new Date(value.toString());
            inputStartDate = new Date(hireDate.value.toString())
        }
        else{
            inputEndDate = value;
            inputStartDate = inputStartDate.value;
        }
        if(inputEndDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            id.setCustomValidity(OWC_pastdate_error_msg);
            id.reportValidity();
        }
        else if(inputStartDate.setHours(0,0,0,0) > inputEndDate.setHours(0,0,0,0)){
            id.setCustomValidity(OWC_lastdate_error_msg)
            hireDate.setCustomValidity(OWC_hiredate_error_msg)
            hireDate.reportValidity();
            id.reportValidity();
        }
        else{
            hireDate.setCustomValidity('');
            hireDate.reportValidity();
            id.setCustomValidity('');
            id.reportValidity();
        }
    }

    isHireDate = false
    isLastDate = false
    isSuccessorDateAcceptable = false

    preliminarySectionBirthdayValidityChecker(ids, values){
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
            id.setCustomValidity('Please select past date.');
            id.reportValidity();
        return true;
        }
    }

    successorSectionDateValidityChecker(ids, values){
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
            id.setCustomValidity(OWC_pastdate_error_msg);
            id.reportValidity();
        return true;
        }
    }

    handleZipCodeFocus(){
        const successorZipCode = this.template.querySelector('[data-id="successorZipCode"]')
        if(successorZipCode.value.trim() == null || successorZipCode.value.trim() == undefined || successorZipCode.value.trim() == ''){
            this.isZipCodeRequired = false
            successorZipCode.setCustomValidity('');
            successorZipCode.reportValidity()
        }
        else if(successorZipCode.value.trim() != null || successorZipCode.value.trim() != undefined || successorZipCode.value.trim() != ''){
            const successorZipCode = this.template.querySelector('[data-id="successorZipCode"]');
            if(successorZipCode.value.match(this.zipCodeRegrex)){
                successorZipCode.setCustomValidity("");
                this.isZipCodeRequired = false
                successorZipCode.reportValidity()
            }
            else{
                successorZipCode.setCustomValidity(OWC_invalid_zipcode_msg);
                this.isZipCodeRequired = true
                successorZipCode.reportValidity()
            }                
        }
        else{
            this.isZipCodeRequired = false
        }



        // const successorZipCode = this.template.querySelector('[data-id="successorZipCode"');
        // if(successorZipCode.value === undefined || successorZipCode.value === null || successorZipCode.value.trim() === ''){
        //     successorZipCode.setCustomValidity('')
        // }
        // else if(successorZipCode.value.match(this.zipCodeRegrex)){
        //     successorZipCode.setCustomValidity('')
        // }
        // else{
        //     successorZipCode.setCustomValidity(OWC_invalid_zipcode_msg)
        // }
        // successorZipCode.reportValidity()
    }

    //Successor Event
    handleSuccessorSectionEvent(){
        const selectEvent = new CustomEvent('successorsectioncustomevent', {
            detail: {              
                sectionId : this.sectionid,     
                 moreThanOneComp : this.moreThanOneComp,
                 isMoreThanOneCompany : this.isMoreThanOneCompany,
                 successorBusinessName : this.successorBusinessName,
                 successorStreetAddress : this.successorStreetAddress,
                 successorCity : this.successorCity,
                 successorState : this.successorState,
                 successorZipCode : this.successorZipCode,
                 successorBusinessPhone : this.successorBusinessPhone,
                 successorEmail : this.successorEmail,
                 successorVehicleLicense : this.successorVehicleLicense,
                 successorWebsite : this.successorWebsite,
                 hireDate : this.hireDate,
                 lastDate : this.lastDate,
                 workForThisComp : this.workForThisComp,
                 workWithSameWorokers : this.workWithSameWorokers,
                 ownershipOfCompRelated : this.ownershipOfCompRelated,
                 nameOfPersonInCharge : this.nameOfPersonInCharge,
                 jobTitleOfPersonInCharge : this.jobTitleOfPersonInCharge,
                 whoPaidYou : this.whoPaidYou,
                 workSchedule : this.workSchedule,
                 workHours : this.workHours,
                 timeCard : this.timeCard,
                 workRecorded : this.workRecorded,
                 totalEmployees : this.totalEmployees,
                 employerNameAfterEmployementDetails : this.employerNameAfterEmployementDetails
            }
        });
        this.dispatchEvent(selectEvent);
    }

    handleSuccessorBusinessPhoneFocus(){
        const successorBusinessPhone = this.template.querySelector('[data-id="successorBusinessPhone"]')
        if(successorBusinessPhone.value.trim() == null || successorBusinessPhone.value.trim() == undefined || successorBusinessPhone.value.trim() == ''){
            this.isPhoneChecked = false
            successorBusinessPhone.setCustomValidity('');
            successorBusinessPhone.reportValidity()
        }
        else if(successorBusinessPhone.value.trim() != null || successorBusinessPhone.value.trim() != undefined || successorBusinessPhone.value.trim() != ''){
            const successorBusinessPhone = this.template.querySelector('[data-id="successorBusinessPhone"]');
            if(successorBusinessPhone.value.match(this.regExpPhone)){
                successorBusinessPhone.setCustomValidity("");
                this.isPhoneChecked = false
                successorBusinessPhone.reportValidity()
            }
            else{
                successorBusinessPhone.setCustomValidity(OWC_invalid_phone_msg);
                this.isPhoneChecked = true
                successorBusinessPhone.reportValidity()
            }                
        }

        // const successorBusinessPhone = this.template.querySelector('[data-id="successorBusinessPhone"');
        // if(successorBusinessPhone.value === undefined || successorBusinessPhone.value === null || successorBusinessPhone.value.trim() === ''){
        //     successorBusinessPhone.setCustomValidity('')
        // }
        // else if(successorBusinessPhone.value.match(this.regExpPhone)){
        //     successorBusinessPhone.setCustomValidity('')
        // }
        // else{
        //     successorBusinessPhone.setCustomValidity(OWC_invalid_phone_msg)
        // }
        // successorBusinessPhone.reportValidity()
    }

    handleSuccessorEmailFocus(){
        const successorEmail = this.template.querySelector('[data-id="successorEmail"]')
        if(successorEmail.value === undefined || successorEmail.value === null || successorEmail.value === ''){
            this.issuccessorEmail = false
            successorEmail.setCustomValidity('')
            successorEmail.reportValidity()
        }
        else{
            if(successorEmail.value.match(this.regExpEmailformat)){
                this.issuccessorEmail = false
           }
           else{
                this.issuccessorEmail = true
                successorEmail.setCustomValidity(OWC_invalid_email_msg)
                successorEmail.reportValidity()
           }
           
        }


        // if(this.individualRepEmail == undefined || this.individualRepEmail == null || this.individualRepEmail.trim() == ''){
        // }
        // else{
        //     if(this.successorEmail.match(this.regExpEmailformat)){
        //         let successorEmail = this.template.querySelector('[data-id="successorEmail"]');
        //         successorEmail.setCustomValidity('');
        //         successorEmail.reportValidity();
        //     }
        //     else{
        //         let successorEmail = this.template.querySelector('[data-id="successorEmail"]');
        //         successorEmail.setCustomValidity(OWC_invalid_email_msg)
        //         successorEmail.reportValidity();
        //     }
        // }
    }
    regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    regExpPhone = /^((\\+[1-9]{1,4}[ \\-]*)|(\\([0-9]{2,3}\\)[ \\-]*)|([0-9]{2,4})[ \\-]*)*?[0-9]{3,4}?[ \\-]*[0-9]{3,4}?$/;
    zipCodeRegrex = /^[0-9]{5}(?:[0-9]{4})?$/;
    isZipCodeRequired = false
    isPhoneChecked = false
    issuccessorEmail = false
    @api isemployernamechanged = false

    @api 
    owcSuccessorDataForParent(){
            this.template.querySelector('c-owc-Employer-Name-After-Employement').handleEmployerNameChangedParent();
            this.isNotChangedCurrentStep === true ? this.handleCustomValidityEvent() : this.handleSuccessorSectionEvent(); 
        //  ? 
    }
    handleCustomValidityEvent(){
        const selectEvent = new CustomEvent('successorsectionvalidity', {
            detail: {
                currentStep : true
            }
        });
        this.dispatchEvent(selectEvent);
        return;
    }
    @api successorSectionDetails
    @api dateSection = false
    @api additionalSuccesorSectionTemplate = false
    @api
    owcSucessorInfoForChild(strString,isFormPreviewMode){

            this.successorSectionDetails = strString
            this.isFormPreviewMode = isFormPreviewMode

            if(this.successorSectionDetails.nameOfPersonInCharge != null || this.successorSectionDetails.jobTitleOfPersonInCharge != null || this.successorSectionDetails.whoPaidYou != null || this.successorSectionDetails.workSchedule != null || this.successorSectionDetails.workHours != null || this.successorSectionDetails.timeCard != null || this.successorSectionDetails.workRecorded != null || this.successorSectionDetails.totalEmployees != null){
                this.additionalSuccesorSectionTemplate = true;
            }

            if(isNaN(strString.workForThisComp)){
                this.template.querySelector('[data-id="workForThisComp"]').value = strString.workForThisComp
                this.workForThisComp = strString.workForThisComp
            }
            if(isNaN(strString.workWithSameWorokers)){
                this.template.querySelector('[data-id="workWithSameWorokers"]').value = strString.workWithSameWorokers
                this.workWithSameWorokers = strString.workWithSameWorokers
            }
            if(isNaN(strString.ownershipOfCompRelated)){
                this.template.querySelector('[data-id="ownershipOfCompRelated"]').value = strString.ownershipOfCompRelated
                this.ownershipOfCompRelated = strString.ownershipOfCompRelated
            }
            // if(strString.workHours !== undefined || strString.workHours !== null){
            //     this.template.querySelector('[data-id="workHoursId"]').value = strString.workHours
            //     this.workHours = strString.workHours
            // }
            // if(isNaN(strString.timeCard)){
            //     this.template.querySelector('[data-id="timeCard"]').value = strString.timeCard
            //     this.timeCard = strString.timeCard
            // }
            this.isMoreThanOneCompany = strString.isMoreThanOneCompany,
            this.successorBusinessName = strString.successorBusinessName,
            this.successorStreetAddress = strString.successorStreetAddress,
            this.successorCity = strString.successorCity,
            this.successorState = strString.successorState,
            this.successorZipCode = strString.successorZipCode,
            this.successorBusinessPhone = strString.successorBusinessPhone,
            this.successorEmail = strString.successorEmail,
            this.successorVehicleLicense = strString.successorVehicleLicense,
            this.successorWebsite = strString.successorWebsite,
            
            this.nameOfPersonInCharge = strString.nameOfPersonInCharge,
            this.jobTitleOfPersonInCharge = strString.jobTitleOfPersonInCharge,
            this.whoPaidYou = strString.whoPaidYou,
            this.workSchedule = strString.workSchedule,
           
            this.workRecorded = strString.workRecorded,
            this.totalEmployees = strString.totalEmployees,
            this.employerNameAfterEmployementDetails = strString.employerNameAfterEmployementDetails
            this.isRenderedCallback = true
    }

    renderedCallback(){
        if(this.isRenderedCallback === true && this.employerNameAfterEmployementDetails !== undefined && this.employerNameAfterEmployementDetails !== null){
            this.template.querySelector('c-owc-Employer-Name-After-Employement').handleEmployerNameAfterEmployementChild(this.employerNameAfterEmployementDetails, this.isFormPreviewMode);
        }
    }

    //Ownership of both comp related PickList
    @wire(getOWCPreliminaryMetaData)
    wiredfetchOwnershipMetaData({ data,error}) {
            if(data){
                this.ownershipOptions = data[0].owcCompanyOwnerships;
            }else{
                this.errorMsg = error;
            }
    }

    //hours work recorded PickList
    @wire(fetchHoursWorkedMetaData)
    wiredfetchHoursWorkedMetaData({ data,error}) {
            if(data){
                this.hoursWorkRecordedOptions = data;
                console.log('wiredfetchHoursWorkedMetaData'+JSON.stringify(data));
            }else{
                this.errorMsg = error;
            }
    }

    @wire(owcWorkRecordList)
    fetchOwcWorkRecorded({ data,error}) {
        if(data){
            this.owcWorkRecordList_List = data;
            console.log('new list'+JSON.stringify(this.owcWorkRecordList_List));
        }else{
            this.errorMsg = error;
        }
    }

   
    // Helptext Hanlder
    handleHelpText(event){
        event.preventDefault();
        switch ( event.target.name ){
            case "nameOfPersonInChargeHelpText":
                this.isHelpText = true;
                this.helpText = OWC_successor_nameofperson_helptext;
                break;
            case "totalEmployeesHelpText":
                this.isHelpText = true;
                this.helpText = OWC_successor_info_estimation;
                break;
        }
    }

    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        console.log('helpTextValue:', JSON.stringify(helpTextValue));
        this.isHelpText = helpTextValue.isClosedHelpText
    }
    
}