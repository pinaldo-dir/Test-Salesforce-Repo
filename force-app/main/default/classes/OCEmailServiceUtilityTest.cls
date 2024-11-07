@isTest
public class OCEmailServiceUtilityTest
{
    
    static testMethod void sendConfirmationEmailtoClaimantTest()
    {
        Trigger_Settings__c setting = new Trigger_Settings__c();
        setting.Name = 'GenerateFieldHistoryAction';
        setting.Is_Active__c = TRUE;
        insert setting;
        
        DIR_Case__c cse = new DIR_Case__c();
        List<DIR_Case__c> dirCases=new List<DIR_Case__c>();
        cse.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
        cse.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
        cse.Related_Party_Advocate_Email__c='dmaurya@cloudsciencelabs.com';
        cse.Status__c = 'Not Confirmed';
        cse.Advocate_Name_in_Text__c = 'Rajat';
        cse.Employer_Name_in_Text__c = 'Amit';
        cse.Claimant_Name_in_Text__c = 'Abhay';
        cse.Case_Number__c = 'testnumber';
        cse.Applicant_Type__c = 'Representative Garment';
        dirCases.add(cse);
        insert dirCases;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Wage Claim Summary Report'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
         content.PathOnClient='/' + content.Title + '.jpg'; 
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=dirCases[0].id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        
        insert contentlink;
 
        
         DIR_Case__c cse1 = new DIR_Case__c();
        List<DIR_Case__c> dirCases1=new List<DIR_Case__c>();
        cse1.recordTypeId = OWCConstants.WCA_CASE_RECORD_TYPE_ID;
        cse1.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
        cse1.Related_Party_Advocate_Email__c='dmaurya@cloudsciencelabs.com';
        cse1.Status__c = 'New';
        cse1.Referred_From__c='Claimant';
        cse1.Applicant_Type__c='Claimant Garment';
        cse1.Advocate_Name_in_Text__c = 'Rajat';
        cse1.Employer_Name_in_Text__c = 'Amit';
        cse1.Claimant_Name_in_Text__c = 'Abhay';
        cse1.Case_Number__c = 'testnumber';
        dirCases1.add(cse1);
        insert dirCases1;
        
        
         DIR_Case__c cse2 = new DIR_Case__c();
        List<DIR_Case__c> dirCases2=new List<DIR_Case__c>();
        cse2.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
        cse2.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
        cse2.Related_Party_Advocate_Email__c='dmaurya@cloudsciencelabs.com';
        cse2.Status__c = 'New';
        cse2.Referred_From__c='';
        cse2.Applicant_Type__c='Claimant Garment';
        cse2.Advocate_Name_in_Text__c = 'Rajat';
        cse2.Employer_Name_in_Text__c = 'Amit';
        cse2.Claimant_Name_in_Text__c = 'Abhay';
        cse2.Case_Number__c = 'testnumber';
        dirCases2.add(cse2);
        insert dirCases2;
        
        DIR_Case__c cse3 = new DIR_Case__c();
        List<DIR_Case__c> dirCases3=new List<DIR_Case__c>();
        cse3.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
        cse3.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
        cse3.Related_Party_Advocate_Email__c='dmaurya@cloudsciencelabs.com';
        cse3.Status__c = 'New';
        cse3.Referred_From__c='Claimant';
        cse3.Applicant_Type__c='';
        cse3.Advocate_Name_in_Text__c = 'Rajat';
        cse3.Employer_Name_in_Text__c = 'Amit';
        cse3.Claimant_Name_in_Text__c = 'Abhay';
        cse3.Case_Number__c = 'testnumber';
        dirCases3.add(cse3);
        insert dirCases3;
        
        ContentVersion content1=new ContentVersion(); 
        content1.Title='Wage Claim Summary Report'; 
        Blob bodyBlob1=Blob.valueOf('Unit Test ContentVersion Body'); 
        content1.VersionData=bodyBlob1; 
        //content.LinkedEntityId=sub.id;
         content1.PathOnClient='/' + content1.Title + '.jpg'; 
        content1.origin = 'H';
        insert content1;
        ContentDocumentLink contentlink1=new ContentDocumentLink();
        contentlink1.LinkedEntityId=dirCases3[0].id;
        contentlink1.contentdocumentid=[select contentdocumentid from contentversion where id =: content1.id].contentdocumentid;
        contentlink1.ShareType = 'I';
        contentlink1.Visibility = 'AllUsers'; 
        
        
        insert contentlink1;
        
        
        OCEmailServiceUtility.sendConfirmationEmailtoClaimant(dirCases);
        OCEmailServiceUtility.sendConfirmationEmailtoClaimant(dirCases1);
        OCEmailServiceUtility.sendConfirmationEmailtoClaimant(dirCases2);
        OCEmailServiceUtility.sendConfirmationEmailtoClaimant(dirCases3);
        OCEmailServiceUtility.sendTestEmail('Testing 123');
        OCEmailServiceUtility.sendOfficeChangeEmailToClaimant('Office_Assignment_change_notification', cse.Id);
        OCEmailServiceUtility.sendOfficeChangeEmailToAdvocate('Office_Assignment_change_notification', cse.Id);
    }
    static testMethod void sendConfirmationEmailtoClaimantTest2()
    {	
        User usr = [SELECT Id, LanguageLocaleKey FROM User WHERE Id =: UserInfo.getUserId()];
        usr.LanguageLocaleKey = 'es';
        update usr;
        System.runAs(usr){
            Trigger_Settings__c setting = new Trigger_Settings__c();
            setting.Name = 'GenerateFieldHistoryAction';
            setting.Is_Active__c = TRUE;
            insert setting;
            
            DIR_Case__c cse = new DIR_Case__c();
            List<DIR_Case__c> dirCases=new List<DIR_Case__c>();
            cse.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
            cse.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
            cse.Related_Party_Advocate_Email__c='dmaurya@cloudsciencelabs.com';
            cse.Status__c = 'Not Confirmed';
            cse.Advocate_Name_in_Text__c = 'Rajat';
            cse.Employer_Name_in_Text__c = 'Amit';
            cse.Claimant_Name_in_Text__c = 'Abhay';
            cse.Case_Number__c = 'testnumber';
            dirCases.add(cse);
            insert dirCases;
            
            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            //content.LinkedEntityId=sub.id;
             content.PathOnClient='/' + content.Title + '.jpg'; 
            content.origin = 'H';
            insert content;
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=dirCases[0].id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            
            
            insert contentlink;
            
            DIR_Case__c cse1 = new DIR_Case__c();
            List<DIR_Case__c> dirCases1=new List<DIR_Case__c>();
            cse1.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
            cse1.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
            cse1.Related_Party_Advocate_Email__c='dmaurya@cloudsciencelabs.com';
            cse1.Status__c = 'New';
            cse1.Referred_From__c='';
            cse1.Applicant_Type__c='Representative Garment';
            cse1.Advocate_Name_in_Text__c = 'Rajat';
            cse1.Employer_Name_in_Text__c = 'Amit';
            cse1.Claimant_Name_in_Text__c = 'Abhay';
            cse1.Case_Number__c = 'testnumber';
            dirCases1.add(cse1);
            insert dirCases1;
            
            DIR_Case__c cse2 = new DIR_Case__c();
            List<DIR_Case__c> dirCases2=new List<DIR_Case__c>();
            cse2.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
            cse2.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
            cse2.Related_Party_Advocate_Email__c='dmaurya@cloudsciencelabs.com';
            cse2.Status__c = 'New';
            cse2.Referred_From__c='';
            cse2.Applicant_Type__c='Claimant Garment';
            cse2.Advocate_Name_in_Text__c = 'Rajat';
            cse2.Employer_Name_in_Text__c = 'Amit';
            cse2.Claimant_Name_in_Text__c = 'Abhay';
            cse2.Case_Number__c = 'testnumber';
            dirCases2.add(cse2);
            insert dirCases2;
            
            DIR_Case__c cse3 = new DIR_Case__c();
            List<DIR_Case__c> dirCases3=new List<DIR_Case__c>();
            cse3.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
            cse3.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
            cse3.Related_Party_Advocate_Email__c='dmaurya@cloudsciencelabs.com';
            cse3.Status__c = 'New';
            cse3.Referred_From__c='Claimant';
            cse3.Applicant_Type__c='';
            cse3.Advocate_Name_in_Text__c = 'Rajat';
            cse3.Employer_Name_in_Text__c = 'Amit';
            cse3.Claimant_Name_in_Text__c = 'Abhay';
            cse3.Case_Number__c = 'testnumber';
            dirCases3.add(cse3);
            insert dirCases3;
            
            OCEmailServiceUtility.sendConfirmationEmailtoClaimant(dirCases);
            OCEmailServiceUtility.sendConfirmationEmailtoClaimant(dirCases1);
            OCEmailServiceUtility.sendConfirmationEmailtoClaimant(dirCases2);
            OCEmailServiceUtility.sendConfirmationEmailtoClaimant(dirCases3);
            OCEmailServiceUtility.sendTestEmail('Testing 123');
            OCEmailServiceUtility.sendOfficeChangeEmailToClaimant('Office_Assignment_change_notification', cse.Id);
            OCEmailServiceUtility.sendOfficeChangeEmailToAdvocate('Office_Assignment_change_notification', cse.Id);
        }
        
    }
    static testMethod void sendAutoResponseTest()
    {
        Trigger_Settings__c setting = new Trigger_Settings__c();
        setting.Name = 'GenerateFieldHistoryAction';
        setting.Is_Active__c = TRUE;
        insert setting;
        
        Account objAcct1 = new Account(Name = 'Acct1', ShippingCity = 'ShippingCity1', BillingCity = 'BillingCity1');
        Account objAcct2 = new Account(Name = 'Acct2', ShippingCity = 'ShippingCity2', BillingCity = 'BillingCity2');
        insert new List<Account> {objAcct1,objAcct2}; 
            
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
        cse.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
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
        
          OCEmailServiceUtility.sendAutoResponse(cseList,'Claim Email Reply Confirm',cse.Related_Party_Employee_Email__c);
        OCEmailServiceUtility.sendNewOnlineClaimEmail(cse);
      
        
        
        
    }
    static testMethod void sendAutoResponseTest2()
    {	
        
        User usr = [SELECT Id, LanguageLocaleKey FROM User WHERE Id =: UserInfo.getUserId()];
        usr.LanguageLocaleKey = 'es';
        update usr;
        
        System.runAs(usr){
            Trigger_Settings__c setting = new Trigger_Settings__c();
            setting.Name = 'GenerateFieldHistoryAction';
            setting.Is_Active__c = TRUE;
            insert setting;
            
            Account objAcct1 = new Account(Name = 'Acct1', ShippingCity = 'ShippingCity1', BillingCity = 'BillingCity1');
            Account objAcct2 = new Account(Name = 'Acct2', ShippingCity = 'ShippingCity2', BillingCity = 'BillingCity2');
            insert new List<Account> {objAcct1,objAcct2}; 
                
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
            cse.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
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
            
            OCEmailServiceUtility.sendAutoResponse(cseList,'Claim Email Reply Confirm',cse.Related_Party_Employee_Email__c);
            OCEmailServiceUtility.sendNewOnlineClaimEmail(cse);
        }
        
    }
        static testMethod void sendAutoResponseTest3()
    {	
        
        
            Trigger_Settings__c setting = new Trigger_Settings__c();
            setting.Name = 'GenerateFieldHistoryAction';
            setting.Is_Active__c = TRUE;
            insert setting;
            
            Account objAcct1 = new Account(Name = 'Acct1', ShippingCity = 'ShippingCity1', BillingCity = 'BillingCity1');
            Account objAcct2 = new Account(Name = 'Acct2', ShippingCity = 'ShippingCity2', BillingCity = 'BillingCity2');
            insert new List<Account> {objAcct1,objAcct2}; 
                
                Zip_Code__c zip=new Zip_Code__c();
            zip.City__c='Santa Clara Ave';
            zip.County__c='Alameda';
            zip.Region__c='North';
            zip.Name='94501';
            insert zip;
            
            Office__c ofc=new Office__c();
            ofc.Name='Callifornia';
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
            List<DIR_Case__c> dirCases=new List<DIR_Case__c>();
            cse.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
            cse.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
            cse.Related_Party_Advocate_Email__c='dmaurya@cloudsciencelabs.com';
            cse.Status__c = 'New';
            cse.Advocate_Name_in_Text__c = 'Rajat';
            cse.Employer_Name_in_Text__c = 'Amit';
            cse.Claimant_Name_in_Text__c = 'Abhay';
            cse.Case_Number__c = 'testnumber';
        cse.Office__c = ofc.id;
        dirCases.add(cse);
        insert dirCases;
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        content.PathOnClient='/' + content.Title + '.jpg'; 
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=dirCases[0].id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        
        insert contentlink;
        
            DIR_Case__c cse1 = new DIR_Case__c();
            List<DIR_Case__c> dirCases1=new List<DIR_Case__c>();
            cse1.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
            cse1.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
            cse1.Related_Party_Advocate_Email__c='dmaurya@cloudsciencelabs.com';
            cse1.Status__c = 'New';
            cse1.Referred_From__c='';
            cse1.Applicant_Type__c='Representative Garment';
            cse1.Advocate_Name_in_Text__c = 'Rajat12345678';
            cse1.Employer_Name_in_Text__c = 'Amit';
            cse1.Claimant_Name_in_Text__c = 'Abhay';
            cse1.Case_Number__c = 'testnumber';
            dirCases1.add(cse1);
            insert dirCases1;
            
            Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = cse1.Id,
                                                           Role__c = 'Defendant',
                                                           Street_Address__c = '123 Praire City Drive, Apt B',
                                                           City__c = 'Whittier',
                                                           State__c = 'CA',
                                                           Zip_Code__c = '90607',
                                                           RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                          );
            
            
            insert new List<Related_Party__c> {objRL1};
                
                
                List<DIR_Case__c> cseList = [SELECT Id,Name,Related_Party_Advocate_Email__c,Claimant_Name_in_Text__c,Advocate_Name_in_Text__c,CreatedDate,Related_Party_Employer_Name__c,Case_Number__c,Office__r.Name  
                                             FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat12345678' ];
            
            OCEmailServiceUtility.sendAutoResponse(cseList,'Claim Email Reply Confirm',cse1.Related_Party_Employee_Email__c);
        	OCEmailServiceUtility.sendEmailToClaimantOnYourself('Claimant_notification_Claim_submitted_by_Claimant',dirCases[0].Id,'California');
        	OCEmailServiceUtility.sendEmailToAdvocateOnConfirm('Advocate_notification_Confirmed',dirCases[0]);
        
            List<DIR_Case__c> cseList1 = [SELECT Id,Name,Claimant_Name_in_Text__c,Related_Party_Advocate_Email__c,CreatedDate,Advocate_Name_in_Text__c,Related_Party_Employer_Name__c,Case_Number__c,Office__r.Name  
                                         FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat' ];
        
        	OCEmailServiceUtility.sendEmailtoAdvocateOnClosed(cseList1[0]);
            OCEmailServiceUtility.sendNewOnlineClaimEmail(cse1);
            
        
    }
    
}