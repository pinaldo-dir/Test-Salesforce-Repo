global class HR_Appraisal_Send_Past_Dues implements Database.Batchable <sObject>, schedulable {
    Date TodaysDate = System.today();
    Integer currentYear = System.Today().year();
    Date DateToComparePastDue1 = Date.newInstance(currentYear, 5, 1);
    Date DateToComparePastDue2 = Date.newInstance(currentYear, 6, 1);
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Expired__c, Invalid__c, Employee_Name__c, Tenure__c, Send_Reminder_1__c, Send_Reminder_2__c, Send_Past_Due_Notice_1__c, Send_Past_Due_Notice_2__c, Appointment_End_Date__c, Appraisal_Date__c, First_Appraisal_Period_Formula__c from Performance_Appraisal_Tracking__c';
        return Database.getQueryLocator(query); 
    }        
    global void execute(Database.BatchableContext bc,List<Performance_Appraisal_Tracking__c> batch) {
        for (Performance_Appraisal_Tracking__c Appr : batch) {
            IF (Appr.Expired__c == FALSE && Appr.Invalid__c == FALSE && Appr.First_Appraisal_Period_Formula__c < currentYear && Appr.Tenure__c == 'Permanent' && Appr.Appraisal_Date__c == NULL && Appr.Appointment_End_Date__c == NULL){
                IF (DateToComparePastDue1 == TodaysDate){
                    Appr.Send_Past_Due_Notice_1__c = TRUE;}
                Else IF (DateToComparePastDue2 == TodaysDate){
                    Appr.Send_Past_Due_Notice_2__c = TRUE;}
            }
        }
        UPDATE batch;
    }    
    global void finish(Database.BatchableContext bc) {
        //Do Nothing.
    }   
    global void execute(SchedulableContext sc) {
         ID BatchId = Database.executeBatch(new HR_Appraisal_Send_Past_Dues(), 200);
    }
}