public class HearingTriggerHandler{
    public static string orgwideDefaultId = OWCConstants.orgWideDefaultId;	
    public static void updateMeetingParticipants(List<Hearing__c> newList){
        Map<Id,Id> caseIdMap = new Map<Id,Id>();
        Map<Id,String> recordTypeIdMap = new Map<Id,String>();
        for(Hearing__c h : newList){
            caseIdMap.put(h.Case__c, h.id);
            recordTypeIdMap.put(h.id,h.Record_Type_Name__c);
        }
        
        List<Meeting_Participant__c> mps = new List<Meeting_Participant__c>();
        for(DIR_Case__c c : [select id, (select id from Case_Roles__r where Case_Role_Status__c = 'Active') from DIR_Case__c where Id IN :caseIdMap.keySet()]){
            if(c.Case_Roles__r != null){
                for(Case_Role__c cr : c.Case_Roles__r){
                    Meeting_Participant__c mp = new Meeting_Participant__c();
                    if(recordTypeIdMap.get(caseIdMap.get(c.Id)).contains('Conference'))
                       mp.RecordTypeId = Schema.SObjectType.Meeting_Participant__c.getRecordTypeInfosByName().get('Conference').getRecordTypeId(); 
                       mp.Attendance__c = 'Invited';
                       mp.Case__c = c.id;
                       mp.Case_Role__c = cr.id;
                       mp.Meeting__c = caseIdMap.get(c.id);
                       mps.add(mp);
                    
                }
            }
        }
        if(mps.size() > 0){
            insert mps;
        }
    }

    public static void sendSMSToMeetingParticipants(List<Hearing__c> newHearings,Map<Id,Hearing__c> oldHearings){
        System.debug('inside sendSMSToMeetingParticipants');
        Set<Id> meetingIds = new Set<Id>();
        Id conferenceRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('Conference').getRecordTypeId();
        Id garmentConferenceRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('Garment Conference').getRecordTypeId();
        Id garmentHearingRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('Garment Hearing').getRecordTypeId();
        Id wcaHearingRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('WCA Hearing').getRecordTypeId();

        for(Hearing__c hearing : newHearings){
            Hearing__c oldHearing = oldHearings.get(hearing.Id);
            if((hearing.RecordTypeId != oldHearing.RecordTypeId) || (hearing.Meeting_Start_Date_Time__c!= oldHearing.Meeting_Start_Date_Time__c) || (hearing.Status__c != oldHearing.Status__c) && (hearing.RecordTypeId == conferenceRecordTypeId || hearing.RecordTypeId == garmentConferenceRecordTypeId || hearing.RecordTypeId == garmentHearingRecordTypeId || hearing.RecordTypeId == wcaHearingRecordTypeId) && (/* hearing.Status__c == 'Scheduled' ||*/ hearing.Status__c == 'Rescheduled') && hearing.Meeting_Start_Date_Time__c != null ){
                       meetingIds.add(hearing.Id);
            }
        }
        System.debug('inside meetingIds:'+meetingIds);
        List<smagicinteract__smsMagic__c>  smsObjectList = new List<smagicinteract__smsMagic__c> ();
        for(Meeting_Participant__c participant : [SELECT Id,Case_Role__r.Entity__r.PersonMobilePhone,Case_Role__r.Entity__r.Cell_Phone__c,Meeting__c,
                                                  Meeting__r.RecordType.Name, Meeting__r.Meeting_Start_Date__c, Meeting__r.Meeting_Start_Time__c,
                                                  Meeting__r.Record_Type_Name__c,Meeting__r.Status__c,Meeting__r.In_Person_Remote_Meeting__c,Meeting__r.WCA_Office__r.Name,
                                                  Meeting__r.WCA_Office__r.Office_Address_Formula__c,Meeting__r.Meeting_Location__c,SMS_Text__c, Case_Role__r.Interpreter_Language__c,SMS_Spanish_Text__c,
                                                  Case_Role__r.Entity__r.RecordType.Name
                                                  FROM Meeting_Participant__c WHERE Meeting__c IN:meetingIds]){
             String message; 
             if(participant.Case_Role__r.Interpreter_Language__c == 'Spanish'){
            	message = participant.SMS_Spanish_Text__c;     
             }else{
                 message = participant.SMS_Text__c;
             }
             message = message.replaceAll('<br><br>', ' ');
             message = message.replaceAll('<br>', ' ');
             smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
             smsObject.smagicinteract__SenderId__c = Label.Owc_Sender_Id;
             if(participant.Case_Role__r.Entity__r.RecordType.Name == 'Person Account' && String.isNotBlank(participant.Case_Role__r.Entity__r.PersonMobilePhone)){
                 smsObject.smagicinteract__PhoneNumber__c =  participant.Case_Role__r.Entity__r.PersonMobilePhone;
             } else if(String.isNotBlank(participant.Case_Role__r.Entity__r.Cell_Phone__c)) {
                 smsObject.smagicinteract__PhoneNumber__c =  participant.Case_Role__r.Entity__r.Cell_Phone__c;
             }
             //smsObject.smagicinteract__PhoneNumber__c =  ? participant.Case_Role__r.Entity__r.PersonMobilePhone:participant.Case_Role__r.Entity__r.Cell_Phone__c;
             smsObject.smagicinteract__Name__c = 'DIR'; // records name
             smsObject.smagicinteract__ObjectType__c = 'Meeting Participant'; // record type
             smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
             smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
             smsObject.smagicinteract__SMSText__c = message;
             //smsObject.Hearing__c = participant.Meeting__c;
             smsObject.Meeting_Participant__c = participant.Id;
             System.debug('inside smsObject.smagicinteract__PhoneNumber__c:'+smsObject.smagicinteract__PhoneNumber__c);
             System.debug('participant.Case_Role__r.Entity__r.PersonMobilePhone:'+participant.Case_Role__r.Entity__r.PersonMobilePhone);
             System.debug('participant.Case_Role__r.Entity__r.Cell_Phone__c:'+participant.Case_Role__r.Entity__r.Cell_Phone__c);
             if(String.isNotBlank(smsObject.smagicinteract__PhoneNumber__c)){
                 smsObjectList.add(smsObject);                 
             }

        }
        try{
            Database.insert(smsObjectList, false);
        }catch(Exception e){
            System.debug('HearingTriggerHandle sendSMS:'+e.getMessage());
            new OWCServiceUtility().Log(e);
        }	
    }

