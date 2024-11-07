/*************************************************************************************************
Class     :  ReturnedVoidedReceiptTest.cls
Created   :  June 11, 2019
Modified  :  May 2022 - Cashiering Enhancement Project, Phase 2
Objective :  Obvious test class is obvious.

*************************************************************************************************/

@isTest
public class ReturnedVoidedReceiptTest {
    
    @isTest
    public static void testReturnedReceipt(){
        User adminUser = [SELECT Id
                            FROM User
                            WHERE Profile.Name = 'System Administrator'
                            AND IsActive = true LIMIT 1 ];
        
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

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'DIR_EmployeeTrigger',
            Is_Active__c = false
        ));
        insert triggerSettings;
        
        Receipt__c rct = new Receipt__c(
            Payment_Type__c = 'Check',
            Instrument_Number__c = 'asf',
            Date_Received__c = Date.today(),
            Bank_Location__c = 'CA Bank',
            Deposit_Account__c = '04-116',
            Gross_Amount__c = 20,
            Payment_Amount__c = 12,
            Payment_Can_Be_Processed__c = true,
            Office_Unit__c = 'CCU 32',
            Status__c = 'Deposited',
            Payment_Exchange__c = 'Division Payment'
        );
        insert rct;
        
        Receipt__c rct_d = new Receipt__c(
            Payment_Type__c = 'Deduction',
            Instrument_Number__c = 'Deduction for asf',
            Date_Received__c = Date.today(),
            Bank_Location__c = 'CA Bank',
            Deposit_Account__c = '04-116',
            Gross_Amount__c = 20,
            Deduction_Amount__c = 8,
            Payment_Can_Be_Processed__c = true,
            Office_Unit__c = 'CCU 32',
            Status__c = 'New',
            Payment_Exchange__c = 'Division Payment',
            Net_Receipt__c = rct.id
        );
        insert rct_d;
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            Name = 'Employer',
            ShippingPostalCode = '92345',
            Bankruptcy_Status_Date__c = Date.today()
        );
        accounts.add(employer);

        Account bankAccount = new Account(
            Name = 'Department of Industrial Relations',
            ShippingPostalCode = '98765'
        );
        accounts.add(bankAccount);
        insert accounts;
        
        DIR_Employee__c mgr = new DIR_Employee__c(
            Active__c = true,
            User__c = adminUser.Id
        );
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c(
            Active__c = true,
            User__c = adminUser.Id,
            Manager__c = mgr.Id
        );
        insert de;

        DIR_Case__c cm = new DIR_Case__c(
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Employer__c = employer.Id,
            Assigned_Deputy__c = de.Id
        );
        insert cm;
        
        Case_Payment__c cp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Payment_Amount__c = rct.Payment_Amount__c,
            Case__c = cm.Id,
            Receipt__c = rct.Id,
            Status__c = 'Posted'
        );
        insert cp;

        Liability_Payment__c lp = new Liability_Payment__c(
            Case_Payment__c = cp.Id,
            Posted_Amount__c = cp.Payment_Amount__c * 0.75,
            Status__c = 'Posted'
        );
        insert lp;
        
        Judgement__c jmt = new Judgement__c(
            Case_Management__c = cm.Id,
            Type__c = 'ODA',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
        );
        insert jmt;
        
        Judgment_Payment__c jp = new Judgment_Payment__c(
            Case_Payment__c = cp.Id,
            Posted_Amount__c = cp.Payment_Amount__c * 0.25,
            Judgment__c = jmt.Id,
            Status__c = 'Posted'
        );
        insert jp;
        
        Accounting_Code__c ac = new Accounting_Code__c(
            Fund__c = '123.23',
            Program__c = 'BOFE',
            Payment_Type__c = 'Penalty',
            Industry__c = 'Car Wash',
            Active__c = true
        );
        insert ac; 
        
        Applied_Accounting_Code__c aeac = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp.Id, 
            Amount__c  = 555.55, 
            Accounting_Code__c = ac.Id, 
            Added_Manually__c = false
        );
        insert aeac; 
        
        /* TODO: not needed at this time, but if more coverage needed, we can incorporate testing PR handling:
        Account payeeAccount1 = new Account(
            Name = 'payee1',
            ShippingPostalCode = '90001'
        );
        insert payeeAccount1;

        Account payeeAccount2 = new Account(
            Name = 'payee2',
            ShippingPostalCode = '90002'
        );
        insert payeeAccount2;
        
        Case_Role__c caseRole1 = new Case_Role__c(
            Case__c = cm.Id,
            Entity__c = payeeAccount1.Id,
            Case_Role_Status__c = 'Active'
        );
        insert caseRole1;
        
        Case_Role__c caseRole2 = new Case_Role__c(
            Case__c = cm.Id,
            Entity__c = payeeAccount2.Id,
            Case_Role_Status__c = 'Active'
        );
        insert caseRole2;
        
        Payee__c payee1 = new Payee__c(
            Factor__c = 75,
            Payee_Type__c = 'Employee',
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole1.Id
        );
        insert payee1;
        
        Payee__c payee2 = new Payee__c(
            Factor__c = 25,
            Payee_Type__c = 'Employee',
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole2.Id
        );
        insert payee2;
        
        Payment_Record__c prlp = new Payment_Record__c(
            Liability_Payment__c = lp.Id,
            Payment_Amount__c = lp.Payment_Amount__c,
            Payee__c = payee1.Id
        );
        insert prlp;
        
        Payment_Record__c prjp = new Payment_Record__c(
            Judgment_Payment__c = jp.Id,
            Payment_Amount__c = jp.Posted_Amount__c,
            Payee__c = payee2.Id
        );
        insert prjp;
        */
        
        Test.startTest();
        rct.Returned_Item__c = true;
        rct.Returned_Reason__c = 'NSF';
        rct.Returned_Item_Received_By__c = 'DLSE';
        update rct;
        
        List<Id> rctIdList = new List<Id>();
        rctIdList.add(rct.Id);

        Test.stopTest();
        
        Receipt__c testRct = [SELECT Id, Name, Returned_Item__c
                                FROM Receipt__c
                                WHERE Id = :rct.Id];
        System.debug('testRct = '+testRct);
        
        Liability_Payment__c testNegatedLp = [SELECT Id, Name, Posted_Amount__c, Case_Payment__r.Status__c
                                                FROM Liability_Payment__c
                                                WHERE Returned_Voided_Liability_Payment__c = :lp.Id][0];
        
        System.assertEquals(testNegatedLp.Posted_Amount__c, -lp.Posted_Amount__c);
        
        Judgment_Payment__c testNegatedJP = [SELECT Id, Name, Posted_Amount__c, Case_Payment__r.Status__c
                                                FROM Judgment_Payment__c
                                                WHERE Returned_Voided_Judgment_Payment__c = :jp.Id][0];
        
        System.assertEquals(testNegatedJP.Posted_Amount__c, -jp.Posted_Amount__c);

    }
    
    @isTest
    public static void testVoidedReceipt(){
        User adminUser = [SELECT Id
                            FROM User
                            WHERE Profile.Name = 'System Administrator'
                            AND IsActive = true LIMIT 1 ];

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

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'DIR_EmployeeTrigger',
            Is_Active__c = true
        ));
        insert triggerSettings;
                            
        Receipt__c rct = new Receipt__c(
            Payment_Type__c = 'Check',
            Instrument_Number__c = 'asf',
            Date_Received__c = Date.today(),
            Bank_Location__c = 'CA Bank',
            Deposit_Account__c = '04-116',
            Gross_Amount__c = 20,
            Payment_Amount__c = 12,
            Payment_Can_Be_Processed__c = true,
            Office_Unit__c = 'CCU 32',
            Status__c = 'Deposit Pending',
            Payment_Exchange__c = 'Division Payment'
        );
        insert rct;
        
        Receipt__c rct_d = new Receipt__c(
            Payment_Type__c = 'Deduction',
            Instrument_Number__c = 'Deduction for asf',
            Date_Received__c = Date.today(),
            Bank_Location__c = 'CA Bank',
            Deposit_Account__c = '04-116',
            Gross_Amount__c = 20,
            Deduction_Amount__c = 8,
            Payment_Can_Be_Processed__c = true,
            Office_Unit__c = 'CCU 32',
            Status__c = 'New',
            Payment_Exchange__c = 'Division Payment',
            Net_Receipt__c = rct.id
        );
        insert rct_d;
        
        Account employer = new Account(
            Name = 'Employer',
            ShippingPostalCode = '92345',
            Bankruptcy_Status_Date__c = Date.today()
        );
        insert employer;
        
        DIR_Employee__c mgr = new DIR_Employee__c(
            Active__c = true,
            User__c = adminUser.Id
        );
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c(
            Active__c = true,
            User__c = adminUser.Id,
            Manager__c = mgr.Id
        );
        insert de;

        DIR_Case__c cm = new DIR_Case__c(
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Employer__c = employer.Id,
            Assigned_Deputy__c = de.Id
        );
        insert cm;
        
        Case_Payment__c cp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Payment_Amount__c = rct.Payment_Amount__c,
            Case__c = cm.Id,
            Receipt__c = rct.Id,
            Status__c = 'Posted'
        );
        insert cp;

        Liability_Payment__c lp = new Liability_Payment__c(
            Case_Payment__c = cp.Id,
            Posted_Amount__c = cp.Payment_Amount__c * 0.75,
            Status__c = 'Posted'
        );
        insert lp;
        
        Judgement__c jmt = new Judgement__c(
            Case_Management__c = cm.Id,
            Type__c = 'ODA',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
        );
        insert jmt;
        
        Judgment_Payment__c jp = new Judgment_Payment__c(
            Case_Payment__c = cp.Id,
            Posted_Amount__c = cp.Payment_Amount__c * 0.25,
            Judgment__c = jmt.Id,
            Status__c = 'Posted'
        );
        insert jp;
        
        Accounting_Code__c ac = new Accounting_Code__c(
            Fund__c = '123.23',
            Program__c = 'BOFE',
            Payment_Type__c = 'Penalty',
            Industry__c = 'Car Wash',
            Active__c = true
        );
        insert ac; 
        
        Applied_Accounting_Code__c aeac = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp.Id, 
            Amount__c  = 555.55, 
            Accounting_Code__c = ac.Id, 
            Added_Manually__c = false
        );
        insert aeac; 
        
        /* TODO: not needed at this time, but if more coverage needed, we can incorporate testing PR handling:
        Account payeeAccount1 = new Account(
            Name = 'payee1',
            ShippingPostalCode = '90001'
        );
        insert payeeAccount1;

        Account payeeAccount2 = new Account(
            Name = 'payee2',
            ShippingPostalCode = '90002'
        );
        insert payeeAccount2;
        
        Case_Role__c caseRole1 = new Case_Role__c(
            Case__c = cm.Id,
            Entity__c = payeeAccount1.Id,
            Case_Role_Status__c = 'Active'
        );
        insert caseRole1;
        
        Case_Role__c caseRole2 = new Case_Role__c(
            Case__c = cm.Id,
            Entity__c = payeeAccount2.Id,
            Case_Role_Status__c = 'Active'
        );
        insert caseRole2;
        
        Payee__c payee1 = new Payee__c(
            Factor__c = 75,
            Payee_Type__c = 'Employee',
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole1.Id
        );
        insert payee1;
        
        Payee__c payee2 = new Payee__c(
            Factor__c = 25,
            Payee_Type__c = 'Employee',
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole2.Id
        );
        insert payee2;
        
        Payment_Record__c prlp = new Payment_Record__c(
            Liability_Payment__c = lp.Id,
            Payment_Amount__c = lp.Payment_Amount__c,
            Payee__c = payee1.Id
        );
        insert prlp;
        
        Payment_Record__c prjp = new Payment_Record__c(
            Judgment_Payment__c = jp.Id,
            Payment_Amount__c = jp.Posted_Amount__c,
            Payee__c = payee2.Id
        );
        insert prjp;
        */
        
        
        Test.startTest();
        rct.Voided_Item__c = true;
        update rct;
        
        List<Id> rctIdList = new List<Id>();
        rctIdList.add(rct.Id);
        
        Test.stopTest();
        
        Receipt__c testRct = [SELECT Id, Name, Voided_Item__c
                                FROM Receipt__c
                                WHERE Id = :rct.Id];
        System.debug('testRct = '+testRct);
        
        Liability_Payment__c testNegatedLp = [SELECT Id, Name, Posted_Amount__c, Case_Payment__r.Status__c
                                                FROM Liability_Payment__c
                                                WHERE Returned_Voided_Liability_Payment__c = :lp.Id][0];
        
        System.assertEquals(testNegatedLp.Posted_Amount__c, -lp.Posted_Amount__c);
        
        Judgment_Payment__c testNegatedJp = [SELECT Id, Name, Posted_Amount__c, Case_Payment__r.Status__c
                                                FROM Judgment_Payment__c
                                                WHERE Returned_Voided_Judgment_Payment__c = :jp.Id][0];
        
        System.assertEquals(testNegatedJp.Posted_Amount__c, -jp.Posted_Amount__c);
 
    }
}