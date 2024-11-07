global class ScheduleRegistrationArchiveBatch Implements Schedulable {
    
	global void execute (SchedulableContext sc)
    {
        archiveRegistrationContentDocument();
        archiveSubmissionDetailContentDocument();
    }
    
    public void archiveRegistrationContentDocument(){
        //String version Query Content Document for Registration
        String q = 'SELECT Id, LINkedEntityId, LINkedEntity.name, ContentDocumentId , ContentDocument.title FROM ContentDocumentLink' + 
            ' WHERE LINkedEntityId IN (SELECT Id FROM License_Registration__c WHERE Status__c IN (\'Approved\', \'Closed\', \'Closed - Denied\', \'Closed - Duplicate\', \'Closed - INactive\', \'Closed - Rejected\', \'Closed - Revoked\', \'Closed_Suspended\', \'Closed - Withdrawn\', \'Closed - Renewed\', \'Expired\', \'Renewed\' )' +  
            ' AND RecordType.Name IN (\'Car Wash\', \'Child Performer Services\', \'EntertaINment Work\', \'Farm Labor Contractor\', \'Garment Manufacturers AND Contractors\', \'Janitorial\', \'Permit to Employ MINors\', \'Talent Agency\')' +
            ' AND (Registration_Close_Date__c < LAST_N_MONTHS:6 OR Approval_Date_Time__c < LAST_N_MONTHS:6))' + 
            ' AND (Not ContentDocument.title LIKE \'!Archived!-%\')' +
            ' LIMIT 20000';  
        
        Id job = Database.executeBatch(new RegistrationArchiveBatch(q),20);	
    }
    
    public void archiveSubmissionDetailContentDocument(){
        //String version Query Content Document for Submission Detail
        String q = 'SELECT Id, LINkedEntityId, LINkedEntity.name, ContentDocumentId , ContentDocument.title FROM ContentDocumentLink' + 
            ' WHERE LINkedEntityId IN (SELECT Id FROM Attachments_Plus__c WHERE Registration__r.status__c IN (\'Approved\', \'Closed\', \'Closed - Denied\', \'Closed - Duplicate\', \'Closed - INactive\', \'Closed - Rejected\', \'Closed - Revoked\', \'Closed_Suspended\', \'Closed - Withdrawn\', \'Closed - Renewed\', \'Expired\', \'Renewed\' )' +  
            ' AND Registration__r.RecordType.Name IN (\'Car Wash\', \'Child Performer Services\', \'EntertaINment Work\', \'Farm Labor Contractor\', \'Garment Manufacturers AND Contractors\', \'Janitorial\', \'Permit to Employ MINors\', \'Talent Agency\') AND (Registration__r.Registration_Close_Date__c < LAST_N_MONTHS:6 OR Registration__r.Approval_Date_Time__c < LAST_N_MONTHS:6))' +
            ' AND (Not ContentDocument.title LIKE \'!Archived!-%\')' +
            ' LIMIT 20000';  
        Id job = Database.executeBatch(new RegistrationArchiveBatch(q),20);
		
    }
}