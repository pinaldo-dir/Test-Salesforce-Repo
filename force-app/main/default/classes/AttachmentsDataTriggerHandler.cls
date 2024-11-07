public class AttachmentsDataTriggerHandler {
    public static void afterUpdateAttachmentsDataTriggerHandler(List<Attachments_Data__c> newList, Map<Id,Attachments_Data__c> oldMapList){
        Map<Id, String> mapAttId2Release = new  Map<Id, String>();
        String fieldApiName = 'Release_to_Public';
        for(Attachments_Data__c attList : newList){
            Attachments_Data__c oldObject = oldMapList.get(attList.Id);
            if(attList.Value__c != oldObject.Value__c && attList.Field_API_Name__c != '' && attList.Field_API_Name__c.contains(fieldApiName)){
                mapAttId2Release.put(attList.Attachments__c, attList.Value__c);
            }
        }
        if(mapAttId2Release.size() > 0){
            alterAttachmentNew(mapAttId2Release);
        }
    }
    public static void afterInsertAttachmentsDataTriggerHandler(List<Attachments_Data__c> newList){
        Map<Id, String> mapAttId2Release = new  Map<Id, String>();
        String fieldApiName = 'Release_to_Public';
        for(Attachments_Data__c attachementObj : newList){
            if(attachementObj.Field_API_Name__c.contains(fieldApiName)){
                mapAttId2Release.put(attachementObj.Attachments__c,attachementObj.Value__c);
            }
        }
        if(mapAttId2Release.size() > 0){
            alterAttachmentNew(mapAttId2Release);
        }
    }
    
    private static void alterAttachmentNew(Map<Id, String> alterDataMap){
        List<Attachments_New__c> attachmentsToUpdate = [SELECT ID, Release_to_Public__c FROM Attachments_New__c WHERE
                                                        ID IN:alterDataMap.keyset()];
        if(attachmentsToUpdate.size() > 0){
            List<Attachments_New__c> attachmentsListToUpdate = new List<Attachments_New__c>();
            for(Attachments_New__c attObj : attachmentsToUpdate){
                attObj.Release_to_Public__c = ('true'.equalsIgnoreCase(alterDataMap.get(attObj.Id))) ? true : false;
                attachmentsListToUpdate.add(attObj);
            }
            update attachmentsListToUpdate;
        }
    }
}