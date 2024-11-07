@istest
public class LicenseRegistrationAllTest {
    //test approval and platform event to create accounts/locations
    public static testMethod void testApproved(){
        profile p = [SELECT ID from Profile Where name = 'WCA User' Limit 1];
        
        user u = new User();
        u.username = 'lralltestuser1@test.com';
        u.Email = 'lralltestusers@test.com';
        u.LastName = 'testuserlastname';
        u.ProfileId = p.Id;
        //u.UserRoleId = r.Id;
        u.EmailEncodingKey = 'ISO-8859-1';
        u.Alias = 'uName';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        insert u;
               
        
        UserRole rsRole = [select id from UserRole where DeveloperName = 'Registration_Services' limit 1];
        DIR_Employee__c deputy = new DIR_Employee__c();
        deputy.Active__c = true;
        deputy.Email__c = 'test@test.com';
        deputy.Position__c = 'Registration_Services';
        //deputy.User__c = [select id from User where UserRoleId = :rsRole.Id and isActive = true limit 1].id;
        //deputy.User__c = UserInfo.getUserId();
        deputy.User__c = u.Id;
        insert deputy;
        
      
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();

        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.License_Registration_Number__c = '00023568500';
        lreg.Status__c = 'Incomplete';
        lreg.Assigned_Deputy__c = deputy.Id;
        lreg.Legal_Entity_Name__c = 'name';
        insert lreg;
        System.debug('##################lreg:' + lreg.Name);
        
        License_Registration__c lreg2 = new License_Registration__c();
        lreg2.RecordTypeId = devRecordTypeId;
        lreg2.Account__c = acc.Id;
        lreg2.Applicant__c = con.Id;
        lreg2.License_Registration_Number__c = '00023568500';
        lreg2.Status__c = 'Incomplete';
        lreg2.Assigned_Deputy__c = deputy.Id;
        lreg2.Legal_Entity_Name__c = 'name';
        lreg2.Company_Type__c = 'Sole Proprietorship';
        insert lreg2;
        
        Id personRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Partnership').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
            
        
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
        racc1.Registration__c = lreg.Id;
        insert racc1;
        
        
        Registration_Account__c racc2 = new Registration_Account__c();
        racc2.RecordTypeId = businessRecordTypeId;
        racc2.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc2.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc2.First_Name__c = 'FirstName';
        racc2.Last_Name__c = 'LastName';
        racc2.Email_Address__c = 'test@asdadad.com';
        racc2.Legal_Entity_Name__c = 'Legal Entity Name';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_State__c = 'CA';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_Street__c = 'Street ';
        racc2.Mailing_Zip_Code__c = '54434';
        racc2.Business_Phone__c = '4445553434';
        racc2.Mobile_Phone__c = '5445445555';
        racc2.Registration__c = lreg.Id;
        insert racc2;
        
        Registration_Location__c rloc = new Registration_Location__c();
        rloc.Address__c = 'address';
        rloc.City__c = 'San Francisco';
        rloc.DBA_Name__c = 'DBA Name';
        rloc.FBNS__c = 'FBNS';
        rloc.Foreign_Address__c = 'Foreign Address';
        rloc.Mobile_Business__c = true;
        rloc.Phone__c = '4445553434';
        rloc.Registration__c = lreg.Id;
        rloc.Account__c = acc.Id;
        rloc.Zip_Code__c = '12343';
        rloc.Business_Regulatory_Compliance__c = 'No';
        insert rloc;
        
        Bond__c bond = new Bond__c();
        bond.Bond_Type__c = 'Registration/Surety Bond';
        bond.Bond_Amount__c = 2500;
        bond.Bond_Status__c = 'Active';
        bond.Name_of_Surety_Company__c = 'XYZ';
        bond.Effective_Date__c = date.today();
        bond.Registration__c = lreg.Id; 
        insert bond; 
        
        DBA__c dba = new DBA__c();
        dba.Name = 'Test DBA';
        dba.Active__c = 'Yes';
        dba.Registration__c = lreg.Id;
        insert dba;
        
        Ownership__c nown = new Ownership__c();
        nown.Email__c = 'aaaaa@aaaaaa.com';
        nown.First_Name__c = 'aaaaa';
        nown.Last_Name__c = 'aaaaaa';
        nown.Registration__c = lreg.Id; 
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
        //nown.Registration__c = lreg.Id;
        insert nown;

        Ownership__c ow = [SELECT Id,Registration__c FROM Ownership__c WHERE Registration__c=:lreg.Id];
        
        VIPForm__VIP_Template__c temp = new VIPForm__VIP_Template__c();
        temp.Name = 'Registration Services - Farm Labor';
        temp.VIPForm__Object_Record_Type__c = 'Farm Labor Contractors';
        //temp.VIPForm__Form_Style__c = 'Vertical Navigation';
        insert temp;
        
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'FLC Card Photo';
        section.Name = 'Photo Documents - FLC ';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 587;
        section.VIPForm__Template__c = temp.id;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
        //Attachment plus
        Attachments_Plus__c attPlus = new Attachments_Plus__c();
        //attPlus.Registration__c = ow.Id;
        attPlus.Attachment_Name__c = 'Owners Photo';
        attPlus.Type__c = 'Other Required Document';
        attPlus.Instructions__c = 'Owners Photo-aaaaa';
        attPlus.Registration__c = lreg.id;
        attPlus.Reg_Related_Rec_Id__c = ow.id;
        attPlus.VIP_Form_Section__c = section.id;
        insert attPlus;
        
        License_Registration__c lr = [SELECT Id, Status__c FROM License_Registration__c WHERE Id=:lreg.Id];
        List<Attachments_Plus__c> attToUPdate = [SELECT Id, Attachment_Name__c, Type__c, Instructions__c, Reg_Related_Rec_Id__c, Attachment_Required__c, VIP_Form_Section_Name_Display__c
                                                     FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =: ow.Id];
        //List<Attachments_Plus__c> attToUpdate = [SELECT Id,Registration__c,VIP_Form_Section_Name_Display__c FROM Attachments_Plus__c];
        
        lr.Status__c = 'Approved';
        lr.Effective_Date__c = date.today();
        lr.Expiration_Date__c = date.today()+365;
        test.startTest();
           update lr;
        dba.Name = 'Test DBA';
        	update dba;
        ow.First_Name__c = 'bbbbbb';
        ow.Last_Name__c = 'bbbbbb';
        	update ow;
            update attToUpdate;
        
        //System.runAs(u) {
        lr.Status__c = 'Incomplete';
        update lr;
        delete nown;
        delete rloc;
        delete racc1;
        delete dba;    
        delete bond;
       //}

        test.stopTest();
        
    }
    
