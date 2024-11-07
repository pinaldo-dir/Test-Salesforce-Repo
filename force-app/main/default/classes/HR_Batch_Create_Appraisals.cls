global class HR_Batch_Create_Appraisals implements Database.Batchable <sObject>, schedulable {    
    Integer currentYear = System.Today().year();
    List<Performance_Appraisal_Tracking__c> lstPA = new List<Performance_Appraisal_Tracking__c>();    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Tenure__c, End_Date__c, Employee_Full_Name__c, First_Appraisal_Period_Formula__c,Supervisor_Contact__r.Email from Appointment__c';
        return Database.getQueryLocator(query); 
    }    
    
    global void execute(Database.BatchableContext bc,List<Appointment__c> batch) {
        //Appt shorts for 'Appointment', PA shorts for 'Performance Appraisal'
        for (Appointment__c Appt : batch) {
            IF (Appt.End_Date__c == NULL && Appt.Tenure__c == 'Permanent' && Appt.First_Appraisal_Period_Formula__c < currentYear){
            Performance_Appraisal_Tracking__c PA =  new Performance_Appraisal_Tracking__c();
            PA.Appointment__c = Appt.Id;
            PA.Supervisor_Email__c = Appt.Supervisor_Contact__r.Email;
            PA.Employee_Name__c = Appt.Employee_Full_Name__c;
            PA.Appraisal_Period_Enhanced__c =  String.valueOf(System.Today().year()-1);
            lstPA.add(PA);
            }
        }
        INSERT lstPA;
    }    
    global void finish(Database.BatchableContext bc) {
        //Do Nothing.
    }   
        global void execute(SchedulableContext sc) {
            //Database.executeBatch takes in the class, and then the size of batches.
            ID BatchId = Database.executeBatch(new HR_Batch_Create_Appraisals(), 200);
        }
}