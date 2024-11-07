@istest
public class account_MethodsTest {

    public static testMethod void testUpdateIndustrySelection(){
        
        NAICS_Code__c other = new NAICS_Code__c();
        other.Name = '2';
        other.NAICS_Title__c = 'other';
        other.Level__c = 'Level 1';
        insert other;
        
        NAICS_Code__c level1 = new NAICS_Code__c();
        level1.Name = '11';
        level1.NAICS_Title__c = 'TEST1';
        level1.Level__c = 'Level 1';
        insert level1;
        
        NAICS_Code__c level2 = new NAICS_Code__c();
        level2.Name = '111';
        level2.NAICS_Title__c = 'TEST2';
        level2.Level__c = 'Level 2';
        level2.Supersector__c = level1.Id;
        insert level2;
        
        NAICS_Code__c level3 = new NAICS_Code__c();
        level3.Name = '1111';
        level3.NAICS_Title__c = 'TEST3';
        level3.Level__c = 'Level 3';
        level3.Supersector__c = level2.Id;
        insert level3;
        
        NAICS_Code__c level4 = new NAICS_Code__c();
        level4.Name = '11111';
        level4.NAICS_Title__c = 'TEST4';
        level4.Level__c = 'Level 4';
        level4.Supersector__c = level3.Id;
        insert level4;
        
        NAICS_Code__c level5 = new NAICS_Code__c();
        level5.Name = '111111';
        level5.NAICS_Title__c = 'TEST5';
        level5.Level__c = 'Level 5';
        level5.Supersector__c = level4.Id;
        insert level5;
        
        BOFE_Low_Wage_Industry__c Industry = new BOFE_Low_Wage_Industry__c();
        Industry.name = '111111';
        Industry.Industry__c = 'retail';
        Industry.active__c = true;
        insert Industry;
        
        BOFE_Low_Wage_Industry__c Industry1 = new BOFE_Low_Wage_Industry__c();
        Industry1.name = '11111';
        Industry1.Industry__c = 'Construction';
        Industry1.active__c = true;
        insert Industry1;
        
        BOFE_Low_Wage_Industry__c Industry2 = new BOFE_Low_Wage_Industry__c();
        Industry2.name = '1111';
        Industry2.Industry__c = 'Garment';
        Industry2.active__c = true;
        insert Industry2;
        
        BOFE_Low_Wage_Industry__c Industry3 = new BOFE_Low_Wage_Industry__c();
        Industry3.name = '111';
        Industry3.Industry__c = 'Warehouse';
        Industry3.active__c = true;
        insert Industry3;
        
        BOFE_Low_Wage_Industry__c Industry4 = new BOFE_Low_Wage_Industry__c();
        Industry4.name = '11';
        Industry4.Industry__c = 'Janitorial';
        Industry4.active__c = true;
        insert Industry4;
        
        Account a = new Account();
        a.Name = 'Lucian395274';
        a.Text_Message_Opt_Out__c = true;
        a.Cell_Phone__c = '2345678901';
        insert a;
        
        test.startTest();
        a.Naics_code__c = level5.id;
        update a;
        //system.assert(a.Low_wage_Industry_Selection__c == 'retail');
        
        a.NAICS_Code__c = level4.Id;
        update a;
        //system.assert(a.Low_wage_Industry_Selection__c == 'Construction');
        
        a.NAICS_Code__c = level3.Id;
        update a;
        //system.assert(a.Low_wage_Industry_Selection__c == 'Garment');
        
        a.NAICS_Code__c = level2.Id;
        update a;
        //system.assert(a.Low_wage_Industry_Selection__c == 'Warehouse');
        
        a.NAICS_Code__c = level1.Id;
        update a;
        //system.assert(a.Low_wage_Industry_Selection__c == 'Janitorial');
        
        a.NAICS_Code__c = other.Id;
        update a;
        //system.assert(a.Low_wage_Industry_Selection__c == 'Other');
        test.stopTest();
    }
    
    @isTest static void testAddPrimaryAddress(){
        
        Account a1 = new Account(
            Name = 'test acct'
        );
        insert a1;
        
        List<Address__c> locations1 = new List<Address__c>([
            SELECT Id, City__c, State__c, Zip_Code__c FROM Address__c WHERE entity__c =: a1.Id
        ]);
        
        system.assertEquals(0, locations1.size());
        
        Account a2 = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert a2;
        
        List<Address__c> locations2 = new List<Address__c>([
            SELECT Id, City__c, State__c, Zip_Code__c FROM Address__c WHERE entity__c =: a2.Id
        ]);
        
        system.assertEquals(1, locations2.size());
        
        Address__c loc = locations2[0];
        
        system.assertEquals(a2.ShippingCity, loc.City__c);
        
        system.assertEquals(a2.ShippingState, loc.State__c);
        
        system.assertEquals(a2.ShippingPostalCode, loc.Zip_Code__c);
        Account acc1 = new Account(RecordTypeId =  Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID(), lastName = 'test',FirstName = 'test',
                            PersonMailingCity = 'test',PersonMailingState = 'test',PersonMailingPostalCode = 'test',
                            PersonMailingStreet = 'test');
        Account acc2 = new Account(RecordTypeId =  Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID(), lastName = 'test',FirstName = 'test',
                            PersonMailingCity = 'test',PersonMailingState = 'test',PersonMailingPostalCode = 'test',
                            shippingCity = 'test',shippingState = 'test',shippingPostalCode = 'test',shippingStreet = 'test');
        insert new List<Account>{acc1,acc2};
                            
        test.startTest();
        a2.ShippingCity = 'dallas';
        update a2;
        test.stopTest();
    }
    
    @isTest static void testcreateConsent() {
        
        Account personAcc = new Account(
            firstName = 'claimant',
            lastName = 'acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            Text_Message_Opt_Out__c = true,
            PersonMobilePhone = '8377922023',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        Account businessAcc = new Account(
            Name = 'dlse acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            Text_Message_Opt_Out__c = true,
            Cell_Phone__c = '8377922022',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId()
        );
        
        test.startTest();
        insert new List<Account>{personAcc,businessAcc};
            personAcc.Text_Message_Opt_Out__c = false;
        businessAcc.Text_Message_Opt_Out__c = false;
        update new List<Account>{personAcc,businessAcc};
            
            Account duplicatePersonAcc = new Account(
                firstName = 'claimant',
                lastName = 'acct 123',
                ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
                ShippingCity = 'Denver',
                ShippingState = 'CO',
                ShippingPostalCode = '80212',
                Text_Message_Opt_Out__c = false,
                PersonMobilePhone = '8377922023',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
            );
        Account duplicateBusinessAcc = new Account(
            Name = 'dlse acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            Text_Message_Opt_Out__c = false,
            Cell_Phone__c = '8377922022',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId()
        );
        List<Account> accountList =  new List<Account>{duplicatePersonAcc,duplicateBusinessAcc};
            Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        List<Database.SaveResult> sr = Database.insert(accountList, dml);
        test.stopTest();
        
    }
}