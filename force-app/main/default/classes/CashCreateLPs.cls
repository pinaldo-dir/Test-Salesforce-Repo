//Create LPs from CIW allocations.
// On Cases with Judgments, the CashCreateRedundantJPs class creates JPs with funds redundant the LPs created here as an accounting device/convenience.
public with sharing class CashCreateLPs{
    public static List<Liability_Payment__c> createLPs(List<CashCaseIssueWrapper> caseIssueWrapperList,
                                                        Case_Payment__c casePayment,
                                                        String whichButtonClicked)
        {
        List<Liability_Payment__c> createdLPs = new List<Liability_Payment__c>();

        for(CashCaseIssueWrapper ciw : caseIssueWrapperList){
            if(ciw.wageAllocation > 0 && ciw.matchingWageLP == NULL){
                Liability_Payment__c newWageLP = new Liability_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Wages',
                    Assessment__c = ciw.caseIssueAssessment.Id,
                    Liability__c = ciw.relevantLiability.Id,
                    Case_Violation__c = ciw.thisCaseIssue.Id,
                    Case_Issue_RecordTypeId__c = ciw.caseIssueRecordTypeId,
                    Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId
                );
                if(whichButtonClicked == 'Recommend'){
                    newWageLP.Recommended_Amount__c = ciw.wageAllocation;
                    newWageLP.Status__c = 'Recommended';
                }else{
                    newWageLP.Posted_Amount__c = ciw.wageAllocation;
                    newWageLP.Status__c = 'Posted';
                }
                createdLPs.add(newWageLP);
            }
            if(ciw.wageInterestAllocation > 0 && ciw.matchingWageInterestLP == NULL){
                Liability_Payment__c newWageInterestLP = new Liability_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Wage Interest',
                    Assessment__c = ciw.caseIssueAssessment.Id,
                    Liability__c = ciw.relevantLiability.Id,
                    Case_Violation__c = ciw.thisCaseIssue.Id,
                    Case_Issue_RecordTypeId__c = ciw.caseIssueRecordTypeId,
                    Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId
                );
                if(whichButtonClicked == 'Recommend'){
                    newWageInterestLP.Recommended_Amount__c = ciw.wageInterestAllocation;
                    newWageInterestLP.Status__c = 'Recommended';
                }else{
                    newWageInterestLP.Posted_Amount__c = ciw.wageInterestAllocation;
                    newWageInterestLP.Status__c = 'Posted';
                }
                createdLPs.add(newWageInterestLP);
            }
            if(ciw.penaltyAllocation > 0 && ciw.matchingPenaltyLP == NULL){
                Liability_Payment__c newPenaltyLP = new Liability_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Penalties',
                    Assessment__c = ciw.caseIssueAssessment.Id,
                    Liability__c = ciw.relevantLiability.Id,
                    Case_Violation__c = ciw.thisCaseIssue.Id,
                    Case_Issue_RecordTypeId__c = ciw.caseIssueRecordTypeId,
                    Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId
                );
                if(whichButtonClicked == 'Recommend'){
                    newPenaltyLP.Recommended_Amount__c = ciw.penaltyAllocation;
                    newPenaltyLP.Status__c = 'Recommended';
                }else{
                    newPenaltyLP.Posted_Amount__c = ciw.penaltyAllocation;
                    newPenaltyLP.Status__c = 'Posted';
                }
                createdLPs.add(newPenaltyLP);
            }
            if(ciw.interestAllocation > 0 && ciw.matchingInterestLP == NULL){
                Liability_Payment__c newInterestLP = new Liability_Payment__c(
                    Case_Payment__c = casePayment.Id,
                    Payment_Applied_To__c = 'Interest',
                    Assessment__c = ciw.caseIssueAssessment.Id,
                    Liability__c = ciw.relevantLiability.Id,
                    Case_Violation__c = ciw.thisCaseIssue.Id,
                    Case_Issue_RecordTypeId__c = ciw.caseIssueRecordTypeId,
                    Payment_On_Behalf_Of__c = ciw.relevantPoboLiablePartyId
                );
                if(whichButtonClicked == 'Recommend'){
                    newInterestLP.Recommended_Amount__c = ciw.interestAllocation;
                    newInterestLP.Status__c = 'Recommended';
                }else{
                    newInterestLP.Posted_Amount__c = ciw.interestAllocation;
                    newInterestLP.Status__c = 'Posted';
                }
                createdLPs.add(newInterestLP);
            }
        }
        return createdLPs;
    }
}