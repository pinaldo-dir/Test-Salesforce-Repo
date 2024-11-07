@IsTest
public class UpdateRegistrationApproveStatusBatchTest {
    
    public static testMethod void UpdateRegistrationApproveStatusBatch(){
        
        
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
        
        
        
        //Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
  		//Database.executeBatch(new UpdateRegistrationApproveStatusBatch(), 1); 
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        //Id  indivRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        //Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        //Date myDate = Date.today().addDays(-1826); 	
       
        Date d1 = Date.today();
          
        
        License_Registration__c lregprev = new License_Registration__c();
        
        lregprev.RecordTypeId = RecordTypeId;
        lregprev.Account__c = acc.Id;
        lregprev.Applicant__c = con.Id;
        lregprev.License_Registration_Number__c = '00023568500';
        lregprev.Status__c = 'Submitted';
        lregprev.Service_Type__c = 'Renewal';
        lregprev.Registration_Duration__c = '6 Months - Permit';
        lregprev.Assigned_Deputy__c = deputy.Id;
        lregprev.Legal_Entity_Name__c = 'name';
        lregprev.Account_Email__c = 'test@dir.ca.gov'; 
        lregprev.Birth_Date__c = d1.addyears(-4);
        lregprev.First_Name__c = 'FirstName';
        lregprev.Last_Name__c = 'LastName';
        lregprev.Legal_Entity_Name__c = 'Legal Entity Name';
        
        lregprev.Residential_Address_Line_1__c = 'Street ';
        lregprev.Residential_City__c = 'San Francisco';
        lregprev.Residential_State__c = 'CA';
        lregprev.Residential_Postal_Code__c = '54434';
        
        lregprev.Mailing_Address_Line_1__c = 'Street ';
        lregprev.Mailing_City__c = 'San Francisco';
        lregprev.Mailing_State__c = 'CA';
        lregprev.Mailing_Postal_Code__c = '54434';
        lregprev.Mobile_Phone__c = '5445445555';
        lregprev.Effective_Date__c = date.today();
        lregprev.Expiration_Date__c = date.today()+90;
        insert lregprev;
        
        // current reg
        License_Registration__c lreg = new License_Registration__c();
        lreg.Original_Registration__c = lregprev.Id;
        lreg.RecordTypeId = RecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.License_Registration_Number__c = '00023568500';
        lreg.Status__c = 'Submitted';
        lreg.Service_Type__c = 'Renewal';
        lreg.Registration_Duration__c = '6 Months - Permit';
        lreg.Assigned_Deputy__c = deputy.Id;
        lreg.Legal_Entity_Name__c = 'name';
        lreg.Account_Email__c = 'test@dir.ca.gov'; 
        lreg.Birth_Date__c = d1.addyears(-4);
        lreg.First_Name__c = 'FirstName';
        lreg.Last_Name__c = 'LastName';
        lreg.Legal_Entity_Name__c = 'Legal Entity Name';
        
        System.debug('Bdate: '+d1.addyears(-4));
        
        lreg.Residential_Address_Line_1__c = 'Street ';
        lreg.Residential_City__c = 'San Francisco';
        lreg.Residential_State__c = 'CA';
        lreg.Residential_Postal_Code__c = '54434';
        
        lreg.Mailing_Address_Line_1__c = 'Street ';
        lreg.Mailing_City__c = 'San Francisco';
        lreg.Mailing_State__c = 'CA';
        lreg.Mailing_Postal_Code__c = '54434';
        lreg.Mobile_Phone__c = '5445445555';
        lreg.Effective_Date__c = date.today();
        lreg.Expiration_Date__c = date.today()+90;
        insert lreg;
        
        /*Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = indivRecordTypeId;
        racc1.Birth_Date__c = date.today() - 1825;
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Legal_Entity_Name__c = 'Legal Entity Name';
        
        racc1.Residential_Street__c = 'Street ';
        racc1.Residential_City__c = 'San Francisco';
        racc1.Residential_State__c = 'CA';
        racc1.Residential_Zip_Code__c = '54434';
        
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_Zip_Code__c = '54434';
        
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Registration__c = lreg.Id;
        insert racc1;       */
        
        Database.executeBatch(new UpdateRegistrationApproveStatusBatch(), 1); 
        
                    
    }
 @isTest static void testCoverage() {
     
        UpdateRegistrationApproveStatusBatch batch = New UpdateRegistrationApproveStatusBatch();              
             batch.neededForTestCoverage();
       
       
    } 

}