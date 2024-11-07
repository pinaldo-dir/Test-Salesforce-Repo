public class FLCClassAdminController { // without sharing if instructor cannot view registration #, otherwise use sharing rules/sets
    
    public License_Registration__c currentRegistration {get;set;}
    public List<License_Registration__c> AllRegistrations {get;set;}
    public Ownership__c owners {get;set;}
    public List<Ownership__c> allOwners {get;set;}
    
    public String errormessage {get; set;}
    public String errortype {get; set;}
    public String errorDisplay {get; set;}
    private User currentUser;
  //  public String currentRecordType {get; set;}
    private List<RecordType> registrationRecordTypes;
    
    public FLCClassAdminController(){
        
        currentRegistration = new License_Registration__c();
        AllRegistrations = new List<License_Registration__c>();
        owners = new Ownership__c();
        allOwners = new List<Ownership__c>();
        
        errortype = '';
        errorDisplay = 'none'; 
        errormessage = '';
        
        currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        
         Map<String,String> devNames = new Map<String,String>();
        for(Registration_Template_Mapping__mdt mdt : [select id,DeveloperName,Record_Type_Developer_Name__c,Template_ID__c from Registration_Template_Mapping__mdt]){
            devNames.put(mdt.Record_Type_Developer_Name__c, mdt.Template_ID__c);
        }       
        registrationRecordTypes = new List<RecordType>();
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='License_Registration__c' AND DeveloperName IN :devNames.keySet() AND IsActive = true ORDER BY Name ASC]){
            registrationRecordTypes.add(rt);
        }        
    }
    
    
    
    public void SearchRegistration() {
    
        System.debug('License entered '+currentRegistration.License_Registration_Number__c);
        
        String query = 'SELECT Id ' 
                 +', Registration__r.Legal_Entity_Name__c'
                 +', Registration__r.License_Registration_Number__c'
                 +', Registration__r.Effective_Date__c'
                 +', Registration__r.Expiration_Date__c'
            	 +', Registration__r.Status__c'
            	+', Registration__r.CreatedDate'
           		 +', First_Name__c, Middle_Name__c'
                 +', Last_Name__c'
             +' FROM Ownership__c'
             +' WHERE  Registration__r.Status__c IN (\'Approved\', \'Incomplete\', \'Pending Payment\', \'Pending / Defect\', \'Transmitted\', \'Submitted\', \'Resubmitted\') AND Registration__r.RecordType.Name = \'Farm Labor Contractor\'';
        
        // Add additional search criteria here
        if (currentRegistration.License_Registration_Number__c != NULL) {query += ' AND Registration__r.License_Registration_Number__c LIKE \''+ currentRegistration.License_Registration_Number__c+'\'';}
        if (currentRegistration.Legal_Entity_Name__c != NULL) {query += ' AND Registration__r.Legal_Entity_Name__c LIKE \''+ currentRegistration.Legal_Entity_Name__c +'%\'';}
        if (owners.First_Name__c != NULL) {query += ' AND First_Name__c LIKE \''+ owners.First_Name__c + '%\'';}
        if (owners.Middle_Name__c != NULL) {query += ' AND Middle_Name__c LIKE \''+ owners.Middle_Name__c + '%\'';} 
        if (owners.Last_Name__c != NULL) {query += ' AND Last_Name__c LIKE \''+ owners.Last_Name__c+'%\'';}


        
        
            
            System.debug('Query=======>'+query);
            if( !Test.isRunningTest()){
                allOwners = Database.query(query);
            }

            System.debug('ALL Owners: '+ AllOwners);
   
            if(AllOwners.size() < 1) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,'No results found.Please create a new Application.');
                ApexPages.addMessage(msg);  
            }  
        }
    

 public PageReference CancelBack() {
currentRegistration.License_Registration_Number__c = NULL;
        return null;
    } 
    
    // clears all the fields on Search page
    public void ClearFields() {
        currentRegistration.License_Registration_Number__c = NULL;
        currentRegistration.Legal_Entity_Name__c = NULL;
        owners.First_Name__c = NULL;
        owners.Middle_Name__c = NULL;
        owners.Last_Name__c = NULL;
        
    } 
    
    
}