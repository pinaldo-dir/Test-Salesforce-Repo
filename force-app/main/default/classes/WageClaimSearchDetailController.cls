public with sharing class WageClaimSearchDetailController {
    @AuraEnabled
    public static WageClaimDetails getWageClaimDetails(string selectedCaseId, string selectedCaseRoleId){
        WageClaimDetails wageClaimObj = new WageClaimDetails();
        DIR_Case__c caseObj = WageClaimQuerySelector.getWageClaimDetails(selectedCaseId , selectedCaseRoleId );
        if(caseObj!= null){
            wageClaimObj.caseName = caseObj.Name;
            wageClaimObj.dirOffice = caseObj.Office__r.Name;
            if(caseObj.Case_Roles__r[0].Role__c == 'Claimant' || caseObj.Case_Roles__r[0].Role__c == 'Defendant'){
                wageClaimObj.accountName = ((caseObj.Case_Roles__r != null && caseObj.Case_Roles__r.size() >0) ? caseObj.Case_Roles__r[0].Case_Role_Entity_Full_Output__c : '' );
            }
            else{
                wageClaimObj.accountName = ((caseObj.Case_Roles__r != null && caseObj.Case_Roles__r.size() >0) ? caseObj.Case_Roles__r[0].Entity__r.Name : '' );
            }
            wageClaimObj.caseRole = ((caseObj.Case_Roles__r != null && caseObj.Case_Roles__r.size() >0) ? caseObj.Case_Roles__r[0].Role__c : '' );
            wageClaimObj.caseNumber = caseObj.Case_Number__c;
            wageClaimObj.naicsCode = caseObj.NAICS_Code__c;
            wageClaimObj.naicsTitle = (caseObj.NAICS_Code_Title__c != null ? caseObj.NAICS_Code_Title__c : '');
            wageClaimObj.dateofDocket = caseObj.Date_of_Docket__c;
            wageClaimObj.assignedDeputy = caseObj.Assigned_Deputy__r.Name;
            wageClaimObj.caseStatus = (String.isEmpty(caseObj.Status__c) && String.isEmpty(caseObj.Closure_Disposition__c)) ? '' : (String.isEmpty(caseObj.Status__c) ? caseObj.Closure_Disposition__c : String.isEmpty(caseObj.Closure_Disposition__c) ? caseObj.Status__c : caseObj.Status__c+' '+ caseObj.Closure_Disposition__c);
                wageClaimObj.applies = caseObj.X2810_4_Applies__c;
            wageClaimObj.lowWageOccupation = caseObj.Low_Wage_Occupation__c;
            wageClaimObj.downloadContentUrl = getDownloadContentUrl(caseObj.id);
            
        }
        return wageClaimObj; 
    }
    //Method to get downloadContentUrl for files those are related to case management
    public static Map<String,String> getDownloadContentUrl(ID caseId){
        Set<ID> contentdocumentIds = new Set<ID>();
        Map<Id,String> contentDocumentIdWithAttachmentFileNameMap = new Map<Id,String>();
        Map<String,String> downloadContentUrlMap = new Map<String,String>();
        List<ContentDocumentLink> ContentDocumentLinks = new List<ContentDocumentLink>();
        for(Attachments_New__c att : [Select id,File_Name__c,(SELECT Id,ContentDocumentId,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLinks LIMIT 1) from Attachments_New__c
                                      where Related_Id__c =: caseId AND Release_to_Public__c = true])
        {
            for(ContentDocumentLink objCDL : att.ContentDocumentLinks){
                ContentDocumentLinks.add(objCDL);
                contentDocumentIdWithAttachmentFileNameMap.put(objCDL.ContentDocumentId, att.File_Name__c);
            }
        }
        if(ContentDocumentLinks.size() > 0){
            for(ContentDocumentLink conDocLinkObj : ContentDocumentLinks){
                contentdocumentIds.add(conDocLinkObj.ContentDocumentId);
            }
            List<ContentVersion> contentVersionList = WageClaimQuerySelector.getContentVersionList(contentdocumentIds);
            List<DirPublicContentDownloadUrlController.contentDistributionObj> getDownloadContentUrl = DirPublicContentDownloadUrlController.getDownloadPublicContentUrl(contentdocumentIds);
            for(ContentVersion contentVersionObj : contentVersionList){
                if(contentVersionObj.FileType == 'PDF'){
                    for(DirPublicContentDownloadUrlController.contentDistributionObj contentDistributionObj : getDownloadContentUrl){
                        if(contentVersionObj.ContentDocumentId == contentDistributionObj.contentDocumentId){
                            downloadContentUrlMap.put(contentDocumentIdWithAttachmentFileNameMap.get(contentDistributionObj.contentDocumentId),contentDistributionObj.downloadPublicUrl);
                            break;
                        }
                    }
                }
            }
        }
        return downloadContentUrlMap;
    }
    public class WageClaimDetails{
        @AuraEnabled
        public String caseName;
        @AuraEnabled
        public String lowWageOccupation;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String caseRole;
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public Date dateOfDocket;
        @AuraEnabled
        public String dirOffice;
        @AuraEnabled
        public String assignedDeputy;
        @AuraEnabled
        public String naicsCode;
        @AuraEnabled
        public String naicsTitle;
        @AuraEnabled
        public String applies;
        @AuraEnabled
        public String caseStatus;
        @AuraEnabled
        public String meetingScheduledFor;
        @AuraEnabled
        public Date meetingStartDate;
        @AuraEnabled
        public DateTime meetingTime;
        @AuraEnabled
        public String meetingLocation;
        @AuraEnabled
        public String meetingType;
        @AuraEnabled
        public Map<String,String> downloadContentUrl;
    }
}