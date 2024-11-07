@isTest
public with sharing class inputLookupFieldControllerTest {
    
    @TestSetup
    static void makeData(){

        Account acc = new Account(
            Name = 'Tux The Penquin',
            ShippingStreet = '123 Sesame St'
        );
        insert acc;

        
    }

    @isTest
    static void testInputLookupFieldController(){

        Account acc = [SELECT Id, Name, ShippingStreet FROM Account][0];

        List<Account> lookupAccounts = inputLookupFieldController.getRecords(acc.Name, 'Account');

        Assert.areEqual(acc.Id, lookupAccounts[0].Id);
    }
}