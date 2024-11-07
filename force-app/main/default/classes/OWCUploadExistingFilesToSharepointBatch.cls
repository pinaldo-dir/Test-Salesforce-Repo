public class OWCUploadExistingFilesToSharepointBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public DateTime formattedFromDate; //'01/01/2021'
    public DateTime formattedToDate; //'01/01/2021'
    public static String errorMsg ;
    Integer recordCount = 0;
    List<String> caseIds = new List<String>();
    public OWCUploadExistingFilesToSharepointBatch(String fromDate, String toDate){
        Date fromDates = !Test.isRunningTest() ? Date.parse(fromDate) : System.today().addDays(-1);
        Date toDates = !Test.isRunningTest() ? Date.parse(toDate) : System.today().addDays(1);
        formattedFromDate = datetime.newInstance(fromDates.year(), fromDates.month(),fromDates.day());
        formattedToDate = datetime.newInstance(toDates.year(), toDates.month(),toDates.day());
    }  
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        //String query= 'SELECT Id,Name, File_Type__c, Related_Id__c FROM Attachments_New__c WHERE CreatedDate >= 2020-01-01T00:00:00Z AND CreatedDate <= 2020-12-31T00:00:00Z AND  Release_to_Public__c = false AND Related_Id__c LIKE \'a1Bd00000063vqWEAQ%\' AND Share_Point_Item_Id__c = null AND Case_Management__r.RecordType.name != \'PAGA Case\'  order by Related_Id__c limit 1000';
        String query= 'SELECT Id, Name, File_Type__c, Related_Id__c FROM Attachments_New__c';
        query += ' WHERE CreatedDate >=: formattedFromDate AND CreatedDate <=: formattedToDate';
        query += ' AND Release_to_Public__c = false';
        query += ' AND Share_Point_Item_Id__c = null AND Related_Id__c LIKE \'a1B%\' order by Related_Id__c ';
		
        return Database.getQueryLocator(query); 
    }
    
    public void execute(Database.BatchableContext bc, List<Attachments_New__c> attachPlusRecords){
        List<Attachments_New__c> updateAPlusList = new List<Attachments_New__c>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        Set<Id> attachIds = new Set<Id>();
        Map<Id,Attachments_New__c> aPlusMap = new Map<Id,Attachments_New__c>();
        for(Attachments_New__c attObj : attachPlusRecords){
            //attachIds.add(attObj.Id);
            aPlusMap.put(attObj.Id, attObj);
        }
        
        if(aPlusMap.keySet().size() > 0){
            cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: aPlusMap.keySet()];
        }
        
        if(cdlList.size() > 0){
            Map<String,String> aplusWithCDLMap = new  Map<String,String>();
            Map<Id,Id> aPlusAndContIds = new Map<Id,Id>();
            List<Attachments_New__c> aPlusData = new List<Attachments_New__c>();
            for(ContentDocumentLink cdl: cdlList){
                aplusWithCDLMap.put(cdl.LinkedEntityId, cdl.Id);
                aPlusAndContIds.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                aPlusData.add(aPlusMap.get(cdl.LinkedEntityId));
            }
            uploadFilesOnSharePoint(aplusWithCDLMap, aPlusAndContIds, aPlusData, updateAPlusList);
        }
        //update the Aplus when the required fields are missing.
        if(updateAPlusList.size() >0){
            Database.update( updateAPlusList);
        }
        if(String.isNotBlank(errorMsg)){
            Online_Claim_Error_Log__c logger = new Online_Claim_Error_Log__c();
            logger.Error_Stack_Trace__c = 'SharePoint File Upload error.';
            logger.Class_Name__c = 'OWCUploadExistingFilesToSharepointBatch';
            logger.Line_number__c = 197; 
            //lets check the message length
            if(errorMsg.length() > 32768){
                logger.Error_Message__c  = errorMsg.mid(errorMsg.length() - 32768, 32760); //get the text upto 32760 char from the end
            } else {
                logger.Error_Message__c  = errorMsg; 
            }
        	 
        	Database.SaveResult srList = Database.insert(logger, false);
        }
    }
    
    public void finish(Database.BatchableContext bc){
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
    
    public static void uploadFilesOnSharePoint(Map<String,String> aplusWithCDLMap, Map<Id,Id> aPlusAndContIds, List<Attachments_New__c> aPlusData, List<Attachments_New__c> updateAPlusList ){
        
        Map<Id,List<Attachments_New__c>> caseWithAplusMap = new Map<Id,List<Attachments_New__c>>();
        for(Attachments_New__c attachDta:  aPlusData){
            if(caseWithAplusMap.containsKey(attachDta.Related_Id__c)){
                caseWithAplusMap.get(attachDta.Related_Id__c).add(attachDta);
            } else{
                caseWithAplusMap.put(attachDta.Related_Id__c, new List<Attachments_New__c>{attachDta});
            }
        }
        for(String caseId: caseWithAplusMap.keySet()){
            Map<Id,String> folderInfoMap = new  Map<Id,String>(); //containFolderInformation
            Map<Id,String> caseNumberMap = new Map<Id,String>(); //conatainCaseNumber
            Map<String, Set<String>> binWithFilesNameMap = new Map<String, Set<String>>(); 
            for(Attachments_New__c attachDta:  caseWithAplusMap.get(caseId)){
                if(String.isNotBlank(aPlusAndContIds.get(attachDta.Id)) && String.isNotBlank(attachDta.File_Type__c) 
                   && String.isNotBlank(attachDta.Name)){
                       folderInfoMap.put(aPlusAndContIds.get(attachDta.Id), attachDta.File_Type__c);
                       //caseId = attachDta.Related_Id__c;
                       caseNumberMap.put(aPlusAndContIds.get(attachDta.Id), attachDta.Id);
                   }
                
            } 
            System.debug('caseId'+caseId);
            //return if case not found
            if(String.isBlank(caseId)){
                return;
            }
            List<DIR_Case__c> caseName = [SELECT Id, Name,RecordType.name FROM DIR_Case__c WHERE Id =: caseId];
            
            //check if the case is deleted
            if(!caseName.isEmpty() && caseName.size() >0){
                List<ContentVersion> ContentVersionList = [SELECT Id, Title, Description, ContentSize,ContentDocumentId, FileExtension, FileType,PathOnClient FROM ContentVersion 
                                                           WHERE ContentDocumentId IN : folderInfoMap.keySet() ];
                
                //Make a Data to send on Mule Soft
                
                DataWrapperClass totalDta = new DataWrapperClass();
                //totalDta.caseNumber = caseId;
                List<File> fileInfoList = new List<File>();
                //use for if duplicate file exist in same bin
                Integer i =0;
                for(ContentVersion cv : ContentVersionList){
                    if(cv.Description != 'Third Party'){
                        Boolean isValid = true;
                        if(String.isNotBlank(folderInfoMap.get(cv.ContentDocumentId))){
                            totalDta.caseNumber = (caseName != null && caseName.size() > 0) ? caseName[0].Name : '';
                            File fileInfoObj = new File();
                            fileInfoObj.attachmentFolder = folderInfoMap.get(cv.ContentDocumentId);
                            fileInfoObj.aplusId = caseNumberMap.get(cv.ContentDocumentId);
                            fileInfoObj.contentDocumentId = cv.Id;
                            fileInfoObj.description = 'Description' ;
                            
                            Attachments_New__c aPlus = new Attachments_New__c(Id =fileInfoObj.aplusId);  
                            //Add the extention in the File Name	
                            if(String.isBlank(cv.FileExtension)){
                                if(String.isNotBlank(cv.PathOnClient.substringAfterLast('.'))){
                                    fileInfoObj.fileExtension =  cv.PathOnClient.substringAfterLast('.');
                                }
                                else if(String.isNotBlank(cv.Title.substringAfterLast('.'))) {
                                    fileInfoObj.fileExtension =  cv.Title.substringAfterLast('.');
                                }
                                
                            }
                            else{
                                fileInfoObj.fileExtension = cv.FileExtension;
                            }
                            //remove the extention from the File Name
                            if(String.isNotBlank(cv.Title) && String.isNotBlank(cv.Title.substringAfterLast('.'))){
                                fileInfoObj.fileName = cv.Title.removeEnd('.' + cv.Title.substringAfterLast('.')); 
                            }
                            else{
                                fileInfoObj.fileName = cv.Title;
                            }
                            if(binWithFilesNameMap.containsKey(fileInfoObj.attachmentFolder)){
                                if(binWithFilesNameMap.get(fileInfoObj.attachmentFolder).contains(fileInfoObj.fileName)){
                                    fileInfoObj.fileName = fileInfoObj.fileName+i;
                                    i++;
                                } else{
                                    binWithFilesNameMap.get(fileInfoObj.attachmentFolder).add(fileInfoObj.fileName);
                                }
                            } else {
                                binWithFilesNameMap.put(fileInfoObj.attachmentFolder, new Set<String>{fileInfoObj.fileName});
                            }
                            if(String.isNotBlank(fileInfoObj.fileName)){
                               fileInfoObj.fileName = EncodingUtil.urlEncode(fileInfoObj.fileName, 'UTF-8').replace('+', '%20'); 
                            } else{
                                isValid = false;
                                aPlus.Sharepoint_File_Upload_Error__c = 'File Name is missing.';
                               
                            }
                            
                            //fileInfoObj.fileExtension = cv.FileExtension;
                            //fileInfoObj.fileName = cv.Title;
                            if(String.isBlank(fileInfoObj.fileExtension)){
                                isValid = false;
                                aPlus.Sharepoint_File_Upload_Error__c = 'File Extension is missing.';
                            } 
                            if(String.isBlank(fileInfoObj.contentDocumentId)){
                                isValid = false;
                                aPlus.Sharepoint_File_Upload_Error__c = 'Salesforce File is missing.';
                            }
                            if(isValid){
                                fileInfoList.add(fileInfoObj);
                            } else {
                                updateAPlusList.add(aPlus); 
                            }
                        }
                    }
                }
                totalDta.files = fileInfoList;
                
                if(String.isNotBlank(totalDta.caseNumber)){
                    if(fileInfoList.size() > 0){
                        String fileInfo = JSON.serialize(totalDta);
                        //Send required Json data to MuleSoft 
                        if(caseName[0].RecordType.name != 'PAGA Case'){
                            OWCSharepointAPIService.uploadSalesforceFileOnMule(fileInfo);
                        }
                    }
                }
            }
            
        }
        
    }
}