@isTest
public class TestenhancedNoteEditDeleteRules {
    
    //Verify that Standard User profiles are unable to delete attachments
    static testMethod void testStandardUser() {
        
        // Create a new user with the Standard User profile
        Profile standardProf = [select id from profile where name='Standard User']; 
        User su = new User(alias = 'standt', email='standarduser12@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = standardProf.Id, 
            timezonesidkey='America/Los_Angeles', username='standarduser127843@testorg.com');
            
        // Switch current user to Standard User
        System.runAs(su) {      
        
            // Create test data (a new Account with an Note)
            Account acct = new Account(Name = 'Test Account');
            insert acct;
            
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
            contentlink.LinkedEntityId = acct.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            

            ContentNote nt = new ContentNote(Title='Title of Note', Content=Blob.valueOf('Content of Note'));
            insert nt;
            ContentDocument cd = [select id from ContentDocument where id=:nt.Id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cd.id;
            cdl.LinkedEntityId = acct.Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;

            // Verify the "Unable to delete attachments" error is thrown when attachment is deleted
            Boolean errorThrown = false; 
            try {
                delete cd;
            } catch (Exception e) {
                System.debug(e);
                if (e.getMessage().contains('Notes cannot be deleted')) {
                    errorThrown = true;
                }
            }
            System.assert(errorThrown);
            
        }
    }
    
    static testMethod void testAdminUser() {
        
        // Next make sure that a System Admin can delete an attachment
        Profile adminProf = [select id from profile where name='System Administrator']; 
        User au = new User(alias = 'admint', email='adminuser12@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestUser111', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = adminProf.Id, 
            timezonesidkey='America/Los_Angeles', username='adminuser127896@testorg.com');
        
        // Switch current user to System Admin user
        System.runAs(au) {
            
            // Create test data (a new Account with an Note)
            Account acct = new Account(Name = 'Test Account');
            insert acct;
            
            ContentNote nt = new ContentNote(Title='Title of Note', Content=Blob.valueOf('Content of Note'));
            insert nt;
            ContentDocument cd = [select id from ContentDocument where id=:nt.Id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cd.id;
            cdl.LinkedEntityId = acct.Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            // Verify that no error is thrown when the attachment is deleted
            Boolean errorThrown = false;
            try {
                delete nt;
            } catch (Exception e) {
                System.debug(e);
                errorThrown = true;
            }
            System.assert(!errorThrown);
        }
    }
    
}