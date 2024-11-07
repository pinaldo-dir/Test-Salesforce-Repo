public with sharing class WarrantPendingUpdateQable implements Queueable {
    List<DIR_Case__c> caseWarrantList = new List<DIR_Case__c>();
    List<DIR_Case__c> overflowCases = new List<DIR_Case__c>();
    List<DIR_Case__c> caseToUpdate = new List<DIR_Case__c>();
    String wbURL;
    Map<String, List<Id>> qJobIdMap = new Map<String, List<Id>>();
    Decimal sumOfPrintedWarrants = 0.00;
    Decimal sumOfPendingWarrants = 0.00;
    Integer maxCase = 25;
    String actType;

    public WarrantPendingUpdateQable(List<DIR_Case__c> caseWarrantDetail, String wbLink, Map<String, List<Id>> qJobId, String action){
        wbURL = wbLink;
        caseWarrantList = caseWarrantDetail;
        qJobIdMap = qJobId;
        actType = action;
        
        while(caseWarrantList.size()>maxCase){
            overflowCases.add(caseWarrantList.remove(maxCase));
        }
    }

    public void execute(QueueableContext qc){
        try{
            System.debug('<============= QueueableContext =============> ');
            System.debug('<============= caseWarrantList =============> ');
            System.debug(caseWarrantList);
            
            for(DIR_Case__c eachCase: caseWarrantList){
                system.debug('For Loop Case ==> ' + eachCase.Id);
                sumOfPrintedWarrants = 0.00;
                sumOfPendingWarrants = 0.00;
                for(Warrant__c wr: eachCase.Warrants__r){
                    system.debug('For Loop Warrants ==> ' + wr.Id);
                    if(wr.Status__c == 'Printed'){
                        sumOfPrintedWarrants = sumOfPrintedWarrants + wr.Amount__c;
                    }
                    else{
                        sumOfPendingWarrants = sumOfPendingWarrants + wr.Amount__c;
                    }
                }
                eachCase.Funds_Drawn_on_Deposits__c = sumOfPrintedWarrants;
                eachCase.Warrants_Pending__c = sumOfPendingWarrants;
                caseToUpdate.add(eachCase);
            }
            system.debug('!!!!!!!!!!!!!!!!!! Update Case !!!!!!!!!!!!!!!!!!');
            update caseToUpdate;

            if(qJobIdMap.containsKey('Update Warrant Pending')){
                List<Id> tempList = qJobIdMap.get('Update Warrant Pending');
                tempList.add(qc.getJobId());
                qJobIdMap.put('Update Warrant Pending', tempList);
            }
            else{
                qJobIdMap.put('Update Warrant Pending', new List<Id>{qc.getJobId()});
            }

            system.debug('<====================== wbURL <======================' + wbURL);

            if(!overflowCases.isEmpty()){
                System.enqueueJob(new WarrantPendingUpdateQable(overflowCases, wbURL, qJobIdMap, actType));
            }
            else{
                //Call the Warrant finalizer Class to send an email
                System.attachFinalizer(new WarrantFinalizer(wbURL, qJobIdMap, actType ,''));
            }
        }
        catch(Exception e){
            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();
            
            if(qJobIdMap.containsKey('Update Warrant Pending')){
                List<Id> tempList = qJobIdMap.get('Update Warrant Pending');
                tempList.add(qc.getJobId());
                qJobIdMap.put('Update Warrant Pending', tempList);
            }else{
                qJobIdMap.put('Update Warrant Pending', new List<Id>{qc.getJobId()});
            }
            System.attachFinalizer(new WarrantFinalizer(wbURL, qJobIdMap, actType ,errorMessage));
        }
        
    }
}