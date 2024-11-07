@isTest
public with sharing class CashCustomLookupControllerTest {
    public CashCustomLookupControllerTest() {
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

        Account otherLiableAccount = new Account(
            RecordTypeId = businessAccountId,
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

        Account statePayeeAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'DIR Accounting',
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
        insert accounts;


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
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert bofeCase;

        

    }


    @isTest
    static void testCashCustomLookupController(){

        DIR_Case__c bofeCase = [SELECT Id, Name, LastViewedDate FROM DIR_Case__c LIMIT 1];
        System.debug('160 bofeCase: ' + bofeCase);
        CashCustomLookupController.searchCases(bofeCase.Name, new List<String>());

        Account otherLiableAccount = [SELECT Id, Name, LastViewedDate FROM Account WHERE Name = 'Wholly Owned Offshore Shell Corp'];
        System.debug('164 otherLiableAccount: ' + otherLiableAccount);
        CashCustomLookupController.searchAccounts(otherLiableAccount.Name, new List<String>());

        CashCustomLookupController.getRecentlyViewedCases();
        CashCustomLookupController.getRecentlyViewedAccounts();

    }
}