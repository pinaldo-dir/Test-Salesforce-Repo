public with sharing class PaymentRecordUpdateQable implements Queueable{
    List<Payment_Record__c> prsToUpdate = new List<Payment_Record__c>();
    List<Payment_Record__c> overflowPrs = new List<Payment_Record__c>();
    List<DIR_Case__c> caseWarrantList = new List<DIR_Case__c>();
    String wbURL;
    Map<String, List<Id>> qJobIdMap = new Map<String, List<Id>>();
    Integer maxPrs = 100;
    String actType;

    public PaymentRecordUpdateQable(List<Payment_Record__c> prListToUpdate, List<DIR_Case__c> caseWarrantDetail, String wbLink, Map<String, List<Id>> qJobId, String action) {
        wbURL = wbLink;
        prsToUpdate = prListToUpdate;
        caseWarrantList = caseWarrantDetail;
        qJobIdMap = qJobId;
        actType = action;

        while(prsToUpdate.size() > maxPrs){
            overflowPrs.add(prsToUpdate.remove(maxPrs));
        }
    }


    public void execute(QueueableContext qc){
        try{
            system.debug('!!!!!!!!!!!!!!!!!! Update Payment Records !!!!!!!!!!!!!!!!!!');
            update prsToUpdate;
            system.debug('Updated Payment Records ==> ' + prsToUpdate);

            if(qJobIdMap.containsKey('Update Payment Records')){
                List<Id> tempList = qJobIdMap.get('Update Payment Records');
                tempList.add(qc.getJobId());
                qJobIdMap.put('Update Payment Records', tempList);
            }
            else{
                qJobIdMap.put('Update Payment Records', new List<Id>{qc.getJobId()});
            }
            system.debug('Updated qJobIdMap after Updated PRs ==> ' + qJobIdMap);

            system.debug('<====================== wbURL <======================' + wbURL);
            if(!overflowPrs.isEmpty()){
                System.enqueueJob(new PaymentRecordUpdateQable(overflowPrs, caseWarrantList, wbURL, qJobIdMap, actType));
            }
            else{
                //Call Warrant Pending Qable Class
                System.enqueueJob(new WarrantPendingUpdateQable(caseWarrantList, wbURL, qJobIdMap, actType));
            }
        }
        catch(Exception e){
            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();
            
            if(qJobIdMap.containsKey('Update Payment Records')){
                List<Id> tempList = qJobIdMap.get('Update Payment Records');
                tempList.add(qc.getJobId());
                qJobIdMap.put('Update Payment Records', tempList);
            }
            else{
                qJobIdMap.put('Update Payment Records', new List<Id>{qc.getJobId()});
            }

            System.attachFinalizer(new WarrantFinalizer(wbURL, qJobIdMap, actType ,errorMessage));
        }
        
    }
}