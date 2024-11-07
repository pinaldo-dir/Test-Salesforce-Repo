@isTest
public class OWCClosedUnconfirmedCaseSchedulerTest {
static testMethod void TestcreateLogs()
    {
        Test.StartTest();
        OWCClosedUnconfirmedCaseScheduler testsche = new OWCClosedUnconfirmedCaseScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}