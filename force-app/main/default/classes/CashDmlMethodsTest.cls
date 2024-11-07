@isTest
public with sharing class CashDmlMethodsTest {

    @TestSetup
    static void makeData(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(
            Name = 'CaseRoleAll',
            Is_Active__c = false
        ));
            
        triggerSettings.add(new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'dlrs_JudgementTrigger',
            Is_Active__c = false
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'LiabilityPaymentTrigger',
            Is_Active__c = false
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = false
        ));
        
         triggerSettings.add(new Trigger_Settings__c(
            Name = 'DIR_EmployeeTrigger',
            Is_Active__c = false
        ));

        insert triggerSettings;
            
        List<Account> accounts = new List<Account>();
        Id businessAccountRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        Account employerAccount = new Account(
            RecordTypeId = businessAccountRtId,
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employerAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        /*
        Account statePayeeAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'DIR',
            ShippingStreet = '456 Almighty Capitalism Dr',
            ShippingCity = 'Scrotamento',
            ShippingState = 'CA',
            ShippingPostalCode = '98765'
        );
        accounts.add(statePayeeAccount);
                    
        Account courtPayeeAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'The Superior Inferior Court Jester',
            ShippingStreet = '666 Hubba Hubba Dr',
            ShippingCity = 'National City',
            ShippingState = 'CA',
            ShippingPostalCode = '91545'
        );
        accounts.add(courtPayeeAccount);
        */
        insert accounts;
                        
        Address__c employerAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employerAccount.Id];
        Address__c employeePayeeAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employeePayeeAccount.Id];

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
        
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        
        List<Office__c> offices = new List<Office__c>();
        Office__c bofeOffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        offices.add(bofeOffice);
        
        Office__c ccuOffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        offices.add(ccuOffice);
        
        insert offices;

        DIR_Case__c bofeCase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employerAccount.Id,
            Office__c = bofeOffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert bofeCase;

        Payment_Plan__c pp = new Payment_Plan__c(
            Case__c = bofeCase.Id,
            Payment_Plan_Total_Amount_Due__c = 666,
            Number_of_Payments__c = 7,
            Payment_Plan_Regular_Payment__c = 3,
            Responsible_Party__c = employerAccount.Id,
            Date_of_First_Payment__c = Date.today() + 15,
            Payment_Plan_Start_Date__c = Date.today() + 15,
            Frequency__c = 'Weekly',
            Day_of_Week_Payment_Due__c = (DateTime.now() + 15).format('EEEE')
        );
        insert pp;
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Id bofeCaseRoleRecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        Case_Role__c bofeDefendantCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = employerAccount.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(bofeDefendantCaseRole);

        Case_Role__c bofeEmployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(bofeEmployeePayeeCaseRole);
                
        /*Case_Role__c statePayeeCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(statePayeeCaseRole);

        Case_Role__c courtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(courtPayeeCaseRole);
        */
        insert caseRoles;

        List<Payee__c> payees = new List<Payee__c>();
        Payee__c bofeEmployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = bofeEmployeePayeeCaseRole.Id
        );
        payees.add(bofeEmployeePayee);
        
        /*
        Payee__c statePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = statePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(statePayee);

        Payee__c courtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = courtPayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(courtPayee);*/
        insert payees;


        List<Violation_Type__c> violationTypes = new List<Violation_Type__c>();
        Violation_Type__c bofeViolationType = new Violation_Type__c(
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            //Even though the method is "getRecordTypeInfosByName()", it actually gets the info by the Label.
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Active__c = true
        );
        violationTypes.add(bofeViolationType);

        /*
        Violation_Type__c wcaViolationType = new Violation_Type__c(
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            //Even though the method is "getRecordTypeInfosByName()", it actually gets the info by the Label.
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - Active').getRecordTypeId(),
            Active__c = true
        );
        violationTypes.add(wcaViolationType);
        */
        
        insert violationTypes;
                
        Assessments__c bofeAssessment = new Assessments__c(
            Case_Management__c = bofeCase.Id,
            Appeal_Deadline_Days__c = 14,
            Appeal_Deadline_Selector__c = 'Business Days',
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert bofeAssessment;

        List<DIR_Violation__c> caseIssues = new List<DIR_Violation__c>();
        Id bofeCaseIssueRecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        //Id wcaCaseIssueRecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId();
        DIR_Violation__c bofeCaseIssue = new DIR_Violation__c(
            Violation_Type__c = bofeViolationType.Id,
            Case__c = bofeCase.Id,
            Assessment__c = bofeAssessment.Id,
            Citation_Amount__c = 6666,
            Wages_Due__c = 4999.50,
            Total_Interest_Amount__c = 1666.50,
            Status__c = 'Open',
            RecordTypeId = bofeCaseIssueRecordTypeId
        );
        caseIssues.add(bofeCaseIssue);

        /*
        DIR_Violation__c wcaCaseIssue = new DIR_Violation__c(
            Violation_Type__c = wcaViolationType.Id,
            Case__c = bofeCase.Id,
            Assessment__c = bofeAssessment.Id,
            Citation_Amount__c = 7777,
            Wages_Due__c = 1999.50,
            Total_Interest_Amount__c = 5777.50,
            Status__c = 'Open',
            RecordTypeId = wcaCaseIssueRecordTypeId
        );
        caseIssues.add(wcaCaseIssue);
        */
        insert caseIssues;

        
        Judgement__c wcaJudgment = new Judgement__c(
            Case_Management__c = bofeCase.Id,
            Type__c = 'ODA',
            Status__c = 'New',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert wcaJudgment;
        
        
        Liability__c bofeLiability = new Liability__c(
            Case_Management__c = bofeCase.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = bofeAssessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );            
        insert bofeLiability;
        /*
        Liability__c wcaLiability = new Liability__c(
            Case_Management__c = wcaCase.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = WCAassessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert wcaLiability;
        */
        Liable_Party__c bofeLiableParty = new Liable_Party__c(
            Liability__c = bofeLiability.Id,
            Entity__c = employerAccount.Id,
            Liable_Party_Account_Name__c = employerAccount.Name,
            Case_Role__c = bofeDefendantCaseRole.Id
        );
        insert bofeLiableParty;
        /*
        Liable_Party__c wcaLiableParty = new Liable_Party__c(
            Liability__c = wcaLiability.Id,
            Entity__c = employerAccount.Id,
            Case_Role__c = wcaDefendantCaseRole.Id
        );
        insert wcaLiableParty;
        */
        Liable_Party_Case_Issue__c bofeLPCI = new Liable_Party_Case_Issue__c(
            Liable_Party__c = bofeLiableParty.Id,
            Case_Issue__c = bofeCaseIssue.Id
        );
        insert bofeLPCI;

        /*        
        Liability_Judgement__c wcaJudgmentParty = new Liability_Judgement__c(
            Judgement__c = WCAjudgment.Id,
            Liable_Party__c = wcaLiableParty.Id
        );
        insert wcaJudgmentParty;
        */

        Office_Account__c ccuOfficeAccount = new Office_Account__c(
            Name = '32-117',
            Office__c = ccuOffice.Id
        );
        insert ccuOfficeAccount;
        
        Transaction__c bofeTRN = new Transaction__c(
            Office_Account__c = ccuOfficeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-7),
            Business_Unit__c = 'CCU',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 55.55,
            Check_Count__c = 1,
            Checks_Amount__c = 55.55,
            Treasury_Deposit_Number__c = '😜😲😅'
        );
        insert bofeTRN;
    
        Receipt__c bofeRCT = new Receipt__c(
            Payor__c = employerAccount.Id,
            Created_Via_PartyPaymentVFP__c = false,
            Deposit_Account__c = '32-117',
            Date_Received__c = Date.today().addDays(-14),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 55.55,
            Transaction__c = bofeTRN.Id,
            Instrument_Number__c = '🍺🍻🍸🍹🍷',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Senior_Deputy__c = manager.Id
        );
        insert bofeRCT;

        Case_Payment__c bofeCP = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = bofeCase.Id,
            Receipt__c = bofeRCT.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'New'
        );
        insert bofeCP;


        List<Liability_Payment__c> cu1List = new List<Liability_Payment__c>();
        cu1List.add(
            new Liability_Payment__c(
                Case_Payment__c = bofeCP.Id,
                Payment_on_Behalf_of__c = bofeLiableParty.Id,
                Recommended_Amount__c = 33.33,
                Payment_Applied_To__c = 'Refund Amount',
                Assessment__c = bofeAssessment.Id,
                Liability__c = bofeLiability.Id,
                Case_Violation__c = bofeCaseIssue.Id,
                Status__c = 'Posted',
                Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
            )
        );
        cu1List.add(
            new Liability_Payment__c(
                Case_Payment__c = bofeCP.Id,
                Payment_on_Behalf_of__c = bofeLiableParty.Id,
                Recommended_Amount__c = 33.33,
                Payment_Applied_To__c = 'Amounts Due to DIR',
                Assessment__c = bofeAssessment.Id,
                Liability__c = bofeLiability.Id,
                Case_Violation__c = bofeCaseIssue.Id,
                Status__c = 'Posted',
                Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
            )
        );
        cu1List.add(
            new Liability_Payment__c(
                Case_Payment__c = bofeCP.Id,
                Payment_on_Behalf_of__c = bofeLiableParty.Id,
                Recommended_Amount__c = 33.33,
                Payment_Applied_To__c = 'Other Amount',
                Assessment__c = bofeAssessment.Id,
                Liability__c = bofeLiability.Id,
                Case_Violation__c = bofeCaseIssue.Id,
                Status__c = 'Posted',
                Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
            )
        );
        /* lpList.add(
            new Liability_Payment__c(
                Case_Payment__c = bofeCP.Id,
                Payment_on_Behalf_of__c = bofeLiableParty.Id,
                Recommended_Amount__c = 33.33,
                Payment_Applied_To__c = 'Penalties',
                Assessment__c = bofeAssessment.Id,
                Liability__c = bofeLiability.Id,
                Case_Violation__c = bofeCaseIssue.Id,
                Status__c = 'Posted',
                Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
            )
        ); */
        insert cu1List;
        
        /*
        List<Judgment_Payment__c> jpList = new List<Judgment_Payment__c>();
        
        Judgment_Payment__c phiJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Allocated_Amount__c = 22.22,
            Apply_Payment_To__c = 'Post-Hearing Interest'
        );
        jpList.add(phiJP);
        
        Judgment_Payment__c afJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Allocated_Amount__c = 22.22,
            Apply_Payment_To__c = 'Attorney Fees'
        );
        jpList.add(afJP);
        
        Judgment_Payment__c ffJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Allocated_Amount__c = 22.22,
            Apply_Payment_To__c = 'Filing Fees'
        );
        jpList.add(ffJP);
        
        insert jpList;
        */
    }

    @isTest
    public static void testQueryCase(){
        DIR_Case__c queriedCase = [SELECT Id, Name FROM DIR_Case__c][0];
        DIR_Case__c testCase = CashDmlMethods.queryCase(queriedCase.Id);
        System.assertEquals(queriedCase.Name, testCase.Name);
    }

    @isTest
    public static void testQueryCP(){
        Case_Payment__c queriedCp = [SELECT Id, Name FROM Case_Payment__c][0];
        Case_Payment__c testCp = CashDmlMethods.queryCP(queriedCp.Id);
        System.assertEquals(queriedCp.Name, testCp.Name);
    }

    @isTest
    public static void testQueryPPs(){
        Payment_Plan__c queriedPp = [SELECT Id, Name, Case__c FROM Payment_Plan__c][0];
        Payment_Plan__c testPp = CashDmlMethods.queryPPs(queriedPp.Case__c)[0];
        System.assertEquals(queriedPp.Name, testPp.Name);
    }

    @isTest
    public static void testQueryCIs(){
        DIR_Violation__c queriedCi = [SELECT Id, Name, Case__c FROM DIR_Violation__c][0];
        DIR_Violation__c testCi = CashDmlMethods.queryCIs(queriedCi.Case__c)[0];
        System.assertEquals(queriedCi.Name, testCi.Name);
    }

    @isTest
    public static void testQueryJudgments(){
        Judgement__c queriedJudgment = [SELECT Id, Name, Case_Management__c FROM Judgement__c][0];
        Judgement__c testJudgment = CashDmlMethods.queryJudgments(queriedJudgment.Case_Management__c)[0];
        System.assertEquals(queriedJudgment.Name, testJudgment.Name);
    }

    @isTest
    public static void testQueryPayees(){
        Payee__c queriedPayee = [SELECT Id, Name, Case_Management__c FROM Payee__c][0];
        Payee__c testPayee = CashDmlMethods.queryPayees(queriedPayee.Case_Management__c)[0];
        System.assertEquals(queriedPayee.Name, testPayee.Name);
    }

    @isTest
    public static void testQueryLiableParties(){
        Liable_Party__c queriedLiableParty = [SELECT Id, Name, Case_Role__r.Case__c FROM Liable_Party__c][0];
        Liable_Party__c testLiableParty = CashDmlMethods.queryLiableParties(queriedLiableParty.Case_Role__r.Case__c)[0];
        System.assertEquals(queriedLiableParty.Name, testLiableParty.Name);
    }
}