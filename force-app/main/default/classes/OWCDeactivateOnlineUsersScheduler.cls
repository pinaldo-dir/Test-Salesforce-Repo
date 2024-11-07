/*Name:OWCDeactivateOnlineUsersScheduler
 * Description: //deactivating the community accounts that are 90 days since the close of case  
 */
global class OWCDeactivateOnlineUsersScheduler implements Schedulable {
    global void execute(SchedulableContext sc) 
    { 
        //deactivating the community accounts that are 90 days since the close of case  
        OWCDeactivateOnlineUsersWithClosedCase batch = new OWCDeactivateOnlineUsersWithClosedCase();
        database.executeBatch(batch, 100); 
    }
}