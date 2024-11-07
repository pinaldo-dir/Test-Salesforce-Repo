global class HRbatchF1StatusTodayUpdate implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String[] RTnameFilters = new String[]{'%Return to Program%', '%Under Review%'};
        String query= 'SELECT Todays_Date_Hidden__c from Form_1_Status__c where recordtype.name like: RTnameFilters AND Status_End_Date__c = NULL';

        //return Database.QueryLocator(query);
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Form_1_Status__c> scope)
    {
        for(Form_1_Status__c F1Status: scope)
        {

                F1Status.Todays_Date_Hidden__c = system.today();
               
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}