@IsTest
public class RelatedBusinessLookupJudgmentPartyTest {
    @isTest public static void onGoTest(){
        List<Account> accountList = DIRDataFactory.createAccount();
        Judgement__c judObj = DIRDataFactory.createTestJudgmentRecord();
        PageReference pageRef = Page.RelatedBusinessLookupForJudgmentParty;
        Related_Businesses__c relatedBusiness = DIRDataFactory.relatedBusinessesRecord('Test Account - BPAAS',accountList);
        //DIR_Case__c caseManagement = DIRDataFactory.createCaseManagement(accountList[0].id);
        Liability_Judgement__c liableObj = new Liability_Judgement__c();
        liableObj.Related_Business__c = relatedBusiness.id;
        liableObj.Judgement__c = judObj.id;
        insert liableObj;
        pageRef.getParameters().put('rbname',relatedBusiness.Name);
        pageRef.getParameters().put('bid',relatedBusiness.Id);
        pageRef.getParameters().put('jid',judObj.Id);
        pageRef.getParameters().put('name',accountList[0].Name);
        Test.setCurrentPage(pageRef);
        RelatedBusinessLookupJudgmentPartyCtrl controller = new RelatedBusinessLookupJudgmentPartyCtrl();
        Test.startTest();
        PageReference returnValue =controller.onGo();
        Test.stopTest();
        System.assert(returnValue == null);
    }
    @isTest public static void onGoTestWithoutName(){
        List<Account> accountList = DIRDataFactory.createAccount();
        Judgement__c judObj = DIRDataFactory.createTestJudgmentRecord();
        PageReference pageRef = Page.RelatedBusinessLookupForJudgmentParty;
        Related_Businesses__c relatedBusiness = DIRDataFactory.relatedBusinessesRecord('Test Account - BPAAS',accountList);
        //DIR_Case__c caseManagement = DIRDataFactory.createCaseManagement(accountList[0].id);
        Liability_Judgement__c liableObj = new Liability_Judgement__c();
        liableObj.Related_Business__c = relatedBusiness.id;
        liableObj.Judgement__c = judObj.id;
        insert liableObj;
        pageRef.getParameters().put('rbname',relatedBusiness.Name);
        pageRef.getParameters().put('bid',relatedBusiness.Id);
        pageRef.getParameters().put('jid',judObj.Id);
        pageRef.getParameters().put('name','');
        Test.setCurrentPage(pageRef);
        RelatedBusinessLookupJudgmentPartyCtrl controller = new RelatedBusinessLookupJudgmentPartyCtrl();
        Test.startTest();
        PageReference returnValue =controller.onGo();
        Test.stopTest();
        System.assert(returnValue == null);
    }
}