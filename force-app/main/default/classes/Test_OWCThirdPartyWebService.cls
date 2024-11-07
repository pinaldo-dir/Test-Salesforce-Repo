@isTest
public class Test_OWCThirdPartyWebService {    
    
    
    @istest 
    public static void testOnlineWageClaimThirdPartyWebService(){ 
        
        Online_Claim_Draft__c owcDraftList = new Online_Claim_Draft__c();
        owcDraftList.Section_Id__c = '1';
        owcDraftList.Draft_JSON__c = 'Test area';
        insert owcDraftList;
        
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
        
        Id p = [select id from profile where name='Customer Online Claim User'].id;
        System.debug('Community profile::::'+p);
        
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
        
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        String typeId1 =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
        affA.RecordTypeId=typeId1; 
        insert affA;
        
        Contact portalContact = new Contact(  
            FirstName = 'portalContactFirst',  
            Lastname = 'portalContactLast',  
            AccountId = affA.Id,  
            Email = 'portalContact' + System.currentTimeMillis() + '@test.com'  
        );  
        insert portalContact;
        
        User communityUser = new User(  
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Online Claim User'].Id,  
            FirstName = 'CommunityUserFirst',  
            LastName = 'CommunityUserLast',  
            Email = 'community.user@test.com',  
            Username = 'community.user.' + System.currentTimeMillis() + '@test.com',  
            Title = 'Title',  
            Alias = 'Alias',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            EmailEncodingKey = 'UTF-8',  
            LanguageLocaleKey = 'en_US',  
            LocaleSidKey = 'en_US',
            ContactId = portalContact.id
        );
        insert communityUser;
        System.debug('communityUser::::'+communityUser);
        User  getUserRecord  = [SELECT Id, Name,accountId FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        
        DIR_Case__c c = new DIR_Case__c();
        c.Online_Claim_Account__c = getUserRecord.accountId;
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
        Online_Claim_Draft__c  owcDraftListGetRecord  = [SELECT Id, Name, Draft_JSON__c, Section_Id__c, Case_Management__c FROM Online_Claim_Draft__c];
        DateTime myDateTime = DateTime.newInstance(2000, 7, 7, 7, 8, 12);
        list<Case_Role__c> getDemoRole= [SELECT Id, Case__c, Entity__c,Role__c,recordTypeId FROM Case_Role__c];
        DIR_Case__c getDemoCase = [SELECT Id, Name, Bank__c FROM DIR_Case__c];
        Account ac=[SELECT Id, PersonEmail, firstName,lastName,Name,RecordTypeId FROM Account WHERE PersonEmail='abc@gmail.com' AND Name='abc xyz'];
        String recordId = owcDraftListGetRecord.Id;
        String sectionId = owcDraftListGetRecord.Section_Id__c;
        String caseId = getDemoCase.Id;
        
        
        System.debug('caseId:::'+caseId);
        
        /**User  getUserRecord  = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
System.debug('getUserRecord:::'+getUserRecord);
String userId = getUserRecord.Id;*/
        
        
        String userId = getUserRecord.Id;
        
        
        StaticResource srs = [SELECT Id, Body FROM StaticResource WHERE Name = 'OWCThirdPartyJsonTestData' LIMIT 1];
        system.debug('srs : ' + srs);
        system.debug('srs.Body : ' + srs.Body);
        String JsonMsg = srs.Body.toString();
        system.debug('JsonMsg : ' + JsonMsg);
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        system.debug('Jreq.requestBody ' + req.requestBody.toString());
        RestContext.request = req;
        RestContext.response= res;
        
        
        String powDetails = '{"paymentOfWagesDetails":{"pieceRateAdditionalDetails":[{"perUnitPaymentOfWagesAdditional":"test"}]}}';
        Map<String,Object> powDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(powDetails);
        System.debug('powDetailsTempMap::'+powDetailsTempMap);
        
        Map<String,Object> powDetailsMap = (Map<String,Object>) powDetailsTempMap.get('paymentOfWagesDetails');
        
        String powDetails1 = '{"paymentOfWagesDetails":{"hourlyAdditionalDetails":[{"hourlyRateBegDateAdditional":"2022"}]}}';
        Map<String,Object> powDetailsTempMap1 = (Map<String,Object>) json.deserializeUntyped(powDetails1);
        System.debug('powDetailsTempMap1::'+powDetailsTempMap1);
        
        Map<String,Object> powDetailsMap1 = (Map<String,Object>) powDetailsTempMap1.get('paymentOfWagesDetails');
        
        System.RunAs(getUserRecord){
            Test.startTest();
            Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                           Role__c = 'Claimant',
                                                           Street_Address__c = '123 Praire City Drive, Apt B',
                                                           City__c = 'Whittier',
                                                           State__c = 'CA',
                                                           Zip_Code__c = '90607',
                                                           RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                          );
            
            
            List<DIR_Case__c>d=new List<DIR_Case__c>();
            c.Status__c = 'Not Confirmed';
            d.add(c);
            update d;
            
            system.debug('Network ommunityId ****' + Network.getNetworkId());
            OnlineWageClaimThirdPartyWebService.getResponce();
            
            OnlineWageClaimThirdPartyAPIController.prepareFullName('obama','putin','modi');
            OnlineWageClaimThirdPartyAPIController.generatePDF(caseId,true);
            OnlineWageClaimThirdPartyAPIController.prepareCaseRole(userId,caseId);
            OnlineWageClaimThirdPartyAPIController.serverResponseWrapper serverWrapObj = new OnlineWageClaimThirdPartyAPIController.serverResponseWrapper();
            serverWrapObj.isSuccess = True;
            serverWrapObj.serverMsg = 'Success';
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap);
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap1);
            
