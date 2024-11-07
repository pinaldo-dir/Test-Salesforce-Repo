//Create LPs for CU1W allocations--"Refund", "Amounts Due to DIR", and "Other" amount and related fields. 
//  CU-1 fields without a related amount--"Payment Classification", "Payment Terms", and "Funds Mailed to Employee" are only updated on the CP.
public with sharing class CashCreateCU1s{
    public static List<Liability_Payment__c> createCU1s(List<CashCu1Wrapper> cu1WrapperList,
                                                            Case_Payment__c casePayment,
                                                            String whichButtonClicked) {
        
        List<Liability_Payment__c> createdCU1s = new List<Liability_Payment__c>();

        for(CashCu1Wrapper cu1w : cu1WrapperList){
            if(cu1w.refundAmount > 0 && cu1w.matchingLP == NULL){
                System.debug('12 cu1w.relevantPoboLiablePartyId: ' + cu1w.relevantPoboLiablePartyId);
                Liability_Payment__c newRefundLP = new Liability_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Refund Amount',
                    Payment_On_Behalf_Of__c = cu1w.relevantPoboLiablePartyId,
                    Refund_Amount_Details__c = cu1w.refundAmountDetails
                );
                if(whichButtonClicked == 'Recommend'){
                    newRefundLP.Recommended_Amount__c = cu1w.refundAmount;
                    newRefundLP.Status__c = 'Recommended';
                }else{
                    newRefundLP.Posted_Amount__c = cu1w.refundAmount;
                    newRefundLP.Status__c = 'Posted';
                }
                createdCU1s.add(newRefundLP);
            }
            if(cu1w.amtDueToDir > 0 && cu1w.matchingLP == NULL){
                Liability_Payment__c newAmtDueToDirLP = new Liability_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Amounts Due to DIR',
                    Payment_On_Behalf_Of__c = cu1w.relevantPoboLiablePartyId,
                    Amounts_Due_to_DIR_Explanation__c = cu1w.amtDueToDirExplanation
                );
                if(whichButtonClicked == 'Recommend'){
                    newAmtDueToDirLP.Recommended_Amount__c = cu1w.amtDueToDir;
                    newAmtDueToDirLP.Status__c = 'Recommended';
                }else{
                    newAmtDueToDirLP.Posted_Amount__c = cu1w.amtDueToDir;
                    newAmtDueToDirLP.Status__c = 'Posted';
                }
                createdCU1s.add(newAmtDueToDirLP);
            }
            if(cu1w.otherAmount > 0 && cu1w.matchingLP == NULL){
                Liability_Payment__c newOtherLP = new Liability_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Other Amount',
                    Payment_On_Behalf_Of__c = cu1w.relevantPoboLiablePartyId,
                    Other_Amount_Details__c = cu1w.otherAmountDetails
                );
                if(whichButtonClicked == 'Recommend'){
                    newOtherLP.Recommended_Amount__c = cu1w.otherAmount;
                    newOtherLP.Status__c = 'Recommended';
                }else{
                    newOtherLP.Posted_Amount__c = cu1w.otherAmount;
                    newOtherLP.Status__c = 'Posted';
                }
                createdCU1s.add(newOtherLP);
            }
        }
        return createdCu1s;
    }
}