public class UpdateRegistrationApproveStatusIterable implements Iterable<SObject> {
    
    public Iterator<SObject> iterator() {
        List<License_Registration__c> registrationList = new List<License_Registration__c>();
        List<License_Registration__c> successList = new List<License_Registration__c>();
        //List<Registration_Account__c> registrationAccountList = new List<Registration_Account__c>();
        
        // * get list EWP - 6 month permit for ages 0 to 5 years
        Date d1 = Date.today();
        Date d2 = d1.addYears(-6);
        String query = 'SELECT Id'
            + ' , Birth_Date__c'
            + ' , Applicant_s_Email__c'
            +'  , Applicant__c'
            + ' FROM License_Registration__c'
            + ' WHERE RecordType.Name = \'Entertainment Work\''
            + ' AND Service_Type__c = \'Renewal\''
            + ' AND Status__c IN (\'Submitted\', \'Resubmitted\')'
            + ' AND Registration_Duration__c = \'6 Months - Permit\''
            + ' AND Previous_Registration_Duration__c = \'6 Months - Permit\''
            + ' AND Applicant__c != NULL'
            + ' AND Birth_Date__c >:d2'
            //+ ' AND Birth_Date__c >= LAST_N_DAYS:1825'
            + ' ORDER BY CreatedDate DESC'
            + ' LIMIT 22';
        
        registrationList = Database.query(query);
                
        if (!registrationList.isEmpty()) {
            
          System.debug('Entering .....:' + registrationList);  
          
            for(License_Registration__c eachRegistration : registrationList){
                eachRegistration.Status__c = 'Approved';
                eachRegistration.Effective_Date__c = date.today();
                eachRegistration.Expiration_Date__c = eachRegistration.Effective_Date__c.addMonths(6);
                //registrationList.add(eachRegistration);
                              
            }// for loop
             
            if(!registrationList.isEmpty()){
                Database.SaveResult[] updateResults = Database.update(registrationList,false);
                
               for(Integer i=0;i<updateResults.size();i++){
                  if (updateResults.get(i).isSuccess()){
                         successList.add(registrationList.get(i));

                  } else{ 
                      
                      System.debug('Failure records:' + registrationList.get(i));
                  }
                  
              } // for loop 
            }// If !registrationList.isEmpty()
                     
        } 
        
          return successList.iterator();
    } 
}