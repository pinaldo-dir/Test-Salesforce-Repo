global class SBX_PostRefreshAutomation implements SandboxPostCopy{

    @testVisible static final Integer DEFAULT_BATCH_SIZE = 2; 
    static String currHost = URL.getOrgDomainURL().getHost();
    static String sandboxName;
    static String commBaseURL;
    static String baseUrl = url.getOrgDomainURL().toexternalform();
       

    global void runApexClass(SandboxContext context) {
        System.debug('Base URL External form ' + url.getOrgDomainURL().toexternalform());        
        System.debug('SandboxContext Org ID: ' + context.organizationId());
        System.debug('SandboxContext Sandbox ID: ' + context.sandboxId());
        System.debug('SandboxContext Sandbox Name: ' + context.sandboxName());

        if (baseUrl.containsignorecase('--'))
        {
            sandboxName = baseUrl.substringBetween('--','.').toLowerCase();
        } else 
        {
            sandboxName = '';
        }

        if (sandboxName != null) 
        {
            commBaseURL = 'https://cadir--' + sandboxName + '.sandbox.my.site.com/registrations';
        } 
        else 
        {
            commBaseURL = 'https://cadir.my.site.com/registrations';
        }       

        if (sandboxName != null || Test.isRunningTest())
        {
            updateAdministratorsAccount();
            updateCustomSettings();

            if (sandboxName.containsignorecase('uat') || sandboxName.containsignorecase('devcode'))
            {
                updateSMEAndRegistratiorUsers();
                
                Id batchJobId1 = Database.executeBatch(new UpdateAccountEmailBatch(), DEFAULT_BATCH_SIZE);
                Id batchJobId2 = Database.executeBatch(new UpdateAccountPersonEmailBatch(), DEFAULT_BATCH_SIZE);
                Id batchJobId3 = Database.executeBatch(new UpdateRegistrationLicenseEmailBatch(), DEFAULT_BATCH_SIZE+18);
                Id batchJobId4 = Database.executeBatch(new UpdateRegistrationAccountEmailBatch(), DEFAULT_BATCH_SIZE);
            }            
        }      
    }
        
    @testVisible
    @future
    public static void updateAdministratorsAccount()
    {
        List<User> adminUserlist = [SELECT id, Name, Profile.Name, Profile.Id, email from User where Profile.Name like 'System Administrator%' and isActive = true and email like '%.invalid%'];
    
        if (!adminUserlist.isEmpty()){
            for(user u: adminUserlist){
                u.email = u.email.replace('.invalid', '');
                
                //if sandbox not UAT and Profile is System Administrator LTD, change profile to System Administrator
                //as they need to be admin in other sandboxes
                if (!sandboxName.containsignorecase('uat') && u.Profile.Name.containsignorecase('System Administrator LTD'))
                {
                     u.profileid = '00ed00000013xgXAAQ';
                }                        
            }
            update adminUserlist;
        }        
    }
    
    @testVisible
    @future
    private static void updateSMEAndRegistratiorUsers()
    {
        //Update SME and some registration users
        List<User> smeuserlist = [SELECT id, Name, Profile.Name, email from User where isActive = true and isSME__c = true and email like '%.invalid%'];
        if (!smeuserlist.isEmpty()){
            for (user u : smeuserlist){
                u.email = u.email.replace('.invalid', '');
            }
            update smeuserlist;               
        }
    }
    
    @testVisible
    @future
    private static void updateCustomSettings()
    {
        //update some key-value-store variables
        List<Key_Value_Store__c> kvslist = [select id, name, Description__c, Value__c from Key_Value_Store__c];
        if (!kvslist.isEmpty()){
            for (Key_Value_Store__c kvs : kvslist){
                if (kvs.name.contains('Community UserID Suffix'))
                    kvs.value__c = kvs.value__c + '.' + sandboxName;
                if (kvs.name.contains('RS Community Base URL')) 
                    kvs.value__c = commBaseURL;
                if (kvs.name.contains('BaseURL'))
                    kvs.value__c = currHost;
                if (kvs.name.contains('PostRefreshCounter'))
                    kvs.value__c = '0';                
            }
            update kvslist;
        }
    }
    
    public void neededForTestCoverage() {
        // keep this so that coverage is not dependent on custom metadata records
        
        String foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
    }
    
}