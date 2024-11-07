@isTest
public class OWCCaseManagementControllerTest {
    @testSetup static void setUpMethod() {
        List<Trigger_Settings__c> triggerSettings = OWCTestDataFactory.createTriggerCustomSettingRecord();
        
        DIR_Employee__c employerObj = OWCTestDataFactory.createEmployerRecord();
            
            
            
            RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
            
            Office__c office = new Office__c();
            office.Name = 'Lucian832474';
            insert office;
            
            Zip_Code__c zip = new Zip_Code__c();
            zip.Name = '234889';
            insert zip;
            
            Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
            map1.Zip_Code__c = zip.Id;
            map1.Office__c = office.Id;
            insert map1;
            
            Id p = [select id from profile where name='Customer Online Claim User'].id;
            System.debug('Community profile::::'+p);
            
            Account mainA = new Account();
            mainA.firstName='abc';
            mainA.lastName='xyz';
            mainA.PersonEmail='abc@gmail.com';
            mainA.ShippingPostalCode = '234889';
            
            String typeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
            System.debug('Id'+ typeId);
            mainA.RecordTypeId=typeId; 
            insert mainA;
            
            
            
            
            String email = 'test@gmail.com';
            String accountId = mainA.Id;
                        
            Account ac = new Account(name ='Grazitti') ;
            insert ac;
            
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
            insert con;
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                 ContactId = con.Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            
            Account affA = new Account();
            affA.Name = 'Lucian235432';
            String typeId1 =[SELECT Id FROM RecordType WHERE Name = 'Business Account'].Id;
            affA.RecordTypeId=typeId1; 
            insert affA;
            
            DIR_Case__c c = new DIR_Case__c();
            c.Employer__c = mainA.Id;
            c.Status__c = 'New';
            c.RecordTypeId = caseRT.Id;            
            c.Assigned_Deputy__c = employerObj.Id;
        	c.Online_Claim_Account__c = ac.Id;
            
            insert c;
        
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'Wage Claim Summary Report',
                PathOnClient   = 'WageClaimSummaryReport.pdf',
                VersionData    = Blob.valueOf('Wage Claim Summary Report'),
                IsMajorVersion = true);
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = c.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        
        String PERSON_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account accObj = new Account();
        accObj.LastName = 'testCommunityUser';
        accObj.RecordTypeId = PERSON_ACCOUNT_RECORD_TYPE_ID;
        insert accObj;
        
    } 
    @istest 
    public static void getSubmittedCaseRecordsTest(){
        User  getUserRecord  = [SELECT Id, Name, accountId FROM User WHERE email = 'test123@noemail.com' limit 1];
        List<DIR_Case__c> getDemoCase = [SELECT Id, Name, Bank__c FROM DIR_Case__c where Online_Claim_Account__c =: getUserRecord.accountId limit 1];
        List<OWCCaseManagementController.caseWrapperObj> getDemoCaseRecord;
        System.debug('Omega'+getUserRecord.accountId);
        Test.startTest();
        system.runAs(getUserRecord) {
            getDemoCaseRecord = OWCCaseManagementController.getSubmittedCaseRecords();
         	OWCCaseManagementController.getCaseDetails(getDemoCase[0].Id);
        }
        Test.stopTest();
       	System.assert(getDemoCaseRecord.size()>0);
        System.assertEquals(getDemoCaseRecord.size(), getDemoCase.size());
    }
}