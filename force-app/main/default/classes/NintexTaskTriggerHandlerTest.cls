@isTest
public class NintexTaskTriggerHandlerTest {
    @isTest static void onBeforeInsertTest(){
        
        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        
        insert GenerateFieldHistoryActionTriggerSetting;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma;
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
        Account mainA = new Account();
        mainA.Name = 'name';
        mainA.ShippingPostalCode = '234889';
        String typeId =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        DIR_Case__c testCase = new DIR_Case__c();
        testCase.Employer__c = mainA.Id;
        testCase.Status__c = 'New';
        testCase.RecordTypeId = caseRT.Id;            
        testCase.Assigned_Deputy__c = de.Id;
        testCase.Docketing_Staff__c='Morfine';
        testCase.Date_Case_Received__c=  Date.newInstance(2016, 12, 9);
        testCase.Intake_Origin__c='Online';
        insert testCase;
        
        Date currentDate = System.today();
        Task testTask = new Task();
        testTask.Subject = 'This is feedback text! @ # $ % ^ &amp; * ( ) : ; &quot; &#39; &lt; &gt;';
        testTask.Start_Date__c = currentDate;
        testTask.Due_Date__c = currentDate;
        testTask.Type = 'Other';
        testTask.OwnerId = UserInfo.getUserId();
        testTask.WhatId = testCase.Id;
        testTask.Status = 'Completed';
        
        Test.startTest();
        Database.SaveResult result = Database.insert(testTask);
        Test.stopTest();
    }
}