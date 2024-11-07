@isTest
public class RsCommunitySelfRegisterCtrlTest {
    @isTest static void initializeComponentTest(){
        
        Account mainA = new Account();
        mainA.LastName='Lnamet';
        mainA.FirstName='fnamew';
        mainA.Phone='77383246292';
        mainA.PersonEmail='abc@gmail.comm';
        mainA.PersonMailingStreet='1026 Point Streeta';
        mainA.ShippingPostalCode = '234884';
        insert mainA;
        
        Account affA = new Account();
        affA.LastName='Lnamer';
        affA.FirstName='fnamew';
        affA.Phone='77383246291';
        affA.PersonEmail='abc@gmail.coma';
        affA.PersonMailingStreet='1026 Point Streett';
        affA.ShippingPostalCode = '234885';
        insert affA;
        
        Account temp = new Account();
        temp.LastName='Templname';
        temp.FirstName='Tempfname';
        temp.Phone='7738324623';
        temp.PersonEmail='abc@gmail.comr';
        temp.PersonMailingStreet='1026 Point srt1';
        temp.ShippingPostalCode = '234811';
        insert temp; 
       
        Address__c addObj = new Address__c();
        addObj.Entity__c = affA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        insert addObj;
      
        Key_Value_Store__c obj =new Key_Value_Store__c();
        obj.name='OC Recaptcha Public Key';
        obj.Value__c='qwertyuiop';
        upsert obj;
        
        Account mainA1 = new Account();
        mainA1.LastName='Pavitra';
        mainA1.FirstName='Chauhan';
        mainA1.Phone='77383246292';
        mainA1.PersonEmail='abc@gmail.com';
        mainA1.PersonMailingStreet='1026 Point Streeta';
        mainA1.ShippingPostalCode = '234884';
        insert mainA1;
        
/*
        //Create portal account owner
        //For possible testing in future
        UserRole portalRole = [Select Id From UserRole where name = 'System Administrators' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'Standard Platform User'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'dlseregistrationservices@dir.ca.gov.donotuse',
            Alias = 'rserv',
            Email='dlseregistrationservices@dir.ca.gov.invalid',
            EmailEncodingKey='UTF-8',
            Firstname='Registration',
            Lastname='Services',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles'
        );
        Database.insert(portalAccountOwner1);     
 */       
      
        Test.startTest();
        RsCommunitySelfRegisterCtrl.initializeComponent();
        RsCommunitySelfRegisterCtrl.createUser( mainA.FirstName,'hello',mainA.LastName, mainA.PersonEmail, mainA.PersonEmail,mainA.Phone);
        RsCommunitySelfRegisterCtrl.createUser( temp.FirstName,'hello',temp.LastName, temp.PersonEmail, temp.PersonEmail,temp.Phone);
        RsCommunitySelfRegisterCtrl.createUser( 'Pavitra','hello','Chauhan', 'abc@gmail.com','abc@gmail.com','9876543210');    
        RsCommunitySelfRegisterCtrl.createUser( temp.FirstName,'hello',temp.LastName, temp.PersonEmail, temp.PersonEmail,temp.Phone);
     
        //exception
        //RsCommunitySelfRegisterCtrl.createUser( null,null,'abc',null,null,null);
        RsCommunitySelfRegisterCtrl.createUser( 'FirstName','MName','Last', 'abc@gmail.gmail.com','abc@gmail.gmail.com','9876543210');
		               
        Test.stopTest();
        
    }
    @isTest static void verifyCaptchaTest(){
        Key_Value_Store__c ob =new Key_Value_Store__c();
        ob.Name='OC Recaptcha Public Key';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('USPSDemoResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        HttpResponse res = new HttpResponse();
        res.setBody('{"success":true,"score":"10","action":""test}');
        Test.setMock(HttpCalloutMock.class, mock);
        Key_Value_Store__c obj =new Key_Value_Store__c();
        obj.name='OC Recaptcha Private Key';
        obj.Value__c='qwertyuiop';
        upsert obj;
        Test.startTest();
        RsCommunitySelfRegisterCtrl.makeRequest('https://www.google.com/recaptcha/api/siteverify','{"success":true,"score":"10","action":""test}');
        RsCommunitySelfRegisterCtrl.verifyCaptcha('{"success":true,"error-codes": ["missing-input-secret"]}');
        List<Key_Value_Store__c> keyValue =  [SELECT Name, Value__c from Key_Value_Store__c where Name = 'OC Recaptcha Private Key' LIMIT 1];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        request.setMethod('POST');
        request.setBody('secret=' + (KeyValue != null ? keyValue[0].Value__c : '') + '&response=' + '6LftnNsaAAAAAI8IiySL5eTfN_MIhevenuugg2rW');
        HttpResponse response = http.send(request);
        RsCommunitySelfRegisterCtrl.verifyCaptcha( '6LftnNsaAAAAAI8IiySL5eTfN_MIhevenuugg2rW');
        RsCommunitySelfRegisterCtrl.getValueFromJson('{"success":true,"error-codes": ["missing-input-secret"]}','success');
        Test.stopTest();
    }
}