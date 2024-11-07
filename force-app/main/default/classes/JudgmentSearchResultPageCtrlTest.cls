@IsTest
public class JudgmentSearchResultPageCtrlTest {
    @IsTest
    static void testJudgmentSearchResultPageControllerForNegativeCase(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecords();
        Test.setCurrentPage(Page.JudgmentSearchResultPage);
        ApexPages.currentPage().getParameters().put('liststatus','Confirmed-On List');
        ApexPages.currentPage().getParameters().put('naics','');
        ApexPages.currentPage().getParameters().put('accountName','');
        ApexPages.currentPage().getParameters().put('city','');
        ApexPages.currentPage().getParameters().put('zipCode','');
        ApexPages.currentPage().getParameters().put('judgmentdate',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('judgmentdatefrom',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('judgmentdateto',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('court','');
        ApexPages.currentPage().getParameters().put('judgmentstatus','Partial Satisfaction,Full Satisfaction,Open');
        ApexPages.currentPage().getParameters().put('defandantemployer','');
        ApexPages.currentPage().getParameters().put('judgmenttotal',String.valueOf(0));
        ApexPages.currentPage().getParameters().put('citationnumber','');
        ApexPages.currentPage().getParameters().put('diroffice','');
        ApexPages.currentPage().getParameters().put('naicsCodeTitle','');
        ApexPages.currentPage().getParameters().put('county','');
        ApexPages.currentPage().getParameters().put('judgmentTotalFrom','0');
        ApexPages.currentPage().getParameters().put('judgmentTotalTo','0');
        ApexPages.currentPage().getParameters().put('sortingOrder','');
        ApexPages.currentPage().getParameters().put('selectedHeader','');
        ApexPages.currentPage().getParameters().put('judgmentEntryDateTo',String.valueOf(System.today()));
        Test.startTest();
        JudgmentSearchResultPageController judgmentObj = new JudgmentSearchResultPageController();
        Test.stopTest();
        System.assert(judgmentObj != null);
    }
    @IsTest
    static void testJudgmentSearchResultPageControllerForPositiveCase(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        Test.setCurrentPage(Page.JudgmentSearchResultPage);
        ApexPages.currentPage().getParameters().put('liststatus','Confirmed-On List');
        ApexPages.currentPage().getParameters().put('naics','');
        ApexPages.currentPage().getParameters().put('accountName','');
        ApexPages.currentPage().getParameters().put('city','');
        ApexPages.currentPage().getParameters().put('zipCode','');
        ApexPages.currentPage().getParameters().put('judgmentdate',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('judgmentdatefrom',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('judgmentdateto',String.valueOf(System.today()));
        ApexPages.currentPage().getParameters().put('court','');
        ApexPages.currentPage().getParameters().put('judgmentstatus','Partial Satisfaction,Full Satisfaction,Open');
        ApexPages.currentPage().getParameters().put('defandantemployer','');
        ApexPages.currentPage().getParameters().put('judgmenttotal',String.valueOf(0));
        ApexPages.currentPage().getParameters().put('citationnumber','');
        ApexPages.currentPage().getParameters().put('diroffice','');
        ApexPages.currentPage().getParameters().put('naicsCodeTitle','');
        ApexPages.currentPage().getParameters().put('county','');
        ApexPages.currentPage().getParameters().put('judgmentTotalFrom','0');
        ApexPages.currentPage().getParameters().put('judgmentTotalTo','0');
        ApexPages.currentPage().getParameters().put('sortingOrder','');
        ApexPages.currentPage().getParameters().put('selectedHeader','');
        ApexPages.currentPage().getParameters().put('judgmentEntryDateTo',String.valueOf(System.today()));
        JudgmentSearchResultPageController judgmentObj = new JudgmentSearchResultPageController();
        Test.stopTest();
        System.assert(judgmentObj != null);
    }
}