    // Test Questions
    public static testMethod void testLicenseRegistrationQuestions(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        Question_Bank__c qb = new Question_Bank__c();
        qb.Answer_Type__c = 'YesNo'; 
        qb.Question_Text__c = 'Is this a test question?';
        insert qb;
        
        Question_Rule__c qr = new Question_Rule__c();
        qr.Active__c = true;
        qr.Question_ID__c = qb.Id;
        qr.Registration_Type__c = 'Car Wash';
        qr.Sort_Order__c = 1;
        insert qr;
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();

        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.License_Registration_Number__c = '00023568500';
        //lreg.Renewal__c = true;

        test.startTest();
           insert lreg; 
        test.stopTest();
    }
    
    // Test Defects
    public static testMethod void testLicenseRegistrationDefects(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        Defect__c de = new Defect__c();
        de.Active__c = true;
        de.Description__c = 'Description test';
        de.Registration_Type__c = 'Car Wash';
        de.Section__c = 'Company Information';
        de.Sub_Section__c = 'Documents';
        de.Object__c = 'Business Account';
        insert de;
        
        

        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();

        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.Status__c = 'Incomplete';
        lreg.License_Registration_Number__c = '00023568500';
        lreg.Audit_Number__c = null;
        lreg.Legal_Entity_Name__c = 'name';
        //lreg.Renewal__c = true;
        insert lreg;
        
       
        
        List<License_Registration__c> lregUpdate = [SELECT Id, Status__c FROM License_Registration__c WHERE Id =: lreg.Id LIMIT 1];
        lregUpdate[0].Enter_Your_Name__c = 'Submit';
        lregUpdate[0].I_Agree__c = true;
        lregUpdate[0].Status__c = 'Submitted';
        lregUpdate[0].Id = lreg.Id;
        
        UserRole r = new UserRole();
        //r.DeveloperName = 'Registration_Services';
        r.Name = 'Registration Services';
        //insert r;
        
        profile p = [SELECT ID from Profile Where name = 'WCA User' Limit 1];
        
        user u = new User();
        u.username = 'lralltestuser2@test.com';
        u.Email = 'lralltestuser@test.com';
        u.LastName = 'testuserlastname';
        u.ProfileId = p.Id;
        u.UserRoleId = r.Id;
        u.EmailEncodingKey = 'ISO-8859-1';
        u.Alias = 'uName';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        insert u;
     
        
        UserRole rsRole = [select id from UserRole where DeveloperName = 'Registration_Services' limit 1];
        DIR_Employee__c deputy = new DIR_Employee__c();
        deputy.Active__c = true;
        deputy.Email__c = 'test@test.com';
        deputy.Position__c = 'Registration_Services';
        //deputy.User__c = [select id from User where UserRoleId = :rsRole.Id and isActive = true limit 1].id;
        //deputy.User__c = UserInfo.getUserId();
        deputy.User__c = u.Id;
        insert deputy;
        
        Rejection_Defect__c rej = new Rejection_Defect__c();
        rej.Applies__c = True;
        rej.Defect__c = de.Id;
        rej.Registration__c = lreg.Id;
        rej.Description_of_Defect__c = de.Description__c;
        rej.Item_Name__c = de.Item_Name__c;
        rej.Section__c = de.Section__c;
        rej.Sub_Section__c = de.Sub_Section__c;
        insert rej;
        
        test.startTest();
            update lregUpdate;
            /*
            List<License_Registration__c> lregUpdate1 = [SELECT Id, Status__c FROM License_Registration__c WHERE Id =: lreg.Id LIMIT 1];
            lregUpdate1[0].Status__c = 'Pending / Defect';
            lregUpdate1[0].Id = lreg.Id;
            */
        
                    
            list<License_Registration__c> lregUpdate1 = new list<License_Registration__c>();
            lreg.Status__c = 'Pending / Defect';
            lregUpdate1.add(lreg);
        
            update lregUpdate1;
        
        //David added this
            lreg.Status__c = 'Closed - Rejected';
            lreg.Closure_Reason__c = 'test';
            update lregUpdate1;
        
            rej.Resolved__c = True;
            update rej;
        
            lreg.Status__c = 'Approved';
            lreg.Effective_Date__c = date.today();
            lreg.Expiration_Date__c = date.today()+365;
            lreg.Assigned_Deputy__c = deputy.id;
            update lreg;
        test.stopTest();
        
        
    }
    
