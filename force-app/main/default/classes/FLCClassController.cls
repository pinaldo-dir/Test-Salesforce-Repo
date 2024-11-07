public class FLCClassController {
    
    public String Training_Organization{get;set;}
    public String Hours_Completed{get;set;}
    public String Language{get;set;}
    public String Other_Language{get;set;}
    public Date Completion_Date{get;set;}
    public String Notes{get;set;}
    
    public Id ownerId {get;set;}
    
    public Ownership__c owner {get;set;}
    public List<Registration_Course__c> regCourse {get;set;}
    
    public FLCClassController(){
        System.debug('Start of Controller');
        
        ownerId = ApexPages.currentPage().getParameters().get('id');
        //ownerId = 'a3s350000002cft';
        
        owner = [SELECT Id,First_Name__c, Last_Name__c
                 FROM Ownership__c 
                 WHERE Id =: ownerId];
        
        regCourse = [SELECT id
                     , Name
                     , Ownership__r.First_Name__c
                     , Ownership__r.Last_Name__c
                     , Training_Organization__c
                     , Hours_Completed__c
                     , Language__c
                     , Completion_Date__c
                     , Notes__c
                     , User__r.Name
                     
                     FROM Registration_Course__c
                     WHERE Ownership__r.Id =: ownerId];
        
    }
    
    public void LinkClass() {
        Registration_Course__c course1 = new Registration_Course__c();
        
        course1.Ownership__c = ownerId;
        course1.Training_Organization__c = Training_Organization;
        course1.Hours_Completed__c = Hours_Completed;
        course1.Language__c = Language;
        course1.Completion_Date__c = Completion_Date;
        course1.Notes__c = Notes;
        course1.User__c = UserInfo.getUserId();
        insert course1;
        
        regCourse = [SELECT id
                     , Name
                     , Ownership__r.First_Name__c
                     , Ownership__r.Last_Name__c
                     , Training_Organization__c
                     , Hours_Completed__c
                     , Language__c
                     , Completion_Date__c
                     , Notes__c
                     , User__r.Name
                     FROM Registration_Course__c
                     WHERE Ownership__r.Id =: ownerId];
        
        Training_Organization = null;
        Hours_Completed = null;
        Language = 'English';
        Completion_Date = null;
        Notes = null;
        
        course1 = new Registration_Course__c();
    }

    
    public List<SelectOption> getLanguageList() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('English','English'));
        options.add(new SelectOption('Spanish','Spanish'));
        return options;
    } 
}