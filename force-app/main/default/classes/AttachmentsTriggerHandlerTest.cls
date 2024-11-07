@isTest
public class AttachmentsTriggerHandlerTest {
    @testSetup 
    static void createTestData(){
        List<Trigger_Settings__c> createTrigger = OWCTestDataFactory.createTriggerCustomSettingRecord();
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
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
        String typeId =[SELECT Id FROM RecordType WHERE Name = 'Person Account'].Id;
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert affA;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        c.Purge_Date__c = date.today();
        insert c;
        
        Attachments_New__c attachmentObj = new Attachments_New__c();
        attachmentObj.File_Name__c = 'Test1';
        attachmentObj.File_Type__c = 'Port';
        attachmentObj.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"Name"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        attachmentObj.Release_to_Public__c = true;
        attachmentObj.Related_Id__c = c.Id;
        insert attachmentObj;
        
        Attachments_New__c attachmentObj1 = new Attachments_New__c();
        attachmentObj1.File_Name__c = 'Test2';
        attachmentObj1.File_Type__c = 'JPG';
        attachmentObj1.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"Namw"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        attachmentObj1.Release_to_Public__c = false;
        attachmentObj1.Related_Id__c = c.Id;
        insert attachmentObj1; 
        /*
        Attachments_Data__c attachmentDataObj = new Attachments_Data__c();
        attachmentDataObj.Attachments__c = attachmentObj.Id;
        attachmentDataObj.Value__c = 'False';
        attachmentDataObj.Field_API_Name__c = 'Release_to_Public_Port';
        insert attachmentDataObj;
        */
        AttachmentsTriggerHandler.File fileObj = new AttachmentsTriggerHandler.File();
        fileObj.newPath = '';
        fileObj.sharePointDocumentId = '';
        fileObj.fileExtension = '.pdf';
        fileObj.fileName = '';
        AttachmentsTriggerHandler.MoveFileWrapper scope = new AttachmentsTriggerHandler.MoveFileWrapper();
        scope.caseNumber = '';
        scope.file = fileObj;
    }
    
   /* @IsTest static void testAttachmentDelete(){
        Test.startTest();
        DIR_AttachmentsNewTriggerHandler.onBeforeDelete(mapattachments);
        Test.stopTest();
    }*/
    
    @isTest static void afterUpdateAttachementHandlerWithoutChild(){
        Attachments_New__c attachmentObj = [SELECT File_Type__c,Related_Id__c, Share_Point_Item_Id__c, Release_to_Public__c FROM Attachments_New__c
                                            WHERE File_Name__c = 'Test2' LIMIT 1];
        Test.startTest();
        System.debug('attachmentObj Related_Id__c::: '+attachmentObj.Related_Id__c);
        System.debug('attachmentObj Id::: '+attachmentObj.Id);
        attachmentObj.Release_to_Public__c = true;
        update attachmentObj;
        Test.stopTest();
    }
    @isTest static void DeleteLinkTest(){ 
        Attachments_New__c attachmentObj = [SELECT File_Type__c,Related_Id__c, Share_Point_Item_Id__c,Release_to_Public__c FROM Attachments_New__c
                                            WHERE File_Name__c = 'Test2' LIMIT 1];
        
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient = 'TestDocument.pdf';        
        cv.VersionData =beforeblob;  
        insert cv;         
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=attachmentObj.id;
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
            
        Test.startTest();
        attachmentObj.Release_to_Public__c = true;
        update attachmentObj;
        attachmentObj.Release_to_Public__c = false;
        
        update attachmentObj;
        delete attachmentObj;
        Test.stopTest();
    }
    
    @isTest static void DeleteFilesFromSalesforceTest(){ 
        Attachments_New__c attachmentObj = [SELECT File_Type__c,Related_Id__c, Share_Point_Item_Id__c,Release_to_Public__c FROM Attachments_New__c
                                            WHERE File_Name__c = 'Test2' LIMIT 1];
        
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient = 'TestDocument.pdf';        
        cv.VersionData =beforeblob;  
        insert cv;         
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=attachmentObj.id;
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
            
        Test.startTest();
        attachmentObj.Share_Point_Item_Id__c = '01GQWYHARNW5I5ZDIOFFGJ3JJGI3ZSJ3EI';
        attachmentObj.Sharepoint_File_Status__c = 'success';
        update attachmentObj;
        Test.stopTest();
    }
    
    @IsTest static void testAttachNoChild(){
        List<Trigger_Settings__c> createTrigger = OWCTestDataFactory.createTriggerCustomSettingRecord();
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
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
        String typeId =[SELECT Id FROM RecordType WHERE Name = 'Person Account'].Id;
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian2354232';
        insert affA;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        
        insert c;
        Attachments_New__c attachmentObj1 = new Attachments_New__c();
        attachmentObj1.File_Name__c = 'Test22';
        attachmentObj1.File_Type__c = 'JPG';
        attachmentObj1.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"Namw"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"true","fileType":"","fieldName":"Release_to_Public","fieldAPIName":"Release_to_Public"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        attachmentObj1.Release_to_Public__c = false;
        attachmentObj1.Related_Id__c = c.Id;
        insert attachmentObj1; 
        
        Attachments_New__c attachmentObj = [SELECT File_Type__c,Related_Id__c, Share_Point_Item_Id__c, Release_to_Public__c FROM Attachments_New__c
                                            WHERE File_Name__c = 'Test22' LIMIT 1];
        Test.startTest();
        attachmentObj.Release_to_Public__c = true;
        update attachmentObj;
        Test.stopTest();
    }
    @IsTest static void testAttachNoChild1(){
        List<Trigger_Settings__c> createTrigger = OWCTestDataFactory.createTriggerCustomSettingRecord();
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
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
        String typeId =[SELECT Id FROM RecordType WHERE Name = 'Person Account'].Id;
        System.debug('Id'+ typeId);
        mainA.RecordTypeId=typeId; 
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian2354232';
        insert affA;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        
        insert c;
        Attachments_New__c attachmentObj1 = new Attachments_New__c();
        attachmentObj1.File_Name__c = 'Test22';
        attachmentObj1.File_Type__c = 'JPG';
        attachmentObj1.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"Namw"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        attachmentObj1.Release_to_Public__c = true;
        attachmentObj1.Related_Id__c = c.Id;
        insert attachmentObj1; 
        
        Attachments_New__c attachmentObj = [SELECT File_Type__c,Related_Id__c, Share_Point_Item_Id__c, Release_to_Public__c FROM Attachments_New__c
                                            WHERE File_Name__c = 'Test22' LIMIT 1];
        Test.startTest();
        attachmentObj.Release_to_Public__c = false;
        update attachmentObj;
        Test.stopTest();
    }
    
    
    /*@isTest static void moveFileOnSharePointTest(){
        List<Attachments_New__c> attachmentObj1 = [SELECT File_Type__c,Related_Id__c, Share_Point_Item_Id__c,Release_to_Public__c FROM Attachments_New__c
                                            WHERE File_Name__c = 'Test2' LIMIT 1];
        Attachments_New__c attachmentObj2 = [SELECT File_Type__c,Related_Id__c,Share_Point_Item_Id__c,Release_to_Public__c FROM Attachments_New__c
                                            WHERE File_Name__c = 'Test1' LIMIT 1];
        Map<Id,Attachments_New__c> attachObjMap = new Map<Id,Attachments_New__c>();
        attachObjMap.put(attachmentObj2.Id, attachmentObj2);
        AttachmentsTriggerHandler.moveFileOnSharePoint(attachmentObj1,attachObjMap);
        
    }*/
}