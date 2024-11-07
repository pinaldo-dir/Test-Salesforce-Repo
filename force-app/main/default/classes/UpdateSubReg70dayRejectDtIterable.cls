public without sharing class UpdateSubReg70dayRejectDtIterable implements Iterable<SObject>{
    
        public Iterator<SObject> iterator() {
        List<License_Registration__c> sobjects = new List<License_Registration__c>();
        List<License_Registration__c> records2 = new List<License_Registration__c>();
        List<License_Registration__c> registrationList = new List<License_Registration__c>();
        List<License_Registration__c> successList = new List<License_Registration__c>();
                       
        //* Update Initial Rejection date at 71 day subsequent start - allowing 10 day grace period from the warning email for 61st day.
        Date myDate = Date.today().addDays(-71); 
        //Date newDate = myDate.addDays(-71);
            
         String query2 = 'SELECT id, Applicant__r.Id, Applicant__r.Email,Initial_Reject_Date__c,Initial_Defect_Date__c '
            + ' FROM License_Registration__c'
            + ' WHERE Status__c = \'Pending / Defect\''
            + ' AND Applicant__r.id != NULL'
            + ' AND Account__r.id != NULL'
            + ' AND Initial_Defect_Date__c =: myDate'
            + ' AND Initial_Reject_Date__c = NULL'
            + ' AND RecordType.Name = \'Garment Manufacturers and Contractors\'';
        
        records2 = Database.query(query2);
        if (!records2.isEmpty()) {
            for(License_Registration__c eachRecord : records2){
                               
                eachRecord.Initial_Reject_Date__c = System.Today();
                registrationList.add(eachRecord);
                //if(eachRecord.Initial_Reject_Date__c == NULL){    // Intial Reject date
                                
                }
                
            }
                                        
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
    
    //sobjects.addAll(records3);
    sobjects.addAll(successList); 
    //sobjects.addAll(emailWarningList); 
    //sobjects.addAll(closedList);     
    return sobjects.iterator();

}
}