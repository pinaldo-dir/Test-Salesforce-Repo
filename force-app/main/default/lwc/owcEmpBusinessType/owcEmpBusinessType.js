import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions } from 'c/owcUtils';
import { loadStyle } from 'lightning/platformResourceLoader';  
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  

import OWC_preliminary_office_locator_link from '@salesforce/label/c.OWC_preliminary_office_locator_link';
import fetchOwnershipMetaData from '@salesforce/apex/OWCSuccessorInfoController.fetchOwnershipMetaData'
import OWC_preliminary_office_locator_dlse_wage_for from '@salesforce/label/c.OWC_preliminary_office_locator_dlse_wage_for';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import owcWorkRecordList from '@salesforce/apex/OwcBusinessController.fetchOwcWorkRecorded';
import deleteMultipleFiles from '@salesforce/apex/OWCMultipleFileDeleteController.deleteMultipleFiles';	

import OWC_invalid_email_msg from '@salesforce/label/c.OWC_invalid_email_msg';
import OWC_successorinfo_WorkWithSameCoWorkerComp from '@salesforce/label/c.OWC_successorinfo_WorkWithSameCoWorkerComp';
import OWC_successorinfo_BothCompOwnershipRelated from '@salesforce/label/c.OWC_successorinfo_BothCompOwnershipRelated';
import OWC_successorinfo_WorkForThisComp from '@salesforce/label/c.OWC_successorinfo_WorkForThisComp';
import OWC_invalid_phone_msg from '@salesforce/label/c.OWC_invalid_phone_msg';
import OWC_successorinfo_HireDate from '@salesforce/label/c.OWC_successorinfo_HireDate';
import OWC_date_format_label from '@salesforce/label/c.OWC_date_format_label';
import Owc_Ending from '@salesforce/label/c.Owc_Ending';
import OWC_file_size_error from '@salesforce/label/c.OWC_file_size_error';
import OWC_employee_changed_worked_dates from '@salesforce/label/c.OWC_employee_changed_worked_dates';
import OWC_preliminary_covid19_claim from '@salesforce/label/c.OWC_preliminary_covid19_claim';
import OWC_invalid_zipcode_msg from '@salesforce/label/c.OWC_invalid_zipcode_msg';
import OWC_employee_additional_bank from '@salesforce/label/c.OWC_employee_additional_bank'
import OWC_employee_additional_whopaidyou from '@salesforce/label/c.OWC_employee_additional_whopaidyou'
import OWC_employee_additional_personinchargename from '@salesforce/label/c.OWC_employee_additional_personinchargename'
import OWC_first_name from '@salesforce/label/c.OWC_first_name';
import OWC_last_name from '@salesforce/label/c.OWC_last_name';
import OWC_street_address from '@salesforce/label/c.OWC_street_address';
import OWC_city from '@salesforce/label/c.OWC_city';
import OWC_zipcode from '@salesforce/label/c.OWC_zipcode';
import OWC_email from '@salesforce/label/c.OWC_email';
import OWC_website from '@salesforce/label/c.OWC_website';
import OWC_lawfirm_representative_businessname from '@salesforce/label/c.OWC_lawfirm_representative_businessname';
import OWC_state from '@salesforce/label/c.OWC_state';
import OWC_businessname from '@salesforce/label/c.OWC_businessname';
import OWC_empinfo_ClaimField from '@salesforce/label/c.OWC_empinfo_ClaimField';
import OWC_empinfo_EmpBusinessType from '@salesforce/label/c.OWC_empinfo_EmpBusinessType';
import OWC_empinfo_explain from '@salesforce/label/c.OWC_empinfo_explain';
import OWC_empinfo_BusinessPhone from '@salesforce/label/c.OWC_empinfo_BusinessPhone';
import OWC_empinfo_VehicleLicense from '@salesforce/label/c.OWC_empinfo_VehicleLicense';
import OWC_empinfo_Phone from '@salesforce/label/c.OWC_empinfo_Phone';
import OWC_empinfo_ConstructionTrades from '@salesforce/label/c.OWC_empinfo_ConstructionTrades';
import OWC_empinfo_Uploaddoc from '@salesforce/label/c.OWC_empinfo_Uploaddoc';
import OWC_empinfo_Addimage from '@salesforce/label/c.OWC_empinfo_Addimage';
import OWC_ContractionTrade_Helptext from '@salesforce/label/c.OWC_ContractionTrade_Helptext';
import OWC_UploadDocument_Helptext from '@salesforce/label/c.OWC_UploadDocument_Helptext';
import OWC_AddImage_HelpText from '@salesforce/label/c.OWC_AddImage_HelpText';
import OWC_individual_required_helptext from '@salesforce/label/c.OWC_individual_required_helptext';
import OWC_required_field_error_msg from '@salesforce/label/c.OWC_required_field_error_msg';
import OWC_Additional_Info from '@salesforce/label/c.OWC_Additional_Info';
import OWC_NameOfPersonInChage from '@salesforce/label/c.OWC_NameOfPersonInChage';
import OWC_EnterName_HelpText from '@salesforce/label/c.OWC_EnterName_HelpText';
import OWC_JobTitle_PersonInCharge from '@salesforce/label/c.OWC_JobTitle_PersonInCharge';
import OWC_WhoPaidYou from '@salesforce/label/c.OWC_WhoPaidYou';
import OWC_DifferentPerson from '@salesforce/label/c.OWC_DifferentPerson';
import OWC_WorkRecord from '@salesforce/label/c.OWC_WorkRecord';
import OWC_SignTimeCard from '@salesforce/label/c.OWC_SignTimeCard';
import OWC_SomeoneElseName from '@salesforce/label/c.OWC_SomeoneElseName';
import OWC_TotalEmployees from '@salesforce/label/c.OWC_TotalEmployees';
import OWC_BestGuess_HelpText from '@salesforce/label/c.OWC_BestGuess_HelpText';
import OWC_EmpBusiness from '@salesforce/label/c.OWC_EmpBusiness';
import OWC_CompEmployed from '@salesforce/label/c.OWC_CompEmployed';
import OWC_ChangeOrSold from '@salesforce/label/c.OWC_ChangeOrSold';
import OWC_Bankruptcy from '@salesforce/label/c.OWC_Bankruptcy';
import OWC_ShowTost from '@salesforce/label/c.OWC_ShowTost';
import OWC_CellPhone from '@salesforce/label/c.OWC_CellPhone';
import OWC_COVID19_helptext from '@salesforce/label/c.OWC_COVID19_helptext';
import OWC_employee_reuired_field_error_msg from '@salesforce/label/c.OWC_employee_reuired_field_error_msg';
import OWC_fileupload_success_toast_msg from '@salesforce/label/c.OWC_fileupload_success_toast_msg';
import OWC_multiple_file_delete_toast_msg from '@salesforce/label/c.OWC_multiple_file_delete_toast_msg';
import OWC_preliminary_union_contract_covering from '@salesforce/label/c.OWC_preliminary_union_contract_covering';
import OWC_preliminary_upload_document from '@salesforce/label/c.OWC_preliminary_upload_document';
import OWC_url_address from '@salesforce/label/c.OWC_url_address';
import OWC_preliminary_coversheet_mailing_document from '@salesforce/label/c.OWC_preliminary_coversheet_mailing_document';
import OWC_learnmore_button from '@salesforce/label/c.OWC_learnmore_button';
import OWC_filing_wage_claim from '@salesforce/label/c.OWC_filing_wage_claim';	
import OWC_multiplefileupload_helptext from '@salesforce/label/c.OWC_multiplefileupload_helptext';
import OWC_preliminary_coversheet_helptext from '@salesforce/label/c.OWC_preliminary_coversheet_helptext';
import OWC_LastName_helptext from '@salesforce/label/c.OWC_LastName_helptext';
import OWC_empinfo_empName from '@salesforce/label/c.OWC_empinfo_empName';
import OWC_employer_changedname_label from '@salesforce/label/c.OWC_employer_changedname_label';
import OWC_Yes from '@salesforce/label/c.OWC_Yes';
import OWC_No from '@salesforce/label/c.OWC_No';
import OWC_employer_delete_button from '@salesforce/label/c.OWC_employer_delete_button';
import OWC_preliminary_specify_one from '@salesforce/label/c.OWC_preliminary_specify_one';
import OWC_select_picklist_label from '@salesforce/label/c.OWC_select_picklist_label';
import OWC_preliminary_specify_other_reason from '@salesforce/label/c.OWC_preliminary_specify_other_reason';
import OWC_urladdress_error_msg from '@salesforce/label/c.OWC_urladdress_error_msg';
import OWC_preliminary_local_office_mail_label from '@salesforce/label/c.OWC_preliminary_local_office_mail_label';
import OWC_union_contract_options_label from '@salesforce/label/c.OWC_union_contract_options_label';
import OWC_invalid_url_msg from '@salesforce/label/c.OWC_invalid_url_msg';
import OWC_employee_additional_bank_incharge_name from '@salesforce/label/c.OWC_employee_additional_bank_incharge_name';
import OWC_employee_additional_bank_claimrelated_action from '@salesforce/label/c.OWC_employee_additional_bank_claimrelated_action';
import OWC_employee_additional_employeer_changed_name from '@salesforce/label/c.OWC_employee_additional_employeer_changed_name';
import OWC_employer_startdate_error_msg from '@salesforce/label/c.OWC_employer_startdate_error_msg';
import OWC_employer_enddate_error_msg from '@salesforce/label/c.OWC_employer_enddate_error_msg';
import OWC_pastdate_error_msg from '@salesforce/label/c.OWC_pastdate_error_msg';
import OWC_begdate_error_msg from '@salesforce/label/c.OWC_begdate_error_msg';
import OWC_enddate_error_msg from '@salesforce/label/c.OWC_enddate_error_msg';
import OWC_employer_verification_doc_label from '@salesforce/label/c.OWC_employer_verification_doc_label';
import OWC_address_proceed from '@salesforce/label/c.OWC_address_proceed';
import OWC_suggested_response_label from '@salesforce/label/c.OWC_suggested_response_label';
import OWC_error_response_label from '@salesforce/label/c.OWC_error_response_label';
import OWC_action_label from '@salesforce/label/c.OWC_action_label';
import OWC_AnotherEmployerNote from '@salesforce/label/c.OWC_AnotherEmployerNote';
import OWC_copy_mail_helptext from '@salesforce/label/c.OWC_copy_mail_helptext';
import OWC_time_card_name from '@salesforce/label/c.OWC_time_card_name';
import OWC_employer_name_changed_helptext from '@salesforce/label/c.OWC_employer_name_changed_helptext';
import OWC_date_filed from '@salesforce/label/c.OWC_date_filed';
import OWC_retialiation_complain from '@salesforce/label/c.OWC_retialiation_complain';
import owc_Case_Number from '@salesforce/label/c.owc_Case_Number';
import OWC_retaliated_against_msg from '@salesforce/label/c.OWC_retaliated_against_msg';
import { Utils} from './owcEmpBusinessTypeFnc';

export default class OwcEmpBusinessType extends Utils(LightningElement)  {
    @api deletebutton
    @api toastFileUploadMsg = OWC_fileupload_success_toast_msg
    @api toastFileDeleteMsg = OWC_multiple_file_delete_toast_msg
    @api unionUploadDocSize
    @api uploadAdditionalFileSize
    @api uploadPayStubImageFileSize
    @api employeesectionheader
    @api isclaimantgarment
    @api claimantRelatedRoleActions
    @api countryCodeindividualBusinessPhone
    @api countryCodeindividualCellPhone
    @api countryCodeOtherIndividualPhone
    @api countryCodeValue
    @api isChecked = false
    @api isMultipleRequiredCheck = false
    isRenderedCallback = false
    @api retaliationComplain
    
    @api uploadPayStubImages
    @api getPicklistValues = []

    
    @api helpText
    @api isHelpText = false

    
    @api IsOther = false;
    @api IsIndividual  = false;
    @api IsOtherIndividual  = false;
    @api IsAdditionalInfo = false;
    @api isEmployerSellingAssets = false;
    @api isUnionDocumentFileUploaded = false;
    @api isFileUploadedAdditional = false;
    
