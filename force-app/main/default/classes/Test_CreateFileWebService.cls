@IsTest
public class Test_CreateFileWebService {
    @isTest
    static void testFileCreationService(){
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        Contact objContact =  new Contact(LastName = 'Test', AccountId = objAccount.Id);
        insert objContact;
        
        List<Trigger_Settings__c> triggerSettings = OWCTestDataFactory.createTriggerCustomSettingRecord();
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
        Id profileId = [select id from profile where name='Customer Online Claim User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        Account mainA = new Account();
        mainA.firstName='abc';
        mainA.lastName='xyz';
        mainA.PersonEmail='abc@gmail.com';
        mainA.ShippingPostalCode = '234889';
        
        String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        String email = 'test@gmail.com';
        String accountId = mainA.Id;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        c.Online_Claim_Account__c = ac.Id;
        
        insert c;
        
        Attachments_New__c attachmentObj = new Attachments_New__c();
        attachmentObj.File_Name__c = 'Test1';
        attachmentObj.File_Type__c = 'Port';
        attachmentObj.Related_Id__c = c.Id;
        attachmentObj.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"Name"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        insert attachmentObj;
        Test.startTest();
        serviceResponseWrapper wrapperObj = new serviceResponseWrapper();
        wrapperObj.aPlusId = attachmentObj.Id;
        wrapperObj.caseNumber = [SELECT Id, Case_Number__c FROM DIR_Case__c LIMIT 1].Case_Number__c;
        wrapperObj.name = 'Test';
        wrapperObj.fileExtension = '.png';
        wrapperObj.communityUserId = ac.Id;
        wrapperObj.contenttype = 'application/pdf';
        wrapperObj.versionData = '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';
        String myJSON = JSON.serialize(wrapperObj);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='https://cadir--uat.my.salesforce.com:443/services/apexrest/CreateFile';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(myJSON);
		
        RestContext.request = request;
        RestContext.response = res;
		CreateFileWebService.uploadDocument();
        OWCThirdPartyFileUploadWebService.uploadDocument();
        Test.stopTest();
    }
    
    @isTest
    static void testFileCreationService1(){
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        Contact objContact =  new Contact(LastName = 'Test', AccountId = objAccount.Id);
        insert objContact;
        
        List<Trigger_Settings__c> triggerSettings = OWCTestDataFactory.createTriggerCustomSettingRecord();
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
        Id profileId = [select id from profile where name='Customer Online Claim User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        Account mainA = new Account();
        mainA.firstName='abc';
        mainA.lastName='xyz';
        mainA.PersonEmail='abc@gmail.com';
        mainA.ShippingPostalCode = '234889';
        
        String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        String email = 'test@gmail.com';
        String accountId = mainA.Id;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        c.Online_Claim_Account__c = ac.Id;
        
        insert c;
        
        Attachments_New__c attachmentObj = new Attachments_New__c();
        attachmentObj.File_Name__c = 'Test1';
        attachmentObj.File_Type__c = 'Port';
        attachmentObj.Related_Id__c = c.Id;
        attachmentObj.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"Name"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        insert attachmentObj;
        Test.startTest();
        serviceResponseWrapper wrapperObj = new serviceResponseWrapper();
        wrapperObj.aPlusId = '';
        wrapperObj.name = 'Test';
        wrapperObj.fileExtension = '.png';
        wrapperObj.contenttype = 'application/pdf';
        wrapperObj.versionData = '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';
        String myJSON = JSON.serialize(wrapperObj);
        RestRequest request = new RestRequest();
        request.requestUri ='https://cadir--uat.my.salesforce.com:443/services/apexrest/CreateFile';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(myJSON);
		
        RestContext.request = request;
		CreateFileWebService.uploadDocument();
        Test.stopTest();
    }
    
    @isTest
    static void testFileCreationService2(){
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        Contact objContact =  new Contact(LastName = 'Test', AccountId = objAccount.Id);
        insert objContact;
        
        List<Trigger_Settings__c> triggerSettings = OWCTestDataFactory.createTriggerCustomSettingRecord();
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
        Id profileId = [select id from profile where name='Customer Online Claim User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        Account mainA = new Account();
        mainA.firstName='abc';
        mainA.lastName='xyz';
        mainA.PersonEmail='abc@gmail.com';
        mainA.ShippingPostalCode = '234889';
        
        String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        String email = 'test@gmail.com';
        String accountId = mainA.Id;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        c.Online_Claim_Account__c = ac.Id;
        
        insert c;
        
        Attachments_New__c attachmentObj = new Attachments_New__c();
        attachmentObj.File_Name__c = 'Test1';
        attachmentObj.File_Type__c = 'Port';
        attachmentObj.Related_Id__c = c.Id;
        attachmentObj.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"Name"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        insert attachmentObj;
        Test.startTest();
        serviceResponseWrapper wrapperObj = new serviceResponseWrapper();
        wrapperObj.aPlusId = attachmentObj.Id;
        wrapperObj.name = '';
        wrapperObj.fileExtension = '.png';
        wrapperObj.contenttype = 'application/pdf';
        wrapperObj.versionData = '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';
        String myJSON = JSON.serialize(wrapperObj);
        RestRequest request = new RestRequest();
        request.requestUri ='https://cadir--uat.my.salesforce.com:443/services/apexrest/CreateFile';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(myJSON);
		
        RestContext.request = request;
		CreateFileWebService.uploadDocument();
        Test.stopTest();
    }
    
    @isTest
    static void testFileCreationService3(){
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        Contact objContact =  new Contact(LastName = 'Test', AccountId = objAccount.Id);
        insert objContact;
        
        List<Trigger_Settings__c> triggerSettings = OWCTestDataFactory.createTriggerCustomSettingRecord();
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
        Id profileId = [select id from profile where name='Customer Online Claim User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        Account mainA = new Account();
        mainA.firstName='abc';
        mainA.lastName='xyz';
        mainA.PersonEmail='abc@gmail.com';
        mainA.ShippingPostalCode = '234889';
        
        String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        String email = 'test@gmail.com';
        String accountId = mainA.Id;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        c.Online_Claim_Account__c = ac.Id;
        
        insert c;
        
        Attachments_New__c attachmentObj = new Attachments_New__c();
        attachmentObj.File_Name__c = 'Test1';
        attachmentObj.File_Type__c = 'Port';
        attachmentObj.Related_Id__c = c.Id;
        attachmentObj.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"Name"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        insert attachmentObj;
        Test.startTest();
        serviceResponseWrapper wrapperObj = new serviceResponseWrapper();
        wrapperObj.aPlusId = attachmentObj.Id;
        wrapperObj.name = 'Test';
        wrapperObj.fileExtension = '.png';
        wrapperObj.contenttype = 'application/pdf';
        wrapperObj.versionData = '';
        String myJSON = JSON.serialize(wrapperObj);
        RestRequest request = new RestRequest();
        request.requestUri ='https://cadir--uat.my.salesforce.com:443/services/apexrest/CreateFile';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(myJSON);
		
        RestContext.request = request;
		CreateFileWebService.uploadDocument();
        Test.stopTest();
    }
    public class serviceResponseWrapper{
        public String aPlusId{get;set;}
        public String name{get;set;}
        public String fileExtension{get;set;}
        public String contenttype{get;set;}
        public String versionData{get;set;}
        public String communityUserId{get;set;}
        public String caseNumber{get;set;}
    }
}