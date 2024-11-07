@isTest
public class ScheduleCashNightlyRollupTest{
    
    static testmethod void test(){
        SchedulableContext sc;
        ScheduleCashNightlyRollup scnr = new ScheduleCashNightlyRollup();
        scnr.execute(sc);
    }
}