@isTest
public class OWCUploadFailedFilesBatchTest {
				
    @testSetup
    static void setupData(){
        List<RecordType> recordType = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and (NOT Name like '%paga%') LIMIT 1];
        Trigger_Settings__c cpTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = true
        );
        insert cpTriggerSetting;
        DIR_Case__c caseManRec = new DIR_Case__c();
        caseManRec.Case_Number__c = 'WC-CM-882980';
        caseManRec.RecordTypeId = recordType[0].Id;
        caseManRec.Purge_Date__c = Date.today();
        insert caseManRec;
        
        Attachments_New__c attachmentObj = new Attachments_New__c();
        attachmentObj.File_Name__c = 'Test1';
        attachmentObj.File_Type__c = 'Port';
        attachmentObj.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"Name"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        attachmentObj.Release_to_Public__c = true;
        attachmentObj.Related_Id__c = caseManRec.Id;
        //attachmentObj.Share_Point_Item_Id__c = null;
        attachmentObj.Sharepoint_File_Status__c = 'Error';
        insert attachmentObj;
        
        ContentVersion contentVersionRec = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersionRec; 
        
        List<ContentDocument> documents = [SELECT Id, Title, Description, FileType, FileExtension FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = attachmentObj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'I';
        cdl.visibility = 'AllUsers';
        insert cdl;
        
    }
    
     @isTest
    static void OWCUploadFailedFilesBatchTest(){
        Test.startTest();
        Database.executeBatch(new OWCUploadFailedFilesBatch(),1);
        System.debug('');
        
        Test.stopTest();
    }
}