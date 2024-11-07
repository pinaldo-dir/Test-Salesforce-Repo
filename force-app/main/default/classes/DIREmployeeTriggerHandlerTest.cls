@isTest
public class DIREmployeeTriggerHandlerTest {
    
    @testSetup static void methodName() {
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        
        Trigger_Settings__c casePaymentAllTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = false
        );
        triggerSettings.add(casePaymentAllTriggerSetting);
        
        Trigger_Settings__c dlrsDirViolationTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrsDirViolationTriggerSetting);
        
        Trigger_Settings__c dlrsJudgementTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_JudgementTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrsJudgementTriggerSetting);
        
        Trigger_Settings__c dlrsPaymentRecordTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_Payment_RecordTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrsPaymentRecordTriggerSetting);
        
        Trigger_Settings__c generateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        triggerSettings.add(generateFieldHistoryActionTriggerSetting);        
        
        Trigger_Settings__c liabilityPaymentTriggerSetting = new Trigger_Settings__c(
            Name = 'liabilityPaymentTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(liabilityPaymentTriggerSetting);
        
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = false
        );
        triggerSettings.add(rctTriggerSetting);

        Trigger_Settings__c EmployeeTriggerSetting = new Trigger_Settings__c(
            Name = 'DIR_EmployeeTrigger',
            Is_Active__c = true
        );
        triggerSettings.add(EmployeeTriggerSetting);        

        Trigger_Settings__c CaseRoleAllTriggerSetting = new Trigger_Settings__c(
            Name = 'CaseRoleAll',
            Is_Active__c = false
        );
        triggerSettings.add(CaseRoleAllTriggerSetting);  
        insert triggerSettings;
        
        Profile p = [select id from profile where name='RCI User'];
        User u = new User(alias = 'standt', email='testuser1@ca-dir.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='testuser1@ca-dir.com');
        insert u;
        
        User u2 = new User(alias = 'standt', email='testuser2@ca-dir.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p.Id,
                           timezonesidkey='America/Los_Angeles', username='testuser2@ca-dir.com');
        insert u2;
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = u2.id;
        insert ma; 
        //internal employee
        DIR_Employee__c de = new DIR_Employee__c();
        de.Name = 'name';
        de.Position__c = 'Deputy';
        de.User__c = u.Id;
        de.Manager__c = ma.Id;
        insert de;
        
        Account defendant = new Account();
        defendant.Name='defendant xyz';
        //defendant.PersonEmail='defendant@gmail.com';  
        defendant.Email__c='defendant@gmail.com';
        defendant.ShippingPostalCode = '234881';
        String typeId =[SELECT Id FROM RecordType WHERE Name = 'Person Account'].Id;
        defendant.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId(); 
        
        Account Claimant = new Account();
        Claimant.firstName='Claim';
        Claimant.lastName='ant acc';
        Claimant.PersonEmail='Claim@gmail.com';
        //Claimant.PersonMobilePhone = '8377922024';
        Claimant.Email__c='Claim@gmail.com';
        Claimant.ShippingPostalCode = '234889';
        Claimant.RecordTypeId=typeId; 
        
        List<Account> accList = new List<Account>();
        accList.add(Claimant);
        accList.add(defendant);
        insert accList;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = defendant.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        c.Intake_Origin__c = 'Online';
        
        insert c;
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = c.Id;
        System.debug(c.Id);
        cr.Entity__c = defendant.Id;
        cr.Role__c = 'Employer';
        cr.Case_Role_Status__c = 'Active';
        cr.Account_Name__c = defendant.Name;
        cr.Interpreter_Language__c = 'Spanish';
        insert cr;
        
        Case_Role__c cr2 = new Case_Role__c();
        cr2.Case__c = c.Id;
        System.debug(c.Id);
        cr2.Entity__c = Claimant.Id;
        cr2.Role__c = 'Claimant';
        cr2.Case_Role_Status__c = 'Active';
        cr2.Account_Name__c = Claimant.Name;
        insert cr2;
        
        Assessments__c assess = new Assessments__c();
        assess.Case_Management__c = c.Id;
        assess.Appeal_Deadline_Selector__c = 'Business Days';
        insert assess;
        
        test.startTest();
        DIR_Violation__c dv = new DIR_Violation__c();
        dv.Case__c = c.Id;
        dv.Assessment__c = assess.Id;
        insert dv;
        
        Liability__c lia = new Liability__c();
        lia.Assessment__c = assess.Id;
        insert lia;
        
        Appeal__c appeal1 = new Appeal__c();
        appeal1.Status__c = 'New';
        appeal1.Case__c = c.Id;
        appeal1.X2810_3_Case__c = 'Yes';
        appeal1.Citation_Selected__c = true;
        appeal1.Estimated_Length_of_Hearing_In_Minutes__c = 60;
        insert appeal1;
        
        Liability_Appeal__c la = new Liability_Appeal__c();
        la.Appeal__c = appeal1.Id;
        la.Liability__c = lia.Id;
        insert la;
        
        Hearing__c h = new Hearing__c();
        h.Appeal__c = appeal1.Id;
        h.Case__c = c.Id;
        h.Status__c = 'Scheduled';
        h.Meeting_Start_Date_Time__c = Date.today();
        h.Meeting_End_Date_Time__c = Date.today() + 1;
        h.Meeting_Type__c = 'Conference';
        h.Length_of_Hearing__c = 30;
        h.Meeting_Scheduled_For__c = de.id;
        h.In_Person_Remote_Meeting__c = 'In Person';
        insert h;
        
        
        test.stopTest();
     
    }
    
     @isTest static void updateInternalEmployee() {
         DIR_Employee__c de = [SELECT Id FROM DIR_Employee__c WHERE Position__c = 'Deputy' limit 1];
         test.startTest();

         DIR_Employee__c ma = new DIR_Employee__c();
         ma.User__c = UserInfo.getUserId();
         insert ma; 
         
         de.Manager__c = ma.Id;
         
         update de;
         test.stopTest();
        
     }

}