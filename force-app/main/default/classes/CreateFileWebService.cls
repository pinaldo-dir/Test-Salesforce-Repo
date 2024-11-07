/*
* Name: CreateFileWebService
* Description: Used to create the public link for all documents those are uploaded from third party system.
* Primary Record: Content Document
* Related Records: Content Document Link, Content Version, Content Distribution
*/ 
@RestResource(urlMapping='/CreateFile/*')
global class CreateFileWebService {
    public static Boolean stopTriggerFromCreateFileWebService = false;
    private static String aPlusId;
    private static String name;
    private static String jsonString;
    private static String message;
    private static String fileExtension;
    private static String caseId;
    private static OWCThirdPartyModel.createFileResponseWrapper createFileWrapObj;
    
    @HttpPost
    global static void uploadDocument()
    {	
        createFileWrapObj = new OWCThirdPartyModel.createFileResponseWrapper();
        RestRequest responseObj = RestContext.request;
        String requestBody = responseObj.requestBody.toString();
        try
        {
            if(String.isNotBlank(requestBody)){
                //Deserialize the third party response
                Map<String, Object> responseWrapper = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
                aPlusId = (String) responseWrapper.get('aPlusId');
                name = (String) responseWrapper.get('name');
                jsonString = (String) responseWrapper.get('versionData');
                if(((String) responseWrapper.get('fileExtension')).equalsIgnoreCase( '.WORD' )){
                    fileExtension = '.docx';
                }
                else if(((String) responseWrapper.get('fileExtension')).equalsIgnoreCase( '.WORD_X' )){
                    fileExtension = '.docx';
                }
                else if(((String) responseWrapper.get('fileExtension')).equalsIgnoreCase( '.EXCEL' )){
                    fileExtension = '.xlsx';
                }
                else if(((String) responseWrapper.get('fileExtension')).equalsIgnoreCase( '.EXCEL_X' )){
                    fileExtension = '.xlsx';
                }
                else{
                    fileExtension = (String) responseWrapper.get('fileExtension');
                }
                
                if(String.isBlank(aPlusId)){
                    createFileWrapObj.isSuccess = false;
                    createFileWrapObj.message = ThirdPartyErrorMsgConstants.ATTACHMENT_ID_MISSING_ERROR_MSG;
                }
                else if(String.isBlank(name)){
                    createFileWrapObj.isSuccess = false;
                    createFileWrapObj.message = ThirdPartyErrorMsgConstants.FILE_NAME_MISSING_ERROR_MSG;
                }
                else if(String.isBlank(jsonString)){
                    createFileWrapObj.isSuccess = false;
                    createFileWrapObj.message = ThirdPartyErrorMsgConstants.VERSION_DATA_MISSING_ERROR_MSG;
                }
                else if(String.isNotBlank(aPlusId)){
                    List<Attachments_New__c> attachmentPlusObj = [SELECT Related_Id__c, Id FROM Attachments_New__c WHERE ID =: aPlusId];
                    if(attachmentPlusObj != null && attachmentPlusObj.size() > 0){
                        createFileRecords();
                    }
                    else{
                        createFileWrapObj.isSuccess = false;
                        createFileWrapObj.message = ThirdPartyErrorMsgConstants.contentDataErrorMsg(aPlusId);
                    }
                }
            }
            if(!Test.isRunningTest()){
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(createFileWrapObj));
            }
        }
        catch(Exception ex){
            System.debug('exception ::: '+ex.getLineNumber());
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(createFileWrapObj));
        }
    }
    
    private static void createFileRecords(){
        stopTriggerFromCreateFileWebService = true;
        system.debug('In createFileRecords: '); 
        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.PathOnClient = name + fileExtension;//File name with extention
        cVersion.Title = name;//Name of the file
        cVersion.VersionData = EncodingUtil.base64Decode(jsonString);//File content
        Insert cVersion;
        
        //After saved the Content Verison, get the ContentDocumentId
        ContentVersion conVerObj = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id];
        
        //Create ContentDocumentLink record for attachment plus record
        ContentDocumentLink aPlusDocLink = new ContentDocumentLink();
        aPlusDocLink.ContentDocumentId = conVerObj.ContentDocumentId;//Add ContentDocumentId
        aPlusDocLink.LinkedEntityId = aPlusId;//Add attachment parentId
        aPlusDocLink.Visibility = 'AllUsers';
        Insert aPlusDocLink;
        
        //Create ContentDocumentLink record for case management record
        Attachments_New__c attachPlusObj = [SELECT Related_Id__c, Id FROM Attachments_New__c WHERE ID =: aPlusId LIMIT 1];
        
        if(attachPlusObj != null && String.isNotBlank(attachPlusObj.Related_Id__c)){
            caseId = attachPlusObj.Related_Id__c;
            ContentDocumentLink caseDocLink = new ContentDocumentLink();
            caseDocLink.ContentDocumentId = conVerObj.ContentDocumentId;//Add ContentDocumentId
            caseDocLink.LinkedEntityId = caseId;//Add attachment parentId
            caseDocLink.Visibility = 'AllUsers';
            Insert caseDocLink;
        }
        
        //Create content distribution record to generate public link
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Port Drayage Link';//name;
        cd.ContentVersionId = conVerObj.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
        system.debug('conVerObj.ContentDocumentId: '+conVerObj.ContentDocumentId);        
        createFileWrapObj.isSuccess = true;
        createFileWrapObj.documentId = conVerObj.ContentDocumentId;
        createFileWrapObj.message = 'Record has been successfully created.';
    }
}