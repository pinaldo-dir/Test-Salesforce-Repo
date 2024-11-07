public class RegistrationsExamHandler {
    private static registrationsExamHandler classInstance = null;
    public Boolean stopRecursion {get; set;}
    
    private RegistrationsExamHandler() {
        stopRecursion = FALSE;
    }
    
    public static RegistrationsExamHandler getInstance(){
        if (null == classInstance) {
            classInstance = new registrationsExamHandler();
        }
        return classInstance;
    }
    
    public void onBeforeInsert(List<Registrations_Exam__c> newList){ 
    }
    
    public void onAfterInsert(List<Registrations_Exam__c> newList , Map<id, Registrations_Exam__c> newMap){  
    }
    
    public void onBeforeUpdate(List<Registrations_Exam__c> newList, Map<id, Registrations_Exam__c> newMap, Map<id, Registrations_Exam__c> oldMap){
    }
    
    public void onAfterUpdate(List<Registrations_Exam__c> newList, Map<id, Registrations_Exam__c> newMap, Map<id, Registrations_Exam__c> oldMap){
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            updateNumberOfExams(newList, 'update');
            stopRecursion = FALSE;
        }
    }
    
    public void onBeforeDelete(List<Registrations_Exam__c> oldList, Map<id, Registrations_Exam__c> oldMap){
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            updateNumberOfExams(oldList, 'delete');
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterDelete(list<Registrations_Exam__c> oldList, Map<id, Registrations_Exam__c> oldMap){

    }
    
    private void updateNumberOfExams(List<Registrations_Exam__c> oldREList, String action){
        List<License_Registration__c> lReg = [SELECT Id, Number_of_Registration_Exams__c FROM License_Registration__c WHERE Id =: oldREList[0].Registration_Id__c];
        //System.debug('lReg:' + lReg[0]);
        System.debug('lReg:' + lReg.size());
        
        List<Registrations_Exam__c> numberOfExams = [SELECT Id, Registration_Id__c FROM Registrations_Exam__c WHERE Registration_Id__c =: oldREList[0].Registration_Id__c AND Inactive__c = FALSE AND Exam_Disposition__c  != 'Not Taken'];
        //System.debug('numberOfExams:' + numberOfExams[0]);
        System.debug('numberOfExams:' + numberOfExams.size());
        
        if(lReg.size() > 0){ 
            if(numberOfExams.size() > 0){
                if(action == 'delete'){
                    lReg[0].Number_of_Registration_Exams__c = numberOfExams.size() - 1;
                }
                else if(action == 'update'){
                    lReg[0].Number_of_Registration_Exams__c = numberOfExams.size();
                }
            } 
            else if(numberOfExams.size() < 1){
                lReg[0].Number_of_Registration_Exams__c = 0;
            }
        }
        update lReg;
    }
}