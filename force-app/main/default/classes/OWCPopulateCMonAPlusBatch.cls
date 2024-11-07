global class OWCPopulateCMonAPlusBatch implements Database.Batchable<sobject> {
    
    global Database.QueryLocator start(database.BatchableContext bc ){        
        String attachment = 'SELECT Id, Related_Id__c,Name, Case_Management__c FROM Attachments_New__c WHERE Case_Management__c = null AND Related_Id__c like \'a1B%\' ' ;        
        return Database.getQueryLocator(attachment);
    }
    
    global void execute (Database.BatchableContext bc, List<Attachments_New__c> scope ) {
        List<Attachments_New__c> attachUpate = new List<Attachments_New__c>(); 
        for(Attachments_New__c attachObj: scope){
            if(String.isNotBlank(attachObj.Related_Id__c)){
                attachObj.Case_Management__c = attachObj.Related_Id__c;
                attachUpate.add(attachObj);
            }            
        } 
        system.debug('attachUpate::::: ' + attachUpate);
        if(attachUpate !=  null && attachUpate.size() > 0 ){
            Database.update(attachUpate, false) ; 
        }   
        
    }
    
    global void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'dsyadav@cloudsciencelabs.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation schedule email update' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed Attachment plus update ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}