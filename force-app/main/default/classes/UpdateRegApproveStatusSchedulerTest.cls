@IsTest
public class UpdateRegApproveStatusSchedulerTest {
    
    @isTest static void testClass() {
         
         // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
         String CRON_EXP = '0 0 0 3 9 ? 2029';
         
         Test.startTest();
         
         String jobId = System.schedule('UpdateRegistrationApproveStatusScheduler', CRON_EXP, new UpdateRegistrationApproveStatusScheduler());
         
         // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
        FROM CronTrigger
        WHERE id = :jobId];
         
        System.debug(ct);
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
         
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
         
          // Verify the next time the job will run
        System.assertEquals('2029-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        

        Test.stopTest();
    

     }
    
      @isTest static void testCoverage() {
                      
        
          //batch.neededForTestCoverage();
       
       
    } 

}