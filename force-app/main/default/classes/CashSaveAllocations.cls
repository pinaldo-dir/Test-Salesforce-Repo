/*This class is called from the cashCasePaymentAllocation.js controller. It handles, along with dependent subclasses, saving recommended allocations (aka "Recommend") and
posting recommended allocations (aka "Post").

"Recommend" has to do 3 things:
    1) match the Case Issue Wrapper (CIW) allocations made in the Case Issue table on the LWC with any existing LPs
            and any 'redundant,' 'Judgment Amount' JPs, (iow, we're 're-recommending') and update any changes.
        If an allocation exists without an existing LP (iow, we're recommending a CP for the first time),
            create a new LP and new 'redundant,' 'Judgment Amount' JPs if needed.
        There should be a separate 'redundant' JP created for each Liable Party on a Case Issue where each Liable Party has a Judgment. IOW, if a
            Case has multiple Judgments, there'll probably be a 'redundant' JP created for each Judgment, each for the same amount. (Verify with
            the business--this seemingly changes all the time).
    2) match the Judgment Wrapper (JW) allocations with any existing JPs and update any changes. If an allocation exists without a JP, create a new JP for it. 
    3) match the CU1W (wrapper pseudo-class for the CU-1 fields) allocations with any existing LPs of that type. If an allocation exists without an LP,
            create a new LP for it.

"Post" pretty much is exactly like "Recommend" in that it has to do the same 3 things, but also needs to do:
    1) CP.Status updated to Posted instead of Allocations Recommended.
    2) CP.Record Type updated to Posted.
    3) LP and JP Posted_Amount__c fields are populated instead of LP and JP Recommended_Amount__c.
    4) Payment Records are created for LPs and non-'Judgment Amount' JPs, if the RCT has been deposited.

TODO: Applied Accounting Code records are created in the LiabilityPaymentTrigger/LiabilityPaymentMethods classes. Maybe it would make more sense to create them here?
TODO: LP and JP record types - set from parent violation or Judgment? */

