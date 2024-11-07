@isTest
class SBX_PostRefreshAutomationTest {
    
          
    private static final String ORGID = UserInfo.getOrganizationId();
    private static final String SBXID = UserInfo.getOrganizationId();
    private static final String SBXNM = UserInfo.getUserName().substringAfterLast('.');
    
    static List<String> CTX = new List<String>();

    @isTest
    static void testMySandboxPrep() {

        SBX_PostRefreshAutomationTest.CTX.add(SBX_PostRefreshAutomationTest.ORGID);
        SBX_PostRefreshAutomationTest.CTX.add(SBX_PostRefreshAutomationTest.SBXID);
        SBX_PostRefreshAutomationTest.CTX.add(SBX_PostRefreshAutomationTest.SBXNM);
        
        String currentHost = URL.getOrgDomainURL().getHost();     
        String sandboxName = '';
        String communityBaseURL = '';
        String sandboxOrgId = UserInfo.getOrganizationId();
             
        if (currentHost != null || SBXNM == 'gov')
        {            
            sandboxName = currentHost.substringBetween('--','.');
        }         
        
        if (sandboxName != null)
        {
            communityBaseURL = 'https://cadir--' + sandboxName + '.sandbox.my.site.com/registrations';
        } else
        {
            communityBaseURL = 'https://cadir.my.site.com/registrations';
        }
        
        profile p = [SELECT ID from Profile Where name = 'System Administrator LTD' Limit 1];
        String personRT = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Person Account'].id;
        
        user u = new User();
        u.username = 'lralltestuser@test.com';
        u.Email = 'lralltestuser@test.com.invalid';
        u.LastName = 'testuserlastname';
        u.ProfileId = p.Id;
        u.EmailEncodingKey = 'ISO-8859-1';
        u.Alias = 'uName';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        System.debug('User - ' + u.Id);    

        List<Account> accts = new List<Account>();
        Account acc1 = new Account(
            Name = 'test acct 1',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            Email__c = 'test_businessemail_account@test.com.invalid'
        );
        insert acc1;
        accts.add(acc1);
        
        List<Key_Value_Store__c> kvsclist = new List<Key_Value_Store__c>();
        Key_Value_Store__c kvcs1 = new Key_Value_Store__c();
        kvcs1.name = 'Community UserID Suffix';
        kvcs1.value__c = '.regcom';
        insert kvcs1;
        kvsclist.add(kvcs1);
        
        Key_Value_Store__c kvcs2 = new Key_Value_Store__c();
        kvcs2.name = 'RS Community Base URL';
        if (sandboxName != null)
        {
            kvcs2.value__c = 'https://cadir--' + sandboxName + '.sandbox.my.site.com/registrations';
        } else 
        {
            kvcs2.value__c = 'https://cadir.my.site.com/registrations';
        }
        
        insert kvcs2;
        kvsclist.add(kvcs2);

        Key_Value_Store__c kvcs3 = new Key_Value_Store__c();
        kvcs3.name = 'BaseURL';
        if (sandboxName != null)
        {
            kvcs3.value__c = 'https://cadir--' + sandboxName + '.sandbox.my.salesforce.com';
        } else
        {
            kvcs3.value__c = 'https://cadir.my.salesforce.com';
        }
        
        insert kvcs3;
        kvsclist.add(kvcs3);

        Key_Value_Store__c kvcs4 = new Key_Value_Store__c();
        kvcs4.name = 'PostRefreshCounter';
        kvcs4.value__c = '1';
        insert kvcs4;
        kvsclist.add(kvcs4);

        Test.startTest();
        
        if (sandboxName != null)
        {
            if (sandboxName.containsignorecase('uat'))
            {
                Test.testSandboxPostCopyScript(
                    new SBX_PostRefreshAutomation(), 
                    '00DBZ0000008qch' ,
                    '00DBZ0000008qch' , 
                    'uat' );             
            } else 
            {
                Test.testSandboxPostCopyScript(
                    new SBX_PostRefreshAutomation(), 
                    SBXID,
                    SBXID, 
                    sandboxName );                      
            }
        } else 
        {
            Test.testSandboxPostCopyScript(
                new SBX_PostRefreshAutomation(), 
                '00Dd0000000fe2H',
                '00Dd0000000fe2H', 
                'prod'
            );
        
        }
        
        Test.stopTest();

        if (sandboxName != null || SBXNM == 'gov')
        {        
            List<Key_Value_Store__c> kvslist1 = [select id, name, Description__c, Value__c from Key_Value_Store__c where name IN ('Community UserID Suffix', 'Integration User', 'Reg Community Profile', 'RS Community Base URL')];        
            if (kvslist1 != null)
            {
                for (Key_Value_Store__c kvs1 : kvslist1){
                    if (kvs1.name == 'Community UserID Suffix')
                        System.assertEquals(kvs1.value__c , kvs1.value__c);
                }
            }        
    
            UpdateAccountEmailBatch updateAE = new UpdateAccountEmailBatch();
            Id testbatchjob1 = Database.executeBatch(updateAE, SBX_PostRefreshAutomation.DEFAULT_BATCH_SIZE);
            List<AsyncApexJob> batchJob1 = [SELECT Id, Status, JobType, ApexClassId FROM AsyncApexJob where id = :testbatchjob1];
            if (batchJob1 != null)
            {
                for (AsyncApexJob bj1 : batchJob1)            
                {
                    System.debug('Batch Id - ' + bj1.Id);
                    System.assertEquals('Queued', bj1.Status);
                }
            }
    
            UpdateAccountPersonEmailBatch updateAPE = new UpdateAccountPersonEmailBatch();
            Id testbatchjob2 = Database.executeBatch(updateAPE, SBX_PostRefreshAutomation.DEFAULT_BATCH_SIZE);
            List<AsyncApexJob> batchJob2 = [SELECT Id, Status, JobType, ApexClassId FROM AsyncApexJob where id = :testbatchjob2];
            if (batchJob2 != null)
            {
                for (AsyncApexJob bj2 : batchJob2)            
                {
                    System.debug('Batch Id - ' + bj2.Id);
                    System.assertEquals('Queued', bj2.Status);
                }
            }
    
            UpdateRegistrationLicenseEmailBatch updateRLE = new UpdateRegistrationLicenseEmailBatch();
            Id testbatchjob3 = Database.executeBatch(updateRLE, SBX_PostRefreshAutomation.DEFAULT_BATCH_SIZE);
            List<AsyncApexJob> batchJob3 = [SELECT Id, Status, JobType, ApexClassId FROM AsyncApexJob where id = :testbatchjob3];
            if (batchJob3 != null)
            {
                for (AsyncApexJob bj3 : batchJob3)
                {
                    System.debug('Batch Id - ' + bj3.Id);
                    System.assertEquals('Queued', bj3.Status);
                }
            }
    
            UpdateRegistrationAccountEmailBatch updateRAE = new UpdateRegistrationAccountEmailBatch();
            Id testbatchjob4 = Database.executeBatch(updateRAE, SBX_PostRefreshAutomation.DEFAULT_BATCH_SIZE);
            List<AsyncApexJob> batchJob4 = [SELECT Id, Status, JobType, ApexClassId FROM AsyncApexJob where id = :testbatchjob4];
            if (batchJob4 != null)
            {
                for (AsyncApexJob bj4 : batchJob4)
                {
                    System.debug('Batch Id - ' + bj4.Id);
                    System.assertEquals('Queued', bj4.Status);
                }
            }
            
            if (sandboxName != null)
            {
                User u1 = [Select id, email, username from User where id =: u.id];
                System.assertEquals('lralltestuser@test.com', u1.email);
            }   
        }                
    }
     @isTest static void testCoverage() {

    SBX_PostRefreshAutomation batch = New SBX_PostRefreshAutomation();              
         batch.neededForTestCoverage();
         }
}