/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Report_of_Labor_Code_ViolationTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Report_of_Labor_Code_Viola1cTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Report_of_Labor_Code_Violation__c());
    }
}