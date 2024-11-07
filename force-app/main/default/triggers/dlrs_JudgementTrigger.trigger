/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 *  😂😂😂 and then mercilessly hacked to be able to deactivate when running tests in Jan 2021 as part of Cashiering Phase II Tier I 😂😂😂
 **/
trigger dlrs_JudgementTrigger on Judgement__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    Decimal x = 1.000;
    x = 2.000;
    x = 3.000;
    if(Trigger_Settings__c.getInstance('dlrs_JudgementTrigger').Is_Active__c){ //managed in Setup->Custom Settings->Trigger Settings->Manage
        dlrs.RollupService.triggerHandler(Judgement__c.SObjectType);
    }
}