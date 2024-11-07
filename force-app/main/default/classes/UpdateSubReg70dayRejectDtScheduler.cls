public class UpdateSubReg70dayRejectDtScheduler implements Schedulable {
            
    public interface IScheduleUpdate {
        void execute(SchedulableContext sc);
    }
    
    public void execute(SchedulableContext sc) {
        Type targetType = Type.forName('UpdateSubReg70dayRejectDt');
        if (targetType != null) {
            IScheduleUpdate obj = (IScheduleUpdate)targetType.newInstance();
            obj.execute(sc);
        }
    }
}