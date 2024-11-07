public class WageClaimSearchResultPageCtrl {
    public List<WageClaimSearchResultPageWrapperCtrl> wageClaimList{get;set;}
    public String accountName{get;set;}
    public String caseNumber{get;set;}
    public Date docketFromDate{get;set;}
    public Date docketToDate{get;set;}
    public Date closedFromDate{get;set;}
    public Date closedToDate{get;set;}
    public String naicsCode{get;set;}
    public String naicsIndustry{get;set;}
    public String lowWageIndustry{get;set;}
    public String dirOffice{get;set;}
    public String sortedHeader;
    public String sortedOrder;
    public WageClaimSearchResultPageCtrl(){
        wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        if(ApexPages.currentPage().getParameters().get('fromDate') != 'null' && ApexPages.currentPage().getParameters().get('fromDate') != 'undefined'){
            docketFromDate = Date.valueOf(ApexPages.currentPage().getParameters().get('fromDate'));
        }
        if(ApexPages.currentPage().getParameters().get('toDate') != 'null' && ApexPages.currentPage().getParameters().get('toDate') != 'undefined'){
            docketToDate = Date.valueOf(ApexPages.currentPage().getParameters().get('toDate'));
        }
        if(ApexPages.currentPage().getParameters().get('caseclosedfromdate') != 'null' && ApexPages.currentPage().getParameters().get('caseclosedfromdate') != 'undefined'){
            closedFromDate = Date.valueOf(ApexPages.currentPage().getParameters().get('caseclosedfromdate'));
        }
        if(ApexPages.currentPage().getParameters().get('caseclosedtodate') != 'null' && ApexPages.currentPage().getParameters().get('caseclosedtodate') != 'undefined'){
            closedToDate = Date.valueOf(ApexPages.currentPage().getParameters().get('caseclosedtodate'));
        }
        if(ApexPages.currentPage().getParameters().get('dirOffice') != null){
            dirOffice = ApexPages.currentPage().getParameters().get('dirOffice');
        }
        if(ApexPages.currentPage().getParameters().get('accountName') != null){
            accountName = ApexPages.currentPage().getParameters().get('accountName');
        }
        if(ApexPages.currentPage().getParameters().get('naicsCodeTitle') != null){
            naicsIndustry = ApexPages.currentPage().getParameters().get('naicsCodeTitle');
        }
        if(ApexPages.currentPage().getParameters().get('naicsCode') != null){
            naicsCode = ApexPages.currentPage().getParameters().get('naicsCode');
        }
        if(ApexPages.currentPage().getParameters().get('caseNumber') != null){
            caseNumber = ApexPages.currentPage().getParameters().get('caseNumber');
        }
        if(ApexPages.currentPage().getParameters().get('lowWage') != null){
            lowWageIndustry = ApexPages.currentPage().getParameters().get('lowWage');
        }
        if(ApexPages.currentPage().getParameters().get('sortingOrder') != null){
            sortedOrder = ApexPages.currentPage().getParameters().get('sortingOrder');
        }
        if(ApexPages.currentPage().getParameters().get('selectedHeader') != null){
            sortedHeader = ApexPages.currentPage().getParameters().get('selectedHeader');
        }
        System.debug('docketFromDate ::: '+docketFromDate);
        System.debug('docketToDate ::: '+docketToDate);
        System.debug('closedFromDate ::: '+closedFromDate);
        System.debug('closedToDate ::: '+closedToDate);
        System.debug('dirOffice ::: '+dirOffice);
        System.debug('accountName ::: '+accountName);
        System.debug('naicsIndustry ::: '+naicsIndustry);
        System.debug('naicsCode ::: '+naicsCode);
        System.debug('caseNumber ::: '+caseNumber);
        List<Case_Role__c> caseRoleRecords = WageClaimQuerySelector.getWageClaimRecods(naicsCode , accountName, docketFromDate, docketToDate,closedFromDate,closedToDate, caseNumber, lowWageIndustry , dirOffice);
        System.debug('caseRoleRecords ::: '+caseRoleRecords.size());
        for(Case_Role__c caseRoleObj : caseRoleRecords){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            if(caseRoleObj.Role__c == 'Claimant' || caseRoleObj.Role__c == 'Defendant'){
                wageClaimObj.accountName = caseRoleObj.Case_Role_Entity_Full_Output__c ;
            }
            else{
                wageClaimObj.accountName = caseRoleObj.Entity__r.Name;
            }
            wageClaimObj.caseRole = caseRoleObj.Role__c;
            wageClaimObj.caseNumber = caseRoleObj.Case__r.Case_Number__c;
            wageClaimObj.naicsCode = caseRoleObj.Case__r.NAICS_Code__c;
            wageClaimObj.naicsTitle = (caseRoleObj.Case__r.NAICS_Code_Title__c != null ? caseRoleObj.Case__r.NAICS_Code_Title__c : '');
            wageClaimObj.dateofDocket = caseRoleObj.Case__r.Date_of_Docket__c;
            wageClaimObj.assignedDeputy = caseRoleObj.Case__r.Assigned_Deputy__r.Name;
            wageClaimObj.caseStatus = caseRoleObj.Case__r.Status__c +' '+(caseRoleObj.Case__r.Closure_Disposition__c != null ? caseRoleObj.Case__r.Closure_Disposition__c : '');
            wageClaimObj.applies = caseRoleObj.Case__r.X2810_4_Applies__c;
            wageClaimObj.dirOffice = caseRoleObj.Case__r.Office__r.Name;
            wageClaimList.add(wageClaimObj);
        }
        System.debug('wageClaimList ::: '+wageClaimList.size());
        WageClaimSearchResultPageWrapperCtrl.sortBy = sortedHeader;
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = sortedOrder;
        wageClaimList.sort();
    }
}