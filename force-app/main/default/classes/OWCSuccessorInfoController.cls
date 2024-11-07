public with sharing class OWCSuccessorInfoController {
    @AuraEnabled(cacheable=true)
    public static List<OptionPickerWrapper> fetchOwnershipMetaData(){
        try {
            List<OptionPickerWrapper> OptionPickerWrapperList = new List<OptionPickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<OWC_Successor_Ownership_Type__mdt> owcOwnershipOptionList =  [SELECT Id, MasterLabel,label,Order_Number__c, Spanish_Translation__c,OWC_Successor_Ownership_Type_Value__c FROM OWC_Successor_Ownership_Type__mdt ORDER BY Order_Number__c];
            for(OWC_Successor_Ownership_Type__mdt owcOwnershipOptionObj : owcOwnershipOptionList){
                OptionPickerWrapper ownershipOptionPickerObj = new OptionPickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    ownershipOptionPickerObj.label = owcOwnershipOptionObj.Spanish_Translation__c;
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    ownershipOptionPickerObj.label = owcOwnershipOptionObj.label;
                }
                ownershipOptionPickerObj.value = owcOwnershipOptionObj.label;
                OptionPickerWrapperList.add(ownershipOptionPickerObj);
            }

            return OptionPickerWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OptionPickerWrapper> fetchHoursWorkedMetaData(){
        try {
            List<OptionPickerWrapper> OptionPickerWrapperList = new List<OptionPickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<OWC_Successor_Hours_Work_Recorded_Type__mdt> owcHoursWorkedOptionList =  [SELECT Id, MasterLabel,label,Order_Number__c, Spanish_Translation__c,OWC_Successor_Hours_Work_Recorded_Value__c FROM OWC_Successor_Hours_Work_Recorded_Type__mdt ORDER BY Order_Number__c];
            for(OWC_Successor_Hours_Work_Recorded_Type__mdt owcHoursWorkedOptionObj : owcHoursWorkedOptionList){
                OptionPickerWrapper hoursWorkedPickerObj = new OptionPickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    hoursWorkedPickerObj.label = owcHoursWorkedOptionObj.Spanish_Translation__c;
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    hoursWorkedPickerObj.label = owcHoursWorkedOptionObj.label;
                }
                hoursWorkedPickerObj.value = owcHoursWorkedOptionObj.label;
                OptionPickerWrapperList.add(hoursWorkedPickerObj);
            }

            return OptionPickerWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class OptionPickerWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled 
        public string value{get;set;}
    }
}