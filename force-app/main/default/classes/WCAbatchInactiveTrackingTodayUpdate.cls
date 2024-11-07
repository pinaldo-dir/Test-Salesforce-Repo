global class WCAbatchInactiveTrackingTodayUpdate implements Database.Batchable<sObject> {

    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //String RTnameFilters = 'Intake Stage';
             String query= 'SELECT Todays_Date_Hidden__c from Inactive_Tracking__c';

        //return Database.QueryLocator(query);
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Inactive_Tracking__c> scope)
    {
        for(Inactive_Tracking__c InactiveTracking: scope)
        {

                InactiveTracking.Todays_Date_Hidden__c = system.today();
               
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}