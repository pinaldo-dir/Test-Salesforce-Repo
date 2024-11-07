public without sharing class UpdateSubsequentRegistrationIterable implements Iterable<SObject>{
    
    public Iterator<SObject> iterator() {
      
        List<License_Registration__c> emailWarningList = new List<License_Registration__c>();
      
        
     // * send warning email for rejection at start of 60 day subsequent is sent
		Date myDate = Date.today().addDays(-61); 
        //Date newDate = myDate.addDays(-61);
        
        String query = 'SELECT id, Applicant__r.Id, Applicant__r.Email,Initial_Reject_Date__c,Initial_Defect_Date__c,Number_of_Exam_Takers__c'
            + ' FROM License_Registration__c'
            + ' WHERE Status__c = \'Pending / Defect\''
            + ' AND Applicant__r.id != NULL'
            + ' AND Account__r.id != NULL'
            + ' AND Initial_Defect_Date__c =: myDate'
            + ' AND Initial_Reject_Date__c = NULL'
            + ' AND RecordType.Name = \'Garment Manufacturers and Contractors\'';
        
       	emailWarningList = Database.query(query);
        if (!emailWarningList.isEmpty()) {
                               
  		} 
        
    return emailWarningList.iterator();
} 

}