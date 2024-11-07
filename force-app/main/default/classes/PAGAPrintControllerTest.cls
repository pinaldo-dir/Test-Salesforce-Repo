@istest
public class PAGAPrintControllerTest {
    
    public static testMethod void testPAGAPrint1(){
            
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
        
        	DIR_Case__c dirCase1 = new DIR_Case__c();
         	Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
            dirCase1.RecordTypeId = RecordTypeId;
        	dirCase1.Employer__c = acc.Id;
        	dirCase1.PAGA_Court_Case_Number__c = '333';
        	dirCase1.LWDA_Number__c = 'LWDA-CM-1007596-24';
        	dirCase1.Court_Type__c = 'Other';
        	dirCase1.Court_Name__c = 'Other';
     
        	dirCase1.Date_Case_Received__c = Date.Today();
        
        
        
        	insert dirCase1;
        	Attachments_Plus__c attach01 = new Attachments_Plus__c();
        	attach01.Case_Management__c = attach01.Id;
        	insert attach01;
        	
        	

            test.startTest();

                PAGAPrintController pagaPrint = new PAGAPrintController();
              
                pagaPrint.getCurrentCases('Case', '444333', '2017-01-01', '2017-08-08', 'Case 1', 'Case 1', 'Case 1', 'Denver', '80212', '3333', 'California Courts', 'California Courts', 'violation1; violation2;', 'document1;document2', 'PAGA Notice');

                pagaPrint.currentCase = dirCase1;
            test.stopTest();
        }
    

}