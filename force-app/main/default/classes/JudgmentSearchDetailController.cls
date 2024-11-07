public class JudgmentSearchDetailController {
    @AuraEnabled
    public static JudgmentDetails getJudgmentDetails(ID selectedJudgmentRecordId, ID judgmentPartyId){
        Map<String,String> displayListStatusMap = new  Map<String,String>();
        for(Judgment_List_Status_2810__mdt mdtObj : [SELECT Label, Name__c FROM Judgment_List_Status_2810__mdt]){
            displayListStatusMap.put(mdtObj.Label,mdtObj.Name__c);
        }
        DirQuerySelector.judgmentDetailModel judgmentDetailModalObj = DirQuerySelector.getJudgmentDetails(selectedJudgmentRecordId , judgmentPartyId);
        JudgmentDetails judgmentDetailObj = new JudgmentDetails();
        Judgement__c judgmentRecordList = judgmentDetailModalObj.judgmentDetail;
        judgmentDetailObj.citationNumber = (judgmentRecordList.Liability__c != null ? judgmentRecordList.Liability__r.Citation_Number__c : '');
        judgmentDetailObj.court = judgmentRecordList.Court__r.Name;
        judgmentDetailObj.judgmentName = judgmentRecordList.Name; 
        judgmentDetailObj.judgmentStatus = judgmentRecordList.Status__c;
        judgmentDetailObj.totalDueToOthers = judgmentRecordList.Total_Due_to_Other_s__c;
        judgmentDetailObj.caseManagementName = judgmentRecordList.Case_Management__r.Name;
        judgmentDetailObj.courtCaseNumber = judgmentRecordList.Court_Case_Number__c;
        if(judgmentRecordList.RecordType.Name == 'Non-DLSE (LC 2810.4)' || judgmentRecordList.Case_Management__r.RecordType.Name == 'Garment' || judgmentRecordList.Case_Management__r.RecordType.Name == 'WCA'){
            judgmentDetailObj.accountName = judgmentDetailModalObj.claimantPlaintiffName;
        }
        else{
            judgmentDetailObj.accountName = 'Labor Commissioner';
        }
        judgmentDetailObj.naicsCode = judgmentRecordList.Case_Management__r.Naics_code__c;
        judgmentDetailObj.naicsTitle = judgmentRecordList.Case_Management__r.NAICS_Code_Title__c;
        judgmentDetailObj.judgmentEntryDate = judgmentRecordList.Judgement_Date__c;
        judgmentDetailObj.judgmentTotal = judgmentRecordList.Judgment_Total__c;
        judgmentDetailObj.totalDueToState = judgmentRecordList.Total_Penalties_Due__c;
        judgmentDetailObj.totalDueToEmployee = judgmentRecordList.Total_Wage_Balance_Due__c;
        if(judgmentRecordList.RecordType.Name == 'Non-DLSE (LC 2810.4)'){
            judgmentdetailObj.totalDue = judgmentRecordList.Total_Due_to_Other_s__c == null ? 0 : judgmentRecordList.Total_Due_to_Other_s__c;
        }
        else{
            judgmentdetailObj.totalDue = judgmentRecordList.Judgment_Total__c == null ? 0 : judgmentRecordList.Judgment_Total__c;
        }
        judgmentDetailObj.dirOffice = judgmentRecordList.Case_Management__r.Office__r.Name;
        String address ='';
        String defendantName = '';
        String judgmentPartyListStatus = '';
        if(judgmentRecordList.Liability_Judgements__r != null && judgmentRecordList.Liability_Judgements__r.size() > 0) {
            if(judgmentRecordList.Liability_Judgements__r[0].Liable_Party__c != null && judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__c != null) {
                address += (judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.ShippingStreet != null ? judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.ShippingStreet+ ' ' : '');
                address += (judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.ShippingCity != null ? judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.ShippingCity+ ' ' : '');
                address += (judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.ShippingState != null ? judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.ShippingState+ ' ' : '');
                address += (judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.ShippingCountry != null ? judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.ShippingCountry+ ' ' : '');
                address += (judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.ShippingPostalCode != null ? judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.ShippingPostalCode : '');
                defendantName = judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Case_Role_Entity_Full_Output__c;
            }else{
                address += (judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.ShippingStreet != null ? judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.ShippingStreet+ ' ' : '');
                address += (judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.ShippingCity != null ? judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.ShippingCity+ ' ' : '');
                address += (judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.ShippingState != null ? judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.ShippingState+ ' ' : '');
                address += (judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.ShippingCountry != null ? judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.ShippingCountry+ ' ' : '');
                address += (judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.ShippingPostalCode != null ? judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.ShippingPostalCode : '');
                defendantName = ((judgmentRecordList.Liability_Judgements__r != null && judgmentRecordList.Liability_Judgements__r.size() > 0) ? judgmentRecordList.Liability_Judgements__r[0].Related_Business__r.business__r.Name : '') ;
                //defendantName = judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__r.Name + (judgmentDetailModalObj.accWithDBAMap.containsKey(judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__c) ? ' dba ' + judgmentDetailModalObj.accWithDBAMap.get(judgmentRecordList.Liability_Judgements__r[0].Liable_Party__r.Entity__c) : '');
            }
            judgmentPartyListStatus = (judgmentRecordList.Liability_Judgements__r[0].X2810_4_List_Status__c != null ? displayListStatusMap.get(judgmentRecordList.Liability_Judgements__r[0].X2810_4_List_Status__c) : ' ') ;
        }
        judgmentDetailObj.portDrayageMotorCarrierJudgmentStatus = judgmentPartyListStatus;
        judgmentDetailObj.defendantEmployer = defendantName ; 
        judgmentDetailObj.primaryAddress = address;
        judgmentDetailObj.beginningdateofviolationofLaborCode =((judgmentRecordList.Liability_Judgements__r != null && judgmentRecordList.Liability_Judgements__r.size() > 0) ? judgmentRecordList.Liability_Judgements__r[0].X2810_4_Date_added_to_the_list__c : null) ;
        judgmentdetailObj.dateofcompliancewithLaborCode = ((judgmentRecordList.Liability_Judgements__r != null && judgmentRecordList.Liability_Judgements__r.size() > 0) ? judgmentRecordList.Liability_Judgements__r[0].X2810_4_Date_Removed_from_the_list__c : null) ;
        judgmentdetailObj.downloadContentUrl = WageClaimSearchDetailController.getDownloadContentUrl(judgmentRecordList.Case_Management__r.id);
        return judgmentDetailObj;
    }
    public class JudgmentDetails{
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String dirOffice;
        @AuraEnabled
        public String primaryAddress;
        @AuraEnabled
        public String naicsCode;
        @AuraEnabled
        public String naicsTitle;
        @AuraEnabled
        public String judgmentName;
        @AuraEnabled
        public String caseManagementName;
        @AuraEnabled
        public Date judgmentEntryDate;
        @AuraEnabled
        public String court;
        @AuraEnabled
        public String courtCaseNumber;
        @AuraEnabled
        public String portDrayageMotorCarrierJudgmentStatus;
        @AuraEnabled
        public Date beginningdateofviolationofLaborCode;
        @AuraEnabled
        public Date dateofcompliancewithLaborCode;
        @AuraEnabled
        public String judgmentStatus;
        @AuraEnabled
        public String defendantEmployer;
        @AuraEnabled
        public Decimal judgmentTotal;
        @AuraEnabled
        public String citationNumber;
        @AuraEnabled
        public Decimal totalDueToState;
        @AuraEnabled
        public Decimal totalDueToEmployee;
        @AuraEnabled
        public Decimal totalDueToOthers;
        @AuraEnabled
        public Decimal totalDue;
        @AuraEnabled
        public String dbaName;
        @AuraEnabled
        public Map<String,String> downloadContentUrl;
    }
}