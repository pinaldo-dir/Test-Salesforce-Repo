@istest (SeeAllData=true)
public class CommunityRegistrationTest {

    public static testMethod void testCommunityRegistration(){
        
        
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
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        Id personRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Partnership').getRecordTypeId();
        Id indivRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        Id publicWorksRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        Id cPSRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Child Performer Services').getRecordTypeId();

        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = communityUser[0].Contact.AccountId;
        newLR.RecordTypeId = RecordTypeId;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Car Wash';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = communityUser[0].ContactId;
        newLR.Submission_Type__c = 'Paper';
        //newLR.VIP_Template_Status__c = 'Incomplete';
        
        insert newLR;
        system.debug('##### newLR: ' + newLR);
 
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = personRecordTypeId;
        racc1.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc1.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Legal_Entity_Name__c = 'Legal Entity Name';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Registration__c = newLR.Id;
        insert racc1;
        System.debug('##### RA1: ' + racc1);
        
        DBA__c rdba1 = new DBA__c();
        rdba1.Registration__c = newLR.Id;
        rdba1.Name ='DBA Name';
        rdba1.Active__c = 'Yes';
        insert rdba1;
        
        DBA__c rdba2 = new DBA__c();
        rdba2.Registration__c = newLR.Id;
        rdba2.Name ='DBA Inactive';
        rdba2.Active__c = 'No';
        insert rdba2;
 
        Ownership__c nown = new Ownership__c();
        nown.Email__c = 'aaaaa@aaaaaa.aaa';
        nown.First_Name__c = 'aaaaa';
        nown.Last_Name__c = 'aaaaaa';
        nown.Registration__c = newLR.Id; 
        nown.Imported_From__c = 'xyz';
        /// Added below in RSS sprint 5 to adjust for new validation rule: Required_fields_on_FLC_owner_records.
        Date startDate = Date.newInstance(2008, 1, 1);
        nown.Ownership_Percentage__c = 100;
        nown.Date_of_Birth__c = startDate;
        nown.SSN__c = '123456789';
        nown.Live_Scan_Operator_Name__c = 'OperatorName';
        nown.ATI_Number__c = '123456789';
        nown.LSID_Number__c = '12345678';
        nown.Date_Completed__c = startDate;
        nown.Street__c = '6401 Sunflower Ct';
        nown.City__c = 'Oakland';
        nown.Residential_Zip_Code__c = '90012';
        nown.Mailing_Address_Same_as_Residential__c = true;
        insert nown;
        
        Ownership_Occupation__c ownOcc = new Ownership_Occupation__c();
        ownOcc.Ownership__c = nown.Id;
        ownOcc.Physical_Address_Line_1__c = '123 state st';
        ownOcc.Physical_Address_Line_2__c = 'Unit A';
        ownOcc.Physical_City_Province__c = 'Oakland';
        ownOcc.Physical_Postal_Code__c = '94512';
        ownOcc.Physical_State__c = 'CA';
        insert ownOcc;
        
        Registration_Course__c courseOwn = new Registration_Course__c();
        courseOwn.Ownership__c = nown.Id;
        courseOwn.Training_Organization__c = 'ABC Training Institute';
        courseOwn.Hours_Completed__c = '9';
        courseOwn.Completion_Date__c = Date.today();
        courseOwn.Language__c = 'English';
        insert courseOwn;
        
        Registration_Exam__c examOwn = new Registration_Exam__c();
        examOwn.Ownership__c = nown.Id;
        examOwn.Exam_Passed_Date__c = Date.today();
        examOwn.Exam_Version__c = '1';
        examOwn.Exam_Name__c = 'FLC Exam';
        insert examOwn;
        
       
        Registration_Location__c rloc = new Registration_Location__c();
        rloc.Address__c = 'address';
        rloc.City__c = 'San Francisco';
        rloc.DBA_Name__c = 'DBA Name';
        rloc.FBNS__c = 'FBNS';
        rloc.Foreign_Address__c = 'Foreign Address';
        rloc.Mobile_Business__c = true;
        rloc.Phone__c = '4445553434';
        rloc.Registration__c = newLR.Id;
        rloc.Account__c = communityUser[0].Contact.AccountId;
        rloc.Zip_Code__c = '12343';
        rloc.Business_Regulatory_Compliance__c = 'No';
//        insert rloc;
        system.debug('##### rloc: ' + rloc);
 
        system.runAs(communityUser[0]) {
            test.startTest();
                Test.setCurrentPageReference(new PageReference('Page.CommunityRegistration')); 
                System.currentPageReference().getParameters().put('renewId', newLR.Id);
                System.currentPageReference().getParameters().put('recId', newLR.Id);
                System.currentPageReference().getParameters().put('printId', newLR.Id);

                CommunityRegistration CR = new CommunityRegistration();
                CR.currentRecordType = RecordTypeId;
                CR.getAllRegistrations();
                CR.getRegistrationRecordTypes();
                CR.LinkRegistration();
                CR.AddRegistration();
                CR.SubmitPayment();
                CR.RenewRegistration();
                CR.closePopup();
                CR.PrintApplication();
                CR.CheckActiveRegistration();
                
            
            test.stopTest();
        }
    }
    
