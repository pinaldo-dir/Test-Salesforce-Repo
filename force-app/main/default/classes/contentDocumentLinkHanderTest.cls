@istest
private class contentDocumentLinkHanderTest {

    private static testmethod void CDLInsertTest(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = true
        );
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;
        
        Account objAccount = new Account(
                                    Name = 'test acct 123',
                                    Legal_Entity_Name__c = 'test acct 123',
                                    ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
                                    ShippingCity = 'Denver',
                                    ShippingState = 'CO',
                                    ShippingPostalCode = '80212' 
                                );
        insert objAccount;
        
        Contact objContact = new Contact(LastName ='testCon',AccountId = objAccount.Id,Email = 'test@test.com');
        insert objContact;  
        
        License_Registration__c objLR = new License_Registration__c(
                                                                    Account__c = objAccount.Id,
                                                                    License_Registration_Number__c = '222',
                                                                    License_Registration_Type__c = 'Car Wash',
                                                                    Status__c = 'Incomplete',
                                                                    Expiration_Date__c = Date.today(), 
                                                                    Mailing_Country__c = 'United States of America',
                                                                    Physical_Business_Country__c = 'United States of America',
                                                                    Effective_Date__c = Date.today(),
                                                                    Amount_Paid__c = 100, 
                                                                    Applicant__c = objContact.Id,
                                                                    RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId()
                                                                    );
                                                                    
        insert objLR;
        
        Attachments_Plus__c aPlus = new Attachments_Plus__c(
            Registration__c = objLR.Id,
            Attachment_Name__c = 'lrdoc',
            Attachment_Required__c = True
        );
        
        insert aPlus;
        
        Attachments_Plus__c aPlus1 = new Attachments_Plus__c(
            Registration__c = objLR.Id,
            Attachment_Name__c = 'lrdoc',
            Attachment_Required__c = False
        );
        
        insert aPlus1;
        
        ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            //content.LinkedEntityId=sub.id;
            content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=aPlus.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'V';            
        
        ContentVersion content1=new ContentVersion(); 
            content1.Title='Header_Picture1'; 
            content1.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob2=Blob.valueOf('Unit Test ContentVersion Body'); 
            content1.VersionData=bodyBlob2; 
            //content.LinkedEntityId=sub.id;
            content1.origin = 'H';
        insert content1;
        
        ContentDocumentLink contentlink1=new ContentDocumentLink();
            contentlink1.LinkedEntityId=aPlus1.id;
            contentlink1.contentdocumentid=[select contentdocumentid from contentversion where id =: content1.id].contentdocumentid;
            contentlink1.ShareType = 'V';
        
        test.startTest();
        insert contentLink;
        insert contentlink1;
        
        License_Registration__c lr = [SELECT ID, Number_of_Attachments__c, Number_of_attachments_Required__c from License_Registration__c WHERE Id = :objlr.Id Limit 1 ];
        //system.assert(lr.Number_of_Attachments_Required__c == 1);
        //system.assert(lr.Number_of_Attachments__c == 1);
        
        delete contentLink;
        
