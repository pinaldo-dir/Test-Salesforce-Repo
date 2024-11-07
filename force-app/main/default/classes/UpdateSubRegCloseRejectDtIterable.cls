public without sharing class UpdateSubRegCloseRejectDtIterable implements Iterable<SObject>{
    
    public Iterator<SObject> iterator() {

        List<License_Registration__c> sobjects = new List<License_Registration__c>();
        List<License_Registration__c> records3 = new List<License_Registration__c>();
        List<License_Registration__c> registrationList = new List<License_Registration__c>();
        List<License_Registration__c> closedList = new List<License_Registration__c>();

        
        // Subsequent End process - final rejection email sent out ****
        Date myDate = Date.today().addDays(-61); 
        //Date newDate = myDate.addDays(-61);
    
    String query3 = 'SELECT id, Applicant__r.Id, Applicant__r.Email,Initial_Reject_Date__c,Initial_Defect_Date__c '
        + ' FROM License_Registration__c'
        + ' WHERE Status__c = \'Pending / Defect\''
        + ' AND Applicant__r.id != NULL'
        + ' AND Account__r.id != NULL'
        + ' AND Initial_Reject_Date__c != NULL'
        + ' AND Initial_Reject_Date__c =: myDate'
        + ' AND RecordType.Name = \'Garment Manufacturers and Contractors\'';
    
    records3 = Database.query(query3);
    if (!records3.isEmpty()) {
        for(License_Registration__c eachRecord : records3){
            eachRecord.Status__c = 'Closed - Rejected';
            eachRecord.Closure_Reason__c ='60Day-Sub';
            eachRecord.Reject_Date__c = System.Today();
            
            registrationList.add(eachRecord);
        }// for loop records3 not empty()
        
            if(!registrationList.isEmpty()){
                Database.SaveResult[] updateResults = Database.update(registrationList,false);
                
               for(Integer i=0;i<updateResults.size();i++){
                  if (updateResults.get(i).isSuccess()){
                         closedList.add(registrationList.get(i));
                        

                  } else{ 
                      
                      System.debug('Failure records:' + registrationList.get(i));
                  }
                  
              } // for loop 
            }// If !registrationList.isEmpty()
            
                 
    }
        //sobjects.addAll(closedList);
        
        //return sobjects.iterator();
        return closedList.iterator();
    }    
    
}