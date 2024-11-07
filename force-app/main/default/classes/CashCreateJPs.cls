public with sharing class CashCreateJPs{
    public static List<Judgment_Payment__c> createJPs(List<CashJudgmentWrapper> judgmentWrapperList,
                                                        Case_Payment__c casePayment,
                                                        String whichButtonClicked)
        {
        List<Judgment_Payment__c> createdJPs = new List<Judgment_Payment__c>();        

        for(CashJudgmentWrapper jw : judgmentWrapperList){
            if(jw.postHearingInterestAllocation > 0 && jw.matchingPostHearingInterestJP == NULL){
                Judgment_Payment__c newPHIJP = new Judgment_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Post-Hearing Interest',
                    Judgment__c = jw.thisJudgment.Id,
                    Payment_On_Behalf_Of__c = jw.relevantPoboLiablePartyId
                );            
                if(whichButtonClicked == 'Recommend'){
                    newPHIJP.Recommended_Amount__c = jw.postHearingInterestAllocation;
                    newPHIJP.Status__c = 'Recommended';
                }else{
                    newPHIJP.Posted_Amount__c = jw.postHearingInterestAllocation;
                    newPHIJP.Status__c = 'Posted';
                }
                createdJPs.add(newPHIJP);
            }
            if(jw.postJudgmentInterestAllocation > 0 && jw.matchingPostJudgmentInterestJP == NULL){
                Judgment_Payment__c newPJIJP = new Judgment_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Post-Judgment Interest',
                    Judgment__c = jw.thisJudgment.Id,
                    Payment_On_Behalf_Of__c = jw.relevantPoboLiablePartyId
                );
                if(whichButtonClicked == 'Recommend'){
                    newPJIJP.Recommended_Amount__c = jw.postJudgmentInterestAllocation;
                    newPJIJP.Status__c = 'Recommended';
                }else{
                    newPJIJP.Posted_Amount__c = jw.postJudgmentInterestAllocation;
                    newPJIJP.Status__c = 'Posted';
                }
                createdJPs.add(newPJIJP);
            }
            if(jw.attorneyFeesAllocation > 0 && jw.matchingAttorneyFeeJP == NULL){
                Judgment_Payment__c newAFJP = new Judgment_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Attorney Fees',
                    Judgment__c = jw.thisJudgment.Id,
                    Payment_On_Behalf_Of__c = jw.relevantPoboLiablePartyId
                );
                if(whichButtonClicked == 'Recommend'){
                    newAFJP.Recommended_Amount__c = jw.attorneyFeesAllocation;
                    newAFJP.Status__c = 'Recommended';
                }else{
                    newAFJP.Posted_Amount__c = jw.attorneyFeesAllocation;
                    newAFJP.Status__c = 'Posted';
                }
                createdJPs.add(newAFJP);
            }
            if(jw.filingFeesAllocation > 0 && jw.matchingFilingFeeJP == NULL){
                Judgment_Payment__c newFFJP = new Judgment_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Filing Fees',
                    Judgment__c = jw.thisJudgment.Id,
                    Payment_On_Behalf_Of__c = jw.relevantPoboLiablePartyId
                );
                if(whichButtonClicked == 'Recommend'){
                    newFFJP.Recommended_Amount__c = jw.filingFeesAllocation;
                    newFFJP.Status__c = 'Recommended';
                }else{
                    newFFJP.Posted_Amount__c = jw.filingFeesAllocation;
                    newFFJP.Status__c = 'Posted';
                }
                createdJPs.add(newFFJP);
            }
        }
        return createdJPs;
    }
}