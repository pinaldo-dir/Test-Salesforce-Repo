public class WageClaimQuerySelector {
    
    public static List<Case_Role__c> getWageClaimRecods(String naicsCode, String accountName, Date docketDateFrom, Date docketDateTo,Date caseClosedFrom,Date caseClosedTo , String caseNumber, String lowWageIndustry, String dirOffice){
        Set<Id> caseId = new Set<Id>();
        //List<String> caseRoleText = new List<String>{'%Claimant%','%minor%','%witness%','%Bank%','%Family Relative%','%Spouse%','%Garnishee%','%Escrow Company%'};
        List<String> caseRoleText = new List<String>{'%Case Employer%','%Client Employer%','Defendant','%Defendant - Guarantor%','%Defendant - Joint Employer%','%Defendant - Successor%','%Guarantor%','%Joint Employer%','Successor'};
            if(String.isNotBlank(accountName)){
            string partyName = '%' + String.escapeSingleQuotes(accountName) + '%';
            List<Case_Role__c> caseRole = [SELECT id,Case__c from Case_Role__c WHERE Entity__r.Name LIKE :partyName limit 5000];
            for(Case_Role__c cr : caseRole){
                caseId.add(cr.Case__c);
            }
        }
        String caseRoleQuery = 'SELECT id, Case_Role_Entity_Full_Output__c,Case__c, Role__c, Entity__r.Name, Case__r.Name, Case__r.Assigned_Deputy__r.Name, Case__r.Closure_Disposition__c, Case__r.Case_Number__c, Case__r.NAICS_Code_Title__c, Case__r.NAICS_Code__c, Case__r.Office__r.Office_Location__c, Case__r.Date_of_Docket__c, Case__r.Office__r.Name, Case__r.Status__c, Case__r.X2810_4_Applies__c, Case__r.Employer__r.name FROM Case_Role__c WHERE ( Role__c LIKE :caseRoleText)';
        if(String.isNotBlank(accountName)){
            caseRoleQuery += ' AND Entity__r.Name like \'%' + String.escapeSingleQuotes(accountName) + '%\' ';
        }
        if(caseId.size() > 0){
            caseRoleQuery+= ' AND Case__r.createdDate != null AND (Case__r.RecordType.Name =\'WCA\' OR Case__r.RecordType.Name =\'Garment\' OR Case__r.RecordType.Name =\'Legacy Garment Case\' OR Case__r.RecordType.Name =\'Legacy WCA Case\') AND Case__r.Id IN :caseId ';
        }else{
           caseRoleQuery+= ' AND Case__r.createdDate != null AND (Case__r.RecordType.Name =\'WCA\' OR Case__r.RecordType.Name =\'Garment\' OR Case__r.RecordType.Name =\'Legacy Garment Case\' OR Case__r.RecordType.Name =\'Legacy WCA Case\') '; 
        }
        
        if(String.isNotBlank(naicsCode)){
          caseRoleQuery += ' AND Case__r.NAICS_Code__c like \'' + naicsCode + '%\' ';
        }
        if(docketDateFrom != null){
            caseRoleQuery += ' AND Case__r.Date_of_Docket__c >=: docketDateFrom ';
        }
        if(docketDateTo != null){
            caseRoleQuery += ' AND Case__r.Date_of_Docket__c <=: docketDateTo ';
        }
        if(caseClosedFrom != null){
            caseRoleQuery += ' AND Case__r.Case_Closed_Date__c >=: caseClosedFrom ';
        }
        if(caseClosedTo != null){
            caseRoleQuery += ' AND Case__r.Case_Closed_Date__c <=: caseClosedTo ';
        }
        if(String.isNotBlank(caseNumber)){
          caseRoleQuery += ' AND Case__r.Case_Number__c LIKE \'' + '%' + caseNumber+ '%' + '\' ';
        }
        if(String.isNotBlank(lowWageIndustry)){
          caseRoleQuery += ' AND Case__r.Low_Wage_Occupation__c = \'' + lowWageIndustry + '\' ';
        }
         if(String.isNotBlank(dirOffice)){
            if(dirOffice.equals('Los Angeles')){
                caseRoleQuery += ' And Case__r.Office__r.RecordType.Name = \'WCA\' ';
            }
            caseRoleQuery += ' And Case__r.Office__r.Name =\'' + dirOffice + '\' ';
        }
        caseRoleQuery+= 'ORDER BY Case__r.Date_of_Docket__c DESC NULLS LAST limit 5000 '; 
        List<Case_Role__c> dirCaseList = database.query(caseRoleQuery);
        
        return dirCaseList;
    }
    public static DIR_Case__c getWageClaimDetails(String caseId ,String caseRoleId){
        return [SELECT Id,Name, Assigned_Deputy__r.Name, Low_Wage_Occupation__c, Closure_Disposition__c,Case_Number__c,NAICS_Code_Title__c, NAICS_Code__c,Office__r.Office_Location__c, Date_of_Docket__c, Office__c,Office__r.Name, Status__c, X2810_4_Applies__c ,(SELECT id,Case__c,Role__c,Entity__r.Name,Case_Role_Entity_Full_Output__c From Case_Roles__r where Id=: caseRoleId) FROM DIR_Case__c where id=: caseId LIMIT 1];
    }
    public static List<ContentDocumentLink> getContentDocumentLinkList(ID caseId){
        return [SELECT LinkedEntityId, Id, ContentDocumentId,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink where LinkedEntityId =: caseId];
    }
    public static List<ContentVersion> getContentVersionList(Set<ID> contentdocumentIdList){
        return [SELECT Id, Title, ContentDocumentId, FileType FROM ContentVersion where ContentDocumentId IN :contentdocumentIdList];
    }
    public static List<ContentDistribution> getDownloadContentUrlList(Set<ID> contentdocumentIdList){
        return [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentDocumentId IN :contentdocumentIdList];
    }
}