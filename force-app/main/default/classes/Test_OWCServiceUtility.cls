@isTest
public class Test_OWCServiceUtility {
    @isTest
    public static void getDuplicateAccountTest(){
        
        Account ob=new Account();
        ob.PersonEmail='abc@gmail.com';
        ob.firstName='abc';
        ob.lastName='xyz';
        ob.Name='abc xyz';
        ob.Email__c='abcxyz@gmail.com';
        String typeId =[SELECT Id FROM RecordType WHERE Name = 'Person Account'].Id;
        ob.RecordTypeId=typeId; 
        
        Zip_Code__c zipCodeObj = new Zip_Code__c();
        zipCodeObj.City__c = 'New York';
        zipCodeObj.County__c = 'Alameda';
        zipCodeObj.Name = 'test';
        insert zipCodeObj;
        
        Office__c officeObj = new Office__c();
        officeObj.City__c = 'New York';
        insert officeObj;
        
        Office_Zip_Code_Map__c officeZipObj = new Office_Zip_Code_Map__c();
        officeZipObj.Office__c = officeObj.Id;
        officeZipObj.Zip_Code__c = zipCodeObj.Id;
        insert officeZipObj;
        
        Account ob1=new Account();
        ob1.PersonEmail='abc@gmail.com';
        ob1.firstName='abc';
        ob1.lastName='xyz';
        ob1.Name='abc xyz';
        ob1.Email__c='abcxyz@gmail.com';
        ob1.RecordTypeId=null; 
        
        
        
        Test.startTest();
        try{
            Account ob3=new Account();
            System.debug('ob3:::'+ob3);
            insert ob3;
        }catch(Exception ex){
            System.debug('ex:::'+ex);
            new OWCServiceUtility().log(ex);  
        }
        OWCServiceUtility.getDuplicateAccount(ob);  
        OWCServiceUtility.getDuplicateAccount(ob1);
        // OWCServiceUtility.getOfficeLocationByZIPCode('test');
        OWCServiceUtility.getdeserializeUntypedMap('{"name":"John", "Email":"qwer@gmail.com", "lastName":null}');
        OWCServiceUtility.generateJSON('Open','test','fail to update');
        //OWCServiceUtility.populateOfficeOnCM(cse);
        Test.stopTest();
        
        
    }
    
    @isTest static void getPopulateofficeByCm(){
        Trigger_Settings__c setting = new Trigger_Settings__c();
        setting.Name = 'GenerateFieldHistoryAction';
        setting.Is_Active__c = TRUE;
        insert setting;
        
        StaticResource srs = [SELECT Id, Body FROM StaticResource WHERE Name = 'OWCPDFJsonTestData' LIMIT 1];
        Zip_Code__c zip=new Zip_Code__c();
        zip.City__c='Santa Clara Ave';
        zip.County__c='Alameda';
        zip.Region__c='North';
        zip.Name='94501';
        insert zip;
        
        Office__c ofc=new Office__c();
        ofc.Name='WCA - OUT OF STATE';
        ofc.Address_1__c='243 Santa Clara Blvd';
        ofc.City__c='Santa Clara Ave';
        ofc.County__c='Alameda';
        ofc.RecordTypeId= Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        insert ofc;
        
        Office_Zip_Code_Map__c ofczip =new Office_Zip_Code_Map__c();
        ofczip.Zip_Code__c=zip.Id;
        ofczip.Office__c=ofc.Id;
        insert ofczip;
        
        
        DIR_Case__c cse = new DIR_Case__c();
        cse.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
        cse.Related_Party_Employee_Email__c = 'dsyadav@cloudsciencelabs.com';
        cse.Status__c = 'New';
        cse.Advocate_Name_in_Text__c = 'Rajat12345678';
        cse.Employer_Name_in_Text__c = 'Amit';
        cse.Claimant_Name_in_Text__c = 'Abhay';
        cse.Case_Number__c = 'testnumber';
        cse.Intake_Origin__c='Online';
        cse.Office__c=ofc.Id;
        insert cse;
        
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = cse.Id,
                                                       Role__c = 'Defendant',
                                                       Street_Address__c = '123 Praire City Drive, Apt B',
                                                       City__c = 'Whittier',
                                                       State__c = 'CA',
                                                       Zip_Code__c = '90607',
                                                       RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                      );
        
        
        insert new List<Related_Party__c> {objRL1};
            
            
  		List<DIR_Case__c> cseList = [SELECT Id,Name,Claimant_Name_in_Text__c,Advocate_Name_in_Text__c,Related_Party_Employer_Name__c,Case_Number__c,Office__r.Name  
                                         FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat12345678' ];
        
        System.debug('cseList::::'+cseList);
        System.debug('cse:::::'+cse);
        
        
        Test.startTest();
        OWCServiceUtility.populateOfficeOnCM(cse);
        OWCServiceUtility.getOfficeNameByZipCode('94501');
        OWCServiceUtility.validateOfficeAssignment('94501','94501','94501');
        OWCServiceUtility.validateOfficeAssignment('94501','' ,'');
        Test.stopTest();
    }
    
