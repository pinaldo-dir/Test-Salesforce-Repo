@isTest
public class LRHandlerHelperTest {
    
    public static testMethod void testLRHandlerHelper(){
        
        Id recTypeIdEWP = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
		Id recTypeIdCW = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();        
        Id recTypeParent = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Parent Guardian').getRecordTypeId();
        Id recTypeMgmt = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account(
            FirstName = 'test',
            LastName = 'acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            PersonEmail = 'lralltestusers@test.com',
            RecordTypeId = personRecordTypeId
        );
        insert acc;
        
        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Email = 'first.last@gmail.com';
        insert c;
                        
        License_Registration__c lReg1 = new License_Registration__c ();
        lReg1.Account__c = acc.Id;
        lReg1.RecordTypeId = recTypeIdEWP;
        lReg1.License_Registration_Number__c = acc.Id;
        lReg1.License_Registration_Type__c = '3333';
        lReg1.Submitted_Date__c = Date.today() - 3;
        lReg1.Applicant__c = c.Id;
        lReg1.Registration_Duration__c  = '10 Days - Temporary Permit';
        lReg1.Submission_Type__c = 'Online';
        lReg1.Renewal__c = False;
        lReg1.Service_Type__c = 'New';
        lReg1.First_Name__c = 'FirstName';
        lReg1.Middle_Name__c = 'Middle';
        lReg1.Last_Name__c = 'LastName';
        lReg1.Birth_Date__c =  Date.Today() - 30;
        lReg1.Account_Email__c = 'test@asdadad.com';
        lReg1.Mailing_Address_Line_1__c = 'Street';
        lReg1.Mailing_City__c = 'San Francisco';
        lReg1.Mailing_State__c = 'CA';
        lReg1.Mailing_Postal_Code__c = '54434';
        lReg1.Daytime_Phone__c = '1234567890';
        lReg1.Mobile_Phone__c = '1234567890';
        lReg1.Date_Formed__c = Date.today();                   
        lReg1.Daytime_Phone_Ext__c ='123';          
        lReg1.Residential_Address_Line_1__c = 'asdf';            
        lReg1.Residential_City__c = 'asdf';           
        lReg1.Residential_Postal_Code__c = '12345';           
        lReg1.Residential_State__c = 'CA';          
        insert lReg1;
        
        License_Registration__c lReg2= new License_Registration__c ();
        lReg2.Account__c = acc.Id;
        lReg2.RecordTypeId = recTypeIdCW;
        lReg2.License_Registration_Number__c = acc.Id;
        lReg2.License_Registration_Type__c = '3333';
        lReg2.Applicant__c = c.Id;
        lReg2.First_Name__c = 'FirstName';
        lReg2.Last_Name__c = 'LastName';
		lReg2.Birth_Date__c =  Date.Today() - 30;
        lReg2.Company_type__c = 'Sole Proprietorship';
        lReg2.Service_Type__c = 'New';
        lReg2.Renewal__c = False;
        lReg2.Residential_Address_Line_1__c = 'Street';
        lReg2.Residential_City__c ='City';
        lReg2.Residential_State__c = 'CA';
        lReg2.Residential_Postal_Code__c = '54434';
        lReg2.VIP_Date_Time_Submitted__c = NULL;
        lReg2.Mailing_Address_Line_1__c = 'Street';
        lReg2.Mailing_City__c = 'San Francisco';
        lReg2.Mailing_State__c = 'CA';
        lReg2.Mailing_Postal_Code__c = '54434';

		lReg2.Effective_Date__c = date.today();
        lReg2.Expiration_Date__c = date.today()+90;
        insert lReg2; 
        
                                
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = recTypeParent;
        racc1.First_Name__c = 'FirstName';
        racc1.Middle_Name__c = 'Middle';
        racc1.Last_Name__c = 'LastName';
        racc1.Birth_Date__c =  Date.Today() - 30;
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Legal_Entity_Name__c = 'Legal Entity Name';
        racc1.Mailing_Street__c = 'Street';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '1234567890';
        racc1.Mobile_Phone__c = '1234567890';
        racc1.Date_Formed__c = Date.today();        
        racc1.Business_Phone__c = '1234567890';             
        //racc1.Daytime_Phone_Ext__c ='123';          
        racc1.Physical_Business_Street__c = 'asdf';            
        //racc1.Physical_Business_Line_2__c = '';             
        racc1.Physical_Business_City__c = 'asdf';           
        //racc1.Physical_Business_Country__c = '';
        racc1.Physical_Business_Zip_Code__c = '12345';           
        racc1.Physical_Business_State__c = 'CA'; 
        racc1.Federal_Employer_Identification_Number__c ='123456789';
        racc1.State_Employer_Identification_Number_c__c = '12345678';    
        racc1.State_of_Incorporation__c = 'CA';
        racc1.Registration__c = lReg1.Id;
        
        insert racc1;
         
        
        Registration_Account__c racc2 = new Registration_Account__c();
        racc2.RecordTypeId = recTypeMgmt;
        racc2.First_Name__c = 'First Name';
        racc2.Middle_Name__c = 'Middle';
        racc2.Last_Name__c = 'LastName';
        racc2.Birth_Date__c =  Date.Today() - 30;
        
        racc2.Email_Address__c = 'test@asdadad.com';
        racc2.Legal_Entity_Name__c = 'Legal Entity Name';
        racc2.Mailing_Street__c = 'Street';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_State__c = 'CA';
        racc2.Mailing_Zip_Code__c = '54434';
        racc2.Registration__c = lReg2.id;
        insert racc2;
        
               
        License_Registration__c lReg4 = new License_Registration__c ();
        lReg4.Account__c = acc.Id;
        lReg4.RecordTypeId = recTypeIdEWP;
        lReg4.License_Registration_Number__c = acc.Id;
        lReg4.License_Registration_Type__c = '3333';
        lReg4.Submitted_Date__c = Date.today() - 3;
        lReg4.Applicant__c = c.Id;
        lReg4.Registration_Duration__c  = '10 Days - Temporary Permit';
        lReg4.Submission_Type__c = 'Online';
        lReg4.Renewal__c = False;
        lReg4.Service_Type__c = 'New';
        lReg4.First_Name__c = 'FirstName';
        lReg4.Middle_Name__c = 'Middle';
        lReg4.Last_Name__c = 'LastName';
        lReg4.Birth_Date__c =  Date.Today() - 30;
        lReg4.Status__c = 'Submitted';
        lReg4.Account_Email__c = 'test@asdadad.com';
        lReg4.Mailing_Address_Line_1__c = 'Street';
        lReg4.Mailing_City__c = 'San Francisco';
        lReg4.Mailing_State__c = 'CA';
        lReg4.Mailing_Postal_Code__c = '54434';
        lReg4.Daytime_Phone__c = '1234567890';
        lReg4.Mobile_Phone__c = '1234567890';
        lReg4.Date_Formed__c = Date.today();                   
        lReg4.Daytime_Phone_Ext__c ='123';          
        lReg4.Residential_Address_Line_1__c = 'asdf';            
        lReg4.Residential_City__c = 'asdf';           
        lReg4.Residential_Postal_Code__c = '12345';           
        lReg4.Residential_State__c = 'CA';          
        insert lReg4;
        
        License_Registration__c lReg5 = new License_Registration__c ();
        lReg5.Account__c = acc.Id;
        lReg5.RecordTypeId = recTypeIdEWP;
        lReg5.License_Registration_Number__c = acc.Id;
        lReg5.License_Registration_Type__c = '3333';
        lReg5.Submitted_Date__c = Date.today() - 3;
        lReg5.Applicant__c = c.Id;
        lReg5.Registration_Duration__c  = '6 Months - Permit';
        lReg5.Submission_Type__c = 'Online';
        lReg5.Renewal__c = False;
        lReg5.Service_Type__c = 'New';
        lReg5.First_Name__c = 'FirstName';
        lReg5.Middle_Name__c = 'Middle';
        lReg5.Last_Name__c = 'LastName';
        lReg5.Birth_Date__c =  Date.Today() - 30;
        lReg5.Status__c = 'Submitted';
        lReg5.Account_Email__c = 'test@asdadad.com';
        lReg5.Mailing_Address_Line_1__c = 'Street';
        lReg5.Mailing_City__c = 'San Francisco';
        lReg5.Mailing_State__c = 'CA';
        lReg5.Mailing_Postal_Code__c = '54434';
        lReg5.Daytime_Phone__c = '1234567890';
        lReg5.Mobile_Phone__c = '1234567890';
        lReg5.Residential_Address_Line_1__c = 'asdf';            
        lReg5.Residential_City__c = 'asdf';           
        lReg5.Residential_Postal_Code__c = '12345';           
        lReg5.Residential_State__c = 'CA';          
        insert lReg5;
       
      
        List<License_Registration__c> lrList = new List<License_Registration__c>();
        lrList.add(lReg1);
        
        List<License_Registration__c> lReg3 = [SELECT Id,First_Name__c, Last_Name__c, Service_Type__c,Birth_Date__c, RecordTypeId, Record_Type_Name__c, Registration_Duration__c, Status__c FROM License_Registration__c WHERE Id =: lReg1.Id];
        List<License_Registration__c> lReg6 = [SELECT Id,First_Name__c, Last_Name__c, Service_Type__c,Birth_Date__c, RecordTypeId, Record_Type_Name__c, Registration_Duration__c, Status__c FROM License_Registration__c WHERE Id =: lReg5.Id];
            
        test.startTest();
        
        //LRHandlerRegistrations LRHandlerReg = new LRHandlerRegistrations();
        //LRHandlerReg.CreateRegistrations(lrList);
        //LRHandlerHelper.getInstance().initiateRegAccount(lReg1, racc1);
        
        //LRHandlerHelper.getInstance().isDuplicateRegAccount(lReg1, recTypeIdIndvPermit);
        
        Map<Id, License_Registration__c> oldMap = new Map<Id, License_Registration__c>();
        LRHandlerHelper.getInstance().isExistingPermitHolder(lReg3, oldMap);
        LRHandlerHelper.getInstance().isExistingPermitHolder(lReg6, oldMap);
        //LRHandlerHelper.getInstance().CheckValidRegistrationAge(lReg3, oldMap);
        //LRHandlerHelper.getInstance().getAllEWPRA();
         LRHandlerHelper.getInstance().initiateRegAccount(lReg2, racc2);
         LRHandlerHelper.getInstance().isDuplicateRegAccount(lReg2, recTypeIdCW);
        test.stopTest();
        
    }
}