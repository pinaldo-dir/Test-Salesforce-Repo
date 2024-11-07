@isTest 
public class OWCCaseClosedOnTimerExpiredSch_test {
    static testMethod void TestcreateLogs()
    {
        Test.StartTest();
        OWCCaseClosedOnTimerExpiredScheduler testsche = new OWCCaseClosedOnTimerExpiredScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}