    // Test Attachment
    public static testMethod void testLicenseRegistrationAttachment(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        List<Registration_Attachment_Bank__c> ratList = new List<Registration_Attachment_Bank__c>();
        
        Registration_Attachment_Bank__c rab = new Registration_Attachment_Bank__c ();
        rab.Active__c = true;
        rab.Attachment_Name__c = 'Att Name';
        rab.Instructions__c = 'Test Instructions';
        rab.Registration_Type__c = 'Car Wash';
        rab.Registration_Document_Category__c = 'Education';
        rab.Registration_Document_Type__c = 'Bond Certification';
        rab.On_Create__c = true;
        ratList.add(rab);
        
        Registration_Attachment_Bank__c rab1 = new Registration_Attachment_Bank__c ();
        rab1.Active__c = true;
        rab1.Attachment_Name__c = 'Att Name';
        rab1.Instructions__c = 'Test Instructions';
        rab1.Registration_Type__c = 'Car Wash';
        rab1.Registration_Document_Category__c = 'Education';
        rab1.Registration_Document_Type__c = 'Bond Certification';
        rab1.On_Create__c = false;
        rab1.Trigger_Field__c = 'Exempt_Reason__c';
        rab1.Trigger_Field_Value__c = 'Owner/Operator';
        ratList.add(rab1);
        
        Registration_Attachment_Bank__c rab2 = new Registration_Attachment_Bank__c ();
        rab2.Active__c = true;
        rab2.Attachment_Name__c = 'Att Name';
        rab2.Instructions__c = 'Test Instructions';
        rab2.Registration_Type__c = 'Car Wash';
        rab2.Registration_Document_Category__c = 'Education';
        rab2.Registration_Document_Type__c = 'Bond Certification';
        rab2.On_Create__c = false;
        rab2.Trigger_Field__c = 'License_Registration_Type__c';
        rab2.Trigger_Field_Value__c = 'Secretary of State Number';
        ratList.add(rab2);
        
        insert ratList;
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        
        List<License_Registration__c> lregList = new List<License_Registration__c>();
        
        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.Status__c = 'Incomplete';
        lreg.License_Registration_Number__c = '00023568500';
        lreg.Exempt_Reason__c = 'Out of state insurance';
        lregList.add(lreg);
        
        License_Registration__c lreg1 = new License_Registration__c();
        lreg1.RecordTypeId = devRecordTypeId;
        lreg1.Account__c = acc.Id;
        lreg1.Applicant__c = con.Id;
        lreg1.Status__c = 'Incomplete';
        lreg1.License_Registration_Number__c = '00023568501';
        lreg1.License_Registration_Type__c = 'Business License';
        lregList.add(lreg1);
        
        test.startTest();
            insert lregList;
            
        test.stopTest();
    }
    
    // Test Attachment
    public static testMethod void testLicenseRegistrationAttachment2(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        List<Registration_Attachment_Bank__c> ratList = new List<Registration_Attachment_Bank__c>();
        
        Registration_Attachment_Bank__c rab = new Registration_Attachment_Bank__c ();
        rab.Active__c = true;
        rab.Attachment_Name__c = 'Att Name';
        rab.Instructions__c = 'Test Instructions';
        rab.Registration_Type__c = 'Car Wash';
        rab.Registration_Document_Category__c = 'Education';
        rab.Registration_Document_Type__c = 'Bond Certification';
        rab.On_Create__c = true;
        ratList.add(rab);
        
        Registration_Attachment_Bank__c rab1 = new Registration_Attachment_Bank__c ();
        rab1.Active__c = true;
        rab1.Attachment_Name__c = 'Att Name';
        rab1.Instructions__c = 'Test Instructions';
        rab1.Registration_Type__c = 'Car Wash';
        rab1.Registration_Document_Category__c = 'Education';
        rab1.Registration_Document_Type__c = 'Bond Certification';
        rab1.On_Create__c = false;
        rab1.Trigger_Field__c = 'Exempt_Reason__c';
        rab1.Trigger_Field_Value__c = 'Owner/Operator';
        ratList.add(rab1);
        
        Registration_Attachment_Bank__c rab2 = new Registration_Attachment_Bank__c ();
        rab2.Active__c = true;
        rab2.Attachment_Name__c = 'Att Name';
        rab2.Instructions__c = 'Test Instructions';
        rab2.Registration_Type__c = 'Car Wash';
        rab2.Registration_Document_Category__c = 'Corp and LLC';
        rab2.Registration_Document_Type__c = 'Signed Employee Leasing Contract';
        rab2.On_Create__c = false;
        rab2.Trigger_Field__c = 'License_Registration_Type__c';
        rab2.Trigger_Field_Value__c = 'Secretary of State Number';
        ratList.add(rab2);
        
        insert ratList;
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        
        List<License_Registration__c> lregList = new List<License_Registration__c>();
        
        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.Status__c = 'Incomplete';
        lreg.License_Registration_Number__c = '00023568500';
        lreg.Exempt_Reason__c = 'Out of state insurance';
        lreg.License_Registration_Type__c = 'Business License';
        insert lreg;
        
        License_Registration__c lregClone = lreg.clone();
        lregClone.RecordTypeId = devRecordTypeId;
        lregClone.Account__c = acc.Id;
        lregClone.Applicant__c = con.Id;
        
        List<License_Registration__c> lrUpdate = new List<License_Registration__c>();
        License_Registration__c lregUpdate = [SELECT Id, Exempt_Reason__c, License_Registration_Type__c,VIP_Date_Time_Submitted__c,Company_Type__c FROM License_Registration__c WHERE Id = :lreg.Id];
        if(lregUpdate.Exempt_Reason__c == 'Out of state insurance') {
            lregUpdate.Exempt_Reason__c = 'Owner/Operator';
        }
        if(lregUpdate.License_Registration_Type__c == 'Business License') {
            lregUpdate.License_Registration_Type__c = 'Secretary of State Number';
        }
        lregUpdate.VIP_Date_Time_Submitted__c = system.today();
        lregUpdate.Company_Type__c = 'Corporation';
          
        test.startTest();   
            update lregUpdate;
            insert lregClone;
        test.stopTest();
    }
    
