@IsTest
public class WageClaimSearchDetailControllerTest {
	@IsTest
    public static void testWageClaimDetails(){
        Case_Role__c caseRoleObj = DIRDataFactory.createCaseRoleTestRecord();
        List<DIR_Case__c> WageClaimDetailsList = DIRDataFactory.createWageClaimDetailsTestData();
        Test.startTest();
        WageClaimSearchDetailController.WageClaimDetails WageClaimRecList = WageClaimSearchDetailController.getWageClaimDetails(caseRoleObj.Case__c, caseRoleObj.Id);
        Test.stopTest();
        System.debug('WageClaimRecList ::: '+WageClaimRecList);
    }
    @IsTest
    public static void testDownloadContentUrl(){
        Test.startTest();
        ContentVersion cv = DIRDataFactory.createContentDocumentForAttachmentObj();
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = DIRDataFactory.createContentDocumentLinkForAttachmentObj((String)conDocId);
        ID caseObjId = [select id from DIR_Case__c where Low_Wage_Occupation__c = 'Port' limit 1].id;
        Map<String,String> mapOfAttachment = WageClaimSearchDetailController.getDownloadContentUrl(caseObjId);
        Test.stopTest();
        System.debug('testDownloadContentUrl ::: '+mapOfAttachment);
    }
}