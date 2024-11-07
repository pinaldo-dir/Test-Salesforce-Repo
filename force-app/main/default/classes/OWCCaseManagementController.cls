/*Name: OWCCaseManagementController
* Description: This class is used to get all the submitted case management records for the current community login user.
* Primary Record: Case Management
*/
public without sharing class OWCCaseManagementController {
    @AuraEnabled
    public static List<caseWrapperObj> getSubmittedCaseRecords(){
        
        List<caseWrapperObj> wrapperList = new List<caseWrapperObj>();
        String communityAccountId;
        try {
            System.debug('OWCConstants.ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID ::: '+OWCConstants.ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID);
            System.debug('userInfo.getProfileId() ::: '+userInfo.getProfileId());
            if(OWCConstants.ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID != null && userInfo.getProfileId() == OWCConstants.ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID){
                communityAccountId = [SELECT Id, ContactId, AccountId, Profile.Name FROM User 
                                      WHERE Id =: userInfo.getUserId() LIMIT 1].AccountId;
            }
            List<DIR_Case__c> caseObjList;
            if(String.isNotBlank(communityAccountId)){
                caseObjList = [SELECT Case_Number__c,Related_Party_Employer_Name__c, Claimant__r.Name, Claimant_Name_in_Text__c, Id,
                                                 Name, Employer_Name_in_Text__c, Employer__r.Name, CreatedDate, Status__c FROM DIR_Case__c 
                                                 WHERE Online_Claim_Account__c =: communityAccountId ORDER BY CreatedDate DESC];
            }
            
            if(caseObjList.size() > 0){
                for(DIR_Case__c caseObj : caseObjList){
                    caseWrapperObj wrapperObj = new caseWrapperObj();
                    wrapperObj.caseName = caseObj.Name;
                    wrapperObj.recordId = caseObj.Id;
                    wrapperObj.claimantName = caseObj.Claimant__r.Name != null ? caseObj.Claimant__r.Name : caseObj.Claimant_Name_in_Text__c;
                    wrapperObj.status = caseObj.Status__c;
                    wrapperObj.employerName = caseObj.Employer__r.Name != null ? caseObj.Employer__r.Name : caseObj.Related_Party_Employer_Name__c;
                    wrapperObj.CaseNumber = (caseObj.Status__c == 'Not Confirmed') ? '' : caseObj.Case_Number__c;
                    wrapperObj.submittedDate = (caseObj.createdDate).format('MM/dd/yyyy');
                    wrapperObj.submitDate = caseObj.createdDate.Date();
                    if(wrapperObj.submitDate.daysBetween(Date.today()) >=60 && caseObj.Status__c == 'Not Confirmed'){//&& caseObj.Status__c == 'Not Confirmed'
                        wrapperObj.is60DayOld = true;
                    }
                    wrapperList.add(wrapperObj);
                }
            }
            return wrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }
    // This method is used to get the current case management details.
    @AuraEnabled
    public static caseWrapperObj getCaseDetails(String recordId){
        try{
            List<ContentDocumentLink> contentDocLinks;
            List<ContentDistribution> contentDistributionObj;
            System.debug('recordId ::: '+recordId);
            if(String.isNotBlank(recordId)){
                /*Set<Id> contentIds = new Set<Id>();
                List<ContentDocument> contDocs = [SELECT Id, Title, ParentId FROM ContentDocument WHERE Title = 'Wage Claim Summary Report'];
                if(contDocs.size() > 0){
                    for(ContentDocument contDocObj : contDocs){
                        contentIds.add(contDocObj.Id);
                    }
                }*/
                
                    contentDocLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink
                                       WHERE LinkedEntityId =: recordId AND ContentDocument.Title = 'Wage Claim Summary Report'];
                
                //Get the attachment record
                List<Attachments_New__c> aPlusData = [SELECT Id,Name,File_Type__c,Related_Id__c,File_Name__c, Release_To_Public__c FROM Attachments_New__c 
                                              WHERE Related_Id__c =: recordId AND File_Name__c = 'Wage Claim Summary Report' LIMIT 1];
                
                System.debug('aPlusData ::: '+aPlusData);
                
                String fileURL;
                if(aPlusData != null && aPlusData.size() > 0){
                    if(aPlusData[0].Release_To_Public__c){
                        if(contentDocLinks.size() > 0){
                            contentDistributionObj = [SELECT Id, ContentDownloadUrl, PdfDownloadUrl, DistributionPublicUrl, ContentDocumentId FROM ContentDistribution
                                                      WHERE ContentDocumentId =: contentDocLinks[0].ContentDocumentId];
                            
                            fileURL = contentDistributionObj != null && contentDistributionObj.size() > 0 ? contentDistributionObj[0] != null ? contentDistributionObj[0].DistributionPublicUrl : null : null;
                        }
                    }
                    else{
                        fileURL = OWCSharepointAPIService.getFilesFromSharePoint(new List<String>{aPlusData[0].Id})[0];//A_Plus_Controller.viewSharepointFile(aPlusData[0].Id);
                    }
                }
                system.debug('fileURL: '+fileURL);
                
                System.debug('contentDocLinks ::: '+contentDocLinks);
                
                caseWrapperObj caseWrapObj = new caseWrapperObj();
                DIR_Case__c caseObj = [SELECT Id, Name, Address_Primary_Zip__c, Case_Number__c, Assigned_Deputy__r.Name, Office__r.Office_Location__c, 
                                       Office__r.Office_Email__c, CreatedDate, Status__c FROM DIR_Case__c WHERE Id =: recordId];
                if(caseObj != null){
                    caseWrapObj.assignedDeputy = caseObj.Assigned_Deputy__r.Name;
                    caseWrapObj.officeLocation = caseObj.Office__r.Office_Location__c;
                    caseWrapObj.CaseNumber = caseObj.Case_Number__c;
                    caseWrapObj.caseName = caseObj.Name;
                    caseWrapObj.status = caseObj.Status__c;
                    //caseWrapObj.contentDocuments = contentIds;
                    caseWrapObj.officeEmail = caseObj.Office__r.Office_Email__c;
                    caseWrapObj.pdfLink = fileURL;
                    caseWrapObj.isPDFAvailable = caseWrapObj.pdfLink != null ? true : false;
                }
                Date createdDate = caseObj.createdDate.Date();
                if(createdDate.daysBetween(Date.today()) >=30 && caseObj.Status__c == 'Not Confirmed'){// && caseObj.Status__c == 'Not Confirmed'
                    caseWrapObj.is60DayOld = true;
                }
                if(caseWrapObj != null){
                    return caseWrapObj;
                }
            }
            return null;
        }catch (Exception e) {
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
    public class caseWrapperObj{
        @AuraEnabled
        public Set<Id> contentDocuments{get;set;}
        @AuraEnabled
        public String caseName{get;set;}
        @AuraEnabled
        public String recordId{get;set;}
        @AuraEnabled
        public String claimantName{get;set;}
        @AuraEnabled
        public String CaseNumber{get;set;}
        @AuraEnabled
        public String status{get;set;}
        @AuraEnabled
        public String employerName{get;set;}
        @AuraEnabled
        public Date submitDate {get;set;}
        @AuraEnabled
        public String submittedDate {get;set;}
        @AuraEnabled
        public String errorMsg{get;set;}
        @AuraEnabled
        public String assignedDeputy{get;set;}
        @AuraEnabled
        public String officeLocation{get;set;}
        @AuraEnabled
        public String officeEmail{get;set;}
        @AuraEnabled
        public String pdfLink{get;set;}
        @AuraEnabled
        public Boolean is60DayOld{get;set;}
        @AuraEnabled
        public Boolean isPDFAvailable{get;set;}
    }
}