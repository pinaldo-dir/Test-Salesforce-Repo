@IsTest
public class OWCUpdateAPlusSubDetailTest {
    @IsTest
    public static void testAPlusSubDetail(){
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'PAGA_Case' AND IsActive = true LIMIT 1];
        List<Trigger_Settings__c> triggerSetting = OWCTestDataFactory.createTriggerCustomSettingRecord();
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        DIR_Case__c objCase = new DIR_Case__c(Employer__c = objAccount.Id, RecordTypeId = caseRT.Id);
        insert objCase;
        
        
        Attachments_New__c objAttachment = new Attachments_New__c(File_Name__c = 'Test',
                                                                  File_Type__c = 'Other PAGA Document',
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
        
        List<Attachments_Plus__c> attachPlusList = new List<Attachments_Plus__c>();
        Attachments_Plus__c attachPlusObj = new Attachments_Plus__c();
        attachPlusObj.Account__c = objAccount.Id;
        attachPlusObj.Case_Management__c = objCase.Id;
        attachPlusObj.Confidential__c = true;
        attachPlusObj.Attorney_Client_Privilege__c = true;
        attachPlusObj.Confidential__c = true;
        attachPlusList.add(attachPlusObj);
        
        if(attachPlusList.size() > 0){
            insert attachPlusList;
        }
        
        ContentDocumentLink objCDLs = new ContentDocumentLink( ContentDocumentId = cdId,
                                                             ShareType = 'I',
                                                             LinkedEntityId = [SELECT Id FROM Attachments_Plus__c LIMIT 1].Id);
        insert objCDLs;
        
        Test.startTest();
        OWCUpdateAPlusSubDetail.updateAPlusSubDetail(attachPlusList);
        Test.stopTest();
    }
}