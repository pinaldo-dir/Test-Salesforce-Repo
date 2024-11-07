/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Form_1_StatusTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Form_1_StatusTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Form_1_Status__c());
    }
}