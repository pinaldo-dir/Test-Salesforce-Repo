@isTest
public class OWCSaveDraftControllerTest {
    @testSetup static void setUpMethod() {
        Online_Claim_Draft__c owcDraftList = new Online_Claim_Draft__c();
        owcDraftList.Section_Id__c = '1';
        owcDraftList.Draft_JSON__c = 'Test Demo area';
        insert owcDraftList;
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = true
        );
        
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        insert triggerSettings;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
        DIR_Case__c dirCase = new DIR_Case__c(
            RecordTypeId = caseRT.Id,            
            Assigned_Deputy__c = de.Id
        );
        insert dirCase;
    }
    @istest 
    public static void getDraftRecordsTestOne(){
        Online_Claim_Draft__c  owcDraftListGetRecord  = [SELECT Id, Name, Draft_JSON__c, Section_Id__c, Case_Management__c FROM Online_Claim_Draft__c];
        DIR_Case__c getDemoCase = [SELECT Id, Name, Bank__c FROM DIR_Case__c]; 
        String recordId = owcDraftListGetRecord.Id;
        String sectionId = owcDraftListGetRecord.Section_Id__c;
        String caseId = getDemoCase.Id;
        String onlineClaimDetails = owcDraftListGetRecord.Draft_JSON__c;
        Test.startTest();
        OWCSaveDraftController.wrapperMsgObj getReturnRecordIfCase = OWCSaveDraftController.createOWCJSONResponse(onlineClaimDetails,sectionId,recordId);
        Online_Claim_Draft__c getOWCJSONResponseTest = OWCSaveDraftController.getOWCJSONResponse(recordId);
        //Online_Claim_Draft__c getOWCSubmittedResponseDataTest = OWCSaveDraftController.getOWCSubmittedJSONResponse(caseId);
        Test.stopTest();
        System.assert(getOWCJSONResponseTest != Null);
        //System.assert(getOWCSubmittedResponseDataTest != Null);
        System.assert(getReturnRecordIfCase != Null);
    }
    @istest 
    public static void getDraftRecordsTestTwo(){
        Online_Claim_Draft__c  owcDraftListGetRecord  = [SELECT Id, Name, Draft_JSON__c, Section_Id__c, Case_Management__c FROM Online_Claim_Draft__c];
        DIR_Case__c getDemoCase = [SELECT Id, Name, Bank__c FROM DIR_Case__c]; 
        String recordIdNull = Null;
        String sectionId = owcDraftListGetRecord.Section_Id__c;
        String caseId = getDemoCase.Id;
        String onlineClaimDetails = owcDraftListGetRecord.Draft_JSON__c;
        Test.startTest();
        OWCSaveDraftController.wrapperMsgObj getReturnRecordElseCase = OWCSaveDraftController.createOWCJSONResponse(onlineClaimDetails,sectionId,recordIdNull);
        Test.stopTest();
        System.assert(getReturnRecordElseCase != Null);
    }
}