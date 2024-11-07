import { LightningElement,api } from 'lwc';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import OWC_Yes from '@salesforce/label/c.OWC_Yes';
import OWC_action_label from '@salesforce/label/c.OWC_action_label';
import owc_not_paid_vacation from '@salesforce/label/c.owc_not_paid_vacation';
import owc_not_allowed_heat_rest from '@salesforce/label/c.owc_not_allowed_heat_rest';
import owc_not_paid_Holiday from '@salesforce/label/c.owc_not_paid_Holiday';
import OWC_No from '@salesforce/label/c.OWC_No';
import OWC_save_as_draft_label from '@salesforce/label/c.OWC_save_as_draft_label';
import OWC_cancel_button_label from '@salesforce/label/c.OWC_cancel_button_label';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Section delete Msg 
import OWC_section_delete_toastmsg from '@salesforce/label/c.OWC_section_delete_toastmsg';
import OWC_RecieveRestPeriodHelpText from  '@salesforce/label/c.OWC_RecieveRestPeriodHelpText';
import OWC_select_picklist_label from  '@salesforce/label/c.OWC_select_picklist_label';
// Import owcPreliminarySectionCmp Custom labels 
import OWC_claimant_upload_confirm_doc from '@salesforce/label/c.OWC_claimant_upload_confirm_doc';
import OWC_claimant_confirmation_label from '@salesforce/label/c.OWC_claimant_confirmation_label';
import OWC_preliminary_heading from '@salesforce/label/c.OWC_preliminary_question_heading';	
import OWC_middle_name from '@salesforce/label/c.OWC_middle_name';
import OWC_individual_rep_claimant_relationship from '@salesforce/label/c.OWC_individual_rep_claimant_relationship';
import OWC_individual_rep_phonetype from '@salesforce/label/c.OWC_individual_rep_phonetype';
import OWC_preliminary_wageclaim_submit from '@salesforce/label/c.OWC_preliminary_wageclaim_submit';
import OWC_preliminary_union_contract_covering from '@salesforce/label/c.OWC_preliminary_union_contract_covering';
import OWC_preliminary_upload_document from '@salesforce/label/c.OWC_preliminary_upload_document';
import OWC_url_address from '@salesforce/label/c.OWC_url_address';
import OWC_preliminary_coversheet_mailing_document from '@salesforce/label/c.OWC_preliminary_coversheet_mailing_document';
import OWC_filing_wage_claim from '@salesforce/label/c.OWC_filing_wage_claim';	
import OWC_preliminary_specify_one from '@salesforce/label/c.OWC_preliminary_specify_one';
import OWC_preliminary_covid19_claim from '@salesforce/label/c.OWC_preliminary_covid19_claim';
import OWC_preliminary_specify_other_reason from '@salesforce/label/c.OWC_preliminary_specify_other_reason';
import OWC_required_field_error_msg from '@salesforce/label/c.OWC_required_field_error_msg';
import OWC_date_format_label from '@salesforce/label/c.OWC_date_format_label';
import OWC_invalid_phone_msg from '@salesforce/label/c.OWC_invalid_phone_msg';
import OWC_invalid_email_msg from '@salesforce/label/c.OWC_invalid_email_msg';
import OWC_one_hourly_rate_text from '@salesforce/label/c.OWC_one_hourly_rate_text';
import OWC_different_hourly_rate_text from '@salesforce/label/c.OWC_different_hourly_rate_text';
import OWC_claimant_employee_cellphone_helptext from '@salesforce/label/c.OWC_claimant_employee_cellphone_helptext';
import OWC_claimant_employee_email_helptext from '@salesforce/label/c.OWC_claimant_employee_email_helptext';
import OWC_representative_advocatetype_helptext from '@salesforce/label/c.OWC_representative_advocatetype_helptext';
import OWC_invalid_zipcode_msg from '@salesforce/label/c.OWC_invalid_zipcode_msg';
import OWC_multiplefileupload_helptext from '@salesforce/label/c.OWC_multiplefileupload_helptext';
import OWC_preliminary_coversheet_helptext from '@salesforce/label/c.OWC_preliminary_coversheet_helptext';
import OWC_yourself_zipcode_helptext from '@salesforce/label/c.OWC_yourself_zipcode_helptext';	
import OWC_individual_rep_phonetype_helptext from '@salesforce/label/c.OWC_individual_rep_phonetype_helptext';
import OWC_urladdress_error_msg from '@salesforce/label/c.OWC_urladdress_error_msg';
import OWC_fileupload_success_toast_msg from '@salesforce/label/c.OWC_fileupload_success_toast_msg';
import OWC_multiple_file_delete_toast_msg from '@salesforce/label/c.OWC_multiple_file_delete_toast_msg';
import OWC_preliminary_office_locator_link from '@salesforce/label/c.OWC_preliminary_office_locator_link';
import OWC_preliminary_office_locator_dlse_wage_for from '@salesforce/label/c.OWC_preliminary_office_locator_dlse_wage_for';
// import custom labels for claimant and employee section
import OWC_claimant_employee_heading from '@salesforce/label/c.OWC_claimant_employee_heading';
import OWC_first_name from '@salesforce/label/c.OWC_first_name';
import OWC_last_name from '@salesforce/label/c.OWC_last_name';
import OWC_claimant_employee_home_phone from '@salesforce/label/c.OWC_claimant_employee_home_phone';
import OWC_CellPhone from '@salesforce/label/c.OWC_CellPhone';
import OWC_claimant_employee_cellphone_entered from '@salesforce/label/c.OWC_claimant_employee_cellphone_entered';
import OWC_claimant_employee_birthdate from '@salesforce/label/c.OWC_claimant_employee_birthdate';
import OWC_email from '@salesforce/label/c.OWC_email';
import OWC_street_address from '@salesforce/label/c.OWC_street_address';
import OWC_city from '@salesforce/label/c.OWC_city';
import OWC_state from '@salesforce/label/c.OWC_state';
import OWC_empinfo_Phone from '@salesforce/label/c.OWC_empinfo_Phone';
import OWC_zipcode from '@salesforce/label/c.OWC_zipcode';
// import custom labels for representative section
import OWC_representative_advocatetype from '@salesforce/label/c.OWC_representative_advocatetype';
import OWC_website from '@salesforce/label/c.OWC_website';
import OWC_lawfirm_representative_attorney from '@salesforce/label/c.OWC_lawfirm_representative_attorney';
import OWC_businessname from '@salesforce/label/c.OWC_businessname';
import OWC_learnmore_button from '@salesforce/label/c.OWC_learnmore_button';
import OWC_lawfirm_representative_requiredmsg from '@salesforce/label/c.OWC_lawfirm_representative_requiredmsg';
import OWC_claimant_employee_required_msg from '@salesforce/label/c.OWC_claimant_employee_required_msg';
// Import Language Assistance Section custom labels 
import OWC_language_assistance_heading from '@salesforce/label/c.OWC_language_assistance_heading';
import OWC_language_assistance_interpreter from '@salesforce/label/c.OWC_language_assistance_interpreter';
import OWC_language_assistance_preferred_language from '@salesforce/label/c.OWC_language_assistance_preferred_language';
import OWC_language_assistance_preferred_language_other from '@salesforce/label/c.OWC_language_assistance_preferred_language_other';
//Import Custom labels for Information Section
import OWC_industryinfo from '@salesforce/label/c.OWC_industryinfo';
import OWC_industryinfo_category from '@salesforce/label/c.OWC_industryinfo_category';
import OWC_industryinfo_specific from '@salesforce/label/c.OWC_industryinfo_specific';
import OWC_industryinfo_farmlaborer from '@salesforce/label/c.OWC_industryinfo_farmlaborer';
import OWC_industryinfo_farmlaborerhelptext from '@salesforce/label/c.OWC_industryinfo_farmlaborerhelptext';
import OWC_industryinfo_heatrecoveryperiods from '@salesforce/label/c.OWC_industryinfo_heatrecoveryperiods';
import OWC_industryinfo_heatrecoveryperiodshelptext from '@salesforce/label/c.OWC_industryinfo_heatrecoveryperiodshelptext';
import OWC_industryinfo_paidseparatelyforheatrecoveryperiods from '@salesforce/label/c.OWC_industryinfo_paidseparatelyforheatrecoveryperiods';
import OWC_industryinfo_request from '@salesforce/label/c.OWC_industryinfo_request';
import OWC_industryinfo_writtenrequest from '@salesforce/label/c.OWC_industryinfo_writtenrequest';
import OWC_industryinfo_employerstatement from '@salesforce/label/c.OWC_industryinfo_employerstatement';
import OWC_industryinfo_employerneverstatement from '@salesforce/label/c.OWC_industryinfo_employerneverstatement';
import OWC_industryinfo_typeofwork from '@salesforce/label/c.OWC_industryinfo_typeofwork';
import OWC_industryinfo_workhome from '@salesforce/label/c.OWC_industryinfo_workhome';
import OWC_industryinfo_registerednurse from '@salesforce/label/c.OWC_industryinfo_registerednurse';
import OWC_industryinfo_homeworked from '@salesforce/label/c.OWC_industryinfo_homeworked';
import OWC_industryinfo_homeagency from '@salesforce/label/c.OWC_industryinfo_homeagency';
import OWC_industryinfo_residential from '@salesforce/label/c.OWC_industryinfo_residential';
import OWC_industryinfo_duties from '@salesforce/label/c.OWC_industryinfo_duties';
import OWC_industryinfo_domesticworkerhelptext from '@salesforce/label/c.OWC_industryinfo_domesticworkerhelptext';
import OWC_industryinfo_personalattendenthelptext from '@salesforce/label/c.OWC_industryinfo_personalattendenthelptext';
import OWC_industryinfo_facilitypersonalattendenthelptext from '@salesforce/label/c.OWC_industryinfo_facilitypersonalattendenthelptext';
import OWC_industryinfo_publichousekeepinghelptext from '@salesforce/label/c.OWC_industryinfo_publichousekeepinghelptext';
import OWC_empinfo_BusinessPhone from '@salesforce/label/c.OWC_empinfo_BusinessPhone';
import OWC_empinfo_VehicleLicense from '@salesforce/label/c.OWC_empinfo_VehicleLicense';
import OWC_industryinfo_businessname from '@salesforce/label/c.OWC_industryinfo_businessname';
import OWC_industryinfo_jobduties from '@salesforce/label/c.OWC_industryinfo_jobduties';
import OWC_label_info_heading from '@salesforce/label/c.OWC_label_info_heading';
import OWC_successoraddinfo_heading from '@salesforce/label/c.OWC_successoraddinfo_heading';
import OWC_hepttext_header from '@salesforce/label/c.OWC_hepttext_header';
import OWC_addanotherlabel_button from '@salesforce/label/c.OWC_addanotherlabel_button';
import OWC_addanothersuccessor_buttton from '@salesforce/label/c.OWC_addanothersuccessor_buttton';
import OWC_added_section_label from '@salesforce/label/c.OWC_added_section_label';
import OWC_ordinalsuffix_nd from '@salesforce/label/c.OWC_ordinalsuffix_nd';
import OWC_ordinalsuffix_rd from '@salesforce/label/c.OWC_ordinalsuffix_rd';
import OWC_ordinalsuffix_th from '@salesforce/label/c.OWC_ordinalsuffix_th';
import OWC_ordinalsuffix_st from '@salesforce/label/c.OWC_ordinalsuffix_st';
import OWC_farmlabor_statementprovideddate_error_msg from '@salesforce/label/c.OWC_farmlabor_statementprovideddate_error_msg';
import OWC_farmlabor_writtendate_error_msg from '@salesforce/label/c.OWC_farmlabor_writtendate_error_msg';
import OWC_pastdate_error_msg from '@salesforce/label/c.OWC_pastdate_error_msg';
import OWC_anotherlabel_heading from '@salesforce/label/c.OWC_anotherlabel_heading';
import OWC_anothersuccessor_heading from '@salesforce/label/c.OWC_anothersuccessor_heading';
import OWC_deleteSection_msg from '@salesforce/label/c.OWC_deleteSection_msg';

