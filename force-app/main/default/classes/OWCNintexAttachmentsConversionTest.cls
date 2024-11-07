@isTest
public class OWCNintexAttachmentsConversionTest {
    @isTest
    public static void convertAttachmentsintoFilesTest() {
        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        
        Trigger_Settings__c customSettingObj = new Trigger_Settings__c();
        customSettingObj.Name = 'GenerateFieldHistoryAction';
        customSettingObj.Is_Active__c = true;
        Insert customSettingObj;
        
        Account acc = new Account();
        acc.Name = 'name';
        Insert acc;
        
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
        dc.Employer__c = acc.Id;
        dc.RecordTypeId = RecordTypeId;
        dc.Status__c = 'Under Investigation';
        dc.Assigned_Deputy__c = de.Id;
        dc.DLSE_Program__c = 'BOFE';
        dc.e_Sign_Documents__c = 'SETTLEMENT- WCA 026A,SETTLEMENT- WCA 026B,SETTLEMENT- WCA 026C,DIRCase- 633 055,WCA 055 - Complaint,RELEASE- WCA 023';
        Insert dc;
        
        Attachment attach = new Attachment();
        attach.Name = 'SETTLEMENT- WCA 026A.png';
        attach.ParentId = dc.Id;
        attach.Body = Blob.valueOf('Test Body');
        Insert attach;
    }
}