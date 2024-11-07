public with sharing class OWCMultipleFileUploadController {
    /* This method is used to get all the files uploaded by end user on OWC form. */
    @AuraEnabled
    public static List<Object> getUploadedFiles(list<String> multipleFiles){
        return null;
        /*
        try{
            List<MultipleFileWrapper> multipleWrapperList = new List<MultipleFileWrapper>();
            List<ContentVersion> contents = [SELECT Id, Title FROM ContentVersion WHERE Id IN :multipleFiles];
            if(contents.size() > 0){
                for(ContentVersion contentObj : contents){
                    MultipleFileWrapper multipleObj = new MultipleFileWrapper();     
                    multipleObj.title = contentObj.Title;
                    multipleObj.versionData = contentObj.VersionData;
                    multipleWrapperList.add(multipleObj);
                }
            }
            if(multipleWrapperList.size() > 0){
                return multipleWrapperList;
            }
            else{
                return null;
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }	*/
    }
    
    @AuraEnabled 
    public static List<ID> insertUploadedFiles(list<Object> uploadedFiles, List<ID> contentVersionId){
        return null;
        /*
        System.debug('contentVersionIds :::> '+contentVersionId);
        System.debug('uploadedFiles ::: '+uploadedFiles);
        MultipleFileWrapper file;
        List<Blob> versionData = new List<Blob>();
        List<ContentVersion> contentVersionNewList = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id IN :contentVersionId];
        for(ContentVersion cpntentVersionObj : contentVersionNewList){
            versionData.add(cpntentVersionObj.VersionData);
        }
        List<ID> contentVersionIds = new List<ID>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        for (Object fileObj : uploadedFiles) {
            file = (MultipleFileWrapper)JSON.deserialize(JSON.serialize(fileObj), MultipleFileWrapper.class);
            if(versionData.contains(file.VersionData)){
                
            }
            else{
                ContentVersion contentVersionObj = new ContentVersion();
                contentVersionObj.PathOnClient = file.Title;
                contentVersionObj.Title = file.Title;
                contentVersionObj.VersionData = file.VersionData;
                contentVersionList.add(contentVersionObj);
            }
        }
        
        list<Database.saveResult> res = Database.insert(contentVersionList);
        
        for (Database.SaveResult saveResult : res) {
            if(saveResult.isSuccess()) {
                contentVersionIds.add(saveResult.getId());
                System.debug('Inserted Data ::: '+saveResult.getId());
            }
        }
        System.debug(contentVersionIds);
        return contentVersionIds;
		*/
    }
    
    /*
    public class MultipleFileWrapper {
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public Blob versionData {get;set;}
    }
    */
}