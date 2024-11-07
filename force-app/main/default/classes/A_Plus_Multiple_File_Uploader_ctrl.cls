/*
* Controller Name : A_Plus_Multiple_File_Uploader_ctrl
* Description : Used to upload multiple files in sharepoint
*/
public class A_Plus_Multiple_File_Uploader_ctrl {
    public static String communityId;
    public static Integer maxFileUploadSize = 25000000;
    public static Integer fileSize = 0;
    public static List<CollaborationGroup> collabGroups;
    public static responseWrapper responseWrapObj;
    //Used to insert the multiple file data
    @AuraEnabled
    public static responseWrapper uploadMultipleFiles(String selectedOption, String fileInfo, Id relatedRecordId, String configDetails){
        try{
            //Check whether new attachment plus record is duplicate or not.
            checkFilesSize(fileInfo);
            
            if(responseWrapObj.isSuccess == false){ return responseWrapObj;
            }
            
            checkDuplicateAttPlus(selectedOption, fileInfo, relatedRecordId);
            if(responseWrapObj.isSuccess == false){ return responseWrapObj;
            }
            else{
                responseWrapObj.isSuccess = true;
                responseWrapObj.message = 'Your files has been successfully uploaded.';
                List<OWCServiceUtility.attachmentPlusWrapperObj> attPlusObj = new List<OWCServiceUtility.attachmentPlusWrapperObj>();
                List<Attachments_New__c> attachPlusList = new List<Attachments_New__c>();
                Map<Id, Attachments_New__c> updateAttachMap = new Map<Id, Attachments_New__c>();
                List<Map<String, String>> mapFileData = (List<Map<String, String>>)JSON.deserialize(fileInfo, List<Map<String, String>>.class);
                A_Configuration__mdt objConfig = (A_Configuration__mdt) JSON.deserialize(configDetails, A_Configuration__mdt.class);
                communityId = String.isNotBlank(objConfig.Community_ID__c) ? objConfig.Community_ID__c : '';
                List<Sobject> communities = [SELECT id FROM Network WHERE Id =: communityId];
                List<ContentVersion> contVersions = new List<ContentVersion>();
                List<String> documentIds = new List<String>();                
               
                System.debug('mapFileData ::: '+mapFileData);
                //get the record type name of based on relatedRecordID
                String sobjectName = String.valueOf(relatedRecordId.getSObjectType());
                
                String recordTypeName = '';
                
                try{
                    recordTypeName = String.valueOf(Database.query('SELECT Id,RecordType.DeveloperName '+
                                                                   'FROM '+sobjectName+ 
                                                                   ' WHERE Id =: relatedRecordId')[0].getSobject('RecordType').get('DeveloperName'));
                }
                catch(Exception ex){recordTypeName = '';}
                
                for(Map<String, String> fileObj : mapFileData){
                    documentIds.add((String) fileObj.get('documentId'));
                    //get the record type name
                    Attachments_New__c attPlus = new Attachments_New__c();
                    attPlus.File_Name__c = (String) fileObj.get('File_Name');
                    attPlus.Related_Id__c = relatedRecordId;
                    attPlus.File_Type__c = selectedOption;
                    attPlus.Upload_Date_Field_Name__c = 'Date'+'_'+attPlus.File_Type__c+'_'+recordTypeName;
                    
                    //Private checkbox is checked
                    //if Private checkbox isn't checked
                    if(fileObj.containsKey('Private') && fileObj.get('Private') != 'true'){
                        
                        //if the bin is private
                        if(objConfig.Sharing_Permissions__c == 'Private'){
                            
                            attPlus.Visible__c= 'Private ' + recordTypeName; 
                            
                        }else{
                            
                            attPlus.Visible__c=  'Public ' + recordTypeName;
                            
                        }
                        
                        
                    }else{//if private checkbox is checked
                        
                        attPlus.Visible__c= recordTypeName;
                    }
                    attachPlusList.add(attPlus);
                }
                if(attachPlusList != null && attachPlusList.size() > 0){
                    System.debug('attachPlusList ::: '+attachPlusList);
                    insert attachPlusList;
                }
                //Update Attachments_New__c record with the JSON data
                for(Integer i=0; i<attachPlusList.size(); i++){
                    //Add Attachment_Plus id into mapFileData map 
                    mapFileData[i].put('attPlus', attachPlusList[i].Id);
                    attPlusObj.clear();
                    for(String attDataFieldInfo : mapFileData[i].keyset()){
                        if(attDataFieldInfo == 'File_Name' || attDataFieldInfo == 'Private' || attDataFieldInfo == 'Description'){
                            attPlusObj.add(new OWCServiceUtility.attachmentPlusWrapperObj(attDataFieldInfo, attDataFieldInfo, mapFileData[i].get(attDataFieldInfo), ''));
                        }              
                        if(attDataFieldInfo == 'Upload_Date'){
                            attPlusObj.add(new OWCServiceUtility.attachmentPlusWrapperObj(attachPlusList[i].Upload_Date_Field_Name__c, attachPlusList[i].Upload_Date_Field_Name__c, String.valueOf(System.today()), ''));
                        }
                    }
                    attachPlusList[i].APlus_Json__c = JSON.serialize(attPlusObj);
                    updateAttachMap.put(attachPlusList[i].Id, attachPlusList[i]);
                }
                if(updateAttachMap.values() != null){
                    update updateAttachMap.values();
                }
                
                //Map contentVersion with its version data
                List<ContentVersion> contentVers = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion 
                                                                      WHERE ContentDocumentId IN: documentIds];
               
                for(Map<String, String> documentObj : mapFileData){
                    System.debug('result ::: '+(String) documentObj.get('documentId'));
                    ContentVersion contVerObj = new ContentVersion();
                    contVerObj.ContentLocation = 'S';
                    contVerObj.PathOnClient = (String) documentObj.get('name');
                    contVerObj.Title = (String) documentObj.get('File_Name'); 
                    contVerObj.VersionData = !Test.isRunningTest() ? [SELECT VersionData FROM ContentVersion 
                                                                      WHERE ContentDocumentId =: (String) documentObj.get('documentId') LIMIT 1].VersionData : EncodingUtil.base64Decode((String) documentObj.get('documentId'));
                    contVerObj.Origin = 'C';
                    
                    //Validating if network Id mentioned on config is a valid one and assigning to the content version
                    try{
                        if(String.isNotBlank(communityId)){for(Sobject objNetwork : communities) {contVerObj.NetworkId = String.valueOf(objNetwork.get('id'));break;}communityId = String.valueOf(contVerObj.NetworkId);
                        }
                        
                    }
                    catch(Exception ex){communityId = '';
                    }
                    
                    if(Test.isRunningTest()){
                        communityId = '';
                    }
                    contVersions.add(contVerObj);
                }
                
                if(contVersions != null && contVersions.size() > 0){
                    insert contVersions;
                }
                
                Set<Id> contentVerId = new Set<Id>();
                for(ContentVersion contVerObj : contVersions){
                    contentVerId.add(contVerObj.Id);
                }
                
                Map<String, Id> verWithDocIdMap = new Map<String, Id>();
                List<ContentVersion> contentVerList = [SELECT id, Title, ContentDocumentId FROM ContentVersion WHERE id IN: contentVerId];
                
                for(ContentVersion conObj : contentVerList){
                    verWithDocIdMap.put(conObj.Title, conObj.ContentDocumentId);
                }
                
                for(Map<String, String> documentObj : mapFileData){
                    documentObj.put('newContentDocId', verWithDocIdMap.get(documentObj.get('File_Name')));
                }           
                
                if(String.isNotBlank(objConfig.Collaboration_Group_Names__c)){ collabGroups = [SELECT Id, Name FROM CollaborationGroup WHERE Name =: objConfig.Collaboration_Group_Names__c.split(',')];
                }
                
                List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
                
                for(Map<String, String> documentObj : mapFileData){
                    //baseline APlus Object--sharing setting = Public-->Private
                    contentDocLinks.addAll(createSharings(collabGroups, (String) documentObj.get('newContentDocId'),communityId,documentObj,objConfig,new List<ContentDocumentLink>{new ContentDocumentLink( ContentDocumentId = (String) documentObj.get('newContentDocId'),
                                                                                                                                                                                                            ShareType = 'I',
                                                                                                                                                                                                            LinkedEntityId = (String) documentObj.get('attPlus'))}));
                    deleteAttachmentPlusAndCorrespondingRecords(!Test.isRunningTest() ? (String) documentObj.get('documentId') : (String) documentObj.get('newContentDocId'));
                }
                if(contentDocLinks != null && contentDocLinks.size() > 0){
                    insert contentDocLinks;
                }
                return responseWrapObj;
            }
        }
        catch(Exception e){
            //get exception message
            new OWCServiceUtility().Log(e);
            System.debug('Line number ::: '+e.getLineNumber());
            responseWrapObj.message = 'An error occured. Please reach out to administrator.';
            responseWrapObj.isSuccess = false;
            return responseWrapObj;
            //throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Check the files size not exceed apex heap size.
    public static void checkFilesSize(String fileInfo){
        responseWrapObj = new responseWrapper();
        List<Map<String, String>> mapFileData = (List<Map<String, String>>)JSON.deserialize(fileInfo, List<Map<String, String>>.class);
        List<String> documentIds = new List<String>();
        for(Map<String, String> fileObj : mapFileData){
            documentIds.add((String) fileObj.get('documentId'));
        }
        
        List<ContentDocument> contDocs = [SELECT Id, ContentSize FROM ContentDocument WHERE Id IN: documentIds];
        for(ContentDocument conDocObj : contDocs){
            fileSize += conDocObj.ContentSize;
            if(fileSize > maxFileUploadSize){responseWrapObj.isSuccess = false; responseWrapObj.message = 'The maximum supported file size are: 25MB';break;
            }
        }
    }
    
    public static List<ContentDocumentLink> createSharings(List<CollaborationGroup> collabGroups, String contentDocId,String communityId,Map<String,String> mapFileData, A_Configuration__mdt objConfig,List<ContentDocumentLink> contentDocLinks){
        try{
            //private checkbox
            if(String.isBlank(communityId) && String.isNotBlank(objConfig.Sharing_Permissions__c) 
               && (!mapFileData.containsKey('Private') || mapFileData.get('Private') != 'true')){
                   
                   //Giving access to entire Organization if Sharing permssion set to Public
                   if(objConfig.Sharing_Permissions__c == 'Public'){
                       
                       contentDocLinks.add(new ContentDocumentLink( ContentDocumentId = contentDocId,
                                                                   LinkedEntityId = UserInfo.getOrganizationId(),
                                                                   ShareType = 'C',
                                                                   Visibility = 'AllUsers'));
                       
                   }
                   //Giving access to collaboration groups mentioned if the sharing setting is set to private,Group names are mentioned 
                   //and Attachment not marked explicity private on file upload
                   else if(String.isNotBlank(objConfig.Collaboration_Group_Names__c)){for(CollaborationGroup collGroup : collabGroups){contentDocLinks.add(new ContentDocumentLink( ContentDocumentId = contentDocId, LinkedEntityId = collGroup.id, ShareType = 'C', Visibility = 'AllUsers'));
                       }                                                            
                       
                   }
               }
        }
        catch(Exception e){
            System.debug('Exception Line Number ::: '+e.getLineNumber());
        }
        return contentDocLinks;
    }
    @AuraEnabled 
    public static void deleteAttachmentPlusAndCorrespondingRecords(String contentDocId){     
        
        A_Plus_Controller.isNotAplusMode = false;
        
        String attachmentPlusId = '';
        
        for(ContentDocumentLink objCDL : [SELECT Id,LinkedEntity.Type,LinkedEntityId
                                          FROM ContentDocumentLink
                                          WHERE ContentDocumentId =: contentDocId]){
                                              
                                              if(objCDL.LinkedEntity.Type == 'Attachments_New__c'){attachmentPlusId =  objCDL.LinkedEntityId;
                                              }
                                              
                                          }
        
        if(String.isNotBlank(attachmentPlusId)){delete new Attachments_New__c(Id = attachmentPlusId);
        }
        
        delete new ContentDocument(Id = contentDocId);
    }
    @AuraEnabled
    public static Boolean deleteMultipleFiles(String fileInfo){
        List<ContentDocument> contentDocs;
        try{
            List<Map<String, String>> mapFileData = (List<Map<String, String>>)JSON.deserialize(fileInfo, List<Map<String, String>>.class);
            Set<Id> contentDocumentIds = new Set<Id>();
            
            for(Map<String, String> fileObj : mapFileData){
                contentDocumentIds.add((String) fileObj.get('documentId'));
            }
            
            if(contentDocumentIds != null && contentDocumentIds.size() > 0){
                contentDocs = [SELECT Id FROM ContentDocument WHERE Id IN: contentDocumentIds];
            }
            
            //Delete content document records
            if(contentDocs != null && contentDocs.size() > 0){
                Database.delete(contentDocs);
            }
            return true;
        }
        catch(Exception e){
            //get DML exception message
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void checkDuplicateAttPlus(String selectedOption, String fileInfo, String recordId){
        system.debug('duplicate check:');
        responseWrapObj = new responseWrapper();
        List<Map<String, String>> mapFileData = (List<Map<String, String>>)JSON.deserialize(fileInfo, List<Map<String, String>>.class);
        List<String> newFileNames = new List<String>();
        
        List<Attachments_New__c> attachPlusRecs = [SELECT Id, Name, File_Type__c, Related_Id__c, File_Name__c, Share_Point_Item_Id__c
                                                   FROM Attachments_New__c WHERE Related_Id__c =: recordId
                                                   AND File_Type__c =: selectedOption];
        System.debug('attachPlusRecs ::: '+attachPlusRecs);
        for(Map<String, String> mapFileObj : mapFileData){
            String fileName = (String) mapFileObj.get('name');
            if(newFileNames != null && newFileNames.contains(fileName.substring(0, fileName.lastIndexOf('.')))){
                responseWrapObj.isSuccess = false;
                responseWrapObj.message = 'You are uploading duplicate file (' + fileName.substring(0, fileName.lastIndexOf('.')) + ').';
                break;
            }
            else if(fileName.indexOf('.') > 0){
                newFileNames.add(fileName.substring(0, fileName.lastIndexOf('.')));
            }
        }
        System.debug('newFileNames ::: '+newFileNames);
        if(attachPlusRecs.size() > 0){
            for(Attachments_New__c attachPlusObj : attachPlusRecs){
                if(newFileNames.contains(attachPlusObj.File_Name__c) && attachPlusObj.File_Type__c == selectedOption){
                    responseWrapObj.isSuccess = false;
                    responseWrapObj.message = attachPlusObj.File_Name__c + ' is already exist.';
                    break;
                }
            }
        }
    }
    
    public class responseWrapper{
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public Boolean isSuccess{get;set;}
    }
}