    @api Employer_Business_Type_List 
    @api employer_Business_Type = ''
    @api owcWorkRecordList_List
    @api owcWorkRecordList
    @api isEmpBusinessType
    
    @api otherPleaseExplain
    
    @api individualFirstName
    @api individualLastName
    @api individualStreetAddress
    @api individualCity
    @api individualState
    @api individualZipCode
    @api individualBusinessPhone
    @api individualCellPhone
    @api individualEmail
    @api individualVehicleLicense
    @api individualWebsite
    
    @api OtherIndividualBusinessName
    @api OtherIndividualStreetAddress
    @api OtherIndividualCity
    @api OtherIndividualState
    @api OtherIndividualZipCode
    @api OtherIndividualPhone
    @api OtherIndividualEmail
    @api OtherIndividualVehicleLicense
    @api OtherIndividualWebsite
    @api OtherIndividualConstructionTrades
    @api fileUploader
    @api representativeEmployerType
    
    
    @api errorMsg
    @api uploadUnionContractDocument = []
    @api uploadUnionContractDocumentadditional = []
    @api ValidationMsg;
    @api additionalName;
    @api additionalJobTitle;
    @api additionalDifferentPerson;
    @api additionalWorkRecord;
    @api additionalSignTimeCard;
    @api additionalSomeoneElse;
    @api additionalTotalEmployees;
    @api additionalEmpBusiness;
    @api additionalCompEmployed;
    @api additionalChangeOrSold;
    @api additionalBankruptcy;
    @api uploadAdditionalDocuments;
    @api additionalBankName
    @api additionalWHOPaidYou
    @api additionalPersonInchargeName
    @api employerNameChangedDetails
    @track isClaimantAdvocate = true

    
    @api specifyFilingWageClaim 
    @api covid19Claim 
    @api specifyOtherReason 
    @api isEmployeeFilingWageClaimOther  = false
    @track empName;
    @api sectionid
    @track isDontKnow = false;
    @api unionContractCovering
    @api urlAddress
    @api unionContractCovered
    @api coversheetDocument
    @api filingWageClaim
    
    
    @api uploadedEmployerDocuments
    @api employerUploadDocSize
    @api uploadedEmployerAdditionalDocuments = []
    @api employerAdditionalUploadDocSize
    @api preliminaryCovidClaimPicklistData
    @api ispreliminaryshown
    @api mailOfficeLocator
    @api unionContractCoverOptions = unionContractCoverOptions
    @api employerChangedName
    @api isEmployerChangedName
    @api startingDate
    @api endingDate
    @api statePicklistValues;
    @api employerChangedNameAfterEmployement
    @api employerNameAfterEmployementDetails
    @api workForThisComp
    @api workWithSameWorokers
    @api ownershipOfCompRelated
    @api ownershipOptions;
    @api successorSectionDetailsFromParent
    @api employerVerificationUploadDoc = []
    @api employerVerificationUploadSize
    @api isUnionContractCovered = false
    @api isEmployerChangedNameAfterEmployement = false
    @api isUnionContractDocumentUpload = false;
    @api isOfficeLocatorMail = false
    @api isUrlAddress = false;
    @api isMailToOfficeLocator = false;
    @api isNotChangedCurrentCmp = false
    @api isEmployerDocUpload = false
    @api isEmployerAdditionalDoc = false
    @api isCoverSheetDocRequired = false
    @api isNotChangedCurrentSteps = false
    @api isEmployerVerificationDoc = false
    @api isIndividualStatePicklist = false
    @api isOtherIndividualPicklist = false
    @api isRenderIndividualState = false
    @api isRenderOtherIndividualState = false
    @api selectedAddressIndex
    @api addressJson
    
    @api succesWithCurrentAddress = false
    @api isRenderPicklist = false;
    @api isErrorFocus = false;
    @api isSuccessFocus = false;
    @api isLoading = false;
    @api isPrevious = false;
    @api complainFiledDate
    @api complainCaseNumber
    @api isRetaliationComplainFalse = false
    
    @api IndividualFirstNamerequired = false;
    @api IndividualStreetAddressrequired = false;
    @api IndividualCityrequired = false;
    @api IndividualStaterequired = false;
    @api IndividualZipCoderequired = false;
    @api IndividualBusinessPhonerequired = false;
    @api OtherStreetAddressrequired = false
    @api OtherCityrequired = false
    @api OtherStaterequired = false
    @api OtherZipCoderequired = false
    @api OtherBusinessPhonerequired = false
    NotProceed = false;
    isPleaseExplain = false
    isIndividualFirstName = false
    isIndividualLastName = false
    iscovid19Claim = false

    isindividualStreetAddress = false
    isindividualCity = false
    isindividualState = false
    isIndividualZipCode = false
    isIndividualBusinessPhone = false
    
    isOtherIndividualStreetAddress = false
    isOtherIndividualCity = false
    isOtherIndividualState = false
    isOtherIndividualZipCode = false
    isOtherIndividualPhone = false

