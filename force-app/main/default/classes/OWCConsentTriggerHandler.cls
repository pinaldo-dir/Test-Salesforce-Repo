public class OWCConsentTriggerHandler {
    
    public static Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    
    public static void updateStatusField(Map<Id,smagicinteract__Consent__c> oldValue, Map<Id,smagicinteract__Consent__c> newValue ){
        
        //check status change for consent✅
        //prepare Map<Phone,Status> of phone by removing 1 from the starting✅
        //get all the accounts where personMobilePhone in ListOfPhone OR cellPhone in ListOfPhone✅
        //iterate all the account✅
        //if account.recordType == personAccount (if Opt-Out && Account.SMSOptOut == false{true} else if(Opt-In && Account.SMSOptOut == false){true} ) 
        //else (if Opt-Out && Account.SMSOptOut == false{true} else if(Opt-In && Account.SMSOptOut == false){true})
    
        
        
        Map<String,String> phoneAndStatusMap = new Map<String,String>();
        for(Id accId : oldValue.keySet()){
            smagicinteract__Consent__c oldConsentObj = oldValue.get(accId);
            smagicinteract__Consent__c newConsentObj = newValue.get(accId);
            if(oldConsentObj.smagicinteract__Compliance_Status__c != newConsentObj.smagicinteract__Compliance_Status__c){
                System.debug('???'+oldConsentObj.smagicinteract__Compliance_Status__c);
                System.debug('???'+newConsentObj.smagicinteract__Compliance_Status__c);
                String phoneNumber = newConsentObj.Name;
                if(phoneNumber.startsWith('1')){
                    phoneNumber = phoneNumber.removeStart('1');
                }
                System.debug('phoneNumber ?? '+phoneNumber);
                phoneAndStatusMap.put(phoneNumber,newConsentObj.smagicinteract__Compliance_Status__c);
            }
        }
        
		if(phoneAndStatusMap.keyset().size() >0){
            updateAccountRecords(phoneAndStatusMap);
        }        
        
    }
    @future
    public  static void updateAccountRecords(Map<String,String> phoneAndStatusMap){
        List<Account> accountList = [SELECT Id,RecordTypeId,PersonMobilePhone,Cell_Phone__c,Text_Message_Opt_Out__c FROM Account 
                                     WHERE PersonMobilePhone IN : phoneAndStatusMap.keySet() OR Cell_Phone__c IN : phoneAndStatusMap.keySet()];
        System.debug('accountList ??'+ accountList);
        List<Account> accountsToUpdate = new List<Account>();
        //iterate all the accounts 
        if(accountList.size()>0){
            for(Account acc : accountList){
                System.debug('accountList acc.PersonMobilePhone'+ acc.PersonMobilePhone);
                System.debug('accountList acc.Cell_Phone__c'+ acc.Cell_Phone__c);
                System.debug('accountList acc.Text_Message_Opt_Out__c'+ acc.Text_Message_Opt_Out__c);
                if(acc.RecordTypeId == personRecordTypeId && acc.PersonMobilePhone != null && phoneAndStatusMap.containsKey(acc.PersonMobilePhone)){
                    System.debug('1');
                    if(phoneAndStatusMap.get(acc.PersonMobilePhone) == 'Opt-Out' && !acc.Text_Message_Opt_Out__c){
                        System.debug('2');
                        acc.Text_Message_Opt_Out__c = true;
                        accountsToUpdate.add(acc);
                    } 
                    else if(phoneAndStatusMap.get(acc.PersonMobilePhone) == 'Opt-In' && acc.Text_Message_Opt_Out__c){
                        System.debug('3');
                        acc.Text_Message_Opt_Out__c = false;
                        accountsToUpdate.add(acc);
                    }
                }
                else if(acc.RecordTypeId != personRecordTypeId && acc.Cell_Phone__c != null && phoneAndStatusMap.containsKey(acc.Cell_Phone__c)){
                    System.debug('11');
                    if(phoneAndStatusMap.get(acc.Cell_Phone__c) == 'Opt-Out' && !acc.Text_Message_Opt_Out__c){
                        System.debug('12');
                        acc.Text_Message_Opt_Out__c = true;
                        accountsToUpdate.add(acc);
                    } 
                    else if(phoneAndStatusMap.get(acc.Cell_Phone__c) == 'Opt-In' && acc.Text_Message_Opt_Out__c){
                        System.debug('13');
                        acc.Text_Message_Opt_Out__c = false;
                        accountsToUpdate.add(acc);
                    }
                }
            }
        }
        system.debug('accountsToUpdate: '+accountsToUpdate);
        if(accountsToUpdate.size() >0){
            OWCConstants.STOP_TRIGGER_ON_CONSENT_UPDATE = true;
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            List<Database.SaveResult> sr = Database.update(accountsToUpdate, dml);
        }
    }
    
}