/*To set the schedule, assuming there isn't one already, paste the following lines in the execute anonymous window (CTRL+e) in the developer console:

ScheduleCashNightlyRollup scheduleCashNightlyRollup = new ScheduleCashNightlyRollup();
// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
String runTime = '30 15 2 * * ?'; //runs every morning at 2:15:30 am
String jobID = System.schedule('Nightly Cash Balance on Case Rollup', runTime, scheduleCashNightlyRollup);

*/
global class ScheduleCashNightlyRollup implements Schedulable{
    global void execute(SchedulableContext sc){
        Database.executebatch(new CashNightlyRollup(), 1);
    }
}