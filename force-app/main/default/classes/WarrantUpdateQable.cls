public with sharing class WarrantUpdateQable implements Queueable{
    List<Warrant_Batch__c> wbToUpdate = new List<Warrant_Batch__c>();
    List<Warrant__c> wrsToUpdate = new List<Warrant__c>();
    List<Warrant__c> overflowWRs = new List<Warrant__c>();
    Set<Id> caseId = new Set<Id>();
    List<Id> caseIdList = new List<Id>();
    Map<String, List<Id>> qJobIdMap = new Map<String, List<Id>>();
    String wbURL;
    Integer maxWrs = 100;
    String actType;

    public WarrantUpdateQable(List<Warrant_Batch__c> wbListToUpdate, List<Warrant__c> wrListToUpdate, String wbLink) {
        wbURL = wbLink;
        wrsToUpdate = wrListToUpdate;
        wbToUpdate = wbListToUpdate;
        actType = 'Update';

        while(wrsToUpdate.size() > maxWrs){
            overflowWRs.add(wrsToUpdate.remove(maxWrs));
        }
    }


    public void execute(QueueableContext qc){
        try{
            system.debug('!!!!!!!!!!!!!!!!!! Update Warrants !!!!!!!!!!!!!!!!!!');
            update wrsToUpdate;
            system.debug('Updated Warrants ==> ' + wrsToUpdate);
            qJobIdMap.put('Update Warrants', new List<Id>{qc.getJobId()});

            for(Warrant__c wr: wrsToUpdate){
                system.debug('For Loop Warrants ==> ' + wr);
                caseId.add(wr.Case__c);
            }

            system.debug('<====================== wbURL <======================' + wbURL);
            if(!overflowWRs.isEmpty()){
                System.enqueueJob(new WarrantUpdateQable(wbToUpdate, overflowWRs, wbURL));
            }
            else{
                system.debug('!!!!!!!!!!!!!!!!!! Update Warrant Batch !!!!!!!!!!!!!!!!!!');
                update wbToUpdate;
                system.debug('!!!!!!!!!!!!!!!!!! Case - Warrants Pending !!!!!!!!!!!!!!!!!!');
                caseIdList.addAll(caseId);
                system.debug('Case Ids ==> ' + caseIdList);

                List<DIR_Case__c> caseWarrantList =  new List<DIR_Case__c>([SELECT Id, Name, Cash_Balance_on_Case__c, Deposited_Funds__c, 
                                                                    Funds_Drawn_on_Deposits__c, Warrants_Pending__c, 
                                                                    (SELECT Id, Name, Warrant_Number__c, Amount__c, Status__c, Case__c, 
                                                                    Case__r.Id, Case__r.Name FROM Warrants__r 
                                                                    WHERE Status__c IN ('New','Pending Approval','Approved','Not Approved','Secondary Approval Needed','Printed')) 
                                                                  FROM DIR_Case__c WHERE Id IN :caseIdList]);
                System.debug('caseWarrantList =============> ' +caseWarrantList);

                //Call Warrant Pending Qable Class
                System.enqueueJob(new WarrantPendingUpdateQable(caseWarrantList, wbURL, qJobIdMap, actType)); 
            }
        }
        catch(Exception e){
            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();
            
            qJobIdMap.put('Update Warrants', new List<Id>{qc.getJobId()});

            System.attachFinalizer(new WarrantFinalizer(wbURL, qJobIdMap, actType ,errorMessage));
        }
        
    }
}