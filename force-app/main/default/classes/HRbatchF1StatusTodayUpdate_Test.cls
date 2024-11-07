@isTest
public class HRbatchF1StatusTodayUpdate_Test {

   Static testMethod void testBatchExecuteMethod()
   {
        Form_1__c F1 = new Form_1__c();
        F1.Position_Type__c = 'Backfill';
        F1.Division_Manual_Entry__c = 'ACCT';
        F1.Required_Form_700__c = 'Required';
        insert F1;       
     	List<Form_1_Status__c> F1sList = new List<Form_1_Status__c>();       
       		for(Integer i=0; i < 20; i++){                
                Form_1_Status__c rec = new Form_1_Status__c();
                rec.Date_of_Status__c = date.parse('12/27/2009');
                rec.Todays_Date_Hidden__c = date.parse('12/27/2018');
                rec.Part_1_Program_Return_Reason_s__c ='Other (See Status Notes)';
                //rec.Status_End_Date__c = null;
				rec.Form_1__c = F1.Id;
                F1sList.add(rec);
       		}
     	insert F1sList;       
        Test.startTest();       
        HRbatchF1StatusTodayUpdate ub =  new HRbatchF1StatusTodayUpdate();
        database.BatchableContext bc;
        ub.execute(bc, F1sList);
        database.executeBatch(ub,20);
        HRF1StatusTodayUpdateSchedule F1Ssched = new HRF1StatusTodayUpdateSchedule(); 
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, F1Ssched );
        Test.stopTest(); 

        List<Form_1_Status__c> F1checklist = new List<Form_1_Status__c>();
        F1checklist = [Select Todays_Date_Hidden__c from Form_1_Status__c where Todays_Date_Hidden__c = 2022-04-08];
  }
}