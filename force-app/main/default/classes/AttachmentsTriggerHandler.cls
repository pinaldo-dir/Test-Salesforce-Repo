/* 1. Update Release_To_Public from APlus Record.
 * 2. Update Release_To_Public from A_Plus_Manager cmp
 * */
public class AttachmentsTriggerHandler {
    public static Boolean runBeforeUpdate = true;
    public static Boolean runAfterUpdate = true;
    public static void beforeUpdateAttachmentsHandler(Map<Id,Attachments_New__c> newMap, Map<Id,Attachments_New__c> oldMapList) {
        Map<Id, Attachments_New__c> mapAttId2Release = new  Map<Id, Attachments_New__c>();
        List<Attachments_New__c> attPlusListToUpdate = new List<Attachments_New__c>();
        Set<ID> removeAttahementWithNoChildSet = new Set<ID>();
        Set<Id> publicAPlusList = new Set<Id>();
        Set<Id> publicAPlusListToDelete = new Set<Id>();
        String str = 'Release_to_Public%';
        for(Attachments_New__c attObj : newMap.values()){
            if( (attObj.Release_to_Public__c != oldMapList.get(attObj.Id).Release_to_Public__c) && 
               (attObj.APlus_Json__c == oldMapList.get(attObj.Id).APlus_Json__c) )
            {
                mapAttId2Release.put(attObj.id, attObj);
                removeAttahementWithNoChildSet.add(attObj.id);
            }
        }
        
        
        if(mapAttId2Release.size() > 0){
            List<OWCServiceUtility.attachmentPlusWrapperObj> UpdateAttPlusData = new List<OWCServiceUtility.attachmentPlusWrapperObj>();
            Map<Id, Attachments_New__c> attPlusList = new Map<Id, Attachments_New__c>([SELECT ID, Release_to_Public__c, APlus_Json__c FROM Attachments_New__c WHERE Id IN: mapAttId2Release.keySet()]);
            for(Attachments_New__c attObj : newMap.values()){
                if(mapAttId2Release.containsKey(attObj.Id)){
                    List<OWCServiceUtility.attachmentPlusWrapperObj> attPlusObj = (List<OWCServiceUtility.attachmentPlusWrapperObj>) JSON.deserialize(attObj.APlus_Json__c, List<OWCServiceUtility.attachmentPlusWrapperObj>.class);
                    for(OWCServiceUtility.attachmentPlusWrapperObj wrapperAttObj : attPlusObj){
                        System.debug('wrapperAttObj.fieldAPIName ::: '+wrapperAttObj.fieldAPIName);
                        if(wrapperAttObj.fieldAPIName.contains('Release_to_Public')){
                            if(removeAttahementWithNoChildSet.contains(attObj.Id)){
                                removeAttahementWithNoChildSet.remove(attObj.Id);    
                            }
                            System.debug('attObj.Release_to_Public__c ::: '+attObj.Release_to_Public__c);
                            String fieldValue = String.valueOf(attObj.Release_to_Public__c);
                            wrapperAttObj.value = fieldValue;
                            UpdateAttPlusData.add(wrapperAttObj);
                        }
                        else{
                            UpdateAttPlusData.add(wrapperAttObj);
                        }
                    }
                    System.debug('UpdateAttPlusData ::: '+JSON.serialize(UpdateAttPlusData));
                    attObj.APlus_Json__c = JSON.serialize(UpdateAttPlusData);
                }
                
                // attPlusListToUpdate.add(attObj);
            }
            //update attPlusList.values();
            System.debug('removeAttahementWithNoChildSet::: '+removeAttahementWithNoChildSet);
            if(removeAttahementWithNoChildSet.size() > 0){
                List<String> sObjectsList = new List<String>();
                List<OWCServiceUtility.attachmentPlusWrapperObj> UpdateAttPlusDataList = new List<OWCServiceUtility.attachmentPlusWrapperObj>();
                Map<Id, Attachments_New__c> attNewObj = new Map<Id, Attachments_New__c>([SELECT ID,File_Name__c, APlus_Json__c, Release_to_Public__c, Related_Id__c FROM Attachments_New__c WHERE Id IN: removeAttahementWithNoChildSet]);
                Set<String> caseIds = new Set<String>();
                Map<String, String> caseWithRtName = new Map<String, String>();
                for(Attachments_New__c attach: newMap.values())
                {	
                    system.debug('attach.Related_Id__c: '+attach.Related_Id__c);
                    system.debug('attach.File_Name__c: '+attach.File_Name__c);
                    if(removeAttahementWithNoChildSet.contains(attach.Id)){
                        if(String.isNotBlank(attach.Related_Id__c) && attach.Related_Id__c.startsWith('a1B')){
                            caseIds.add(attach.Related_Id__c);
                        }
                    }
                    
                }
                for(DIR_Case__c cse : [SELECT Id,RecordType.DeveloperName FROM DIR_Case__c WHERE ID IN: caseIds])
                {
                    caseWithRtName.put(cse.Id, cse.RecordType.DeveloperName);
                }
                List<Attachments_New__c> attachToUpdate = new List<Attachments_New__c>();              
                for(Attachments_New__c attObj : newMap.values()){
                    if(removeAttahementWithNoChildSet.contains(attObj.Id)){
                        if(String.isNotBlank(attObj.Related_Id__c) && attObj.Related_Id__c.startsWith('a1B')){
                            String  recordTypeName = caseWithRtName.get(attObj.Related_Id__c);
                            List<OWCServiceUtility.attachmentPlusWrapperObj> attPlusObj = (List<OWCServiceUtility.attachmentPlusWrapperObj>) JSON.deserialize(attObj.APlus_Json__c, List<OWCServiceUtility.attachmentPlusWrapperObj>.class);
                            
                            attPlusObj.add(new OWCServiceUtility.attachmentPlusWrapperObj( 
                                'Release_to_Public_'+mapAttId2Release.get(attObj.Id).File_Type__c, 
                                'Release_to_Public_'+mapAttId2Release.get(attObj.Id).File_Type__c, 
                                String.valueOf(mapAttId2Release.get(attObj.Id).Release_to_Public__c),
                                '' 
                            ));
                            if(attObj.Release_to_Public__c == true){
                                attPlusObj.add(new OWCServiceUtility.attachmentPlusWrapperObj( 
                                    'Release_to_Public_'+mapAttId2Release.get(attObj.Id).File_Type__c+'_'+recordTypeName, 
                                    'Release_to_Public_'+mapAttId2Release.get(attObj.Id).File_Type__c+'_'+recordTypeName, 
                                    String.valueOf(mapAttId2Release.get(attObj.Id).Release_to_Public__c),
                                    '' 
                                ));
                            }
                            attObj.APlus_Json__c = JSON.serialize(attPlusObj);
                            system.debug('attObj.APlus_Json__c: '+attObj.APlus_Json__c);
                            //attNewObj.get(attObj.Id).APlus_Json__c = JSON.serialize(attPlusObj);
                            //attachToUpdate.add(attNewObj.get(attObj.Id));
                        }
                    }
                }
                //update attachToUpdate;
            }
        }
    }
    public static void afterUpdateAttachmentsHandler(Map<Id,Attachments_New__c> newMap, Map<Id,Attachments_New__c> oldMapList){
        Map<Id, Attachments_New__c> mapAttId2Release = new  Map<Id, Attachments_New__c>();
        List<Attachments_New__c> attPlusListToUpdate = new List<Attachments_New__c>();
        Set<ID> removeAttahementWithNoChildSet = new Set<ID>();
        Set<Id> publicAPlusList = new Set<Id>();
        Set<Id> publicAPlusListToDelete = new Set<Id>();
        String str = 'Release_to_Public%';
        Set<Id> aPlusIdsToDeleteFiles = new Set<Id>();
        for(Attachments_New__c attObj : newMap.values()){
            /* Code moved in Before Update context
            if( (attObj.Release_to_Public__c != oldMapList.get(attObj.Id).Release_to_Public__c) && 
               	(attObj.APlus_Json__c == oldMapList.get(attObj.Id).APlus_Json__c) )
            {
                mapAttId2Release.put(attObj.id, attObj);
                removeAttahementWithNoChildSet.add(attObj.id);
            }
			*/
            if( (attObj.Release_to_Public__c != oldMapList.get(attObj.Id).Release_to_Public__c) 
               /*&& 
              	(attObj.APlus_Json__c == oldMapList.get(attObj.Id).APlus_Json__c)*/ )
            {
                if(attObj.Release_to_Public__c){
                    //publicAPlusList.add(attObj.Id);
                }else{
                    publicAPlusListToDelete.add(attObj.Id);
                }
            }
            
            //Prepare list of APlus records where sharepoint id is updated so we will delete the related ContentDocument files from salesforce
            if(attObj.Share_Point_Item_Id__c != oldMapList.get(attObj.Id).Share_Point_Item_Id__c 
               && String.isNotBlank(attObj.Share_Point_Item_Id__c)
               && attObj.Sharepoint_File_Status__c != oldMapList.get(attObj.Id).Sharepoint_File_Status__c 
              && attObj.Sharepoint_File_Status__c == 'success' )
            {
                aPlusIdsToDeleteFiles.add(attObj.Id);
            }
        }
        //delete existing Fiels from salesforce when files are stored in sharepoint
        if(aPlusIdsToDeleteFiles.size() > 0)	deleteFilesFromSalesforce(aPlusIdsToDeleteFiles);
        
        //delete existing links when Release To public set to false
        if(publicAPlusListToDelete.size() > 0)	deleteExistingPublicLinks(publicAPlusListToDelete);
        
        //create public Links 
        /*
        if(publicAPlusList.size() > 0)	{
            List<ContentDistribution> distributionsToInsert =  createContentDistribution(publicAPlusList, newMap);
            if(distributionsToInsert != null){
                system.debug('distributionsToInsert: '+distributionsToInsert);
                insert distributionsToInsert;
            }
        }	*/
        /* Code moved in Before Update context
        if(mapAttId2Release.size() > 0){
            List<OWCServiceUtility.attachmentPlusWrapperObj> UpdateAttPlusData = new List<OWCServiceUtility.attachmentPlusWrapperObj>();
            Map<Id, Attachments_New__c> attPlusList = new Map<Id, Attachments_New__c>([SELECT ID, Release_to_Public__c, APlus_Json__c FROM Attachments_New__c WHERE Id IN: mapAttId2Release.keySet()]);
            for(Attachments_New__c attObj : attPlusList.values()){
                List<OWCServiceUtility.attachmentPlusWrapperObj> attPlusObj = (List<OWCServiceUtility.attachmentPlusWrapperObj>) JSON.deserialize(attObj.APlus_Json__c, List<OWCServiceUtility.attachmentPlusWrapperObj>.class);
                for(OWCServiceUtility.attachmentPlusWrapperObj wrapperAttObj : attPlusObj){
                    System.debug('wrapperAttObj.fieldAPIName ::: '+wrapperAttObj.fieldAPIName);
                    if(wrapperAttObj.fieldAPIName.contains('Release_to_Public')){
                        if(removeAttahementWithNoChildSet.contains(attObj.Id)){
                            removeAttahementWithNoChildSet.remove(attObj.Id);    
                        }
                        System.debug('attObj.Release_to_Public__c ::: '+attObj.Release_to_Public__c);
                        String fieldValue = String.valueOf(attObj.Release_to_Public__c);
                        wrapperAttObj.value = fieldValue;
                        UpdateAttPlusData.add(wrapperAttObj);
                    }
                    else{
                        UpdateAttPlusData.add(wrapperAttObj);
                    }
                }
                System.debug('UpdateAttPlusData ::: '+JSON.serialize(UpdateAttPlusData));
                attPlusList.get(attObj.Id).APlus_Json__c = JSON.serialize(UpdateAttPlusData);
                // attPlusListToUpdate.add(attObj);
            }
            update attPlusList.values();
            System.debug('removeAttahementWithNoChildSet::: '+removeAttahementWithNoChildSet);
            if(removeAttahementWithNoChildSet.size() > 0){
                List<String> sObjectsList = new List<String>();
                List<OWCServiceUtility.attachmentPlusWrapperObj> UpdateAttPlusDataList = new List<OWCServiceUtility.attachmentPlusWrapperObj>();
                Map<Id, Attachments_New__c> attNewObj = new Map<Id, Attachments_New__c>([SELECT ID,File_Name__c, APlus_Json__c, Release_to_Public__c, Related_Id__c FROM Attachments_New__c WHERE Id IN: removeAttahementWithNoChildSet]);
                Set<String> caseIds = new Set<String>();
                Map<String, String> caseWithRtName = new Map<String, String>();
                for(Attachments_New__c attach: attNewObj.values())
                {	
                    system.debug('attach.Related_Id__c: '+attach.Related_Id__c);
                    system.debug('attach.File_Name__c: '+attach.File_Name__c);
                    if(String.isNotBlank(attach.Related_Id__c) && attach.Related_Id__c.startsWith('a1B')){
                        caseIds.add(attach.Related_Id__c);
                    }
                }
                for(DIR_Case__c cse : [SELECT Id,RecordType.DeveloperName FROM DIR_Case__c WHERE ID IN: caseIds])
                {
                    caseWithRtName.put(cse.Id, cse.RecordType.DeveloperName);
                }
                List<Attachments_New__c> attachToUpdate = new List<Attachments_New__c>();              
                for(Attachments_New__c attObj : attNewObj.values()){
                    if(String.isNotBlank(attObj.Related_Id__c) && attObj.Related_Id__c.startsWith('a1B')){
                        String  recordTypeName = caseWithRtName.get(attObj.Related_Id__c);
                        List<OWCServiceUtility.attachmentPlusWrapperObj> attPlusObj = (List<OWCServiceUtility.attachmentPlusWrapperObj>) JSON.deserialize(attObj.APlus_Json__c, List<OWCServiceUtility.attachmentPlusWrapperObj>.class);
                        
                        attPlusObj.add(new OWCServiceUtility.attachmentPlusWrapperObj( 
                            'Release_to_Public_'+mapAttId2Release.get(attObj.Id).File_Type__c, 
                            'Release_to_Public_'+mapAttId2Release.get(attObj.Id).File_Type__c, 
                            String.valueOf(mapAttId2Release.get(attObj.Id).Release_to_Public__c),
                            '' 
                        ));
                        if(attObj.Release_to_Public__c == true){
                            attPlusObj.add(new OWCServiceUtility.attachmentPlusWrapperObj( 
                                'Release_to_Public_'+mapAttId2Release.get(attObj.Id).File_Type__c+'_'+recordTypeName, 
                                'Release_to_Public_'+mapAttId2Release.get(attObj.Id).File_Type__c+'_'+recordTypeName, 
                                String.valueOf(mapAttId2Release.get(attObj.Id).Release_to_Public__c),
                                '' 
                            ));
                        }
                        attNewObj.get(attObj.Id).APlus_Json__c = JSON.serialize(attPlusObj);
                        attachToUpdate.add(attNewObj.get(attObj.Id));
                    }
                    
                }
                update attachToUpdate;
            }
			
        }  */
        /* if(mapAttId2Release.size() > 0){
List<Attachments_Data__c> attachmentsDataToUpdate = [SELECT Id, Field_API_Name__c, Value__c,Attachments__c
FROM Attachments_Data__c WHERE Field_API_Name__c LIKE :str AND
Attachments__c IN:mapAttId2Release.keyset()];
List<Attachments_Data__c> attachmentListTOUpdate = new List<Attachments_Data__c>();

if(attachmentsDataToUpdate.size() > 0){
for(Attachments_Data__c attachmentData : attachmentsDataToUpdate){
if(removeAttahementWithNoChildSet.contains(attachmentData.Attachments__c)){
removeAttahementWithNoChildSet.remove(attachmentData.Attachments__c);    
}
String fieldValue = String.valueOf(mapAttId2Release.get(attachmentData.Attachments__c).Release_to_Public__c);
attachmentData.Value__c = fieldValue;
attachmentListTOUpdate.add(attachmentData);

}
update attachmentListTOUpdate;
}
if(removeAttahementWithNoChildSet.size() > 0){
List<Attachments_Data__c> newAttachmentData = new List<Attachments_Data__c>();
for(Id idObj:removeAttahementWithNoChildSet){
Attachments_Data__c newAttachment = new Attachments_Data__c();
newAttachment.Attachments__c = idObj;
newAttachment.Value__c = String.valueOf(mapAttId2Release.get(idObj).Release_to_Public__c);
newAttachment.Field_API_Name__c = 'Release_to_Public_'+mapAttId2Release.get(idObj).File_Type__c;
newAttachment.Field_Name__c = 'Release_to_Public_'+mapAttId2Release.get(idObj).File_Type__c;
newAttachmentData.add(newAttachment);
}
insert newAttachmentData;
}

}*/
        
    }
    /*
    public static List<ContentDistribution> createContentDistribution(Set<Id> publicAPlusList, Map<Id,Attachments_New__c> newMap){
        List<ContentDistribution> cdList = new List<ContentDistribution>();
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        //Set<Id> contentVersionId LatestPublishedVersionId
        Set<Id> contentDocSet = new Set<Id> ();
        linkList = [SELECT Id, ContentDocumentId,Visibility FROM  ContentDocumentLink
                    WHERE linkedEntityId IN: publicAPlusList];
        Map<String, ContentDocumentLink> linksMapwithCD = new Map<String, ContentDocumentLink>();
        for(ContentDocumentLink link: linkList){
            linksMapwithCD.put(link.ContentDocumentId, link);
        }
        for(ContentDocumentLink link: linkList)
        {
            contentDocSet.add(link.ContentDocumentId);                              
            
        }
        system.debug('contentDocSet: '+contentDocSet);
        system.debug('linksMapwithCD: '+linksMapwithCD);
        Map<String, String> allPublishVersionMap = new Map<String, String>();
        for(ContentDocument cd: [SELECT LatestPublishedVersionId, Id FROM ContentDocument 
                                 where Id IN: contentDocSet])
        {
            allPublishVersionMap.put(cd.LatestPublishedVersionId, cd.Id);
        }
        Set<String> existingPublishedLinks = new Set<String>();
        for(ContentDistribution cd: [SELECT ID,ContentVersionId FROM ContentDistribution 
                                     WHERE Name = 'Port Drayage Link' AND ContentVersionId IN: allPublishVersionMap.keySet()]) //
        {
            existingPublishedLinks.add(cd.ContentVersionId);
        }
        system.debug('existingPublishedLinks: '+existingPublishedLinks);
        List<ContentDocumentLink> linksToUpdate = new List<ContentDocumentLink>();
        for(String cdId: allPublishVersionMap.keySet())
        {	system.debug('cdId: '+cdId);
         if(! existingPublishedLinks.contains(cdId)){
             if(linksMapwithCD.containsKey(allPublishVersionMap.get(cdId))){
                 if(linksMapwithCD.get(allPublishVersionMap.get(cdId)).Visibility != 'AllUsers'){
                     ContentDocumentLink link = linksMapwithCD.get(allPublishVersionMap.get(cdId));
                     link.Visibility = 'AllUsers';
                     linksToUpdate.add(link);
                 }
             }
             ContentDistribution newDist = new ContentDistribution();
             newDist.ContentVersionId = cdId;
             newDist.Name = 'Port Drayage Link';
             newDist.PreferencesNotifyOnVisit = false;
             newDist.PreferencesAllowViewInBrowser = true;
             newDist.PreferencesAllowOriginalDownload=true;
             cdList.add(newDist);
         }
        }
        system.debug('cdList: '+cdList);
        system.debug('linksToUpdate: '+linksToUpdate);
        if(linksToUpdate.size() > 0) 	update linksToUpdate;
        if(cdList.size() > 0) 	return cdList; 
        return null;
    }
    */
    public static void deleteExistingPublicLinks(Set<Id> publicAPlusList){
        List<ContentDistribution> newDist = new List<ContentDistribution>();
        List<ContentDistribution> cdList = new List<ContentDistribution>();
        //Set<Id> contentVersionId LatestPublishedVersionId
        Set<Id> contentDocSet = new Set<Id> ();
        for(ContentDocumentLink link: [SELECT Id, ContentDocumentId FROM  ContentDocumentLink
                                       WHERE linkedEntityId IN: publicAPlusList])
        {
            contentDocSet.add(link.ContentDocumentId);                              
            
        }
        Set<String> allPublishVersionList = new Set<String>();
        for(ContentDocument cd: [SELECT LatestPublishedVersionId, Id FROM ContentDocument 
                                 where Id IN: contentDocSet])
        {
            allPublishVersionList.add(cd.LatestPublishedVersionId);
        }
        List<ContentDistribution> existingPublishedLinks = new List<ContentDistribution>();
        for(ContentDistribution cd: [SELECT ID,Name FROM ContentDistribution 
                                     WHERE Name = 'Port Drayage Link' AND ContentVersionId IN: allPublishVersionList]) //
        {
            existingPublishedLinks.add(cd);
        }
        system.debug('existingPublishedLinks: '+existingPublishedLinks);
        delete existingPublishedLinks;
    }
    
