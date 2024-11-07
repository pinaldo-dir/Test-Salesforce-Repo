public class MeetingUpdateSrDeputy Implements Queueable {
    
    private List<Hearing__c> acceptedList; 
	private ID manager;
    
    public MeetingUpdateSrDeputy(List<Hearing__c> acceptedList, ID manager){
        this.acceptedList = acceptedList;
        this.manager = manager;
    }   
    
    public void execute (QueueableContext context){
        for (Hearing__c hearing: acceptedList) {
            hearing.Sr_Case_Deputy__c = manager; 
        }
        
        update acceptedList;
    }

}