@IsTest
public class Test_A_Plus_Multiple_File_Uploader_Ctrl {
    static testMethod void testSetUp(){
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
        
        String jsonString = '[{"name":"3rdpartyclaim.png","fileExtension":"png","documentId":"06935000001o2sOAAQ","File_Name":"3rdpartyclaim","Private":false,"Description":""},{"name":"Case1.png","fileExtension":"png","documentId":"06935000001o2sTAAQ","File_Name":"Case1","Private":false,"Description":""},{"name":"caseRole1.png","fileExtension":"png","documentId":"06935000001o2sYAAQ","File_Name":"caseRole1","Private":false,"Description":""}]';
        String configDetails = '{"Id":"m0Ct0000000XZSIEA4","File_Type__c":"Hearing","Sharing_Permissions__c":"Public","Sort_Order__c":30}';
        Test.startTest();
            A_Plus_Multiple_File_Uploader_ctrl.uploadMultipleFiles('Hearing', jsonString, c.Id, configDetails);
            A_Plus_Multiple_File_Uploader_ctrl.deleteMultipleFiles(jsonString);
        Test.stopTest();

        
    }
}