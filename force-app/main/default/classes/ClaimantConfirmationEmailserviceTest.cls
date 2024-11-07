@isTest
public class ClaimantConfirmationEmailserviceTest {
    @testSetup static void setup() {
        Trigger_Settings__c setting = new Trigger_Settings__c();
        setting.Name = 'GenerateFieldHistoryAction';
        setting.Is_Active__c = TRUE;
        insert setting;
        
        Account objAcct1 = new Account(Name = 'Acct1', ShippingCity = 'ShippingCity1', BillingCity = 'BillingCity1');
        Account objAcct2 = new Account(Name = 'Acct2', ShippingCity = 'ShippingCity2', BillingCity = 'BillingCity2');
        insert new List<Account> {objAcct1,objAcct2}; 
            
            DIR_Case__c cse = new DIR_Case__c();
        cse.recordTypeId = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
        cse.Related_Party_Employee_Email__c = 'rrastogi@cloudsciencelabs.com';
        cse.Status__c = 'Not Confirmed';
        cse.Advocate_Name_in_Text__c = 'Rajat';
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
        
        insert new List<Related_Party__c> {objRL1};
        
    }
    static testMethod void TestinBoundEmail0()
    {
        List<DIR_Case__c> cseList = [SELECT Id,Name  
                                         FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat' ]; 
        
        Test.startTest();
        
         Messaging.InboundEmail email0 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env0 = new Messaging.InboundEnvelope();
        String emailTemplateName0 = '';
        String accname0 = email0.fromName;
        email0.plainTextBody='Note confirmar that Confirmación mailservers have of 990-character limit on negar each line contained wrote within an email message. If an email message is sent that contains lines longer than 990-characters, those lines will be subdivided by additional line ending characters, which can cause corruption in the email message, particularly for HTML content. To prevent this from occurring, add your own line-ending characters at appropriate locations within the email message to ensure that no lines are longer than 990 characters.Anyone else seem to have this problem? and how did you fix this?Sounds like I need to find a good place to split my HTML and manually add a line break';
        email0.Subject='Confirmación'+ '('+cseList[0].Name+')';
        ClaimantConfirmationEmailservice obj0= new ClaimantConfirmationEmailservice();
        Messaging.InboundEmailResult a0= obj0.handleInboundEmail(email0,env0); 
        Test.stopTest();
    } 
    static testMethod void TestinBoundEmail1()
    {  
    
            List<DIR_Case__c> cseList = [SELECT Id,Name  
                                         FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat' ]; 
        
        Test.startTest();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String emailTemplateName = '';
        String accname = email.fromName;
        email.plainTextBody='Note that Confirmación mailservers have a 990-character limit on  confirmar each line contained wrote within an email message. If an email message is sent that contains lines longer than 990-characters, those lines will be subdivided by additional line ending characters, which can cause corruption in the email message, particularly for HTML content. To prevent this from occurring, add your own line-ending characters at appropriate locations within the email message to ensure that no lines are longer than 990 characters.Anyone else seem to have this problem? and how did you fix this?Sounds like I need to find a good place to split my HTML and manually add a line break';
        email.Subject='Confirmación'+ '('+cseList[0].Name+')';
        ClaimantConfirmationEmailservice obj= new ClaimantConfirmationEmailservice();
        obj.handleInboundEmail(email,env); 
        Test.stopTest();
        }
    static testMethod void TestinBoundEmail3()
    {  
    
            List<DIR_Case__c> cseList = [SELECT Id,Name  
                                         FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat' ]; 
        Test.startTest();
        Messaging.InboundEmail email1 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
        String emailTemplateName1 = '';
        String accname1 = email1.fromName;
        email1.plainTextBody='Note negar that Confirmación mailservers have a 990-character limit on  each line contained wrote within an email message. If an email message is sent that contains lines longer than 990-characters, those lines will be subdivided by additional line ending characters, which can cause corruption in the email message, particularly for HTML content. To prevent this from occurring, add your own line-ending characters at appropriate locations within the email message to ensure that no lines are longer than 990 characters.Anyone else seem to have this problem? and how did you fix this?Sounds like I need to find a good place to split my HTML and manually add a line break';
        email1.Subject='Confirmación'+ '('+cseList[0].Name+')';
        ClaimantConfirmationEmailservice obj1= new ClaimantConfirmationEmailservice();
        obj1.handleInboundEmail(email1,env1); 
        Test.stopTest();
    }
    
    static testMethod void TestinBoundEmail2()
    {  
    
            List<DIR_Case__c> cseList = [SELECT Id,Name  
                                         FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat' ]; 

        
        Test.startTest();
        Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
        String emailTemplateName2 = '';
        String accname2 = email2.fromName;
        email2.plainTextBody='Note that Confirmación mailservers have a 990-character limit on  each line contained wrote within an email message. If an email message is sent that contains lines longer than 990-characters, those lines will be subdivided by additional line ending characters, which can cause corruption in the email message, particularly for HTML content. To prevent this from occurring, add your own line-ending characters at appropriate locations within the email message to ensure that no lines are longer than 990 characters.Anyone else seem to have this problem? and how did you fix this?Sounds like I need to find a good place to split my HTML and manually add a line break';
        email2.Subject='Confirmación'+ '('+cseList[0].Name+')';
        ClaimantConfirmationEmailservice obj2= new ClaimantConfirmationEmailservice();
        obj2.handleInboundEmail(email2,env2); 
        
        Test.stopTest();
        
        
    }
    static testMethod void TestinBoundEmail4()
    {   
        
            
            List<DIR_Case__c> cseList = [SELECT Id,Name  
                                         FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat' ]; 
        
        Test.startTest();
        Messaging.InboundEmail email1 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
        String emailTemplateName1 = '';
        String accname1 = email1.fromName;
        email1.plainTextBody='Note Confirmation that mailservers have a confirm 990-character limit on deny each line contained wrote within an email message. If an email message is sent that contains lines longer than 990-characters, those lines will be subdivided by additional line ending characters, which can cause corruption in the email message, particularly for HTML content. To prevent this from occurring, add your own line-ending characters at appropriate locations within the email message to ensure that no lines are longer than 990 characters.Anyone else seem to have this problem? and how did you fix this?Sounds like I need to find a good place to split my HTML and manually add a line break';
        email1.Subject='Confirmation'+ '('+cseList[0].Name+')';
        ClaimantConfirmationEmailservice obj1= new ClaimantConfirmationEmailservice();
        obj1.handleInboundEmail(email1,env1); 
        Test.stopTest();
        }
    static testMethod void TestinBoundEmail()
    {   
        
            
            List<DIR_Case__c> cseList = [SELECT Id,Name  
                                         FROM DIR_Case__c WHERE Advocate_Name_in_Text__c='Rajat' ]; 
        
        
         Messaging.InboundEmail email3 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env3 = new Messaging.InboundEnvelope();
        String emailTemplateName3 = '';
        String accname3 = email3.fromName;
        email3.plainTextBody='Note Confirmation that mailservers have a 990-character limit on each line contained wrote within an email message. If an email message is sent that contains lines longer than 990-characters, those lines will be subdivided by additional line ending characters, which can cause corruption in the email message, particularly for HTML content. To prevent this from occurring, add your own line-ending characters at appropriate locations within the email message to ensure that no lines are longer than 990 characters.Anyone else seem to have this problem? and how did you fix this?Sounds like I need to find a good place to split my HTML and manually add a line break';
        email3.Subject='Confirmation'+ '('+cseList[0].Name+')';
        ClaimantConfirmationEmailservice obj3= new ClaimantConfirmationEmailservice();
        obj3.handleInboundEmail(email3,env3); 
        
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        String emailTemplateName = '';
        String accname = email.fromName;
        email.plainTextBody='Note Confirmation that mailservers have a 990-character limit on  confirm each line contained wrote within an email message. If an email message is sent that contains lines longer than 990-characters, those lines will be subdivided by additional line ending characters, which can cause corruption in the email message, particularly for HTML content. To prevent this from occurring, add your own line-ending characters at appropriate locations within the email message to ensure that no lines are longer than 990 characters.Anyone else seem to have this problem? and how did you fix this?Sounds like I need to find a good place to split my HTML and manually add a line break';
        email.Subject='Confirmation'+ '('+cseList[0].Name+')';
        ClaimantConfirmationEmailservice obj= new ClaimantConfirmationEmailservice();
        obj.handleInboundEmail(email,env); 
        
        
        
        Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
        String emailTemplateName2 = '';
        String accname2 = email2.fromName;
        email2.plainTextBody='Note Confirmation that mailservers have a 990-character limit on deny each line contained wrote within an email message. If an email message is sent that contains lines longer than 990-characters, those lines will be subdivided by additional line ending characters, which can cause corruption in the email message, particularly for HTML content. To prevent this from occurring, add your own line-ending characters at appropriate locations within the email message to ensure that no lines are longer than 990 characters.Anyone else seem to have this problem? and how did you fix this?Sounds like I need to find a good place to split my HTML and manually add a line break';
        email2.Subject='Confirmation'+ '('+cseList[0].Name+')';
        ClaimantConfirmationEmailservice obj2= new ClaimantConfirmationEmailservice();
        obj2.handleInboundEmail(email2,env2); 
        
        
        
        
    } 
}