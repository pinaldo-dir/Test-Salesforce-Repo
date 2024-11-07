@IsTest
public class JudgmentSearchDetailPageCtrlTest {
    @IsTest
    static void testJudgmentSearchDetailPageCtrlForNegativeCase(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecords();
        ApexPages.currentPage().getParameters().put('id',liabilityJudgmentList[0].Judgement__c);
        ApexPages.currentPage().getParameters().put('jpid',liabilityJudgmentList[0].id);
        Test.startTest();
        JudgmentSearchDetailPageCtrl judgmentDetailObj = new JudgmentSearchDetailPageCtrl();
        Test.stopTest();
        System.assert(judgmentDetailObj != null);
    }
     @IsTest
    static void testJudgmentSearchDetailPageCtrlForPositiveCase(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        ApexPages.currentPage().getParameters().put('id',liabilityJudgmentList[0].Judgement__c);
        ApexPages.currentPage().getParameters().put('jpid',liabilityJudgmentList[0].id);
        JudgmentSearchDetailPageCtrl judgmentDetailObj = new JudgmentSearchDetailPageCtrl();
        Test.stopTest();
        System.assert(judgmentDetailObj != null);
    }
}