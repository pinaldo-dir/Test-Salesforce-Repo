trigger RegistrationAccountTrigger on Registration_Account__c (before insert, before update, after insert, after update, before delete, after delete) {
    
    if(Label.runRegistrationTrigger=='true'){
        RegistrationAccountAllHandler handler = RegistrationAccountAllHandler.getInstance();
        
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
}