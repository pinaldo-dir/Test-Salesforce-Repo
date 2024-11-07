/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Report_of_Labor_Code_Viola1cTrigger on Report_of_Labor_Code_Violation__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Report_of_Labor_Code_Violation__c.SObjectType);
}