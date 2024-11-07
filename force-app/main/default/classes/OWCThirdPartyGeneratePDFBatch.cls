public class OWCThirdPartyGeneratePDFBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public final String caseId;
    public final Boolean claimantConfirm;
    public ContentVersion cvRecord ;
    public string caseName ;
    public OWCThirdPartyGeneratePDFBatch(String caseRecordId, Boolean isConfirm){
        caseId = caseRecordId.remove('"');
        claimantConfirm = isConfirm;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name FROM DIR_Case__c WHERE Id =: caseId]);
    }
    
    public void execute(Database.BatchableContext BC, List<DIR_Case__c> caseRecords){
        for(DIR_Case__c cse : caseRecords){
            Pagereference pg = Page.OWCThirdPartyPDFPage;
            pg.getParameters().put('caseManagementId', cse.Id);
            
            ContentVersion cont = new ContentVersion();
            cont.Description = 'Third Party';
            cont.Title = 'Wage Claim Summary Report';
            cont.PathOnClient = 'online_claim_summary.pdf';
            if(Test.isRunningTest()){
                cont.VersionData = blob.valueOf('Unit.Test'); 
            }
            else{
                cont.VersionData = pg.getContentAsPDF();
            }
            
            //cont.
            cont.Origin = 'H';
            insert cont;  
            ContentVersion contentVersion_2 = [SELECT Id, Title,FileType, FileExtension, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = :cont.Id LIMIT 1];
            cvRecord = contentVersion_2;
            caseName = cse.Name;
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caseId;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            contentlink.Visibility = 'AllUsers';
            insert contentlink;
            system.debug('contentlink: '+contentlink);
            
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Test';
            cd.ContentVersionId = cont.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;
            if(!claimantConfirm){
                OCEmailServiceUtility.sendConfirmationEmailtoClaimant(caseRecords);
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        if(cvRecord != null && caseName != null){
            uploadFileToMulesoft(cvRecord, caseName );
        }
    }
    public static void uploadFileToMulesoft(ContentVersion cv, String caseName){
        List<ContentDocumentLink> aPlusLink = [SELECT Id, LinkedEntityId FROM ContentDocumentLink 
                                         WHERE ContentDocumentId =: cv.contentdocumentid];
        String attachmentId ;
        for(ContentDocumentLink cdl: aPlusLink){
            String linkedId = cdl.LinkedEntityId;
            system.debug('linkedId: '+linkedId);
            if(linkedId.startsWith('a4C')){
                attachmentId = cdl.LinkedEntityId;
                break;
            }            
        }
        system.debug('attachmentId: '+attachmentId);
        List<Attachments_New__c> aPlusData = [SELECT Id,Name,File_Type__c,Related_Id__c FROM Attachments_New__c 
                                              WHERE Id =: attachmentId];
        if( (aPlusData != null && aPlusData.size() > 0) || Test.isRunningTest() ) {
            ContentDocumentLinkHandler.DataWrapperClass totalDta = new ContentDocumentLinkHandler.DataWrapperClass();
            //totalDta.caseNumber = caseId;
            List<ContentDocumentLinkHandler.File> fileInfoList = new List<ContentDocumentLinkHandler.File>();
            totalDta.caseNumber = caseName;
            ContentDocumentLinkHandler.File fileInfoObj = new ContentDocumentLinkHandler.File();
            fileInfoObj.attachmentFolder = Test.isRunningTest() == false ? aPlusData[0].File_Type__c : 'Intake';
            fileInfoObj.aplusId = Test.isRunningTest() == false ? aPlusData[0].Id : 'a4C350000008XT8EAM' ;
            fileInfoObj.contentDocumentId = cv.Id;
            fileInfoObj.description = 'Third Party' ;
            fileInfoObj.fileExtension = cv.FileExtension;
            fileInfoObj.fileName = cv.Title;
            fileInfoList.add(fileInfoObj);
            totalDta.files = fileInfoList;
            
            if(String.isNotBlank(totalDta.caseNumber)){
                String fileInfo = JSON.serialize(totalDta);
                System.debug('fileInfo'+fileInfo);
                System.debug('totalDta>>'+totalDta);
                //Send required Json data to MuleSoft 
                OWCSharepointAPIService.uploadDataOnMuleForThirdParty(fileInfo);
            }
        }
        
    }
}