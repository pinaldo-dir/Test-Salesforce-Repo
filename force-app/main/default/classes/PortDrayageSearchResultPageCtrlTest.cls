@IsTest
public class PortDrayageSearchResultPageCtrlTest {
    @IsTest
    static void testPortDrayageSearchResultForNegativeCase(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecords();
        Test.setCurrentPage(Page.PortDrayageSearchResultsPage);
        ApexPages.currentPage().getParameters().put('sortingOrder','asc');
        ApexPages.currentPage().getParameters().put('selectedHeader',' Claimant / Plaintiff Name');
        ApexPages.currentPage().getParameters().put('asofdate',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('todate',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('fromdate',String.valueOf(System.today()));
        Test.startTest();
        PortDrayageSearchResultPageCtrl portDrayageResult = new PortDrayageSearchResultPageCtrl();
        Test.stopTest();
    }
    @IsTest
    static void testPortDrayageSearchResultForPositiveCase(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        Test.setCurrentPage(Page.PortDrayageSearchResultsPage);
        ApexPages.currentPage().getParameters().put('sortingOrder','asc');
        ApexPages.currentPage().getParameters().put('selectedHeader',' Claimant / Plaintiff Name');
        ApexPages.currentPage().getParameters().put('asofdate',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('todate',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('fromdate',String.valueOf(System.today()));
        PortDrayageSearchResultPageCtrl portDrayageResult = new PortDrayageSearchResultPageCtrl();
        Test.stopTest();
    }
}