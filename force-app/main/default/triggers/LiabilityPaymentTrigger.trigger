trigger LiabilityPaymentTrigger on Liability_Payment__c (after insert, after update, after delete) {

    if(Trigger_Settings__c.getInstance('LiabilityPaymentTrigger').Is_Active__c){ //managed in Setup->Custom Settings->Trigger Settings->Manage
        if(Trigger.isDelete){
            LiabilityPaymentMethods.liabilityPaymentRollups(Trigger.old);
        }else{
            LiabilityPaymentMethods.createAppliedAccountingCodes(Trigger.new);
            LiabilityPaymentMethods.liabilityPaymentRollups(Trigger.new);
        }
    }
}