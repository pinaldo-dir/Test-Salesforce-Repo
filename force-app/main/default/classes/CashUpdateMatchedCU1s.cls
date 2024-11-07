//Match CU1W allocations to existing CU-1 LPs, if any.
public with sharing class CashUpdateMatchedCU1s {
    public static void updateMatchedCU1s(List<CashCu1Wrapper> cu1WrapperList,
                                            /* List<Liable_Party__c> allLiablePartyList,  //Commented out because relevantPoboLiablePartyId should already have been set in JS
                                            String selectedPobo, //Case_Role__c Id //Commented out because relevantPoboLiablePartyId should already have been set in JS */
                                            String whichButtonClicked)
        {
        for(CashCu1Wrapper cu1w : cu1WrapperList){
            /* Commented out because cu1w.relevantPoboLiablePartyId should already have been set in JS, thus is contained in the cu1WrapperList
            //  Determine correct Payment_On_Behalf_Of__c the LP should look up to.
            //    TODO: How might this be affected by cases with multiple Liable Parties?
            for(Liable_Party__c liableParty : allLiablePartyList){
                if(selectedPobo == liableParty.Case_Role__c){
                    cu1w.relevantPoboLiablePartyId = liableParty.Id;
                }
            } */

            //  If the recommended amounts are different in the CU1W than in it's matching LP, update the LP,
            //    even if $0 (meaning a previous recommended amount has been removed, but we're still keeping the record for historical purposes).
            if(cu1w.matchingLp != null){
                cu1w.matchingLp.Payment_On_Behalf_Of__c = cu1w.relevantPoboLiablePartyId; //TODO: does this field really need to be on the CU1W? also review for this field on the CIW and JW
                cu1w.matchingLp.Refund_Amount_Details__c = cu1w.refundAmountDetails;
                cu1w.matchingLp.Amounts_Due_to_DIR_Explanation__c	 = cu1w.amtDueToDirExplanation;
                cu1w.matchingLp.Other_Amount_Details__c = cu1w.otherAmountDetails;

                if(whichButtonClicked == 'Recommend'){
                    cu1w.matchingLp.Status__c = 'Recommended'; //TODO: verify these are needed here, cf. CashUpdateMatchedLPs
                    if(cu1w.typeIsRefund){
                        cu1w.matchingLp.Recommended_Amount__c = cu1w.refundAmount;
                    }
                    if(cu1w.typeIsAmtDueToDIR){
                        cu1w.matchingLp.Recommended_Amount__c = cu1w.amtDueToDir;
                    }
                    if(cu1w.typeIsOther){
                        cu1w.matchingLp.Recommended_Amount__c = cu1w.otherAmount;
                    }
                }else{
                    cu1w.matchingLp.Status__c = 'Posted';
                    if(cu1w.typeIsRefund){
                        cu1w.matchingLp.Posted_Amount__c = cu1w.refundAmount;
                    }
                    if(cu1w.typeIsAmtDueToDIR){
                        cu1w.matchingLp.Posted_Amount__c = cu1w.amtDueToDir;
                    }
                    if(cu1w.typeIsOther){
                        cu1w.matchingLp.Posted_Amount__c = cu1w.otherAmount;
                    }
                }
            }
        }        
    }
}