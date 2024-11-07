public class OWCMultipleFileUploadHandler {
    public Integer maxFileSize = 25000000;
    public Integer fileSize = 0;
    public void validateOWCFiles(List<ContentVersion> contentVersions){
        System.debug('files ::: '+contentVersions[0].OWC_Source__c);
        Set<Id> contentVersionIds = new Set<Id>();
        if(contentVersions.size() > 0){
            for(ContentVersion conObj : contentVersions){
                fileSize += conObj.ContentSize;
                if(fileSize > maxFileSize){
                    conObj.addError('Error');
                }
            }
        }
    }
}