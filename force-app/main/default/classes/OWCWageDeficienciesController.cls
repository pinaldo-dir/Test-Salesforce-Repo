public with sharing class OWCWageDeficienciesController {
    // This method is used to get all the violation type variable and show them dynamically on the OWC Form.
    @AuraEnabled
    public static List<violationTypeWrapper> getViolationTypeVariables(String queryCode){
        try {
            System.debug('queryCode ::: '+queryCode);
            List<Violation_Type_Variable__c> violationTypeVariables;
            Wage_Deficiency_Violation_Type__c wageDefViolationTypeObj;
            // Initialize wrapper object list
            List<violationTypeWrapper> violationTypeWrapperList = new List<violationTypeWrapper>();
            
            // Get Logged in User details
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            if(String.isNotBlank(queryCode)){
                // Get Violation Type Id
                wageDefViolationTypeObj = [SELECT Id, Wage_Deficiency_Code__c, Violation_Type__c
                                           FROM Wage_Deficiency_Violation_Type__c
                                           WHERE Wage_Deficiency_Code__c =: queryCode LIMIT 1];
                System.debug('wageDefViolationTypeObj ::: '+wageDefViolationTypeObj);
                // Get Violation Type variables records.
                violationTypeVariables = [SELECT Id, Name, Violation_Type__c, Data_Type__c, Description__c,
                                          value__c, sfxId__c, Label_English__c, Label_Spanish__c
                                          FROM Violation_Type_Variable__c 
                                          WHERE Violation_Type__c =: wageDefViolationTypeObj.Violation_Type__c Order by Sort_Order__c ASC];
                System.debug('violationTypeVariables ::: '+violationTypeVariables);
            }
            if(violationTypeVariables.size() > 0){
                for(Violation_Type_Variable__c violationObj : violationTypeVariables){
                    violationTypeWrapper violationWrapperObj = new violationTypeWrapper();
                    if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                        violationWrapperObj.label = violationObj.Label_English__c; 
                    }
                    else if(currentUserInfo.LanguageLocaleKey == 'es'){
                        violationWrapperObj.label = violationObj.Label_Spanish__c;
                    }
                    violationWrapperObj.dataType = violationObj.Data_Type__c;
                    violationWrapperObj.name = violationObj.Name;
                    violationWrapperObj.value = violationObj.value__c;
                    violationWrapperObj.violationId = violationObj.Id;
                    violationWrapperObj.description = violationObj.Description__c;
                    violationWrapperObj.violationTypeId = wageDefViolationTypeObj.Violation_Type__c;
                    violationTypeWrapperList.add(violationWrapperObj);
                }
            }
            
            List<violationTypeWrapper> violationTypeWrapper = removeNullFields(violationTypeWrapperList);
            return violationTypeWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static List<violationTypeWrapper> removeNullFields(List<violationTypeWrapper> violationTypeWrapperList){
        System.debug('violationTypeWrapperList ::: '+violationTypeWrapperList.size());
        // Prepare new violation type wrapper list after delete null label obj.
        List<violationTypeWrapper> vtList = new List<violationTypeWrapper>();
        for(violationTypeWrapper wrapperObj : violationTypeWrapperList){
            //if(wrapperObj.label != null){
                vtList.add(wrapperObj);
            //}
        }
        
        System.debug('After delete ::: '+vtList.size());
        return vtList;
    }
    
    // This method is used to get the minimum wage record based on the user inputs on the OWC Form.
    @AuraEnabled
    public static wageRateWrapper getMinimumWageRec(String minimumwagezipcode, String minimumhiredate){
        List<Minimum_Wage_Rate__c> minimumWageRateList = new List<Minimum_Wage_Rate__c>();
        List<Minimum_Wage_Rate__c> stateWageList;
        wageRateWrapper wageObj = new wageRateWrapper();
        System.debug('minimumwagezipcode ::: '+minimumwagezipcode);
        if(String.isNotBlank(minimumwagezipcode)){
            minimumWageRateList = [Select Id, Effective_Date_From__c, Effective_Date_To__c, 
                               Max_Employee__c, Min_Employee__c, Min_Wage_Rate__c,
                               Zip_Code__c, Zip_Code__r.Name 
                               FROM Minimum_Wage_Rate__c Where Zip_Code__r.Name =: minimumwagezipcode];
            System.debug('minimumWageRateList :::: '+minimumWageRateList);
            stateWageList = [Select Id, Effective_Date_From__c, Effective_Date_To__c, 
                                   Max_Employee__c, Min_Employee__c, Min_Wage_Rate__c, 
                                   Zip_Code__c, Zip_Code__r.Name 
                                   FROM Minimum_Wage_Rate__c Where Zip_Code__r.Name = '93504'];
            wageObj.stateWageList = stateWageList;
        }
        if(minimumWageRateList.size() == 0){
            minimumWageRateList = [Select Id, Effective_Date_From__c, Effective_Date_To__c, 
                                   Max_Employee__c, Min_Employee__c, Min_Wage_Rate__c, 
                                   Zip_Code__c, Zip_Code__r.Name 
                                   FROM Minimum_Wage_Rate__c Where Zip_Code__r.Name = '93504'];
            wageObj.stateRate = true;
            wageObj.minimumRates = minimumWageRateList;
        } else{
            wageObj.stateRate = false;
            wageObj.minimumRates = minimumWageRateList;
        }
        return wageObj;
    }
    
    /* This method is used to get the IWC section number and IWC Order number for the case Issues. */
    @AuraEnabled
    public static IWCInfoWrapperObj getIWCInfo(String selectedIndustry){
        System.debug('selectedIndustry ::: '+selectedIndustry);
        IWCInfoWrapperObj iwcInfoWrapObj = new IWCInfoWrapperObj();
        if(String.isNotBlank(selectedIndustry)){
            List<NAICS_Code__c> iwcInfoObj = [SELECT IWC_Corder__c, NAICS_Title__c FROM NAICS_Code__c
                                        WHERE NAICS_Title__c =: selectedIndustry order by IWC_Corder__c desc NULLS LAST];
            System.debug('iwcInfoObj ::: '+iwcInfoObj);
            if(iwcInfoObj != null && iwcInfoObj.size() >0){
                iwcInfoWrapObj.iwcOrderNumber = iwcInfoObj[0].IWC_Corder__c;
                iwcInfoWrapObj.iwcSectionNumber = iwcInfoObj[0].IWC_Corder__c;
            }
        }
        System.debug('iwcInfoWrapObj ::: '+iwcInfoWrapObj);
        return iwcInfoWrapObj;
    }
    
    /* This method is used to get the custom metadata values for overtime year selection. */
    @AuraEnabled(cacheable=true)
    public static List<OWCOvertimeYearSelection__mdt> getOtDtYears(){
        return [SELECT Id, Year__c, Order_Number__c FROM OWCOvertimeYearSelection__mdt Order by Order_Number__c ASC];
    }
    
    public class IWCInfoWrapperObj{
        @AuraEnabled
        public Decimal iwcOrderNumber {get;set;}
        @AuraEnabled
        public Decimal iwcSectionNumber {get;set;}
    }
    
    public class wageRateWrapper{
        @AuraEnabled
        public boolean stateRate {get;set;}
        @AuraEnabled
        public List<Minimum_Wage_Rate__c> minimumRates {get;set;}
        @AuraEnabled
        public List<Minimum_Wage_Rate__c> stateWageList {get;set;}
    }
    
    public class violationTypeWrapper{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String dataType{get;set;}
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public String violationId{get;set;}
        @AuraEnabled
        public String violationTypeId{get;set;}
        @AuraEnabled
        public String description{get;set;}
    }
}