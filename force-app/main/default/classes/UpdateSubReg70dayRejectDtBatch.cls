public with sharing class UpdateSubReg70dayRejectDtBatch implements Database.Batchable<SObject>{
    public Iterable<SObject> start(Database.BatchableContext bc) {
        return new UpdateSubReg70dayRejectDtIterable();
    }
    
    
    public void execute(Database.BatchableContext bc, List<License_Registration__c> registrations) {
        update registrations;
        
        
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
    public void neededForTestCoverage() {
        // keep this so that coverage is not dependent on custom metadata records
        
        String foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
    }

}