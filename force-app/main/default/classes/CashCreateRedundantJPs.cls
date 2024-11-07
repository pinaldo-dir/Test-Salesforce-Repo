//On a Case with active Judgments, JPs with Payment_Applied_To__c == "Judgment Amount" need to be created in the same amount as each LP created.
//  These funds are redundant with that LP's funds--these JPs are a record-keeping, amount-rollup convenience.
//  There should be one of these "redundant" JPs created for Judgments where that Judgment's Judgment Party's Liable Party is under that LP's Liability. It's confusing, right?
//     LP -> Liability <- Liable Party <- Judgment Party -> Judgment
//  The new redundant JP's POBO though, will be the LP's POBO, not necessarily the related Judgment Party.
public with sharing class CashCreateRedundantJPs{    
    public static List<Judgment_Payment__c> createRedundantJPs(List<Liability_Payment__c> lps, Case_Payment__c casePayment, String whichButtonClicked){
        List<Judgment_Payment__c> redundantJPs = new List<Judgment_Payment__c>();
        Set<Id> relevantLiabilityIds = new Set<Id>();

        for(Liability_Payment__c lp : lps){
            relevantLiabilityIds.add(lp.Liability__c);
        }

        List<Liability_Judgement__c> relevantJudgmentParties = [SELECT Id, Name, Judgement__c, Liable_Party__c, Liable_Party__r.Liability__c
                                                                    FROM Liability_Judgement__c
                                                                    WHERE Liable_Party__r.Liability__c IN :relevantLiabilityIds
                                                                    WITH SECURITY_ENFORCED];
        
        for(Liability_Payment__c lp : lps){
            Id previousJudgment;
            for(Liability_Judgement__c judgmentParty : relevantJudgmentParties){
                if(judgmentParty.Judgement__c != previousJudgment){ //For the rare Case that has multiple Judgment Parties under one Judgment,
                                                                    //  prevent creating more than one JP per Judgment - SR-010919
                    if(lp.Liability__c == judgmentParty.Liable_Party__r.Liability__c){
                        Judgment_Payment__c jp = new Judgment_Payment__c(
                            Payment_Applied_To__c = 'Judgment Amount',
                            Case_Payment__c = casePayment.Id,
                            Funds_Redundant_With__c = lp.Id,
                            Judgment__c = judgmentParty.Judgement__c,
                            Payment_On_Behalf_Of__c = lp.Payment_On_Behalf_Of__c
                        );
                        if(whichButtonClicked == 'Recommend'){
                            jp.Recommended_Amount__c = lp.Recommended_Amount__c;
                            jp.Status__c = 'Recommended';
                        }else{
                            jp.Posted_Amount__c = lp.Posted_Amount__c;
                            jp.Status__c = 'Posted';
                        }
                        redundantJPs.add(jp);
                        
                        previousJudgment = judgmentParty.Judgement__c;
                    }
                }
            }
        }
        return redundantJPs;
    }
}