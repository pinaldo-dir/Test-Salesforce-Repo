@isTest
public with sharing class CaseRoleAllTest {

    public static testMethod void TestCreate1() {

        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        
        Trigger_Settings__c caseRoleAllTriggerSetting = new Trigger_Settings__c(
            Name = 'CaseRoleAll',
            Is_Active__c = true
        );
        triggerSettings.add(caseRoleAllTriggerSetting);

        Trigger_Settings__c dlrs_DIR_ViolationTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_DIR_ViolationTriggerSetting);

        Trigger_Settings__c dlrs_judgementTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_JudgementTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_judgementTriggerSetting);

        Trigger_Settings__c generateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        triggerSettings.add(generateFieldHistoryActionTriggerSetting);

        Trigger_Settings__c lpTriggerSetting = new Trigger_Settings__c(
            Name = 'LiabilityPaymentTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(lpTriggerSetting);

        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = false
        );
        triggerSettings.add(rctTriggerSetting);
        insert triggerSettings;
                
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
        
        cr.Account_Name__c = 'UpdatedAccountName';
        cr.Case_Role_Status__c = 'Active';
        cr.Role__c = 'Owner';
        update cr;
                        
    } 
    
    public static testMethod void TestCreate2() {

        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c cpTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(cpTriggerSetting);
        
        Trigger_Settings__c caseRoleAllTriggerSetting = new Trigger_Settings__c(
            Name = 'CaseRoleAll',
            Is_Active__c = true
        );
        triggerSettings.add(caseRoleAllTriggerSetting);

        Trigger_Settings__c dlrs_DIR_ViolationTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_DIR_ViolationTriggerSetting);

        Trigger_Settings__c dlrs_judgementTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_JudgementTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_judgementTriggerSetting);

        Trigger_Settings__c generateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        triggerSettings.add(generateFieldHistoryActionTriggerSetting);

        Trigger_Settings__c lpTriggerSetting = new Trigger_Settings__c(
            Name = 'LiabilityPaymentTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(lpTriggerSetting);
        
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = false
        );
        triggerSettings.add(rctTriggerSetting);
        insert triggerSettings;
        
        Account mainA = new Account();
        mainA.firstName = 'Test';
        mainA.lastName = 'Me';
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
        cr.Account_Name__c = mainA.firstName + ' ' + mainA.lastName;
        insert cr;
        
        delete cr;

     } 

}