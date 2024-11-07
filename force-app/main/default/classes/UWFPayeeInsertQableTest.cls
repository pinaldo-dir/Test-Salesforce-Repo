@isTest
public with sharing class UWFPayeeInsertQableTest {
    
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
             
        List<DIR_Employee__c> dirEmployees = new List<DIR_Employee__c>();
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        dirEmployees.add(manager);
                    
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        dirEmployees.add(deputy);
        insert dirEmployees;

        
        List<Account> accounts = new List<Account>();
        Account employerAccount = new Account( //Also used for creating a Payor
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employerAccount);

        Account uwfAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'DIR Accounting-Unpaid Wage Fund',
            ShippingStreet = '666 66th Street NW',
            ShippingCity = 'Sacofmentos',
            ShippingState = 'CA',
            ShippingPostalCode = '92345'
        );
        accounts.add(uwfAccount);
    
        Account employeePayeeAccount1 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount1);

        Account employeePayeeAccount2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Fargo',
            LastName = 'Northdakota',
            ShippingStreet = '1 1st St',
            ShippingCity = 'Ae',
            ShippingState = 'NY',
            ShippingPostalCode = '02254'
        );
        accounts.add(employeePayeeAccount2);
        insert accounts;


        Address__c employerAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employerAccount.Id];
        Address__c uwfAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :uwfAccount.Id];
        Address__c employeePayeeAccountLocation1 = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employeePayeeAccount1.Id];
        Address__c employeePayeeAccountLocation2 = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employeePayeeAccount2.Id];

       
        Office__c ccuOffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        insert ccuOffice;

        Office_Account__c ccuOfficeAccount = new Office_Account__c(
                Name = '32-117',
                Office__c = ccuOffice.Id
        );
        insert ccuOfficeAccount;

        ccuOffice.Office_Account__c = ccuOfficeAccount.Id;
        update ccuOffice;


        DIR_Case__c bofeCase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employerAccount.Id,
            Office__c = ccuOffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00,
            Deposited_Funds__c = 648247.94
        );
        insert bofeCase;

        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c uwfCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Entity__c = uwfAccount.Id,
            Case__c = bofeCase.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = uwfAccountLocation.Id
        );
        caseRoles.add(uwfCaseRole);
        
        Case_Role__c bofeDefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = bofeCase.Id,
            Entity__c = employerAccount.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(bofeDefendantCaseRole);

        Case_Role__c bofeEmployeeCaseRole1 = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = bofeCase.Id,
            Entity__c = employeePayeeAccount1.Id,
            Role__c = 'Employee',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation1.Id
        );
        caseRoles.add(bofeEmployeeCaseRole1);

        Case_Role__c bofeEmployeeCaseRole2 = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = bofeCase.Id,
            Entity__c = employeePayeeAccount2.Id,
            Role__c = 'Employee',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation2.Id
        );
        caseRoles.add(bofeEmployeeCaseRole2);
        insert caseRoles;


        
                
        
        Violation_Type__c bofeViolationType = new Violation_Type__c(
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            //Even though the method is "getRecordTypeInfosByName()", it actually gets the info by the Label.
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Active__c = true
        );
        insert bofeViolationType;
        
        Assessments__c bofeAssessment = new Assessments__c(
            Case_Management__c = bofeCase.Id,
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert bofeAssessment;


        DIR_Violation__c bofeCaseIssue = new DIR_Violation__c(
            Violation_Type__c = bofeViolationType.Id,
            Case__c = bofeCase.Id,
            Assessment__c = bofeAssessment.Id,
            Citation_Amount__c = 6666,
            Wages_Due__c = 4999.50,
            Total_Interest_Amount__c = 1666.50,
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()
        );
        insert bofeCaseIssue;

        Liability__c bofeLiability = new Liability__c(
            Case_Management__c = bofeCase.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = bofeAssessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );            
        insert bofeLiability;

        
        Liable_Party__c bofeLiableParty = new Liable_Party__c(
            Liability__c = bofeLiability.Id,
            Entity__c = employerAccount.Id,
            Liable_Party_Account_Name__c = employerAccount.Name,
            Case_Role__c = bofeDefendantCaseRole.Id
        );
        insert bofeLiableParty;

        Liable_Party_Case_Issue__c bofeLpci = new Liable_Party_Case_Issue__c(
            Liable_Party__c = bofeLiableParty.Id,
            Case_Issue__c = bofeCaseIssue.Id
        );
        insert bofeLpci;
        
        
        Transaction__c bofeTrn = new Transaction__c(
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
        insert bofeTrn;
    
        Receipt__c bofeRct = new Receipt__c(
            Payor__c = employerAccount.Id,
            Created_Via_PartyToPartyLWC__c = false,
            Deposit_Account__c = '32-117',
            Date_Received__c = Date.today().addDays(-21),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 157.36,
            Transaction__c = bofeTrn.Id,
            Instrument_Number__c = '🍺🍻🍸🍹🍷',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Senior_Deputy__c = manager.Id,
            Hold_Date__c = bofeTrn.Deposit_Date__c.addDays(7)
        );
        insert bofeRct;

        System.debug('496 bofeRct: ' + bofeRct);

        Case_Payment__c bofeCp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('Posted').getRecordTypeId(),
            Case__c = bofeCase.Id,
            Receipt__c = bofeRct.Id,
            Payment_Amount__c = 157.36,
            Status__c = 'Posted'
        );
        insert bofeCp;

        System.debug('309 bofeCp before requery: ' + bofeCp);

        //Requery bofeCp to bring in CP.RCT.Hold_Date__c
        bofeCp = [SELECT Id, Name, RecordTypeId, Case__c, Receipt__c, Receipt__r.Hold_Date__c, Payment_Amount__c, Status__c FROM Case_Payment__c WHERE Id = :bofeCp.Id];

        System.debug('314 bofeCP.Receipt__r.Hold_Date__c after requery: ' + bofeCP.Receipt__r.Hold_Date__c);

        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
        Liability_Payment__c bofeWageLP = new Liability_Payment__c(
            Case_Payment__c = bofeCp.Id,
            Payment_On_Behalf_of__c = bofeLiableParty.Id,
            Posted_Amount__c = 44.44,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Status__c = 'Posted',
            Case_Issue_RecordTypeId__c = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()
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
            Case_Issue_RecordTypeId__c = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()
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
            Case_Issue_RecordTypeId__c = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()
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
            Case_Issue_RecordTypeId__c = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()
        );
        lpList.add(bofePenaltyLP);
        insert lpList;


        List<Payee__c> payees = new List<Payee__c>();
        Payee__c bofeEmployeePayee1 = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = bofeEmployeeCaseRole1.Id,
            NetWages__c = null
            );
        payees.add(bofeEmployeePayee1);
        
        Payee__c bofeEmployeePayee2 = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = bofeEmployeeCaseRole2.Id,
            NetWages__c = null
            );
            payees.add(bofeEmployeePayee2);
            
        Payee__c uwfPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'UWF',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = uwfCaseRole.Id,
            NetWages__c = null
        );
        payees.add(uwfPayee);
        insert payees;
        

        
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        Payment_Record__c bofeWagePr = new Payment_Record__c(
            Liability_Payment__c = bofeWageLP.Id,
            Payee__c = bofeEmployeePayee1.Id,
            Payment_Amount__c = bofeWageLP.Posted_Amount__c,
            Payment_Applied_To__c = bofeWageLP.Payment_Applied_To__c
        );
        prList.add(bofeWagePr);

        Payment_Record__c bofeWageInterestPr = new Payment_Record__c(
            Liability_Payment__c = bofeWageInterestLP.Id,
            Payee__c = bofeEmployeePayee2.Id,
            Payment_Amount__c = bofeWageInterestLP.Posted_Amount__c,
            Payment_Applied_To__c = bofeWageInterestLP.Payment_Applied_To__c
        );
        prList.add(bofeWageInterestPr);

        /* Payment_Record__c bofeInterestPr = new Payment_Record__c(
            Liability_Payment__c = bofeInterestLP.Id,
            Payee__c = bofePenaltyPayee2.Id,
            Payment_Amount__c = bofeInterestLP.Posted_Amount__c,
            Payment_Applied_To__c = bofeInterestLP.Payment_Applied_To__c
        );
        prList.add(bofeInterestPr);

        Payment_Record__c bofePenaltyPr = new Payment_Record__c(
            Liability_Payment__c = bofePenaltyLP.Id,
            Payee__c = bofePenaltyPayee2.Id,
            Payment_Amount__c = bofePenaltyLP.Posted_Amount__c,
            Payment_Applied_To__c = bofePenaltyLP.Payment_Applied_To__c
        );
        prList.add(bofePenaltyPr); */
        insert prList;

        Warrant_Batch__c warrantBatch = new Warrant_Batch__c(
            Status__c = 'New',
            Office_Account__c = ccuOfficeAccount.Id,
            WB_Instructions__c = 'UWF'
        );
        insert warrantBatch;
    }


    @isTest
    static void UWFPayeeInsertQableTest() {

        DIR_Case__c bofeCase = [SELECT Id FROM DIR_Case__c][0];
        List<Account> accounts = [SELECT Id FROM Account WHERE FirstName LIKE '%Madison%' OR FirstName LIKE '%Fargo%'];
        List<Address__c> locations = [SELECT Id FROM Address__c];
        Office_Account__c officeAccount = [SELECT Id FROM Office_Account__c][0];
        Warrant_Batch__c warrantBatch = [SELECT Id FROM Warrant_Batch__c][0];
        List<Case_Role__c> caseRoles = [SELECT Id, Case_Role_Account_Name__c FROM Case_Role__c];

        //Create uninserted Payees
        List<Payee__c> payees = new List<Payee__c>();
        Payee__c bofeEmployeePayee1 = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = [SELECT Id FROM Case_Role__c WHERE Case_Role_Account_Name__c LIKE '%Madison%'][0].Id,
            NetWages__c = null
            );
        payees.add(bofeEmployeePayee1);
        
        Payee__c bofeEmployeePayee2 = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = [SELECT Id FROM Case_Role__c WHERE Case_Role_Account_Name__c LIKE '%Fargo%'][0].Id,
            NetWages__c = null
            );
            payees.add(bofeEmployeePayee2);
            
        Payee__c uwfPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'UWF',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = [SELECT Id FROM Case_Role__c WHERE Case_Role_Account_Name__c LIKE '%Accounting%'][0].Id,
            NetWages__c = null
        );
        payees.add(uwfPayee);
        

        List<Payment_Record__c> paymentRecords = [SELECT Id FROM Payment_Record__c];

        Warrant__c warrant = new Warrant__c(
            Warrant_Batch__c = warrantBatch.Id,
            Amount__c = 32.25,
            Case__c = bofeCase.Id,
            Status__c = 'New',
            Disbursement_Type__c = 'Unpaid Wage Fund',
            Office_Account__c = officeAccount.Id
        );
        List<Warrant__c> warrantList = new List<Warrant__c>{warrant};

        Map<String, List<Id>> qJobIdMap = new Map<String, List<Id>>();
        
        qJobIdMap.put('Update Warrants', new List<Id>{'707000001fakeid'});
        qJobIdMap.put('Insert Warrants', new List<Id>{'707000002fakeid'});

        Test.startTest();
        System.enqueueJob(new UWFPayeeInsertQable(payees, warrantList, paymentRecords, 'testString1', 'testString2', qJobIdMap));
        Test.stopTest();

    }

}