    // Test Education
    public static testMethod void testLicenseRegistrationEducation(){
        
        Id personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account(
            RecordTypeId = personAccountRecordType,
            Email__c = 'testLNRDEV@testdir.com',
            FirstName = 'Test',
            LastName = 'Test',
            PersonEmail = 'testLNRDEV@testdir.com'
        );
        insert acc;
        
        Account a = [Select PersonContactId From Account Where Id = :acc.Id];
        
        Registration_Education_Bank__c newedbank = new Registration_Education_Bank__c();
        newedbank.Active__c = true;
        newedbank.Instructions__c = 'Instructions';
        newedbank.Name_of_Exam__c = 'Exam Name';
        newedbank.Registration_Type__c = 'Car Wash';
        newedbank.Version__c = '1';
        insert newedbank;
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();

        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = a.PersonContactId;
        lreg.License_Registration_Number__c = '00023568500';

  
                  
        
        test.startTest();
           insert lreg;
         test.stopTest();
    }
    
    // Test Accounts And Locations
    public static testMethod void testLicenseRegistrationAccounts(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        
        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.License_Registration_Number__c = '00023568500';
        
        insert lreg; 
        
        Id personRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Partnership').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        
        
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
        racc1.Registration__c = lreg.Id;
        insert racc1;
        
        
        Registration_Account__c racc2 = new Registration_Account__c();
        racc2.RecordTypeId = businessRecordTypeId;
        racc2.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc2.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc2.First_Name__c = 'FirstName';
        racc2.Last_Name__c = 'LastName';
        racc2.Email_Address__c = 'test@asdadad.com';
        racc2.Legal_Entity_Name__c = 'Legal Entity Name';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_State__c = 'CA';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_Street__c = 'Street ';
        racc2.Mailing_Zip_Code__c = '54434';
        racc2.Business_Phone__c = '4445553434';
        racc2.Mobile_Phone__c = '5445445555';
        racc2.Registration__c = lreg.Id;
        insert racc2;
        
        Registration_Location__c rloc = new Registration_Location__c();
        rloc.Address__c = 'address';
        rloc.City__c = 'San Francisco';
        rloc.DBA_Name__c = 'DBA Name';
        rloc.FBNS__c = 'FBNS';
        rloc.Foreign_Address__c = 'Foreign Address';
        rloc.Mobile_Business__c = true;
        rloc.Phone__c = '4445553434';
        rloc.Registration__c = lreg.Id;
        rloc.Account__c = acc.Id;
        rloc.Zip_Code__c = '12343';
        rloc.Business_Regulatory_Compliance__c = 'No';
        insert rloc;
        
        
        Ownership__c nown = new Ownership__c();
        nown.Email__c = 'aaaaa@aaaaaa.aaa';
        nown.First_Name__c = 'aaaaa';
        nown.Last_Name__c = 'aaaaaa';
        nown.Registration__c = lreg.Id; 
        nown.Imported_From__c = 'xyz';
        insert nown;
        
        Registrations_Exam__c rex = new Registrations_Exam__c();
        rex.Ownership__c = nown.Id;
        rex.Exam_Disposition__c = 'Failed';
        rex.Language__c = 'English';
        insert rex;
        
        Registrations_Exam__c rex2 = [SELECT id FROM Registrations_Exam__c WHERE id =: rex.Id];
        rex2.Exam_Disposition__c = 'Passed';
        update rex2;
        License_Registration__c lr = [SELECT Id, Status__c FROM License_Registration__c WHERE Id=:lreg.Id];
        lr.Closure_Reason__c = 'Closure_Reason';
        lr.Status__c = 'Closed - Revoked';
        test.startTest();
        update lr;
        delete rex;
        test.stopTest();
    }
    
