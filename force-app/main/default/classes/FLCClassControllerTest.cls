@isTest
public class FLCClassControllerTest {
    
    public static testMethod void testFLCClass(){
        
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
        
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Farm Labor Contractor').getRecordTypeId();
        
        License_Registration__c lReg1 = new License_Registration__c ();
        lReg1.Account__c = acc.Id;
        lReg1.RecordTypeId = RecordTypeId;
        lReg1.License_Registration_Number__c = acc.Id;
        lReg1.License_Registration_Type__c = '3333';
        lReg1.Submitted_Date__c = Date.today() - 3;
        lReg1.Mailing_City__c = 'Denver';
        lReg1.Applicant__c = communityUser[0].ContactId;
        insert lReg1;
        
        Ownership__c owners = new Ownership__c();
        owners.First_Name__c = 'test owner';
        owners.Registration__c = lReg1.Id;
        /// Added below in RSS sprint 5 to adjust for new validation rule: Required_fields_on_FLC_owner_records.
        owners.Email__c = 'aaaaa@aaaaaa.aaa';
        owners.Last_Name__c = 'aaaaaa';
        Date startDate = Date.newInstance(2008, 1, 1);
        owners.Ownership_Percentage__c = 100;
        owners.Date_of_Birth__c = startDate;
        owners.SSN__c = '123456789';
        owners.Live_Scan_Operator_Name__c = 'OperatorName';
        owners.ATI_Number__c = '123456789';
        owners.LSID_Number__c = '12345678';
        owners.Date_Completed__c = startDate;
        owners.Street__c = '6401 Sunflower Ct';
        owners.City__c = 'Oakland';
        owners.Residential_Zip_Code__c = '90012';
        owners.Mailing_Address_Same_as_Residential__c = true;        
        insert owners;
        
        PageReference myVfPage = Page.FLCClass;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',owners.Id);
        

        FLCClassController FLCClass = new FLCClassController();
        
        //FLCCLass.Course_Name = 'test class';
        FLCCLass.Hours_Completed = '9';
        FLCCLass.Language = 'English';
        FLCCLass.Other_Language = 'Spanish';
        FLCCLass.Notes = 'my notes';
        FLCCLass.Completion_Date = Date.today();
        
        test.startTest();
        FLCClass.LinkClass();
        FLCClass.getLanguageList();
        
        test.stopTest();
        
    }
}