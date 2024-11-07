//-----------------------------
// @author: Oswin Correa
// @date: 18/4/2018
// @description: DIR_RelatedParty Trigger on Related_Party__c object
//-----------------------------
trigger DIR_RelatedParty on Related_Party__c (after insert, after update) {
    GlobalFlagClass.preventDuplicateCaseRoles = false;
    GlobalFlagClass.preventBOFEEmployerChange = false;
    
    if(DIR_RelatedPartyTriggerHandler.preventReccursion){
        if(trigger.isAfter){
            if(trigger.isInsert){
                DIR_RelatedPartyTriggerHandler.onAfterInsert(trigger.newMap);
            }
            else if(trigger.isUpdate){
                DIR_RelatedPartyTriggerHandler.onAfterUpdate(trigger.oldMap,trigger.newMap);
                DIR_RelatedPartyTriggerHandler.preventReccursion = false;
            }
        }
    }
    
}