    // Test Create Fees
    public static testMethod void testLicenseRegistrationFees(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        
        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.License_Registration_Number__c = '00023568500';
        lreg.Number_of_Company_Accounts__c = 10;
        insert lreg; 
        
        Id FlatFeeRecordTypeId = Schema.SObjectType.Fee_Schedule__c.getRecordTypeInfosByName().get('Flat Fee').getRecordTypeId();
        Id PerxRecordTypeId = Schema.SObjectType.Fee_Schedule__c.getRecordTypeInfosByName().get('Per x').getRecordTypeId();
        Id PercentRecordTypeId = Schema.SObjectType.Fee_Schedule__c.getRecordTypeInfosByName().get('Percent').getRecordTypeId();
        Id RangeRecordTypeId = Schema.SObjectType.Fee_Schedule__c.getRecordTypeInfosByName().get('Range').getRecordTypeId();
        
        List<Fee_Schedule__c> FeeSchToInsert = new List<Fee_Schedule__c>(); 
        
        Fee_Schedule__c feeSchedule1 = new Fee_Schedule__c();
        feeSchedule1.RecordTypeId = FlatFeeRecordTypeId;
        feeSchedule1.Registration_Type__c = 'Car Wash';
        feeSchedule1.Initiation_Date__c = Date.Today() - 10;
        feeSchedule1.Expiration_Date__c = Date.Today() + 10;
        feeSchedule1.Calculation_Formula__c = '1234.25';
        feeSchedule1.Active__c = true;
        feeSchedule1.Fee_Type__c = 'Registration Fee';
        FeeSchToInsert.add(feeSchedule1);
        
        Fee_Schedule__c feeSchedule2 = new Fee_Schedule__c();
        feeSchedule2.RecordTypeId = PerxRecordTypeId;
        feeSchedule2.Registration_Type__c = 'Car Wash';
        feeSchedule2.Initiation_Date__c = Date.Today() - 10;
        feeSchedule2.Expiration_Date__c = Date.Today() + 10;
        feeSchedule2.Calculation_Formula__c = '{No_of_Locations__c}*[150.50]';
        feeSchedule2.Active__c = true;
        feeSchedule2.Fee_Type__c = 'Registration Fee';
        FeeSchToInsert.add(feeSchedule2);
        
        Fee_Schedule__c feeSchedule3 = new Fee_Schedule__c();
        feeSchedule3.RecordTypeId = PercentRecordTypeId;
        feeSchedule3.Registration_Type__c = 'Car Wash';
        feeSchedule3.Initiation_Date__c = Date.Today() - 10;
        feeSchedule3.Expiration_Date__c = Date.Today() + 10;
        feeSchedule3.Calculation_Formula__c = '{No_of_Locations__c}*[20/100]';
        feeSchedule3.Active__c = true;
        feeSchedule3.Fee_Type__c = 'Registration Fee';
        feeSchedule3.Reference_Field__c = 'No_of_Locations__c';
        FeeSchToInsert.add(feeSchedule3);
        
        Fee_Schedule__c feeSchedule4 = new Fee_Schedule__c();
        feeSchedule4.RecordTypeId = RangeRecordTypeId;
        feeSchedule4.Registration_Type__c = 'Car Wash';
        feeSchedule4.Initiation_Date__c = Date.Today() - 10;
        feeSchedule4.Expiration_Date__c = Date.Today() + 10;
        feeSchedule4.Range_Ceiling__c = 20;
        feeSchedule4.Range_Floor__c = 11;
        feeSchedule4.Reference_Field__c = 'No_of_Locations__c';
        feeSchedule4.Reference_Field__c = 'Number_of_Company_Accounts__c';
        feeSchedule4.Calculation_Formula__c = '2000.20';
        feeSchedule4.Active__c = true;
        feeSchedule4.Fee_Type__c = 'Registration Fee';
        FeeSchToInsert.add(feeSchedule4);
        
        Fee_Schedule__c feeSchedule5 = new Fee_Schedule__c();
        feeSchedule5.RecordTypeId = RangeRecordTypeId;
        feeSchedule5.Registration_Type__c = 'Car Wash';
        feeSchedule5.Initiation_Date__c = Date.Today() - 10;
        feeSchedule5.Expiration_Date__c = Date.Today() + 10;
        feeSchedule5.Range_Ceiling__c = 10;
        feeSchedule5.Range_Floor__c = 0;
        feeSchedule5.Reference_Field__c = 'Number_of_Company_Accounts__c';
        feeSchedule5.Calculation_Formula__c = '1000.20';
        feeSchedule5.Active__c = true;
        feeSchedule5.Fee_Type__c = 'Registration Fee';
        FeeSchToInsert.add(feeSchedule5);
        
        
        insert FeeSchToInsert;
        
        License_Registration__c lr = [SELECT Id, Status__c FROM License_Registration__c WHERE Id=:lreg.Id];
        //lr.Fee_Calculation_Ready__c = true;
        lr.Status__c = 'Fee Calculation Ready';
        test.startTest();
        update lr;
        Integer x = [SELECT COUNT() FROM Fee__c WHERE Registration__c=:lr.Id];
        //System.assertEquals(x, 4);
        test.stopTest();
        
        
    }
    
