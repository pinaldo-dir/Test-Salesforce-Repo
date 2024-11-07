//Match the JW allocations to existing non-'Judgment Amount' JPs, if any.
//   'Judgment Amount' JPs are updated in the CashUpdateMatchingLPs class with their related LPs.
//   Essentially the same algorithm as with matching CIW allocations to LPs, CashUpdateMatchedLPs class, q.v.

public with sharing class CashUpdateMatchedJPs{
    public static void updateMatchedJPs(List<CashJudgmentWrapper> judgmentWrapperList,
                                        List<Liability_Judgement__c> allJudgmentPartyList,
                                        /* String selectedPobo, */
                                        String whichButtonClicked)
        {
        
        for(CashJudgmentWrapper jw : judgmentWrapperList){

            // TODO: Commented out because jw.relevantPoboLiablePartyId should have been populated in JS, CashJudgmentWrapper class, already.
            /* // Determine correct POBO the JP should look up to
            for(Liability_Judgement__c judgmentParty : allJudgmentPartyList){
                if(judgmentParty.Judgement__c == jw.thisJudgment.Id){
                    if(judgmentParty.Liable_Party__r.Case_Role__c == selectedPobo){
                        jw.relevantPoboLiablePartyId = judgmentParty.Liable_Party__r.Id;
                    }
                }
            } */
            
            if(jw.matchingPostHearingInterestJP != null){
                jw.matchingPostHearingInterestJP.Payment_On_Behalf_Of__c = jw.relevantPoboLiablePartyId;

                if(whichButtonClicked == 'Recommend'){
                    jw.matchingPostHearingInterestJP.Recommended_Amount__c = jw.postHearingInterestAllocation;
                    jw.matchingPostHearingInterestJP.Status__c = 'Recommended';
                }else{ //whichButtonClicked == 'Post'
                    jw.matchingPostHearingInterestJP.Posted_Amount__c = jw.postHearingInterestAllocation;
                    jw.matchingPostHearingInterestJP.Status__c = 'Posted';
                }
            }
            if(jw.matchingPostJudgmentInterestJP != null){
                jw.matchingPostJudgmentInterestJP.Payment_On_Behalf_Of__c = jw.relevantPoboLiablePartyId;

                if(whichButtonClicked == 'Recommend'){
                    jw.matchingPostJudgmentInterestJP.Recommended_Amount__c = jw.postJudgmentInterestAllocation;
                    jw.matchingPostJudgmentInterestJP.Status__c = 'Recommended';
                }else{ //whichButtonClicked == 'Post'
                    jw.matchingPostJudgmentInterestJP.Posted_Amount__c = jw.postJudgmentInterestAllocation;
                    jw.matchingPostJudgmentInterestJP.Status__c = 'Posted';
                }
            }
            if(jw.matchingAttorneyFeeJP != null){
                jw.matchingAttorneyFeeJP.Payment_On_Behalf_Of__c = jw.relevantPoboLiablePartyId;

                if(whichButtonClicked == 'Recommend'){
                    jw.matchingAttorneyFeeJP.Recommended_Amount__c = jw.attorneyFeesAllocation;
                    jw.matchingAttorneyFeeJP.Status__c = 'Recommended';
                }else{ //whichButtonClicked == 'Post'
                    jw.matchingAttorneyFeeJP.Posted_Amount__c = jw.attorneyFeesAllocation;
                    jw.matchingAttorneyFeeJP.Status__c = 'Posted';
                }
            }
            if(jw.matchingFilingFeeJP != null){
                jw.matchingFilingFeeJP.Payment_On_Behalf_Of__c = jw.relevantPoboLiablePartyId;

                if(whichButtonClicked == 'Recommend'){
                    jw.matchingFilingFeeJP.Recommended_Amount__c = jw.filingFeesAllocation;
                    jw.matchingFilingFeeJP.Status__c = 'Recommended';
                }else{ //whichButtonClicked == 'Post'
                    jw.matchingFilingFeeJP.Posted_Amount__c = jw.filingFeesAllocation;
                    jw.matchingFilingFeeJP.Status__c = 'Posted';
                }
            }
        }
    }
}