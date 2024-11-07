trigger BondTrigger on Bond__c (before insert, before update, after insert, after update, before delete, after delete) {
    
      if(Label.runRegistrationTrigger=='true'){
        BondAllHandler handler = BondAllHandler.getInstance();
        
        if (Trigger.isInsert) {
            if (Trigger.isBefore)
                handler.onBeforeInsert(Trigger.New) ;
            
            if (Trigger.isAfter) 
                handler.onAfterInsert(Trigger.New, Trigger.NewMap);
        }
        
        if (Trigger.isUpdate) {
            if (Trigger.isBefore)
                handler.onBeforeUpdate(Trigger.New, Trigger.NewMap, Trigger.oldMap);
            
            if (Trigger.isAfter)
                handler.onAfterUpdate(Trigger.New, Trigger.NewMap , Trigger.oldMap);
        }
        
        if (Trigger.isDelete) {
            if (Trigger.isBefore)
                handler.onBeforeDelete(Trigger.Old, Trigger.oldMap);
            
            if (Trigger.isAfter)
                handler.onAfterDelete(Trigger.Old, Trigger.oldMap );
        }
    } 
    
    // Get current user's profile name
    //Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
    //List<Bond__c> bond = [Select Id, Registration__c from Bond__c where Id in : Trigger.old];
    //if (!prof.Name.contains('System Administrator') || !prof.Name.contains('System Administrator LTD') ) {
 /*   
    for(Bond__c bond : trigger.old){
        system.debug('bond '+bond);
        
        if (bond.Registration_Status__c != 'Incomplete') {
            bond.addError('This Record can not be deleted');
        }
        else
        {
            List<Attachments_Plus__c> attplus = [SELECT Id FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =:bond.Id];
            // System.debug('attplus.size():' + attplus.size());
            if(attplus.size() > 0){
                delete attplus;
            }
        }
    }*/
    //}
}