    //Update attachment plus record on SF and delete files from sharepoint.
    public static void updateAttachmentRecord(Map<Id,Attachments_New__c> newMap, Map<Id,Attachments_New__c> oldMapList){
        List<ContentDocumentLink> cdlList;
        Set<Id> aPlusWithoutSharePointId = new Set<Id>();
        deleteFileWrapper wrapperObj = new deleteFileWrapper();
        for(Attachments_New__c attObj : newMap.values()){
            if((attObj.Release_to_Public__c != oldMapList.get(attObj.Id).Release_to_Public__c) && attObj.Release_to_Public__c == true && String.isNotBlank(attObj.Share_Point_Item_Id__c)){
                wrapperObj.aPlusId = attObj.Id;
                wrapperObj.sharePointDocumentId = attObj.Share_Point_Item_Id__c;
                OWCSharepointAPIService.deleteFileFromSharePoint(json.serialize(wrapperObj), attObj.Id);
            }
            else if((attObj.Release_to_Public__c != oldMapList.get(attObj.Id).Release_to_Public__c) && attObj.Release_to_Public__c == false && String.isBlank(attObj.Share_Point_Item_Id__c)){
                aPlusWithoutSharePointId.add(attObj.Id);
            }
        }
        
        if(aPlusWithoutSharePointId != null && aPlusWithoutSharePointId.size() > 0){
            cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: aPlusWithoutSharePointId];
        }
        