    public static testMethod void testCommunityRegistrationPWC(){
        
        
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
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        Id personRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Partnership').getRecordTypeId();
        Id indivRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        Id publicWorksRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        Id cPSRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Child Performer Services').getRecordTypeId();


        License_Registration__c  newLR2 = new License_Registration__c();
        newLR2.Account__c = communityUser[0].Contact.AccountId;
        newLR2.RecordTypeId = publicWorksRecordTypeId;
        newLR2.License_Registration_Number__c = '222';
        newLR2.License_Registration_Type__c = 'Public Works';
        newLR2.Status__c = 'Active'; 
        newLR2.Expiration_Date__c = Date.today() - 365; 
        newLR2.Amount_Paid__c = 100; 
        newLR2.Applicant__c = communityUser[0].ContactId;
        newLR2.License_Registration_Type__c = 'Public Works';
        insert newLR2;
        system.debug('##### newLR2: ' + newLR2); 
        System.assertEquals(newLR2.displayRenewalButton__c, False);
 
        Access_Approval__c aa = new Access_Approval__c();
        aa.Approved__c = 'Yes';
        aa.Requestor__c =  communityUser[0].Contact.Id;
        aa.Registration__c = newLR2.Id;
        
        insert aa;
        
        system.runAs(communityUser[0]) {
            test.startTest();
                Test.setCurrentPageReference(new PageReference('Page.CommunityRegistration')); 
                System.currentPageReference().getParameters().put('renewId', newLR2.Id);
                System.currentPageReference().getParameters().put('recId', newLR2.Id);
                System.currentPageReference().getParameters().put('printId', newLR2.Id);

                CommunityRegistration CR = new CommunityRegistration();
                CR.currentRecordType = RecordTypeId;
                CR.getAllRegistrations();
                CR.getRegistrationRecordTypes();
                CR.LinkRegistration();
                CR.AddRegistration();
                CR.SubmitPayment();
                CR.RenewRegistration();
                CR.closePopup();
                CR.PrintApplication();
                CR.CheckActiveRegistration();
            

            test.stopTest();
        }
    }  

