@IsTest
public class DIRNewRelatedBusinessesCreateCtrlTest {
    @isTest public static void saveRelatedBusinessesRecordTest(){
        List<Account> accountList = DIRDataFactory.createAccount();
        PageReference pageRef = Page.DIRNewRelatedBusinessesCreatePage;
        String url = accountList[0].Id;
        pageref.getParameters().put('_lkid',url);
        Test.setCurrentPage(pageRef);
        Related_Businesses__c relatedBusinessObj = DIRDataFactory.relatedBusinessesRecord('Test Account - BPAAS',accountList);
        Apexpages.StandardController sc = new Apexpages.StandardController(relatedBusinessObj);
        DIRNewRelatedBusinessesCreateController controller = new DIRNewRelatedBusinessesCreateController(sc);
        controller.relatedBusinesses = relatedBusinessObj;
        Test.startTest();
        PageReference returnValue = controller.saveRelatedBusinessesRecord();
        PageReference returnmValue = controller.saveRelatedBusinessesRecord();
        Test.stopTest();
        System.assert(returnValue != null);
    }
    @isTest public static void saveRelatedBusinessesRecordTest2(){
        List<Account> accountList = DIRDataFactory.createAccount();
        PageReference pageRef = Page.DIRNewRelatedBusinessesCreatePage;
        String url = accountList[0].Id;
        pageref.getParameters().put('_kid',url);
        Test.setCurrentPage(pageRef);
        Related_Businesses__c relatedBusinessObj = DIRDataFactory.relatedBusinessesRecord('Test Account',accountList);
        Apexpages.StandardController sc = new Apexpages.StandardController(relatedBusinessObj);
        DIRNewRelatedBusinessesCreateController controller = new DIRNewRelatedBusinessesCreateController(sc);
        controller.relatedBusinesses = relatedBusinessObj;
        Test.startTest();
        
        PageReference returnValue = controller.saveRelatedBusinessesRecord();
        PageReference returnmValue = controller.saveRelatedBusinessesRecord();
        Test.stopTest();
        System.assert(returnValue != null);
    }
}