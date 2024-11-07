public with sharing class TransmittalBatchController {
    /* Triggered by the Run Transmittal Batch link on the Lightning Utility Bar */
    
    /* public boolean userHasPermissions {get;set;} */
    public boolean isRunning {get;set;}
    public List<Case_Payment__c> cpList {get;set;}
    
    public TransmittalBatchController(){
        isRunning = false;

        cpList = [SELECT Id, Transmittal__c, Transmittal_Unit__c, Status__c, Case__c, Case__r.Id, Receipt__c, Receipt__r.Bank_Deposit_Date__c
                    FROM Case_Payment__c
                    WHERE RecordType.Name = 'Posted'
                        AND Status__c = 'Posted'
                        AND Transmittal__c = null
                        AND Receipt__r.Bank_Deposit_Date__c != null
                        AND (Transmittal_Unit__c = 'CCU 32'
                            OR Transmittal_Unit__c = 'JEU'
                            OR Transmittal_Unit__c = 'RCI')
                        AND (Case__r.RecordType.Name LIKE '%BOFE%'
                            OR Case__r.RecordType.Name LIKE '%PASS%'
                            OR Case__r.RecordType.Name LIKE '%RCI%'
                            OR Case__r.RecordType.Name LIKE '%JEU%')];

    }

    public void runTransmittalBatch(){
        isRunning = true;

        String cpIds = '(\'';
        for(Case_Payment__c cp : cpList){
            cpIds += (cp.Id + '\', \'');
        }

        cpIds = cpIds.substring(0, cpIds.length() - 3);
        cpIds += ')'; 

        Transmittal__c transmittal = new Transmittal__c(
            RecordTypeId = Schema.SObjectType.Transmittal__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert transmittal;

        Id tb = Database.executeBatch(new TransmittalBatch(cpIds, transmittal.Id), 25);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The Transmittal Batch job is now queued to run. You will receive an email once the batch process is complete. Please minimize or close this window.'));
    }
}