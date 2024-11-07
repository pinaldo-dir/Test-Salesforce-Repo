trigger RegistrationLocationTrigger on Registration_Location__c (before insert, before update, after insert, after update, before delete, after delete) {
 
     if(Label.runRegistrationTrigger=='true'){
       RegistrationLocationAllHandler handler = RegistrationLocationAllHandler.getInstance();
        
        if (Trigger.isInsert) {
            if (Trigger.isBefore){
                handler.onBeforeInsert(Trigger.New) ;
            }
            if (Trigger.isAfter) {
                handler.onAfterInsert(Trigger.New, Trigger.NewMap);
            }
        }
        
        if (Trigger.isUpdate) {
            if (Trigger.isBefore){
                handler.onBeforeUpdate(Trigger.New, Trigger.NewMap, Trigger.OldMap);
            }
            if (Trigger.isAfter){
                handler.onAfterUpdate(Trigger.New, Trigger.NewMap , Trigger.OldMap);
            }
        }
        
        if (Trigger.isDelete) {
            if (Trigger.isBefore){
                handler.onBeforeDelete(Trigger.Old, Trigger.OldMap);
                    }
            if (Trigger.isAfter){
                handler.onAfterDelete(Trigger.Old, Trigger.OldMap );
            }
        }
    }
    
    
    /*   
    // Get current user's profile name
    // Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
    // List<Registration_Location__c> rloc = [Select Id,  Registration__c from Registration_Location__c where Id in : Trigger.old];
    // if (!prof.Name.contains('System Administrator') || !prof.Name.contains('System Administrator LTD') ) {
        // String rlocstatus = [select Status__c from License_Registration__c where ]
        for(Registration_Location__c rloc : trigger.old){
            // System.debug('RLOC**'+rloc);
            
            if (rloc.Registration_Status__c != 'Incomplete') {
                rloc.addError('This Record can not be deleted');
            }
            else
            {
                List<Attachments_Plus__c> attplus = [SELECT Id FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =:rloc.Id];
                // System.debug('attplus.size():' + attplus.size());
                if(attplus.size() > 0){
                    delete attplus;
                }
            }
        }
    // } */
}