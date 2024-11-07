@IsTest
public class DIRRelatedAccountListOnJudgmentCtrlTest {
    
    @IsTest static void testDIRRelatedAccountListOnJudgmentCtrl(){
        Liability_Judgement__c liablePartyObj = DIRDataFactory.createRelatedBusinessObjs();
        Judgement__c judObj = new Judgement__c();
        judObj.Id = liablePartyObj.Judgement__c;
        PageReference tpageRef = Page.DIRRelatedAccountListOnJudgment;
        Test.setCurrentPage(tpageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(judObj);
        Test.startTest();
        DIRRelatedAccountListOnJudgmentCtrl ct = new DIRRelatedAccountListOnJudgmentCtrl(sc);
        DIRRelatedAccountListOnJudgmentCtrl.judgmentPartyWrapper obj = new DIRRelatedAccountListOnJudgmentCtrl.judgmentPartyWrapper('test','test','test','test','test');
        List<DIRRelatedAccountListOnJudgmentCtrl.judgmentPartyWrapper> wrapperList = new List<DIRRelatedAccountListOnJudgmentCtrl.judgmentPartyWrapper>();
        wrapperList.add(obj);
        ct.wrapper = wrapperList;
        Test.stopTest();
    }
}