public with sharing class OwcWageDeficiencies {
    @AuraEnabled(cacheable=true)
    public static List<languagePickerWrapper> fetchseverancePayOfferedOption(){
        try {
            List<languagePickerWrapper> WrapperList = new List<languagePickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<Owc_severance_Pay_Offered_Option__mdt> owcLanguageList =  [SELECT Id, Value__c, Label, Order_Number__c, Spanish_Translation__c, Language FROM Owc_severance_Pay_Offered_Option__mdt ORDER BY Order_Number__c];
            for( Owc_severance_Pay_Offered_Option__mdt owcLanguageObj : owcLanguageList){
                languagePickerWrapper languagePickerObj = new languagePickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    languagePickerObj.label = owcLanguageObj.Spanish_Translation__c;
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    languagePickerObj.label = owcLanguageObj.Label;
                }
                languagePickerObj.value = owcLanguageObj.Value__c;
                WrapperList.add(languagePickerObj);
            }

            return WrapperList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class languagePickerWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled 
        public string value{get;set;}
    }
}