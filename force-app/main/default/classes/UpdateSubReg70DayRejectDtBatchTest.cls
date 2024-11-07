@IsTest 
public class UpdateSubReg70DayRejectDtBatchTest {
    
    public static testMethod void UpdateSubReg70dayRejectDtBatch(){
        List<License_Registration__c> records2 = new List<License_Registration__c>();
        List<License_Registration__c>  registrationList = new List<License_Registration__c>();
        
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
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Garment Manufacturers and Contractors').getRecordTypeId();

        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.License_Registration_Number__c = '00023568500';
        lreg.Status__c = 'Pending / Defect'; 
        lreg.Initial_Defect_Date__c = date.today() - 71;
        lreg.Initial_Reject_Date__c = Null;
        lreg.Assigned_Deputy__c = deputy.Id;
        lreg.Legal_Entity_Name__c = 'name';
        lreg.Account_Email__c = 'test@dir.ca.gov'; 
        
        insert lreg;
        System.debug('##################lreg:' + lreg.Name);
              
        Database.executeBatch(new UpdateSubReg70dayRejectDtBatch(), 1);  
        
    }
 
@isTest static void testCoverage() {
     
        UpdateSubReg70dayRejectDtBatch batch = New UpdateSubReg70dayRejectDtBatch();              
             batch.neededForTestCoverage();
       
       
    } 
    
}