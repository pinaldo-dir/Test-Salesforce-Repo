@istest
public class PAGAResultsControllerTest {

    public static testMethod void testPAGAResults1(){
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
        dirCase1.LWDA_Number__c = 'LWDA-CM-1007596-24';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        
        test.startTest();
            
            ApexPages.CurrentPage().getParameters().put('ss', 'Case');
           	ApexPages.CurrentPage().getParameters().put('lwn', 'LWDA-CM-1007596-24');
            ApexPages.CurrentPage().getParameters().put('sD', '2017-01-01');
            ApexPages.CurrentPage().getParameters().put('eD', '2017-08-08');
            ApexPages.CurrentPage().getParameters().put('en', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('ef', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('lf', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('ccn', '3333');
            ApexPages.CurrentPage().getParameters().put('ct', 'Other');
            ApexPages.CurrentPage().getParameters().put('cn', 'Other');
            ApexPages.CurrentPage().getParameters().put('vt', 'Child Labor');
            ApexPages.CurrentPage().getParameters().put('ec', 'Denver');
            ApexPages.CurrentPage().getParameters().put('ezc', '80212');
            ApexPages.CurrentPage().getParameters().put('cn', 'name');
            ApexPages.CurrentPage().getParameters().put('vt', 'name');
            ApexPages.CurrentPage().getParameters().put('st', 'name');
            PAGAResultsController pagaResults = new PAGAResultsController();
        	
			pagaResults.startAttachmentDate = Date.Today() - 1;
         	pagaResults.endAttachmentDate = Date.Today() + 1;
            
            PAGAResultsController.getAllCases('Case', '444333', '2017-01-01', '2017-08-08', 'Case 1', 'Case 1', 'Case 1', 'Denver', '80212', '3333', 'California Courts', 'Court Name',  'Child Labor;', 'Intake;','PAGA Notice;');
            
            pagaResults.getPAGASearchFields();
            pagaResults.SearchCases();
          
        	pagaResults.filterField= 'Date_Case_Received__c';
            pagaResults.AddFilter();
            pagaResults.filterField = 'LWDA_Number__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Date_Case_Received__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Employer__r.Name';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Employer_Filer__r.Name';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Law_Firm_for_PAGA_Case__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Employer__r.ShippingCity';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Employer__r.ShippingPostalCode';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Court_Case_Number_for_PAGA_Case__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Court_Type__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Court_Name__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Violation_Type__c';
            pagaResults.RemoveFilter();
        	//Modified for Paga Search 2 project.  Covers line Attachment_Created_Date filter 284 - 287 in the PAGAResultsController.
            pagaResults.filterField = 'Attachment_Created_Date';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Submission_Detail_Type__c';
          	pagaResults.RemoveFilter();
        	pagaResults.filterField = 'Filer_Attorney_for_PAGA_Case__r.Name';
        	pagaResults.RemoveFilter();
            
			pagaResults.PrintResultsToPDF();
            pagaResults.PrintResultsToExcel();
            
            
        test.stopTest();
    }
    
    public static testMethod void testPAGAResults2(){
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
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        //dirCase1.Violation_Type__c = 'Child Labor';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        
        test.startTest();
            
            ApexPages.CurrentPage().getParameters().put('ss', 'Case');
            ApexPages.CurrentPage().getParameters().put('sD', '2017-01-01');
            ApexPages.CurrentPage().getParameters().put('eD', '2017-08-08');
            ApexPages.CurrentPage().getParameters().put('en', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('ef', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('lf', 'Case 1');
            
            ApexPages.CurrentPage().getParameters().put('ccn', '3333');
            ApexPages.CurrentPage().getParameters().put('ct', 'Other');
            ApexPages.CurrentPage().getParameters().put('cn', 'Other');
            ApexPages.CurrentPage().getParameters().put('vt', 'Child Labor');
            ApexPages.CurrentPage().getParameters().put('ec', 'Denver');
            ApexPages.CurrentPage().getParameters().put('ezc', '80212');
            ApexPages.CurrentPage().getParameters().put('cn', 'name');
            ApexPages.CurrentPage().getParameters().put('vt', 'name');
            ApexPages.CurrentPage().getParameters().put('st', 'name');
            PAGAPrintController pagaPrint = new PAGAPrintController();
            
            pagaPrint.getCurrentCases('Case', '444333', '2017-01-01', '2017-08-08', 'Case 1', 'Case 1', 'Case 1', 'Denver', '80212', '3333', 'California Courts', 'California Courts', 'Child Labor;', 'Intake;', 'PAGA Notice;');
            
        test.stopTest();
    } 
    
    /*Added for Paga Search 2 project coverage for getAllCases() method lines 354 - 355 when all parameters are null */
    public static testMethod void testPAGAResults3(){
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
        dirCase1.LWDA_Number__c = 'LWDA-CM-1007596-24';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        //dirCase1.Violation_Type__c = 'Child Labor';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        
        test.startTest();
            
            ApexPages.CurrentPage().getParameters().put('ss', 'Case');
            ApexPages.CurrentPage().getParameters().put('sD', '2017-01-01');
            ApexPages.CurrentPage().getParameters().put('eD', '2017-08-08');
            ApexPages.CurrentPage().getParameters().put('en', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('ef', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('lf', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('lwn', 'LWDA-CM-1007596-24');
            ApexPages.CurrentPage().getParameters().put('ccn', '3333');
            ApexPages.CurrentPage().getParameters().put('ct', 'Other');
            ApexPages.CurrentPage().getParameters().put('cn', 'Other');
            ApexPages.CurrentPage().getParameters().put('vt', 'Child Labor');
            ApexPages.CurrentPage().getParameters().put('ec', 'Denver');
            ApexPages.CurrentPage().getParameters().put('ezc', '80212');
            ApexPages.CurrentPage().getParameters().put('cn', 'name');
            ApexPages.CurrentPage().getParameters().put('vt', 'name');
            ApexPages.CurrentPage().getParameters().put('st', 'PAGA Notice');
            PAGAResultsController pagaResult = new PAGAResultsController();
                 
        	pagaResult.employerFilerName = 'Name';
        	pagaResult.employerName = 'Uber';
        	pagaResult.lawFirmPAGACase = 'Mercury';
        	pagaResult.attorneyFilerName = 'Jane Doe';
        	pagaResult.getItems();
        	pagaResult.setSelectedSubmissionType('PAGA Notice');
        	pagaResult.getSelectedSubmissionType();
            pagaResult.getTotalResults();
            
        test.stopTest();
    }
    
     public static testMethod void testPAGAResults4(){
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
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        
        test.startTest();
            
            ApexPages.CurrentPage().getParameters().put('ss', 'Case');
            ApexPages.CurrentPage().getParameters().put('sD', '2017-01-01');
            ApexPages.CurrentPage().getParameters().put('eD', '2017-08-08');
            ApexPages.CurrentPage().getParameters().put('en', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('ef', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('lf', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('ccn', '3333');
            ApexPages.CurrentPage().getParameters().put('ct', 'Other');
            ApexPages.CurrentPage().getParameters().put('cn', 'Other');
            ApexPages.CurrentPage().getParameters().put('vt', 'Child Labor');
            ApexPages.CurrentPage().getParameters().put('ec', 'Denver');
            ApexPages.CurrentPage().getParameters().put('ezc', '80212');
            ApexPages.CurrentPage().getParameters().put('cn', 'name');
            ApexPages.CurrentPage().getParameters().put('vt', 'name');
            ApexPages.CurrentPage().getParameters().put('st', 'name');
            PAGAResultsController pagaResults = new PAGAResultsController();
            
         //    global static List<DIR_Case__c> getAllCases(String searchName, String lwNumber, String startDate, String endDate, String empName, String empFirmName, String lawFirm, String sAttFirmName, String employerCity, String employerZipCode, String countCaseNumber, String cType, String cName, String vType, String sType) {

         /*    && String.isEmpty(employerCity) && String.isEmpty(employerZipCode) && String.isEmpty(countCaseNumber) && String.isEmpty(cType) 
           && String.isEmpty(cName) && String.isEmpty(vType) && String.isEmpty(sType) ) { */
               
            PAGAResultsController.getAllCases(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            

            
        test.stopTest();
    }
   
    
    //Added as part of paga search 2 project to cover PrintResultsToPDF and PrintResultsToExcel methods
        public static testMethod void testPAGAResults5(){
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
        dirCase1.LWDA_Number__c = 'LWDA-CM-1007596-24';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        
        test.startTest();
            
            ApexPages.CurrentPage().getParameters().put('ss', 'Case');
           	ApexPages.CurrentPage().getParameters().put('lwn', 'LWDA-CM-1007596-24');
            ApexPages.CurrentPage().getParameters().put('sD', '2017-01-01');
            ApexPages.CurrentPage().getParameters().put('eD', '2017-08-08');
            ApexPages.CurrentPage().getParameters().put('en', 'Uber');
            ApexPages.CurrentPage().getParameters().put('ef', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('lf', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('ccn', '3333');
            ApexPages.CurrentPage().getParameters().put('ct', 'Other');
            ApexPages.CurrentPage().getParameters().put('cn', 'Other');
            ApexPages.CurrentPage().getParameters().put('vt', 'Child Labor');
            ApexPages.CurrentPage().getParameters().put('ec', 'Denver');
            ApexPages.CurrentPage().getParameters().put('ezc', '80212');
            ApexPages.CurrentPage().getParameters().put('cn', 'name');
            ApexPages.CurrentPage().getParameters().put('vt', 'name');
            ApexPages.CurrentPage().getParameters().put('st', 'name');
            PAGAResultsController pagaResults = new PAGAResultsController();
        	
            pagaResults.allCases = null;
			pagaResults.startAttachmentDate = Date.Today() - 1;
         	pagaResults.endAttachmentDate = Date.Today() + 1;
            pagaResults.employerName = 'Uber';
            pagaResults.employerFilerName = 'Test';
            pagaResults.lawFirmPAGACase = 'Dave & Co';
            
            
            PAGAResultsController.getAllCases('Case', '444333', '2017-01-01', '2017-08-08', 'Case 1', 'Case 1', 'Case 1', 'Denver', '80212', '3333', 'California Courts', 'Court Name',  'Child Labor;', 'Intake;','PAGA Notice;');
            
            pagaResults.getPAGASearchFields();
            pagaResults.SearchCases();
     
			pagaResults.PrintResultsToPDF();
            pagaResults.PrintResultsToExcel();
            pagaResults.BackToSearch();
            
        test.stopTest();
    }
    
}