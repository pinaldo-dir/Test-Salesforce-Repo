/********************************************************************************************************
Name:  CommunityRegistration.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  08/14/2017
Modified by: 
Date:
Test class: CommunityRegistrationTest.cls

Modified by: Touk Ken, SR-004558, SR-004501
Date: 09/07/2018

Behavior:
    Display My Registrations
        VF component - shows Registration (License_Registration__c) records where Account__c is related to logged-in 
        user's contact record. (print document)
    My Payments
        VF Component - shows Payment (object TBD) records where Payee__c = logged-in user's contact record.
       
********************************************************************************************************/

public class CommunityRegistration {
    
    public User currentUser {get;set;}
    private Id regRecordType; 
    public String currentRecordType {get; set;}
    private List<RecordType> registrationRecordTypes;
    Map<String,String> templateIdMap = new Map<String,String>();
    public boolean displayPopup {get; set;} 
    public boolean dupRecordFound {get; set;} 
    public String licenseRegistrationNumber;
    public String acRequestor;
    public String acRegistration;
    public DateTime acLastModifiedDate;
    public DateTime acLatestCreatedDate;
    public Boolean isInstructorBool {get; set;}
    
    //public String redirectUrl {public get; private set;}
    //public Boolean shouldRedirect {public get; private set;}
     
