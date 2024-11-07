//Match CIW allocations to existing LPs and their related 'redundant' 'Judgment Amount' JPs, if any.
//   Non-'Judgment Amount' JPs updated in the CashUpdateMatchedJPs class.
//   Essentially the same algorithm as with matching JW allocations to JPs, CashUpdateMatchedJPs class,
//    and matching CU1W allocations to their LPs, CashUpdateMatchedCU1s class, q.v.

public with sharing class CashUpdateMatchedLPs{
    public static void updateMatchedLPs(List<CashCaseIssueWrapper> caseIssueWrapperList, 
                                            List<Liable_Party__c> allLiablePartyList, 
                                            /* String selectedPobo, //Case_Role__c.Id //Commented out because relevantPoboLiablePartyId and relevantLiability should already have been set in JS */
                                            String whichButtonClicked)
        {
        for(CashCaseIssueWrapper ciw : caseIssueWrapperList){
            /* Commented out because relevantPoboLiablePartyId and relevantLiability should already have been set in JS.
             //  Determine correct Liability and Payment_on_Behalf_of__c the LP should look up to.
            //    TODO: Verify this works for CIs with multiple Liable Parties (through LPCIs) and Case Roles with multiple Liable Parties. This may be
            //        where we need to bring in LPCI.Proportionate_Share__c
            for(Liable_Party__c liableParty : allLiablePartyList){
                //for(Liable_Party_Case_Issue__c lpci : liableParty.Liable_Party_Case_Issues__r){ //SR-010949
                    //if(lpci.Case_Issue__c == ciw.thisCaseIssue.Id && lpci.Liable_Party__r.Case_Role__c == selectedPobo){ //SR-010949

                    if(selectedPobo == liableParty.Case_Role__c && ciw.caseIssueAssessment.Id == liableParty.Liability__r.Assessment__r.Id){
                        ciw.relevantLiability = liableParty.Liability__r;
                        ciw.relevantPoboLiablePartyId = liableParty.Id;
                    }
                //}
            } */

            //  If the recommended amounts are different in the CIW than in it's matching LP, update the LP and any 'redundant' JPs,
            //    even if $0 (meaning a previous recommended amount has been removed, but we're still keeping the record for historical purposes).
            if(ciw.matchingWageLP != null){
                ciw.matchingWageLP.Case_Violation__c = ciw.thisCaseIssue.Id; // Updating this field here because a lot of the records in PROD have this field blank
                ciw.matchingWageLP.Liability__c = ciw.relevantLiability.Id; // Updating this field here because a lot of the records in PROD have this field blank
                ciw.matchingWageLP.Payment_on_Behalf_of__c = ciw.relevantPoboLiablePartyId;

                if(whichButtonClicked == 'Recommend'){
                    ciw.matchingWageLP.Recommended_Amount__c = ciw.wageAllocation;
                    ciw.matchingWageLP.Status__c = 'Recommended';

                    for(Judgment_Payment__c jp : ciw.matchingRedundantWageJPsArray){   
                        jp.Recommended_Amount__c = ciw.wageAllocation;
                        jp.Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId;
                        jp.Status__c = 'Recommended';
                    }
                }else{ //whichButtonClicked == 'Post'
                    ciw.matchingWageLP.Posted_Amount__c = ciw.wageAllocation;
                    ciw.matchingWageLP.Status__c = 'Posted';
                    
                    for(Judgment_Payment__c jp : ciw.matchingRedundantWageJPsArray){   
                        jp.Posted_Amount__c = ciw.wageAllocation;
                        jp.Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId;
                        jp.Status__c = 'Posted';
                    }
                }
            }
            if(ciw.matchingWageInterestLP != null){
                ciw.matchingWageInterestLP.Case_Violation__c = ciw.thisCaseIssue.Id; // Updating this field here because a lot of the records in PROD have this field blank
                ciw.matchingWageInterestLP.Liability__c = ciw.relevantLiability.Id; // Updating this field here because a lot of the records in PROD have this field blank
                ciw.matchingWageInterestLP.Payment_on_Behalf_of__c = ciw.relevantPoboLiablePartyId;

                if(whichButtonClicked == 'Recommend'){
                    ciw.matchingWageInterestLP.Recommended_Amount__c = ciw.wageInterestAllocation;
                    ciw.matchingWageInterestLP.Status__c = 'Recommended';

                    for(Judgment_Payment__c jp : ciw.matchingRedundantWageInterestJPsArray){   
                        jp.Recommended_Amount__c = ciw.wageInterestAllocation;
                        jp.Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId;
                        jp.Status__c = 'Recommended';
                    }
                }else{ //whichButtonClicked == 'Post'
                    ciw.matchingWageInterestLP.Posted_Amount__c = ciw.wageInterestAllocation;
                    ciw.matchingWageInterestLP.Status__c = 'Posted';
                    
                    for(Judgment_Payment__c jp : ciw.matchingRedundantWageInterestJPsArray){   
                        jp.Posted_Amount__c = ciw.wageInterestAllocation;
                        jp.Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId;
                        jp.Status__c = 'Posted';
                    }
                }
            }
            if(ciw.matchingInterestLP != null){
                ciw.matchingInterestLP.Case_Violation__c = ciw.thisCaseIssue.Id;
                ciw.matchingInterestLP.Liability__c = ciw.relevantLiability.Id;
                ciw.matchingInterestLP.Payment_on_Behalf_of__c = ciw.relevantPoboLiablePartyId;

                if(whichButtonClicked == 'Recommend'){
                    ciw.matchingInterestLP.Recommended_Amount__c = ciw.interestAllocation;
                    ciw.matchingInterestLP.Status__c = 'Recommended';

                    for(Judgment_Payment__c jp: ciw.matchingRedundantInterestJPsArray){
                        jp.Recommended_Amount__c = ciw.interestAllocation;
                        jp.Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId;
                        jp.Status__c = 'Recommended';
                    }
                }else{ //whichButtonClicked == 'Post'
                    ciw.matchingInterestLP.Posted_Amount__c = ciw.interestAllocation;
                    ciw.matchingInterestLP.Status__c = 'Posted';

                    for(Judgment_Payment__c jp: ciw.matchingRedundantInterestJPsArray){
                        jp.Posted_Amount__c = ciw.interestAllocation;
                        jp.Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId;
                        jp.Status__c = 'Posted';
                    }
                }
            }
            if(ciw.matchingPenaltyLP != null){
                ciw.matchingPenaltyLP.Case_Violation__c = ciw.thisCaseIssue.Id;
                ciw.matchingPenaltyLP.Liability__c = ciw.relevantLiability.Id;
                // System.debug('108 ciw.relevantPoboLiablePartyId: ' + ciw.relevantPoboLiablePartyId);
                ciw.matchingPenaltyLP.Payment_on_Behalf_of__c = ciw.relevantPoboLiablePartyId;

                if(whichButtonClicked == 'Recommend'){
                    ciw.matchingPenaltyLP.Recommended_Amount__c = ciw.penaltyAllocation;
                    ciw.matchingPenaltyLP.Status__c = 'Recommended';

                    for(Judgment_Payment__c jp: ciw.matchingRedundantPenaltyJPsArray){
                        jp.Recommended_Amount__c = ciw.penaltyAllocation;
                        jp.Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId;
                        jp.Status__c = 'Recommended';
                    }
                }else{ //whichButtonClicked == 'Post'
                    ciw.matchingPenaltyLP.Posted_Amount__c = ciw.penaltyAllocation;
                    ciw.matchingPenaltyLP.Status__c = 'Posted';

                    for(Judgment_Payment__c jp: ciw.matchingRedundantPenaltyJPsArray){
                        jp.Posted_Amount__c = ciw.penaltyAllocation;
                        jp.Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId;
                        jp.Status__c = 'Posted';
                    }
                }
            }
        }
    }
}