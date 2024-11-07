public class OwnershipAllHandler {
    
    private static ownershipAllHandler classInstance = null;
    public Boolean stopRecursion {get; set;}
    
    private ownershipAllHandler() {
        stopRecursion = FALSE;
    }
    
    public static ownershipAllHandler getInstance(){
        if (null == classInstance) {
            classInstance = new ownershipAllHandler();
        }
        return classInstance;
    }
    
    public void onBeforeInsert(List<Ownership__c> newList){ 
    }
    
    public void onAfterInsert(List<Ownership__c> newList , Map<id, Ownership__c> newMap){  
    }
    
    public void onBeforeUpdate(List<Ownership__c> newList, Map<id, Ownership__c> newMap, Map<id, Ownership__c> oldMap){
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            updateOwners(newList); 
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterUpdate(List<Ownership__c> newList, Map<id, Ownership__c> newMap, Map<id, Ownership__c> oldMap){  
    }
    
    public void onBeforeDelete(List<Ownership__c> oldList, Map<id, Ownership__c> oldMap){
        
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            deleteOwners(oldList);
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterDelete(list<Ownership__c> oldList, Map<id, Ownership__c> oldMap){   
    }
    
    /// String s2 = s1.replace(target, replacement);
    //////////////////////////////////////////////////////////////////////////////////////
/*    private void updateOwners(List<Ownership__c> newList){
        
        Map<Id, Ownership__c> ownersNameOld = new Map<id, Ownership__c>([SELECT Id, Name, Registration__c, First_Name__c, Last_Name__c FROM Ownership__c WHERE Id IN: newList AND Registration__c =: newList[0].Registration__c]);
        
        if(!ownersNameOld.isEmpty()){
            for(Ownership__c ownersNameNew: newList){
                List<Attachments_Plus__c> attplus = [SELECT Id, Attachment_Name__c, Type__c, Instructions__c, Reg_Related_Rec_Id__c FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =: ownersNameNew.Id AND Registration__c =: ownersNameNew.Registration__c];
                // *********this to aviod Nulls for Attachments when there is no name
                if (ownersNameNew.First_Name__c == null && ownersNameNew.Last_Name__c == null)
                {
                    ownersNameNew.First_Name__c='';
                    ownersNameNew.Last_Name__c='';
                }    
                Else 
                    if (ownersNameNew.First_Name__c == Null)
                {
                    ownersNameNew.First_Name__c='';
                }
                
                Else
                    if (ownersNameNew.Last_Name__c == Null)
                {
                    ownersNameNew.Last_Name__c='';
                }
                    
                
                if(attplus.size() > 0){
                    for(Attachments_Plus__c eachAttPlus: attplus){
                        String attName = eachAttPlus.Attachment_Name__c;
                        String attType =  eachAttPlus.Type__c;
                        String attInstruction = eachAttPlus.Instructions__c;  

                        eachAttPlus.Attachment_Name__c = attName.substringBefore('-')+' - '+ownersNameNew.First_Name__c+' '+ownersNameNew.Last_Name__c;
                        eachAttPlus.Type__c = attType.substringBefore('-')+' - '+ownersNameNew.First_Name__c+' '+ownersNameNew.Last_Name__c;
                        eachAttPlus.Instructions__c = attInstruction.substringBefore('-')+' - '+ownersNameNew.First_Name__c+' '+ownersNameNew.Last_Name__c;

                        //System.debug('*************** eachAttPlus.Attachment_Name__c:' + eachAttPlus.Attachment_Name__c);
                    }
                }
                update attplus;
            }
        }
    } */
    
    private void updateOwners(List<Ownership__c> newList){
        
        Map<Id, Ownership__c> ownersNameOld = new Map<id, Ownership__c>([SELECT Id, Name, Registration__c, First_Name__c, Last_Name__c, Request_FLC_Card__c FROM Ownership__c WHERE Id IN: newList AND Registration__c =: newList[0].Registration__c]);
        
        if(!ownersNameOld.isEmpty()){
            for(Ownership__c ownersNameNew: newList){
                List<Attachments_Plus__c> attplus = [SELECT Id, Attachment_Name__c, Type__c, Instructions__c, Reg_Related_Rec_Id__c, Attachment_Required__c, VIP_Form_Section_Name_Display__c FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =: ownersNameNew.Id AND Registration__c =: ownersNameNew.Registration__c];
                // *********this to aviod Nulls for Attachments when there is no name
                if (ownersNameNew.First_Name__c == null && ownersNameNew.Last_Name__c == null)
                {
                    ownersNameNew.First_Name__c='';
                    ownersNameNew.Last_Name__c='';
                }    
                Else 
                    if (ownersNameNew.First_Name__c == Null)
                {
                    ownersNameNew.First_Name__c='';
                }
                
                Else
                    if (ownersNameNew.Last_Name__c == Null)
                {
                    ownersNameNew.Last_Name__c='';
                }
                    
                
                if(attplus.size() > 0){
                    for(Attachments_Plus__c eachAttPlus: attplus){
                        String attName = eachAttPlus.Attachment_Name__c;
                        String attType =  eachAttPlus.Type__c;
                        String attInstruction = eachAttPlus.Instructions__c;  

                        eachAttPlus.Attachment_Name__c = attName.substringBefore('-')+' - '+ownersNameNew.First_Name__c+' '+ownersNameNew.Last_Name__c;
                        eachAttPlus.Type__c = attType.substringBefore('-')+' - '+ownersNameNew.First_Name__c+' '+ownersNameNew.Last_Name__c;
                        eachAttPlus.Instructions__c = attInstruction.substringBefore('-')+' - '+ownersNameNew.First_Name__c+' '+ownersNameNew.Last_Name__c;
                        
                        System.debug('BEFORE if');
                        //if(eachAttPlus.VIP_Form_Section_Name_Display__c == 'Photo Documents - FLC'){ 
                        if(attName.contains('Owners Photo')){
                            System.debug('AFTER if');
                            if(ownersNameNew.Request_FLC_Card__c == True){
                                System.debug('Set True');
                                eachAttPlus.Attachment_Required__c = True;
                            }else{
                                eachAttPlus.Attachment_Required__c = False;
                            }
                             
                        }

                        //System.debug('*************** eachAttPlus.Attachment_Name__c:' + eachAttPlus.Attachment_Name__c);
                    }
                }
                update attplus;
            }
        }
    }    
    
    private void deleteOwners(List<Ownership__c> oldOwnersList){
        // Get current user's profile name
        // Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
        // List<Registration_Account__c> regacc = [Select Id, Registration__c from Registration_Account__c where Id in : Trigger.old];
        // Delete Submission Detail 1st
        // Delete Registration Acconunts 2nd
        // if (!prof.Name.contains('System Administrator')) {
        
        for(Ownership__c ow : oldOwnersList){
            // System.debug('regacc '+regacc);
            
            if (ow.Registration_Status__c != 'Incomplete') {
                ow.addError('This Record can not be deleted');
            }
            else
            {
                List<Attachments_Plus__c> attplus = [SELECT Id FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =: ow.Id AND Registration__c =: ow.Registration__c];
                // System.debug('attplus.size():' + attplus.size());
                if(attplus.size() > 0){
                    delete attplus;
                }
            }
        } 
    }
    
}