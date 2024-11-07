@isTest
public class OwcInfoSection_Test {
     private static testMethod void test_getIndustry() {
         OwcInfoSection.getIndustry();
         OWC_Industry_Wage_Order__mdt obj =new OWC_Industry_Wage_Order__mdt();
         obj.NaicsCodeLevel1EnglishTranslation__c='Technical or Clerical';
         obj.Label='tester';
         obj.NaicsCodeLevel1EnglishTranslation__c='Contact';
         obj.Order_Number__c=548;
         obj.OWC_Industry__c='Technical or Clerical';
         
         OwcInfoSection.getnaics('Professional, Technical or Clerical');
             
     }
}