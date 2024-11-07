global class OWCUploadValidExtensionDocBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public DateTime formattedFromDate; //'2022-08-12';
    public DateTime formattedToDate; //'2022-07-11';
    
    global OWCUploadValidExtensionDocBatch(DateTime fromDate, DateTime toDate){
        formattedFromDate = fromDate;
        formattedToDate = toDate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query= 'SELECT Id, CreatedDate, LastModifiedDate, Release_to_Public__c, Share_Point_Item_Id__c, Case_Management__c, Sharepoint_File_Status__c, File_Name__c, File_Type__c, Related_Id__c FROM Attachments_New__c';
        query += ' WHERE CreatedDate >=: formattedFromDate AND CreatedDate <=: formattedToDate';
        query += ' AND Release_to_Public__c = false';
        query += ' AND Share_Point_Item_Id__c = null';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Attachments_New__c> attachPlusRecords){
        List<ContentDocumentLink> cdlList;
        Set<Id> attachIds = new Set<Id>();
        for(Attachments_New__c attObj : attachPlusRecords){
            attachIds.add(attObj.Id);
        }
        
        if(attachIds.size() > 0){
            cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: attachIds];
        }
        
        if(cdlList.size() > 0){
            uploadFilesOnSharePoint(cdlList);
        }
    }
    
    global void finish(Database.BatchableContext bc){
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
    
    public static void uploadFilesOnSharePoint(List<ContentDocumentLink> newFiles){
        
        System.debug('newFiles in sharepoint ::: '+newFiles); 
        Map<Id,Id> aPlusAndContIds = new Map<Id,Id>();
        if(newFiles.size()>0){
            for(ContentDocumentLink newFile : newFiles){
                System.debug('newFile.LinkedEntityId'+newFile.LinkedEntityId.getSObjectType().getDescribe().getName());
                if(String.isNotBlank(newFile.LinkedEntityId) && String.isNotBlank(newFile.ContentDocumentId) && newFile.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Attachments_New__c') {
                    
                    aPlusAndContIds.put(newFile.LinkedEntityId,newFile.ContentDocumentId);
                }
            }
        }
        System.debug('aPlusAndContIds ::::'+aPlusAndContIds);
        
        Map<Id,String> folderInfoMap = new  Map<Id,String>(); //containFolderInformation
        Map<Id,String> caseNumberMap = new Map<Id,String>(); //conatainCaseNumber
        List<Attachments_New__c> aPlusData = [SELECT Id,Name,File_Type__c,Related_Id__c FROM Attachments_New__c 
                                              WHERE ID IN : aPlusAndContIds.keySet() AND Release_to_Public__c = false Order By CreatedDate desc];
        
        String caseId ;
        for(Attachments_New__c attachDta:  aPlusData){
            if(String.isNotBlank(aPlusAndContIds.get(attachDta.Id)) && String.isNotBlank(attachDta.File_Type__c) 
               && String.isNotBlank(attachDta.Name)){
                   folderInfoMap.put(aPlusAndContIds.get(attachDta.Id), attachDta.File_Type__c);
                   caseId = attachDta.Related_Id__c;
                   caseNumberMap.put(aPlusAndContIds.get(attachDta.Id), attachDta.Id);
               }
            
        } 
        System.debug('caseId'+caseId);
        //return if case not found
        if(String.isBlank(caseId)){
            return;
        }
        List<DIR_Case__c> caseName = [SELECT Id, Name FROM DIR_Case__c WHERE Id =: caseId];
        System.debug('caseNumberMap :::::'+caseNumberMap);
        System.debug('folderInfoMap :::::'+folderInfoMap);
        
        List<ContentVersion> ContentVersionList = [SELECT Id, Title, Description, ContentSize,VersionData,ContentDocumentId, FileExtension, FileType FROM ContentVersion 
                                                   WHERE ContentDocumentId IN : aPlusAndContIds.values() ];
        
        //Make a Data to send on Mule Soft
        
        DataWrapperClass totalDta = new DataWrapperClass();
        //totalDta.caseNumber = caseId;
        List<File> fileInfoList = new List<File>();
        for(ContentVersion cv : ContentVersionList){
            if(cv.Description != 'Third Party'){
                totalDta.caseNumber = (caseName != null && caseName.size() > 0) ? caseName[0].Name : '';
                File fileInfoObj = new File();
                fileInfoObj.attachmentFolder = folderInfoMap.get(cv.ContentDocumentId);
                fileInfoObj.aplusId = caseNumberMap.get(cv.ContentDocumentId);
                fileInfoObj.contentDocumentId = cv.Id;
                fileInfoObj.description = 'Description' ;
                fileInfoObj.fileExtension = cv.FileExtension;
                fileInfoObj.fileName = cv.Title;
                fileInfoList.add(fileInfoObj);
            }
        }
        totalDta.files = fileInfoList;
        
        if(String.isNotBlank(totalDta.caseNumber)){
            String fileInfo = JSON.serialize(totalDta);
            System.debug('fileInfo'+fileInfo);
            System.debug('totalDta>>'+totalDta);
            //Send required Json data to MuleSoft 
            DIR_Case__c pagaCase = [SELECT Id, RecordtypeId, RecordType.name FROM DIR_Case__c where Id =:caseId];
            if(pagaCase.RecordType.name != 'PAGA Case'){
                System.debug('fileInfo'+fileInfo);
                OWCSharepointAPIService.uploadSalesforceFileOnMule(fileInfo);
            }
        }
    }
}