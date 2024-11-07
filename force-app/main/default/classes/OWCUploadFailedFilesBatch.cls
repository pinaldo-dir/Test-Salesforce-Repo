global class OWCUploadFailedFilesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String error = 'Error';
    public Date dates;
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Share_Point_Item_Id__c,Sharepoint_File_Status__c,File_Name__c,File_Type__c,Related_Id__c FROM Attachments_New__c WHERE Share_Point_Item_Id__c = null AND Sharepoint_File_Status__c   = '+ '\'' + error+ '\'' ;
        
        
        System.debug('>>??'+Database.query(query) );
        return Database.getQueryLocator(query); 
    } 
    global void execute(Database.BatchableContext BC, List<Attachments_New__c> attachPlusRecords){
        Map<Id,List<Attachments_New__c>> attachMap = new Map<Id,List<Attachments_New__c>>(); //Map of CaseIds and Attachement plus records
        Map<Id,Id> mapAttachAndContDocIds = new Map<Id,Id>();// Map of AttachmentPlusRecord and ContentDocumentIds
        Map<Id,Id> mapConDocAndAttachIds = new Map<Id,Id>(); //Map of ContentDocumentIds and  AttachmentPlusRecord 
        Map<Id,ContentDocument> contDocWithLinkedIdMap  = new Map<Id,ContentDocument>();
        //get the File Extansion
        Map<Id,String> conDocAndFileExtansion = new Map<Id,String>();
        Set<Id> attachPlusIds = new Set<Id>();//Ids of Attachment Id
        
        for(Attachments_New__c  attachObj : attachPlusRecords){
            attachPlusIds.add(attachObj.Id);
            if(attachMap.containsKey(Id.valueOf(attachObj.Related_Id__c))){
                List<Attachments_New__c> attatchList = attachMap.get(Id.valueOf(attachObj.Related_Id__c));
                attatchList.add(attachObj);
                attachMap.put(attachObj.Related_Id__c,attatchList);
            }
            else{
                attachMap.put(attachObj.Related_Id__c,new List<Attachments_New__c>{attachObj});
            } 
        }
        List<ContentDocumentLink> contentDocumentLinkObj = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : attachPlusIds];
        for(ContentDocumentLink conDocLinkObj : contentDocumentLinkObj){
            mapAttachAndContDocIds.put( conDocLinkObj.LinkedEntityId, conDocLinkObj.ContentDocumentId); //putting  attachment Id  and containDoc ID
            mapConDocAndAttachIds.put (conDocLinkObj.ContentDocumentId,conDocLinkObj.LinkedEntityId);
        }
        List<ContentDocument> contentDocumentList = [SELECT Id, Title, Description, FileType, FileExtension FROM ContentDocument WHERE Id IN : mapAttachAndContDocIds.values()];
        //set in Map conDocId and Content Document Obj
        for(ContentDocument cdObj : contentDocumentList){
            if(mapConDocAndAttachIds.keySet().contains(cdObj.Id)){
                System.debug('mapConDocAndAttachIds.get(cdObj.Id'+mapConDocAndAttachIds.get(cdObj.Id));
                contDocWithLinkedIdMap.put(mapAttachAndContDocIds.get(cdObj.Id),cdObj);
                conDocAndFileExtansion.put(mapConDocAndAttachIds.get(cdObj.Id),cdObj.FileExtension);
            }
        }
        
        //Map for CaseId with CaseName
        Map<Id,String> caseIdWithNameMap = new  Map<Id,String>();
        List<DIR_Case__c> caseMangNameList = [SELECT Id, Name FROM DIR_Case__c WHERE Id IN : attachMap.keySet()];
        for(DIR_Case__c cmObj : caseMangNameList){
            caseIdWithNameMap.put(cmObj.Id,cmObj.Name);
        }
        //Wrapper Class
        DataWrapperClass dataWrapperObj = new DataWrapperClass();
        for(Id attachCaseIdObj : attachMap.keySet()){
            dataWrapperObj.caseNumber = caseIdWithNameMap.get(attachCaseIdObj);
            List<File> fileObjList = new List<File>();
            for(Attachments_New__c attachObj : attachMap.get(attachCaseIdObj)){
                File fileObj = new File();   
                fileObj.attachmentFolder = attachObj.File_Type__c;
                fileObj.aplusId = attachObj.Id;
                fileObj.fileExtension = conDocAndFileExtansion.get(attachObj.Id);
                fileObj.contentDocumentId = String.valueOf(mapAttachAndContDocIds.get(attachObj.Id));
                fileObj.fileName = attachObj.File_Name__c;
                fileObjList.add(fileObj);
            }
            dataWrapperObj.files = fileObjList;
        }
        //Upload File On Mule
        if(dataWrapperObj != null){
        OWCSharepointAPIService.uploadFaildFileOnMule(JSON.serialize(dataWrapperObj));
        }
    }
    global void finish(Database.BatchableContext BC){
        System.debug('finish');
    }
    
    
    //Wrapper Class for Creating JSON for MuleSoft
    public class DataWrapperClass{
        public String caseNumber {get;set;}
        public List<File> files {get;set;}
    }
    public class File{
        public String attachmentFolder {get;set;}
        public String aplusId {get;set;}
        public String contentDocumentId {get;set;}
        public String description {get;set;}
        public String fileExtension {get;set;}
        public String fileName {get;set;} 
    }
}