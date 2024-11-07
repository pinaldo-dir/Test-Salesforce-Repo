/* Stolen and adapted from: https://github.com/pozil/sfdc-ui-lookup-lwc/blob/master/src-sample/main/default/classes/SampleLookupController.cls
    Depends on LookupSearchResult class */
/* Used by the CashPartyToPartyPayment LWC only; NOT the ICL aura component, which uses the inputLookupField aura component instead. */
public with sharing class CashCustomLookupController {
    private final static Integer MAX_RESULTS = 10;

    //TODO: need to break this out into "searchCases" and "searchPayees" so we can use this lookup instead of the other lookup
    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> searchCases(String searchTerm, List<String> selectedIds) {
        System.debug('8 searchTerm: ' + searchTerm);
        System.debug('9 selectedIds: ' + selectedIds);
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                DIR_Case__c(Id, Name, Case_Number__c, Assigned_Deputy__r.Name, Employer__r.Name, Record_Type_Name__c WHERE Id NOT IN :selectedIds)
                // Account(Id, Name, BillingCity WHERE id NOT IN :selectedIds),
                // Opportunity(Id, Name, StageName WHERE id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String caseManagementIcon = 'custom:custom19';
        DIR_Case__c[] cases = (List<DIR_Case__c>) searchResults[0];
        for(DIR_Case__c cm : cases){
            String subtitle = cm.Case_Number__c == null ? 'Case Management' : cm.Case_Number__c + ' • ' + cm.Assigned_Deputy__r.Name + '<br/>' + cm.Employer__r.Name + ' • ' + cm.Record_Type_Name__c;
            
            results.add(new LookupSearchResult(cm.Id, cm.Name, cm.Record_Type_Name__c, 'DIR_Case__c',
                caseManagementIcon, cm.Name, subtitle,
                cm.Case_Number__c, cm.Employer__r.Name, null, null));
        }
        /* String accountIcon = 'standard:account';
        Account[] accounts = (List<Account>) searchResults[0];
        for (Account account : accounts) {
            String subtitle = account.BillingCity == null ? 'Account' : 'Account • ' + account.BillingCity;
            results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, subtitle));
        } */

        // Extract Opportunities & convert them into LookupSearchResult
        /* String opptyIcon = 'standard:opportunity';
        Opportunity[] opptys = (List<Opportunity>) searchResults[1];
        for (Opportunity oppty : opptys) {
            results.add(
                new LookupSearchResult(
                    oppty.Id,
                    'Opportunity',
                    opptyIcon,
                    oppty.Name,
                    'Opportunity • ' + oppty.StageName
                )
            );
        } */

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }


    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> searchAccounts(String searchTerm, List<String> selectedIds) {
        System.debug('65 searchTerm: ' + searchTerm);
        System.debug('66 selectedIds: ' + selectedIds);
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Account(Id, Name, ShippingStreet, Entity_Type__c, Record_Type_Name__c WHERE id NOT IN :selectedIds)
                // Opportunity(Id, Name, StageName WHERE id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        /* String caseManagementIcon = 'action:approval';
        DIR_Case__c[] cases = (List<DIR_Case__c>) searchResults[0];
        for(DIR_Case__c cm : cases){
            String subtitle = cm.Case_Number__c == null ? 'Case Management' : cm.Case_Number__c + ' • ' + cm.Assigned_Deputy__r.Name + '<br/>' + cm.Employer__r.Name + ' • ' + cm.Record_Type_Name__c;
            results.add(new LookupSearchResult(cm.Id, cm.Name, cm.Case_Number__c, cm.Record_Type_Name__c, cm.Employer__r.Name, 'DIR_Case__c', caseManagementIcon, cm.Name, subtitle));
        } */
        String accountIcon = 'standard:account';
        Account[] accounts = (List<Account>) searchResults[0];
        for (Account account : accounts) {
            String subtitle = (account.Entity_Type__c == null ? '' : account.Entity_Type__c + ' • ') + account.Record_Type_Name__c + '<br />' + account.ShippingStreet;
            
            results.add(new LookupSearchResult(account.Id, account.Name, account.Record_Type_Name__c, 'Account',
            accountIcon, account.Name, subtitle,
            null, null, account.ShippingStreet, account.Entity_Type__c));
        }

        // Extract Opportunities & convert them into LookupSearchResult
        /* String opptyIcon = 'standard:opportunity';
        Opportunity[] opptys = (List<Opportunity>) searchResults[1];
        for (Opportunity oppty : opptys) {
            results.add(
                new LookupSearchResult(
                    oppty.Id,
                    'Opportunity',
                    opptyIcon,
                    oppty.Name,
                    'Opportunity • ' + oppty.StageName
                )
            );
        } */

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> getRecentlyViewedCases() {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        /* List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type = 'Account' OR Type = 'Opportunity'
            ORDER BY LastViewedDate DESC
            LIMIT 5
        ]; */
        List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type = 'DIR_Case__c'
            ORDER BY LastViewedDate DESC
            LIMIT 10
        ];

        List<Id> recentlyViewedCaseIds = new List<Id>();
        for(RecentlyViewed recentRecord : recentRecords){
            recentlyViewedCaseIds.add(recentRecord.Id);
        }

        List<DIR_Case__c> recentCases = [
            SELECT Id, Name, LastViewedDate, Case_Number__c, Assigned_Deputy__r.Name, Employer__r.Name, Record_Type_Name__c
                FROM DIR_Case__c
                WHERE Id IN :recentlyViewedCaseIds
                ORDER BY LastViewedDate DESC
        ];

        // Convert recent records into LookupSearchResult
        for(Dir_Case__c cm : recentCases){
            results.add(new LookupSearchResult(cm.Id, cm.Name, cm.Record_Type_Name__c, 'DIR_Case__c',
                'custom:custom19', cm.Name, cm.Case_Number__c + ' • ' + cm.Assigned_Deputy__r.Name + ' • ' + cm.Employer__r.Name + ' • ' + cm.Record_Type_Name__c,
                cm.Case_Number__c, cm.Employer__r.Name, null, null)
            );
        }
        /* for(RecentlyViewed recentRecord : recentRecords) {
            results.add(
                new LookupSearchResult(
                    recentRecord.Id,
                    'DIR_Case__c',
                    'action:approval',
                    recentRecord.Name,
                    recentRecord.Case_Number__c + ' • ' + recentRecord.Assigned_Deputy__r.Name + ' • ' + recentRecord.Employer__r.Name + ' • ' + recentRecord.Record_Type_Name__c
                )
            );
            if (recentRecord.Type == 'Account') {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'Account',
                        'standard:account',
                        recentRecord.Name,
                        'Account • ' + recentRecord.Name
                    )
                );
            } else {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'Opportunity',
                        'standard:opportunity',
                        recentRecord.Name,
                        'Opportunity • ' + recentRecord.Name
                    )
                );
            }
        } */
        return results;
    }


    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> getRecentlyViewedAccounts() {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        /* List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type = 'Account' OR Type = 'Opportunity'
            ORDER BY LastViewedDate DESC
            LIMIT 5
        ]; */
        List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type = 'Account'
            ORDER BY LastViewedDate DESC
            LIMIT 10
        ];

        List<Id> recentlyViewedAccountIds = new List<Id>();
        for(RecentlyViewed recentRecord : recentRecords){
            recentlyViewedAccountIds.add(recentRecord.Id);
        }

        List<Account> recentAccounts = [
            SELECT Id, Name, LastViewedDate, ShippingStreet, Entity_Type__c, Record_Type_Name__c
                FROM Account
                WHERE Id IN :recentlyViewedAccountIds
                ORDER BY LastViewedDate DESC
        ];

        // Convert recent records into LookupSearchResult
        for(Account account : recentAccounts){
            results.add(new LookupSearchResult(account.Id, account.Name, account.Record_Type_Name__c, 'Account',
                'standard:account', account.Name, (account.Entity_Type__c == null ? '' : account.Entity_Type__c + ' • ') + account.Record_Type_Name__c + '<br />' + account.ShippingStreet,
                null, null, account.ShippingStreet, account.Entity_Type__c)
            );
        }
        /* for(RecentlyViewed recentRecord : recentRecords) {
            results.add(
                new LookupSearchResult(
                    recentRecord.Id,
                    'DIR_Case__c',
                    'action:approval',
                    recentRecord.Name,
                    recentRecord.Case_Number__c + ' • ' + recentRecord.Assigned_Deputy__r.Name + ' • ' + recentRecord.Employer__r.Name + ' • ' + recentRecord.Record_Type_Name__c
                )
            );
            if (recentRecord.Type == 'Account') {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'Account',
                        'standard:account',
                        recentRecord.Name,
                        'Account • ' + recentRecord.Name
                    )
                );
            } else {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'Opportunity',
                        'standard:opportunity',
                        recentRecord.Name,
                        'Opportunity • ' + recentRecord.Name
                    )
                );
            }
        } */
        return results;
    }
}