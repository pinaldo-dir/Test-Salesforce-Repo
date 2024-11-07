public with sharing class OwcBusinessController {
   
    @AuraEnabled(cacheable=true)
    public static List<owcEmployerBussinessPickerWrapper> fetchOwcEmployerBussiness(){
        try {
            List<owcEmployerBussinessPickerWrapper> owcEmployerBussinessPickerWrapperList = new List<owcEmployerBussinessPickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<OWC_employer_successor_metadata__mdt> owcEmployerBussinessList =  [SELECT Id, MasterLabel, Label, Order_Number__c, Spanish_Translation__c, Language FROM OWC_employer_successor_metadata__mdt ORDER BY Order_Number__c ];
            for(OWC_employer_successor_metadata__mdt owcEmployerBussinessObj : owcEmployerBussinessList){
                owcEmployerBussinessPickerWrapper owcEmployerBussinessPickerObj = new owcEmployerBussinessPickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    owcEmployerBussinessPickerObj.label = owcEmployerBussinessObj.Spanish_Translation__c;
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    owcEmployerBussinessPickerObj.label = owcEmployerBussinessObj.label;
                }
                owcEmployerBussinessPickerObj.value = owcEmployerBussinessObj.label;
                owcEmployerBussinessPickerWrapperList.add(owcEmployerBussinessPickerObj);
            }

            return owcEmployerBussinessPickerWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<owcEmployerBussinessPickerWrapper> fetchOwcWorkRecorded(){
        try {
            List<owcEmployerBussinessPickerWrapper> owcWorkRecordNewList = new List<owcEmployerBussinessPickerWrapper>();
            User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];
            List<OWC_WorkRecorded__mdt> owcWorkRecordList =  [SELECT Id, MasterLabel, value__c, Label, Order_Number__c, Spanish_Translation__c, Language FROM OWC_WorkRecorded__mdt ORDER BY Order_Number__c];
            for(OWC_WorkRecorded__mdt owcWorkRecObj : owcWorkRecordList){
                owcEmployerBussinessPickerWrapper owcWorkRecordObj = new owcEmployerBussinessPickerWrapper();
                if(currentUserInfo.LanguageLocaleKey == 'es'){
                    owcWorkRecordObj.label = owcWorkRecObj.Spanish_Translation__c;
                }
                else if(currentUserInfo.LanguageLocaleKey == 'en_US'){
                    owcWorkRecordObj.label = owcWorkRecObj.label;
                }
                owcWorkRecordObj.value = owcWorkRecObj.value__c;
                owcWorkRecordNewList.add(owcWorkRecordObj);
            }

            return owcWorkRecordNewList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class owcEmployerBussinessPickerWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled 
        public string value{get;set;}
    }
}