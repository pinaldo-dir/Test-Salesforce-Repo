global class OWCDeleteUnConfirmedClaimsScheduler implements Schedulable {
    global void execute(SchedulableContext sc) 
    {
        //delete Unconfirmed Claims older than 180 days
        OWCDeleteUnConfirmedClaimsBatch deleteUnconfirmedClaims = new OWCDeleteUnConfirmedClaimsBatch(180);
        database.executeBatch(deleteUnconfirmedClaims);
    }

}