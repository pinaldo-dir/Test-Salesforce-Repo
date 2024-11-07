@IsTest
public class WageClaimQuerySelectorTest {
    @IsTest static void testGetWageClaimRecods(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord1();
        Case_Role__c caseRoleObj = DIRDataFactory.createCaseRoleTestRecord();
        List<DIR_Case__c> WageClaimDetailsList = DIRDataFactory.createWageClaimDetailsTestData();
        String naicsCode = 'test';
        String accountName = 'test';
        Date docketDateFrom = System.today();
        Date docketDateTo = System.today();
        Date caseClosedFrom = System.today();
        Date caseClosedTo = System.today();
        String caseNumber = 'test';
        String lowWage = 'test';
        String dirOffice = 'Los Angeles';
        Test.startTest();
        List<Case_Role__c> WageClaimRecList = WageClaimQuerySelector.getWageClaimRecods(naicsCode, accountName, docketDateFrom, docketDateTo, caseClosedFrom, caseClosedTo, caseNumber, lowWage, dirOffice);
        Test.stopTest();
        System.assertEquals(0, WageClaimRecList.size());
    }
    @IsTest static void testGetWageClaimDetails(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord1();
        Case_Role__c caseRoleObj = DIRDataFactory.createCaseRoleRecs();
        List<DIR_Case__c> caseManagementObj = DIRDataFactory.createCaseManagement();  
        Test.startTest();
        DIR_Case__c result = WageClaimQuerySelector.getWageClaimDetails(caseManagementObj[0].id, caseRoleObj.Id);
        Test.stopTest();
        System.assert(result != null);
    }
    @IsTest static void testGetContentDocumentLinkList(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord1();
        DIR_Case__c caseObj = DIRDataFactory.createCaseForContentLink();
        ContentVersion cv = DIRDataFactory.createContentDocument();
        ContentDocumentLink conDocLink = DIRDataFactory.createContentDocumentLink();
        Test.startTest();
        List<ContentDocumentLink> result = WageClaimQuerySelector.getContentDocumentLinkList(caseObj.Id);
        Test.stopTest();
        System.assert(result != null);
    }
    @IsTest static void testGetContentVersionList(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord1();
        Set<Id> createContentdocumentIdSet = DIRDataFactory.createContentdocumentIdList();
        Test.startTest();
        List<ContentVersion> result = WageClaimQuerySelector.getContentVersionList(createContentdocumentIdSet);
        Test.stopTest();
        System.assert(result != null);
    }
    @IsTest static void testGetDownloadContentUrlList(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord1();
        Set<Id> createContentdocumentIdSet = DIRDataFactory.createContentdocumentIdList();
        Test.startTest();
        List<ContentDistribution> result = WageClaimQuerySelector.getDownloadContentUrlList(createContentdocumentIdSet);
        Test.stopTest();
        System.assert(result != null);
    }
}