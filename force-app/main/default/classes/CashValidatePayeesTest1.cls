@isTest
public with sharing class CashValidatePayeesTest1 {
    public CashValidatePayeesTest1() {

    }

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
        Account employerAccount = new Account( //Also used for creating a Payor Payee
            RecordTypeId = businessAccountRtId,
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employerAccount);

        Account otherLiableAccount = new Account(
            RecordTypeId = businessAccountRtId,
            Name = 'Wholly Owned Offshore Shell Corp',
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

        Account dirAccountingAccount = new Account(
            RecordTypeId = businessAccountRtId,
            Name = 'DIR Accounting',
            ShippingStreet = '456 Almighty Capitalism Dr',
            ShippingCity = 'Scrotamento',
            ShippingState = 'CA',
            ShippingPostalCode = '98765'
        );
        accounts.add(dirAccountingAccount);

        Account dlseCcuAccount = new Account(
            RecordTypeId = businessAccountRtId,
            Name = 'DLSE - Centralized Cashiering Unit',
            ShippingStreet = '456 Almighty Capitalism Dr',
            ShippingCity = 'Scrotamento',
            ShippingState = 'CA',
            ShippingPostalCode = '98765'
        );
        accounts.add(dlseCcuAccount);
                  
        Account courtPayeeAccount = new Account(
            RecordTypeId = businessAccountRtId,
            Name = 'The Slightly Less Than Superior Court',
            ShippingStreet = '666 Hubba Hubba Dr',
            ShippingCity = 'National City',
            ShippingState = 'CA',
            ShippingPostalCode = '91545'
        );
        accounts.add(courtPayeeAccount);

        Account payorNotTheDefendantAccount = new Account(
            RecordTypeId = businessAccountRtId,
            Name = 'Anonymous Beneficiary',
            ShippingStreet = '999 1/2 Qqusnstonuta Dr',
            ShippingCity = 'National City',
            ShippingState = 'CA',
            ShippingPostalCode = '91545'
        );
        accounts.add(payorNotTheDefendantAccount);
        insert accounts;

        List<DIR_Employee__c> internalEmployees = new List<DIR_Employee__c>();
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        internalEmployees.add(manager);
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        internalEmployees.add(deputy);
        insert internalEmployees;


        List<Office__c> offices = new List<Office__c>();
        Office__c wcaOffice = new Office__c(
            Name = 'Sacramento WCA',
            Office_Number__c = 'WCA 8',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        offices.add(wcaOffice);

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

        DIR_Case__c wcaCase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employerAccount.Id,
            Office__c = wcaOffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00,
            Date_Case_Received__c = Date.parse('12/16/15')
        );
        insert wcaCase;


        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Id wcaCaseRoleRecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        /* Case_Role__c defendantCaseRole = [SELECT Id, Name, Case__c, Entity__c
                                            FROM Case_Role__c
                                            WHERE Role__c LIKE '%Employer%'
                                                OR Role__c LIKE '%Defendant%'
                                            LIMIT 1];
        delete defendantCaseRole; */

        Case_Role__c employeeCaseRole = new Case_Role__c(
            RecordTypeId = wcaCaseRoleRecordTypeId,
            Case__c = wcaCase.Id,
            Entity__c = employeePayeeAccount.Id,
            Account_Name__c = employeePayeeAccount.Name,
            Role__c = 'State',
            Case_Role_Status__c = 'Active'
        );
        caseRoles.add(employeeCaseRole);

        Case_Role__c dirAccountingCaseRole = new Case_Role__c(
            RecordTypeId = wcaCaseRoleRecordTypeId,
            Case__c = wcaCase.Id,
            Entity__c = dirAccountingAccount.Id,
            Account_Name__c = dirAccountingAccount.Name,
            Role__c = 'State',
            Case_Role_Status__c = 'Active'
        );
        caseRoles.add(dirAccountingCaseRole);

        Case_Role__c dlseCcuCaseRole = new Case_Role__c(
            RecordTypeId = wcaCaseRoleRecordTypeId,
            Case__c = wcaCase.Id,
            Entity__c = dlseCcuAccount.Id,
            Account_Name__c = dlseCcuAccount.Name,
            Role__c = 'State',
            Case_Role_Status__c = 'Active'
        );
        caseRoles.add(dlseCcuCaseRole);

        Case_Role__c courtCaseRole = new Case_Role__c(
            RecordTypeId = wcaCaseRoleRecordTypeId,
            Case__c = wcaCase.Id,
            Entity__c = courtPayeeAccount.Id,
            Account_Name__c = courtPayeeAccount.Name,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active'
        );
        caseRoles.add(courtCaseRole);

        Case_Role__c payorCaseRole = new Case_Role__c(
            RecordTypeId = wcaCaseRoleRecordTypeId,
            Case__c = wcaCase.Id,
            Entity__c = payorNotTheDefendantAccount.Id,
            Account_Name__c = payorNotTheDefendantAccount.Name,
            Role__c = 'Payor',
            Case_Role_Status__c = 'Active'
        );
        caseRoles.add(payorCaseRole);
        insert caseRoles;


        List<Payee__c> payees = new List<Payee__c>();
        Payee__c wcaEmployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            NetWages__c = 666.66,
            Payee_Type__c = 'Employee',
            Case_Management__c = wcaCase.Id,
            Case_Role__c = employeeCaseRole.Id
        );
        payees.add(wcaEmployeePayee);

        /* Payee__c wcaEmployeePayee = [SELECT Id, Name, Status__c, Factor__c, Payee_Type__c, Case_Management__c, Case_Role__c FROM Payee__c WHERE Payee_Type__c = 'Employee'][0];
        wcaEmployeePayee.NetWages__c = 666.66;
        payees.add(wcaEmployeePayee); */

        /* Payee__c dirAccountingPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = wcaCase.Id,
            Case_Role__c = dirAccountingCaseRole.Id
        );
        payees.add(dirAccountingPayee); */

        Payee__c dlseCcuPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = wcaCase.Id,
            Case_Role__c = dlseCcuCaseRole.Id
        );
        payees.add(dlseCcuPayee);
        
        Payee__c courtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = wcaCase.Id,
            Case_Role__c = courtCaseRole.Id
        );
        payees.add(courtPayee);

        Payee__c payorPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Payor',
            Case_Management__c = wcaCase.Id,
            Case_Role__c = payorCaseRole.Id
        );
        payees.add(payorPayee);
        insert payees;

        System.debug('275 payees: ' + payees);

        Office_Account__c wcaOfficeAccount = new Office_Account__c(
            Name = '08-116',
            Office__c = wcaOffice.Id
        );
        insert wcaOfficeAccount;

        Transaction__c wcaTRN = new Transaction__c(
            Office_Account__c = wcaOfficeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-7),
            Business_Unit__c = 'WCA',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 55.55,
            Check_Count__c = 1,
            Checks_Amount__c = 55.55,
            Treasury_Deposit_Number__c = '😜😲😅'
        );
        insert wcaTRN;
    
        Receipt__c wcaRCT = new Receipt__c(
            Payor__c = payorNotTheDefendantAccount.Id,
            Created_Via_PartyToPartyLWC__c = false,
            Deposit_Account__c = '08-116',
            Date_Received__c = Date.today().addDays(-14),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 55.55,
            Transaction__c = wcaTRN.Id,
            Instrument_Number__c = '🍺🍻🍸🍹🍷',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Senior_Deputy__c = manager.Id
        );
        insert wcaRCT;

        Case_Payment__c wcaCP = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = wcaCase.Id,
            Receipt__c = wcaRCT.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'Posted'
        );
        insert wcaCP;


    }
    
    @isTest
    static void testCashValidatePayees(){
        List<CashCaseIssueWrapper> ciwList = new List<CashCaseIssueWrapper>();
        List<CashJudgmentWrapper> jwList = new List<CashJudgmentWrapper>();
        List<CashCu1Wrapper> cu1wList = new List<CashCu1Wrapper>();

        Case_Payment__c wcaCP = [SELECT Id, Name, Case__c, Case__r.RecordType.Name, Receipt__c, Payment_Amount__c FROM Case_Payment__c][0];
        
        Liability_Payment__c amtDueToDirCu1Lp = new Liability_Payment__c(
            Case_Payment__c = wcaCP.Id,
            Posted_Amount__c = 99.99,
            Status__c = 'Posted'
        );
        insert amtDueToDirCu1Lp;

        CashCu1Wrapper cu1w = new CashCu1Wrapper('Amounts Due to DIR');
        cu1w.matchingLp = amtDueToDirCu1Lp;
        cu1w.amtDueToDir = 99.99;
        cu1w.amtDueToDirExplanation = 'testing';
        
        cu1wList.add(cu1w);
    
        Test.startTest();

        CashValidatePayees.validatePayees(cu1wList, ciwList, jwList, wcaCp);

        Test.stopTest();
        
    }
}