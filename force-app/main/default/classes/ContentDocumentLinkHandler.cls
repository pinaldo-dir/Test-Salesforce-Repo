/*
* class to take actions on creation of content document links
* 
* Initial goal is to count files attached to submission details (legacy attachments plus) and roll that count
* to the registration to which it belongs. 
* 
*  
* 
*/
public without sharing class ContentDocumentLinkHandler {
    
    public void onAfterInsert(list<ContentDocumentLink> newList, map<id, ContentDocumentLink> newMap){
        rollupCDL(newList, newMap);
    }
    
    public void onBeforeDelete(list<ContentDocumentLink> oldList, map<id, ContentDocumentLink> oldMap ){
        rollupCDL_Delete(oldList, oldMap);
    }
    
    
    // class methods
    
    //method to rollup cdl count to registration and to submission detail record
    public void rollupCDL(list<ContentDocumentLink> newList, map<Id, ContentDocumentLink> newMap){
        System.debug('##### Entering rollupCDL Method #####');
        
        list<License_Registration__c> regList = new list<License_Registration__c>();
        List<Attachments_Plus__c> attPlusList = new List<Attachments_Plus__c>();
        set<Id> aplusIds = new set<Id>();
        set<Id> regIds = new set<Id>();
        Map<string, License_Registration__c> regMap = new Map<string, License_Registration__c>();
        
        
        // get the prefex for the attachments plus object
        //string aPlusPrefix = objectPrefixHelper();
        
        for(ContentDocumentLink l : newList){
            Schema.SObjectType sObjectType = l.LinkedEntityId.getSObjectType();
            if(sObjectType == Attachments_Plus__c.SObjectType){
                system.debug('##### file is on AttachmentsPlus');
                aplusIds.add(l.LinkedEntityId);
            }
        }
        
        if(aplusIds.size() > 0){
            for(Attachments_Plus__c  aPlus : [Select ID, Registration__c FROM Attachments_Plus__c WHERE ID in :aplusIds]){
                regIds.add(aPlus.Registration__c);
            }
            if(!regIds.contains(null)){
                Set<Id> attPlusSet = new Set<Id>();
                for(Attachments_Plus__c aPlus : [select id, Number_of_Attachments__c, Attachment_Required__c, (select id from ContentDocumentLinks) from Attachments_Plus__c WHERE Registration__c in :regIds]){
                    system.debug('aPlus***'+aPlus);
                    if(aPlus.ContentDocumentLinks != null && aPlus.ContentDocumentLinks.size() > 0){
                        aPlus.Number_of_Attachments__c = aPlus.ContentDocumentLinks.size();
                        if(aPlus.Attachment_Required__c){
                            attPlusSet.add(aPlus.id);
                        }
                    }else{
                        aPlus.Number_of_Attachments__c = 0;
                    }
                    attPlusList.add(aPlus);
                }
                system.debug('attPlusList****'+attPlusList);
                update attPlusList;
                for(License_Registration__c reg : [Select Id, Number_of_Attachments__c, Number_of_Attachments_Required__c,
                                                   (select id from Submission_Detail__r WHERE Attachment_Required__c = true)
                                                   from License_Registration__c WHERE Id IN :regIds]){
                                                       if(reg.Submission_Detail__r != null && reg.Submission_Detail__r.size() > 0){
                                                           reg.Number_of_Attachments_Required__c = reg.Submission_Detail__r.size();
                                                           
                                                           Integer count = 0;
                                                           for(Attachments_Plus__c aPlus : reg.Submission_Detail__r){
                                                               if(attPlusSet.contains(aPlus.id)){
                                                                   count = count + 1;
                                                               }
                                                               
                                                           }
                                                           reg.Number_of_Attachments__c = count;
                                                       }else{
                                                           reg.Number_of_Attachments_Required__c = 0;
                                                       }
                                                       regList.add(reg);
                                                   }
                if(regList.size() > 0){
                    update regList;
                }
            }
        }
    }
    
    
    public void rollupCDL_Delete(list<ContentDocumentLink> newList, map<Id, ContentDocumentLink> newMap){
        System.debug('##### Entering rollupCDL_Delete Method #####');
        
        list<License_Registration__c> regList = new list<License_Registration__c>();
        List<Attachments_Plus__c> attPlusList = new List<Attachments_Plus__c>();
        set<Id> aplusIds = new set<Id>();
        set<Id> regIds = new set<Id>();
        
        
        // get the prefex for the attachments plus object
        //string aPlusPrefix = objectPrefixHelper();
        
        for(ContentDocumentLink l : newList){
            Schema.SObjectType sObjectType = l.LinkedEntityId.getSObjectType();
            if(sObjectType == Attachments_Plus__c.SObjectType){
                system.debug('##### file is on AttachmentsPlus');
                aplusIds.add(l.LinkedEntityId);
            }
        }
        
        if(aplusIds.size() > 0){
            for(Attachments_Plus__c  aPlus : [Select ID, Registration__c FROM Attachments_Plus__c WHERE ID in :aplusIds]){
                regIds.add(aPlus.Registration__c);
            }
            
            Set<Id> attPlusSet = new Set<Id>();
            if(!regIds.contains(null)){
                for(Attachments_Plus__c aPlus : [select id, Attachment_Required__c, Number_of_Attachments__c, (select id from ContentDocumentLinks) from Attachments_Plus__c WHERE Registration__c in :regIds]){
                    system.debug('aPlus ***'+aPlus );
                    if(aPlus.ContentDocumentLinks != null && aPlus.ContentDocumentLinks.size() > 0){
                        system.debug('aplusIds.contains(aPlus.id)******'+aplusIds.contains(aPlus.id));
                        if(aplusIds.contains(aPlus.id)){
                            aPlus.Number_of_Attachments__c = aPlus.ContentDocumentLinks.size() - 1;
                            system.debug('inside if***'+aPlus.Number_of_Attachments__c);
                        }else{
                            aPlus.Number_of_Attachments__c = aPlus.ContentDocumentLinks.size();
                            system.debug('inside else****'+aPlus.Number_of_Attachments__c);
                            if(aPlus.Attachment_Required__c){
                                attPlusSet.add(aPlus.id);
                            }
                        }
                    }else{
                        aPlus.Number_of_Attachments__c = 0;
                    }
                    system.debug('attPlusList****'+attPlusList);
                    attPlusList.add(aPlus);
                }
                
                update attPlusList;
                for(License_Registration__c reg : [Select Id, Number_of_Attachments__c, Number_of_Attachments_Required__c,
                                                   (select id from Submission_Detail__r WHERE Attachment_Required__c = true)
                                                   from License_Registration__c WHERE Id IN :regIds]){
                                                       if(reg.Submission_Detail__r != null && reg.Submission_Detail__r.size() > 0){
                                                           reg.Number_of_Attachments_Required__c = reg.Submission_Detail__r.size();
                                                           
                                                           Integer count = 0;
                                                           for(Attachments_Plus__c aPlus : reg.Submission_Detail__r){
                                                               if(attPlusSet.contains(aPlus.id)){
                                                                   count = count + 1;
                                                               }
                                                           }
                                                           reg.Number_of_Attachments__c = count;
                                                       }else{
                                                           reg.Number_of_Attachments_Required__c = 0;
                                                       }
                                                       regList.add(reg);
                                                   }
                if(regList.size() > 0){
                    update regList;
                }
            }
        }
    }
    
    /*
// private, helper methods
private string objectPrefixHelper(){
// get keyPrefix for sumbmission details
Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
system.debug('##### m is==>'+m);
Schema.SObjectType s = m.get('Attachments_Plus__c') ;
system.debug('##### Sobject Type is ==>'+s);
Schema.DescribeSObjectResult r = s.getDescribe() ;
String keyPrefix = r.getKeyPrefix();
system.debug('#### keyPrefix: ' + keyPrefix);
return keyPrefix;
}

*/
    
    public void broadcastReg_attachment_counter(List<ContentDocumentLink> cdlList, String dmlAction){
        List<Reg_attachment_counter__e> cdlEvents = new List<Reg_attachment_counter__e>();
        for(ContentDocumentLink cdl : cdlList){
            cdlEvents.add(new Reg_attachment_counter__e(CDL_Id__c = cdl.id, Linked_Entity_ID__c = cdl.LinkedEntityId, Action__c = dmlAction));
        }
        
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(cdlEvents);
        // Inspect publishing result for each event
        for(Database.SaveResult sr : results){
            if(sr.isSuccess()){
                System.debug('Successfully published event.');
            }else{
                for(Database.Error err : sr.getErrors()){
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }
    }
    
    //SharePoint Test 
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
                OWCSharepointAPIService.uploadDataOnMule(fileInfo);
            }
        }
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