public with sharing class CashCaseIssueWrapper{
    
    @AuraEnabled
    public DIR_Violation__c thisCaseIssue{get;set;}
    //@AuraEnabled
    //public Id caseIssueId{get;set;}
    @AuraEnabled
    public String caseIssueIdUrl{get;set;}
    @AuraEnabled
    public String caseIssueRecordTypeId{get;set;}
    @AuraEnabled
    public Assessments__c caseIssueAssessment{get;set;}

    @AuraEnabled
    public String assessmentDescription{get;set;}
    @AuraEnabled
    public String status{get;set;}
    @AuraEnabled
    public String violationTypeName{get;set;}
    @AuraEnabled
    public String citationNumbers{get;set;}
    @AuraEnabled
    public String judgmentNumber{get;set;}

    @AuraEnabled
    public Decimal wagesAssessed{get;set;}
    @AuraEnabled
    public Decimal wageBalanceDue{get;set;}
    @AuraEnabled
    public Decimal wageAllocation{get;set;}

    @AuraEnabled
    public Decimal wageInterestAssessed{get;set;}
    @AuraEnabled
    public Decimal wageInterestBalanceDue{get;set;}
    @AuraEnabled
    public Decimal wageInterestAllocation{get;set;}

    @AuraEnabled
    public Decimal penaltiesAssessed{get;set;}
    @AuraEnabled
    public Decimal penaltyBalanceDue{get;set;}
    @AuraEnabled
    public Decimal penaltyAllocation{get;set;}

    @AuraEnabled
    public Decimal interestAssessed{get;set;}
    @AuraEnabled
    public Decimal interestBalanceDue{get;set;}
    @AuraEnabled
    public Decimal interestAllocation{get;set;}

    @AuraEnabled
    public Liability_Payment__c matchingWageLP{get;set;}
    @AuraEnabled
    public Liability_Payment__c matchingWageInterestLP{get;set;}
    @AuraEnabled
    public Liability_Payment__c matchingInterestLP{get;set;}
    @AuraEnabled
    public Liability_Payment__c matchingPenaltyLP{get;set;}

    @AuraEnabled
    public Liability__c relevantLiability{get;set;}
    @AuraEnabled
    public Id relevantPoboLiablePartyId{get;set;} //This is a Liable Party Id, the same as the LP.Payment_On_Behalf_Of__c field.
                                                  //  (cf 'selectedPobo' here and in the main js class, which is a Case Role Id instead).
    
    //Used for matching and updating extant "redundant" "Judgment Amount" JPs only. Doesn't display anything on the VFP:
    @AuraEnabled
    public List<Judgment_Payment__c> matchingRedundantWageJPsArray{get;set;}
    @AuraEnabled
    public List<Judgment_Payment__c> matchingRedundantWageInterestJPsArray{get;set;}
    @AuraEnabled
    public List<Judgment_Payment__c> matchingRedundantInterestJPsArray{get;set;}
    @AuraEnabled
    public List<Judgment_Payment__c> matchingRedundantPenaltyJPsArray{get;set;}

    public CashCaseIssueWrapper(){} //No-arg constructor seems to be required for some reason.

    public CashCaseIssueWrapper(DIR_Violation__c caseIssue){
        System.debug('83 Entered CashCaseIssueWrapper constructor, caseIssue: '+ caseIssue);
        thisCaseIssue = caseIssue;
        caseIssueIdUrl = '/' + caseIssue.Id;
        caseIssueRecordTypeId = caseIssue.RecordTypeId;
        caseIssueAssessment = caseIssue.Assessment__r;

        assessmentDescription = caseIssue.Wage_Assessment_Description__c != null ? caseIssue.Wage_Assessment_Description__c : 'Please fix Violation Type Description';
        status = caseIssue.Status__c; 
        violationTypeName = (caseIssue.Violation_Type__c != null && caseIssue.Violation_Type__r.Name != null)  ? caseIssue.Violation_Type__r.Name : 'Please fix Violation Type Name';
        citationNumbers = caseIssue.Assessment__r.Citation_Number__c != null ? caseIssue.Assessment__r.Citation_Number__c : '---';
        //TODO: Assessments__c.JEU_Case_number__c is misnamed/mislabeled. It should be 'Judgment Number'.
        judgmentNumber = caseIssue.Assessment__r.JEU_Case_Number__c != null ? caseIssue.Assessment__r.JEU_Case_Number__c : '---';

        wagesAssessed = caseIssue.Wages_Due__c != null ? caseIssue.Wages_Due__c : 0; //CI.EE(s) Amt Assessed
        wageBalanceDue = caseIssue.Non_Interest_Wage_Balance_Due__c != null ? caseIssue.Non_Interest_Wage_Balance_Due__c : 0; //CI.Non Interest Wage Balance Due
        wageAllocation = 0;

        wageInterestAssessed = caseIssue.Total_Wage_Interest_Amount__c != null ? caseIssue.Total_Wage_Interest_Amount__c : 0; //CI.Total Wage Interest Amount
        wageInterestBalanceDue = caseIssue.Wage_Interest_Balance_Due__c != null ? caseIssue.Wage_Interest_Balance_Due__c : 0; //CI.Wage Interest Balance Due
        wageInterestAllocation = 0;

        penaltiesAssessed = caseIssue.Citation_Amount__c != null ? caseIssue.Citation_Amount__c : 0; //CI.Penalty Assessment Amt
        penaltyBalanceDue = caseIssue.Penalty_Balance_Due__c != null ? caseIssue.Penalty_Balance_Due__c : 0; //CI.Penalty Balance Due
        penaltyAllocation = 0;

        interestAssessed = caseIssue.Total_Interest_Amount__c != null ? caseIssue.Total_Interest_Amount__c : 0; //CI.Total Interest Amount
        interestBalanceDue = caseIssue.Interest_Balance_Due__c != null ? caseIssue.Interest_Balance_Due__c : 0; //CI.Interest Balance Due
        interestAllocation = 0;

        //relevantLiability
        // relevantPoboLiablePartyId;

        //matchingWageLP;
        //matchingPenaltyLP;
        //matchingInterestLP;

        matchingRedundantWageJPsArray = new List<Judgment_Payment__c>();
        matchingRedundantWageInterestJPsArray = new List<Judgment_Payment__c>();
        matchingRedundantInterestJPsArray = new List<Judgment_Payment__c>();
        matchingRedundantPenaltyJPsArray = new List<Judgment_Payment__c>();
                 
    }


    @AuraEnabled
    public static List<CashCaseIssueWrapper> createCaseIssueWrapperList(List<DIR_Violation__c> ciList, List<Liability_Payment__c> lpList, List<Judgment_Payment__c> jpList,
                                                                        List<Liable_Party__c> liablePartyList, String selectedPobo){

        List<CashCaseIssueWrapper> ciwList = new List<CashCaseIssueWrapper>();
  
        if(selectedPobo == 'ALL' || selectedPobo == null){
            for(DIR_Violation__c ci : ciList){
                ciwList.add(new CashCaseIssueWrapper(ci));
            }
        }else{
            for(DIR_Violation__c ci : ciList){
                for(Liable_Party__c liableParty : liablePartyList){
                    System.debug('139 liableParty: ' + liableParty);
                    if(selectedPobo == liableParty.Case_Role__c && ci.Assessment__c == liableParty.Liability__r.Assessment__c){
                        ciwList.add(new CashCaseIssueWrapper(ci));
                    }
                }
            }

            for(CashCaseIssueWrapper ciw : ciwList){                
                for(Liable_Party__c liableParty : liablePartyList){
                    if(selectedPobo == liableParty.Case_Role__c && ciw.thisCaseIssue.Assessment__c == liableParty.Liability__r.Assessment__c){
                        ciw.relevantLiability = liableParty.Liability__r;
                        ciw.relevantPoboLiablePartyId = liableParty.Id;
                    }
                }
            }
        }
        
        for(Liability_Payment__c lp : lpList){
            for(CashCaseIssueWrapper ciw : ciwList){
                if(lp.Case_Violation__c == ciw.thisCaseIssue.Id){
                    // System.debug('162 citation nos: ' + lp.Case_Violation__r.Assessment__r.Citation_Number__c);
                    // ciw.citationNumbers = lp.Case_Violation__r.Assessment__r.Citation_Number__c;
                    // System.debug('164 jeu nos: ' + lp.Case_Violation__r.Assessment__r.JEU_Case_Number__c);
                    // ciw.judgmentNumber = lp.Case_Violation__r.Assessment__r.JEU_Case_Number__c; //TODO: fixed API fieldname capitalization, verify in other integrations

                    if(lp.Payment_Applied_To__c == 'Wages'){
                        ciw.wageAllocation = (lp.Posted_Amount__c == 0 || lp.Posted_Amount__c == null) ? lp.Recommended_Amount__c : lp.Posted_Amount__c;
                        ciw.matchingWageLP = lp;

                        for(Judgment_Payment__c jp : jpList){
                            if(jp.Funds_Redundant_With__c == lp.Id){
                                ciw.matchingRedundantWageJPsArray.add(jp);
                            }
                        }
                    }else if(lp.Payment_Applied_To__c == 'Wage Interest'){
                        ciw.wageInterestAllocation = (lp.Posted_Amount__c == 0 || lp.Posted_Amount__c == null) ? lp.Recommended_Amount__c : lp.Posted_Amount__c;
                        ciw.matchingWageInterestLP = lp;

                        for(Judgment_Payment__c jp : jpList){
                            if(jp.Funds_Redundant_With__c == lp.Id){
                                ciw.matchingRedundantWageInterestJPsArray.add(jp);
                            }
                        }
                    }else if(lp.Payment_Applied_To__c == 'Interest'){
                        ciw.interestAllocation = (lp.Posted_Amount__c == 0 || lp.Posted_Amount__c == null) ? lp.Recommended_Amount__c : lp.Posted_Amount__c;
                        ciw.matchingInterestLP = lp;

                        for(Judgment_Payment__c jp : jpList){
                            if(jp.Funds_Redundant_With__c == lp.Id){
                                ciw.matchingRedundantInterestJPsArray.add(jp);
                            }
                        }
                    }else if(lp.Payment_Applied_To__c == 'Penalties'){
                        ciw.penaltyAllocation = (lp.Posted_Amount__c == 0 || lp.Posted_Amount__c == null) ? lp.Recommended_Amount__c : lp.Posted_Amount__c;
                        ciw.matchingPenaltyLP = lp;

                        for(Judgment_Payment__c jp : jpList){
                            if(jp.Funds_Redundant_With__c == lp.Id){
                                ciw.matchingRedundantPenaltyJPsArray.add(jp);
                            }
                        }
                    }
                }
            }
        }

        return ciwList;
    }
}