@isTest
private class DIR_ContentDocumentLink_Test {
    private static testMethod void testContentDocumentLink() {
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
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        DIR_Case__c objCase = new DIR_Case__c(Employer__c = objAccount.Id);
        insert objCase;
         

        Attachments_New__c objAttachment = new Attachments_New__c(File_Name__c = 'Test',
                                                                  File_Type__c = 'Test',
                                                                  Related_Id__c = objCase.Id);
        insert  objAttachment;
        
        ContentVersion conVer = new ContentVersion( ContentLocation = 'S',
                                                    PathOnClient = 'Test',
                                                    Title = 'test',
                                                    VersionData = EncodingUtil.base64Decode('Test'),
                                                    Origin = 'C');
       insert conVer;
       
       String cdId = [SELECT id, ContentDocumentId 
                      FROM ContentVersion 
                      WHERE id = :conVer.id].ContentDocumentId;
                      
       ContentDocumentLink objCDL = new ContentDocumentLink( ContentDocumentId = cdId,
                                                              ShareType = 'I',
                                                              LinkedEntityId = objAttachment.id);
        
        insert objCDL;
        
        try{
            delete objCase;
        }
        catch(Exception ex){
            
        }
        
        try{
            delete objAttachment;
        }
        catch(Exception ex){
            system.assertEquals(ex.getMessage().contains('Only system administrators can delete historical attachments.'),true);
        }
        
        try{
            delete objCDL;
        }
        catch(Exception ex){
            
        }
        
        try{
            delete new ContentDocument(Id = cdId);
        }
        catch(Exception ex){
            
        }
        
        

    }
}