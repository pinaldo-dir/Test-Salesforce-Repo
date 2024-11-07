@IsTest
public class OWCMultipleFileDeleteControllerTest {
    @IsTest
    public static void testSetUp(){
        
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
        Profile p = [select id from profile where name='RCI User'];
        User u = new User(alias = 'standt', email='alex@vertiba.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='testuser1@ca-dir.com');
        insert u;
        triggerSettings.add(dlrs_Related_PartyTriggersetting);
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        //internal employee
        DIR_Employee__c de = new DIR_Employee__c();
        de.Name = 'name';
        de.Position__c = 'Deputy';
        de.User__c = u.Id;
        de.Manager__c = ma.Id;
        insert de;
        
        Account defendant = new Account();
        defendant.firstName='defendant';
        defendant.lastName='xyz';
        defendant.PersonEmail='defendant@gmail.com';	
        defendant.Email__c='defendant@gmail.com';
        defendant.ShippingPostalCode = '234881';
        String typeId =[SELECT Id FROM RecordType WHERE Name = 'Person Account'].Id;
        System.debug('Id'+ typeId);
        defendant.RecordTypeId=typeId; 
        
        Account Claimant = new Account();
        Claimant.firstName='Claim';
        Claimant.lastName='ant acc';
        Claimant.PersonEmail='Claim@gmail.com';
        //Claimant.PersonMobilePhone = '8377922024';
        Claimant.Email__c='defendant@gmail.com';
        Claimant.ShippingPostalCode = '234889';
        Claimant.RecordTypeId=typeId; 
        
        List<Account> accList = new List<Account>();
        accList.add(Claimant);
        accList.add(defendant);
        insert accList;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = defendant.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        
        insert c;
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = c.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;

            //System.assertEquals(contentlink.ContentDocumentId,contentVersion_2.ContentDocumentId );
        
        List<String> contentVersionIds = new List<String>();
        contentVersionIds.add(contentlink.Id);
        Test.startTest();
        OWCMultipleFileDeleteController.deleteMultipleFiles(contentVersionIds);
        Test.stopTest();
    }
}