    @isTest static void getPopulateofficeByCm1(){
        Trigger_Settings__c setting = new Trigger_Settings__c();
        setting.Name = 'GenerateFieldHistoryAction';
        setting.Is_Active__c = TRUE;
        insert setting;
        
        StaticResource srs = [SELECT Id, Body FROM StaticResource WHERE Name = 'OWCPDFJsonTestData' LIMIT 1];
        Zip_Code__c zip=new Zip_Code__c();
        zip.City__c='Santa Clara Ave';
        zip.County__c='Alameda';
        zip.Region__c='North';
        zip.Name='94501';
        insert zip;
        
        Office__c ofc=new Office__c();
        ofc.Name='WCA - OUT OF STATE';
        ofc.Address_1__c='243 Santa Clara Blvd';
        ofc.City__c='Santa Clara Ave';
        ofc.County__c='Alameda';
        ofc.RecordTypeId= Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        insert ofc;
        
        Office_Zip_Code_Map__c ofczip =new Office_Zip_Code_Map__c();
        ofczip.Zip_Code__c=zip.Id;
        ofczip.Office__c=ofc.Id;
        insert ofczip;
        
        
        DIR_Case__c cse = new DIR_Case__c();
        cse.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
        cse.Related_Party_Employee_Email__c = 'dsyadav@cloudsciencelabs.com';
        cse.Status__c = 'New';
        cse.Advocate_Name_in_Text__c = 'Rajat12345678';
        cse.Employer_Name_in_Text__c = 'Amit';
        cse.Claimant_Name_in_Text__c = 'Abhay';
        cse.Case_Number__c = 'testnumber';
        cse.Intake_Origin__c='Online';
        
        insert cse;
        
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = cse.Id,
                                                       Role__c = 'Defendant',
                                                       Street_Address__c = '123 Praire City Drive, Apt B',
                                                       City__c = 'Whittier',
                                                       State__c = 'CA',
                                                       Zip_Code__c = '90607',
                                                       RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                      );
        
        
        insert new List<Related_Party__c> {objRL1};
            
            
            List<DIR_Case__c> cseList = [SELECT Id,Name,Claimant_Name_in_Text__c,Advocate_Name_in_Text__c,Related_Party_Employer_Name__c,Case_Number__c,Office__r.Name  
                                         FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat12345678' ];
        
        System.debug('cseList::::'+cseList);
        System.debug('cse:::::'+cse);
        
        
        Test.startTest();
        OWCServiceUtility.populateOfficeOnCM(cse);
        Test.stopTest();
    }
    
    @isTest static void getPopulateofficeByCm2(){
        Trigger_Settings__c setting = new Trigger_Settings__c();
        setting.Name = 'GenerateFieldHistoryAction';
        setting.Is_Active__c = TRUE;
        insert setting;
        
        StaticResource srs = [SELECT Id, Body FROM StaticResource WHERE Name = 'OWCPDFJsonTestData' LIMIT 1];
        Zip_Code__c zip=new Zip_Code__c();
        zip.City__c='Santa Clara Ave';
        zip.County__c='Alameda';
        zip.Region__c='North';
        zip.Name='94501';
        insert zip;
        
        Office__c ofc=new Office__c();
        ofc.Name='WCA - OUT OF STATE';
        ofc.Address_1__c='243 Santa Clara Blvd';
        ofc.City__c='Santa Clara Ave';
        ofc.County__c='Alameda';
        ofc.RecordTypeId= Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        insert ofc;
        
        Office_Zip_Code_Map__c ofczip =new Office_Zip_Code_Map__c();
        ofczip.Zip_Code__c=zip.Id;
        ofczip.Office__c=ofc.Id;
        insert ofczip;
        
        
        DIR_Case__c cse = new DIR_Case__c();
        cse.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
        cse.Related_Party_Employee_Email__c = 'dsyadav@cloudsciencelabs.com';
        cse.Status__c = 'New';
        cse.Advocate_Name_in_Text__c = 'Rajat12345678';
        cse.Employer_Name_in_Text__c = 'Amit';
        cse.Claimant_Name_in_Text__c = 'Abhay';
        cse.Case_Number__c = 'testnumber';
        cse.Intake_Origin__c='Online';
        
        insert cse;
        
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = cse.Id,
                                                       Role__c = 'Defendant',
                                                       Street_Address__c = '123 Praire City Drive, Apt B',
                                                       City__c = 'Whittier',
                                                       State__c = 'CA',
                                                       Zip_Code__c = '12345',
                                                       RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                      );
        
        
        insert new List<Related_Party__c> {objRL1};
            
            
            List<DIR_Case__c> cseList = [SELECT Id,Name,Claimant_Name_in_Text__c,Advocate_Name_in_Text__c,Related_Party_Employer_Name__c,Case_Number__c,Office__r.Name  
                                         FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat12345678' ];
        
        System.debug('cseList::::'+cseList);
        System.debug('cse:::::'+cse);
        
        
        Test.startTest();
        OWCServiceUtility.populateOfficeOnCM(cse);
        Test.stopTest();
    }
    
}