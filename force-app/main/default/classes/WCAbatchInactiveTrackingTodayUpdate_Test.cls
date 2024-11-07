@isTest
public class WCAbatchInactiveTrackingTodayUpdate_Test {

   Static testMethod void testBatchExecuteMethod()
   {    
     	List<Inactive_Tracking__c> ITsList = new List<Inactive_Tracking__c>();       
       		for(Integer i=0; i < 5; i++){                
                Inactive_Tracking__c rec = new Inactive_Tracking__c();
                rec.X1st_Attempt_Date__c = date.parse('12/27/2024');
                rec.Todays_Date_Hidden__c = date.parse('12/27/2024');
                rec.X1st_Attempt_Method__c ='Email';
                rec.X1ST_Attempt_Contact_Info__c ='Mr.A';
                rec.Plaintiff_contact_information__c =TRUE;
                rec.Comment_Entry__c = 'test';
                ITsList.add(rec);
       		}
     	insert ITsList;       
        Test.startTest();       
        WCAbatchInactiveTrackingTodayUpdate ub =  new WCAbatchInactiveTrackingTodayUpdate();
        database.BatchableContext bc;
        ub.execute(bc, ITsList);
        database.executeBatch(ub,5);
        WCAInactiveTrackingTodayUpdateSchedule ITSsched = new WCAInactiveTrackingTodayUpdateSchedule(); 
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, ITSsched );
        Test.stopTest(); 

        List<Inactive_Tracking__c> ITchecklist = new List<Inactive_Tracking__c>();
        ITchecklist = [Select Todays_Date_Hidden__c from Inactive_Tracking__c where Todays_Date_Hidden__c = 2022-04-08];
  }
}