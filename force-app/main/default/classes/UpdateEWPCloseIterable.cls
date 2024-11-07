public class UpdateEWPCloseIterable implements Iterable<SObject>{ 
    public Iterator<SObject> iterator() {
        List<License_Registration__c> registrationList = new List<License_Registration__c>();
        List<License_Registration__c> successList = new List<License_Registration__c>();
        //List<Registration_Account__c> registrationAccountList = new List<Registration_Account__c>();
        
        // * get list EWP - 6 month permit for ages 0 to 5 years
        Date d1 = Date.today();
        Date d2 = d1.addYears(-18);
        String query = 'SELECT Id'
            + ' , Birth_Date__c'
            + ' , Applicant_s_Email__c'
            +'  , Applicant__c'
            + ' FROM License_Registration__c'
            + ' WHERE RecordType.Name = \'Entertainment Work\''
            + ' AND Status__c IN (\'Approved\', \'Submitted\',\'Resubmitted\',\'Pending / Defect\')'
            + ' AND Applicant__c != NULL'
            + ' AND Applicant_s_Email__c != NULL'
            + ' AND Birth_Date__c < :d2'
            + ' ORDER BY CreatedDate DESC';
        
        registrationList = Database.query(query);
                
        if (!registrationList.isEmpty()) {
            
          System.debug('Entering .....:' + registrationList);  
          
            for(License_Registration__c eachRegistration : registrationList){
                eachRegistration.Closure_Reason__c = 'minor is now 18 years old';
                eachRegistration.Status__c = 'Closed';
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