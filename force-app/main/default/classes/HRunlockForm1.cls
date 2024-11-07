// this class is triggered by Process Builder - HR Unlock Form 1
public without sharing class HRunlockForm1 {
    @InvocableMethod
Static Public void unlockrecord(List<Form_1__c> F1List) {   
//Get records to unlock
//F1List =  [SELECT Id From Form_1__c LIMIT 10];
//Check locked records
List<Form_1__c> F1LockList = new List<Form_1__c>();
    
    for(Form_1__c F1 :F1List)
{
    if(Approval.isLocked(F1.id)){
        F1LockList.add(F1);
    }
}
//Unlock record
if(!F1LockList.isEmpty()){
    //Unlock records
    List<Approval.UnlockResult> ulrList = Approval.unlock(F1LockList, false);
     
    // Iterate through each returned result
    for(Approval.UnlockResult  ulr : ulrList) {
        if (ulr.isSuccess()) {
            //Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully locked account with ID: ' + ulr.getId());
        }
        else {
            //Operation failed, so get all errors                
            for(Database.Error err : ulr.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Case fields that affected this error: ' + err.getFields());
                
            }
        }
            }
        }
    }

}