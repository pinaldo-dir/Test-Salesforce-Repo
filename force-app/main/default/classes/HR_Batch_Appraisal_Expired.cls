global class HR_Batch_Appraisal_Expired implements Database.Batchable <sObject>, schedulable {     
    Integer currentYear = System.Today().year();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Expired__c, Invalid__c, Employee_Name__c, Tenure__c, Send_Reminder_1__c, Appointment_End_Date__c, Appraisal_Date__c, First_Appraisal_Period_Formula__c from Performance_Appraisal_Tracking__c';
        return Database.getQueryLocator(query); 
    }        
    global void execute(Database.BatchableContext bc,List<Performance_Appraisal_Tracking__c> batch) {
        for (Performance_Appraisal_Tracking__c Appr : batch) {
            IF (Appr.Expired__c == FALSE){
            	Appr.Expired__c = TRUE;           
            }
        }
        UPDATE batch;
    }    
    global void finish(Database.BatchableContext bc) {
        //Do Nothing.
    }   
    global void execute(SchedulableContext sc) {
         ID BatchId = Database.executeBatch(new HR_Batch_Appraisal_Expired(), 200);
    }
}