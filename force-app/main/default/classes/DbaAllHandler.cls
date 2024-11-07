public class DbaAllHandler {
    
/********************************************************************************************************
Name:  DbaAllHandler.cls

Trigger: DbaTrigger.trigger
Test class: LicenseRegistrationAllTest.cls

Behavior: 
updateDbaName() 
When the user updates the dba name, update the attachment, Attachments_Plus__c, as well.

deleteDBA()
When the user deletes the dba, the attachment, Attachments_Plus__c, should also be deleted.  

********************************************************************************************************/
    
    private static DbaAllHandler classInstance = null;
    public Boolean stopRecursion {get; set;}
    
    private dbaAllHandler() {
        stopRecursion = FALSE;
    }
    
    public static DbaAllHandler getInstance(){
        if (null == classInstance) {
            classInstance = new dbaAllHandler();
        }
        return classInstance;
    }
    
    public void onBeforeInsert(List<DBA__c> newList){ 
    }
    
    public void onAfterInsert(List<DBA__c> newList , Map<id, DBA__c> newMap){  
    }
    
    public void onBeforeUpdate(List<DBA__c> newList, Map<id, DBA__c> newMap, Map<id, DBA__c> oldMap){
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            updateDbaName(newList); 
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterUpdate(List<DBA__c> newList, Map<id, DBA__c> newMap, Map<id, DBA__c> oldMap){  
    }
    
    public void onBeforeDelete(List<DBA__c> oldList, Map<id, DBA__c> oldMap){
        
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            deleteDBA(oldList);
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterDelete(list<DBA__c> oldList, Map<id, DBA__c> oldMap){   
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    private void updateDbaName(List<DBA__c> newList){
        // Get current user's profile name
        //Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
        //List<DBA__c> dbarec = [Select Id, Registration__c from DBA__c where Id in : Trigger.old];
        //if (!prof.Name.contains('System Administrator') || !prof.Name.contains('System Administrator LTD') ) {
        
        
        for(DBA__c dbaUpdate: newList){
            DBA__c dbaName = [SELECT Name FROM DBA__c WHERE Id =: dbaUpdate.Id];
            List<Attachments_Plus__c> attplus = [SELECT Id, Attachment_Name__c, Type__c, Instructions__c FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =:dbaUpdate.Id];
            if(attplus.size() > 0){
                for(Attachments_Plus__c eachAttPlus: attplus){
                    eachAttPlus.Attachment_Name__c = eachAttPlus.Attachment_Name__c.replace(dbaName.Name,  dbaUpdate.Name);
                    eachAttPlus.Type__c = eachAttPlus.Type__c.replace(dbaName.Name,  dbaUpdate.Name);
                    eachAttPlus.Instructions__c = eachAttPlus.Instructions__c.replace(dbaName.Name,  dbaUpdate.Name);
                    //System.debug('*************** eachAttPlus.Attachment_Name__c:' + eachAttPlus.Attachment_Name__c);
                }
            }
            update attplus;
        }
    }
    
    private void deleteDBA(List<DBA__c> oldDbaList){
        for(DBA__c dbarec : oldDbaList){
            //System.debug('dbarec '+dbarec);
            //System.debug('Reg status '+dbarec.Registration_Status__c );
            
            if (dbarec.Registration_Status__c != null){  
                if (dbarec.Registration_Status__c != 'Incomplete') {
                    dbarec.addError('This Record can not be deleted because it is associated with a Registration that is not Incomplete');
                }
            }
            else
            {
                List<Attachments_Plus__c> attplus = [SELECT Id FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =:dbarec.Id];
                // System.debug('attplus.size():' + attplus.size());
                if(attplus.size() > 0){
                    delete attplus;
                }
            }
        }
    }
}