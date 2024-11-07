trigger OWCConsentTrigger on smagicinteract__Consent__c (after update) {
    
    if (trigger.isAfter && trigger.isUpdate){
        { 	
            if(OWCConstants.FIRST_RUN_ON_SMS_CONSENT_UPDATE){
                OWCConstants.FIRST_RUN_ON_SMS_CONSENT_UPDATE = false;
                OWCConsentTriggerHandler.updateStatusField(Trigger.oldMap,Trigger.newMap);
            }
        }
    }

}