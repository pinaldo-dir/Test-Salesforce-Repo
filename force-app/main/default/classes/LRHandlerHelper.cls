/******************************************************************************
* @author         Sapient
* @date           December 2018
* @description    
********************************************************************************************************/
@SuppressWarnings('sf:ClassWithOnlyPrivateConstructorsShouldBeFinal')
public without sharing class LRHandlerHelper {
    private static LRHandlerHelper classInstance = null;
    private LRHandlerHelper() {
        
    }
    
    public static LRHandlerHelper getInstance(){
        if (null == classInstance) {
            classInstance = new LRHandlerHelper();
        }
        return classInstance;
    }
    
    public Registration_Account__c initiateRegAccount(License_Registration__c lr, Registration_Account__c regAccount) {
        //       if ( lr.Company_type__c == 'Sole Proprietorship' && lr.Sole_prop_for_myself__c == 'Yes')
        if ( lr.Company_type__c == 'Sole Proprietorship')
            regAccount.Account__c = lr.Applicant__r.AccountId;
        //regAccount.Registration__c = lr.Id;
        regAccount.Email_Address__c = lr.Account_Email__c;
        regAccount.Corp_or_LLC_ID__c = lr.Corp_or_LLC_ID__c;
        regAccount.Date_Formed__c = lr.Date_Formed__c;          
        regAccount.Business_Phone__c = lr.Daytime_Phone__c;                
        regAccount.Daytime_Phone_Ext__c = lr.Daytime_Phone_Ext__c;                
        regAccount.Federal_Employer_Identification_Number__c = lr.Federal_Employer_Identification_Number__c;               
        regAccount.Good_standing_with_CA_Secretary_of_State__c = lr.Good_standing_with_CA_Secretary_of_State__c;               
        regAccount.Legal_Entity_Name__c = lr.Legal_Entity_Name__c;             
        regAccount.Mailing_Street__c = lr.Mailing_Address_Line_1__c;                
        regAccount.Mailing_Address_Line_2__c = lr.Mailing_Address_Line_2__c;               
        regAccount.Mailing_City__c = lr.Mailing_City__c;                
        regAccount.Mailing_Country__c = lr.Mailing_Country__c;               
        regAccount.Mailing_Zip_Code__c = lr.Mailing_Postal_Code__c;                
        regAccount.Mailing_State__c = lr.Mailing_State__c;                
        regAccount.Mobile_Phone__c = lr.Mobile_Phone__c;                
        regAccount.Physical_Business_Street__c = lr.Physical_Business_Address_Line_1__c;                
        regAccount.Physical_Business_Line_2__c = lr.Physical_Business_Address_Line_2__c;                
        regAccount.Physical_Business_City__c = lr.Physical_Business_City__c;               
        regAccount.Physical_Business_Country__c = lr.Physical_Business_Country__c;                
        regAccount.Physical_Business_Zip_Code__c = lr.Physical_Business_Postal_Code__c;                
        regAccount.Physical_Business_State__c = lr.Physical_Business_State__c;                
        regAccount.State_Employer_Identification_Number_c__c = lr.State_Employer_Identification_Number__c;                
        regAccount.State_of_Incorporation__c = lr.State_of_Incorporation__c;
        Logger.debug('######## LRHandlerHelper regAccount:' + regAccount);
        return regAccount;
        
    }
    
    public Boolean isDuplicateRegAccount( License_Registration__c newLic, ID rTypeID){
        Logger.push('isDuplicateRegAccount','LicenseRegistrationAllHandler');
        List<Registration_Account__c> currentRegs = [ SELECT RecordTypeId
                                                     , Registration__c
                                                     , Email_Address__c
                                                     , Corp_or_LLC_ID__c
                                                     , Date_Formed__c        
                                                     , Business_Phone__c          
                                                     , Daytime_Phone_Ext__c              
                                                     , Federal_Employer_Identification_Number__c          
                                                     , Good_standing_with_CA_Secretary_of_State__c             
                                                     , Legal_Entity_Name__c        
                                                     , Mailing_Street__c           
                                                     , Mailing_Address_Line_2__c          
                                                     , Mailing_City__c             
                                                     , Mailing_Country__c           
                                                     , Mailing_Zip_Code__c              
                                                     , Mailing_State__c             
                                                     , Mobile_Phone__c            
                                                     , Physical_Business_Street__c              
                                                     , Physical_Business_Line_2__c               
                                                     , Physical_Business_City__c             
                                                     , Physical_Business_Country__c              
                                                     , Physical_Business_Zip_Code__c               
                                                     , Physical_Business_State__c             
                                                     , State_Employer_Identification_Number_c__c              
                                                     , State_of_Incorporation__c 
                                                     from Registration_Account__c 
                                                     where Registration__c =: newLic.Id];
        
        for(Registration_Account__c eachReg: currentRegs)
        {
            if( eachReg.RecordTypeId == rTypeID &&
               eachReg.Registration__c == newLic.Id && 
               eachReg.Email_Address__c == newLic.Account_Email__c && 
               //eachReg.Corp_or_LLC_ID__c == newLic.Corp_or_LLC_ID__c && 
               eachReg.Date_Formed__c == newLic.Date_Formed__c &&           
               eachReg.Business_Phone__c == newLic.Daytime_Phone__c &&                 
               //eachReg.Daytime_Phone_Ext__c == newLic.Daytime_Phone_Ext__c &&                 
               eachReg.Federal_Employer_Identification_Number__c == newLic.Federal_Employer_Identification_Number__c &&                
               //eachReg.Good_standing_with_CA_Secretary_of_State__c == newLic.Good_standing_with_CA_Secretary_of_State__c &&                
               eachReg.Legal_Entity_Name__c == newLic.Legal_Entity_Name__c &&              
               eachReg.Mailing_Street__c == newLic.Mailing_Address_Line_1__c &&                 
               //eachReg.Mailing_Address_Line_2__c == newLic.Mailing_Address_Line_2__c &&                
               eachReg.Mailing_City__c == newLic.Mailing_City__c &&                 
               //eachReg.Mailing_Country__c == newLic.Mailing_Country__c &&                
               eachReg.Mailing_Zip_Code__c == newLic.Mailing_Postal_Code__c &&                 
               eachReg.Mailing_State__c == newLic.Mailing_State__c &&                 
               //eachReg.Mobile_Phone__c == newLic.Mobile_Phone__c &&                 
               eachReg.Physical_Business_Street__c == newLic.Physical_Business_Address_Line_1__c &&                 
               //eachReg.Physical_Business_Line_2__c == newLic.Physical_Business_Address_Line_2__c &&                 
               eachReg.Physical_Business_City__c == newLic.Physical_Business_City__c &&                
               //eachReg.Physical_Business_Country__c == newLic.Physical_Business_Country__c &&                 
               eachReg.Physical_Business_Zip_Code__c == newLic.Physical_Business_Postal_Code__c &&                 
               eachReg.Physical_Business_State__c == newLic.Physical_Business_State__c &&                 
               eachReg.State_Employer_Identification_Number_c__c == newLic.State_Employer_Identification_Number__c &&                 
               eachReg.State_of_Incorporation__c == newLic.State_of_Incorporation__c){
                   return false;
               }
        }
        return true;
    }
    
    public void isExistingPermitHolder(List<License_Registration__c> newList, Map<Id, License_Registration__c> oldMap){
        if(newList[0].Record_Type_Name__c != 'Entertainment_Work'){ return;}
        if(newList.isEmpty()
           || (newList[0].Status__c == 'Expired') && (newList[0].Registration_Duration__c != '10 Days - Temporary Permit') // Added to not allow 10 Days duplicate for 10 day expired - Only one in life time is allowed per child.
           //|| (newList[0].Status__c == 'Expired')
           || newList[0].Status__c == 'Closed' 
           || newList[0].Status__c == 'Closed-Rejected' 
           || newList[0].Status__c == 'Closed-Duplicate'
           ||  newList[0].Status__c == 'Pending / Defect')
        { return; }
        
        //Logger.push('checkExistingPermitHolder','RegistrationAccountAllHandler');
        //Logger.debug('Entering isExistingTempPermitHolder' + newList);
        //System.debug('#############Entering isExistingPermitHolder RegistrationAccountAllHandler' + newList);
        //
        Id recTypeIdEWP = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        
        
        if(!newList.isEmpty() 
           && newList[0].Record_Type_Name__c == 'Entertainment_Work'
           && newList[0].Service_Type__c == 'New'
           && newList[0].First_Name__c != Null 
           && newList[0].Last_Name__c !=NULL 
           && newLIst[0].Birth_Date__c !=NULL){
               List<License_Registration__c> existingLR = [ SELECT Id
                                                           , RecordTypeId
                                                           , Service_Type__c
                                                           , License_Registration_Number__c
                                                           , Registration_Duration__c
                                                           , Status__c
                                                           , Approved__c
                                                           , First_Name__c
                                                           , Last_Name__c
                                                           , Birth_Date__c
                                                           
                                                           FROM License_Registration__c
                                                              
                                                           WHERE Id !=: newList[0].Id
                                                           AND RecordTypeId =: recTypeIdEWP
                                                           AND First_Name__c =: newList[0].First_Name__c
                                                           AND Last_Name__c =: newList[0].Last_Name__c
                                                           AND Birth_Date__c =: newList[0].Birth_Date__c
                                                           AND Status__c IN ('Renewed', 'Approved', 'Resubmitted', 'Submitted', 'Pending / Defect')
                                                          ];  
               //System.debug('*****Entering ** New Registration LRhandler:' + NewList[0]);
               //System.debug('*****Entering ** existingRA LRhandler:' + existingRA);
               for(License_Registration__c eachExistingLR: existingLR){
                   
                   if(!existingLR.isEmpty()){
                       // test case 1
                       // if 6 months already exists, don't allow another 6 months
                       if (eachExistingLR.Registration_Duration__c == '6 Months - Permit'
                           && newList[0].Registration_Duration__c == '6 Months - Permit') {
                               newList[0].Registration_Duration__c.addError('The applicant cannot be added because another "6 month" permit has already been submitted or granted to this minor.  You may not apply for another 6 month permit for this minor.  Go to My Dashboard to Renew your existing permit.');
                           }
                       // test case 2
                       // if 10 day already exists, don't allow another 10 day
                       else if (eachExistingLR.Registration_Duration__c  == '10 Days - Temporary Permit'
                                && newList[0].Registration_Duration__c == '10 Days - Temporary Permit') {
                                    newList[0].Registration_Duration__c.addError('The applicant cannot be added because another "10 day" permit has already been submitted or granted to this minor.  Change the Registration Duration to 6 Months - Permit.  You may only apply for 6 month permit for this minor.');
                                }
                       // test case 3
                       // if 6 months already exists, don't allow a 10 day
                       else if (eachExistingLR.Registration_Duration__c == '6 Months - Permit'
                                && newList[0].Registration_Duration__c == '10 Days - Temporary Permit') {
                                    newList[0].Registration_Duration__c.addError('The applicant cannot be added because a "6 month" permit has already been submitted or granted to this minor.  You may not apply for a "10 day" permit for this minor.  Go to My Dashboard to Renew your existing permit.');
                                } 
                   }
               }
           }
    }


 // commented for EWP Enhancement 8.19.2021   
 /*   public void CheckValidRegistrationAge(List<License_Registration__c> newList, Map<Id, License_Registration__c> oldMap){
        //Logger.push('checkExistingPermitHolder','RegistrationAccountAllHandler');
        //Logger.debug('Entering isExistingTempPermitHolder' + newList);
        System.debug('#############Entering isExistingTempPermitHolder RegistrationAccountAllHandler' + newList);
        
        if(newList.isEmpty() 
           || newList[0].Record_Type_Name__c != 'Entertainment_Work' 
           || newList[0].Registration_Duration__c != '10 Days - Temporary Permit') 
        { return; }
        
        Id recTypeIdEWP = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        //Id recTypeIdIndvPermit = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        
        // check if the current ra matches any existing temp ra
        
        
        //List<License_Registration__c> ra = new List<License_Registration__c>();
        List<License_Registration__c> lr = new List<License_Registration__c>();
        //for(License_Registration__c lr :newList){
        lr = [SELECT Id
              , First_Name__c
              , Last_Name__c
              , Birth_Date__c
              , Registration_Duration__c
              , RecordTypeId
              FROM License_Registration__c
              WHERE Id =: newList[0].Id
              //AND RecordTypeId =: recTypeIdIndvPermit
              AND RecordTypeId =: recTypeIdEWP];
        
        if(lr.isEmpty()) { return; }
        
        if(lr[0].Birth_Date__c != NULL){
            if(validateAgeForTempEWP(lr[0].Birth_Date__c) && newList[0].Status__c != 'Expired')
            {        
                newList[0].Registration_Duration__c.addError('Minor must be between the ages of 15 days to 15 years to receive a temporary work permit.  Minors aged 16 and 17 years old must apply for the 6-months permit' + 
                                                             'Change your answer to --None-- and return to the Minor Information section to correct the minors age.');
            }
        }
    }
    
    public Boolean validateAgeForTempEWP(Date dBday)
    {
        // 'Minor must be between the ages of 15 days to 16 years to receive a temporary work permit.'
         Integer days = dBday.daysBetween(Date.Today());
         Integer months = dBday.monthsBetween(Date.Today());
         Integer age = Integer.valueOf(days/365.2425); 
         
         if(Date.Today() <= dBday.addDays(15) || Date.Today() >= dBday.addYears(16)){
            System.debug('entering validateAgeForTempEWP returning True age'+' '+dBday.addYears(16));
             return true;
        }
    
         /*if(months >= 192){
           System.debug('**********entering validateAgeForTempEWP returning True'+' '+age);
            return true;
        } */
         /*if(Date.Today() < dBday.addDays(15)){
           System.debug('**********entering validateAgeForTempEWP returning True'+' '+age);
            return true;
        }
        System.debug('entering validateAgeForTempEWP returning False age'+' '+age);
        return false; 
    }*/
    
}