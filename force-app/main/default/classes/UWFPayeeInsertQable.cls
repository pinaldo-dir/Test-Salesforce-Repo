public with sharing class UWFPayeeInsertQable implements Queueable{
    List<Payee__c> overflowPayees = new List<Payee__c>();
    List<Payee__c> payeesToInsert = new List<Payee__c>();
    List<Warrant__c> updatedWarrantsToInsert = new List<Warrant__c>();
    List<Warrant__c> wrsToInsert = new List<Warrant__c>();
    List<Payment_Record__c> prsToUpdate = new List<Payment_Record__c>();
    Map<String, List<Id>> qJobIdMap = new Map<String, List<Id>>();
    String wbURL;
    String reqType;
    Integer maxRows = 1;
    String actType;

    public UWFPayeeInsertQable(List<Payee__c> payeeListToInsert, List<Warrant__c> wrListToInsert, List<Payment_Record__c> prListToUpdate, String type, String wbLink, Map<String, List<Id>> qJobId) {
        system.debug('!!!!!!!!!!!!!!!!!! UWFPayeeInsertQable !!!!!!!!!!!!!!!!!!');
        wbURL = wbLink;
        reqType = type;
        payeesToInsert = payeeListToInsert;
        wrsToInsert = wrListToInsert;
        prsToUpdate = prListToUpdate;
        actType = 'Insert';
        qJobIdMap = qJobId;

        while(payeesToInsert.size() > maxRows){
            overflowPayees.add(payeesToInsert.remove(maxRows));
        }
    }

    public void execute(QueueableContext qc){
        try{
            system.debug('!!!!!!!!!!!!!!!!!! Insert Payee !!!!!!!!!!!!!!!!!!');
            insert payeesToInsert;
            System.debug('<==================== Inserted Payees ====================> ' +payeesToInsert);
            system.debug('Warrants to Insert ==> ' + wrsToInsert);
            for(Warrant__c wr: wrsToInsert){
                Boolean wrUpdated = false;
                system.debug('For Loop Warrants ==> ' + wr);
                for(Payee__c payee: payeesToInsert){
                    system.debug('For Loop Payees ==> ' + payee);
                    if(payee.Case_Management__c == wr.Case__c && wr.Payee__c == null){
                        wr.Payee__c = payee.Id;
                        updatedWarrantsToInsert.add(wr);
                        system.debug('Warrants after adding Payee field ==> ' + wr);
                        wrUpdated = true;
                    }
                }
                if(!wrUpdated){
                    updatedWarrantsToInsert.add(wr);
                }
            }
            if(qJobIdMap.containsKey('Insert UWF Payees')){
                List<Id> tempList = qJobIdMap.get('Insert UWF Payees');
                tempList.add(qc.getJobId());
                qJobIdMap.put('Insert UWF Payees', tempList);
            }
            else{
                qJobIdMap.put('Insert UWF Payees', new List<Id>{qc.getJobId()});
            }
            system.debug('Updated qJobIdMap after UWF Payees Inserted ==> ' + qJobIdMap);

            //qJobIdMap.put('Insert UWF Payees', new List<Id>{qc.getJobId()});

            if(!overflowPayees.isEmpty()){
                System.enqueueJob(new UWFPayeeInsertQable(overflowPayees, wrsToInsert, prsToUpdate, reqType, wbURL, qJobIdMap));
            }
            else{
                system.debug('!!!!!!!!!!!!!!!!!! UWF Payee - Warrants !!!!!!!!!!!!!!!!!!');
                //Call Insert Warrants
                system.debug('!!!!!!!!!!!!!!!!!! Insert Warrants !!!!!!!!!!!!!!!!!!');
                system.debug('UWF Warrants to Insert ==> ' + updatedWarrantsToInsert);
                System.enqueueJob(new UWFwarrantUpdateQable(updatedWarrantsToInsert, prsToUpdate, reqType, wbURL, qJobIdMap));
            }
        }
        catch(Exception e){
            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();
            qJobIdMap.put('Insert UWF Payees', new List<Id>{qc.getJobId()});
            System.attachFinalizer(new WarrantFinalizer(wbURL, qJobIdMap, actType ,errorMessage));
        }
        
    }
}