//-----------------------------
// @author: Oswin Correa
// @date: 18/4/2018
// @description: Trigger Handler of DIR_RelatedParty Trigger on Related_Party__c object
//-----------------------------
// @modified by: Daniel Chu
// @deploy date: 1/31/2019
// @description: Fix issue with confirming employer related party whose other zip code is out of California  
//-----------------------------
//// @modified by: Ted Negussay and Curtis Wong
// @deploy date: 9/25/2020
// @description: B-000963 - Law Firm account type assigned when a Related Party's Role is Attorney for Plaintiff
// B-000978 - The picklist value of RCI Out of State is assigned in the County field on Case Management when a related party that has the role Case Employer has a out of state zipcode  
//-----------------------------
public with sharing class DIR_RelatedPartyTriggerHandler { 
    public static Boolean preventReccursion = true;
    public static Map<Id,Id> CaseWithAccountMap = new Map<Id,Id>();
    public static Map<Id,Related_Party__c> CaseWithRelatedPartyMap = new Map<Id,Related_Party__c>();
    //-----------------------------
    // @param: Map<Id,Related_Party__c> oldRelatedParties,Map<Id,Related_Party__c> newRelatedParties
    // @description: Method called on After Update of  Related_Party__c records
    // @return: void
    //-----------------------------
    
    public static void onAfterInsert(Map<Id,Related_Party__c> newRelatedParties){
        String recordTypeName_Office = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('RCI').getname();
        String recordTypeName_WCA_Office = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getname();
        Id recordTypeId_RC = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Id recordTypeId_WCA = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        Id recordTypeId_RCI_Case = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Id recordTypeId_WCA_Case = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        Id recordTypeId_Pre_Docketing_Case_Case = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('Pre Docketing Case').getRecordTypeId();
        
        Map<String,Id> zipCodes = new Map<String,Id>();
        Map<String,DIR_Case__c> casesToUpdate = new Map<String,DIR_Case__c>();
        Id officePrimaryId;
        String countyPrimary;
        Map<Id,Related_Party__c> filteredRelatedParties = new Map<Id,Related_Party__c>();
        Map<String,Related_Party__c> mapFilteredRelatedParties = new Map<String,Related_Party__c>();
        for(Zip_Code__c zcode: [Select Id, Name from Zip_Code__c]){
            zipCodes.put(zcode.Name,zcode.Id);
        }  
        for(Related_Party__c objnewRP : newRelatedParties.values()) {
            if(objnewRP.Case_Management__c != null && String.isNotBlank(objnewRP.Role__c) && (objnewRP.Role__c == 'Defendant')){
                mapFilteredRelatedParties.put(objnewRP.Id, objnewRP);
                system.debug('objRP.Zip_Code__c: '+objnewRP.Zip_Code__c);
            }
        }
        system.debug('casesToUpdate: '+mapFilteredRelatedParties);
        
        for(Related_Party__c objRP : [SELECT Id,Case_Management__c,Case_Management__r.recordTypeId,Case_Management__r.Advocate__c,
                                      Case_Management__r.Assigned_Screener__c,Case_Management__r.Assigned_Screener__r.Office__c,
                                      Case_Management__r.Intake_Origin__c,Case_Management__r.Employer__c,Case_Management__r.Claimant__c,
                                      Case_Management__r.Work_Location__c,Still_in_business__c,Case_Management__r.Office__c, Zip_Code__c,
                                      Role__c, Case_Management__r.Office_Location_Zip_Code__c 
                                      FROM Related_Party__c
                                      WHERE (Case_Management__r.recordTypeId !=: recordTypeId_Pre_Docketing_Case_Case AND Case_Management__r.Employer__c = Null 
                                             AND Case_Management__r.Online_Claim_Account__c != null AND Case_Management__r.Intake_Origin__c = 'Online' AND Role__c = 'Defendant')
                                      AND Id IN: mapFilteredRelatedParties.keyset()])
        {
            if(objRP.Role__c == 'Defendant'){
                String zipCode = objRP.Case_Management__r.Office_Location_Zip_Code__c ;
                //lets check for the Online Claim Form
                if(zipCode != null){
                    if(zipCode.length() > 5){
                        zipCode = zipCode.subString(0, 5);
                    }
                }
                
                for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c 
                                                   from Office_Zip_Code_Map__c 
                                                   where Zip_Code__c =: zipCodes.get(zipCode)])
                {
                    
                    if(objRP.Case_Management__r.recordTypeId == recordTypeId_WCA_Case && zcode.Office__r.RecordType.Name.equals(recordTypeName_WCA_Office)){
                        officePrimaryId = zcode.Office__c;
                        countyPrimary = zcode.County__c;
                    } 
                    
                }
                
                //B-000977 Fix       
                if(string.isBlank(officePrimaryId))
                {
                    for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c from Office_Zip_Code_Map__c where Office__r.Name =:'WCA - OUT OF STATE']){
                        
                        officePrimaryId = zcode.Office__c ;
                        countyPrimary = 'Outside CA';
                    }
                }
                
                //B-27763 Fix 
                if(objRP.Case_Management__r.Office__c == Null && mapFilteredRelatedParties.get(objRP.id).Role__c == 'Defendant'){
                    if(objRP.Case_Management__r.Office__c == Null){
                        casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c,County__c = countyPrimary, Office__c = officePrimaryId, Sent_Confirmation_Email__c = true));
                    }
                }
            }
        }
        system.debug('casesToUpdate: '+casesToUpdate);
        update casesToUpdate.values();
    }
    //-----------------------------
    // @param: Map<Id,Related_Party__c> oldRelatedParties,Map<Id,Related_Party__c> newRelatedParties
    // @description: Method called on After Update of  Related_Party__c records
    // @return: void
    //-----------------------------
    
    public static void onAfterUpdate(Map<Id,Related_Party__c> oldRelatedParties,Map<Id,Related_Party__c> newRelatedParties){
        
        Map<Id,Related_Party__c> filteredRelatedParties = new Map<Id,Related_Party__c>();
        Map<Id,Related_Party__c> mapRPs = new Map<Id,Related_Party__c>();
        Set<String> setAccountIds =  new Set<String>();
        Set<String> setcaseIds =  new Set<String>();
        List<Account> accounts =  new List<Account>();
        Map<Id, Related_Party__c> accountWithRelatedPartyMap = new Map<Id, Related_Party__c>();
        for(Related_Party__c objnewRP : newRelatedParties.values()){
            
            Related_Party__c objoldRP = oldRelatedParties.get(objnewRP.Id);
            
            if(objnewRP.Status__c == 'Confirm' && objnewRP.Status__c != objoldRP.Status__c && objnewRP.Role__c != 'Employer Address'){
                
                if(String.isBlank(objnewRP.Account__c) || ( String.valueof(Id.valueof(objnewRP.Account__c).getSobjectType()) == 'Account')){
                    
                    setAccountIds.add(objnewRP.Account__c);
                    setcaseIds.add(objnewRP.Case_Management__c); 
                    filteredRelatedParties.put(objnewRP.id,objnewRP);
                    //prepare data to automatically add data from the related party record to the account 
                    //when that data is missing in the account.  
                    accountWithRelatedPartyMap.put(objnewRP.Account__c, objnewRP);
                    //check for the Claimant and Associate To Representative checkbox
                    if(objnewRP.recordTypeId == OWCConstants.CLAIMANT_RELATED_PARTY_RECORD_TYPE_ID && objnewRP.Associate_the_Representative__c ){
                        CaseWithAccountMap.put(objnewRP.Case_Management__c, objnewRP.Account__c);
                        CaseWithRelatedPartyMap.put(objnewRP.Case_Management__c, objnewRP);
                    }
                }
                
                else{ 
                    
                    objnewRP.addError('Enter valid Account Id in Found_Account_ID field');
                }
            }
        }
        
        if(!filteredRelatedParties.isEmpty()){
            
            matchPersonAccountAndCreateCaseRole(filteredRelatedParties,setAccountIds,setcaseIds);
        }
        //pre-populate the Missing data on Account from Related Party
        if(!accountWithRelatedPartyMap.isEmpty()){
            System.debug('accountWithRelatedPartyMap ::: '+accountWithRelatedPartyMap);
            addMissingDataOnAccounts(accountWithRelatedPartyMap);
        }
    } 
    
    public static void addMissingDataOnAccounts(Map<Id, Related_Party__c> accountWithRelatedPartyMap){
        List<Account> accountToUpdate = new List<Account>();
        System.debug('Soql Map ::: '+[SELECT Id,recordTypeId,PersonEmail,PersonBirthdate,Phone1__c,
                                 ShippingCity,ShippingState,ShippingPostalCode,ShippingStreet,
                                 BillingCity,BillingState,BillingStreet,BillingPostalCode,
                                 Email__c,Phone,NAICS_Code__c,smagicinteract__SMSOptOut__pc,
                          		Text_Message_Opt_Out__c FROM Account
                          WHERE Id IN: accountWithRelatedPartyMap.keySet()]);
        for(Account acc: [SELECT Id,recordTypeId,PersonEmail,PersonBirthdate,Phone1__c,
                                 ShippingCity,ShippingState,ShippingPostalCode,ShippingStreet,
                                 BillingCity,BillingState,BillingStreet,BillingPostalCode,
                                 Email__c,Phone,NAICS_Code__c,smagicinteract__SMSOptOut__pc,
                          		Text_Message_Opt_Out__c FROM Account
                          WHERE Id IN: accountWithRelatedPartyMap.keySet()])
        {	
            Account accRecord = new Account();
            accRecord.Id = acc.Id;
            if(OWCConstants.PERSON_ACCOUNT_RECORD_TYPE_ID == acc.recordTypeId){ 
                accRecord.smagicinteract__SMSOptOut__pc  = accountWithRelatedPartyMap.get(acc.Id).SMS_Opt_Out__c;
                accRecord.Text_Message_Opt_Out__c  = accountWithRelatedPartyMap.get(acc.Id).SMS_Opt_Out__c; 
                if(String.isBlank(acc.PersonEmail)){ 
                    accRecord.PersonEmail = accountWithRelatedPartyMap.get(acc.Id).Email__c;
                }
                if(acc.PersonBirthdate == null){
                    accRecord.PersonBirthdate = accountWithRelatedPartyMap.get(acc.Id).Birthdate__c;
                }
                
            }else{
                if(String.isBlank(acc.Phone1__c)){
                    accRecord.Phone1__c = accountWithRelatedPartyMap.get(acc.Id).Employer_Contact__c;
                }
            }
            if(String.isBlank(acc.ShippingCity)){
                accRecord.ShippingCity = accountWithRelatedPartyMap.get(acc.Id).City__c;
            }
            
            if(String.isBlank(acc.ShippingState)){
                accRecord.ShippingState = accountWithRelatedPartyMap.get(acc.Id).State__c;
            }
            if(String.isBlank(acc.ShippingPostalCode)){
                accRecord.ShippingPostalCode = accountWithRelatedPartyMap.get(acc.Id).Zip_Code__c;
            }
            if(String.isBlank(acc.ShippingStreet)){
                accRecord.ShippingStreet = accountWithRelatedPartyMap.get(acc.Id).Street_Address__c;
            }
            if(String.isBlank(acc.BillingCity)){
                accRecord.BillingCity = accountWithRelatedPartyMap.get(acc.Id).Other_City__c;
            }
            if(String.isBlank(acc.BillingState)){
                accRecord.BillingState = accountWithRelatedPartyMap.get(acc.Id).Other_State__c;
            }
            if(String.isBlank(acc.BillingStreet)){
                accRecord.BillingStreet = accountWithRelatedPartyMap.get(acc.Id).Other_Street_Address__c;
            }
            if(String.isBlank(acc.BillingPostalCode)){
                accRecord.BillingPostalCode = accountWithRelatedPartyMap.get(acc.Id).Other_Zip_Code__c;
            }
            if(String.isBlank(acc.Email__c)){
                accRecord.Email__c = accountWithRelatedPartyMap.get(acc.Id).Email__c;
            }
            if(String.isBlank(acc.Phone)){
                accRecord.Phone = accountWithRelatedPartyMap.get(acc.Id).Phone__c;
            } 
            if(String.isBlank(acc.NAICS_Code__c)){
                accRecord.NAICS_Code__c = accountWithRelatedPartyMap.get(acc.Id).NAICS_Code__c;
            }
            
            accountToUpdate.add(accRecord); 
        }
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        List<Database.SaveResult> sr = Database.update(accountToUpdate, dml);
    }
    //-----------------------------
    // @param: Map<Id,Related_Party__c> filteredRelatedParties,Set<String> setAccountIds,Set<String> setcaseIds
    // @description: Method called to create Case Roles and match Account by fetching the value entered in Account__c
    // @return: void
    //-----------------------------
    
    private static void matchPersonAccountAndCreateCaseRole(Map<Id,Related_Party__c> filteredRelatedParties,Set<String> setAccountIds,Set<String> setcaseIds){
        
        Map<String,Schema.RecordTypeInfo> accountTRMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        
        //Fetching the appropriate Case Role and Account record types
        String recordTypeName_Office = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('RCI').getname();
        String recordTypeName_WCA_Office = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getname();
        Id recordTypeId_RC = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Id recordTypeId_WCA = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        Id recordTypeId_RCI_Case = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Id recordTypeId_WCA_Case = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        Id recordTypeId_Pre_Docketing_Case_Case = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('Pre Docketing Case').getRecordTypeId();
        Id recordTypeId_PA = accountTRMapByName.get('Person Account').getRecordTypeId();
        Id recordTypeId_BA = accountTRMapByName.get('Business Account').getRecordTypeId();
//        Id recordTypeId_LF = accountTRMapByName.get('Law Firm').getRecordTypeId();
        
        List<Case_Role__c> caseRolesToUpsert = new List<Case_Role__c>();
        Set<String> caseIds =  new Set<String>();
        Map<String,DIR_Case__c> casesToUpdate = new Map<String,DIR_Case__c>();
        Map<String,Case_Role__c> mapExistingCaseRoles = new Map<String,Case_Role__c>();
        Map<String,Case_Role__c> mapCaseRoles = new Map<String,Case_Role__c>();
        Map<String,Related_Party__c> mapFilteredRelatedParties = new Map<String,Related_Party__c>();
        Map<String,Account> mapAccountsToInsert = new Map<String,Account>();
        Map<String,Office__c> mapNewDIROffice = new Map<String,Office__c>();
        Map<String,Address__c> mapCaseToLocation = new Map<String,Address__c>();
        Map<String,Account> accounts = new Map<String,Account>();
        Map<String,Id> zipCodes = new Map<String,Id>();
		Map<Id, Id> RelatedPartyWithCaseIdMap = new Map<Id, Id>();
        Id officePrimaryId;
        Id officeSecondId;
        String countyPrimary;
        String countySecond;
        Id zipCode00000Id;
        
        for(Zip_Code__c zcode: [Select Id, Name from Zip_Code__c]){
            zipCodes.put(zcode.Name,zcode.Id);
        }        
        
        zipCode00000Id = zipCodes.get('00000'); 
        //System.debug('zipCode00000Id: '+zipCode00000Id);
        
        //Fetching existing Case Roles
        for(Case_Role__c objCR : [SELECT Id,Case__c,Entity__c
                                  FROM Case_Role__c
                                  WHERE Entity__c =: setAccountIds  
                                  AND Case__c =: setcaseIds])
        {      
            
            mapExistingCaseRoles.put(objCR.Case__c +'_'+ objCR.Entity__c,objCR); 
        }
        
        for(Account objAccount : [SELECT Id
                                  FROM Account
                                  WHERE Id =: setAccountIds])
        {
            
            accounts.put(objAccount.Id,objAccount);
            accounts.put(String.valueOf(objAccount.Id).left(15),objAccount);
        }  
        Map<Id, DIR_Case__c> CaseDataMap = new Map<Id, DIR_Case__c>();
        for(DIR_Case__c objectCase: [SELECT id, RecordTypeId FROM DIR_Case__c 
                  WHERE Id IN: setcaseIds])
        {
          CaseDataMap.put(objectCase.Id, objectCase);  
        }
        for(Related_Party__c objnewRP : filteredRelatedParties.values()){
            String caseRoleRT ;
            String caseRTid = CaseDataMap.get(objnewRP.Case_Management__c).recordTypeId;
            if(caseRTid == recordTypeId_WCA_Case || caseRTid == recordTypeId_Pre_Docketing_Case_Case){
				caseRoleRT = recordTypeId_WCA;                
            } else {
               caseRoleRT = recordTypeId_RC; 
            }
            
            //Creating Case role instance
            Case_Role__c objCaseRole =  new Case_Role__c(Case__c = objnewRP.Case_Management__c,
                                                         RecordTypeId = caseRoleRT,
                                                         Case_Role_Status__c = 'Active',
                                                         Role__c = objnewRP.Role__c);
            //Fix 
            if(objnewRP.Role__c == 'Claimant'){
                objCaseRole.Interpreter_Language__c	= objnewRP.Interpreter_Language__c;
            }
            //Fix Populate Community Account on Case Role
            if(objnewRP.Community_User_Account__c != null){
                objCaseRole.Community_User_Account__c = objnewRP.Community_User_Account__c;
            }
            //FIX Jira OWC-727
            //
            
            //B-27763 Fix
            if(String.isNotBlank(objnewRP.Role__c) && 
               (objnewRP.Role__c == 'Case Employer' || objnewRP.Role__c == 'Advocate' || 
                objnewRP.Role__c == 'Attorney for Plaintiff' ||objnewRP.Role__c == 'Claimant' 
                || objnewRP.Role__c == 'Defendant' || objnewRP.Role__c == 'Defendant - Successor')){
                
                mapFilteredRelatedParties.put(objnewRP.Id,objnewRP);
            }

			//OWC-1139 Fix
			objCaseRole.Email_Address__c =  objnewRP.Email__c;  
            
            //Case 1: When Account Id is entered in Account__c                                                    
            if(String.isNotBlank(objnewRP.Account__c)){
                
                
                //Case 2: When valid Account Id is entered in Account__c
                if(accounts.containsKey(objnewRP.Account__c)){
                    
                    objCaseRole.Entity__c = objnewRP.Account__c;
                    
                    //Appending Id if already Case Role exists to prevent duplicate creation
                    if(mapExistingCaseRoles.containsKey(objnewRP.Case_Management__c  +'_'+ objnewRP.Account__c)){
                        
                        objCaseRole.id = mapExistingCaseRoles.get(objnewRP.Case_Management__c  +'_'+ objnewRP.Account__c).Id;
                    }
                    
                    //B-24891 Fix
                    if((objnewRP.Role__c != 'Claimant') || (objnewRP.Role__c == 'Claimant' && CaseDataMap.get(objnewRP.Case_Management__c).recordTypeId != recordTypeId_RCI_Case) || objCaseRole.id != null){
                        
                        caseRolesToUpsert.add(objCaseRole);
                    }
                }
                //Case 3: When  Account entered in Account__c is not valid
                else{
                    if(mapFilteredRelatedParties.containsKey(objnewRP.Id)){
                        
                        mapFilteredRelatedParties.remove(objnewRP.Id);
                    }
                    
                    objnewRP.addError('No matching Account found for the Account ID entered in Found_Account_ID field');
                    
                }
            }
            //Case 4: When  no Account Id is entered in Account__c field
            else{
                
                //check for the Claimant and Associate To Representative checkbox
                if(objnewRP.recordTypeId == OWCConstants.CLAIMANT_RELATED_PARTY_RECORD_TYPE_ID && objnewRP.Associate_the_Representative__c ){
                    //CaseWithAccountMap.put(objnewRP.Case_Management__c, objnewRP.Account__c);
                    CaseWithRelatedPartyMap.put(objnewRP.Case_Management__c, objnewRP);
                    RelatedPartyWithCaseIdMap.put(objnewRP.Id, objnewRP.Case_Management__c);
                }
                //Case 5: Creation of Person Account fetching first name and last Name
                //String.isNotBlank(objnewRP.First_Name__c)     
                if( String.isNotBlank(objnewRP.Last_Name__c)){
                    
                    mapAccountsToInsert.put(objnewRP.Id, new Account(FirstName = objnewRP.First_Name__c, 
                                                                     middleName = objnewRP.Middle_Name__c,
                                                                     LastName = objnewRP.Last_Name__c,
                                                                     RecordTypeId = recordTypeId_PA,
                                                                     BillingCity = objnewRP.City__c,
                                                                     BillingState = objnewRP.State__c,
                                                                     BillingPostalCode = objnewRP.Zip_Code__c,
                                                                     BillingStreet = objnewRP.Street_Address__c,
                                                                     ShippingCity = objnewRP.City__c,
                                                                     ShippingState = objnewRP.State__c,
                                                                     ShippingPostalCode = objnewRP.Zip_Code__c,
                                                                     ShippingStreet = objnewRP.Street_Address__c,
                                                                     PersonMailingCity = objnewRP.City__c,
                                                                     PersonMailingPostalCode = objnewRP.Zip_Code__c,
                                                                     PersonMailingStreet = objnewRP.Street_Address__c,
                                                                     PersonOtherCity = objnewRP.Other_City__c,
                                                                     PersonOtherState = objnewRP.Other_State__c,
                                                                     PersonOtherStreet = objnewRP.Other_Street_Address__c,
                                                                     PersonOtherPostalCode = objnewRP.Other_Zip_Code__c,
                                                                     PersonEmail = objnewRP.Email__c,
                                                                     PersonBirthdate = objnewRP.Birthdate__c,
                                                                     //Email__c = objnewRP.Email__c, as per owc-835
                                                                     Type = objnewRP.Type_of_Work__c,
                                                                     PersonTitle = objnewRP.Title__c,
                                                                     Phone = objnewRP.Phone__c,
                                                                     PersonHomePhone = objnewRP.Home_Phone__c,
                                                                     PersonMobilePhone = objnewRP.Mobile_Phone__c,
                                                                     PersonOtherPhone = objnewRP.Employer_Contact__c,
                                                                     NumberOfEmployees = objnewRP.Number_of_employees__c != null ? Integer.valueOf(objnewRP.Number_of_employees__c) : null,
                                                                    	NAICS_Code__c = (objnewRP.RecordTypeId == OWCConstants.EMPLOYER_RELATED_PARTY_RECORD_TYPE_ID && objnewRP.NAICS_Code__c != null) ? objnewRP.NAICS_Code__c : null ,
                                           							smagicinteract__SMSOptOut__pc = objnewRP.SMS_Opt_Out__c,
                                           							Text_Message_Opt_Out__c = objnewRP.SMS_Opt_Out__c));
                    //B-24891 Fix
                    if(objnewRP.Role__c != 'Claimant'  || (objnewRP.Role__c == 'Claimant' && CaseDataMap.get(objnewRP.Case_Management__c).recordTypeId != recordTypeId_RCI_Case) ) {
                        
                        mapCaseRoles.put(objnewRP.Id,objCaseRole);
                    }
                    
                }
                //B-000963
                //Case 6: Creation of Law Firm Account fetching Law Firm name
                else if(String.isNotBlank(objnewRP.Business_Name__c) && (objnewRP.Role__c == 'Attorney for Plaintiff' || objnewRP.Role__c == 'Advocate')){
                    
                    mapAccountsToInsert.put(objnewRP.Id, new Account(Name = objnewRP.Business_Name__c,
                                                                     RecordTypeId = recordTypeId_BA,
                                                                     ShippingCity = objnewRP.City__c,
                                                                     ShippingState = objnewRP.State__c,
                                                                     ShippingPostalCode = objnewRP.Zip_Code__c,
                                                                     ShippingStreet = objnewRP.Street_Address__c,
                                                                     BillingCity = objnewRP.Other_City__c,
                                                                     BillingState = objnewRP.Other_State__c,
                                                                     BillingStreet = objnewRP.Other_Street_Address__c,
                                                                     BillingPostalCode = objnewRP.Other_Zip_Code__c,
                                                                     Email__c = objnewRP.Email__c,
                                                                     Type = objnewRP.Type_of_Work__c,
                                                                     Phone = objnewRP.Phone__c,
                                                                     Phone1__c = objnewRP.Employer_Contact__c,
                                                                     NumberOfEmployees = objnewRP.Number_of_employees__c != null ? Integer.valueOf(objnewRP.Number_of_employees__c) : null)); 
                    //B-24891 Fix                                                 
                    if(objnewRP.Role__c != 'Claimant'  || (objnewRP.Role__c == 'Claimant' && CaseDataMap.get(objnewRP.Case_Management__c).recordTypeId != recordTypeId_RCI_Case) ){
                        
                        mapCaseRoles.put(objnewRP.Id,objCaseRole);
                    }                                                  
                }
                //Case 7: Creation of Business Account fetching Business name
                else if(String.isNotBlank(objnewRP.Business_Name__c)){
                    
                    mapAccountsToInsert.put(objnewRP.Id, new Account(Name = objnewRP.Business_Name__c,
                                                                     RecordTypeId = recordTypeId_BA,
                                                                     ShippingCity = objnewRP.City__c,
                                                                     ShippingState = objnewRP.State__c,
                                                                     ShippingPostalCode = objnewRP.Zip_Code__c,
                                                                     ShippingStreet = objnewRP.Street_Address__c,
                                                                     BillingCity = objnewRP.Other_City__c,
                                                                     BillingState = objnewRP.Other_State__c,
                                                                     BillingStreet = objnewRP.Other_Street_Address__c,
                                                                     BillingPostalCode = objnewRP.Other_Zip_Code__c,
                                                                     Email__c = objnewRP.Email__c,
                                                                     Type = objnewRP.Type_of_Work__c,
                                                                     Phone = objnewRP.Phone__c,
                                                                     Phone1__c = objnewRP.Employer_Contact__c,
                                                                     NumberOfEmployees = objnewRP.Number_of_employees__c != null ? Integer.valueOf(objnewRP.Number_of_employees__c) : null,
                                                                     NAICS_Code__c = (objnewRP.RecordTypeId == OWCConstants.EMPLOYER_RELATED_PARTY_RECORD_TYPE_ID && objnewRP.NAICS_Code__c != null) ? objnewRP.NAICS_Code__c : null )); 
                    //B-24891 Fix                                                 
                    if(objnewRP.Role__c != 'Claimant'  || (objnewRP.Role__c == 'Claimant' && CaseDataMap.get(objnewRP.Case_Management__c).recordTypeId != recordTypeId_RCI_Case) ){
                        
                        mapCaseRoles.put(objnewRP.Id,objCaseRole);
                    }                                                  
                }
            }
        }
        system.debug('mapAccountsToInsert: '+mapAccountsToInsert);
        //insert mapAccountsToInsert.values();
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        List<Database.SaveResult> sr = Database.insert(mapAccountsToInsert.values(), dml);
        //insert mapAccountsToInsert.values();
        //prepare the Associate Representative Data when new Account is created for Related Party
        for(Id relatedPartyId: mapAccountsToInsert.keySet()){
            if(RelatedPartyWithCaseIdMap.containsKey(relatedPartyId)){
                CaseWithAccountMap.put(RelatedPartyWithCaseIdMap.get(relatedPartyId), mapAccountsToInsert.get(relatedPartyId).Id);
            }
        }
        system.debug('RelatedPartyWithCaseIdMap: '+RelatedPartyWithCaseIdMap);
        system.debug('CaseWithAccountMap: '+CaseWithAccountMap);
        system.debug('CaseWithRelatedPartyMap: '+CaseWithRelatedPartyMap);
        for(Account objAccount : [SELECT Id,Employer_No_Longer_Operating__c,Imported_From__c,Fax,DBA__c,Attention_To1__c
                                  FROM Account
                                  WHERE Id =: setAccountIds OR Id =: mapAccountsToInsert.values()])
        {
            
            accounts.put(objAccount.Id,objAccount);
            accounts.put(String.valueOf(objAccount.Id).left(15),objAccount);
        }                                                        
        
        List<Address__c> locations =  new List<Address__c>();        
        
        for(Related_Party__c objRP : [SELECT Id,First_Name__c,Middle_Name__c,Last_Name__c,Case_Management__c,Case_Management__r.recordTypeId,Case_Management__r.Advocate__c,Case_Management__r.Assigned_Screener__c,
                                      Case_Management__r.Assigned_Screener__r.Office__c,Case_Management__r.Employer__c,
                                      Case_Management__r.Claimant__c,Case_Management__r.Work_Location__c,Still_in_business__c,
                                      Case_Management__r.Office__c, Zip_Code__c, Case_Management__r.Office_Location_Zip_Code__c,
                                      Case_Management__r.Online_Claim_Account__c   
                                      FROM Related_Party__c
                                      WHERE (Case_Management__r.Employer__c = Null OR Case_Management__r.Claimant__c = Null 
                                             OR Case_Management__r.Work_Location__c = Null)
                                      AND Id =: mapFilteredRelatedParties.keyset()])
        {
            
            Account objAccount;
            
            if(mapAccountsToInsert.containsKey(objRP.Id)){
                
                objAccount = accounts.get(mapAccountsToInsert.get(objRP.Id).Id); 
            }
            else if(String.isNotBlank(mapFilteredRelatedParties.get(objRP.Id).Account__c) && accounts.containsKey(mapFilteredRelatedParties.get(objRP.Id).Account__c)){
                
                objAccount = accounts.get(mapFilteredRelatedParties.get(objRP.Id).Account__c);
                
            }
            
            if(objAccount != Null){
                
                Related_Party__c objnewRP = mapFilteredRelatedParties.get(objRP.Id);
                
                //B-27763 Fix 
                if(objnewRP.Status__c == 'Confirm' && objnewRP.Role__c == 'Case Employer'){
                    
                    caseIds.add(objRP.Case_Management__c);
                    
                }
                String officeNameOutOfState ;
                
                String zipCode;
                if(objRP.Case_Management__r.Online_Claim_Account__c != null){
                    zipCode = objRP.Case_Management__r.Office_Location_Zip_Code__c ;
                } else {
                    zipCode = objRP.Zip_Code__c;
                }
                if(zipCode != null){
                    if(zipCode.length() > 5){
                        zipCode = zipCode.subString(0, 5);
                    }
                }
                for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c 
                                                   from Office_Zip_Code_Map__c 
                                                   where Zip_Code__c =: zipCodes.get(zipCode)])
                {
                    
                    if(objRP.Case_Management__r.recordTypeId == recordTypeId_WCA_Case ){
                        officeNameOutOfState = 'WCA - OUT OF STATE';
                        if(zcode.Office__r.RecordType.Name.equals(recordTypeName_WCA_Office)){
                            officePrimaryId = zcode.Office__c;
                            countyPrimary = zcode.County__c;
                        }
                    }
                    else if(objRP.Case_Management__r.recordTypeId == recordTypeId_RCI_Case){
                        officeNameOutOfState = 'RCI - OUT OF STATE';
                        if(zcode.Office__r.RecordType.Name.equals(recordTypeName_Office)){
                            officePrimaryId = zcode.Office__c;
                            countyPrimary = zcode.County__c;
                        }
                    }
                }
                
                //B-000977 Fix       
                if(string.isBlank(officePrimaryId))
                {
                    for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c from Office_Zip_Code_Map__c where Office__r.Name =: officeNameOutOfState]){
                        
                        officePrimaryId = zcode.Office__c ;
                        countyPrimary = 'Outside CA';
                    }
                }
                system.debug('officePrimaryId: '+officePrimaryId);
                //B-27763 Fix 
                if((objRP.Case_Management__r.Employer__c == Null || objRP.Case_Management__r.Office__c == Null) && (mapFilteredRelatedParties.get(objRP.id).Role__c == 'Case Employer' || (objRP.Case_Management__r.Online_Claim_Account__c != null && mapFilteredRelatedParties.get(objRP.id).Role__c == 'Defendant') )){
                    
                    if(objRP.Case_Management__r.Employer__c == Null && objRP.Case_Management__r.Office__c == Null){
                        casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c, Employer__c = objAccount.Id, County__c = countyPrimary, Office__c = officePrimaryId));
                    }
                    
                    else if(objRP.Case_Management__r.Employer__c == Null){
                        casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c, Employer__c = objAccount.Id));
                    }
                    
                    else if(objRP.Case_Management__r.Office__c == Null){
                        casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c,County__c = countyPrimary, Office__c = officePrimaryId));
                    }
                    
                }
                
                //B-27763 Fix 
                else if(objRP.Case_Management__r.Advocate__c == Null && (mapFilteredRelatedParties.get(objRP.id).Role__c == 'Advocate' || mapFilteredRelatedParties.get(objRP.id).Role__c == 'Attorney for Plaintiff')){
                    
                    casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c, Advocate__c = objAccount.Id));
                }
                
                else if(objRP.Case_Management__r.Claimant__c == Null && mapFilteredRelatedParties.get(objRP.id).Role__c == 'Claimant'){
                    
                    casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c,Claimant__c = objAccount.Id, Employee_First_Name__c = objRP.First_Name__c,Employee_Middle_Name__c = objRP.Middle_Name__c, Employee_Last_Name__c = objRP.Last_Name__c));
                }
                
            }
            
        }
        
        update casesToUpdate.values();
        
        //Linking newly created accounts to Case Roles
        for(String rpId : mapCaseRoles.keyset()){
            
            Case_Role__c objCaseRole = mapCaseRoles.get(rpId);
            objCaseRole.Entity__c = mapAccountsToInsert.get(rpId).Id;
            caseRolesToUpsert.add(objCaseRole);
        }
        system.debug('caseRolesToUpsert: '+caseRolesToUpsert);
        upsert caseRolesToUpsert;
        
        List<Related_Party__c> parties =  new List<Related_Party__c>();
        Map<Id,String> zipCode =  new Map<Id,String>();
        
        accounts.clear();
        
        Address__c location;
        
        for(Related_Party__c objRP : [   SELECT Id, Zip_Code__c, State__c, City__c, Street_Address__c, Other_Zip_Code__c,Other_State__c,Other_City__c,Other_Street_Address__c,
                                      Number_of_employees__c,Still_in_business__c,Phone__c,Case_Management__c,Case_Management__r.Employer__r.IsPersonAccount,
                                      Case_Management__r.Employer__c,Case_Management__r.Employer__r.Employer_No_Longer_Operating__c,
                                      Case_Management__r.Employer__r.Attention_To1__c,Case_Management__r.Employer__r.Imported_From__c,
                                      Case_Management__r.Employer__r.Fax,Case_Management__r.Employer__r.DBA__c
                                      FROM Related_Party__c
                                      WHERE Case_Management__c =: caseIds
                                      AND Role__c = 'Employer Address'
                                      AND Status__c != 'Confirm'
                                      AND Case_Management__r.Employer__c != Null
                                      AND Other_Zip_Code__c != Null])
        {
            
            //System.debug('objRP -------------- '+objRP);
            //System.debug('objRP.Other_Zip_Code__c ------------ '+objRP.Other_Zip_Code__c);
            
            if(zipCodes.containsKey(objRP.Other_Zip_Code__c)){
                
                zipCode.put(zipCodes.get(objRP.Other_Zip_Code__c),objRP.Other_Zip_Code__c);
            }
            //SR-005287: fixes the issue with confirming out of CA zip codes
            //Zip Code: 00000 is an arbitrary zip code to hold employer with out of CA address zip codes
            else{
                
                zipCode.put(zipCode00000Id,'00000');     
            }
            
            
            location = new Address__c(Entity__c = objRP.Case_Management__r.Employer__c,
                                      Work_Performed_at_this_Location__c = !objRP.Case_Management__r.Employer__r.Employer_No_Longer_Operating__c,
                                      Type__c = 'Business Location',
                                      Active_Location__c = true,
                                      Total_Employees__c = objRP.Number_of_employees__c != null ? Integer.valueOf(objRP.Number_of_employees__c) : null,
                                      Phone__c = objRP.Phone__c,
                                      Imported_From__c = objRP.Case_Management__r.Employer__r.Imported_From__c,
                                      Fax__c = objRP.Case_Management__r.Employer__r.Fax,
                                      Employer_Still_Operating_Here__c = objRP.Still_in_business__c,
                                      DBA__c = objRP.Case_Management__r.Employer__r.DBA__c,  
                                      Attention_To__c = objRP.Case_Management__r.Employer__r.Attention_To1__c);
            
            
            location.City__c = objRP.Other_City__c;
            location.State__c = objRP.Other_State__c;
            location.Zip_Code__c = objRP.Other_Zip_Code__c;
            location.Address__c = String.isNotBlank(objRP.Other_Street_Address__c) ? objRP.Other_Street_Address__c : '';
            location.Address__c = location.Address__c.removeEnd(',');  
            objRP.Status__c = 'Confirm';
            parties.add(objRP);
            mapCaseToLocation.put(objRP.Case_Management__c,  location);
            locations.add(location);
            
        }
        
        insert locations;            
        
        casesToUpdate.clear();
        
        //System.debug('zipCode ---- '+zipCode);
        //System.debug(' query zipcode ---- '+[Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c from Office_Zip_Code_Map__c where Zip_Code__c = :zipCode.keyset()]);
        
        for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c from Office_Zip_Code_Map__c where Zip_Code__c =: zipCode.keyset()]){
            /*
            //System.debug('zcode ---------- '+zcode);
            if(objRP.Case_Management__r.recordTypeId == recordTypeId_WCA_Case && zcode.Office__r.RecordType.Name.equals(recordTypeName_WCA_Office)){
                officeSecondId = zcode.Office__c;
                countySecond = zcode.County__c;
            } else if(objRP.Case_Management__r.recordTypeId == recordTypeId_RCI_Case && zcode.Office__r.RecordType.Name.equals(recordTypeName_Office)){
                officeSecondId = zcode.Office__c;
                countySecond = zcode.County__c;
            }
            */
            if(zcode.Office__r.RecordType.Name.equals(recordTypeName_Office)){
                
                officeSecondId = zcode.Office__c;
                countySecond = zcode.County__c;
                
            } 
        }
        
        //System.debug('officeSecondId ----- '+officeSecondId);
        //System.debug('countySecond ----- '+countySecond);
        
        for(String caseId :  mapCaseToLocation.keyset()){
            casesToUpdate.put(caseId, new DIR_Case__c(Work_Location__c = mapCaseToLocation.get(caseId).Id, WorkAddressDifferent__c = 'Yes', Id = caseId, Office__c = officeSecondId, County__c = countySecond)); 
        }
        
        update casesToUpdate.values();
        //System.debug('casesToUpdate ----- '+casesToUpdate);
        update parties;
        associateRepresentativeWithClaimant();
    }
    
    //populate office based on Related Party Address
    public static void associateRepresentativeWithClaimant(){
        
        List<Case_Role__c> caseRoleToUpdate = new List<Case_Role__c>();
        for(Case_Role__c cr: [SELECT id,Case__c, Also_Related_To__c, Relationship_to_Claimant__c FROM Case_Role__c
                             WHERE Case__c IN: caseWithAccountMap.keySet() AND (Role__c = 'Advocate' OR Role__c = 'Attorney for Plaintiff')])
        {	
            cr.Also_Related_To__c = caseWithAccountMap.get(cr.Case__c);
            cr.Relationship_to_Claimant__c = caseWithRelatedPartyMap.get(cr.Case__c).Relationship_Description__c ;
            caseRoleToUpdate.add(cr);
        }
        update caseRoleToUpdate;
        system.debug('caseRoleToUpdate: '+caseRoleToUpdate);
    }
}