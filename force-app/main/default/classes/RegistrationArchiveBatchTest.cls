@isTest
public class RegistrationArchiveBatchTest {
    
    @testSetup static void setup(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();

        Trigger_Settings__c EmployeeTriggerSetting = new Trigger_Settings__c(
            Name = 'DIR_EmployeeTrigger',
            Is_Active__c = true
        );
        triggerSettings.add(EmployeeTriggerSetting);        
        
        Trigger_Settings__c CaseRoleAllTriggerSetting = new Trigger_Settings__c(
            Name = 'CaseRoleAll',
            Is_Active__c = false
        );
        triggerSettings.add(CaseRoleAllTriggerSetting);  
        insert triggerSettings;
        
        Account a = new Account();
        a.Name = 'test account'+system.now();
        insert a;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Community Contact').getRecordTypeId();
        insert con;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma;
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        
        List<License_Registration__c> lregList = new List<License_Registration__c>();
        for (Integer i = 0; i < 10;i++){
            lregList.add(new  License_Registration__c(
            RecordTypeId = devRecordTypeId,
            Account__c = a.Id,
            Applicant__c = con.Id));
            
        }
        insert lregList;
        /*
        License_Registration__c lreg = new License_Registration__c(
            RecordTypeId = devRecordTypeId,
            Account__c = a.Id,
            Applicant__c = con.Id
            //License_Registration_Number__c = '00023568500'
            //Status__c = 'Approved'
        );
        insert lreg; 
		*/
        
        DIR_Employee__c de = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = ma.Id
        );
        insert de;
        
        
        Attachment att = new Attachment(
            Body = blob.valueOf('test body'),
            Name = 'test name',
            isPrivate = false,
            ParentId = lregList[0].Id
        );
        insert att;
        
        List<ContentVersion> contentList = new List<ContentVersion>();
        for(Integer i = 0 ; i < 10 ; i++){
            contentList.add(new ContentVersion(
            Title='Test' + i,
            PathOnClient='/' + 'Test' + i + '.jpg', 
            VersionData=Blob.valueOf('Unit Test ContentVersion Body'))); 
        }
        insert contentList;
        
        /*
        ContentVersion content=new ContentVersion(
            Title='Test',
            PathOnClient='/' + 'Test' + '.jpg', 
            VersionData=Blob.valueOf('Unit Test ContentVersion Body')
        ); 
        insert content;
        */
        
        List<ContentDocumentLink> contentLinkList = new List<ContentDocumentLink>();
        //contentList = [Select Id from ContentVersion];
        Integer k = 0;
        for (License_Registration__c lreg: [Select id From License_Registration__c]){
            contentLinkList.add(new ContentDocumentLink(
                LinkedEntityId=lreg.id,
                contentdocumentid=[select contentdocumentid from contentversion where id =: contentList[k].id].contentdocumentid,
                ShareType = 'I',
            	Visibility = 'AllUsers'));
            k++;
        }
        
        insert contentLinkList;
        
        /*
        ContentDocumentLink contentlink=new ContentDocumentLink(
            LinkedEntityId=lregList[0].id,
            contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid,
            ShareType = 'I',
            Visibility = 'AllUsers' 
        );
        insert contentlink;
        */
        
        Attachments_Plus__c attPlus = new Attachments_Plus__c(
            Attachment_ID__c = att.Id, 
            Attachment_Name__c = 'test att name', 
            //Attachment_URL__c, 
            Description__c = 'test desc', 
            //Object__c, 
            //Record_ID__c = cm.Id,
            Registration__c = lregList[0].Id,
            Registration_Document_Category__c = 'Education', 
            Type__c = '', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true
        );
        insert attPlus;
        
        
        
        Attachments_Plus__c attPlus1 = new Attachments_Plus__c(
            Attachment_ID__c = att.Id, 
            Attachment_Name__c = 'test att name', 
            //Attachment_URL__c, 
            Description__c = 'test desc', 
            //Object__c, 
            //Record_ID__c = cm.Id, 
            Registration__c = lregList[0].Id,
            Registration_Document_Category__c = 'Education', 
            Type__c = 'Unknown', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true
        );
        insert attPlus1;
        
        
        Attachments_Plus__c attPlus2 = new Attachments_Plus__c(
            Attachment_ID__c = att.Id, 
            Attachment_Name__c = 'test att name', 
            //Attachment_URL__c, 
            Description__c = 'test desc', 
            //Object__c, 
            //Record_ID__c = cm.Id,
            Registration__c = lregList[0].Id,
            Registration_Document_Category__c = 'Education',  
            Type__c = 'Subpoena', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true
        );
            
    }
    
    @isTest 
    static void testRegistrationArchiveBatch() {
        // Implement test code
        test.startTest();
        
        String q = 'SELECT Id, ContentDocumentId, ContentDocument.title FROM ContentDocumentLINk' + 
            ' WHERE LINkedEntityId IN (SELECT Id FROM License_Registration__c) LIMIT 10';  
        
        Id tb = Database.executeBatch(new RegistrationArchiveBatch(q));
        test.stopTest();
        
        //verify content doucments title updated
        //List<contentDocument> cdList = [Select Id, Title from ContentDocument];
        //System.assert(cdList[0].Title.startsWithIgnoreCase('!Archived!-'));

    }
    
    @isTest 
    static void ScheduleRegistrationArchiveBatch() {
        test.startTest();
        //Schedule the test Job
        String chron = '0 0 23 * * ?';        
    
        String jobId = System.schedule('ScheduleRegistrationArchiveBatch', chron, new ScheduleRegistrationArchiveBatch());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        //verify the expression are the same
        System.assertEquals(chron, ct.CronExpression);
        
        //verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        test.stopTest();
    }
    

}