        License_Registration__c lr1 = [SELECT ID, Number_of_Attachments__c, Number_of_attachments_Required__c from License_Registration__c WHERE Id = :objlr.Id Limit 1 ];
        //system.assert(lr1.Number_of_Attachments_Required__c == 1);
        //system.assert(lr1.Number_of_Attachments__c == 0);
        test.stopTest();
        
    }
    @IsTest
    public static void testAttachmentCaseThirdParty(){
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c cpTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        triggerSettings.add(cpTriggerSetting);
        
        Trigger_Settings__c lpTriggerSetting = new Trigger_Settings__c(
            Name = 'liabilityPaymentTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(lpTriggerSetting);

        Trigger_Settings__c dlrs_prTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_Payment_RecordTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_prTriggerSetting);

        Trigger_Settings__c dlrs_judgementTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_JudgementTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_judgementTriggerSetting);

        Trigger_Settings__c dlrs_DIR_ViolationTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = true
        );
        triggerSettings.add(dlrs_DIR_ViolationTriggerSetting);

        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = true
        );
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;


        History_Object_Configuration__c hoc = new History_Object_Configuration__c(
            Object_name__c = 'Case Violation',
            Object_API_Name__c = 'DIR_Violation__c',
            Active__c = true,
            Path_to_Case__c = 'Case__r'
        );
        insert hoc;

        //Create case record
        DIR_Case__c caseObj = new DIR_Case__c();
        caseObj.Status__c = 'New';
        insert caseObj;
        
        //Create attachment new record
        Attachments_New__c attachPlusObj = new Attachments_New__c();
        attachPlusObj.Related_Id__c = caseObj.Id;
        attachPlusObj.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"File_Name"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        attachPlusObj.File_Name__c = 'Wage Claim Summary Report';
        attachPlusObj.File_Type__c = 'Intake';
        insert attachPlusObj;
        
        ContentVersion contentObj=new ContentVersion(); 
        contentObj.Title='Wage Claim Summary Report'; 
        contentObj.Description = 'Third Party';
        contentObj.PathOnClient='/' + contentObj.Title + '.pdf'; 
        Blob bodyBlob1=Blob.valueOf('Unit Test ContentVersion Body'); 
        contentObj.VersionData=bodyBlob1; 
        //content.LinkedEntityId=sub.id;
        contentObj.origin = 'H';
        insert contentObj;
        
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=attachPlusObj.id;
        contentlink2.contentdocumentid=[select contentdocumentid from contentversion where id =: contentObj.id].contentdocumentid;
        contentlink2.ShareType = 'V';
        
        Test.startTest();
        insert contentlink2;
        Test.stopTest();
        
    }
    @IsTest
    public static void testAttachmentCase(){
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c cpTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        triggerSettings.add(cpTriggerSetting);
        
        Trigger_Settings__c lpTriggerSetting = new Trigger_Settings__c(
            Name = 'liabilityPaymentTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(lpTriggerSetting);

        Trigger_Settings__c dlrs_prTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_Payment_RecordTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_prTriggerSetting);

        Trigger_Settings__c dlrs_judgementTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_JudgementTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_judgementTriggerSetting);

        Trigger_Settings__c dlrs_DIR_ViolationTriggerSetting = new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = true
        );
        triggerSettings.add(dlrs_DIR_ViolationTriggerSetting);

        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = true
        );
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;


        History_Object_Configuration__c hoc = new History_Object_Configuration__c(
            Object_name__c = 'Case Violation',
            Object_API_Name__c = 'DIR_Violation__c',
            Active__c = true,
            Path_to_Case__c = 'Case__r'
        );
        insert hoc;

        //Create case record
        DIR_Case__c caseObj = new DIR_Case__c();
        caseObj.Status__c = 'New';
        insert caseObj;
        
        //Create attachment new record
        Attachments_New__c attachPlusObj = new Attachments_New__c();
        attachPlusObj.Related_Id__c = caseObj.Id;
        attachPlusObj.APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"","fieldName":"File_Name","fieldAPIName":"File_Name"},{"value":"Third Party","fileType":"","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]';
        attachPlusObj.File_Name__c = 'Wage Claim Summary Report';
        attachPlusObj.File_Type__c = 'Intake';
        insert attachPlusObj;
        
        ContentVersion contentObj=new ContentVersion(); 
        contentObj.Title='Wage Claim Summary Report'; 
        contentObj.Description = 'Intake';
        contentObj.PathOnClient='/' + contentObj.Title + '.pdf'; 
        Blob bodyBlob1=Blob.valueOf('Unit Test ContentVersion Body'); 
        contentObj.VersionData=bodyBlob1; 
        //content.LinkedEntityId=sub.id;
        contentObj.origin = 'H';
        insert contentObj;
        
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=attachPlusObj.id;
        contentlink2.contentdocumentid=[select contentdocumentid from contentversion where id =: contentObj.id].contentdocumentid;
        contentlink2.ShareType = 'V';
        
        Test.startTest();
        insert contentlink2;
        Test.stopTest();
        
    }
}