        if(cdlList != null && cdlList.size() > 0){
           	ContentDocumentLinkHandler.uploadFilesOnSharePoint(cdlList);
        }
    }
    
    //Move file on SharePoint
    
    public static void moveFileOnSharePoint(List<Attachments_New__c> fileData,Map<Id,Attachments_New__c> oldData){
        System.debug('>>>'+fileData);
        String caseId;
        MoveFileWrapper pathData = new MoveFileWrapper();
        
        for(Attachments_New__c mvObj : fileData){
            if(mvObj.File_Type__c != oldData.get(mvObj.Id).File_Type__c)
            {
                caseId = mvObj.Related_Id__c;
                File flObj = new File();
                flObj.newPath = mvObj.File_Type__c;
                flObj.sharePointDocumentId = mvObj.Share_Point_Item_Id__c;
                flObj.fileExtension = '';
                flObj.fileName = '';
                pathData.file = flObj;
            }
        }
        if(String.isNotBlank(caseId)){
            List<DIR_Case__c> caseName = [SELECT Id, Name FROM DIR_Case__c WHERE Id =: caseId];
            pathData.caseNumber = caseName[0].Name;
            System.debug('?????????'+JSON.serialize(pathData));
            String jsonDta = JSON.serialize(pathData,true);
            OWCSharepointAPIService.moveFileOnSharePoint(jsonDta);
        }
    }
    
    //delete files from salesforce when the Files are successfully created in sharepoint
    public static void deleteFilesFromSalesforce(Set<Id> aPlusIdsToDeleteFiles) {
        //get all contentDocumentIds to delete
        List<ContentDocumentLink> conDocIds = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: aPlusIdsToDeleteFiles];
        //List of ContentDocumentId
        List<Id> contentDocIdToDelete = new List<Id>();
        for(ContentDocumentLink conDocLinkObj : conDocIds){
            contentDocIdToDelete.add(conDocLinkObj.ContentDocumentId);
        }
        
        Database.delete(contentDocIdToDelete) ;        
    }
    //Wrapper class for move File on SharePoint
    
    public class MoveFileWrapper{
        public String caseNumber {get;set;}
        public File file {get;set;}
    }
    
    public class File{
        public String newPath {get; set;}
        public String sharePointDocumentId {get; set;}
        public String fileExtension {get;set;}
        public String fileName {get;set;}
        
    }
    
    public class deleteFileWrapper{
        public String aPlusId {get;set;}
        public String sharePointDocumentId {get;set;}
    }
}