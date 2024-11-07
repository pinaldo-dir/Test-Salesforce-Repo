@isTest(SeeAllData=true)
public class OWCConsentTriggerHandlerTest {
    @isTest static void testupdateConsentOptOut(){
        List<smagicinteract__Consent__c> consents = [SELECT Id,smagicinteract__Compliance_Status__c 
                                                     FROM smagicinteract__Consent__c 
                                                     WHERE smagicinteract__Compliance_Status__c = 'Opt-Out' LIMIT 1];
        if(consents != null && consents.size() > 0){
            Test.startTest();
            consents[0].smagicinteract__Compliance_Status__c = 'Opt-In';
            smagicinteract__Consent__c consent = consents[0];
            update consent;
            Test.stopTest();
        }
    }
        @isTest static void testupdateConsentOptIn(){
        List<smagicinteract__Consent__c> consents = [SELECT Id,smagicinteract__Compliance_Status__c 
                                                     FROM smagicinteract__Consent__c 
                                                     WHERE smagicinteract__Compliance_Status__c = 'Opt-In' LIMIT 1];
        if(consents != null && consents.size() > 0){
            Test.startTest();
            consents[0].smagicinteract__Compliance_Status__c = 'Opt-Out';
            smagicinteract__Consent__c consent = consents[0];
            update consent;
            Test.stopTest();
        }
    }
}