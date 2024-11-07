@isTest
public class RegistrationImportControllerTest {
    
    static testMethod void importData() {
        List<StaticResource> FLCGrowersCsvData = [select id, name, body from StaticResource where name = 'FLCGrowers']; 
        List<StaticResource> FLCDriversCsvData = [select id, name, body from StaticResource where name = 'FLCDrivers']; 
        List<StaticResource> JSSubCsvData = [select id, name, body from StaticResource where name = 'JSSub']; 
        List<StaticResource> JSCustCsvData = [select id, name, body from StaticResource where name = 'JSCust']; 
        List<StaticResource> FLCVehiclesCsvData = [select id, name, body from StaticResource where name = 'FLCVehicles']; 

        Id personAcct = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Farm Labor Contractor').getRecordTypeId();

  
        Account acct = new Account();
        acct.recordtypeid = personAcct;
        acct.FirstName = 'testName';  
        acct.LastName  = 'TestlastName'; 
        acct.ShippingStreet = 'testStreet'; 
        acct.ShippingPostalCode  = 'testZip';       
        insert acct;
        
        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Email = 'first.last@gmail.com';
        insert c;
        
        License_Registration__c lReg1 = new License_Registration__c ();
        lReg1.Account__c = acct.Id;
        lReg1.RecordTypeId = RecordTypeId;
        lReg1.License_Registration_Number__c = acct.Id;
        lReg1.License_Registration_Type__c = '3333';
        lReg1.Submitted_Date__c = Date.today() - 3;
        lReg1.Mailing_City__c = 'oak';
        lReg1.Applicant__c = c.Id;
        insert lReg1;
        
        
        
        PageReference testPage = Page.RegistrationImport;
        testPage.getParameters().put('id', lReg1.id);
        
        Test.setCurrentPage(testPage);
        
        RegistrationImportController contGrower = new RegistrationImportController();
        contGrower.nameFile = 'FLCGrowers.csv';
        contGrower.contentFile = FLCGrowersCsvData[0].body;

        RegistrationImportController contDriver = new RegistrationImportController();
        contDriver.nameFile = 'FLCDrivers.csv';
        contDriver.contentFile = FLCDriversCsvData[0].body;
    
        RegistrationImportController contSub = new RegistrationImportController();
        contSub.nameFile = 'JSSub.csv';
        contSub.contentFile = JSSubCsvData[0].body;
        
        RegistrationImportController contCust = new RegistrationImportController();
        contCust.nameFile = 'JSCust.csv';
        contCust.contentFile = JSCustCsvData[0].body;
        
        RegistrationImportController contVehicle = new RegistrationImportController();
        contVehicle.nameFile = 'FLCVehicles.csv';
        contVehicle.contentFile = FLCVehiclesCsvData[0].body;
        
        Test.StartTest();
        
        contGrower.ImportGrower();
        contDriver.ImportDriver();
        contSub.ImportSubcontractor();
        contCust.ImportCustomerBusiness();
        contVehicle.ImportVehicle();
        
        contGrower.Close();

        Test.StopTest();
    }
}