 /*
    public static void sendEmailNotifications(List<Hearing__c> newHearings,Map<Id,Hearing__c> oldHearings){
        Map<Id,List<Hearing__c>> caseIds = new Map<Id,List<Hearing__c>>();
        Id conferenceRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('Conference').getRecordTypeId();
        Id garmentConferenceRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('Garment Conference').getRecordTypeId();
        Id garmentHearingRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('Garment Hearing').getRecordTypeId();
        Id wcaHearingRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('WCA Hearing').getRecordTypeId();
        Map<Id,Hearing__c> hearingDetails = new Map<Id,Hearing__c>([SELECT Id,WCA_Office__r.Office_Address_Formula__c FROM Hearing__c WHERE Id IN :newHearings]);
        if(oldHearings!=null){
            for(Hearing__c hearing : newHearings){
                Hearing__c oldHearing = oldHearings.get(hearing.Id);
                if( (hearing.RecordTypeId != oldHearing.RecordTypeId) || (hearing.Meeting_Start_Date_Time__c != oldHearing.Meeting_Start_Date_Time__c) || (hearing.Status__c != oldHearing.Status__c) && (hearing.RecordTypeId == conferenceRecordTypeId ||  hearing.RecordTypeId == garmentConferenceRecordTypeId || hearing.RecordTypeId == garmentHearingRecordTypeId ||  hearing.RecordTypeId == wcaHearingRecordTypeId)  && (hearing.Status__c == 'Scheduled' || hearing.Status__c == 'Rescheduled') && hearing.Meeting_Start_Date_Time__c != null ){
                    if(!caseIds.containsKey(hearing.Case__c)){
                        caseIds.put(hearing.Case__c,new List<Hearing__c>());
                    }
                    caseIds.get(hearing.Case__c).add(hearing);
                }
            }
        }
        else{
            for(Hearing__c hearing : newHearings){
                
                if((hearing.RecordTypeId == conferenceRecordTypeId ||  hearing.RecordTypeId == garmentConferenceRecordTypeId ||  hearing.RecordTypeId == garmentHearingRecordTypeId || hearing.RecordTypeId == wcaHearingRecordTypeId) && (hearing.Status__c == 'Scheduled' || hearing.Status__c == 'Rescheduled') && hearing.Meeting_Start_Date_Time__c != null){
                    if(!caseIds.containsKey(hearing.Case__c)){
                        caseIds.put(hearing.Case__c,new List<Hearing__c>());
                    }
                    caseIds.get(hearing.Case__c).add(hearing);
                }
            }
        }
        system.debug('caseIds create: '+caseIds);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Case_Role__c caseRole : [SELECT Id,Case__c,Case__r.Name,Entity__r.RecordType.Name,Entity__r.PersonEmail,Entity__r.Name,Entity__r.Email__c,Interpreter_Language__c FROM Case_Role__c 
                                     WHERE Case__c IN :caseIds.keySet()])
        {
            if (caseRole.Entity__r.Email__c != null || String.isNotBlank(caseRole.Entity__r.PersonEmail)) {
                for(Hearing__c hearing : caseIds.get(caseRole.Case__c)){
                     
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> sendTo = new List<String>();
                    if(String.isNotBlank(caseRole.Entity__r.PersonEmail) && caseRole.Entity__r.RecordType.Name == 'Person Account'){
                        sendTo.add(caseRole.Entity__r.PersonEmail);    
                    }else if(caseRole.Entity__r.RecordType.Name != 'Person Account'){
                        sendTo.add(caseRole.Entity__r.Email__c);
                    }
                    
                    mail.saveAsActivity = true;
                    mail.setWhatId(caseRole.Case__c);
                    if(orgwideDefaultId != null){
                        mail.setOrgWideEmailAddressId(orgwideDefaultId);
                    }
                    mail.setToAddresses(sendTo);
                    mail.setSubject('Meeting Scheduled for ' + caseRole.Case__r.Name);
                    String body = '';
                    if(caseRole.Interpreter_Language__c == 'Spanish'){
                        body += 'Hola '+caseRole.Entity__r.Name+',<br><br>';
                        String status = hearing.Status__c == 'Scheduled' ? 'programada' : 'reprogramado';
                        body += 'Su '+getRecordTypeName(hearing.RecordTypeId)+' reunión está '+status+' para el '+String.valueOf(hearing.Meeting_Start_Date__c.format())+' '+hearing.Meeting_Start_Time__c;
                        body += ', que es una reunión '+hearing.In_Person_Remote_Meeting__c+' meeting,';
                        if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('In Person')){
                            body += ' '+hearingDetails.get(hearing.Id).WCA_Office__r.Office_Address_Formula__c;
                        }else if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('Phone/Remote')){
                            body += ' '+hearing.Audio_telephone__c != null ? hearing.Audio_telephone__c : ''; 
                        }else if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('Video')){
                            body += hearing.Video_Meeting_URL__c != null ? ' ' + hearing.Video_Meeting_URL__c + ' ' + hearing.Video_Meeting_Information__c : ''; 
                        }
                        body +='<br><br>';
                        if(hearing.Meeting_Office_Email__c!=null){
                            body += 'Si tiene preguntas, envíeme un correo electrónico a '+hearing.Meeting_Office_Email__c+'<br><br>';
                        }
                        
                        body += 'Gracias, <br>';
                        body += hearing.Meeting_Scheduled_for_Name__c+' <br>';
                        body += 'La Oficina de la Comisionada Laboral';
                        body = body.replaceAll('_BR_ENCODED_','<br>');
                    }else{
                        body += 'Hello '+caseRole.Entity__r.Name+',<br><br>'; 
                        body += 'Your '+getRecordTypeName(hearing.RecordTypeId)+' meeting is ' +hearing.Status__c+ ' for '+String.valueOf(hearing.Meeting_Start_Date__c.format())+' '+hearing.Meeting_Start_Time__c;
                        body += ' which is a/an '+hearing.In_Person_Remote_Meeting__c+' meeting,';
                        if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('In Person')){
                            body += ' '+hearingDetails.get(hearing.Id).WCA_Office__r.Office_Address_Formula__c;
                        }else if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('Phone/Remote')){
                            body += ' '+hearing.Audio_telephone__c != null ? hearing.Audio_telephone__c : ''; 
                        }else if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('Video')){
                            body += hearing.Video_Meeting_URL__c != null ? ' ' + hearing.Video_Meeting_URL__c + ' ' + hearing.Video_Meeting_Information__c : '';
                        }
                        body +='<br><br>';
                        if(hearing.Meeting_Office_Email__c!=null){
                            body += 'For questions, please email me at '+hearing.Meeting_Office_Email__c+'<br><br>';
                        }
                        
                        body += 'Thank you, <br>';
                        body += hearing.Meeting_Scheduled_for_Name__c+' <br>';
                        body += 'Labor Commissioner\'s Office';
                        body = body.replaceAll('_BR_ENCODED_','<br>');
                    }
                    
                    mail.setHtmlBody(body);
                    System.debug('sendTo: '+sendTo);
                    if(sendTo.size() > 0){
                        //mails.add(mail);    
                        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
                        System.debug(r[0].isSuccess());
                    }
                }
            }
        }
		/*System.debug(mails.size());
        if(mails.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            System.debug(JSON.serialize(results));
        }*/
        
