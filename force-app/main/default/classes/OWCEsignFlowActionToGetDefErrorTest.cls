@isTest
public class OWCEsignFlowActionToGetDefErrorTest {
    
    @testSetup
    public static void setupData(){
        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        
        Account employerAccount = new Account();
        employerAccount.Name = 'Big Mega General Corp';
        employerAccount.ShippingStreet = '123 Sesame Street';
        employerAccount.ShippingCity = 'New York';
        employerAccount.ShippingState = 'NY';
        employerAccount.ShippingPostalCode = '01234';
        insert employerAccount;
        
        Trigger_Settings__c customSettingObj = new Trigger_Settings__c();
        customSettingObj.Name = 'GenerateFieldHistoryAction';
        customSettingObj.Is_Active__c = true;
        Insert customSettingObj;
        
        DIR_Employee__c mgr = new DIR_Employee__c();
        mgr.User__c = userinfo.getuserid();
        mgr.Active__c = true;
        mgr.Email__c = 'mgr@test.com';
        mgr.Phone__c = '2223335555';
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = userinfo.getuserid();
        de.Active__c = true;
        de.Email__c = 'dep@test.com';
        de.Phone__c = '2223335555';
        de.Manager__c = mgr.id;
        insert de;
        
        DIR_Case__c dc = new DIR_Case__c();
        dc.Employer__c = employerAccount.Id;
        dc.RecordTypeId = RecordTypeId;
        dc.Status__c = 'Under Investigation';
        dc.Assigned_Deputy__c = de.Id;
        dc.DLSE_Program__c = 'BOFE';
        dc.e_Sign_Documents__c = 'SETTLEMENT- WCA 026A,SETTLEMENT- WCA 026B,SETTLEMENT- WCA 026C,DIRCase- 633 055,WCA 055 - Complaint,RELEASE- WCA 023';
        Insert dc;
        
        Case_Role__c crObj = new Case_Role__c();
        crObj.Entity__c = employerAccount.Id;
        crObj.Case__c = dc.Id;
        Insert crObj;
    }
    
    @isTest
    public static void getDefendantsWithErrorTest() {
        List<Case_Role__c> crList = [SELECT Id FROM Case_Role__c LIMIT 1];
        Test.startTest();
        OWCEsignFlowActionToGetDefendantsError.getDefendantsWithError(new List<String>{crList[0].Id});
        Test.stopTest();
    }
}