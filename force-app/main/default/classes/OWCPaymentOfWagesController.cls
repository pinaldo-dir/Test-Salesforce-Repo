public with sharing class OWCPaymentOfWagesController {
    @AuraEnabled(cacheable=true)
    public static List<OptionPickerWrapper> fetchFrequencyMetaData(){
        try {
            List<OptionPickerWrapper> OptionPickerWrapperList = new List<OptionPickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<OwcFrequencyOption__mdt> owcOwnershipOptionList =  [SELECT label,Value__c,Order_Number__c,Spanish_Translation__c FROM OwcFrequencyOption__mdt ORDER BY Order_Number__c];
            for(OwcFrequencyOption__mdt owcOwnershipOptionObj : owcOwnershipOptionList){
                OptionPickerWrapper ownershipOptionPickerObj = new OptionPickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    ownershipOptionPickerObj.label = owcOwnershipOptionObj.Spanish_Translation__c;
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    ownershipOptionPickerObj.label = owcOwnershipOptionObj.Value__c;
                }
                ownershipOptionPickerObj.value = owcOwnershipOptionObj.Value__c;
                OptionPickerWrapperList.add(ownershipOptionPickerObj);
            }

            return OptionPickerWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<OptionPickerWrapper> fetchOptionsMetaData(){
        try {
            List<OptionPickerWrapper> owcPaymentTypeList = new List<OptionPickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<OWC_PaymentTypeMultiSelect__mdt> PaymentTypeMultiList =  [SELECT label,PicklistTypeValue__c,Order_Number__c,Spanish_Translation__c FROM OWC_PaymentTypeMultiSelect__mdt ORDER BY Order_Number__c];
            for(OWC_PaymentTypeMultiSelect__mdt owcPaymentTypeOptionObj : PaymentTypeMultiList){
                OptionPickerWrapper PaymentTypeOptionPickerObj = new OptionPickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    PaymentTypeOptionPickerObj.label = owcPaymentTypeOptionObj.Spanish_Translation__c;
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    PaymentTypeOptionPickerObj.label = owcPaymentTypeOptionObj.PicklistTypeValue__c;
                }
                PaymentTypeOptionPickerObj.value = owcPaymentTypeOptionObj.PicklistTypeValue__c;
                owcPaymentTypeList.add(PaymentTypeOptionPickerObj);
            }

            return owcPaymentTypeList;
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