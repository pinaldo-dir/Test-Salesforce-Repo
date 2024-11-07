global class UpdateAccountEmailBatch implements Database.Batchable<sobject> {
  
    global Database.QueryLocator start(database.BatchableContext bc ){
    
        String acctE = 'Select Id, Email__c from Account where Email__c != \'\' and (not Email__c like \'%.uat%\') ' ;
        return Database.getQueryLocator(acctE);
    }
    
    global void execute (Database.BatchableContext bc, List<Account> scope ) {
    
        String sandboxName;

        List<Organization> orgsList = [SELECT id, Name, isSandbox, instancename FROM Organization limit 1];
        if (orgsList != null)
        {
            for (Organization org : orgsList)
            {
                if (org.isSandbox)
                {
                    sandboxName = URL.getOrgDomainURL().getHost().substringBetween('--','.').toLowerCase();
                }
            }
        }
        

        List<Account> scopeAE = (List<Account>) scope;
            for(Account ci : scopeAE) {
                if (sandboxName != null)
                {
                    ci.Email__c = ci.Email__c + '.' + sandboxName;
                }
            }
            if (!scopeAE.isEmpty())
            {
                update scopeAE;
            }
    }
    
    global void finish(Database.BatchableContext bc){
       
    }
}