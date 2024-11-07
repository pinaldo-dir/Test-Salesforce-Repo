@istest
public class HR_Batch_Appraisal_Test {
    public static testMethod void testschedule() {
		Test.StartTest();
		HR_Appraisal_Send_Reminders testsche1 = new HR_Appraisal_Send_Reminders();
		String sch1 = '0 0 23 * * ?';
		system.schedule('Test Sch Appraisal1', sch1, testsche1 );
        
        HR_Appraisal_Send_Past_Dues testsche2 = new HR_Appraisal_Send_Past_Dues();
		String sch2 = '0 0 23 * * ?';
		system.schedule('Test Sch Appraisal2', sch2, testsche2 );
        
        HR_Batch_Appraisal_Expired testsche3 = new HR_Batch_Appraisal_Expired();
		String sch3 = '0 0 23 * * ?';
		system.schedule('Test Sch Appraisal3', sch3, testsche3 );
        
		Test.stopTest();
	}    
     public static testMethod void testbatch() {
        Employee__c emp = new Employee__c();
        emp.First_Name__c = 'Test';
        emp.Last_Name__c = 'Last';
        insert emp;
        
        Position__c p1 = new Position__c();
        p1.Serial_Number__c = '111';
        p1.Manual_Entry__c = false;
        insert p1;
        Contact c1 = new Contact();
        c1.LastName = 'Test';
        insert c1;
         
        Contact c2 = new Contact();
        c2.LastName = 'Test2';
        insert c2;
        
        Appointment__c a1 = new Appointment__c();
        a1.Position__c = p1.Id;
        a1.Employee_Contact__c = c1.Id;
        a1.Supervisor_Contact__c = c2.Id;
        a1.Start_Date__c = System.today().addDays(-800);
        a1.Employee__c = emp.Id;
        a1.Type__c = 'xyz';
        a1.Hiring_Type__c = 'zyz';
        a1.Tenure__c = 'Permanent';
        a1.End_Date__c =  NULL;
        insert a1;
        
		List<Performance_Appraisal_Tracking__c> PAList = new List<Performance_Appraisal_Tracking__c>();         
        for(Integer i=0 ;i <5;i++){
            Performance_Appraisal_Tracking__c PA = new Performance_Appraisal_Tracking__c();
         	PA.Appointment__c = a1.Id;
            PA.Supervisor_Email__c = 'test@gmail.com';
            IF(PA.Send_Reminder_1__c == FALSE){PA.Send_Reminder_1__c = TRUE;}
            IF(PA.Send_Reminder_2__c == FALSE){PA.Send_Reminder_2__c = TRUE;}
            IF(PA.Send_Past_Due_Notice_1__c == FALSE){PA.Send_Past_Due_Notice_1__c = TRUE;}
            IF(PA.Send_Past_Due_Notice_2__c == FALSE){PA.Send_Past_Due_Notice_2__c = TRUE;}
            IF(PA.Expired__c == FALSE){PA.Expired__c = TRUE;}
        	PAList.add(PA);
            
        }
        Insert PAList;
         
        test.startTest();
        HR_Appraisal_Send_Reminders ba1 = new HR_Appraisal_Send_Reminders();
        Id jobid1 = Database.executeBatch(ba1,200);   
        HR_Appraisal_Send_Past_Dues ba2 = new HR_Appraisal_Send_Past_Dues();
        Id jobid2 = Database.executeBatch(ba2,200); 
        HR_Batch_Appraisal_Expired ba3 = new HR_Batch_Appraisal_Expired();
        Id jobid3 = Database.executeBatch(ba3,200); 
        test.stopTest();
    }

}