@isTest
public class OnlineClaimDraftDeleteScheduleTest {
 static testMethod void TestcreateLogs()
    {
        Test.StartTest();
        OnlineClaimDraftDeleteSchedule testsche = new OnlineClaimDraftDeleteSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}