/*Majorly HACKED as part of the Cashiering Enhancements Phase II project to reduce APEX CPU Time Limit errors when running most other tests.*/
@isTest
private class GenerateFieldHistoryActionTEST {

    static testMethod void testCreateCaseHistory() {

        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(
            Name = 'CaseRoleAll',
            Is_Active__c = true
        ));
            
        triggerSettings.add(new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = true
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'dlrs_JudgementTrigger',
            Is_Active__c = false
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = true
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'LiabilityPaymentTrigger',
            Is_Active__c = false
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = false
        ));
        insert triggerSettings;


        History_Object_Configuration__c hoc = new History_Object_Configuration__c(
            Object_name__c = 'Case Violation',
            Object_API_Name__c = 'DIR_Violation__c',
            Active__c = true,
            Path_to_Case__c = 'Case__r'
        );
        insert hoc;

        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
                
        DIR_Case__c dirCase = new DIR_Case__c(
            RecordTypeId = caseRT.Id,            
            Assigned_Deputy__c = de.Id
        );
        insert dirCase;
        
        RecordType violRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Violation__c' AND Name LIKE '%WCA%' AND IsActive = true LIMIT 1];

        Assessments__c assess = new Assessments__c(
        Case_Management__c = dirCase.Id
        );
        insert assess;
        
        DIR_Violation__c viol = new DIR_Violation__c(
            Case__c = dirCase.Id,
            Assessment__c = assess.Id,
            Status__c = 'New',
            RecordTypeId = violRT.Id
        );
        insert viol;
        
        History_Field_Configuration__c hfc = new History_Field_Configuration__c(
            History_Object_Configuration__c = hoc.Id,
            Active__c = true,
            API_Field_Name__c = 'Status__c',
            Tracked_Record_Types__c = violRT.Id
        );
        insert hfc;
        
        viol.Status__c = 'Under Investigation';
        update viol;

        System.debug('92 case: ' + dirCase);

        Case_History__c ch = [SELECT Id, Old_Value__c, New_Value__c 
                                FROM Case_History__c WHERE Case_Management__c =:dirCase.Id LIMIT 1];
        
        system.assertEquals(ch.Old_Value__c, 'Open');
        system.assertEquals(ch.New_Value__c, 'Under Investigation');
    }
    
    static testmethod void testLabel(){
        Labels__c l = new Labels__c();
        insert l;
    }
}