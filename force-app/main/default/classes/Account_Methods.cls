public class Account_Methods {
    Public static Boolean firstcall = false;
    public static Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    public static void beforeInsert(list<Account> newList){
        //after insert method calls
        // Update the Low Wage Industry selection
        updateIndustrySelection(newList);
    }
    
    // after insert method calls
    public static void afterInsert(list<Account> newList){
        addPrimaryAddress(newList);
        createConsent(newList);
    }
    
    public static void beforeUpdate(list<Account> newList, Map<Id, Account> oldList){
        //after insert method calls
        // Update the Low Wage Industry selection
        updateIndustrySelection(newList);
        updatePrimaryAddress(newList, oldList);
        //createConsent(newList);
    }
    
    
    public static void afterUpdate(List<Account> newList, Map<Id, Account> oldMap) {
        
        Set<Id> accountIds = new Set<Id>();
        for(Account acct : newList) {
            if(acct.Name != oldMap.get(acct.Id).Name) {
                accountIds.add(acct.Id);
            }
        }
        
        //List<Wage_Claim_Party__c> wcpToUpdate = [Select Id From Wage_Claim_Party__c Where Account__c IN :accountIds];
        //if(wcpToUpdate.size() > 0) {
            //update wcpToUpdate;
       // }
        
        List<Appeal_Party__c> apToUpdate = [Select Id From Appeal_Party__c Where Account__c IN :accountIds];
        if(apToUpdate.size() > 0) {
            update apToUpdate;
        }
        system.debug('System.isfuture():  '+System.isfuture());
        if(!System.isfuture()){
            createConsent(newList,oldMap);
        }
        
    }
    
    // Uses the Naics code and the BOFE Low Wage Industry custom setting to set the low wage industry on the account
    public static void updateIndustrySelection(list<Account> acctList){
        list<string> Naics = new list<string>();
        map<Id, string> naicsMap = new map<Id, string>();
        Map<Id, Id> accMap = new Map<Id, Id>();
        
        Set<Id> NaicsSet = new Set<Id>();
        for (Account acc : acctList){
            if (acc.Naics_code__c != null){
                NaicsSet.add(acc.Naics_code__c);
                accMap.put(acc.Id, acc.Naics_code__c);
            }
        }
        
        List<NAICS_Code__c> NaicsList = new List<NAICS_Code__c>();
        NaicsList = [SELECT Id, Name FROM NAICS_Code__c WHERE Id IN : NaicsSet];
        for (NAICS_Code__c nc : NaicsList)
            naicsMap.put(nc.Id, nc.Name);
        
        Map<String, BOFE_Low_Wage_Industry__c> Industry_Selection = new Map<String, BOFE_Low_Wage_Industry__c>();
        //get all the NAICS Code >> industry matches into map
        BOFE_Low_Wage_Industry__c Industry = BOFE_Low_Wage_Industry__c.getInstance();
        Industry_Selection = BOFE_Low_Wage_Industry__c.getAll();
        
        for(Account a : acctList){
            if(a.Naics_code__c != null){
                //Naics.add(a.NAICS_Code__r.name);
                //naicsMap.add(a, a.NAICS_Code__r.name);
            //}
            //if(Naics.size() > 0){
                system.debug('NAICS Code set on record');
                //list<Account> accountToUpdate = new list<account>();
                
                String resultIndustry = null;
                // first lookup of map value   
                if ((accMap.containsKey(a.Id)) && (naicsMap.containsKey(accMap.get(a.Id)))){             
                    String naicsCode = naicsMap.get(accMap.get(a.Id));
                    String helpvar;
                    if ((Industry_Selection.containsKey(naicsCode)) && (Industry_Selection.get(naicsCode).Active__c == true))
                        resultIndustry = Industry_Selection.get(naicsCode).Industry__c;
                    //system.debug('****** resultIndustry: ' + resultIndustry);
                    else{
                        helpvar = naicsCode.Left(5);
                        if ((Industry_Selection.containsKey(helpvar)) && (Industry_Selection.get(helpvar).Active__c == true)){
                            system.debug('First industry lookup failed, attempting lookup on 5 characters');
                            resultIndustry = Industry_Selection.get(helpvar).Industry__c;
                        }
                        else{
                            helpvar = naicsCode.Left(4);
                            if ((Industry_Selection.containsKey(helpvar)) && (Industry_Selection.get(helpvar).Active__c == true)){
                                system.debug('First industry lookup failed, attempting lookup on 4 characters');
                                resultIndustry = Industry_Selection.get(helpvar).Industry__c;
                            }
                            else{
                                helpvar = naicsCode.Left(3);
                                if ((Industry_Selection.containsKey(helpvar)) && (Industry_Selection.get(helpvar).Active__c == true)){
                                    system.debug('First industry lookup failed, attempting lookup on 3 characters');
                                    resultIndustry = Industry_Selection.get(helpvar).Industry__c;
                                }
                                else{
                                    helpvar = naicsCode.Left(2);
                                    if ((Industry_Selection.containsKey(helpvar)) && (Industry_Selection.get(helpvar).Active__c == true)){
                                        system.debug('First industry lookup failed, attempting lookup on 2 characters');
                                        resultIndustry = Industry_Selection.get(helpvar).Industry__c;
                                    }
                                    else resultIndustry = 'Other';
                                }
                            }
                        }
                    }
                    
                }
                
                a.Low_wage_industry_selection__c = resultIndustry;
                
            }
            
        }
    }
    
    public static void addPrimaryAddress(list<Account> acctList){
        // create primary address from the address entered on the account
         
        string personRt = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
        
        list<Address__c> loc = new list<Address__c>();
        for (Account a : acctList){
            Address__c addr = new Address__c();
            Address__c addr1 = new Address__c();
            addr1.Entity__c = a.Id;
            addr.entity__c = a.ID;
            if( a.RecordTypeId != personRt){
                system.debug('##### begin building business primary address');
                if( a.ShippingCity == NULL && a.ShippingState == null && a.ShippingPostalCode == null ){
                    system.debug('##### address details blank for buisness account. Skipping');
                    continue;
                }
                
                if(a.ShippingStreet != null && a.ShippingStreet != ''){
                    //parse address field
                    list<String> addString = new list<String>();
                    addString = a.ShippingStreet.split('\r\n');
                    if (addString.size() > 0){ 
                        addr.address__c = addString.get(0);
                    }
                    if (addString.size() > 1){ 
                        addr.address_2__c = addString.get(1);
                    }
                    if (addString.size() == 3){ 
                        addr.address_3__c = addString.get(2);
                    } 
                }
                addr.City__c = a.ShippingCity;
                addr.State__c = a.ShippingState;
                addr.Zip_Code__c = a.ShippingPostalCode;
                addr.Phone__c = a.Phone;
                addr.Fax__c = a.Fax;
                addr.Active_Location__c = true;
                addr.Type__c = 'Primary';
                system.debug('##### Adding business address: ' + addr);
                loc.add(addr);
            }
                        
            else{
                // add addresses for person accounts
                system.debug('##### begin building person account address');
                if( a.PersonMailingCity != NULL && a.PersonMailingState != NULL && a.PersonMailingPostalCode != NULL){
                    system.debug('##### building home address for person account');
                    if( a.PersonMailingStreet != null && a.PersonMailingStreet != '' ){
                        //parse address field
                        list<String> addString = new list<String>();
                        addString = a.PersonMailingStreet.split('\r\n');
                        if (addString.size() > 0){ 
                            addr.address__c = addString.get(0);
                        }
                        if (addString.size() > 1){ 
                            addr.address_2__c = addString.get(1);
                        }
                        if (addString.size() == 3){ 
                            addr.address_3__c = addString.get(2);
                        } 
                        addr.City__c = a.PersonMailingCity;
                        addr.State__c = a.PersonMailingState;
                        addr.Zip_Code__c = a.PersonMailingPostalCode;
                        addr.Phone__c = a.Phone;
                       // addr.Fax__c = a.Fax;
                        addr.Active_Location__c = true;
                        addr.Type__c = 'Home';
                       // addr.DBA__c = a.DBA__c;
                       system.debug('##### Adding home address for person account ' + addr);
                       loc.add(addr);
                    }                       
                }
                // build primary address for person account
                if( a.ShippingCity != NULL && a.ShippingState != NULL && a.ShippingPostalCode != NULL){
                    system.debug('##### building home address for person account');
                    if( a.ShippingStreet != null && a.ShippingStreet != '' ){
                        //parse address field
                        list<String> addString = new list<String>();
                        addString = a.ShippingStreet.split('\r\n');
                        if (addString.size() > 0){ 
                            addr1.address__c = addString.get(0);
                        }
                        if (addString.size() > 1){ 
                            addr1.address_2__c = addString.get(1);
                        }
                        if (addString.size() == 3){ 
                            addr1.address_3__c = addString.get(2);
                        } 
                        addr1.City__c = a.ShippingCity;
                        addr1.State__c = a.ShippingState;
                        addr1.Zip_Code__c = a.ShippingPostalCode;
                        addr1.Phone__c = a.Phone;
                       // addr.Fax__c = a.Fax;
                        addr1.Active_Location__c = true;
                        addr1.Type__c = 'Primary';
                       // addr.DBA__c = a.DBA__c;
                       system.debug('##### Adding primary address for person account ' + addr);
                       loc.add(addr1);
                    }                       
                }
                 
            }
        }
        if(loc.size() > 0){
            insert loc;
        }
        
    }
    
    //update the primary address when the address changes on an account
    public static void updatePrimaryAddress(list<account> newList, Map<ID, Account> oldMap){
        list<Account> addChanged = new list<Account>();
        // check to see if the address has changed
        for(Account a : newList){
            if(a.ShippingStreet != oldmap.get(a.id).ShippingStreet
               || a.ShippingCity != oldmap.get(a.id).ShippingCity
               || a.ShippingState != oldmap.get(a.id).ShippingState
               || a.ShippingPostalCode != oldmap.get(a.id).ShippingPostalCode
               || a.PersonMailingPostalCode != oldmap.get(a.id).PersonMailingPostalCode
               || a.PersonMailingState != oldmap.get(a.id).PersonMailingState
               || a.PersonMailingCity != oldmap.get(a.id).PersonMailingCity
               || a.PersonMailingStreet != oldmap.get(a.id).PersonMailingStreet
              ){
                system.debug('##### address changed for account ' + a.Id);  
                addChanged.add(a);
            }
        }
        
        if (!addChanged.isEmpty()){
            //get list of active headquarters addresses
            list<Address__c> addList = [Select ID, Address__c, Address_2__c, Address_3__c, City__c, State__c, Zip_code__c, Type__c, Active_Location__c FROM Address__c where Entity__c in :newList and (Type__c = 'Primary' OR Type__c = 'Home') AND Active_Location__C = true];
            
            // Deactivate the previous headquarters location
            if (!addList.isEmpty()){
                for(Address__c a : addList){
                    a.Active_Location__c = false;
                }
                update addList;
            }
            // add the changed address as the new headquarters address
            addPrimaryAddress(addChanged);
        }
    }
    
    public static void createConsent(List<Account> accounts){
        List<smagicinteract__Consent__c> consents = new List<smagicinteract__Consent__c>();
        Map<String, Boolean> numberMapWithOptOutPerson = new Map<String, Boolean>();
        Map<String, Boolean> numberMapWithOptOutBusiness = new Map<String, Boolean>();
        for(Account acc : accounts){
            if(acc.Text_Message_Opt_Out__c){
                if(acc.RecordTypeId == personRecordTypeId && acc.PersonMobilePhone != null){
                    numberMapWithOptOutPerson.put(acc.PersonMobilePhone, acc.Text_Message_Opt_Out__c);
                    //letc check the existing consent record with the phone
                    String phone = getPhoneNumber(acc.PersonMobilePhone);
                    system.debug('phone: '+phone);
                    List<smagicinteract__Consent__c> consentList = [SELECT id,smagicinteract__Compliance_Status__c FROM smagicinteract__Consent__c WHERE smagicinteract__External_Key__c =: phone ];
                    system.debug('consentList: '+consentList);
                    if(consentList.isEmpty()) {
                        consents.add(SMSHistoryController.textMessageConsent(phone,acc.Id,'Opt-Out', true));
                    } else if(consentList.size() > 0 && consentList[0].smagicinteract__Compliance_Status__c == 'Opt-In'){
                        smagicinteract__Consent__c consent = SMSHistoryController.textMessageConsent(phone,acc.Id,'Opt-Out', false);
                        //update the existing record if already exist.
                        consent.Id = consentList[0].Id;
                        consents.add(consent);
                    }
                }else if(acc.RecordTypeId != personRecordTypeId && acc.Cell_Phone__c != null){
                    numberMapWithOptOutBusiness.put(acc.Cell_Phone__c, acc.Text_Message_Opt_Out__c);
                    String phone = getPhoneNumber(acc.Cell_Phone__c);
                    List<smagicinteract__Consent__c> consentList = [SELECT id FROM smagicinteract__Consent__c WHERE smagicinteract__External_Key__c =: phone];
                    system.debug('consentList: '+consentList);
                    if(consentList.isEmpty()){
                        consents.add(SMSHistoryController.textMessageConsent(phone,acc.Id,'Opt-Out', true));
                    } else if(consentList.size() > 0 && consentList[0].smagicinteract__Compliance_Status__c == 'Opt-In'){
                        smagicinteract__Consent__c consent = SMSHistoryController.textMessageConsent(phone,acc.Id,'Opt-Out', false);
                        //update the existing record if already exist.
                        consent.Id = consentList[0].Id;
                        consents.add(consent);
                    }  
                }
            } 
            else {
                if(acc.RecordTypeId == personRecordTypeId && acc.PersonMobilePhone != null){
                    numberMapWithOptOutPerson.put(acc.PersonMobilePhone, acc.Text_Message_Opt_Out__c);
                    //letc check the existing consent record with the phone
                    String phone = getPhoneNumber(acc.PersonMobilePhone);
                    system.debug('phone: '+phone);
                    List<smagicinteract__Consent__c> consentList = [SELECT id,smagicinteract__Compliance_Status__c FROM smagicinteract__Consent__c WHERE smagicinteract__External_Key__c =: phone ];
                    system.debug('consentList: '+consentList);
                    if(consentList.size() > 0 && consentList[0].smagicinteract__Compliance_Status__c == 'Opt-Out'){
                        smagicinteract__Consent__c consent = SMSHistoryController.textMessageConsent(phone,acc.Id,'Opt-In', false);
                        //update the existing record if already exist.
                        consent.Id = consentList[0].Id;
                        consents.add(consent);
                    }
                }else if(acc.RecordTypeId != personRecordTypeId && acc.Cell_Phone__c != null){
                    numberMapWithOptOutBusiness.put(acc.Cell_Phone__c, acc.Text_Message_Opt_Out__c);
                    String phone = getPhoneNumber(acc.Cell_Phone__c);
                    List<smagicinteract__Consent__c> consentList = [SELECT id FROM smagicinteract__Consent__c WHERE smagicinteract__External_Key__c =: phone];
                    system.debug('consentList: '+consentList);
                    if(consentList.size() > 0 && consentList[0].smagicinteract__Compliance_Status__c == 'Opt-Out'){
                        smagicinteract__Consent__c consent = SMSHistoryController.textMessageConsent(phone,acc.Id,'Opt-In', false);
                        //update the existing record if already exist.
                        consent.Id = consentList[0].Id;
                        consents.add(consent);
                    }  
                }
            }
        }
        if(consents.size() > 0 && !Test.isRunningTest()){
            system.debug('consents: '+consents[0].smagicinteract__External_Key__c);
            try{
                upsert consents smagicinteract__External_Key__c;
            } catch(Exception ex){
                new OWCServiceUtility().Log(ex);
            }
            
            //upsertConsents(Json.serialize(consents));
        }
        //updateSMSOptOutAccountWithSameNumber(numberMapWithOptOutPerson, numberMapWithOptOutBusiness);
        
    }
    @future
    public static void upsertConsents(String consentsJson){
        List<smagicinteract__Consent__c> consents = (List<smagicinteract__Consent__c>)JSON.deserialize(consentsJson, List<smagicinteract__Consent__c>.class);
        upsert consents smagicinteract__External_Key__c;
    }
    private static String getPhoneNumber(String phone){
        phone = phone.replaceAll('[^0-9]','');
        if(!phone.startsWith('1')){
            phone = '1'+phone;
        }
        return phone;
    }
    public static void createConsent(List<Account> accounts, Map<Id, Account> oldAccounts){
        List<smagicinteract__Consent__c> consents = new List<smagicinteract__Consent__c>();
        Map<String, Account> accountByPhone = new Map<String, Account>();
        
        Map<String, Boolean> numberMapWithOptOutPerson = new Map<String, Boolean>();
        Map<String, Boolean> numberMapWithOptOutBusiness = new Map<String, Boolean>();
        
        for(Account acc : accounts){
            if(acc.Text_Message_Opt_Out__c != oldAccounts.get(acc.Id).Text_Message_Opt_Out__c){
                if(acc.RecordTypeId == personRecordTypeId && acc.PersonMobilePhone != null){
                    numberMapWithOptOutPerson.put(acc.PersonMobilePhone, acc.Text_Message_Opt_Out__c);
                    accountByPhone.put(getPhoneNumber(acc.PersonMobilePhone),acc);
                }else if(acc.RecordTypeId != personRecordTypeId && acc.Cell_Phone__c != null){
                    numberMapWithOptOutBusiness.put(acc.Cell_Phone__c, acc.Text_Message_Opt_Out__c);
                    accountByPhone.put(getPhoneNumber( acc.Cell_Phone__c),acc);
                }
            }
        }
        system.debug('accountByPhone: '+accountByPhone);
        for(smagicinteract__Consent__c consent : [SELECT Id, Name, smagicinteract__External_Key__c ,
                                                  smagicinteract__Compliance_Status__c,
                                                  smagicinteract__Action_Type__c 
                                                  FROM smagicinteract__Consent__c 
                                                  WHERE Name IN :accountByPhone.keySet()])
        {
            String status = accountByPhone.get(consent.Name).Text_Message_Opt_Out__c?'Opt-Out':'Opt-In';
            smagicinteract__Consent__c tempConsent = new smagicinteract__Consent__c();
            //check the consent status
            if(consent.smagicinteract__Compliance_Status__c != status){
                tempConsent.smagicinteract__Compliance_Status__c = status;
                //SMSHistoryController.textMessageConsent(consent.Name,accountByPhone.get(consent.Name).Id,status, false);
                tempConsent.Id = consent.Id;
                //tempConsent.smagicinteract__External_Key__c = consent.smagicinteract__External_Key__c ;
                consents.add(tempConsent);
            }
			accountByPhone.remove(consent.Name);
        }
        List<String> phoneNumbers = new List<String>();
        for(String phoneNumber : accountByPhone.keySet()){
            String status = accountByPhone.get(phoneNumber).Text_Message_Opt_Out__c?'Opt-Out':'Opt-In';
			consents.add(SMSHistoryController.textMessageConsent(phoneNumber,accountByPhone.get(phoneNumber).Id,status, true));
            
        }
		system.debug('consents: '+consents);
        if(consents.size() > 0  && !Test.isRunningTest()){
            try{
                upsert consents ;
            } catch(Exception ex){
                new OWCServiceUtility().Log(ex);
            }
            
        }
        //updateSMSOptOutAccountWithSameNumber(numberMapWithOptOutPerson, numberMapWithOptOutBusiness);
    }
    /**************************
    @future
    public static void updateSMSOptOutAccountWithSameNumber(Map<String, Boolean> numberMapWithOptOutPerson, Map<String, Boolean> numberMapWithOptOutBusiness){
        List<Account> accountToUpdate = new List<Account>();
        for(Account acc: [SELECT Id,Text_Message_Opt_Out__c,PersonMobilePhone,Cell_Phone__c,RecordTypeId FROM Account 
                          WHERE PersonMobilePhone IN: numberMapWithOptOutPerson.keySet() OR Cell_Phone__c IN: numberMapWithOptOutBusiness.keySet()])
        {	
            if(acc.RecordTypeId == personRecordTypeId){
                if(acc.Text_Message_Opt_Out__c != numberMapWithOptOutPerson.get(acc.PersonMobilePhone)){
                    acc.Text_Message_Opt_Out__c = numberMapWithOptOutPerson.get(acc.PersonMobilePhone);
                    accountToUpdate.add(acc);
                }
            } else{
                if(acc.Text_Message_Opt_Out__c != numberMapWithOptOutBusiness.get(acc.Cell_Phone__c)){
                    acc.Text_Message_Opt_Out__c = numberMapWithOptOutBusiness.get(acc.Cell_Phone__c);
                    accountToUpdate.add(acc);
                }
            }
        }
        if(accountToUpdate.size() >0){
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            List<Database.SaveResult> sr = Database.update(accountToUpdate, dml);
        }
    }
	***************/
}