public without sharing class CashSaveAllocations {
    @AuraEnabled(cacheable=false) //****must be called from JS imperatively, i.e. without @wire */
    public static void saveAllocations(Receipt__c receipt, Case_Payment__c casePayment, String whichButtonClicked, String ppIdString, //TODO: yea, yea, yea, way too many parameters
            List<CashCu1Wrapper> cu1WrapperList, List<CashCaseIssueWrapper> caseIssueWrapperList, List<CashJudgmentWrapper> judgmentWrapperList,
            List<Liable_Party__c> allLiablePartyList, List<Liability_Judgement__c> allJudgmentPartyList, List<SObject> recordsToDelete){
        
        Savepoint sp = Database.setSavePoint();

        try{

            //Delete old LPs and JPs
            if(recordsToDelete.size() > 0){
                /* //Would get random DLRS failures trying to delete, so shutting off Trigger Settings here for now.
                //  TODO: remove DLRSs from cashiering objects, rework other Triggers if needed, so we don't have to do this.
                List<Trigger_Settings__c> triggerSettings = [SELECT Id, Name, Is_Active__c
                                                                FROM Trigger_Settings__c
                                                                WHERE Is_Active__c = TRUE];
                for(Trigger_Settings__c triggerSetting : triggerSettings){
                    triggerSetting.Is_Active__c = false;
                }
                update triggerSettings; */

                delete recordsToDelete;

                /* for(Trigger_Settings__c triggerSetting : triggerSettings){
                    triggerSetting.Is_Active__c = true;
                }
                update triggerSettings; */
            }

            if(whichButtonClicked == 'PostPartyPayment'){
                insert receipt;
                casePayment.Receipt__c = receipt.Id;
                casePayment.Status__c = 'Posted';
                casePayment.Case_Payment_Posted_Date__c = Date.today();
                casePayment.RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('Posted').getRecordTypeId();
            }else if(whichButtonClicked == 'Recommend'){
                casePayment.Status__c = 'Allocations Recommended';
                casePayment.Case_Payment_Recommended_Date__c = Date.today();
            }else{
                casePayment.Status__c = 'Posted';
                casePayment.Case_Payment_Posted_Date__c = Date.today();
                casePayment.RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('Posted').getRecordTypeId();
            }

            if(ppIdString == 'NONE'){
                casePayment.Payment_Plan__c = null;
            }else{
                casePayment.Payment_Plan__c = ppIdString;
            }

            //Save non-LP CU-1 fields that are on the CP
            for(CashCu1Wrapper cu1w : cu1WrapperList){
                if(cu1w.typeIsPaymentClassification){
                    casePayment.Payment_Classification__c = cu1w.paymentClassificationPicklist;
                    casePayment.Special_Instructions__c = cu1w.paymentClassificationSpecialInstructions;
                }else if(cu1w.typeIsPaymentTerms){
                    casePayment.Payment_Terms__c = cu1w.paymentTermsPicklist;
                    casePayment.Payment_Terms_Other__c = cu1w.paymentTermsOtherExplanation;
                }else if(cu1w.typeIsFundsMailedToEmployee){
                    if(cu1w.fundsMailedToEmployeeDateString == '' || cu1w.fundsMailedToEmployeeDateString == null){
                        casePayment.Date_Funds_Mailed_to_Employee__c = null;
                    }else{
                        casePayment.Date_Funds_Mailed_to_Employee__c = Date.valueOf(cu1w.fundsMailedToEmployeeDateString);
                    }
                    casePayment.Mailing_Instructions__c = cu1w.fundsMailedToEmployeeInstructionsPicklist;
                }else if(cu1w.typeIsRefund){ //The "Refund", "Amounts Due to DIR", and "Other" fields are on LPs, but also updated here for display on the CP without the need for roll-ups.
                    casePayment.Refund_Amount__c = cu1w.refundAmount;
                    casePayment.Refund_Amount_Details__c = cu1w.refundAmountDetails;
                }else if(cu1w.typeIsAmtDueToDIR){
                    casePayment.Amounts_Due_to_DIR__c = cu1w.amtDueToDir;
                    casePayment.Amounts_Due_to_DIR_Explanation__c = cu1w.amtDueToDirExplanation;
                }else if(cu1w.typeIsOther){
                    casePayment.Other_Amount__c = cu1w.otherAmount;
                    casePayment.Other_Amount_Details__c = cu1w.otherAmountDetails;
                }
                // else if(cu1w.typeIsHold){
                //     casePayment.Hold_Amount__c = cu1w.holdAmount;
                //     casePayment.Hold_Explanation__c = cu1w.holdExplanation;
                //     casePayment.Hold_For__c = cu1w.holdForPicklist;
                //     casePayment.Hold_For_Other__c = cu1w.holdForOther;
                //     casePayment.Hold_Review_Date__c = cu1w.holdReviewDate;
                // }
            }

            upsert casePayment;

            System.debug('112 casePayment: ' + casePayment);

            List<Liability_Payment__c> cu1sToUpdate = new List<Liability_Payment__c>();
            List<Liability_Payment__c> cu1sToInsert = new List<Liability_Payment__c>();
            List<Liability_Payment__c> allCu1List = new List<Liability_Payment__c>();

            List<Liability_Payment__c> lpsToUpdate = new List<Liability_Payment__c>();
            List<Liability_Payment__c> lpsToInsert = new List<Liability_Payment__c>();
            List<Liability_Payment__c> allLpList = new List<Liability_Payment__c>();

            List<Judgment_Payment__c> jpsToUpdate = new List<Judgment_Payment__c>();
            List<Judgment_Payment__c> jpsToInsert = new List<Judgment_Payment__c>();
            List<Judgment_Payment__c> allJpList = new List<Judgment_Payment__c>();

            //If there are no pre-existing CU-1 LPs, the following method call won't do anything.
            CashUpdateMatchedCU1s.updateMatchedCU1s(cu1WrapperList, whichButtonClicked);

            for(CashCu1Wrapper cu1w : cu1WrapperList){
                if(cu1w.matchingLP != null &&
                    ((cu1w.typeIsRefund && cu1w.refundAmount > 0) ||
                    (cu1w.typeIsAmtDueToDIR && cu1w.amtDueToDir > 0) ||
                    (cu1w.typeIsOther && cu1w.otherAmount > 0))){
                    cu1sToUpdate.add(cu1w.matchingLP);
                }
            }

            cu1sToInsert.addAll(CashCreateCU1s.createCU1s(cu1WrapperList, casePayment, whichButtonClicked));

            allCu1List.addAll(cu1sToInsert);
            allCu1List.addAll(cu1sToUpdate);
            upsert allCu1List;

            //Requery CU-1s to bring in CU1.CP.RCT.Payor__c for later processing (CashCreatePrsQable, determining if a Payor Payee is the same Payor on the RCT).
            allCu1List = [SELECT Id, Name, Payment_Applied_To__c, Payment_On_Behalf_Of__c, Recommended_Amount__c, Posted_Amount__c, Status__c, 
                                Refund_Amount_Details__c, Amounts_Due_to_DIR_Explanation__c	, Other_Amount_Details__c, Case_Payment__c, Case_Payment__r.Receipt__r.Payor__c
                            FROM Liability_Payment__c
                            WHERE Id IN :allCu1List];

            //Existing LPs have been matched with CIWs already in the JS constructor.
            //  Determine the correct Liability and Payment_On_Behalf_Of__c the CIW looks up to,
            //  then update any fields on those matched LPs as necessary.
            //  Also update fields on any linked 'redundant' 'Judgment Amount' JPs.
            CashUpdateMatchedLPs.updateMatchedLPs(caseIssueWrapperList, allLiablePartyList, whichButtonClicked);

            for(CashCaseIssueWrapper ciw : caseIssueWrapperList){
                if(ciw.matchingPenaltyLP != null && ciw.penaltyAllocation > 0){
                    lpsToUpdate.add(ciw.matchingPenaltyLP);
                    jpsToUpdate.addAll(ciw.matchingRedundantPenaltyJPsArray);
                }
                if(ciw.matchingInterestLP != null && ciw.interestAllocation > 0){
                    lpsToUpdate.add(ciw.matchingInterestLP);
                    jpsToUpdate.addAll(ciw.matchingRedundantInterestJPsArray);
                }
                if(ciw.matchingWageLP != null && ciw.wageAllocation > 0){
                    lpsToUpdate.add(ciw.matchingWageLP);
                    jpsToUpdate.addAll(ciw.matchingRedundantWageJPsArray);
                }
                if(ciw.matchingWageInterestLP != null && ciw.wageInterestAllocation > 0){
                    lpsToUpdate.add(ciw.matchingWageInterestLP);
                    jpsToUpdate.addAll(ciw.matchingRedundantWageInterestJPsArray);
                }
            }

            //Create LPs from CIWs for new allocations that don't have pre-existing matching LPs.
            lpsToInsert.addAll(CashCreateLPs.createLPs(caseIssueWrapperList, casePayment, whichButtonClicked));
            
            update lpsToUpdate;
            insert lpsToInsert; //Must be inserted separately for call to createRedundantJPs() below.

            //Create 'redundant' 'Judgment Amount' JPs related to the LPs just created above, if needed.
            jpsToInsert.addAll(CashCreateRedundantJPs.createRedundantJPs(lpsToInsert, casePayment, whichButtonClicked));

            //Existing JPs have been matched with JWs already in the JW constructor.
            //  Determine correct Judgment and Payment_On_Behalf_Of__c the JW looks up to,
            //  then update any fields on those matched JPs as necessary.
            //  (Essentially the same algorithm as with the matching CIW allocations to LPs, above.)
            CashUpdateMatchedJPs.updateMatchedJPs(judgmentWrapperList, allJudgmentPartyList, whichButtonClicked);

            for(CashJudgmentWrapper jw : judgmentWrapperList){
                if(jw.matchingPostHearingInterestJP != null && jw.postHearingInterestAllocation > 0){
                    jpsToUpdate.add(jw.matchingPostHearingInterestJP);
                }
                if(jw.matchingPostJudgmentInterestJP != null && jw.postJudgmentInterestAllocation > 0){
                    jpsToUpdate.add(jw.matchingPostJudgmentInterestJP);
                }
                if(jw.matchingAttorneyFeeJP != null && jw.attorneyFeesAllocation > 0){
                    jpsToUpdate.add(jw.matchingAttorneyFeeJP);
                }
                if(jw.matchingFilingFeeJP != null && jw.filingFeesAllocation > 0){
                    jpsToUpdate.add(jw.matchingFilingFeeJP);
                }
            }

            //Create JPs from JWs for new allocations that don't have pre-existing matching JPs.
            jpsToInsert.addAll(CashCreateJPs.createJPs(judgmentWrapperList, casePayment, whichButtonClicked));

            allJpList.addAll(jpsToInsert);
            allJpList.addAll(jpsToUpdate);
            upsert allJpList;


            if(whichButtonClicked == 'Post' && (casePayment.Payment_Exchange__c == 'Division Payment' && casePayment.Deposited__c)){

                List<Payment_Record__c> prsToInsert = new List<Payment_Record__c>();
                allLpList.addAll(lpsToInsert);
                allLpList.addAll(lpsToUpdate);

                //Query for and validate Payees. validatePayees() returns an empty list if there are no Payees, obviously (which could be valid e.g. when
                // a Penalty payment is deposited to a Deposit Account other than 32-117), or if the Payees fail validation.
                List<Payee__c> allPayeeList = CashValidatePayees.validatePayees(cu1WrapperList, caseIssueWrapperList, judgmentWrapperList, casePayment);

                if(!allPayeeList.isEmpty()){

                    System.enqueueJob(new CashCreatePrsQable(casePayment, allPayeeList, allCu1List, allLpList, allJpList));
                }
            }

        }catch(Exception e){

            Database.rollback(sp);
            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();
            throw new AuraHandledException(errorMessage);

        }

    }

}