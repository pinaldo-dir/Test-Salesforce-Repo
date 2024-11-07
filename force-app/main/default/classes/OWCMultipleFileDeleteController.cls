public with sharing class OWCMultipleFileDeleteController {
    @AuraEnabled
    public static void deleteMultipleFiles(List<String> contentVersionIds){
        try{
            if(contentVersionIds != null ){
                if(contentVersionIds.size() > 0){
                    Database.delete(contentVersionIds);
                }
            }
        }
        catch (Exception e) { throw new AuraHandledException(e.getMessage());
        }
    }
}