public class WageClaimSearchResultContainer {
    @AuraEnabled
    public static List<WageClaimRecord> getWageClaimRecords(String naicsCode, String accountName, Date docketDateFrom,Date docketDateTo ,Date caseClosedFrom,Date caseClosedTo, String caseNumber, String lowWage, String dirOffice){
        List<Case_Role__c> caseRoleRecords = WageClaimQuerySelector.getWageClaimRecods(naicsCode , accountName, docketDateFrom, docketDateTo,caseClosedFrom,caseClosedTo, caseNumber, lowWage , dirOffice );
        System.debug('docketDateFrom ::: '+docketDateFrom);
        System.debug('docketDateTo ::: '+docketDateTo);
        System.debug('caseClosedFrom ::: '+caseClosedFrom);
        System.debug('caseClosedTo ::: '+caseClosedTo);
        System.debug('dirOffice ::: '+dirOffice);
        System.debug('accountName ::: '+accountName);
        //System.debug('naicsIndustry ::: '+naicsIndustry);
       //System.debug('naicsCode ::: '+naicCode);
        System.debug('caseNumber ::: '+caseNumber);
        System.debug('lowWage ::: '+lowWage);
        List<WageClaimRecord> wageClaimList = new List<WageClaimRecord>();
        for(Case_Role__c caseRoleObj : caseRoleRecords){
            WageClaimRecord wageClaimObj = new WageClaimRecord();
            wageClaimObj.id = caseRoleObj.Case__r.id;
            if(caseRoleObj.Role__c == 'Claimant' || caseRoleObj.Role__c == 'Defendant'){
                wageClaimObj.accountName = caseRoleObj.Case_Role_Entity_Full_Output__c;
            }
            else{
                wageClaimObj.accountName = caseRoleObj.Entity__r.Name;
            }
            if(caseRoleObj.Case__r.Case_Number__c == 'WC-CM-208334'){
                System.debug('Celestino Santiago, an Individual ::: '+caseRoleObj.Case_Role_Entity_Full_Output__c);
            }
            wageClaimObj.caseRole = caseRoleObj.Role__c;
            wageClaimObj.caseRoleId = caseRoleObj.Id;
            wageClaimObj.caseNumber = caseRoleObj.Case__r.Case_Number__c;
            wageClaimObj.naicsCode = caseRoleObj.Case__r.NAICS_Code__c;
            wageClaimObj.naicsTitle = (caseRoleObj.Case__r.NAICS_Code_Title__c != null ? caseRoleObj.Case__r.NAICS_Code_Title__c : '');
            wageClaimObj.dateofDocket = caseRoleObj.Case__r.Date_of_Docket__c;
            wageClaimObj.assignedDeputy = caseRoleObj.Case__r.Assigned_Deputy__r.Name;
            wageClaimObj.caseStatus = (String.isEmpty(caseRoleObj.Case__r.Status__c) && String.isEmpty(caseRoleObj.Case__r.Closure_Disposition__c)) ? '' : (String.isEmpty(caseRoleObj.Case__r.Status__c) ? caseRoleObj.Case__r.Closure_Disposition__c : String.isEmpty(caseRoleObj.Case__r.Closure_Disposition__c) ? caseRoleObj.Case__r.Status__c : caseRoleObj.Case__r.Status__c+' '+ caseRoleObj.Case__r.Closure_Disposition__c);
                wageClaimObj.applies = caseRoleObj.Case__r.X2810_4_Applies__c;
            wageClaimObj.dirOffice = caseRoleObj.Case__r.Office__r.Name;
            wageClaimList.add(wageClaimObj);
        }
        return wageClaimList;
    }
    public class WageClaimRecord{
        @AuraEnabled
        public string id;
        @AuraEnabled
        public string accountName;
        @AuraEnabled
        public string caseRole;
        @AuraEnabled
        public string caseRoleId;
        @AuraEnabled
        public string caseNumber;
        @AuraEnabled
        public string naicsCode;
        @AuraEnabled
        public string naicsTitle;
        @AuraEnabled
        public date dateofDocket;
        @AuraEnabled
        public string assignedDeputy;
        @AuraEnabled 
        public string dirOffice;
        @AuraEnabled
        public string caseStatus;
        @AuraEnabled
        public string applies;
        @AuraEnabled
        public String judgmentStatus;
        @AuraEnabled
        public String defendantEmployer;
        @AuraEnabled
        public Decimal judgmentTotal;
        
        
    }
    
}