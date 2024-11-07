public class OWCNintexAttachmentsConversion {
    
    public static void convertAttachmentsintoFiles(List<Attachment> newAttachments){
        List<ContentVersion> newContentDocuments = new List<ContentVersion>();
        Map<Id,Attachment> conVersionIdWithAttachment = new Map<Id,Attachment>();
        Map<Id,ContentVersion> attachmentIdWithConVersion = new Map<Id,ContentVersion>();
        Set<Id> parentCaseIds = new Set<Id>();
        for(Attachment newAttachment : newAttachments){
            parentCaseIds.add(newAttachment.ParentId);
        }
        Map<Id, DIR_Case__c> caseManagements = new Map<Id, DIR_Case__c>([SELECT Id, e_Sign_Documents__c FROM DIR_Case__c WHERE Id IN :parentCaseIds ]);
        if(!caseManagements.isEmpty() ){
            for(Attachment newAttachment : newAttachments){
                String nintexDocuments = Label.OWC_nintex_Documents ;	//caseManagements.get(newAttachment.ParentId).e_Sign_Documents__c;
                String attachDocument = String.valueOf(newAttachment.Name).split('\\.').get(0);
                system.debug('nintexDocuments: '+nintexDocuments);
                system.debug('attachDocument: '+attachDocument);
                if(nintexDocuments.containsIgnoreCase(attachDocument)){
                    ContentVersion cVersion = new ContentVersion();
                    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce.
                    cVersion.PathOnClient = newAttachment.Name;//File name with extention
                    //cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                    cVersion.OwnerId = newAttachment.OwnerId;//Owner of the file
                    cVersion.Title = newAttachment.Name;//Name of the file
                    cVersion.VersionData = newAttachment.Body;//File content
                    attachmentIdWithConVersion.put(newAttachment.Id, cVersion);
                    newContentDocuments.add(cVersion);
                }
            }
            if(!newContentDocuments.isEmpty()){
                try{
                    insert newContentDocuments;
                }catch(DMLException dmlExp){
                    System.debug('Following Exception has been occurred : '+ dmlExp.getDmlMessage(0));
                }
                
                for(Attachment attachment : newAttachments){
                    conVersionIdWithAttachment.put(attachmentIdWithConVersion.get(attachment.Id).Id , attachment);
                }
                List<ContentDocumentLink> conDocumentLinks = new List<ContentDocumentLink>{};
                    for(ContentVersion newConVer : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :newContentDocuments]){
                        System.debug('newConVer.ContentDocumentId '+ newConVer.ContentDocumentId);
                        ContentDocumentLink linkDocWithCaseMgmt = new ContentDocumentLink();
                        linkDocWithCaseMgmt.LinkedEntityId = conVersionIdWithAttachment.get(newConVer.Id).ParentId;
                        linkDocWithCaseMgmt.ContentDocumentId = newConVer.ContentDocumentId;
                        conDocumentLinks.add(linkDocWithCaseMgmt);
                    }
                List<Attachment> attachmentToDelete = [SELECT Id FROM Attachment WHERE Id IN :conVersionIdWithAttachment.values()];
                try{
                    insert conDocumentLinks;
                    delete attachmentToDelete;
                }catch(DMLException dmlExp){
                    System.debug('Following Exception has been occurred : '+ dmlExp.getDmlMessage(0));
                }
            }
        }
    }
    /*
    public static void convertAttachmentsintoFilesTest(List<Attachment> newAttachments){
        
        List<ContentVersion> newContentDocuments = new List<ContentVersion>();
        Map<Id,Attachment> conVersionIdWithAttachment = new Map<Id,Attachment>();
        Map<Id,ContentVersion> attachmentIdWithConVersion = new Map<Id,ContentVersion>();
        //Map<Id,Id> attachmentIdCaseMgmtId = new Map<Id,Id>();
        Set<Id> parentCaseIds = new Set<Id>();
        for(Attachment newAttachment : newAttachments){
            parentCaseIds.add(newAttachment.ParentId);
        }
        system.debug('parentCaseIds: '+parentCaseIds);
        Map<Id, DIR_Case__c> caseManagements = new Map<Id, DIR_Case__c>([SELECT Id, e_Sign_Documents__c FROM DIR_Case__c WHERE Id IN :parentCaseIds ]);
        if(!caseManagements.isEmpty() ){
            for(Attachment newAttachment : newAttachments){
                String nintexDocuments = Label.OWC_nintex_Documents ;//'SETTLEMENT- WCA 026A,SETTLEMENT- WCA 026B,SETTLEMENT- WCA 026C,DIRCase- 633 055,WCA 055 - Complaint,RELEASE- WCA 023';
                    //caseManagements.get(newAttachment.ParentId).e_Sign_Documents__c;
                String attachDocument = String.valueOf(newAttachment.Name).split('\\.').get(0);
                system.debug('nintexDocuments: '+nintexDocuments);
                system.debug('attachDocument: '+attachDocument);
                if(nintexDocuments.containsIgnoreCase(attachDocument)){
                    ContentVersion cVersion = new ContentVersion();
                    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce.
                    cVersion.PathOnClient = newAttachment.Name;//File name with extention
                    //cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                    cVersion.OwnerId = newAttachment.OwnerId;//Owner of the file 
                    cVersion.Title = newAttachment.Name;//Name of the file
                    cVersion.VersionData = newAttachment.Body;//File content
                    attachmentIdWithConVersion.put(newAttachment.Id, cVersion);
                    //attachmentIdCaseMgmtId.put(newAttachment.Id, newAttachment.ParentId);
                    newContentDocuments.add(cVersion);
                }
            }
            if(!newContentDocuments.isEmpty()){
                try{
                    insert newContentDocuments;
                }catch(DMLException dmlExp){
                    System.debug('Following Exception has been occurred : '+ dmlExp.getDmlMessage(0));
                }
                
                for(Attachment attachment : newAttachments){
                    conVersionIdWithAttachment.put(attachmentIdWithConVersion.get(attachment.Id).Id , attachment);
                }
                system.debug('conVersionIdWithAttachment: '+conVersionIdWithAttachment);
                List<ContentDocumentLink> conDocumentLinks = new List<ContentDocumentLink>{};
                    for(ContentVersion newConVer : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :newContentDocuments]){
                        System.debug('newConVer.ContentDocumentId '+ newConVer.ContentDocumentId);
                        ContentDocumentLink linkDocWithCaseMgmt = new ContentDocumentLink();
                        linkDocWithCaseMgmt.LinkedEntityId = conVersionIdWithAttachment.get(newConVer.Id).ParentId;
                        linkDocWithCaseMgmt.ContentDocumentId = newConVer.ContentDocumentId;
                        conDocumentLinks.add(linkDocWithCaseMgmt);
                        system.debug('conVersionIdWithAttachment.get(newConVer.Id).ParentId: '+conVersionIdWithAttachment.get(newConVer.Id).ParentId);
                    }
                List<Attachment> attachmentToDelete = [SELECT Id FROM Attachment WHERE Id IN :conVersionIdWithAttachment.values()];
                try{
                    insert conDocumentLinks;
                    //delete attachmentToDelete;
                }catch(DMLException dmlExp){
                    System.debug('Following Exception has been occurred : '+ dmlExp.getDmlMessage(0));
                }
            }
        }
    }
    */
}