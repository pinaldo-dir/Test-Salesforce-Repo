/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Service_AddressTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Service_AddressTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Service_Address__c());
    }
}