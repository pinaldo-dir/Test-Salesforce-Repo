@isTest
public class OwcCommunitySelfRegisterCtrl_Test {
    @isTest static void initializeComponentTest(){
        Trigger_Settings__c caseTriggerSetting = new Trigger_Settings__c(
            Name = 'CaseManagementHistoryConfig',
            Is_Active__c = false
        );
        insert caseTriggerSetting;
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        
        Trigger_Settings__c dlrs_Related_PartyTriggersetting = new Trigger_Settings__c(
            Name = 'dlrs_Related_PartyTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_Related_PartyTriggersetting);
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
        
        Office__c office = new Office__c();
        office.Name = 'Lucian832474';
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '234889';
        insert zip;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
        map1.Zip_Code__c = zip.Id;
        map1.Office__c = office.Id;
        insert map1;
        
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
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        insert c;
        
        
        Address__c addObj = new Address__c();
        addObj.Entity__c = affA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        insert addObj;
        
        Associated_Agents__c agent =new Associated_Agents__c();
        agent.Account__c=mainA.Id;
        agent.Type__c='Attorney';
        agent.Associated_Account__c=affA.Id;
        agent.Relationship_Status__c=true;
        insert agent;
        
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = affA.Id;
        relatedBusinessObj.Related_Business__c = mainA.Id;
        relatedBusinessObj.Type__c = 'Alter Ego';
        relatedBusinessObj.Case_Management_Id__c=c.Id;
        insert relatedBusinessObj;
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = c.Id;
        System.debug(c.Id);
        cr.Entity__c = affA.Id;
        cr.Role__c = 'Employer';
        cr.Case_Role_Status__c = 'No Longer Active On Case';
        cr.Reason_No_Longer_Active__c='its no longer active on case';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        cr.Role__c = 'Owner';
        update cr;
        List<DIR_Case__c>d=new List<DIR_Case__c>();
        c.Status__c = 'Not Confirmed';
        d.add(c);
        update d;
        
        Key_Value_Store__c obj =new Key_Value_Store__c();
        obj.name='OC Recaptcha Public Key';
        obj.Value__c='qwertyuiop';
        upsert obj;
        
       /* Account mainA1 = new Account();
        mainA1.LastName='Pavitra';
        mainA1.FirstName='Chauhan';
        mainA1.Phone='77383246292';
        mainA1.PersonEmail='abc@gmail.com';
        mainA1.PersonMailingStreet='1026 Point Streeta';
        mainA1.ShippingPostalCode = '234884';
        insert mainA1;*/
        
        Test.startTest();
        OwcCommunitySelfRegisterCtrl.initializeComponent();
        OwcCommunitySelfRegisterCtrl.createUser( mainA.FirstName,'hello',mainA.LastName, mainA.PersonEmail, mainA.PersonEmail,mainA.Phone);
        OwcCommunitySelfRegisterCtrl.createUser( temp.FirstName,'hello',temp.LastName, temp.PersonEmail, temp.PersonEmail,temp.Phone);
        OwcCommunitySelfRegisterCtrl.createUser( 'Pavitra','hello','Chauhan', 'abc@gmail.com','abc@gmail.com','9876543210');    
        OwcCommunitySelfRegisterCtrl.createUser( temp.FirstName,'hello',temp.LastName, temp.PersonEmail, temp.PersonEmail,temp.Phone);
        OwcCommunitySelfRegisterCtrl.createUser( null,null,'abc',null,null,null);
        
        
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
        OwcCommunitySelfRegisterCtrl.makeRequest('https://www.google.com/recaptcha/api/siteverify','{"success":true,"score":"10","action":""test}');
        OwcCommunitySelfRegisterCtrl.verifyCaptcha('{"success":true,"error-codes": ["missing-input-secret"]}');
        List<Key_Value_Store__c> keyValue =  [SELECT Name, Value__c from Key_Value_Store__c where Name = 'OC Recaptcha Private Key' LIMIT 1];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        request.setMethod('POST');
        request.setBody('secret=' + (KeyValue != null ? keyValue[0].Value__c : '') + '&response=' + '6LftnNsaAAAAAI8IiySL5eTfN_MIhevenuugg2rW');
        HttpResponse response = http.send(request);
        OwcCommunitySelfRegisterCtrl.verifyCaptcha( '6LftnNsaAAAAAI8IiySL5eTfN_MIhevenuugg2rW');
        OwcCommunitySelfRegisterCtrl.getValueFromJson('{"success":true,"error-codes": ["missing-input-secret"]}','success');
        Test.stopTest();
    }
}