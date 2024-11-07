@isTest
public class OWCDeleteUnConfirmedClaimsScheduler_Test {
    static testMethod void TestcreateLogs()
    {
        Test.StartTest();
        OWCDeleteUnConfirmedClaimsScheduler testsche = new OWCDeleteUnConfirmedClaimsScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}