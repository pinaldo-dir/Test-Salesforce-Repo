@IsTest
public class Test_DeactivateOnlineUsersWithClosedCase {
    @IsTest
    public static void testme(){
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        List<Trigger_Settings__c> triggerSettings = OWCTestDataFactory.createTriggerCustomSettingRecord();
        User userObj = OWCTestDataFactory.createCommunityUserAccount();
        Id userAccountId = [SELECT Id, Name, AccountId FROM User WHERE Id =: userObj.Id LIMIT 1].AccountId;
        System.debug('AccountId ::: '+userAccountId);
        
        Account mainA = new Account();
        mainA.FirstName = 'Right';
        mainA.LastName = 'Cow';
        mainA.ShippingPostalCode = '234889';
        mainA.Phone='9653472428';
        insert mainA;
        
        DIR_Case__c caseObj = new DIR_Case__c();
        caseObj.Online_Claim_Account__c = userAccountId;
        caseObj.Status__c = 'Closed';
        caseObj.Case_Closed_Date__c = System.today().addDays(-99);
        caseObj.RecordTypeId = caseRecordTypeId;
        caseObj.Employer__c = mainA.Id;
        insert caseObj;
        
        Test.startTest();
        OWCDeactivateOnlineUsersScheduler scope = new OWCDeactivateOnlineUsersScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, scope );
        Test.stopTest();
    }
}