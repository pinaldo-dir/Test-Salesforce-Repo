/*************************************************************************************************
TransactionAccountingDepositTest - tests TransactionTrigger, TransactionMethods, AccountingDepositBatch, and CalculateBusinessDays classes,
    and ReceiptTrigger to some extent (76%).
*************************************************************************************************/

@isTest
public class TransactionAccountingDepositTest{
    
    @isTest
    public static void testAccountingDepositBatch(){
        
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
        
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
        
        Office__c wcaOffice = new Office__c(
            Name = 'Bakersfield WCA',
            Office_Number__c = 'WCA 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert wcaOffice;
        
        Office_Account__c wcaOfficeAccount = new Office_Account__c(
            Name = '01-112',
            Office__c = wcaOffice.Id
        );
        insert wcaOfficeAccount;
        
        Account employer = new Account(
            Name = 'Employer',
            ShippingPostalCode = '92345'
        );
        insert employer;
        
        Transaction__c wcaTrn = new Transaction__c(
            RecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('TRN Pending').getRecordTypeId(),
            Office_Account__c = wcaOfficeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-8),
            Business_Unit__c = 'WCA',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Pending',
            Transaction_Sum__c = 44.44,
            Treasury_Deposit_Number__c = NULL,
            Check_Count__c = NULL,
            Checks_Amount__c = NULL,
            Balances_Set__c = FALSE,
            Account_Balance_Before_Transaction__c = NULL,
            Account_Balance_After_Transaction__c = NULL
        );
        insert wcaTrn;

        Receipt__c wcaRct = new Receipt__c(
            Payor__c = employer.Id,
            Deposit_Account__c = '01-112',
            Date_Received__c = Date.today().addDays(-15),
            Status__c = 'Deposit Pending',
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


        Test.startTest();

        wcaTrn.Check_Count__c = 1;
        wcaTrn.Checks_Amount__c = 44.44;
        wcaTrn.Treasury_Deposit_Number__c = '🥓🥩🌈';
        update wcaTrn;
        
        Test.stopTest();
        
        Transaction__c updatedTRN = [SELECT Id, Transaction_Status__c, Balances_Set__c FROM Transaction__c WHERE Id = :wcaTrn.Id];
        Receipt__c updatedRCT = [SELECT Id, Status__c FROM Receipt__c WHERE Id = :wcaRct.Id];

        System.assertEquals('Deposited', updatedRCT.Status__c, 'RCT.Status fail');
        System.assertEquals('Deposited', updatedTRN.Transaction_Status__c, 'TRN.Status fail');
        System.assertEquals(TRUE, updatedTRN.Balances_Set__c, 'TRN.Balances_Set__c fail');        
    }
}