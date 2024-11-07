@isTest 
public class OWCCaseClosedOnTimerExpiredBatch_test {
    public static testmethod void BatchPopulateTest(){
            Trigger_Settings__c caseTriggerSetting = new Trigger_Settings__c(
                Name = 'CaseManagementHistoryConfig',
                Is_Active__c = false
            );
            insert caseTriggerSetting;
              List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
            Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
                Name = 'Receipt Trigger',
                Is_Active__c = true
            );
            triggerSettings.add(rctTriggerSetting);
            
            Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
                Name = 'GenerateFieldHistoryAction',
                Is_Active__c = false
            );
            
            Trigger_Settings__c dlrs_Related_PartyTriggersetting = new Trigger_Settings__c(
                Name = 'dlrs_Related_PartyTrigger',
                Is_Active__c = false
            );
             triggerSettings.add(dlrs_Related_PartyTriggersetting);
            triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
            insert triggerSettings;
            
            RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'Pre_Docketing_Case' AND IsActive = true LIMIT 1];
            
            Account mainA = new Account();
            mainA.Name = 'name';
            mainA.ShippingPostalCode = '234889';
            insert mainA;
            
            DIR_Case__c c = new DIR_Case__c();
            c.Employer__c = mainA.Id;
            c.Status__c = 'Not Confirmed';
            c.RecordTypeId = caseRT.Id;            
            insert c;
            
            
            test.startTest();
            OWCCaseClosedOnTimerExpiredBatch bch = new OWCCaseClosedOnTimerExpiredBatch(100);
            Database.executeBatch(bch);
            test.stopTest();
            
        }
}