//Import onlineWageClaimContainerCmp custom label
import OWC_previous_button from '@salesforce/label/c.OWC_previous_button';
import OWC_continue_button from '@salesforce/label/c.OWC_continue_button';
import OWC_finish_button from '@salesforce/label/c.OWC_finish_button';
// Import owcCertificationAndAuthorizationCmp Custom Label
import OWC_certification_section_heading from '@salesforce/label/c.OWC_certification_section_heading';
import OWC_certification_additional_claim_documents from '@salesforce/label/c.OWC_certification_additional_claim_documents';
import OWC_certification_authorization_to_release from '@salesforce/label/c.OWC_certification_authorization_to_release';
import OWC_authorised_claimant_date from '@salesforce/label/c.OWC_authorised_claimant_date';
import OWC_authorised_claimant_name from '@salesforce/label/c.OWC_authorised_claimant_name';
import OWC_edit_buttton_label from '@salesforce/label/c.OWC_edit_buttton_label';
import OWC_preview_button_label from '@salesforce/label/c.OWC_preview_button_label';
// Import owcPaymentOfWagesCmp custom label 
import OWC_paymentofwages_per_label from '@salesforce/label/c.OWC_paymentofwages_per_label';
import OWC_PaymentOfWages from '@salesforce/label/c.OWC_PaymentOfWages';
import OWC_SelectPayment from '@salesforce/label/c.OWC_SelectPayment';
import OWC_HourlyEmplyee from '@salesforce/label/c.OWC_HourlyEmplyee';
import OWC_PaidPerHour from '@salesforce/label/c.OWC_PaidPerHour';
import OWC_PromisedPerHour from '@salesforce/label/c.OWC_PromisedPerHour';
import OWC_ProvideDifferentRates from '@salesforce/label/c.OWC_ProvideDifferentRates';
import OWC_PaidFor from '@salesforce/label/c.OWC_PaidFor';
import OWC_PromisedFor from '@salesforce/label/c.OWC_PromisedFor';
import OWC_FixedAmountWages from '@salesforce/label/c.OWC_FixedAmountWages';
import OWC_Paid from '@salesforce/label/c.OWC_Paid';
import OWC_Amount from '@salesforce/label/c.OWC_Amount';
import OWC_Frequency from '@salesforce/label/c.OWC_Frequency';
import OWC_Promised from '@salesforce/label/c.OWC_Promised';
import OWC_WrittenCommissionAgreement from '@salesforce/label/c.OWC_WrittenCommissionAgreement';
import OWC_UploadAgreementFunction from '@salesforce/label/c.OWC_UploadAgreementFunction';
import OWC_ProvidePriceRate from '@salesforce/label/c.OWC_ProvidePriceRate';
import OWC_PaidMinimumWage from '@salesforce/label/c.OWC_PaidMinimumWage';
import OWC_RecieveRestPeriod from '@salesforce/label/c.OWC_RecieveRestPeriod';
import OWC_FollowUp_PaidSeparately from '@salesforce/label/c.OWC_FollowUp_PaidSeparately';
import OWC_ByCheck from '@salesforce/label/c.OWC_ByCheck';
import OWC_ByCash from '@salesforce/label/c.OWC_ByCash';
import OWC_ByCheckByCash from '@salesforce/label/c.OWC_ByCheckByCash';
import OWC_Other from '@salesforce/label/c.OWC_Other';
import OWC_notPaid from '@salesforce/label/c.OWC_notPaid';
import OWC_NotSufficientFundHelpText from '@salesforce/label/c.OWC_NotSufficientFundHelpText';
import OWC_ProvideCommissionRate from '@salesforce/label/c.OWC_ProvideCommissionRate';
import OWC_ContractionTrade_Helptext from '@salesforce/label/c.OWC_ContractionTrade_Helptext';
import OWC_UploadDocument_Helptext from '@salesforce/label/c.OWC_UploadDocument_Helptext';
import OWC_Per from '@salesforce/label/c.OWC_Per';
import OWC_paymentofwages_required_date_errormsg from '@salesforce/label/c.OWC_paymentofwages_required_date_errormsg';
import Owc_pieceRateTotalEarned from '@salesforce/label/c.Owc_pieceRateTotalEarned'
import Owc_pieceRateTotalPaid from '@salesforce/label/c.Owc_pieceRateTotalPaid'
import OWC_pieceRateHintText from '@salesforce/label/c.OWC_pieceRateHintText'
import owc_selectOne_field from '@salesforce/label/c.owc_selectOne_field'
//Import owcHoursYouTypicallyWorkedCmp custom label  
import OWC_hours_typically_worked_work_missed_reason from '@salesforce/label/c.OWC_hours_typically_worked_work_missed_reason';
import OWC_unpaid_work_hours from '@salesforce/label/c.OWC_unpaid_work_hours';
import OWC_hours_typically_worked_heading from '@salesforce/label/c.OWC_hours_typically_worked_heading';
import OWC_typicallyworked_selectone from '@salesforce/label/c.OWC_typicallyworked_selectone';	
import OWC_typicallyworked_sameworkinghours from '@salesforce/label/c.OWC_typicallyworked_sameworkinghours';
import OWC_typicallyworked_perweek from '@salesforce/label/c.OWC_typicallyworked_perweek';	
import OWC_typically_worked_no_of_saturday from '@salesforce/label/c.OWC_typically_worked_no_of_saturday';
import OWC_typically_worked_no_of_sunday from '@salesforce/label/c.OWC_typically_worked_no_of_sunday';
import OWC_typically_worked_restperiod from '@salesforce/label/c.OWC_typically_worked_restperiod';
import OWC_typically_worked_explain_restperiod from '@salesforce/label/c.OWC_typically_worked_explain_restperiod';
import OWC_typically_worked_mealperiod from '@salesforce/label/c.OWC_typically_worked_mealperiod';
import OWC_typically_worked_mealperiod_explain from '@salesforce/label/c.OWC_typically_worked_mealperiod_explain';
import OWC_typically_worked_missed from '@salesforce/label/c.OWC_typically_worked_missed';
import OWC_typically_worked_holiday_selection from '@salesforce/label/c.OWC_typically_worked_holiday_selection';
import OWC_typically_worked_newyear_holiday from '@salesforce/label/c.OWC_typically_worked_newyear_holiday';	
import OWC_typically_worked_othertext from '@salesforce/label/c.OWC_typically_worked_othertext';
import OWC_typically_worked_upload_form from '@salesforce/label/c.OWC_typically_worked_upload_form';
import OWC_typically_worked_vacation_time_claims from '@salesforce/label/c.OWC_typically_worked_vacation_time_claims';
import OWC_typically_worked_unreimbursed_business from '@salesforce/label/c.OWC_typically_worked_unreimbursed_business';
import OWC_typically_worked_unreimbursed_business_helptext from '@salesforce/label/c.OWC_typically_worked_unreimbursed_business_helptext';
import OWC_typically_working_hours_same from '@salesforce/label/c.OWC_typically_working_hours_same';
import OWC_hours_typically_worked_dlseform55_helptext from '@salesforce/label/c.OWC_hours_typically_worked_dlseform55_helptext';
import OWC_typically_worked_vacationtimeclaims_helptext from '@salesforce/label/c.OWC_typically_worked_vacationtimeclaims_helptext';
//Employement status and final wages
import OWC_date_placeholder from '@salesforce/label/c.OWC_date_placeholder';
import owc_dischargedDateHelpText from '@salesforce/label/c.owc_dischargedDateHelpText';

