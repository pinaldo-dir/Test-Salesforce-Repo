public class WCAInactiveTrackingTodayUpdateSchedule implements Schedulable {
    
     public void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled       
        // We now call the batch class to be scheduled
        WCAbatchInactiveTrackingTodayUpdate TodaysDate = new WCAbatchInactiveTrackingTodayUpdate ();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(TodaysDate,5);
    }   
   
}