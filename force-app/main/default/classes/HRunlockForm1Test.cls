@isTest
public class HRunlockForm1Test {
     @isTest static void unlockrecord1() {
           //Test data setup
          
          //Create a Position to assign to Form1
          Position__c p = new Position__c();
          p.Name = '400-152-1441-888';
          p.Serial_Number__c = '888';
          p.Manual_Entry__c = false;
          insert p;
          
          //Create a Form1 that is locked and unlock and edit it
          Form_1__c F1 = new Form_1__c(  SEC1_Position__c = p.Id, Position_Type__c= 'New Position', Required_Form_700__c='Required');
          insert F1;
          Approval.lock(F1.Id);
         
         List<Form_1__c> F1LockList = new List<Form_1__c>();
         F1LockList.add(F1);
         
         //Perform Test
         Test.startTest();  
         //Call the invocable method directly!!!!
         HRunlockForm1.unlockrecord(F1LockList);
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

         Test.stopTest();
     }
}