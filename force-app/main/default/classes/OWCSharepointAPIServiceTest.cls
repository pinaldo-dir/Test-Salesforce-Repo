@isTest
public class OWCSharepointAPIServiceTest {
	@TestSetup
    public  static void muleSoftUploadSetupData(){
        OWCTestDataFactory.createTriggerCustomSettingRecord();
        Attachments_New__c attachPlusObj = new Attachments_New__c();
        attachPlusObj.APlus_Json__c = '{"files":[{"fileName":"Test1 (1)","fileExtension":"JPG","description":"Description","contentDocumentId":"06835000001o5I7AAI","attachmentFolder":"Investigation","aplusId":"a4C350000008WR9EAM"}],"caseNumber":"CM-882958"}';
        attachPlusObj.File_Name__c = 'Test1 (1)';
        attachPlusObj.Share_Point_Item_Id__c = '12345678909';
        insert attachPlusObj;
        
        ContentVersion contentVersion = new ContentVersion(
                                                            Title          = 'Wage Claim Summary Report',
                                                            PathOnClient   = 'WageClaimSummaryReport.pdf',
                                                            VersionData    = Blob.valueOf('Wage Claim Summary Report'),
                                                            IsMajorVersion = true
        												  );
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = attachPlusObj.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }
    
    @isTest
    public static void uploadDataOnMule(){
        Test.setMock(HttpCalloutMock.class, new OWCSharePointMockService());
        List<String> attachPlusList = new List<String>();
        Attachments_New__c attachPlusObj = [SELECT Id, File_Name__c, APlus_Json__c, Share_Point_Item_Id__c FROM Attachments_New__c WHERE Share_Point_Item_Id__c = '12345678909' LIMIT 1];
        attachPlusList.add(attachPlusObj.Id);
        Test.startTest();
        String jsonData = '{"files":[{"fileName":"Test1 (1)","fileExtension":"JPG","description":"Description","contentDocumentId":"06835000001o5I7AAI","attachmentFolder":"Investigation","aplusId":"a4C350000008WR9EAM"}],"caseNumber":"CM-882958"}';
        //OWCSharepointAPIService.uploadDataOnMule(jsonData);
        OWCSharepointAPIService.deleteFileFromSharePoint(jsonData, attachPlusObj.Id);
        OWCSharepointAPIService.uploadFaildFileOnMule(JSON.serialize(attachPlusObj));
        OWCSharepointAPIService.getFilesFromSharePoint(attachPlusList);
        OWCSharepointAPIService.viewSharePointFile(attachPlusObj.Id);
        OWCSharepointAPIService.moveFileOnSharePoint(jsonData);
        Test.stopTest();
    }
    
    @isTest
    static void testUploadDataMule(){
        Test.startTest();
        String jsonData = '{"files":[{"fileName":"Test1 (1)","fileExtension":"JPG","description":"Description","contentDocumentId":"06835000001o5I7AAI","attachmentFolder":"Investigation","aplusId":"a4C350000008WR9EAM"}],"caseNumber":"CM-882958"}';
        OWCSharepointAPIService.uploadDataOnMule(jsonData);
        Test.stopTest();
    }

}