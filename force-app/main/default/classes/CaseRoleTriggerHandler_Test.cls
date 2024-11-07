@isTest
public class CaseRoleTriggerHandler_Test {
    @istest 
    public static void setUpMethod() {
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = true
        );
        
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;
        
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        // de.Manager__c = ma.Id;
        insert de; 
        
        String recordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        
        DIR_Case__c dirCase = new DIR_Case__c(
            RecordTypeId = recordTypeId,            
            Assigned_Deputy__c = de.Id,
            OWC_JSON__c = 'str',
            Status__c = 'Not Confirmed'
        );
        insert dirCase;
        
        Violation_Type__c vt1 = new Violation_Type__c();
        vt1.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByDeveloperName().get('BOFE_Violations').getRecordTypeId();
        vt1.Appeal_Deadline_Days__c = 12;
        vt1.Active__c = true;
        vt1.Name = 'UNREIMBURSED BUSINESS EXPENSES: Reasonable costs';
        vt1.Appeal_Deadline_Selector__c = 'Business Days';
        //vt.Name= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Help_Text__c= 'SL17 SL10 Expenses other than mileage';
        vt1.Wage_Assessment_Formula__c= 'VTV0106-VTV0107';
        vt1.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt1.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Amount_Paid_Formula__c= 'VTV0107';
        vt1.Amount_Earned_Formula__c= 'VTV0106';
        vt1.Wizard_Search_Text__c= '( BE10 - 2802 )';
        insert vt1;
        
        
       
    }
    
    
    @IsTest
    public static void TestinBoundEmail(){
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        
        Trigger_Settings__c caseTriggerSetting = new Trigger_Settings__c(
            Name = 'CaseManagementHistoryConfig',
            Is_Active__c = false
        );
        insert caseTriggerSetting;
          List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        
        Trigger_Settings__c dlrs_Related_PartyTriggersetting = new Trigger_Settings__c(
            Name = 'dlrs_Related_PartyTrigger',
            Is_Active__c = false
        );
        Trigger_Settings__c dlrs_DIR_ViolationTriggersetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        );
        
         triggerSettings.add(dlrs_Related_PartyTriggersetting);
        triggerSettings.add(dlrs_DIR_ViolationTriggersetting);
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];       
        
        Office__c office = new Office__c();
        office.Name = 'Lucian832474';
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '234889';
        insert zip;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
        map1.Zip_Code__c = zip.Id;
        map1.Office__c = office.Id;
        insert map1;
        
        Account mainA = new Account();
        mainA.Name = 'name';
        mainA.ShippingPostalCode = '234889';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert affA;
        
        Address__c addObj = new Address__c();
        addObj.Entity__c = affA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        insert addObj;
        
        Associated_Agents__c agent =new Associated_Agents__c();
        agent.Account__c=mainA.Id;
        agent.Type__c='Attorney';
        agent.Associated_Account__c=affA.Id;
        agent.Relationship_Status__c=true;
        insert agent;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();            
        c.Assigned_Deputy__c = de.Id;
        c.Case_Number__c = 'WC-CM-834315';
        insert c;
    }

   

}