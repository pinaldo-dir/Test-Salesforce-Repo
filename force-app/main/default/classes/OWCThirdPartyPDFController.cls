/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 11-16-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc 
**/

public with sharing class OWCThirdPartyPDFController {
    public String caseName {get; set;}
    public String userLanguage{get {if(userinfo.getLanguage() != 'es'){return 'en_US';} else {return userinfo.getLanguage();} } set;}
    public String todayDate {get; set;}
    public claimantEmployeeWrapper claimantEmpWrapperObj{get;set;}
    public industryInfoWrapper industryInfoWrapperObj{get;set;}
    public List<LabelDetails> LabelDetailsWrapperObj{get;set;}
    public otherWorkLocationWrapper otherWorkLocationWrapperObj{get;set;}
    public empStatusAndFinalWagesWrapper empStatusAndFinalWagesWrapperObj{get;set;}
    public workWeekAndWorkDayWrapper workWeekAndWorkDayWrapperObj{get;set;}
    public hoursYouTypicallyWorkedWrapper hoursYouTypicallyWorkedWrapperObj{get;set;}
    
    public paymentOfWagesWrapper paymentOfWagesWrapperObj{get;set;}
    public powAdditionalWrapper powAdditionalWrapObj{get;set;}
    public List<powAdditionalWrapper> hourlyAdditionalDetails{get;set;}
    public List<powDifferentHourAdditionalWrapper> differentHourAdditionalDetails{get;set;}
    public List<powSalaryRateAdditionalWrapper> salaryRateAdditionalDetails{get;set;}
    public List<powPieceRateAdditionalWrapper> pieceRateAdditionalDetails{get;set;}
    public List<agreementDocsWrapper> agreementDocsDetails{get;set;}
    public List<wageDeficiencyDetails> wageDefDetails{get;set;}
    public CertificationAndAuth CertificationAndAuthObj{get;set;}
    public List<empClaimWrapper> empClaimWrapperObj{get;set;}
    public Map<String,Object> hourlyObj{get;set;}
    public List<Object> wageDeficiencyDetails{get;set;}
    public static List<violationTypeVariables> violationTypeVariables{get;set;}
    public String advocateType;
    
    public OWCThirdPartyPDFController(){
        // Current User Language
        //userLanguage = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1].LanguageLocaleKey;
        // Get newly created casemanagement object Id from the pagereference
        
        try{
            System.debug('result OnlineWageClaimThirdPartyAPIController ::: '+OnlineWageClaimThirdPartyAPIController.thirdPartyJson);
            String caseManagementId = ApexPages.currentPage().getParameters().get('caseManagementId');
            system.debug('params: '+ApexPages.currentPage().getParameters());
            System.debug('caseManagementId ::: '+caseManagementId);
            
            // Remove " from the string start and end
            String caseId = caseManagementId.remove('"');
            //if(1 == 1) return;
            Dir_Case__c cse = [SELECT Id,Name, OWC_JSON__c, CreatedDate FROM Dir_Case__c WHERE Id =: caseId LIMIT 1];
            
            todayDate = cse.CreatedDate.month() + '/' + cse.CreatedDate.day() + '/' + cse.CreatedDate.year();
              
            // Get OWC Form JSON record from case management object
            //String onlineClaimDetails = .OWC_JSON__c;
            caseName = 'WC-'+cse.Name;
            Map<String, object> responseWrapper = OWCServiceUtility.getdeserializeUntypedMap (cse.OWC_JSON__c.replace('&quot;','"').replace('&#39;', '\''));
            Map<String, Object> claimantEmployeeData = (Map<String, Object>) responseWrapper.get('claimantEmployeeValues');
            Map<String, Object> claimantDetails = (Map<String, Object>) claimantEmployeeData.get('claimantDetails');
            //List<wageDeficiencyDetails> wageDeficiencyDetails = (List<wageDeficiencyDetails>) responseWrapper.get('wageDeficiencyDetails');
            String jsonWageDefDetails = JSON.serialize(responseWrapper.get('wageDeficiencyDetails'));
            if(jsonWageDefDetails != null){
                wageDefDetails = (List<wageDeficiencyDetails>) System.JSON.deserialize(jsonWageDefDetails, List<wageDeficiencyDetails>.class);        
            }
            
            claimantEmpWrapperObj = new claimantEmployeeWrapper();
            if(claimantEmployeeData != null){
                claimantEmpWrapperObj.representativeAdvocateType = (String) claimantEmployeeData.get('representativeAdvocateType');
                if(userinfo.getLanguage() != 'es'){
                    claimantEmpWrapperObj.wageClaimSubmitChoice = (String) claimantEmployeeData.get('WageClaimSubmit');
                }else{
                    Map<String, OWCPreliminaryWageClaimSubmit__mdt> mapObj = OWCPreliminaryWageClaimSubmit__mdt.getAll();
                    for(String obj : mapObj.keySet()){
                        if(mapObj.get(obj).English_Translation__c == (String) claimantEmployeeData.get('WageClaimSubmit')){
                            claimantEmpWrapperObj.wageClaimSubmitChoice = mapObj.get((String) claimantEmployeeData.get('WageClaimSubmit')).Spanish_Translation__c;
                        }
                    }
                }
                claimantEmpWrapperObj.countryCodeindividualRepPhone = (String) claimantEmployeeData.get('countryCodeindividualRepPhone');
                claimantEmpWrapperObj.countryCodelawfirmRepStatePhone = (String) claimantEmployeeData.get('countryCodelawfirmRepStatePhone');
            }
            
            if(claimantDetails != null){
                // Add Yourself Claimant Information into the wrapper object.
                claimantEmpWrapperObj.yourselfFirstName = (String) claimantDetails.get('yourselfFirstName');
                claimantEmpWrapperObj.yourselfMiddleName = (String) claimantDetails.get('yourselfMiddleName');
                claimantEmpWrapperObj.yourselfLastName = (String) claimantDetails.get('yourselfLastName');
                claimantEmpWrapperObj.yourselfBirthDate = (String) claimantDetails.get('yourselfBirthDate') != null ? cleanDate((String) claimantDetails.get('yourselfBirthDate')) : null;
                claimantEmpWrapperObj.yourselfCellPhone = formattedPhone((String) claimantDetails.get('yourselfCellPhone'));
                claimantEmpWrapperObj.countryCodeyourselfCellPhone = (String) claimantDetails.get('countryCodeyourselfCellPhone');
                claimantEmpWrapperObj.countryCodeyourselfHomePhone = (String) claimantDetails.get('countryCodeyourselfHomePhone');        
                claimantEmpWrapperObj.yourselfTextMsg = (Boolean) claimantDetails.get('isCellPhoneEntered');
                claimantEmpWrapperObj.yourselfHomePhone = formattedPhone((String) claimantDetails.get('yourselfHomePhone'));
                claimantEmpWrapperObj.yourselfEmail = (String) claimantDetails.get('yourselfEmail');
                claimantEmpWrapperObj.yourselfStreetAddress = (String) claimantDetails.get('yourselfStreetAddress');
                claimantEmpWrapperObj.yourselfCity = (String) claimantDetails.get('yourselfCity');
                claimantEmpWrapperObj.yourselfState = (String) claimantDetails.get('yourselfState');
                claimantEmpWrapperObj.yourselfZipCode = (String) claimantDetails.get('yourselfZipCode');
                claimantEmpWrapperObj.needLanguageInterpreter = ((String) claimantDetails.get('needLanguageInterpreter') != null && (String) claimantDetails.get('needLanguageInterpreter') == 'Yes') ? (String) claimantDetails.get('needLanguageInterpreter') : 'No';
                if(userinfo.getLanguage() != 'es'){
                    claimantEmpWrapperObj.prefferedLanguageSelection = (String) claimantDetails.get('prefferedLanguageSelection');
                }
                else{
                    Map<String, OWCPrefferedLanguageAssistantData__mdt> mapObj = OWCPrefferedLanguageAssistantData__mdt.getAll();
                    for(String obj : mapObj.keySet()){
                        if(mapObj.get(obj).English_Translation__c == (String) claimantDetails.get('prefferedLanguageSelection')){
                            claimantEmpWrapperObj.prefferedLanguageSelection = mapObj.get((String) claimantDetails.get('prefferedLanguageSelection')).Spanish_Translation__c;
                        }
                    }
                }
                claimantEmpWrapperObj.otherPrefferedLanguage = (String) claimantDetails.get('otherPrefferedLanguage');
            }
            
            if(claimantEmployeeData != null){
                claimantEmpWrapperObj.isRepresentative = (boolean) claimantEmployeeData.get('isRepresentative');
                claimantEmpWrapperObj.isYourself = (boolean) claimantEmployeeData.get('isYourself');
                claimantEmpWrapperObj.isIndividualRepresentation = (boolean) claimantEmployeeData.get('isIndividualRepresentation');
                claimantEmpWrapperObj.isLawFirmRepresentation = (boolean) claimantEmployeeData.get('isLawFirmRepresentation');
                
                // Add Individual Representative Information into the wrapper object.
                claimantEmpWrapperObj.individualRepFirstName = (String) claimantEmployeeData.get('individualRepFirstName');
                claimantEmpWrapperObj.individualRepLastName = (String) claimantEmployeeData.get('individualRepLastName');
                claimantEmpWrapperObj.individualRepStreetAddress = (String) claimantEmployeeData.get('individualRepStreetAddress');
                claimantEmpWrapperObj.individualRepCity = (String) claimantEmployeeData.get('individualRepCity');
                claimantEmpWrapperObj.individualRepState = (String) claimantEmployeeData.get('individualRepState');
                claimantEmpWrapperObj.individualRepZipCode = (String) claimantEmployeeData.get('individualRepZipCode');
                claimantEmpWrapperObj.individualRepPhone = formattedPhone((String) claimantEmployeeData.get('individualRepPhone'));
                claimantEmpWrapperObj.individualRepPhoneType = (String) claimantEmployeeData.get('individualRepPhoneType');
                claimantEmpWrapperObj.individualRepClaimantRelationship = (String) claimantEmployeeData.get('individualRepClaimantRelationship');
                claimantEmpWrapperObj.individualRepEmail = (String) claimantEmployeeData.get('individualRepEmail');
                claimantEmpWrapperObj.individualRepWebsite = (String) claimantEmployeeData.get('individualRepWebsite');
                
                System.debug('representativeAdvocateType ::: '+claimantEmpWrapperObj.representativeAdvocateType);
                
                // Add Claimant Confirmation upload docs information into the wrapper Object
                claimantEmpWrapperObj.isClaimantConfirmation = claimantEmployeeData.get('isClaimantConfirmation') != null ? (Boolean)claimantEmployeeData.get('isClaimantConfirmation') : false;
            } 
            // Add Law Firm/Organization Information into the Wrapper object.
            if(claimantEmpWrapperObj != null){
                claimantEmpWrapperObj.lawfirmRepBusinessName = (String) claimantEmployeeData.get('lawfirmRepBusinessName');
                claimantEmpWrapperObj.lawfirmRepAttorney = (String) claimantEmployeeData.get('lawfirmRepAttorney');
                claimantEmpWrapperObj.lawfirmRepStreetAddress = (String) claimantEmployeeData.get('lawfirmRepStreetAddress');
                claimantEmpWrapperObj.lawfirmRepCity = (String) claimantEmployeeData.get('lawfirmRepCity');
                claimantEmpWrapperObj.lawfirmRepState = (String) claimantEmployeeData.get('lawfirmRepState');
                claimantEmpWrapperObj.lawFirmRepZipCode = (String) claimantEmployeeData.get('lawFirmRepZipCode');
                claimantEmpWrapperObj.lawfirmRepStatePhone = formattedPhone((String) claimantEmployeeData.get('lawfirmRepStatePhone'));
                claimantEmpWrapperObj.lawfirmRepEmail = (String) claimantEmployeeData.get('lawfirmRepEmail');
                claimantEmpWrapperObj.lawfirmRepWebsite = (String) claimantEmployeeData.get('lawfirmRepWebsite');
            }
            //SendAttachment(ApexPages.currentPage().getParameters().get('id'));
            
            //IndusrtyInfo Data into Map
            Map<String, Object> industryInfoData = (Map<String, Object>) responseWrapper.get('industryInfoDataValues');
            System.debug('industryInfoData ::: '+industryInfoData);
            
            if(industryInfoData != null){
                industryInfoWrapperObj = new industryInfoWrapper();
                industryInfoWrapperObj.selectedIndustry = (userinfo.getLanguage() != 'es') ? (String) industryInfoData.get('selectedIndustry') : (String) industryInfoData.get('selectedIndustry_es');
                industryInfoWrapperObj.selectedOption = (userinfo.getLanguage() != 'es') ? (String) industryInfoData.get('selectedOption') : (String) industryInfoData.get('selectedOption_es');
                industryInfoWrapperObj.farmWorker = (String) industryInfoData.get('farmWorker');
                industryInfoWrapperObj.isGarmentDutyFollow = (String) industryInfoData.get('isGarmentDutyFollow') != null && (String) industryInfoData.get('isGarmentDutyFollow') == 'Yes' ? (String) industryInfoData.get('isGarmentDutyFollow') : 'No';
                industryInfoWrapperObj.heatRecovery = (String) industryInfoData.get('heatRecovery') != null && (String) industryInfoData.get('heatRecovery') == 'Yes' ? (String) industryInfoData.get('heatRecovery') : 'No';
                industryInfoWrapperObj.paidBreaks = (String) industryInfoData.get('paidBreaks') != null && (String) industryInfoData.get('paidBreaks') == 'Yes' ? (String) industryInfoData.get('paidBreaks') : 'No';
                industryInfoWrapperObj.rateOfCompensation = (String) industryInfoData.get('rateOfCompensation') != null && (String) industryInfoData.get('rateOfCompensation') == 'Yes' ? (String) industryInfoData.get('rateOfCompensation') : 'No';
                industryInfoWrapperObj.writtenReqDate = (String) industryInfoData.get('writtenReqDate') != null ? cleanDate((String) industryInfoData.get('writtenReqDate')) : null;
                industryInfoWrapperObj.statementDate = (String) industryInfoData.get('statementDate') != null ? cleanDate((String) industryInfoData.get('statementDate')) : null;
                industryInfoWrapperObj.empStatementProvided = (String) industryInfoData.get('empStatementProvided') != null && (String) industryInfoData.get('empStatementProvided') == 'Yes' ? (String) industryInfoData.get('empStatementProvided') : 'No';
                industryInfoWrapperObj.domesticWorkType = (String) industryInfoData.get('domesticWorkType');
                industryInfoWrapperObj.domesticWorkHome = (String) industryInfoData.get('domesticWorkHome');
                industryInfoWrapperObj.domesticRegisteredNurse = (String) industryInfoData.get('domesticRegisteredNurse');
                industryInfoWrapperObj.domesticLiveInWorkHome = (String) industryInfoData.get('domesticLiveInWorkHome') != null && (String) industryInfoData.get('domesticLiveInWorkHome') == 'Yes' ? (String) industryInfoData.get('domesticLiveInWorkHome') : 'No';
                industryInfoWrapperObj.domesticSentByHomeAgency = (String) industryInfoData.get('domesticSentByHomeAgency') != null && (String) industryInfoData.get('domesticSentByHomeAgency') == 'Yes' ? (String) industryInfoData.get('domesticSentByHomeAgency') : 'No';
                industryInfoWrapperObj.personalAttendentWorkType = (String) industryInfoData.get('personalAttendentWorkType');
                industryInfoWrapperObj.personalAttendentWorkHome = (String) industryInfoData.get('personalAttendentWorkHome');
                industryInfoWrapperObj.personalAttendentRegisteredNurse = (String) industryInfoData.get('personalAttendentRegisteredNurse');
                industryInfoWrapperObj.personalAttendentLiveInWorkHome = (String) industryInfoData.get('personalAttendentLiveInWorkHome');
                industryInfoWrapperObj.personalAttendentSentByHomeAgency = (String) industryInfoData.get('personalAttendentSentByHomeAgency');
                industryInfoWrapperObj.facilityPersonalAttendentWorkType = (String) industryInfoData.get('facilityPersonalAttendentWorkType');
                industryInfoWrapperObj.facilityWorkResidential = (String) industryInfoData.get('facilityWorkResidential');
                industryInfoWrapperObj.facilityAttendentRegisteredNurse = (String) industryInfoData.get('facilityAttendentRegisteredNurse');
                industryInfoWrapperObj.listOfDuties = (String) industryInfoData.get('listOfDuties');
                industryInfoWrapperObj.OtherIndividualConstructionTrades = (String) industryInfoData.get('OtherIndividualConstructionTrades');
            }
            
            
            //Employeer Data into Map
            List<Object> employeesDetailsData = (List<Object>) responseWrapper.get('employeesDetails');
            if(employeesDetailsData != null){
                System.debug('employeesDetailsData ::: '+employeesDetailsData);
                String jsonEmpDeatailsString = JSON.serialize(employeesDetailsData);
                System.debug('jsonEmpDeatailsString::'+jsonEmpDeatailsString);
                empClaimWrapperObj = (List<empClaimWrapper>) System.JSON.deserialize(jsonEmpDeatailsString, List<empClaimWrapper>.class);        
                System.debug('empClaimWrapperObj ::: '+empClaimWrapperObj);
            }
            
            //Other Work Location Data into Map
            Map<String, Object> otherWorkLocationData = (Map<String, Object>) responseWrapper.get('otherLocWorkInfo');
            if(otherWorkLocationData != null){
                System.debug('otherWorkLocationData ::: '+otherWorkLocationData);
                
                otherWorkLocationWrapperObj = new otherWorkLocationWrapper();
                otherWorkLocationWrapperObj.workLocationBusinessAddress = (String) otherWorkLocationData.get('workLocationBusinessAddress');
                otherWorkLocationWrapperObj.isBusinessAddressDifferent = (boolean) otherWorkLocationData.get('isBusinessAddressDifferent');
                otherWorkLocationWrapperObj.otherBusinessStreetAddress = (String) otherWorkLocationData.get('otherBusinessStreetAddress');
                otherWorkLocationWrapperObj.otherBusinessCity = (String) otherWorkLocationData.get('otherBusinessCity');
                otherWorkLocationWrapperObj.otherBusinessState = (String) otherWorkLocationData.get('otherBusinessState');
                otherWorkLocationWrapperObj.otherBusinessZipCode = (String) otherWorkLocationData.get('otherBusinessZipCode');
                otherWorkLocationWrapperObj.approximateLocation = (String) otherWorkLocationData.get('approximateLocation');
                otherWorkLocationWrapperObj.countryCode = (String) otherWorkLocationData.get('countryCode');
                otherWorkLocationWrapperObj.otherBusinessPhone = formattedPhone((String) otherWorkLocationData.get('otherBusinessPhone'));
            }
            
            //Label Data into Map
            Map<String, Object> labelData = (Map<String, Object>) responseWrapper.get('labelDetails');
            
            if(labelData != null && String.isNotBlank(claimantEmpWrapperObj.wageClaimSubmitChoice) && claimantEmpWrapperObj.wageClaimSubmitChoice == 'Representative' && String.isNotBlank(industryInfoWrapperObj.isGarmentDutyFollow) && industryInfoWrapperObj.isGarmentDutyFollow == 'Yes'){
                List<Object> labelDetailsData = (List<Object>) labelData.get('labelDetails');
                if(labelDetailsData != null){
                    System.debug('labelDetailsData ::: '+labelDetailsData);
                    String jsonlabelDetailsString = JSON.serialize(labelDetailsData);
                    System.debug('jsonlabelDetailsString::'+jsonlabelDetailsString);
                    LabelDetailsWrapperObj = (List<LabelDetails>) System.JSON.deserialize(jsonlabelDetailsString, List<LabelDetails>.class);        
                    System.debug('LabelDetailsWrapperObj ::: '+LabelDetailsWrapperObj);
                    
                }
            }
            
            //Emp Status And Final Wages Data into Map
            Map<String, Object> empStatusAndFinalWagesData = (Map<String, Object>) responseWrapper.get('employeeStatusAndFinalClaimDetails');
            if(empStatusAndFinalWagesData != null){
                System.debug('empStatusAndFinalWagesData ::: '+empStatusAndFinalWagesData);
                
                empStatusAndFinalWagesWrapperObj = new empStatusAndFinalWagesWrapper();
                empStatusAndFinalWagesWrapperObj.hireDate = (String) empStatusAndFinalWagesData.get('hireDate') != null ? cleanDate((String) empStatusAndFinalWagesData.get('hireDate')) : null;
                empStatusAndFinalWagesWrapperObj.nameOfPersonWhoHiredYou = (String) empStatusAndFinalWagesData.get('nameOfPersonWhoHiredYou');
                empStatusAndFinalWagesWrapperObj.howWereYourWagesPaid = (String) empStatusAndFinalWagesData.get('howWereYourWagesPaid');
                empStatusAndFinalWagesWrapperObj.wereWagesPaid = (String) empStatusAndFinalWagesData.get('wereWagesPaid');
                empStatusAndFinalWagesWrapperObj.statementReceived = (String) empStatusAndFinalWagesData.get('statementReceived');
                empStatusAndFinalWagesWrapperObj.payStubSickRecord = String.isNotBlank((String) empStatusAndFinalWagesData.get('payStubSickRecord')) && (String) empStatusAndFinalWagesData.get('payStubSickRecord') == 'Yes' ? (String) empStatusAndFinalWagesData.get('payStubSickRecord') : 'No';
                empStatusAndFinalWagesWrapperObj.stillIdentifiedEmp = (String) empStatusAndFinalWagesData.get('stillIdentifiedEmp');
                empStatusAndFinalWagesWrapperObj.selectAnyOne = (String) empStatusAndFinalWagesData.get('selectAnyOne');
                empStatusAndFinalWagesWrapperObj.noticeBeforeQuiting = (String) empStatusAndFinalWagesData.get('noticeBeforeQuiting');
                empStatusAndFinalWagesWrapperObj.receivedFinalPayment = (String) empStatusAndFinalWagesData.get('receivedFinalPayment');
                empStatusAndFinalWagesWrapperObj.receivedFinalPayment2 = (String) empStatusAndFinalWagesData.get('receivedFinalPayment2');
                empStatusAndFinalWagesWrapperObj.Explanation = (String) empStatusAndFinalWagesData.get('Explanation');
                empStatusAndFinalWagesWrapperObj.paidByCheck = (String) empStatusAndFinalWagesData.get('paidByCheck');
                empStatusAndFinalWagesWrapperObj.chequeReplaced = (String) empStatusAndFinalWagesData.get('chequeReplaced');
                empStatusAndFinalWagesWrapperObj.chequeReplacedDate = (String) empStatusAndFinalWagesData.get('chequeReplacedDate') != null ? cleanDate((String) empStatusAndFinalWagesData.get('chequeReplacedDate')) : null;
                
                empStatusAndFinalWagesWrapperObj.QuitDateTemplate = (boolean) empStatusAndFinalWagesData.get('QuitDateTemplate');
                empStatusAndFinalWagesWrapperObj.quitDate = (String) empStatusAndFinalWagesData.get('quitDate') != null ? cleanDate((String) empStatusAndFinalWagesData.get('quitDate')) : null;
                
                empStatusAndFinalWagesWrapperObj.finalPaymentDate = (String) empStatusAndFinalWagesData.get('finalPaymentDate') != null ? cleanDate((String) empStatusAndFinalWagesData.get('finalPaymentDate')) : null;
                empStatusAndFinalWagesWrapperObj.finalPaymentExplanation = (String) empStatusAndFinalWagesData.get('finalPaymentExplanation');
                empStatusAndFinalWagesWrapperObj.DischargeDateTemplate = (boolean) empStatusAndFinalWagesData.get('DischargeDateTemplate');
                empStatusAndFinalWagesWrapperObj.dischargedDate = (String) empStatusAndFinalWagesData.get('dischargedDate') != null ? cleanDate((String) empStatusAndFinalWagesData.get('dischargedDate')) : null;
                empStatusAndFinalWagesWrapperObj.personNameWhoDischargeYou = (String) empStatusAndFinalWagesData.get('personNameWhoDischargeYou');
                
                empStatusAndFinalWagesWrapperObj.DateFS2 = (String) empStatusAndFinalWagesData.get('DateFS2') != null ? cleanDate((String) empStatusAndFinalWagesData.get('DateFS2')) : null;
                empStatusAndFinalWagesWrapperObj.dischargedExplanation = (String) empStatusAndFinalWagesData.get('dischargedExplanation');
            }
            
            //WorkWeek And WorkDay Data into Map
            Map<String, Object> workWeekAndWorkDayData = (Map<String, Object>) responseWrapper.get('workWeekAndWorkDaysDetails');
            if(workWeekAndWorkDayData != null){
                System.debug('workWeekAndWorkDayData ::: '+workWeekAndWorkDayData);
                
                workWeekAndWorkDayWrapperObj = new workWeekAndWorkDayWrapper();
                workWeekAndWorkDayWrapperObj.EmpFollowSatToSun = (String) workWeekAndWorkDayData.get('EmpFollowSatToSun');
                workWeekAndWorkDayWrapperObj.EmpDefinedWorkweek = (String) workWeekAndWorkDayData.get('EmpDefinedWorkweek');
                workWeekAndWorkDayWrapperObj.EmpFollowMidnightToMidnight = (String) workWeekAndWorkDayData.get('EmpFollowMidnightToMidnight');
                workWeekAndWorkDayWrapperObj.isEmpFollowMidnightToMidnight = (boolean) workWeekAndWorkDayData.get('isEmpFollowMidnightToMidnight');
                workWeekAndWorkDayWrapperObj.BegDate = (String) workWeekAndWorkDayData.get('BegDate') != null ? cleanTime((String) workWeekAndWorkDayData.get('BegDate')) : null;
                workWeekAndWorkDayWrapperObj.EndDate = (String) workWeekAndWorkDayData.get('EndDate') != null ? cleanTime((String) workWeekAndWorkDayData.get('EndDate')) : null;
            }
            
            //Hours You Typically Worked Data into Map
            Map<String, Object> hoursYouTypicallyWorkedData = (Map<String, Object>) responseWrapper.get('hoursYouTypicallyWorkedDetails');
            if(hoursYouTypicallyWorkedData != null){
                System.debug('hoursYouTypicallyWorkedData ::: '+hoursYouTypicallyWorkedData);
                hoursYouTypicallyWorkedWrapperObj = new hoursYouTypicallyWorkedWrapper();
                hoursYouTypicallyWorkedWrapperObj.workMissedReason = (String) hoursYouTypicallyWorkedData.get('workMissedReason');
                hoursYouTypicallyWorkedWrapperObj.daysMissed = (String) hoursYouTypicallyWorkedData.get('daysMissed');
                hoursYouTypicallyWorkedWrapperObj.whyDaysMissed = (String) hoursYouTypicallyWorkedData.get('whyDaysMissed');
                hoursYouTypicallyWorkedWrapperObj.specifyTypicalyyworked = (String) hoursYouTypicallyWorkedData.get('specifyTypicalyyworked');
                hoursYouTypicallyWorkedWrapperObj.isSameWeekDaysAndHours = (boolean) hoursYouTypicallyWorkedData.get('isSameWeekDaysAndHours');
                hoursYouTypicallyWorkedWrapperObj.isDaysOrWeekVaried = (boolean) hoursYouTypicallyWorkedData.get('isDaysOrWeekVaried');
                hoursYouTypicallyWorkedWrapperObj.isRestPeriodNotfourHours = (boolean) hoursYouTypicallyWorkedData.get('isRestPeriodNotfourHours');
                hoursYouTypicallyWorkedWrapperObj.isMealPeriodNotProvide = (boolean) hoursYouTypicallyWorkedData.get('isMealPeriodNotProvide');
                hoursYouTypicallyWorkedWrapperObj.isWorkMissedDueToIllness = (boolean) hoursYouTypicallyWorkedData.get('isWorkMissedDueToIllness');
                hoursYouTypicallyWorkedWrapperObj.isWorkMissedReason = (boolean) hoursYouTypicallyWorkedData.get('isWorkMissedReason');
                hoursYouTypicallyWorkedWrapperObj.isCompanyHolidayOther = (boolean) hoursYouTypicallyWorkedData.get('isCompanyHolidayOther');
                //hoursYouTypicallyWorkedWrapperObj.overTimeSheet = (String) hoursYouTypicallyWorkedData.get('overTimeSheet');
                if(hoursYouTypicallyWorkedData.get('overTimeSheet') != null && hoursYouTypicallyWorkedData.get('overTimeSheet') != ''){
                    List<Object> uploadedDocList = (List<Object>) hoursYouTypicallyWorkedData.get('overTimeSheet');
                    if(uploadedDocList != null){
                        List<OnlineWageClaimPDFController.overTimeSheet> otsList = new List<OnlineWageClaimPDFController.overTimeSheet>();
                        for(Object obj: uploadedDocList) {
                            OnlineWageClaimPDFController.overTimeSheet ots = new OnlineWageClaimPDFController.overTimeSheet();
                            Map<String, Object> docMap = (Map<String, Object>) obj;
                            if(String.isNotBlank((String)docMap.get('name'))){
                                ots.name = (String)docMap.get('name');
                                otsList.add(ots);
                            }
                        }
                        //hoursYouTypicallyWorkedWrapperObj.overTimeSheet = otsList;
                    }
                }
                hoursYouTypicallyWorkedWrapperObj.otherHolidaySelection = (String) hoursYouTypicallyWorkedData.get('otherHolidaySelection');
                hoursYouTypicallyWorkedWrapperObj.isOverTimeSheetUploaded = (boolean) hoursYouTypicallyWorkedData.get('isOverTimeSheetUploaded');
                hoursYouTypicallyWorkedWrapperObj.selectedHolidayOptions = (List<Object>) hoursYouTypicallyWorkedData.get('selectedHolidayOptions');
                hoursYouTypicallyWorkedWrapperObj.companyHolidaySelection = (List<Object>) hoursYouTypicallyWorkedData.get('companyHolidaySelection');
                String timeEntriesDetailserialize = JSON.serialize(hoursYouTypicallyWorkedData.get('timeEntriesDetail'));
                hoursYouTypicallyWorkedWrapperObj.timeEntriesDetail  = (List<TimeEntriesDetail>)JSON.deserialize(timeEntriesDetailserialize, List<TimeEntriesDetail>.class);
                // hoursYouTypicallyWorkedWrapperObj.timeEntriesDetail = (List<Object>) hoursYouTypicallyWorkedData.get('timeEntriesDetail');
            }
            
            
            //Payment Of Wages Data into Map
            Map<String, Object> paymentOfWagesData = (Map<String, Object>) responseWrapper.get('paymentOfWagesDetails');
            paymentOfWagesWrapperObj = new paymentOfWagesWrapper();
            if(paymentOfWagesData != null){
                //One Hourly Data
                paymentOfWagesWrapperObj.isOneHourlyRate = (boolean) paymentOfWagesData.get('isOneHourlyRate');
                paymentOfWagesWrapperObj.paidAmountPerHour = (String) paymentOfWagesData.get('paidAmountPerHour');
                paymentOfWagesWrapperObj.promisedAmountPerHour = (String) paymentOfWagesData.get('promisedAmountPerHour');
                paymentOfWagesWrapperObj.hourlyRateBegDate = (String) paymentOfWagesData.get('hourlyRateBegDate') != null ? cleanDate((String) paymentOfWagesData.get('hourlyRateBegDate')) : null;
                paymentOfWagesWrapperObj.hourlyRateEndDate = (String) paymentOfWagesData.get('hourlyRateEndDate') != null ? cleanDate((String) paymentOfWagesData.get('hourlyRateEndDate')) : null;
                paymentOfWagesWrapperObj.isOneHourlyAdditionalSection = (boolean) paymentOfWagesData.get('isOneHourlyAdditionalSection');        
                //One Hourly Additional Data    
                String jsonOneHourString = JSON.serialize(paymentOfWagesData.get('hourlyAdditionalDetails'));        
                System.debug('paymentOfWagesData ::: '+JSON.serialize(paymentOfWagesData.get('hourlyAdditionalDetails')));
                System.debug('jsonOneHourString ::: '+String.isNotBlank(jsonOneHourString));
                hourlyAdditionalDetails = (List<powAdditionalWrapper>) System.JSON.deserialize(jsonOneHourString, List<powAdditionalWrapper>.class);        
                System.debug('hourlyAdditionalDetails ::: '+hourlyAdditionalDetails);
                
                //Different Hour Data
                paymentOfWagesWrapperObj.isDifferentHourRate = (boolean) paymentOfWagesData.get('isDifferentHourRate');
                paymentOfWagesWrapperObj.HourlyOptionValue = (boolean) paymentOfWagesData.get('HourlyOptionValue');
                paymentOfWagesWrapperObj.differentHourOptionValue = (boolean) paymentOfWagesData.get('differentHourOptionValue');
                paymentOfWagesWrapperObj.salaryRateOptionValue = (boolean) paymentOfWagesData.get('salaryRateOptionValue');
                paymentOfWagesWrapperObj.commissionRateOptionValue = (boolean) paymentOfWagesData.get('commissionRateOptionValue');
                paymentOfWagesWrapperObj.pieceRateOptionValue = (boolean) paymentOfWagesData.get('pieceRateOptionValue');
                paymentOfWagesWrapperObj.paidAmountDifferentHour = (String) paymentOfWagesData.get('paidAmountDifferentHour');
                paymentOfWagesWrapperObj.promisedAmountDifferentHour = (String) paymentOfWagesData.get('promisedAmountDifferentHour');
                paymentOfWagesWrapperObj.forActivity = (String) paymentOfWagesData.get('forActivity');
                paymentOfWagesWrapperObj.differentHourlyRateBegDate = (String) paymentOfWagesData.get('differentHourlyRateBegDate') != null ? cleanDate((String) paymentOfWagesData.get('differentHourlyRateBegDate')) : null;
                paymentOfWagesWrapperObj.differentHourlyRateEndDate = (String) paymentOfWagesData.get('differentHourlyRateEndDate') != null ? cleanDate((String) paymentOfWagesData.get('differentHourlyRateEndDate')) : null;
                paymentOfWagesWrapperObj.isDifferentHourAdditionalInfoSection = (boolean) paymentOfWagesData.get('isDifferentHourAdditionalInfoSection');
                //Different Hour Additional Data    
                String jsonDifferentHourString = JSON.serialize(paymentOfWagesData.get('differentHourAdditionalDetails'));        
                System.debug('paymentOfWagesData ::: '+JSON.serialize(paymentOfWagesData.get('differentHourAdditionalDetails')));
                System.debug('jsonDifferentHourString ::: '+String.isNotBlank(jsonDifferentHourString));
                differentHourAdditionalDetails = (List<powDifferentHourAdditionalWrapper>) System.JSON.deserialize(jsonDifferentHourString, List<powDifferentHourAdditionalWrapper>.class);        
                System.debug('differentHourAdditionalDetails ::: '+differentHourAdditionalDetails);
                
                //Salary Rate Data
                paymentOfWagesWrapperObj.isSalaryRateForEachDay = (boolean) paymentOfWagesData.get('isSalaryRateForEachDay');
                paymentOfWagesWrapperObj.paidAmountForEachDay = (String) paymentOfWagesData.get('paidAmountForEachDay');
                paymentOfWagesWrapperObj.promisedAmountForEachDay = (String) paymentOfWagesData.get('promisedAmountForEachDay');
                paymentOfWagesWrapperObj.frequencyOfEachDay = (String) paymentOfWagesData.get('frequencyOfEachDay') != null ? cleanDate((String) paymentOfWagesData.get('frequencyOfEachDay')) : null;
                paymentOfWagesWrapperObj.eachPayRateBegDate = (String) paymentOfWagesData.get('eachPayRateBegDate') != null ? cleanDate((String) paymentOfWagesData.get('eachPayRateBegDate')) : null;
                paymentOfWagesWrapperObj.eachPayRateEndDate = (String) paymentOfWagesData.get('eachPayRateEndDate') != null ? cleanDate((String) paymentOfWagesData.get('eachPayRateEndDate')) : null;
                
                paymentOfWagesWrapperObj.isSalaryRateAdditionalSection = (boolean) paymentOfWagesData.get('isSalaryRateAdditionalSection');
                //Salary Rate Additional Data    
                String jsonSalaryRateString = JSON.serialize(paymentOfWagesData.get('salaryRateAdditionalDetails'));        
                System.debug('paymentOfWagesData ::: '+JSON.serialize(paymentOfWagesData.get('salaryRateAdditionalDetails')));
                System.debug('jsonSalaryRateString ::: '+String.isNotBlank(jsonSalaryRateString));
                salaryRateAdditionalDetails = (List<powSalaryRateAdditionalWrapper>) System.JSON.deserialize(jsonSalaryRateString, List<powSalaryRateAdditionalWrapper>.class);        
                System.debug('salaryRateAdditionalDetails ::: '+salaryRateAdditionalDetails);
                
                //Commission Rate
                paymentOfWagesWrapperObj.isCommissionRate = (boolean) paymentOfWagesData.get('isCommissionRate');
                paymentOfWagesWrapperObj.writtenCommission = String.isNotBlank((String) paymentOfWagesData.get('writtenCommission')) && (String) paymentOfWagesData.get('writtenCommission') == 'Yes' ? (String) paymentOfWagesData.get('writtenCommission') : 'No';
                paymentOfWagesWrapperObj.isWrittenCommission = (boolean) paymentOfWagesData.get('isWrittenCommission');
                
                String jsonCommissionRateString = JSON.serialize(paymentOfWagesData.get('agreementDocs'));  
                agreementDocsDetails = (List<agreementDocsWrapper>) System.JSON.deserialize(jsonCommissionRateString, List<agreementDocsWrapper>.class);        
                
                
                //Piece Rate Data
                paymentOfWagesWrapperObj.isPieceRate = (boolean) paymentOfWagesData.get('isPieceRate');
                paymentOfWagesWrapperObj.paidPieceRate = (String) paymentOfWagesData.get('paidPieceRate');
                paymentOfWagesWrapperObj.promisedPieceRate = (String) paymentOfWagesData.get('promisedPieceRate'); 
                paymentOfWagesWrapperObj.perUnitPaymentOfWages = (String) paymentOfWagesData.get('perUnitPaymentOfWages');
                paymentOfWagesWrapperObj.other = (String) paymentOfWagesData.get('other');
                paymentOfWagesWrapperObj.numberOfUnits = (String) paymentOfWagesData.get('numberOfUnits');
                paymentOfWagesWrapperObj.pieceRateBegDate = (String) paymentOfWagesData.get('pieceRateBegDate') != null ? cleanDate((String) paymentOfWagesData.get('pieceRateBegDate')) : null;
                paymentOfWagesWrapperObj.pieceRateEndDate = (String) paymentOfWagesData.get('pieceRateEndDate') != null ? cleanDate((String) paymentOfWagesData.get('pieceRateEndDate')) : null;
                paymentOfWagesWrapperObj.pieceRateTotalEarned = (String) paymentOfWagesData.get('pieceRateTotalEarned');
                paymentOfWagesWrapperObj.pieceRateTotalPaid = (String) paymentOfWagesData.get('pieceRateTotalPaid');
                paymentOfWagesWrapperObj.isProvidePriceRate = (boolean) paymentOfWagesData.get('isProvidePriceRate');
                paymentOfWagesWrapperObj.isPieceRateAdditionalSection = (boolean) paymentOfWagesData.get('isPieceRateAdditionalSection');
                
                //Piece Rate Additional Data    
                String jsonPieceRateString = JSON.serialize(paymentOfWagesData.get('pieceRateAdditionalDetails'));        
                System.debug('paymentOfWagesData ::: '+JSON.serialize(paymentOfWagesData.get('pieceRateAdditionalDetails')));
                System.debug('jsonPieceRateString ::: '+String.isNotBlank(jsonPieceRateString));
                pieceRateAdditionalDetails = (List<powPieceRateAdditionalWrapper>) System.JSON.deserialize(jsonPieceRateString, List<powPieceRateAdditionalWrapper>.class);        
                System.debug('pieceRateAdditionalDetails ::: '+pieceRateAdditionalDetails);
            }
            
            
            //Cerificate And Auth
            Map<String, Object> claimantCertification = (Map<String, Object>) responseWrapper.get('certAndAuthDetails');
            if(claimantCertification != null){
                System.debug('claimantCertification ::: '+claimantCertification);
                CertificationAndAuthObj = new CertificationAndAuth();
                CertificationAndAuthObj.claimantName = (String)claimantCertification.get('claimantName');
                CertificationAndAuthObj.claimDate = (String) claimantCertification.get('claimDate') != null ? cleanDate((String) claimantCertification.get('claimDate')) : null;
                system.debug('CertificationAndAuth'+CertificationAndAuthObj.claimDate);
                List<Object> certAndAuthObj = (List<Object>) claimantCertification.get('addtionalClaimDocs');
                List<String> certAndAuthList = new List<String>();
                if(certAndAuthObj != null && certAndAuthObj.size()>0){
                    for(Object certificationAnd : certAndAuthObj){
                        Map<String, Object> newclaimantAuthMap = (Map<String, Object>) certificationAnd;
                        certAndAuthList.add((String)newclaimantAuthMap.get('name'));
                    }
                    CertificationAndAuthObj.certificationDocs = certAndAuthList;
                }
            }
            
            String caseIssue;
            //Get case issues data from json
            List<object> caseIssueDetails = (List<object>) responseWrapper.get('caseIssues');
            if(caseIssueDetails != null && caseIssueDetails.size() > 0){
                caseIssue = JSON.serialize(caseIssueDetails);
            }
            
            if(caseIssue != null){
                violationTypeVariables = (List<violationTypeVariables>) System.JSON.deserialize(caseIssue, List<violationTypeVariables>.class);
            }
            
        }catch (Exception e) {
            system.debug('e.getMessage(): '+e.getMessage());
            system.debug('Error line: '+e.getLineNumber());
            system.debug('Stack line: '+e.getStackTraceString());
            
            //new OWCServiceUtility().Log(e);
            
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            new OWCServiceUtility().Log(e);
            /**wageClaimWrapper wcWrapper = new wageClaimWrapper();
            wcWrapper.isSuccess = false;
            wcWrapper.fullErrorMsg = errorMessage+e.getStackTraceString();
            wcWrapper.error = Label.owcWageClaimSubmitError;
            return wcWrapper;**/
            //throw new AuraHandledException(errorMessage+e.getStackTraceString());
        }
    }
    
    public class wageClaimWrapper{
        @auraenabled
        public String caseId;
        @auraenabled
        public boolean isSuccess;
        @auraenabled
        public String error;
        @auraenabled
        public String fullErrorMsg;
    }
    
    public String cleanDate(String theDate){
        try{
            theDate = theDate.replaceAll('/', '-');
            String [] s = theDate.split('-');           
            if(s.size() == 3){
                String newMonth= '';
                if(s[1].length() == 1){
                    newMonth = '0'+s[1];
                }else{
                    newMonth = s[1];
                }
                
                String newDate = newMonth+'/'+s[2]+'/'+s[0];
                return newDate;
            }
        }        
        catch (Exception e) {
            system.debug('e.getMessage(): '+e.getMessage());
            system.debug('Error line: '+e.getLineNumber());
            system.debug('Stack line: '+e.getStackTraceString());
            
            //new OWCServiceUtility().Log(e);
            
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            throw new AuraHandledException(errorMessage+e.getStackTraceString());
        }
        return null;
    }
    
    public static String cleanTime(String timeValue){
        try{
            if(String.isBlank(timeValue)){
            return timeValue;
        } else{
            List<String> timeValueList = timeValue.split(':');
            try{
                if(Integer.valueOf(timeValueList[0]) > 12){
                    Integer hourTime = Integer.valueOf(timeValueList[0]) - 12;
                    String timeValueUpdated = String.valueOf(hourTime) +':'+ timeValueList[1]+' PM';
                    return timeValueUpdated;
                } else if(Integer.valueOf(timeValueList[0]) == 12){
                    String timeValueUpdated = timeValueList[0] +':'+ timeValueList[1]+' PM'; 
                    return timeValueUpdated;
                }  else{
                    String timeValueUpdated = timeValueList[0] +':'+ timeValueList[1]+' AM'; 
                    return timeValueUpdated;
                }
            }catch(exception ex){
                return timeValue;
            }
            
        }
    }catch (Exception e) {
            system.debug('e.getMessage(): '+e.getMessage());
            system.debug('Error line: '+e.getLineNumber());
            system.debug('Stack line: '+e.getStackTraceString());
            
            //new OWCServiceUtility().Log(e);
            
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            throw new AuraHandledException(errorMessage+e.getStackTraceString());
        }
    }
    
    public class violationTypeVariables {
		public String violationTypeName{get;set;}	//Double Time issue
		public violationVariables[] violationVariables{get;set;}
	}
    
	public class violationVariables {
		public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;}	//Start date of the claim.
		public String dataType{get;set;}	//String
		public String Value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}
	}
    
    public class claimantEmployeeWrapper{
        public String wageClaimSubmitChoice{get;set;} // 1. Are you submitting a wage claim for yourself or on behalf of the claimant?
        public String countryCodeindividualRepPhone{get;set;}
        public String countryCodelawfirmRepStatePhone{get;set;}
        public String yourselfFirstName{get;set;} // Yourself First Name
        public String yourselfMiddleName{get;set;} // Yourself Middle Name
        public String yourselfLastName{get;set;} // Yourself Last Name
        public String yourselfBirthDate{get;set;} // Yourself BirthDate
        public String countryCodeyourselfCellPhone{get;set;}
        public String countryCodeyourselfHomePhone{get;set;}
        public String yourselfCellPhone{get;set;} // Yourself CellPhone
        public Boolean yourselfTextMsg{get;set;} // Yourself Text Message
        public String yourselfHomePhone{get;set;} // Yourself Home Phone
        public String yourselfEmail{get;set;} // Yourself Email
        public String yourselfStreetAddress{get;set;} // Yourself Street Address
        public String yourselfCity{get;set;} // Yourself City
        public String yourselfState{get;set;} // Yourself State
        public String yourselfZipCode{get;set;} // Yourself Zip Code
        public String needLanguageInterpreter{get;set;} // Need Language Interpreter 
        public String prefferedLanguageSelection{get; set;} // Preffered Language Selection
        public String otherPrefferedLanguage{get;set;} // Other Language
        public String representativeAdvocateType{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                Map<String, OWCRepresentationAdvocateType__mdt> mapObj = OWCRepresentationAdvocateType__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).Value__c == representativeAdvocateType){
                        spanishTranslation = mapObj.get(obj).English_Translation__c;
                    }
                }
                return representativeAdvocateType;
            }
            else{
                Map<String, OWCRepresentationAdvocateType__mdt> mapObj = OWCRepresentationAdvocateType__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).Value__c == representativeAdvocateType){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;} // Representative Advocate Type Picklist
        public boolean isRepresentative{get;set;} // Representative
        public boolean isYourself{get;set;} // Yourself
        public boolean isIndividualRepresentation{get;set;}
        public String individualRepFirstName{get;set;} // Individual First Name
        public String individualRepLastName{get;set;} // Individual Last Name
        public String individualRepStreetAddress{get;set;} // Individual Street Address
        public String individualRepCity{get;set;} // Individual City
        public String individualRepState{get;set;} // Individual State
        public String individualRepZipCode{get;set;} // Individual Zip Code
        public String individualRepPhone{get;set;} // Individual Phone
        public String individualRepPhoneType{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return individualRepPhoneType;
            }
            else{
                Map<String, OWCIndividualRepresentativePhoneType__mdt> mapObj = OWCIndividualRepresentativePhoneType__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == individualRepPhoneType){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;} // Individual Phone Type
        public String individualRepEmail{get;set;} // Individual Email
        public String individualRepWebsite{get;set;} // Individual Website
        public String individualRepClaimantRelationship{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return individualRepClaimantRelationship;
            }
            else{
                Map<String, OWCIndividualRepClaimantRelationship__mdt> mapObj = OWCIndividualRepClaimantRelationship__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == individualRepClaimantRelationship){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;} // Individual Claimant Relationship
        public boolean isLawFirmRepresentation{get;set;}
        public String lawfirmRepBusinessName{get;set;} // Law Firm/Organization Business Name
        public String lawfirmRepAttorney{get;set;} // Law Firm/Organization Attorney/Representative Name
        public String lawfirmRepStreetAddress{get;set;} // Law Firm/Organization Street Address
        public String lawfirmRepCity{get;set;} // Law Firm/Organization City
        public String lawfirmRepState{get;set;} // Law Firm/Organization State
        public String lawFirmRepZipCode{get;set;} // Law Firm/Organization Zip Code
        public String lawfirmRepStatePhone{get;set;} // Law Firm/Organization Phone
        public String lawfirmRepEmail{get;set;} // Law Firm/Organization Email
        public String lawfirmRepWebsite{get;set;} // Law Firm/Organization Website
        public boolean isClaimantConfirmation{get;set;} // Is Claimant Confirmation checkbox checked
        public List<String> claimantConfirmUploadedDocs{get;set;} // Claimant Uploaded docs
    }
    
    //Industry Info Wrapper
    public class industryInfoWrapper{
        public String selectedIndustry{get;set;}//Selected Industry
        public String selectedOption{get;set;}//Seledcted sub industry
        public String isGarmentDutyFollow{get;set;}
        public String farmWorker{get;set;}
        public String heatRecovery{get;set;}
        public String paidBreaks{get;set;}
        public String rateOfCompensation{get;set;}
        public String writtenReqDate{get;set;}
        public String statementDate{get;set;}
        public String empStatementProvided{get;set;}
        public String domesticWorkType{get;set;}
        public String domesticWorkHome{get;set;}
        public String domesticRegisteredNurse{get;set;}
        public String domesticLiveInWorkHome{get;set;}
        public String domesticSentByHomeAgency{get;set;}
        public String personalAttendentWorkType{get;set;}
        public String personalAttendentWorkHome{get;set;}
        public String personalAttendentRegisteredNurse{get;set;}
        public String personalAttendentLiveInWorkHome{get;set;}
        public String personalAttendentSentByHomeAgency{get;set;}
        public String facilityPersonalAttendentWorkType{get;set;}
        public String facilityWorkResidential{get;set;}
        public String facilityAttendentRegisteredNurse{get;set;}
        public String listOfDuties{get;set;}
        public String OtherIndividualConstructionTrades{get;set;}
    }
    //Mileage Claim Details Wrapper
    public class mileageClaimDetails {
        public String additinalPersonFirstName{get;set;}    
        public String additinalPersonLastName{get;set;} 
        public String claimantRelatedRoleActions{get;set;}
        public Integer sectionId{get;set;}
    }
    //Emp Name Changed Wrapper
    public class employerNameChangedDetails {
        public boolean uspsProceedAddress{get;set;}
        public boolean isUSPSAddressCheck{get;set;}
        public boolean isUSPSAddressSuccessTemplate{get;set;}
        public boolean isUSPSAddressErrorTemplate{get;set;}
        public boolean uspsCurrentAddressCheck{get;set;}
        public boolean isUPSPAddressValid{get;set;}
        public boolean isUSPSAddressInvalid{get;set;}
        public boolean isDontKnow{get;set;}
        public boolean IsOtherIndividual{get;set;}
        public String OtherIndividualWebsite{get;set;}  //.com.com
        public String OtherIndividualVehicleLicense{get;set;}   //76576811
        public String OtherIndividualEmail{get;set;}    //demo@demo.com
        public String OtherIndividualPhone{get;set;}    //01234567890
        public String OtherIndividualState{get;set;}    //CA
        public String OtherIndividualCity{get;set;} //New Delhi
        public String OtherIndividualStreetAddress{get;set;}    //UnKnown
        public String OtherIndividualBusinessName{get;set;} //hgh
        public String individualState{get;set;} //CA
        public String OtherIndividualZipCode{get;set;}
        public String countryCodeindividualBusinessPhone{get;set;}  //+1
        public String countryCodeindividualCellPhone{get;set;}  //+1
        public String countryCodeOtherIndividualPhone{get;set;} //+1
        public boolean showIndividualSole{get;set;}
        public String otherPleaseExplain{get;set;}  //2nd SUb part
        public String representativeEmployerType{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return representativeEmployerType;
            }
            else{
                Map<String, OWC_Employer_Business_Type__mdt> mapObj = OWC_Employer_Business_Type__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == representativeEmployerType){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}  //Other / I dont know
        public boolean IsOther{get;set;}
        public boolean isIndividualStatePicklist{get;set;}
        public boolean isOtherIndividualPicklist{get;set;}
        public boolean isClaimantAdvocate{get;set;}
        public boolean IsIndividual{get;set;}
        public Integer additionalTotalEmployees{get;set;}
        public String individualFirstName{get;set;}
        public String individualLastName{get;set;}
        public String individualStreetAddress{get;set;}
        public String individualCity{get;set;}
        public boolean IsAdditionalInfo{get;set;}
        public String  individualZipCode{get;set;}
        public String individualBusinessPhone{get {
            return formattedPhone(OtherIndividualPhone); 
        }set;}
        public String individualCellPhone{get{
            return formattedPhone(individualCellPhone); 
        }set;}
        public String individualEmail{get;set;}
        public String individualVehicleLicense{get;set;}
        public String individualWebsite{get;set;}
        
    }
    //SuccessorDeatils 
    public class successorDetails {
        public List<successorDetails> successorDetails{get;set;}
        public Integer length{get;set;}
        public employerNameAfterEmployementDetails employerNameAfterEmployementDetails{get;set;}
        public String ownershipOfCompRelated{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return ownershipOfCompRelated;
            }
            else{
                Map<String, OWC_Successor_Ownership_Type__mdt> mapObj = OWC_Successor_Ownership_Type__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == ownershipOfCompRelated){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}
        public String workWithSameWorokers{get;set;}
        public String workForThisComp{get;set;}
        public String labelDetails{get;set;}
        public boolean isDontKnow{get;set;}
        public boolean IsOtherIndividual{get;set;}
        public String OtherIndividualWebsite{get;set;}  //.com.com
        public String OtherIndividualVehicleLicense{get;set;}   //76576811
        public String OtherIndividualEmail{get;set;}    //demo@demo.com
        public String OtherIndividualPhone{get;set;}    //01234567890
        public String OtherIndividualState{get;set;}    //CA
        public String OtherIndividualCity{get;set;} //New Delhi
        public String OtherIndividualStreetAddress{get;set;}    //UnKnown
        public String OtherIndividualBusinessName{get;set;} //hgh
        public String individualState{get;set;} //CA
        public String OtherIndividualZipCode{get;set;}
        public String countryCodeindividualBusinessPhone{get;set;}  //+1
        public String countryCodeindividualCellPhone{get;set;}  //+1
        public String countryCodeOtherIndividualPhone{get;set;} //+1
        public boolean showIndividualSole{get;set;}
        public String otherPleaseExplain{get;set;}  //2nd SUb part
        public String representativeEmployerType{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return representativeEmployerType;
            }
            else{
                Map<String, OWC_Employer_Business_Type__mdt> mapObj = OWC_Employer_Business_Type__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == representativeEmployerType){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}  //Other / I dont know
        public boolean IsOther{get;set;}
        public boolean isIndividualStatePicklist{get;set;}
        public boolean isOtherIndividualPicklist{get;set;}
        public boolean isClaimantAdvocate{get;set;}
        public boolean IsIndividual{get;set;}
        public Integer additionalTotalEmployees{get;set;}
        public String individualStreetAddress{get;set;}
        
    }
    //Employer Name After EMployement Details Wrapper 
    public class employerNameAfterEmployementDetails {
        public boolean uspsProceedAddress{get;set;}
        public boolean isUSPSAddressCheck{get;set;}
        public boolean isUSPSAddressSuccessTemplate{get;set;}
        public boolean isUSPSAddressErrorTemplate{get;set;}
        public boolean uspsCurrentAddressCheck{get;set;}
        public boolean isUPSPAddressValid{get;set;}
        public boolean isUSPSAddressInvalid{get;set;}
        public boolean isDontKnow{get;set;}
        public boolean IsOtherIndividual{get;set;}
        public String otherPleaseExplain{get;set;}
        public String OtherIndividualWebsite{get;set;}  //.com.com
        public String OtherIndividualVehicleLicense{get;set;}   //76576811
        public String OtherIndividualEmail{get;set;}    //demo@demo.com
        public String OtherIndividualPhone{get;set;}    //01234567890
        public String OtherIndividualZipCode{get;set;}
        public String OtherIndividualState{get;set;}    //CA
        public String OtherIndividualCity{get;set;} //New Delhi
        public String OtherIndividualStreetAddress{get;set;}    //UnKnown
        public String OtherIndividualBusinessName{get;set;} //yufjy
        public String individualState{get;set;} //CA
        public boolean showIndividualSole{get;set;}
        public String representativeEmployerType{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return representativeEmployerType;
            }
            else{
                Map<String, OWC_Employer_Business_Type__mdt> mapObj = OWC_Employer_Business_Type__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == representativeEmployerType){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}  //Corporation
        public String countryCodeOtherIndividualPhone{get;set;} //+1
        public String countryCodeindividualCellPhone{get;set;}  //+1
        public String countryCodeindividualBusinessPhone{get;set;}  //+1
        public boolean IsOther{get;set;}
        public boolean isIndividualStatePicklist{get;set;}
        public boolean isOtherIndividualPicklist{get;set;}
        public boolean isClaimantAdvocate{get;set;}
        public boolean IsIndividual{get;set;}
        public Integer additionalTotalEmployees{get;set;}
        public String individualFirstName{get;set;}
        public String individualLastName{get;set;}
        public String individualStreetAddress{get;set;}
        public String individualCity{get;set;}
        public boolean IsAdditionalInfo{get;set;}
        public String  individualZipCode{get;set;}
        public String individualBusinessPhone{get {
            return formattedPhone(individualBusinessPhone);
        }  set;}
        public String individualCellPhone{get;set;}
        public String individualEmail{get;set;}
        public String individualVehicleLicense{get;set;}
        public String individualWebsite{get;set;}
        
    }
    //Upload Employeer Additional Documents
    public class uploadedEmployerAdditionalDocuments {
        public String name{get;set;}    //sample.pdf
        public String documentId{get;set;}  //06935000001Z4VXAA0
        public String contentVersionId{get;set;}    //06835000001Z0UcAAK
    }
    //Employeer Verification upload doc
    public class employerVerificationUploadDoc {
        public String contentVersionId{get;set;}    //06835000001Z0UlAAK
        public String documentId{get;set;}  //06935000001Z4VgAAK
        public String name{get;set;}    //sample.pdf
    }
    //Employeer Verification upload doc
    public class overTimeSheet {
        public String contentVersionId{get;set;}    //06835000001Z0UlAAK
        public String documentId{get;set;}  //06935000001Z4VgAAK
        public String name{get;set;}    //sample.pdf
    }
    //Employee
    public class empClaimWrapper{
        public List<mileageClaimDetails> mileageClaimDetails{get{
            if(mileageClaimDetails != null && mileageClaimDetails.size() >0){
                return mileageClaimDetails;
            } else{
                return null;
            }
        }set;}
        public boolean showNameHeader{get;set;}
        public employerNameChangedDetails employerNameChangedDetails{get;set;}
        public String countryCodeindividualBusinessPhone{get;set;}
        public String countryCodeindividualCellPhone{get;set;}
        public String countryCodeOtherIndividualPhone{get;set;}
        public String employerChangedName{get{
            if(String.isNotBlank(employerChangedName) && employerChangedName == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public boolean isEmployerChangedName{get;set;}
        public boolean isOfficeLocatorMail{get;set;}
        public boolean IsIndividual{get;set;}
        public boolean isClaimantAdvocate{get;set;}
        public boolean isOtherIndividualPicklist{get;set;}
        public boolean isIndividualStatePicklist{get;set;}
        public Integer employerAdditionalUploadDocSize{get;set;}
        public List<employerVerificationUploadDoc> employerVerificationUploadDoc{get;set;}
        public List<uploadedEmployerAdditionalDocuments> uploadedEmployerAdditionalDocuments{get;set;}
        /*
public boolean isEmployerAdditionalDoc{get;set;}
public String uploadUnionContractDocument{get;set;}
public boolean isEmployerDocUpload{get;set;}
*/
        public boolean IsOther{get;set;}
        public boolean isEmployerSellingAssets{get;set;}
        public String additionalWHOPaidYou{get;set;}
        
        public String owcWorkRecordList{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return owcWorkRecordList;
            }
            else{
                Map<String, OWC_WorkRecorded__mdt> mapObj = OWC_WorkRecorded__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == owcWorkRecordList){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}
        public String additionalBankName{get;set;}
        public String representativeEmployerType{get {
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return representativeEmployerType;
            }
            else{
                Map<String, OWC_Employer_Business_Type__mdt> mapObj = OWC_Employer_Business_Type__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == representativeEmployerType){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}
        public boolean showIndividualSole{get;set;}
        public String individualFirstName{get;set;}
        public String individualLastName{get;set;}
        public String individualStreetAddress{get;set;}
        public String individualCity{get;set;}
        public String individualState{get;set;}
        public boolean IsAdditionalInfo{get;set;}
        public String  individualZipCode{get;set;}
        public String individualBusinessPhone{get;set;}
        public String individualCellPhone{get;set;}
        public String individualEmail{get;set;}
        public String individualVehicleLicense{get;set;}
        public String individualWebsite{get;set;}
        public String otherPleaseExplain{get;set;}
        public String OtherIndividualBusinessName{get;set;}
        public String OtherIndividualStreetAddress{get;set;}
        public String OtherIndividualCity{get;set;}
        public String OtherIndividualState{get;set;}
        public String OtherIndividualZipCode{get;set;}
        public String OtherIndividualPhone{get {
            return formattedPhone(OtherIndividualPhone);
        }set;}
        public String OtherIndividualEmail{get;set;}
        public String OtherIndividualVehicleLicense{get;set;}
        public String OtherIndividualWebsite{get;set;}
        public boolean isUnionDocumentFileUploaded{get;set;}
        public boolean isFileUploadedAdditional{get;set;}
        public String additionalName{get;set;}
        public String additionalJobTitle{get;set;}
        public String additionalDifferentPerson{get;set;}
        
        
        
        public String additionalSignTimeCard{get{
            if(String.isNotBlank(additionalSignTimeCard) && additionalSignTimeCard == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public String additionalSomeoneElse{get;set;}
        public String additionalTotalEmployees{get;set;}
        public String additionalEmpBusiness{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return additionalEmpBusiness;
            }
            else{
                Map<String, OWCPreliminaryCovid19Claim__mdt> mapObj = OWCPreliminaryCovid19Claim__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == additionalEmpBusiness){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}
        public String additionalBankruptcy{get{
            if(String.isNotBlank(additionalBankruptcy) && additionalBankruptcy == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public boolean IsOtherIndividual{get;set;}
        public String unionContractCovering{get{
            if(String.isNotBlank(unionContractCovering) && unionContractCovering == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public String retaliationComplain{get{
            if(String.isNotBlank(retaliationComplain) && retaliationComplain == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public boolean isRetaliationComplain{get;set;}
        public String complainFiledDate{get {
            return OnlineWageClaimPDFController.cleanDateStatic(complainFiledDate);
        }set;}
        public String complainCaseNumber{get;set;}
        public String urlAddress{get;set;}
        public boolean isUnionContractCovered{get;set;}
        public String unionContractCovered{get;set;}
        public String filingWageClaim{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return filingWageClaim;
            }
            else{
                Map<String, OWCPreliminaryCovid19Claim__mdt> mapObj = OWCPreliminaryCovid19Claim__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == filingWageClaim){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}
        public boolean isEmployeeFilingWageClaim{get;set;}
        public String specifyFilingWageClaim{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return specifyFilingWageClaim;
            }
            else{
                Map<String, OWCPreliminarySpecifyCovidClaim__mdt> mapObj = OWCPreliminarySpecifyCovidClaim__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == specifyFilingWageClaim){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}
        
        //* 
        public String covid19Claim{get{
            if(String.isNotBlank(covid19Claim) && covid19Claim == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public boolean isEmployeeFilingWageClaimOther{get;set;}
        public String specifyOtherReason{get;set;}
        public boolean isDontKnow{get;set;}
        public boolean isUnionContractDocumentUpload{get;set;}
        public boolean isUrlAddress{get;set;}
        public boolean isMailToOfficeLocator{get;set;}
        public boolean isclaimantgarment{get;set;}
        public String startingDate{get {
            return OnlineWageClaimPDFController.cleanDateStatic(startingDate);
        }set;}
        public String endingDate{get {
            return OnlineWageClaimPDFController.cleanDateStatic(endingDate);
        }set;}
        public String employerChangedNameAfterEmployement{get;set;}
        public boolean isEmployerChangedNameAfterEmployement{get;set;}
        //*/
        public successorDetails successorDetails{get;set;}
    }
    //Other work location wrapper
    public class otherWorkLocationWrapper{
        public String workLocationBusinessAddress{get{
            if(String.isNotBlank(workLocationBusinessAddress) && workLocationBusinessAddress == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public boolean isBusinessAddressDifferent{get;set;}
        public String otherBusinessStreetAddress{get;set;}
        public String otherBusinessCity{get;set;}
        public String otherBusinessState{get;set;}
        public String otherBusinessZipCode{get;set;}
        public String approximateLocation{get;set;}
        public String countryCode{get;set;}
        public String otherBusinessPhone{get;set;}
    }
    
    //UploadRNDocument Wrapper
    public class UploadRNDocument {
        public String name{get;set;}
        public String documentId{get;set;}
        public String contentVersionId{get;set;}
    }
    //Label Wrapper
    public LabelDetails_Z labelDetails{get;set;}
    
    public class LabelDetails_Z {
        public LabelDetails[] LabelDetails{get;set;}
    }
    
    public class LabelDetails {
        public Integer sectionId{get;set;}
        public String labelName{get;set;}
        public String labelGarmentDescription{get;set;}
        public String labelGarmentsDuration{get;set;}
        public boolean isOther{get;set;}
        public String Other{get;set;}
        public String labelGarmentDelAddCompName{get;set;}
        public String labelPersonVisit{get;set;}
        public String labelTheyWereWorking{get;set;}
        public String labelWhatTheySay{get;set;}
        public String labelWhatIfMistakFound{get;set;}
        public String labelWorkOverTime{get;set;}
        public String superVisorCheck{get{
            if(String.isNotBlank(superVisorCheck) && superVisorCheck == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public boolean isSuperVisorCheck{get;set;}
        public String labelWorkOverTimeDeadline{get;set;}
        public String labelPriority{get;set;}
        public String labelStartDate{get {
            return OnlineWageClaimPDFController.cleanDateStatic(labelStartDate);
        }set;}
        public String labelEndDate{get {
            return OnlineWageClaimPDFController.cleanDateStatic(labelEndDate);
        }set;}
        public Boolean islabelPercPerDay{get;set;}
        public String namePersonVisit{get;set;}
        public String sampleOfGarment{get{
            if(String.isNotBlank(sampleOfGarment) && sampleOfGarment == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public String labelGarmentDelAdd{get;set;}
        public String labelPercPerDay{get;set;}
        public String labelPercProvided{get;set;}
        public Integer uploadFileSize{get;set;}
        public List<UploadRNDocument> uploadRNDocument{get;set;}
        public Boolean isFileUploaded{get;set;}
    }
    
    //Emp Status And Final Wages Wrapper
    public class empStatusAndFinalWagesWrapper{
        public String hireDate{get;set;}
        public String nameOfPersonWhoHiredYou{get;set;}
        public String howWereYourWagesPaid{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return howWereYourWagesPaid;
            }
            else{
                Map<String, OWCWagesPaidType__mdt> mapObj = OWCWagesPaidType__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == howWereYourWagesPaid){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}
        public String Explanation{get;set;}
        public String paidByCheck{get{
            if(String.isNotBlank(paidByCheck) && paidByCheck == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public String chequeReplaced{get;set;}
        public String chequeReplacedDate{get;set;}
        public String wereWagesPaid{get{
            if(String.isNotBlank(wereWagesPaid) && wereWagesPaid == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public String statementReceived{get{
            if(String.isNotBlank(statementReceived) && statementReceived == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public String payStubSickRecord{get{
            if(String.isNotBlank(payStubSickRecord) && payStubSickRecord == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public String stillIdentifiedEmp{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return stillIdentifiedEmp;
            }
            else{
                Map<String, OWCEmployementStatusAndFinalWageOptions__mdt> mapObj = OWCEmployementStatusAndFinalWageOptions__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == stillIdentifiedEmp){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}
        public String selectAnyOne{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return selectAnyOne;
            }
            else{
                Map<String, owcQuitDateDischargeDate__mdt> mapObj = owcQuitDateDischargeDate__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == selectAnyOne){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}
        public boolean QuitDateTemplate{get;set;}
        public String quitDate{get;set;}
        public String noticeBeforeQuiting{get{
            if(String.isNotBlank(noticeBeforeQuiting) && noticeBeforeQuiting == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public String receivedFinalPayment{get{
            if(String.isNotBlank(receivedFinalPayment) && receivedFinalPayment == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public String finalPaymentDate{get;set;}
        public String finalPaymentExplanation{get;set;}
        public boolean DischargeDateTemplate{get;set;}
        public String dischargedDate{get;set;}
        public String personNameWhoDischargeYou{get;set;}
        public String receivedFinalPayment2{get{
            if(String.isNotBlank(receivedFinalPayment2) && receivedFinalPayment2 == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public String DateFS2{get;set;}
        public String dischargedExplanation{get;set;}
    }
    
    //Hours You Typically Worked Wrapper
    public class hoursYouTypicallyWorkedWrapper{
        public String workMissedReason{get;set;}
        public String daysMissed{get;set;}
        public String whyDaysMissed{get;set;}
        public String specifyTypicalyyworked{get;set;}
        public List<Object> selectedHolidayOptions{get{
            if(selectedHolidayOptions != null && selectedHolidayOptions.size() >0){
                return selectedHolidayOptions;
            } else{
                return null;
            }
        }set;}
        public boolean isSameWeekDaysAndHours{get;set;}
        public boolean isDaysOrWeekVaried{get;set;}
        public boolean isRestPeriodNotfourHours{get;set;}
        public boolean isMealPeriodNotProvide{get;set;}
        public boolean isWorkMissedDueToIllness{get;set;}
        public boolean isWorkMissedReason{get;set;}
        public List<Object> companyHolidaySelection{get;set;}
        public boolean isCompanyHolidayOther{get;set;}
        public String otherHolidaySelection{get;set;}
        public List<overTimeSheet> overTimeSheet{get;set;}
        public boolean isOverTimeSheetUploaded{get;set;}
        public TimeEntriesDetail[] timeEntriesDetail{get;set;}
        
    }
    public class TimeEntriesDetail {
        public String name{get;set;}
        public String startTime{get{
            return OnlineWageClaimPDFController.cleanTime(startTime);
        }set;}
        public String endTime{get{
            return OnlineWageClaimPDFController.cleanTime(endTime);
        }set;}
        public boolean dateDiffer{get;set;}
        public boolean isFirstMeal{get;set;}
        public boolean isSecondMeal{get;set;}
        public String startTimeFirstMeal{get;set;}
        public String breakTimeFirstMeal{get;set;}
        public String startTimeSecondMeal{get;set;}
        public String breakTimeSecondMeal{get;set;}
        public String totalHours{get;set;}
        public boolean issameScheduled{get;set;}
        public Integer id{get;set;}
        public boolean isChecked{get;set;}
        public String formattedWorkingHours{get;set;}
    }
    //WorkWeek And WorkDay Wrapper
    public class workWeekAndWorkDayWrapper{
        public String EmpFollowSatToSun{get{String spanishTranslation = '';if(userInfo.getLanguage() != 'es'){return EmpFollowSatToSun; }else{Map<String, Owc_workWeek_YesOrNoOption__mdt> mapObj = Owc_workWeek_YesOrNoOption__mdt.getAll();for(String obj : mapObj.keySet()){if(mapObj.get(obj).English_Translation__c == EmpFollowSatToSun){spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                                                                                                                                                                                                                                                                                                                                              }
                                                                                                                                                                                                                                                                              }
                                                                                                                                              return spanishTranslation;
                                                                                                                                             }
                                           }set;}
        public String EmpDefinedWorkweek{get{ String spanishTranslation = '';if(userInfo.getLanguage() != 'es'){return EmpDefinedWorkweek; }else{Map<String, Owc_workWeekOption__mdt> mapObj = Owc_workWeekOption__mdt.getAll(); for(String obj : mapObj.keySet()){if(mapObj.get(obj).English_Translation__c == EmpDefinedWorkweek){spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                                                                                                                                                                                                                                                                                                                                   }  }return spanishTranslation;
                                                                                                                                                }
                                            }set;}
        public String EmpFollowMidnightToMidnight{get{String spanishTranslation = ''; if(userInfo.getLanguage() != 'es'){return EmpFollowMidnightToMidnight;  } else{ Map<String, Owc_workWeek_YesOrNoOption__mdt> mapObj = Owc_workWeek_YesOrNoOption__mdt.getAll(); for(String obj : mapObj.keySet()){ if(mapObj.get(obj).English_Translation__c == EmpFollowMidnightToMidnight){ spanishTranslation = mapObj.get(obj).Spanish_Translation__c;  } }return spanishTranslation;
                                                                                                                                                                    }
                                                     }set;}
        public boolean isEmpFollowMidnightToMidnight{get;set;}
        public String BegDate{get;set;}
        public String EndDate{get;set;}
    }
    
    //Payment of Wages Wrapper
    public class paymentOfWagesWrapper{
        public boolean isOneHourlyRate{get;set;}
        public String paidAmountPerHour{get;set;}
        public String promisedAmountPerHour{get;set;}
        public String hourlyRateBegDate{get;set;}
        public String hourlyRateEndDate{get;set;}
        public boolean isOneHourlyAdditionalSection{get;set;}        
        
        public boolean isDifferentHourRate{get;set;}
        public boolean HourlyOptionValue {get;set;}
        public boolean differentHourOptionValue {get;set;}
        public boolean salaryRateOptionValue {get;set;}
        public boolean commissionRateOptionValue {get;set;}
        public boolean pieceRateOptionValue {get;set;}
        public String paidAmountDifferentHour{get;set;}
        public String promisedAmountDifferentHour{get;set;}
        public String forActivity{get;set;}
        public String differentHourlyRateBegDate{get;set;}
        public String differentHourlyRateEndDate{get;set;}        
        public boolean isDifferentHourAdditionalInfoSection{get;set;}
        
        public boolean isSalaryRateForEachDay{get;set;}
        public String paidAmountForEachDay{get;set;}
        public String promisedAmountForEachDay{get;set;}
        public String frequencyOfEachDay{get{String spanishTranslation = '';if(userInfo.getLanguage() != 'es'){return frequencyOfEachDay; }else{ Map<String, OwcFrequencyOption__mdt> mapObj = OwcFrequencyOption__mdt.getAll(); for(String obj : mapObj.keySet()){if(mapObj.get(obj).English_Translation__c == frequencyOfEachDay){spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                                                                                                                                                                                                                                                                                                                                   }
                                                                                                                                                                                                                                                                  }
                                                                                                                                                return spanishTranslation;
                                                                                                                                               }
                                            }set;}
        public String eachPayRateBegDate{get;set;}
        public String eachPayRateEndDate{get;set;}
        public boolean isSalaryRateAdditionalSection{get;set;}
        
        public boolean isCommissionRate{get;set;}
        public String writtenCommission{get{
            if(String.isNotBlank(writtenCommission) && writtenCommission == 'Yes'){
                return 'Yes';
            }
            else{
                return 'No';
            }
        }set;}
        public boolean isWrittenCommission{get;set;}public boolean isCommissionReciptFileUpload{get;set;}public boolean isAgreementFileUpload{get;set;}public boolean isSelectedFileDeleted{get;set;}
        
        public boolean isPieceRate{get;set;}
        public String paidPieceRate{get;set;}
        public String promisedPieceRate{get;set;}
        public String perUnitPaymentOfWages{get{ String spanishTranslation = '';if(userInfo.getLanguage() != 'es'){return perUnitPaymentOfWages; }else{ Map<String, Owc_pOWagesPerUnitOption__mdt> mapObj = Owc_pOWagesPerUnitOption__mdt.getAll();for(String obj : mapObj.keySet()){if(mapObj.get(obj).English_Translation__c == perUnitPaymentOfWages){spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                                                                                                                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                                                    }
                                                                                                                                                       return spanishTranslation;
                                                                                                                                                      }
                                               }set;}
        public String other{get;set;}
        public String numberOfUnits{get;set;}
        public String pieceRateBegDate{get;set;}
        public String pieceRateEndDate{get;set;}
        public String pieceRateTotalEarned{get;set;}
        public String pieceRateTotalPaid{get;set;}
        public boolean isProvidePriceRate{get;set;}
        public boolean isPieceRateAdditionalSection{get;set;}
        
    }
    //One Hourly Additional Wrapper
    public class powAdditionalWrapper{
        public String paidAmountPerHourAdditional{get;set;}
        public String promisedAmountPerHourAdditional{get;set;}
        public String hourlyRateBegDateAdditional{get;set;}
        public String hourlyRateEndDateAdditional{get;set;}
    }
    //Different Hour Additional Wrapper
    public class powDifferentHourAdditionalWrapper{
        public String paidAmountDifferentHourAdditional{get;set;}
        public String promisedAmountDifferentHourAdditional{get;set;}
        public String forActivityAdditional{get;set;}
        public String differentHourlyRateBegDateAdditional{get;set;}
        public String differentHourlyRateEndDateAdditional{get;set;}
    }
    //Salary Rate Additional Wrapper
    public class powSalaryRateAdditionalWrapper{
        public String paidAmountForEachDayAdditional{get;set;}
        public String promisedAmountForEachDayAdditional{get;set;}
        public String frequencyOfEachDayAdditional{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return frequencyOfEachDayAdditional;
            }
            else{
                Map<String, OwcFrequencyOption__mdt> mapObj = OwcFrequencyOption__mdt.getAll();
                for(String obj : mapObj.keySet()){
                    if(mapObj.get(obj).English_Translation__c == frequencyOfEachDayAdditional){
                        spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                    }
                }
                return spanishTranslation;
            }
        }set;}
        public String eachPayRateBegDateAdditional{get;set;}
        public String eachPayRateEndDateAdditional{get;set;}
    }
    //Piece Rate Additional Wrapper
    public class powPieceRateAdditionalWrapper{
        public String paidPieceRateAdditional{get;set;}
        public String promisedPieceRateAdditional{get;set;}
        public String numberOfUnitsAdditional{get;set;}
        public String pieceRateBegDateAdditional{get;set;}
        public String pieceRateEndDateAdditional{get;set;}
        public String perUnitPaymentOfWagesAdditional{get{
            String spanishTranslation = '';
            if(userInfo.getLanguage() != 'es'){
                return perUnitPaymentOfWagesAdditional;
            }
            else{Map<String, Owc_severance_Pay_Offered_Option__mdt> mapObj = Owc_severance_Pay_Offered_Option__mdt.getAll();
                 for(String obj : mapObj.keySet()){
                     if(mapObj.get(obj).English_Translation__c == perUnitPaymentOfWagesAdditional){
                         spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                     }
                 }
                 return spanishTranslation;
                }
        }set;}
        public String otherAdditional{get;set;}
    }
    //Agreement Docs Wrapper 
    public class agreementDocsWrapper{
        public String name{get;set;}
        public String documentId{get;set;}
        public String contentVersionId{get;set;}
    }
    //Claimant Employee Wrapper
    public class CertificationAndAuth{
        public List<Object> certificationDocs{get;set;}  public boolean isAuthorizationRelease{get;set;}
        public string claimantName{get;set;}
        public string claimDate{get;set;}
    }
    // Wage Defeciecneies
    public class wageDeficiencyDetails{
        public Integer sectionId{get;set;}  //1
        public boolean notPaidForWork{get;set;}
        public boolean showOneHourlyRateTemplate{get;set;}
        public boolean isOneHourlyRate{get;set;}
        public boolean isLocalMinimumWage{get;set;}
        public boolean isStateMinimumWage{get;set;}
        public boolean isFirstOptionTrue{get;set;} public workNotPaidData[] workNotPaidData{get;set;} public renderWorkedNotPaidSection[] renderWorkedNotPaidSection{get;set;}
        public boolean noOvertimePaid{get;set;}   public overTimeDetails[] overTimeDetails{get;set;}
        public boolean isSecondOptionTrue{get;set;}
        public boolean noSickLeavePaid{get;set;}
        public boolean isThirdOptionTrue{get;set;}  public sickLeaveDetails[] sickLeaveDetails{get;set;}
        public boolean notPaidForVacationTime{get;set;}
        public boolean isFourthOptionTrue{get;set;} public violationTypeVariablesForVacationTime[] violationTypeVariablesForVacationTime{get;set;}
        public boolean notPaidForHoliday{get;set;}
        public boolean isFifthOptionTrue{get;set;}
        public boolean notAllowedBathBreak{get;set;}
        public boolean isSixthOptionTrue{get;set;} public restBreakDetails[] restBreakDetails{get;set;}
        public boolean notAllowedMealBreak{get;set;}
        public boolean isSeventhOptionTrue{get;set;} public mealBreakDetails[] mealBreakDetails{get;set;}
        public boolean notAllowedForHeatRest{get;set;}
        public boolean isEightOptionTrue{get;set;} public restClaimDetails[] restClaimDetails{get;set;}
        public boolean notPaidSeverancePay{get;set;}
        public boolean deniedShareTips{get;set;}
        public boolean isTenthOptionTrue{get;set;}
        public boolean deniedBusinessCost{get;set;}
        public boolean isEleventhOptionTrue{get;set;}
        public boolean deniedPaymentMilega{get;set;}
        public boolean isTwelveOptionTrue{get;set;} public mileageClaimDetailsWageDef[] mileageClaimDetails{get{if(mileageClaimDetails != null && mileageClaimDetails.size() >0){return mileageClaimDetails;} else{return null;
                                                                                                                                                                                                                  }
                                                                                                               }set;}
        public boolean paycheckDeduction{get;set;}
        public boolean isThirteenthOptionTrue{get;set;}
        public boolean deniedPayrollInfo{get;set;}
        public boolean isFouteenOptionTrue{get;set;}
        public boolean deniedPersonnelFile{get;set;}
        public boolean isFifteenOptionTrue{get;set;}
        public boolean employerDeniedWork{get;set;}
        public boolean isSixteenOptionTrue{get;set;} public fundClaimDetails[] fundClaimDetails{get;set;}
        public boolean productionBonus{get;set;}
        public boolean isSeventeenOptionTrue{get;set;}
        public boolean reportedToWork{get;set;}
        public boolean isEighteenOptionTrue{get;set;} public payClaimDetails[] payClaimDetails{get;set;}
        public boolean isEmployeeWorkedDateValid{get;set;} public violationTypeVariablesForShareTips[] violationTypeVariablesForShareTips{get;set;}
        public String isVacationTimeClaimUpload{get;set;}   //
        public boolean isVacationTime{get;set;}
        public boolean isHolidayPay{get;set;}
        public String holidayPay{get;set;}
        public String serverancePay{get;set;}
        public boolean isSeverancePay{get;set;}
        public boolean isPayRollInfo{get;set;}
        public boolean isPayCheck{get;set;}
        public boolean isPersonalFile{get;set;}
        public boolean isProductionBonus{get;set;}
        public boolean isBusinessCost{get;set;}
        public boolean isUnreimbursedUpload{get;set;}
        public boolean isExplain{get;set;}
        public boolean noticebeforequit{get;set;}
        public Integer flag{get;set;}public employerWorkedDetails employerWorkedDetails{get;set;}
        public violationTypeVariablesForPayCheck[] violationTypeVariablesForPayCheck{get;set;}
        public String payrollDemandDate{get {return OnlineWageClaimPDFController.cleanDateStatic(payrollDemandDate);
                                            }set;}
        public String employerResponse{get;set;} public String personalFileDemandDate{get{return OnlineWageClaimPDFController.cleanDateStatic(personalFileDemandDate);
                                                                                         }set;}
        public String personalEmployerResponse{get;set;} public violationTypeVariablesForBusinessCost[] violationTypeVariablesForBusinessCost{get;set;} public violationTypeVariablesForProductionBonus[] violationTypeVariablesForProductionBonus{get;set;}
        public String anotherClaimExplain{get;set;} public WaitingTimeDetails waitingTimeDetails{get;set;}
        public boolean isHeatRestDef{get;set;} 
        public boolean isLatePayroll{get;set;} public violationTypeVariablesForLatePayroll[] violationTypeVariablesForLatePayroll{get;set;}
        public boolean isWrittenStatement{get;set;}
    }//0
    public class workNotPaidData {
        public Integer sectionId{get;set;}  //1
        public boolean isonehourlyrate{get;set;}
        public boolean islocalminimumwage{get;set;}
        public boolean isstateminimumwage{get;set;}
        public violationTypeVariablesForOneHourlyRate[] violationTypeVariablesForOneHourlyRate{get;set;}
        public violationTypeVariablesForOneSalaryRate[] violationTypeVariablesForOneSalaryRate{get;set;}
        public violationTypeVariablesForDifferentHourlyRate[] violationTypeVariablesForDifferentHourlyRate{get;set;}
        public violationTypeVariablesForOnePieceRate[] violationTypeVariablesForOnePieceRate{get;set;}
        public violationTypeVariablesForCommissionRate[] violationTypeVariablesForCommissionRate{get;set;}
        public List<ViolationTypeVariablesForknownPieceRate> violationTypeVariablesForknownPieceRate{get;set;}
        public boolean isOnePieceRatePOW{get;set;}
        public boolean isDifferentPieceRatePOW{get;set;}
        public boolean isOneHourlyRatePOW{get;set;}
        public boolean isSalaryRatePOW{get;set;}
        public boolean isDifferentHourPOW{get;set;}
        public boolean isPieceRateUnknown{get;set;}
        public boolean isCommissionAgreementUpload{get;set;}
        public boolean isNotCommissionAgreementUpload{get;set;}
        public boolean isCommissionSumUpload{get;set;}
        public boolean isLocalWageDifferentHourPOW{get;set;}
        public boolean isLocalWageOneHourlyRatePOW{get;set;}
        public boolean isLocalWageSalaryRatePOW{get;set;}
        public boolean isStateWageOneHourlyRatePOW{get;set;}
        public boolean isStateWageSalaryRatePOW{get;set;}
        public boolean isStateWageDifferentHourPOW{get;set;}
        public boolean isSalaryRateCallback{get;set;}
        public boolean isMultipleRateCallback{get;set;}
        public boolean isOneHourlyRateCallback{get;set;}
        public boolean isLocalWageOneHourlyCallback{get;set;}
        public boolean isStateWageOneHourlyRateCallback{get;set;}
        public boolean isLocalWageSalaryRateCallback{get;set;}
        public boolean isLocalWageDifferentHourCallback{get;set;}
        public boolean isStateWageSalaryRateCallback{get;set;}
        public boolean staterate{get;set;}
    }
    public class violationTypeVariablesForOneHourlyRate {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //START DATE OF CLAIM PERIOD
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;}  
        public String name{get;set;}    //VTV0010
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9e1EAA
        public String violationTypeId{get;set;} //a1i35000000LQBnAAO
        public boolean dateFormat{get;set;}
    }
    public class violationTypeVariablesForOneSalaryRate {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //START DATE OF CLAIM PERIOD
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV1332
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9lmEAA
        public String violationTypeId{get;set;} //a1i35000000LQ9GAAW
        public boolean dateFormat{get;set;}
    }
    public class violationTypeVariablesForDifferentHourlyRate {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //START DATE OF CLAIM PERIOD
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV1373
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9qIEAQ
        public String violationTypeId{get;set;} //a1i35000000LQALAA4
        public boolean dateFormat{get;set;}
    }
    public class violationTypeVariablesForOnePieceRate {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //START DATE OF CLAIM PERIOD
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0026
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9hYEAQ
        public String violationTypeId{get;set;} //a1i35000000LQDMAA4
        public boolean dateFormat{get;set;}
    }
    public class violationTypeVariablesForCommissionRate {
        public String dataType{get;set;}    //Currency
        public String description{get;set;} //$ TOTAL AMOUNT OF COMMISSIONS EARNED DURING CLAIM PERIOD
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV1545
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9n2EAA
        public String violationTypeId{get;set;} //a1i35000000LQ9gAAG
        public boolean currencyFormat{get;set;}
    }
    public class ViolationTypeVariablesForknownPieceRate {
        public String dataType{get;set;}
        public String description{get;set;}
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}
        public String violationId{get;set;}
        public String violationTypeId{get;set;}
        public Boolean currencyFormat{get;set;}
        public Boolean dateFormat{get;set;}
    }
    public class renderWorkedNotPaidSection {
        public String heading{get;set;} //Claim for Regular Wages
        public boolean button{get;set;}
        public Integer sectionId{get;set;}  //1
    }
    public class overTimeDetails {
        public Integer sectionId{get;set;}  //1
        public String claimDoubleTimeOnly{get{String spanishTranslation = '';if(userInfo.getLanguage() != 'es'){return claimDoubleTimeOnly;}else{Map<String, OWCOvertimeClaimOptions__mdt> mapObj = OWCOvertimeClaimOptions__mdt.getAll();for(String obj : mapObj.keySet()){if(mapObj.get(obj).English_Translation__c == claimDoubleTimeOnly){spanishTranslation = mapObj.get(obj).Spanish_Translation__c;
                                                                                                                                                                                                                                                                                                                                             }
                                                                                                                                                                                                                                                                           }return spanishTranslation;
                                                                                                                                                }
                                             }set;} //Overtime only
        public boolean isDoubleTimeClaim{get;set;}
        public boolean isOneHourly{get;set;} 
        public violationTypeVariablesForOneHourly[] violationTypeVariablesForOneHourly{get;set;}
        public violationTypeVariablesForOneHourlyRecs[] violationTypeVariablesForOneHourlyRecs{get;set;}
        public violationTypeVariablesForAdditional[] violationTypeVariablesForAdditional{get;set;}
        public violationTypeVariablesForDt15[] violationTypeVariablesForDt15{get;set;}
        public violationTypeVariablesForOt28[] violationTypeVariablesForOt28{get;set;}
        public boolean isOT28Issue{get;set;}
        public boolean isDT15Issue{get;set;}
        public boolean isSalaryRatePOW{get;set;}
        public boolean isOneHourlyRec{get;set;}
        public boolean isSalaryRatePOWRec{get;set;}
        public boolean isOneHourlyRecs{get;set;}
        public boolean isSalaryRatePOWRecs{get;set;}
        public boolean isAdditonalCheck{get;set;}
    }
    public class violationTypeVariablesForOt28 {
        public String dataType{get;set;}    //Text
        public String description{get;set;} //DATE(S) OF SICK LEAVE. Enter all known date(s) when sick leave was taken but not paid as required by law (ex: 1/4/16, 1/5/16, 1/6/16). If date(s) are not known, enter date range or at least the year (ex: “between June through December 2016”{get;set;} “in 2016”).
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0087
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9hlEAA
        public String violationTypeId{get;set;} //a1i35000000LQCnAAO
        public boolean inputFormat{get;set;}
        public boolean helpText{get;set;}
    }
    public class violationTypeVariablesForDt15 {
        public String dataType{get;set;}    //Text
        public String description{get;set;} //DATE(S) OF SICK LEAVE. Enter all known date(s) when sick leave was taken but not paid as required by law (ex: 1/4/16, 1/5/16, 1/6/16). If date(s) are not known, enter date range or at least the year (ex: “between June through December 2016”{get;set;} “in 2016”).
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0087
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9hlEAA
        public String violationTypeId{get;set;} //a1i35000000LQCnAAO
        public boolean inputFormat{get;set;}
        public boolean helpText{get;set;}
    }
    public class violationTypeVariablesForOneHourlyRecs {
        public String dataType{get;set;}    //Text
        public String description{get;set;} //DATE(S) OF SICK LEAVE. Enter all known date(s) when sick leave was taken but not paid as required by law (ex: 1/4/16, 1/5/16, 1/6/16). If date(s) are not known, enter date range or at least the year (ex: “between June through December 2016”{get;set;} “in 2016”).
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0087
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9hlEAA
        public String violationTypeId{get;set;} //a1i35000000LQCnAAO
        public boolean inputFormat{get;set;}
        public boolean helpText{get;set;}
    }
    public class violationTypeVariablesForAdditional {
        public String dataType{get;set;}    //Text
        public String description{get;set;} //DATE(S) OF SICK LEAVE. Enter all known date(s) when sick leave was taken but not paid as required by law (ex: 1/4/16, 1/5/16, 1/6/16). If date(s) are not known, enter date range or at least the year (ex: “between June through December 2016”{get;set;} “in 2016”).
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0087
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9hlEAA
        public String violationTypeId{get;set;} //a1i35000000LQCnAAO
        public boolean inputFormat{get;set;}
        public boolean helpText{get;set;}
    }
    public class violationTypeVariablesForOneHourly {
        public String dataType{get;set;}    //Text
        public String description{get;set;} //DATE(S) OF SICK LEAVE. Enter all known date(s) when sick leave was taken but not paid as required by law (ex: 1/4/16, 1/5/16, 1/6/16). If date(s) are not known, enter date range or at least the year (ex: “between June through December 2016”{get;set;} “in 2016”).
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0087
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9hlEAA
        public String violationTypeId{get;set;} //a1i35000000LQCnAAO
        public boolean inputFormat{get;set;}
        public boolean helpText{get;set;}
    }
    public class sickLeaveDetails {
        public Integer sectionId{get;set;}  //1
        public boolean isNotPaid{get;set;}
        public boolean isNotAllowedSickLeave{get;set;}
        public String sickLeaveClaim{get{String spanishTranslation = '';if(userInfo.getLanguage() != 'es'){return sickLeaveClaim;} else{Map<String, OWCSickLeaveSelection__mdt> mapObj = OWCSickLeaveSelection__mdt.getAll();for(String obj : mapObj.keySet()){if(mapObj.get(obj).English_Translation__c == sickLeaveClaim){spanishTranslation = mapObj.get(obj).Spanish_Translation__c;} }return spanishTranslation;
                                                                                                                                       }
                                        }set;}  //I took sick leave but was not paid for it
        public boolean isOneHourly{get;set;}public violationTypeVariablesForOneHourly[] violationTypeVariablesForOneHourly{get;set;}
        public boolean isDifferentHourly{get;set;}
        public boolean isOneHourlyAllow{get;set;}
        public boolean isDifferentHourlyAllow{get;set;}
    }
    public class restBreakDetails {
        public Integer sectionId{get;set;}  public violationTypeVariablesForOneHourlyRate[] violationTypeVariablesForOneHourlyRate{get;set;}
        public boolean isOneHourlyRatePOW{get;set;}
        public boolean isSalaryRatePOW{get;set;}
    }
    public class mealBreakDetails {
        public Integer sectionId{get;set;}  public violationTypeVariablesForOneHourlyRate[] violationTypeVariablesForOneHourlyRate{get;set;}
        public boolean isOneHourlyRatePOW{get;set;}
        public boolean isSalaryRatePOW{get;set;}
    }
    public class restClaimDetails {
        public Integer sectionId{get;set;}  public violationTypeVariablesForOneHourlyRate[] violationTypeVariablesForOneHourlyRate{get;set;}
        public boolean isOneHourlyRatePOW{get;set;}
        public boolean isSalaryRatePOW{get;set;} 
    }
    public class mileageClaimDetailsWageDef {
        public Integer sectionId{get;set;} public List<ViolationTypeVariablesForOneHourlyRate> violationTypeVariablesForOneHourlyRate{get;set;}
        public Boolean isOneHourlyRatePOW{get;set;}
    }
    public class fundClaimDetails {
        public Integer sectionId{get;set;}  public violationTypeVariablesForInsufficientFunds[] violationTypeVariablesForInsufficientFunds{get;set;}
        public boolean isOneHourlyRatePOW{get;set;}
    }
    public class violationTypeVariablesForInsufficientFunds {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //DATE OF REPLACEMENT CHECK OR WHEN CHECK WAS CASHED
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV1021
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9eTEAQ
        public String violationTypeId{get;set;} //a1i35000000LQC7AAO
        public boolean dateFormat{get;set;}
    }
    public class payClaimDetails {
        public Integer sectionId{get;set;}  public violationTypeVariablesForOneHourlyRate[] violationTypeVariablesForOneHourlyRate{get;set;}
        public boolean isOneHourlyRatePOW{get;set;}
        public boolean isSalaryRatePOW{get;set;}
    }
    public class violationTypeVariablesForVacationTime {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //DATE OF TERMINATION
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0091
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}
        public String violationId{get;set;} //a2K35000000h9e6EAA
        public String violationTypeId{get;set;} //a1i35000000LQBpAAO
        public boolean dateFormat{get;set;}
        public boolean helpText{get;set;}
    }
    public class violationTypeVariablesForShareTips {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //START DATE OF UNLAWFUL TIP DEDUCTIONS
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0100
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9eLEAQ
        public String violationTypeId{get;set;} //a1i35000000LQBuAAO
        public boolean dateFormat{get;set;}
    }
    public class employerWorkedDetails {
        
        public boolean isOneHourlyRatePOW{get;set;} public violationTypeVariablesForOneHourlyForMin[] violationTypeVariablesForOneHourlyForMin{get;set;}
        public boolean isOneHourlyForMin{get;set;}
        public boolean isSalaryWagePOW{get;set;}
        public boolean isSS12Visible{get;set;}
    }
    public class violationTypeVariablesForOneHourlyForMin {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //START DATE OF CLAIM PERIOD FOR SPLIT SHIFT WAGES
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV1758
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9q1EAA
        public String violationTypeId{get;set;} //a1i35000000LQCNAA4
        public boolean dateFormat{get;set;}
    }
    public class violationTypeVariablesForPayCheck {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //START DATE OF WAGES EARNED FROM WHICH UNLAWFUL DEDUCTIONS WERE TAKEN
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0096
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9eFEAQ
        public String violationTypeId{get;set;} //a1i35000000LQBtAAO
        public boolean dateFormat{get;set;}
    }
    public class violationTypeVariablesForBusinessCost {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //START DATE OF CLAIM FOR UNREIMBURSED BUSINESS EXPENSES
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0104
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9heEAA
        public String violationTypeId{get;set;} //a1i35000000LQD0AAO
        public boolean dateFormat{get;set;}
    }
    
    public class violationTypeVariablesForProductionBonus {
        public String dataType{get;set;}    //Date
        public String description{get;set;} //START DATE OF CLAIM PERIOD FOR PRODUCTION BONUS
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}    //VTV0057
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}  //
        public String violationId{get;set;} //a2K35000000h9hyEAA
        public String violationTypeId{get;set;} //a1i35000000LQD4AAO
        public boolean dateFormat{get;set;}
    }
    public class WaitingTimeDetails {
        
        public Boolean isWaitingTimeOne{get;set;} public List<ViolationTypeVariablesForWaitingTimeOne> violationTypeVariablesForWaitingTimeOne{get;set;}
        public Boolean isWaitingTimeTwo{get;set;}
        public Boolean isWaitingTimeThree{get;set;}
        public Boolean isWaitingTimeFour{get;set;}
        public String isnotidentifyemployer{get;set;}
        public String dischargeddate{get {return OnlineWageClaimPDFController.cleanDateStatic(dischargeddate);
                                         }set;}
        public String quitdatevalue{get {String Value = (String) quitdatevalue;return OnlineWageClaimPDFController.cleanDateStatic(Value);
                                        }set;}
        public String noticebeforequit{get;set;}
    }
    public class ViolationTypeVariablesForWaitingTimeOne {
        public String dataType{get;set;}
        public String description{get;set;}
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        public String name{get;set;}
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                }set;}
        public String violationId{get;set;}
        public String violationTypeId{get;set;}
        public Boolean dateFormat{get;set;}
        public Boolean helpText{get;set;}
        public Boolean inputFormat{get;set;}
        public Boolean currencyFormat{get;set;}
    }
    public class violationTypeVariablesForLatePayroll{
        public String dataType{get;set;}
        public String description{get;set;}
        public String label{get { if(label != null) { if(label.endsWith('?')){return label;} else{return label+':'; }} else {return label; } } set;} 
        /*
public String colonSuffix {get {
if(label.endsWith('?'))
{
return '';
} else{
return ':';
}
} set;}	*/
        public String name{get;set;}
        public String value{get {return OnlineWageClaimPDFController.cleanDateStatic(value);
                                } set;}
        public String violationId{get;set;}
        public String violationTypeId{get;set;}
        public Boolean dateFormat{get;set;}
        public Boolean helpText{get;set;}
        public Boolean inputFormat{get;set;}
        public Boolean currencyFormat{get;set;}
    }
    public static String formattedPhone(String phoneValue){
        if(String.isNotBlank(phoneValue)){
            if(phoneValue.length() == 10){
                return phoneValue.substring(0,3)+'-'+phoneValue.substring(3,6)+'-'+phoneValue.substring(6,10);
            }
        }
        return phoneValue;
    }
    public static String cleanDateStatic(String theDate){
        if(String.isBlank(theDate)){return theDate;
                                   }    
        String [] s = theDate.split('-');
        if(s.size() == 3){
            String newMonth= '';
            if(s[1].length() == 1){newMonth = '0'+s[1]; 
                                  }else{
                                      newMonth = s[1];
                                  }
            
            String newDate = newMonth+'/'+s[2]+'/'+s[0];
            return newDate;}return theDate;
    }
}