    public static testMethod void testMissingMethods(){
        test.startTest();
        
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;        
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        VIPForm__VIP_Template__c temp = new VIPForm__VIP_Template__c();
        temp.Name = 'Registration Services';
        temp.VIPForm__Object_Record_Type__c = 'Car Wash';
        insert temp;        
        
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'WCI Documentation';
        section.Name = 'WCI Documentation';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 300;
        section.VIPForm__Template__c = temp.id;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
        VIPForm__VIP_Category__c section1 = new VIPForm__VIP_Category__c();
        section1.VIPForm__Name_Displayed__c = 'Location Documentation - External';
        section1.Name = 'Location Documentation - External';
        section1.VIPForm__Object_API__c = 'License_Registration__c';
        section1.VIPForm__Order__c = 300;
        section1.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section1;
        
        
         // Added by jag
/*        VIPForm__VIP_Category__c section2 = new VIPForm__VIP_Category__c();
        section2.VIPForm__Name_Displayed__c = 'Documentation';
        section2.Name = 'Documentation - CW';
        section2.VIPForm__Object_API__c = 'License_Registration__c';
        section2.VIPForm__Order__c = 300;
        section2.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section2;   */ 
        
        List<Registration_Attachment_Bank__c> ratList = new List<Registration_Attachment_Bank__c>();
        
        Registration_Attachment_Bank__c rab = new Registration_Attachment_Bank__c ();
        rab.Active__c = true;
        rab.Attachment_Name__c = 'Att Name';
        rab.Instructions__c = 'Test Instructions';
        rab.Registration_Type__c = 'Car Wash';
        rab.Registration_Document_Category__c = 'Education';
        rab.Registration_Document_Type__c = 'Bond Certification';
        rab.On_Create__c = true;
        ratList.add(rab);
        
        Registration_Attachment_Bank__c rab1 = new Registration_Attachment_Bank__c ();
        rab1.Active__c = true;
        rab1.Attachment_Name__c = 'Att Name';
        rab1.Instructions__c = 'Test Instructions';
        rab1.Registration_Type__c = 'Car Wash';
        rab1.Registration_Document_Category__c = 'Education';
        rab1.Registration_Document_Type__c = 'Bond Certification';
        rab1.On_Create__c = false;
        rab1.Trigger_Field__c = 'Exempt_Reason__c';
        rab1.Trigger_Field_Value__c = 'Owner/Operator';
        ratList.add(rab1);
        
          //Location with DBA - Added by  Jag
        Registration_Attachment_Bank__c rab2 = new Registration_Attachment_Bank__c ();
        rab2.Active__c = true;
        rab2.Attachment_Name__c = 'Att Name';
        rab2.Instructions__c = 'Test Instructions';
        rab2.Registration_Type__c = 'Car Wash';
        rab2.Registration_Document_Category__c = 'Registration Location';
        rab2.Registration_Document_Type__c = 'Fictitious Business Name Statement for DBA';
        rab2.On_Create__c = false;
        ratList.add(rab2); 
        
       // Registration_Attachment_Bank__c rab2 = new Registration_Attachment_Bank__c ();
        //rab2.Active__c = true;
      
       /* rab2.Attachment_Name__c = 'Att Name';
        rab2.Instructions__c = 'Test Instructions';
        rab2.Registration_Type__c = 'Car Wash';
        rab2.Registration_Document_Category__c = 'Registration Location';
        rab2.Registration_Document_Type__c = 'Fictitious Business Name Statement for location';
        rab2.On_Create__c = false;
        ratList.add(rab1); */
        
        
/*       
        Registration_Attachment_Bank__c rab2 = new Registration_Attachment_Bank__c ();
        rab2.Active__c = true;
        rab2.Attachment_Name__c = 'Att Name';
        rab2.Instructions__c = 'Test Instructions';
        rab2.Registration_Type__c = 'Car Wash';
        rab2.Registration_Document_Category__c = 'Education';
        rab2.Registration_Document_Type__c = 'Bond Certification';
        rab2.On_Create__c = false;
        rab2.Trigger_Field__c = 'License_Registration_Type__c';
        rab2.Trigger_Field_Value__c = 'Secretary of State Number';
        ratList.add(rab2);
*/        
        insert ratList;        
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        Id publicWorksId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        
        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.Status__c = 'Incomplete';
        lreg.License_Registration_Number__c = '00023568500';
        lreg.Exempt_Reason__c = 'Out of state insurance';
        lreg.License_Registration_Type__c = 'Business License';
        lreg.Employee_Leasing__c = 'No';
        lreg.VIP_Date_Time_Submitted__c = null;
        lreg.Ready_to_Submit__c='No';
        lreg.CompanyFinancesCWDocuments__c=false;   
        lreg.CompanyFinancesReviewed__c=false;
        lreg.VIP_Template__c =  temp.id;
        lreg.VIP_Template_Status__c='[{"parentCategoryId":null,"isSubmit":null,"isCurrent":null,"categoryStatusLabels":{"noValue":"","missingReqData":"Missing Required Data","inProgress":"In Progress","complete":"Completed"},"categoryStatus":"Completed","categoryId":"a3Sr0000000DXyN"}]';
        insert lreg;
/*        
        lreg.Status__c = 'Resubmitted';
        lreg.Employee_Leasing__c = 'Yes';
        lreg.Function_as_Employee_Leasing_Co__c = 'No';
        lreg.Workers_Comp_Selection__c='Insured by carrier';
        lreg.VIP_Date_Time_Submitted__c = system.Today();
        lreg.Company_Type__c = 'Corp or LLC';
        lreg.Renewal__c = false;
        lreg.Audit_Number__c = null;
        lreg.CompanyFinancesCWDocuments__c=true;
        lreg.CompanyFinancesReviewed__c=true;
        lreg.VIP_Template__c =  temp.id;
        lreg.VIP_Template_Status__c='[{"parentCategoryId":null,"isSubmit":null,"isCurrent":null,"categoryStatusLabels":{"noValue":"","missingReqData":"Missing Required Data","inProgress":"In Progress","complete":"Incomplete"},"categoryStatus":"Completed","categoryId":"a3Sr0000000DXyN"}]';
        update lreg;
 */      
        lreg.Employee_Leasing__c = 'No';
        lreg.Function_as_Employee_Leasing_Co__c = 'No';
        lreg.Workers_Comp_Selection__c='Exempt from workers\' compensation insurance';
        update lreg;
        
        lreg.Employee_Leasing__c = 'No';
        lreg.Function_as_Employee_Leasing_Co__c = 'No';
        lreg.Workers_Comp_Selection__c='Self-Insured';
        update lreg;
        
        License_Registration__c lreg2 = new License_Registration__c();
        lreg2.RecordTypeId = publicWorksId;
        lreg2.Account__c = acc.Id;
        lreg2.EntityNumber__c = '123';
        lreg2.Applicant__c = con.Id;        
        lreg2.Status__c = 'Fee Calculation Ready';
        lreg2.License_Registration_Number__c = '00023568502';
        lreg2.Exempt_Reason__c = 'Out of state insurance';
        lreg2.Employee_Leasing__c = 'No';
        lreg2.VIP_Date_Time_Submitted__c = system.Today();
        lreg2.Company_Type__c = 'Corp or LLC';
        lreg2.Renewal__c = true;
        lreg2.Audit_Number__c = null;
        lreg2.Imported_From__c = null;
        lreg2.Ready_to_Submit__c='Yes';
        lreg2.payment_status__c = 'Canceled';
        lreg2.Original_Registration__c = lreg.id;
        lreg2.Submission_Type__c='Paper';
        lreg2.CompanyFinancesCWDocuments__c=false;
        lreg2.CompanyFinancesReviewed__c=false;   
        lreg2.VIP_Template__c =  temp.id;
        lreg2.accAlreadyCreated__c = false;
        insert lreg2;       
        
        lreg2.CompanyFinancesCWDocuments__c=true;
        lreg2.CompanyFinancesReviewed__c=true;       
        update lreg2;
      
        List<License_Registration__c> lregList = new List<License_Registration__c>();
        lregList.add(lreg2);
        
        LicenseRegistrationAllHandler LRHandler = LicenseRegistrationAllHandler.getInstance();
        LRHandler.onAfterClone(lregList);
        LRHandler.onBeforeDelete(null,null);
        LRHandler.onAfterDelete(null,null);
                    
        test.stopTest();
    }
    
