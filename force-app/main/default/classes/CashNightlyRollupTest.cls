/* This test class provides test code coverage for CashNightlyRollup.cls, but to do a REAL test, deactivate the Case Payment Flow and
    Warrant Flow first.
 */
@isTest
public with sharing class CashNightlyRollupTest {

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
            Is_Active__c = true
        ));

        insert triggerSettings;


        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        insert employer;
        /*
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        insert employerAccountLocation;*/
        /*
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        insert statePayeeAccount;
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        insert statePayeeAccountLocation;
        */
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        insert employeePayeeAccount;
        /*
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        insert employeePayeeAccountLocation;
        */
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
        
        Office__c wcaOffice = new Office__c(
            Name = 'Bakersfield WCA',
            Office_Number__c = 'WCA 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert wcaOffice;
        
        DIR_Case__c wcaCase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = wcaOffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()/* ,
            Deposited_Funds__c = 0.00,
            Funds_Drawn_on_Deposits__c = 0.00 */
        );
        insert wcaCase;

        DIR_Case__c wcaCaseWithNoMoney = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = wcaOffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()/* ,
            Deposited_Funds__c = 0.00,
            Funds_Drawn_on_Deposits__c = 0.00 */
        );
        insert wcaCaseWithNoMoney;


        /*
        Case_Role__c wcaDefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = wcaCase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        insert wcaDefendantCaseRole;*/
        /*
        Case_Role__c wcaStatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = wcaCase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        insert wcaStatePayeeCaseRole;
        */
        Case_Role__c wcaEmployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Entity__c = employeePayeeAccount.Id,
            Case__c = wcaCase.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active' //,
            //Location__c = employeePayeeAccountLocation.Id
        );
        insert wcaEmployeePayeeCaseRole;
        
