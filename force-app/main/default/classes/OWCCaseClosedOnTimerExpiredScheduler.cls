public class OWCCaseClosedOnTimerExpiredScheduler implements Schedulable {
    public void execute(SchedulableContext sc) 
    {
        OWCCaseClosedOnTimerExpiredBatch cloasedCaseBatch = new OWCCaseClosedOnTimerExpiredBatch(0);
        database.executeBatch(cloasedCaseBatch);
    }
}