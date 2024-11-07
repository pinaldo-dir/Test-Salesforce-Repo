@IsTest
public class WageClaimSearchControllerTest {
    @IsTest(SeeAllData=true)
    static void getJudgmentDirOfficeTest(){
        Test.startTest();
        List<String> dirOfficeList = WageClaimSearchController.getJudgmentDirOffice();
        Test.stopTest();
    }
    @IsTest
    static void getLowWageOccupationPicklistTest(){
        List<DIR_Case__c> dirCaseList = DIRDataFactory.createCaseManagement();
        Test.startTest();
        List<String> wageClaimList =  WageClaimSearchController.getLowWageOccupationPicklist();
        Test.stopTest();
        System.assertEquals(19, wageClaimList.size());
    }
    @IsTest
    static void getAllPicklistTest(){
        List<DIR_Case__c> dirCaseList = DIRDataFactory.createCaseManagement();
        Test.startTest();
        WageClaimSearchController.WageClaimWrapperClass pickListObj = WageClaimSearchController.getAllPicklist();
        Test.stopTest();
        System.assertEquals(19, pickListObj.lowWage.size());
    }
}