import OWC_EmpStatusRequiredMsg from '@salesforce/label/c.OWC_EmpStatusRequiredMsg';
import OWC_successorinfo_HireDate from '@salesforce/label/c.OWC_successorinfo_HireDate';
import OWC_Employment_Status_and_Final_Wages from '@salesforce/label/c.OWC_Employment_Status_and_Final_Wages';
import OWC_Name_of_person_who_hired_you from '@salesforce/label/c.OWC_Name_of_person_who_hired_you';
import OWC_How_were_your_wages_paid from '@salesforce/label/c.OWC_How_were_your_wages_paid';
import OWC_Did_any_of_the_paychecks_Bounce from '@salesforce/label/c.OWC_Did_any_of_the_paychecks_Bounce';
import OWC_Explanation from '@salesforce/label/c.OWC_Explanation';
import OWC_ReceiveItemizedWages from '@salesforce/label/c.OWC_ReceiveItemizedWages';
import OWC_employee_additional_whopaidyou from '@salesforce/label/c.OWC_employee_additional_whopaidyou';
import OWC_WorkingForIdentifiedEmployer from '@salesforce/label/c.OWC_WorkingForIdentifiedEmployer';
import OWC_CompleteAtLeastOne from '@salesforce/label/c.OWC_CompleteAtLeastOne';
import OWC_Quit_Date from '@salesforce/label/c.OWC_Quit_Date';
import OWC_notice_before_quitting from '@salesforce/label/c.OWC_notice_before_quitting';
import OWC_RecievedFinalPayment from '@salesforce/label/c.OWC_RecievedFinalPayment';
import OWC_DischargedDate from '@salesforce/label/c.OWC_DischargedDate';
import OWC_PersonWhoDischargeYou from '@salesforce/label/c.OWC_PersonWhoDischargeYou';
import OWC_employement_status_quitdate_heading from '@salesforce/label/c.OWC_employement_status_quitdate_heading';
//import owcPaidTypeMetaData from '@salesforce/apex/OWCEmpStatusAndFinalWagesController.fetchPaidTypeMetaData';
import OWC_employement_status_dischargeddate_heading from '@salesforce/label/c.OWC_employement_status_dischargeddate_heading';
import OWC_employement_status_othersection_heading from '@salesforce/label/c.OWC_employement_status_othersection_heading';
//Owc WorkWeek and WorkDay
import OWC_WorkweekAndWorkday_Heading from '@salesforce/label/c.OWC_WorkweekAndWorkday_Heading';
import OWC_WorkweekAndWorkday_EmpFollowSatToSun from '@salesforce/label/c.OWC_WorkweekAndWorkday_EmpFollowSatToSun';
import OWC_WorkweekAndWorkday_EmpDefinedWorkweek from '@salesforce/label/c.OWC_WorkweekAndWorkday_EmpDefinedWorkweek';
import OWC_WorkweekAndWorkday_EmpFollowMidnightToMidnight from '@salesforce/label/c.OWC_WorkweekAndWorkday_EmpFollowMidnightToMidnight';
import OWC_WorkweekAndWorkday_ProvideEmpDefWorkday from '@salesforce/label/c.OWC_WorkweekAndWorkday_ProvideEmpDefWorkday';
import OWC_WorkweekAndWorkday_BegDate from '@salesforce/label/c.OWC_WorkweekAndWorkday_BegDate';
import OWC_WorkweekAndWorkday_EndDate from '@salesforce/label/c.OWC_WorkweekAndWorkday_EndDate';
// Import owcWageDeficienciesCmp Custom Labels
import OWC_wage_deficiencies_heading from '@salesforce/label/c.OWC_wage_deficiencies_heading';
import OWC_wage_deficiencies_claim_timeperiod from '@salesforce/label/c.OWC_wage_deficiencies_claim_timeperiod';
import OWC_wage_deficiencies_firstDate from '@salesforce/label/c.OWC_wage_deficiencies_firstDate';
import OWC_wage_deficiencies_lastdate from '@salesforce/label/c.OWC_wage_deficiencies_lastdate';
import OWC_wage_deficiencies_your_claim from '@salesforce/label/c.OWC_wage_deficiencies_your_claim';
import OWC_wage_deficiencies_notpaid_for_worked from '@salesforce/label/c.OWC_wage_deficiencies_notpaid_for_worked';
import OWC_wage_deficiencies_paid_minimum_wages from '@salesforce/label/c.OWC_wage_deficiencies_paid_minimum_wages';
import OWC_wage_deficiencies_regular_paid from '@salesforce/label/c.OWC_wage_deficiencies_regular_paid';
import OWC_wage_deficiencies_promised_onerate from '@salesforce/label/c.OWC_wage_deficiencies_promised_onerate';
import OWC_wage_deficiencies_sickleave_paid from '@salesforce/label/c.OWC_wage_deficiencies_sickleave_paid';
import OWC_wage_deficiencies_bathroom_break from '@salesforce/label/c.OWC_wage_deficiencies_bathroom_break';
import OWC_wage_deficiencies_mealbreak from '@salesforce/label/c.OWC_wage_deficiencies_mealbreak';
import OWC_wage_deficiencies_severancepay from '@salesforce/label/c.OWC_wage_deficiencies_severancepay';
import OWC_wage_deficiencies_sharetips from '@salesforce/label/c.OWC_wage_deficiencies_sharetips';
import OWC_wage_deficiencies_payment_denied from '@salesforce/label/c.OWC_wage_deficiencies_payment_denied';
import OWC_wage_deficiencies_denied_payment from '@salesforce/label/c.OWC_wage_deficiencies_denied_payment';
import OWC_wage_deficiencies_paycheck_deduction from '@salesforce/label/c.OWC_wage_deficiencies_paycheck_deduction';
import OWC_wage_deficiencies_payroll_information from '@salesforce/label/c.OWC_wage_deficiencies_payroll_information';
import OWC_wage_deficiencies_personnel_file from '@salesforce/label/c.OWC_wage_deficiencies_personnel_file';
import OWC_wage_deficiencies_paystub_payment from '@salesforce/label/c.OWC_wage_deficiencies_paystub_payment';
import OWC_wage_deficiencies_severancepay_offered from '@salesforce/label/c.OWC_wage_deficiencies_severancepay_offered';
import OWC_wage_deficiencies_pooltips from '@salesforce/label/c.OWC_wage_deficiencies_pooltips';
import OWC_wage_deficiencies_receive_tips from '@salesforce/label/c.OWC_wage_deficiencies_receive_tips';
import OWC_wage_deficiencies_receipts_docs from '@salesforce/label/c.OWC_wage_deficiencies_receipts_docs';
import OWC_wage_deficiencies_mileage_log from '@salesforce/label/c.OWC_wage_deficiencies_mileage_log';
import OWC_wage_deficiencies_mileage_reimbursement_rate from '@salesforce/label/c.OWC_wage_deficiencies_mileage_reimbursement_rate';
import OWC_wage_deficiencies_make_demand from '@salesforce/label/c.OWC_wage_deficiencies_make_demand';
import OWC_wage_deficiencies_employer_response from '@salesforce/label/c.OWC_wage_deficiencies_employer_response';
import OWC_First_date_error_msg from '@salesforce/label/c.OWC_First_date_error_msg';
import OWC_Last_date_error_msg from '@salesforce/label/c.OWC_Last_date_error_msg';
import OWC_Date_Of_Hire from '@salesforce/label/c.OWC_Date_Of_Hire';
import OWC_Date_Of_Hire_helptext from '@salesforce/label/c.OWC_Date_Of_Hire_helptext';
import Owc_Was_Check_Replaced from '@salesforce/label/c.Owc_Was_Check_Replaced';
import Owc_Was_Check_ReplacedDate from '@salesforce/label/c.Owc_Was_Check_ReplacedDate';
import Owc_Date from '@salesforce/label/c.Owc_Date';
import Owc_Did_Receive_Itemized_Wage from '@salesforce/label/c.Owc_Did_Receive_Itemized_Wage';
import Owc_Did_Receive_Itemized_Wage_HelpText from '@salesforce/label/c.Owc_Did_Receive_Itemized_Wage_HelpText';
import OWC_EnterValidAmount from '@salesforce/label/c.OWC_EnterValidAmount';
import OWC_empinfo_ClaimField from '@salesforce/label/c.OWC_empinfo_ClaimField';
import OWC_AddEmployerInformation from '@salesforce/label/c.OWC_AddEmployerInformation';
import OWC_anotheremployer_heading from '@salesforce/label/c.OWC_anotheremployer_heading';
import OWC_payement_commission_agreement_helptext from '@salesforce/label/c.OWC_payement_commission_agreement_helptext';
import OWC_fixed_amount_wage_paid from '@salesforce/label/c.OWC_fixed_amount_wage_paid';
import OWC_fixed_amount_wage_promised from '@salesforce/label/c.OWC_fixed_amount_wage_promised';
import OWC_payment_received_final_wage from '@salesforce/label/c.OWC_payment_received_final_wage';
import OWC_AdditionalRates from '@salesforce/label/c.OWC_AdditionalRates';
import OWC_piecerate_label from '@salesforce/label/c.OWC_piecerate_label';
import OWC_piecerate_label_permile from '@salesforce/label/c.OWC_piecerate_label_permile';
import OWC_checkbox_group_error_msg from '@salesforce/label/c.OWC_checkbox_group_error_msg';
import OWC_invalid_claimant_birthdate_error_msg from '@salesforce/label/c.OWC_invalid_claimant_birthdate_error_msg';
import OWC_lawfirm_representative_PhoneNumberEmailrequiredmsg from '@salesforce/label/c.OWC_lawfirm_representative_PhoneNumberEmailrequiredmsg';
import OWC_begdate_error_msg from '@salesforce/label/c.OWC_begdate_error_msg'
import OWC_enddate_error_msg from '@salesforce/label/c.OWC_enddate_error_msg'
import Owc_perHour from '@salesforce/label/c.Owc_perHour';
import Owc_Beginning  from '@salesforce/label/c.Owc_Beginning';
import Owc_Ending from '@salesforce/label/c.Owc_Ending';
import Owc_forActivity from '@salesforce/label/c.Owc_forActivity'
import Owc_ratePaid from '@salesforce/label/c.Owc_ratePaid'
import Owc_ratePromised from '@salesforce/label/c.Owc_ratePromised'
import Owc_perUnit from '@salesforce/label/c.Owc_perUnit'
import Owc_paidAtleasrMin from '@salesforce/label/c.Owc_paidAtleasrMin'
import Owc_lowestAmntPaid from '@salesforce/label/c.Owc_lowestAmntPaid'
import Owc_highestAmntPaid from '@salesforce/label/c.Owc_highestAmntPaid'
import Owc_Additional from '@salesforce/label/c.Owc_Additional'
import Owc_oneHourlyAdditionalText from '@salesforce/label/c.Owc_oneHourlyAdditionalText'
import Owc_eachPayAdditionalText from '@salesforce/label/c.Owc_eachPayAdditionalText'
import Owc_noOfUnits from '@salesforce/label/c.Owc_noOfUnits'
import Owc_pieceOfRateText from '@salesforce/label/c.Owc_pieceOfRateText'
import Owc_commissionPayRate from '@salesforce/label/c.Owc_commissionPayRate'
import Owc_commissionPayEarned from '@salesforce/label/c.Owc_commissionPayEarned'
import OWC_typically_worked_explain_mealperiod from '@salesforce/label/c.OWC_typically_worked_explain_mealperiod'
import OWC_WhyWorkMissed from '@salesforce/label/c.OWC_WhyWorkMissed'
import OWC_DaysOfWorkMissed from '@salesforce/label/c.OWC_DaysOfWorkMissed'
import OWC_available_sick_leave from '@salesforce/label/c.OWC_available_sick_leave'
import OWC_miss_for_this_reason from '@salesforce/label/c.OWC_miss_for_this_reason'
// import custom labels for Claim Filed Against (Employer Information) section
import OWC_employee_additional_bank from '@salesforce/label/c.OWC_employee_additional_bank'
import OWC_employee_additional_personinchargename from '@salesforce/label/c.OWC_employee_additional_personinchargename'
import OWC_lawfirm_representative_businessname from '@salesforce/label/c.OWC_lawfirm_representative_businessname'
import OWC_empinfo_EmpBusinessType from '@salesforce/label/c.OWC_empinfo_EmpBusinessType'
import OWC_empinfo_explain from '@salesforce/label/c.OWC_empinfo_explain'
import OWC_empinfo_ConstructionTrades from '@salesforce/label/c.OWC_empinfo_ConstructionTrades'
import OWC_empinfo_Uploaddoc from '@salesforce/label/c.OWC_empinfo_Uploaddoc'
import OWC_empinfo_Addimage from '@salesforce/label/c.OWC_empinfo_Addimage'
import OWC_AddImage_HelpText from '@salesforce/label/c.OWC_AddImage_HelpText'
import OWC_Additional_Info from '@salesforce/label/c.OWC_Additional_Info'
import OWC_NameOfPersonInChage from '@salesforce/label/c.OWC_NameOfPersonInChage'
import OWC_EnterName_HelpText from '@salesforce/label/c.OWC_EnterName_HelpText'
import OWC_JobTitle_PersonInCharge from '@salesforce/label/c.OWC_JobTitle_PersonInCharge'
import OWC_WhoPaidYou from '@salesforce/label/c.OWC_WhoPaidYou'
import OWC_DifferentPerson from '@salesforce/label/c.OWC_DifferentPerson'
import OWC_WorkRecord from '@salesforce/label/c.OWC_WorkRecord'
import OWC_SignTimeCard from '@salesforce/label/c.OWC_SignTimeCard'
import OWC_SomeoneElseName from '@salesforce/label/c.OWC_SomeoneElseName'
import OWC_TotalEmployees from '@salesforce/label/c.OWC_TotalEmployees'
import OWC_BestGuess_HelpText from '@salesforce/label/c.OWC_BestGuess_HelpText'
import OWC_EmpBusiness from '@salesforce/label/c.OWC_EmpBusiness'
import OWC_CompEmployed from '@salesforce/label/c.OWC_CompEmployed'
import OWC_ChangeOrSold from '@salesforce/label/c.OWC_ChangeOrSold'
import OWC_Bankruptcy from '@salesforce/label/c.OWC_Bankruptcy'
import OWC_ShowTost from '@salesforce/label/c.OWC_ShowTost'
import OWC_employee_reuired_field_error_msg from '@salesforce/label/c.OWC_employee_reuired_field_error_msg'
import OWC_empinfo_empName from '@salesforce/label/c.OWC_empinfo_empName'
import OWC_employer_delete_button from '@salesforce/label/c.OWC_employer_delete_button'
import OWC_invalid_url_msg from '@salesforce/label/c.OWC_invalid_url_msg'
import owc_Production_Bonus from '@salesforce/label/c.owc_Production_Bonus'
import owc_reported_to_work from '@salesforce/label/c.owc_reported_to_work'
import OWC_preliminary_local_office_mail_label from '@salesforce/label/c.OWC_preliminary_local_office_mail_label'
// import custom labels for Claim Filed Against (Employer Information) section
import OWC_individual_required_helptext from '@salesforce/label/c.OWC_individual_required_helptext';
import OWC_union_contract_options_label from '@salesforce/label/c.OWC_union_contract_options_label';
import OWC_employee_additional_bank_incharge_name from '@salesforce/label/c.OWC_employee_additional_bank_incharge_name';
import OWC_employee_additional_bank_claimrelated_action from '@salesforce/label/c.OWC_employee_additional_bank_claimrelated_action';
import OWC_employee_additional_employeer_changed_name from '@salesforce/label/c.OWC_employee_additional_employeer_changed_name';
import OWC_employer_other_name_label from '@salesforce/label/c.OWC_employer_other_name_label';
import OWC_different_hourly_additonal_help_text from '@salesforce/label/c.OWC_different_hourly_additonal_help_text';
import OWC_save_button_label from '@salesforce/label/c.OWC_save_button_label';
import OWC_industry_paid_breaks from '@salesforce/label/c.OWC_industry_paid_breaks';
import OWC_one_hourly_rate_label from '@salesforce/label/c.OWC_one_hourly_rate_label';
import OWC_different_hourly_rate_label from '@salesforce/label/c.OWC_different_hourly_rate_label';
import OWC_salary_rate_label from '@salesforce/label/c.OWC_salary_rate_label';
import OWC_commission_rate_label from '@salesforce/label/c.OWC_commission_rate_label';
import OWC_piece_rate_label from '@salesforce/label/c.OWC_piece_rate_label';
import OWC_address_proceed from '@salesforce/label/c.OWC_address_proceed';
import OWC_usps_continue_address from '@salesforce/label/c.OWC_usps_continue_address';
import OWC_Click_here from '@salesforce/label/c.OWC_Click_here';
import OWC_wages_paid_on_the_pay_day from '@salesforce/label/c.OWC_wages_paid_on_the_pay_day';
import OWC_Claimant_Confirmation_alert_message from '@salesforce/label/c.OWC_Claimant_Confirmation_alert_message';
import OWC_online_draft_label from '@salesforce/label/c.OWC_online_draft_label';
import OWC_draft_number_label from '@salesforce/label/c.OWC_draft_number_label';
import OWC_no_record_error from '@salesforce/label/c.OWC_no_record_error';
import OWC_submitted_claim_label from '@salesforce/label/c.OWC_submitted_claim_label';
import OWC_submitted_case_label from '@salesforce/label/c.OWC_submitted_case_label';
import OWC_case_status_label from '@salesforce/label/c.OWC_case_status_label';
import OWC_advocate_assist_label from '@salesforce/label/c.OWC_advocate_assist_label';
import OWC_receipt_summary_label from '@salesforce/label/c.OWC_receipt_summary_label';
import OWC_success_label from '@salesforce/label/c.OWC_success_label';
import OWC_delete_button_label from '@salesforce/label/c.OWC_delete_button_label';
import OWC_label_draft_create_msg from '@salesforce/label/c.OWC_label_draft_create_msg';
import OWC_draft_update_toast_msg from '@salesforce/label/c.OWC_draft_update_toast_msg';
import OWC_usps_response_error_header from '@salesforce/label/c.OWC_usps_response_error_header';
import OWC_suggested_response_label from '@salesforce/label/c.OWC_suggested_response_label';
import OWC_error_response_label from '@salesforce/label/c.OWC_error_response_label';
import OWC_another_deficiencies_claim_button from '@salesforce/label/c.OWC_another_deficiencies_claim_button';
import OWC_another_deficiencies_claim_question_label from '@salesforce/label/c.OWC_another_deficiencies_claim_question_label';
import OWC_another_wage_deficiencies_label from '@salesforce/label/c.OWC_another_wage_deficiencies_label';
import OWC_delete_claim_button from '@salesforce/label/c.OWC_delete_claim_button';
import OWC_another_wage_claim_label from '@salesforce/label/c.OWC_another_wage_claim_label';
import OWC_repeat_claim from '@salesforce/label/c.OWC_repeat_claim';
import OWC_another_claim_label from '@salesforce/label/c.OWC_another_claim_label';
import OWC_overtime_pay_claim_heading_label from '@salesforce/label/c.OWC_overtime_pay_claim_heading_label';
import OWC_overtime_pay_claim_label from '@salesforce/label/c.OWC_overtime_pay_claim_label';
import OWC_overtime_another_pay_claim_heading from '@salesforce/label/c.OWC_overtime_another_pay_claim_heading';
import OWC_sick_leave_label from '@salesforce/label/c.OWC_sick_leave_label';
import OWC_sick_leave_claim_heading_label from '@salesforce/label/c.OWC_sick_leave_claim_heading_label';
import OWC_another_sick_leave_claim_heading from '@salesforce/label/c.OWC_another_sick_leave_claim_heading';
import OWC_another_rest_break_claim_label from '@salesforce/label/c.OWC_another_rest_break_claim_label';
import OWC_rest_break_claim_heading_label from '@salesforce/label/c.OWC_rest_break_claim_heading_label';
import OWC_another_rest_break_claim_heading_label from '@salesforce/label/c.OWC_another_rest_break_claim_heading_label';
import OWC_meal_break_claim_label from '@salesforce/label/c.OWC_meal_break_claim_label';
import OWC_meal_break_claim_heading from '@salesforce/label/c.OWC_meal_break_claim_heading';
import OWC_another_meal_break_claim_heading_label from '@salesforce/label/c.OWC_another_meal_break_claim_heading_label';
import OWC_heat_rest_claim_label from '@salesforce/label/c.OWC_heat_rest_claim_label';
import OWC_heat_rest_claim_heading_label from '@salesforce/label/c.OWC_heat_rest_claim_heading_label';
import OWC_another_rest_claim_heading_label from '@salesforce/label/c.OWC_another_rest_claim_heading_label';
import OWC_milega_claim_label from '@salesforce/label/c.OWC_milega_claim_label';
import OWC_milega_expense_claim from '@salesforce/label/c.OWC_milega_expense_claim';
import OWC_another_milega_expense_claim_label from '@salesforce/label/c.OWC_another_milega_expense_claim_label';
import OWC_insufficient_fund_claim_label from '@salesforce/label/c.OWC_insufficient_fund_claim_label';
import OWC_insufficient_fund_claim_heading from '@salesforce/label/c.OWC_insufficient_fund_claim_heading';
import OWC_another_insufficient_fund_claim_heading from '@salesforce/label/c.OWC_another_insufficient_fund_claim_heading';
import OWC_reporting_time_claim_label from '@salesforce/label/c.OWC_reporting_time_claim_label';
import OWC_reporting_time_pay_claim_heading from '@salesforce/label/c.OWC_reporting_time_pay_claim_heading';
import OWC_another_pay_time_claim_heading from '@salesforce/label/c.OWC_another_pay_time_claim_heading';
import OWC_claim_double_time_label from '@salesforce/label/c.OWC_claim_double_time_label';
import OWC_yourself_submit_label from '@salesforce/label/c.OWC_yourself_submit_label';
import OWC_time_card_name from '@salesforce/label/c.OWC_time_card_name';
import OWC_OnlineWageClaimLiPart from '@salesforce/label/c.OWC_OnlineWageClaimLiPart';
import OWC_lawfirm_custom_msg from '@salesforce/label/c.OWC_lawfirm_custom_msg';
import OWC_employer_name_changed_helptext from '@salesforce/label/c.OWC_employer_name_changed_helptext';
import OWC_hourlyrate_help_button_text from '@salesforce/label/c.OWC_hourlyrate_help_button_text';
import OWC_regular_wages_claim_heading from '@salesforce/label/c.OWC_regular_wages_claim_heading';
import OWC_Cell_Phone_Number from '@salesforce/label/c.OWC_Cell_Phone_Number';
import OWC_Submit from '@salesforce/label/c.OWC_Submit';
import OWC_Create_Account from '@salesforce/label/c.OWC_Create_Account';

