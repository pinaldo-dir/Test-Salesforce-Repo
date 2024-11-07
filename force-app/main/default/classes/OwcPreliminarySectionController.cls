public with sharing class OwcPreliminarySectionController {

    @AuraEnabled(cacheable=true)
    public static List<preliminarySectionMetaData> getOWCPreliminaryMetaData(String userId){
        try {
            List<preliminarySectionMetaData> preliminaryMetaList = new List<preliminarySectionMetaData>();
            preliminarySectionMetaData preliminaryMetaWrapperObj = new preliminarySectionMetaData();
            preliminaryMetaWrapperObj.wageClaimSubmitYourselfOrBehalf = owcWageClaimPreliminaryPicklistData('OWCPreliminaryWageClaimSubmit__mdt', userId);
            preliminaryMetaWrapperObj.covid19WageClaim = owcWageClaimPreliminaryPicklistData('OWCPreliminaryCovid19Claim__mdt', userId);
            preliminaryMetaWrapperObj.representativeAdvocateType = owcWageClaimPreliminaryPicklistData('OWCRepresentationAdvocateType__mdt', userId);
            preliminaryMetaWrapperObj.individualRepresentativePhoneType = owcWageClaimPreliminaryPicklistData('OWCIndividualRepresentativePhoneType__mdt', userId);
            preliminaryMetaWrapperObj.individualRepresentativeClaimantRelationShip = owcWageClaimPreliminaryPicklistData('OWCIndividualRepClaimantRelationship__mdt',userId);
            preliminaryMetaWrapperObj.preliminaryCovidClaimValues = owcWageClaimPreliminaryPicklistData('OWCPreliminarySpecifyCovidClaim__mdt', userId);
            preliminaryMetaWrapperObj.languageAssitantPrefferedLanguages = owcWageClaimPreliminaryPicklistData('OWCPrefferedLanguageAssistantData__mdt', userId);
            preliminaryMetaWrapperObj.perUnitPaymentOfWages = owcWageClaimPreliminaryPicklistData('Owc_pOWagesPerUnitOption__mdt', userId);
            preliminaryMetaWrapperObj.owcWagePaidTypes = owcWageClaimPreliminaryPicklistData('OWCWagesPaidType__mdt', userId);
            preliminaryMetaWrapperObj.owcYesOrNoPicklistOption = owcWageClaimPreliminaryPicklistData('OWCEmployementStatusAndFinalWageOptions__mdt', userId);
            preliminaryMetaWrapperObj.owcBusineesTypeOptions = owcWageClaimPreliminaryPicklistData('OWC_Employer_Business_Type__mdt', userId);
            preliminaryMetaWrapperObj.owcQuitDateDischargeDate = owcWageClaimPreliminaryPicklistData('OWCQuitDateDischargeDate__mdt', userId);
            preliminaryMetaWrapperObj.owcWorkedRecordedList = owcWageClaimPreliminaryPicklistData('OWC_WorkRecorded__mdt', userId);
            preliminaryMetaWrapperObj.owcCountryCodeList =  owcWageClaimPreliminaryPicklistData('OWC_CountryCode__mdt', userId);
            preliminaryMetaWrapperObj.owcOverttimeOptions =  owcWageClaimPreliminaryPicklistData('OWCOvertimeClaimOptions__mdt', userId);
            preliminaryMetaWrapperObj.owcSickLeaveOptions =  owcWageClaimPreliminaryPicklistData('OWCSickLeaveSelection__mdt', userId);
            preliminaryMetaWrapperObj.owcCompanyOwnerships = owcWageClaimPreliminaryPicklistData('OWC_Successor_Ownership_Type__mdt', userId);
            preliminaryMetaWrapperObj.owcPOWSalaryRateOptions = owcWageClaimPreliminaryPicklistData('OwcFrequencyOption__mdt', userId);
            preliminaryMetaWrapperObj.owcWorkWeekAndWorkDays = owcWageClaimPreliminaryPicklistData('Owc_workWeekOption__mdt', userId);
            preliminaryMetaWrapperObj.owcWorkWeekYesOrNoOptions = owcWageClaimPreliminaryPicklistData('Owc_workWeek_YesOrNoOption__mdt', userId);
            preliminaryMetaWrapperObj.owcLabelSectionOptions = owcWageClaimPreliminaryPicklistData('OWC_Label_Garement_Option_Type__mdt', userId);
            preliminaryMetaWrapperObj.owcSeverancePayOfferedOptions = owcWageClaimPreliminaryPicklistData('Owc_severance_Pay_Offered_Option__mdt', userId);
            preliminaryMetaWrapperObj.owcPrimaryIndustryOptions = owcWageClaimPreliminaryPicklistData('OWCPrimaryIndustrySelection__mdt', userId);

            preliminaryMetaWrapperObj.owcDemographicGenderOptions = owcWageClaimPreliminaryPicklistData('owc_demographic_gender__mdt', userId);
            preliminaryMetaWrapperObj.owcDemographicRaceOptions = owcWageClaimPreliminaryPicklistData('owc_demographic_race__mdt', userId);
            preliminaryMetaWrapperObj.owcDemographicEthnicOriginOptions = owcWageClaimPreliminaryPicklistData('owc_demographic_ethnic_origin__mdt', userId);
            preliminaryMetaWrapperObj.owcDemographicEthnicityOptions = owcWageClaimPreliminaryPicklistData('owc_demographic_ethnicity__mdt', userId);
            preliminaryMetaWrapperObj.owcDemographicSexualOrientationOptions = owcWageClaimPreliminaryPicklistData('owc_demographic_sexual_orientation__mdt', userId);
            //preliminaryMetaWrapperObj.owcOvertimeYearSelection =  owcWageClaimPreliminaryPicklistData('OWCOvertimeYearSelection__mdt', userId);
            //System.debug('preliminaryMetaWrapperObj.owcCountryCodeList :::: '+preliminaryMetaWrapperObj.OWCOvertimeClaimOptions__mdt);
            preliminaryMetaWrapperObj.statePicklist = getPicklistValues();
            preliminaryMetaList.add(preliminaryMetaWrapperObj);
           
            return preliminaryMetaList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<metaDataWrapperObj> owcWageClaimPreliminaryPicklistData(String metaObjApiName, String userId){
        String query;
        try {
            System.debug('metaObjApiName ::: '+metaObjApiName);
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            if(metaObjApiName == 'OWCPrimaryIndustrySelection__mdt'){
                query = 'SELECT Id, MasterLabel, Label, Value__c, Order_Number__c, Spanish_Translation__c, English_Translation__c, Mapped_Value__c, Language FROM ' + metaObjApiName;
            }
            else{
                query = 'SELECT Id, MasterLabel, Label, Value__c, Order_Number__c, Spanish_Translation__c, English_Translation__c, Language FROM ' + metaObjApiName;
            }
            
            List<metaDataWrapperObj> metaDataWrapperObjList = new List<metaDataWrapperObj>();
            
            if(metaObjApiName == 'OWC_CountryCode__mdt'){
                query += ' order by Label ASC';
            }
            else{
                query += ' order by Order_Number__c ASC';
            }
            List<SObject> owcPreliminaryMetaDataList = Database.query(query);
            for(SObject metaDataObj : owcPreliminaryMetaDataList){
                metaDataWrapperObj metaDataWrapperObj = new metaDataWrapperObj();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    metaDataWrapperObj.label = (String)metaDataObj.get('Spanish_Translation__c');
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    metaDataWrapperObj.label = (String)metaDataObj.get('English_Translation__c');
                }
                metaDataWrapperObj.value = (String)metaDataObj.get('Value__c');
                if(metaObjApiName == 'OWCPrimaryIndustrySelection__mdt'){
                    metaDataWrapperObj.value2 = (String)metaDataObj.get('Mapped_Value__c');
                }
                metaDataWrapperObjList.add(metaDataWrapperObj);
            }
            return metaDataWrapperObjList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<metaDataWrapperObj> getPicklistValues(){
            List<String> pickListValuesList= new List<String>();
            List<metaDataWrapperObj> wrapperList = new List<metaDataWrapperObj>();
            Schema.DescribeFieldResult fieldResult = User.State__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }     
            
            for(String stateObj : pickListValuesList){
                metaDataWrapperObj stateWrapObj = new metaDataWrapperObj();
                stateWrapObj.label = stateObj;
                stateWrapObj.value = stateObj;
                wrapperList.add(stateWrapObj);
            }
            System.debug('wrapperList ::: '+wrapperList);
            return wrapperList;
    }
    
    public class preliminarySectionMetaData{
        @AuraEnabled
        public List<metaDataWrapperObj> owcPrimaryIndustryOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> wageClaimSubmitYourselfOrBehalf {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> covid19WageClaim {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> representativeAdvocateType {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> individualRepresentativePhoneType {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> individualRepresentativeClaimantRelationShip {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> preliminaryCovidClaimValues {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> languageAssitantPrefferedLanguages {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> statePicklist {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> perUnitPaymentOfWages {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcWagePaidTypes {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcYesOrNoPicklistOption {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcQuitDateDischargeDate {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcBusineesTypeOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcWorkedRecordedList {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcCountryCodeList {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcEmpSuccessorData {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcOverttimeOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcSickLeaveOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcCompanyOwnerships {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcPOWSalaryRateOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcWorkWeekAndWorkDays {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcWorkWeekYesOrNoOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcSeverancePayOfferedOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcLabelSectionOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcDemographicGenderOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcDemographicRaceOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcDemographicEthnicOriginOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcDemographicEthnicityOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcDemographicSexualOrientationOptions {get;set;}
        @AuraEnabled
        public List<metaDataWrapperObj> owcOvertimeYearSelection {get;set;}
    }

    public class metaDataWrapperObj{
        @AuraEnabled 
        public string label{get;set;}
        @AuraEnabled 
        public string value{get;set;}
        @AuraEnabled 
        public string value2{get;set;}
    }
}