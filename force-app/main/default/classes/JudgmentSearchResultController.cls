public with sharing class JudgmentSearchResultController {
    
    @AuraEnabled
    public static List<judgmentDetailsObj> getJudgmentRecords(String listStatus2810,String naicsCode,String accountName, String City, String ZipCode, 
                                                              Date judgmentEntryDateFrom,Date judgmentEntryDateTo,String court, List<String> judgmentStatus, String defandantEmployerName,
                                                              double judgmentTotalFrom ,double judgmentTotalTo , String citationNumber ,String dirOffice,string county ){
                                                                  Map<String,String> displayListStatusMap = new  Map<String,String>();
                                                                  for(Judgment_List_Status_2810__mdt mdtObj : [SELECT Label, Name__c FROM Judgment_List_Status_2810__mdt]){
                                                                      displayListStatusMap.put(mdtObj.Label,mdtObj.Name__c);
                                                                  }
                                                                  DirQuerySelector.judgmentSearchRecordWrapper judgmentSearchWrapperObj = DirQuerySelector.getJudgmentRecords(listStatus2810, naicsCode, accountName, City, ZipCode, judgmentEntryDateFrom, judgmentEntryDateTo, court, judgmentStatus, defandantEmployerName, judgmentTotalFrom,judgmentTotalTo, citationNumber, dirOffice,county);
                                                                  List<judgmentDetailsObj> judgmentObjList = new List<judgmentDetailsObj>();
                                                                  for(Liability_Judgement__c judgmentPartyObj : judgmentSearchWrapperObj.judgmentPartyList){
                                                                      judgmentDetailsObj judgmentdetailObj = new judgmentDetailsObj();
                                                                      String address ='';
                                                                      string defendantName = '';
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
                                                                              address += (judgmentPartyObj.Related_Business__r.business__r.ShippingCity != null ? judgmentPartyObj.Related_Business__r.business__r.ShippingCity+ ' ' : '');
                                                                              address += (judgmentPartyObj.Related_Business__r.business__r.ShippingState != null ? judgmentPartyObj.Related_Business__r.business__r.ShippingState+ ' ' : '');
                                                                              address += (judgmentPartyObj.Related_Business__r.business__r.ShippingCountry != null ? judgmentPartyObj.Related_Business__r.business__r.ShippingCountry+ ' ' : '');
                                                                              address += (judgmentPartyObj.Related_Business__r.business__r.ShippingPostalCode != null ? judgmentPartyObj.Related_Business__r.business__r.ShippingPostalCode : '');
                                                                              // Changes according to DPD-28
                                                                              defendantName = ((judgmentPartyObj != null) ? judgmentPartyObj.Related_Business__r.business__r.Name : '') ;
                                                                          }
                                                                          judgmentPartyListStatus = (judgmentPartyObj.X2810_4_List_Status__c != null ? displayListStatusMap.get(judgmentPartyObj.X2810_4_List_Status__c) : ' ') ; 
                                                                      }
                                                                      judgmentdetailObj.Court = judgmentPartyObj.Judgement__r.Court__r.Name;
                                                                      judgmentdetailObj.JudgmentName = judgmentPartyObj.Judgement__r.Name;
                                                                      /*// Get ClaimantPlaintiffName based on case management record type
                                                                      if(judgmentPartyObj.Judgement__r.RecordType.Name == 'Non-DLSE (LC 2810.4)' || judgmentPartyObj.Judgement__r.Case_Management__r.RecordType.Name == 'Garment' || judgmentPartyObj.Judgement__r.Case_Management__r.RecordType.Name == 'WCA'){
                                                                          judgmentdetailObj.ClaimantPlaintiffName = judgmentSearchWrapperObj.caseRoleMap.containsKey(judgmentPartyObj.Judgement__r.Case_Management__c) ? judgmentSearchWrapperObj.caseRoleMap.get(judgmentPartyObj.Judgement__r.Case_Management__c) : judgmentPartyObj.Judgement__r.Case_Management__r.Employer__r.Name;
                                                                      }
                                                                      else{
                                                                          judgmentdetailObj.ClaimantPlaintiffName = 'Labor Commissioner';
                                                                      }*/
                                                                      judgmentdetailObj.JudgmentStatus = judgmentPartyObj.Judgement__r.Status__c;
                                                                      judgmentdetailObj.recordId = judgmentPartyObj.Judgement__r.id;
                                                                      // Get JudgmentTotal based on judgment record type
                                                                      if(judgmentPartyObj.Judgement__r.RecordType.Name == 'Non-DLSE (LC 2810.4)'){
                                                                          judgmentdetailObj.JudgmentTotal = judgmentPartyObj.Judgement__r.Total_Due_to_Other_s__c;
                                                                      }
                                                                      else{
                                                                          judgmentdetailObj.JudgmentTotal = judgmentPartyObj.Judgement__r.Judgment_Total__c;
                                                                      }
                                                                      judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = judgmentPartyListStatus ;
                                                                      judgmentdetailObj.PrimaryAddress = address;
                                                                      judgmentdetailObj.judgmentPartyId = ((judgmentPartyObj != null) ? judgmentPartyObj.Id : null);
                                                                      judgmentdetailObj.Defendant_EmployerName = defendantName ;
                                                                      judgmentdetailObj.judgmentEntryDate = judgmentPartyObj.Judgement__r.Judgement_Date__c;
                                                                      judgmentdetailObj.citationNumber = (judgmentPartyObj.Judgement__r.Liability__c != null ? judgmentPartyObj.Judgement__r.Liability__r.Citation_Number__c : '');
                                                                      judgmentdetailObj.totalDueEmployee = judgmentPartyObj.Judgement__r.Total_Wage_Balance_Due__c;
                                                                      judgmentdetailObj.totalDueState = judgmentPartyObj.Judgement__r.Total_Penalties_Due__c;
                                                                      judgmentdetailObj.totalDueToOthers = judgmentPartyObj.Judgement__r.Total_Due_to_Other_s__c;
                                                                      judgmentdetailObj.industryNAICS = judgmentPartyObj.Judgement__r.Case_Management__r.NAICS_Code_Title__c;
                                                                      judgmentdetailObj.naicsCode = judgmentPartyObj.Judgement__r.Case_Management__r.Naics_code__c;
                                                                      judgmentdetailObj.dirOffice = judgmentPartyObj.Judgement__r.Case_Management__r.Office__r.Name;
                                                                      
                                                                      judgmentObjList.add(judgmentdetailObj);
                                                                  }
                                                                  return judgmentObjList;
                                                              }
    
    @AuraEnabled
    public static List<judgmentDetailsObj> getPortDrayageRecords(date asOfDate, date fromDate , date toDate){  
        Map<String,String> displayListStatusMap = new  Map<String,String>();
        for(Judgment_List_Status_2810__mdt mdtObj : [SELECT Label, Name__c FROM Judgment_List_Status_2810__mdt]){
            displayListStatusMap.put(mdtObj.Label,mdtObj.Name__c);
        }
        DirQuerySelector.judgmentSearchRecordWrapper judgmentModel = DirQuerySelector.getPortDrayageRecords(asOfDate, fromDate, toDate);
        List<judgmentDetailsObj> judgmentObjList = new List<judgmentDetailsObj>();
        for(Liability_Judgement__c judgmentObj : judgmentModel.judgmentPartyList){
            judgmentDetailsObj judgmentdetailObj = new judgmentDetailsObj();
            judgmentdetailObj.JudgmentName = judgmentObj.Judgement__r.Name;
            /*if(judgmentObj.Judgement__r.RecordType.Name == 'Non-DLSE (LC 2810.4)' || judgmentObj.Judgement__r.Case_Management__r.RecordType.Name == 'Garment' || judgmentObj.Judgement__r.Case_Management__r.RecordType.Name == 'WCA'){
                judgmentdetailObj.ClaimantPlaintiffName = judgmentModel.caseRoleMap.containsKey(judgmentObj.Judgement__r.Case_Management__c) ? judgmentModel.caseRoleMap.get(judgmentObj.Judgement__r.Case_Management__c) : judgmentObj.Judgement__r.Case_Management__r.Employer__r.Name;
            }
            else{
                judgmentdetailObj.ClaimantPlaintiffName = 'Labor Commissioner';
            }*/
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
            judgmentdetailObj.recordId = judgmentObj.Judgement__r.Id ;
            judgmentdetailObj.confirmedOnListDate = ((judgmentObj != null) ? judgmentObj.X2810_4_Date_added_to_the_list__c : null) ;
            judgmentdetailObj.confirmedOffListDate = ((judgmentObj != null) ? judgmentObj.X2810_4_Date_Removed_from_the_list__c : null) ;
            judgmentdetailObj.Defendant_EmployerName = defendantName;
            if(judgmentObj.Judgement__r.RecordType.Name == 'Non-DLSE (LC 2810.4)'){
                judgmentdetailObj.JudgmentTotal = judgmentObj.Judgement__r.Total_Due_to_Other_s__c;
            }
            else{
                judgmentdetailObj.JudgmentTotal = judgmentObj.Judgement__r.Judgment_Total__c;
            }
            judgmentdetailObj.judgmentPartyId = ((judgmentObj != null) ? judgmentObj.Id : '');
            judgmentdetailObj.asSuccessorTo = ((judgmentObj != null) ? judgmentObj.Related_Business__r.Related_Business__r.Name : '');
            judgmentdetailObj.Court = judgmentObj.Judgement__r.Court__r.Name;
            judgmentdetailObj.judgmentEntryDate = judgmentObj.Judgement__r.Judgement_Date__c;
            judgmentdetailObj.citationNumber = (judgmentObj.Judgement__r.Liability__c != null ? judgmentObj.Judgement__r.Liability__r.Citation_Number__c : '');
            judgmentdetailObj.totalDueEmployee = judgmentObj.Judgement__r.Total_Wage_Balance_Due__c;
            judgmentdetailObj.totalDueState = judgmentObj.Judgement__r.Total_Penalties_Due__c;
            judgmentdetailObj.totalDueToOthers = judgmentObj.Judgement__r.Total_Due_to_Other_s__c;
            judgmentdetailObj.industryNAICS = judgmentObj.Judgement__r.Case_Management__r.NAICS_Code_Title__c;
            judgmentdetailObj.naicsCode = judgmentObj.Judgement__r.Case_Management__r.Naics_code__c;
            judgmentdetailObj.dirOffice = judgmentObj.Judgement__r.Case_Management__r.Office__r.Name;
            
            judgmentObjList.add(judgmentdetailObj);
        }
        return judgmentObjList;
    }
    
    
    public class judgmentDetailsObj{
        @AuraEnabled
        public String PortDrayageMotorCarrierJudgmentStatus;
        @AuraEnabled
        public String PrimaryAddress;
        @AuraEnabled
        public String JudgmentName;
        @AuraEnabled
        public String asSuccessorTo;
        @AuraEnabled
        public String JudgmentStatus;
        @AuraEnabled
        public String Court;
        @AuraEnabled
        public String Defendant_EmployerName;
        @AuraEnabled
        public Decimal JudgmentTotal;
        @AuraEnabled
        public ID recordId;
        @AuraEnabled
        public Date confirmedOnListDate;
        @AuraEnabled
        public Date confirmedOffListDate;
        @AuraEnabled
        public Id judgmentPartyId;
        @AuraEnabled
        public Date judgmentEntryDate;
        @AuraEnabled
        public String citationNumber;
        @AuraEnabled
        public Decimal totalDueEmployee;
        @AuraEnabled
        public Decimal totalDueState;
        @AuraEnabled
        public Decimal totalDueToOthers;
        @AuraEnabled
        public String industryNAICS;
        @AuraEnabled
        public String naicsCode;
        @AuraEnabled
        public String dbaName;
        @AuraEnabled
        public String dirOffice;
    }
}