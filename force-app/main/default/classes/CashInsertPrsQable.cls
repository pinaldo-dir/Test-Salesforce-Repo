public with sharing class CashInsertPrsQable implements Queueable {
    
    List<Payment_Record__c> prsToInsert = new List<Payment_Record__c>();
    List<Payment_Record__c> overflowPrs = new List<Payment_Record__c>();
    Map<String, List<Id>> qableJobIdMap;
    Case_Payment__c casePayment;
    Integer MAX_DML_ROWS = 9999; //Can only insert 10000 records at a time, keeping at 9999 just for luck.
    
    public CashInsertPrsQable(List<Payment_Record__c> prList, Case_Payment__c cp, Map<String, List<Id>> qJobIdMap){

        casePayment = cp;
        qableJobIdMap = qJobIdMap;

        prsToInsert = prList;
        // System.debug('16 prsToInsert.size(): ' + prsToInsert.size());
        while(prsToInsert.size() > MAX_DML_ROWS){
            overflowPrs.add(prsToInsert.remove(MAX_DML_ROWS));
        }
    }

    public void execute(QueueableContext qc){

        try{
            System.debug('24 prsToInsert: ' + prsToInsert);
            
            insert prsToInsert;

            System.debug('27 prsToInsert: ' + prsToInsert);
    
            if(qableJobIdMap.containsKey('Insert PRs')){
                List<Id> tempList = qableJobIdMap.get('Insert PRs');
                tempList.add(qc.getJobId());
                qableJobIdMap.put('Insert PRs', tempList);
            }else{
                qableJobIdMap.put('Insert PRs', new List<Id>{qc.getJobId()});
            }
    
            if(!overflowPrs.isEmpty()){
                // System.debug('28 overflowprs: ' + overflowPrs.size());
                System.enqueueJob(new CashInsertPrsQable(overflowPrs, casePayment, qableJobIdMap));
            }else{
                System.attachFinalizer(new CashPrFinalizer(casePayment.Id, casePayment.Name, qableJobIdMap, ''));
            }

        }catch(Exception e){

            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();
            
            if(qableJobIdMap.containsKey('Insert PRs')){
                List<Id> tempList = qableJobIdMap.get('Insert PRs');
                tempList.add(qc.getJobId());
                qableJobIdMap.put('Insert PRs', tempList);
            }else{
                qableJobIdMap.put('Insert PRs', new List<Id>{qc.getJobId()});
            }
            
            System.attachFinalizer(new CashPrFinalizer(casePayment.Id, casePayment.Name, qableJobIdMap, errorMessage));
        }

    }

}