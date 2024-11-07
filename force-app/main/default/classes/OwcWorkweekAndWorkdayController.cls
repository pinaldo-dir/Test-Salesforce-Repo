public with sharing class OwcWorkweekAndWorkdayController {

    @AuraEnabled(cacheable=true)
    public static List<OptionPickerWrapper> fetchWorkweekMetaData(){
        try {
            List<OptionPickerWrapper> OptionPickerWrapperList = new List<OptionPickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<Owc_workWeekOption__mdt> owcOwnershipOptionList =  [SELECT Id, MasterLabel,label,Value__c,Order_Number__c, Spanish_Translation__c FROM Owc_workWeekOption__mdt ORDER BY Order_Number__c];
            for(Owc_workWeekOption__mdt owcOwnershipOptionObj : owcOwnershipOptionList){
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
    public static List<OptionPickerWrapper> fetchYesOrNoOptions(){
        try {
            List<OptionPickerWrapper> OptionPickerWrapperList = new List<OptionPickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<Owc_workWeek_YesOrNoOption__mdt> owcWorkWeekYesOrNoList =  [SELECT Id, MasterLabel, Label, Order_Number__c, Spanish_Translation__c, Language FROM Owc_workWeek_YesOrNoOption__mdt ORDER BY Order_Number__c];
            for(Owc_workWeek_YesOrNoOption__mdt owcWorkWeekYesOrNoObj : owcWorkWeekYesOrNoList){
                OptionPickerWrapper languagePickerObj = new OptionPickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    languagePickerObj.label = owcWorkWeekYesOrNoObj.Spanish_Translation__c;
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    languagePickerObj.label = owcWorkWeekYesOrNoObj.label;
                }
                languagePickerObj.value = owcWorkWeekYesOrNoObj.label;
                OptionPickerWrapperList.add(languagePickerObj);
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