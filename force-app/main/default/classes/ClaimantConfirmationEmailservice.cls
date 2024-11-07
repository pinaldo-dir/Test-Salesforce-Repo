global class ClaimantConfirmationEmailservice implements Messaging.InboundEmailHandler {
    public static String templateLang = 'English';
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope envelop){
        String wca_Case_RecordType_Id = OWCConstants.WCA_CASE_RECORD_TYPE_ID;
        String garment_Case_RecordType_Id = OWCConstants.Garment_CASE_RECORD_TYPE_ID;
        String garment_Office_Los_Angeles = OWCConstants.Garment_Office_Los_Angeles;
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String emailTemplateName = '';
        String accname = email.fromName;
        system.debug('fromAddress: '+email.fromAddress);
        String emailBody = email.plainTextBody;
        emailBody = emailBody.toLowerCase();
        String subject = email.Subject;
        system.debug('subject: '+subject);
        system.debug('emailBody: '+emailBody);
        if(subject.containsIgnoreCase('Confirmation') || subject.containsIgnoreCase('Confirmación')){
            String caseName = subject.substringBetween('(', ')');
            List<DIR_Case__c>  cseList = [SELECT Id,Case_Number__c,Name,Advocate_Name_in_Text__c ,
                                          Related_Party_Employer_Name__c,Claimant_Name_in_Text__c, 
                                          Related_Party_Employee_Email__c, Status__c,County__c,Office__c,
                                          Date_of_Docket__c,Applicant_Type__c  
                                          FROM DIR_Case__c 
                                          WHERE Name = : caseName AND Status__c = 'Not Confirmed'];
            if(!cseList.isEmpty() && cseList.size() >0){
                if(emailBody.containsIgnoreCase('email.fromAddress')){
                    emailBody = emailBody.split(email.fromAddress.toLowerCase())[0];
                } else if(emailBody.containsIgnoreCase('hello')){
                    emailBody = emailBody.split('hello')[0];
                } else if(emailBody.containsIgnoreCase('wrote')){
                    emailBody = emailBody.split('wrote')[0];
                } else if(emailBody.containsIgnoreCase('noreply@salesforce.com')){
                    emailBody = emailBody.split('noreply@salesforce.com')[0];
                    
                }
                
                //create the Claimant Confirmation record
                Claimant_Confirmation__c  cc = new Claimant_Confirmation__c ();
                cc.Case_Management__c = cseList[0].Id;
                if(emailBody.length() > 10000){
                    cc.Claimant_response__c = emailBody.substring(0, 9999); 
                } else{
                    cc.Claimant_response__c = emailBody; 
                } 
                if(subject.containsIgnoreCase('Confirmation') || subject.containsIgnoreCase('confirmation')){
                    emailBody = emailBody.remove('Confirmation');
                    emailBody = emailBody.remove('confirmation');
                    
                    system.debug('email.fromAddress: '+email.fromAddress);
                    Integer confirmIndex = emailBody.indexOfIgnoreCase('confirm');
                    Integer denyIndex = emailBody.indexOfIgnoreCase('deny');
                    //Integer wroteIndex = emailBody.split('wrote')[0];
                    system.debug('emailBody: '+emailBody);
                    //System.debug(confirmIndex + ' -- ' + denyIndex + ' -- '+ wroteIndex);
                    if(emailBody.containsIgnoreCase('confirm') && emailBody.containsIgnoreCase('deny')){
                        // NOT VALID Response
                        emailTemplateName = 'Claim Email Reply INVALID';
                        insert cc;
                        
                        List<DIR_Case__c>  caseList = [SELECT Id,Case_Number__c,Name,Advocate_Name_in_Text__c ,recordTypeId,
                                                       Related_Party_Employer_Name__c,Claimant_Name_in_Text__c, Related_Party_Employee_Email__c,
                                                       Status__c,Office__c,Office__r.Name,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c 
                                                       FROM DIR_Case__c 
                                                       WHERE Id =: cseList[0].Id];
                        
                        // set auto reply mail to the end user.
                        OCEmailServiceUtility.sendAutoResponse(caseList, emailTemplateName, caseList[0].Related_Party_Employee_Email__c);
                        
                    }
                    else if((emailBody.containsIgnoreCase('confirm') ) ){
                        cseList[0].Status__c = 'New';
                        if(cseList[0].Applicant_Type__c == 'Representative Garment'){
                            emailTemplateName = 'Claim Email Reply Confirm Garment';
                            //update case RecordType to Garment
                            cseList[0].recordTypeId = garment_Case_RecordType_Id;
                            cseList[0].Office__c = garment_Office_Los_Angeles;
                        } else {
                            // CONFIRM Response
                            emailTemplateName = 'Claim Email Reply Confirm';
                            //update case RecordType to WCA
                            cseList[0].recordTypeId = wca_Case_RecordType_Id;
                            cseList[0] = OWCServiceUtility.populateOfficeOnCM(cseList[0]);
                        }
                        system.debug('emailTemplateName: '+emailTemplateName);
                        cc.Claimant_Confirmation__c = 'Confirm';
                        cc.Case_Promoted__c = true;
                        	
                        //get Current Time as per Org Time Zone
                        DateTime currenTime = System.now();
                        cseList[0].Date_of_Docket__c = OWCOnlineClaimFormService.nextBusinessDate();
                        /*
                        // Get the default business hours
                        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
                        // Find whether the time is within the default business hours
                        Boolean isWithin= BusinessHours.isWithin(bh.id, currenTime);
                        //lets set the next business datetime if current time is outside of business hours
                        
                        
                        if(isWithin){
                            cseList[0].Date_of_Docket__c = OWCOnlineClaimFormService.nextBusinessDate();
                        }
                        else{
                            Datetime nextStart = BusinessHours.nextStartDate(bh.id, currenTime);
                            nextStart = nextStart;//OWCOnlineClaimFormService.getTimeInOrgTimeZone(nextStart);
                            cseList[0].Date_of_Docket__c = nextStart.dateGMT();
                        }
                        */
                        update cseList[0];
                        insert cc;
                        
                        List<DIR_Case__c>  caseList = [SELECT Id,Case_Number__c,Name,Advocate_Name_in_Text__c ,recordTypeId,
                                                       Related_Party_Employer_Name__c,Claimant_Name_in_Text__c, Related_Party_Employee_Email__c,
                                                       Status__c,Office__c,Office__r.Name,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c,
                                                       Closure_Disposition__c
                                                       FROM DIR_Case__c 
                                                       WHERE Id =: cseList[0].Id];
                        
                        // set auto reply mail to the end user.
                        OCEmailServiceUtility.sendAutoResponse(caseList, emailTemplateName,caseList[0].Related_Party_Employee_Email__c);
                        
                    }else if(emailBody.containsIgnoreCase('deny') ) {   //(denyIndex < confirmIndex)
                        // DENY Response
                        emailTemplateName = 'Claim Email Reply Deny';
                        cc.Claimant_Confirmation__c = 'Deny';
                        cc.Case_Promoted__c = false;
                        cseList[0].Closure_Disposition__c = 'Closed for Lack of Claimant Confirmation';
                        cseList[0].Case_Closed_Date__c = Date.today();
                        cseList[0].Status__c = 'Closed';
                        cseList[0].Sent_Confirmation_Email__c = true;
                        update cseList[0];
                        insert cc;
                        
                        List<DIR_Case__c>  caseList = [SELECT Id,Case_Number__c,Name,Advocate_Name_in_Text__c ,recordTypeId,
                                                       Related_Party_Employer_Name__c,Claimant_Name_in_Text__c, Related_Party_Employee_Email__c,
                                                       Status__c,Office__c,Office__r.Name,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c,
                                                       Related_Party_Advocate_Email__c
                                                       FROM DIR_Case__c 
                                                       WHERE Id =: cseList[0].Id];
                        
                        // set auto reply mail to the end user.
                        OCEmailServiceUtility.sendAutoResponse(caseList, emailTemplateName,caseList[0].Related_Party_Employee_Email__c);
                        
                        //send the Case Closer response to the Advocate
                        if(caseList[0].Related_Party_Advocate_Email__c != null){
                            OCEmailServiceUtility.sendAutoResponse(caseList, 'Advocate Email Reply Deny', caseList[0].Related_Party_Advocate_Email__c);  
                        }
                        
                    }
                    else {
                        // NOT VALID Response
                        emailTemplateName = 'Claim Email Reply INVALID';
                        insert cc;
                        
                        List<DIR_Case__c>  caseList = [SELECT Id,Case_Number__c,Name,Advocate_Name_in_Text__c ,recordTypeId,
                                                       Related_Party_Employer_Name__c,Claimant_Name_in_Text__c, Related_Party_Employee_Email__c,
                                                       Status__c,Office__c,Office__r.Name,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c 
                                                       FROM DIR_Case__c 
                                                       WHERE Id =: cseList[0].Id];
                        
                        // set auto reply mail to the end user.
                        OCEmailServiceUtility.sendAutoResponse(caseList, emailTemplateName, caseList[0].Related_Party_Employee_Email__c);
                        
                        
                    }
                    system.debug('emailTemplateName: '+emailTemplateName);
                }
                else if(subject.containsIgnoreCase('Confirmación') || subject.containsIgnoreCase('confirmación')){
                    templateLang = 'es';
                    //for spanish	confirmación 
                    emailBody = emailBody.remove('Confirmación');
                    emailBody = emailBody.remove('confirmación');
                    system.debug('email.fromAddress: '+email.fromAddress);
                    Integer confirmIndex = emailBody.indexOfIgnoreCase('confirmar');
                    Integer denyIndex = emailBody.indexOfIgnoreCase('negar');
                    //Integer wroteIndex = emailBody.split('wrote')[0];
                    system.debug('emailBody: '+emailBody);
                    //System.debug(confirmIndex + ' -- ' + denyIndex + ' -- '+ wroteIndex);
                    if(emailBody.containsIgnoreCase('confirmar') && emailBody.containsIgnoreCase('negar')){
                        // NOT VALID Response
                        emailTemplateName = 'Claim Email Reply INVALID_es';
                        insert cc;
                        system.debug('todayDate:invalid '+emailBody);
                        List<DIR_Case__c>  caseList = [SELECT Id,Case_Number__c,Name,Advocate_Name_in_Text__c ,recordTypeId,
                                                       Related_Party_Employer_Name__c,Claimant_Name_in_Text__c, Related_Party_Employee_Email__c,
                                                       Status__c,Office__c,Office__r.Name,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c 
                                                       FROM DIR_Case__c 
                                                       WHERE Id =: cseList[0].Id];
                        
                        // set auto reply mail to the end user.
						
                        OCEmailServiceUtility.sendAutoResponse(caseList, emailTemplateName, caseList[0].Related_Party_Employee_Email__c);
                        
                    }
                    else if((emailBody.containsIgnoreCase('confirmar') ) ){
                        //check for Garment
                        if(cseList[0].Applicant_Type__c == 'Representative Garment'){
                            emailTemplateName = 'Claim Email Reply Confirm_es Garment';
                        } else {
                            // CONFIRM Response
                            emailTemplateName = 'Claim Email Reply Confirm_es';
                        }
                        
                        cc.Claimant_Confirmation__c = 'Confirm';
                        cc.Case_Promoted__c = true;
                        cseList[0].Status__c = 'New';	
                        //get Current Time as per Org Time Zone
                        DateTime currenTime = System.now();
                        // Get the default business hours
                        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
                        // Find whether the time is within the default business hours
                        Boolean isWithin= BusinessHours.isWithin(bh.id, currenTime);
                        //lets set the next business datetime if current time is outside of business hours
                        cseList[0].Date_of_Docket__c = OWCOnlineClaimFormService.nextBusinessDate();
                        /*
                        if(isWithin){
                            cseList[0].Date_of_Docket__c = currenTime.dateGMT();
                        }
                        else{
                            Datetime nextStart = BusinessHours.nextStartDate(bh.id, currenTime);
                            nextStart = nextStart;//OWCOnlineClaimFormService.getTimeInOrgTimeZone(nextStart);
                            cseList[0].Date_of_Docket__c = nextStart.dateGMT();
                        }
                        */
                        cseList[0] = OWCServiceUtility.populateOfficeOnCM(cseList[0]);
                        update cseList[0];
                        insert cc;
                        
                        List<DIR_Case__c>  caseList = [SELECT Id,Case_Number__c,Name,Advocate_Name_in_Text__c ,recordTypeId,
                                                       Related_Party_Employer_Name__c,Claimant_Name_in_Text__c, Related_Party_Employee_Email__c,
                                                       Status__c,Office__c,Office__r.Name,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c,
                                                       Closure_Disposition__c
                                                       FROM DIR_Case__c 
                                                       WHERE Id =: cseList[0].Id];
                        
                        // set auto reply mail to the end user.
                        OCEmailServiceUtility.sendAutoResponse(caseList, emailTemplateName,caseList[0].Related_Party_Employee_Email__c);
                        
                    }else if(emailBody.containsIgnoreCase('negar') ) {   //(denyIndex < confirmIndex)
                        // DENY Response
                        emailTemplateName = 'Claim Email Reply Deny_es';
                        cc.Claimant_Confirmation__c = 'Deny';
                        cc.Case_Promoted__c = false;
                        cseList[0].Closure_Disposition__c = 'Closed for Lack of Claimant Confirmation';
                        cseList[0].Case_Closed_Date__c = Date.today();
                        cseList[0].Status__c = 'Closed';
                        cseList[0].Sent_Confirmation_Email__c = true;
                        update cseList[0];
                        insert cc;
                        
                        List<DIR_Case__c>  caseList = [SELECT Id,Case_Number__c,Name,Advocate_Name_in_Text__c ,recordTypeId,
                                                       Related_Party_Employer_Name__c,Claimant_Name_in_Text__c, Related_Party_Employee_Email__c,
                                                       Status__c,Office__c,Office__r.Name,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c,
                                                       Related_Party_Advocate_Email__c
                                                       FROM DIR_Case__c 
                                                       WHERE Id =: cseList[0].Id];
                        
                        // set auto reply mail to the end user.
                        OCEmailServiceUtility.sendAutoResponse(caseList, emailTemplateName,caseList[0].Related_Party_Employee_Email__c);
                        
                        //send the Case Closer response to the Advocate
                        if(caseList[0].Related_Party_Advocate_Email__c != null){
                            OCEmailServiceUtility.sendAutoResponse(caseList, 'Advocate Email Reply Deny', caseList[0].Related_Party_Advocate_Email__c);  
                        }
                        
                    }
                    else {
                        // NOT VALID Response
                        emailTemplateName = 'Claim Email Reply INVALID_es';
                        insert cc;
                        
                        List<DIR_Case__c>  caseList = [SELECT Id,Case_Number__c,Name,Advocate_Name_in_Text__c ,recordTypeId,
                                                       Related_Party_Employer_Name__c,Claimant_Name_in_Text__c, Related_Party_Employee_Email__c,
                                                       Status__c,Office__c,Office__r.Name,DIR_WCA_Office_Address__c,DIR_Office_Phone_Number__c 
                                                       FROM DIR_Case__c 
                                                       WHERE Id =: cseList[0].Id];
                        
                        // set auto reply mail to the end user.
                        OCEmailServiceUtility.sendAutoResponse(caseList, emailTemplateName, caseList[0].Related_Party_Employee_Email__c);
                        
                        
                    }
                    system.debug('emailTemplateName: '+emailTemplateName);
                }
                
            }
            
        }
        return null;
    }
    
}