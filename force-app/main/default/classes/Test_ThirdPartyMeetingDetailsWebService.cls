@isTest
public class Test_ThirdPartyMeetingDetailsWebService {
    
    @istest 
    public static void testThirdPartyMeetingDetailsWebService(){ 
        
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
        
		/*        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        //c.Case_Number__c = '1234';
        
        insert c;
        System.debug('c:::'+c);
        
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
        cr.Community_User_Account__c = affA.id;
        insert cr;
        
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                       Role__c = 'Claimant',
                                                       Community_User_Account__c = affA.id,
                                                       Street_Address__c = '123 Praire City Drive, Apt B',
                                                       City__c = 'Whittier',
                                                       State__c = 'CA',
                                                       Zip_Code__c = '90607',
                                                       RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                      );
        
        cr.Role__c = 'Owner';
        update cr;
        List<DIR_Case__c>d=new List<DIR_Case__c>();
        c.Status__c = 'Not Confirmed';
        d.add(c);
        update d;
        
        */
        User  getUserRecord  = [SELECT Id, Name FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        String userId = getUserRecord.Id;
        
        
        
        DIR_Case__c c1 = new DIR_Case__c();
        c1.Employer__c = mainA.Id;
        c1.Status__c = 'New';
        c1.RecordTypeId = caseRT.Id;            
        c1.Assigned_Deputy__c = de.Id;
        //c1.Case_Number__c = '1234';
        c1.Online_Claim_Account__c = affA.Id;
        insert c1;
        
        DIR_Case__c caseObj = [SELECT Id, Name, Case_Number__c, Online_Claim_Account__c FROM DIR_Case__c
                               WHERE Id =: c1.Id];
        System.debug('caseObj:::'+caseObj);
        Account accObj = [SELECT Name, Id, LastName, FirstName, MiddleName FROM Account WHERE Id =: mainA.Id];
        System.debug('accObj:::'+accObj);
        
        System.RunAs(getUserRecord){
            Test.startTest();
            
            OWCThirdPartyValidationCheckerController.validateMeetingAPIResponse(caseObj.Case_Number__c,mainA.lastName,null);
            try{                
                OWCThirdPartyValidationCheckerController.validateCCAPIResponse(caseObj.Case_Number__c,null);
                OWCThirdPartyValidationCheckerController.dateFormatChecker('2022-04-10',null);
            }catch(Exception e){
                System.debug('Exception 1:'+e);
            }
            
            Test.stopTest();
        }
    }
    
    
    @istest 
    public static void testThirdPartyMeetingDetailsWebService1(){ 
        
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
        
        /*
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        c.Case_Number__c = '1234';
        
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
        cr.Community_User_Account__c = affA.id;
        insert cr;
        
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                       Role__c = 'Claimant',
                                                       Community_User_Account__c = affA.id,
                                                       Street_Address__c = '123 Praire City Drive, Apt B',
                                                       City__c = 'Whittier',
                                                       State__c = 'CA',
                                                       Zip_Code__c = '90607',
                                                       RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                      );
        
        cr.Role__c = 'Owner';
        update cr;
        List<DIR_Case__c>d=new List<DIR_Case__c>();
        c.Status__c = 'Not Confirmed';
        d.add(c);
        update d;
        
        */
        
        
        User  getUserRecord  = [SELECT Id, Name FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        String userId = getUserRecord.Id;
        
        DIR_Case__c c1 = new DIR_Case__c();
        c1.Employer__c = mainA.Id;
        c1.Status__c = 'New';
        c1.RecordTypeId = caseRT.Id;            
        c1.Assigned_Deputy__c = de.Id;
        //c1.Case_Number__c = '1234';
        c1.Online_Claim_Account__c = affA.Id;
        insert c1;
        
        DIR_Case__c caseObj = [SELECT Id, Name, Case_Number__c, Online_Claim_Account__c FROM DIR_Case__c
                               WHERE Id =: c1.Id];
        System.debug('caseObj:::'+caseObj);
        Account accObj = [SELECT Name, Id, LastName, FirstName, MiddleName FROM Account WHERE Id =: mainA.Id];
        System.debug('accObj:::'+accObj);
        
        System.RunAs(getUserRecord){
            Test.startTest();
            
            //ThirdPartyMeetingDetailsWebService.getHearingDetails();  
            OWCThirdPartyValidationCheckerController.validateMeetingAPIResponse(null,'Test',userId);
            OWCThirdPartyValidationCheckerController.validateCCAPIResponse(null,userId);
            OWCThirdPartyValidationCheckerController.dateFormatChecker('2022','No Value');
            Test.stopTest();
        }
    }
    
    @istest 
    public static void testThirdPartyMeetingDetailsWebService2(){ 
        
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
        
        /*
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        //c.Case_Number__c = '1234';
        c.Online_Claim_Account__c = affA.Id;
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
        cr.Community_User_Account__c = affA.Id;
        cr.Role__c = 'Employer';
        cr.Case_Role_Status__c = 'No Longer Active On Case';
        cr.Reason_No_Longer_Active__c='its no longer active on case';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                       Role__c = 'Claimant',
                                                       Community_User_Account__c = affA.id,
                                                       Street_Address__c = '123 Praire City Drive, Apt B',
                                                       City__c = 'Whittier',
                                                       State__c = 'CA',
                                                       Zip_Code__c = '90607',
                                                       RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                      );
        
        cr.Role__c = 'Owner';
        update cr;
        List<DIR_Case__c>d=new List<DIR_Case__c>();
        c.Status__c = 'Not Confirmed';
        d.add(c);
        update d;
        
        
        */
        
        User  getUserRecord  = [SELECT Id, Name FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        String userId = getUserRecord.Id;
        
        
        DIR_Case__c c1 = new DIR_Case__c();
        c1.Employer__c = mainA.Id;
        c1.Status__c = 'New';
        c1.RecordTypeId = caseRT.Id;            
        c1.Assigned_Deputy__c = de.Id;
        //c1.Case_Number__c = '1234';
        c1.Online_Claim_Account__c = affA.Id;
        insert c1;
        
        DIR_Case__c caseObj = [SELECT Id, Name, Case_Number__c, Online_Claim_Account__c FROM DIR_Case__c
                               WHERE Id =: c1.Id];
        System.debug('caseObj:::'+caseObj);
        Account accObj = [SELECT Name, Id, LastName, FirstName, MiddleName FROM Account WHERE Id =: mainA.Id];
        System.debug('accObj:::'+accObj);
        System.RunAs(getUserRecord){
            
            
            Test.startTest();
            OWCThirdPartyValidationCheckerController.validateMeetingAPIResponse(caseObj.Case_Number__c,accObj.LastName,userId);
            OWCThirdPartyValidationCheckerController.validateCCAPIResponse(caseObj.Case_Number__c,userId);
            OWCThirdPartyValidationCheckerController.dateFormatChecker('2022','No Value');
            Test.stopTest();
        }
    }
    
    @istest 
    public static void testThirdPartyMeetingDetailsWebService3(){ 
        
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
        
        /*
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        //c.Case_Number__c = '1234';
        c.Online_Claim_Account__c = affA.Id;
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
        cr.Community_User_Account__c = affA.Id;
        cr.Role__c = 'Employer';
        cr.Case_Role_Status__c = 'No Longer Active On Case';
        cr.Reason_No_Longer_Active__c='its no longer active on case';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                       Role__c = 'Claimant',
                                                       Community_User_Account__c = affA.id,
                                                       Street_Address__c = '123 Praire City Drive, Apt B',
                                                       City__c = 'Whittier',
                                                       State__c = 'CA',
                                                       Zip_Code__c = '90607',
                                                       RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                      );
        
        cr.Role__c = 'Owner';
        update cr;
        List<DIR_Case__c>d=new List<DIR_Case__c>();
        c.Status__c = 'Not Confirmed';
        d.add(c);
        update d;
        
		*/
        
        
        User  getUserRecord  = [SELECT Id, Name FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        String userId = getUserRecord.Id;
        
        
        
        DIR_Case__c c1 = new DIR_Case__c();
        c1.Employer__c = mainA.Id;
        c1.Status__c = 'New';
        c1.RecordTypeId = caseRT.Id;            
        c1.Assigned_Deputy__c = de.Id;
        //c1.Case_Number__c = '1234';
        c1.Online_Claim_Account__c = affA.Id;
        insert c1;
        
        DIR_Case__c caseObj = [SELECT Id, Name, Case_Number__c, Online_Claim_Account__c FROM DIR_Case__c
                               WHERE Id =: c1.Id];
        System.debug('caseObj:::'+caseObj);
        Account accObj = [SELECT Name, Id, LastName, FirstName, MiddleName FROM Account WHERE Id =: mainA.Id];
        System.debug('accObj:::'+accObj);
        System.RunAs(getUserRecord){
            
            
            Test.startTest();
            OWCThirdPartyValidationCheckerController.validateMeetingAPIResponse(null,null,'test_Id');
            OWCThirdPartyValidationCheckerController.validateCCAPIResponse(null,'test_Id');
            Test.stopTest();
        }
    }
    
    
    @istest 
    public static void testThirdPartyMeetingDetailsWebService4(){ 
        
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
        
        /*
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        //c.Case_Number__c = '1234';
        c.Online_Claim_Account__c = affA.Id;
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
        cr.Community_User_Account__c = affA.Id;
        cr.Role__c = 'Employer';
        cr.Case_Role_Status__c = 'No Longer Active On Case';
        cr.Reason_No_Longer_Active__c='its no longer active on case';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = c.Id,
                                                       Role__c = 'Claimant',
                                                       Community_User_Account__c = affA.id,
                                                       Street_Address__c = '123 Praire City Drive, Apt B',
                                                       City__c = 'Whittier',
                                                       State__c = 'CA',
                                                       Zip_Code__c = '90607',
                                                       RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                      );
        
        cr.Role__c = 'Owner';
        update cr;
        List<DIR_Case__c>d=new List<DIR_Case__c>();
        c.Status__c = 'Not Confirmed';
        d.add(c);
        update d;
        */
        
        User  getUserRecord  = [SELECT Id, Name FROM User WHERE Id =: communityUser.Id];
        System.debug('getUserRecord:::'+getUserRecord);
        String userId = getUserRecord.Id;
        
        DIR_Case__c c1 = new DIR_Case__c();
        c1.Employer__c = mainA.Id;
        c1.Status__c = 'New';
        c1.RecordTypeId = caseRT.Id;            
        c1.Assigned_Deputy__c = de.Id;
        //c1.Case_Number__c = '1234';
        c1.Online_Claim_Account__c = affA.Id;
        insert c1;
        
        DIR_Case__c caseObj = [SELECT Id, Name, Case_Number__c, Online_Claim_Account__c FROM DIR_Case__c
                               WHERE Id =: c1.Id];
        System.debug('caseObj:::'+caseObj);
        Account accObj = [SELECT Name, Id, LastName, FirstName, MiddleName FROM Account WHERE Id =: mainA.Id];
        System.debug('accObj:::'+accObj);
        System.RunAs(getUserRecord){
            
             
            Test.startTest();
            OWCThirdPartyValidationCheckerController.validateMeetingAPIResponse('test_Id',null,null);
            OWCThirdPartyValidationCheckerController.validateCCAPIResponse('test_Id',null);
            Test.stopTest();
        }
    }
    
}