            Test.stopTest();
        }
    }
    
    @istest 
    public static void testOnlineWageClaimThirdPartyWebService1(){         
        
        Online_Claim_Draft__c owcDraftList = new Online_Claim_Draft__c();
        owcDraftList.Section_Id__c = '1';
        owcDraftList.Draft_JSON__c = 'Test area';
        insert owcDraftList;
        
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
        
        Id p = [select id from profile where name='Customer Online Claim User'].id;
        System.debug('Community profile::::'+p);
        
        Account mainA = new Account();
        mainA.firstName='abc';
        mainA.lastName='xyz';
        mainA.PersonEmail='abc@gmail.com';
        mainA.ShippingPostalCode = '234889';
        
        String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        String typeId1 =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
        affA.RecordTypeId=typeId1; 
        insert affA;
        
        Contact portalContact = new Contact(  
            FirstName = 'portalContactFirst',  
            Lastname = 'portalContactLast',  
            AccountId = affA.Id,  
            Email = 'portalContact' + System.currentTimeMillis() + '@test.com'  
        );  
        insert portalContact;
        
        User communityUser = new User(  
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Online Claim User'].Id,  
            FirstName = 'CommunityUserFirst',  
            LastName = 'CommunityUserLast',  
            Email = 'community.user@test.com',  
            Username = 'community.user.' + System.currentTimeMillis() + '@test.com',  
            Title = 'Title',  
            Alias = 'Alias',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            EmailEncodingKey = 'UTF-8',  
            LanguageLocaleKey = 'en_US',  
            LocaleSidKey = 'en_US',
            ContactId = portalContact.id
        );
        insert communityUser;
        System.debug('communityUser::::'+communityUser);
        
        User  getUserRecord  = [SELECT Id, Name,accountId FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        String userId = getUserRecord.Id;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Online_Claim_Account__c = getUserRecord.accountId;
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
        
        StaticResource srs = [SELECT Id, Body FROM StaticResource WHERE Name = 'OWCThirdPartyJsonTestData' LIMIT 1];
        system.debug('srs : ' + srs);
        system.debug('srs.Body : ' + srs.Body);
        
        String JsonMsg = srs.Body.toString();
        
        Map<String,Object> jsonMap = (Map<String,Object>) json.deserializeUntyped(JsonMsg);
        Map<String,Object> addMap = (Map<String,Object>) jsonMap.get('additionalParams');
        JsonMsg = JsonMsg.replaceAll('Goku', userId);
        system.debug('JsonMsg :::' + JsonMsg);
        
        String powDetails = '{"paymentOfWagesDetails":{"salaryRateAdditionalDetails":[{"eachPayRateEndDateAdditional":"Test"}]}}';
        Map<String,Object> powDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(powDetails);
        System.debug('powDetailsTempMap::'+powDetailsTempMap);
        
        Map<String,Object> powDetailsMap = (Map<String,Object>) powDetailsTempMap.get('paymentOfWagesDetails');
        
        String powDetails1 = '{"paymentOfWagesDetails":{"hourlyAdditionalDetails":[{"hourlyRateEndDateAdditional":"2022"}]}}';
        Map<String,Object> powDetailsTempMap1 = (Map<String,Object>) json.deserializeUntyped(powDetails1);
        System.debug('powDetailsTempMap1::'+powDetailsTempMap1);
        
        Map<String,Object> powDetailsMap1 = (Map<String,Object>) powDetailsTempMap1.get('paymentOfWagesDetails');
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        //req.requestBody = Blob.valueOf(JSON.serializePretty(JsonMsg));
        req.requestBody = Blob.valueof(JsonMsg);
        system.debug('Jreq.requestBody ' + req.requestBody.toString());
        RestContext.request = req;
        RestContext.response= res;
        System.RunAs(getUserRecord){
            Test.startTest();        
            
            Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                           Role__c = 'Claimant',
                                                           Street_Address__c = '123 Praire City Drive, Apt B',
                                                           City__c = 'Whittier',
                                                           State__c = 'CA',
                                                           Zip_Code__c = '90607',
                                                           RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                          );
            
            
            List<DIR_Case__c>d=new List<DIR_Case__c>();
            c.Status__c = 'Not Confirmed';
            d.add(c);
            update d; 
            
            OnlineWageClaimThirdPartyWebService.getResponce();
            OnlineWageClaimThirdPartyAPIController.todayDate();
            OnlineWageClaimThirdPartyAPIController.communityUserId = '';
            OnlineWageClaimThirdPartyAPIController.userRec = getUserRecord;
            OnlineWageClaimThirdPartyAPIController.additionalParams = addMap;
            OnlineWageClaimThirdPartyAPIController.fieldValidationError = 'Not blank';
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap);
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap1);
            
            Test.stopTest();
        }
        
    }    
    
    @istest 
    public static void testOnlineWageClaimThirdPartyWebService2(){         
        
        Online_Claim_Draft__c owcDraftList = new Online_Claim_Draft__c();
        owcDraftList.Section_Id__c = '1';
        owcDraftList.Draft_JSON__c = 'Test area';
        insert owcDraftList;
        
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
        
        Id p = [select id from profile where name='Customer Online Claim User'].id;
        System.debug('Community profile::::'+p);
        
        Account mainA = new Account();
        mainA.firstName='abc';
        mainA.lastName='xyz';
        mainA.PersonEmail='abc@gmail.com';
        mainA.ShippingPostalCode = '234889';
        
        String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        String typeId1 =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
        affA.RecordTypeId=typeId1; 
        insert affA;
        
        Contact portalContact = new Contact(  
            FirstName = 'portalContactFirst',  
            Lastname = 'portalContactLast',  
            AccountId = affA.Id,  
            Email = 'portalContact' + System.currentTimeMillis() + '@test.com'  
        );  
        insert portalContact;
        
        User communityUser = new User(  
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Online Claim User'].Id,  
            FirstName = 'CommunityUserFirst',  
            LastName = 'CommunityUserLast',  
            Email = 'community.user@test.com',  
            Username = 'community.user.' + System.currentTimeMillis() + '@test.com',  
            Title = 'Title',  
            Alias = 'Alias',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            EmailEncodingKey = 'UTF-8',  
            LanguageLocaleKey = 'en_US',  
            LocaleSidKey = 'en_US',
            ContactId = portalContact.id
        );
        insert communityUser;
        System.debug('communityUser::::'+communityUser);
        
        User  getUserRecord  = [SELECT Id, Name,accountId FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Online_Claim_Account__c = getUserRecord.accountId;
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
        
        Online_claim__c testOc = new Online_claim__c(Missed_Work__c = '2');
        insert testOc;
        
        String srs1 = '{"additionalParams":{"thirdPartySource":"Test Portal","communityUserId":"Goku"},"certAndAuthDetails":{"isAuthorizationRelease":true,"isAdditionalClaimDocUpload":false,"claimantName":"test","claimDate":"2022-04-10","addtionalClaimDocs":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}]},"claimantEmployeeValues":{"countryCodeindividualRepPhone":"+1","countryCodelawfirmRepStatePhone":"+1","isClaimantConfirmation":true,"claimantConfirmUploadDoc":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}],"claimantDetails":{"yourselfFirstName":"test name","yourselfLastName":"test last name","yourselfMiddleName":"test middle name","yourselfHomePhone":"1234567890","yourselfCellPhone":"1234567890","countryCodeyourselfCellPhone":"+1","countryCodeyourselfHomePhone":"+1","isCellPhoneEntered":true,"yourselfBirthDate":"2022-03-27","yourselfEmail":"akash.som@cloudsciencelabs.com","yourselfStreetAddress":"test street ","yourselfCity":"test city","yourselfState":"CA","yourselfZipCode":"12345-6544","needLanguageInterpreter":"Yes","isPrefferedLanguage":true,"isOtherPrefferedLanguage":true,"prefferedLanguageSelection":"Other","otherPrefferedLanguage":"Hindi"},"isRepresentative":true,"isYourself":true,"WageClaimSubmit":null,"representativeAdvocateType":null,"lawfirmRepBusinessName":null,"lawfirmRepAttorney":"New Online Claim","lawfirmRepStreetAddress":"test street","lawfirmRepCity":"test city","lawfirmRepState":"CA","lawfirmRepStatePhone":"1234567890","lawFirmRepZipCode":"23122-3333","lawfirmRepEmail":"somakash999@gmail.com","lawfirmRepWebsite":"https://www.google"},"demoGraphicInfoData":{"DemographicGenderIdentity":"Male","DemographicSexualOrientation":"Other","DemographicRace":"American Indian, Native American or Alaskan Native","GenderOther":"","SexualOrientationOther":"543","DemographicRaceOther":"","isGenderOther":false,"isSexualOrientationOther":false,"isDemographicRaceOther":false},"employeeStatusAndFinalClaimDetails":{"QuitDateTemplate":false,"DischargeDateTemplate":true,"hireDate":"2022-03-27","nameOfPersonWhoHiredYou":"sd","wereWagesPaid":"Yes","howWereYourWagesPaid":"Cash","isCheck":false,"paidByCheck":null,"chequeReplacedDate":null,"isOther":false,"Explanation":null,"statementReceived":"Yes","isPayStubRecord":true,"stillIdentifiedEmp":"No","selectAnyOne":"I was discharged/laid off","isstillIdentifiedEmp":true,"quitDate":null,"noticeBeforeQuiting":null,"receivedFinalPayment":null,"isreceivedFinalPayment":false,"isDidntReceivedFinalPayment":false,"finalPaymentDate":null,"finalPaymentExplanation":null,"dischargedDate":"2022-03-27","personNameWhoDischargeYou":"test","receivedFinalPayment2":"No","isreceivedFinalPayment2":false,"isDidntReceivedFinalPayment2":true,"DateFS2":null,"payStubSickRecord":"No","dischargedExplanation":"test"},"employeesDetails":[{"countryCodeindividualBusinessPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeOtherIndividualPhone":"+1","employerChangedName":"Yes","isEmployerChangedName":true,"isOfficeLocatorMail":false,"IsIndividual":true,"IsOther":false,"additionalWHOPaidYou":"test","owcWorkRecordList":"Card swipe machine","additionalBankName":"test","representativeEmployerType":"Individual/Sole Proprietor","individualFirstName":"test name","individualLastName":"test","individualStreetAddress":"test street","individualCity":"test city","individualState":"CA","IsAdditionalInfo":false,"individualZipCode":"12345-6789","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"akash.som@cloudsciencelabs.com","individualVehicleLicense":"1234567890","individualWebsite":"google.com","OtherIndividualBusinessName":null,"OtherIndividualStreetAddress":null,"OtherIndividualCity":null,"OtherIndividualState":"CA","OtherIndividualZipCode":null,"OtherIndividualPhone":null,"OtherIndividualEmail":null,"OtherIndividualVehicleLicense":null,"OtherIndividualWebsite":null,"additionalDifferentPerson":"test","additionalSignTimeCard":"Yes","additionalSomeoneElse":"test","additionalTotalEmployees":"11","additionalEmpBusiness":"I dont know","additionalBankruptcy":"Yes","IsOtherIndividual":false,"unionContractCovering":"Yes","urlAddress":"https://www.regextester.com/93652","isUnionContractCovered":true,"unionContractCovered":"Your unions website address","filingWageClaim":"I dont know","isEmployeeFilingWageClaim":true,"specifyFilingWageClaim":"Other – please explain","covid19Claim":"Yes","isEmployeeFilingWageClaimOther":true,"specifyOtherReason":"test","isDontKnow":false,"isUrlAddress":true,"isMailToOfficeLocator":false,"otherPleaseExplain":"","isSignCard":true,"signCardName":"test","retaliationComplain":"Yes","isRetaliationComplain":true,"complainFiledDate":"2022-03-27","complainCaseNumber":"test","isRetaliationComplainFalse":false,"employerNameChangedDetails":{"additionalTotalEmployees":"21","IsIndividual":true,"IsOther":false,"representativeEmployerType":"Individual/Sole Proprietor","individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-6543","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"test@gmail.com","individualVehicleLicense":"testgjbsxn","individualWebsite":"google.com","IsOtherIndividual":false,"OtherIndividualBusinessName":null,"OtherIndividualStreetAddress":null,"OtherIndividualCity":null,"OtherIndividualState":"CA","OtherIndividualZipCode":null,"OtherIndividualPhone":null,"OtherIndividualEmail":null,"OtherIndividualVehicleLicense":null,"OtherIndividualWebsite":null},"startingDate":"2022-03-27","endingDate":"2022-03-31","employerChangedNameAfterEmployement":"Yes","isEmployerChangedNameAfterEmployement":true,"successorDetails":{"successorDetails":[{"workForThisComp":"Yes","workWithSameWorokers":"Yes","ownershipOfCompRelated":"Owner(s) of both were same","employerNameAfterEmployementDetails":{"additionalTotalEmployees":"22","IsIndividual":true,"isClaimantAdvocate":true,"isOtherIndividualPicklist":false,"isIndividualStatePicklist":true,"IsOther":false,"representativeEmployerType":"Individual/Sole Proprietor","showIndividualSole":true,"individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-6765","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"test@gmail.com","individualVehicleLicense":"1234565423","individualWebsite":"google.com","OtherIndividualState":"CA","IsOtherIndividual":false,"isDontKnow":false,"IndividualFirstNamerequired":true,"IndividualStreetAddressrequired":true,"IndividualCityrequired":true,"IndividualStaterequired":true,"IndividualZipCoderequired":true,"IndividualBusinessPhonerequired":true,"OtherStreetAddressrequired":false,"OtherCityrequired":false,"OtherStaterequired":false,"OtherZipCoderequired":false,"OtherBusinessPhonerequired":false}}]},"mileageClaimDetails":[{"additinalPersonLastName":"test","additinalPersonFirstName":"test","claimantRelatedRoleActions":"test"}]}],"hoursYouTypicallyWorkedDetails":{"workMissedReason":"Yes","daysMissed":"56","whyDaysMissed":"test","specifyTypicalyyworked":"My work hours and days of work were usually the same each week that I worked","selectedHolidayOptions":["New Years Day (January 1)","Other holidays you did not work"],"isSameWeekDaysAndHours":true,"isDaysOrWeekVaried":false,"isWorkMissedReason":true,"companyHolidaySelection":["New Years Day (January 1)","Other holidays you did not work"],"isCompanyHolidayOther":true,"otherHolidaySelection":"test","overTimeSheet":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}],"isOverTimeSheetUploaded":true,"timeEntriesDetail":[{"name":"Friday","startTime":"00:00:00.000","endTime":"00:30:00.000","dateDiffer":true,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 30min","issameScheduled":false,"isChecked":false},{"name":"Saturday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":false,"isChecked":true},{"name":"Sunday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Monday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Tuesday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Wednesday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Thursday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true}]},"industryInfoDataValues":{"paidBreaks":"Yes","OtherIndividualConstructionTrades":"","selectedIndustry":"Agriculture","rateOfCompensation":"Yes","farmWorker":"Yes","heatRecovery":"Yes","writtenReqDate":"2022-03-27","statementDate":"2022-03-27","empStatementProvided":"Yes","domesticWorkType":"","isHouseDomesticWorker":false,"isHousePersonalAttendent":false,"domesticRegisteredNurse":"","domesticLiveInWorkHome":"","domesticSentByHomeAgency":"","isLabelsInfo":false,"isClaimantGarment":false,"listOfDuties":"test","selectedIndustryValue":"Agriculture - Farm Labor (work done in the fields)","isGarmentDutyFollow":"No"},"labelDetails":{"labelDetails":[{"labelName":"56","labelGarmentDescription":"test","labelGarmentsDuration":"Daily","isOther":false,"Other":"test","labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-15","labelEndDate":"2022-05-19","islabelPercPerDay":false,"namePersonVisit":"test 4t","sampleOfGarment":"Yes","labelGarmentDelAdd":"sIM","labelPercProvided":"99","superVisorCheck":"Yes","isSuperVisorCheck":true},{"labelName":"67","labelGarmentDescription":"test 3","labelGarmentsDuration":"Monthly","isOther":false,"labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-08","labelEndDate":"2022-05-18","islabelPercPerDay":false,"namePersonVisit":"test name","sampleOfGarment":"Yes","labelGarmentDelAdd":"Som","labelPercProvided":"88","superVisorCheck":"Yes","isSuperVisorCheck":true}]},"otherLocWorkInfo":{"workLocationBusinessAddress":"Yes","isBusinessAddressDifferent":true,"otherBusinessStreetAddress":"test","otherBusinessCity":"New York","approximateLocation":"test","countryCode":"+1","otherBusinessState":"CA","otherBusinessZipCode":"10014","otherBusinessPhone":"2124683378"},"paymentOfWagesDetails":{"value":"","isOneHourlyRate":true,"paidAmountPerHour":"12","promisedAmountPerHour":"45","hourlyRateBegDate":"2022-03-27","hourlyRateEndDate":"2022-03-31","isDifferentHourRate":true,"paidAmountDifferentHour":"12","promisedAmountDifferentHour":"22","forActivity":"fds","forActivityAdditional":null,"differentHourlyRateBegDate":"2022-03-28","differentHourlyRateEndDate":"2022-04-08","isSalaryRateForEachDay":true,"paidAmountForEachDay":"12","promisedAmountForEachDay":"22","frequencyOfEachDay":"Day","eachPayRateBegDate":"2022-03-27","eachPayRateEndDate":"2022-03-31","isCommissionRate":true,"writtenCommission":"Yes","isWrittenCommission":true,"commissionRateBegDate":null,"commissionRateEndDate":null,"isFileUploaded":false,"isPieceRate":true,"paidPieceRate":"22","promisedPieceRate":"2421","perUnitPaymentOfWages":"Bin","other":null,"numberOfUnits":"98","pieceRateBegDate":"2022-03-27","pieceRateEndDate":"2022-03-30","pieceRateTotalEarned":"55","pieceRateTotalPaid":"45","isProvidePriceRate":false,"otherAdditional":null,"paymentOfWagesForGarmentDetails":[],"differentHourAdditionalDetails":[],"hourlyAdditionalDetails":[],"salaryRateAdditionalDetails":[],"pieceRateAdditionalDetails":[],"HourlyOptionValue":true,"pieceRateOptionValue":true,"commissionRateOptionValue":true,"salaryRateOptionValue":true,"differentHourOptionValue":true},"workWeekAndWorkDaysDetails":{"EmpFollowSatToSun":"No","isEmpFollowSatToSun":true,"EmpDefinedWorkweek":"Friday to Thursday","EmpFollowMidnightToMidnight":"No","isEmpFollowMidnightToMidnight":true,"BegDate":"00:00:00.000","EndDate":"00:00:00.000","workWeekValue":6}}';
            
            StaticResource srs = [SELECT Id, Body FROM StaticResource WHERE Name = 'OWCThirdPartyJsonTestData' LIMIT 1];
        system.debug('srs : ' + srs);
        system.debug('srs.Body : ' + srs.Body);
        
        
        String userId = getUserRecord.Id;
        
        String JsonMsg = srs1;
        
        JsonMsg = JsonMsg.replaceAll('Goku', '');
        system.debug('JsonMsg :::' + JsonMsg);
        
        Map<String,Object> jsonMap = (Map<String,Object>) json.deserializeUntyped(JsonMsg);
        Map<String,Object> otherWorkLocMap = (Map<String,Object>) jsonMap.get('otherLocWorkInfo');
        Map<String,Object> finalWagesMap = new Map<String,Object>();
        finalWagesMap = null;
        
        String workWeekWorkDay = '{"workWeekAndWorkDaysDetails":{"EmpFollowSatToSun":null,"isEmpFollowSatToSun":true,"EmpDefinedWorkweek":null,"EmpFollowMidnightToMidnight":"True","isEmpFollowMidnightToMidnight":true,"BegDate":"00:00:00.000","EndDate":"00:00:00.000","workWeekValue":6}}';
        Map<String,Object> workWeekWorkDayTempMap = (Map<String,Object>) json.deserializeUntyped(workWeekWorkDay);
        System.debug('workWeekWorkDayTempMap::'+workWeekWorkDayTempMap);
        
        Map<String,Object> workWeekWorkDayMap = (Map<String,Object>) workWeekWorkDayTempMap.get('workWeekAndWorkDaysDetails');
        
        String demoGraphicInfoData = '{"demoGraphicInfoData":{"DemographicGenderIdentity":"Male","DemographicSexualOrientation":"Test","DemographicRace":"American Indian, Native American or Alaskan Native","GenderOther":"","SexualOrientationOther":"543","DemographicRaceOther":"","isGenderOther":false,"isSexualOrientationOther":true,"isDemographicRaceOther":false}}';
        Map<String,Object> demoGraphicInfoDataTempMap = (Map<String,Object>) json.deserializeUntyped(demoGraphicInfoData);
        System.debug('demoGraphicInfoDataMap::'+demoGraphicInfoDataTempMap);
        
        Map<String,Object> demoGraphicInfoDataMap = (Map<String,Object>) demoGraphicInfoDataTempMap.get('demoGraphicInfoData');
        
        String powDetails = '{"paymentOfWagesDetails":{"pieceRateAdditionalDetails":[{"pieceRateBegDateAdditional":"2022"}]}}';
        Map<String,Object> powDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(powDetails);
        System.debug('powDetailsTempMap::'+powDetailsTempMap);
        
        Map<String,Object> powDetailsMap = (Map<String,Object>) powDetailsTempMap.get('paymentOfWagesDetails');
        
        
        String powDetails1 = '{"paymentOfWagesDetails":{"differentHourAdditionalDetails":[{"differentHourlyRateBegDateAdditional":"2022"}]}}';
        Map<String,Object> powDetailsTempMap1 = (Map<String,Object>) json.deserializeUntyped(powDetails1);
        System.debug('powDetailsTempMap1::'+powDetailsTempMap1);
        
        Map<String,Object> powDetailsMap1 = (Map<String,Object>) powDetailsTempMap1.get('paymentOfWagesDetails');
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        //req.requestBody = Blob.valueOf(JSON.serializePretty(JsonMsg));
        req.requestBody = Blob.valueof(JsonMsg);
        system.debug('Jreq.requestBody ' + req.requestBody.toString());
        RestContext.request = req;
        RestContext.response= res;
        System.RunAs(getUserRecord){
            Test.startTest();        
            
            Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                           Role__c = 'Claimant',
                                                           Street_Address__c = '123 Praire City Drive, Apt B',
                                                           City__c = 'Whittier',
                                                           State__c = 'CA',
                                                           Zip_Code__c = '90607',
                                                           RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                          );
            
            
            List<DIR_Case__c>d=new List<DIR_Case__c>();
            c.Status__c = 'Not Confirmed';
            d.add(c);
            update d;
            
            OnlineWageClaimThirdPartyWebService.getResponce();
            OnlineWageClaimThirdPartyAPIController.onlineClaimSubmit(JsonMsg);
            OnlineWageClaimThirdPartyAPIController.todayDate();
            OWCOnlineClaimThirdPartyAPIService.workweekAndWorkDaysCheck(workWeekWorkDayMap);
            OWCOnlineClaimThirdPartyAPIService.populateOtherWorkLocation(jsonMap,c,objRL1);
            OWCOnlineClaimThirdPartyAPIService.populateFinalWagesData(finalWagesMap,c,testOc);
            OWCOnlineClaimThirdPartyAPIService.demograhicInfoCheck(demoGraphicInfoDataMap);
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap);
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap1);
            
            Test.stopTest();   
        }
    }    
    
    @istest 
    public static void testOnlineWageClaimThirdPartyWebService3(){         
        
        Online_Claim_Draft__c owcDraftList = new Online_Claim_Draft__c();
        owcDraftList.Section_Id__c = '1';
        owcDraftList.Draft_JSON__c = 'Test area';
        insert owcDraftList;
        
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
        
        Id p = [select id from profile where name='Customer Online Claim User'].id;
        System.debug('Community profile::::'+p);
        
        Account mainA = new Account();
        mainA.firstName='abc';
        mainA.lastName='xyz';
        mainA.PersonEmail='abc@gmail.com';
        mainA.ShippingPostalCode = '234889';
        
        String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        String typeId1 =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
        affA.RecordTypeId=typeId1; 
        insert affA;
        
        Contact portalContact = new Contact(  
            FirstName = 'portalContactFirst',  
            Lastname = 'portalContactLast',  
            AccountId = affA.Id,  
            Email = 'portalContact' + System.currentTimeMillis() + '@test.com'  
        );  
        insert portalContact;
        
        User communityUser = new User(  
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Online Claim User'].Id,  
            FirstName = 'CommunityUserFirst',  
            LastName = 'CommunityUserLast',  
            Email = 'community.user@test.com',  
            Username = 'community.user.' + System.currentTimeMillis() + '@test.com',  
            Title = 'Title',  
            Alias = 'Alias',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            EmailEncodingKey = 'UTF-8',  
            LanguageLocaleKey = 'en_US',  
            LocaleSidKey = 'en_US',
            ContactId = portalContact.id
        );
        insert communityUser;
        System.debug('communityUser::::'+communityUser);
        
        User  getUserRecord  = [SELECT Id, Name,accountId FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        
        DIR_Case__c c = new DIR_Case__c();
        c.Online_Claim_Account__c = getUserRecord.accountId;
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
        
        Online_claim__c testOc = new Online_claim__c(Missed_Work__c = '2');
        insert testOc;
        
        String srs1 = '{"additionalParams":{"thirdPartySource":"Test Portal","communityUserId":"Goku"},"certAndAuthDetails":{"isAuthorizationRelease":true,"isAdditionalClaimDocUpload":false,"claimantName":"test","claimDate":"2022-04-10","addtionalClaimDocs":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}]},"claimantEmployeeValues":{"countryCodeindividualRepPhone":"+1","countryCodelawfirmRepStatePhone":"+1","isClaimantConfirmation":true,"claimantConfirmUploadDoc":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}],"claimantDetails":{"yourselfFirstName":"test name","yourselfLastName":"test last name","yourselfMiddleName":"test middle name","yourselfHomePhone":"1234567890","yourselfCellPhone":"1234567890","countryCodeyourselfCellPhone":"+1","countryCodeyourselfHomePhone":"+1","isCellPhoneEntered":true,"yourselfBirthDate":"2022-03-27","yourselfEmail":"akash.som@cloudsciencelabs.com","yourselfStreetAddress":"test street ","yourselfCity":"test city","yourselfState":"CA","yourselfZipCode":"12345-6544","needLanguageInterpreter":"Yes","isPrefferedLanguage":true,"isOtherPrefferedLanguage":true,"prefferedLanguageSelection":"Other","otherPrefferedLanguage":"Hindi"},"isRepresentative":true,"isYourself":true,"WageClaimSubmit":"Representative","representativeAdvocateType":"Law Firm / Organization","lawfirmRepBusinessName":"Test Name","lawfirmRepAttorney":"New Online Claim","lawfirmRepStreetAddress":"test street","lawfirmRepCity":"test city","lawfirmRepState":"CA","lawfirmRepStatePhone":"1234567890","lawFirmRepZipCode":"23122-3333","lawfirmRepEmail":"somakash999@gmail.com","lawfirmRepWebsite":"https://www.google"},"demoGraphicInfoData":{"DemographicGenderIdentity":"Male","DemographicSexualOrientation":"Straight","DemographicRace":"American Indian, Native American or Alaskan Native","GenderOther":"","SexualOrientationOther":"","DemographicRaceOther":"","isGenderOther":false,"isSexualOrientationOther":false,"isDemographicRaceOther":false},"employeeStatusAndFinalClaimDetails":{"QuitDateTemplate":false,"DischargeDateTemplate":true,"hireDate":"2022-03-27","nameOfPersonWhoHiredYou":"sd","wereWagesPaid":"Yes","howWereYourWagesPaid":"Cash","isCheck":false,"paidByCheck":null,"chequeReplacedDate":null,"isOther":false,"Explanation":null,"statementReceived":"Yes","isPayStubRecord":true,"stillIdentifiedEmp":"No","selectAnyOne":"I was discharged/laid off","isstillIdentifiedEmp":true,"quitDate":"2022-03-27","noticeBeforeQuiting":null,"receivedFinalPayment":null,"isreceivedFinalPayment":false,"isDidntReceivedFinalPayment":false,"finalPaymentDate":null,"finalPaymentExplanation":null,"dischargedDate":"2022-03-27","personNameWhoDischargeYou":"test","receivedFinalPayment2":"No","isreceivedFinalPayment2":false,"isDidntReceivedFinalPayment2":true,"DateFS2":null,"payStubSickRecord":"No","dischargedExplanation":"test"},"employeesDetails":[{"countryCodeindividualBusinessPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeOtherIndividualPhone":"+1","employerChangedName":"Yes","isEmployerChangedName":true,"isOfficeLocatorMail":false,"IsIndividual":true,"IsOther":false,"additionalWHOPaidYou":"test","owcWorkRecordList":"Card swipe machine","additionalBankName":"test","representativeEmployerType":"Corporation","individualFirstName":"test name","individualLastName":"test","individualStreetAddress":"test street","individualCity":"test city","individualState":"CA","IsAdditionalInfo":false,"individualZipCode":"12345-6789","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"akash.som@cloudsciencelabs.com","individualVehicleLicense":"1234567890","individualWebsite":"google.com","OtherIndividualBusinessName":"test","OtherIndividualStreetAddress":"test","OtherIndividualCity":"test","OtherIndividualState":"CA","OtherIndividualZipCode":"12345","OtherIndividualPhone":"1234567890","OtherIndividualEmail":"test@test.com","OtherIndividualVehicleLicense":null,"OtherIndividualWebsite":null,"additionalDifferentPerson":"test","additionalSignTimeCard":"Yes","additionalSomeoneElse":"test","additionalTotalEmployees":"11","additionalEmpBusiness":"I dont know","additionalBankruptcy":"Yes","IsOtherIndividual":false,"unionContractCovering":"Yes","urlAddress":"https://www.regextester.com/93652","isUnionContractCovered":true,"unionContractCovered":"Your unions website address","filingWageClaim":"I dont know","isEmployeeFilingWageClaim":true,"specifyFilingWageClaim":"Other – please explain","covid19Claim":"Yes","isEmployeeFilingWageClaimOther":true,"specifyOtherReason":"test","isDontKnow":false,"isUrlAddress":true,"isMailToOfficeLocator":false,"otherPleaseExplain":"","isSignCard":true,"signCardName":"test","retaliationComplain":"Yes","isRetaliationComplain":true,"complainFiledDate":"2022-03-27","complainCaseNumber":"test","isRetaliationComplainFalse":false,"employerNameChangedDetails":{"additionalTotalEmployees":"21","IsIndividual":true,"IsOther":false,"representativeEmployerType":"Corporation","individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-6543","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"test@gmail.com","individualVehicleLicense":"testgjbsxn","individualWebsite":"google.com","IsOtherIndividual":false,"OtherIndividualBusinessName":"test","OtherIndividualStreetAddress":"test","OtherIndividualCity":"test","OtherIndividualState":"CA","OtherIndividualZipCode":"12345","OtherIndividualPhone":"1234567890","OtherIndividualEmail":"test@test.com","OtherIndividualVehicleLicense":null,"OtherIndividualWebsite":null},"startingDate":"2022-03-27","endingDate":"2022-03-31","employerChangedNameAfterEmployement":"Yes","isEmployerChangedNameAfterEmployement":true,"successorDetails":{"successorDetails":[{"workForThisComp":"Yes","workWithSameWorokers":"Yes","ownershipOfCompRelated":"Owner(s) of both were same","employerNameAfterEmployementDetails":{"additionalTotalEmployees":"22","IsIndividual":true,"isClaimantAdvocate":true,"isOtherIndividualPicklist":false,"isIndividualStatePicklist":true,"IsOther":false,"representativeEmployerType":"Corporation","showIndividualSole":true,"individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-6765","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"test@gmail.com","individualVehicleLicense":"1234565423","individualWebsite":"google.com","OtherIndividualState":"CA","IsOtherIndividual":false,"isDontKnow":false,"IndividualFirstNamerequired":true,"IndividualStreetAddressrequired":true,"IndividualCityrequired":true,"IndividualStaterequired":true,"IndividualZipCoderequired":true,"IndividualBusinessPhonerequired":true,"OtherStreetAddressrequired":false,"OtherCityrequired":false,"OtherStaterequired":false,"OtherZipCoderequired":false,"OtherBusinessPhonerequired":false}}]},"mileageClaimDetails":[{"additinalPersonLastName":"test","additinalPersonFirstName":"test","claimantRelatedRoleActions":"test"}]}],"hoursYouTypicallyWorkedDetails":{"workMissedReason":"Yes","daysMissed":"56","whyDaysMissed":"test","specifyTypicalyyworked":"My work hours and days of work were usually the same each week that I worked","selectedHolidayOptions":["New Years Day (January 1)","Other holidays you did not work"],"isSameWeekDaysAndHours":true,"isDaysOrWeekVaried":false,"isWorkMissedReason":true,"companyHolidaySelection":["New Years Day (January 1)","Other holidays you did not work"],"isCompanyHolidayOther":true,"otherHolidaySelection":"test","overTimeSheet":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}],"isOverTimeSheetUploaded":true,"timeEntriesDetail":[{"name":"Friday","startTime":"00:00:00.000","endTime":"00:30:00.000","dateDiffer":true,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 30min","issameScheduled":false,"isChecked":false},{"name":"Saturday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":false,"isChecked":true},{"name":"Sunday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Monday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Tuesday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Wednesday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Thursday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true}]},"industryInfoDataValues":{"paidBreaks":"Yes","OtherIndividualConstructionTrades":"","selectedIndustry":"Agriculture","rateOfCompensation":"Yes","farmWorker":"Yes","heatRecovery":"Yes","writtenReqDate":"2022-03-27","statementDate":"2022-03-27","empStatementProvided":"Yes","domesticWorkType":"","isHouseDomesticWorker":false,"isHousePersonalAttendent":false,"domesticRegisteredNurse":"","domesticLiveInWorkHome":"","domesticSentByHomeAgency":"","isLabelsInfo":false,"isClaimantGarment":false,"listOfDuties":"test","selectedIndustryValue":"Agriculture - Farm Labor (work done in the fields)","isGarmentDutyFollow":"No"},"labelDetails":{"labelDetails":[{"labelName":"56","labelGarmentDescription":"test","labelGarmentsDuration":"Daily","isOther":false,"Other":"test","labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-15","labelEndDate":"2022-05-19","islabelPercPerDay":false,"namePersonVisit":"test 4t","sampleOfGarment":"Yes","labelGarmentDelAdd":"sIM","labelPercProvided":"99","superVisorCheck":"Yes","isSuperVisorCheck":true},{"labelName":"67","labelGarmentDescription":"test 3","labelGarmentsDuration":"Monthly","isOther":false,"labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-08","labelEndDate":"2022-05-18","islabelPercPerDay":false,"namePersonVisit":"test name","sampleOfGarment":"Yes","labelGarmentDelAdd":"Som","labelPercProvided":"88","superVisorCheck":"Yes","isSuperVisorCheck":true}]},"otherLocWorkInfo":{"workLocationBusinessAddress":"Yes","isBusinessAddressDifferent":true,"otherBusinessStreetAddress":"test","otherBusinessCity":"New York","approximateLocation":"test","countryCode":"+1","otherBusinessState":"CA","otherBusinessZipCode":"10014","otherBusinessPhone":"2124683378"},"paymentOfWagesDetails":{"value":"","isOneHourlyRate":true,"paidAmountPerHour":"12","promisedAmountPerHour":"45","hourlyRateBegDate":"2022-03-27","hourlyRateEndDate":"2022-03-31","isDifferentHourRate":true,"paidAmountDifferentHour":"12","promisedAmountDifferentHour":"22","forActivity":"fds","forActivityAdditional":null,"differentHourlyRateBegDate":"2022-03-28","differentHourlyRateEndDate":"2022-04-08","isSalaryRateForEachDay":true,"paidAmountForEachDay":"12","promisedAmountForEachDay":"22","frequencyOfEachDay":"Day","eachPayRateBegDate":"2022-03-27","eachPayRateEndDate":"2022-03-31","isCommissionRate":true,"writtenCommission":"Yes","isWrittenCommission":true,"commissionRateBegDate":null,"commissionRateEndDate":null,"isFileUploaded":false,"isPieceRate":true,"paidPieceRate":"22","promisedPieceRate":"2421","perUnitPaymentOfWages":"Bin","other":null,"numberOfUnits":"98","pieceRateBegDate":"2022-03-27","pieceRateEndDate":"2022-03-30","pieceRateTotalEarned":"55","pieceRateTotalPaid":"45","isProvidePriceRate":false,"otherAdditional":null,"paymentOfWagesForGarmentDetails":[],"differentHourAdditionalDetails":[],"hourlyAdditionalDetails":[],"salaryRateAdditionalDetails":[],"pieceRateAdditionalDetails":[],"HourlyOptionValue":true,"pieceRateOptionValue":true,"commissionRateOptionValue":true,"salaryRateOptionValue":true,"differentHourOptionValue":true},"workWeekAndWorkDaysDetails":{"EmpFollowSatToSun":"No","isEmpFollowSatToSun":true,"EmpDefinedWorkweek":"Friday to Thursday","EmpFollowMidnightToMidnight":"No","isEmpFollowMidnightToMidnight":true,"BegDate":"00:00:00.000","EndDate":"00:00:00.000","workWeekValue":6}}';
            
            
            
        String userId = getUserRecord.Id;
        
        String JsonMsg = srs1;
        
        JsonMsg = JsonMsg.replaceAll('Goku', userId);
        system.debug('JsonMsg :::' + JsonMsg);
        
        Map<String,Object> jsonMap = (Map<String,Object>) json.deserializeUntyped(JsonMsg);
        Map<String,Object> otherWorkLocMap = (Map<String,Object>) jsonMap.get('otherLocWorkInfo');
        Map<String,Object> finalWagesMap = new Map<String,Object>();
        finalWagesMap = null;
        
        String workWeekWorkDay = '{"workWeekAndWorkDaysDetails":{"EmpFollowSatToSun":null,"isEmpFollowSatToSun":true,"EmpDefinedWorkweek":"test","EmpFollowMidnightToMidnight":"True+","isEmpFollowMidnightToMidnight":true,"BegDate":"00:00:00.000","EndDate":"00:00:00.000","workWeekValue":6}}';
        Map<String,Object> workWeekWorkDayTempMap = (Map<String,Object>) json.deserializeUntyped(workWeekWorkDay);
        System.debug('workWeekWorkDayTempMap::'+workWeekWorkDayTempMap);
        
        Map<String,Object> workWeekWorkDayMap = (Map<String,Object>) workWeekWorkDayTempMap.get('workWeekAndWorkDaysDetails');
        
        String demoGraphicInfoData = '{"demoGraphicInfoData":{"DemographicGenderIdentity":"Male","DemographicSexualOrientation":"Other","DemographicRace":"Test Race","GenderOther":"","SexualOrientationOther":"543","DemographicRaceOther":"","isGenderOther":false,"isSexualOrientationOther":true,"isDemographicRaceOther":false}}';
        Map<String,Object> demoGraphicInfoDataTempMap = (Map<String,Object>) json.deserializeUntyped(demoGraphicInfoData);
        System.debug('demoGraphicInfoDataTempMap::'+demoGraphicInfoDataTempMap);
        
        Map<String,Object> demoGraphicInfoDataMap = (Map<String,Object>) demoGraphicInfoDataTempMap.get('demoGraphicInfoData');
        
        String powDetails = '{"paymentOfWagesDetails":{"pieceRateAdditionalDetails":[{"pieceRateEndDateAdditional":"2022"}]}}';
        Map<String,Object> powDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(powDetails);
        System.debug('powDetailsTempMap::'+powDetailsTempMap);
        
        Map<String,Object> powDetailsMap = (Map<String,Object>) powDetailsTempMap.get('paymentOfWagesDetails');
        
        String powDetails1 = '{"paymentOfWagesDetails":{"differentHourAdditionalDetails":[{"differentHourlyRateEndDateAdditional":"2022"}]}}';
        Map<String,Object> powDetailsTempMap1 = (Map<String,Object>) json.deserializeUntyped(powDetails1);
        System.debug('powDetailsTempMap1::'+powDetailsTempMap1);
        
        Map<String,Object> powDetailsMap1 = (Map<String,Object>) powDetailsTempMap1.get('paymentOfWagesDetails');
        
        String powDetails2 = '{"paymentOfWagesDetails":{"perUnitPaymentOfWages:":"two"}}';
        Map<String,Object> powDetailsTempMap2 = (Map<String,Object>) json.deserializeUntyped(powDetails2);
        System.debug('powDetailsTempMap2::'+powDetailsTempMap2);
        
        Map<String,Object> powDetailsMap2 = (Map<String,Object>) powDetailsTempMap2.get('paymentOfWagesDetails');
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        //req.requestBody = Blob.valueOf(JSON.serializePretty(JsonMsg));
        req.requestBody = Blob.valueof(JsonMsg);
        system.debug('Jreq.requestBody ' + req.requestBody.toString());
        RestContext.request = req;
        RestContext.response= res;
        System.RunAs(getUserRecord){
            Test.startTest();        
            
            Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                           Role__c = 'Claimant',
                                                           Street_Address__c = '123 Praire City Drive, Apt B',
                                                           City__c = 'Whittier',
                                                           State__c = 'CA',
                                                           Zip_Code__c = '90607',
                                                           RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                          );
            
            
            List<DIR_Case__c>d=new List<DIR_Case__c>();
            c.Status__c = 'Not Confirmed';
            d.add(c);
            update d;
            
            OnlineWageClaimThirdPartyWebService.getResponce();
            OnlineWageClaimThirdPartyAPIController.prepareCaseRole('TestData','1234');
            
            OnlineWageClaimThirdPartyAPIController.onlineClaimSubmit(JsonMsg);
            OnlineWageClaimThirdPartyAPIController.todayDate();
            OWCOnlineClaimThirdPartyAPIService.populateOtherWorkLocation(jsonMap,c,objRL1);
            OWCOnlineClaimThirdPartyAPIService.populateFinalWagesData(finalWagesMap,c,testOc);
            OWCOnlineClaimThirdPartyAPIService.workweekAndWorkDaysCheck(workWeekWorkDayMap);
            OWCOnlineClaimThirdPartyAPIService.demograhicInfoCheck(demoGraphicInfoDataMap);
            OWCOnlineClaimThirdPartyAPIService.populateIndustryData(null,null,null,null);
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap);
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap1);
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap2);
            Test.stopTest();   
        }
    }    
    
    @istest 
    public static void testOnlineWageClaimThirdPartyWebService4(){         
        
        Online_Claim_Draft__c owcDraftList = new Online_Claim_Draft__c();
        owcDraftList.Section_Id__c = '1';
        owcDraftList.Draft_JSON__c = 'Test area';
        insert owcDraftList;
        
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
        
        Id p = [select id from profile where name='Customer Online Claim User'].id;
        System.debug('Community profile::::'+p);
        
        Account mainA = new Account();
        mainA.firstName='abc';
        mainA.lastName='xyz';
        mainA.PersonEmail='abc@gmail.com';
        mainA.ShippingPostalCode = '234889';
        
        String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        String typeId1 =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
        affA.RecordTypeId=typeId1; 
        insert affA;
        
        Contact portalContact = new Contact(  
            FirstName = 'portalContactFirst',  
            Lastname = 'portalContactLast',  
            AccountId = affA.Id,  
            Email = 'portalContact' + System.currentTimeMillis() + '@test.com'  
        );  
        insert portalContact;
        
        User communityUser = new User(  
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Online Claim User'].Id,  
            FirstName = 'CommunityUserFirst',  
            LastName = 'CommunityUserLast',  
            Email = 'community.user@test.com',  
            Username = 'community.user.' + System.currentTimeMillis() + '@test.com',  
            Title = 'Title',  
            Alias = 'Alias',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            EmailEncodingKey = 'UTF-8',  
            LanguageLocaleKey = 'en_US',  
            LocaleSidKey = 'en_US',
            ContactId = portalContact.id
        );
        insert communityUser;
        System.debug('communityUser::::'+communityUser);
        
        User  getUserRecord  = [SELECT Id, Name,accountId FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        
        DIR_Case__c c = new DIR_Case__c();
        c.Online_Claim_Account__c = getUserRecord.accountId;
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
        
        Online_claim__c testOc = new Online_claim__c(Missed_Work__c = '2');
        insert testOc;
        
        String srs1 = '{"additionalParams":{"thirdPartySource":"Test Portal","communityUserId":"Goku"},"certAndAuthDetails":{"isAuthorizationRelease":true,"isAdditionalClaimDocUpload":false,"claimantName":"test","claimDate":"2022-04-10","addtionalClaimDocs":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}]},"claimantEmployeeValues":{"countryCodeindividualRepPhone":"+1","countryCodelawfirmRepStatePhone":"+1","isClaimantConfirmation":true,"claimantConfirmUploadDoc":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}],"claimantDetails":{"yourselfFirstName":null,"yourselfLastName":null,"yourselfMiddleName":"test middle name","yourselfHomePhone":"123456789","yourselfCellPhone":"123456789","countryCodeyourselfCellPhone":"+1","countryCodeyourselfHomePhone":"+1","isCellPhoneEntered":true,"yourselfBirthDate":null,"yourselfEmail":"akash.som","yourselfStreetAddress":"test street ","yourselfCity":"test city","yourselfState":"CA","yourselfZipCode":null,"needLanguageInterpreter":"Yes","isPrefferedLanguage":true,"isOtherPrefferedLanguage":true,"prefferedLanguageSelection":"Other","otherPrefferedLanguage":null},"isRepresentative":true,"isYourself":true,"WageClaimSubmit":"null","representativeAdvocateType":"Law Firm / Organization","lawfirmRepBusinessName":null,"lawfirmRepAttorney":null,"lawfirmRepStreetAddress":"test street","lawfirmRepCity":"test city","lawfirmRepState":"CA","lawfirmRepStatePhone":"123456789","lawFirmRepZipCode":"23122-333","lawfirmRepEmail":"somakash999","lawfirmRepWebsite":"test"},"demoGraphicInfoData":{"DemographicGenderIdentity":"Male","DemographicSexualOrientation":"Straight","DemographicRace":"American Indian, Native American or Alaskan Native","GenderOther":"","SexualOrientationOther":"","DemographicRaceOther":"","isGenderOther":false,"isSexualOrientationOther":false,"isDemographicRaceOther":false},"employeeStatusAndFinalClaimDetails":{"QuitDateTemplate":false,"DischargeDateTemplate":true,"hireDate":"2022-03-27","nameOfPersonWhoHiredYou":"sd","wereWagesPaid":"Yes","howWereYourWagesPaid":"Cash","isCheck":false,"paidByCheck":null,"chequeReplacedDate":null,"isOther":false,"Explanation":null,"statementReceived":"Yes","isPayStubRecord":true,"stillIdentifiedEmp":"No","selectAnyOne":"I was discharged/laid off","isstillIdentifiedEmp":true,"quitDate":"2022-03-27","noticeBeforeQuiting":null,"receivedFinalPayment":null,"isreceivedFinalPayment":false,"isDidntReceivedFinalPayment":false,"finalPaymentDate":null,"finalPaymentExplanation":null,"dischargedDate":"2022-03-27","personNameWhoDischargeYou":"test","receivedFinalPayment2":"No","isreceivedFinalPayment2":false,"isDidntReceivedFinalPayment2":true,"DateFS2":null,"payStubSickRecord":"No","dischargedExplanation":"test"},"employeesDetails":[{"countryCodeindividualBusinessPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeOtherIndividualPhone":"+1","employerChangedName":"Yes","isEmployerChangedName":true,"isOfficeLocatorMail":false,"IsIndividual":true,"IsOther":false,"additionalWHOPaidYou":"test","owcWorkRecordList":"Card swipe machine","additionalBankName":"test","representativeEmployerType":"LLC","individualFirstName":"test name","individualLastName":"test","individualStreetAddress":"test street","individualCity":"test city","individualState":"CA","IsAdditionalInfo":false,"individualZipCode":"12345-6789","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"akash.som@cloudsciencelabs.com","individualVehicleLicense":"1234567890","individualWebsite":"google.com","OtherIndividualBusinessName":null,"OtherIndividualStreetAddress":null,"OtherIndividualCity":null,"OtherIndividualState":"CA","OtherIndividualZipCode":null,"OtherIndividualPhone":null,"OtherIndividualEmail":null,"OtherIndividualVehicleLicense":null,"OtherIndividualWebsite":null,"additionalDifferentPerson":"test","additionalSignTimeCard":"Yes","additionalSomeoneElse":"test","additionalTotalEmployees":"11","additionalEmpBusiness":"I dont know","additionalBankruptcy":"Yes","IsOtherIndividual":false,"unionContractCovering":"Yes","urlAddress":"https://www.regextester.com/93652","isUnionContractCovered":true,"unionContractCovered":"Your unions website address","filingWageClaim":"I dont know","isEmployeeFilingWageClaim":true,"specifyFilingWageClaim":"Other – please explain","covid19Claim":"Yes","isEmployeeFilingWageClaimOther":true,"specifyOtherReason":"test","isDontKnow":false,"isUrlAddress":true,"isMailToOfficeLocator":false,"otherPleaseExplain":"","isSignCard":true,"signCardName":"test","retaliationComplain":"Yes","isRetaliationComplain":true,"complainFiledDate":"2022-03-27","complainCaseNumber":"test","isRetaliationComplainFalse":false,"employerNameChangedDetails":{"additionalTotalEmployees":"21","IsIndividual":true,"IsOther":false,"representativeEmployerType":"Individual/Sole Proprietor","individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-6543","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"test@gmail.com","individualVehicleLicense":"testgjbsxn","individualWebsite":"google.com","IsOtherIndividual":false,"OtherIndividualBusinessName":null,"OtherIndividualStreetAddress":null,"OtherIndividualCity":null,"OtherIndividualState":"CA","OtherIndividualZipCode":null,"OtherIndividualPhone":null,"OtherIndividualEmail":null,"OtherIndividualVehicleLicense":null,"OtherIndividualWebsite":null},"startingDate":"2022-03-27","endingDate":"2022-03-31","employerChangedNameAfterEmployement":"Yes","isEmployerChangedNameAfterEmployement":true,"successorDetails":{"successorDetails":[{"workForThisComp":"Yes","workWithSameWorokers":"Yes","ownershipOfCompRelated":"Owner(s) of both were same","employerNameAfterEmployementDetails":{"additionalTotalEmployees":"22","IsIndividual":true,"isClaimantAdvocate":true,"isOtherIndividualPicklist":false,"isIndividualStatePicklist":true,"IsOther":false,"representativeEmployerType":"Individual/Sole Proprietor","showIndividualSole":true,"individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-6765","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"test@gmail.com","individualVehicleLicense":"1234565423","individualWebsite":"google.com","OtherIndividualState":"CA","IsOtherIndividual":false,"isDontKnow":false,"IndividualFirstNamerequired":true,"IndividualStreetAddressrequired":true,"IndividualCityrequired":true,"IndividualStaterequired":true,"IndividualZipCoderequired":true,"IndividualBusinessPhonerequired":true,"OtherStreetAddressrequired":false,"OtherCityrequired":false,"OtherStaterequired":false,"OtherZipCoderequired":false,"OtherBusinessPhonerequired":false}}]},"mileageClaimDetails":[{"additinalPersonLastName":"test","additinalPersonFirstName":"test","claimantRelatedRoleActions":"test"}]}],"hoursYouTypicallyWorkedDetails":{"workMissedReason":"Yes","daysMissed":"56","whyDaysMissed":"test","specifyTypicalyyworked":"My work hours and days of work were usually the same each week that I worked","selectedHolidayOptions":["New Years Day (January 1)","Other holidays you did not work"],"isSameWeekDaysAndHours":true,"isDaysOrWeekVaried":false,"isWorkMissedReason":true,"companyHolidaySelection":["New Years Day (January 1)","Other holidays you did not work"],"isCompanyHolidayOther":true,"otherHolidaySelection":"test","overTimeSheet":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}],"isOverTimeSheetUploaded":true,"timeEntriesDetail":[{"name":"Friday","startTime":"00:00:00.000","endTime":"00:30:00.000","dateDiffer":true,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 30min","issameScheduled":false,"isChecked":false},{"name":"Saturday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":false,"isChecked":true},{"name":"Sunday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Monday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Tuesday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Wednesday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Thursday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true}]},"industryInfoDataValues":{"paidBreaks":"Yes","OtherIndividualConstructionTrades":"","selectedIndustry":"Agriculture","rateOfCompensation":"Yes","farmWorker":"Yes","heatRecovery":"Yes","writtenReqDate":null,"statementDate":null,"empStatementProvided":"Yes","domesticWorkType":"","isHouseDomesticWorker":false,"isHousePersonalAttendent":false,"domesticRegisteredNurse":"","domesticLiveInWorkHome":"","domesticSentByHomeAgency":"","isLabelsInfo":false,"isClaimantGarment":false,"listOfDuties":"test","selectedIndustryValue":"Agriculture - Farm Labor (work done in the fields)","isGarmentDutyFollow":"No"},"labelDetails":{"labelDetails":[{"labelName":"56","labelGarmentDescription":"test","labelGarmentsDuration":"Daily","isOther":false,"Other":"test","labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-15","labelEndDate":"2022-05-19","islabelPercPerDay":false,"namePersonVisit":"test 4t","sampleOfGarment":"Yes","labelGarmentDelAdd":"sIM","labelPercProvided":"99","superVisorCheck":"Yes","isSuperVisorCheck":true},{"labelName":"67","labelGarmentDescription":"test 3","labelGarmentsDuration":"Monthly","isOther":false,"labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-08","labelEndDate":"2022-05-18","islabelPercPerDay":false,"namePersonVisit":"test name","sampleOfGarment":"Yes","labelGarmentDelAdd":"Som","labelPercProvided":"88","superVisorCheck":"Yes","isSuperVisorCheck":true}]},"otherLocWorkInfo":{"workLocationBusinessAddress":"Yes","isBusinessAddressDifferent":true,"otherBusinessStreetAddress":"test","otherBusinessCity":"New York","approximateLocation":"test","countryCode":"+1","otherBusinessState":"CA","otherBusinessZipCode":"10014","otherBusinessPhone":"2124683378"},"paymentOfWagesDetails":{"value":"","isOneHourlyRate":true,"paidAmountPerHour":"12","promisedAmountPerHour":"45","hourlyRateBegDate":"2022-03-27","hourlyRateEndDate":"2022-03-31","isDifferentHourRate":true,"paidAmountDifferentHour":"12","promisedAmountDifferentHour":"22","forActivity":"fds","forActivityAdditional":null,"differentHourlyRateBegDate":"2022-03-28","differentHourlyRateEndDate":"2022-04-08","isSalaryRateForEachDay":true,"paidAmountForEachDay":"12","promisedAmountForEachDay":"22","frequencyOfEachDay":"Day","eachPayRateBegDate":"2022-03-27","eachPayRateEndDate":"2022-03-31","isCommissionRate":true,"writtenCommission":"Yes","isWrittenCommission":true,"commissionRateBegDate":null,"commissionRateEndDate":null,"isFileUploaded":false,"isPieceRate":true,"paidPieceRate":"22","promisedPieceRate":"2421","perUnitPaymentOfWages":"Bin","other":null,"numberOfUnits":"98","pieceRateBegDate":"2022-03-27","pieceRateEndDate":"2022-03-30","pieceRateTotalEarned":"55","pieceRateTotalPaid":"45","isProvidePriceRate":false,"otherAdditional":null,"paymentOfWagesForGarmentDetails":[],"differentHourAdditionalDetails":[],"hourlyAdditionalDetails":[],"salaryRateAdditionalDetails":[],"pieceRateAdditionalDetails":[],"HourlyOptionValue":true,"pieceRateOptionValue":true,"commissionRateOptionValue":true,"salaryRateOptionValue":true,"differentHourOptionValue":true},"workWeekAndWorkDaysDetails":{"EmpFollowSatToSun":"No","isEmpFollowSatToSun":true,"EmpDefinedWorkweek":"Friday to Thursday","EmpFollowMidnightToMidnight":"No","isEmpFollowMidnightToMidnight":true,"BegDate":"00:00:00.000","EndDate":"00:00:00.000","workWeekValue":6}}';
            
            
            
        String userId = getUserRecord.Id;
        
        String JsonMsg = srs1;
        
        JsonMsg = JsonMsg.replaceAll('Goku', userId);
        system.debug('JsonMsg :::' + JsonMsg);
        
        Map<String,Object> jsonMap = (Map<String,Object>) json.deserializeUntyped(JsonMsg);
        Map<String,Object> otherWorkLocMap = (Map<String,Object>) jsonMap.get('otherLocWorkInfo');
        Map<String,Object> finalWagesMap = new Map<String,Object>();
        finalWagesMap = null;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        //req.requestBody = Blob.valueOf(JSON.serializePretty(JsonMsg));
        req.requestBody = Blob.valueof(JsonMsg);
        system.debug('Jreq.requestBody ' + req.requestBody.toString());
        RestContext.request = req;
        RestContext.response= res;
        
        String empNameAfterJson = '{"employerNameAfterEmployementDetails":{"additionalTotalEmployees":null,"IsIndividual":true,"isClaimantAdvocate":true,"isOtherIndividualPicklist":false,"isIndividualStatePicklist":true,"IsOther":false,"representativeEmployerType":"Individual/Sole Proprietor","showIndividualSole":true,"individualFirstName":null,"individualLastName":null,"countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":null,"individualCity":null,"individualState":null,"individualZipCode":null,"individualBusinessPhone":null,"individualCellPhone":null,"individualEmail":null,"individualVehicleLicense":null,"individualWebsite":null,"OtherIndividualState":"CA","IsOtherIndividual":false,"isDontKnow":false,"IndividualFirstNamerequired":true,"IndividualStreetAddressrequired":true,"IndividualCityrequired":true,"IndividualStaterequired":true,"IndividualZipCoderequired":true,"IndividualBusinessPhonerequired":true,"OtherStreetAddressrequired":false,"OtherCityrequired":false,"OtherStaterequired":false,"OtherZipCoderequired":false,"OtherBusinessPhonerequired":false}}';
        Map<String,Object> empNameAfterJsonMap = (Map<String,Object>) json.deserializeUntyped(empNameAfterJson);
        System.debug('empNameAfterJsonMap::'+empNameAfterJsonMap);
        Map<String,Object> empNameAfterMap = (Map<String,Object>) empNameAfterJsonMap.get('employerNameAfterEmployementDetails');
        System.debug('empNameAfterMap::'+empNameAfterMap);
        
        String empNameAfterJson1 = '{"employerNameAfterEmployementDetails":{"additionalTotalEmployees":"two","IsIndividual":true,"isClaimantAdvocate":true,"isOtherIndividualPicklist":false,"isIndividualStatePicklist":true,"IsOther":false,"representativeEmployerType":"Individual/Sole Proprietor","showIndividualSole":true,"individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-676","individualBusinessPhone":"123456789","individualCellPhone":"123456789","individualEmail":"test","individualVehicleLicense":"1234565423","individualWebsite":"google","OtherIndividualState":"CA","IsOtherIndividual":false,"isDontKnow":false,"IndividualFirstNamerequired":true,"IndividualStreetAddressrequired":true,"IndividualCityrequired":true,"IndividualStaterequired":true,"IndividualZipCoderequired":true,"IndividualBusinessPhonerequired":true,"OtherStreetAddressrequired":false,"OtherCityrequired":false,"OtherStaterequired":false,"OtherZipCoderequired":false,"OtherBusinessPhonerequired":false}}';
        Map<String,Object> empNameAfterJsonMap1 = (Map<String,Object>) json.deserializeUntyped(empNameAfterJson1);
        System.debug('empNameAfterJsonMap1::'+empNameAfterJsonMap1);
        Map<String,Object> empNameAfterMap1 = (Map<String,Object>) empNameAfterJsonMap1.get('employerNameAfterEmployementDetails');
        System.debug('empNameAfterMap1::'+empNameAfterMap1);
        
        String empNameAfterJson2 = '{"employerNameAfterEmployementDetails":{"additionalTotalEmployees":"two","IsIndividual":false,"isClaimantAdvocate":true,"isOtherIndividualPicklist":false,"isIndividualStatePicklist":true,"IsOther":false,"representativeEmployerType":"Individual/Sole Proprietor","showIndividualSole":true,"individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-676","individualBusinessPhone":"123456789","individualCellPhone":"123456789","individualEmail":"test","individualVehicleLicense":"1234565423","individualWebsite":"google","OtherIndividualState":null,"IsOtherIndividual":true,"OtherIndividualBusinessName":null,"isDontKnow":false,"IndividualFirstNamerequired":true,"IndividualStreetAddressrequired":true,"IndividualCityrequired":true,"IndividualStaterequired":true,"IndividualZipCoderequired":true,"IndividualBusinessPhonerequired":true,"OtherStreetAddressrequired":false,"OtherCityrequired":false,"OtherStaterequired":false,"OtherZipCoderequired":false,"OtherBusinessPhonerequired":false,"OtherIndividualVehicleLicense":null,"OtherIndividualStreetAddress":null,"OtherIndividualCity":null,"OtherIndividualZipCode":null,"OtherIndividualPhone":null,"OtherIndividualEmail":"test","OtherIndividualWebsite":"test","additionalTotalEmployees":"two","IsOther":true,"otherPleaseExplain":null}}';
        Map<String,Object> empNameAfterJsonMap2 = (Map<String,Object>) json.deserializeUntyped(empNameAfterJson2);
        System.debug('empNameAfterJsonMap2::'+empNameAfterJsonMap2);
        Map<String,Object> empNameAfterMap2 = (Map<String,Object>) empNameAfterJsonMap2.get('employerNameAfterEmployementDetails');
        System.debug('empNameAfterMap2::'+empNameAfterMap2);
        
        String empNameAfterJson3 = '{"employerNameAfterEmployementDetails":{"additionalTotalEmployees":"two","IsIndividual":false,"isClaimantAdvocate":true,"isOtherIndividualPicklist":false,"isIndividualStatePicklist":true,"IsOther":false,"representativeEmployerType":"Individual/Sole Proprietor","showIndividualSole":true,"individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-676","individualBusinessPhone":"123456789","individualCellPhone":"123456789","individualEmail":"test","individualVehicleLicense":"1234565423","individualWebsite":"google","OtherIndividualState":null,"IsOtherIndividual":true,"OtherIndividualBusinessName":null,"isDontKnow":false,"IndividualFirstNamerequired":true,"IndividualStreetAddressrequired":true,"IndividualCityrequired":true,"IndividualStaterequired":true,"IndividualZipCoderequired":true,"IndividualBusinessPhonerequired":true,"OtherStreetAddressrequired":false,"OtherCityrequired":false,"OtherStaterequired":false,"OtherZipCoderequired":false,"OtherBusinessPhonerequired":false,"OtherIndividualVehicleLicense":null,"OtherIndividualStreetAddress":null,"OtherIndividualCity":null,"OtherIndividualZipCode":"12345678","OtherIndividualPhone":"123456789","OtherIndividualEmail":"test","OtherIndividualWebsite":"test","additionalTotalEmployees":null,"IsOther":true,"otherPleaseExplain":null}}';
        Map<String,Object> empNameAfterJsonMap3 = (Map<String,Object>) json.deserializeUntyped(empNameAfterJson3);
        System.debug('empNameAfterJsonMap3::'+empNameAfterJsonMap3);
        Map<String,Object> empNameAfterMap3 = (Map<String,Object>) empNameAfterJsonMap3.get('employerNameAfterEmployementDetails');
        System.debug('empNameAfterMap3::'+empNameAfterMap3);
        
        String workWeekWorkDay = '{"workWeekAndWorkDaysDetails":{"EmpFollowSatToSun":"test","isEmpFollowSatToSun":true,"EmpDefinedWorkweek":"test","EmpFollowMidnightToMidnight":"True+","isEmpFollowMidnightToMidnight":true,"BegDate":"00:00:00.000","EndDate":"00:00:00.000","workWeekValue":6}}';
        Map<String,Object> workWeekWorkDayTempMap = (Map<String,Object>) json.deserializeUntyped(workWeekWorkDay);
        System.debug('workWeekWorkDayTempMap::'+workWeekWorkDayTempMap);
        
        Map<String,Object> workWeekWorkDayMap = (Map<String,Object>) workWeekWorkDayTempMap.get('workWeekAndWorkDaysDetails');
        
        String demoGraphicInfoData = '{"demoGraphicInfoData":{"DemographicGenderIdentity":"Unknown","DemographicSexualOrientation":"Other","DemographicRace":"American Indian, Native American or Alaskan Native","GenderOther":"","SexualOrientationOther":"543","DemographicRaceOther":"","isGenderOther":false,"isSexualOrientationOther":true,"isDemographicRaceOther":false}}';
        Map<String,Object> demoGraphicInfoDataTempMap = (Map<String,Object>) json.deserializeUntyped(demoGraphicInfoData);
        System.debug('demoGraphicInfoDataTempMap::'+demoGraphicInfoDataTempMap);
        
        Map<String,Object> demoGraphicInfoDataMap = (Map<String,Object>) demoGraphicInfoDataTempMap.get('demoGraphicInfoData');
        
        String LabelInfoDetails = '{"labelDetails":{"labelDetails":[{"labelName":"56","labelGarmentDescription":"test","labelGarmentsDuration":"Daily","isOther":false,"Other":"test","labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022","labelEndDate":"2022","islabelPercPerDay":false,"namePersonVisit":"test 4t","sampleOfGarment":"Yes","labelGarmentDelAdd":"sIM","labelPercProvided":"99","superVisorCheck":"Yes","isSuperVisorCheck":true},{"labelName":"67","labelGarmentDescription":"test 3","labelGarmentsDuration":"Monthly","isOther":false,"labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-08","labelEndDate":"2022-05-18","islabelPercPerDay":false,"namePersonVisit":"test name","sampleOfGarment":"Yes","labelGarmentDelAdd":"Som","labelPercProvided":"88","superVisorCheck":"Yes","isSuperVisorCheck":true}]}}';
        Map<String,Object> LabelInfoDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(LabelInfoDetails);
        System.debug('LabelInfoDetailsTempMap::'+LabelInfoDetailsTempMap);
        
        Map<String,Object> labelInfoDetailsMap = (Map<String,Object>) LabelInfoDetailsTempMap.get('labelDetails');
        
        String industryInfoDataValues = '{"industryInfoDataValues":{"paidBreaks":"Yes","OtherIndividualConstructionTrades":"","selectedIndustry":"Test Data","rateOfCompensation":"Yes","farmWorker":"Yes","heatRecovery":"Yes","writtenReqDate":"2022-03-27","statementDate":"2022-03-27","empStatementProvided":"Yes","domesticWorkType":"","isHouseDomesticWorker":false,"isHousePersonalAttendent":false,"domesticRegisteredNurse":"","domesticLiveInWorkHome":"","domesticSentByHomeAgency":"","isLabelsInfo":false,"isClaimantGarment":false,"listOfDuties":"test","selectedIndustryValue":"Agriculture - Farm Labor (work done in the fields)","isGarmentDutyFollow":"No"}}';
        Map<String,Object> industryInfoDataValuesTempMap = (Map<String,Object>) json.deserializeUntyped(industryInfoDataValues);
        System.debug('industryInfoDataValuesTempMap::'+industryInfoDataValuesTempMap);
        
        Map<String,Object> industryInfoDataValuesMap = (Map<String,Object>) industryInfoDataValuesTempMap.get('industryInfoDataValues');
        
        String powDetails = '{"paymentOfWagesDetails":{"value":"","isOneHourlyRate":true,"paidAmountPerHour":"12","promisedAmountPerHour":"45","hourlyRateBegDate":"2022-03-27","hourlyRateEndDate":"2022-03-31","isDifferentHourRate":true,"paidAmountDifferentHour":"12","promisedAmountDifferentHour":"22","forActivity":"fds","forActivityAdditional":null,"differentHourlyRateBegDate":"2022-03-28","differentHourlyRateEndDate":"2022-04-08","isSalaryRateForEachDay":true,"paidAmountForEachDay":"12","promisedAmountForEachDay":"22","frequencyOfEachDay":"test","eachPayRateBegDate":"2022-03-27","eachPayRateEndDate":"2022-03-31","isCommissionRate":true,"writtenCommission":"Yes","isWrittenCommission":true,"commissionRateBegDate":null,"commissionRateEndDate":null,"isFileUploaded":false,"isPieceRate":true,"paidPieceRate":"22","promisedPieceRate":"2421","perUnitPaymentOfWages":"Bin","other":null,"numberOfUnits":"98","pieceRateBegDate":"2022-03-27","pieceRateEndDate":"2022-03-30","pieceRateTotalEarned":"55","pieceRateTotalPaid":"45","isProvidePriceRate":false,"otherAdditional":null,"paymentOfWagesForGarmentDetails":[],"differentHourAdditionalDetails":[{"paidAmountDifferentHourAdditional":"1","promisedAmountDifferentHourAdditional":"45","forActivityAdditional":"fg","differentHourlyRateBegDateAdditional":"2022-05-31","differentHourlyRateEndDateAdditional":"2022-06-01"}],"hourlyAdditionalDetails":[{"hourlyRate":"200","beggingDate":"2022-05-30","endingDate":"2022-06-06"}],"salaryRateAdditionalDetails":[{"paidAmountForEachDayAdditional":"1","promisedAmountForEachDayAdditional":"300","frequencyOfEachDayAdditional":"test","eachPayRateBegDateAdditional":"2022-05-31","eachPayRateEndDateAdditional":"2022-06-05"}],"pieceRateAdditionalDetails":[{"paidPieceRateAdditional":"1","promisedPieceRateAdditional":"100","numberOfUnitsAdditional":"1","pieceRateBegDateAdditional":"2022-05-30","pieceRateEndDateAdditional":"2022-06-12","perUnitPaymentOfWagesAdditional":"Mile","isPerUnitOtherAdditional":false}],"HourlyOptionValue":true,"pieceRateOptionValue":true,"commissionRateOptionValue":true,"salaryRateOptionValue":true,"differentHourOptionValue":true}}';
        Map<String,Object> powDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(powDetails);
        System.debug('powDetailsTempMap::'+powDetailsTempMap);
        
        Map<String,Object> powDetailsMap = (Map<String,Object>) powDetailsTempMap.get('paymentOfWagesDetails');
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        List<Related_Party__c> additinalPersonList = new List<Related_Party__c>();
        
        String docList = json.serialize(cvList);
        
        List<Object> docListMap = (List<Object>) json.deserializeUntyped(docList.replaceAll('ContentDocumentId', 'documentId'));
        
        
        System.RunAs(getUserRecord){
            Test.startTest();        
            
            Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                           Role__c = 'Claimant',
                                                           Street_Address__c = '123 Praire City Drive, Apt B',
                                                           City__c = 'Whittier',
                                                           State__c = 'CA',
                                                           Zip_Code__c = '90607',
                                                           RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                          );
            
            
            List<DIR_Case__c>d=new List<DIR_Case__c>();
            c.Status__c = 'Not Confirmed';
            d.add(c);
            update d;
            
            OnlineWageClaimThirdPartyWebService.getResponce();
            OnlineWageClaimThirdPartyAPIController.prepareCaseRole('TestData','1234');
            OnlineWageClaimThirdPartyAPIController.onlineClaimSubmit(JsonMsg);
            OnlineWageClaimThirdPartyAPIController.todayDate();
            OWCOnlineClaimThirdPartyAPIService.workweekAndWorkDaysCheck(workWeekWorkDayMap);
            
            OnlineWageClaimThirdPartyAPIController.createCaseRecord(null);
            OnlineWageClaimThirdPartyAPIController.createRelatedPartyRecords(null);
            OWCOnlineClaimThirdPartyAPIService.populateOtherWorkLocation(jsonMap,c,objRL1);
            OWCOnlineClaimThirdPartyAPIService.populateFinalWagesData(finalWagesMap,c,testOc);
            OWCOnlineClaimThirdPartyAPIService.prepareCaseRole(c.id, affA.Id, 'Test', typeId1);
            OWCOnlineClaimThirdPartyAPIService.prepareWorkLocationRecord();
            DateTime dtGMT = DateTime.newInstanceGMT(2020, 01, 20, 20, 0, 0);
            OWCOnlineClaimThirdPartyAPIService.getTimeInOrgTimeZone(dtGMT);
            OnlineWageClaimThirdPartyAPIController.validateEmployerUnionDoc(empNameAfterMap);
            OnlineWageClaimThirdPartyAPIController.validateEmployerUnionDoc(empNameAfterMap1);
            OnlineWageClaimThirdPartyAPIController.validateEmployerUnionDoc(empNameAfterMap2);
            OnlineWageClaimThirdPartyAPIController.validateEmployerUnionDoc(empNameAfterMap3);
            
            OWCOnlineClaimThirdPartyAPIService.prepareUploadedDocuments(null,documentLinks);
            OWCOnlineClaimThirdPartyAPIService.prepareUploadedDocumentsTest(null,documentLinks);
            OWCOnlineClaimThirdPartyAPIService.parseWageDetails(null,documentLinks);
            
            
            OWCOnlineClaimThirdPartyAPIService.prepareUploadedDocuments(docListMap,documentLinks);
            OWCOnlineClaimThirdPartyAPIService.prepareUploadedDocumentsTest(null,documentLinks);
            
            OWCOnlineClaimThirdPartyAPIService.demograhicInfoCheck(demoGraphicInfoDataMap);
            OWCOnlineClaimThirdPartyAPIService.labelDetailsValidationCheck(labelInfoDetailsMap);
            OWCOnlineClaimThirdPartyAPIService.populateIndustryData(industryInfoDataValuesMap, null, null, null);
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap);
            
            Test.stopTest();   
        }
    }
    
    @istest 
    public static void testOnlineWageClaimThirdPartyWebService5(){         
        Online_Claim_Draft__c owcDraftList = new Online_Claim_Draft__c();
        owcDraftList.Section_Id__c = '1';
        owcDraftList.Draft_JSON__c = 'Test area';
        insert owcDraftList;
        
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
        
        Id p = [select id from profile where name='Customer Online Claim User'].id;
        System.debug('Community profile::::'+p);
        
        Account mainA = new Account();
        mainA.firstName='abc';
        mainA.lastName='xyz';
        mainA.PersonEmail='abc@gmail.com';
        mainA.ShippingPostalCode = '234889';
        
        String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        String typeId1 =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
        affA.RecordTypeId=typeId1; 
        insert affA;
        
        Contact portalContact = new Contact(  
            FirstName = 'portalContactFirst',  
            Lastname = 'portalContactLast',  
            AccountId = affA.Id,  
            Email = 'portalContact' + System.currentTimeMillis() + '@test.com'  
        );  
        insert portalContact;
        
        User communityUser = new User(  
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Online Claim User'].Id,  
            FirstName = 'CommunityUserFirst',  
            LastName = 'CommunityUserLast',  
            Email = 'community.user@test.com',  
            Username = 'community.user.' + System.currentTimeMillis() + '@test.com',  
            Title = 'Title',  
            Alias = 'Alias',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            EmailEncodingKey = 'UTF-8',  
            LanguageLocaleKey = 'en_US',  
            LocaleSidKey = 'en_US',
            ContactId = portalContact.id
        );
        insert communityUser;
        System.debug('communityUser::::'+communityUser);
        User  getUserRecord  = [SELECT Id, Name,accountId FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        
        DIR_Case__c c = new DIR_Case__c();
        c.Online_Claim_Account__c = getUserRecord.accountId;
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
        
        Online_claim__c testOc = new Online_claim__c(Missed_Work__c = '2');
        insert testOc;
        
        String srs1 = '{"additionalParams":{"thirdPartySource":"Test Portal","communityUserId":"Goku"},"certAndAuthDetails":{"isAuthorizationRelease":true,"isAdditionalClaimDocUpload":false,"claimantName":"test","claimDate":"2022-04-10","addtionalClaimDocs":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}]},"claimantEmployeeValues":{"countryCodeindividualRepPhone":"+1","countryCodelawfirmRepStatePhone":"+1","isClaimantConfirmation":true,"claimantConfirmUploadDoc":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}],"claimantDetails":{"yourselfFirstName":"test name","yourselfLastName":"test last name","yourselfMiddleName":"test middle name","yourselfHomePhone":"1234567890","yourselfCellPhone":"1234567890","countryCodeyourselfCellPhone":"+1","countryCodeyourselfHomePhone":"+1","isCellPhoneEntered":true,"yourselfBirthDate":"2022-03-27","yourselfEmail":"akash.som@cloudsciencelabs.com","yourselfStreetAddress":"test street ","yourselfCity":"test city","yourselfState":"CA","yourselfZipCode":"12345-6544","needLanguageInterpreter":"Yes","isPrefferedLanguage":true,"isOtherPrefferedLanguage":true,"prefferedLanguageSelection":"Other","otherPrefferedLanguage":"Hindi"},"isRepresentative":true,"isYourself":true,"WageClaimSubmit":null,"representativeAdvocateType":null,"lawfirmRepBusinessName":null,"lawfirmRepAttorney":null,"lawfirmRepStreetAddress":"test street","lawfirmRepCity":"test city","lawfirmRepState":"CA","lawfirmRepStatePhone":"123456789","lawFirmRepZipCode":"23122-333","lawfirmRepEmail":"somakash999","lawfirmRepWebsite":"https"},"demoGraphicInfoData":{"DemographicGenderIdentity":"Male","DemographicSexualOrientation":"Straight","DemographicRace":"American Indian, Native American or Alaskan Native","GenderOther":"","SexualOrientationOther":"","DemographicRaceOther":"","isGenderOther":false,"isSexualOrientationOther":false,"isDemographicRaceOther":false},"employeeStatusAndFinalClaimDetails":{"QuitDateTemplate":false,"DischargeDateTemplate":true,"hireDate":"2022-03-27","nameOfPersonWhoHiredYou":"sd","wereWagesPaid":"Yes","howWereYourWagesPaid":"Cash","isCheck":false,"paidByCheck":null,"chequeReplacedDate":null,"isOther":false,"Explanation":null,"statementReceived":"Yes","isPayStubRecord":true,"stillIdentifiedEmp":"No","selectAnyOne":"I was discharged/laid off","isstillIdentifiedEmp":true,"quitDate":"2022-03-27","noticeBeforeQuiting":null,"receivedFinalPayment":null,"isreceivedFinalPayment":false,"isDidntReceivedFinalPayment":false,"finalPaymentDate":null,"finalPaymentExplanation":null,"dischargedDate":"2022-03-27","personNameWhoDischargeYou":"test","receivedFinalPayment2":"No","isreceivedFinalPayment2":false,"isDidntReceivedFinalPayment2":true,"DateFS2":null,"payStubSickRecord":"No","dischargedExplanation":"test"},"employeesDetails":[{"countryCodeindividualBusinessPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeOtherIndividualPhone":"+1","employerChangedName":"Yes","isEmployerChangedName":true,"isOfficeLocatorMail":false,"IsIndividual":true,"IsOther":false,"additionalWHOPaidYou":"test","owcWorkRecordList":"Card swipe machine","additionalBankName":"test","representativeEmployerType":"Corporation","individualFirstName":"test name","individualLastName":"test","individualStreetAddress":"test street","individualCity":"test city","individualState":"CA","IsAdditionalInfo":false,"individualZipCode":"12345-6789","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"akash.som@cloudsciencelabs.com","individualVehicleLicense":"1234567890","individualWebsite":"google.com","OtherIndividualBusinessName":"test","OtherIndividualStreetAddress":"test","OtherIndividualCity":"test","OtherIndividualState":"CA","OtherIndividualZipCode":"12345","OtherIndividualPhone":"1234567890","OtherIndividualEmail":"test@test.com","OtherIndividualVehicleLicense":null,"OtherIndividualWebsite":null,"additionalDifferentPerson":"test","additionalSignTimeCard":"Yes","additionalSomeoneElse":"test","additionalTotalEmployees":"11","additionalEmpBusiness":"I dont know","additionalBankruptcy":"Yes","IsOtherIndividual":false,"unionContractCovering":"Yes","urlAddress":"https://www.regextester.com/93652","isUnionContractCovered":true,"unionContractCovered":"Your unions website address","filingWageClaim":"I dont know","isEmployeeFilingWageClaim":true,"specifyFilingWageClaim":"Other – please explain","covid19Claim":"Yes","isEmployeeFilingWageClaimOther":true,"specifyOtherReason":"test","isDontKnow":false,"isUrlAddress":true,"isMailToOfficeLocator":false,"otherPleaseExplain":"","isSignCard":true,"signCardName":"test","retaliationComplain":"Yes","isRetaliationComplain":true,"complainFiledDate":"2022-03-27","complainCaseNumber":"test","isRetaliationComplainFalse":false,"employerNameChangedDetails":{"additionalTotalEmployees":"21","IsIndividual":true,"IsOther":false,"representativeEmployerType":"Corporation","individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-6543","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"test@gmail.com","individualVehicleLicense":"testgjbsxn","individualWebsite":"google.com","IsOtherIndividual":false,"OtherIndividualBusinessName":"test","OtherIndividualStreetAddress":"test","OtherIndividualCity":"test","OtherIndividualState":"CA","OtherIndividualZipCode":"12345","OtherIndividualPhone":"1234567890","OtherIndividualEmail":"test@test.com","OtherIndividualVehicleLicense":null,"OtherIndividualWebsite":null},"startingDate":"2022-03-27","endingDate":"2022-03-31","employerChangedNameAfterEmployement":"Yes","isEmployerChangedNameAfterEmployement":true,"successorDetails":{"successorDetails":[{"workForThisComp":"Yes","workWithSameWorokers":"Yes","ownershipOfCompRelated":"Owner(s) of both were same","employerNameAfterEmployementDetails":{"additionalTotalEmployees":"22","IsIndividual":true,"isClaimantAdvocate":true,"isOtherIndividualPicklist":false,"isIndividualStatePicklist":true,"IsOther":false,"representativeEmployerType":"Corporation","showIndividualSole":true,"individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-6765","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"test@gmail.com","individualVehicleLicense":"1234565423","individualWebsite":"google.com","OtherIndividualState":"CA","IsOtherIndividual":false,"isDontKnow":false,"IndividualFirstNamerequired":true,"IndividualStreetAddressrequired":true,"IndividualCityrequired":true,"IndividualStaterequired":true,"IndividualZipCoderequired":true,"IndividualBusinessPhonerequired":true,"OtherStreetAddressrequired":false,"OtherCityrequired":false,"OtherStaterequired":false,"OtherZipCoderequired":false,"OtherBusinessPhonerequired":false}}]},"mileageClaimDetails":[{"additinalPersonLastName":"test","additinalPersonFirstName":"test","claimantRelatedRoleActions":"test"}]}],"hoursYouTypicallyWorkedDetails":{"workMissedReason":"Yes","daysMissed":"56","whyDaysMissed":"test","specifyTypicalyyworked":"My work hours and days of work were usually the same each week that I worked","selectedHolidayOptions":["New Years Day (January 1)","Other holidays you did not work"],"isSameWeekDaysAndHours":true,"isDaysOrWeekVaried":false,"isWorkMissedReason":true,"companyHolidaySelection":["New Years Day (January 1)","Other holidays you did not work"],"isCompanyHolidayOther":true,"otherHolidaySelection":"test","overTimeSheet":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}],"isOverTimeSheetUploaded":true,"timeEntriesDetail":[{"name":"Friday","startTime":"00:00:00.000","endTime":"00:30:00.000","dateDiffer":true,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 30min","issameScheduled":false,"isChecked":false},{"name":"Saturday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":false,"isChecked":true},{"name":"Sunday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Monday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Tuesday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Wednesday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Thursday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true}]},"industryInfoDataValues":{"paidBreaks":"Yes","OtherIndividualConstructionTrades":"","selectedIndustry":"Agriculture","rateOfCompensation":"Yes","farmWorker":"Yes","heatRecovery":"Yes","writtenReqDate":"2022-03-27","statementDate":"2022-03-27","empStatementProvided":"Yes","domesticWorkType":"","isHouseDomesticWorker":false,"isHousePersonalAttendent":false,"domesticRegisteredNurse":"","domesticLiveInWorkHome":"","domesticSentByHomeAgency":"","isLabelsInfo":true,"isClaimantGarment":false,"listOfDuties":"test","selectedIndustryValue":"Agriculture - Farm Labor (work done in the fields)","isGarmentDutyFollow":"Yes"},"labelDetails":{"labelDetails":[{"labelName":"56","labelGarmentDescription":"test","labelGarmentsDuration":"Daily","isOther":false,"Other":"test","labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-15","labelEndDate":"2022-05-19","islabelPercPerDay":false,"namePersonVisit":"test 4t","sampleOfGarment":"Yes","labelGarmentDelAdd":"sIM","labelPercProvided":"99","superVisorCheck":"Yes","isSuperVisorCheck":true},{"labelName":"67","labelGarmentDescription":"test 3","labelGarmentsDuration":"Monthly","isOther":false,"labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-08","labelEndDate":"2022-05-18","islabelPercPerDay":false,"namePersonVisit":"test name","sampleOfGarment":"Yes","labelGarmentDelAdd":"Som","labelPercProvided":"88","superVisorCheck":"Yes","isSuperVisorCheck":true}]},"otherLocWorkInfo":{"workLocationBusinessAddress":"Yes","isBusinessAddressDifferent":true,"otherBusinessStreetAddress":"test","otherBusinessCity":"New York","approximateLocation":"test","countryCode":"+1","otherBusinessState":"CA","otherBusinessZipCode":"10014","otherBusinessPhone":"2124683378"},"paymentOfWagesDetails":{"value":"","isOneHourlyRate":true,"paidAmountPerHour":"12","promisedAmountPerHour":"45","hourlyRateBegDate":"2022-03-27","hourlyRateEndDate":"2022-03-31","isDifferentHourRate":true,"paidAmountDifferentHour":"12","promisedAmountDifferentHour":"22","forActivity":"fds","forActivityAdditional":null,"differentHourlyRateBegDate":"2022-03-28","differentHourlyRateEndDate":"2022-04-08","isSalaryRateForEachDay":true,"paidAmountForEachDay":"12","promisedAmountForEachDay":"22","frequencyOfEachDay":"Day","eachPayRateBegDate":"2022-03-27","eachPayRateEndDate":"2022-03-31","isCommissionRate":true,"writtenCommission":"Yes","isWrittenCommission":true,"commissionRateBegDate":null,"commissionRateEndDate":null,"isFileUploaded":false,"isPieceRate":true,"paidPieceRate":"22","promisedPieceRate":"2421","perUnitPaymentOfWages":"Bin","other":null,"numberOfUnits":"98","pieceRateBegDate":"2022-03-27","pieceRateEndDate":"2022-03-30","pieceRateTotalEarned":"55","pieceRateTotalPaid":"45","isProvidePriceRate":false,"otherAdditional":null,"paymentOfWagesForGarmentDetails":[],"differentHourAdditionalDetails":[],"hourlyAdditionalDetails":[],"salaryRateAdditionalDetails":[],"pieceRateAdditionalDetails":[],"HourlyOptionValue":true,"pieceRateOptionValue":true,"commissionRateOptionValue":true,"salaryRateOptionValue":true,"differentHourOptionValue":true},"workWeekAndWorkDaysDetails":{"EmpFollowSatToSun":"No","isEmpFollowSatToSun":true,"EmpDefinedWorkweek":"Friday to Thursday","EmpFollowMidnightToMidnight":"No","isEmpFollowMidnightToMidnight":true,"BegDate":"00:00:00.000","EndDate":"00:00:00.000","workWeekValue":6}}';
            
            
            
        String userId = getUserRecord.Id;
        
        String JsonMsg = srs1;
        
        JsonMsg = JsonMsg.replaceAll('Goku', userId);
        system.debug('JsonMsg :::' + JsonMsg);  
        
        
        String powDetails = '{"paymentOfWagesDetails":{"paymentOfWagesForGarmentDetails":[],"differentHourAdditionalDetails":[{"paidAmountDifferentHourAdditional":"1","promisedAmountDifferentHourAdditional":"45","forActivityAdditional":"fg","differentHourlyRateBegDateAdditional":"2022-05-31","differentHourlyRateEndDateAdditional":"2022-06-01"}],"hourlyAdditionalDetails":[{"hourlyRate":"200","beggingDate":"2022-05-30","endingDate":"2022-06-06"}],"salaryRateAdditionalDetails":[{"paidAmountForEachDayAdditional":"1","promisedAmountForEachDayAdditional":"300","frequencyOfEachDayAdditional":"test","eachPayRateBegDateAdditional":"2022-05-31","eachPayRateEndDateAdditional":"2022-06-05"}],"pieceRateAdditionalDetails":[{"paidPieceRateAdditional":"1","promisedPieceRateAdditional":"100","numberOfUnitsAdditional":"1","pieceRateBegDateAdditional":"2022-05-30","pieceRateEndDateAdditional":"2022-06-12","perUnitPaymentOfWagesAdditional":"Mile","isPerUnitOtherAdditional":false}],"HourlyOptionValue":true,"pieceRateOptionValue":true,"commissionRateOptionValue":true,"salaryRateOptionValue":true,"differentHourOptionValue":true}}';
        Map<String,Object> powDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(powDetails);
        System.debug('powDetailsTempMap::'+powDetailsTempMap);
        
        Map<String,Object> powDetailsMap = (Map<String,Object>) powDetailsTempMap.get('paymentOfWagesDetails');
        
        
        String lawDetails = '{"lawDetails":{"lawFirmRepZipCode":"123456","lawfirmRepStatePhone":"123456789","lawfirmRepEmail":"Test","lawfirmRepWebsite":"google"}}';
        Map<String,Object> lawDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(lawDetails);
        System.debug('powDetailsTempMap::'+lawDetailsTempMap);
        
        Map<String,Object> lawDetailsMap = (Map<String,Object>) lawDetailsTempMap.get('lawDetails');        
        
        String yourselfDetails = '{"yourselfDetails":{"yourselfFirstName":null,"yourselfLastName":null,"yourselfBirthDate":null,"yourselfZipCode":null,"yourselfCellPhone":"123456789","yourselfEmail":"Test@test.com","isPrefferedLanguage":true,"isOtherPrefferedLanguage":true,"otherPrefferedLanguage":null}}';
        Map<String,Object> yourselfDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(yourselfDetails);
        System.debug('yourselfDetailsTempMap::'+yourselfDetailsTempMap);
        
        Map<String,Object> yourselfDetailsMap = (Map<String,Object>) yourselfDetailsTempMap.get('yourselfDetails');        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        //req.requestBody = Blob.valueOf(JSON.serializePretty(JsonMsg));
        req.requestBody = Blob.valueof('');
        system.debug('Jreq.requestBody ' + req.requestBody.toString());
        RestContext.request = req;
        RestContext.response= res;
        System.RunAs(getUserRecord){
            Test.startTest();        
            
            Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                           Role__c = 'Claimant',
                                                           Street_Address__c = '123 Praire City Drive, Apt B',
                                                           City__c = 'Whittier',
                                                           State__c = 'CA',
                                                           Zip_Code__c = '90607',
                                                           RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                          );
            
            
            List<DIR_Case__c>d=new List<DIR_Case__c>();
            c.Status__c = 'Not Confirmed';
            d.add(c);
            update d;
            
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap);
            OnlineWageClaimThirdPartyWebService.getResponce();
            OnlineWageClaimThirdPartyAPIController.prepareCaseRole(userId,c.Id);
            OnlineWageClaimThirdPartyAPIController.onlineClaimSubmit(JsonMsg);
            OnlineWageClaimThirdPartyAPIController.validateClaimantAdvocateData(lawDetailsMap);
            OnlineWageClaimThirdPartyAPIController.validateClaimantData(yourselfDetailsMap);
            
            Test.stopTest(); 
        }
        
    }
    
    @istest 
    public static void testOnlineWageClaimThirdPartyWebService6(){         
        Online_Claim_Draft__c owcDraftList = new Online_Claim_Draft__c();
        owcDraftList.Section_Id__c = '1';
        owcDraftList.Draft_JSON__c = 'Test area';
        insert owcDraftList;
        
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
        
        Id p = [select id from profile where name='Customer Online Claim User'].id;
        System.debug('Community profile::::'+p);
        
        Account mainA = new Account();
        mainA.firstName='abc';
        mainA.lastName='xyz';
        mainA.PersonEmail='abc@gmail.com';
        mainA.ShippingPostalCode = '234889';
        
        String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        String typeId1 =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
        affA.RecordTypeId=typeId1; 
        insert affA;
        
        Contact portalContact = new Contact(  
            FirstName = 'portalContactFirst',  
            Lastname = 'portalContactLast',  
            AccountId = affA.Id,  
            Email = 'portalContact' + System.currentTimeMillis() + '@test.com'  
        );  
        insert portalContact;
        
        User communityUser = new User(  
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Online Claim User'].Id,  
            FirstName = 'CommunityUserFirst',  
            LastName = 'CommunityUserLast',  
            Email = 'community.user@test.com',  
            Username = 'community.user.' + System.currentTimeMillis() + '@test.com',  
            Title = 'Title',  
            Alias = 'Alias',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            EmailEncodingKey = 'UTF-8',  
            LanguageLocaleKey = 'en_US',  
            LocaleSidKey = 'en_US',
            ContactId = portalContact.id
        );
        insert communityUser;
        System.debug('communityUser::::'+communityUser);
        
        User  getUserRecord  = [SELECT Id, Name,accountId FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        DIR_Case__c c = new DIR_Case__c();
        c.Online_Claim_Account__c = getUserRecord.accountId;
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
        
        Online_claim__c testOc = new Online_claim__c(Missed_Work__c = '2');
        insert testOc;
        
        String srs1 = '{"additionalParams":{"thirdPartySource":"Test Portal","communityUserId":"Goku"},"certAndAuthDetails":{"isAuthorizationRelease":true,"isAdditionalClaimDocUpload":false,"claimantName":"test","claimDate":"2022-04-10","addtionalClaimDocs":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}]},"claimantEmployeeValues":{"countryCodeindividualRepPhone":"+1","countryCodelawfirmRepStatePhone":"+1","isClaimantConfirmation":true,"claimantConfirmUploadDoc":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}],"claimantDetails":{"yourselfFirstName":"test name","yourselfLastName":"test last name","yourselfMiddleName":"test middle name","yourselfHomePhone":"1234567890","yourselfCellPhone":"1234567890","countryCodeyourselfCellPhone":"+1","countryCodeyourselfHomePhone":"+1","isCellPhoneEntered":true,"yourselfBirthDate":"2022-03-27","yourselfEmail":"akash.som@cloudsciencelabs.com","yourselfStreetAddress":"test street ","yourselfCity":"test city","yourselfState":"CA","yourselfZipCode":"12345-6544","needLanguageInterpreter":"Yes","isPrefferedLanguage":true,"isOtherPrefferedLanguage":true,"prefferedLanguageSelection":"Other","otherPrefferedLanguage":"Hindi"},"isRepresentative":true,"isYourself":true,"WageClaimSubmit":"Representative","representativeAdvocateType":"Law Firm / Organization","lawfirmRepBusinessName":"Test Name","lawfirmRepAttorney":"New Online Claim","lawfirmRepStreetAddress":"test street","lawfirmRepCity":"test city","lawfirmRepState":"CA","lawfirmRepStatePhone":"1234567890","lawFirmRepZipCode":"23122-3333","lawfirmRepEmail":"somakash999@gmail.com","lawfirmRepWebsite":"https://www.google"},"demoGraphicInfoData":{"DemographicGenderIdentity":"Male","DemographicSexualOrientation":"Straight","DemographicRace":"American Indian, Native American or Alaskan Native","GenderOther":"","SexualOrientationOther":"","DemographicRaceOther":"","isGenderOther":false,"isSexualOrientationOther":false,"isDemographicRaceOther":false},"employeeStatusAndFinalClaimDetails":{"QuitDateTemplate":false,"DischargeDateTemplate":true,"hireDate":"2022-03-27","nameOfPersonWhoHiredYou":"sd","wereWagesPaid":"Yes","howWereYourWagesPaid":"Cash","isCheck":false,"paidByCheck":null,"chequeReplacedDate":null,"isOther":false,"Explanation":null,"statementReceived":"Yes","isPayStubRecord":true,"stillIdentifiedEmp":"No","selectAnyOne":"I was discharged/laid off","isstillIdentifiedEmp":true,"quitDate":"2022-03-27","noticeBeforeQuiting":null,"receivedFinalPayment":null,"isreceivedFinalPayment":false,"isDidntReceivedFinalPayment":false,"finalPaymentDate":null,"finalPaymentExplanation":null,"dischargedDate":"2022-03-27","personNameWhoDischargeYou":"test","receivedFinalPayment2":"No","isreceivedFinalPayment2":false,"isDidntReceivedFinalPayment2":true,"DateFS2":null,"payStubSickRecord":"No","dischargedExplanation":"test"},"employeesDetails":[{"countryCodeindividualBusinessPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeOtherIndividualPhone":"+1","employerChangedName":"Yes","isEmployerChangedName":true,"isOfficeLocatorMail":false,"IsIndividual":true,"IsOther":false,"additionalWHOPaidYou":"test","owcWorkRecordList":"Card swipe machine","additionalBankName":"test","representativeEmployerType":"Corporation","individualFirstName":"test name","individualLastName":"test","individualStreetAddress":"test street","individualCity":"test city","individualState":"CA","IsAdditionalInfo":false,"individualZipCode":"12345-6789","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"akash.som@cloudsciencelabs.com","individualVehicleLicense":"1234567890","individualWebsite":"google.com","OtherIndividualBusinessName":"test","OtherIndividualStreetAddress":"test","OtherIndividualCity":"test","OtherIndividualState":"CA","OtherIndividualZipCode":"12345","OtherIndividualPhone":"1234567890","OtherIndividualEmail":"test@test.com","OtherIndividualVehicleLicense":null,"OtherIndividualWebsite":null,"additionalDifferentPerson":"test","additionalSignTimeCard":"Yes","additionalSomeoneElse":"test","additionalTotalEmployees":"11","additionalEmpBusiness":"No","additionalBankruptcy":"Yes","IsOtherIndividual":false,"unionContractCovering":"Yes","urlAddress":"https://www.regextester.com/93652","isUnionContractCovered":true,"unionContractCovered":"Your unions website address","filingWageClaim":"No","isEmployeeFilingWageClaim":true,"specifyFilingWageClaim":"Other – please explain","covid19Claim":"Yes","isEmployeeFilingWageClaimOther":true,"specifyOtherReason":"test","isDontKnow":false,"isUrlAddress":true,"isMailToOfficeLocator":false,"otherPleaseExplain":"","isSignCard":true,"signCardName":"test","retaliationComplain":"Yes","isRetaliationComplain":true,"complainFiledDate":"2022-03-27","complainCaseNumber":"test","isRetaliationComplainFalse":false,"employerNameChangedDetails":{"additionalTotalEmployees":"21","IsIndividual":true,"IsOther":false,"representativeEmployerType":"Corporation","individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-6543","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"test@gmail.com","individualVehicleLicense":"testgjbsxn","individualWebsite":"google.com","IsOtherIndividual":false,"OtherIndividualBusinessName":"test","OtherIndividualStreetAddress":"test","OtherIndividualCity":"test","OtherIndividualState":"CA","OtherIndividualZipCode":"12345","OtherIndividualPhone":"1234567890","OtherIndividualEmail":"test@test.com","OtherIndividualVehicleLicense":null,"OtherIndividualWebsite":null},"startingDate":"2022-03-27","endingDate":"2022-03-31","employerChangedNameAfterEmployement":"Yes","isEmployerChangedNameAfterEmployement":true,"successorDetails":{"successorDetails":[{"workForThisComp":"Yes","workWithSameWorokers":"Yes","ownershipOfCompRelated":"Owner(s) of both were same","employerNameAfterEmployementDetails":{"additionalTotalEmployees":"22","IsIndividual":true,"isClaimantAdvocate":true,"isOtherIndividualPicklist":false,"isIndividualStatePicklist":true,"IsOther":false,"representativeEmployerType":"Corporation","showIndividualSole":true,"individualFirstName":"test","individualLastName":"test","countryCodeOtherIndividualPhone":"+1","countryCodeindividualCellPhone":"+1","countryCodeindividualBusinessPhone":"+1","individualStreetAddress":"test","individualCity":"test","individualState":"CA","individualZipCode":"12345-6765","individualBusinessPhone":"1234567890","individualCellPhone":"1234567890","individualEmail":"test@gmail.com","individualVehicleLicense":"1234565423","individualWebsite":"google.com","OtherIndividualState":"CA","IsOtherIndividual":false,"isDontKnow":false,"IndividualFirstNamerequired":true,"IndividualStreetAddressrequired":true,"IndividualCityrequired":true,"IndividualStaterequired":true,"IndividualZipCoderequired":true,"IndividualBusinessPhonerequired":true,"OtherStreetAddressrequired":false,"OtherCityrequired":false,"OtherStaterequired":false,"OtherZipCoderequired":false,"OtherBusinessPhonerequired":false}}]},"mileageClaimDetails":[{"additinalPersonLastName":"test","additinalPersonFirstName":"test","claimantRelatedRoleActions":"test"}]}],"hoursYouTypicallyWorkedDetails":{"workMissedReason":"Yes","daysMissed":"56","whyDaysMissed":"test","specifyTypicalyyworked":"My work hours and days of work were usually the same each week that I worked","selectedHolidayOptions":["New Years Day (January 1)","Other holidays you did not work"],"isSameWeekDaysAndHours":true,"isDaysOrWeekVaried":false,"isWorkMissedReason":true,"companyHolidaySelection":["New Years Day (January 1)","Other holidays you did not work"],"isCompanyHolidayOther":true,"otherHolidaySelection":"test","overTimeSheet":[{"name":"SuccessMsgCreateCase.PNG","mimeType":"image/png"}],"isOverTimeSheetUploaded":true,"timeEntriesDetail":[{"name":"Friday","startTime":"00:00:00.000","endTime":"00:30:00.000","dateDiffer":true,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 30min","issameScheduled":false,"isChecked":false},{"name":"Saturday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":false,"isChecked":true},{"name":"Sunday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Monday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Tuesday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Wednesday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true},{"name":"Thursday","startTime":"00:00:00.000","endTime":"00:15:00.000","dateDiffer":false,"isFirstMeal":false,"isSecondMeal":false,"startTimeFirstMeal":"","breakTimeFirstMeal":"","startTimeSecondMeal":"","breakTimeSecondMeal":"","totalHours":"0hr 15min","issameScheduled":true,"isChecked":true}]},"industryInfoDataValues":{"paidBreaks":"Yes","OtherIndividualConstructionTrades":"","selectedIndustry":"Agriculture","rateOfCompensation":"Yes","farmWorker":"Yes","heatRecovery":"Yes","writtenReqDate":"2022-03-27","statementDate":"2022-03-27","empStatementProvided":"Yes","domesticWorkType":"","isHouseDomesticWorker":false,"isHousePersonalAttendent":false,"domesticRegisteredNurse":"","domesticLiveInWorkHome":"","domesticSentByHomeAgency":"","isLabelsInfo":true,"isClaimantGarment":false,"listOfDuties":"test","selectedIndustryValue":"Agriculture - Farm Labor (work done in the fields)","isGarmentDutyFollow":"Yes"},"labelDetails":{"labelDetails":[{"labelName":"56","labelGarmentDescription":"test","labelGarmentsDuration":"Daily","isOther":false,"Other":"test","labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-15","labelEndDate":"2022-05-19","islabelPercPerDay":false,"namePersonVisit":"test 4t","sampleOfGarment":"Yes","labelGarmentDelAdd":"sIM","labelPercProvided":"99","superVisorCheck":"Yes","isSuperVisorCheck":true},{"labelName":"67","labelGarmentDescription":"test 3","labelGarmentsDuration":"Monthly","isOther":false,"labelGarmentDelAddCompName":"test 3","labelPersonVisit":"test visit","labelTheyWereWorking":"test label","labelWhatTheySay":"test spoke","labelWhatIfMistakFound":"test happened","labelWorkOverTime":"test mistake","labelWorkOverTimeDeadline":"test dealing","labelPriority":"test 11","labelStartDate":"2022-05-08","labelEndDate":"2022-05-18","islabelPercPerDay":false,"namePersonVisit":"test name","sampleOfGarment":"Yes","labelGarmentDelAdd":"Som","labelPercProvided":"88","superVisorCheck":"Yes","isSuperVisorCheck":true}]},"otherLocWorkInfo":{"workLocationBusinessAddress":"Yes","isBusinessAddressDifferent":true,"otherBusinessStreetAddress":"test","otherBusinessCity":"New York","approximateLocation":"test","countryCode":"+1","otherBusinessState":"CA","otherBusinessZipCode":"10014","otherBusinessPhone":"2124683378"},"paymentOfWagesDetails":{"value":"","isOneHourlyRate":true,"paidAmountPerHour":"12","promisedAmountPerHour":"45","hourlyRateBegDate":"2022-03-27","hourlyRateEndDate":"2022-03-31","isDifferentHourRate":true,"paidAmountDifferentHour":"12","promisedAmountDifferentHour":"22","forActivity":"fds","forActivityAdditional":null,"differentHourlyRateBegDate":"2022-03-28","differentHourlyRateEndDate":"2022-04-08","isSalaryRateForEachDay":true,"paidAmountForEachDay":"12","promisedAmountForEachDay":"22","frequencyOfEachDay":"Day","eachPayRateBegDate":"2022-03-27","eachPayRateEndDate":"2022-03-31","isCommissionRate":true,"writtenCommission":"Yes","isWrittenCommission":true,"commissionRateBegDate":null,"commissionRateEndDate":null,"isFileUploaded":false,"isPieceRate":true,"paidPieceRate":"22","promisedPieceRate":"2421","perUnitPaymentOfWages":"Bin","other":null,"numberOfUnits":"98","pieceRateBegDate":"2022-03-27","pieceRateEndDate":"2022-03-30","pieceRateTotalEarned":"55","pieceRateTotalPaid":"45","isProvidePriceRate":false,"otherAdditional":null,"paymentOfWagesForGarmentDetails":[],"differentHourAdditionalDetails":[],"hourlyAdditionalDetails":[],"salaryRateAdditionalDetails":[],"pieceRateAdditionalDetails":[],"HourlyOptionValue":true,"pieceRateOptionValue":true,"commissionRateOptionValue":true,"salaryRateOptionValue":true,"differentHourOptionValue":true},"workWeekAndWorkDaysDetails":{"EmpFollowSatToSun":"No","isEmpFollowSatToSun":true,"EmpDefinedWorkweek":"Friday to Thursday","EmpFollowMidnightToMidnight":"No","isEmpFollowMidnightToMidnight":true,"BegDate":"00:00:00.000","EndDate":"00:00:00.000","workWeekValue":6}}';
        
            
        
        String userId = getUserRecord.Id;
        
        String JsonMsg = srs1;
        
        JsonMsg = JsonMsg.replaceAll('Goku', userId);
        system.debug('JsonMsg :::' + JsonMsg);        
        
        String powDetails = '{"paymentOfWagesDetails":{"salaryRateAdditionalDetails":[{"eachPayRateBegDateAdditional":"Test"}]}}';
        Map<String,Object> powDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(powDetails);
        System.debug('powDetailsTempMap::'+powDetailsTempMap);
        
        Map<String,Object> powDetailsMap = (Map<String,Object>) powDetailsTempMap.get('paymentOfWagesDetails');        
        
        String lawDetails = '{"lawDetails":{"lawFirmRepZipCode":"123456","lawfirmRepStatePhone":"123456789","lawfirmRepEmail":"Test@test.com","lawfirmRepWebsite":"https://test.com"}}';
        Map<String,Object> lawDetailsTempMap = (Map<String,Object>) json.deserializeUntyped(lawDetails);
        System.debug('powDetailsTempMap::'+lawDetailsTempMap);
        
        Map<String,Object> lawDetailsMap = (Map<String,Object>) lawDetailsTempMap.get('lawDetails');        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        //req.requestBody = Blob.valueOf(JSON.serializePretty(JsonMsg));
        req.requestBody = Blob.valueof(JsonMsg);
        system.debug('Jreq.requestBody ' + req.requestBody.toString());
        RestContext.request = req;
        RestContext.response= res;
        System.RunAs(getUserRecord){
            Test.startTest();        
            Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                           Role__c = 'Claimant',
                                                           Street_Address__c = '123 Praire City Drive, Apt B',
                                                           City__c = 'Whittier',
                                                           State__c = 'CA',
                                                           Zip_Code__c = '90607',
                                                           RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                          );
            
            
            List<DIR_Case__c>d=new List<DIR_Case__c>();
            c.Status__c = 'Not Confirmed';
            d.add(c);
            update d;
            
            OWCOnlineClaimThirdPartyAPIService.paymentOfWagesMap(powDetailsMap);
            OnlineWageClaimThirdPartyWebService.getResponce();
            OnlineWageClaimThirdPartyAPIController.createRelatedPartyRecords(JsonMsg);
            OnlineWageClaimThirdPartyAPIController.onlineClaimSubmit(JsonMsg);
            OWCOnlineClaimThirdPartyAPIService.prepareRelatedPartyForLawFirmRepresentative(powDetailsMap);
            OWCOnlineClaimThirdPartyAPIService.prepareRelatedPartyForLawFirmRepresentative(lawDetailsMap);
            Test.stopTest(); 
        }
        
    }
    
    
    
    
}