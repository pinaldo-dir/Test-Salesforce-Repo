/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Inactive_TrackingTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Inactive_TrackingTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Inactive_Tracking__c());
    }
}