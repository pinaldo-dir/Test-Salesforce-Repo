@IsTest
public class RelatedBusinessTriggerTest {
    @testSetup static void methodName(){
        List<Account> listOfAccount = DIRDataFactory.createAccount();
    }
    @IsTest public static void checkInverseRelatedBusinessRecordTestForTypeSuccessor(){
        List<Account> listOfAccount = DIRDataFactory.createAccount();
        DIRDataFactory.caseRoleRecord(listOfAccount[0].Id);
        Related_Businesses__c relatedBusinessesObj = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[0].Id,Related_Business__c=listOfAccount[1].Id,Type__c='Successor');
        Test.startTest();
        Database.saveResult result = Database.insert(relatedBusinessesObj);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess());
        
    }
    @IsTest public static void checkInverseRelatedBusinessRecordTestForTypeRelatedBusiness(){
        List<Account> listOfAccount = DIRDataFactory.createAccount();
        DIRDataFactory.caseRoleRecord(listOfAccount[0].Id);
        Related_Businesses__c relatedBusinessesObj = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[0].Id,Related_Business__c=listOfAccount[1].Id,Type__c='LC 238 (Related Business)');
        Test.startTest();
        Database.saveResult result = Database.insert(relatedBusinessesObj);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess());
        
    }
    @IsTest public static void checkInverseRelatedBusinessRecordTestForTypeAlterEgo(){
        List<Account> listOfAccount = DIRDataFactory.createAccount();
        DIRDataFactory.caseRoleRecord(listOfAccount[0].Id);
        Related_Businesses__c relatedBusinessesObj = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[0].Id,Related_Business__c=listOfAccount[1].Id,Type__c='Alter Ego');
        Test.startTest();
        Database.saveResult result = Database.insert(relatedBusinessesObj);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess());
        
    }
    @IsTest public static void checkInverseRelatedBusinessRecordTestForTypeParentCompany(){
        List<Account> listOfAccount = DIRDataFactory.createAccount();
        DIRDataFactory.caseRoleRecord(listOfAccount[0].Id);
        Related_Businesses__c relatedBusinessesObj = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[0].Id,Related_Business__c=listOfAccount[1].Id,Type__c='Parent Company');
        Test.startTest();
        Database.saveResult result = Database.insert(relatedBusinessesObj);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess());
        
    }
    @IsTest public static void checkInverseRelatedBusinessRecordTestForTypeSubsidiary(){
        List<Account> listOfAccount = DIRDataFactory.createAccount();
        DIRDataFactory.caseRoleRecord(listOfAccount[0].Id);
        Related_Businesses__c relatedBusinessesObj = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[0].Id,Related_Business__c=listOfAccount[1].Id,Type__c='Subsidiary');
        Test.startTest();
        Database.saveResult result = Database.insert(relatedBusinessesObj);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess());
        
    }
    @IsTest public static void checkInverseRelatedBusinessRecordTestForTypeSingleEnterprise(){
        List<Account> listOfAccount = DIRDataFactory.createAccount();
        DIRDataFactory.caseRoleRecord(listOfAccount[0].Id);
        Related_Businesses__c relatedBusinessesObj = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[0].Id,Related_Business__c=listOfAccount[1].Id,Type__c='Single Enterprise');
        Test.startTest();
        Database.saveResult result = Database.insert(relatedBusinessesObj);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess());
        
    }
    @IsTest public static void checkInverseRelatedBusinessRecordTestForTypePredecessor(){
        List<Account> listOfAccount = DIRDataFactory.createAccount();
        DIRDataFactory.caseRoleRecord(listOfAccount[1].Id);
        Related_Businesses__c relatedBusinessesObj = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[1].Id,Related_Business__c=listOfAccount[0].Id,Type__c='Predecessor');
        Test.startTest();
        Database.saveResult result = Database.insert(relatedBusinessesObj);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess());
        
    }
    @IsTest public static void checkDuplicateRelatedBusinessesTest(){ 
        List<Account> listOfAccount = DIRDataFactory.createAccount();
        DIRDataFactory.caseRoleRecord(listOfAccount[1].Id);
        DIRDataFactory.relatedBusinessesRecord('Test Account - EXIST', listOfAccount);
        Related_Businesses__c relatedBusinessesObj = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[0].Id,Related_Business__c=listOfAccount[1].Id,Type__c='LC 238 (Related Business)');
        Test.startTest();
        Database.saveResult result = Database.insert(relatedBusinessesObj, False);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess());
        
    }
    @IsTest public static void checkCreateCaseNoteTest(){
        String caseNote = 'A potential related business has been identified.';
        DIR_Case__c caseObj = DIRDataFactory.createCaseManagementTestRecord();
        Test.startTest();
        Case_Note__c caseNoteObj = RelatedBusinessTriggerHelper.createCaseNote(caseObj.Id, caseNote);
        Test.stopTest();
        System.assert(caseNoteObj != null);
    }
    @IsTest public static void checkCreateRelatedPartyRecord(){
        DIR_Case__c caseObj = DIRDataFactory.createCaseManagementTestRecord();
        List<Related_Businesses__c> relatedBusinessObjList = DIRDataFactory.createRelatedBusinessesTestData1();
        Test.startTest();
        Related_Party__c relatedPartyObj = RelatedBusinessTriggerHelper.createRelatedPartyRecord(caseObj.Id, relatedBusinessObjList[0].Id, relatedBusinessObjList[0].Id);
        Test.stopTest();
        System.assert(relatedPartyObj != null);
    }
    @IsTest public static void checkRelatedBusinessAfterUpdate(){
        List<String> accNameSet = new List<String>{'%William%','%Nina KalKat%'};
        List<Account> listOfAccount = [select Name from Account WHERE Name LIKE :accNameSet];
        DIRDataFactory.caseRoleRecord(listOfAccount[0].Id);
        Related_Businesses__c relatedBusinessesObj = new Related_Businesses__c(Name__c='Test Account - BPAAS',Business__c=listOfAccount[1].Id,Related_Business__c=listOfAccount[0].Id,Type__c='Predecessor');
        insert relatedBusinessesObj;
        relatedBusinessesObj.Type__c = 'Alter Ego';
        Test.startTest();
        DirUtils.isFirstTime = true; 
        Database.SaveResult result = Database.update(relatedBusinessesObj);
        Test.stopTest();
        System.assert(result.isSuccess());
        System.assert(result.getId() != null);
    }
}