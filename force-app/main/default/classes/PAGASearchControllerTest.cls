@istest
public class PAGASearchControllerTest {

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
        
        
        test.startTest();
            PAGASearchController pagaSearch = new PAGASearchController();
            pagaSearch.getItems();
            pagaSearch.employeeCity = 'Denver';
            pagaSearch.employeeZipCode = '80212';
            pagaSearch.dummyCase.PAGA_Court_Case_Number__c = '3333';
            pagaSearch.dummyCase.Court_Type__c = 'Other';
            pagaSearch.dummyCase.Court_Name__c = 'Other';
            pagaSearch.dummyCase.Violation_Type__c = 'Child Labor;';
            pagaSearch.dummyCase.Notice_Filing_Date__c = Date.Today().addDays(-4);
        	pagaSearch.dummyCase.Court_Filing_Date_for_PAGA_Cases__c = Date.Today().addDays(4);
        	pagaSearch.startAttachDate = Date.Today().addDays(-30);
            pagaSearch.endAttachDate = Date.Today().addDays(-1);
        	pagaSearch.selectedsubmissiontype = 'PAGA Notice';
            pagaSearch.searchString = 'Uber';
         	pagaSearch.dummyCase.LWDA_Number__c = 'LWDA-CM-1007596-24';
            pagaSearch.SearchCases();
            pagaSearch.ClearFields();
            
            
        test.stopTest();
    }
    
     public static testMethod void testPAGASearch2(){
         
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
        
        
         //Covers PAGASearchController.axpc 92 - 103 when startAttach Date & endAttachDate & selectedsubmission type = Select One... 
        test.startTest();
            PAGASearchController pagaSearch = new PAGASearchController();
            pagaSearch.getItems();
         	pagaSearch.searchString = 'Uber';
         	pagaSearch.dummyCase.LWDA_Number__c = 'LWDA-CM-1007596-24';
            pagaSearch.employeeCity = 'Denver';
            pagaSearch.employeeZipCode = '80212';
            pagaSearch.dummyCase.PAGA_Court_Case_Number__c = '3333';
            pagaSearch.dummyCase.Court_Type__c = 'Other';
            pagaSearch.dummyCase.Court_Name__c = 'Other';
            pagaSearch.dummyCase.Violation_Type__c = 'Child Labor;';
            pagaSearch.dummyCase.Notice_Filing_Date__c = Date.Today().addDays(-4);
        	pagaSearch.dummyCase.Court_Filing_Date_for_PAGA_Cases__c = Date.Today().addDays(4);
        	pagaSearch.startAttachDate = null;
            pagaSearch.endAttachDate = null;
        	pagaSearch.selectedsubmissiontype = 'Select One...';
            pagaSearch.SearchCases();
    
         
         
         test.stopTest();
              
}
    
    
public static testMethod void testPAGASearch3()
	{
         
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
        
        
         //Covers PAGASearchController.axpc 92 - 103 when startAttach Date & endAttachDate & selectedsubmission type = Select One... 
        test.startTest();
            PAGASearchController pagaSearch = new PAGASearchController();
            pagaSearch.getItems();
            pagaSearch.employeeCity = 'Denver';
            pagaSearch.employeeZipCode = '80212';
            pagaSearch.dummyCase.PAGA_Court_Case_Number__c = '3333';
            pagaSearch.dummyCase.Court_Type__c = 'Other';
            pagaSearch.dummyCase.Court_Name__c = 'Other';
            pagaSearch.dummyCase.Violation_Type__c = 'Child Labor;';
            pagaSearch.dummyCase.Notice_Filing_Date__c = Date.Today().addDays(-4);
        	pagaSearch.dummyCase.Court_Filing_Date_for_PAGA_Cases__c = Date.Today().addDays(4);
        	pagaSearch.startAttachDate = Date.Today().addDays(-15);
            pagaSearch.endAttachDate = null;
        	pagaSearch.selectedsubmissiontype = 'Select One...';
            pagaSearch.SearchCases();        
    
         test.stopTest();    
	}
    
        public static testMethod void testPAGASearch4()
	{
         
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
        
        
         //Covers PAGASearchController.axpc 120 - 127 when startAttach Date & endAttachDate are not null and submission type is not Select One...
        test.startTest();
            PAGASearchController pagaSearch = new PAGASearchController();
            pagaSearch.getItems();
            pagaSearch.employeeCity = 'Denver';
            pagaSearch.employeeZipCode = '80212';
            pagaSearch.dummyCase.PAGA_Court_Case_Number__c = '3333';
            pagaSearch.dummyCase.Court_Type__c = 'Other';
            pagaSearch.dummyCase.Court_Name__c = 'Other';
            pagaSearch.dummyCase.Violation_Type__c = 'Child Labor;';
            pagaSearch.dummyCase.Notice_Filing_Date__c = Date.Today().addDays(-4);
        	pagaSearch.dummyCase.Court_Filing_Date_for_PAGA_Cases__c = Date.Today().addDays(4);
        	pagaSearch.startAttachDate = Date.Today().addDays(-15);
            pagaSearch.endAttachDate = null;
        	pagaSearch.selectedsubmissiontype = 'PAGA Notice';
            pagaSearch.SearchCases();        
    
        test.stopTest();    
	}
    
    public static testMethod void testPAGASearch5()
	{
         
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
        
        
         //Covers PAGASearchController.axpc 131 - 138 when startAttach Date & endAttachDate are not null and submission type = Select One...
        test.startTest();
            PAGASearchController pagaSearch = new PAGASearchController();
            pagaSearch.getItems();
            pagaSearch.employeeCity = 'Denver';
            pagaSearch.employeeZipCode = '80212';
            pagaSearch.dummyCase.PAGA_Court_Case_Number__c = '3333';
            pagaSearch.dummyCase.Court_Type__c = 'Other';
            pagaSearch.dummyCase.Court_Name__c = 'Other';
            pagaSearch.dummyCase.Violation_Type__c = 'Child Labor;';
            pagaSearch.dummyCase.Notice_Filing_Date__c = Date.Today().addDays(-4);
        	pagaSearch.dummyCase.Court_Filing_Date_for_PAGA_Cases__c = Date.Today().addDays(4);
        	pagaSearch.startAttachDate = Date.Today().addDays(-15);
            pagaSearch.endAttachDate = Date.Today().addDays(-10);
        	pagaSearch.selectedsubmissiontype = 'Select One...';
            pagaSearch.SearchCases();        
    
        test.stopTest();    
	}

}