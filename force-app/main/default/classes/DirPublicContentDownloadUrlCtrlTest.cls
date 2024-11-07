@IsTest
public class DirPublicContentDownloadUrlCtrlTest {
    @IsTest static void testGetDownloadPublicContentUrl(){
        ContentVersion cv = DIRDataFactory.createContentDocumentForAttachmentObj();
        ContentDistribution newDist = new ContentDistribution();
        newDist.ContentVersionId = cv.Id;
        newDist.Name = 'Port Drayage Link';
        newDist.PreferencesNotifyOnVisit = false;
        newDist.PreferencesAllowViewInBrowser = true;
        newDist.PreferencesAllowOriginalDownload=true;
        insert newDist;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = DIRDataFactory.createContentDocumentLinkForAttachmentObj((String)conDocId);
        Set<Id> createContentdocumentIdSet = new Set<Id>(); 
        createContentdocumentIdSet.add(conDocLink.ContentDocumentId);
        Test.startTest();
        List<DirPublicContentDownloadUrlController.contentDistributionObj> result = DirPublicContentDownloadUrlController.getDownloadPublicContentUrl(createContentdocumentIdSet);
        Test.stopTest();
        System.assert(result != null);
    }
}