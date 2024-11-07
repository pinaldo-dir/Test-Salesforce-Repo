global class UpdateExistingAttachmentDataBatch implements Database.Batchable<sObject>, Database.Stateful{
    public integer count = 0;
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id,APlus_Json__c, Name, Community__c, File_Name__c, File_Type__c, Related_Id__c, Visible__c, Description__c ';
        //query += ' (SELECT Id, Name, Attachments__c, Field_API_Name__c, Field_Name__c, File_Type__c, Value__c FROM Attachments_Data__r)';
        query += ' FROM Attachments_New__c';// + ' WHERE Related_Id__c = \'a1Bt00000005PO9EAM\'';
        //query += (!Test.isRunningTest()) ? '': ' LIMIT 1';
        System.debug('query ::: '+query);
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext bc, List<Attachments_New__c> scope){
        List<Attachments_New__c> attachPlusToBeUpdated = new List<Attachments_New__c>();
        Map<Id, List<Attachments_Data__c>> aPlusWithaDatasMap = new Map<Id, List<Attachments_Data__c>>();
        Set<Id> aPlusIds = new Set<Id>();
        System.debug('result ::: '+scope);
        for(Attachments_New__c aPlus: scope)
        {
           aPlusIds.add(aPlus.Id); 
        }
        for(Attachments_Data__c aData : [SELECT Id, Name, Attachments__c, Field_API_Name__c, Field_Name__c, File_Type__c, Value__c FROM Attachments_Data__c
                                        WHERE Attachments__c IN: aPlusIds ])
        {
            if(!aPlusWithaDatasMap.containsKey(aData.Attachments__c)){
                aPlusWithaDatasMap.put(aData.Attachments__c, new List<Attachments_Data__c>());
            }
            aPlusWithaDatasMap.get(aData.Attachments__c).add(aData);
        }
        if(scope != null && scope.size() > 0){
            for(Attachments_New__c aPlus : scope){
                if(aPlusWithaDatasMap.containsKey(aPlus.Id)){
                    List<OWCServiceUtility.attachmentPlusWrapperObj> updateAttachPlusRec = new List<OWCServiceUtility.attachmentPlusWrapperObj>();
                    for(Attachments_Data__c attachDataObj : aPlusWithaDatasMap.get(aPlus.Id)){
                        updateAttachPlusRec.add(new OWCServiceUtility.attachmentPlusWrapperObj(attachDataObj.Field_API_Name__c, attachDataObj.Field_Name__c, attachDataObj.Value__c, attachDataObj.File_Type__c));
                    }
                    
                    aPlus.APlus_Json__c = (updateAttachPlusRec != null && updateAttachPlusRec.size() > 0) ? JSON.serialize(updateAttachPlusRec) : '';
                    attachPlusToBeUpdated.add(aPlus);
                }
            }
        }
        
        if(attachPlusToBeUpdated != null && attachPlusToBeUpdated.size() > 0){
            update attachPlusToBeUpdated;
        }
    }
    
    global void finish(Database.BatchableContext bc){
    }
}