    public CommunityRegistration(){
        dupRecordFound = false;
        isInstructorBool = false;
        currentUser = [SELECT Id, ContactId, Contact.AccountId,FLC_Instructor__c FROM User WHERE Id =: UserInfo.getUserId()];
        //regRecordType = [SELECT DeveloperName FROM RecordType WHERE Id IN (SELECT RecordType FROM License_Registration__c Where ID = ApexPages.currentPage().getParameters().get('recId')) ];
        //registrationRecordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType='License_Registration__c' ORDER BY Name ASC];
        Map<String,String> devNames = new Map<String,String>();
        for(Registration_Template_Mapping__mdt mdt : [select id,DeveloperName,Record_Type_Developer_Name__c,Template_ID__c from Registration_Template_Mapping__mdt]){
            devNames.put(mdt.Record_Type_Developer_Name__c, mdt.Template_ID__c);
        }
        registrationRecordTypes = new List<RecordType>();
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='License_Registration__c' AND DeveloperName IN :devNames.keySet() AND IsActive = true ORDER BY Name ASC]){
            registrationRecordTypes.add(rt);
            templateIdMap.put(rt.id, devNames.get(rt.DeveloperName));
        }
        if(currentUser.FLC_Instructor__c==TRUE){    // or if null or empty string
            isInstructorBool = TRUE;
          //  new CommunityRegistration().instructorModule();
        }else{
             isInstructorBool = FALSE;
        }        
    }
    
    public List<License_Registration__c> getAllRegistrations() {
        List<Id> accApprovalId =  new List<Id>();
        
        
        try{
            List<Access_Approval__c> accApproval = [select id,Registration__c from Access_Approval__c where Approved__c='Yes' and Requestor__c= :currentUser.ContactId order by LastModifiedDate DESC];
            for(Access_Approval__c acc:accApproval){
                accApprovalId.add(acc.Registration__c);
            }
        }catch(Exception e){
            
        } 
                
        System.debug('accApprovalId--'+accApprovalId);
        
        List<License_Registration__c> regList = [SELECT Id,Renewal_Registration__c, Account__c, Account__r.Name, Account__r.Legal_Entity_Name__c, License_Registration_Number__c, toLabel(License_Registration_Type__c),
            	Date_Created__c,Submitted_Date__c, Status__c,Effective_Date__c, Expiration_Date__c, Initial_Reject_Date__c, Payment_Status__c, Status_of_payment__c, Amount_Paid__c, Amount_Due__c, Balance__c, Legal_Entity_Name__c, 
            Service_Type__c, Last_Exam_Passed_Date__c, Latest_Exam_Passed_Date__c, displayRenewalButton__c, OwnerId, Applicant__c, Registration_Duration__c, First_Name__c, Middle_Name__c, Last_Name__c
                FROM License_Registration__c WHERE (Applicant__c =: currentUser.ContactId or id in :accApprovalId) /*Account__c =: currentUser.Contact.AccountId*/ AND RecordType.Name != 'Public Works' ORDER BY CreatedDate DESC LIMIT 500];
         
         //Changes done by Shivam Goyal for REEQ 169949(Displaying renewal button for public works)       
         List<License_Registration__c> finalRegList = new List<License_Registration__c>(); 
         Integer renewalDuration = integer.valueOf(Key_Value_Store__c.getValues('Renewal Button Availability').Value__c);
         
         System.debug('renewalDuration--'+renewalDuration);
         for(License_Registration__c reg:regList){ 
            
             //King don't display the reg if owner isn't the logged-in user for public works users
             if((reg.License_Registration_Type__c=='Public Works & Prevailing Wage Contractor Registration' && reg.OwnerId != UserInfo.getUserId()) && 
                (reg.License_Registration_Type__c=='Public Works & Prevailing Wage Contractor Registration' && reg.Applicant__c != currentUser.ContactId)){
                    continue;
                }
             
             if(reg.Renewal_Registration__c!=null){
                 reg.displayRenewalButton__c=False;
             }
             //Renewal button will be displayed for active registrations having record type public works and which are expiring this year. It will be displayed from 1st may(based on custom setting) til 30th Sep
             else if(reg.License_Registration_Type__c=='Public Works & Prevailing Wage Contractor Registration' && (reg.Status__c=='Active' || reg.Status__c=='Expired') && reg.Expiration_Date__c !=null && reg.Expiration_Date__c.year()<=System.Today().year()
                     && System.Today()>=reg.Expiration_Date__c-renewalDuration){
                         reg.displayRenewalButton__c=True;
                     }
             //Renewal button will be displayed for inactive registrations having record type public works and which have already expired. It will be displayed from 1st July till 30th Sep
             else if(reg.License_Registration_Type__c=='Public Works & Prevailing Wage Contractor Registration' && reg.Status__c=='Inactive'  && reg.Expiration_Date__c !=null && reg.Expiration_Date__c.year()<=System.Today().year()
                     && System.Today()>reg.Expiration_Date__c){
                         reg.displayRenewalButton__c=True;
                     }else{
                         reg.displayRenewalButton__c=False;  
                     }
             
             finalRegList.add(reg);
             
         }
                
        return finalRegList;        
    }
    
    public void DeleteRegistration() {
        String delRecordId = ApexPages.currentPage().getParameters().get('recId');
        License_Registration__c lrDel = [SELECT Id FROM License_Registration__c WHERE Id =: delRecordId];
        delete lrDel;
    }
    
    public void PrintApplication() {
        String printRecordId = ApexPages.currentPage().getParameters().get('printId');
        License_Registration__c lrPrint = [
                SELECT Id, Approved__c, Record_Type_Name__c
                FROM License_Registration__c
                WHERE Id =: printRecordId
        ];

        if (lrPrint.Record_Type_Name__c == 'Public_Works') lrPrint.Send_PW_Affidavit__c = true;
        else lrPrint.Send_Application__c = true;

        update lrPrint;
    }
    
    public void ResendApplication() {
        String resendId = ApexPages.currentPage().getParameters().get('resendId');
        License_Registration__c lrSend = [SELECT Id, Resend_Certificate__c FROM License_Registration__c WHERE Id =: resendId];
        lrSend.Resend_Certificate__c = True;
        update lrSend;
    }
    
    public PageReference SubmitPayment() {
      
        String recordId = ApexPages.currentPage().getParameters().get('rId'); // Original
   
        //String recordId = ApexPages.currentPage().getParameters().get('Id');
            // PageReference regPage = new PageReference('/apex/CommunityCheckOrACH?id=' + recordId); // Original
            // PageReference regPage = new PageReference('/registrations/s/community-check-or-ach?recordId=' + recordId);
            // PageReference regPage = new PageReference('/registrations/s/license-registration');
            // regPage.setRedirect(true);
            // return regPage;
 
        // This is for EWP only to check defects before allowing payment so that multiple payments would not apply...
        List<Rejection_Defect__c> rejects = [SELECT Id,Registration__r.Id, Registration__r.RecordType.Name
                                             FROM Rejection_Defect__c
                                             WHERE Registration__r.Id =: recordId
                                             AND Applies__c = TRUE AND  Resolved__c = FALSE];
        if(rejects.size() > 0)
        {
            for(Rejection_Defect__c eachRej: rejects)
            {
                System.debug('rejections ....'+' '+eachRej.Registration__r.Id);
                System.debug('rejections ....'+' '+eachRej.Registration__r.RecordType.Name);
                If (eachRej.Registration__r.RecordType.Name == 'Entertainment Work'){//and if ewp
                    System.debug('After If rejects.size');
                    //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Due to Permit defected, cannot Pay');
                    //ApexPages.addMessage(msg);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'you cannot pay while defected'));
                    return null;
                }
            }
        }
          
        PageReference regPage = new PageReference('/registrations/s/community-check-or-ach?recordId=' + recordId);
        regPage.setRedirect(true);
        return regPage;
        
            //shouldRedirect = true;
            //redirectUrl = '/registrations/s/community-check-or-ach?recordId=' + recordId;
            //return null; 
                
    }
              
     
    public PageReference RenewRegistration() {
        //CBINOVI 1-24-18 The following clones the Registration and displays it in the form wizard 
        
        PageReference regPage = null;  
        String recordId = null;
        
        try{
            recordId = ApexPages.currentPage().getParameters().get('renewId'); 
        }catch(Exception e){
            System.debug('error in CommunityRegistration:' + e);
        }
        
        if(recordid=='' || recordid==null){
            System.debug('inside if--');
            recordId = ApexPages.currentPage().getParameters().get('publicowrksrenewid'); 
            System.debug('recordid2--'+recordId);            
        }
        
        currentUser = [SELECT Id, userType , ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            //Clone License Registration
            DescribeSObjectResult describeResult = License_Registration__c.sObjectType.getDescribe();
            
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            String query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' ID = :recordId ' +
              ' '
            ;
            
            //Set overriden values for cloned registration
            Map<String, String> overrideValue = new Map<String,String>();

            
            
            
            License_Registration__c toCloneLicRegObj = Database.query( query );
            //License_Registration__c newLicenseRegObj = toCloneLicRegObj.clone(false, false, false, false);
            sObject newLicenseRegObj = toCloneLicRegObj.clone(false, false, false, false);
            string recType = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosById().get(toCloneLicRegObj.RecordTypeId).getName();

            //get overrides
            //Map<String,Registration_Renewal_Field_Override__mdt> renewFieldMap = new Map<String,Registration_Renewal_Field_Override__mdt>();
            for(Registration_Renewal_Field_Override__mdt mdt : [SELECT ID, Registration_Record_Type__c, Field_API_Name__c, Value__c FROM Registration_Renewal_Field_Override__mdt]){
                if(String.isBlank(mdt.Registration_Record_Type__c) || (mdt.Registration_Record_Type__c != null && recType == mdt.Registration_Record_Type__c)){
                    //renewFieldMap.put(mdt.Field_API_Name__c + ':' + mdt.Registration_Record_Type__c, mdt);
                    //Dynamically adding field key/value.
                    if( mdt.Value__c == 'true'){
                        newLicenseRegObj.put(mdt.Field_API_Name__c, True);
                    }
                    Else IF (mdt.Value__c == 'False'){
                        newLicenseRegObj.put(mdt.Field_API_Name__c, False);
                    }
                    /*
                    Else If (mdt.Value__c.isNumeric()){
                        newLicenseRegObj.put(mdt.Field_API_Name__c, decimal.valueOf(mdt.Value__c));
                    }
                    */
                    Else{
                        newLicenseRegObj.put(mdt.Field_API_Name__c, mdt.Value__c);
                    }
                    
                    System.debug('##### Added to NewLicenseRegObj built from mdt: ' + mdt.Field_API_Name__c + ' , ' + mdt.Value__c);
                }
            }
            
            newLicenseRegObj.put('Original_Registration__c', recordId);
            newLicenseRegObj.put('License_Registration_Number__c', toCloneLicRegObj.License_Registration_number__c);
           
            
            //Changes done for bug TC-25077 - Don't copy effective date and expiration date for public works
            if(recType!='Public Works'){
            newLicenseRegObj.put('Effective_Date__c', toCloneLicRegObj.Expiration_Date__c);
            newLicenseRegObj.put('Expiration_Date__c', toCloneLicRegObj.Expiration_Date__c.addYears(1));    
            }  
            
            //tk 04/26/2019 - CPS changes          
            if(toCloneLicRegObj.Record_Type_Name__c == 'Child_Performer_Services'){
                newLicenseRegObj.put('Expiration_Date__c', toCloneLicRegObj.Expiration_Date__c.addYears(2));
            }
            
             // JK 5/19/2020 - EntPEM expiration date to blank on renewal
            if(toCloneLicRegObj.Record_Type_Name__c == 'Permit_to_Employ_Minors'){
                newLicenseRegObj.put('Expiration_Date__c', NULL);
            }
            
             // JK 4/29/2021 - FLC expiration date to blank on renewal
            if(toCloneLicRegObj.Record_Type_Name__c == 'Farm_Labor_Contractor'){
                newLicenseRegObj.put('Expiration_Date__c', NULL);
            }
            //B-000268
            //SR-007758
            
            System.debug('#####toCloneLicRegObj.Record_Type_Name__c:' + toCloneLicRegObj.Record_Type_Name__c);
            
            if(toCloneLicRegObj.Record_Type_Name__c == 'Entertainment_Work'){
                System.debug('#####toCloneLicRegObj.Status__c:' + toCloneLicRegObj.Status__c);
                newLicenseRegObj.put('Override_Default_Effective_Date__c', FALSE);
                newLicenseRegObj.put('Override_Default_Expiration_Date__c', FALSE);
                if(toCloneLicRegObj.Registration_Duration__c == '10 Days - Temporary Permit'){
                    newLicenseRegObj.put('Registration_Duration__c', '6 Months - Permit');
                    newLicenseRegObj.put('Effective_Date__c',Null);
                    newLicenseRegObj.put('Expiration_Date__c',Null);

                }
                     
                if(toCloneLicRegObj.Status__c == 'Expired'){
                    newLicenseRegObj.put('Effective_Date__c', Date.today());
                    newLicenseRegObj.put('Expiration_Date__c', Date.today().addMonths(6));
                }
                else
                {
                   newLicenseRegObj.put('Expiration_Date__c',NULL);
                   newLicenseRegObj.put('Effective_Date__c',NULL); 
                    // newLicenseRegObj.put('Expiration_Date__c', toCloneLicRegObj.Expiration_Date__c.addMonths(6));
                }   // - does not bring expiry date upon renewal - commented out for EWP enhancement - Jag.
            }
            
            newLicenseRegObj.put('Renewal__c', True);
            newLicenseRegObj.put('Internal_Notes__c', NULL);
            newLicenseRegObj.put('Ready_To_Submit__c', NULL);
            newLicenseRegObj.put('Ready_to_resubmit__c', NULL);
            newLicenseRegObj.put('Assigned_Deputy__c', NULL);
            newLicenseRegObj.Put('Imported_From__c', NULL);
            newLicenseRegObj.Put('Submitted__c', False);
            newLicenseRegObj.Put('First_Name__c',toCloneLicRegObj.First_Name__c);
            newLicenseRegObj.Put('Middle_Name__c',toCloneLicRegObj.Middle_Name__c);
            newLicenseRegObj.Put('Last_Name__c',toCloneLicRegObj.Last_Name__c);
            
            newLicenseRegObj.Put('Initial_Defect_Date__c', NULL);
            newLicenseRegObj.Put('Initial_Reject_Date__c', NULL);
            newLicenseRegObj.Put('Defect_Date__c', NULL);
            newLicenseRegObj.Put('Reject_Date__c', NULL);
            newLicenseRegObj.Put('Exam_Fee_Adjustments__c', 0);
            newLicenseRegObj.Put('Filing_Fee_Adjustments__c', 0);
            newLicenseRegObj.Put('Business_does_not_have_customers__c', FALSE);
            newLicenseRegObj.Put('Business_does_not_have_subcontractors__c', FALSE);
            newLicenseRegObj.Put('Exam_Status__c', NULL);
            newLicenseRegObj.Put('Status_Date__c', NULL);        
            newLicenseRegObj.Put('Revocation_Date__c', NULL);
            newLicenseRegObj.Put('Revocation_End_Date__c', NULL);
            newLicenseRegObj.Put('Revoked_Entities__c', NULL);
            newLicenseRegObj.Put('Closure_Reason__c', NULL);
            newLicenseRegObj.Put('Closure_Reason__c', NULL);
            newLicenseRegObj.Put('Received_Date__c', NULL);
            newLicenseRegObj.Put('Registration_Close_Date__c', NULL);
            newLicenseRegObj.Put('Regulatory_Compliance__c', NULL);
            newLicenseRegObj.Put('Business_Type__c', NULL);
            newLicenseRegObj.Put('I_Acknowledge_Garment_Manufacturer__c', FALSE);
            newLicenseRegObj.Put('Gross_Sales_for_Manufacturers__c', NULL);
            newLicenseRegObj.Put('Number_of_Registration_Exams__c', 0);
            newLicenseRegObj.Put('Exempt_Reason__c', NULL);
            newLicenseRegObj.Put('Workers_Comp_Selection__c', NULL);
            newLicenseRegObj.Put('Workers_Compensation_Carrier__c', NULL);
            newLicenseRegObj.Put('WCI_Cert_Number__c', NULL);
           newLicenseRegObj.Put('WCI_Effective_Date__c', NULL);
           newLicenseRegObj.Put('WCI_Expiration_Date__c', NULL);
           newLicenseRegObj.Put('Employee_Leasing__c', NULL);
           newLicenseRegObj.Put('Function_as_Employee_Leasing_Co__c', NULL);
           newLicenseRegObj.Put('WCI_Mailing_Address_Line_1__c', NULL);
           newLicenseRegObj.Put('WCI_Mailing_Address_Line_2__c', NULL);
           newLicenseRegObj.Put('WCI_Mailing_City_Province__c', NULL);
           newLicenseRegObj.Put('WCI_Mailing_State__c', NULL);
           newLicenseRegObj.Put('WCI_Mailing_Postal_Code__c', NULL);
           newLicenseRegObj.Put('WCI_Mailing_Country__c', NULL);            

            if(currentUser.UserType == 'CspLitePortal'){
                newLicenseRegObj.put('Submission_Type__c', 'Online');
            }
            Else{
                newLicenseRegObj.put('Submission_Type__c' , 'Paper');
            }
            If (toCloneLicRegObj.VIP_Template_Status__c != null)
            newLicenseRegObj.put('VIP_Template_Status__c', toCloneLicRegObj.VIP_Template_Status__c.Replace('Completed', 'Incomplete'));
            
            // tk 09/06/2018 SR-004558, SR-004501
            newLicenseRegObj.Put('Approval_Date_Time__c', NULL);
            newLicenseRegObj.Put('Approved__c', false);
            
            // tk 04/26/2019 CPS changes
            newLicenseRegObj.Put('isConvicted__c', NULL);
            // tk 5/14/2019 B-000224
            newLicenseRegObj.Put('I_Acknowledge_Labor_Code_Compliance__c', NULL);
            
            //Perry Security Settings Changes - set Renewer the new Submitter
            if(recType == 'Public Works'){
                newLicenseRegObj.put('Applicant__c', currentUser.ContactId);
                newLicenseRegObj.put('CertifyDate__c', date.today());
            }            
            
            System.debug('##### Ready to insert NewLicenseRegObj: ' + newLicenseRegObj);
            insert newLicenseRegObj;
            

            
            //Clone Attachment
            /*
            describeResult = Attachment.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' ParentId = :recordId ' +
              ' '
            ;
            
            List<Attachment> toAttachmentList =  Database.query( query ); 
                                            
                                            
            List<Attachment> newAttachmentList = new List<Attachment>(); 
            for(Attachment toAttachmentObj: toAttachmentList){
                Attachment newAttachmentObj = toAttachmentObj.clone(false, true, false, false);
                newAttachmentObj.ParentId = newLicenseRegObj.Id;
                newAttachmentList.add(newAttachmentObj);
            }
            insert newAttachmentList;       
            */
 /*   
            //Clone Attachment Plus (Submission Detail)
            describeResult = Attachments_Plus__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' Registration__c = :recordId ' +
              ' '
            ;           
            List<Attachments_Plus__c> toAttachmentsPlusList = Database.query( query ); 
            
            //Clone Attachment (related to Submission Detail)
            Set<Id> attPlusIds = new Set<Id>();
            for(Attachments_Plus__c ap: toAttachmentsPlusList) {
               attPlusIds.add(ap.Id); 
                
            }
            
            if(attPlusIds.size() > 0) {
                LIST <ContentDocumentLink> cdl = [ SELECT Id, ContentDocumentId, ShareType, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :attPlusIds];
                Map<Id, ContentDocumentLink> ContentDocumentLinkMap = new Map<Id, ContentDocumentLink>();                             
                for(ContentDocumentLink c: cdl) {
                    ContentDocumentLinkMap.put(c.LinkedEntityId, c);
                }
    
       
                List<Attachments_Plus__c> newAttachmentsPlusList = new List<Attachments_Plus__c>(); 
                for(Attachments_Plus__c toAttachmentsPlusObj: toAttachmentsPlusList){
                    Attachments_Plus__c newAttachmentsPlusObj = toAttachmentsPlusObj.clone(false, true, false, false);
                    newAttachmentsPlusObj.Registration__c = newLicenseRegObj.Id;
                    newAttachmentsPlusObj.Clone_For__c = toAttachmentsPlusObj.Id;
                    newAttachmentsPlusObj.Number_of_Attachments__c = null;
                    newAttachmentsPlusObj.Attachment_Needed__c = '';
                    newAttachmentsPlusList.add(newAttachmentsPlusObj);
                }
            
                insert newAttachmentsPlusList;  
               
                List<Attachments_Plus__c> ClonedAttachmentsPlus = [SELECT Id, Clone_For__c FROM Attachments_Plus__c WHERE Id IN: newAttachmentsPlusList];                               
                List<ContentDocumentLink> ContentDocumentLinkToClone = new List<ContentDocumentLink>();
                for(Attachments_Plus__c ap: ClonedAttachmentsPlus) {
                    if(ContentDocumentLinkMap.containsKey(ap.Clone_For__c)) {
                        ContentDocumentLink cdlToClone = ContentDocumentLinkMap.get(ap.Clone_For__c);
                        ContentDocumentLink newContentDocumentLink = cdlToClone.clone(false, true, false, false);
                        newContentDocumentLink.LinkedEntityId = ap.Id;
                        
                        ContentDocumentLinkToClone.add(newContentDocumentLink);
                    }
                }
                insert ContentDocumentLinkToClone;
                
            }
            
*/   //Clone Attachment Plus (Submission Detail)   
            
            //////////Clone Registration Accounts
/*            describeResult = Registration_Account__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' Registration__c = :recordId ' +
                  ' AND RecordType.Name !=  \'Trainer\'' +
              ' '
            ;               
            List<Registration_Account__c> toRegistrationAccountsList = Database.query( query ); 
                                            
            List<Registration_Account__c> newRegistrationAccountsList = new List<Registration_Account__c>(); 
            for(Registration_Account__c toRegistrationAccountsObj: toRegistrationAccountsList){
                Registration_Account__c newRegistrationAccountsObj = toRegistrationAccountsObj.clone(false, true, false, false);
                newRegistrationAccountsObj.Registration__c = newLicenseRegObj.Id;
                newRegistrationAccountsList.add(newRegistrationAccountsObj);
            }
            insert newRegistrationAccountsList;   
*/            
            
            // SR SR-009457 - Bypass code not required for EWP
            if(toCloneLicRegObj.Record_Type_Name__c != 'Entertainment_Work'){
                // tk 05/10/2019 CPS changes
                //////////Clone Live Scan Data
                describeResult = Live_Scan__c.sObjectType.getDescribe();
                
                fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                
                query =
                    ' SELECT ' +
                    String.join( fieldNames, ',' ) +
                    ' FROM ' +
                    describeResult.getName() +
                    ' WHERE ' +
                    ' Registration__c = :recordId ' +
                    ' '
                    ;               
                List<Live_Scan__c> toLiveScanList = Database.query( query ); 
                
                List<Live_Scan__c> newLiveScanList = new List<Live_Scan__c>(); 
                for(Live_Scan__c toLiveScanObj: toLiveScanList){
                    Live_Scan__c newLiveScanObj = toLiveScanObj.clone(false, true, false, false);
                    newLiveScanObj.Registration__c = newLicenseRegObj.Id;
                    newLiveScanList.add(newLiveScanObj);
                }
                insert newLiveScanList;   
                
                //////////Clone Bond
                describeResult = Bond__c.sObjectType.getDescribe();
                
                fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                
                query =
                    ' SELECT ' +
                    String.join( fieldNames, ',' ) +
                    ' FROM ' +
                    describeResult.getName() +
                    ' WHERE ' +
                    ' Registration__c = :recordId ' +
                    ' '
                    ;
                List<Bond__c> toCloneBondList = Database.query( query );                                        
                
                List<Bond__c> newBondObjList = new List<Bond__c>(); 
                for(Bond__c toCloneBondObj: toCloneBondList){
                    Bond__c newBondObj = toCloneBondObj.clone(false, false, false, false);
                    newBondObj.Registration__c = newLicenseRegObj.Id;
                    newBondObjList.add(newBondObj);
                }
                insert newBondObjList;
                
                //////////Clone DBA's :code starts
                describeResult = DBA__c.sObjectType.getDescribe();
                
                fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                
                query =
                    ' SELECT ' +
                    String.join( fieldNames, ',' ) +
                    ' FROM ' +
                    describeResult.getName() +
                    ' WHERE ' +
                    ' Registration__c = :recordId ' +
                    ' '
                    ;               
                List<DBA__c> toDBAList = Database.query( query ); 
                
                List<DBA__c> newDBAList = new List<DBA__c>(); 
                for(DBA__c toDBAObj: toDBAList){
                    DBA__c newDBAObj = toDBAObj.clone(false, true, false, false);
                    newDBAObj.Registration__c = newLicenseRegObj.Id;
                    if(newDBAObj.Active__c == 'Yes')
                    {    
                        newDBAList.add(newDBAObj);
                    }
                }
                insert newDBAList; 
                //Clone DBA's :code ends
                
                //////////Clone Registration Locations
/*                describeResult = Registration_Location__c.sObjectType.getDescribe();
                
                fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                
                query =
                    ' SELECT ' +
                    String.join( fieldNames, ',' ) +
                    ' FROM ' +
                    describeResult.getName() +
                    ' WHERE ' +
                    ' Registration__c = :recordId ' +
                    ' '
                    ;                           
                List<Registration_Location__c> toRegistrationLocationList = Database.query( query );                                            
                
                List<Registration_Location__c> newRegistrationLocationList = new List<Registration_Location__c>(); 
                for(Registration_Location__c toRegistrationLocationObj: toRegistrationLocationList){
                    Registration_Location__c newRegistrationLocationObj = toRegistrationLocationObj.clone(false, true, false, false);
                    newRegistrationLocationObj.Registration__c = newLicenseRegObj.Id;
                    if(newRegistrationLocationObj.Date_Deactivated__c == Null || newRegistrationLocationObj.Date_Deactivated__c > date.today() )
                        newRegistrationLocationList.add(newRegistrationLocationObj);
                }
                insert newRegistrationLocationList;         
*/                
                
                //////////Clone Owner
/*                describeResult = Ownership__c.sObjectType.getDescribe();
                
                fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                
                query =
                    ' SELECT ' +
                    String.join( fieldNames, ',' ) +
                    ' FROM ' +
                    describeResult.getName() +
                    ' WHERE ' +
                    ' Registration__c = :recordId ' +
                    ' '
                    ;                   
                List<Ownership__c> toOwnershipList = Database.query( query ); 
                
                List<Ownership__c> newOwnershipList = new List<Ownership__c>(); 
                for(Ownership__c toOwnershipObj: toOwnershipList){
                  
                    Ownership__c newOwnershipObj = toOwnershipObj.clone(false, true, false, false);
                    
                    newOwnershipObj.Registration__c = newLicenseRegObj.Id;
                    
                    newOwnershipList.add(newOwnershipObj);
                }
                insert newOwnershipList;
                
                // Clone Ownerhship Occupation - loop through ownership__c newOwnershipList
                describeResult = Ownership__c.sObjectType.getDescribe();
                
                fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                
                query =
                    ' SELECT ' +
                    String.join( fieldNames, ',' ) +
                    ' FROM ' +
                    describeResult.getName() +
                    ' WHERE ' +
                    ' Registration__c = :recordId ' +
                    ' '
                    ;                   
                List<Ownership__c> oldOwnershipList = Database.query( query ); 
                List<Registration_Exam__c> newOwnershipExamList = new List<Registration_Exam__c>();
                List<Ownership_Occupation__c> newOwnershipOccupationList = new List<Ownership_Occupation__c>();
                for(Ownership__c eachNewOwner: newOwnershipList){
                    // find new owners id by matching new owners with old owners by  name
 
                    for (Ownership__c eachOldOwner: oldOwnershipList){
  
                        if ((eachOldOwner.First_Name__c == eachNewOwner.First_Name__c) && (eachOldOwner.Last_Name__c == eachNewOwner.Last_Name__c))
                        {
                            
                            describeResult = Ownership_Occupation__c.sObjectType.getDescribe();
                            
                            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                            String oldOwnerID = eachOldOwner.Id;
                            // query to ownership occupation object Owners of old owner id - get the ownership occupation record to clone                            
                            query =
                                ' SELECT ' +
                                String.join( fieldNames, ',' ) +
                                ' FROM ' +
                                describeResult.getName() +
                                ' WHERE ' +
                                ' Ownership__c = :oldOwnerID ' +
                                ' '
                                ;                   
                            List<Ownership_Occupation__c> toOwnershipOccupationList = Database.query( query ); 
                            
                            newOwnershipOccupationList = new List<Ownership_Occupation__c>(); 
                            for(Ownership_Occupation__c toOwnershipOccupationObj: toOwnershipOccupationList){
                                Ownership_Occupation__c newOwnershipOccupationObj = toOwnershipOccupationObj.clone(false, true, false, false);// clone the ownership occupation 
                                newOwnershipOccupationObj.Ownership__c = eachNewOwner.Id;// set the Ownership_Occupation object(Owners_id) = new owner id 
                                newOwnershipOccupationList.add(newOwnershipOccupationObj);
                            }
                            //insert newOwnershipOccupationList;
                            
                            describeResult = Registration_Exam__c.sObjectType.getDescribe();
                            
                            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                            //String oldOwnerID = eachOldOwner.Id;
                            query =
                                ' SELECT ' +
                                String.join( fieldNames, ',' ) +
                                ' FROM ' +
                                describeResult.getName() +
                                ' WHERE ' +
                                ' Ownership__c = :oldOwnerID ' +
                                ' '
                                ;                   
                            List<Registration_Exam__c> toOwnershipExamList = Database.query( query ); 
                            
                            newOwnershipExamList = new List<Registration_Exam__c>(); 
                            for(Registration_Exam__c toOwnershipExamObj: toOwnershipExamList){
                                Registration_Exam__c newOwnershipExamObj = toOwnershipExamObj.clone(false, true, false, false);
                                newOwnershipExamObj.Ownership__c = eachNewOwner.Id;
                                newOwnershipExamList.add(newOwnershipExamObj);
                            } // for registration exam
                            //insert newOwnershipExamList;  
    
                        } // End If Ownership
                        
                    } // for oldOwnershipList
                    
                        insert newOwnershipExamList; 
                        insert newOwnershipOccupationList;
                }
*/                
                //////////Clone Training - # of employees and date of training
                // B-001188
/*                describeResult = Registration_Education__c.sObjectType.getDescribe();
                
                fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                
                query =
                    ' SELECT ' +
                    String.join( fieldNames, ',' ) +
                    ' FROM ' +
                    describeResult.getName() +
                    ' WHERE ' +
                    ' Registration__c = :recordId ' +
                    ' '
                    ;                   
                List<Registration_Education__c> toEducationList = Database.query( query ); 
                
                List<Registration_Education__c> newEducationList = new List<Registration_Education__c>(); 
                for(Registration_Education__c toEducationObj: toEducationList){
                    
                  Registration_Education__c newEducationObj = toEducationObj.clone(false, true, false, false);
                    
                    newEducationObj.Registration__c = newLicenseRegObj.Id;
                    
                    newEducationList.add(newEducationObj);
                }
                insert newEducationList;
*/                
            } 

            //////////End IF Record_Type_Name__c != 'Entertainment_Work'
            
            
            //////////Clone License Registrations
            describeResult = License_Registration__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' License__c = :recordId ' +
              ' '
            ;
            List<License_Registration__c> toCloneLicenseList = Database.query( query );                                        
                                            
            List<License_Registration__c> newLicenseObjList = new List<License_Registration__c>(); 
            for(License_Registration__c toCloneLicenseObj: toCloneLicenseList){
                License_Registration__c newLicenseObj = toCloneLicenseObj.clone(false, false, false, false);
                newLicenseObj.License__c = newLicenseRegObj.Id;
                //Perry Change License Owner CSLB
                newLicenseObj.OwnerId = UserInfo.getUserId();
                newLicenseObjList.add(newLicenseObj);
            }
            insert newLicenseObjList;            
            
            //////////Update existing record
            if(recType!='Public Works'){
              toCloneLicRegObj.Status__c = 'Renewed';  
            }else{
              toCloneLicRegObj.Renewal_Registration__c = newLicenseRegObj.id;   
            }    
            
            if(!Test.isRunningTest())
            update toCloneLicRegObj;

            //Redirect Page    
            If( currentUser.UserType == 'CspLitePortal'){
                //shouldRedirect = true;
                //redirectUrl = '/registrations/VIPForm__VIP_FormWizard?id=' + newLicenseRegObj.Id;
                //return null; 
                regPage = new PageReference('/registrations/VIPForm__VIP_FormWizard?id=' + newLicenseRegObj.Id);
            }
            else{
                regPage = new PageReference('/' + newLicenseRegObj.Id);
            }
            regPage.setRedirect(true);

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'OPTIONAL MESSAGE'));
        }
        catch(Exception e) {
            Database.RollBack(sp);
            ApexPages.addMessages(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ADDITIONAL MESSAGE'));
        }

        return regPage;

    }
    
    // jk 5/14/2020 - SR-008838
    public List<SelectOption> getRegistrationRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('a Select','Select a Registration Type'));
        for( RecordType rt: registrationRecordTypes ) {

            if(rt.Name == 'Entertainment Work') {
                options.add(new SelectOption(rt.Id,'Minors – Entertainment Work Permit'));
            }
            else if(rt.Name == 'Permit to Employ Minors') {
                options.add(new SelectOption(rt.Id,'Production – Entertainment Permit to Employ'));
            }
            else if(rt.Name == 'Child Performer Services') { 
                options.add(new SelectOption(rt.Id,'Providers – Child Performer Services'));
            }
            else if(rt.Name == 'Farm Labor Contractor') { 
                options.add(new SelectOption(rt.Id,'Farm Labor'));
            }
            else if(rt.Name == 'Garment Manufacturers and Contractors') { 
                options.add(new SelectOption(rt.Id,'Garment'));
            }
            else if(rt.Name == 'Public Works') { 
                //options.add(new SelectOption(rt.Id,'Public Works & Prevailing Wage Contractor Registration'));
            }
            else {
                options.add(new SelectOption(rt.Id,rt.Name)); 
            }
        }
        return options;
    }
    
    public void closePopup() {        
        displayPopup = false;    
    } 
    
    public pagereference checkActiveRegistration() {  
        
        if(currentRecordType=='a Select'){
            
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'To apply for a new registration, please select a valid registration type from the drop down below and click New.');
            ApexPages.addMessage(msg);
            return null;             
        }
        
        PageReference regPageRef;
        string currenttype = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosById().get(currentRecordType).getName();
        if(currenttype == 'Public Works'){
           
            currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];
            List<License_Registration__c> reglst = [SELECT Id, Status__c FROM License_Registration__c 
                                                    WHERE Applicant__c =: currentUser.ContactId
                                                    AND Status__c ='Active' 
                                                    AND License_Registration_Type__c='Public Works'];
            if(!regLst.isEmpty()){                                        
                displayPopup = true;  
                

            }else{
                
                regPageRef = AddRegistration();
            }  
        }else{
           
            regPageRef = AddRegistration();
        }
        if(regPageRef != null){
            
            return regPageRef;
        }
        else{
            
            return null; 
        }
    }
    /*public PageReference AddRegistrationnew() {
        PageReference regPage1 = AddRegistration();
        if(regPage1 != null)
            return regPage1 ;
        else
        return null;
    }*/
    public PageReference AddRegistration() {
        try{
            License_Registration__c newRegistration = new License_Registration__c();
            newRegistration.RecordTypeId = currentRecordType;
            newRegistration.Account__c = currentUser.Contact.AccountId;
            newRegistration.Applicant__c = currentUser.ContactId;
            newRegistration.Status__c = 'Incomplete';
            //newRegistration.License_Registration_Type__c = 'Car Wash';
            newRegistration.License_Registration_Type__c = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosById().get(currentRecordType).getName();
            newRegistration.License_Registration_Number__c = 'XXXXXX';
            newRegistration.VIP_Template__c = templateIdMap.get(currentRecordType);
            if(dupRecordFound){
                newRegistration.Dup_Found_Proceed__c='Yes';
            }
           
            insert newRegistration;
                        
            //shouldRedirect = true;
            //redirectUrl = '/registrations/VIPForm__VIP_FormWizard?id=' + newRegistration.Id;
            //return null; 
            
             PageReference regPage = new PageReference('/registrations/VIPForm__VIP_FormWizard?id=' + newRegistration.Id);//?id=' + newRegistration.Id);
             regPage.setRedirect(true);
             return regPage;
         }catch(Exception e){
             System.debug('error in CommunityRegistration:' + e);
//             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a valid Registration Type from the dropdown menu below.');
//             ApexPages.addMessage(msg);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
             return null;
         }

    }
    
    public PageReference LinkRegistration() {
        
            //shouldRedirect = true;
            //redirectUrl = '/registrations/CommunityRegistrationLink';
            //return null; 
        
        PageReference regPage = new PageReference('/registrations/CommunityRegistrationLink');
        regPage.setRedirect(true);
        return regPage;
    }
    
    /*public List<License_Registration__c> getAllRegistrations() {
        return [SELECT Id, Account__c, Account__r.Name, License_Registration_Number__c,
            Submitted_Date__c, Status__c, Expiration_Date__c 
                FROM License_Registration__c WHERE Account__c =: currentUser.Contact.AccountId];
    }*/
    public void displayMessage(){
        
    }
    
    public void sendLicenseRegistrationPermitPDF() {
        String permitRecordId = ApexPages.currentPage().getParameters().get('permitId');
        License_Registration__c lrSendPDF = [
            SELECT Id, Approved__c, Record_Type_Name__c
            FROM License_Registration__c
            WHERE Id =: permitRecordId
        ];
        
        if (lrSendPDF.Record_Type_Name__c == 'Entertainment_Work' 
            || lrSendPDF.Record_Type_Name__c == 'Child_Performer_Services'
            || lrSendPDF.Record_Type_Name__c == 'Janitorial'  
            || lrSendPDF.Record_Type_Name__c == 'Car_Wash' 
            || lrSendPDF.Record_Type_Name__c == 'Talent_Agency'
            || lrSendPDF.Record_Type_Name__c == 'Permit_to_Employ_Minors'
            || lrSendPDF.Record_Type_Name__c == 'Garment_Manufacturers_and_Contractors'
            || lrSendPDF.Record_Type_Name__c == 'Farm_Labor_Contractor') 
        {
            lrSendPDF.Send_License_Registration_Permit_Boolean__c = true;
        }
        
        update lrSendPDF;
    }
    
    public PageReference instructorModule() {
        String recordId = ApexPages.currentPage().getParameters().get('rId');
        PageReference regPage = new PageReference('/registrations/FLCClassAdmin?id=' + '00000000');
        regPage.setRedirect(true);
        return regPage;
    }    
}