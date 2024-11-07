trigger RelatedBusinessTrigger on Related_Businesses__c (before insert,after insert, after update) {
    if(trigger.isBefore && trigger.isInsert){
        RelatedBusinessTriggerHelper.beforeInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert){
        RelatedBusinessTriggerHelper.afterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        RelatedBusinessTriggerHelper.afterUpdate(trigger.new, trigger.oldMap);
    }
}