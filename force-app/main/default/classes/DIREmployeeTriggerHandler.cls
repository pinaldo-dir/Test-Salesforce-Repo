public class DIREmployeeTriggerHandler {
    
    public static void updateDeputyOnMeeting(List<DIR_Employee__c> newList, Map<Id, DIR_Employee__c> oldMap){
        
        set<id> employeeSet = new set<id>();
        set<id> managerSet = new set<id>();
        
        //compare if assigned deputy or senior deputy has changed
        for (DIR_Employee__c c : newList){
            if (c.Manager__c  != oldMap.get(c.Id).Manager__c && c.Manager__c  != null){
                employeeSet.add(c.User__c );
                managerSet.add(c.Manager__c);
                
            }   
        }
        
        if(employeeSet.size() > 0){
            list<Hearing__c> acceptedList = [SELECT ID, Case__c, Case_Deputy__c, Sr_Case_Deputy__c,Case__r.Assigned_Deputy__r.User__c,
                                             Case__r.Assigned_Deputy__r.Manager__r.User__c, Status__c FROM Hearing__c Where Case_Deputy__c	in : employeeSet AND Status__c IN ('New','Pending Approval') AND Case__r.Status__c != 'Closed' 
                                             AND RecordType.name IN ('WCA Hearing', 'BOFE Hearing')];
            List<DIR_Employee__c> manager = [Select User__c FROM DIR_Employee__c where ID in : managerSet ];
            
            //instantiate a new instance of the Queable class
            MeetingUpdateSrDeputy updateDeputy = new MeetingUpdateSrDeputy(acceptedList, manager[0].user__c);
            // enqueue the job for processsing
            ID jobID= System.enqueueJob(updateDeputy);  
        }
    }
}