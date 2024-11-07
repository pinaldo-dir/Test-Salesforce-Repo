public class RegistrationLocationAllHandler {
    
    private static registrationLocationAllHandler classInstance = null;
    public Boolean stopRecursion {get; set;}
    
    private registrationLocationAllHandler() {
        stopRecursion = FALSE;
    }
    
    public static RegistrationLocationAllHandler getInstance(){
        if (null == classInstance) {
            classInstance = new registrationLocationAllHandler();
        }
        return classInstance;
    }
    
    public void onBeforeInsert(List<Registration_Location__c> newList){ 
    }
    
    public void onAfterInsert(List<Registration_Location__c> newList , Map<id, Registration_Location__c> newMap){  
    }
    
    public void onBeforeUpdate(List<Registration_Location__c> newList, Map<id, Registration_Location__c> newMap, Map<id, Registration_Location__c> oldMap){
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            updateLoc(newList); 
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterUpdate(List<Registration_Location__c> newList, Map<id, Registration_Location__c> newMap, Map<id, Registration_Location__c> oldMap){  
    }
    
    public void onBeforeDelete(List<Registration_Location__c> oldList, Map<id, Registration_Location__c> oldMap){
        
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            deleteLoc(oldList);
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterDelete(list<Registration_Location__c> oldList, Map<id, Registration_Location__c> oldMap){   
    }
    
    private void updateLoc(List<Registration_Location__c> newList){
        Map<Id, Registration_Location__c> locNameOld=new Map<id, Registration_Location__c>([SELECT Id, DBA_Name__c,	Address__c
                      FROM Registration_Location__c WHERE Id IN: newList AND Registration__c =: newList[0].Registration__c]);
        
        if(!locNameOld.isEmpty()){
        for(Registration_Location__c locNameNew: newList){
         
            List<Attachments_Plus__c> attplus = [SELECT Id, Attachment_Name__c, Type__c,Reg_Related_Rec_Id__c, Instructions__c, Registration_Type__c FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =: locNameNew.Id];
             if (locNameNew.DBA_Name__c == Null)
                {
                   locNameNew.DBA_Name__c='';
                }
            if(attplus.size() > 0){
                for(Attachments_Plus__c eachAttPlus: attplus){
                        String attName = eachAttPlus.Attachment_Name__c;
                        String attType =  eachAttPlus.Type__c;
                        String attInstruction = eachAttPlus.Instructions__c;                    
                    if(eachAttPlus.Registration_Type__c == 'Car_Wash'){

                        eachAttPlus.Attachment_Name__c = attName.substringBefore('-')+' - '+locNameNew.DBA_Name__c;
                        eachAttPlus.Type__c = attType.substringBefore('-') +' - '+ locNameNew.DBA_Name__c;
                        eachAttPlus.Instructions__c = attInstruction.substringBefore('-') +' - '+ locNameNew.DBA_Name__c;
                        
                        System.debug('*************** eachAttPlus.Attachment_Name__c:' + eachAttPlus.Attachment_Name__c);
                    }
                    else {
                        //if(eachAttPlus.Registration_Type__c == 'Garment_Manufacturers_and_Contractors')
                        eachAttPlus.Attachment_Name__c = attName.substringBefore('-')+' - '+locNameNew.Address__c;
                        eachAttPlus.Type__c = attType.substringBefore('-') +' - '+ locNameNew.Address__c;
                        eachAttPlus.Instructions__c = attInstruction.substringBefore('-') +' - '+ locNameNew.Address__c;
                        System.debug('*******I am here if not Carwash');
                            }
                }
               
            }
            update attplus;
        }
       }
    }
    
    
    private void deleteLoc(List<Registration_Location__c> oldLocList){
                // Get current user's profile name
                // Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
                // List<Registration_Location__c> regloc = [Select Id, Registration__c from Registration_Location__c where Id in : Trigger.old];
                // Delete Submission Detail 1st
                // Delete Registration location 2nd
                // if (!prof.Name.contains('System Administrator')) {
                
                for(Registration_Location__c regloc : oldLocList){
                    // System.debug('regloc '+regloc);
                    
                    if (regloc.Registration_Status__c != 'Incomplete') {
                        regloc.addError('This Record can not be deleted');
                    }
                    else
                    {
                        List<Attachments_Plus__c> attplus = [SELECT Id FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =:regloc.Id AND Registration__c =: regloc.Registration__c];
                        // System.debug('attplus.size():' + attplus.size());
                        if(attplus.size() > 0){
                            delete attplus;
                        }
                    }
                } 
    }

}