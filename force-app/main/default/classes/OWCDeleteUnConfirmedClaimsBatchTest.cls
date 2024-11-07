@isTest
public class OWCDeleteUnConfirmedClaimsBatchTest {
    static testMethod void testMethod1() {
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert affA;
        /*
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        System.runAs(u) {
		*/
        Test.startTest();
            Trigger_Settings__c setting = new Trigger_Settings__c();
            setting.Name = 'GenerateFieldHistoryAction';
            setting.Is_Active__c = true;
            insert setting;
            DIR_Case__c cse = new DIR_Case__c();
            cse.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
            cse.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
            cse.Advocate_Name_in_Text__c = 'Rajat';
            cse.Employer_Name_in_Text__c = 'Amit';
            cse.Claimant_Name_in_Text__c = 'Abhay';
            cse.Case_Number__c = 'testnumber';
            cse.Status__c = 'Closed';
            cse.Intake_Origin__c = 'Online';
            cse.Online_Claim_Account__c = affA.Id;
            cse.Closure_Disposition__c = 'Not confirmed by Claimant';
            cse.Purge_Date__c = Date.today();
            insert cse;
            System.debug('');
        OWCDeleteUnConfirmedClaimsBatch oduc = new OWCDeleteUnConfirmedClaimsBatch(0);
        DataBase.executeBatch(oduc); 
        Test.stopTest();
        //}
    }
}