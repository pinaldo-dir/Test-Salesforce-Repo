public without sharing class DirPublicContentDownloadUrlController {
    public static List<contentDistributionObj> getDownloadPublicContentUrl(Set<ID> contentdocumentIds){
        List<contentDistributionObj> conObjList = new List<contentDistributionObj>();
        List<ContentDistribution> conDisList = WageClaimQuerySelector.getDownloadContentUrlList(contentdocumentIds);
        for(ContentDistribution conDistObj : conDisList){
            contentDistributionObj conObj = new contentDistributionObj();
            conObj.downloadPublicUrl = conDistObj.ContentDownloadUrl;
            conObj.contentDocumentId = conDistObj.ContentDocumentId;
            conObjList.add(conObj);
        }
        return conObjList; 
    }
    public class contentDistributionObj{
        @AuraEnabled
        public String downloadPublicUrl;
        @AuraEnabled
        public String contentDocumentId;
    }
}