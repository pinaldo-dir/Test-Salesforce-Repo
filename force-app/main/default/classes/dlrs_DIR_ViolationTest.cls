/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 * 😂😂😂 and then mercilessly hacked to be able to deactivate when running tests in Jan 2021 as part of Cashiering Phase II Tier I 😂😂😂
 **/
@IsTest
private class dlrs_DIR_ViolationTest
{
    @IsTest
    private static void testTrigger()
    {
        ////
        ////
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c cpTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        triggerSettings.add(cpTriggerSetting);
        
        Trigger_Settings__c lpTriggerSetting = new Trigger_Settings__c(
            Name = 'liabilityPaymentTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(lpTriggerSetting);

        Trigger_Settings__c dlrs_prTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_Payment_RecordTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_prTriggerSetting);

        Trigger_Settings__c dlrs_judgementTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_JudgementTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_judgementTriggerSetting);

        Trigger_Settings__c dlrs_DIR_ViolationTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = true
        );
        triggerSettings.add(dlrs_DIR_ViolationTriggerSetting);

        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = true
        );
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;
        ////

        Account employerAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        insert employerAccount;
        
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employerAccount.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        insert employerAccountLocation;
        
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );            
        insert manager;
            
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
        
        Office__c bofeOffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert bofeOffice;
        
        DIR_Case__c bofeCase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employerAccount.Id,
            Office__c = bofeOffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert bofeCase;
        
        DIR_Violation__c caseIssue = new DIR_Violation__c(
            Case__C = bofeCase.Id
        );
        ////
        ////

        // Force the dlrs_DIR_ViolationTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(caseIssue);
    }
}