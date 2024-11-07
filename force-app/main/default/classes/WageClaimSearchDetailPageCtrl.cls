public class WageClaimSearchDetailPageCtrl {
    public WageClaimDetails wageClaimObj{get;set;}
    public WageClaimSearchDetailPageCtrl(){
        String selectedCaseRoleId = ApexPages.currentPage().getParameters().get('crid');
        String selectedCaseId = ApexPages.currentPage().getParameters().get('id');
        DIR_Case__c caseObj = WageClaimQuerySelector.getWageClaimDetails(selectedCaseId , selectedCaseRoleId );
        if(caseObj!= null){
            wageClaimObj = new WageClaimDetails();
            wageClaimObj.caseName = caseObj.Name;
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
            wageClaimObj.caseStatus =  caseObj.Closure_Disposition__c == null ? caseObj.Status__c : caseObj.Status__c+' '+ caseObj.Closure_Disposition__c;
            wageClaimObj.applies = caseObj.X2810_4_Applies__c;
            wageClaimObj.dirOffice = caseObj.Office__r.Name;
            wageClaimObj.lowWageIndustry = caseObj.Low_Wage_Occupation__c;
        }
    }
    public class WageClaimDetails{
        public String caseName{get;set;} 
        public String accountName{get;set;}
        public String caseRole{get;set;}
        public String caseNumber{get;set;}
        public Date dateOfDocket{get;set;}
        public String dirOffice{get;set;}
        public String assignedDeputy{get;set;}
        public String naicsCode{get;set;}
        public String naicsTitle{get;set;}
        public String applies{get;set;}
        public String caseStatus{get;set;}
        public String lowWageIndustry{get;set;}
    }
}