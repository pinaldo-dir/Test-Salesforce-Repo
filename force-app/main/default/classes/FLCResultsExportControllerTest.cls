@istest (SeeAllData=true)
public class FLCResultsExportControllerTest {
    
    public static testMethod void testRegistrationResultsExportController(){
        
        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        account a = new Account(
            RecordTypeID=personAccountRTId,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
        );
        insert a;
        
        system.debug('##### A: ' + a);
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        
        User u = new User(contactId = acc.PersonContactId, Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p, isActive = true,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        insert u;
        system.debug('##### u: ' + u);
        
        List<User> communityUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE ProfileId =: p AND isActive = true LIMIT 1];
        system.debug('##### CommunityUser: ' + communityUser);
        
        Id fLCRecordType = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Farm Labor Contractor').getRecordTypeId();
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = communityUser[0].Contact.AccountId;
        newLR.RecordTypeId = fLCRecordType;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Farm Labor Contractor';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() - 365; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = communityUser[0].ContactId;
        newLR.License_Registration_Type__c = 'Farm Labor Contractor';
        newLR.License_Registration_Number__c = '1234';
        newLR.Physical_Business_Address_Line_1__c = '1234';
        newLR.Physical_Business_Address_Line_2__c = '';
        newLR.Physical_Business_City__c = 'oakland';
        newLR.Physical_Business_State__c = 'CA';
        newLR.Physical_Business_Postal_Code__c = '12345';
        newLR.Effective_Date__c = System.today();
        newLR.Expiration_Date__c =  System.today() + 30;
        insert newLR;
        
        Ownership__c owner = new Ownership__c();
        owner.First_Name__c = 'firstname';
        owner.Last_Name__c = 'lastname';
        owner.Middle_Name__c = 'mn';
        owner.Request_FLC_Card__c = TRUE;
        owner.Registration__c = newLR.Id;
        /// Added below in RSS sprint 5 to adjust for new validation rule: Required_fields_on_FLC_owner_records.
        owner.Email__c = 'aaaaa@aaaaaa.aaab.com';
        Date Date1 = Date.newInstance(2008, 1, 1);
        owner.Ownership_Percentage__c = 50;
        owner.Date_of_Birth__c = Date1;
        owner.SSN__c = '123456789';
        owner.Live_Scan_Operator_Name__c = 'OperatorName';
        owner.ATI_Number__c = '123456789';
        owner.LSID_Number__c = '12345678';
        owner.Date_Completed__c = Date1;
        owner.Street__c = '6401 Sunflower Ct';
        owner.City__c = 'Oakland';
        owner.Residential_Zip_Code__c = '90012';
        owner.Mailing_Address_Same_as_Residential__c = true;
        insert owner;
        
        Ownership__c owner2 = new Ownership__c();
        owner2.First_Name__c = 'firstname2';
        owner2.Last_Name__c = 'lastname2';
        owner2.Middle_Name__c = 'mn2';
        owner2.Request_FLC_Card__c = TRUE;
        owner2.Registration__c = newLR.Id;
        /// Added below in RSS sprint 5 to adjust for new validation rule: Required_fields_on_FLC_owner_records.
        owner2.Email__c = 'aaaaa@aaaaaa.aaa.com';
        Date Date2 = Date.newInstance(2008, 1, 1);
        owner2.Ownership_Percentage__c = 50;
        owner2.Date_of_Birth__c = Date2;
        owner2.SSN__c = '987654321';
        owner2.Live_Scan_Operator_Name__c = 'OperatorName';
        owner2.ATI_Number__c = '123456789';
        owner2.LSID_Number__c = '12345678';
        owner2.Date_Completed__c = Date2;
        owner2.Street__c = '6401 Sunflower Ct';
        owner2.City__c = 'Oakland';
        owner2.Residential_Zip_Code__c = '90012';
        owner2.Mailing_Address_Same_as_Residential__c = true;
        insert owner2;
        
        DBA__c dba = new DBA__c();
        dba.Active__c = 'Yes';
        dba.Name = 'mydbaname';
        dba.Registration__c = newLR.Id;
        insert dba;
        
        DBA__c dba2 = new DBA__c();
        dba2.Active__c = 'Yes';
        dba2.Name = 'mydbaname2';
        dba2.Registration__c = newLR.Id;
        insert dba2;
        
        Bond__c bond = new Bond__c();
        bond.Bond_Amount__c = 12;
        bond.Bond_Status__c = 'Active';
        bond.Bond_Type__c = 'Money Order';
        bond.Registration__c = newLR.Id;
        insert bond;
        
        Apexpages.currentpage().getparameters().put('myList',newLR.id);
        FLCResultsExportController reg =  new FLCResultsExportController();
    }
}