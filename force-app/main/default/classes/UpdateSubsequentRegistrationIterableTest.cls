@istest
public class UpdateSubsequentRegistrationIterableTest {
    
    public static testMethod void UpdateSubsequentRegistrationIterableTest(){
        
     
        List<License_Registration__c> sobjects = new List<License_Registration__c>();
        List<License_Registration__c> records = new List<License_Registration__c>();
        List<License_Registration__c> records2 = new List<License_Registration__c>();
        List<License_Registration__c> records3 = new List<License_Registration__c>();
        
             // * send warning email for rejection at start of 60 day subsequent is sent

        String query = 'SELECT id, Applicant__r.Id, Applicant__r.Email,Initial_Reject_Date__c,Initial_Defect_Date__c,Number_of_Exam_Takers__c'
            + ' FROM License_Registration__c'
            + ' WHERE Status__c = \'Pending / Defect\''
            + ' AND Applicant__r.id != NULL'
            + ' AND Account__r.id != NULL'
            + ' AND Initial_Defect_Date__c < LAST_N_DAYS:60'
            + ' AND Initial_Reject_Date__c = NULL'
            + ' AND RecordType.Name = \'Garment Manufacturers and Contractors\'';
        
                records = Database.query(query);
        if (!records.isEmpty()) {
            for(License_Registration__c eachRecord : records){
                  
               Integer days = (eachRecord.Initial_Defect_Date__c.daysBetween(Date.valueOf(system.today()))); 
                //System.debug('days =' + days);
                if(days <= 61){
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setTargetObjectId(eachRecord.Applicant__r.Id); 
                        message.setSenderDisplayName('DLSE Registration Services'); 
                        message.setReplyTo('no-reply@salesforce.com');
                        message.setUseSignature(false); 
                        message.setBccSender(false); 
                        message.setSaveAsActivity(false); 
                        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Rejection Warning Email'];
                        message.setTemplateID(emailTemplate.Id); 
                        message.setWhatId(eachRecord.Id); //This is important for the merge fields in template to work
                        message.toAddresses = new String[] {eachRecord.Applicant__r.email};
                            //message.toAddresses = new String[] {'tken@dir.ca.gov'};
                            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
           		 
                    if (results[0].success) 
                    {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send:'  +  results[0].errors[0].message);
                    }
                } // days
            }  
  		
    
  	 }
        
            // Subsequent End process - final rejection email sent out ****
    
    String query2 = 'SELECT id, Applicant__r.Id, Applicant__r.Email,Initial_Reject_Date__c '
        + ' FROM License_Registration__c'
        + ' WHERE Status__c = \'Pending / Defect\''
        + ' AND Applicant__r.id != NULL'
        + ' AND Account__r.id != NULL'
        + ' AND Initial_Reject_Date__c != NULL'
        + ' AND Initial_Reject_Date__c < LAST_N_DAYS:60'
        + ' AND RecordType.Name = \'Garment Manufacturers and Contractors\'';
    
            records2 = Database.query(query2);
    if (!records2.isEmpty()) {
        for(License_Registration__c eachRecord : records2){
            eachRecord.Status__c = 'Closed - Rejected';
            eachRecord.Closure_Reason__c ='60Day-Sub';
            eachRecord.Reject_Date__c = System.Today();
            
            //if(eachRecord.Initial_Reject_Date__c == NULL){ 	// Intial Reject date
            
            
            // }
            //if(eachRecord.Reject_Date__c == NULL){ //initial reject date
            // eachRecord.Reject_Date__c = System.Today();
            //}
            
            Messaging.SingleEmailMessage message2 = new Messaging.SingleEmailMessage();
            message2.setTargetObjectId(eachRecord.Applicant__r.Id); 
            message2.setSenderDisplayName('DLSE Registration Services'); 
            message2.setReplyTo('no-reply@salesforce.com');
            message2.setUseSignature(false); 
            message2.setBccSender(false); 
            message2.setSaveAsActivity(false); 
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Rejection Close Email'];
            message2.setTemplateID(emailTemplate.Id); 
            message2.setWhatId(eachRecord.Id); //This is important for the merge fields in template to work
            message2.toAddresses = new String[] {eachRecord.Applicant__r.email};
                //message.toAddresses = new String[] {'tken@dir.ca.gov'};
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message2};
                    Messaging.SendEmailResult[] results2 = Messaging.sendEmail(messages);
            
            if (results2[0].success) 
            {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send:'  +  results2[0].errors[0].message);
            }
        }                  
    }
        
                //* Update Initial Rejection date at 60 day subsequent start - allowing 10 day grace period
        
         String query3 = 'SELECT id, Applicant__r.Id, Applicant__r.Email,Initial_Reject_Date__c,Initial_Defect_Date__c '
            + ' FROM License_Registration__c'
            + ' WHERE Status__c = \'Pending / Defect\''
            + ' AND Applicant__r.id != NULL'
            + ' AND Account__r.id != NULL'
            + ' AND Initial_Defect_Date__c < LAST_N_DAYS:70'
            + ' AND Initial_Reject_Date__c = NULL'
            + ' AND RecordType.Name = \'Garment Manufacturers and Contractors\'';
        
                records3 = Database.query(query3);
        if (!records3.isEmpty()) {
            for(License_Registration__c eachRecord : records3){
                               
                eachRecord.Initial_Reject_Date__c = System.Today();
               
                //if(eachRecord.Initial_Reject_Date__c == NULL){ 	// Intial Reject date
            	}
            }
        
         sobjects.addAll(records3);
   		 sobjects.addAll(records2);    
    
  		// return sobjects.iterator();
        
  }
}