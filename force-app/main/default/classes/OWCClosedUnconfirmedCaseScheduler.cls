global class OWCClosedUnconfirmedCaseScheduler implements Schedulable {
    global void execute(SchedulableContext sc) 
    { 
        //delete Unconfirmed Claims older than 180 days 
        OWCClosedUnconfirmedCaseBatch closedUnconfirmedClaims = new OWCClosedUnconfirmedCaseBatch(60);
        database.executeBatch(closedUnconfirmedClaims); 
    }
}