@isTest
public class OWCThirdPartyGeneratePDFBatchTest {
    @istest
    public static void testThirdPartyPDFBatch(){
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
        
        Test.startTest();
        Attachments_New__c objAttachment1 = new Attachments_New__c(File_Name__c = 'Test',
                                                                  File_Type__c = 'Test',
                                                                  Related_Id__c = c.Id,
                                                                  APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"Legal","fieldName":"File_Name","fieldAPIName":"File_Name"},{"value":"Third Party","fileType":"Legal","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"Legal","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"Legal","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]');
        
        insert objAttachment1;
        ContentVersion cont = new ContentVersion();
            cont.Description = 'Third Party';
            cont.Title = 'Wage Claim Summary Report';
            cont.PathOnClient = 'online_claim_summary.pdf';
            if(Test.isRunningTest()){
                cont.VersionData = blob.valueOf('Unit.Test'); 
            }
            
            //cont.
            cont.Origin = 'H';
            insert cont;  
            ContentVersion contentVersion_2 = [SELECT Id, Title,FileType, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = :cont.Id LIMIT 1];
        	ContentDocumentLink contentlink1 = new ContentDocumentLink();
        contentlink1.LinkedEntityId = c.Id;
        contentlink1.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink1.ShareType = 'V';
        contentlink1.Visibility = 'AllUsers';
        
        ContentDocumentLink contentlink2 = new ContentDocumentLink();
        contentlink2.LinkedEntityId = objAttachment1.Id;
        contentlink2.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink2.ShareType = 'V';
        contentlink2.Visibility = 'AllUsers';
        insert new List<ContentDocumentLink>{contentlink1, contentlink2};
            OWCThirdPartyGeneratePDFBatch batch = new OWCThirdPartyGeneratePDFBatch(c.Id, true);
        Database.executeBatch(batch);
        Test.stopTest();
    }
}