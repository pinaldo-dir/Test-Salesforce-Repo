@isTest
public class DIRCaseArchiveBatchTest {
    @testSetup static void setup(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        
        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;
        
        // Implement test code
        Account a = new Account(
            Name = 'test Account'+system.now()
        );
        insert a;
        
        DIR_Employee__c ma = new DIR_Employee__c(
            User__c = UserInfo.getUserId()
        );
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = ma.Id
        );
        insert de; 
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = de.Id,
            Employer__c = a.Id,
            Status__c = 'Closed',
            Case_Closed_Date__c =  Date.newInstance(2015, 1, 1)
        );
        insert cm;
        
        cm = [SELECT Status__c, Case_Closed_Date__c, Total_Penalties_Balance_Due__c, Total_Wages_Balance_Due__c, Total_Interest_Balance_Due__c, Archive__c
              FROM DIR_Case__c WHERE id =: cm.id ];
        update cm;
        
        Attachments_New__c objAttachment1 = new Attachments_New__c(File_Name__c = 'Test',
                                                                   File_Type__c = 'Test',
                                                                   Related_Id__c = cm.Id,
                                                                   APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"File_Name"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]');
        
        insert objAttachment1;
        
        insert new List<Attachments_Data__c> {new Attachments_Data__c(Field_Name__c = 'Test',
                                                                      Value__c = 'Test',
                                                                      Field_API_Name__c = 'Test',
                                                                      Attachments__c = objAttachment1.id),
            
                                            new Attachments_Data__c(Field_Name__c = 'Test2',
                                                                    Value__c = 'Test2',
                                                                    Field_API_Name__c = 'Test2',
                                                                    Attachments__c = objAttachment1.id)};
        
        
    }
    
    @isTest 
    static void testCaseIssueBatch() {
        // Implement test code
        test.startTest();
        string q = 'SELECT Id, Archive__c from DIR_Case__c WHERE Status__c = \'Closed\'' +
            ' AND ' + 'Case_Closed_Date__c < LAST_N_DAYS:366';    
        DIRCaseArchiveBatch.dirCaseArchive = false;
        Id tb = Database.executeBatch(new DIRCaseArchiveBatch(q), 200);
        test.stopTest();
    }
    
    @isTest 
    static void ScheduleDIRCaseArchiveBatch() {
        test.startTest();
        //Schedule the test Job
        String jobId = System.schedule('ScheduleDIRCaseArchiveBatch', ScheduleCaseIssueReclass.CRON_SCHEDULE, new ScheduleDIRCaseArchiveBatch());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        //verify the expression are the same
        System.assertEquals(ScheduleCaseIssueReclass.CRON_SCHEDULE, ct.CronExpression);
        
        //verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        test.stopTest();
    }
    
    
}