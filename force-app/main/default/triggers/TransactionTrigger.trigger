trigger TransactionTrigger on Transaction__c (before update) {
    if(Trigger.isBefore && Trigger.isUpdate && !TransactionMethods.hasRun){
        TransactionMethods.depositChildReceipts(Trigger.new, Trigger.old);
    }
}