        public static testMethod void testCommunityRegistrationCPS(){
        
        
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
        
        //Id EWPRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        //Id iPRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        //Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        //Id publicWorksRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        Id cPSRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Child Performer Services').getRecordTypeId();
        
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = communityUser[0].Contact.AccountId;
        newLR.RecordTypeId = cPSRecordTypeId;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Child Performer Services';
        newLR.Status__c = 'Incomplete'; 

        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = communityUser[0].ContactId;
        //newLR.Registration_Duration__c = '6 Months - Permit';
        //newLR.VIP_Template_Status__c = 'Incomplete';
        newLR.Submission_Type__c = 'Paper';
        
        newLR.Residential_Address_Line_1__c = 'Street';
        newLR.Residential_City__c = 'SF';
        newLR.Residential_State__c = 'CA';
        newLR.Residential_Postal_Code__c = '12345';
        
        newLR.Mailing_Address_Line_1__c = 'Street';
        newLR.Mailing_City__c = 'SF';
        newLR.Mailing_State__c = 'CA';
        newLR.Mailing_Postal_Code__c = '12345';
        
        newLR.Effective_Date__c = Date.Today();
        newLR.Expiration_Date__c = Date.Today() + 180;
        
        insert newLR;
        system.debug('##### newLR: ' + newLR);
        
        List<Live_Scan__c> newLiveScanList = new List<Live_Scan__c>();
        Live_Scan__c ls = new Live_Scan__c();
        ls.ATI_Number__c = 'asdf';
        ls.LSID_Number__c = '123';
        ls.Registration__c = newLR.Id;
        
        /*
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = iPRecordTypeId;
        racc1.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc1.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Legal_Entity_Name__c = 'Legal Entity Name';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Registration__c = newLR.Id;
        racc1.Birth_Date__c = Date.today() - 60;
        insert racc1;
        System.debug('##### RA1: ' + racc1);
  */
            test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.CommunityRegistration')); 
            System.currentPageReference().getParameters().put('renewId', newLR.Id);
            System.currentPageReference().getParameters().put('recId', newLR.Id);
            System.currentPageReference().getParameters().put('printId', newLR.Id);
            System.currentPageReference().getParameters().put('permitId', newLR.Id);
            System.currentPageReference().getParameters().put('rId', newLR.Id);
            
            CommunityRegistration CR = new CommunityRegistration();
            CR.currentRecordType = cPSRecordTypeId;
            CR.getAllRegistrations();
            CR.getRegistrationRecordTypes();
            CR.LinkRegistration();
            CR.AddRegistration();
            CR.SubmitPayment();
            CR.RenewRegistration();
            CR.closePopup();
            CR.PrintApplication();
            CR.CheckActiveRegistration();
            CR.sendLicenseRegistrationPermitPDF();
            
        test.stopTest();
        }
    
    public static testMethod void testCommunityRegistrationEWP(){
        
        
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
        
        Id EWPRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        //Id iPRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        //Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        //Id publicWorksRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        //Id cPSRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Child Performer Services').getRecordTypeId();
        
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = communityUser[0].Contact.AccountId;
        newLR.RecordTypeId = EWPRecordTypeId;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Entertainment Work';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = communityUser[0].ContactId;
        newLR.Registration_Duration__c = '6 Months - Permit';
        //newLR.VIP_Template_Status__c = 'Incomplete';
        newLR.Submission_Type__c = 'Paper';
        
        newLR.Residential_Address_Line_1__c = 'Street';
        newLR.Residential_City__c = 'SF';
        newLR.Residential_State__c = 'CA';
        newLR.Residential_Postal_Code__c = '12345';
        
        newLR.Mailing_Address_Line_1__c = 'Street';
        newLR.Mailing_City__c = 'SF';
        newLR.Mailing_State__c = 'CA';
        newLR.Mailing_Postal_Code__c = '12345';
        
        newLR.Effective_Date__c = Date.Today();
        newLR.Expiration_Date__c = Date.Today() + 180;
        
        insert newLR;
        system.debug('##### newLR: ' + newLR);
        
        List<Live_Scan__c> newLiveScanList = new List<Live_Scan__c>();
        Live_Scan__c ls = new Live_Scan__c();
        ls.ATI_Number__c = 'asdf';
        ls.LSID_Number__c = '123';
        ls.Registration__c = newLR.Id;
        
        /*
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = iPRecordTypeId;
        racc1.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc1.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Legal_Entity_Name__c = 'Legal Entity Name';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Registration__c = newLR.Id;
        racc1.Birth_Date__c = Date.today() - 60;
        insert racc1;
        System.debug('##### RA1: ' + racc1);
  */
            test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.CommunityRegistration')); 
            System.currentPageReference().getParameters().put('renewId', newLR.Id);
            System.currentPageReference().getParameters().put('recId', newLR.Id);
            System.currentPageReference().getParameters().put('printId', newLR.Id);
            
            CommunityRegistration CR = new CommunityRegistration();
            CR.currentRecordType = EWPRecordTypeId;
            CR.getAllRegistrations();
            CR.getRegistrationRecordTypes();
            CR.LinkRegistration();
            CR.AddRegistration();
            CR.SubmitPayment();
            CR.RenewRegistration();
            CR.closePopup();
            CR.PrintApplication();
            CR.CheckActiveRegistration();
            
        test.stopTest();
        }
    //}
}