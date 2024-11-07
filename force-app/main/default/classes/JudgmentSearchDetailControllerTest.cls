@IsTest
public class JudgmentSearchDetailControllerTest {
@IsTest
    static void testGetJudgmentDetailsForNegativeCase(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecords();
        JudgmentSearchDetailController.JudgmentDetails judgmentSearchDetailObj = JudgmentSearchDetailController.getJudgmentDetails(liabilityJudgmentList[0].Judgement__c, liabilityJudgmentList[0].id);
        Test.stopTest();
        System.assert(judgmentSearchDetailObj != null);
    }
    @IsTest
    static void testGetJudgmentDetailsForPositiveCase(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        JudgmentSearchDetailController.JudgmentDetails judgmentSearchDetailObj = JudgmentSearchDetailController.getJudgmentDetails(liabilityJudgmentList[0].Judgement__c, liabilityJudgmentList[0].id);
        Test.stopTest();
        System.assert(judgmentSearchDetailObj != null);
    }
}