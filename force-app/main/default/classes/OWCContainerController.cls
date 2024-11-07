public with sharing class OWCContainerController {

    public static String currentUserId = UserInfo.getUserId();

    @AuraEnabled(cacheable=false)
    public static string changedUserLanguage(String selectedLanguage){
        try {
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :currentuserId limit 1];
            currentUserInfo.LanguageLocaleKey = selectedLanguage;
            update currentUserInfo;
            return 'OK';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static string getUserCurrentLanguage(boolean status){
        try {
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :currentUserId limit 1];
            return currentUserInfo.LanguageLocaleKey;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<languagePickerWrapper> getLanguagesData(){
        try {
            List<languagePickerWrapper> languagePickerWrapperList = new List<languagePickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<OWCLanguages__mdt> owcLanguageList =  [SELECT Id, Language__c, Spanish_Translation__c FROM OWCLanguages__mdt];
            for(OWCLanguages__mdt owcLanguageObj : owcLanguageList){
                languagePickerWrapper languagePickerObj = new languagePickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    languagePickerObj.label = owcLanguageObj.Spanish_Translation__c;
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    languagePickerObj.label = owcLanguageObj.Language__c;
                }
                languagePickerObj.value = owcLanguageObj.Language__c;
                languagePickerWrapperList.add(languagePickerObj);
            }
            return languagePickerWrapperList;
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