/*        Payee__c wcaStatePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = wcaCase.Id,
            Case_Role__c = wcaStatePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        insert wcaStatePayee;
        
        Payee__c wcaCourtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = wcaCase.Id,
            Case_Role__c = wcaCourtPayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        insert wcaCourtPayee;
        */
        
        Payee__c wcaEmployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = wcaCase.Id,
            Case_Role__c = wcaEmployeePayeeCaseRole.Id
        );
        insert wcaEmployeePayee;
        
        Violation_Type__c wcaViolationType = new Violation_Type__c(
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - Active').getRecordTypeId(),
            Active__c = true
        );
        insert wcaViolationType;
        /*
        Assessments__c wcaAssessment = new Assessments__c(
            Case_Management__c = wcaCase.Id,
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert wcaAssessment;
    */
        DIR_Violation__c wcaCaseIssue = new DIR_Violation__c(
            Violation_Type__c = wcaViolationType.Id,
            Case__c = wcaCase.Id,
            //Assessment__c = wcaAssessment.Id,
            Citation_Amount__c = 3333,
            Wages_Due__c = 2499.75,
            Total_Interest_Amount__c = 833.25,
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()
        );
        insert wcaCaseIssue;
        /*
        Liability__c wcaLiability = new Liability__c(
            Case_Management__c = wcaCase.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = wcaAssessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert wcaLiability;
        
        Liable_Party__c wcaLiableParty = new Liable_Party__c(
            Liability__c = wcaLiability.Id,
            Entity__c = employer.Id,
            Case_Role__c = wcaDefendantCaseRole.Id
        );
        insert wcaLiableParty;
        
        Liable_Party_Case_Issue__c wcaLpCi = new Liable_Party_Case_Issue__c(
            Liable_Party__c = wcaLiableParty.Id,
            Case_Issue__c = wcaCaseIssue.Id
        );
        insert wcaLpCi;
        
        Payment_Plan__c wcaPaymentPlan = new Payment_Plan__c(
            Case__c = wcaCase.Id
        );
        insert wcaPaymentPlan;
        
        Judgement__c wcaJudgment = new Judgement__c(
            Case_Management__c = wcaCase.Id,
            Type__c = 'ODA',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert wcaJudgment;
        
        Liability_Judgement__c wcaJudgmentParty = new Liability_Judgement__c(
            Judgement__c = wcaJudgment.Id,
            Liable_Party__c = wcaLiableParty.Id
        );
        insert wcaJudgmentParty;
        */
        Office_Account__c wcaOfficeAccount = new Office_Account__c(
            Name = '01-112',
            Office__c = wcaOffice.Id
        );
        insert wcaOfficeAccount;
        
        Transaction__c wcaTrn = new Transaction__c(
            Office_Account__c = wcaOfficeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-8),
            Business_Unit__c = 'WCA',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 44.44,
            Check_Count__c = 1,
            Checks_Amount__c = 44.44,
            Treasury_Deposit_Number__c = '🥓🥩🌈'
        );
        insert wcaTrn;
        
        Receipt__c wcaRct = new Receipt__c(
            Payor__c = employer.Id,
            Deposit_Account__c = '01-112',
            Date_Received__c = Date.today().addDays(-15),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 44.44,
            Transaction__c = wcaTrn.Id,
            Instrument_Number__c = '🌮🍔🌮🍔💯',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'WCA 1',
            Senior_Deputy__c = manager.Id
        );
        insert wcaRct;

        Case_Payment__c wcaCp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = wcaCase.Id,
            Receipt__c = wcaRct.Id,
            Payment_Amount__c = 44.44,
            Status__c = 'New',
            Nightly_Rollup__c = false
        );
        insert wcaCp;
        
        Liability_Payment__c wcaLp = new Liability_Payment__c(
            Case_Payment__c = wcaCp.Id,
            Posted_Amount__c = 44.44,
            Payment_Applied_To__c = 'Wages',
            //Assessment__c = wcaAssessment.Id,
            //Liability__c = wcaLiability.Id,
            Case_Violation__c = wcaCaseIssue.Id
        );
        insert wcaLp;
        
        Warrant_Batch__c wcaWb = new Warrant_Batch__c(
            Status__c = 'Printed',
            Office_Account__c = wcaOfficeAccount.Id,
            Request_Date__c = Date.today().addDays(-12),
            Requested_By__c = deputy.Id,
            Requesting_Cashier__c = deputy.Id,
            Requesting_Cashier_Date__c = Date.today().addDays(-6),
            Requesting_Cashier_Attest__c = true,
            Reviewed_By__c = manager.Id
        );
        insert wcaWb;
        
        Warrant__c wcaWarrant1 = new Warrant__c(
            RecordTypeId = Schema.SObjectType.Warrant__c.getRecordTypeInfosByName().get('Warrant Approved').getRecordTypeId(),
            Warrant_Batch__c = wcaWb.Id,
            Amount__c = 22.21,
            Case__c = wcaCase.Id,
            Office_Account__c = wcaOfficeAccount.Id,
            Payee__c = wcaEmployeePayee.Id,
            Issue_Date__c = Date.today().addDays(-1),
            Mailed_Date__c = Date.today().addDays(-1),
            Status_Date__c = Date.today().addDays(-1),
            Status__c = 'Printed',
            Approved_By__c = manager.Id,
            Approved_Date__c = Date.today().addDays(-1),
            Approved_Warrant__c = true,
            Nightly_Rollup__c = false
        );
        insert wcaWarrant1;

        Warrant__c wcaWarrant2 = new Warrant__c(
            RecordTypeId = Schema.SObjectType.Warrant__c.getRecordTypeInfosByName().get('Warrant Approved').getRecordTypeId(),
            Warrant_Batch__c = wcaWb.Id,
            Amount__c = 22.23,
            Case__c = wcaCase.Id,
            Office_Account__c = wcaOfficeAccount.Id,
            Payee__c = wcaEmployeePayee.Id,
            Issue_Date__c = Date.today().addDays(-1),
            Mailed_Date__c = Date.today().addDays(-1),
            Status_Date__c = Date.today().addDays(-1),
            Status__c = 'Printed',
            Approved_By__c = manager.Id,
            Approved_Date__c = Date.today().addDays(-1),
            Approved_Warrant__c = true,
            Nightly_Rollup__c = false
        );
        insert wcaWarrant2;
        
        Payment_Record__c wcaPr1 = new Payment_Record__c(
            Liability_Payment__c = wcaLp.Id,
            Payment_Amount__c = 22.21,
            Payee__c = wcaEmployeePayee.Id,
            Warrant__c = wcaWarrant1.Id,
            Warrant_Issued__c = true
        );
        insert wcaPr1;
        
        Payment_Record__c wcaPr2 = new Payment_Record__c(
            Liability_Payment__c = wcaLp.Id,
            Payment_Amount__c = 22.23,
            Payee__c = wcaEmployeePayee.Id,
            Warrant__c = wcaWarrant2.Id,
            Warrant_Issued__c = true
        );
        insert wcaPr2;
        
        /* List<Id> wcaPrIds = new List<Id>();
        wcaPrIds.add(wcaPr1.Id);
        wcaPrIds.Add(wcaPr2.Id); */
        
    }

    @isTest
    public static void testCashNightlyRollup(){

        Test.startTest();

        Database.executeBatch(new CashNightlyRollup(), 2);

        Test.stopTest();
        
        DIR_Case__c dirCase = [SELECT Id, Name, Funds_Drawn_on_Deposits__c, Deposited_Funds__c FROM DIR_Case__c][0];
        Case_Payment__c cp = [SELECT Id, Name, Payment_Amount__c, Nightly_Rollup__c FROM Case_Payment__c][0];
        List<Warrant__c> warrantList = [SELECT Id, Name, Amount__c, Nightly_Rollup__c FROM Warrant__c];

        System.assertEquals(cp.Payment_Amount__c, dirCase.Deposited_Funds__c, 'Deposited Funds not equal');
        System.assert(cp.Nightly_Rollup__c, 'cp.Nightly_Rollup__c not set to TRUE');
        
        Decimal sumOfWarrants = 0.00;
        Boolean warrNightlyRollupsSet = true;
        for(Warrant__c warr : warrantList){
            sumOfWarrants += warr.Amount__c;
            warrNightlyRollupsSet = warrNightlyRollupsSet && warr.Nightly_Rollup__c;
        }
        System.assertEquals(sumOfWarrants, dirCase.Funds_Drawn_on_Deposits__c, 'Funds Drawn on Deposits not equal');
        System.assert(warrNightlyRollupsSet, 'Both warr.Nightly_Rollup__c not set to TRUE');


    }
}