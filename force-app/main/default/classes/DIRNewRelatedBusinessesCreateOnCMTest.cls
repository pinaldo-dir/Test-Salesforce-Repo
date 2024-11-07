@isTest 
public class DIRNewRelatedBusinessesCreateOnCMTest {
    @isTest public static void saveRelatedBusinessesRecordTest(){
        PageReference pageRef = Page.DIRNewRelatedBusinessesCreateOnCM; 
        Test.setCurrentPage(pageRef);
        List<Account> listOfAccount = DIRDataFactory.createAccount();
        DIR_Case__c caseManagement = DIRDataFactory.createCaseManagement(listOfAccount[0].Id);
        Apexpages.StandardController sc = new Apexpages.StandardController(caseManagement);
        DIRNewRelatedBusinessesCreateOnCM controller = new DIRNewRelatedBusinessesCreateOnCM(sc);
        Test.startTest();
        controller.relatedBusinesses = DIRDataFactory.relatedBusinessesRecord('Test Account - BPAAS',listOfAccount);
        controller.businessName = 'Test Business';
        PageReference returnValue = controller.saveRelatedBusinessesRecord();
        Test.stopTest();
        System.assert(returnValue != null);
    }
    
    @isTest public static void saveRelatedBusinessesRecordTest1(){
        PageReference pageRef = Page.DIRNewRelatedBusinessesCreateOnCM;
        Test.setCurrentPage(pageRef);
        List<Account> listOfAccount = DIRDataFactory.createAccount();
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[0].Id,Related_Business__c=listOfAccount[1].Id,Type__c='Successor');
        insert relatedBusinessObj;
        DIR_Case__c caseManagement = DIRDataFactory.createCaseManagement(listOfAccount[0].Id);
        Apexpages.StandardController sc = new Apexpages.StandardController(caseManagement);
        DIRNewRelatedBusinessesCreateOnCM controller = new DIRNewRelatedBusinessesCreateOnCM(sc);
        Test.startTest();
        PageReference returnValue1 = controller.saveRelatedBusinessesRecord();
        controller.relatedBusinesses = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[0].Id,Related_Business__c=listOfAccount[1].Id,Type__c='Successor');
    	PageReference returnValue2 = controller.saveRelatedBusinessesRecord();
        Test.stopTest();
    	System.assertEquals(null, returnValue1);
    }
  
}