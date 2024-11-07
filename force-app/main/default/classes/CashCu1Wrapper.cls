public with sharing class CashCu1Wrapper{
    
    @AuraEnabled
    public String cu1Type{get;set;}
    @AuraEnabled
    public Liability_Payment__c matchingLp{get;set;} //Only 'Refund', 'Amounts Due to DIR', and 'Other' cu1Types may have a matchingLp.
    
    @AuraEnabled
    public Id relevantPoboLiablePartyId{get;set;} //This is a Liable Party Id, the same as the LP.Payment_On_Behalf_Of__c field.
                                                  //  (cf 'selectedPobo' here and in the main js class, a Case Role Id, which is
                                                  //  used to populate the POBO dropdown).
    
    @AuraEnabled
    public Boolean typeIsPaymentClassification{get;set;} // These booleans may seem somewhat redundant with cu1Type, but they are used for if:true conditionals in the html file.
    @AuraEnabled
    public String paymentClassificationPicklist{get;set;}
    @AuraEnabled
    public String paymentClassificationSpecialInstructions{get;set;}
    
    @AuraEnabled
    public Boolean typeIsPaymentTerms{get;set;}
    @AuraEnabled
    public String paymentTermsPicklist{get;set;}
    @AuraEnabled
    public String paymentTermsOtherExplanation{get;set;}
    
    @AuraEnabled
    public Boolean typeIsFundsMailedToEmployee{get;set;}
    @AuraEnabled
    public String fundsMailedToEmployeeDateString{get;set;} //needs to be a String, not a Date, because Apex doesn't like being passed a '' or null Date parameter from JS.
                                                            // Default this to '' empty string.
    @AuraEnabled
    public String fundsMailedToEmployeeInstructionsPicklist{get;set;}
    
    @AuraEnabled
    public Boolean typeIsRefund{get;set;}
    @AuraEnabled
    public Decimal refundAmount{get;set;}
    @AuraEnabled
    public String refundAmountDetails{get;set;}
    
    @AuraEnabled
    public Boolean typeIsAmtDueToDIR{get;set;}
    @AuraEnabled
    public Decimal amtDueToDir{get;set;}
    @AuraEnabled
    public String amtDueToDirExplanation{get;set;}
    
    @AuraEnabled
    public Boolean typeIsOther{get;set;}
    @AuraEnabled
    public Decimal otherAmount{get;set;}
    @AuraEnabled
    public String otherAmountDetails{get;set;}
    
    public CashCu1Wrapper(){} //No-arg constructor seems to be required for some reason.

    public CashCu1Wrapper(String type){

        if(type == 'Payment Classification'){
            cu1Type = type;
            typeIsPaymentClassification = true;
            typeIsPaymentTerms = false;
            typeIsFundsMailedToEmployee = false;
            typeIsRefund = false;
            typeIsAmtDueToDIR = false;
            typeIsOther = false;
            paymentClassificationPicklist = '';
            paymentClassificationSpecialInstructions = '';
        }
        if(type == 'Payment Terms'){
            cu1Type = type;
            typeIsPaymentClassification = false;
            typeIsPaymentTerms = true;
            typeIsFundsMailedToEmployee = false;
            typeIsRefund = false;
            typeIsAmtDueToDIR = false;
            typeIsOther = false;
            paymentTermsPicklist = '';
            paymentTermsOtherExplanation = '';    
        }
        if(type == 'Funds Mailed To Employee'){
            cu1Type = type;
            typeIsPaymentClassification = false;
            typeIsPaymentTerms = false;
            typeIsFundsMailedToEmployee = true;
            typeIsRefund = false;
            typeIsAmtDueToDIR = false;
            typeIsOther = false;
            fundsMailedToEmployeeDateString = '';
            fundsMailedToEmployeeInstructionsPicklist = '';
        }
        if(type == 'Refund'){
            cu1Type = type;
            typeIsPaymentClassification = false;
            typeIsPaymentTerms = false;
            typeIsFundsMailedToEmployee = false;
            typeIsRefund = true;
            typeIsAmtDueToDIR = false;
            typeIsOther = false;
            refundAmount = 0;
            refundAmountDetails = '';
        }
        if(type == 'Amounts Due to DIR'){
            cu1Type = type;
            typeIsPaymentClassification = false;
            typeIsPaymentTerms = false;
            typeIsFundsMailedToEmployee = false;
            typeIsRefund = false;
            typeIsAmtDueToDIR = true;
            typeIsOther = false;
            amtDueToDir = 0;
            amtDueToDirExplanation = '';
        }
        if(type == 'Other'){
            cu1Type = type;
            typeIsPaymentClassification = false;
            typeIsPaymentTerms = false;
            typeIsFundsMailedToEmployee = false;
            typeIsRefund = false;
            typeIsAmtDueToDIR = false;
            typeIsOther = true;
            otherAmount = 0;
            otherAmountDetails = '';
        }
    }

    @AuraEnabled
    //public static List<CashCu1Wrapper> createCu1WrapperList(List<Liability_Payment__c> lpList, List<Liable_Party__c> liablePartyList, String selectedPobo){
    public static List<CashCu1Wrapper> createCu1WrapperList(List<Liability_Payment__c> lpList, List<Liable_Party__c> liablePartyList, String selectedPobo){
        System.debug('131 selectedPobo: ' + selectedPobo);
        System.debug('132 liablePartyList: ' + liablePartyList);
        List<CashCu1Wrapper> cu1WrapperList = new List<CashCu1Wrapper>();

        cu1WrapperList.add(new CashCu1Wrapper('Payment Classification'));
        cu1WrapperList.add(new CashCu1Wrapper('Payment Terms'));
        cu1WrapperList.add(new CashCu1Wrapper('Funds Mailed To Employee'));
        cu1WrapperList.add(new CashCu1Wrapper('Refund'));
        cu1WrapperList.add(new CashCu1Wrapper('Amounts Due to DIR'));
        cu1WrapperList.add(new CashCu1Wrapper('Other'));

        for(Liability_Payment__c lp : lpList){
            for(CashCu1Wrapper cu1w : cu1WrapperList){
                if(lp.Payment_Applied_To__c == 'Refund Amount' && cu1w.typeIsRefund){
                    cu1w.refundAmount = (lp.Posted_Amount__c == 0 || lp.Posted_Amount__c == null) ? lp.Recommended_Amount__c : lp.Posted_Amount__c;
                    cu1w.refundAmountDetails = lp.Refund_Amount_Details__c;
                    cu1w.relevantPoboLiablePartyId = lp.Payment_On_Behalf_Of__c;
                    cu1w.matchingLp = lp;
                }
                if(lp.Payment_Applied_To__c == 'Amounts Due to DIR' && cu1w.typeIsAmtDueToDIR){
                    cu1w.amtDueToDir = (lp.Posted_Amount__c == 0 || lp.Posted_Amount__c == null) ? lp.Recommended_Amount__c : lp.Posted_Amount__c;
                    cu1w.amtDueToDirExplanation = lp.Amounts_Due_to_DIR_Explanation__c;
                    cu1w.relevantPoboLiablePartyId = lp.Payment_On_Behalf_Of__c;
                    cu1w.matchingLp = lp;
                }
                if(lp.Payment_Applied_To__c == 'Other Amount' && cu1w.typeIsOther){
                    cu1w.otherAmount = (lp.Posted_Amount__c == 0 || lp.Posted_Amount__c == null) ? lp.Recommended_Amount__c : lp.Posted_Amount__c;
                    cu1w.otherAmountDetails = lp.Other_Amount_Details__c;
                    cu1w.relevantPoboLiablePartyId = lp.Payment_On_Behalf_Of__c;
                    cu1w.matchingLp = lp;
                }
            }
        }

        for(CashCu1Wrapper cu1w : cu1WrapperList){
            for(Liable_Party__c liableParty : liablePartyList){
                if(selectedPobo != 'ALL' && selectedPobo == liableParty.Case_Role__c){
                    cu1w.relevantPoboLiablePartyId = liableParty.Id;
                }
            }
        }

        System.debug('172 cu1WrapperList: ' + cu1WrapperList);

        return cu1WrapperList;
    }
}