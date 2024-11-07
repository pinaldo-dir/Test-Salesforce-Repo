@isTest
public with sharing class CashSaveAllocationsTest2{

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

        Account bofePenaltyAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'DLSE - Centralized Cashiering Unit',
            ShippingStreet = '0 Zeroth St',
            ShippingCity = 'Mentosacra',
            ShippingState = 'CA',
            ShippingPostalCode = '98765'
        );
        accounts.add(bofePenaltyAccount);

        Account otherLiableAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'Wholly Owned Shell Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(otherLiableAccount);
        
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

        Account statePayeeAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'DIR Accounting',
            ShippingStreet = '456 Almighty Capitalism Dr',
            ShippingCity = 'Scrotamento',
            ShippingState = 'CA',
            ShippingPostalCode = '98765'
        );
        accounts.add(statePayeeAccount);
                  
        /* Account courtPayeeAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'The Superior Inferior Court Jester',
            ShippingStreet = '666 Hubba Hubba Dr',
            ShippingCity = 'National City',
            ShippingState = 'CA',
            ShippingPostalCode = '91545'
        );
        accounts.add(courtPayeeAccount); */
        insert accounts;

        Address__c employerAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employerAccount.Id];
        Address__c otherLiableAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :otherLiableAccount.Id];
        Address__c employeePayeeAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employeePayeeAccount.Id];
        Address__c statePayeeAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :statePayeeAccount.Id];
        /* Address__c courtPayeeAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :courtPayeeAccount.Id]; */
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
        locations.add(employeePayeeAccountLocation); 

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
        insert locations; */
                    
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
            Court_Account__c = null,
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('Courthouse').getRecordTypeId()
        );
        offices.add(courtOffice);
        insert offices;

        DIR_Case__c bofeCase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employerAccount.Id,
            Office__c = bofeOffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId(),
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
        /* Case_Role__c bofeDefendantCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = employerAccount.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(bofeDefendantCaseRole); */

        Case_Role__c otherLiableCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = otherLiableAccount.Id,
            Role__c = 'Other',
            Case_Role_Status__c = 'Active',
            Location__c = otherLiableAccountLocation.Id
        );
        caseRoles.add(otherLiableCaseRole);
        
        
        Case_Role__c bofeEmployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(bofeEmployeePayeeCaseRole);
        
        /* Case_Role__c statePayeeCaseRole = new Case_Role__c(
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
        caseRoles.add(courtPayeeCaseRole); */
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

        /* Payee__c statePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = statePayeeCaseRole.Id,
            NetWages__c = 666.66
        );
        payees.add(statePayee);
        
        Payee__c courtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = courtPayeeCaseRole.Id,
            NetWages__c = 666.66
        );
        payees.add(courtPayee); */
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
            Case_Role__c = otherLiableCaseRole.Id
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
            Created_Via_PartyToPartyLWC__c = false,
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
            Status__c = 'Allocations Recommended'
        );
        insert bofeCP;


        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
        Liability_Payment__c bofeWageLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_of__c = bofeLiableParty.Id,
            Recommended_Amount__c = 33.33,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Status__c = 'Recommended',
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofeWageLP);
        
        /* Liability_Payment__c bofeInterestLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Recommended_Amount__c = 33.33,
            Status__c = 'Recommended',
            Payment_Applied_To__c = 'Interest',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofeInterestLP); */

        Liability_Payment__c bofeWageInterestLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Recommended_Amount__c = 33.33,
            Status__c = 'Recommended',
            Payment_Applied_To__c = 'Wage Interest',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofeWageInterestLP);
        
        Liability_Payment__c bofePentaltyLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Recommended_Amount__c = 33.33,
            Status__c = 'Recommended',
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofePentaltyLP);
        
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
            Recommended_Amount__c = 22.22,
            Payment_Applied_To__c = 'Post-Hearing Interest'
        );
        jpList.add(phiJP);

        Judgment_Payment__c pjiJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Recommended_Amount__c = 22.22,
            Payment_Applied_To__c = 'Post-Judgment Interest'
        );
        jpList.add(pjiJP);

        Judgment_Payment__c afJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Recommended_Amount__c = 22.22,
            Payment_Applied_To__c = 'Attorney Fees'
        );
        jpList.add(afJP);
        
        /* Judgment_Payment__c ffJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Recommended_Amount__c = 22.22,
            Payment_Applied_To__c = 'Filing Fees'
        );
        jpList.add(ffJP); */
        insert jpList;

        List<Liability_Payment__c> cu1List = new List<Liability_Payment__c>();
        Liability_Payment__c refundCu1 = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Recommended_Amount__c = 5.55,
            Payment_Applied_To__c = 'Refund Amount',
            Status__c = 'Recommended'
        );
        cu1List.add(refundCu1);

        Liability_Payment__c amtDueToDirCu1 = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Recommended_Amount__c = 2.52,
            Payment_Applied_To__c = 'Amounts Due to DIR',
            Status__c = 'Recommended'
        );
        cu1List.add(amtDueToDirCu1);

        Liability_Payment__c otherAmountCu1 = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Recommended_Amount__c = .33,
            Payment_Applied_To__c = 'Other Amount',
            Status__c = 'Recommended'
        );
        cu1List.add(otherAmountCu1);
        insert cu1List;

    }

    @isTest
    static void testCashSaveAllocations(){
        Receipt__c bofeRCT = [SELECT Id, Name, Payor__c FROM Receipt__c][0];
        Case_Payment__c bofeCP = [SELECT Id, Name, Case__c, Case__r.RecordType.Name, Receipt__c, Receipt__r.Payor__c, Receipt__r.Payor__r.Name, Receipt__r.Deposit_Account__c,
                                        Status__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Deposited__c, Payment_Exchange__c,
                                        Payment_Classification__c, Special_Instructions__c, Payment_Terms__c, Payment_Terms_Other__c, 
                                        Date_Funds_Mailed_To_Employee__c, Mailing_Instructions__c, Refund_Amount__c, Refund_Amount_Details__c, 
                                        Amounts_Due_to_DIR__c, Amounts_Due_to_DIR_Explanation__c, Other_Amount__c, Other_Amount_Details__c, RecordTypeId, Receipt_Hold_Date__c
                                    FROM Case_Payment__c][0];
        Payment_Plan__c pp = [SELECT Id, Name FROM Payment_Plan__c][0];
        List<DIR_Violation__c> ciList = [SELECT Id, Name, Wage_Assessment_Description__c, RecordTypeId, Status__c,
                                                Violation_Type__c, Violation_Type__r.Name, 
                                                Assessment__c, Assessment__r.Citation_Number__c, Assessment__r.JEU_Case_Number__c,
                                                Wages_Due__c, Non_Interest_Wage_Balance_Due__c, Total_Wage_Interest_Amount__c, Wage_Interest_Balance_Due__c,
                                                Citation_Amount__c,  Penalty_Balance_Due__c, Total_Interest_Amount__c, Interest_Balance_Due__c
                                            FROM DIR_Violation__c];
        List<Liable_Party__c> liablePartyList = [SELECT Id, Name, Liability__c, Liability__r.Id, Liability__r.Assessment__c, Liability__r.Assessment__r.Id, Case_Role__c, Entity__c
                                                    FROM Liable_Party__c];
        List<Judgement__c> judgmentList = [SELECT Id, Name, Type__c, Court_Case_Number__c, Court__c, Court__r.Name, Status__c,
                                                Post_hearing_Interest_Balance_Due__c, Post_judgment_Interest_Balance_Due__c,
                                                Attorney_Fees_Balance_Due__c, Filing_Fees_Balance_Due__c
                                            FROM Judgement__c];
        List<Liability_Judgement__c> judgmentPartyList = [SELECT Id, Name, Judgement__c, Liable_Party__r.Case_Role__r.Account_Name__c,
                                                                Liable_Party__r.Id, Liable_Party__r.Case_Role__r.Id FROM Liability_Judgement__c];
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Payment_Applied_To__c, Recommended_Amount__c, Posted_Amount__c, Status__c, Refund_Amount_Details__c,
                                                    Payment_On_Behalf_Of__c, Amounts_Due_to_DIR_Explanation__c, Other_Amount_Details__c, Case_Issue_RecordTypeId__c,
                                                Case_Violation__c, Case_Violation__r.Assessment__r.Citation_Number__c, 
                                                Case_Violation__r.Assessment__r.JEU_Case_Number__c FROM Liability_Payment__c];
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Judgment__c, Payment_Applied_To__c, Posted_Amount__c, Recommended_Amount__c, Funds_Redundant_With__c FROM Judgment_Payment__c];
        
        List<CashCaseIssueWrapper> ciwList = CashCaseIssueWrapper.createCaseIssueWrapperList(ciList, lpList, jpList, liablePartyList, liablePartyList[0].Case_Role__c);
        List<CashCu1Wrapper> cu1wList = CashCu1Wrapper.createCu1WrapperList(lpList, liablePartyList, liablePartyList[0].Case_Role__c);
        
        List<CashJudgmentWrapper> jwList = CashJudgmentWrapper.createJudgmentWrapperList(judgmentList, jpList, judgmentPartyList, liablePartyList[0].Case_Role__c);


        List<SObject> recordsToDelete = new List<SObject>();
        Liability_Payment__c lpToDelete = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = liablePartyList[0].Id,
            Recommended_Amount__c = .89,
            Payment_Applied_To__c = 'Wages'
        );
        recordsToDelete.add(lpToDelete);
        insert(recordsToDelete);


        Test.startTest();
        
        CashSaveAllocations.saveAllocations(bofeRCT, bofeCP, 'Post', pp.Id, cu1wList, ciwList, jwList, liablePartyList, judgmentPartyList, recordsToDelete);
        
        Test.stopTest();

        /* List<Payment_Record__c> prList = [SELECT Id, Name, Payment_Applied_To__c, Payment_Amount__c FROM Payment_Record__c];
        Payment_Record__c bofeWagePr;
        for(Payment_Record__c pr : prList){
            if(pr.Payment_Applied_To__c == 'Wages'){
                bofeWagePr = pr;
            }
        }
        System.assertEquals(33.33, bofeWagePr.Payment_Amount__c, 'bofeWagePr amount not equal'); */
    }
}