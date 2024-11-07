/* Called by the TransactionTrigger class */
public class TransactionMethods{
    
    public static boolean hasRun = false;
    
    public static void depositChildReceipts(List<Transaction__c> newTrnList, List<Transaction__c> oldTrnList){

        hasRun = true;
        Set<Id> trnIds = new Set<Id>();
        Set<Id> oaIds = new Set<Id>();

        for(Transaction__c trn : newTrnList){
            //trnIds.add(trn.Id);
            oaIds.add(trn.Office_Account__c);
        }

        Map<Id, Office_Account__c> idToOaBalanceMap = new Map<Id, Office_Account__c>([SELECT Id, Account_Balance__c FROM Office_Account__c WHERE Id IN :oaIds]);

        for(Transaction__c oldTrn : oldTrnList){
            for(Transaction__c newTrn : newTrnList){
                if(oldTrn.Id == newTrn.Id){
                    if(oldTrn.Transaction_Type__c == 'Deposit' && oldTrn.Transaction_Status__c == 'Pending' &&
                        oldTrn.Treasury_Deposit_Number__c == NULL && newTrn.Treasury_Deposit_Number__c != NULL &&
                        oldTrn.Check_Count__c == NULL && newTrn.Check_Count__c != NULL &&
                        oldTrn.Checks_Amount__c == NULL && newTrn.Checks_Amount__c != NULL){
                            newTrn.Transaction_Status__c = 'Deposited';
                            newTrn.Account_Balance_Before_Transaction__c = idToOaBalanceMap.get(newTrn.Office_Account__c).Account_Balance__c;
                            newTrn.Account_Balance_After_Transaction__c = idToOaBalanceMap.get(newTrn.Office_Account__c).Account_Balance__c + newTrn.Transaction_Sum__c;
                            newTrn.Balances_Set__c = TRUE;
                            newTrn.RecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('TRN Locked').getRecordTypeId();
                            trnIds.add(newTrn.Id);
                    }
                }
            }
        }

        if(!trnIds.isEmpty()){
            Id db = Database.executeBatch(new AccountingDepositBatch(trnIds), 10);
        }
    }
}