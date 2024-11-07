@IsTest
public class NewJudgmentPartyWithRelatedBusinessTest {
    @IsTest
    public static void testNewJudgmentPartyWithRelatedBusinessCtrl(){
        List<Judgement__c> judgList = DIRDataFactory.createJudgmentSearchRecords();
        PageReference pageRef = Page.NewJudgmentPartyWithRelatedBusiness;
        pageRef.getParameters().put('id', String.valueOf(judgList[0].Id));
        Test.setCurrentPage(pageRef);
        Related_Businesses__c relatedbuisnessdataList = DIRDataFactory.createRelatedBusinessesRecTestData();
        List<Account> accObjList = [select id from Account];
        Liability_Judgement__c liableJudgmentObj = new Liability_Judgement__c();
        liableJudgmentObj.Related_Business__c = relatedbuisnessdataList.id;
        liableJudgmentObj.X2810_4_Date_added_to_the_list__c = System.today();
        liableJudgmentObj.X2810_4_Date_Removed_from_the_list__c = System.today();
        liableJudgmentObj.X2810_4_List_Status__c = 'Confirmed-On List';
        Apexpages.StandardController sc = new Apexpages.StandardController(liableJudgmentObj);
        NewJudgmentPartyWithRelatedBusinessCtrl controller = new NewJudgmentPartyWithRelatedBusinessCtrl(sc);
        Test.startTest();
        PageReference returnValue = controller.saveRecord();
        Test.stopTest();
        //System.assert(returnValue != null);
    }
    @IsTest
    public static void testNewJudgmentPartyWithRelatedBusinessCtrl1(){
        NewJudgmentPartyWithRelatedBusinessCtrl controller;
        List<Judgement__c> judgList = DIRDataFactory.createJudgmentSearchRecords();
        PageReference pageRef = Page.NewJudgmentPartyWithRelatedBusiness;
        pageRef.getParameters().put('id', String.valueOf(judgList[0].Id));
        Test.setCurrentPage(pageRef);
        Related_Businesses__c relatedbuisnessdataList = DIRDataFactory.createRelatedBusinessesRecTestData();
        List<Account> accObjList = [select id from Account];
        Liability_Judgement__c liableJudgmentObj = new Liability_Judgement__c();
        liableJudgmentObj.Related_Business__c = relatedbuisnessdataList.id;
        liableJudgmentObj.X2810_4_Date_added_to_the_list__c = System.today();
        liableJudgmentObj.X2810_4_Date_Removed_from_the_list__c = System.today();
        liableJudgmentObj.X2810_4_List_Status__c = 'Confirmed-On List';
        liableJudgmentObj.Judgement__c = judgList[0].id;
        insert liableJudgmentObj;
        
        Liability_Judgement__c liableJudgmentObj1 = new Liability_Judgement__c();
        liableJudgmentObj1.Related_Business__c = relatedbuisnessdataList.id;
        liableJudgmentObj1.X2810_4_Date_added_to_the_list__c = System.today();
        liableJudgmentObj1.X2810_4_Date_Removed_from_the_list__c = System.today();
        liableJudgmentObj1.X2810_4_List_Status__c = 'Confirmed-On List';
        Apexpages.StandardController sc = new Apexpages.StandardController(liableJudgmentObj1);
        controller = new NewJudgmentPartyWithRelatedBusinessCtrl(sc);
        PageReference returnValue = controller.saveRecord();
        //System.assert(returnValue == null);
    }
}