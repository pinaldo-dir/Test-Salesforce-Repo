@isTest
public class AttachmentsDataTriggerHandlerTest {
	@testSetup 
    static void createTestData(){
        
        Attachments_New__c attachmentObj1 = new Attachments_New__c();
        attachmentObj1.File_Name__c = 'Test2';
        attachmentObj1.File_Type__c = 'Port';
        attachmentObj1.Release_to_Public__c = false;
        insert attachmentObj1;
        
        Attachments_Data__c attachmentDataObj1 = new Attachments_Data__c();
        attachmentDataObj1.Attachments__c = attachmentObj1.Id;
        attachmentDataObj1.Value__c = 'false';
        attachmentDataObj1.Field_API_Name__c = 'Release_to_Public_Port';
        insert attachmentDataObj1;
    }
    @isTest static void insertAttachmentsDataTriggerHandlerTest(){
        Attachments_New__c attachmentObj2 = new Attachments_New__c();
        attachmentObj2.File_Name__c = 'Test2';
        attachmentObj2.File_Type__c = 'Port';
        insert attachmentObj2;
        
        Attachments_Data__c attachmentDataObj = new Attachments_Data__c();
        attachmentDataObj.Attachments__c = attachmentObj2.Id;
        attachmentDataObj.Value__c = 'true';
        attachmentDataObj.Field_API_Name__c = 'Release_to_Public_Port';
        
        Test.startTest();
        insert attachmentDataObj;
        Attachments_New__c attachmentsToUpdate = [SELECT ID, Release_to_Public__c FROM Attachments_New__c WHERE
                                                        ID =:attachmentDataObj.Attachments__c AND 
                                                 Release_to_Public__c=: Boolean.valueOf(attachmentDataObj.Value__c)];
        System.assertEquals(attachmentsToUpdate.Release_to_Public__c, Boolean.valueOf(attachmentDataObj.Value__c));
        Test.stopTest();
        
    }
    
    @isTest static void updateAttachmentsDataTriggerHandlerTest(){      
        Attachments_Data__c attachmentDataObj = [SELECT Value__c,Field_API_Name__c,Attachments__c FROM 
                                                 Attachments_Data__c LIMIT 1];
        attachmentDataObj.Value__c='true';
        Test.startTest();
        update attachmentDataObj;
        Attachments_New__c attachmentsToUpdate = [SELECT ID, Release_to_Public__c FROM Attachments_New__c WHERE
                                                        ID =:attachmentDataObj.Attachments__c 
                                                 ];
        System.assertEquals(attachmentsToUpdate.Release_to_Public__c ,Boolean.valueOf(attachmentDataObj.Value__c));
        Test.stopTest();
    }
}