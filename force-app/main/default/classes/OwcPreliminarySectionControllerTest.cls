@isTest
public class OwcPreliminarySectionControllerTest {
    @testSetup static void setUpMethod() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User userRecord = new User(
            ProfileId = p.Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id);
        insert userRecord;
    }
    @istest 
    public static void getOWCPreliminaryMetaData(){
        User  getUserRecord  = [SELECT Id, Name FROM User WHERE Email = 'puser000@amamama.com'];
        String userId = getUserRecord.Id;
        Test.startTest();
        List<OwcPreliminarySectionController.preliminarySectionMetaData> getOWCPreliminaryMetaDataTest = OwcPreliminarySectionController.getOWCPreliminaryMetaData(userId);
        Test.stopTest();
        System.assert(getOWCPreliminaryMetaDataTest.size()>0);
    }
}