    /*} */


    @InvocableMethod (label= 'Send Email Notificaton for Meeting') 
    public static void sendEmailNotifications(List<Hearing__c> newHearings){
        Map<Id,List<Hearing__c>> caseIds = new Map<Id,List<Hearing__c>>();
        Id conferenceRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('Conference').getRecordTypeId();
        Id garmentConferenceRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('Garment Conference').getRecordTypeId();
        Id garmentHearingRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('Garment Hearing').getRecordTypeId();
        Id wcaHearingRecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('WCA Hearing').getRecordTypeId();
        Map<Id,Hearing__c> hearingDetails = new Map<Id,Hearing__c>([SELECT Id,WCA_Office__r.Office_Address_Formula__c FROM Hearing__c WHERE Id = :newHearings[0].id]);
       
        
        for(Hearing__c hearing : newHearings){
            
            if((hearing.RecordTypeId == conferenceRecordTypeId ||  hearing.RecordTypeId == garmentConferenceRecordTypeId ||  hearing.RecordTypeId == garmentHearingRecordTypeId || hearing.RecordTypeId == wcaHearingRecordTypeId) && (hearing.Status__c == 'Scheduled' || hearing.Status__c == 'Rescheduled') && hearing.Meeting_Start_Date_Time__c != null){
                if(!caseIds.containsKey(hearing.Case__c)){
                    caseIds.put(hearing.Case__c,new List<Hearing__c>());
                }
                caseIds.get(hearing.Case__c).add(hearing);
            }
        }
        
        system.debug('caseIds create: '+caseIds);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
		//To Do: Loop through Meeting Participant
		
        For(Meeting_Participant__c meetingParticipant: [SELECT Id, Case_Role__c, Case_Role__r.Case__c, Case_Role__r.Case__r.name,
                                                         Case_Role__r.Entity__r.RecordType.Name, Case_Role__r.Entity__r.PersonEmail,
                                                         Case_Role__r.Entity__r.Name, Case_Role__r.Entity__r.Email__c, Case_Role__r.Interpreter_Language__c
                                                         FROM Meeting_Participant__c WHERE Meeting__c IN : hearingDetails.keyset() AND Case_Role__r.Case_Role_Status__c = 'Active'])
        {
             if (meetingParticipant.Case_Role__r.Entity__r.Email__c != null || String.isNotBlank(meetingParticipant.Case_Role__r.Entity__r.PersonEmail)) {
                for(Hearing__c hearing : caseIds.get(meetingParticipant.Case_Role__r.Case__c)){
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> sendTo = new List<String>();
                    if(String.isNotBlank(meetingParticipant.Case_Role__r.Entity__r.PersonEmail) && meetingParticipant.Case_Role__R.Entity__r.RecordType.Name == 'Person Account'){
                        sendTo.add(meetingParticipant.Case_Role__r.Entity__r.PersonEmail);    
                    }else if(meetingParticipant.Case_Role__r.Entity__r.RecordType.Name != 'Person Account'){
                        sendTo.add(meetingParticipant.Case_Role__r.Entity__r.Email__c);
                    }
                    
                    mail.saveAsActivity = true;
                    mail.setWhatId(meetingParticipant.Case_Role__r.Case__c);
                    if(orgwideDefaultId != null){
                        mail.setOrgWideEmailAddressId(orgwideDefaultId);
                    }
                    mail.setToAddresses(sendTo);
                    mail.setSubject('Meeting Scheduled for ' + meetingParticipant.Case_Role__r.Case__r.Name);
                    String body = '';
                    if(meetingParticipant.Case_Role__r.Interpreter_Language__c == 'Spanish'){
                        body += 'Hola '+ meetingParticipant.Case_Role__r.Entity__r.Name+',<br><br>';
                        String status = hearing.Status__c == 'Scheduled' ? 'programada' : 'reprogramado';
                        body += 'Su '+getRecordTypeName(hearing.RecordTypeId)+' reunión está '+status+' para el '+String.valueOf(hearing.Meeting_Start_Date__c.format())+' '+hearing.Meeting_Start_Time__c;
                        body += ', que es una reunión '+hearing.In_Person_Remote_Meeting__c+' meeting, ';
                        if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('In Person')){
                            body += ' '+hearingDetails.get(hearing.Id).WCA_Office__r.Office_Address_Formula__c;
                        }else if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('Phone/Remote')){
                            body += ' '+hearing.Audio_telephone__c != null ? hearing.Audio_telephone__c : ''; 
                        }else if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('Video')){
                            body += hearing.Video_Meeting_URL__c != null ? ' ' + hearing.Video_Meeting_URL__c + ' ' + hearing.Video_Meeting_Information__c : ''; 
                        }
                        body +='<br><br>';
                        if(hearing.Meeting_Office_Email__c!=null){
                            body += 'Si tiene preguntas, envíeme un correo electrónico a '+hearing.Meeting_Office_Email__c+'<br><br>';
                        }
                        
                        body += 'Gracias, <br>';
                        body += hearing.Meeting_Scheduled_for_Name__c+' <br>';
                        body += 'La Oficina de la Comisionada Laboral';
                        body = body.replaceAll('_BR_ENCODED_','<br>');
                    }else{
                        body += 'Hello '+ meetingParticipant.Case_Role__r.Entity__r.Name+',<br><br>'; 
                        body += 'Your '+getRecordTypeName(hearing.RecordTypeId)+' meeting is ' +hearing.Status__c+ ' for '+String.valueOf(hearing.Meeting_Start_Date__c.format())+' '+hearing.Meeting_Start_Time__c;
                        body += ' which is a/an '+hearing.In_Person_Remote_Meeting__c+' meeting, ';
                        if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('In Person')){
                            body += ' '+hearingDetails.get(hearing.Id).WCA_Office__r.Office_Address_Formula__c;
                        }else if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('Phone/Remote')){
                            body += ' '+hearing.Audio_telephone__c != null ? hearing.Audio_telephone__c : ''; 
                        }else if(hearing.In_Person_Remote_Meeting__c.equalsIgnoreCase('Video')){
                            body += hearing.Video_Meeting_URL__c != null ? ' ' + hearing.Video_Meeting_URL__c + ' ' + hearing.Video_Meeting_Information__c : '';
                        }
                        body +='<br><br>';
                        if(hearing.Meeting_Office_Email__c!=null){
                            body += 'This is an automated email sent by our system, for questions please email '+hearing.Meeting_Office_Email__c+'<br><br>';
                        }
                        
