@isTest
public class WageClaimSearchResultContainerTest {
	@isTest
    public static void testgetWageClaimRecords(){
        Case_Role__c caseRoleObj = DIRDataFactory.createCaseRoleTestRecord();
        List<DIR_Case__c> WageClaimDetailsList = DIRDataFactory.createWageClaimDetailsTestData();
        String naicsCode = '';
        String accountName = '';
        Date docketDateFrom = System.today();
        Date docketDateTo = System.today();
        Date caseClosedFrom = System.today();
        Date caseClosedTo = System.today();
        String caseNumber = '';
        String lowWage = '';
        String dirOffice = '';
        Test.startTest();
        List<WageClaimSearchResultContainer.WageClaimRecord> WageClaimRecList = WageClaimSearchResultContainer.getWageClaimRecords(naicsCode, accountName, docketDateFrom, docketDateTo, caseClosedFrom, caseClosedTo, caseNumber, lowWage, dirOffice);
        Test.stopTest();
        System.assertEquals(1, WageClaimRecList.size());
    }
}