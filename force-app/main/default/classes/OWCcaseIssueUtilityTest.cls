@isTest
public class OWCcaseIssueUtilityTest {
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
        
        Trigger_Settings__c dlrs_DIR_ViolationTriggersetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        );
        
        triggerSettings.add(dlrs_DIR_ViolationTriggersetting);
        
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
        
        List<Violation_Type_Variable__c> vtvList = new List<Violation_Type_Variable__c>();   
        vtvList.add(prepareVtv('Date', 'START DATE OF CLAIM PERIOD', 'Start date of this claim (MM/DD/YYYY)', '2021-10-31', vt1.Id, true));
        vtvList.add(prepareVtv('Date', 'END DATE OF CLAIM PERIOD', 'End date of this claim (MM/DD/YYYY)', '2021-10-31', vt1.Id, true));
        vtvList.add(prepareVtv('Decimal', 'TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD',
                               'How many hours did you work during this period?', 'test', vt1.Id, false));
        vtvList.add(prepareVtv('Currency', '$ HOURLY RATE EARNED FOR **NON-OT** HRS WORKED.  (Hourly rate higher than MW.)',
                               'What was your hourly rate of pay earned during this claim period?', '45', vt1.Id, true));
        vtvList.add(prepareVtv('Currency', '$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD', 
                               'What is the total amount you were paid for regular hours during this period?', '66', vt1.Id, true));
        insert vtvList;
        Test.startTest();
        String caseIssueJson = '{"caseIssues":[{"violationTypeId":"'+vt1.Id+'",'
            +'"violationVariables":[{"dataType":"Date","description":"START DATE OF CLAIM PERIOD","label":"Start date of this claim (MM/DD/YYYY)","name":"VTV0010","value":"2021-10-31","violationId":"'+vtvList[0].Id+'","violationTypeId":"'+vt1.Id+'","dateFormat":true},'
            +'{"dataType":"Date","description":"END DATE OF CLAIM PERIOD","label":"End date of this claim (MM/DD/YYYY)","name":"VTV0011","value":"2021-11-03","violationId":"'+vtvList[1].Id+'","violationTypeId":"'+vt1.Id+'","dateFormat":true},'
            +'{"dataType":"Decimal","description":"TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD","label":"How many hours did you work during this period?","name":"VTV0013","value":"test 1","violationId":"'+vtvList[2].Id+'","violationTypeId":"'+vt1.Id+'","inputFormat":true},'
            +'{"dataType":"Currency","description":"$ HOURLY RATE EARNED FOR **NON-OT** HRS WORKED.  (Hourly rate higher than MW.)","label":"What was your hourly rate of pay earned during this claim period?","name":"VTV0012","value":"45","violationId":"'+vtvList[3].Id+'","violationTypeId":"'+vt1.Id+'","currencyFormat":true},'
            +'{"dataType":"Currency","description":"$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD","label":"What is the total amount you were paid for regular hours during this period?","name":"VTV0014","value":"55","violationId":"'+vtvList[4].Id+'","violationTypeId":"'+vt1.Id+'","currencyFormat":true}]}]}';
        OWCcaseIssueUtility.parseResponse(caseIssueJson, dirCase.Id);
        Test.stopTest();
    }
    
    @istest 
    public static void setUpMethod1() {
        
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
        
        Trigger_Settings__c dlrs_DIR_ViolationTriggersetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        );
        
        triggerSettings.add(dlrs_DIR_ViolationTriggersetting);
        
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
        vt1.Help_Text__c= 'SL17 SL11 Expenses other than mileage';
        vt1.Wage_Assessment_Formula__c= 'VTV0106-VTV0107';
        vt1.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt1.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Amount_Paid_Formula__c= 'VTV0107';
        vt1.Amount_Earned_Formula__c= 'VTV0106';
        vt1.Wizard_Search_Text__c= '( BE10 - 2802 )';
        insert vt1;
        
        List<Violation_Type_Variable__c> vtvList = new List<Violation_Type_Variable__c>();   
        vtvList.add(prepareVtv('Date', 'START DATE OF CLAIM PERIOD', 'Start date of this claim (MM/DD/YYYY)', '2021-10-31', vt1.Id, true));
        vtvList.add(prepareVtv('Date', 'END DATE OF CLAIM PERIOD', 'End date of this claim (MM/DD/YYYY)', '2021-10-31', vt1.Id, true));
        vtvList.add(prepareVtv('Decimal', 'TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD',
                               'How many hours did you work during this period?', 'test', vt1.Id, false));
        vtvList.add(prepareVtv('Currency', '$ HOURLY RATE EARNED FOR **NON-OT** HRS WORKED.  (Hourly rate higher than MW.)',
                               'What was your hourly rate of pay earned during this claim period?', '45', vt1.Id, true));
        vtvList.add(prepareVtv('Currency', '$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD', 
                               'What is the total amount you were paid for regular hours during this period?', '66', vt1.Id, true));
        insert vtvList;
        Test.startTest();
        String caseIssueJson = '{"caseIssues":[{"violationTypeId":"'+vt1.Id+'",'
            +'"violationVariables":[{"dataType":"Date","description":"START DATE OF CLAIM PERIOD","label":"Start date of this claim (MM/DD/YYYY)","name":"VTV0010","value":"2021-10-31","violationId":"'+vtvList[0].Id+'","violationTypeId":"'+vt1.Id+'","dateFormat":true},'
            +'{"dataType":"Date","description":"END DATE OF CLAIM PERIOD","label":"End date of this claim (MM/DD/YYYY)","name":"VTV0011","value":"2021-11-03","violationId":"'+vtvList[1].Id+'","violationTypeId":"'+vt1.Id+'","dateFormat":true},'
            +'{"dataType":"Decimal","description":"TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD","label":"How many hours did you work during this period?","name":"VTV0013","value":"test 1","violationId":"'+vtvList[2].Id+'","violationTypeId":"'+vt1.Id+'","inputFormat":true},'
            +'{"dataType":"Currency","description":"$ HOURLY RATE EARNED FOR **NON-OT** HRS WORKED.  (Hourly rate higher than MW.)","label":"What was your hourly rate of pay earned during this claim period?","name":"VTV0012","value":"45","violationId":"'+vtvList[3].Id+'","violationTypeId":"'+vt1.Id+'","currencyFormat":true},'
            +'{"dataType":"Currency","description":"$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD","label":"What is the total amount you were paid for regular hours during this period?","name":"VTV0014","value":"55","violationId":"'+vtvList[4].Id+'","violationTypeId":"'+vt1.Id+'","currencyFormat":true}]}]}';
        OWCcaseIssueUtility.parseResponse(caseIssueJson, dirCase.Id);
        Test.stopTest();
    }
    
    @istest 
    public static void setUpMethod2() {
        
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
        
        Trigger_Settings__c dlrs_DIR_ViolationTriggersetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        );
        
        triggerSettings.add(dlrs_DIR_ViolationTriggersetting);
        
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
        vt1.Help_Text__c= 'SL17 SL11 LD10 Expenses other than mileage';
        vt1.Wage_Assessment_Formula__c= 'VTV0106-VTV0107';
        vt1.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt1.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Amount_Paid_Formula__c= 'VTV0107';
        vt1.Amount_Earned_Formula__c= 'VTV0106';
        vt1.Wizard_Search_Text__c= '( BE10 - 2802 )';
        insert vt1;
        
        List<Violation_Type_Variable__c> vtvList = new List<Violation_Type_Variable__c>();   
        vtvList.add(prepareVtv('Date', 'START DATE OF CLAIM PERIOD', 'Start date of this claim (MM/DD/YYYY)', '2021-10-31', vt1.Id, true));
        vtvList.add(prepareVtv('Date', 'END DATE OF CLAIM PERIOD', 'End date of this claim (MM/DD/YYYY)', '2021-10-31', vt1.Id, true));
        vtvList.add(prepareVtv('Decimal', 'TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD',
                               'How many hours did you work during this period?', 'test', vt1.Id, false));
        vtvList.add(prepareVtv('Currency', '$ HOURLY RATE EARNED FOR **NON-OT** HRS WORKED.  (Hourly rate higher than MW.)',
                               'What was your hourly rate of pay earned during this claim period?', '45', vt1.Id, true));
        vtvList.add(prepareVtv('Currency', '$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD', 
                               'What is the total amount you were paid for regular hours during this period?', '66', vt1.Id, true));
        insert vtvList;
        Test.startTest();
        String caseIssueJson = '{"caseIssues":[{"violationTypeId":"'+vt1.Id+'",'
            +'"violationVariables":[{"dataType":"Date","description":"START DATE OF CLAIM PERIOD","label":"Start date of this claim (MM/DD/YYYY)","name":"VTV0010","value":"2021-10-31","violationId":"'+vtvList[0].Id+'","violationTypeId":"'+vt1.Id+'","dateFormat":true},'
            +'{"dataType":"Date","description":"END DATE OF CLAIM PERIOD","label":"End date of this claim (MM/DD/YYYY)","name":"VTV1697","value":"2021-11-03","violationId":"'+vtvList[1].Id+'","violationTypeId":"'+vt1.Id+'","dateFormat":true},'
            +'{"dataType":"Decimal","description":"TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD","label":"How many hours did you work during this period?","name":"VTV0013","value":"test 1","violationId":"'+vtvList[2].Id+'","violationTypeId":"'+vt1.Id+'","inputFormat":true},'
            +'{"dataType":"Currency","description":"$ HOURLY RATE EARNED FOR **NON-OT** HRS WORKED.  (Hourly rate higher than MW.)","label":"What was your hourly rate of pay earned during this claim period?","name":"VTV0012","value":"45","violationId":"'+vtvList[3].Id+'","violationTypeId":"'+vt1.Id+'","currencyFormat":true},'
            +'{"dataType":"Currency","description":"$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD","label":"What is the total amount you were paid for regular hours during this period?","name":"VTV0014","value":"55","violationId":"'+vtvList[4].Id+'","violationTypeId":"'+vt1.Id+'","currencyFormat":true}]}]}';
        OWCcaseIssueUtility.parseResponse(caseIssueJson, dirCase.Id);
        OWCcaseIssueUtility.ViolationTypeWrapper vtw = new OWCcaseIssueUtility.ViolationTypeWrapper();
        try{
            OWCcaseIssueUtility.prepareLDissues(vtw, '', '','', '','',dirCase.Id);
        }catch(Exception e){
            System.debug('Exception::::'+e);
        }
        Test.stopTest();
    }
    
    @istest 
    public static void setUpMethod3() {
        
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
        
        Trigger_Settings__c dlrs_DIR_ViolationTriggersetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        );
        
        triggerSettings.add(dlrs_DIR_ViolationTriggersetting);
        
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
        vt1.Help_Text__c= 'SL17 SL11 Expenses other than mileage';
        vt1.Wage_Assessment_Formula__c= 'VTV0106-VTV0107';
        vt1.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt1.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Amount_Paid_Formula__c= 'VTV0107';
        vt1.Amount_Earned_Formula__c= 'VTV0106';
        vt1.Wizard_Search_Text__c= '( BE10 - 2802 )';
        insert vt1;
        
        List<Violation_Type_Variable__c> vtvList = new List<Violation_Type_Variable__c>();   
        vtvList.add(prepareVtv('Date', 'START DATE OF CLAIM PERIOD', 'Start date of this claim (MM/DD/YYYY)', '2021-10-31', vt1.Id, true));
        vtvList.add(prepareVtv('Date', 'END DATE OF CLAIM PERIOD', 'End date of this claim (MM/DD/YYYY)', '2021-10-31', vt1.Id, true));
        vtvList.add(prepareVtv('Decimal', 'TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD',
                               'How many hours did you work during this period?', 'test', vt1.Id, false));
        vtvList.add(prepareVtv('Currency', '$ HOURLY RATE EARNED FOR **NON-OT** HRS WORKED.  (Hourly rate higher than MW.)',
                               'What was your hourly rate of pay earned during this claim period?', '45', vt1.Id, true));
        vtvList.add(prepareVtv('Currency', '$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD', 
                               'What is the total amount you were paid for regular hours during this period?', '66', vt1.Id, true));
        insert vtvList;
        Test.startTest();
        String caseIssueJson = '{"caseIssues":[{"violationTypeId":"'+vt1.Id+'",'
            +'"violationVariables":[{"dataType":"Date","description":"START DATE OF CLAIM PERIOD","label":"Start date of this claim (MM/DD/YYYY)","name":"VTV0010","value":"2021-10-31","violationId":"'+vtvList[0].Id+'","violationTypeId":"'+vt1.Id+'","dateFormat":true},'
            +'{"dataType":"Date","description":"END DATE OF CLAIM PERIOD","label":"End date of this claim (MM/DD/YYYY)","name":"VTV1697","value":"2021-11-03","violationId":"'+vtvList[1].Id+'","violationTypeId":"'+vt1.Id+'","dateFormat":true},'
            +'{"dataType":"Decimal","description":"TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD","label":"How many hours did you work during this period?","name":"VTV0013","value":"test 1","violationId":"'+vtvList[2].Id+'","violationTypeId":"'+vt1.Id+'","inputFormat":true},'
            +'{"dataType":"Currency","description":"$ HOURLY RATE EARNED FOR **NON-OT** HRS WORKED.  (Hourly rate higher than MW.)","label":"What was your hourly rate of pay earned during this claim period?","name":"VTV0012","value":"45","violationId":"'+vtvList[3].Id+'","violationTypeId":"'+vt1.Id+'","currencyFormat":true},'
            +'{"dataType":"Currency","description":"$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD","label":"What is the total amount you were paid for regular hours during this period?","name":"VTV0014","value":"55","violationId":"'+vtvList[4].Id+'","violationTypeId":"'+vt1.Id+'","currencyFormat":true}]}]}';
        try{
            OWCcaseIssueUtility.parseResponse(caseIssueJson, dirCase.Id);
        }catch(Exception e){
            System.debug('Exception:::'+e);
        }    
        
        Test.stopTest();
    }
    
    @istest 
    public static void setUpMethod4() {
        
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
        
        Trigger_Settings__c dlrs_DIR_ViolationTriggersetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        );
        
        triggerSettings.add(dlrs_DIR_ViolationTriggersetting);
        
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
        vt1.Help_Text__c= 'SL17 SL11 Expenses other than mileage';
        vt1.Wage_Assessment_Formula__c= 'VTV0106-VTV0107';
        vt1.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt1.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Amount_Paid_Formula__c= 'VTV0107';
        vt1.Amount_Earned_Formula__c= 'VTV0106';
        vt1.Wizard_Search_Text__c= '( BE10 - 2802 )';
        insert vt1;
        
        List<Violation_Type_Variable__c> vtvList = new List<Violation_Type_Variable__c>();   
        vtvList.add(prepareVtv('Date', 'START DATE OF CLAIM PERIOD', 'Start date of this claim (MM/DD/YYYY)', '2021-10-31', vt1.Id, true));
        vtvList.add(prepareVtv('Date', 'END DATE OF CLAIM PERIOD', 'End date of this claim (MM/DD/YYYY)', '2021-10-31', vt1.Id, true));
        vtvList.add(prepareVtv('Decimal', 'TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD',
                               'How many hours did you work during this period?', 'test', vt1.Id, false));
        vtvList.add(prepareVtv('Currency', '$ HOURLY RATE EARNED FOR **NON-OT** HRS WORKED.  (Hourly rate higher than MW.)',
                               'What was your hourly rate of pay earned during this claim period?', '45', vt1.Id, true));
        vtvList.add(prepareVtv('Currency', '$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD', 
                               'What is the total amount you were paid for regular hours during this period?', '66', vt1.Id, true));
        insert vtvList;
        Test.startTest();
        String caseIssueJson = '{"caseIssues":[{"violationTypeId":"'+vt1.Id+'",'
            +'"violationVariables":[{"dataType":"Date","description":"START DATE OF CLAIM PERIOD","label":"Start date of this claim (MM/DD/YYYY)","name":"VTV0010","value":"2021-10-31","violationId":"'+vtvList[0].Id+'","violationTypeId":"'+vt1.Id+'","dateFormat":true},'
            +'{"dataType":"Date","description":"END DATE OF CLAIM PERIOD","label":"End date of this claim (MM/DD/YYYY)","name":"VTV1697","value":"2021-11-03","violationId":"'+vtvList[1].Id+'","violationTypeId":"'+vt1.Id+'","dateFormat":true},'
            +'{"dataType":"Decimal","description":"TOTAL NUMBER OF **NON-OT** HRS WORKED DURING CLAIM PERIOD","label":"How many hours did you work during this period?","name":"VTV0013","value":"test 1","violationId":"'+vtvList[2].Id+'","violationTypeId":"'+vt1.Id+'","inputFormat":true},'
            +'{"dataType":"Currency","description":"$ HOURLY RATE EARNED FOR **NON-OT** HRS WORKED.  (Hourly rate higher than MW.)","label":"What was your hourly rate of pay earned during this claim period?","name":"VTV0012","value":"45","violationId":"'+vtvList[3].Id+'","violationTypeId":"'+vt1.Id+'","currencyFormat":true},'
            +'{"dataType":"Currency","description":"$ TOTAL AMOUNT PAID BY EMPLOYER FOR **NON-OT** HRS WORKED DURING CLAIM PERIOD","label":"What is the total amount you were paid for regular hours during this period?","name":"VTV0014","value":"55","violationId":"'+vtvList[4].Id+'","violationTypeId":"'+vt1.Id+'","currencyFormat":true}]}]}';
        
        List<OWCCaseIssueUtility.violationTypeVarWrapper> violationVarWrapperList = new List<OWCCaseIssueUtility.violationTypeVarWrapper>();//indexCounter = 1, vTypeVar = vtv1, varValue = 'test', isUserInput = true, dataType = 'Date', vtvName = 'test'};
        OWCCaseIssueUtility.violationTypeVarWrapper newObj = new OWCCaseIssueUtility.violationTypeVarWrapper(vtvList[0], 77, 'test');
        newObj.dataType = 'Date';
        //newObj.indexCounter = 1;
        newObj.vtvName = 'The amou';
        newObj.vTypeVar = vtvList[0];
        newObj.isUserInput = true;
        newObj.varValue = null;
        violationVarWrapperList.add(newObj);
        
        List<OWCcaseIssueUtility.ViolationTypeWrapper> wrapperList = new List<OWCcaseIssueUtility.ViolationTypeWrapper>();
        OWCcaseIssueUtility.ViolationTypeWrapper wrapperObj = new OWCcaseIssueUtility.ViolationTypeWrapper();
        wrapperObj.amount = 24;
        wrapperObj.vType = vt1;
        wrapperObj.vTypeVars = vtvList;
        wrapperObj.vtvWrapperList = violationVarWrapperList;
        wrapperObj.formula = '0';
        wrapperObj.amountEarned = 33;
        wrapperObj.amountEarnedFormula = '34';
        wrapperObj.amountPaid = 32;
        wrapperObj.amountPaidFormula = '45';
        wrapperObj.subTotalA = 43;
        wrapperObj.indexCounter = 1;
        wrapperObj.selected = true;
        wrapperObj.subTotalIW = 45;
        wrapperObj.subTotalW = 67;
        wrapperObj.wage = 877;
        wrapperObj.wageinterest = 90;
        wrapperObj.wageinterestformula = '33';
        wrapperList.add(wrapperObj);
        
        OWCcaseIssueUtility.CaseIssueWrapper caseIssueWrap = new OWCcaseIssueUtility.CaseIssueWrapper();
        caseIssueWrap.caseIssues = null;
        
        
        try{
            OWCcaseIssueUtility.parseResponse(caseIssueJson, dirCase.Id);
        }catch(Exception e){
            System.debug('Exception:::'+e);
        }      
        
        try{
            List<OWCcaseIssueUtility.ViolationTypeWrapper> sampleVTList = new List<OWCcaseIssueUtility.ViolationTypeWrapper>();
            OWCcaseIssueUtility.Finalize(wrapperList, '123');
        }catch(Exception e){
            System.debug('Finalize Exception:::'+e);
        }
        
        try{
            
            String valueString = '2:400::1:400.00::1:0::1:0.00::1:0::1:0::';
            OWCcaseIssueUtility.saveVarValues(valueString,wrapperList);
        }catch(Exception e){
            System.debug('saveVarValues Exception:::'+e);
        }
        Test.stopTest();
    }
    
    public static Violation_Type_Variable__c prepareVtv(String dataType, String description, String label, String value, String violatioTypeId, boolean dataFormat){
        Violation_Type_Variable__c vtv1 = new Violation_Type_Variable__c();
        vtv1.Violation_Type__c= violatioTypeId;
        vtv1.Label_English__c = label;
        vtv1.Label_Spanish__c = label;
        vtv1.value__c = value;
        vtv1.Description__c= description;
        vtv1.Data_Type__c= dataType;
        return vtv1;
    }
    
    @IsTest
    public static void testSaveVarValues(){
        
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
        String typeId =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        String typeId1 =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
        affA.RecordTypeId=typeId1; 
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
        //c.DLSE_Program__c = ;
        //c.Record_Type_Text__c = ;
        //c.Violation_Type__c = vt.id;
        System.debug('DIR_Case__c::'+c);
        try{
            insert c;
        }
        catch(Exception ex){
            System.debug('Insert case number ::: '+ex.getStackTraceString());
        }
        
        Violation_Type__c vt1 = new Violation_Type__c();
        vt1.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByDeveloperName().get('BOFE_Violations').getRecordTypeId();
        vt1.Appeal_Deadline_Days__c = 12;
        vt1.Active__c = true;
        //vt1.Name='BOFE_Investigation L.C. 238(f) – Subsequent Violations';
        vt1.Name = 'UNREIMBURSED BUSINESS EXPENSES: Reasonable costs';
        vt1.Appeal_Deadline_Selector__c = 'Business Days';
        //vt.Name= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Help_Text__c= 'SL17 RW10 LD10 Expenses other than mileage';
        vt1.Wage_Assessment_Formula__c= '';
        vt1.Wage_Interest_Assessment_Formula__c = '';
        vt1.Assessment_Formula__c = '';
        vt1.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt1.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Amount_Paid_Formula__c= '';
        vt1.Amount_Earned_Formula__c= '';
        vt1.Wizard_Search_Text__c= '( BE10 - 2802 )';
        vt1.Civil_Penalty_Section__c = 'L.C. 3710.1';
        system.debug('vt1::'+vt1);
        insert vt1;
        
        List<Violation_Type_Variable__c> vtvList = new List<Violation_Type_Variable__c>();
        Violation_Type_Variable__c vtv1 = new Violation_Type_Variable__c();
        vtv1.Violation_Type__c= vt1.id;
        //vtv.Name= 'VTV0104';
        vtv1.Description__c= '$ TOTAL AMOUNT PAYABLE TO PLAINTIFF. Multiply TOTAL NUMBER OF DAYS THAT VIOLATION OCCURRED AND CONTINUED by $50 for each day. Total cannot exceed $4000. Ex: 90 days of violation X $50 per day = $4500.  Enter $4000.';
        vtv1.Data_Type__c= 'Currency';
        vtv1.value__c= '400';
        system.debug('vtv1::'+vtv1);
        vtvList.add(vtv1);
        insert vtvList;
        
        List<OWCCaseIssueUtility.violationTypeVarWrapper> violationVarWrapperList = new List<OWCCaseIssueUtility.violationTypeVarWrapper>();//indexCounter = 1, vTypeVar = vtv1, varValue = 'test', isUserInput = true, dataType = 'Date', vtvName = 'test'};
        OWCCaseIssueUtility.violationTypeVarWrapper newObj = new OWCCaseIssueUtility.violationTypeVarWrapper(vtvList[0], 77, 'test');
        newObj.dataType = 'Date';
        newObj.indexCounter = 1;
        newObj.vtvName = 'The amou';
        newObj.vTypeVar = vtvList[0];
        newObj.isUserInput = true;
        newObj.varValue = null;
        violationVarWrapperList.add(newObj);
        // violationVarWrapperList.add(new OWCCaseIssueUtility.violationTypeVarWrapper());
        String valueString = '2:400::1TOTALW:400.00::1TOTALIW:0::1TOTALA:0.00::1AMTP:0::1AMTE:0::';
        List<OWCCaseIssueUtility.ViolationTypeWrapper> wrapperList = new List<OWCCaseIssueUtility.ViolationTypeWrapper>();
        for(Integer i=0; i<1; i++){
            OWCCaseIssueUtility.ViolationTypeWrapper wrapperObj = new OWCCaseIssueUtility.ViolationTypeWrapper();
            wrapperObj.amount = 24;
            wrapperObj.vType = vt1;
            wrapperObj.vTypeVars = vtvList;
            wrapperObj.vtvWrapperList = violationVarWrapperList;
            wrapperObj.formula = '0';
            wrapperObj.amountEarned = 33;
            wrapperObj.amountEarnedFormula = '34';
            wrapperObj.amountPaid = 32;
            wrapperObj.amountPaidFormula = '45';
            wrapperObj.subTotalA = 43;
            wrapperObj.indexCounter = 1;
            wrapperObj.selected = true;
            wrapperObj.subTotalIW = 45;
            wrapperObj.subTotalW = 67;
            wrapperObj.wage = 877;
            wrapperObj.wageinterest = 90;
            wrapperObj.wageinterestformula = '33';
            wrapperList.add(wrapperObj);
        }
        OWCCaseIssueUtility.ViolationTypeWrapper wrapperObj1 = new OWCCaseIssueUtility.ViolationTypeWrapper();
        wrapperObj1.amount = 24;
        wrapperObj1.formula = '0';
        wrapperObj1.vTypeVars = vtvList;
        wrapperObj1.vtvWrapperList = violationVarWrapperList;
        wrapperObj1.amountEarned = 33;
        wrapperObj1.amountEarnedFormula = '34';
        wrapperObj1.amountPaid = 32;
        wrapperObj1.amountPaidFormula = '45';
        wrapperObj1.subTotalA = 43;
        wrapperObj1.indexCounter = 1;
        wrapperObj1.selected = true;
        wrapperObj1.subTotalIW = 45;
        wrapperObj1.subTotalW = 67;
        wrapperObj1.wage = 877;
        wrapperObj1.wageinterest = 90;
        wrapperObj1.wageinterestformula = '33';
        
        Test.startTest();
        List<OWCCaseIssueUtility.vtVarModel> vtvModel = new List<OWCCaseIssueUtility.vtVarModel>();
        OWCCaseIssueUtility.vtVarModel vtvModelObj = new OWCCaseIssueUtility.vtVarModel();
        vtvModelObj.dataType = 'Date';
        vtvModelObj.label = 'test label';
        vtvModelObj.name = 'test';
        vtvModelObj.value = 'test';
        vtvModelObj.violationId = null;
        vtvModel.add(vtvModelObj);
        
        OWCCaseIssueUtility.violationTypeResponse violationResponseObj = new OWCCaseIssueUtility.violationTypeResponse();
        violationResponseObj.violationId = 'test';
        violationResponseObj.vtVarModelList = vtvModel;
        OWCCaseIssueUtility.saveVarValues(valueString, wrapperList);
        //OWCCaseIssueUtility.Finalize(wrapperList, c.Id);
        OWCCaseIssueUtility.ParseExplanation(wrapperObj1, '{~The amount of wages to be cashiered is 400.}');
        Test.stopTest();
    }
}