public with sharing class CashJudgmentWrapper{

    @AuraEnabled
    public Judgement__c thisJudgment{get;set;}
    @AuraEnabled
    public String judgmentIdUrl{get;set;}
    /* @AuraEnabled
    public String judgmentTooltip{get;set;} */
    @AuraEnabled
    public String judgmentName{get;set;}
    @AuraEnabled
    public String judgmentPartyName{get;set;}
    @AuraEnabled
    public String judgmentPartyUrl{get;set;}
    @AuraEnabled
    public String courtName{get;set;}
    @AuraEnabled
    public String courtUrl{get;set;}
    @AuraEnabled
    public String judgmentStatus{get;set;}

    @AuraEnabled
    public Id relevantPoboLiablePartyId{get;set;} //This is a Liable Party Id, the same as the LP.Payment_On_Behalf_Of__c field.
                                                  //  (cf 'selectedPobo' here and in the main js class, a Case Role Id, which is
                                                  //  used to populate the POBO dropdown).
    /* @AuraEnabled
    public Id relevantCaseRoleId{get;set;} //Case Role Id of the Judgment Parties. May or may not be related to the relevantPoboLiablePartyId. TODO: not used anywhere, seemingly */
 
    @AuraEnabled
    public Decimal postHearingInterestBalanceDue{get;set;}
    @AuraEnabled
    public Decimal postHearingInterestAllocation{get;set;}
    
    @AuraEnabled
    public Decimal postJudgmentInterestBalanceDue{get;set;}
    @AuraEnabled
    public Decimal postJudgmentInterestAllocation{get;set;}

    @AuraEnabled
    public Decimal attorneyFeesBalanceDue{get;set;}
    @AuraEnabled
    public Decimal attorneyFeesAllocation{get;set;}

    @AuraEnabled
    public Decimal filingFeesBalanceDue{get;set;}
    @AuraEnabled
    public Decimal filingFeesAllocation{get;set;}

    @AuraEnabled
    public Judgment_Payment__c matchingPostHearingInterestJP{get;set;}
    @AuraEnabled
    public Judgment_Payment__c matchingPostJudgmentInterestJP{get;set;}
    @AuraEnabled
    public Judgment_Payment__c matchingAttorneyFeeJP{get;set;}
    @AuraEnabled
    public Judgment_Payment__c matchingFilingFeeJP{get;set;}

    public CashJudgmentWrapper(){} //No-arg constructor seems to be required for some reason.

    public CashJudgmentWrapper(Judgement__c judgment){
        System.debug('54 Entered CashJudgmentWrapper apex class constructor');
        thisJudgment = judgment;
        judgmentIdUrl = '/' + judgment.Id;
        /* judgmentTooltip = '🔴𝙏𝙮𝙥𝙚: ' + judgment.Type__c + '      🟠𝘾𝙤𝙪𝙧𝙩 𝘾𝙖𝙨𝙚 #: ' + judgment.Court_Case_Number__c + '      🟡𝘾𝙤𝙪𝙧𝙩: ' + judgment.Court__r.Name; */
        judgmentName = judgment.Name;
        courtName = judgment.Court__r.Name;
        courtUrl = '/' + judgment.Court__c;
        judgmentStatus = judgment.Status__c;

        // relevantPoboLiablePartyId = '';
        // relevantCaseRoleId = '';

        postHearingInterestBalanceDue = judgment.Post_hearing_Interest_Balance_Due__c != null ? judgment.Post_hearing_Interest_Balance_Due__c : 0;
        postHearingInterestAllocation = 0;

        postJudgmentInterestBalanceDue = judgment.Post_judgment_Interest_Balance_Due__c != null ? judgment.Post_judgment_Interest_Balance_Due__c : 0;
        postJudgmentInterestAllocation = 0;

        attorneyFeesBalanceDue = judgment.Attorney_Fees_Balance_Due__c != null ? judgment.Attorney_Fees_Balance_Due__c : 0;
        attorneyFeesAllocation = 0;

        filingFeesBalanceDue = judgment.Filing_Fees_Balance_Due__c != null ? judgment.Filing_Fees_Balance_Due__c : 0;
        filingFeesAllocation = 0;
        
        /*
        matchingPostHearingInterestJP;
        matchingPostJudgmentInterestJP;
        matchingAttorneyFeeJP;
        matchingFilingFeeJP;
        */        

    }

    @AuraEnabled
    public static List<CashJudgmentWrapper> createJudgmentWrapperList(List<Judgement__c> judgmentList, List<Judgment_Payment__c> jpList,
                                                                        List<Liability_Judgement__c> judgmentPartyList, String selectedPobo){
        
        System.debug('98 jpList: ' + judgmentPartyList);
        List<CashJudgmentWrapper> jwList = new List<CashJudgmentWrapper>();
        //TODO: for now (Phase 2, Iteration 3) JP.POBO is set to whichever POBO has been selected on the Case Payment Allocation screen, assuming that that Case Role has only one Liable Party, since we're
        //   displaying all Judgments on that screen regardless of the selected POBO. This may change in a later phase of development.
        List<Liable_Party__c> effectivePoboLiablePartyList = [SELECT Id FROM Liable_Party__c WHERE Case_Role__r.Id = :selectedPobo LIMIT 1];

        /* //Phase 2 iteration 3: no longer filtering Judgments, just bring in all of them on the case regardless of POBO 
        //No POBO selected on page load, so bring in Judgments for ALL POBOs
        if(selectedPobo == 'ALL' || selectedPobo == null){
            for(Judgement__c judgment : judgmentList){
                jwList.add(new CashJudgmentWrapper(judgment));
            }
        }else{
            for(Judgement__c judgment: judgmentList){
                for(Liability_Judgement__c judgmentParty : judgmentPartyList){
                    if(selectedPobo == judgmentParty.Liable_Party__r.Case_Role__r.Id){  //TODO: may need more finesse in filtering--Judgment Parties are currently derived from the Judgments
                                                                                        //  and filtered by Case Role. Maybe derive from the Liable Parties and filter by Judgment, etc, to make
                                                                                        //  the filtering algorithm more like that of the CIWs
                        jwList.add(new CashJudgmentWrapper(judgment));
                    }
                }
            }
        } */

        //TODO: as stated above, for now (Phase 2 Iteration 3) no longer filtering Judgments, so here we just bring in all of them on the case regardless of selectedPobo
        for(Judgement__c judgment : judgmentList){
            jwList.add(new CashJudgmentWrapper(judgment));
        }

        for(CashJudgmentWrapper jw : jwList){
            for(Judgment_Payment__c jp : jpList){
                if(jp.Judgment__c == jw.thisJudgment.Id){
                    if(jp.Payment_Applied_To__c == 'Post-Hearing Interest'){
                        jw.postHearingInterestAllocation = (jp.Posted_Amount__c == 0 || jp.Posted_Amount__c == null) ? jp.Recommended_Amount__c : jp.Posted_Amount__c;
                        jw.matchingPostHearingInterestJP = jp;
                    }else if(jp.Payment_Applied_To__c == 'Post-Judgment Interest'){
                        jw.postJudgmentInterestAllocation = (jp.Posted_Amount__c == 0 || jp.Posted_Amount__c == null) ? jp.Recommended_Amount__c : jp.Posted_Amount__c;
                        jw.matchingPostJudgmentInterestJP = jp;
                    }else if(jp.Payment_Applied_To__c == 'Attorney Fees'){
                        jw.attorneyFeesAllocation = (jp.Posted_Amount__c == 0 || jp.Posted_Amount__c == null) ? jp.Recommended_Amount__c : jp.Posted_Amount__c;
                        jw.matchingAttorneyFeeJP = jp;
                    }else if(jp.Payment_Applied_To__c == 'Filing Fees'){
                        jw.filingFeesAllocation = (jp.Posted_Amount__c == 0 || jp.Posted_Amount__c == null) ? jp.Recommended_Amount__c : jp.Posted_Amount__c;
                        jw.matchingFilingFeeJP = jp;
                    } //// jp.Payment_Applied_To__c == 'Judgment Amount' means this JP is redundant with one of the LPs. These 'redundant' JPs don't show up on the LWC nor are meant to be directly editable.
                      ////   These JPs are created in CashCreateRendundantJPs, and handled mostly in the LP code: CashCaseIssueWrapper, CashUpdateMatchedLPs.  
                }
            }

            if(!effectivePoboLiablePartyList.isEmpty()){
                jw.relevantPoboLiablePartyId = effectivePoboLiablePartyList[0].Id;
            }
            
            for(Liability_Judgement__c judgmentParty : judgmentPartyList){
                if(judgmentParty.Judgement__c == jw.thisJudgment.Id){ //Assuming all Judgment Parties on one Judgment look up to the same Case Role.

                    Liability_Judgement__c judgmentPartyDetail = [SELECT Id, Liable_Party__r.Case_Role__r.Account_Name__c, Liable_Party__r.Case_Role__r.Entity__c
                                                                    FROM Liability_Judgement__c
                                                                    WHERE Id = :judgmentParty.Id];

                    System.debug('jp name: ' + judgmentPartyDetail.Liable_Party__r.Case_Role__r.Account_Name__c);
                    jw.judgmentPartyName = judgmentPartyDetail.Liable_Party__r.Case_Role__r.Account_Name__c;
                    jw.judgmentPartyUrl = '/' + judgmentPartyDetail.Liable_Party__r.Case_Role__r.Entity__c;
                    /* jw.judgmentTooltip = '🔴𝙅𝙪𝙙𝙜𝙢𝙚𝙣𝙩 𝙋𝙖𝙧𝙩𝙮: ' + judgmentParty.Liable_Party__r.Case_Role__r.Account_Name__c + ' ' + jw.judgmentTooltip; */

                    /* jw.relevantCaseRoleId = judgmentParty.Liable_Party__r.Case_Role__r.Id; */
                    /* jw.relevantPoboLiablePartyId = judgmentParty.Liable_Party__r.Id; */
                }
            }
        }

        return jwList;
    }
}