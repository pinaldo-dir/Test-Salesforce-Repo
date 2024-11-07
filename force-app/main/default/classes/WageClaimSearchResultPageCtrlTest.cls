@IsTest
public class WageClaimSearchResultPageCtrlTest {
    @IsTest
    static void testWageClaimSearchResultPageCtrl(){
        Case_Role__c caseRoleObj = DIRDataFactory.createCaseRoleTestRecord();
        List<DIR_Case__c> WageClaimDetailsList = DIRDataFactory.createWageClaimDetailsTestData();
        Test.setCurrentPage(Page.WageClaimSearchResultPage);
        ApexPages.currentPage().getParameters().put('fromDate',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('toDate',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('caseclosedfromdate',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('caseclosedtodate',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('dirOffice','');
        ApexPages.currentPage().getParameters().put('accountName','');
        ApexPages.currentPage().getParameters().put('naicsCode','');
        ApexPages.currentPage().getParameters().put('caseNumber','');
        ApexPages.currentPage().getParameters().put('lowWage','');
        ApexPages.currentPage().getParameters().put('sortingOrder','');
        ApexPages.currentPage().getParameters().put('selectedHeader','');
        Test.startTest();
        WageClaimSearchResultPageCtrl wageClaimObj = new WageClaimSearchResultPageCtrl();
        Test.stopTest();
        System.assert(wageClaimObj != null);
    }
}