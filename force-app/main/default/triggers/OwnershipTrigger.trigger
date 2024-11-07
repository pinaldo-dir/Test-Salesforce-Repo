trigger OwnershipTrigger on Ownership__c (before insert, before update, after insert, after update, before delete, after delete){
      
    if(Label.runRegistrationTrigger=='true'){
        OwnershipAllHandler handler = OwnershipAllHandler.getInstance();
        
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
    
 }
  
    
    
 /*   
    for(Ownership__c owc : trigger.old){
        // System.debug('OWC '+owc);
        
        if (owc.Registration_Status__c != 'Incomplete') {
            owc.addError('This Record can not be deleted');
        }
        else
        {
            List<Attachments_Plus__c> attplus = [SELECT Id FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =:owc.Id];
            // System.debug('attplus.size():' + attplus.size());
            if(attplus.size() > 0){
                delete attplus;
            }
        }
    }
//    } 
}*/