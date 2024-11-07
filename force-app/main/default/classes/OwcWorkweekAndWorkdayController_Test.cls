@isTest
public class OwcWorkweekAndWorkdayController_Test {
    @isTest
     public static void testOwcWorkweekAndWorkdayController()
     {  
         Test.startTest();
         OwcWorkweekAndWorkdayController.fetchWorkweekMetaData();
         OwcWorkweekAndWorkdayController.fetchYesOrNoOptions();
         Test.stopTest();   
     }


}