public with sharing class OwcInfoSection {
    
    @AuraEnabled(cacheable=true)
    public static List<industryPickerWrapper>  getIndustry(){
        try {
            List<industryPickerWrapper> industryPickerWrapperList = new List<industryPickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<OWC_Industry_Wage_Order__mdt> owcindustryList =  [SELECT Id, Label, NaicsCodeLevel1EnglishTranslation__c, NaicsCodeLevel1SpanishTranslation__c, Order_Number__c FROM OWC_Industry_Wage_Order__mdt ORDER BY Order_Number__c ASC];
            for(OWC_Industry_Wage_Order__mdt owcindustryObj : owcindustryList){
                industryPickerWrapper industryPickerObj = new industryPickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    industryPickerObj.label = owcindustryObj.NaicsCodeLevel1SpanishTranslation__c;
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    industryPickerObj.label = owcindustryObj.NaicsCodeLevel1EnglishTranslation__c;
                }
                industryPickerObj.value = owcindustryObj.NaicsCodeLevel1EnglishTranslation__c;
                industryPickerWrapperList.add(industryPickerObj);
            }

            
            return industryPickerWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<industryPickerWrapper> getnaics(String industryName){
        try {
            List<industryPickerWrapper> industryPickerWrapperList = new List<industryPickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            OWC_Industry_Wage_Order__mdt owcindustryList =  [SELECT Id, Label, NaicsCodeLevel1EnglishTranslation__c, NaicsCodeLevel2EnglishTranslation__c, NaicsCodeLevel2SpanishTranslation__c, Order_Number__c FROM OWC_Industry_Wage_Order__mdt WHERE NaicsCodeLevel1EnglishTranslation__c =:industryName limit 1];
            List<String> subIndustrySpanishTranslation = owcindustryList.NaicsCodeLevel2SpanishTranslation__c.split(';');
            List<String> subIndustryEnglishTranslation = owcindustryList.NaicsCodeLevel2EnglishTranslation__c.split(';');
            for(Integer i = 0; i<subIndustryEnglishTranslation.size(); i++){
                industryPickerWrapper industryPickerObj = new industryPickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    industryPickerObj.label = subIndustrySpanishTranslation[i];
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    industryPickerObj.label = subIndustryEnglishTranslation[i].split('~')[0];
                }
                industryPickerObj.value = subIndustryEnglishTranslation[i].split('~')[1];
                industryPickerWrapperList.add(industryPickerObj);
            }
            System.debug('industryPickerWrapperList ::: '+industryPickerWrapperList);
            return industryPickerWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class industryPickerWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled 
        public string value{get;set;}
    }
}