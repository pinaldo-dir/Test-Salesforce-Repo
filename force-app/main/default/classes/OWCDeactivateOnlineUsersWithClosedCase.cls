/*
* Class Name: OWCDeactivateOnlineUsersWithClosedCase
*Description: automated process for deactivating the community accounts that are 90 days since the 
close of case and If the community user has multiple cases, then the deactivation should occur 90 days 
after the last case closes. * 
* 
*/
global class OWCDeactivateOnlineUsersWithClosedCase implements Database.Batchable<sObject> {
    public static Date dateBefore90Days = System.today().addDays(-90); 
    global Database.QueryLocator start(Database.BatchableContext bc){
        dateBefore90Days = (!Test.isRunningTest()) ? dateBefore90Days : System.today().addDays(1);
        String query = 'SELECT Id, Name, AccountId, ContactId, ProfileId, IsActive FROM User WHERE AccountId != null';
        query += ' AND Profile.Name = \'Customer Online Claim User\'';
        query += ' AND IsActive = true';
        query += ' AND CreatedDate <: dateBefore90Days';
        query += (!Test.isRunningTest()) ? '': ' LIMIT 1';
        System.debug('query ::: '+query);
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext bc, List<User> scope){
        System.debug('scope ::: '+scope);
        List<User> deactivateUsers = new List<User>();
        Set<Id> deactivateUserIds = new Set<Id>();
        Set<Id> userWithActiveCase = new Set<Id>();
        Set<Id> deactivateAccountIds = new Set<Id>();
        for(User userObj : scope){
            deactivateAccountIds.add(userObj.accountId);
        }
        
        for(DIR_Case__c caseObj : [SELECT Id, Name, Online_Claim_Account__c, Status__c, Case_Closed_Date__c, CreatedDate
                                   FROM DIR_Case__c 
                                   WHERE Online_Claim_Account__c IN: deactivateAccountIds
                                   AND (Status__c != 'Closed' OR Case_Closed_Date__c >: dateBefore90Days )])
        {	
            if(deactivateAccountIds.contains(caseObj.Online_Claim_Account__c)){
                deactivateAccountIds.remove(caseObj.Online_Claim_Account__c);
            }
        }
        
        System.debug('deactivateUserIds ::: '+deactivateUserIds);
        //Check the list size of deactivated user
        if(deactivateAccountIds != null && deactivateAccountIds.size() > 0){
            for(User userObj : [SELECT Id, Name, IsActive, accountId, IsPortalEnabled FROM User 
                                WHERE accountId IN: deactivateAccountIds])
            {
                userObj.IsActive = false;
                userObj.IsPortalEnabled = false;
                deactivateUsers.add(userObj);
            }
        }
        
        if(deactivateUsers.size() > 0){
            update deactivateUsers;
        }
    }
    
    global void finish(Database.BatchableContext bc){
    }
}