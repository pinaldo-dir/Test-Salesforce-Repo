@isTest
public with sharing class CashPrRoundCorrSetupQableTest {

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
        insert triggerSettings;        

            
        List<Account> accounts = new List<Account>();
        Id businessAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        Account employerAccount = new Account( //Also used for creating a Payor Payee
            RecordTypeId = businessAccountId,
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

        Account dirAccountingPayeeAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'DIR Accounting',
            ShippingStreet = '456 Almighty Capitalism Dr',
            ShippingCity = 'Scrotamento',
            ShippingState = 'CA',
            ShippingPostalCode = '98765'
        );
        accounts.add(dirAccountingPayeeAccount);

        Account bofePenaltyAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'DLSE - Centralized Cashiering Unit',
            ShippingStreet = '123 Gavin Newsome Blvd',
            ShippingCity = 'Sack of Mentos',
            ShippingState = 'CA',
            ShippingPostalCode = '96669'
        );
        accounts.add(bofePenaltyAccount);
                    
        Account courtPayeeAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'The Superior Inferior Court Jester',
            ShippingStreet = '666 Hubba Hubba Dr',
            ShippingCity = 'National City',
            ShippingState = 'CA',
            ShippingPostalCode = '91545'
        );
        accounts.add(courtPayeeAccount);
        insert accounts;

        Address__c employerAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employerAccount.Id];
        Address__c employeePayeeAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employeePayeeAccount.Id];
        Address__c bofePenaltyAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :bofePenaltyAccount.Id];
        Address__c dirAccountingPayeeAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :dirAccountingPayeeAccount.Id];
        Address__c courtPayeeAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :courtPayeeAccount.Id];
        /* List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employerAccount.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
                        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation); */
        /*      
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '456 Almighty Capitalism Dr',
            City__c = 'Scrotamento',
            State__c = 'CA',
            Zip_Code__c = '98765'
        );
        locations.add(statePayeeAccountLocation);
            
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '666 Hubba Hubba Dr',
            City__c = 'National City',
            State__c = 'CA',
            Zip_Code__c = '91545'
        );
        locations.add(courtPayeeAccountLocation);
        */
        /* insert locations; */
                    
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
        
        /* Profile p = [SELECT Id, Name
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
        System.debug('####sysAd = '+sysAd); */
        
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

        Office__c courtOffice = new Office__c(
            Name = 'The Slightly Less Than Superior Court',
            Address_1__c = '555 555th St',
            City__c = 'Mxpljrfsca',
            State__c = 'CA',
            Zip_Code__c = '99991',
            Judicial__c = '',
            Phone__c = '999-999-6666',
            Court_Account__c = courtPayeeAccount.Id,
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('Courthouse').getRecordTypeId()
        );
        offices.add(courtOffice);
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
            Responsible_Party__c = employerAccount.Id,
            Payment_Plan_Total_Amount_Due__c = 1111.00,
            Number_of_Payments__c = 11,
            Payment_Plan_Regular_Payment__c = 101.00,
            Payment_Plan_Start_Date__c = Date.newInstance(2024, 7, 15),
            Date_of_First_Payment__c = Date.newInstance(2024, 7, 15),
            Frequency__c = 'Monthly',
            Day_of_Monthly_Payment_Due__c = '15'
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

        Case_Role__c bofePenaltyCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = bofePenaltyAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = bofePenaltyAccountLocation.Id
        );
        caseRoles.add(bofePenaltyCaseRole);

        Case_Role__c dirAccountingCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = dirAccountingPayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = dirAccountingPayeeAccountLocation.Id
        );
        caseRoles.add(dirAccountingCaseRole);
        
        Case_Role__c courtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(courtPayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
        Payee__c bofeEmployeePayee = [SELECT Id, Name, Status__c, Factor__c, Payee_Type__c, Case_Management__c, Case_Role__c FROM Payee__c WHERE Payee_Type__c = 'Employee'][0];
        bofeEmployeePayee.NetWages__c = 666.66;
        payees.add(bofeEmployeePayee);
        /* Payee__c bofeEmployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = bofeEmployeePayeeCaseRole.Id
        );
        payees.add(bofeEmployeePayee); */

        Payee__c bofePenaltyPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = bofePenaltyCaseRole.Id,
            NetWages__c = null
        );
        payees.add(bofePenaltyPayee);

        Payee__c dirAccountingPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = dirAccountingCaseRole.Id,
            NetWages__c = null
        );
        payees.add(dirAccountingPayee);
        
        Payee__c courtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = courtPayeeCaseRole.Id,
            NetWages__c = null
        );
        payees.add(courtPayee);

        Payee__c payorPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Payor',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = bofeDefendantCaseRole.Id,
            NetWages__c = null
        );
        payees.add(payorPayee);



        upsert payees;
        
        List<Violation_Type__c> violationTypes = new List<Violation_Type__c>();
        Violation_Type__c bofeViolationType = new Violation_Type__c(
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            //Even though the method is "getRecordTypeInfosByName()", it actually gets the info by the Label.
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Active__c = true
        );
        violationTypes.add(bofeViolationType);

        /* Violation_Type__c wcaViolationType = new Violation_Type__c(
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            //Even though the method is "getRecordTypeInfosByName()", it actually gets the info by the Label.
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - Active').getRecordTypeId(),
            Active__c = true
        );
        violationTypes.add(wcaViolationType); */
        insert violationTypes;
        
        Assessments__c bofeAssessment = new Assessments__c(
            Case_Management__c = bofeCase.Id,
            Appeal_Deadline_Days__c = 15,
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

        /* DIR_Violation__c wcaCaseIssue = new DIR_Violation__c(
            Violation_Type__c = wcaViolationType.Id,
            Case__c = bofeCase.Id,
            Assessment__c = bofeAssessment.Id,
            Citation_Amount__c = 7777,
            Wages_Due__c = 1999.50,
            Total_Interest_Amount__c = 5777.50,
            Status__c = 'Open',
            RecordTypeId = wcaCaseIssueRecordTypeId
        );
        caseIssues.add(wcaCaseIssue); */
        insert caseIssues;

        List<Judgement__c> judgmentList = new List<Judgement__c>();
        Judgement__c judgment = new Judgement__c(
            Case_Management__c = bofeCase.Id,
            Court__c = courtOffice.Id,
            Type__c = 'JEU',
            Status__c = 'New',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
        );
        judgmentList.add(judgment);
        insert judgmentList;

        Liability__c bofeLiability = new Liability__c(
            Case_Management__c = bofeCase.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = bofeAssessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );            
        insert bofeLiability;

        List<Liable_Party__c> liablePartyList = new List<Liable_Party__c>();
        Liable_Party__c bofeLiableParty = new Liable_Party__c(
            Liability__c = bofeLiability.Id,
            Entity__c = employerAccount.Id,
            Liable_Party_Account_Name__c = employerAccount.Name,
            Case_Role__c = bofeDefendantCaseRole.Id
        );
        liablePartyList.add(bofeLiableParty);
        insert liablePartyList;

        Liable_Party_Case_Issue__c bofeLPCI = new Liable_Party_Case_Issue__c(
            Liable_Party__c = bofeLiableParty.Id,
            Case_Issue__c = bofeCaseIssue.Id
        );
        insert bofeLPCI;
        
        List<Liability_Judgement__c> judgmentPartyList = new List<Liability_Judgement__c>();
        Liability_Judgement__c bofeJudgmentParty = new Liability_Judgement__c(
            Judgement__c = judgment.Id,
            Liable_Party__c = bofeLiableParty.Id
        );
        judgmentPartyList.add(bofeJudgmentParty);
        insert judgmentPartyList;
        
        Office_Account__c ccuOfficeAccount = new Office_Account__c(
            Name = '32-117',
            Office__c = ccuOffice.Id
        );
        insert ccuOfficeAccount;
        
        Transaction__c bofeTRN = new Transaction__c(
            Office_Account__c = ccuOfficeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-14),
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
            Created_Via_PartyToPartyLWC__c = false,
            Deposit_Account__c = '32-117',
            Date_Received__c = Date.today().addDays(-21),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 157.36,
            Transaction__c = bofeTRN.Id,
            Instrument_Number__c = '🍺🍻🍸🍹🍷',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Senior_Deputy__c = manager.Id,
            Hold_Date__c = bofeTRN.Deposit_Date__c.addDays(7)
        );
        insert bofeRCT;

        System.debug('433 bofeRCT: ' + bofeRCT);

        Case_Payment__c bofeCP = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('Posted').getRecordTypeId(),
            Case__c = bofeCase.Id,
            Receipt__c = bofeRCT.Id,
            Payment_Amount__c = 157.36,
            Status__c = 'Posted'
        );
        insert bofeCP;

        System.debug('478 bofeCP before requery: ' + bofeCP);

        //Requery bofeCP to bring in CP.RCT.Hold_Date__c
        bofeCP = [SELECT Id, Name, RecordTypeId, Case__c, Receipt__c, Receipt__r.Hold_Date__c, Payment_Amount__c, Status__c FROM Case_Payment__c WHERE Id = :bofeCP.Id];

        System.debug('483 bofeCP.Receipt__r.Hold_Date__c after requery: ' + bofeCP.Receipt__r.Hold_Date__c);

        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
        Liability_Payment__c bofeWageLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_of__c = bofeLiableParty.Id,
            Posted_Amount__c = 44.44,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Status__c = 'Posted',
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofeWageLP);
        
        Liability_Payment__c bofeInterestLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Posted_Amount__c = 33.33,
            Status__c = 'Posted',
            Payment_Applied_To__c = 'Interest',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofeInterestLP);

        Liability_Payment__c bofeWageInterestLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Posted_Amount__c = 22.22,
            Status__c = 'Posted',
            Payment_Applied_To__c = 'Wage Interest',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofeWageInterestLP);
        
        Liability_Payment__c bofePenaltyLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Posted_Amount__c = 11.11,
            Status__c = 'Posted',
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofePenaltyLP);
        
        /* Liability_Payment__c wcaInterestLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Payment_Amount__c = 33.33,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = wcaCaseIssue.Id,
            Case_Issue_RecordTypeId__c = wcaCaseIssueRecordTypeId
        );
        lpList.add(wcaInterestLP); */
        insert lpList;

        
        List<Judgment_Payment__c> jpList = new List<Judgment_Payment__c>();
        Judgment_Payment__c phiJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Posted_Amount__c = 9.99,
            Status__c = 'Posted',
            Payment_Applied_To__c = 'Post-Hearing Interest'
        );
        jpList.add(phiJP);

        Judgment_Payment__c pjiJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Posted_Amount__c = 8.88,
            Status__c = 'Posted',
            Payment_Applied_To__c = 'Post-Judgment Interest'
        );
        jpList.add(pjiJP);

        Judgment_Payment__c afJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Posted_Amount__c = 7.77,
            Status__c = 'Posted',
            Payment_Applied_To__c = 'Attorney Fees'
        );
        jpList.add(afJP);
        
        Judgment_Payment__c ffJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Posted_Amount__c = 6.66,
            Status__c = 'Posted',
            Payment_Applied_To__c = 'Filing Fees'
        );
        jpList.add(ffJP);
        insert jpList;

        List<Liability_Payment__c> cu1List = new List<Liability_Payment__c>();
        Liability_Payment__c refundCu1 = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Posted_Amount__c = 5.43,
            Payment_Applied_To__c = 'Refund Amount',
            Status__c = 'Posted'
        );
            cu1List.add(refundCu1);

        Liability_Payment__c amtDueToDirCu1 = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Posted_Amount__c = 4.32,
            Payment_Applied_To__c = 'Amounts Due to DIR',
            Status__c = 'Posted'
        );
        cu1List.add(amtDueToDirCu1);

        Liability_Payment__c otherAmountCu1 = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Posted_Amount__c = 3.21,
            Payment_Applied_To__c = 'Other Amount',
            Status__c = 'Posted'
        );
        cu1List.add(otherAmountCu1);
        insert cu1List;

        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        Payment_Record__c bofeWagePr = new Payment_Record__c(
            Liability_Payment__c = bofeWageLP.Id,
            Payee__c = bofeEmployeePayee.Id,
            Payment_Amount__c = bofeWageLP.Posted_Amount__c,
            Payment_Applied_To__c = bofeWageLP.Payment_Applied_To__c
        );
        prList.add(bofeWagePr);

        Payment_Record__c bofeWageInterestPr = new Payment_Record__c(
            Liability_Payment__c = bofeWageInterestLP.Id,
            Payee__c = bofeEmployeePayee.Id,
            Payment_Amount__c = bofeWageInterestLP.Posted_Amount__c,
            Payment_Applied_To__c = bofeWageInterestLP.Payment_Applied_To__c
        );
        prList.add(bofeWageInterestPr);

        Payment_Record__c bofeInterestPr = new Payment_Record__c(
            Liability_Payment__c = bofeInterestLP.Id,
            Payee__c = bofePenaltyPayee.Id,
            Payment_Amount__c = bofeInterestLP.Posted_Amount__c,
            Payment_Applied_To__c = bofeInterestLP.Payment_Applied_To__c
        );
        prList.add(bofeInterestPr);

        Payment_Record__c bofePenaltyPr = new Payment_Record__c(
            Liability_Payment__c = bofePenaltyLP.Id,
            Payee__c = bofePenaltyPayee.Id,
            Payment_Amount__c = bofePenaltyLP.Posted_Amount__c,
            Payment_Applied_To__c = bofePenaltyLP.Payment_Applied_To__c
        );
        prList.add(bofePenaltyPr);

        Payment_Record__c phiPr = new Payment_Record__c(
            Judgment_Payment__c = phiJP.Id,
            Payee__c = bofeEmployeePayee.Id,
            Payment_Amount__c = phiJP.Posted_Amount__c,
            Payment_Applied_To__c = phiJP.Payment_Applied_To__c
        );
        prList.add(phiPr);

        Payment_Record__c pjiPr = new Payment_Record__c(
            Judgment_Payment__c = phiJP.Id,
            Payee__c = bofeEmployeePayee.Id,
            Payment_Amount__c = pjiJP.Posted_Amount__c,
            Payment_Applied_To__c = pjiJP.Payment_Applied_To__c
        );
        prList.add(pjiPr);

        Payment_Record__c afPr = new Payment_Record__c(
            Judgment_Payment__c = afJP.Id,
            Payee__c = dirAccountingPayee.Id,
            Payment_Amount__c = afJP.Posted_Amount__c,
            Payment_Applied_To__c = afJP.Payment_Applied_To__c
        );
        prList.add(afPr);

        Payment_Record__c ffPr = new Payment_Record__c(
            Judgment_Payment__c = ffJP.Id,
            Payee__c = courtPayee.Id,
            Payment_Amount__c = ffJP.Posted_Amount__c,
            Payment_Applied_To__c = ffJP.Payment_Applied_To__c
        );
        prList.add(ffPr);

        Payment_Record__c refundPr = new Payment_Record__c(
            Liability_Payment__c = refundCu1.Id,
            Payee__c = courtPayee.Id,
            Payment_Amount__c = refundCu1.Posted_Amount__c,
            Payment_Applied_To__c = refundCu1.Payment_Applied_To__c
        );
        prList.add(refundPr);

        Payment_Record__c dirAttorneyFeePr = new Payment_Record__c(
            Liability_Payment__c = amtDueToDirCu1.Id,
            Payee__c = dirAccountingPayee.Id,
            Payment_Amount__c = amtDueToDirCu1.Posted_Amount__c,
            Payment_Applied_To__c = amtDueToDirCu1.Payment_Applied_To__c
        );
        prList.add(dirAttorneyFeePr);
        
        insert prList;
    }

    @isTest
    static void testCashPrRoundCorrSetupQable(){

        Case_Payment__c bofeCP = [SELECT Id, Name, RecordTypeId, Case__c, Receipt__c, Receipt__r.Hold_Date__c, Payment_Amount__c, Status__c FROM Case_Payment__c][0];
        List<Payment_Record__c> prList = [SELECT Id, Name, Payment_Applied_To__c, Payment_Amount__c, Liability_Payment__c, Judgment_Payment__c, Payee__c FROM Payment_Record__c];
        List<Payee__c> payeeList = [SELECT Id, Name, NetWages__c, Sum_Of_All_Payment_Records__c FROM Payee__c];
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Status__c, Posted_Amount__c, Payment_Applied_To__c, Case_Issue_RecordTypeId__c FROM Liability_Payment__c];
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Status__c, Posted_Amount__c, Payment_Applied_To__c FROM Judgment_Payment__c];

        Map<Id, List<Payment_Record__c>> payeeIdToPrListMap = new Map<Id, List<Payment_Record__c>>();
        for(Payment_Record__c pr : prList){
            if(payeeIdToPrListMap.containsKey(pr.Payee__c)){
                List<Payment_Record__c> tempList = payeeIdToPrListMap.get(pr.Payee__c);
                tempList.add(pr);
                payeeIdToPrListMap.put(pr.Payee__c, tempList);
            }else{
                List<Payment_Record__c> tempList = new List<Payment_Record__c>{pr};
                payeeIdToPrListMap.put(pr.Payee__c, tempList);
            }
        }

        Map<String, List<Id>> qJobIdMap = new Map<String, List<Id>>();


        Test.startTest();

        System.enqueueJob(new CashPrRoundCorrSetupQable(bofeCp, payeeIdToPrListMap, payeeList, lpList, jpList, qJobIdMap));

        Test.stopTest();

    }

}