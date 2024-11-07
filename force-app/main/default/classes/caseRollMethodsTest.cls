@isTest
public with sharing class caseRollMethodsTest {
     public static testMethod void TestCreate0() {
        
        Account mainA = new Account();
        mainA.Name = 'Lucian459487';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert AffA;
        
        DIR_Case__c cs = new DIR_Case__c();
        cs.Employer__c = mainA.Id;
        insert cs;
        list<Case_Role__c> caseRoleList = new list<Case_Role__c>();
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = cs.Id;
        cr.Entity__c = affA.Id;
        cr.Role__c = 'Employer';
        cr.Account_Name__c = mainA.Name;
        caseRoleList.add(cr);
        
        Address__c addObj = new Address__c();
        addObj.Entity__c = affA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        insert addObj;
        
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = affA.Id;
        relatedBusinessObj.Related_Business__c = mainA.Id;
        relatedBusinessObj.Type__c = 'Alter Ego';
        insert relatedBusinessObj;
        caseRollMethods.applyLocation(caseRoleList);
        
    } 
    
    public static testMethod void TestCreate1() {
        
        Account mainA = new Account();
        mainA.Name = 'Lucian459487';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert AffA;
        
        DIR_Case__c cs = new DIR_Case__c();
        cs.Employer__c = mainA.Id;
        insert cs;
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = cs.Id;
        cr.Entity__c = affA.Id;
        cr.Role__c = 'Employer';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        Address__c addObj = new Address__c();
        addObj.Entity__c = affA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        insert addObj;
        
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = affA.Id;
        relatedBusinessObj.Related_Business__c = mainA.Id;
        relatedBusinessObj.Type__c = 'Alter Ego';
        insert relatedBusinessObj;
        
        cr.Role__c = 'Owner';
        update cr;
        
    } 
    
    public static testMethod void TestCreate2() {
        
        Account mainA = new Account();
        mainA.firstName = 'Test';
        mainA.lastName = 'Me';
        insert mainA;
        
        Account mainA1 = new Account();
        mainA1.firstName = 'Test1';
        mainA1.lastName = 'Me1';
        insert mainA1;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert AffA;
        
        DIR_Case__c cs = new DIR_Case__c();
        cs.Employer__c = mainA.Id;
        insert cs;
        
        DIR_Case__c cs1 = new DIR_Case__c();
        cs1.Employer__c = mainA.Id;
        insert cs1;
        
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = affA.Id;
        relatedBusinessObj.Related_Business__c = mainA.Id;
        relatedBusinessObj.Type__c = 'Successor';
        insert relatedBusinessObj;
        Test.startTest();
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = cs.Id;
        cr.Entity__c = affA.Id;
        cr.Account_Name__c = mainA.firstName + ' ' + mainA.lastName;
        insert cr;
        
        delete cr;
        Test.stopTest();
    } 
    
    public static testMethod void TestCreate3(){
        Account mainA = new Account();
        mainA.firstName = 'Test';
        mainA.lastName = 'Me';
        insert mainA;
        
        DIR_Case__c cs = new DIR_Case__c();
        cs.Employer__c = mainA.Id;
        insert cs;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert AffA;
        
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = affA.Id;
        relatedBusinessObj.Related_Business__c = mainA.Id;
        relatedBusinessObj.Type__c = 'Successor';
        insert relatedBusinessObj;
        
        Related_Party__c result = caseRollMethods.createRelatedPartyRecord(cs.Id, relatedBusinessObj.Business__r.Name, relatedBusinessObj.Business__c);
    }
    
    public static testMethod void TestCreate4(){
        Account mainA = new Account();
        mainA.firstName = 'Test';
        mainA.lastName = 'Me';
        insert mainA;
        
        DIR_Case__c cs = new DIR_Case__c();
        cs.Employer__c = mainA.Id;
        insert cs;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert AffA;
        
        Case_Note__c caseNoteObj = caseRollMethods.createCaseNote(cs.Id, 'test');
    }
}