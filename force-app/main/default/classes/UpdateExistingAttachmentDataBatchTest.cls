@IsTest
public class UpdateExistingAttachmentDataBatchTest {
    @IsTest
    public static void testAttachmentDataBatch(){
        Attachments_New__c attachPlus = new Attachments_New__c();
        attachPlus.File_Name__c = 'test.pdf';
        attachPlus.File_Type__c = 'Intake';
        insert attachPlus;
        
        Attachments_Data__c attachDataObj = new Attachments_Data__c();
        attachDataObj.Attachments__c = [SELECT Id, File_Name__c FROM Attachments_New__c WHERE File_Name__c = 'test.pdf' LIMIT 1].Id;
        attachDataObj.Value__c = 'test';
        attachDataObj.Field_API_Name__c = 'test';
        attachDataObj.Field_Name__c = 'test';
        insert attachDataObj;
        
        Test.startTest();
        UpdateExistingAttachmentDataBatch scope = new UpdateExistingAttachmentDataBatch();
        Database.executeBatch(scope);
        Test.stopTest();
        
    }
}