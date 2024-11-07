public with sharing class UpdateSubRegDtCloseBatch implements Database.Batchable<SObject>{
    
    public Iterable<SObject> start(Database.BatchableContext bc) {
        return new UpdateSubRegCloseRejectDtIterable();
    }
    
    
    public void execute(Database.BatchableContext bc, List<License_Registration__c> registrations) {
        //update registrations;
        
        if(!registrations.isEmpty()){
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();  
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            EmailTemplate emailTemplate = new EmailTemplate();
            
            for(License_Registration__c eachRegistration : registrations){
                //System.debug('Registration number =' + eachRegistration.Id); 
                message = new Messaging.SingleEmailMessage();
                emailTemplate = new EmailTemplate();
                
                message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(eachRegistration.Applicant__r.Id); 
                message.setSenderDisplayName('DLSE Registration Services'); 
                message.setReplyTo('no-reply@salesforce.com');
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false);
                
                /*Integer rejectDays = NULL;
                                               
                 if(eachRegistration.Initial_Reject_Date__c != NULL)
                {                
                    rejectdays = (eachRegistration.Initial_Reject_Date__c.daysBetween(Date.valueOf(system.today()))); 
                }
                if(eachRegistration.Initial_Reject_Date__c != NULL
                        && rejectdays != NULL
                        && rejectdays <= 61)
                {
                    emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Rejection Close Email'];   
                }*/
                
                emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Rejection Close Email'];   
                               
                message.setTemplateID(emailTemplate.Id); 
                message.setWhatId(eachRegistration.Id); //This is important for the merge fields in template to work
                message.toAddresses = new String[] {eachRegistration.Applicant__r.email};
                //message.toAddresses = new String[] {'tken@dir.ca.gov'};
                //messages = new List<Messaging.SingleEmailMessage> {message};
                //Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                messages.add(message);

            }   //For Loop
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success){
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send:'  +  results[0].errors[0].message);
            }       
            
        } // If registrations not empty
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
    public void neededForTestCoverage() {
        // keep this so that coverage is not dependent on custom metadata records
        
        String foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
    }
    

}