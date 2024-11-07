@isTest
public class OWCSubmitClaimContainerControllerTest {
    @testSetup static void setUpMethod() {
        String before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        //Insert contentdocument data
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;         
        
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
            Assigned_Deputy__c = de.Id,
            Status__c = 'Not Confirmed'
        );
        insert dirCase;
    }
    @istest 
    public static void testOWCSubmitClaimContainerControllerOne(){
        DIR_Case__c getDemoCase = [SELECT Id, Name, Bank__c,Status__c FROM DIR_Case__c];
        ContentVersion contentVersionData = [SELECT Id, Title, PathOnClient, ContentUrl FROM ContentVersion];
        List<string> contentIds =new List<string>();
        contentIds.add(contentVersionData.Id);
        Id recordId = getDemoCase.Id;
        Test.startTest();
        DIR_Case__c getDemoCaseRecord = OWCSubmitClaimContainerController.getSubmitClaimConfirmation(recordId);
        boolean getDemoComfiramtionRecord = OWCSubmitClaimContainerController.submitClaimantConfirmationRecords(contentIds,recordId);
        Test.stopTest();
        System.assert(getDemoComfiramtionRecord == true);
    }
    @IsTest
    public static void testExceptionBlock(){
        DIR_Case__c getDemoCase = [SELECT Id, Name, Bank__c,Status__c FROM DIR_Case__c];
        Account objAcct2 = new Account(Name = 'Company XYZ',
                                       ShippingCity = 'Austin',
                                       ShippingState = 'CA',
                                       ShippingPostalCode = '78751',
                                       ShippingStreet = '321 Industrial Drive'); 
        Test.startTest();
        try{
            OWCSubmitClaimContainerController.getSubmitClaimConfirmation(objAcct2.Id);
        }
        catch(Exception ex){
            
        }
        Test.stopTest();
    }
}