import OWC_Confirm_Email from '@salesforce/label/c.OWC_Confirm_Email';
import OWC_Email_Not_Match from '@salesforce/label/c.OWC_Email_Not_Match';
import OWC_Enter_Valid_Phone from '@salesforce/label/c.OWC_Enter_Valid_Phone';
import OWC_Enter_Valid_Email from '@salesforce/label/c.OWC_Enter_Valid_Email';
import OWC_Required_Field from '@salesforce/label/c.OWC_Required_Field';
import OWC_date_filed from '@salesforce/label/c.OWC_date_filed';
import OWC_signed_confirmation from '@salesforce/label/c.OWC_signed_confirmation';
import OWC_additional_responsible_person from '@salesforce/label/c.OWC_additional_responsible_person';
import OWC_claim_information from '@salesforce/label/c.OWC_claim_information';
import OWC_delete_responsible_person from '@salesforce/label/c.OWC_delete_responsible_person';
import OWC_paystub_sick_leave from '@salesforce/label/c.OWC_paystub_sick_leave';
import OWC_regular_wage_add_button from '@salesforce/label/c.OWC_regular_wage_add_button';
import OWC_another_regular_wage_button from '@salesforce/label/c.OWC_another_regular_wage_button';
import OWC_other_claims_label from '@salesforce/label/c.OWC_other_claims_label';
import OWC_second_meal from '@salesforce/label/c.OWC_second_meal';
import OWC_first_meal from '@salesforce/label/c.OWC_first_meal';
import OWC_start_time from '@salesforce/label/c.OWC_start_time';
import OWC_first_meal_time from '@salesforce/label/c.OWC_first_meal_time';
import OWC_second_meal_time from '@salesforce/label/c.OWC_second_meal_time';
import OWC_end_time from '@salesforce/label/c.OWC_end_time';
import OWC_break_time from '@salesforce/label/c.OWC_break_time';
import 	OWC_shift_end_follow_day from '@salesforce/label/c.OWC_shift_end_follow_day';
import OWC_total_work_hours from '@salesforce/label/c.OWC_total_work_hours';
import OWC_one_hourly_rate from '@salesforce/label/c.OWC_one_hourly_rate';
import OWC_salary_rate from '@salesforce/label/c.OWC_salary_rate';
import OWC_total_owed_label from '@salesforce/label/c.OWC_total_owed_label';
import OWC_different_hourly_rate from '@salesforce/label/c.OWC_different_hourly_rate';
import OWC_single_piece_rate from '@salesforce/label/c.OWC_single_piece_rate';
import OWC_multiple_piece_rate from '@salesforce/label/c.OWC_multiple_piece_rate';
import OWC_unknown_piece_rate from '@salesforce/label/c.OWC_unknown_piece_rate';
import OWC_commission_agreement from '@salesforce/label/c.OWC_commission_agreement';
import OWC_commision_summary_v1 from '@salesforce/label/c.OWC_commision_summary_v1';
import OWC_written_statement_help_msg from '@salesforce/label/c.OWC_written_statement_help_msg';
import OWC_written_statement from '@salesforce/label/c.OWC_written_statement';
import OWC_late_payroll from '@salesforce/label/c.OWC_late_payroll';
import OWC_insufficient_msg from '@salesforce/label/c.OWC_insufficient_msg';
import OWC_late_payroll_msg from '@salesforce/label/c.OWC_late_payroll_msg';
import OWC_payroll_beg_date from '@salesforce/label/c.OWC_payroll_beg_date';
import OWC_payroll_end_date from '@salesforce/label/c.OWC_payroll_end_date';
import OWC_not_promised_holiday_pay from '@salesforce/label/c.OWC_not_promised_holiday_pay';
import OWC_one_calendar_year_span from '@salesforce/label/c.OWC_one_calendar_year_span';
import OWC_sick_leave_claim from '@salesforce/label/c.OWC_sick_leave_claim';
import OWC_waiting_time from '@salesforce/label/c.OWC_waiting_time';
import OWC_waiting_time_msg from '@salesforce/label/c.OWC_waiting_time_msg';
import OWC_total_owed_helptext from '@salesforce/label/c.OWC_total_owed_helptext';
import OWC_total_owed_salary_helptext from '@salesforce/label/c.OWC_total_owed_salary_helptext';
import OWC_total_salary_owed from '@salesforce/label/c.OWC_total_salary_owed';
import OWC_different_owed_label from '@salesforce/label/c.OWC_different_owed_label';
import OWC_different_owed_help_msg from '@salesforce/label/c.OWC_different_owed_help_msg';
import OWC_sick_leave_help_msg from '@salesforce/label/c.OWC_sick_leave_help_msg';
import OWC_select_one_checkbox_label from '@salesforce/label/c.OWC_select_one_checkbox_label';
import OWC_vacation_time_final_rate from '@salesforce/label/c.OWC_vacation_time_final_rate';
import OWC_holiday_claim from '@salesforce/label/c.OWC_holiday_claim';
import OWC_hourly_rate_pay_helptext from '@salesforce/label/c.OWC_hourly_rate_pay_helptext';
import OWC_holiday_beg_date from '@salesforce/label/c.OWC_holiday_beg_date';
import OWC_holiday_end_date from '@salesforce/label/c.OWC_holiday_end_date';
import OWC_holiday_total_unpaid from '@salesforce/label/c.OWC_holiday_total_unpaid';
import OWC_holiday_total_hour_claimed from '@salesforce/label/c.OWC_holiday_total_hour_claimed';
import OWC_holiday_hourly_claim from '@salesforce/label/c.OWC_holiday_hourly_claim';
import OWC_holiday_rate_helptextmsg from '@salesforce/label/c.OWC_holiday_rate_helptextmsg';
import OWC_holiday_amount_paid from '@salesforce/label/c.OWC_holiday_amount_paid';
import OWC_regular_hourly_rate_helprtext from '@salesforce/label/c.OWC_regular_hourly_rate_helprtext';
import OWC_severance_pay_claim_heading from '@salesforce/label/c.OWC_severance_pay_claim_heading';
import OWC_how_label from '@salesforce/label/c.OWC_how_label';
import OWC_receive_text_msg_label from '@salesforce/label/c.OWC_receive_text_msg_label';
import OWC_total_severance_pay_amount from '@salesforce/label/c.OWC_total_severance_pay_amount';
import OWC_hourly_rate_pay_helptext_heat_rest from '@salesforce/label/c.OWC_hourly_rate_pay_helptext_heat_rest';
import OWC_calendar_time_helptext from '@salesforce/label/c.OWC_calendar_time_helptext';
import OWC_wage_header_summary from '@salesforce/label/c.OWC_wage_header_summary';
import OWC_regular_wage_heading_text from '@salesforce/label/c.OWC_regular_wage_heading_text';
import OWC_regular_claim_helptext from '@salesforce/label/c.OWC_regular_claim_helptext';
import OWC_piece_rate_owed_label from '@salesforce/label/c.OWC_piece_rate_owed_label';
import OWC_piece_rate_owed_helptext from '@salesforce/label/c.OWC_piece_rate_owed_helptext';
import OWC_commission_rate_amount_owed from '@salesforce/label/c.OWC_commission_rate_amount_owed';
import OWC_commission_rate_owed_helptext from '@salesforce/label/c.OWC_commission_rate_owed_helptext';
import OWC_OT_DT_claim_helptext from '@salesforce/label/c.OWC_OT_DT_claim_helptext';
import OWC_overtime_text from '@salesforce/label/c.OWC_overtime_text';
import OWC_overtime_balance_label from '@salesforce/label/c.OWC_overtime_balance_label';
import OWC_overtime_balance_helptext from '@salesforce/label/c.OWC_overtime_balance_helptext';
import OWC_dt_balance_owed_label from '@salesforce/label/c.OWC_dt_balance_owed_label';
import OWC_Date_Modified from '@salesforce/label/c.OWC_Date_Modified';
import OWC_overtime_dt_balance_helptext from '@salesforce/label/c.OWC_overtime_dt_balance_helptext';
import OWC_sick_leave_helptext from '@salesforce/label/c.OWC_sick_leave_helptext';
import OWC_wage_def_sick_claim_text from '@salesforce/label/c.OWC_wage_def_sick_claim_text';
import OWC_rest_break_screen_text from '@salesforce/label/c.OWC_rest_break_screen_text';
import OWC_meal_break_claim_screen_text from '@salesforce/label/c.OWC_meal_break_claim_screen_text';
import OWC_heat_recovery_claim_screen_text from '@salesforce/label/c.OWC_heat_recovery_claim_screen_text';
import OWC_tip_claim_heading from '@salesforce/label/c.OWC_tip_claim_heading';
import OWC_business_denied_helptext from '@salesforce/label/c.OWC_business_denied_helptext';
import OWC_business_expense_claim_heading from '@salesforce/label/c.OWC_business_expense_claim_heading';
import OWC_mileage_denied_helptext from '@salesforce/label/c.OWC_mileage_denied_helptext';
import OWC_mileage_claim_screen_text from '@salesforce/label/c.OWC_mileage_claim_screen_text';
import OWC_mileage_claim_span_year_msg from '@salesforce/label/c.OWC_mileage_claim_span_year_msg';
import OWC_do_you_mileage_claim from '@salesforce/label/c.OWC_do_you_mileage_claim';
import OWC_mileage_rate from '@salesforce/label/c.OWC_mileage_rate';
import OWC_deduction_claim_heading from '@salesforce/label/c.OWC_deduction_claim_heading';
import OWC_denied_payroll_helptext from '@salesforce/label/c.OWC_denied_payroll_helptext';
import OWC_demand_date_label from '@salesforce/label/c.OWC_demand_date_label';
import OWC_denied_personnel_file_label from '@salesforce/label/c.OWC_denied_personnel_file_label';
import OWC_split_shift_premium_claim_heading from '@salesforce/label/c.OWC_split_shift_premium_claim_heading';
import OWC_splitshift_screent_text from '@salesforce/label/c.OWC_splitshift_screent_text';
import OWC_reporting_claim_screentext from '@salesforce/label/c.OWC_reporting_claim_screentext';
import OWC_insufficient_screen_text from '@salesforce/label/c.OWC_insufficient_screen_text';
import OWC_other_rate_label from '@salesforce/label/c.OWC_other_rate_label';
import OWC_not_paid_sick_leave from '@salesforce/label/c.OWC_not_paid_sick_leave';
import OWC_additional_claim_bonus from '@salesforce/label/c.OWC_additional_claim_bonus';
import OWC_explain_label from '@salesforce/label/c.OWC_explain_label';
import OWC_latepayroll_screen_text from '@salesforce/label/c.OWC_latepayroll_screen_text';
import OWC_non_negotiable_check_label from '@salesforce/label/c.OWC_non_negotiable_check_label';
import OWC_employer_response_label from '@salesforce/label/c.OWC_employer_response_label';
import OWC_listed_another_claim from '@salesforce/label/c.OWC_listed_another_claim';
import OWC_meeting_detail_heading from '@salesforce/label/c.OWC_meeting_detail_heading';
import OWC_jump_to_label from '@salesforce/label/c.OWC_jump_to_label';
import OWC_start_wage_claim_text from '@salesforce/label/c.OWC_start_wage_claim_text';
import OWC_meeting_details from '@salesforce/label/c.OWC_meeting_details';
import OWC_new_claim_label from '@salesforce/label/c.OWC_new_claim_label';
import OWC_employer_name_label from '@salesforce/label/c.OWC_employer_name_label';
import OWC_claimant_name_label from '@salesforce/label/c.OWC_claimant_name_label';
import OWC_submitted_date from '@salesforce/label/c.OWC_submitted_date';
import OWC_status_label from '@salesforce/label/c.OWC_status_label';
import OWC_case_confirmed_msg from '@salesforce/label/c.OWC_case_confirmed_msg';
import OWC_industryinfo_IndustryCategory from '@salesforce/label/c.OWC_industryinfo_IndustryCategory';
import Owc_fillBothDate_Fields from '@salesforce/label/c.Owc_fillBothDate_Fields';
import OWC_Commissioner_Office_contact_message from '@salesforce/label/c.OWC_Commissioner_Office_contact_message';
import OWC_cert_date_label from '@salesforce/label/c.OWC_cert_date_label';
import OWC_claimant_name_cert_label from '@salesforce/label/c.OWC_claimant_name_cert_label';
import OWC_claimant_garment_text_msg from '@salesforce/label/c.OWC_claimant_garment_text_msg';
import OWC_overtime_additinal_balance from '@salesforce/label/c.OWC_overtime_additinal_balance';
import OWC_overtime_additinal_balance_helptext from '@salesforce/label/c.OWC_overtime_additinal_balance_helptext';
import OWC_Same_as_above from '@salesforce/label/c.OWC_Same_as_above';
import OWC_complete_saveit_label from '@salesforce/label/c.OWC_complete_saveit_label';
import OWC_production_bonus_helptext from '@salesforce/label/c.OWC_production_bonus_helptext';
import OWC_waiting_ten_helptext from '@salesforce/label/c.OWC_waiting_ten_helptext';
import OWC_waiting_time_eleven_helptext from '@salesforce/label/c.OWC_waiting_time_eleven_helptext';
import OWC_case_status1 from '@salesforce/label/c.OWC_case_status1';
import OWC_case_name from '@salesforce/label/c.OWC_case_name';
import owc_Case_Number from '@salesforce/label/c.owc_Case_Number';
import OWC_case_details_label from '@salesforce/label/c.OWC_case_details_label';
import OWC_case_closed_label from '@salesforce/label/c.OWC_case_closed_label';
import OWC_successor_employer_heading from '@salesforce/label/c.OWC_successor_employer_heading';
import OWC_thankyou_dialog from '@salesforce/label/c.OWC_thankyou_dialog';
import OWC_return_to_dashboard from '@salesforce/label/c.OWC_return_to_dashboard';
import OWC_break_length_helptext from '@salesforce/label/c.OWC_break_length_helptext';
import OWC_vacation_helpText from '@salesforce/label/c.OWC_vacation_helpText';
import OWC_holiday_helptext from '@salesforce/label/c.OWC_holiday_helptext';
import OWC_meal_help from '@salesforce/label/c.OWC_meal_help';
import OWC_rest_break_helptext from '@salesforce/label/c.OWC_rest_break_helptext';
import OWC_heat_help from '@salesforce/label/c.OWC_heat_help';
import OWC_hpt from '@salesforce/label/c.OWC_hpt';
import OWC_share_hpt from '@salesforce/label/c.OWC_share_hpt';
import OWC_pay_hp from '@salesforce/label/c.OWC_pay_hp';
import OWC_report_hpt from '@salesforce/label/c.OWC_report_hpt';
import OWC_mileage_claim_amount from '@salesforce/label/c.OWC_mileage_claim_amount';
import OWC_workweek_helptext from '@salesforce/label/c.OWC_workweek_helptext';
import OWC_workdays_helptext from '@salesforce/label/c.OWC_workdays_helptext';
import OWC_spinner_msg from '@salesforce/label/c.OWC_spinner_msg';
import OWC_another_split_shift_claim from '@salesforce/label/c.OWC_another_split_shift_claim';
import OWC_split_shift_claim_addmore from '@salesforce/label/c.OWC_split_shift_claim_addmore';
import OWC_welcome_path_label from '@salesforce/label/c.OWC_welcome_path_label';
import OWC_industry_path_heading from '@salesforce/label/c.OWC_industry_path_heading';
import OWC_employer_path_heading from '@salesforce/label/c.OWC_employer_path_heading';
import OWC_other_location_path_heading from '@salesforce/label/c.OWC_other_location_path_heading';
import OWC_emp_status_path_heading from '@salesforce/label/c.OWC_emp_status_path_heading';
import OWC_pow_path_label from '@salesforce/label/c.OWC_pow_path_label';
import OWC_workweek_path_label from '@salesforce/label/c.OWC_workweek_path_label';
import OWC_hours_typically_label from '@salesforce/label/c.OWC_hours_typically_label';
import OWC_file_size_error from '@salesforce/label/c.OWC_file_size_error';
const customLabelValues = {
    OWC_file_size_error,
    OWC_hours_typically_label,
    OWC_workweek_path_label,
    OWC_pow_path_label,
    OWC_emp_status_path_heading,
    OWC_other_location_path_heading,
    OWC_employer_path_heading,
    OWC_industry_path_heading,
    OWC_welcome_path_label,
    OWC_split_shift_claim_addmore,
    OWC_another_split_shift_claim,
    OWC_spinner_msg,
    OWC_workdays_helptext,
    OWC_workweek_helptext,
    OWC_mileage_claim_amount,
    OWC_report_hpt,
    OWC_pay_hp,
    OWC_share_hpt,
    OWC_hpt,
    OWC_heat_help,
    OWC_rest_break_helptext,
    OWC_meal_help,
    OWC_holiday_helptext,
    OWC_vacation_helpText,
    OWC_break_length_helptext,
    OWC_return_to_dashboard,
    OWC_thankyou_dialog,
    OWC_successor_employer_heading,
    OWC_case_name,
    owc_Case_Number,
    OWC_case_status1,
    OWC_case_closed_label,
    OWC_case_details_label,
    OWC_waiting_time_eleven_helptext,
    OWC_waiting_ten_helptext,
    OWC_production_bonus_helptext,
    OWC_complete_saveit_label,
    OWC_Same_as_above,
    OWC_overtime_additinal_balance_helptext,
    OWC_overtime_additinal_balance,
    OWC_claimant_garment_text_msg,
    OWC_cert_date_label,
    OWC_Date_Modified,
    OWC_meeting_details,
    OWC_claimant_name_cert_label,
    OWC_industryinfo_IndustryCategory,
    OWC_Commissioner_Office_contact_message,
    OWC_case_confirmed_msg,
    OWC_status_label,
    OWC_submitted_date,
    OWC_employer_name_label,
    OWC_claimant_name_label,
    OWC_new_claim_label,
    OWC_start_wage_claim_text,
    OWC_jump_to_label,
    OWC_meeting_detail_heading,
    OWC_listed_another_claim,
    OWC_employer_response_label,
    OWC_non_negotiable_check_label,
    OWC_latepayroll_screen_text,
    OWC_explain_label,
    OWC_additional_claim_bonus,
    OWC_not_paid_sick_leave,
    OWC_other_rate_label,
    OWC_insufficient_screen_text,
    OWC_reporting_claim_screentext,
    OWC_splitshift_screent_text,
    OWC_split_shift_premium_claim_heading,
    OWC_denied_personnel_file_label,
    OWC_demand_date_label,
    OWC_denied_payroll_helptext,
    OWC_deduction_claim_heading,
    OWC_mileage_rate,
    OWC_do_you_mileage_claim,
    OWC_mileage_claim_span_year_msg,
    OWC_mileage_claim_screen_text,
    OWC_mileage_denied_helptext,
    OWC_business_expense_claim_heading,
    OWC_business_denied_helptext,
    OWC_tip_claim_heading,
    OWC_heat_recovery_claim_screen_text,
    OWC_meal_break_claim_screen_text,
    OWC_rest_break_screen_text,
    OWC_wage_def_sick_claim_text,
    OWC_sick_leave_helptext,
    OWC_overtime_dt_balance_helptext,
    OWC_dt_balance_owed_label,
    OWC_overtime_balance_helptext,
    OWC_overtime_balance_label,
    OWC_overtime_text,
    OWC_OT_DT_claim_helptext,
    OWC_commission_rate_owed_helptext,
    OWC_commission_rate_amount_owed,
    OWC_piece_rate_owed_helptext,
    OWC_piece_rate_owed_label,
    OWC_regular_claim_helptext,
    OWC_regular_wage_heading_text,
    OWC_wage_header_summary,
    OWC_calendar_time_helptext,
    OWC_receive_text_msg_label,
    OWC_total_severance_pay_amount,
    OWC_how_label,
    OWC_severance_pay_claim_heading,
    OWC_hourly_rate_pay_helptext_heat_rest,
    OWC_regular_hourly_rate_helprtext,
    OWC_holiday_amount_paid,
    OWC_holiday_rate_helptextmsg,
    OWC_holiday_hourly_claim,
    OWC_holiday_total_hour_claimed,
    OWC_holiday_total_unpaid,
    OWC_holiday_end_date,
    OWC_holiday_beg_date,
    OWC_hourly_rate_pay_helptext,
    OWC_holiday_claim,
    OWC_vacation_time_final_rate,
    OWC_select_one_checkbox_label,
    OWC_sick_leave_help_msg,
    OWC_different_owed_help_msg,
    OWC_different_owed_label,
    OWC_total_salary_owed,
    OWC_total_owed_salary_helptext,
    OWC_total_owed_helptext,
    OWC_waiting_time_msg,
    OWC_waiting_time,
    OWC_sick_leave_claim,
    OWC_one_calendar_year_span,
    OWC_not_promised_holiday_pay,
    OWC_payroll_end_date,
    OWC_payroll_beg_date,
    OWC_late_payroll_msg,
    OWC_insufficient_msg,
    OWC_late_payroll,
    OWC_written_statement_help_msg,
    OWC_written_statement,
    OWC_commision_summary_v1,
    OWC_commission_agreement,
    OWC_unknown_piece_rate,
    OWC_multiple_piece_rate,
    OWC_single_piece_rate,
    OWC_different_hourly_rate,
    OWC_total_owed_label,
    OWC_salary_rate,
    OWC_one_hourly_rate,
    OWC_total_work_hours,
    OWC_shift_end_follow_day,
    OWC_break_time,
    OWC_end_time,
    OWC_second_meal_time,
    OWC_first_meal_time,
    OWC_start_time,
    OWC_second_meal,
    OWC_first_meal,
    OWC_other_claims_label,
    OWC_another_regular_wage_button,
    OWC_regular_wage_add_button,
    OWC_paystub_sick_leave,
    OWC_delete_responsible_person,
    OWC_claim_information,
    OWC_additional_responsible_person,
    OWC_signed_confirmation,
    OWC_date_filed,
    OWC_Required_Field,
    OWC_Enter_Valid_Email,
    OWC_Email_Not_Match,
    OWC_Enter_Valid_Phone,
    OWC_Confirm_Email,
    OWC_Cell_Phone_Number,
    OWC_Submit,
    OWC_Create_Account,

    OWC_regular_wages_claim_heading,
    OWC_hourlyrate_help_button_text,
    OWC_lawfirm_custom_msg,
    OWC_OnlineWageClaimLiPart,
    OWC_employer_name_changed_helptext,
    OWC_SomeoneElseName,
    OWC_time_card_name,
    OWC_yourself_submit_label,
    OWC_claim_double_time_label,
    OWC_another_pay_time_claim_heading,
    OWC_reporting_time_pay_claim_heading,
    OWC_reporting_time_claim_label,
    OWC_another_insufficient_fund_claim_heading,
    OWC_insufficient_fund_claim_label,
    OWC_insufficient_fund_claim_heading,
    OWC_another_milega_expense_claim_label,
    OWC_milega_expense_claim,
    OWC_milega_claim_label,
    OWC_another_rest_claim_heading_label,
    OWC_heat_rest_claim_heading_label,
    OWC_heat_rest_claim_label,
    OWC_another_meal_break_claim_heading_label,
    OWC_meal_break_claim_heading,
    OWC_meal_break_claim_label,
    OWC_another_rest_break_claim_heading_label,
    OWC_rest_break_claim_heading_label,
    OWC_another_rest_break_claim_label,
    OWC_another_sick_leave_claim_heading,
    OWC_sick_leave_claim_heading_label,
    OWC_sick_leave_label,
    OWC_overtime_another_pay_claim_heading,
    OWC_overtime_pay_claim_heading_label,
    OWC_overtime_pay_claim_label,
    OWC_another_claim_label,
    OWC_repeat_claim,
    OWC_another_wage_claim_label,
    OWC_delete_claim_button,
    OWC_another_wage_deficiencies_label,
    OWC_another_deficiencies_claim_question_label,
    OWC_another_deficiencies_claim_button,
    OWC_another_deficiencies_claim_button,
    OWC_action_label,
    OWC_suggested_response_label,
    OWC_error_response_label,
    OWC_usps_response_error_header,
    OWC_usps_continue_address,
    OWC_label_draft_create_msg,
    OWC_draft_update_toast_msg,
    OWC_delete_button_label,
    OWC_success_label,
    OWC_receipt_summary_label,
    OWC_advocate_assist_label,
    OWC_case_status_label,
    OWC_submitted_case_label,
    OWC_submitted_claim_label,
    OWC_no_record_error,
    OWC_draft_number_label,
    OWC_online_draft_label,
    OWC_wages_paid_on_the_pay_day,
    OWC_usps_continue_address,
    OWC_address_proceed,
    OWC_Click_here,
    OWC_Claimant_Confirmation_alert_message,
    OWC_piece_rate_label,
    OWC_commission_rate_label,
    OWC_salary_rate_label,
    OWC_different_hourly_rate_label,
    OWC_one_hourly_rate_label,
    OWC_different_hourly_rate_text,
    OWC_one_hourly_rate_text,
    OWC_industry_paid_breaks,
    OWC_cancel_button_label,
    OWC_different_hourly_additonal_help_text,
    OWC_save_button_label,
    OWC_employer_other_name_label,
    OWC_individual_required_helptext,
    OWC_union_contract_options_label,
    OWC_employee_additional_bank_incharge_name,
    OWC_employee_additional_bank_claimrelated_action,
    OWC_preliminary_local_office_mail_label,
    OWC_employee_additional_employeer_changed_name,
    owc_not_paid_vacation,
    owc_not_allowed_heat_rest,
    owc_not_paid_Holiday,
    owc_Production_Bonus,
    owc_reported_to_work,
    owc_dischargedDateHelpText,
    OWC_typically_worked_explain_mealperiod,
    OWC_WhyWorkMissed,
    OWC_DaysOfWorkMissed,
    OWC_available_sick_leave,
    OWC_miss_for_this_reason,
    OWC_save_as_draft_label,
    OWC_checkbox_group_error_msg,
    OWC_invalid_claimant_birthdate_error_msg,
    OWC_piecerate_label_permile,
    OWC_piecerate_label,
    OWC_AdditionalRates,
    OWC_lawfirm_representative_PhoneNumberEmailrequiredmsg,
    OWC_select_picklist_label,
    OWC_fixed_amount_wage_promised,
    OWC_fixed_amount_wage_paid,
    OWC_payement_commission_agreement_helptext,
    OWC_EnterValidAmount,
    OWC_preliminary_office_locator_dlse_wage_for,
    OWC_preliminary_office_locator_link,
    OWC_section_delete_toastmsg,
    OWC_Yes,
    OWC_No,
    //owcPreliminarySectionCmp Custom labels
    OWC_claimant_upload_confirm_doc,
    OWC_claimant_confirmation_label,
    OWC_preliminary_heading,
    OWC_middle_name,
    OWC_individual_rep_claimant_relationship,
    OWC_individual_rep_phonetype,
    OWC_preliminary_wageclaim_submit,
    OWC_preliminary_union_contract_covering,
    OWC_preliminary_upload_document,
    OWC_url_address,
    OWC_preliminary_coversheet_mailing_document,
    OWC_filing_wage_claim,
    OWC_preliminary_specify_one,
    OWC_preliminary_covid19_claim,
    OWC_preliminary_specify_other_reason,
    OWC_required_field_error_msg,
    OWC_date_format_label,
    OWC_invalid_phone_msg,
    OWC_invalid_email_msg,
    OWC_claimant_employee_cellphone_helptext,
    OWC_claimant_employee_email_helptext,
    OWC_representative_advocatetype_helptext,
    OWC_invalid_zipcode_msg,
    OWC_multiplefileupload_helptext,
    OWC_preliminary_coversheet_helptext,
    OWC_yourself_zipcode_helptext,
    OWC_individual_rep_phonetype_helptext,
    OWC_urladdress_error_msg,
    OWC_fileupload_success_toast_msg,
    OWC_multiple_file_delete_toast_msg,
    //custom labels for claimant and employee section
    OWC_claimant_employee_heading,
    OWC_first_name,
    OWC_last_name,
    OWC_claimant_employee_home_phone,
    OWC_CellPhone,
    OWC_claimant_employee_cellphone_entered,
    OWC_claimant_employee_birthdate,
    OWC_email,
    OWC_street_address,
    OWC_city,
    OWC_state,
    OWC_empinfo_Phone,
    OWC_zipcode,
    //custom labels for representative section
    OWC_representative_advocatetype,
    OWC_website,
    OWC_lawfirm_representative_attorney,
    OWC_businessname,
    OWC_learnmore_button,
    OWC_lawfirm_representative_requiredmsg,
    OWC_claimant_employee_required_msg,
    //Language Assistance Section custom labels
    OWC_language_assistance_heading,
    OWC_language_assistance_interpreter,
    OWC_language_assistance_preferred_language,
    OWC_language_assistance_preferred_language_other,
    //Custom labels for INformation Section
    OWC_addanotherlabel_button,
    OWC_addanothersuccessor_buttton,
    OWC_industryinfo,
    OWC_industryinfo_category,
    OWC_industryinfo_specific,
    OWC_industryinfo_farmlaborer,
    OWC_industryinfo_farmlaborerhelptext,
    OWC_industryinfo_heatrecoveryperiods,
    OWC_industryinfo_heatrecoveryperiodshelptext,
    OWC_industryinfo_paidseparatelyforheatrecoveryperiods,
    OWC_industryinfo_request,
    OWC_industryinfo_writtenrequest,
    OWC_industryinfo_employerstatement,
    OWC_industryinfo_employerneverstatement,
    OWC_industryinfo_typeofwork,
    OWC_industryinfo_workhome,
    OWC_industryinfo_registerednurse,
    OWC_industryinfo_homeworked,
    OWC_industryinfo_homeagency,
    OWC_industryinfo_residential,
    OWC_industryinfo_duties,
    OWC_industryinfo_domesticworkerhelptext,
    OWC_industryinfo_personalattendenthelptext,
    OWC_industryinfo_facilitypersonalattendenthelptext,
    OWC_industryinfo_publichousekeepinghelptext,   
    OWC_empinfo_BusinessPhone, 
    OWC_empinfo_VehicleLicense,
    OWC_industryinfo_businessname,
    OWC_industryinfo_jobduties,
    OWC_successoraddinfo_heading,
    OWC_hepttext_header,
    OWC_label_info_heading,
    OWC_added_section_label,
    OWC_ordinalsuffix_nd,
    OWC_ordinalsuffix_rd,
    OWC_ordinalsuffix_th,
    OWC_ordinalsuffix_st,
    OWC_farmlabor_statementprovideddate_error_msg,
    OWC_farmlabor_writtendate_error_msg,
    OWC_pastdate_error_msg,
    OWC_anotherlabel_heading,
    OWC_anothersuccessor_heading,
    OWC_deleteSection_msg,
    // onlineWageClaimContainerCmp custom label
    OWC_previous_button,
    OWC_continue_button,
    OWC_finish_button,
    // owcCertificationAndAuthorizationCmp Custom Label
    OWC_preview_button_label,
    OWC_edit_buttton_label,
    OWC_certification_section_heading,
    OWC_certification_additional_claim_documents,
    OWC_certification_authorization_to_release,
    OWC_authorised_claimant_name,
    OWC_authorised_claimant_date,
    // owcPaymentOfWagesCmp custom label 
    OWC_paymentofwages_per_label,
    OWC_payment_received_final_wage,   
    OWC_PaymentOfWages,
    OWC_RecieveRestPeriodHelpText   ,
    OWC_SelectPayment,
    OWC_HourlyEmplyee,
    OWC_PaidPerHour,
    OWC_PromisedPerHour,
    OWC_ProvideDifferentRates,
    OWC_PaidFor,
    OWC_PromisedFor,
    OWC_FixedAmountWages,
    OWC_Paid,
    OWC_Amount,
    OWC_Frequency,
    OWC_Promised,
    OWC_WrittenCommissionAgreement,
    OWC_UploadAgreementFunction,
    OWC_ProvidePriceRate,
    OWC_PaidMinimumWage,
    OWC_RecieveRestPeriod,
    OWC_FollowUp_PaidSeparately,
    OWC_ByCheck,
    OWC_ByCash,
    OWC_ByCheckByCash,
    OWC_Other,
    OWC_notPaid,
    OWC_NotSufficientFundHelpText,
    OWC_ProvideCommissionRate,
    OWC_ContractionTrade_Helptext,
    OWC_UploadDocument_Helptext,
    OWC_Per,
    OWC_paymentofwages_required_date_errormsg,
    Owc_pieceRateTotalEarned,
    Owc_pieceRateTotalPaid,
    OWC_pieceRateHintText,
    owc_selectOne_field,
    Owc_fillBothDate_Fields,
    //owcHoursYouTypicallyWorkedCmp custom label
    OWC_unpaid_work_hours,
    OWC_hours_typically_worked_work_missed_reason,
    OWC_hours_typically_worked_heading,
    OWC_typicallyworked_sameworkinghours,
    OWC_typicallyworked_selectone,
    OWC_typically_worked_no_of_saturday,
    OWC_typically_worked_no_of_sunday,
    OWC_typically_worked_restperiod,
    OWC_typically_worked_explain_restperiod,
    OWC_typically_worked_mealperiod,
    OWC_typically_worked_mealperiod_explain,
    OWC_typically_worked_missed,
    OWC_typically_worked_holiday_selection,
    OWC_typically_worked_othertext,
    OWC_typically_worked_upload_form,
    OWC_typically_worked_vacation_time_claims,
    OWC_typically_worked_unreimbursed_business,
    OWC_typicallyworked_perweek,
    OWC_typically_worked_newyear_holiday,
    OWC_typically_worked_unreimbursed_business_helptext,
    OWC_typically_working_hours_same,
    OWC_hours_typically_worked_dlseform55_helptext,
    OWC_typically_worked_vacationtimeclaims_helptext,
    //Employement status and final wages
    OWC_EmpStatusRequiredMsg,
    OWC_date_placeholder,
    OWC_employement_status_othersection_heading,
    OWC_employement_status_dischargeddate_heading,
    OWC_employement_status_quitdate_heading,
    OWC_successorinfo_HireDate ,
    Owc_Date,
    OWC_Date_Of_Hire,
    OWC_Date_Of_Hire_helptext,
    Owc_Was_Check_ReplacedDate,
    OWC_Employment_Status_and_Final_Wages ,
    Owc_Did_Receive_Itemized_Wage,
    Owc_Did_Receive_Itemized_Wage_HelpText,
    OWC_Name_of_person_who_hired_you ,
    OWC_How_were_your_wages_paid ,
    OWC_Did_any_of_the_paychecks_Bounce ,
    Owc_Was_Check_Replaced,
    OWC_Explanation ,
    OWC_ReceiveItemizedWages ,
    OWC_employee_additional_whopaidyou ,
    OWC_WorkingForIdentifiedEmployer ,
    OWC_CompleteAtLeastOne ,
    OWC_Quit_Date ,
    OWC_notice_before_quitting ,
    OWC_RecievedFinalPayment ,
    OWC_DischargedDate ,
    OWC_PersonWhoDischargeYou ,
    //owcPaidTypeMetaData ,
    //WorkWeek WorkDay
    OWC_WorkweekAndWorkday_Heading ,
    OWC_WorkweekAndWorkday_EmpFollowSatToSun,
    OWC_WorkweekAndWorkday_EmpDefinedWorkweek,
    OWC_WorkweekAndWorkday_EmpFollowMidnightToMidnight,
    OWC_WorkweekAndWorkday_ProvideEmpDefWorkday,
    OWC_WorkweekAndWorkday_BegDate,
    OWC_WorkweekAndWorkday_EndDate,
    // Import owcWageDeficienciesCmp Custom Labels
    OWC_wage_deficiencies_heading,
    OWC_wage_deficiencies_claim_timeperiod,
    OWC_wage_deficiencies_firstDate,
    OWC_wage_deficiencies_lastdate,
    OWC_wage_deficiencies_your_claim,
    OWC_wage_deficiencies_severancepay_offered,
    OWC_wage_deficiencies_pooltips,
    OWC_wage_deficiencies_receive_tips,
    OWC_wage_deficiencies_receipts_docs,
    OWC_wage_deficiencies_mileage_log,
    OWC_wage_deficiencies_mileage_reimbursement_rate,
    OWC_wage_deficiencies_make_demand,
    OWC_wage_deficiencies_employer_response,
    OWC_wage_deficiencies_notpaid_for_worked,
    OWC_wage_deficiencies_paid_minimum_wages,
    OWC_wage_deficiencies_regular_paid,
    OWC_wage_deficiencies_promised_onerate,
    OWC_wage_deficiencies_sickleave_paid,
    OWC_wage_deficiencies_bathroom_break,
    OWC_wage_deficiencies_mealbreak,
    OWC_wage_deficiencies_severancepay,
    OWC_wage_deficiencies_sharetips,
    OWC_wage_deficiencies_payment_denied,
    OWC_wage_deficiencies_denied_payment,
    OWC_wage_deficiencies_paycheck_deduction,
    OWC_wage_deficiencies_payroll_information,
    OWC_wage_deficiencies_personnel_file,
    OWC_wage_deficiencies_paystub_payment,
    OWC_First_date_error_msg,
    OWC_Last_date_error_msg,
    OWC_empinfo_ClaimField,
    OWC_AddEmployerInformation,
    OWC_anotheremployer_heading,
    //Payment of wages
    OWC_begdate_error_msg,
    OWC_enddate_error_msg,
    Owc_perHour,
    Owc_Beginning,
    Owc_Ending,
    Owc_forActivity,
    Owc_ratePaid,
    Owc_ratePromised,
    Owc_perUnit,
    Owc_paidAtleasrMin,
    Owc_lowestAmntPaid,
    Owc_highestAmntPaid,
    Owc_Additional,
    Owc_oneHourlyAdditionalText,
    Owc_eachPayAdditionalText,
    Owc_noOfUnits,
    Owc_pieceOfRateText,
    OWC_begdate_error_msg,
    OWC_enddate_error_msg,
    Owc_commissionPayRate,
    Owc_commissionPayEarned,
    // custom labels of Claim Filed Against (Employer Information) section
    OWC_employee_additional_bank,
    OWC_employee_additional_personinchargename, 
    OWC_lawfirm_representative_businessname, 
    OWC_empinfo_EmpBusinessType, 
    OWC_empinfo_explain, 
    OWC_empinfo_ConstructionTrades, 
    OWC_empinfo_Uploaddoc, 
    OWC_empinfo_Addimage, 
    OWC_AddImage_HelpText, 
    OWC_Additional_Info, 
    OWC_NameOfPersonInChage, 
    OWC_EnterName_HelpText, 
    OWC_JobTitle_PersonInCharge, 
    OWC_WhoPaidYou, 
    OWC_DifferentPerson, 
    OWC_WorkRecord, 
    OWC_SignTimeCard, 
    OWC_SomeoneElseName, 
    OWC_TotalEmployees, 
    OWC_BestGuess_HelpText, 
    OWC_EmpBusiness, 
    OWC_CompEmployed, 
    OWC_ChangeOrSold, 
    OWC_Bankruptcy, 
    OWC_ShowTost, 
    OWC_employee_reuired_field_error_msg, 
    OWC_empinfo_empName, 
    OWC_employer_delete_button, 
    OWC_invalid_url_msg, 
}

// Accepted formats for upload files
const acceptedFileFormat = [ '.pdf', '.png', '.docx', '.xlsx', '.jpg', '.jpeg' ];

// Radio group Yes/No values list
const radioOptions = [
    { label: OWC_Yes, value: OWC_Yes },
    { label: OWC_No, value: OWC_No }
];

// USPS radio options
const uspsRadioOption = [
    { label: OWC_address_proceed, value: OWC_address_proceed },
    { label: OWC_usps_continue_address, value: OWC_usps_continue_address }
];

// Radio group options for employer Union Contract Covering
const unionContractCoverOptions = [
    { label: OWC_preliminary_upload_document, value: OWC_preliminary_upload_document },
    { label: OWC_url_address, value: OWC_url_address },
    { label: OWC_preliminary_local_office_mail_label, value: OWC_preliminary_local_office_mail_label }
];


export function showToastMsg(message, variant){
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
}


export { radioOptions, acceptedFileFormat, customLabelValues, unionContractCoverOptions, uspsRadioOption  };