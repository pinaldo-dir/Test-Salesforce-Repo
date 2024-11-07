public class JudgmentSearchResultPageController {
    public List<JudgmentDetailsObjCompare> judgmentRecordsLists{get;set;}
    public String listStatus2810{get;set;}
    public String naicsCode{get;set;}
    public String cliamantPlaintiffName{get;set;}
    public String city{get;set;}
    public String zipCode{get;set;}
    public Date judgmentEntryDateFrom{get;set;}
    public Date judgmentEntryDateTo{get;set;}
    public String court{get;set;}
    public String county{get;set;}
    public String naicsCodeTitle{get;set;}
    public String judgmentStatus{get;set;}
    public String defandantEmployerName{get;set;}
    public Double judgmentTotalFrom{get;set;}
    public Double judgmentTotalTo{get;set;}
    public String citationNumber{get;set;}
    public String dirOffice{get;set;}
    public String sortedHeader;
    public String sortedOrder;
    public JudgmentSearchResultPageController(){
        judgmentRecordsLists = new List<JudgmentDetailsObjCompare>();
        Set<String> judgmentPartyRejectSet = new Set<String>();
        Map<String,String> displayListStatusMap = new  Map<String,String>();
        for(Judgment_List_Status_2810__mdt mdtObj : [SELECT Label, Name__c FROM Judgment_List_Status_2810__mdt]){
            displayListStatusMap.put(mdtObj.Label,mdtObj.Name__c);
        }
        if(ApexPages.currentPage().getParameters().get('liststatus') != null){
            listStatus2810 = ApexPages.currentPage().getParameters().get('liststatus');
        }
        if(ApexPages.currentPage().getParameters().get('naicsCodeTitle') != null){
            naicsCodeTitle = ApexPages.currentPage().getParameters().get('naicsCodeTitle');
        }
        if(ApexPages.currentPage().getParameters().get('county') != null){
            county = ApexPages.currentPage().getParameters().get('county');
        }
        if(ApexPages.currentPage().getParameters().get('naics') != null){
            naicsCode = ApexPages.currentPage().getParameters().get('naics');
        }
        if(ApexPages.currentPage().getParameters().get('accountName') != null){
            cliamantPlaintiffName = ApexPages.currentPage().getParameters().get('accountName');
        }
        if(ApexPages.currentPage().getParameters().get('city') != null){
            city = ApexPages.currentPage().getParameters().get('city');
        }
        if(ApexPages.currentPage().getParameters().get('zipCode') != null){
            zipCode = ApexPages.currentPage().getParameters().get('zipCode');
        }
        if(ApexPages.currentPage().getParameters().get('judgmentdatefrom') != 'null' && ApexPages.currentPage().getParameters().get('judgmentdatefrom') != 'undefined'){
            judgmentEntryDateFrom = Date.valueOf(ApexPages.currentPage().getParameters().get('judgmentdatefrom'));
        }
        if(ApexPages.currentPage().getParameters().get('court') != null){
            court = ApexPages.currentPage().getParameters().get('court');
        }
        System.debug('judgmentstatus list ::::: '+ApexPages.currentPage().getParameters().get('judgmentstatus'));
        if(ApexPages.currentPage().getParameters().get('judgmentstatus') != null){
            judgmentstatus = ApexPages.currentPage().getParameters().get('judgmentstatus');
        }
        if(ApexPages.currentPage().getParameters().get('defandantemployer') != null){
            defandantEmployerName = ApexPages.currentPage().getParameters().get('defandantemployer');
        }
        if(ApexPages.currentPage().getParameters().get('judgmentTotalFrom') != null){
            judgmentTotalFrom = Double.valueOf(ApexPages.currentPage().getParameters().get('judgmentTotalFrom'));
        }
        if(ApexPages.currentPage().getParameters().get('judgmentTotalTo') != null){
            judgmentTotalTo = Double.valueOf(ApexPages.currentPage().getParameters().get('judgmentTotalTo'));
        }
        if(ApexPages.currentPage().getParameters().get('citationnumber') != null){
            citationNumber = ApexPages.currentPage().getParameters().get('citationnumber');
        }
        if(ApexPages.currentPage().getParameters().get('diroffice') != null){
            diroffice = ApexPages.currentPage().getParameters().get('diroffice');
        }
        if(ApexPages.currentPage().getParameters().get('judgmentdateto') != 'null' && ApexPages.currentPage().getParameters().get('judgmentdateto') != 'undefined'){
            judgmentEntryDateTo = Date.valueOf(ApexPages.currentPage().getParameters().get('judgmentdateto'));
        }
        if(ApexPages.currentPage().getParameters().get('sortingOrder') != null){
            sortedOrder = ApexPages.currentPage().getParameters().get('sortingOrder');
        }
        if(ApexPages.currentPage().getParameters().get('selectedHeader') != null){
            sortedHeader = ApexPages.currentPage().getParameters().get('selectedHeader');
        }
        List<string> judgmentStatusList = new List<string>();
        if(judgmentstatus.contains(',')){
            for(String s : judgmentstatus.split(',')){
                judgmentStatusList.add(s);
            }
        }else{
            judgmentStatusList.add(judgmentstatus);
        }
        DirQuerySelector.judgmentSearchRecordWrapper judgmentSearchWrapperObj = DirQuerySelector.getJudgmentRecords(listStatus2810, naicsCode, cliamantPlaintiffName, City, ZipCode, judgmentEntryDateFrom, judgmentEntryDateTo, court, judgmentStatusList, defandantEmployerName, judgmentTotalFrom,judgmentTotalTo, citationNumber, dirOffice,county);
        for(Liability_Judgement__c judgmentPartyObj : judgmentSearchWrapperObj.judgmentPartyList){
            String address ='';
            String defendantName = '';
            String judgmentPartyListStatus = '';
            if(judgmentPartyObj != null) {
                //check if liable party found
                if(judgmentPartyObj.Liable_Party__c != null && judgmentPartyObj.Liable_Party__r.Entity__c != null){
                    address += (judgmentPartyObj.Liable_Party__r.Entity__r.ShippingStreet != null ? judgmentPartyObj.Liable_Party__r.Entity__r.ShippingStreet+ ' ' : '');
                    address += (judgmentPartyObj.Liable_Party__r.Entity__r.ShippingCity != null ? judgmentPartyObj.Liable_Party__r.Entity__r.ShippingCity+ ' ' : '');
                    address += (judgmentPartyObj.Liable_Party__r.Entity__r.ShippingState != null ? judgmentPartyObj.Liable_Party__r.Entity__r.ShippingState+ ' ' : '');
                    address += (judgmentPartyObj.Liable_Party__r.Entity__r.ShippingCountry != null ? judgmentPartyObj.Liable_Party__r.Entity__r.ShippingCountry+ ' ' : '');
                    address += (judgmentPartyObj.Liable_Party__r.Entity__r.ShippingPostalCode != null ? judgmentPartyObj.Liable_Party__r.Entity__r.ShippingPostalCode : '');
                    // Changes according to DPD-28
                    defendantName = judgmentPartyObj.Liable_Party__r.Case_Role_Entity_Full_Output__c;
                } else{
                    address += (judgmentPartyObj.Related_Business__r.business__r.ShippingStreet != null ? judgmentPartyObj.Related_Business__r.business__r.ShippingStreet+ ' ' : '');
                    address = (judgmentPartyObj.Related_Business__r.business__r.ShippingCity != null ? judgmentPartyObj.Related_Business__r.business__r.ShippingCity+ ' ' : '');
                    address += (judgmentPartyObj.Related_Business__r.business__r.ShippingState != null ? judgmentPartyObj.Related_Business__r.business__r.ShippingState+ ' ' : '');
                    address += (judgmentPartyObj.Related_Business__r.business__r.ShippingCountry != null ? judgmentPartyObj.Related_Business__r.business__r.ShippingCountry+ ' ' : '');
                    address += (judgmentPartyObj.Related_Business__r.business__r.ShippingPostalCode != null ? judgmentPartyObj.Related_Business__r.business__r.ShippingPostalCode : '');
                    // Changes according to DPD-28
                    defendantName = (judgmentPartyObj != null) ? judgmentPartyObj.Related_Business__r.business__r.Name : '';
                }
                judgmentPartyListStatus = (judgmentPartyObj.X2810_4_List_Status__c != null ? displayListStatusMap.get(judgmentPartyObj.X2810_4_List_Status__c) : ' ') ;
            }
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = judgmentPartyListStatus ;
            judgmentdetailObj.Court = judgmentPartyObj.Judgement__r.Court__r.Name;
            judgmentdetailObj.JudgmentName = judgmentPartyObj.Judgement__r.Name;
            if(judgmentPartyObj.Judgement__r.RecordType.Name == 'Non-DLSE (LC 2810.4)' || judgmentPartyObj.Judgement__r.Case_Management__r.RecordType.Name == 'Garment' || judgmentPartyObj.Judgement__r.Case_Management__r.RecordType.Name == 'WCA'){
                judgmentdetailObj.cliamantPlaintiffName = judgmentSearchWrapperObj.caseRoleMap.containsKey(judgmentPartyObj.Judgement__r.Case_Management__c) ? judgmentSearchWrapperObj.caseRoleMap.get(judgmentPartyObj.Judgement__r.Case_Management__c) : judgmentPartyObj.Judgement__r.Case_Management__r.Employer__r.Name;
            }
            else{
                judgmentdetailObj.cliamantPlaintiffName = 'Labor Commissioner';
            }
            judgmentdetailObj.JudgmentStatus = judgmentPartyObj.Judgement__r.Status__c;
            if(judgmentPartyObj.Judgement__r.RecordType.Name == 'Non-DLSE (LC 2810.4)'){
                judgmentdetailObj.JudgmentTotal = judgmentPartyObj.Judgement__r.Total_Due_to_Other_s__c;
            }
            else{
                judgmentdetailObj.JudgmentTotal = judgmentPartyObj.Judgement__r.Judgment_Total__c;
            }
            judgmentdetailObj.PrimaryAddress = address;
            judgmentdetailObj.Defendant_EmployerName = defendantName;
            if(!judgmentPartyRejectSet.contains(judgmentPartyObj.Judgement__r.Name + defendantName + judgmentPartyObj.Judgement__r.Id)){
                judgmentRecordsLists.add(judgmentdetailObj);
                judgmentPartyRejectSet.add(judgmentPartyObj.Judgement__r.Name + defendantName + judgmentPartyObj.Judgement__r.Id);
            }
        }
        JudgmentDetailsObjCompare.sortBy = sortedHeader;
        JudgmentDetailsObjCompare.sortedOrder = sortedOrder;
        judgmentRecordsLists.sort();
    }
}