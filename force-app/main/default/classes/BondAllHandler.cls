public class BondAllHandler {
    
    /********************************************************************************************************
Name:  BondAllHandler.cls

Trigger: BondTrigger.trigger
Test class: LicenseRegistrationAllTest.cls

Behavior: 
updateDbaName() 
When the user updates the dba name, update the attachment, Attachments_Plus__c, as well.

deleteBond()
When the user deletes the dba, the attachment, Attachments_Plus__c, should also be deleted.  

********************************************************************************************************/
    
    private static BondAllHandler classInstance = null;
    public Boolean stopRecursion {get; set;}
    
    private bondAllHandler() {
        stopRecursion = FALSE;
    }
    
    public static BondAllHandler getInstance(){
        if (null == classInstance) {
            classInstance = new bondAllHandler();
        }
        return classInstance;
    }
    
    public void onBeforeInsert(List<Bond__c> newList){ 
    }
    
    public void onAfterInsert(List<Bond__c> newList , Map<id, Bond__c> newMap){  
    }
    
    public void onBeforeUpdate(List<Bond__c> newList, Map<id, Bond__c> newMap, Map<id, Bond__c> oldMap){
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            updateBondName(newList); 
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterUpdate(List<Bond__c> newList, Map<id, Bond__c> newMap, Map<id, Bond__c> oldMap){  
    }
    
    public void onBeforeDelete(List<Bond__c> oldList, Map<id, Bond__c> oldMap){
        
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            deleteBond(oldList);
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterDelete(list<Bond__c> oldList, Map<id, Bond__c> oldMap){   
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    private void updateBondName(List<Bond__c> newList){
        // Get current user's profile name
        //Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
        //List<DBA__c> dbarec = [Select Id, Registration__c from DBA__c where Id in : Trigger.old];
        //if (!prof.Name.contains('System Administrator') || !prof.Name.contains('System Administrator LTD') ) {
        
        
        for(Bond__c bondUpdate: newList){
            Bond__c bondName = [SELECT Name FROM Bond__c WHERE Id =: bondUpdate.Id];
            List<Attachments_Plus__c> attplus = [SELECT Id, Attachment_Name__c, Type__c, Instructions__c FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =:bondUpdate.Id];
            if(attplus.size() > 0){
                for(Attachments_Plus__c eachAttPlus: attplus){
                    eachAttPlus.Attachment_Name__c = eachAttPlus.Attachment_Name__c.replace(bondName.Name,  bondUpdate.Name);
                    eachAttPlus.Type__c = eachAttPlus.Type__c.replace(bondName.Name,  bondUpdate.Name);
                    eachAttPlus.Instructions__c = eachAttPlus.Instructions__c.replace(bondName.Name,  bondUpdate.Name);
                    //System.debug('*************** eachAttPlus.Attachment_Name__c:' + eachAttPlus.Attachment_Name__c);
                }
            }
            update attplus;
        }
    }
    
    private void deleteBond(List<Bond__c> oldBondList){
        for(Bond__c bondrec : oldBondList){
            //System.debug('dbarec '+dbarec);
            
            if (bondrec.Registration_Status__c != 'Incomplete') {
                bondrec.addError('This Record can not be deleted');
            }
            else
            {
                List<Attachments_Plus__c> attplus = [SELECT Id FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =:bondrec.Id];
                // System.debug('attplus.size():' + attplus.size());
                if(attplus.size() > 0){
                    delete attplus;
                }
            }
        }
    }

}