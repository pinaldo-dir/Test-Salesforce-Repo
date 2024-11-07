public class OCEmailServiceUtility {
    public static string orgwideDefaultId = OWCConstants.orgWideDefaultId;	
    public static string replyToAddress = OWCConstants.replyToAddress;
    public static string wcaPrefix = 'WC-';
    @InvocableMethod(label='Send claimant confirmation')
    public static void sendConfirmationEmailtoClaimant(List<DIR_Case__c> dirCase){
        //system.debug('dirCase[0].Id '+dirCase[0].Id);
        List<DIR_Case__c> dirCases;
        if(dirCase.size() > 0){
            dirCases = [SELECT Id,Case_Number__c, Name, Record_Type_Name__c,Referred_From__c,Status__c,
                                      Assigned_Deputy__r.User__c,Employer__r.name, Related_Party_Employee_Email__c,
                                      Claimant_Name_in_Text__c, Related_Party_Employer_Name__c,
                                      Related_Party_Advocate_Email__c,Advocate_Name_in_Text__c,Office__c,
                                      Office__r.Name,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c,
                                      Applicant_Type__c 
                                      FROM DIR_Case__c 
                                      WHERE Id =:dirCase[0].Id];
        }
        
        String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        if(dirCases != null && dirCases.size() > 0){
            for(DIR_Case__c cse: dirCases){
                
                //send Email to Claimant and Advocate when Claim is not confirm
                if(cse.Status__c == 'Not Confirmed' ){
                    //Check for Advocate Garment
                    if(cse.Applicant_Type__c == 'Representative Garment') {
                        //Send to Claimant on Confirm
                        if(String.isNotBlank(cse.Related_Party_Employee_Email__c)){
                            if(UserInfo.getLanguage() == 'es'){
                                Messaging.SingleEmailMessage emailMessage2 = sendEmailToClaimantOnUnConfirm('Claimant_notification_Unconfirmed_es',cse);
                                emailList.add(emailMessage2);
                            }else{
                                Messaging.SingleEmailMessage emailMessage2 = sendEmailToClaimantOnUnConfirm('Claimant_notification_Unconfirmed',cse);
                                emailList.add(emailMessage2);
                            }
                        }
                        if(String.isNotBlank(cse.Related_Party_Advocate_Email__c)){	
                            if(UserInfo.getLanguage() == 'es'){
                                //send to Advocate on Confirm
                                Messaging.SingleEmailMessage emailMessage2 = sendEmailToAdvocateOnUnConfirm('Advocate_notification_UnConfirmed_es',cse);
                                emailList.add(emailMessage2);
                            } else{
                                //send to Advocate on Confirm
                                Messaging.SingleEmailMessage emailMessage2 = sendEmailToAdvocateOnUnConfirm('Advocate_notification_UnConfirmed',cse);
                                emailList.add(emailMessage2);
                            }
                        }
                    } else {
                        if(String.isNotBlank(cse.Related_Party_Employee_Email__c)){
                            System.debug('Email Sent ::: '+cse.Related_Party_Employee_Email__c);
                            //Send to Claimant on Not Confirm
                            if(UserInfo.getLanguage() == 'es') {
                                Messaging.SingleEmailMessage emailMessage = sendEmailToClaimantOnUnConfirm('Claimant_notification_Unconfirmed_es', cse);
                                emailList.add(emailMessage);
                            } else {
                                Messaging.SingleEmailMessage emailMessage = sendEmailToClaimantOnUnConfirm('Claimant_notification_Unconfirmed', cse);
                                emailList.add(emailMessage);
                            }
                        }
                        if(String.isNotBlank(cse.Related_Party_Advocate_Email__c)){
                            //Send to Advocate on Not Confirm
                            if(UserInfo.getLanguage() == 'es') {
                                Messaging.SingleEmailMessage emailMessage = sendEmailToAdvocateOnUnConfirm('Advocate_notification_UnConfirmed_es', cse);
                                emailList.add(emailMessage);
                            } else{
                                Messaging.SingleEmailMessage emailMessage = sendEmailToAdvocateOnUnConfirm('Advocate_notification_UnConfirmed', cse);
                                emailList.add(emailMessage);
                            }
                            
                        }
                    }
                    
                    
                } else if(cse.Status__c == 'New'){
                    if(cse.Referred_From__c == 'Claimant'){
                        //Send to Claimant on submitted by Itself
                        //Messaging.SingleEmailMessage emailMessage = sendEmailToClaimantOnYourself('Claimant_notification_Claim_submitted_by_Claimant',cse.Id);
                        //emailList.add(emailMessage);		 
                        if(cse.Applicant_Type__c == 'Claimant Garment'){
                            //check for the login user language: 
                            if(UserInfo.getLanguage() == 'es'){ 
                                sendEmailToClaimantOnYourself('Claimant_notification_Claimant_Garment_es',cse.Id, 'Asignación pendiente');
                            } else{
                                sendEmailToClaimantOnYourself('Claimant_notification_Claimant_Garment',cse.Id, 'Pending Assignment');
                            }
                            if(String.isNotBlank(cse.Related_Party_Advocate_Email__c)){
                                ////check for the login user language: 
                                if(UserInfo.getLanguage() == 'es'){
                                    //send to Advocate on Confirm
                                    Messaging.SingleEmailMessage emailMessage2 = sendEmailToAdvocateOnConfirm('Advocate_notification_Filled_by_claimant_garment_es',cse);
                                    emailList.add(emailMessage2);
                                } else{
                                    //send to Advocate on Confirm
                                    Messaging.SingleEmailMessage emailMessage2 = sendEmailToAdvocateOnConfirm('Advocate_notification_Filled_by_claimant_Garment',cse);
                                    emailList.add(emailMessage2);
                                }
                            }
                            
                        }else{
                            //check for the login user language: 
                            if(UserInfo.getLanguage() == 'es'){
                                sendEmailToClaimantOnYourself('Claimant_notification_Claim_submitted_by_Claimant_es',cse.Id, 'Asignación pendiente');
                            }
                            else{
                                sendEmailToClaimantOnYourself('Claimant_notification_Claim_submitted_by_Claimant',cse.Id, 'Pending Assignment');
                            }
                            //send for the Advocate Fix Jira OWC-737
                            if(String.isNotBlank(cse.Related_Party_Advocate_Email__c)){
                                ////check for the login user language: 
                                if(UserInfo.getLanguage() == 'es'){
                                    //send to Advocate on Confirm
                                    Messaging.SingleEmailMessage emailMessage2 = sendEmailToAdvocateOnConfirm('Advocate_notification_Filled_by_claimant_es',cse);
                                    emailList.add(emailMessage2);
                                } else{
                                    //send to Advocate on Confirm
                                    Messaging.SingleEmailMessage emailMessage2 = sendEmailToAdvocateOnConfirm('Advocate_notification_Filled_by_claimant',cse);
                                    emailList.add(emailMessage2);
                                }
                            }
                        }
                    } 
                    else {
                        //Check for Advocate Garment
                        if(cse.Applicant_Type__c == 'Representative Garment') {
                            //Send to Claimant on Confirm
                            if(String.isNotBlank(cse.Related_Party_Employee_Email__c)){
                                if(UserInfo.getLanguage() == 'es'){
                                    sendEmailToClaimantOnConfirm('Claimant_notification_By_Advocate_Garment_Confirmed_es',cse.Id);
                                }else{
                                    sendEmailToClaimantOnConfirm('Claimant_notification_By_Advocate_Garment_Confirmed',cse.Id);
                                }
                            }
                            if(String.isNotBlank(cse.Related_Party_Advocate_Email__c)){	
                                if(UserInfo.getLanguage() == 'es'){
                                    //send to Advocate on Confirm
                                    Messaging.SingleEmailMessage emailMessage2 = sendEmailToAdvocateOnConfirm('Advocate_notification_By_Advocate_Garment_Confirmed_es',cse);
                                    emailList.add(emailMessage2);
                                } else{
                                    //send to Advocate on Confirm
                                    Messaging.SingleEmailMessage emailMessage2 = sendEmailToAdvocateOnConfirm('Advocate_notification_By_Advocate_Garment_Confirmed',cse);
                                    emailList.add(emailMessage2);
                                }
                            }
                        } 
                        else {
                            //Send to Claimant on Confirm
                            if(String.isNotBlank(cse.Related_Party_Employee_Email__c)){
                                if(UserInfo.getLanguage() == 'es'){
                                    sendEmailToClaimantOnConfirm('Claimant_notification_Confirmed_es',cse.Id);
                                }else{
                                    sendEmailToClaimantOnConfirm('Claimant_notification_Confirmed',cse.Id);
                                }
                                
                            }
                            if(String.isNotBlank(cse.Related_Party_Advocate_Email__c)){	
                                if(UserInfo.getLanguage() == 'es'){
                                    //send to Advocate on Confirm
                                    Messaging.SingleEmailMessage emailMessage2 = sendEmailToAdvocateOnConfirm('Advocate_notification_Confirmed_es',cse);
                                    emailList.add(emailMessage2);
                                } else{
                                    //send to Advocate on Confirm
                                    Messaging.SingleEmailMessage emailMessage2 = sendEmailToAdvocateOnConfirm('Advocate_notification_Confirmed',cse);
                                    emailList.add(emailMessage2);
                                }
                            }
                        }
                        
                    }
                }
                
            }
        }
        
        if(!emailList.isEmpty()){
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
            }
            catch(Exception e){
                System.debug('error : '+ e.getMessage());
            }
        }
        
    }
    
    public static void sendAutoResponse(List<DIR_Case__c> dirCase, String templateName, String recipientEmail){
        system.debug('dirCase 123- '+dirCase[0].Id);
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate WHERE Name=:templateName];
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        for(DIR_Case__c cse: dirCase){
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setTemplateId(emailTemplate.Id);
            Date todayDate = Date.today();
            if(String.isNotBlank(recipientEmail)){
                emailMessage.setToAddresses(new list<String>{recipientEmail});
                emailMessage.setReplyTo(replyToAddress);
                emailMessage.saveAsActivity = true;
                emailMessage.setWhatId(cse.Id);
                if(orgwideDefaultId != null){
                    emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
                }
                String htmlBody = emailTemplate.HtmlValue;
                if(String.isNotBlank(cse.Claimant_Name_in_Text__c)){
                    htmlBody = htmlBody.replace('{!Claimant}', cse.Claimant_Name_in_Text__c);
                }
                if(String.isNotBlank(cse.Advocate_Name_in_Text__c)){
                    htmlBody = htmlBody.replace('{!Advocate}', cse.Advocate_Name_in_Text__c);
                }
                if(String.isNotBlank(cse.Advocate_Name_in_Text__c)){
                    htmlBody = htmlBody.replace('{!advocate/rep}', cse.Advocate_Name_in_Text__c);
                }
                if(String.isNotBlank(cse.Related_Party_Employer_Name__c)){
                    htmlBody = htmlBody.replace('{!Defendant}', cse.Related_Party_Employer_Name__c);
                }
                System.debug('case number = '+ cse.Case_Number__c);
                if(String.isNotBlank(cse.Case_Number__c)){
                    htmlBody = htmlBody.replace('{!case number}', cse.Case_Number__c);
                }
                // for replace date with today's date FORMAT MM/DD/YYYY
                String month = todayDate.month() >9 ? String.valueOf(todayDate.month()) : '0'+todayDate.month();
                String day = todayDate.day() >9 ? String.valueOf(todayDate.day()) : '0'+todayDate.day();
                
                htmlBody = htmlBody.replace('{!filed date}', month + '/' + day + '/' + todayDate.year());
                String officeName;
                if(cse.Office__c == null || cse.Office__r.Name == 'WCA - OUT OF STATE'){
                    if(ClaimantConfirmationEmailservice.templateLang == 'es'){
                        officeName = 'Asignación pendiente';
                    } else{
                        officeName = 'Pending Assignment';
                    }
                }else {
                    officeName = cse.Office__r.Name; 
                }
                //if(templateName == 'Claim Email Reply Confirm' || ){
                    if(officeName == 'Pending Assignment' || officeName == 'Asignación pendiente'){
                        htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', ''+officeName+'<br></br>');
                        htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', '');
                        htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', '');
                    } else{
                        htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', ''+officeName+'<br>');
                        htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', cse.DIR_WCA_Office_Address__c+'<br>');
                        htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', cse.DIR_Office_Phone_Number__c+'<br></br>');
                    }
                //}
                
                emailMessage.setHtmlBody(htmlBody);
                String subject = emailTemplate.Subject;
                subject = subject.replace('{Case.Name}', cse.Name);
                emailMessage.setSubject(subject);
                emailList.add(emailMessage);
            }
        }
        
        if(!emailList.isEmpty()){
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
            }
            catch(Exception e){
                System.debug('error : '+ e.getMessage());
            }
        }
        
    }
    
    public static void sendNewOnlineClaimEmail(DIR_Case__c dirCse){
        DIR_Case__c cseRecord = [SELECT id,Status__c,Related_Party_Employee_Email__c,Claimant_Name_in_Text__c,Advocate_Name_in_Text__c,
                                 Related_Party_Employer_Name__c,Office__c,
                                 Office__r.Name,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c,Name,
                                 Referred_From__c FROM DIR_Case__c
                                 WHERE Id =: dirCse.Id];
        if(dirCse.Status__c == 'Not Confirmed'){
            //sendNewOnlineClaimEmail('Claimant_notification_Unconfirmed',dirCse);
                                                
        } else{
            if(cseRecord.Referred_From__c == 'Claimant'){
                sendNewOnlineClaimEmail('Claimant_notification_Claim_submitted_by_Claimant',dirCse);
            } else {
                sendNewOnlineClaimEmail('Claimant_notification_Confirmed',dirCse);
            }
            
        }
        /************
        //lets check for the related parties
        List<Related_Party__c> relatedParties = [SELECT Id,Role__c,Email__c,Business_Name__c,Combined_First_and_Last_Name__c,
                                                 Case_Management__r.Office__r.Name,Case_Management__r.DIR_WCA_Office_Address__c,
                                                 Case_Management__r.DIR_Office_Phone_Number__c,Case_Management__r.Name,
                                                 Case_Management__r.Employer__c,Case_Management__r.Employer_Name_in_Text__c
                                                 FROM Related_Party__c
                                                 WHERE (Role__c = 'Advocate' OR Role__c = 'Claimant' OR Role__c = 'Defendant') 
                                                 AND Case_Management__c =: dirCse.Id];
        String advocateName ;
        String defendantName;
        if(relatedParties.size() > 0){
            for(Related_Party__c rp: relatedParties){
                if(rp.Role__c == 'Advocate'){
                    if(String.isNotBlank(rp.Business_Name__c)){
                        advocateName =  rp.Business_Name__c;
                    } else{
                        advocateName = rp.Combined_First_and_Last_Name__c;
                    }
                } else if(rp.Role__c == 'Defendant'){
                    if(String.isNotBlank(rp.Business_Name__c)){
                        defendantName =  rp.Business_Name__c;
                    } else{
                        defendantName = rp.Combined_First_and_Last_Name__c;
                    }
                }
            }
            for(Related_Party__c rp: relatedParties)
            {	
                if(rp.Role__c == 'Claimant'){
                    String officeName ;	
                    if(rp.Case_Management__r.Office__r.Name == 'WCA - OUT OF STATE'){
                        officeName = 'Pending Assignment';
                    }else {
                        officeName = rp.Case_Management__r.Office__r.Name;
                    }
                    String recipientName;
                    if(String.isNotBlank(rp.Business_Name__c)){
                        recipientName =  rp.Business_Name__c;
                    } else{
                        recipientName = rp.Combined_First_and_Last_Name__c;
                    }
                    if(dirCse.Status__c == 'Not Confirmed'){
                        sendNewOnlineClaimEmail('Claimant_notification_Unconfirmed',
                                                rp.Email__c,
                                                recipientName,
                                                defendantName,
                                                dirCse,
                                                officeName, 
                                                rp.Case_Management__r.DIR_WCA_Office_Address__c,
                                                rp.Case_Management__r.DIR_Office_Phone_Number__c,
                                                advocateName);
                    } else {
                        sendNewOnlineClaimEmail('Claimant_notification_Confirmed',
                                                rp.Email__c,
                                                recipientName,
                                                defendantName,
                                                dirCse ,
                                                officeName, 
                                                rp.Case_Management__r.DIR_WCA_Office_Address__c,
                                                rp.Case_Management__r.DIR_Office_Phone_Number__c,
                                                advocateName);
                    }
                    break;
                }
                
            }
        }
        */
    }
    public static void sendNewOnlineClaimEmail(String emailTemplateName, 
                                               DIR_Case__c dirCse)
    {
        
        /*DIR_Case__c caseRecord = [SELECT Id, Name FROM DIR_Case__c WHERE Id =: dirCse.Id];  	*/                                         
        List<EmailTemplate> emailTemplateList = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                                 FROM EmailTemplate WHERE developerName=: emailTemplateName];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(emailTemplateList[0].Id);
        
        emailMessage.setToAddresses(new list<String>{dirCse.Related_Party_Employee_Email__c});
        emailMessage.saveAsActivity = true;
        emailMessage.setWhatId(dirCse.Id);
        if(orgwideDefaultId != null){
            emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
        }
        String htmlBody = emailTemplateList[0].HtmlValue; 
        htmlBody = htmlBody.replace('<Claimant>',dirCse.Claimant_Name_in_Text__c +'<br></br>');
        if(String.isNotBlank(dirCse.Advocate_Name_in_Text__c)){
            htmlBody = htmlBody.replace('<advocate/rep>',dirCse.Advocate_Name_in_Text__c);
        }
        Date todayDate = Date.today();
        // for replace date with today's date FORMAT MM/DD/YYYY
        String month = todayDate.month() >9 ? String.valueOf(todayDate.month()) : '0'+todayDate.month();
        String day = todayDate.day() >9 ? String.valueOf(todayDate.day()) : '0'+todayDate.day();
        htmlBody = htmlBody.replace('{!Today}',month + '/' + day + '/' + todayDate.year());
        if(String.isNotBlank(dirCse.Related_Party_Employer_Name__c )){
            htmlBody = htmlBody.replace('<Defendant>', dirCse.Related_Party_Employer_Name__c);
        }
        String office ;
        if(dirCse.Office__c == null || dirCse.Office__r.Name == 'WCA - OUT OF STATE'){
            if(UserInfo.getLanguage() == 'es'){
                office = 'Asignación pendiente';
            } else{
                office = 'Pending Assignment';
            }
        }else {
            office = dirCse.Office__r.Name;
        }
        if(office == 'Pending Assignment' || office == 'Asignación pendiente'){
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', ''+office+'<br></br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', '');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', '');
        } else{
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', ''+office+'<br>');
            String officeAddress = '';
            String officePhone = ''; 		
            if(String.isNotBlank(dirCse.DIR_WCA_Office_Address__c)){
                officeAddress = dirCse.DIR_WCA_Office_Address__c;
            }
            if(String.isNotBlank(dirCse.DIR_Office_Phone_Number__c)){
                officePhone = dirCse.DIR_Office_Phone_Number__c;
            }
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', officeAddress+'<br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', officePhone+'<br></br>');
        }
        if(dirCse.Status__c == 'New'){
            htmlBody = htmlBody.replace('<case number>', 'WC-'+dirCse.Name);
        } else{
            htmlBody = htmlBody.replace('<case number>', dirCse.Name);
        }
        
        //htmlBody = htmlBody.replace('{!Case.Office}', recipientName);
        emailMessage.setHtmlBody(htmlBody);
        String subject = emailTemplateList[0].Subject;
        
        emailMessage.setSubject(subject);
        emailList.add(emailMessage);
        
        if(!emailList.isEmpty()){
            try{
            	Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
            }
            catch(Exception e){
                System.debug('error : '+ e.getMessage());
            }
        }
    }
    public static void sendTestEmail(String body){
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate WHERE Name='Claim Confirmation Email notification'];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(emailTemplate.Id);
        emailMessage.setToAddresses(new list<String>{'akash.som@cloudsciencelabs.com', 'vikas@cloudsciencelabs.com'});
        //   emailMessage.setTargetObjectId(UserInfo.getUserId());
        emailMessage.saveAsActivity = true;
        if(orgwideDefaultId != null){
            emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
        }
        String htmlBody = emailTemplate.Body;
        htmlBody = body;
        emailMessage.setHtmlBody(htmlBody);
        String subject = emailTemplate.Subject;
        emailMessage.setSubject(subject);
        emailList.add(emailMessage);
        
        if(!emailList.isEmpty()){
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
            }
            catch(Exception e){
                System.debug('error : '+ e.getMessage());
            }
        }
    }
    @future
    public static void sendEmailToClaimantOnYourself(String templateName, String caseId, String pendingOffice){
       List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                   
        DIR_Case__c caseRecord = [SELECT Id,Related_Party_Employee_Email__c,Claimant_Name_in_Text__c,Related_Party_Employer_Name__c,Office__r.Name,
                                  Office__c,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c,Status__c,Name FROM DIR_Case__c
                                  WHERE Id =: caseId];
        System.debug('<<aaa<<<<<<<<:'+caseId);
        List<ContentVersion> cvList = new List<ContentVersion>();
       List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
       Blob fileData;
       Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate WHERE developerName=: templateName];
        
 		
        System.debug('<<<<<<<<<<');
        System.debug(caseRecord.Id);
       cdlList = [SELECT ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink 
                                             WHERE LinkedEntityId = :caseRecord.Id AND ContentDocument.Title = 'Wage Claim Summary Report'];
        
        if(!cdlList.isEmpty()){
            System.debug('under333');
             cvList = [SELECT VersionData, FileExtension FROM ContentVersion
                                       WHERE ContentDocumentId = :cdlList[0].ContentDocumentId AND IsLatest = true]; 
        }
      
        
        if(!cvList.isEmpty()){
            System.debug('under340');
            fileData = cvList[0].VersionData;
            
            attach = new Messaging.EmailFileAttachment();
            attach.setFilename('Wage Claim Summary Report.' + cvList[0].FileExtension);
            attach.setInline(false);
            attach.setBody(fileData);
        }
        // <= This step converts the version data into a blob for the attachment

        
        
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(emailTemplate.Id);
        emailMessage.setToAddresses(new list<String>{caseRecord.Related_Party_Employee_Email__c});
        emailMessage.saveAsActivity = true;
        emailMessage.setWhatId(caseRecord.Id);
        if(orgwideDefaultId != null){
            emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
        }
        if(!cdlList.isEmpty()){
            System.debug('under360');
            if(cdlList[0].ContentDocument.Title ==  'Wage Claim Summary Report'){
                        System.debug('under362');
        	emailMessage.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });//Set File Attachment
        }
		}
        
        
        String htmlBody = emailTemplate.HtmlValue;
        
        String claimantName = String.isNotBlank(caseRecord.Claimant_Name_in_Text__c) ? caseRecord.Claimant_Name_in_Text__c : ''; 
        htmlBody = htmlBody.replace('{!Claimant}', claimantName);
        
        String employerName = String.isNotBlank(caseRecord.Related_Party_Employer_Name__c) ? caseRecord.Related_Party_Employer_Name__c : '';
        htmlBody = htmlBody.replace('{!Defendant}', employerName);
        
        
        System.debug('caseRecord: '+caseRecord.Office__r.Name);
        System.debug('caseRecord: '+caseRecord.Office__c);
        String office ;
        if(caseRecord.Office__c == null || caseRecord.Office__r.Name == 'WCA - OUT OF STATE'){
            office = pendingOffice;
        }else {
            office = caseRecord.Office__r.Name;
        }
        if(office == 'Pending Assignment' || office == 'Asignación pendiente'){
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', ''+office+'<br></br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', '');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', '');
        } else{
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', ''+office+'<br>');
            String officeAddress = '';
            String officePhone = ''; 
            if(String.isNotBlank(caseRecord.DIR_WCA_Office_Address__c)){ 
                officeAddress = caseRecord.DIR_WCA_Office_Address__c;
            }
            if(String.isNotBlank(caseRecord.DIR_Office_Phone_Number__c)){
                officePhone = caseRecord.DIR_Office_Phone_Number__c;
            }
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', officeAddress+'<br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', officePhone+'<br></br>');
        }
        if(caseRecord.Status__c == 'New'){ 
            htmlBody = htmlBody.replace('{!case number}', 'WC-'+caseRecord.Name);
        }
        emailMessage.setHtmlBody(htmlBody);
        String subject = emailTemplate.Subject;
        //subject = subject.replace('{!DIR_Case__c.Name}', caseRecord.Name);
        emailMessage.setSubject(subject);
        //return emailMessage;
        emailList.add(emailMessage);
        
        if(!emailList.isEmpty()){
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
            }
            catch(Exception e){
                System.debug('error : '+ e.getMessage());
            }
        }
        
    }
    public static Messaging.SingleEmailMessage sendEmailToClaimantOnUnConfirm (String templateName, DIR_Case__c caseRecord){
       System.debug('fdsfd');
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate WHERE developerName=: templateName];
        
        
       List<ContentVersion> cvList = new List<ContentVersion>();
       List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
       Blob fileData;
       Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        
 		
        System.debug('<<<<<<<<<<');
        System.debug(caseRecord.Id);
       cdlList = [SELECT ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink 
                                             WHERE LinkedEntityId = :caseRecord.Id AND ContentDocument.Title =  'Wage Claim Summary Report'];
        System.debug('cdlList ::: '+cdlList);
        
        if(!cdlList.isEmpty()){
            System.debug('under333');
             cvList = [SELECT VersionData, FileExtension FROM ContentVersion
                                       WHERE ContentDocumentId = :cdlList[0].ContentDocumentId AND IsLatest = true]; 
        }
      
        
        if(!cvList.isEmpty()){
            System.debug('under340');
            fileData = cvList[0].VersionData;
            
            attach = new Messaging.EmailFileAttachment();
            attach.setFilename('Wage Claim Summary Report.' + cvList[0].FileExtension);
            attach.setInline(false);
            attach.setBody(fileData);
        }
        // <= This step converts the version data into a blob for the attachment




        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(emailTemplate.Id);
        emailMessage.setToAddresses(new list<String>{caseRecord.Related_Party_Employee_Email__c});
        //Set the Reply To option to Confirm/Deny
        emailMessage.setReplyTo(replyToAddress);
        //   emailMessage.setTargetObjectId(UserInfo.getUserId());
        emailMessage.saveAsActivity = true;
        emailMessage.setWhatId(caseRecord.Id);
        if(orgwideDefaultId != null){
            emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
        }
        if(!cdlList.isEmpty()){
            System.debug('under360');
            if(cdlList[0].ContentDocument.Title ==  'Wage Claim Summary Report'){
                System.debug('under362');
                emailMessage.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });//Set File Attachment
            }
        }
        
        String htmlBody = emailTemplate.HtmlValue;
        
        String claimantName = String.isNotBlank(caseRecord.Claimant_Name_in_Text__c) ? caseRecord.Claimant_Name_in_Text__c : ''; 
        htmlBody = htmlBody.replace('{!Claimant}', claimantName);
        
        String advocateName = String.isNotBlank(caseRecord.Advocate_Name_in_Text__c) ? caseRecord.Advocate_Name_in_Text__c : '';
        htmlBody = htmlBody.replace('{!advocate/rep}', advocateName);
        
        String employerName = String.isNotBlank(caseRecord.Related_Party_Employer_Name__c) ? caseRecord.Related_Party_Employer_Name__c : '';
        htmlBody = htmlBody.replace('{!Defendant}', employerName);
        
        Date todayDate = Date.today();
        // for replace date with today's date FORMAT MM/DD/YYYY
        String month = todayDate.month() >9 ? String.valueOf(todayDate.month()) : '0'+todayDate.month();
        String day = todayDate.day() >9 ? String.valueOf(todayDate.day()) : '0'+todayDate.day();
        htmlBody = htmlBody.replace('{!filed date}', month + '/' + day + '/' + todayDate.year());
        
        emailMessage.setHtmlBody(htmlBody);
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!DIR_Case__c.Name}', caseRecord.Name);
        emailMessage.setSubject(subject);
        return emailMessage;
    }
    @future
    public static void sendEmailToClaimantOnConfirm(String templateName, String caseId){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        DIR_Case__c caseRecord = [SELECT Id,Related_Party_Employee_Email__c,Claimant_Name_in_Text__c,Related_Party_Employer_Name__c,Office__r.Name,
                                  Office__c,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c,Status__c,Name,
                                  Advocate_Name_in_Text__c FROM DIR_Case__c
                                  WHERE Id =: caseId];
        System.debug('sssss');
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate WHERE developerName=: templateName];
        
        
        
       List<ContentVersion> cvList = new List<ContentVersion>();
       List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
       Blob fileData;
       Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        
        
 		
        System.debug('<<<<<<<<<<');
        System.debug(caseRecord.Id);
       cdlList = [SELECT ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink 
                                             WHERE LinkedEntityId = :caseRecord.Id AND ContentDocument.Title =  'Wage Claim Summary Report'];
        
        if(!cdlList.isEmpty()){
            System.debug('under333');
             cvList = [SELECT VersionData, FileExtension FROM ContentVersion
                                       WHERE ContentDocumentId = :cdlList[0].ContentDocumentId AND IsLatest = true]; 
        }
      
        
        if(!cvList.isEmpty()){
            System.debug('under340');
            fileData = cvList[0].VersionData;
            
            attach = new Messaging.EmailFileAttachment();
            attach.setFilename('Wage Claim Summary Report.' + cvList[0].FileExtension);
            attach.setInline(false);
            attach.setBody(fileData);
        }
        // <= This step converts the version data into a blob for the attachment

               
        
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(emailTemplate.Id);
        emailMessage.setToAddresses(new list<String>{caseRecord.Related_Party_Employee_Email__c});
        emailMessage.saveAsActivity = true;
        emailMessage.setWhatId(caseId);
        if(orgwideDefaultId != null){
            emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
        }
        if(!cdlList.isEmpty()){
            System.debug('under360');
            if(cdlList[0].ContentDocument.Title ==  'Wage Claim Summary Report'){
                System.debug('under362');
                emailMessage.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });//Set File Attachment
            }
        }

        String htmlBody = emailTemplate.HtmlValue;
        
        String claimantName = String.isNotBlank(caseRecord.Claimant_Name_in_Text__c) ? caseRecord.Claimant_Name_in_Text__c : ''; 
        htmlBody = htmlBody.replace('{!Claimant}', claimantName);
        
        String advocateName = String.isNotBlank(caseRecord.Advocate_Name_in_Text__c) ? caseRecord.Advocate_Name_in_Text__c : '';
        htmlBody = htmlBody.replace('{!advocate/rep}', advocateName);
        
        String employerName = String.isNotBlank(caseRecord.Related_Party_Employer_Name__c) ? caseRecord.Related_Party_Employer_Name__c : '';
        htmlBody = htmlBody.replace('{!Defendant}', employerName);
        
        htmlBody = htmlBody.replace('{!case number}', 'WC-'+caseRecord.Name);
        
        String office ;
        if(caseRecord.Office__c == null || caseRecord.Office__r.Name == 'WCA - OUT OF STATE'){
            if(UserInfo.getLanguage() == 'es'){
                office = 'Asignación pendiente';
            } else{
                office = 'Pending Assignment';
            }
        }else {
            office = caseRecord.Office__r.Name;
        }
        if(office == 'Pending Assignment' || office == 'Asignación pendiente'){
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', ''+office+'<br></br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', '');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', '');
        } else{
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', ''+office+'<br>');
            String officeAddress = '';
            String officePhone = ''; 
            if(String.isNotBlank(caseRecord.DIR_WCA_Office_Address__c)){
                officeAddress = caseRecord.DIR_WCA_Office_Address__c;
            }
            if(String.isNotBlank(caseRecord.DIR_Office_Phone_Number__c)){
                officePhone = caseRecord.DIR_Office_Phone_Number__c;
            }
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', officeAddress+'<br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', officePhone+'<br></br>');
        }
        
        emailMessage.setHtmlBody(htmlBody);
        String subject = emailTemplate.Subject;
        //subject = subject.replace('{!DIR_Case__c.Name}', caseRecord.Name);
        emailMessage.setSubject(subject);
        //return emailMessage;
        emailList.add(emailMessage);
        
        if(!emailList.isEmpty()){
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
            }
            catch(Exception e){
                System.debug('error : '+ e.getMessage());
            }
        }
        //return emailMessage;
    }
    public static Messaging.SingleEmailMessage  sendEmailToAdvocateOnConfirm(String templateName, DIR_Case__c caseRecord){
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate WHERE developerName=: templateName];
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(emailTemplate.Id);
        emailMessage.setToAddresses(new list<String>{caseRecord.Related_Party_Advocate_Email__c});
        emailMessage.saveAsActivity = true;
        emailMessage.setWhatId(caseRecord.Id);
        if(orgwideDefaultId != null){
            emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
        }
        String htmlBody = emailTemplate.HtmlValue;
        String advocateName  = String.isNotBlank(caseRecord.Advocate_Name_in_Text__c) ? caseRecord.Advocate_Name_in_Text__c : ''; 
        htmlBody = htmlBody.replace('{!Advocate}', advocateName);
        
        String claimantName = String.isNotBlank(caseRecord.Claimant_Name_in_Text__c) ? caseRecord.Claimant_Name_in_Text__c : '';
        htmlBody = htmlBody.replace('{!Claimant}', claimantName);
        
        String employerName = String.isNotBlank(caseRecord.Related_Party_Employer_Name__c) ? caseRecord.Related_Party_Employer_Name__c : '';
        htmlBody = htmlBody.replace('{!Defendant}', employerName);
        
        Date todayDate = Date.today();
        // for replace date with today's date FORMAT MM/DD/YYYY
        String month = todayDate.month() >9 ? String.valueOf(todayDate.month()) : '0'+todayDate.month();
        String day = todayDate.day() >9 ? String.valueOf(todayDate.day()) : '0'+todayDate.day();
        htmlBody = htmlBody.replace('{!filed date}', month + '/' + day + '/' + todayDate.year());
        htmlBody = htmlBody.replace('{!case number}', 'WC-'+caseRecord.Name);
        
        String office ;
        if(caseRecord.Office__c == null || caseRecord.Office__r.Name == 'WCA - OUT OF STATE'){
            if(UserInfo.getLanguage() == 'es'){
                office = 'Asignación pendiente';
            } else{
                office = 'Pending Assignment';
            }
        }else {
            office = caseRecord.Office__r.Name;
        }
        if(office == 'Pending Assignment' || office == 'Asignación pendiente'){
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', ''+office+'<br></br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', '');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', '');
        } else{
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', ''+office+'<br>');
            String officeAddress = '';
            String officePhone = ''; 
            if(String.isNotBlank(caseRecord.DIR_WCA_Office_Address__c)){
                officeAddress = caseRecord.DIR_WCA_Office_Address__c;
            }
            if(String.isNotBlank(caseRecord.DIR_Office_Phone_Number__c)){
                officePhone = caseRecord.DIR_Office_Phone_Number__c;
            }
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', officeAddress+'<br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', officePhone+'<br></br>');
        }
        
        emailMessage.setHtmlBody(htmlBody);
        String subject = emailTemplate.Subject;
        //subject = subject.replace('{!DIR_Case__c.Name}', caseRecord.Name);
        emailMessage.setSubject(subject);
        return emailMessage;
    }
    public static Messaging.SingleEmailMessage sendEmailToAdvocateOnUnConfirm(String templateName, DIR_Case__c caseRecord){
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate WHERE developerName=: templateName];
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(emailTemplate.Id);
        emailMessage.setToAddresses(new list<String>{caseRecord.Related_Party_Advocate_Email__c});
        emailMessage.saveAsActivity = true;
        emailMessage.setWhatId(caseRecord.Id);
        if(orgwideDefaultId != null){
            emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
        }
        String htmlBody = emailTemplate.HtmlValue;
        String advocateName  = String.isNotBlank(caseRecord.Advocate_Name_in_Text__c) ? caseRecord.Advocate_Name_in_Text__c : ''; 
        htmlBody = htmlBody.replace('{!Advocate}', advocateName);
        
        String claimantName = String.isNotBlank(caseRecord.Claimant_Name_in_Text__c) ? caseRecord.Claimant_Name_in_Text__c : '';
        htmlBody = htmlBody.replace('{!Claimant}', claimantName);
        
        String employerName = String.isNotBlank(caseRecord.Related_Party_Employer_Name__c) ? caseRecord.Related_Party_Employer_Name__c : '';
        htmlBody = htmlBody.replace('{!Defendant}', employerName);
        
        Date todayDate = Date.today();
        // for replace date with today's date FORMAT MM/DD/YYYY
        String month = todayDate.month() >9 ? String.valueOf(todayDate.month()) : '0'+todayDate.month();
        String day = todayDate.day() >9 ? String.valueOf(todayDate.day()) : '0'+todayDate.day();
        htmlBody = htmlBody.replace('{!filed date}', month + '/' + day + '/' + todayDate.year());
        
        emailMessage.setHtmlBody(htmlBody);
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!DIR_Case__c.Name}', caseRecord.Name);
        emailMessage.setSubject(subject);
        return emailMessage;
        
    }
    @future
    public static void sendOfficeChangeEmailToClaimant(String templateName, String caseId){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        DIR_Case__c caseRecord = [SELECT Id,Related_Party_Employee_Email__c,Claimant_Name_in_Text__c,Related_Party_Employer_Name__c,Office__r.Name,
                                  Office__c,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c,Status__c,Name,
                                  Advocate_Name_in_Text__c FROM DIR_Case__c
                                  WHERE Id =: caseId];
        if(String.isBlank(caseRecord.Related_Party_Employee_Email__c)){
            return;
        }
        if(caseRecord.Office__c == null ) return;
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate WHERE developerName=: templateName];
       
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(emailTemplate.Id);
        emailMessage.setToAddresses(new list<String>{caseRecord.Related_Party_Employee_Email__c});
        emailMessage.saveAsActivity = true;
        emailMessage.setWhatId(caseId);
        if(orgwideDefaultId != null){
            emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
        }
        String htmlBody = emailTemplate.HtmlValue;
        
        String claimantName = String.isNotBlank(caseRecord.Claimant_Name_in_Text__c) ? caseRecord.Claimant_Name_in_Text__c : ''; 
        htmlBody = htmlBody.replace('{!User}', claimantName);
        
        String employerName = String.isNotBlank(caseRecord.Related_Party_Employer_Name__c) ? caseRecord.Related_Party_Employer_Name__c : '';
        htmlBody = htmlBody.replace('{!Defendant}', employerName);
        
        htmlBody = htmlBody.replace('{!case number}', 'WC-'+caseRecord.Name);
        
        String office ;
        if(caseRecord.Office__r.Name == 'WCA - OUT OF STATE'){
            if(UserInfo.getLanguage() == 'es'){
                office = 'Asignación pendiente';
            } else{
                office = 'Pending Assignment';
            }
        }else {
            office = caseRecord.Office__r.Name;
        }
        if(office == 'Pending Assignment' || office == 'Asignación pendiente'){
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', '<br></br>'+office+'<br></br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', '');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', '');
        } else{
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', '<br></br>'+office+'<br>');
            String officeAddress = '';
            String officePhone = ''; 
            if(String.isNotBlank(caseRecord.DIR_WCA_Office_Address__c)){
                officeAddress = caseRecord.DIR_WCA_Office_Address__c;
            }
            if(String.isNotBlank(caseRecord.DIR_Office_Phone_Number__c)){
                officePhone = caseRecord.DIR_Office_Phone_Number__c;
            }
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', officeAddress+'<br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', officePhone+'<br></br>');
        }
        
        emailMessage.setHtmlBody(htmlBody);
        String subject = emailTemplate.Subject;
        //subject = subject.replace('{!DIR_Case__c.Name}', caseRecord.Name);
        emailMessage.setSubject(subject);
        //return emailMessage;
        emailList.add(emailMessage);
        
        if(!emailList.isEmpty()){
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
            }
            catch(Exception e){
                System.debug('error : '+ e.getMessage());
            }
        }
        //return emailMessage;
    }
    @future
    public static void sendOfficeChangeEmailToAdvocate(String templateName, String caseId){
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        DIR_Case__c caseRecord = [SELECT Id,Related_Party_Advocate_Email__c,Advocate_Name_in_Text__c,
                                  Claimant_Name_in_Text__c,Related_Party_Employer_Name__c,Office__r.Name,
                                  Office__c,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c,Status__c,Name
                                  FROM DIR_Case__c
                                  WHERE Id =: caseId];
        if(String.isBlank(caseRecord.Related_Party_Advocate_Email__c)){
            return;
        }
        if(caseRecord.Office__c == null ) return;
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate WHERE developerName=: templateName];
        
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(emailTemplate.Id);
        emailMessage.setToAddresses(new list<String>{caseRecord.Related_Party_Advocate_Email__c});
        emailMessage.saveAsActivity = true;
       	emailMessage.setWhatId(caseId);
        if(orgwideDefaultId != null){
            emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
        }
        String htmlBody = emailTemplate.HtmlValue;
        
        String claimantName = String.isNotBlank(caseRecord.Advocate_Name_in_Text__c) ? caseRecord.Advocate_Name_in_Text__c : ''; 
        htmlBody = htmlBody.replace('{!User}', claimantName);
        
        String employerName = String.isNotBlank(caseRecord.Related_Party_Employer_Name__c) ? caseRecord.Related_Party_Employer_Name__c : '';
        htmlBody = htmlBody.replace('{!Defendant}', employerName);
        
        htmlBody = htmlBody.replace('{!case number}', 'WC-'+caseRecord.Name);
        
        String office ;
        
        if(caseRecord.Office__r.Name == 'WCA - OUT OF STATE'){
            if(UserInfo.getLanguage() == 'es'){
                office = 'Asignación pendiente';
            } else{
                office = 'Pending Assignment';
            }
        }else {
            office = caseRecord.Office__r.Name;
        }
        if(office == 'Pending Assignment' || office == 'Asignación pendiente'){
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', '<br></br>'+office+'<br></br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', '');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', '');
        } else{
            htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', '<br></br>'+office+'<br>');
            String officeAddress = '';
            String officePhone = ''; 
            if(String.isNotBlank(caseRecord.DIR_WCA_Office_Address__c)){
                officeAddress = caseRecord.DIR_WCA_Office_Address__c;
            }
            if(String.isNotBlank(caseRecord.DIR_Office_Phone_Number__c)){
                officePhone = caseRecord.DIR_Office_Phone_Number__c;
            }
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', officeAddress+'<br>');
            htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', officePhone+'<br></br>');
        }
        
        emailMessage.setHtmlBody(htmlBody);
        String subject = emailTemplate.Subject;
        //subject = subject.replace('{!DIR_Case__c.Name}', caseRecord.Name);
        emailMessage.setSubject(subject);
        //return emailMessage;
        emailList.add(emailMessage);
        
        if(!emailList.isEmpty()){
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
            }
            catch(Exception e){
                System.debug('error : '+ e.getMessage());
            }
        }
        //return emailMessage;
    }
    public static void sendEmailtoAdvocateOnClosed(DIR_Case__c caseRecord){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = sendEmailToAdvocateOnCaseClosure('Advocate_notification_on_unconfirmed_case_closed', caseRecord);
        if(email != null){
            emailList.add(email);
        }
        
        if(!emailList.isEmpty()){
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
            }
            catch(Exception e){
                System.debug('error : '+ e.getMessage());
            }
        }
    }
    public static Messaging.SingleEmailMessage sendEmailToAdvocateOnCaseClosure(String templateName, DIR_Case__c caseRecord){
        if(caseRecord.Related_Party_Advocate_Email__c == null){
            return null;
        }
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate WHERE developerName=: templateName];
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(emailTemplate.Id);
        emailMessage.setToAddresses(new list<String>{caseRecord.Related_Party_Advocate_Email__c});
        emailMessage.saveAsActivity = true;
        emailMessage.setWhatId(caseRecord.Id);
        if(orgwideDefaultId != null){
            emailMessage.setOrgWideEmailAddressId(orgwideDefaultId);
        }
        String htmlBody = emailTemplate.HtmlValue;
        String advocateName  = String.isNotBlank(caseRecord.Advocate_Name_in_Text__c) ? caseRecord.Advocate_Name_in_Text__c : ''; 
        htmlBody = htmlBody.replace('{!Advocate}', advocateName);
        
        String claimantName = String.isNotBlank(caseRecord.Claimant_Name_in_Text__c) ? caseRecord.Claimant_Name_in_Text__c : '';
        htmlBody = htmlBody.replace('{!Claimant}', claimantName);
        
        String employerName = String.isNotBlank(caseRecord.Related_Party_Employer_Name__c) ? caseRecord.Related_Party_Employer_Name__c : '';
        htmlBody = htmlBody.replace('{!Defendant}', employerName);
        
        Date todayDate = Date.valueOf(caseRecord.createdDate);
        // for replace date with today's date FORMAT MM/DD/YYYY
        String month = todayDate.month() >9 ? String.valueOf(todayDate.month()) : '0'+todayDate.month();
        String day = todayDate.day() >9 ? String.valueOf(todayDate.day()) : '0'+todayDate.day();
        htmlBody = htmlBody.replace('{!filed date}', month + '/' + day + '/' + todayDate.year());
        
        emailMessage.setHtmlBody(htmlBody);
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!DIR_Case__c.Name}', caseRecord.Name);
        emailMessage.setSubject(subject);
        return emailMessage;
        
    }
}