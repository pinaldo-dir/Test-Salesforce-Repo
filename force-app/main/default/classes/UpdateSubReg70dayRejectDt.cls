public class UpdateSubReg70dayRejectDt implements UpdateSubReg70dayRejectDtScheduler.IScheduleUpdate{
      
    public void execute(SchedulableContext sc) {
        Datetime dt = Datetime.now().addMinutes(10);
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        
        if ([SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')] < 1){
            Database.executeBatch(new UpdateSubReg70dayRejectDtBatch(), 1);
        } else {
            System.Schedule('UpdateSubReg70dayRejectDtBatch_RETRY_' + timeForScheduler, timeForScheduler, new UpdateSubReg70dayRejectDtScheduler());
        }
    }
}