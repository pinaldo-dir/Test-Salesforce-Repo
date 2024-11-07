@isTest
public class Test_MeetingDetailsController {
    
    @isTest
    public static void testgetMeetingDetails()
    {        
        Trigger_Settings__c caseTriggerSetting = new Trigger_Settings__c(
        Name = 'CaseManagementHistoryConfig',
        Is_Active__c = false
    );
     insert caseTriggerSetting;
     Trigger_Settings__c caseTriggerSetting2 = new Trigger_Settings__c(
         Name = 'DIRCaseAll',
         Is_Active__c = false
     );
     insert caseTriggerSetting2;
     Trigger_Settings__c caseTriggerSetting3 = new Trigger_Settings__c(
         Name = 'CaseRoleAll',
         Is_Active__c = false
     );
     insert caseTriggerSetting3;
     
     Trigger_Settings__c ts = new Trigger_Settings__c(
         Name = 'GenerateFieldHistoryAction',
         Is_Active__c = false
     );
     insert ts;
     
     Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
     
     Office__c office = new Office__c();
     office.Name = 'Lucian832474';
     insert office;
     
     Zip_Code__c zip = new Zip_Code__c();
     zip.Name = '234889';
     insert zip;
     
     Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
     map1.Zip_Code__c = zip.Id;
     map1.Office__c = office.Id;
     
     Account mainA = new Account();
     mainA.Name = 'name';
     mainA.ShippingPostalCode = '234889';
     mainA.Phone='9653472428';
     insert mainA;
     
     Account affA = new Account();
     affA.Name = 'Lucian235432';
     affA.Phone='9653472428';
     
     DIR_Case__c c = new DIR_Case__c();
     c.Employer__c = mainA.Id;
     c.Status__c = 'New';
     c.RecordTypeId = caseRecordTypeId;
     insert c;
     
     Address__c addObj = new Address__c();
     addObj.Entity__c = affA.Id;
     addObj.Active_Location__c = true;
     addObj.Type__c = 'Primary';
     
     Case_Role__c cr = new Case_Role__c();
     cr.Case__c = c.Id;
     System.debug(c.Id);
     cr.Entity__c =mainA.Id;
     cr.Role__c = 'Employer';
     cr.Case_Role_Status__c = 'Active On Case';
     cr.Account_Name__c = mainA.Name;
     insert cr;
     
     Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
     relatedBusinessObj.Business__c = affA.Id;
     relatedBusinessObj.Related_Business__c = mainA.Id;
     relatedBusinessObj.Type__c = 'Alter Ego';
     System.debug('before case role6');  
     
     Hearing__c meet =new Hearing__c();
     meet.Case__c=c.Id;
     meet.Status__c= 'Closed';
     meet.Meeting_Start_Date_Time__c= datetime.newInstance(2014, 9, 15, 12, 30, 0);
     insert meet;
     
     
     Meeting_Participant__c part =new Meeting_Participant__c();
     part.Meeting__c= meet.Id;
     part.Case_Role__c=cr.Id;
     part.Case__c=c.Id;
     insert part;
     
     
     Test.startTest(); 
     MeetingDetailsController.getMeetingDetails();
     Test.stopTest();
     
    }
    
}