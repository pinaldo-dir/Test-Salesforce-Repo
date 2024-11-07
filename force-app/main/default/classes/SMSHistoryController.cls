public with sharing class SMSHistoryController {
    @AuraEnabled
    public static Map<String,Object> getSMSDetails(String recordId){
        Map<String,Object> response = new Map<String,Object>();
        
        Set<Id> smsToGetIds = new Set<Id>();
        for(Meeting_Participant__c participant : [SELECT Id,Name_of_Attendee__c,Case_Role__c FROM Meeting_Participant__c
        WHERE Meeting__r.Case__c =:recordId AND Case_Role__c!=NULL]){
            smsToGetIds.add(participant.Id);
            smsToGetIds.add(participant.Case_Role__c);
        }
        for(Case_Role__c caseRole : [SELECT Id FROM Case_Role__c WHERE Case__c =:recordId]){
            smsToGetIds.add(caseRole.Id);
        }
        if(!smsToGetIds.isEmpty()){
            Map<String,Map<String,List<SMSDetails>>> smsByParticipant = new Map<String,Map<String,List<SMSDetails>>>();
            Map<String,List<SMSDetails>> caseRoleSMS = new Map<String,List<SMSDetails>>();
            for(smagicinteract__smsMagic__c sms : [SELECT Id, meeting_participant__c, meeting_participant__r.Name,
                                                   smagicinteract__SMSText__c,
                                                   smagicinteract__Direction__c,
                                                   meeting_participant__r.Meeting__r.Name,
                                                   meeting_participant__r.Meeting__r.Record_Type_Name__c,
                                                   meeting_participant__r.Name_of_Attendee__c,
                                                    meeting_participant__r.Case_Role__r.Role__c ,Case_Role__c,
                                                    Case_Role__r.Role__c,Case_Role__r.Case_Role_Account_Name__c,CreatedDate
                                                   FROM smagicinteract__smsMagic__c
                                                   WHERE meeting_participant__c IN :smsToGetIds OR Case_Role__c IN :smsToGetIds ORDER BY CreatedDate DESC]){
                SMSDetails details = new SMSDetails();
                details.sms = sms;
                if(String.isNotBlank(sms.meeting_participant__c)){
                    String role = sms.meeting_participant__r.Case_Role__r.Role__c;
                    String key1 = sms.meeting_participant__r.Name_of_Attendee__c+'-'+role;
                    String key2 = sms.meeting_participant__r.Meeting__r.Name+'-'+sms.meeting_participant__r.Meeting__r.Record_Type_Name__c;
                    if(!smsByParticipant.containsKey(key1)){
                        smsByParticipant.put(key1,new Map<String,List<SMSDetails>>());
                    }
                    if(String.isNotBlank(sms.meeting_participant__c) && !smsByParticipant.get(key1).containsKey(key2)){
                        smsByParticipant.get(key1).put(key2,new List<SMSDetails>());
                    }
                    smsByParticipant.get(key1).get(key2).add(details);
                }else if(String.isNotBlank(sms.Case_Role__c)){
                    String role = sms.Case_Role__r.Role__c;
                    String key1 = sms.Case_Role__r.Case_Role_Account_Name__c+'-'+role;
                    if(!caseRoleSMS.containsKey(key1)){
                        caseRoleSMS.put(key1, new List<SMSDetails>());
                    }
                    caseRoleSMS.get(key1).add(details);
                }
             }
             response.put('records',smsByParticipant);
             response.put('caseRoleSMS',caseRoleSMS);
        }
        return response;
    }

    public class SMSDetails{
        @AuraEnabled
        public  smagicinteract__smsMagic__c sms;

        @AuraEnabled
        public  Meeting_Participant__c participant;
    }
    
    public static smagicinteract__Consent__c optOut(String phone, Id recordId){
        //smagicinteract__Channel_Master__c channel = [SELECT Id, Name FROM smagicinteract__Channel_Master__c WHERE Name = 'SMS'];
		if(!phone.startsWith('1')){
            phone += '1'+phone;
        }
        smagicinteract__Consent__c consent = new smagicinteract__Consent__c();
        consent.smagicinteract__Compliance_Status__c = 'Opt-Out';
        consent.Name = phone;
        //consent.smagicinteract__SenderId__c = Label.Owc_Sender_Id;
        consent.smagicinteract__Do_Not_Send_Confirmation__c = true;
        consent.smagicinteract__Error_Message__c = 'sender-id: None does not exist';
        consent.smagicinteract__External_Key__c = phone;
        consent.smagicinteract__Send_Confirmation_Message__c = false;
        consent.smagicinteract__Source__c = 'Non-Handset';
        consent.smagicinteract__Account__c = recordId;
        consent.smagicinteract__Action_Type__c = 'Opt-Out';
        return consent;
    }
    
    public static smagicinteract__Consent__c textMessageConsent(String phone, Id recordId, String status, Boolean isNew){
        
        system.debug('phone sms: '+phone);
        //smagicinteract__Channel_Master__c channel = [SELECT Id, Name FROM smagicinteract__Channel_Master__c WHERE Name = 'SMS'];
        smagicinteract__Consent__c consent = new smagicinteract__Consent__c();
        consent.smagicinteract__Compliance_Status__c = status;
        consent.Name = phone;
        //consent.smagicinteract__SenderId__c = Label.Owc_Sender_Id;
        consent.smagicinteract__Do_Not_Send_Confirmation__c = true;
        consent.smagicinteract__Error_Message__c = 'sender-id: None does not exist';
        consent.smagicinteract__External_Key__c = phone;
        consent.smagicinteract__Send_Confirmation_Message__c = false;
        consent.smagicinteract__Source__c = 'Non-Handset';
        if(isNew){
            consent.smagicinteract__Account__c = recordId;
        }
        consent.smagicinteract__Action_Type__c = status;
        return consent;
    }
    public static smagicinteract__Consent__c optOut1(String phone, Id recordId){
        //smagicinteract__Channel_Master__c channel = [SELECT Id, Name FROM smagicinteract__Channel_Master__c WHERE Name = 'SMS'];
        smagicinteract__Consent__c consent = new smagicinteract__Consent__c();
        consent.smagicinteract__Compliance_Status__c = 'Opt-Out';
        consent.Name = phone;
        //consent.smagicinteract__SenderId__c = Label.Owc_Sender_Id;
        consent.smagicinteract__Do_Not_Send_Confirmation__c = true;
        consent.smagicinteract__Error_Message__c = 'sender-id: None does not exist';
        consent.smagicinteract__External_Key__c = phone;
        consent.smagicinteract__Send_Confirmation_Message__c = false;
        consent.smagicinteract__Source__c = 'Non-Handset';
        consent.smagicinteract__Account__c = recordId;
        consent.smagicinteract__Action_Type__c = 'Opt-Out';
        return consent;
    }
    public static smagicinteract__Consent__c optOut2(String phone, Id recordId){
        //smagicinteract__Channel_Master__c channel = [SELECT Id, Name FROM smagicinteract__Channel_Master__c WHERE Name = 'SMS'];
        smagicinteract__Consent__c consent = new smagicinteract__Consent__c();
        consent.smagicinteract__Compliance_Status__c = 'Opt-Out';
        consent.Name = phone;
        //consent.smagicinteract__SenderId__c = Label.Owc_Sender_Id;
        consent.smagicinteract__Do_Not_Send_Confirmation__c = true;
        consent.smagicinteract__Error_Message__c = 'sender-id: None does not exist';
        consent.smagicinteract__External_Key__c = phone;
        consent.smagicinteract__Send_Confirmation_Message__c = false;
        consent.smagicinteract__Source__c = 'Non-Handset';
        consent.smagicinteract__Account__c = recordId;
        consent.smagicinteract__Action_Type__c = 'Opt-Out';
        return consent;
    }
    public static smagicinteract__Consent__c optOut3(String phone, Id recordId){
        //smagicinteract__Channel_Master__c channel = [SELECT Id, Name FROM smagicinteract__Channel_Master__c WHERE Name = 'SMS'];
        smagicinteract__Consent__c consent = new smagicinteract__Consent__c();
        consent.smagicinteract__Compliance_Status__c = 'Opt-Out';
        consent.Name = phone;
        //consent.smagicinteract__SenderId__c = Label.Owc_Sender_Id;
        consent.smagicinteract__Do_Not_Send_Confirmation__c = true;
        consent.smagicinteract__Error_Message__c = 'sender-id: None does not exist';
        consent.smagicinteract__External_Key__c = phone;
        consent.smagicinteract__Send_Confirmation_Message__c = false;
        consent.smagicinteract__Source__c = 'Non-Handset';
        consent.smagicinteract__Account__c = recordId;
        consent.smagicinteract__Action_Type__c = 'Opt-Out';
        return consent;
    }
}