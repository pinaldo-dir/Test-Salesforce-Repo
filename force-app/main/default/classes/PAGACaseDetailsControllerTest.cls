@istest
public class PAGACaseDetailsControllerTest {

    public static testMethod void testPAGASearch1(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        insert triggerSettings;
        
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        
        DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        dirCase1.Violation_Type__c = 'Child Labor';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        //Added as part of the Paga Search 2 project to cover line 32 of the PAGACaseDetailsController.axpc  for(Attachments_Plus__c ap: allAttPlus) { attSet.add(ap.Id);
        Attachments_Plus__c attach01 = new Attachments_Plus__c();
        attach01.Case_Management__c = dirCase1.Id;
        attach01.File_URL__c = 'test01';
        insert attach01;
        Attachments_Plus__c attach02 = new Attachments_Plus__c();
        attach02.Case_Management__c = dirCase1.Id;
        attach02.File_URL__c = 'test02';
        insert attach02;
        
        
        test.startTest();
            ApexPages.CurrentPage().getParameters().put('id', dirCase1.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(dirCase1);
            PAGACaseDetailsController pagaCaseDetails = new PAGACaseDetailsController(sc);
            pagaCaseDetails.getAttachments();
        test.stopTest();
    }
    
   
}