    // Test EWP, FLC
    public static testMethod void testEWPRegistration(){
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        //Id indivRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        Id parentRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Parent Guardian').getRecordTypeId();
        //Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        Id FLCRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Farm Labor Contractor').getRecordTypeId();

        
        Account acc2 = new Account(
            FirstName = 'ewp',
            LastName = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            PersonEmail = 'lralltestusers@test.com',
            RecordTypeId = personRecordTypeId
        );
        insert acc2;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test';
        con2.LastName = 'Test';
        con2.Email = 'testLNRDEV@testdir.com';
        insert con2;
        
        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = RecordTypeId;
        lreg.Account__c = acc2.Id;
        lreg.Applicant__c = con2.Id;
        lreg.License_Registration_Number__c = '00023568500';
        lreg.Status__c = 'Incomplete';
        //lreg.Assigned_Deputy__c = deputy.Id;
        lreg.Legal_Entity_Name__c = 'name';
        lreg.Registration_Duration__c  = '10 Days - Temporary Permit';
        //lreg.Registration_Duration__c  = '6 Months - Permit';
        lreg.Submission_Type__c = 'Online';
        //lreg.Status_of_Payment__c = 'Paid / No Balance Due';
        //lreg.Balance__c = 0;
        lreg.Amount_Due__c = 50;
        lreg.Amount_Paid_Online__c  = 50;
        lreg.Amount_Paid_Manually__c = 0;
        lreg.Effective_Date__c = Date.today() + 5;
        lreg.Ready_to_Submit__c = 'No';
        lreg.First_Name__c = 'FirstName';
        lreg.Last_Name__c = 'LastName';
        
        lreg.Residential_Address_Line_1__c = 'Street ';
        lreg.Residential_City__c = 'San Francisco';
        lreg.Residential_State__c = 'CA';
        lreg.Residential_Postal_Code__c = '54434';
        
        lreg.Mailing_Address_Line_1__c = 'Street ';
        lreg.Mailing_City__c = 'San Francisco';
        lreg.Mailing_State__c = 'CA';
        lreg.Mailing_Postal_Code__c = '54434';
        lreg.Mobile_Phone__c = '5445445555';
        lreg.Birth_Date__c = Date.today() - 40;
        insert lreg; 
        
        License_Registration__c lreg2 = new License_Registration__c();
        lreg2.RecordTypeId = RecordTypeId;
        lreg2.Account__c = acc2.Id;
        lreg2.Applicant__c = con2.Id;
        lreg2.License_Registration_Number__c = '00023568500';
        lreg2.Status__c = 'Submitted';
        //lreg.Assigned_Deputy__c = deputy.Id;
        lreg2.Legal_Entity_Name__c = 'name';
        //lreg.Registration_Duration__c  = '10 Days - Temporary Permit';
        lreg2.Registration_Duration__c  = '6 Months - Permit';
        lreg2.Submission_Type__c = 'Online';
        //lreg.Status_of_Payment__c = 'Paid / No Balance Due';
        //lreg.Balance__c = 0;
        //lreg2.Amount_Due__c = 50;
        //lreg2.Amount_Paid_Online__c  = 50;
        //lreg2.Amount_Paid_Manually__c = 0;
        lreg2.Effective_Date__c = Date.today() + 5;
        lreg2.Expiration_Date__c = Date.today() + 90;
        lreg2.First_Name__c = 'FirstName1';
        lreg2.Last_Name__c = 'LastName1';
        
        lreg2.Residential_Address_Line_1__c = 'Street ';
        lreg2.Residential_City__c = 'San Francisco';
        lreg2.Residential_State__c = 'CA';
        lreg2.Residential_Postal_Code__c = '54434';
        
        lreg2.Mailing_Address_Line_1__c = 'Street ';
        lreg2.Mailing_City__c = 'San Francisco';
        lreg2.Mailing_State__c = 'CA';
        lreg2.Mailing_Postal_Code__c = '54434';
        
        lreg2.Mobile_Phone__c = '5445445555';
        lreg2.Birth_Date__c = Date.today() - 40;
        insert lreg2; 
        
        /*Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = indivRecordTypeId;
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Birth_Date__c = Date.today() - 40;
        racc1.Registration__c = lreg.Id;
        insert racc1; */
        
        Registration_Account__c racc2 = new Registration_Account__c();
        racc2.RecordTypeId = parentRecordTypeId;
        racc2.First_Name__c = 'FirstName';
        racc2.Last_Name__c = 'LastName';
        racc2.Email_Address__c = 'test@asdadad.com';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_State__c = 'CA';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_Street__c = 'Street ';
        racc2.Mailing_Zip_Code__c = '54434';
        racc2.Business_Phone__c = '4445553434';
        racc2.Mobile_Phone__c = '5445445555';
        racc2.Birth_Date__c = Date.today() - 40;
        racc2.Registration__c = lreg.Id;
        insert racc2;
        
        lreg.Ready_to_Submit__c = 'Yes';
        lreg.Status__c = 'Submitted';
        update lreg;
        
        License_Registration__c lregFLC = new License_Registration__c();
        lregFLC.RecordTypeId = FLCRecordTypeId;
        lregFLC.Account__c = acc2.Id;
        lregFLC.Applicant__c = con2.Id;
        lregFLC.License_Registration_Number__c = '00023568501';
        lregFLC.Status__c = 'Pending Payment';
        //lregFLC.Assigned_Deputy__c = deputy.Id;
        lregFLC.Legal_Entity_Name__c = 'name';
        lregFLC.Submission_Type__c = 'Online';
        //lregFLC.Status_of_Payment__c = 'Paid / No Balance Due';
        //lregFLC.Balance__c = 0;
        lregFLC.Amount_Due__c = 50;
        lregFLC.Amount_Paid_Online__c  = 0;
        lregFLC.Amount_Paid_Manually__c = 50;
        lregFLC.Effective_Date__c = Date.today() + 5;
        lregFLC.Expiration_Date__c = Date.today()+365;
        lregFLC.Ready_to_Submit__c = 'No';
              
        lregFLC.Mailing_City__c = 'San Francisco';
        lregFLC.Mailing_State__c = 'CA';
        lregFLC.Mailing_City__c = 'San Francisco';
        lregFLC.Mailing_Address_Line_1__c = 'Street ';
        lregFLC.Mailing_Postal_Code__c = '54434';
        lregFLC.Mobile_Phone__c = '5445445555';
        //lregFLC.Pending_Final_Submission__c = 'False';
        lregFLC.Service_type__c = 'New'; 
        
        insert lregFLC; 
        lregFLC.Status__c = 'Submitted';        
        update lregFLC;
        
        List<License_Registration__c> newList = new List<License_Registration__c>();
        newList.add(lreg);
        
        LicenseRegistrationAllHandler handler = LicenseRegistrationAllHandler.getInstance();

        test.startTest();
        
        handler.AutoApproveTempEWPRegistration(newList, new Map<Id, License_Registration__c>());
        
        test.stopTest();
        
    }
    
