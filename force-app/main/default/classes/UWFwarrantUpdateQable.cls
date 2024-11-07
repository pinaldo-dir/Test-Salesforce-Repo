public with sharing class UWFwarrantUpdateQable implements Queueable{
    List<Warrant__c> wrsToInsert = new List<Warrant__c>();
    List<Warrant__c> overflowWRs = new List<Warrant__c>();
    List<Payment_Record__c> prsToUpdate = new List<Payment_Record__c>();
    List<Payment_Record__c> prsUpdated = new List<Payment_Record__c>();
    Set<Id> caseId = new Set<Id>();
    List<Id> caseIdList = new List<Id>();
    Map<String, List<Id>> qJobIdMap = new Map<String, List<Id>>();
    String wbURL;
    String reqType;
    Integer maxRows = 100;
    String actType;

    public UWFwarrantUpdateQable(List<Warrant__c> wrListToInsert, List<Payment_Record__c> prListToUpdate, String type, String wbLink,  Map<String, List<Id>> qJobId) {
        wbURL = wbLink;
        reqType = type;
        wrsToInsert = wrListToInsert;
        prsToUpdate = prListToUpdate;
        actType = 'Insert';
        qJobIdMap = qJobId;

        while(wrsToInsert.size() > maxRows){
            overflowWRs.add(wrsToInsert.remove(maxRows));
        }
    }

    public void execute(QueueableContext qc){
        try{
            system.debug('!!!!!!!!!!!!!!!!!! Insert Warrants !!!!!!!!!!!!!!!!!!');
            insert wrsToInsert;
            system.debug('31 Inserted Warrants ==> ' + wrsToInsert);
            //requery the just-inserted Warrants to bring in Case_Number__c--formula fields aren't calculated until after insert
            wrsToInsert = [SELECT Id, Name, Payee__c, Warrant_Batch__c, Amount__c, Case__c, Status__c, Disbursement_Type__c,
                                    Office_Account__c, Case_Number__c
                            FROM Warrant__c
                            WHERE Id IN :wrsToInsert]; 
            system.debug('37 Inserted Warrants ==> ' + wrsToInsert);

            if(reqType == 'reqUWFwr'){
                for(Warrant__c wr: wrsToInsert){
                    system.debug('For Loop Warrants ==> ' + wr);
                    caseId.add(wr.Case__c);
                    for(Payment_Record__c pr: prsToUpdate){
                        system.debug('For Loop Payment Records ==> ' + wr);
                        system.debug('<====================== wr.Case_Number__c <======================' + wr.Case_Number__c);
                        system.debug('<====================== pr.Case_Number__c <======================' + pr.Case_Number__c);
                        system.debug('<====================== wr.Id <======================' + wr.Id);
                        if(wr.Case_Number__c == pr.Case_Number__c && pr.Payment_Amount__c > 0){
                            pr.Warrant__c = wr.Id;
                            pr.UWF_Payee__c = wr.Payee__c;
                            pr.Batched_Under_Warrant__c = true;
                            pr.Disbursement_Type__c = 'Unpaid Wage Fund';
                            prsUpdated.add(pr);
                        }
                    }
                }
            }
            
            if(qJobIdMap.containsKey('Insert Warrants')){
                List<Id> tempList = qJobIdMap.get('Insert Warrants');
                tempList.add(qc.getJobId());
                qJobIdMap.put('Insert Warrants', tempList);
            }
            else{
                qJobIdMap.put('Insert Warrants', new List<Id>{qc.getJobId()});
            }
            system.debug('Updated qJobIdMap after UWF Warrants Inserted ==> ' + qJobIdMap);

            system.debug('<====================== wbURL <======================' + wbURL);
            if(!overflowWRs.isEmpty()){
                System.enqueueJob(new UWFwarrantUpdateQable(overflowWRs, prsToUpdate, reqType, wbURL, qJobIdMap));
            }
            else{
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

                //Call Update Payment Record
                system.debug('!!!!!!!!!!!!!!!!!! Update Payment Records !!!!!!!!!!!!!!!!!!');
                system.debug('Updated PRs ==> ' + prsUpdated);
                System.enqueueJob(new PaymentRecordUpdateQable(prsUpdated, caseWarrantList, wbURL, qJobIdMap, actType));
                
            }
        }
        catch(Exception e){
            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();
            
            qJobIdMap.put('Insert UWF Warrants', new List<Id>{qc.getJobId()});

            System.attachFinalizer(new WarrantFinalizer(wbURL, qJobIdMap, actType ,errorMessage));
        }
        
    }
}