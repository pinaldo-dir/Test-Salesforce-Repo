public without sharing class OWCSharepointAPIService {
    
    @future(callout = true)
    public static void deleteFolderOnSharepoint(String cmFolderName){
        System.debug('cmFolderName'+cmFolderName);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Accept', '*/*');
        req.setEndpoint('callout:SharePointNamedCred/api/deleteFolder');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('client_id', '{!$Credential.UserName}');
        req.setHeader('client_secret', '{!$Credential.Password}');
        req.setTimeout(60*1000);
        req.setBody(cmFolderName);
        HttpResponse res;
        res = http.send(req);
        if(!Test.isRunningTest()){
        }
    }
    
    public static void uploadFaildFileOnMule(String aplusData){
        System.debug('aPlusData'+aplusData);
        Blob myBlob = Blob.valueOf(aplusData);
        System.debug('myBlob'+myBlob);
        Integer contentSize = myBlob.size();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Accept', '*/*');
        req.setEndpoint('callout:SharePointNamedCred/api/uploadFile');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('client_id', '{!$Credential.UserName}');
        req.setHeader('client_secret', '{!$Credential.Password}');
        req.setHeader('Content-Length',String.valueOf(contentSize));
        req.setTimeout(60*1000);
        req.setBody(aplusData);
        HttpResponse res;
        if(!Test.isRunningTest()){
            res = http.send(req);
            System.debug('res?????'+res.getBody());
            System.debug('resStatusCode?????'+res.getBody());
        }
    }
    
    @future(callout=true)
    public static void uploadDataOnMule(String aplusData){
        uploadSalesforceFileOnMule(aplusData);
    }
    public static void uploadDataOnMuleForThirdParty(String aplusData){
        uploadSalesforceFileOnMule(aplusData);
    }
    public static void uploadSalesforceFileOnMule(String aplusData){
        System.debug('aPlusData'+aplusData);
        Blob myBlob = Blob.valueOf(aplusData);
        System.debug('myBlob'+myBlob);
        Integer contentSize = myBlob.size();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Accept', '*/*');
        req.setEndpoint('callout:SharePointNamedCred/api/uploadFile');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('client_id', '{!$Credential.UserName}');
        req.setHeader('client_secret', '{!$Credential.Password}');
        req.setHeader('Content-Length',String.valueOf(contentSize));
        req.setTimeout(60*1000);
        req.setBody(aplusData);
        HttpResponse res;
        if(!Test.isRunningTest()){
            res = http.send(req);
        }
    }
    @future(callout=true)
    public static void deleteFileFromSharePoint(String jsonBody, String aPlusId){
        Http http = new Http();
        HttpRequest moveRequest = new HttpRequest();
        moveRequest.setMethod('POST');
        moveRequest.setHeader('Accept', '*/*');
        moveRequest.setEndpoint('callout:SharePointNamedCred/api/createFile');
        moveRequest.setHeader('Content-Type', 'application/json');
        moveRequest.setHeader('client_id', '{!$Credential.UserName}');
        moveRequest.setHeader('client_secret', '{!$Credential.Password}');
        moveRequest.setTimeout(20*1000);
        moveRequest.setBody(jsonBody);
        HttpResponse res = http.send(moveRequest);
        if(res.getStatusCode() == 201){
            System.debug('Files deleted successfully.');
            Attachments_New__c attachPlusObj = [SELECT Id, Share_Point_Item_Id__c, Sharepoint_File_Status__c, Sharepoint_File_Upload_Error__c
                                                FROM Attachments_New__c WHERE Id =: aPlusId LIMIT 1];
            try{
                attachPlusObj.Share_Point_Item_Id__c = '';
                attachPlusObj.Sharepoint_File_Status__c = '';
                attachPlusObj.Sharepoint_File_Upload_Error__c = '';
                update attachPlusObj;
                System.debug('After update ::: '+[SELECT Id, Share_Point_Item_Id__c, Sharepoint_File_Status__c, Sharepoint_File_Upload_Error__c FROM Attachments_New__c WHERE Id =: aPlusId LIMIT 1]);
            }
            catch(Exception ex){
                System.debug('Exception caught ::: '+ex.getStackTraceString());
            }
        }
    }
    
    
    //Used to download the multiple files from sharepoint via call sharepoint API
    public static List<String> getFilesFromSharePoint(List<String> attachPlusIds){
        Set<Id> attachPlusIdSet = new Set<Id>();
        List<Attachments_New__c> sharepointId = [SELECT Id,Share_Point_Item_Id__c FROM Attachments_New__c WHERE Id IN : attachPlusIds];
        System.debug('attachPlusIds in Sharepoint class :::: '+attachPlusIds);
        List<String> dowloadLinkList = new List<String>();
        DownloadWrapper downloadFileJson = new DownloadWrapper();
        List<Files> downloadFileList = new List<Files>();	
        for(Attachments_New__c fmObj : sharepointId){ 
            Files downloadFileObj = new Files();
            if(String.isNotBlank(fmObj.Share_Point_Item_Id__c)){
                downloadFileObj.sharePointDocumentId = fmObj.Share_Point_Item_Id__c;
                downloadFileList.add(downloadFileObj);
            }
            else{
                attachPlusIdSet.add(fmObj.Id);
            }
        }
        List<String> downloadUrlList = new List<String>();
        //check for the sharepoint files
        if(downloadFileList.size() >0){
            downloadFileJson.files = downloadFileList;
            Blob myBlob = Blob.valueOf(JSON.serialize(downloadFileJson));
            Integer contentSize = myBlob.size();
            Http http = new Http();
            HttpRequest downLoadFileReq = new HttpRequest();
            downLoadFileReq.setMethod('GET');
            downLoadFileReq.setEndpoint('callout:SharePointNamedCred/api/downloadFile');
            downLoadFileReq.setHeader('Content-Type', 'application/json');
            downLoadFileReq.setHeader('client_id', '{!$Credential.UserName}');
            downLoadFileReq.setHeader('client_secret', '{!$Credential.Password}');
            downLoadFileReq.setHeader('Accept', '*/*');
            downLoadFileReq.setHeader('Content-Length', String.valueOf(contentSize));
            downLoadFileReq.setBody(JSON.serialize(downloadFileJson));
            downLoadFileReq.setTimeout(60 * 1000);
            HttpResponse res = http.send(downLoadFileReq);
            List<Object> response = (List<Object>)JSON.deserializeUntyped(res.getBody());
            for(Object obj : response){
                Map<String,Object> mapObj = (Map<String,Object>) obj;
                downloadUrlList.add(String.valueOf(mapObj.get('downloadURL')));
            }
        }
        //check for teh Salesforce files
        if(attachPlusIdSet.size() >0){
            List<ContentDocumentLink> cdl;
            if(attachPlusIdSet != null && attachPlusIdSet.size() > 0){
                cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: attachPlusIdSet];
            }
            
            Set<Id> conDocs = new Set<Id>();
            if(cdl != null && cdl.size() > 0){
                for(ContentDocumentLink cdlObj : cdl){
                    conDocs.add(cdlObj.ContentDocumentId);
                }
            }
            
            if(conDocs != null && conDocs.size() > 0){
                for(Id contObj : conDocs){
                    String downloadURL = String.valueOf(system.URL.getSalesforceBaseUrl().toExternalForm()) + '/sfc/servlet.shepherd/document/download/' +contObj;
                    System.debug('downloadURL ::: '+downloadURL);
                    downloadUrlList.add(downloadURL);
                }
            }
        }
        
        return downloadUrlList;
        
        
    }
    //move SharePoint File
    @future(callout=true)
    public static void moveFileOnSharePoint(String jsonDta){
        String moveJson = '{"caseNumber":"Test","file":{"newPath":"attachmentFoldernew","sharePointDocumentId":"01FWPR3IE24H744REPHFAIO6CO3L6FRUKQ","fileExtension":"pdf","fileName":"aksTest"}}';
        Blob myBlob = Blob.valueOf(moveJson);
        Integer contentSize = myBlob.size();
        Http http = new Http();
        HttpRequest moveRequest = new HttpRequest();
        moveRequest.setMethod('PUT');
        moveRequest.setHeader('Accept', '*/*');
        moveRequest.setEndpoint('callout:SharePointNamedCred/api/moveFile');
        moveRequest.setHeader('Content-Type', 'application/json');
        moveRequest.setHeader('client_id', '{!$Credential.UserName}');
        moveRequest.setHeader('client_secret', '{!$Credential.Password}');
        moveRequest.setHeader('Content-Length',String.valueOf(contentSize));
        moveRequest.setBody(jsonDta);
        If(!Test.isRunningTest()){
            HttpResponse res = http.send(moveRequest);
        }       
    }
    
    //View sharePoint File
    public static String viewSharePointFile(String aPlusId){
        String viewFileURL;
        List<Attachments_New__c> sharepointId = [SELECT Id,Share_Point_Item_Id__c FROM Attachments_New__c WHERE Id =: aPlusId];
        String jsonDataForSharePoint = '{"sharePointDocumentId":'+ '"' + sharepointId[0].Share_Point_Item_Id__c + '"' + '}';
        System.debug('jsonDataForSharePoint'+jsonDataForSharePoint);
        Http http = new Http();
        HttpRequest viewFileReq = new HttpRequest();
        viewFileReq.setMethod('POST');
        viewFileReq.setHeader('Accept', '*/*');
        viewFileReq.setEndpoint('callout:SharePointNamedCred/api/viewFile');
        viewFileReq.setHeader('Content-Type', 'application/json');
        viewFileReq.setHeader('client_id', '{!$Credential.UserName}');
        viewFileReq.setHeader('client_secret', '{!$Credential.Password}');
        viewFileReq.setBody(jsonDataForSharePoint);
        viewFileReq.setTimeout(2 * 1000);
        if(!Test.isRunningTest()){
            HttpResponse res = http.send(viewFileReq);
            Map<String,Object> response = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            System.debug('response'+response);
            viewFileURL = String.valueOf(response.get('getUrl')) ;
            
            System.debug('viewFileURL>>>'+viewFileURL);
            
        }
        return viewFileURL;
    } 
    
    
    //DownloadWrapper
    //
    public class DownloadWrapper{
        public List<Files> files {get;set;}
    }
    public class Files{
        public String sharePointDocumentId {get;set;}
    }
    
    public class FileUploadWrapper{
        public String caseId {get;set;}
        public List<FolderDataWrapper> folderData {get;set;}
    }
    public class FolderDataWrapper{
        public String folderName {get; set;}
        Map<String,String> aPlusRecords {get; set;}
    }
}