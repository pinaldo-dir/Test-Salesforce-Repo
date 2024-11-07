public class HRF1StatusTodayUpdateSchedule implements Schedulable {
     public void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
       
        // We now call the batch class to be scheduled
        HRbatchF1StatusTodayUpdate TodaysDate = new HRbatchF1StatusTodayUpdate ();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(TodaysDate,2000);
    }
    
    

}