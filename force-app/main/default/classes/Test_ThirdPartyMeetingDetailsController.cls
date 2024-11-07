@isTest
public class Test_ThirdPartyMeetingDetailsController {
   
    @istest
    public static void testThirdPartyMeetingDetailsController(){
        
        List<Trigger_Settings__c> triggerSettings = OWCTestDataFactory.createTriggerCustomSettingRecord();
       
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        
        User commUserObj = OWCTestDataFactory.createCommunityUserAccount();
               
        String communityUserId = [SELECT accountId FROM User WHERE email='test123@noemail.com'].accountId;
        
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
        mainA.FirstName = 'Right';
        mainA.LastName = 'Cow';
        mainA.ShippingPostalCode = '234889';
        mainA.Phone='9653472428';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        affA.Phone='9653472428';
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.Online_Claim_Account__c = communityUserId;
        c.RecordTypeId = caseRecordTypeId;
        insert c;
        
        Address__c addObj = new Address__c();
        addObj.Entity__c = affA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        
        System.debug('account Id community ::: '+communityUserId);
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = c.Id;
        System.debug(c.Id);
        cr.Entity__c =mainA.Id;
        cr.Role__c = 'Claimant';
        cr.Community_User_Account__c = communityUserId;
        cr.Case_Role_Status__c = 'Active On Case';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        System.debug('Case role ::: '+[SELECT Community_User_Account__c, Id, Case__c, Entity__r.LastName, Role__c, Case__r.Case_Number__c FROM Case_Role__c WHERE Role__c = 'Claimant' AND Case_Role_Status__c = 'Active On Case'].Community_User_Account__c);
        
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
        
        System.debug('meet Id ::: '+meet.Id);
        
        Case_Role__c caseRoleObj = [SELECT Community_User_Account__c, Id, Case__c, Entity__r.LastName, Role__c, Case__r.Case_Number__c FROM Case_Role__c WHERE Id =: cr.Id AND Role__c = 'Claimant' AND Case_Role_Status__c = 'Active On Case' LIMIT 1];
        
        meetingResponseWrapper meetingWrapperObj = new meetingResponseWrapper();
        meetingWrapperObj.caseNumber = caseRoleObj.Case__r.Case_Number__c;
        meetingWrapperObj.claimantLastName = caseRoleObj.Entity__r.LastName;
        meetingWrapperObj.communityUserId = commUserObj.Id;
        Test.startTest();
        String myJSON = JSON.serialize(meetingWrapperObj);
		

        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='https://wc-thirdparty-upload-api-1-0-uat.usg-w1.gov.cloudhub.io/api/hearingdetail';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
		request.requestBody = Blob.valueof(myJSON);
		
        RestContext.request = request;
        RestContext.response = res;
		ThirdPartyMeetingDetailsWebService.getHearingDetails();
        
        ThirdPartyMeetingDetailsController.getMeetingDetails(commUserObj.Id, caseRoleObj.Entity__r.LastName, caseRoleObj.Case__r.Case_Number__c);
        System.runAs(commUserObj){
            ThirdPartyMeetingDetailsWebService.getHearingDetails();
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void testMeetingDetailValidation(){
        List<Trigger_Settings__c> triggerSettings = OWCTestDataFactory.createTriggerCustomSettingRecord();
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        
        User commUserObj = OWCTestDataFactory.createCommunityUserAccount();
        
        String communityUserId = [SELECT accountId FROM User WHERE email='test123@noemail.com'].accountId;
        
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
        mainA.FirstName = 'Right';
        mainA.LastName = 'Cow';
        mainA.ShippingPostalCode = '234889';
        mainA.Phone='9653472428';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        affA.Phone='9653472428';
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.Online_Claim_Account__c = communityUserId;
        c.RecordTypeId = caseRecordTypeId;
        insert c;
        
        Address__c addObj = new Address__c();
        addObj.Entity__c = affA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        
        System.debug('account Id community ::: '+communityUserId);
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = c.Id;
        System.debug(c.Id);
        cr.Entity__c =mainA.Id;
        cr.Role__c = 'Claimant';
        cr.Community_User_Account__c = communityUserId;
        cr.Case_Role_Status__c = 'Active On Case';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        System.debug('Case role ::: '+[SELECT Community_User_Account__c, Id, Case__c, Entity__r.LastName, Role__c, Case__r.Case_Number__c FROM Case_Role__c WHERE Role__c = 'Claimant' AND Case_Role_Status__c = 'Active On Case'].Community_User_Account__c);
        
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
        
        System.debug('meet Id ::: '+meet.Id);
        
        Case_Role__c caseRoleObj = [SELECT Community_User_Account__c, Id, Case__c, Entity__r.LastName, Role__c, Case__r.Case_Number__c FROM Case_Role__c WHERE Id =: cr.Id AND Role__c = 'Claimant' AND Case_Role_Status__c = 'Active On Case' LIMIT 1];
        
        meetingResponseWrapper meetingWrapperObj = new meetingResponseWrapper();
        meetingWrapperObj.caseNumber = '12';
        meetingWrapperObj.claimantLastName = caseRoleObj.Entity__r.LastName;
        meetingWrapperObj.communityUserId = commUserObj.Id;
        Test.startTest();
        String myJSON = JSON.serialize(meetingWrapperObj);
        
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='https://wc-thirdparty-upload-api-1-0-uat.usg-w1.gov.cloudhub.io/api/hearingdetail';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        RestContext.response = res;
        ThirdPartyMeetingDetailsWebService.getHearingDetails();
        
        //ThirdPartyMeetingDetailsController.getMeetingDetails(commUserObj.Id, caseRoleObj.Entity__r.LastName, caseRoleObj.Case__r.Case_Number__c);
        Test.stopTest();
    }

	@IsTest
    public static void testMeetingDetailValidation1(){
        List<Trigger_Settings__c> triggerSettings = OWCTestDataFactory.createTriggerCustomSettingRecord();
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        
        User commUserObj = OWCTestDataFactory.createCommunityUserAccount();
        
        String communityUserId = [SELECT accountId FROM User WHERE email='test123@noemail.com'].accountId;
        
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
        mainA.FirstName = 'Right';
        mainA.LastName = 'Cow';
        mainA.ShippingPostalCode = '234889';
        mainA.Phone='9653472428';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        affA.Phone='9653472428';
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.Online_Claim_Account__c = communityUserId;
        c.RecordTypeId = caseRecordTypeId;
        insert c;
        
        Address__c addObj = new Address__c();
        addObj.Entity__c = affA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        
        System.debug('account Id community ::: '+communityUserId);
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = c.Id;
        System.debug(c.Id);
        cr.Entity__c =mainA.Id;
        cr.Role__c = 'Claimant';
        cr.Community_User_Account__c = communityUserId;
        cr.Case_Role_Status__c = 'Active On Case';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        System.debug('Case role ::: '+[SELECT Community_User_Account__c, Id, Case__c, Entity__r.LastName, Role__c, Case__r.Case_Number__c FROM Case_Role__c WHERE Role__c = 'Claimant' AND Case_Role_Status__c = 'Active On Case'].Community_User_Account__c);
        
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
        
        System.debug('meet Id ::: '+meet.Id);
        
        Case_Role__c caseRoleObj = [SELECT Community_User_Account__c, Id, Case__c, Entity__r.LastName, Role__c, Case__r.Case_Number__c FROM Case_Role__c WHERE Id =: cr.Id AND Role__c = 'Claimant' AND Case_Role_Status__c = 'Active On Case' LIMIT 1];
        
        meetingResponseWrapper meetingWrapperObj = new meetingResponseWrapper();
        meetingWrapperObj.caseNumber = caseRoleObj.Case__r.Case_Number__c;
        meetingWrapperObj.claimantLastName = 'test12';
        meetingWrapperObj.communityUserId = commUserObj.Id;
        Test.startTest();
        String myJSON = JSON.serialize(meetingWrapperObj);
        
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='/services/apexrest/Lead/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        RestContext.response = res;
        
        ThirdPartyMeetingDetailsWebService.getHearingDetails();
        
        //ThirdPartyMeetingDetailsController.getMeetingDetails(commUserObj.Id, caseRoleObj.Entity__r.LastName, caseRoleObj.Case__r.Case_Number__c);
        Test.stopTest();
    }
    
    public class meetingResponseWrapper{
        public string caseNumber{get;set;}
        public string claimantLastName{get;set;}
        public string communityUserId{get;set;}
    }
}