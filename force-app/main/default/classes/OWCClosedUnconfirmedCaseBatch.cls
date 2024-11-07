global class OWCClosedUnconfirmedCaseBatch implements Database.Batchable<sObject>{
    Integer timer ;
    global OWCClosedUnconfirmedCaseBatch(Integer noOfDays){
        timer = noOfDays;
    }
    //Fetching all the online claim Draft having lastmodifieddate less than 60 days 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT ID,Name,LastModifiedDate,Status__c,Closure_Disposition__c,Case_Closed_Date__c,
            Related_Party_Advocate_Email__c,Advocate_Name_in_Text__c,Claimant_Name_in_Text__c,Related_Party_Employer_Name__c,createdDate, Sent_Confirmation_Email__c 
            FROM DIR_Case__c  
            WHERE Status__c = 'Not Confirmed' AND Timer__c < 0
        ]);
    }
    global void execute(Database.BatchableContext BC, List<DIR_Case__c>scope){
        List<DIR_Case__c> caseToUpdate = new List<DIR_Case__c>();
        for(DIR_Case__c cse: scope){
            cse.Status__c = 'Closed';
            cse.Case_Closed_Date__c = Date.today();
            cse.Closure_Disposition__c = 'Not confirmed by Claimant';
            cse.Sent_Confirmation_Email__c = true; 
            caseToUpdate.add(cse);
            //send email nofication to advocate
        }
        
        database.update(caseToUpdate, false) ;
        sendEmailtoAdvocateOnClosed(caseToUpdate);
    }
    
    public static void sendEmailtoAdvocateOnClosed(List<DIR_Case__c> caseRecordList){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(DIR_Case__c caseRecord: caseRecordList){
            Messaging.SingleEmailMessage email = OCEmailServiceUtility.sendEmailToAdvocateOnCaseClosure('Advocate_notification_on_unconfirmed_case_closed', caseRecord);
            if(email != null){
                emailList.add(email);
            }
        }
                
        if(!emailList.isEmpty()){
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
            }
            catch(Exception e){
                System.debug('error : '+ e.getMessage());
            }
        }
    }
    global void finish(Database.BatchableContext BC){
    }

}