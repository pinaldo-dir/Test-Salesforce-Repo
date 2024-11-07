@IsTest
public class WageClaimSearchDetailPageCtrlTest {
    @IsTest static void testWageClaimSearchDetailPageCtrl(){
        Case_Role__c caseRoleObj = DIRDataFactory.createCaseRoleTestRecord();
        List<DIR_Case__c> WageClaimDetailsList = DIRDataFactory.createWageClaimDetailsTestData();
        ApexPages.currentPage().getParameters().put('crid',caseRoleObj.Id);
        ApexPages.currentPage().getParameters().put('id',caseRoleObj.Case__c);
        Test.startTest();
        WageClaimSearchDetailPageCtrl wageClaimSearchResult = new WageClaimSearchDetailPageCtrl();
        Test.stopTest();
        System.assert(wageClaimSearchResult != null);
    }
}