public with sharing class PurgeIterable implements Iterable<SObject> {
    public Iterator<SObject> iterator() {
        List<SObject> sobjects = new List<SObject>();
        Map<String, List<String>> recordTypesByObject = new Map<String, List<String>>();
        Map<String, List<String>> statusesByObject = new Map<String, List<String>>();
        String paymentStatus = '';
        Map<String, Decimal> daysByObject = new Map<String, Decimal>();

        for (Purge_Settings__mdt setting : [
                SELECT Object__r.QualifiedApiName,
                        Record_Type__c,
                        Status__c,
            			Status_of_Payment__c,
                        Age_of_Records_to_Purge__c
                FROM Purge_Settings__mdt
        ]) {
            String objectApiName = setting.Object__r.QualifiedApiName;
            recordTypesByObject.put(objectApiName, setting.Record_Type__c.replaceAll( '\\s+', '').split(','));
            statusesByObject.put(objectApiName, setting.Status__c.split(','));
            paymentStatus = setting.Status_of_Payment__c;
            daysByObject.put(objectApiName, Integer.valueOf(Math.round(setting.Age_of_Records_to_Purge__c)));
            List<SObject> records;
            List<String> recordTypes = recordTypesByObject.get(objectApiName);
            List<String> statuses = statusesByObject.get(objectApiName);
            String query;

            query = 'SELECT Id FROM ' + objectApiName + ' ';
            query += 'WHERE RecordType.DeveloperName IN :recordTypes' + ' ';
            query += 'AND Status__c IN :statuses' + ' ';
            IF(paymentStatus == 'Paid / No Balance Due')
            {
                query += 'AND Status_of_Payment__c = \'Paid / No Balance Due\'' +  ' ';
            }
            IF(paymentStatus == '' || paymentStatus == 'Not Paid') 
            {
                query += 'AND (Status_of_Payment__c = \'\' OR Status_of_Payment__c = \'Not Paid\')' + ' ';
                
            }
            query += 'AND LastModifiedDate < LAST_N_DAYS:' + daysByObject.get(objectApiName);

            records = Database.query(query);
            sobjects.addAll(records);
        }

        return sobjects.iterator();
    }
}