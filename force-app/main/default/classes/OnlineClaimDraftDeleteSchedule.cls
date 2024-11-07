global class OnlineClaimDraftDeleteSchedule implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        OnlineClaimDraftDeleteBatch batch = new OnlineClaimDraftDeleteBatch(180);
        
        database.executeBatch(batch);
    }
}