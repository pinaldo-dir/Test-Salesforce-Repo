public with sharing class UWFCaseRoleInsertQable implements Queueable{

    List<Case_Role__c> crsToInsert = new List<Case_Role__c>();
    List<Case_Role__c> overflowCRs = new List<Case_Role__c>();
    List<Payee__c> payeesToInsert = new List<Payee__c>();
    List<Payee__c> updatedPayeesToInsert = new List<Payee__c>();
    List<Warrant__c> wrsToInsert = new List<Warrant__c>();
    List<Payment_Record__c> prsToUpdate = new List<Payment_Record__c>();
    Map<String, List<Id>> qJobIdMap = new Map<String, List<Id>>();
    String wbURL;
    String reqType;
    Integer maxRows = 1;
    String actType;

    
    public UWFCaseRoleInsertQable(List<Case_Role__c> crListToInsert, List<Payee__c> payeeListToInsert, List<Warrant__c> wrListToInsert, List<Payment_Record__c> prListToUpdate, String type, String wbLink) {
        system.debug('!!!!!!!!!!!!!!!!!! UWFCaseRoleInsertQable !!!!!!!!!!!!!!!!!!');
        wbURL = wbLink;
        reqType = type;
        crsToInsert = crListToInsert;
        payeesToInsert = payeeListToInsert;
        wrsToInsert = wrListToInsert;
        prsToUpdate = prListToUpdate;
        actType = 'Insert';

        while(crsToInsert.size() > maxRows){
            overflowCRs.add(crsToInsert.remove(maxRows));
        }

    }

    public void execute(QueueableContext qc){
        try{
            system.debug('!!!!!!!!!!!!!!!!!! Insert Case Role !!!!!!!!!!!!!!!!!!');
            insert crsToInsert;
            System.debug('<==================== Inserted Case Roles ====================> ' +crsToInsert);
            for(Payee__c payee: payeesToInsert){
                system.debug('For Loop payee ==> ' + payee);
                Boolean payeeUpdated = false;
                for(Case_Role__c cr: crsToInsert){
                    //system.debug('For Loop payee ==> ' + payee);
                    system.debug('For Loop Case Roles ==> ' + cr);
                    system.debug('<====================== payee.Case_Management__c <======================' + payee.Case_Management__c);
                    system.debug('<====================== payee.Case_Role__c <======================' + payee.Case_Role__c);
                    system.debug('<====================== cr.Case__c <======================' + cr.Case__c);
                    system.debug('<====================== cr.Id <======================' + cr.Id);
                    if(cr.Case__c == payee.Case_Management__c && payee.Case_Role__c == null){
                        payee.Case_Role__c = cr.Id;
                        updatedPayeesToInsert.add(payee);
                        system.debug('Payee after adding Case Role field ==> ' + payee);
                        payeeUpdated = true;
                    }
                }
                if(!payeeUpdated){
                    updatedPayeesToInsert.add(payee);
                }
            }

            qJobIdMap.put('Insert UWF Case Roles', new List<Id>{qc.getJobId()});

            if(!Test.isRunningTest()){
                if(!overflowCRs.isEmpty()){
                    System.enqueueJob(new UWFCaseRoleInsertQable(overflowCRs, payeesToInsert, wrsToInsert, prsToUpdate, reqType, wbURL));
                }
                else{
                    system.debug('!!!!!!!!!!!!!!!!!! Case Role - UWF Payee !!!!!!!!!!!!!!!!!!');
    
                    //Call Insert Payee
                    system.debug('!!!!!!!!!!!!!!!!!! Insert UWF Payees !!!!!!!!!!!!!!!!!!');
                    system.debug('UWF Payees to Insert ==> ' + updatedPayeesToInsert);
                    System.enqueueJob(new UWFPayeeInsertQable(updatedPayeesToInsert, wrsToInsert, prsToUpdate, reqType, wbURL, qJobIdMap));
                }
            }
        }
        catch(Exception e){
            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();
            
            qJobIdMap.put('Insert UWF Case Roles', new List<Id>{qc.getJobId()});

            System.attachFinalizer(new WarrantFinalizer(wbURL, qJobIdMap, actType ,errorMessage));
        }
        
    }
}