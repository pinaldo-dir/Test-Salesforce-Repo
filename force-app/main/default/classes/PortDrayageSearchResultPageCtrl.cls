public class PortDrayageSearchResultPageCtrl {
    public List<judgmentDetailsObjCompare> portDrayageSearchDetail{get;set;}
    public Date fromdate{get;set;}
    public Date todate{get;set;}
    public Date asofdate{get;set;}
    public String sortedHeader;
    public String sortedOrder;
    public PortDrayageSearchResultPageCtrl(){
        if(ApexPages.currentPage().getParameters().get('asofdate') != null && ApexPages.currentPage().getParameters().get('asofdate') != 'undefined'){
            asofdate = Date.valueOf(ApexPages.currentPage().getParameters().get('asofdate'));
        }
        if(ApexPages.currentPage().getParameters().get('todate') != null && ApexPages.currentPage().getParameters().get('todate') != 'undefined'){
            todate = Date.valueOf(ApexPages.currentPage().getParameters().get('todate'));
        }
        if(ApexPages.currentPage().getParameters().get('fromdate') != null && ApexPages.currentPage().getParameters().get('fromdate') != 'undefined'){
            fromDate = Date.valueOf(ApexPages.currentPage().getParameters().get('fromdate'));
        }
        if(ApexPages.currentPage().getParameters().get('sortingOrder') != null){
            sortedOrder = ApexPages.currentPage().getParameters().get('sortingOrder');
        }
        if(ApexPages.currentPage().getParameters().get('selectedHeader') != null){
            sortedHeader = ApexPages.currentPage().getParameters().get('selectedHeader');
        }
        Set<String> judgmentPartyRejectSet = new Set<String>();
        Map<String,String> displayListStatusMap = new  Map<String,String>();
        for(Judgment_List_Status_2810__mdt mdtObj : [SELECT Label, Name__c FROM Judgment_List_Status_2810__mdt]){
            displayListStatusMap.put(mdtObj.Label,mdtObj.Name__c);
        }
        DirQuerySelector.judgmentSearchRecordWrapper judgmentModel = DirQuerySelector.getPortDrayageRecords(asofdate,fromDate,todate);
        portDrayageSearchDetail = new List<judgmentDetailsObjCompare>();
        for(Liability_Judgement__c judgmentObj : judgmentModel.judgmentPartyList){
            judgmentDetailsObjCompare judgmentdetailObj = new judgmentDetailsObjCompare();
            judgmentdetailObj.JudgmentName = judgmentObj.Judgement__r.Name;
            if(judgmentObj.Judgement__r.RecordType.Name == 'Non-DLSE (LC 2810.4)' || judgmentObj.Judgement__r.Case_Management__r.RecordType.Name == 'Garment' || judgmentObj.Judgement__r.Case_Management__r.RecordType.Name == 'WCA'){
                judgmentdetailObj.cliamantPlaintiffName = judgmentModel.caseRoleMap.containsKey(judgmentObj.Judgement__r.Case_Management__c) ? judgmentModel.caseRoleMap.get(judgmentObj.Judgement__r.Case_Management__c) : judgmentObj.Judgement__r.Case_Management__r.Employer__r.Name;
            }
            else{
                judgmentdetailObj.cliamantPlaintiffName = 'Labor Commissioner';
            }
            String address ='';
            string defendantName = '';
            if(judgmentObj != null) {
                //check if liable party found
                if(judgmentObj.Liable_Party__c != null && judgmentObj.Liable_Party__r.Entity__c != null){
                    address += (judgmentObj.Liable_Party__r.Entity__r.ShippingStreet != null ? judgmentObj.Liable_Party__r.Entity__r.ShippingStreet+ ' ' : '');
                    address += (judgmentObj.Liable_Party__r.Entity__r.ShippingCity != null ? judgmentObj.Liable_Party__r.Entity__r.ShippingCity+ ' ' : '');
                    address += (judgmentObj.Liable_Party__r.Entity__r.ShippingState != null ? judgmentObj.Liable_Party__r.Entity__r.ShippingState+ ' ' : '');
                    address += (judgmentObj.Liable_Party__r.Entity__r.ShippingCountry != null ? judgmentObj.Liable_Party__r.Entity__r.ShippingCountry+ ' ' : '');
                    address += (judgmentObj.Liable_Party__r.Entity__r.ShippingPostalCode != null ? judgmentObj.Liable_Party__r.Entity__r.ShippingPostalCode : '');
                    // Changes according to DPD-28
                    defendantName = judgmentObj.Liable_Party__r.Case_Role_Entity_Full_Output__c;
                } else{
                    address += (judgmentObj.Related_Business__r.business__r.ShippingStreet != null ? judgmentObj.Related_Business__r.business__r.ShippingStreet+ ' ' : '');
                    address += (judgmentObj.Related_Business__r.business__r.ShippingCity != null ? judgmentObj.Related_Business__r.business__r.ShippingCity+ ' ' : '');
                    address += (judgmentObj.Related_Business__r.business__r.ShippingState != null ? judgmentObj.Related_Business__r.business__r.ShippingState+ ' ' : '');
                    address += (judgmentObj.Related_Business__r.business__r.ShippingCountry != null ? judgmentObj.Related_Business__r.business__r.ShippingCountry+ ' ' : '');
                    address += (judgmentObj.Related_Business__r.business__r.ShippingPostalCode != null ? judgmentObj.Related_Business__r.business__r.ShippingPostalCode : '');
                    // Changes according to DPD-28
                    defendantName = ((judgmentObj != null) ? judgmentObj.Related_Business__r.business__r.Name : '') ;
                }
            }
            
            judgmentdetailObj.PrimaryAddress = address;
            judgmentdetailObj.confirmedOnListDate = ((judgmentObj != null) ? judgmentObj.X2810_4_Date_added_to_the_list__c : null) ;
            judgmentdetailObj.confirmedOffListDate = ((judgmentObj != null) ? judgmentObj.X2810_4_Date_Removed_from_the_list__c : null) ;
            judgmentdetailObj.Defendant_EmployerName = defendantName;
            if(judgmentObj.Judgement__r.RecordType.Name == 'Non-DLSE (LC 2810.4)'){
                judgmentdetailObj.JudgmentTotal = judgmentObj.Judgement__r.Total_Due_to_Other_s__c;
            }
            else{
                judgmentdetailObj.JudgmentTotal = judgmentObj.Judgement__r.Judgment_Total__c;
            }
            judgmentdetailObj.asSuccessorTo = ((judgmentObj != null) ? judgmentObj.Related_Business__r.Related_Business__r.Name : '');
            
            if(!judgmentPartyRejectSet.contains(judgmentObj.Judgement__r.Name + defendantName + judgmentObj.Judgement__r.Id)){
                portDrayageSearchDetail.add(judgmentdetailObj);
                judgmentPartyRejectSet.add(judgmentObj.Judgement__r.Name + defendantName + judgmentObj.Judgement__r.Id);
            }
            judgmentDetailsObjCompare.sortBy = sortedHeader;
            judgmentDetailsObjCompare.sortedOrder = sortedOrder;
            portDrayageSearchDetail.sort();
        }
    }
}