    isadditionalTotalEmployees = false
    isadditionalEmpBusiness = false
    isIndividualLicensePlateNo = false
    isBusinessName = false
    isempBusinessType = false
    isUnionContractCoveredDoc = false
    isurlAddressValid = false
    isIndividualRequiredSet = false
    isOtherIndividualBusinessName = false
    isotherPleaseExplain = false
    isDontKnowEmpName = false
    isindividualCellPhone = false
    isIndividualWebsite = false
    isOtherIndividualWebsite = false
    isOtherIndividualPhone = false
    isOtherIndividualEmail = false
    isDontKnowspecifyOtherReason = false
    @api isRetaliationComplain = false
    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`
    options = radioOptions;
    NotProceed = false
    regExpPhone = /^((\\+[1-9]{1,4}[ \\-]*)|(\\([0-9]{2,3}\\)[ \\-]*)|([0-9]{2,4})[ \\-]*)*?[0-9]{3,4}?[ \\-]*[0-9]{3,4}?$/;
    regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    zipCodeRegrex = /^\d{5}(?:[-\s]\d{4})?$/;
    urlAddressChekerRegrex = /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$/;
    isIndivudualWebsite = false
    isNotProvidedUnionCovering = false
    isNotProvideAnyUnionContractInfo = false
    isNotUrlAddressValid = false
    isEmployerDateAcceptable = false
    @api isSignCard = false;
    @api isFormPreviewMode = false
    @api empBusinessTypeDetails
    @api isNotClaimantGarment = false
    @api isAdditionalHeading = false
    @api isRenderedPicklist = false
    @api employerBusinessTypeList
   @api isFocusable = false;
    connectedCallback(){
        this.isFocusable = true;
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
        });
    if(this.isclaimantgarment === true){
        this.isRenderPicklist = true;
        const employerBusinessTypeList = JSON.parse(JSON.stringify(this.Employer_Business_Type_List))
        employerBusinessTypeList.splice(1,1)
        this.employerBusinessTypeList = employerBusinessTypeList
        this.isClaimantAdvocate = false
        }
    }
    
    @wire(fetchOwnershipMetaData)
    wiredfetchOwnershipMetaData({ data,error}) {
            if(data){
                this.ownershipOptions = data;
            }else{
                this.errorMsg = error;
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

    customLabelValues = {
        OWC_file_size_error,
        OWC_COVID19_helptext,
        OWC_retaliated_against_msg,
        OWC_retaliated_against_msg,
        owc_Case_Number,
        OWC_retialiation_complain,
        OWC_date_filed,
        OWC_employer_name_changed_helptext,
        OWC_time_card_name,
        OWC_copy_mail_helptext,
        OWC_AnotherEmployerNote,
        OWC_action_label,
        OWC_address_proceed,
        OWC_suggested_response_label,
        OWC_error_response_label,
        OWC_employer_verification_doc_label,
        OWC_begdate_error_msg,
        OWC_enddate_error_msg,
        OWC_pastdate_error_msg,
        OWC_employer_startdate_error_msg,
        OWC_employer_enddate_error_msg,
        OWC_successorinfo_BothCompOwnershipRelated,
        OWC_successorinfo_WorkWithSameCoWorkerComp,
        OWC_successorinfo_WorkForThisComp,
        OWC_employer_changedname_label,
        OWC_employee_changed_worked_dates,
        Owc_Ending,
        OWC_date_format_label,
        OWC_successorinfo_HireDate,
        OWC_employee_additional_employeer_changed_name,
        OWC_employee_additional_bank_claimrelated_action,
        OWC_employee_additional_bank_incharge_name,
        OWC_invalid_url_msg,
        OWC_union_contract_options_label,
        OWC_preliminary_local_office_mail_label,
        OWC_urladdress_error_msg,
        OWC_preliminary_specify_other_reason,
        OWC_preliminary_specify_one,
        OWC_Yes,
        OWC_No,
        OWC_preliminary_covid19_claim,
        OWC_preliminary_office_locator_link,
        OWC_preliminary_office_locator_dlse_wage_for,
        OWC_employer_delete_button,
        OWC_filing_wage_claim,
        OWC_learnmore_button,
        OWC_preliminary_coversheet_mailing_document,
        OWC_url_address,
        OWC_preliminary_upload_document,
        OWC_employee_additional_whopaidyou,
        OWC_employee_additional_personinchargename,
        OWC_employee_additional_bank,
        OWC_select_picklist_label,
        OWC_ShowTost,
        OWC_Additional_Info,
        OWC_NameOfPersonInChage,
        OWC_EnterName_HelpText,
        OWC_JobTitle_PersonInCharge,
        OWC_SomeoneElseName,
        OWC_WhoPaidYou,
        OWC_DifferentPerson,
        OWC_WorkRecord,
        OWC_SignTimeCard,
        OWC_CellPhone,
        OWC_TotalEmployees,
        OWC_BestGuess_HelpText,
        OWC_EmpBusiness,
        OWC_CompEmployed,
        OWC_ChangeOrSold,
        OWC_Bankruptcy,
        OWC_first_name,
        OWC_last_name,
        OWC_street_address,
        OWC_city,
        OWC_state,
        OWC_zipcode,
        OWC_email,
        OWC_website,
        OWC_lawfirm_representative_businessname,
        OWC_businessname,
        OWC_empinfo_ClaimField,
        OWC_empinfo_EmpBusinessType,
        OWC_empinfo_explain,
        OWC_CompEmployed,
        OWC_empinfo_BusinessPhone,
        OWC_empinfo_VehicleLicense,
        OWC_empinfo_Phone,
        OWC_empinfo_ConstructionTrades,
        OWC_empinfo_Uploaddoc,
        OWC_empinfo_Addimage,
        OWC_ContractionTrade_Helptext,
        OWC_UploadDocument_Helptext,
        OWC_AddImage_HelpText,
        OWC_required_field_error_msg,
        OWC_preliminary_union_contract_covering,
        OWC_empinfo_empName,
    }

    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data, error }){
        if(data){
            this.covid19ClaimPicklistData = data[0].covid19WageClaim;
            this.countryCodeValue = data[0].owcCountryCodeList;
            this.statePicklistValues = data[0].statePicklist;
            this.preliminaryCovidClaimPicklistData = data[0].preliminaryCovidClaimValues;
            this.Employer_Business_Type_List = data[0].owcBusineesTypeOptions;
            this.owcWorkRecordList_List = data[0].owcWorkedRecordedList;
            this.individualState = ''
            this.OtherIndividualState = ''
            this.countryCodeOtherIndividualPhone = '+1'
            this.countryCodeindividualBusinessPhone = '+1'
            this.countryCodeindividualCellPhone = '+1'
        }
        else if(error){
            this.error = error;
        }
    }

    @api get showIndividualSole(){
        return this.IsIndividual === true && this.isClaimantAdvocate === true
    }
    resetOtherAttributes(){
        this.OtherIndividualBusinessName = null;
        this.OtherIndividualStreetAddress = null;
        this.OtherIndividualCity = null;
        this.OtherIndividualZipCode = null;
        this.OtherIndividualState = '';
        this.countryCodeOtherIndividualPhone = '+1'
        this.countryCodeindividualCellPhone = '+1'
        this.OtherIndividualPhone = null;
        this.OtherIndividualEmail = null;
        this.OtherIndividualVehicleLicense = null;
        this.OtherIndividualWebsite = null;
        this.OtherStreetAddressrequired = false;
        this.OtherCityrequired = false;
        this.OtherStaterequired = false;
        this.OtherZipCoderequired = false;
        this.OtherBusinessPhonerequired = false;
        this.isIndividualStatePicklist = true
        this.isOtherIndividualPicklist = false
        this.individualFirstName = null;
        this.individualLastName = null;
        this.individualStreetAddress = null;
        this.individualCity = null;
        this.individualZipCode = null;
        this.individualState = '';
        this.countryCodeindividualBusinessPhone = '+1'
        this.countryCodeindividualCellPhone = '+1'
        this.individualBusinessPhone = null;
        this.individualEmail = null;
        this.individualVehicleLicense = null;
        this.individualWebsite = null;
        
    }
    
    resetIndividualSoleAttributes(){
        this.individualCellPhone = null;
        this.individualFirstName = null;
        this.individualLastName = null;
        this.individualStreetAddress = null;
        this.individualCity = null;
        this.individualZipCode = null;
        this.individualState = '';
        this.countryCodeindividualBusinessPhone = '+1'
        this.countryCodeindividualCellPhone = '+1'
        this.individualBusinessPhone = null;
        this.individualEmail = null;
        this.individualVehicleLicense = null;
        this.individualWebsite = null;
        this.IndividualFirstNamerequired = false;
        this.IndividualStreetAddressrequired = false;
        this.IndividualCityrequired = false;
        this.IndividualStaterequired = false;
        this.IndividualZipCoderequired = false;
        this.IndividualBusinessPhonerequired = false;
    }
    
    @api isClaimFiledDateValid = false;
    handleComplainFiledDateValidation(){
        let complainFiledDate = this.template.querySelector('[data-id="complainFiledDate"]');
        var inputDate
        let today = new Date(); 
        if(complainFiledDate.value != null){
            inputDate = new Date(complainFiledDate.value.toString());
        }
        else{
            inputDate = complainFiledDate.value;
        }
        if(complainFiledDate.value == undefined || complainFiledDate.value == null || complainFiledDate.value == ''){
            complainFiledDate.setCustomValidity('');
            this.isClaimFiledDateValid = false;
        }
        else if(inputDate.setHours(0,0,0,0) > today.setHours(0,0,0,0)){
            complainFiledDate.setCustomValidity(customLabelValues.OWC_pastdate_error_msg);
            this.isClaimFiledDateValid = true;
        }
        else{
            complainFiledDate.setCustomValidity("");
            this.isClaimFiledDateValid = false;
        }
        complainFiledDate.reportValidity();
    }

    isIndiVehi = false
    isOthiVehi = false

    
    
    handleUnionContractCoveringFocus(){
        let unionContractCovering = this.template.querySelector('[data-id="unionContractId"]')

        if(unionContractCovering === null || unionContractCovering === undefined){
            this.isNotProvidedUnionCovering = false;
        }
        else{
            if(unionContractCovering.value === null || unionContractCovering.value === undefined || unionContractCovering.value.trim() === ''){
                unionContractCovering.setCustomValidity(OWC_required_field_error_msg);
                this.isNotProvidedUnionCovering = true;
            }
            else{
                unionContractCovering.setCustomValidity('')
                this.isNotProvidedUnionCovering = false;
            }
            unionContractCovering.reportValidity();
        }
        
    }

    handleUnionContractCovered(){
        const unionContractCovered = this.template.querySelector('[data-id="unionContractCovered"]');
        if(unionContractCovered.value === undefined || unionContractCovered.value === null || unionContractCovered.value === ''){
            unionContractCovered.setCustomValidity(OWC_required_field_error_msg);
            unionContractCovered.reportValidity();
            this.isNotProvideAnyUnionContractInfo = true;
        }
        else{
            unionContractCovered.setCustomValidity('');
            unionContractCovered.reportValidity();
            this.isNotProvideAnyUnionContractInfo = false;
        }
    }

    handleIndividualWebsiteFocus(){
        const individualWebsite = this.template.querySelector('[data-id="individualWebsite"');
        if(individualWebsite.value === undefined || individualWebsite.value === null || individualWebsite.value.trim() === ''){
            individualWebsite.setCustomValidity('')
            individualWebsite.reportValidity()
            this.isIndivudualWebsite = false
        }
        else if(individualWebsite.
            value.match(this.urlAddressChekerRegrex)){
            individualWebsite.setCustomValidity('')
            individualWebsite.reportValidity()
            this.isIndivudualWebsite = false
        }
        else{
            individualWebsite.setCustomValidity(this.customLabelValues.OWC_urladdress_error_msg)
            individualWebsite.reportValidity()
            this.isIndivudualWebsite = true;
        }
    }

    handleOtherIndividualWebsiteFocus(){
        const OtherIndividualWebsite = this.template.querySelector('[data-id="OtherIndividualWebsite"');
        if(OtherIndividualWebsite.value === undefined || OtherIndividualWebsite.value === null || OtherIndividualWebsite.value.trim() === ''){
            OtherIndividualWebsite.setCustomValidity('')
        }
        else if(OtherIndividualWebsite.value.match(this.urlregex)){
            OtherIndividualWebsite.setCustomValidity('')
        }
        else{
            OtherIndividualWebsite.setCustomValidity(OWC_invalid_url_msg)
        }
        OtherIndividualWebsite.reportValidity()

    }
    
    handleUrlAddressValidity(){
        const urlAddress = this.template.querySelector('[data-id="urlAddress"');
        if(urlAddress.value === undefined || urlAddress.value === null || urlAddress.value === ''){
            urlAddress.setCustomValidity(OWC_required_field_error_msg);
            this.isNotUrlAddressValid = true;
        }
        else if(urlAddress.value.match(this.urlAddressChekerRegrex)){
            urlAddress.setCustomValidity('');
            this.isNotUrlAddressValid = false;
        }
        else{
            urlAddress.setCustomValidity(OWC_invalid_url_msg);
            this.isNotUrlAddressValid = true;
        }
        urlAddress.reportValidity();
    }

    handleEmployer_Business_TypeFocus(){
        let employer_Business_Type = this.template.querySelector('[data-id="employer_Business_Type"]');          
        if(employer_Business_Type.value == undefined || employer_Business_Type.value == null || employer_Business_Type.value.trim() == '' || employer_Business_Type.value == '--Select--'){
            this.isMultipleRequiredCheck = true
            employer_Business_Type.setCustomValidity(OWC_required_field_error_msg);
        }else{
            this.isMultipleRequiredCheck = false
            employer_Business_Type.setCustomValidity("");
        }
        employer_Business_Type.reportValidity();
    }
    
    handleIndividualLastNameFocus(){
        let individualLastName = this.template.querySelector('[data-id="individualLastName"]');
        if(individualLastName.value == null || individualLastName.value == undefined || individualLastName.value.trim() == ''){
            individualLastName.setCustomValidity(OWC_required_field_error_msg);
            this.isIndividualLastName = true;
        }
        else{
            individualLastName.setCustomValidity('')
            this.isIndividualLastName = false;
        }
        individualLastName.reportValidity();
    }

    handleadditionalTotalEmployeesFocus(){
        let additionalTotalEmployees = this.template.querySelector('[data-id="additionalTotalEmployees"]');
        if(additionalTotalEmployees.value == null || additionalTotalEmployees.value == undefined || additionalTotalEmployees.value.trim() == ''){
            additionalTotalEmployees.setCustomValidity(OWC_required_field_error_msg);
            this.isadditionalTotalEmployees = true;
        }
        else{
            additionalTotalEmployees.setCustomValidity('')
            this.isadditionalTotalEmployees = false;
        }
        additionalTotalEmployees.reportValidity();
    }

    handleadditionalEmpBusinessFocus(){
        let additionalEmpBusiness = this.template.querySelector('[data-id="additionalEmpBusiness"]');
        if(additionalEmpBusiness.value == undefined || additionalEmpBusiness.value == null || additionalEmpBusiness.value.trim() == '' || additionalEmpBusiness.value == '--Select--'){
            additionalEmpBusiness.setCustomValidity(OWC_required_field_error_msg);
            this.isadditionalEmpBusiness = true;
        }
        else{
            additionalEmpBusiness.setCustomValidity('')
            this.isadditionalEmpBusiness = false;
        }
        additionalEmpBusiness.reportValidity();
        console.log('empbusiness ::: ', this.isadditionalEmpBusiness);
    }

    handleOtherReasonFocus(){
        let specifyOtherReason = this.template.querySelector('[data-id="specifyOtherReason"]');
                if(specifyOtherReason.value.trim() == undefined || specifyOtherReason.value.trim() == null || specifyOtherReason.value.trim() == ''){
                    specifyOtherReason.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
                }
                else{
                    specifyOtherReason.setCustomValidity("");
                }
                specifyOtherReason.reportValidity();
    }
    
    handleOtherWebsiteFocus(){
        const OtherIndividualWebsite = this.template.querySelector('[data-id="OtherIndividualWebsite"');
        if(OtherIndividualWebsite.value === undefined || OtherIndividualWebsite.value === null || OtherIndividualWebsite.value.trim() === ''){
            OtherIndividualWebsite.setCustomValidity('')
            OtherIndividualWebsite.reportValidity()
            this.isOtherIndividualWebsite = false
            return false;
        }
        else if(OtherIndividualWebsite.value.match(this.urlAddressChekerRegrex)){
            OtherIndividualWebsite.setCustomValidity('')
            OtherIndividualWebsite.reportValidity()
            this.isOtherIndividualWebsite = false
            return false;
        }
        else{
            OtherIndividualWebsite.setCustomValidity(customLabelValues.OWC_urladdress_error_msg)
            OtherIndividualWebsite.reportValidity()
            this.isOtherIndividualWebsite = true
            return true;
        }
    }

    handleEmpNameDontKnowFocus(){
        let empName = this.template.querySelector('[data-id="empName"]');
        if(empName.value == null || empName.value == undefined || empName.value.trim() == ''){
            empName.setCustomValidity(OWC_required_field_error_msg);
        }
        else{
            empName.setCustomValidity('')
        }
        empName.reportValidity();
    }

    handleIndividualCellPhoneFocus(){
        const individualCellPhone = this.template.querySelector('[data-id="individualCellPhone"');
        if(individualCellPhone.value === undefined || individualCellPhone.value === null || individualCellPhone.value.trim() === ''){
            individualCellPhone.setCustomValidity('')
        }
        else if(individualCellPhone.value.match(this.regExpPhone)){
            individualCellPhone.setCustomValidity('')
        }
        else{
            individualCellPhone.setCustomValidity(OWC_invalid_phone_msg)
        }
        individualCellPhone.reportValidity()
    }

    isindividualEmail = false
    handleIndividualEmailFocus(){
        const individualEmail = this.template.querySelector('[data-id="individualEmail"');
        if(individualEmail.value === undefined || individualEmail.value === null || individualEmail.value.trim() === ''){
            individualEmail.setCustomValidity('')
            this.isindividualEmail = false;
        }
        else if(individualEmail.value.match(this.regExpEmailformat)){
            individualEmail.setCustomValidity('')
            this.isindividualEmail = false;
        }
        else{
            individualEmail.setCustomValidity(OWC_invalid_email_msg)
            this.isindividualEmail = true;
        }
        individualEmail.reportValidity()
    }

    handleOtherIndividualEmail(){
        const OtherIndividualEmail = this.template.querySelector('[data-id="OtherIndividualEmail"');
        if(OtherIndividualEmail.value === undefined || OtherIndividualEmail.value === null || OtherIndividualEmail.value.trim() === ''){
            OtherIndividualEmail.setCustomValidity('')
            this.isOtherIndividualEmail = false
        }
        else if(OtherIndividualEmail.value.match(this.regExpEmailformat)){
            OtherIndividualEmail.setCustomValidity('')
            this.isOtherIndividualEmail = false
        }
        else{
            OtherIndividualEmail.setCustomValidity(OWC_invalid_email_msg)
            this.isOtherIndividualEmail = true
        }
        OtherIndividualEmail.reportValidity()
    }
    
    handlecovid19ClaimFocus(){
        let covid19Claim = this.template.querySelector('[data-id="covid19ClaimId"]');
        if(covid19Claim === null || covid19Claim === undefined){
            this.iscovid19Claim = false;
        }
        else{
            if(covid19Claim.value === null || covid19Claim.value === undefined || covid19Claim.value.trim() === ''){
                covid19Claim.setCustomValidity(OWC_required_field_error_msg);
                this.iscovid19Claim = true;
            }
            else{
                covid19Claim.setCustomValidity('')
                this.iscovid19Claim = false;
            }
            covid19Claim.reportValidity();
        }
    }

    handleOtherBusinessReasonFocus(){
        let otherPleaseExplain = this.template.querySelector('[data-id="otherPleaseExplain"]');
        if(otherPleaseExplain.value == null || otherPleaseExplain.value == undefined || otherPleaseExplain.value.trim() == ''){
            otherPleaseExplain.setCustomValidity(OWC_required_field_error_msg);
        }
        else{
            otherPleaseExplain.setCustomValidity('')
        }
        otherPleaseExplain.reportValidity();
    }

    handleOtherIndividualBusinessNameFocus(){
        let OtherIndividualBusinessName = this.template.querySelector('[data-id="OtherIndividualBusinessName"]');          
        if(OtherIndividualBusinessName.value == undefined || OtherIndividualBusinessName.value == null || OtherIndividualBusinessName.value.trim() == ''){
            this.isMultipleRequiredCheck = true
            OtherIndividualBusinessName.setCustomValidity(OWC_required_field_error_msg);
        }
        else{
            this.isMultipleRequiredCheck = false
            OtherIndividualBusinessName.setCustomValidity("");
        }
        OtherIndividualBusinessName.reportValidity();
    }

    handleIndividualFirstNameFocus(){ 
        let individualFirstName = this.template.querySelector('[data-id="individualFirstName"]');  
        
            if(individualFirstName.value == undefined || individualFirstName.value == null || individualFirstName.value.trim() == ''){
                if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){
                this.isIndividualFirstName = true
                individualFirstName.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isIndividualFirstName = false
                individualFirstName.setCustomValidity("");
                }
            }
            else{
                this.isIndividualFirstName = false
                individualFirstName.setCustomValidity("");
            }
            individualFirstName.reportValidity();
        
    }

    handleindividualStreetAddressFocus(){ 
        let individualStreetAddress = this.template.querySelector('[data-id="individualStreetAddress"]');  
        
            if(individualStreetAddress.value == undefined || individualStreetAddress.value == null || individualStreetAddress.value.trim() == ''){
                if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
                this.isindividualStreetAddress = true
                individualStreetAddress.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isindividualStreetAddress = false
                    individualStreetAddress.setCustomValidity("");
                }
            }
            else{
                this.isindividualStreetAddress = false
                individualStreetAddress.setCustomValidity("");
            }
            individualStreetAddress.reportValidity();
        
    }
    handleOtherIndividualStreetAddressFocus(){ 
        let OtherIndividualStreetAddress = this.template.querySelector('[data-id="OtherIndividualStreetAddress"]');  
        
            if(OtherIndividualStreetAddress.value == undefined || OtherIndividualStreetAddress.value == null || OtherIndividualStreetAddress.value.trim() == ''){
                if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){        
                this.isOtherIndividualStreetAddress = true
                OtherIndividualStreetAddress.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isOtherIndividualStreetAddress = false
                OtherIndividualStreetAddress.setCustomValidity("");
                }
            }
            else{
                this.isOtherIndividualStreetAddress = false
                OtherIndividualStreetAddress.setCustomValidity("");
            }
            OtherIndividualStreetAddress.reportValidity();
        
    }

    handleindividualCityFocus(){ 
        let individualCity = this.template.querySelector('[data-id="individualCity"]');  
        if(individualCity.value == undefined || individualCity.value == null || individualCity.value.trim() == ''){
            if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
                this.isindividualCity = true
                individualCity.setCustomValidity(OWC_required_field_error_msg);
            }
            else{
                this.isindividualCity = false
                individualCity.setCustomValidity("");
            }
        }
        else{
            this.isindividualCity = false
            individualCity.setCustomValidity("");
        }
        individualCity.reportValidity();
        
    }
    handleOtherIndividualCityfocus(){ 
        let OtherIndividualCity = this.template.querySelector('[data-id="OtherIndividualCity"]');  
        
            if(OtherIndividualCity.value == undefined || OtherIndividualCity.value == null || OtherIndividualCity.value.trim() == ''){
                if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){        
                OtherIndividualCity.setCustomValidity(OWC_required_field_error_msg)
                this.isOtherIndividualCity = TextTrackCueList
                }
                else{
                    OtherIndividualCity.setCustomValidity("")
                this.isOtherIndividualCity = false
                }
            }
            else{
                OtherIndividualCity.setCustomValidity("");
                this.isOtherIndividualCity = false
            }
            OtherIndividualCity.reportValidity();
        
    }
    handleindividualStateFocus(){ 
        let individualState = this.template.querySelector('[data-id="individualState"]');  
        
            if(individualState.value == undefined || individualState.value == null || individualState.value.trim() == ''){
                if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
                this.isindividualState = true
                individualState.setCustomValidity(OWC_required_field_error_msg);
                }
                else{
                    this.isindividualState = false
                individualState.setCustomValidity("");
                }
            }
            else{
                this.isindividualState = false
                individualState.setCustomValidity("");
            }
            individualState.reportValidity();
        
    }
    handleOtherIndividualStatefocus(){ 
        let OtherIndividualState = this.template.querySelector('[data-id="OtherIndividualState"]');  
       
            if(OtherIndividualState.value == undefined || OtherIndividualState.value == null || OtherIndividualState.value.trim() == ''){
                if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){
                this.isOtherIndividualState = true
                OtherIndividualState.setCustomValidity(OWC_required_field_error_msg);}
                else{
                    this.isOtherIndividualState = false
                OtherIndividualState.setCustomValidity("");
                }
            }
            else{
                this.isOtherIndividualState = false
                OtherIndividualState.setCustomValidity("");
            }
            OtherIndividualState.reportValidity();
        
    }
    handleIndividualZipCodeFocus(){
        const individualZipCode = this.template.querySelector('[data-id="individualZipCode"');
        if(individualZipCode.value === undefined || individualZipCode.value === null || individualZipCode.value.trim() === ''){
            if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
            individualZipCode.setCustomValidity(OWC_required_field_error_msg)
            this.isIndividualZipCode = true
            }
            else{
                individualZipCode.setCustomValidity("")
            this.isIndividualZipCode = false
            
            }
        }
        else if(individualZipCode.value.match(this.zipCodeRegrex)){
            individualZipCode.setCustomValidity('')
            this.isIndividualZipCode = false
        }
        else{
            individualZipCode.setCustomValidity(OWC_invalid_zipcode_msg)
            this.isIndividualZipCode = true
        }
        individualZipCode.reportValidity()
    }

    handleOtherIndividualZipCodeFocus(){
        const OtherIndividualZipCode = this.template.querySelector('[data-id="OtherIndividualZipCode"');
        if(OtherIndividualZipCode.value === undefined || OtherIndividualZipCode.value === null || OtherIndividualZipCode.value.trim() === ''){
            if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){        
                OtherIndividualZipCode.setCustomValidity(OWC_required_field_error_msg)
                this.isOtherIndividualZipCode = true
            }
            else{
                OtherIndividualZipCode.setCustomValidity("")
                this.isOtherIndividualZipCode = false
            }
        }
        else if(OtherIndividualZipCode.value.match(this.zipCodeRegrex)){
            OtherIndividualZipCode.setCustomValidity('')
            this.isOtherIndividualZipCode = false
        }
        else{
            OtherIndividualZipCode.setCustomValidity(OWC_invalid_zipcode_msg)
            this.isOtherIndividualZipCode = true
        }
        OtherIndividualZipCode.reportValidity()
    }

    handleIndividualBusinessPhoneFocus(){
        const individualBusinessPhone = this.template.querySelector('[data-id="individualBusinessPhone"');
        if(individualBusinessPhone.value === undefined || individualBusinessPhone.value === null || individualBusinessPhone.value.trim() === ''){
            if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){        
                individualBusinessPhone.setCustomValidity(OWC_required_field_error_msg)
                this.isIndividualBusinessPhone = true
                }
                else{
                    individualBusinessPhone.setCustomValidity("")
                this.isIndividualBusinessPhone = false
                }
        }
        else if(individualBusinessPhone.value.match(this.regExpPhone)){
            individualBusinessPhone.setCustomValidity('')
            this.isIndividualBusinessPhone = false
        }
        else{
            individualBusinessPhone.setCustomValidity(OWC_invalid_phone_msg)
            this.isIndividualBusinessPhone = true
        }
        individualBusinessPhone.reportValidity()
    }
    handleOtherIndividualPhoneFocus(){
        const OtherIndividualPhone = this.template.querySelector('[data-id="OtherIndividualPhone"');
        if(OtherIndividualPhone.value === undefined || OtherIndividualPhone.value === null || OtherIndividualPhone.value.trim() === ''){
            if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){        
                OtherIndividualPhone.setCustomValidity(OWC_required_field_error_msg)
                this.isOtherIndividualPhone = true
                }
                else{
                    OtherIndividualPhone.setCustomValidity("")
                this.isOtherIndividualPhone = false
                }
        }
        else if(OtherIndividualPhone.value.match(this.regExpPhone)){
            OtherIndividualPhone.setCustomValidity('')
            this.isOtherIndividualPhone = false
        }
        else{
            OtherIndividualPhone.setCustomValidity(OWC_invalid_phone_msg)
            this.isOtherIndividualPhone = true
        }
        OtherIndividualPhone.reportValidity()
    }

    @api 
    owcEmpDataForParent(isPrevious){
        this.isPrevious = isPrevious
        let empBusinessType = this.template.querySelector('[data-id="employer_Business_Type"]');
        if(empBusinessType.value === '--Select--' || empBusinessType.value === '--Seleccione--' || empBusinessType.value === undefined || empBusinessType.value === null || empBusinessType.value === ''){
            let empBusinessType = this.template.querySelector('[data-id="employer_Business_Type"]');
            let empBusinessTypeValue = this.empBusinessType
            this.isempBusinessType = this.sectionValidityChecker(empBusinessType, empBusinessTypeValue);
            this.isempBusinessType === true ? empBusinessType.focus() : ''
            
        }
        else{
            this.isempBusinessType = false;
        }
        
        if(this.isRetaliationComplain === true){
            let complainFiledDate = this.template.querySelector('[data-id="complainFiledDate"]');
            this.handleComplainFiledDateValidation();
            this.isClaimFiledDateValid === true ? complainFiledDate.focus() : ''
        }

        const unionContractCovering = this.template.querySelector('[data-id="unionContractId"');
        (unionContractCovering !== undefined || unionContractCovering !== null) ? this.handleUnionContractCoveringFocus() : '';
        this.isNotProvidedUnionCovering === true ? unionContractCovering.focus() : '';

        if(this.isUnionContractCovered === true){
            let unionContractCovered = this.template.querySelector('[data-id="unionContractCovered"]');
            this.handleUnionContractCovered();
            if(this.isUnionContractDocumentUpload === true){
                if(this.uploadUnionContractDocument === undefined || this.uploadUnionContractDocument === null || this.uploadUnionContractDocument === ''){
                    this.isCoverSheetDocRequired = true;
                }
                else{
                    this.isCoverSheetDocRequired = false;
                }
            }
            else if(this.isUrlAddress === true){
                let urlAddress = this.template.querySelector('[data-id="urlAddress"]');
                this.handleUrlAddressValidity();
                this.isCoverSheetDocRequired = false;
                this.isNotUrlAddressValid === true ? urlAddress.focus() : ''
            }
            this.isCoverSheetDocRequired === true || this.isNotProvideAnyUnionContractInfo === true ? unionContractCovered.focus() : ''
            
        }
        if(this.IsIndividual === true){
            const individualEmail = this.template.querySelector('[data-id="individualEmail"]');
            const individualLastName = this.template.querySelector('[data-id="individualLastName"]');
            const individualCellPhone = this.template.querySelector('[data-id="individualCellPhone"]');
            const individualBusinessPhone = this.template.querySelector('[data-id="individualBusinessPhone"]');
            const individualZipCode = this.template.querySelector('[data-id="individualZipCode"]');
            const individualWebsite = this.template.querySelector('[data-id="individualWebsite"]');
            const additionalTotalEmployees = this.template.querySelector('[data-id="additionalTotalEmployees"]');
            this.handleadditionalTotalEmployeesFocus();
            this.isadditionalTotalEmployees === true ? additionalTotalEmployees.focus() : ''
            const additionalEmpBusiness = this.template.querySelector('[data-id="additionalEmpBusiness"]');
            this.handleadditionalEmpBusinessFocus();
            this.isadditionalEmpBusiness === true ? additionalEmpBusiness.focus() : ''
            
            if(this.individualCellPhone != undefined || this.individualCellPhone != null || this.individualCellPhone != ''){
                const individualCellPhone = this.template.querySelector('[data-id="individualCellPhone"');
                this.isindividualCellPhone = this.handlePhoneValidityChecker(individualCellPhone);
            }
            else{
                this.isindividualCellPhone = false
            }
            this.handleIndividualWebsiteFocus();
            this.isIndivudualWebsite === true  ? individualWebsite.focus() : ''
            this.handleIndividualLastNameFocus();
            this.isIndividualLastName === true ? individualLastName.focus() : ''
            this.handleIndividualEmailFocus();
            this.isindividualEmail === true ? individualEmail.focus() : ''
            this.isindividualCellPhone === true ? individualCellPhone.focus() : ''
            this.handleIndividualBusinessPhoneFocus();
            this.isIndividualBusinessPhone === true ? individualBusinessPhone.focus() : ''
            this.handleIndividualZipCodeFocus();
            this.isIndividualZipCode === true ? individualZipCode.focus() : ''
            if(this.individualVehicleLicense === undefined || this.individualVehicleLicense === null || this.individualVehicleLicense === ''){
                if(this.individualFirstName === undefined ||
                    this.individualFirstName === null ||
                    this.individualFirstName === '' ||
                    this.individualStreetAddress === undefined ||
                    this.individualStreetAddress === null ||
                    this.individualStreetAddress === ''||
                    this.individualCity === undefined ||
                    this.individualCity === null ||
                    this.individualCity === ''||
                    this.individualState === undefined ||
                    this.individualState === null ||
                    this.individualState === ''||
                    this.individualZipCode === undefined ||
                    this.individualZipCode === null ||
                    this.individualZipCode === ''||
                    this.individualBusinessPhone === undefined ||
                    this.individualBusinessPhone === null ||
                    this.individualBusinessPhone === ''){
                    let individualFirstName = this.template.querySelector('[data-id="individualFirstName"]');
                    this.handleIndividualFirstNameFocus();
                    this.isIndividualFirstName === true ? individualFirstName.focus() : ''
                    let individualStreetAddress = this.template.querySelector('[data-id="individualStreetAddress"]');
                    this.handleindividualStreetAddressFocus();
                    this.isindividualStreetAddress === true ? individualStreetAddress.focus() : ''
                    let individualCity = this.template.querySelector('[data-id="individualCity"]');
                    this.handleindividualCityFocus();
                    this.isindividualCity === true ? individualCity.focus() : ''
                    let individualState = this.template.querySelector('[data-id="individualState"]');
                    this.handleindividualStateFocus();
                    this.isindividualState === true ? individualState.focus() : ''
                    let individualZipCode = this.template.querySelector('[data-id="individualZipCode"]');
                    this.handleIndividualZipCodeFocus();
                    this.isIndividualZipCode === true ? individualZipCode.focus() : ''
                    let individualBusinessPhone = this.template.querySelector('[data-id="individualBusinessPhone"]');
                    this.handleIndividualBusinessPhoneFocus();
                    this.isIndividualBusinessPhone === true ? individualBusinessPhone.focus() : ''
                }
                else{
                    this.isIndividualFirstName = false
                    this.isindividualStreetAddress = false
                    this.isindividualCity = false
                    this.isindividualState = false
                    // this.isIndividualZipCode = false
                    this.isIndividualBusinessPhone = false
                }
            }
            else{
                this.isIndividualFirstName = false
                this.isindividualStreetAddress = false
                this.isindividualCity = false
                this.isindividualState = false
                // this.isIndividualZipCode = false
                this.isIndividualBusinessPhone = false
            }
        }
        if(this.IsOtherIndividual === true){
            const OtherIndividualPhone = this.template.querySelector('[data-id="OtherIndividualPhone"');
            const OtherIndividualEmail = this.template.querySelector('[data-id="OtherIndividualEmail"');
            const OtherIndividualWebsite = this.template.querySelector('[data-id="OtherIndividualWebsite"');
            let OtherIndividualBusinessName = this.template.querySelector('[data-id="OtherIndividualBusinessName"]');
            let OtherIndividualBusinessNameValue = this.OtherIndividualBusinessName
            this.isOtherIndividualBusinessName = this.sectionValidityChecker(OtherIndividualBusinessName, OtherIndividualBusinessNameValue);
            const OtherIndividualZipCode = this.template.querySelector('[data-id="OtherIndividualZipCode"]');
            this.handleOtherIndividualZipCodeFocus();
            this.handleOtherIndividualPhoneFocus();
            this.handleOtherIndividualEmail();
            this.handleOtherWebsiteFocus();
            this.isOtherIndividualEmail === true ? OtherIndividualEmail.focus() : ''
            this.isOtherIndividualPhone === true ? OtherIndividualPhone.focus() : ''
            this.isOtherIndividualZipCode === true ? OtherIndividualZipCode.focus() : ''
            this.isOtherIndividualBusinessName === true ? OtherIndividualBusinessName.focus() : ''
            this.isOtherIndividualWebsite === true ? OtherIndividualWebsite.focus() : ''
            const additionalTotalEmployees = this.template.querySelector('[data-id="additionalTotalEmployees"');
            this.handleadditionalTotalEmployeesFocus();
            this.isadditionalTotalEmployees === true ? additionalTotalEmployees.focus() : ''
            let additionalEmpBusiness = this.template.querySelector('[data-id="additionalEmpBusiness"]');
            this.handleadditionalEmpBusinessFocus();
            this.isadditionalEmpBusiness === true ? additionalEmpBusiness.focus() : ''
            if(this.OtherIndividualVehicleLicense === undefined || this.OtherIndividualVehicleLicense === null || this.OtherIndividualVehicleLicense === ''){
                if(this.OtherIndividualStreetAddress === undefined ||
                    this.OtherIndividualStreetAddress === null ||
                    this.OtherIndividualStreetAddress === ''||
                    this.OtherIndividualCity === undefined ||
                    this.OtherIndividualCity === null ||
                    this.OtherIndividualCity === ''||
                    this.OtherIndividualState === undefined ||
                    this.OtherIndividualState === null ||
                    this.OtherIndividualState === ''||
                    this.OtherIndividualZipCode === undefined ||
                    this.OtherIndividualZipCode === null ||
                    this.OtherIndividualZipCode === ''||
                    this.OtherIndividualPhone === undefined ||
                    this.OtherIndividualPhone === null ||
                    this.OtherIndividualPhone === ''){
                    let OtherIndividualStreetAddress = this.template.querySelector('[data-id="OtherIndividualStreetAddress"]');
                    this.handleOtherIndividualStreetAddressFocus();
                    this.isOtherIndividualStreetAddress === true ? OtherIndividualStreetAddress.focus() : ''
                    let OtherIndividualCity = this.template.querySelector('[data-id="OtherIndividualCity"]');
                    this.handleOtherIndividualCityfocus();
                    this.isOtherIndividualCity === true ? OtherIndividualCity.focus() : ''
                    let OtherIndividualState = this.template.querySelector('[data-id="OtherIndividualState"]');
                    this.handleOtherIndividualStateFocus();
                    this.isOtherIndividualState === true ? OtherIndividualState.focus() : ''
                    let OtherIndividualZipCode = this.template.querySelector('[data-id="OtherIndividualZipCode"]');
                    this.handleOtherIndividualZipCodeFocus();
                    this.isOtherIndividualZipCode === true ? OtherIndividualZipCode.focus() : ''
                    let OtherIndividualPhone = this.template.querySelector('[data-id="OtherIndividualPhone"]');
                    this.handleOtherIndividualPhoneFocus();
                    this.isOtherIndividualPhone === true ? OtherIndividualPhone.focus() : ''
                }
                else{
                    this.isOtherIndividualStreetAddress = false
                    this.isOtherIndividualCity = false
                    this.isOtherIndividualState = false
                    // this.isOtherIndividualZipCode = false
                    this.isOtherIndividualPhone = false
                }
            }
            else{
                this.isOtherIndividualStreetAddress = false
                this.isOtherIndividualCity = false
                this.isOtherIndividualState = false
                // this.isOtherIndividualZipCode = false
                this.isOtherIndividualPhone = false
            }
            
        }
        if(this.IsOther === true){
            let otherPleaseExplain = this.template.querySelector('[data-id="otherPleaseExplain"]');
            let otherPleaseExplainValue = this.otherPleaseExplain
            this.isotherPleaseExplain = this.sectionValidityChecker(otherPleaseExplain, otherPleaseExplainValue);
            this.isotherPleaseExplain === true ? otherPleaseExplain.focus() : ''
        }
        if(this.isEmployeeFilingWageClaimOther === true){
            let specifyOtherReason = this.template.querySelector('[data-id="specifyOtherReason"]');
                let specifyOtherReasonValue = this.specifyOtherReason
                this.isDontKnowspecifyOtherReason = this.sectionValidityChecker(specifyOtherReason, specifyOtherReasonValue);
                this.isDontKnowspecifyOtherReason === true ? specifyOtherReason.focus() : ''
                
        }
        if(this.isEmployerChangedName === true){
            let startingDate = this.template.querySelector('[data-id="startingDate"]')
            let endingDate = this.template.querySelector('[data-id="endingDate"]')
            this.isEmployerDateAcceptable = this.handleEmployerDateValidation(startingDate, endingDate, startingDate.value, endingDate.value);
            this.isEmployerDateAcceptable === true ? startingDate.focus() : ''
            this.template.querySelector('c-owc-Employer-Name-Changed-Cmp').handleEmployerNameChangedParent();
        }
        if(this.isEmployerChangedNameAfterEmployement === true){
            this.template.querySelector('c-owc-Successor-Section-Container-Cmp').successorSectionDetailsFromParent();
        }


        const covid19Claim = this.template.querySelector('[data-id="covid19ClaimId"');
        (covid19Claim !== undefined || covid19Claim !== null) ? this.handlecovid19ClaimFocus() : '';
        this.iscovid19Claim === true ? covid19Claim.focus() : '';
        if(this.isClaimFiledDateValid === true ||
            this.isEmployerDateAcceptable === true ||
            this.isOtherIndividualWebsite === true ||
            this.isDontKnowspecifyOtherReason === true ||
            this.isNotChangedCurrentStep === true ||
            this.isNotChangedCurrentCmp === true ||
            this.isempBusinessType === true ||
            this.isotherPleaseExplain === true ||
            this.isOtherIndividualBusinessName === true||
            this.isOtherIndividualWebsite === true  ||
            this.isOtherIndividualZipCode === true ||
            this.isOtherIndividualPhone === true ||
            this.isOtherIndividualEmail === true ||
            this.isIndividualRequiredSet === true ||
            this.isIndivudualWebsite === true ||
            this.isIndividualBusinessPhone === true ||
            this.isIndividualLastName === true||
            this.isadditionalTotalEmployees === true ||
            this.isadditionalEmpBusiness === true ||
            this.iscovid19Claim === true ||
            this.isindividualCellPhone === true ||
            this.isindividualEmail === true ||
            this.isIndividualZipCode === true ||
            this.isNotProvidedUnionCovering === true ||
            this.isNotProvideAnyUnionContractInfo === true ||
            this.isCoverSheetDocRequired === true || 
            this.isNotUrlAddressValid === true ||
            this.isIndividualFirstName === true || 
            this.isindividualStreetAddress === true || 
            this.isindividualCity === true || 
            this.isindividualState === true || 
            this.isOtherIndividualStreetAddress  === true || 
            this.isOtherIndividualCity  === true || 
            this.isOtherIndividualState  === true ){ 
            this.isNotChangedCurrentStep = false;
            this.isNotChangedCurrentCmp = false;
            this.handleCustomValidityChecker();
        }
        else{
            this.handleEvent();
        }
    }
    sectionValidityChecker(ids, values){
        let id = ids
        let value = values
        if(value == undefined && value == null || value.trim() == ""){
            id.setCustomValidity(OWC_required_field_error_msg);
            id.reportValidity();
            return true;
        }
    }

    handlePhoneValidityChecker(values){
        const value = values
        if(value.value.trim() == ''){
            value.setCustomValidity('');
            value.reportValidity()
            return false
        }
        else if(value.value.trim() != ''){
            if(value.value.match(this.regExpPhone)){
                value.setCustomValidity("");
                value.reportValidity()
                return false
            }
            else{
                value.setCustomValidity(OWC_invalid_phone_msg);
                value.reportValidity()
                return true
            }                
        }
    }
    
    @api
    getSectionId(event){
        event.preventDefault()
        const selectEvent = new CustomEvent('customemployerdeleteevent', {
            detail: {
                sectionId : this.sectionid
            }
        });
        this.dispatchEvent(selectEvent);
    }

    @api
    handleEmployerSectionData(){
        const selectEvent = new CustomEvent('employersectiondeleteevent', {
            detail: this.employerInfoObj()},
        );
        this.dispatchEvent(selectEvent);
    }
    
    employerInfoObj(){
        return {
            sectionId : this.sectionid,
            countryCodeindividualBusinessPhone : this.countryCodeindividualBusinessPhone,
            countryCodeindividualCellPhone : this.countryCodeindividualCellPhone,
            countryCodeOtherIndividualPhone : this.countryCodeOtherIndividualPhone,
            employerChangedName : this.employerChangedName,
            isEmployerChangedName : this.isEmployerChangedName,
            claimantRelatedRoleActions : this.claimantRelatedRoleActions,
            mailOfficeLocator : this.mailOfficeLocator,
            isOfficeLocatorMail : this.isOfficeLocatorMail,
            IsIndividual : this.IsIndividual,
            isClaimantAdvocate : this.isClaimantAdvocate,
            isOtherIndividualPicklist : this.isOtherIndividualPicklist,
            isIndividualStatePicklist : this.isIndividualStatePicklist,
            employerAdditionalUploadDocSize : this.employerAdditionalUploadDocSize,
            uploadedEmployerAdditionalDocuments : this.uploadedEmployerAdditionalDocuments,
            isEmployerAdditionalDoc : this.isEmployerAdditionalDoc,
            uploadedEmployerDocuments : this.uploadedEmployerDocuments,
            isEmployerDocUpload : this.isEmployerDocUpload,
            employerUploadDocSize : this.employerUploadDocSize,
            uploadUnionContractDocument : this.uploadUnionContractDocument,
            IsOther : this.IsOther,
            isEmployerSellingAssets : this.isEmployerSellingAssets,
            additionalWHOPaidYou : this.additionalWHOPaidYou,
            owcWorkRecordList : this.owcWorkRecordList,
            additionalBankName : this.additionalBankName,
            additionalPersonInchargeName : this.additionalPersonInchargeName,
            uploadUnionContractDocumentadditional : this.uploadUnionContractDocumentadditional,
            representativeEmployerType : this.representativeEmployerType,
            otherPleaseExplain : this.otherPleaseExplain,
            showIndividualSole : this.showIndividualSole,
            individualFirstName : this.individualFirstName, 
            individualLastName : this.individualLastName,
            individualStreetAddress : this.individualStreetAddress,
            individualCity : this.individualCity,
            individualState : this.individualState,
            IsAdditionalInfo : this.IsAdditionalInfo,
            individualZipCode : this.individualZipCode,
            uploadPayStubImages : this.uploadPayStubImages,
            individualBusinessPhone : this.individualBusinessPhone,
            individualCellPhone : this.individualCellPhone,
            individualEmail : this.individualEmail,
            individualVehicleLicense : this.individualVehicleLicense,
            individualWebsite : this.individualWebsite,
            OtherIndividualBusinessName : this.OtherIndividualBusinessName,
            OtherIndividualStreetAddress : this.OtherIndividualStreetAddress,
            OtherIndividualCity : this.OtherIndividualCity, 
            OtherIndividualState : this.OtherIndividualState,
            OtherIndividualZipCode : this.OtherIndividualZipCode,
            OtherIndividualPhone : this.OtherIndividualPhone,
            OtherIndividualEmail : this.OtherIndividualEmail,
            OtherIndividualVehicleLicense : this.OtherIndividualVehicleLicense,
            OtherIndividualWebsite : this.OtherIndividualWebsite,
            OtherIndividualConstructionTrades : this.OtherIndividualConstructionTrades,
            isUnionDocumentFileUploaded : this.isUnionDocumentFileUploaded,
            isFileUploadedAdditional : this.isFileUploadedAdditional,
            additionalName : this.additionalName,
            paystubFileSize : this.paystubFileSize,
            additionalJobTitle : this.additionalJobTitle,
            additionalDifferentPerson : this.additionalDifferentPerson,
            additionalWorkRecord : this.additionalWorkRecord,
            additionalSignTimeCard : this.additionalSignTimeCard,
            additionalSomeoneElse : this.additionalSomeoneElse,
            additionalTotalEmployees : this.additionalTotalEmployees,
            additionalEmpBusiness : this.additionalEmpBusiness,
            additionalCompEmployed : this.additionalCompEmployed,
            additionalChangeOrSold : this.additionalChangeOrSold,
            additionalBankruptcy : this.additionalBankruptcy,
            uploadAdditionalDocuments : this.uploadAdditionalDocuments,
            IsOtherIndividual : this.IsOtherIndividual,
            isPayStubFileUploaded : this.isPayStubFileUploaded,
            IsIndividual : this.IsIndividual,
            unionContractCovering : this.unionContractCovering,
            urlAddress : this.urlAddress,
            isUnionContractCovered : this.isUnionContractCovered,
            unionContractCovered : this.unionContractCovered,
            filingWageClaim : this.filingWageClaim,
            coversheetDocument : this.coversheetDocument,
            isEmployeeFilingWageClaim : this.isEmployeeFilingWageClaim,
            specifyFilingWageClaim : this.specifyFilingWageClaim,
            covid19Claim : this.covid19Claim,
            isEmployeeFilingWageClaimOther : this.isEmployeeFilingWageClaimOther,
            specifyOtherReason : this.specifyOtherReason,
            empName : this.empName,
            isDontKnow : this.isDontKnow,
            unionUploadDocSize : this.unionUploadDocSize,
            isUnionContractDocumentUpload : this.isUnionContractDocumentUpload,
            isUrlAddress : this.isUrlAddress,
            isMailToOfficeLocator : this.isMailToOfficeLocator,
            employerNameChangedDetails : this.employerNameChangedDetails,
            startingDate : this.startingDate,
            endingDate : this.endingDate,
            employerChangedNameAfterEmployement : this.employerChangedNameAfterEmployement,
            isEmployerChangedNameAfterEmployement : this.isEmployerChangedNameAfterEmployement,
            isNotChangedCurrentSteps : this.isNotChangedCurrentSteps,
            employerNameAfterEmployementDetails : this.employerNameAfterEmployementDetails,
            workForThisComp : this.workForThisComp,
            workWithSameWorokers : this.workWithSameWorokers,
            ownershipOfCompRelated : this.ownershipOfCompRelated,
            successorDetails : this.successorDetails,
            employerVerificationUploadDoc : this.employerVerificationUploadDoc,
            isEmployerVerificationDoc : this.isEmployerVerificationDoc,
            employerVerificationUploadSize : this.employerVerificationUploadSize,
            isSignCard : this.isSignCard,
            signCardName : this.signCardName,
            retaliationComplain : this.retaliationComplain,
            isRetaliationComplain : this.isRetaliationComplain,
            complainFiledDate : this.complainFiledDate,
            complainCaseNumber : this.complainCaseNumber,
            isRetaliationComplainFalse : this.isRetaliationComplainFalse,
            mileageClaimDetails : this.mileageClaimDetails,
            renderMilegaClaimSection : this.renderMilegaClaimSection,
            showAdditionalInfoHeading : this.showAdditionalInfoHeading,
            IndividualFirstNamerequired : this.IndividualFirstNamerequired,
            IndividualStreetAddressrequired : this.IndividualStreetAddressrequired,
            IndividualCityrequired : this.IndividualCityrequired,
            IndividualStaterequired : this.IndividualStaterequired,
            IndividualZipCoderequired : this.IndividualZipCoderequired,
            IndividualBusinessPhonerequired : this.IndividualBusinessPhonerequired,
            OtherStreetAddressrequired : this.OtherStreetAddressrequired,
            OtherCityrequired : this.OtherCityrequired,
            OtherStaterequired : this.OtherStaterequired,
            OtherZipCoderequired : this.OtherZipCoderequired,
            OtherBusinessPhonerequired : this.OtherBusinessPhonerequired,
            totalVerficationUploadFiles : this.totalVerficationUploadFiles,
            totalUnionUploadFiles : this.totalUnionUploadFiles,
            totalEmployerUploadFile : this.totalEmployerUploadFile
        }
    }

    @api
    handleEvent(){
        this.template.querySelector('c-owc-Additinal-Person-Name-Container').handleSickLeaveTimeParent()
        const selectEvent = new CustomEvent('claimfiledcustomevent', {
            detail: this.employerInfoObj()
        });
        this.dispatchEvent(selectEvent);
    }

    @api
    handleCustomValidityChecker(){
        const selectEvent = new CustomEvent('empbusinessvalidityevent', {
            detail: { 
                currentStep : true
            }
        });
        this.dispatchEvent(selectEvent);
        return;
    }

     handleEmployerDateValidation(startDateId, endDateId, startDate, endDate){
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

        else if((startDate === '' && endDate !== '') || 
        (startDate !== '' && endDate === '')){
            startDateId.setCustomValidity('Please fill both date field.')
            endDateId.setCustomValidity('Please fill both date field.')
            startDateId.reportValidity();
            endDateId.reportValidity();
            return true;
        }
        
        else if(startDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            startDateId.setCustomValidity(customLabelValues.OWC_pastdate_error_msg)
            startDateId.reportValidity()
            return true;
        }

        else if(endDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            endDateId.setCustomValidity(customLabelValues.OWC_pastdate_error_msg)
            endDateId.reportValidity()
            return true;
        }
        
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

   
    @api isNotChangedCurrentStep = false

    
    handleEmployerNameChangedValidity(event){
        this.isNotChangedCurrentStep = event.detail.currentStep
    }

    handleMileageClaimParentValidityCheck(event){
        this.isNotChangedCurrentStep = event.detail.currentStep;
    }

    @api get showAdditionalInfoHeading(){
        return ((this.mileageClaimDetails !== undefined && this.mileageClaimDetails.filter(item => item.additinalPersonLastName !== undefined || 
            item.additinalPersonLastName !== undefined || 
            item.claimantRelatedRoleActions !== undefined).length > 0) || 
        this.additionalWHOPaidYou !== undefined || 
        this.additionalDifferentPerson !== undefined || 
        this.owcWorkRecordList !== undefined || 
        this.additionalSignTimeCard !== undefined || 
        this.additionalSomeoneElse !== undefined || 
        this.additionalEmpBusiness !== undefined || 
        this.additionalBankruptcy !== undefined || 
        this.additionalBankName !== undefined || 
        this.isEmployerChangedName === true || 
        this.isEmployerChangedNameAfterEmployement === true) && this.isFormPreviewMode === true
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

    handleEmployerNameChangedDataEvent(event){
        this.employerNameChangedDetails = event.detail
    }

    
    handleSuccessorSectionInfoEvent(event){
        const successorDetails = event.detail
        this.successorDetails = successorDetails
    }
    
    
    handleSuccessorSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentCmp = val.currentStep
    }

    
    get showAdditionalIncharge(){
        return this.empBusinessTypeDetails.additionalPersonInchargeName !== null || this.empBusinessTypeDetails.claimantRelatedRoleActions !== null
    }
    
    get showChangedDate(){
        return this.empBusinessTypeDetails.startingDate !== null || this.empBusinessTypeDetails.endingDate !== null
    }

    @api
    owcEmpDataForChild(strString,isFormPreviewMode){
        this.isFormPreviewMode = isFormPreviewMode
        this.empBusinessTypeDetails = strString

        if(this.empBusinessTypeDetails.additionalName !== undefined || this.empBusinessTypeDetails.additionalJobTitle !== undefined || this.empBusinessTypeDetails.additionalWHOPaidYou != undefined || this.empBusinessTypeDetails.additionalDifferentPerson != undefined || this.empBusinessTypeDetails.owcWorkRecordList != undefined || this.empBusinessTypeDetails.additionalSignTimeCard != undefined || this.empBusinessTypeDetails.additionalSomeoneElse != undefined || this.empBusinessTypeDetails.additionalTotalEmployees != undefined || this.empBusinessTypeDetails.additionalEmpBusiness != undefined || this.empBusinessTypeDetails.additionalCompEmployed != undefined || this.empBusinessTypeDetails.additionalChangeOrSold != undefined || this.empBusinessTypeDetails.additionalBankruptcy != undefined ){
            this.isAdditionalHeading = true;
        }
        else{
            this.isAdditionalHeading = false;
        }

        if(this.empBusinessTypeDetails.IsIndividual === true && this.empBusinessTypeDetails.isClaimantAdvocate === true){
            this.isNotClaimantGarment = true
        }
        if(isNaN(strString.representativeEmployerType)){
            this.template.querySelector('[data-id="employer_Business_Type"]').value = strString.representativeEmployerType
            this.representativeEmployerType = strString.representativeEmployerType
        }
        this.mileageClaimDetails = strString.mileageClaimDetails
        this.renderMilegaClaimSection = strString.renderMilegaClaimSection
        this.claimantRelatedRoleActions = strString.claimantRelatedRoleActions
        this.owcWorkRecordList = strString.owcWorkRecordList
        this.additionalSignTimeCard = strString.additionalSignTimeCard
        this.additionalEmpBusiness = strString.additionalEmpBusiness
        this.additionalCompEmployed = strString.additionalCompEmployed
        this.CodeindividualBusinessPhone = strString.CodeindividualBusinessPhone
        this.countryCodeindividualCellPhone = strString.countryCodeindividualCellPhone
        this.countryCodeOtherIndividualPhone = strString.countryCodeOtherIndividualPhone
        this.additionalChangeOrSold = strString.additionalChangeOrSold
        this.additionalBankruptcy = strString.additionalBankruptcy
        this.isEmployerSellingAssets = strString.isEmployerSellingAssets
        this.isEmployeeFilingWageClaim = strString.isEmployeeFilingWageClaim
        this.covid19Claim = strString.covid19Claim
        this.isEmployeeFilingWageClaimOther = strString.isEmployeeFilingWageClaimOther
        this.specifyOtherReason = strString.specifyOtherReason
        this.isOtherIndividualPicklist = strString.isOtherIndividualPicklist
        this.isIndividualStatePicklist = strString.isIndividualStatePicklist
        this.employerAdditionalUploadDocSize = strString.employerAdditionalUploadDocSize
        this.uploadedEmployerAdditionalDocuments = strString.uploadedEmployerAdditionalDocuments
        this.isEmployerDocUpload = strString.isEmployerDocUpload
        this.isEmployerAdditionalDoc = strString.isEmployerAdditionalDoc
        this.employerUploadDocSize = strString.employerUploadDocSize
        this.otherPleaseExplain = strString.otherPleaseExplain
        this.empName = strString.empName
        this.isDontKnow = strString.isDontKnow
        this.additionalBankName = strString.additionalBankName
        this.additionalWHOPaidYou = strString.additionalWHOPaidYou
        this.additionalPersonInchargeName = strString.additionalPersonInchargeName
        this.individualFirstName = strString.individualFirstName
        this.individualLastName = strString.individualLastName
        this.individualStreetAddress = strString.individualStreetAddress
        this.individualCity = strString.individualCity
        this.IsOther = strString.IsOther
        this.uploadPayStubImages = strString.uploadPayStubImages
        this.showIndividualSole = strString.showIndividualSole
        this.individualState = strString.individualState
        this.individualZipCode = strString.individualZipCode
        this.individualBusinessPhone = strString.individualBusinessPhone
        this.individualCellPhone = strString.individualCellPhone
        this.individualEmail = strString.individualEmail
        this.individualVehicleLicense = strString.individualVehicleLicense
        this.individualWebsite = strString.individualWebsite
        this.OtherIndividualBusinessName = strString.OtherIndividualBusinessName
        this.OtherIndividualStreetAddress = strString.OtherIndividualStreetAddress
        this.OtherIndividualCity = strString.OtherIndividualCity
        this.OtherIndividualState = strString.OtherIndividualState
        this.OtherIndividualZipCode = strString.OtherIndividualZipCode
        this.OtherIndividualPhone = strString.OtherIndividualPhone
        this.OtherIndividualEmail = strString.OtherIndividualEmail
        this.OtherIndividualVehicleLicense = strString.OtherIndividualVehicleLicense
        this.OtherIndividualWebsite = strString.OtherIndividualWebsite
        this.OtherIndividualConstructionTrades = strString.OtherIndividualConstructionTrades
        this.uploadedEmployerDocuments = strString.uploadedEmployerDocuments
        this.uploadUnionContractDocument = strString.uploadUnionContractDocument === undefined ? [] : strString.uploadUnionContractDocument
        this.uploadUnionContractDocumentadditional = strString.uploadUnionContractDocumentadditional === undefined ? [] : strString.uploadUnionContractDocumentadditional
        this.isUnionDocumentFileUploaded = strString.isUnionDocumentFileUploaded
        this.isFileUploadedAdditional = strString.isFileUploadedAdditional
        this.isPayStubFileUploaded = strString.isPayStubFileUploaded
        this.additionalName = strString.additionalName
        this.additionalJobTitle = strString.additionalJobTitle
        this.additionalDifferentPerson = strString.additionalDifferentPerson
        this.additionalWorkRecord = strString.additionalWorkRecord
        this.additionalSomeoneElse = strString.additionalSomeoneElse
        this.additionalTotalEmployees = strString.additionalTotalEmployees
        this.uploadAdditionalDocuments = strString.uploadAdditionalDocuments
        this.IsIndividual = strString.IsIndividual
        this.unionContractCovering = strString.unionContractCovering
        this.urlAddress = strString.urlAddress
        this.isUnionContractCovered = strString.isUnionContractCovered
        this.unionContractCovered = strString.unionContractCovered
        this.filingWageClaim = strString.filingWageClaim
        this.isEmployerChangedName = strString.isEmployerChangedName
        this.employerChangedName = strString.employerChangedName
        this.coversheetDocument = strString.coversheetDocument,
        this.specifyFilingWageClaim = strString.specifyFilingWageClaim,
        this.covid19Claim = strString.covid19Claim,
        this.specifyOtherReason = strString.specifyOtherReason,
        this.IsAdditionalInfo = strString.IsAdditionalInfo
        this.paystubFileSize = strString.paystubFileSize
        this.IsOtherIndividual = strString.IsOtherIndividual
        this.unionUploadDocSize = strString.unionUploadDocSize
        this.mailOfficeLocator = strString.mailOfficeLocator
        this.isOfficeLocatorMail = strString.isOfficeLocatorMail
        this.isUnionContractDocumentUpload = strString.isUnionContractDocumentUpload
        this.isUrlAddress = strString.isUrlAddress
        this.isMailToOfficeLocator = strString.isMailToOfficeLocator
        this.employerNameChangedDetails = strString.employerNameChangedDetails
        this.startingDate = strString.startingDate
        this.endingDate = strString.endingDate
        this.employerChangedNameAfterEmployement = strString.employerChangedNameAfterEmployement
        this.isEmployerChangedNameAfterEmployement = strString.isEmployerChangedNameAfterEmployement
        this.isNotChangedCurrentSteps = strString.isNotChangedCurrentSteps
        this.employerNameAfterEmployementDetails = strString.employerNameAfterEmployementDetails
        this.workForThisComp = strString.workForThisComp
        this.workWithSameWorokers = strString.workWithSameWorokers
        this.ownershipOfCompRelated = strString.ownershipOfCompRelated
        this.successorDetails = strString.successorDetails
        this.employerVerificationUploadDoc = strString.employerVerificationUploadDoc === undefined ? [] : strString.employerVerificationUploadDoc,
        this.isEmployerVerificationDoc = strString.isEmployerVerificationDoc,
        this.employerVerificationUploadSize = strString.employerVerificationUploadSize
        this.selectedAddressIndex = strString.selectedAddressIndex
        this.succesWithCurrentAddress = strString.succesWithCurrentAddress
        this.isSignCard = strString.isSignCard
        this.signCardName = strString.signCardName
        this.retaliationComplain = strString.retaliationComplain
        this.isRetaliationComplain = strString.isRetaliationComplain
        this.complainFiledDate = strString.complainFiledDate,
        this.complainCaseNumber = strString.complainCaseNumber
        this.isRetaliationComplainFalse = strString.isRetaliationComplainFalse
        this.isRenderedCallback = true
        this.showAdditionalInfoHeading = strString.showAdditionalInfoHeading
        this.IndividualFirstNamerequired = strString.IndividualFirstNamerequired
        this.IndividualStreetAddressrequired = strString.IndividualStreetAddressrequired
        this.IndividualCityrequired = strString.IndividualCityrequired
        this.IndividualStaterequired = strString.IndividualStaterequired
        this.IndividualZipCoderequired = strString.IndividualZipCoderequired
        this.IndividualBusinessPhonerequired = strString.IndividualBusinessPhonerequired
        this.OtherStreetAddressrequired = strString.OtherStreetAddressrequired
        this.OtherCityrequired = strString.OtherCityrequired
        this.OtherStaterequired = strString.OtherStaterequired
        this.OtherZipCoderequired = strString.OtherZipCoderequired
        this.totalVerficationUploadFiles = strString.totalVerficationUploadFiles
        this.totalUnionUploadFiles = strString.totalUnionUploadFiles
        this.OtherBusinessPhonerequired = strString.OtherBusinessPhonerequired
        this.totalEmployerUploadFile  = strString.totalEmployerUploadFile
    }

    renderedCallback(){
        if(this.isFocusable === true){
            var employer_Business_Type = this.template.querySelector('[data-id="employer_Business_Type"]');
            employer_Business_Type.focus();
            this.isFocusable = false;
        }
        if(this.isRenderedCallback === true && this.mileageClaimDetails.filter(item => item.additinalPersonLastName !== undefined || item.additinalPersonFirstName !== undefined).length > 0){
            this.template.querySelector('c-owc-Additinal-Person-Name-Container').overTimeParentInfoSectionChild(this.mileageClaimDetails, this.renderMilegaClaimSection, this.isFormPreviewMode);
        }
        if(this.isRenderedCallback === true && this.isUnionContractCovered === true && this.unionContractCovered !== undefined){
            this.template.querySelector('[data-id="unionContractCovered"]').value = this.unionContractCovered
        }
        if(this.isRenderedCallback === true && this.isClaimantAdvocate === false && this.isRenderIndividualState === false){
            this.template.querySelector('[data-id="individualState"]').value = this.individualState
        }
        if(this.isRenderedCallback === true && this.OtherIndividualState !== undefined && this.isOtherIndividualPicklist === true){
            this.template.querySelector('[data-id="OtherIndividualState"]').value = this.OtherIndividualState
        }
        if(this.isRenderedCallback === true && this.mailOfficeLocator !== undefined && this.mailOfficeLocator !== null){
            this.template.querySelector('[data-id="mailOfficeLocator"]').value = this.mailOfficeLocator
        }
        if(this.isRenderedCallback === true && this.workForThisComp !== undefined && this.workForThisComp !== null){
            this.template.querySelector('[data-id="workForThisComp"]').value = this.workForThisComp
        }
        if(this.isRenderedCallback === true && this.ownershipOfCompRelated !== undefined && this.ownershipOfCompRelated !== null){
            this.template.querySelector('[data-id="ownershipOfCompRelated"]').value = this.ownershipOfCompRelated
        }
        if(this.isRenderedCallback === true && this.workWithSameWorokers !== undefined && this.workWithSameWorokers !== null){
            this.template.querySelector('[data-id="workWithSameWorokers"]').value = this.workWithSameWorokers
        }
        if(this.isRenderedCallback === true && this.employerNameChangedDetails !== undefined && this.employerNameChangedDetails !== null && this.isEmployerChangedName === true){
            this.template.querySelector('c-owc-Employer-Name-Changed-Cmp').handleEmployerNameChangedChild(this.employerNameChangedDetails, this.isFormPreviewMode);
        }
        if(this.isRenderedCallback === true && this.isEmployerChangedNameAfterEmployement === true && this.successorDetails !== null && this.successorDetails !== undefined){
            this.template.querySelector('c-owc-Successor-Section-Container-Cmp').successorSectionDetailsForChild(this.successorDetails, this.isFormPreviewMode);
        }
        if(this.isRenderedCallback === true && this.isEmployerChangedName === true && (this.startingDate !== undefined || this.startingDate !== null || this.startingDate !== null)){
            this.template.querySelector('[data-id="startingDate"]').value = this.startingDate
        }
        if(this.isRenderedCallback === true && this.isEmployerChangedName === true && (this.endingDate !== undefined || this.endingDate !== null || this.endingDate !== null)){
            this.template.querySelector('[data-id="endingDate"]').value = this.endingDate
        }
        if(this.isRenderedCallback === true && this.employerChangedNameAfterEmployement !== undefined && this.employerChangedNameAfterEmployement !== null){
            this.template.querySelector('[data-id="employerChangedNameAfterEmployement"]').value = this.employerChangedNameAfterEmployement
        }
        if(this.isRenderedCallback === true){
            const templateArray = this.template.querySelectorAll('c-owc-Multiple-File-Upload-Details-Cmp')
            for (let i = 0; i < templateArray.length; i++){
                if(templateArray[i].name === 'unionContractDocFile'){
                        templateArray[i].getDocInfos(this.uploadUnionContractDocument, this.isFormPreviewMode);
                }
                else if(templateArray[i].name === 'employerFileUpload'){
                        templateArray[i].getDocInfos(this.uploadedEmployerDocuments, this.isFormPreviewMode);
                }
                else if(templateArray[i].name === 'employerAdditionalDocument'){
                        templateArray[i].getDocInfos(this.uploadedEmployerAdditionalDocuments, this.isFormPreviewMode);
                }
                else if(templateArray[i].name === 'employerVerificationDoc'){
                    templateArray[i].getDocInfos(this.employerVerificationUploadDoc, this.isFormPreviewMode);
                }
            }
            this.isRenderedCallback = false
        }
        this.isRenderedCallback = false
        
    }

    @api
    handleEmployerSectionDeleteFiles(isFilesDeleted){
        if(isFilesDeleted === true){
            const templateArray = this.template.querySelectorAll('c-owc-Multiple-File-Upload-Details-Cmp')
            for (let i = 0; i < templateArray.length; i++){
                if(templateArray[i].name === 'unionContractDocFile'){
                    if(this.uploadUnionContractDocument != ''){
                        templateArray[i].getDocData(this.uploadUnionContractDocument, isFilesDeleted);
                    }
                }
                else if(templateArray[i].name === 'employerFileUpload'){
                    if(this.uploadedEmployerDocuments != ''){
                        templateArray[i].getDocData(this.uploadedEmployerDocuments, isFilesDeleted);
                    }
                }
                else if(templateArray[i].name === 'employerAdditionalDocument'){
                    if(this.uploadedEmployerAdditionalDocuments != ''){
                        templateArray[i].getDocData(this.uploadedEmployerAdditionalDocuments, isFilesDeleted);
                    }
                }
                else if(templateArray[i].name === 'employerAdditionalDocument'){
                    if(this.employerVerificationUploadDoc != ''){
                        templateArray[i].getDocData(this.employerVerificationUploadDoc, isFilesDeleted);
                    }
                }
            }
        }
    }
    
    get acceptedFormats() {
        return acceptedFileFormat;
    }
    
    @api get isFileUploadDisabled(){
        return this.employerVerificationUploadDoc.length >= 10 && this.isRenderedCallback === false;
    }

    @api get isUnionUploadDisabled(){
        return this.uploadUnionContractDocument.length >= 10 && this.isRenderedCallback === false;
    }

    @api get isEmployerFileUploaded(){
        return this.uploadedEmployerAdditionalDocuments.length >= 10 && this.isRenderedCallback === false;
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
           })
    }

    @api totalVerficationUploadFiles = [];

    handleEmployerVerificationDocs(event){
        const uploadedFiles = event.detail.files;
        for(var i=0; i<uploadedFiles.length; i++){
            this.totalVerficationUploadFiles.push(uploadedFiles[i]);
        }
        if(this.totalVerficationUploadFiles.length <= 10){
            this.employerVerificationUploadDoc = uploadedFiles;
            if(uploadedFiles != null){
                this.isEmployerVerificationDoc = false
                this.employerVerificationUploadSize = this.employerVerificationUploadDoc.length
                this.template.querySelector('[data-id="employerVerificationDocId"]').getDocData(this.employerVerificationUploadDoc, false);
                this.isRenderedCallback = false
                this.showToast('Success!',this.toastFileUploadMsg,'success');
            }
            else{
                this.isEmployerVerificationDoc = true
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
            for(var j=0; j<this.totalVerficationUploadFiles.length; j++){
                if(uploadedFiles[i].documentId === this.totalVerficationUploadFiles[j].documentId){
                    this.totalVerficationUploadFiles.splice(j , 1)
                }
            }
        }
    }

    updateFileVariables(){
        if(this.employerVerificationUploadDoc !== undefined && this.employerVerificationUploadDoc.length > 0){
            this.totalVerficationUploadFiles.length = 0;
            this.totalVerficationUploadFiles = this.employerVerificationUploadDoc;
        }
    }

    
    handleEmployerVerficationUpload(event){
        this.employerVerificationUploadDoc = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.updateFileVariables();
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.employerVerificationUploadSize = this.employerVerificationUploadDoc.length
    }
    
    @api totalUnionUploadFiles = [];

    handleUnionContractUpload(event) {
        const uploadedFiles = event.detail.files;

        for(var i=0; i<uploadedFiles.length; i++){
            this.totalUnionUploadFiles.push(uploadedFiles[i]);
        }
        if(this.totalUnionUploadFiles.length <= 10){
            this.uploadUnionContractDocument = uploadedFiles;
            this.handleUnionContractUpload.length > 0 ? this.isCoverSheetDocRequired = false : this.isCoverSheetDocRequired = true;
            if(uploadedFiles != null){
                this.isUnionDocumentFileUploaded = false
                this.unionUploadDocSize = this.uploadUnionContractDocument.length
                this.template.querySelector('[data-id="unionContractDocFileId"]').getDocData(this.uploadUnionContractDocument, false);
                this.isRenderedCallback = false
                this.showToast('Success!',this.toastFileUploadMsg,'success');
            }
            else{
                this.isUnionDocumentFileUploaded = true
            }
        }
        else{
            this.deleteExtraFiles(uploadedFiles);
            this.handleUnionFileLimit(uploadedFiles);
            this.showToast('Error!', this.customLabelValues.OWC_file_size_error,'error');
        }
    }

    handleUnionFileLimit(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            for(var j=0; j<this.totalUnionUploadFiles.length; j++){
                if(uploadedFiles[i].documentId === this.totalUnionUploadFiles[j].documentId){
                    this.totalUnionUploadFiles.splice(j , 1)
                }
            }
        }
    }
    
    updateUnionFileVariables(){
        if(this.uploadUnionContractDocument !== undefined && this.uploadUnionContractDocument.length > 0){
            this.totalUnionUploadFiles.length = 0;
            this.totalUnionUploadFiles = this.uploadUnionContractDocument;
        }
    }

    handleUploadedDocDataUnionContract(event){
        this.uploadUnionContractDocument = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.updateUnionFileVariables();
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.unionUploadDocSize = this.uploadUnionContractDocument.length
    }
    
    handleEmployerDocUpload(event){
        const uploadedFiles = event.detail.files;
        this.uploadedEmployerDocuments = uploadedFiles;
        if(uploadedFiles != null){
            this.isEmployerDocUpload = false
            this.employerUploadDocSize = this.uploadedEmployerDocuments.length
            this.template.querySelector('[data-id="employeeDocId"]').getDocData(this.uploadedEmployerDocuments, false);
            this.isRenderedCallback = false
            this.showToast('Success!',this.toastFileUploadMsg,'success');
        }
        else{
            this.isEmployerDocUpload = true
        }
    }
    
    handleEmployerDocData(event){
        this.uploadedEmployerDocuments = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.employerUploadDocSize = this.uploadedEmployerDocuments.length
    }

    @api totalEmployerUploadFile = [];
    
    handleEmployerAddtionalDocUpload(event){
        const uploadedFiles = event.detail.files;

        for(var i=0; i<uploadedFiles.length; i++){
            this.totalEmployerUploadFile.push(uploadedFiles[i]);
        }

        if(this.totalEmployerUploadFile.length <= 10){
            this.uploadedEmployerAdditionalDocuments = uploadedFiles;
            if(uploadedFiles != null){
                this.isEmployerAdditionalDoc = false
                this.employerAdditionalUploadDocSize = this.uploadedEmployerAdditionalDocuments.length
                this.template.querySelector('[data-id="employerAdditionalDocId"]').getDocData(this.uploadedEmployerAdditionalDocuments, false);
                this.isRenderedCallback = false
                this.showToast('Success!',this.toastFileUploadMsg,'success');
            }
            else{
                this.isEmployerAdditionalDoc = true
            }
        }
        else{
            this.deleteExtraFiles(uploadedFiles);
            this.handleEmployerFileLimit(uploadedFiles);
            this.showToast('Error!', this.customLabelValues.OWC_file_size_error,'error');
        }
    }

    handleEmployerFileLimit(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            for(var j=0; j<this.totalEmployerUploadFile.length; j++){
                if(uploadedFiles[i].documentId === this.totalEmployerUploadFile[j].documentId){
                    this.totalEmployerUploadFile.splice(j , 1)
                }
            }
        }
    }
    
    updateEmployerFileVariables(){
        if(this.uploadedEmployerAdditionalDocuments !== undefined && this.uploadedEmployerAdditionalDocuments.length > 0){
            this.totalEmployerUploadFile.length = 0;
            this.totalEmployerUploadFile = this.uploadedEmployerAdditionalDocuments;
        }
    }

    handleEmployerAdditionalDocData(event){
        this.uploadedEmployerAdditionalDocuments = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.updateEmployerFileVariables()
        this.isSelectedFileDeleted === true ? this.showToast('Success!',this.toastFileDeleteMsg,'success') : ''
        this.employerAdditionalUploadDocSize = this.uploadedEmployerAdditionalDocuments.length
    }    
    @api isMultipleFileUploadHelpText
    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === 'covid19HelpText'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_COVID19_helptext;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === "ConstructionTradesHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_ContractionTrade_Helptext;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === 'employerNameChangedDuringEmp'){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_employer_name_changed_helptext;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === "MultiFileUploadHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_UploadDocument_Helptext;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        }
        else if(learnMoreName === "AddImageHelpText"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_AddImage_HelpText;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === "additionalName"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_EnterName_HelpText;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === "bestGuess"){
            this.isHelpText = true;
            this.helpText = this.customLabelValues.OWC_BestGuess_HelpText;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === 'multiFileUploadHelpText1'){
            this.isHelpText = true;
            this.helpText = OWC_multiplefileupload_helptext;
            this.isMultipleFileUploadHelpText = ''
        }
        else if(learnMoreName === "coversheetDocumentHelpText"){
            this.isHelpText = true;
            this.helpText = OWC_preliminary_coversheet_helptext;
            this.isMultipleFileUploadHelpText = OWC_multiplefileupload_helptext
        }
        else if(learnMoreName === "LastName"){
            this.isHelpText = true;
            this.helpText = OWC_LastName_helptext;
            this.isMultipleFileUploadHelpText = ''
        }
    }

    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }
}