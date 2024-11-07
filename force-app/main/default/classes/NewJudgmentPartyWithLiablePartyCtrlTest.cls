@IsTest
public class NewJudgmentPartyWithLiablePartyCtrlTest {
    @IsTest
    public static void NewJudgmentPartyWithLiablePartyTest(){
        PageReference pageRef = Page.NewJudgmentPartyWithLiableParty;
        Test.setCurrentPage(pageRef);
        Judgement__c judgmentObj = DIRDataFactory.createTestJudgmentRecord();
        Liable_Party__c liablePartyObj = DIRDataFactory.createTestLiablePartyRecord();
        Liability_Judgement__c liableJudgmentObj = new Liability_Judgement__c();
        liableJudgmentObj.Liable_Party__c = liablePartyObj.Id;
        liableJudgmentObj.X2810_4_List_Status__c = 'Confirmed-on List';
        liableJudgmentObj.Judgement__c = system.currentPageReference().getParameters().put('Id', String.valueOf(judgmentObj.Id));
        Apexpages.StandardController sc = new Apexpages.StandardController(liableJudgmentObj);
        NewJudgmentPartyWithLiablePartyCtrl controller = new NewJudgmentPartyWithLiablePartyCtrl(sc);
        Test.startTest();
        PageReference returnValue = controller.saveRecord();
        Test.stopTest();
        System.assert(returnValue != null);
    }
}