                        body += 'Thank you, <br>';
                        body += hearing.Meeting_Scheduled_for_Name__c+' <br>';
                        body += 'Labor Commissioner\'s Office';
                        body = body.replaceAll('_BR_ENCODED_','<br>');
                    }
                    
                    mail.setHtmlBody(body);
                    System.debug('sendTo: '+sendTo);
                    if(sendTo.size() > 0){
                        mails.add(mail); 
                        //Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
                        //System.debug(r[0].isSuccess());
                    }
                }
            }
        }
        
        if(mails.size() > 0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        }
        

    }
        
        
    private static String getRecordTypeName(Id recordTypeId){
        return Schema.SObjectType.Hearing__c.getRecordTypeInfosById().get(recordTypeId).getname();
    }
    
    public static void sendEmailToDeputy(List<Hearing__c> newList){
        Map<Id,List<Hearing__c>> caseIdMap = new Map<Id,List<Hearing__c>>();
        for(Hearing__c h : newList){
            if(h.Status__c == 'Scheduled' && h.Meeting_Start_Date_Time__c != null && h.Meeting_Type__c != null){
                if(caseIdMap.containsKey(h.Case__c)){
                    List<Hearing__c> hs = caseIdMap.get(h.Case__c);
                    hs.add(h);
                    caseIdMap.put(h.Case__c, hs);
                }else{
                    caseIdMap.put(h.Case__c, new Hearing__c[]{h});
                }
            }
        }
        
        EmailTemplate et = [Select Id, HtmlValue, Body, subject from EmailTemplate where DeveloperName = 'Linked_Case_Meeting_Notification' LIMIT 1];
        
        Map<Id,List<String>> emailsMap = new Map<Id,List<String>>();
        for(DIR_Case__c c : [select id, (select id,Linked_Case__r.Assigned_Deputy_Email__c from Linked_Cases1__r WHERE Linked_Case__r.Assigned_Deputy_Email__c != null) from DIR_Case__c where Id IN :caseIdMap.keySet() AND Assigned_Deputy__r.User__r.Profile.Name = 'RCI User']){
            if(c.Linked_Cases1__r != null){
                List<String> emailList = new List<String>();
                for(Linked_Case__c lc : c.Linked_Cases1__r){
                    emailList.add(lc.Linked_Case__r.Assigned_Deputy_Email__c);
                }
                emailsMap.put(c.id, emailList);
            }
        }
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String baseURL = system.URL.getSalesforceBaseUrl().toExternalForm();
        for(DIR_Case__c c : [select id, Name, Assigned_Deputy__r.User__c, Case_Number__c from DIR_Case__c where Id IN :caseIdMap.keySet() AND Assigned_Deputy__r.User__r.Profile.Name = 'RCI User']){
            if(emailsMap.containsKey(c.id)){
                for(Hearing__c h : caseIdMap.get(c.id)){
                    Messaging.SingleEmailMessage emsg = new Messaging.SingleEmailMessage();
                    emsg.setTemplateId(et.Id);
                    emsg.setToAddresses(emailsMap.get(c.id));
                    emsg.setTargetObjectId(c.Assigned_Deputy__r.User__c);
                    //emsg.setWhatId(h.id);
                    emsg.saveAsActivity = false;
                    String htmlBody = String.isNotBlank(et.htmlValue) ? et.htmlValue : et.Body;
                    htmlBody = htmlBody.replace('{!Hearing__c.Meeting_Type__c}', h.Meeting_Type__c);
                    htmlBody = htmlBody.replace('{!Hearing__c.Meeting_Start_Date_Time__c}', h.Meeting_Start_Date_Time__c.format());
                    htmlBody = htmlBody.replace('{!DIR_Case__c.Case_Number__c}', c.Case_Number__c);
                    htmlBody = htmlBody.replace('{!DIR_Case__c.Name}', c.Name);
                    htmlBody = htmlBody.replace('{!Hearing__c.Link}',  + baseURL + '/' + h.id);
                    htmlBody = htmlBody.replaceAll(']]>','');
                    emsg.setHtmlBody(htmlBody);
                    emsg.setSubject(et.Subject);
                    emails.add(emsg);
                }
            }
        }
        if(emails.size() > 0){
            Messaging.sendEmail(emails);
        }
        
    }
    public static smagicinteract__Consent__c optOut(String phone, Id recordId){
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