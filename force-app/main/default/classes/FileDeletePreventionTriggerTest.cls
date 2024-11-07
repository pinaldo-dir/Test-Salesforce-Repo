@isTest
private class FileDeletePreventionTriggerTest {
    
    static testMethod void testFileDeletionPrevention() {
        
        // Create a test user with HR profile
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'HR Personnel Specialist User' LIMIT 1];
        User testUser = new User(
            LastName = 'Test',
            Alias = 'test',
            Email = 'testuser@testorg.com',
            Username = 'testuser@testorg.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Set the current user to the test user
        System.runAs(testUser) {
            // Create a test content document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'Test Document.txt';
            cv.VersionData = Blob.valueOf('Test Content');
            insert cv;

            ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id LIMIT 1];

            // Try to delete the test content document
            try {
                delete cd;
                System.assert(false, 'File deletion should have been prevented');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('You do not have permission to delete file'), 'Correct error message not thrown');
            }
        }
    }
}