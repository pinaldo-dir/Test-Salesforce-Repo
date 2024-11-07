public class RegistrationAccountAllHandler {
    private static registrationAccountAllHandler classInstance = null;
    public Boolean stopRecursion {get; set;}
    
    private registrationAccountAllHandler() {
        stopRecursion = FALSE;
    }
    
    public static RegistrationAccountAllHandler getInstance(){
        if (null == classInstance) {
            classInstance = new registrationAccountAllHandler();
        }
        return classInstance;
    }
    
    public void onBeforeInsert(List<Registration_Account__c> newList){ 
    }
    
    public void onAfterInsert(List<Registration_Account__c> newList , Map<id, Registration_Account__c> newMap){  
    }
    
    public void onBeforeUpdate(List<Registration_Account__c> newList, Map<id, Registration_Account__c> newMap, Map<id, Registration_Account__c> oldMap){
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            updateRA(newList); 
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterUpdate(List<Registration_Account__c> newList, Map<id, Registration_Account__c> newMap, Map<id, Registration_Account__c> oldMap){  
    }
    
    public void onBeforeDelete(List<Registration_Account__c> oldList, Map<id, Registration_Account__c> oldMap){
        
        if(stopRecursion == null || !stopRecursion)
        {
            stopRecursion = TRUE;
            deleteRA(oldList);
            stopRecursion = FALSE;
        }
    }
    
    public void onAfterDelete(list<Registration_Account__c> oldList, Map<id, Registration_Account__c> oldMap){   
    }
    
    /// String s2 = s1.replace(target, replacement);
    //////////////////////////////////////////////////////////////////////////////////////  Old one
/*    private void updateRA(List<Registration_Account__c> newList){
        
        Map<Id, Registration_Account__c> raNameOld=new Map<id, Registration_Account__c>([SELECT Id, Name, Registration__c, First_Name__c, Last_Name__c FROM Registration_Account__c WHERE Id IN: newList AND Registration__c =: newList[0].Registration__c]);
        if(!raNameOld.isEmpty()){
            for(Registration_Account__c raNameNew: newList){
                List<Attachments_Plus__c> attplus = [SELECT Id, Attachment_Name__c, Type__c, Instructions__c, Reg_Related_Rec_Id__c FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =: raNameOld.keySet() AND Registration__c =: raNameNew.Registration__c ];        
                if (raNameNew.First_Name__c == null && raNameNew.Last_Name__c == null)
                {
                    raNameNew.First_Name__c='';
                    raNameNew.Last_Name__c='';
                }    
                Else
                    if (raNameNew.First_Name__c == Null)
                {
                    raNameNew.First_Name__c='';
                }
                Else{
                    if (raNameNew.Last_Name__c == Null)
                    {
                        raNameNew.Last_Name__c='';
                    }
                }
                if(attplus.size() > 0){
                    for(Attachments_Plus__c eachAttPlus: attplus){
                        String attName = eachAttPlus.Attachment_Name__c;
                        String attType =  eachAttPlus.Type__c;
                        String attInstruction = eachAttPlus.Instructions__c;  
                        //eachAttPlus.Attachment_Name__c = 
                        //eachAttPlus.Attachment_Name__c.replace(raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).First_Name__c + ' ' + raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).Last_Name__c, raNameNew.First_Name__c + ' ' + raNameNew.Last_Name__c );
                        eachAttPlus.Attachment_Name__c = attName.substringBefore('-')+' - '+raNameNew.First_Name__c+' '+raNameNew.Last_Name__c;
                        eachAttPlus.Type__c = attType.substringBefore('-')+' - '+raNameNew.First_Name__c+' '+raNameNew.Last_Name__c;
                        eachAttPlus.Instructions__c = attInstruction.substringBefore('-')+' - '+raNameNew.First_Name__c+' '+raNameNew.Last_Name__c;

                        //eachAttPlus.Type__c = eachAttPlus.Type__c.replace(raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).First_Name__c + ' ' + raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).Last_Name__c, raNameNew.First_Name__c + ' ' + raNameNew.Last_Name__c );
                        //eachAttPlus.Instructions__c = eachAttPlus.Instructions__c.replace(raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).First_Name__c + ' ' + raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).Last_Name__c, raNameNew.First_Name__c + ' ' + raNameNew.Last_Name__c );
                        System.debug('*************** eachAttPlus.Attachment_Name__c:' + eachAttPlus.Attachment_Name__c);
                    }
                }
                update attplus;
            }
        }
    } */

    private void updateRA(List<Registration_Account__c> newList){
        
        Map<Id, Registration_Account__c> raNameOld=new Map<id, Registration_Account__c>([SELECT Id, Name, Registration__c, First_Name__c, Last_Name__c FROM Registration_Account__c WHERE Id IN: newList AND Registration__c =: newList[0].Registration__c]);
        if(!raNameOld.isEmpty()){
            for(Registration_Account__c raNameNew: newList){
                List<Attachments_Plus__c> attplus = [SELECT Id, Attachment_Name__c, Type__c, Instructions__c, Reg_Related_Rec_Id__c FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =: raNameOld.keySet() AND Registration__c =: raNameNew.Registration__c ];        
/*                if (raNameNew.First_Name__c == null && raNameNew.Last_Name__c == null)
                {
                    raNameNew.First_Name__c='';
                    raNameNew.Last_Name__c='';
                }    
                Else
                    if (raNameNew.First_Name__c == Null)
                {
                    raNameNew.First_Name__c='';
                }
                Else{
                    if (raNameNew.Last_Name__c == Null)
                    {
                        raNameNew.Last_Name__c='';
                    }
                } */
                if(attplus.size() > 0){
                    for(Attachments_Plus__c eachAttPlus: attplus){
                        String attName = eachAttPlus.Attachment_Name__c;
                        String attType =  eachAttPlus.Type__c;
                        String attInstruction = eachAttPlus.Instructions__c;  
                        //eachAttPlus.Attachment_Name__c = 
                        //eachAttPlus.Attachment_Name__c.replace(raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).First_Name__c + ' ' + raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).Last_Name__c, raNameNew.First_Name__c + ' ' + raNameNew.Last_Name__c );
                        eachAttPlus.Attachment_Name__c = attName.substringBefore('-')+' - '+raNameNew.First_Name__c+' '+raNameNew.Last_Name__c;
                        eachAttPlus.Type__c = attType.substringBefore('-')+' - '+raNameNew.First_Name__c+' '+raNameNew.Last_Name__c;
                        eachAttPlus.Instructions__c = attInstruction.substringBefore('-')+' - '+raNameNew.First_Name__c+' '+raNameNew.Last_Name__c;

                        //eachAttPlus.Type__c = eachAttPlus.Type__c.replace(raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).First_Name__c + ' ' + raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).Last_Name__c, raNameNew.First_Name__c + ' ' + raNameNew.Last_Name__c );
                        //eachAttPlus.Instructions__c = eachAttPlus.Instructions__c.replace(raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).First_Name__c + ' ' + raNameOld.get(eachAttPlus.Reg_Related_Rec_Id__c).Last_Name__c, raNameNew.First_Name__c + ' ' + raNameNew.Last_Name__c );
                        System.debug('*************** eachAttPlus.Attachment_Name__c:' + eachAttPlus.Attachment_Name__c);
                    }
                }
                update attplus;
            }
        }
    }    
    
    
    private void deleteRA(List<Registration_Account__c> oldRAList){
        // Get current user's profile name
        // Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
        // List<Registration_Account__c> regacc = [Select Id, Registration__c from Registration_Account__c where Id in : Trigger.old];
        // Delete Submission Detail 1st
        // Delete Registration Acconunts 2nd
        // if (!prof.Name.contains('System Administrator')) {
        
        for(Registration_Account__c regacc : oldRAList){
            // System.debug('regacc '+regacc);
            
            if (regacc.Registration_Status__c != 'Incomplete') {
                regacc.addError('This Record can not be deleted');
            }
            else
            {
                List<Attachments_Plus__c> attplus = [SELECT Id FROM Attachments_Plus__c WHERE Reg_Related_Rec_Id__c =:regacc.Id AND Registration__c =: regacc.Registration__c];
                // System.debug('attplus.size():' + attplus.size());
                if(attplus.size() > 0){
                    delete attplus;
                }
            }
        } 
    }
}