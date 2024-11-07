/*
* Name: OWCThirdPartyFileUploadWebService
* Description: Used to upload the claimant confirmation from the third party system.
* Primary Record: Content Document
* Related Records: Content Document Link, Content Version
*/ 
@RestResource(urlMapping='/ClaimantConfirmationAPI/*')
global class OWCThirdPartyFileUploadWebService {
    public static DIR_Case__c caseObj;
    public static String caseNumber;
    public static String communityUserId;
    public static String contenttype;
    public static String name;
    public static String jsonString;
    public static String fieldValidationError;
    public static String fileExtension;
    
    
    @HttpPost
    global static void uploadDocument()
    {   
        OWCThirdPartyModel.ClaimantConfirmUploadResponseWrapper claimantWrapObj = new OWCThirdPartyModel.ClaimantConfirmUploadResponseWrapper();
        RestRequest responseObj = RestContext.request;
        String requestBody = responseObj.requestBody.toString();
        try
        {
            if(String.isNotBlank(requestBody)){
                //Deserialize the third party response
                Map<String, Object> responseWrapper = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
                caseNumber = (String) responseWrapper.get('caseNumber');
                communityUserId = (String) responseWrapper.get('communityUserId');
                contenttype = (String) responseWrapper.get('contenttype');
                name = (String) responseWrapper.get('name');
                jsonString = (String) responseWrapper.get('versionData');
                fileExtension = (String) responseWrapper.get('fileExtension');
                
                //Validate third party response
                //OWCThirdPartyValidationCheckerController.validateCCAPIResponse(caseNumber, communityUserId);
                if(String.isNotBlank(fieldValidationError)){
                    claimantWrapObj.isSuccess = false;
                    claimantWrapObj.message = fieldValidationError;
                }
                else{
                    String wca_Case_RecordType_Id = OWCConstants.WCA_CASE_RECORD_TYPE_ID;
                    String garment_Case_RecordType_Id = OWCConstants.Garment_CASE_RECORD_TYPE_ID;
                    String garment_Office_Los_Angeles = OWCConstants.Garment_Office_Los_Angeles;
                    
                    //Get the case management record
                    if(String.isNotBlank(caseNumber)){
                        caseObj = [SELECT Id, Name, Case_Number__c, Office__r.Name, Office__r.Office_Email__c,
                                   Applicant_Type__c FROM DIR_Case__c
                                   WHERE Case_Number__c =: caseNumber LIMIT 1];
                    }
                    
                    //Insert ContentVersion
                    ContentVersion cVersion = new ContentVersion();
                    cVersion.PathOnClient = name + fileExtension;//File name with extention
                    cVersion.Title = name;//Name of the file
                    cVersion.VersionData = EncodingUtil.base64Decode(jsonString);//File content
                    Insert cVersion;
                    
                    //After saved the Content Verison, get the ContentDocumentId
                    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                    
                    //Insert ContentDocumentLink
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                    cDocLink.LinkedEntityId = caseObj.Id;//Add attachment parentId
                    Insert cDocLink;
                    
                    //update the case record.
                    if(caseObj.Applicant_Type__c == 'Representative Garment'){
                        //emailTemplateName = 'Claim Email Reply Confirm Garment';
                        //update case RecordType to Garment
                        caseObj.recordTypeId = garment_Case_RecordType_Id;
                        caseObj.Office__c = garment_Office_Los_Angeles;
                    } else {
                        // CONFIRM Response
                        //emailTemplateName = 'Claim Email Reply Confirm';
                        //update case RecordType to WCA
                        caseObj.recordTypeId = wca_Case_RecordType_Id;
                        caseObj = OWCServiceUtility.populateOfficeOnCM(caseObj);
                    }
                    //create the Claimant Confirmation record
                    Claimant_Confirmation__c  cc = new Claimant_Confirmation__c ();
                    cc.Claimant_Confirmation__c = 'Confirm';
                    cc.Case_Promoted__c = true;
                    caseObj.Date_of_Docket__c = OWCOnlineClaimFormService.nextBusinessDate();
                    /*
                    //get Current Time as per Org Time Zone
                    DateTime currenTime = System.now();
                    // Get the default business hours
                    BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
                    // Find whether the time is within the default business hours
                    Boolean isWithin= BusinessHours.isWithin(bh.id, currenTime);
                    //lets set the next business datetime if current time is outside of business hours
                    if(isWithin){
                        caseObj.Date_of_Docket__c = currenTime.dateGMT();
                    }
                    else{
                        Datetime nextStart = BusinessHours.nextStartDate(bh.id, currenTime);
                        nextStart = nextStart;//OWCOnlineClaimFormService.getTimeInOrgTimeZone(nextStart);
                        caseObj.Date_of_Docket__c = nextStart.dateGMT();
                    }
                    */
                    update caseObj;
                    insert cc;
                    
                    DIR_Case__c updatedCase = [SELECT Id, Name, Case_Number__c, Office__r.Name, Office__r.Office_Email__c,
                                   Applicant_Type__c FROM DIR_Case__c
                                   WHERE Case_Number__c =: caseNumber LIMIT 1];
                    
                    claimantWrapObj.isSuccess = true;
                    claimantWrapObj.message = 'Success';
                    claimantWrapObj.districtOffice = updatedCase.Office__r.Name;
                    claimantWrapObj.officeEmail = updatedCase.Office__r.Office_Email__c;
                    claimantWrapObj.documentId = conDocument;
                }
            }
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(claimantWrapObj));
        }
        catch(Exception e)
        {
            System.debug('exception ::: '+e.getMessage());
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(claimantWrapObj));
        }
    }
}