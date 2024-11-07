global class ScheduleDIRCaseArchiveBatch Implements Schedulable {
    
    // Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
    // runs a scheduled job at midnight July. 1st. every year
    
    public static String CRON_SCHEDULE = '0 0 0 7 1 ?';
    
    global void execute (SchedulableContext sc)
    {
        archiveBOFEAplus();
    }
    
    public void archiveBOFEAplus(){
        string q = 'SELECT Id, Archive__c from DIR_Case__c WHERE Status__c = \'Closed\'' +
            ' AND ' + 'Case_Closed_Date__c < LAST_N_DAYS:366' + ' AND ' + 'Total_Penalties_Balance_Due__c = 0.00' +
            ' AND ' + 'Total_Wages_Balance_Due__c = 0.00' + ' AND ' + 'Total_Interest_Balance_Due__c = 0.00' +
            ' AND ' + 'Archive__c = False' + ' AND ' + 'RecordType.Name LIKE \'%BOFE%\'' + ' LIMIT 20000';    
        
        Id job = Database.executeBatch(new DIRCaseArchiveBatch(q),50);
    }
}