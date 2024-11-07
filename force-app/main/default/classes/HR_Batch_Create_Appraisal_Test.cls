@istest
public class HR_Batch_Create_Appraisal_Test {
	public static testMethod void testschedule() {
		Test.StartTest();
		HR_Batch_Create_Appraisals testsche = new HR_Batch_Create_Appraisals();
		String sch = '0 0 23 * * ?';
		system.schedule('Test Sch Appraisal', sch, testsche );
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
        for(Integer i=0 ;i <100;i++){
            Performance_Appraisal_Tracking__c PA = new Performance_Appraisal_Tracking__c();
         	PA.Appointment__c = a1.Id;
        	PAList.add(PA);        
        }
        Insert PAList;
         
        test.startTest();
        HR_Batch_Create_Appraisals ba= new HR_Batch_Create_Appraisals();
        Id jobid= Database.executeBatch(ba,100);       
        test.stopTest();
    }
}