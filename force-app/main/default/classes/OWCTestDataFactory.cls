@IsTest
public class OWCTestDataFactory {
    public static List<Trigger_Settings__c> createTriggerCustomSettingRecord(){
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c cpTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        triggerSettings.add(cpTriggerSetting);
        
        Trigger_Settings__c lpTriggerSetting = new Trigger_Settings__c(
            Name = 'liabilityPaymentTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(lpTriggerSetting);
        
        Trigger_Settings__c dlrs_prTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_Payment_RecordTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_prTriggerSetting);
        
        Trigger_Settings__c dlrs_judgementTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_JudgementTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_judgementTriggerSetting);
        
        Trigger_Settings__c dlrs_DIR_ViolationTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = true
        );
        triggerSettings.add(dlrs_DIR_ViolationTriggerSetting);
        
        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = true
        );
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;
        return triggerSettings;
    }
    
    //Create Employer record
    public static DIR_Employee__c createEmployerRecord(){
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        return de;
    }
    
    //Create community user account
    public static User createCommunityUserAccount(){
        Id profileId = [select id from profile where name='Customer Online Claim User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        return user;
    }
}