    // Test CheckEntityLicenceNumbers
    public static testMethod void testCheckEntityLicenceNumbers(){
        test.startTest();
        
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;        
        
        Contact con = new Contact(
            AccountId = acc.id,
            FirstName = 'Test',
            LastName = 'Test',
            Email = 'testLNRDEV@testdir.com'
        );
        insert con;
        
        Profile p = [select Id,name from Profile where UserType = 'CspLitePortal' and name = 'Community Registrations User' limit 1];
        User newUser = new User(
            profileId = p.id,
            username = 'testLNRDEV@testdir.com',
            email = 'testLNRDEV@testdir.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            contactId = con.id
        );
        insert newUser;
        
        VIPForm__VIP_Template__c temp = new VIPForm__VIP_Template__c();
        temp.Name = 'Registration Services';
        temp.VIPForm__Object_Record_Type__c = 'Car Wash';
        insert temp;        
        
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'WCI Documentation';
        section.Name = 'WCI Documentation';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 300;
        section.VIPForm__Template__c = temp.id;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
        VIPForm__VIP_Category__c section1 = new VIPForm__VIP_Category__c();
        section1.VIPForm__Name_Displayed__c = 'Location Documentation - External';
        section1.Name = 'Location Documentation - External';
        section1.VIPForm__Object_API__c = 'License_Registration__c';
        section1.VIPForm__Order__c = 300;
        section1.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section1;
        
        Id publicWorksId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        
        License_Registration__c lreg2 = new License_Registration__c();
        lreg2.RecordTypeId = publicWorksId;
        lreg2.Account__c = acc.Id;
        lreg2.EntityNumber__c = '123';
        lreg2.Applicant__c = con.Id;        
        lreg2.Status__c = 'Fee Calculation Ready';
        lreg2.License_Registration_Number__c = '00023568502';
        lreg2.Exempt_Reason__c = 'Out of state insurance';
        lreg2.Employee_Leasing__c = 'No';
        lreg2.VIP_Date_Time_Submitted__c = system.Today();
        lreg2.Company_Type__c = 'Corp or LLC';
        lreg2.Renewal__c = true;
        lreg2.Audit_Number__c = null;
        lreg2.Imported_From__c = null;
        lreg2.Ready_to_Submit__c='Yes';
        lreg2.payment_status__c = 'Canceled';
        //lreg2.Original_Registration__c = lreg.id;
        lreg2.Submission_Type__c='Paper';
        lreg2.CompanyFinancesCWDocuments__c=false;
        lreg2.CompanyFinancesReviewed__c=false;   
        lreg2.VIP_Template__c =  temp.id;
        lreg2.accAlreadyCreated__c = false;
        insert lreg2;       
        
           
        System.runAs (newUser){        
            lreg2.CompanyFinancesCWDocuments__c=true;
            lreg2.CompanyFinancesReviewed__c=true;       
            update lreg2;
        }
        
        List<License_Registration__c> lregList = new List<License_Registration__c>();
        lregList.add(lreg2);
        
              
        LicenseRegistrationAllHandler LRHandler = LicenseRegistrationAllHandler.getInstance();
        LRHandler.onAfterClone(lregList);
        LRHandler.onBeforeDelete(null,null);
        LRHandler.onAfterDelete(null,null);
        
        test.stopTest();
    }
    
    
    
}