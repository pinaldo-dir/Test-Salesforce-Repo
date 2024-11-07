/*************************************************************************************************
Class     :  ReturnedVoidedReceipt.cls
Modified  :  May 2022 - Cashiering Enhancement Project, Phase 2
Objective :  This class creates negative amount (aka "Corrective Entry") cashiering object
                records--Receipt__c, Case_Payment__c, Liability_Payment__c, Judgment_Payment__c,
                Applied_Account_Code__c--to negate Receipt__c records marked returned or voided.
                Also creates Buyback LPs and PRs when needed.
                Called by ReceiptTrigger.trigger

*************************************************************************************************/

public class ReturnedVoidedReceipt{
    
    @future
    @TestVisible
    /* TODO: this description needs to be updated */
    /*Voiding very similar to Returning. Negative records created and linked. Differences:
    1 - Void: original RCT removed from TRN. Return: original RCT not removed from TRN. TODO: (old) make return RCT removal dependant on TRN "Pending" or "Deposited".
    2 - Void: negative CP rolls up to CM.Deposited_Funds__c. Return: negative CP does not roll up to CM.Deposited_Funds__c.
    3 - Void: negative CP.Status__c same as original CP.Status__c. Return: negative CP.Status__c = "New".
    4 - Unlike Returning, an RCT may be Voided whether or not it has been Deposited. */
    public static void voidReceipts(List<Id> triggerRctIdList){
        List<Receipt__c> triggerRctList = new List<Receipt__c>();
        Set<Id> allRctIdSet = new Set<Id>();
        List<Receipt__c> allRctList = new List<Receipt__c>();
        Map<Id, String> rctIdToVoidReasonMap = new Map<Id, String>();
        List<Case_Payment__c> cpList = new List<Case_Payment__c>();
        List<Id> cpIdList = new List<Id>();
        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
        List<Id> lpIdList = new List<Id>();
        List<Applied_Accounting_Code__c> aeacList = new List<Applied_Accounting_Code__c>();
        List<Judgment_Payment__c> jpList = new List<Judgment_Payment__c>();
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        
        //Query for trigger RCTs and their related Net or Deduction RCT Ids
        triggerRctList = [SELECT Id, Net_Receipt__r.Id, Returned_Item__c, Returned_Reason__c, Returned_Date__c, Returned_Item_Received_By__c,
                        
                            (SELECT Id, Returned_Item__c, Returned_Date__c, Returned_Reason__c, Returned_Item_Received_By__c
                                FROM Deduction_Receipts__r)
                        
                            FROM Receipt__c
                            WHERE Id IN :triggerRctIdList];

        for(Receipt__c rct : triggerRctList){
            allRctIdSet.add(rct.Id);
            
            for(Receipt__c deductionRct : rct.Deduction_Receipts__r){
                allRctIdSet.add(deductionRct.Id);
            }
        }
                
        //Re-query now for all RCTs and all needed fields.
        allRctList = [SELECT Add_Deduction__c, Adjustment__c, Bank_Location__c, Date_Received__c, Deduction_Amount__c, Deposit_Account__c,
                            Gross_Amount__c, Hold_Date__c, Id, Instrument_Number__c, Name, 
                            Office_Unit__c, Payment_Amount__c, Payment_Exchange__c, Payment_Type__c,
                            Payor__c, Receipt_Index__c, Returned_Date__c, Returned_Item__c, Returned_Item_Received_By__c, Returned_Reason__c,
                            Senior_Deputy__c, Status__c, Transaction__c, Void_Reason__c, Voided_Item__c,
                            
                            Net_Receipt__c, Net_Receipt__r.Id, Net_Receipt__r.Returned_Item__c, Net_Receipt__r.Returned_Reason__c,
                            Net_Receipt__r.Returned_Item_Received_By__c, 

                            Returned_Voided_Receipt__c, Returned_Voided_Receipt__r.Net_Receipt__c,
                            
                            (SELECT Id, Name, Net_Receipt__c, Net_Receipt__r.Id, Net_Receipt__r.Returned_Item__c, Returned_Date__c, Returned_Item__c,
                                    Returned_Item_Received_By__c, Returned_Reason__c, Void_Reason__c, Voided_Item__c
                                FROM Deduction_Receipts__r),
                                
                            (SELECT Amount_Payable_to_Employees__c, Apprenticeship_Penalties__c, CA_Apprenticeship_Council_Craft__c, CA_Apprenticeship_County__c,
                                California_Apprenticeship_Council__c, Case__c, Case__r.Id, Case__r.RecordType.Name, CMU_Reimbursement__c, CPR_Only__c, CPR_Only_Pay_Business__c, CPR_Refund__c,
                                CPR_Refund_Pay_Business__c, Deduction_Payment__c, Amounts_Due_to_DIR__c, Amounts_Due_to_DIR_Explanation__c, Hold_Amount__c,
                                Id, Name, Other_Refund__c, Payment_Amount__c, Payment_Plan__c, Public_Works_Penalties__c, Receipt__c, RecordTypeId, RecordType.Name,
                                Restitution_Fund__c, Status__c, Transmittal__c
                            FROM Case_Payments__r)

                        FROM Receipt__c
                        WHERE Id IN :allRctIdSet];

        for(Receipt__c rct : allRctList){
            rctIdToVoidReasonMap.put(rct.Id, rct.Void_Reason__c);
            
            for(Receipt__c deductionRct : rct.Deduction_Receipts__r){
                rctIdToVoidReasonMap.put(deductionRct.Id, deductionRct.Void_Reason__c);
            }
            
        }

        for(Receipt__c rct : allRctList){
            if(rct.Net_Receipt__c != null){ //This RCT is a Deduction RCT that was marked Voided. The related Net RCT will be marked Voided
                                            // eventually in the following ELSE statement.
                rct.Status__c = 'Voided';
                rct.Voided_Item__c = true;
                rct.Void_Reason__c = 'Parent Net Receipt voided. ' + rctIdToVoidReasonMap.get(rct.Id);
                if(rctIdToVoidReasonMap.get(rct.Net_Receipt__r.Id) != null){
                    rct.Void_Reason__c += '. ' + rctIdToVoidReasonMap.get(rct.Net_Receipt__r.Id);
                }
            }else{ //This RCT is a Net RCT that was marked Voided.
                rct.Status__c = 'Voided';
                rct.Voided_Item__c = true;
                for(Receipt__c deductionRct : rct.Deduction_Receipts__r){
                    if(rctIdToVoidReasonMap.get(deductionRct.Id) != null){
                        rct.Void_Reason__c += '. ' + rctIdToVoidReasonMap.get(deductionRct.Id);
                    }
                }
            }
        }

        //Turn off the ReceiptTrigger to prevent this class from calling itself, otherwise we get an error stating that a future method cannot call a future method.
        // Turn off other triggers too to reduce overhead, except for the LiabilityPaymentTrigger as we need that for rollups to the CI.
        // Trigger Settings managed in Setup->Custom Settings->Trigger Settings->Manage.
        List<Trigger_Settings__c> triggerSettings = [SELECT Id, Name, Is_Active__c
                                                        FROM Trigger_Settings__c
                                                        WHERE Is_Active__c = TRUE
                                                            AND Name != 'LiabilityPaymentTrigger'];
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = false;
        }
        update triggerSettings;

        update allRctList;
        
        for(Receipt__c rct : allRctList){
            cpList.addAll(rct.Case_Payments__r);
        }
        
        for(Case_Payment__c cp : cpList){
            cpIdList.add(cp.Id);
        }
        
        lpList = [SELECT Id, Name, Case_Payment__c, Liability__c, Assessment__c, Case_Violation__c, Posted_Amount__c, Payment_Applied_To__c,
                        Payment_On_Behalf_Of__c, Payment_Type__c, Recommended_Amount__c, Status__c, Case_Payment__r.Status__c, Returned_Voided_Liability_Payment__c,
                        
                        (SELECT Id, Name, Added_Manually__c, Check_Count__c, Liability_Payment__c, Receipt__c, Accounting_Code__c,
                                Violation_Accounting_Code__c, Payment_Type__c, Amount__c, Penalty_Amt__c, Interest_Amt__c
                            FROM Applied_Accounting_Codes__r),
                        
                        (SELECT Id, Name, Batched_Under_Warrant__c
                            FROM Payment_Records__r)
                    
                    FROM Liability_Payment__c
                    WHERE Case_Payment__c IN :cpIdList];
        
        for(Liability_Payment__c lp : lpList){
            aeacList.addAll(lp.Applied_Accounting_Codes__r);
            prList.addAll(lp.Payment_Records__r);
        }
        
        jpList = [SELECT Id, Name, Case_Payment__c, Judgment__c, Posted_Amount__c, Payment_Applied_To__c, Payment_On_Behalf_Of__c, Recommended_Amount__c, Status__c, Case_Payment__r.Status__c,
                        
                        (SELECT Id, Name, Batched_Under_Warrant__c
                            FROM Payment_Records__r)
                    
                    FROM Judgment_Payment__c
                    WHERE Case_Payment__c IN :cpIdList];
        
        for(Judgment_Payment__c jp : jpList){
            prList.addAll(jp.Payment_Records__r);
        }
        
        //make cashiering object records in negative amounts
        List<Receipt__c> rctsToUpsertList = new List<Receipt__c>();
        List<Case_Payment__c> cpsToUpsertList = new List<Case_Payment__c>();
        List<Liability_Payment__c> lpsToUpsertList = new List<Liability_Payment__c>();
        List<Applied_Accounting_Code__c> aeacsToInsertList = new List<Applied_Accounting_Code__c>();
        List<Judgment_Payment__c> jpsToUpsertList = new List<Judgment_Payment__c>();
        
        for(Receipt__c rct : allRctList){
            Receipt__c newNegativeRct = new Receipt__c(
                Payor__c = rct.Payor__c,
                Payment_Amount__c = rct.Payment_Amount__c == null ? null : -rct.Payment_Amount__c,
                Deduction_Amount__c = rct.Deduction_Amount__c == null ? null : -rct.Deduction_Amount__c,
                Gross_Amount__c = rct.Gross_Amount__c == null ? null : -rct.Gross_Amount__c, /*Non user-visible field for internal tracking */
                Add_Deduction__c = rct.Add_Deduction__c, /*Non user-visible field for internal tracking */
                Receipt_Index__c = rct.Receipt_Index__c, /*Non user-visible field for internal tracking */
                Deposit_Account__c = rct.Deposit_Account__c,
                Date_Received__c = Date.today(), //the negated record's Date Received is the original record's Date Returned
                Instrument_Number__c = 'Adjustment for Voiding ' + rct.Instrument_Number__c,
                Payment_Type__c = rct.Payment_Type__c,
                Bank_Location__c = rct.Bank_Location__c,
                Payment_Exchange__c = rct.Payment_Exchange__c,
                Senior_Deputy__c = rct.Senior_Deputy__c,
                Status__c = 'Corrective Entry',
                Office_Unit__c = rct.Office_Unit__c,
                Returned_Voided_Receipt__c = rct.Id,
                Adjustment__c = true
            );
            rctsToUpsertList.add(newNegativeRct);
            rct.Transaction__c = null;
            rct.Status__c = 'Voided';
            rct.Status_Date__c = Date.today();
            rctsToUpsertList.add(rct);
        }
        upsert rctsToUpsertList;
        
        //Requery to pull in any original deduction RCTs' parent net RCT.
        rctsToUpsertList = [SELECT Id, Name, Status__c, Payment_Type__c, Voided_Item__c, Returned_Voided_Receipt__c, Returned_Voided_Receipt__r.Net_Receipt__c, Net_Receipt__c
                                FROM Receipt__c
                                WHERE Id IN :rctsToUpsertList];
        
        /*Find new negative deduction RCTs and parent them to the corresponding new negative net RCTs*/
        for(Receipt__c negDedRct : rctsToUpsertList){
            if(negDedRct.Payment_Type__c == 'Deduction' && !negDedRct.Voided_Item__c){ //is a new negative deduction RCT
                for(Receipt__c negNetRct : rctsToUpsertList){
                    if(negNetRct.Payment_Type__c == 'Check' && !negNetRct.Voided_Item__c){ //is a new negative net RCT
                        System.debug('negDedRct.Returned_Voided_Receipt__c: ' + negDedRct.Returned_Voided_Receipt__c);
                        System.debug('negDedRct.Returned_Voided_Receipt__r.Net_Receipt__c: ' + negDedRct.Returned_Voided_Receipt__r.Net_Receipt__c);
                        System.debug('negNetRct.Returned_Voided_Receipt__c: '+negNetRct.Returned_Voided_Receipt__c);
                        if(negDedRct.Returned_Voided_Receipt__r.Net_Receipt__c == negNetRct.Returned_Voided_Receipt__c){
                            negDedRct.Net_Receipt__c = negNetRct.Id; 
                        }
                    }
                }
            }
        }
        upsert rctsToUpsertList;
        
        for(Case_Payment__c cp : cpList){
            for(Receipt__c newNegativeRct : rctsToUpsertList){
                if(newNegativeRct.Status__c != 'Voided'){ //original RCT was added to rctsToUpsertList for DML convenience, so we're filtering it out here
                    if(cp.Receipt__c == newNegativeRct.Returned_Voided_Receipt__c && cp.Status__c == 'Posted'){ //only create a negative CP record (and thus negatives for it's children) if the original CP was Posted.
                        Case_Payment__c newNegativeCp  = new Case_Payment__c(
                            Receipt__c = newNegativeRct.Id,
                            RecordTypeId = cp.RecordTypeId,
                            Case__c = cp.Case__c,
                            Payment_Amount__c = cp.Payment_Amount__c == null ? null : -cp.Payment_Amount__c,
                            Payment_Plan__c = cp.Payment_Plan__c,
                            //Transmittal__c = cp.Transmittal__c, //or allow newNegativeCp to be added to a new Transmittal? or no Transmittal
                            Returned_Voided_Case_Payment__c = cp.Id,
                            Status__c = 'Corrective Entry',
                            Restitution_Fund__c = cp.Restitution_Fund__c,
                            Amount_Payable_to_Employees__c = cp.Amount_Payable_to_Employees__c == null ? null : -cp.Amount_Payable_to_Employees__c,
                            Deduction_Payment__c = cp.Deduction_Payment__c,
                            Public_Works_Penalties__c = cp.Public_Works_Penalties__c == null ? null : -cp.Public_Works_Penalties__c,
                            Apprenticeship_Penalties__c = cp.Apprenticeship_Penalties__c == null ? null : -cp.Apprenticeship_Penalties__c,
                            California_Apprenticeship_Council__c = cp.California_Apprenticeship_Council__c == null ? null : -cp.California_Apprenticeship_Council__c,
                            CA_Apprenticeship_Council_Craft__c = cp.CA_Apprenticeship_Council_Craft__c == null ? null : -cp.CA_Apprenticeship_Council_Craft__c,
                            CA_Apprenticeship_County__c = cp.CA_Apprenticeship_County__c == null ? null : -cp.CA_Apprenticeship_County__c,
                            CPR_Only__c = cp.CPR_Only__c == null ? null : -cp.CPR_Only__c,
                            CPR_Refund__c = cp.CPR_Refund__c == null ? null : -cp.CPR_Refund__c,
                            CMU_Reimbursement__c = cp.CMU_Reimbursement__c == null ? null : -cp.CMU_Reimbursement__c,
                            Amounts_Due_to_DIR__c = cp.Amounts_Due_to_DIR__c == null ? null : -cp.Amounts_Due_to_DIR__c,
                            Amounts_Due_to_DIR_Explanation__c = cp.Amounts_Due_to_DIR_Explanation__c,
                            Hold_Amount__c = cp.Hold_Amount__c == null ? null : -cp.Hold_Amount__c,
                            CPR_Only_Pay_Business__c = cp.CPR_Only_Pay_Business__c,
                            CPR_Refund_Pay_Business__c = cp.CPR_Refund_Pay_Business__c,
                            Other_Refund__c = cp.Other_Refund__c == null ? null : -cp.Other_Refund__c
                        );
                        cpsToUpsertList.add(newNegativeCp);
                    }
                }
            }
            cp.Status__c = 'Voided';
            cpsToUpsertList.add(cp);
        }
        upsert cpsToUpsertList;
        
        
        for(Liability_Payment__c lp : lpList){
            for(Case_Payment__c newNegativeCp : cpsToUpsertList){
                if(newNegativeCp.Status__c != 'Voided'){ //Original CP was added to cpsToUpsertList for DML convenience, so we're filtering it out here
                    if(lp.Case_Payment__c == newNegativeCp.Returned_Voided_Case_Payment__c){
                        Liability_Payment__c newNegativeLp = new Liability_Payment__c(
                            Case_Payment__c = newNegativeCp.Id,
                            Liability__c = lp.Liability__c,
                            Assessment__c = lp.Assessment__c,
                            Case_Violation__c = lp.Case_Violation__c,
                            Posted_Amount__c = lp.Posted_Amount__c == null ? null : -lp.Posted_Amount__c,
                            Payment_Applied_To__c = lp.Payment_Applied_To__c,
                            Payment_On_Behalf_Of__c = lp.Payment_On_Behalf_Of__c,
                            Payment_Type__c = lp.Payment_Type__c,
                            Recommended_Amount__c = lp.Recommended_Amount__c == null ? null : -lp.Recommended_Amount__c,
                            Returned_Voided_Liability_Payment__c = lp.Id,
                            Status__c = 'Corrective Entry'
                        );
                        lpsToUpsertList.add(newNegativeLp);
                    }
                }
            }
            lp.Status__c = 'Voided';
            lpsToUpsertList.add(lp);
        }
        upsert lpsToUpsertList;
        
        
        for(Applied_Accounting_Code__c aeac : aeacList){
            for(Liability_Payment__c newNegativeLp : lpsToUpsertList){
                if(newNegativeLp.Status__c != 'Voided'){ //Original LPs were added to lpsToUpsertList for DML convenience, so we filter them out here
                    if(aeac.Liability_Payment__c == newNegativeLp.Returned_Voided_Liability_Payment__c){
                        Applied_Accounting_Code__c newNegativeAeac = new Applied_Accounting_Code__c(
                            Accounting_Code__c = AeAC.Accounting_Code__c,
                            Added_Manually__c = AeAC.Added_Manually__c,
                            Amount__c = aeac.Amount__c == null ? null : -aeac.Amount__c,
                            Check_Count__c = aeac.Check_Count__c == null ? null : aeac.Check_Count__c, //TODO: verify this with business
                            Liability_Payment__c = newNegativeLp.Id,
                            Payment_Type__c = aeac.Payment_Type__c,
                            Returned_Voided_Applied_Accounting_Code__c = aeac.Id,
                            Violation_Accounting_Code__c = aeac.Violation_Accounting_Code__c
                        );
                        aeacsToInsertList.add(newNegativeAeac);
                    }
                }
            }
        }
        insert aeacsToInsertList;
        
        
        for(Judgment_Payment__c jp : jpList){
            for(Case_Payment__c newNegativeCp : cpsToUpsertList){
                if(newNegativeCp.Status__c != 'Voided'){ //Original CP was added to cpsToUpsertList for DML convenience, so we're filtering it out here
                    if(jp.Case_Payment__c == newNegativeCp.Returned_Voided_Case_Payment__c){
                        Judgment_Payment__c newNegativeJp = new Judgment_Payment__c(
                            Case_Payment__c = newNegativeCp.Id,
                            Judgment__c = jp.Judgment__c,
                            Posted_Amount__c = jp.Posted_Amount__c == null ? null : -jp.Posted_Amount__c,
                            Payment_Applied_To__c = jp.Payment_Applied_To__c,
                            Payment_On_Behalf_Of__c = jp.Payment_On_Behalf_Of__c,
                            Recommended_Amount__c = jp.Recommended_Amount__c == null ? null : -jp.Recommended_Amount__c,
                            Status__c = 'Corrective Entry',
                            Returned_Voided_Judgment_Payment__c = jp.Id
                        );
                        jpsToUpsertList.add(newNegativeJp);
                    }
                }
            }
            jp.Status__c = 'Voided';
            jpsToUpsertList.add(jp);            
        }
        upsert jpsToUpsertList;
        
        
        //Existing PRs: delete if not batched under a Warrant, otherwise no need to create Corrective Entry PRs.
        List<Payment_Record__c> prsToDelete = new List<Payment_Record__c>();
        for(Payment_Record__c pr : prList){
            if(!pr.Batched_Under_Warrant__c){
                prsToDelete.add(pr);
            }
        }
        delete prsToDelete;
        

        //Turn back on the Trigger Settings turned off above
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = true;
        }
        update triggerSettings;
    }
    


    @future
    @TestVisible
    /* TODO: this description sorely needs to be updated */
    /*Returning very similar to Voiding. Negative records created and linked. Differences:
    1 - Void: original RCT removed from TRN. Return: original RCT not removed from TRN.
    2 - Void: negative CP rolls up to CM.Deposited_Funds__c. Return: negative CP does not roll up to CM.Deposited_Funds__c.
    3 - Void: negative CP.Status__c same as original CP.Status__c. Return: negative CP.Status__c = "New".
    4 - RCTs may only be Returned if they've been Deposited, Related Deduction RCTs however are never deposited, but if their parent
        Net RCT is deposited then returned, we set the Deduction RCT's status to "Deposited-Returned Deduction".
    5 - Buyback LP and Buyback PR are created under original CP for the full amount of that CP. CP thus appearing overpaid is the accepted convention.*/
    public static void returnReceipts(List<Id> triggerRctIdList){
        Map<Id, Transaction__c> trnMap;
        Set<Id> trnIdSet = new Set<Id>();
        List<Receipt__c> triggerRctList = new List<Receipt__c>();
        //Map<Id, String> rctIdToReturnedReasonMap = new Map<Id, String>();
        Set<Id> allRctIdSet = new Set<Id>();
        List<Receipt__c> allRctList = new List<Receipt__c>();
        List<Case_Payment__c> cpList = new List<Case_Payment__c>();
        List<Id> cpIdList = new List<Id>();
        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
        List<Applied_Accounting_Code__c> aeacList = new List<Applied_Accounting_Code__c>();
        List<Judgment_Payment__c> jpList = new List<Judgment_Payment__c>();
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        
        //Query for trigger RCTs and their related Net or Deduction RCT Ids
        triggerRctList = [SELECT Id, Net_Receipt__r.Id, Returned_Item__c, Returned_Reason__c, Returned_Date__c, Returned_Item_Received_By__c,
                        
                            (SELECT Id, Returned_Item__c, Returned_Date__c, Returned_Reason__c, Returned_Item_Received_By__c
                                FROM Deduction_Receipts__r)
                        
                            FROM Receipt__c
                            WHERE Id IN :triggerRctIdList];

        for(Receipt__c rct : triggerRctList){
            allRctIdSet.add(rct.Id);
            allRctIdSet.add(rct.Net_Receipt__r.Id);
            
            for(Receipt__c deductionRct : rct.Deduction_Receipts__r){
                allRctIdSet.add(deductionRct.Id);
            }
        }
                
        //Re-query now for all RCTs and all needed fields.
        allRctList = [SELECT Add_Deduction__c, Adjustment__c, Bank_Location__c, Date_Received__c, Deduction_Amount__c, Deposit_Account__c,
                            Gross_Amount__c, Hold_Date__c, Id, Instrument_Number__c, Name, NSF_Demand_Letter_Attention_To__c, 
                            Office_Unit__c, Payment_Amount__c, Payment_Exchange__c, Payment_Type__c,
                            Payor__c, Receipt_Index__c, Returned_Date__c, Returned_Item__c, Returned_Item_Received_By__c, Returned_Reason__c,
                            Senior_Deputy__c, Status__c, Transaction__c, Void_Reason__c, Voided_Item__c,
                            
                            Net_Receipt__c, Net_Receipt__r.Id, Net_Receipt__r.Returned_Item__c, Net_Receipt__r.Returned_Reason__c,
                            Net_Receipt__r.Returned_Item_Received_By__c, Net_Receipt__r.NSF_Demand_Letter_Attention_To__c, Net_Receipt__r.Returned_Date__c,

                            Returned_Voided_Receipt__c, Returned_Voided_Receipt__r.Net_Receipt__c,
                            
                            (SELECT Id, Name, Net_Receipt__c, Net_Receipt__r.Id, Net_Receipt__r.Returned_Item__c, Returned_Date__c, Returned_Item__c,
                                    Returned_Item_Received_By__c, Returned_Reason__c, Void_Reason__c, Voided_Item__c, NSF_Demand_Letter_Attention_To__c
                                FROM Deduction_Receipts__r),
                                
                            (SELECT Amount_Payable_to_Employees__c, Apprenticeship_Penalties__c, CA_Apprenticeship_Council_Craft__c, CA_Apprenticeship_County__c,
                                    California_Apprenticeship_Council__c, Case__c, Case__r.Id, Case__r.RecordType.Name, CMU_Reimbursement__c, CPR_Only__c, CPR_Only_Pay_Business__c,
                                    CPR_Refund__c, CPR_Refund_Pay_Business__c, Deduction_Payment__c, Amounts_Due_to_DIR__c, Amounts_Due_to_DIR_Explanation__c, Hold_Amount__c,
                                    Id, Name, Other_Amount__c, Other_Refund__c, Payment_Amount__c, Payment_Plan__c, Public_Works_Penalties__c, Receipt__c, RecordType.Name,
                                    RecordTypeId, Refund_Amount__c, Restitution_Fund__c, Status__c, Transmittal__c
                            FROM Case_Payments__r)

                        FROM Receipt__c
                        WHERE Id IN :allRctIdSet];

        /* for(Receipt__c rct : allRctList){
            rctIdToReturnedReasonMap.put(rct.Id, rct.Returned_Reason__c);
            
            for(Receipt__c deductionRct : rct.Deduction_Receipts__r){
                rctIdToReturnedReasonMap.put(deductionRct.Id, deductionRct.Returned_Reason__c);
            }
            
        }

        System.debug(' 416 rctIdToReturnedReasonMap: ' + rctIdToReturnedReasonMap); */
        
        for(Receipt__c rct : allRctList){
            if(rct.Net_Receipt__c != null){ //This RCT is a Deduction RCT. Deduction RCTs are technically never deposited, so we give them the convoluted
                                            //  Status of 'Returned-Deposited Deduction' because yadda yadda reasons cashiering staff obtuse.
                                            //If this Deduction RCT was the one originally marked Returned instead of the Net RCT--not standard business
                                            //  practice as they should only be initiating the returning process from the Net RCT--we're checking
                                            //  and correcting for that here.
                                            //The related Net RCT will be marked 'Returned-Deposited' eventually in the following ELSE statement.
                rct.Voided_Item__c = false; //RCTs can't be both Voided and Returned
                rct.Void_Reason__c = '';

                rct.Status__c = 'Deposited-Returned Deduction';
                rct.Returned_Item__c = true;
                rct.Returned_Date__c = Date.today();
                rct.Hold_Date__c = null;
                // rct.Returned_Reason__c = rctIdToReturnedReasonMap.get(rct.Id);
                /* if(rctIdToReturnedReasonMap.get(rct.Net_Receipt__r.Id) != null){
                    rct.Returned_Reason__c = rctIdToReturnedReasonMap.get(rct.Net_Receipt__r.Id);
                } */
                if(rct.Returned_Item_Received_By__c == null){
                    rct.Returned_Item_Received_By__c = rct.Net_Receipt__r.Returned_Item_Received_By__c;
                }
                if(rct.Returned_Reason__c == null){
                    rct.Returned_Reason__c = rct.Net_Receipt__r.Returned_Reason__c;
                }
                if(rct.NSF_Demand_Letter_Attention_To__c == null){
                    rct.NSF_Demand_Letter_Attention_To__c = rct.Net_Receipt__r.NSF_Demand_Letter_Attention_To__c;
                }
                /* if(rct.Returned_Date__c == null){
                    rct.Returned_Date__c = rct.Net_Receipt__r.Returned_Date__c;
                } */
            }else{ //This RCT is a Net RCT that was marked Returned.
                rct.Voided_Item__c = false; //RCTs can't be both Voided and Returned
                rct.Void_Reason__c = '';

                rct.Status__c = 'Deposited-Returned';
                rct.Returned_Item__c = true;
                rct.Returned_Date__c = Date.today();
                rct.Hold_Date__c = null;
                for(Receipt__c deductionRct : rct.Deduction_Receipts__r){
                    if(rct.Returned_Item_Received_By__c == null){
                        rct.Returned_Item_Received_By__c = deductionRct.Returned_Item_Received_By__c;
                    }
                    if(rct.Returned_Reason__c == null){
                        rct.Returned_Reason__c = deductionRct.Returned_Reason__c;
                    }
                    if(rct.NSF_Demand_Letter_Attention_To__c == null){
                        rct.NSF_Demand_Letter_Attention_To__c = deductionRct.NSF_Demand_Letter_Attention_To__c;
                    }
                    /* if(rct.Returned_Date__c == null){
                        rct.Returned_Date__c = deductionRct.Returned_Date__c;
                    } */

                    /* if(rctIdToReturnedReasonMap.get(deductionRct.Id) != null){
                        rct.Returned_Reason__c = rctIdToReturnedReasonMap.get(deductionRct.Id);
                    } */
                    
                }
            }
        }

        //Turn off the ReceiptTrigger to prevent this class from calling itself, otherwise we get an error stating that a future method cannot call a future method.
        // Turn off other triggers too to reduce overhead, except for the LiabilityPaymentTrigger as we need that for rollups to the CI
        // Trigger Settings managed in Setup->Custom Settings->Trigger Settings->Manage.
        List<Trigger_Settings__c> triggerSettings = [SELECT Id, Name, Is_Active__c
                                                        FROM Trigger_Settings__c
                                                        WHERE Is_Active__c = TRUE
                                                            AND Name != 'LiabilityPaymentTrigger'];
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = false;
        }
        update triggerSettings;

        System.debug('499 allRctList: ' + allRctList);

        update allRctList;

        //requery allRctList to catch all changes to parent and child Net and Deduction RCTs
        allRctList = [SELECT Add_Deduction__c, Adjustment__c, Bank_Location__c, Date_Received__c, Deduction_Amount__c, Deposit_Account__c,
                            Gross_Amount__c, Hold_Date__c, Id, Instrument_Number__c, Name, NSF_Demand_Letter_Attention_To__c, 
                            Office_Unit__c, Payment_Amount__c, Payment_Exchange__c, Payment_Type__c,
                            Payor__c, Receipt_Index__c, Returned_Date__c, Returned_Item__c, Returned_Item_Received_By__c, Returned_Reason__c,
                            Senior_Deputy__c, Status__c, Transaction__c, Void_Reason__c, Voided_Item__c,
                            
                            Net_Receipt__c, Net_Receipt__r.Id, Net_Receipt__r.Returned_Item__c, Net_Receipt__r.Returned_Reason__c,
                            Net_Receipt__r.Returned_Item_Received_By__c, Net_Receipt__r.NSF_Demand_Letter_Attention_To__c, Net_Receipt__r.Returned_Date__c,

                            Returned_Voided_Receipt__c, Returned_Voided_Receipt__r.Net_Receipt__c,
                            
                            (SELECT Id, Name, Net_Receipt__c, Net_Receipt__r.Id, Net_Receipt__r.Returned_Item__c, Returned_Date__c, Returned_Item__c,
                                    Returned_Item_Received_By__c, Returned_Reason__c, Void_Reason__c, Voided_Item__c, NSF_Demand_Letter_Attention_To__c
                                FROM Deduction_Receipts__r),
                                
                            (SELECT Amount_Payable_to_Employees__c, Apprenticeship_Penalties__c, CA_Apprenticeship_Council_Craft__c, CA_Apprenticeship_County__c,
                                    California_Apprenticeship_Council__c, Case__c, Case__r.Id, Case__r.RecordType.Name, CMU_Reimbursement__c, CPR_Only__c, CPR_Only_Pay_Business__c,
                                    CPR_Refund__c, CPR_Refund_Pay_Business__c, Deduction_Payment__c, Amounts_Due_to_DIR__c, Amounts_Due_to_DIR_Explanation__c, Hold_Amount__c,
                                    Id, Name, Other_Amount__c, Other_Refund__c, Payment_Amount__c, Payment_Plan__c, Public_Works_Penalties__c, Receipt__c, RecordType.Name,
                                    RecordTypeId, Refund_Amount__c, Restitution_Fund__c, Status__c, Transmittal__c, Returned_Voided_Case_Payment__c
                            FROM Case_Payments__r)

                        FROM Receipt__c
                        WHERE Id IN :allRctIdSet];
        
        System.debug('529 allRctList: ' + allRctList);

        for(Receipt__c rct : allRctList){
            trnIdSet.add(rct.Transaction__c);
            cpList.addAll(rct.Case_Payments__r);
        }
        
        trnMap = new Map<Id, Transaction__c>([SELECT Id, Name, Office_Account__c, Business_Unit__c, Transaction_Status__c
                                                FROM Transaction__c
                                                WHERE Id IN :trnIdSet]);
        
        for(Case_Payment__c cp : cpList){
            cpIdList.add(cp.Id);
        }
        
        lpList = [SELECT Id, Name, Case_Payment__c, Liability__c, Assessment__c, Case_Violation__c, Posted_Amount__c, Payment_Applied_To__c,
                        Payment_On_Behalf_Of__c, Payment_Type__c, Recommended_Amount__c, Status__c, Case_Payment__r.Status__c, Returned_Voided_Liability_Payment__c,
                        
                        (SELECT Id, Name, Added_Manually__c, Check_Count__c, Liability_Payment__c, Receipt__c, Accounting_Code__c,
                                Violation_Accounting_Code__c, Payment_Type__c, Amount__c, Penalty_Amt__c, Interest_Amt__c
                            FROM Applied_Accounting_Codes__r),
                        
                        (SELECT Id, Name, Batched_Under_Warrant__c
                          FROM Payment_Records__r)
                    
                    FROM Liability_Payment__c
                    WHERE Case_Payment__c IN :cpIdList];
        
        for(Liability_Payment__c lp : lpList){
            aeacList.addAll(lp.Applied_Accounting_Codes__r);
            prList.addAll(lp.Payment_Records__r);
        }
        
        jpList = [SELECT Id, Name, Case_Payment__c, Judgment__c, Posted_Amount__c, Payment_Applied_To__c, Payment_On_Behalf_Of__c, Recommended_Amount__c, Status__c, Case_Payment__r.Status__c,

                        (SELECT Id, Name, Batched_Under_Warrant__c
                            FROM Payment_Records__r)
            
                    FROM Judgment_Payment__c
                    WHERE Case_Payment__c IN :cpIdList];
        
        for(Judgment_Payment__c jp : jpList){
            prList.addAll(jp.Payment_Records__r);
        }
        

        //Make 'Corrective Entry' cashiering object records in negative amounts
        // Also create Buyback LP and PR under each CP.
        //List<Transaction__c> trnsToInsertList = new List<Transaction__c>();
        List<Receipt__c> rctsToUpsertList = new List<Receipt__c>();
        List<Case_Payment__c> cpsToUpsertList = new List<Case_Payment__c>();
        List<Liability_Payment__c> lpsToUpsertList = new List<Liability_Payment__c>();
        List<Applied_Accounting_Code__c> aeacsToInsertList = new List<Applied_Accounting_Code__c>();
        List<Judgment_Payment__c> jpsToUpsertList = new List<Judgment_Payment__c>();
        List<Payment_Record__c> prsToInsertList = new List<Payment_Record__c>();
        
        for(Receipt__c rct : allRctList){
            Receipt__c newNegativeRct = new Receipt__c(
                Payor__c = rct.Payor__c,
                Payment_Amount__c = rct.Payment_Amount__c == null ? null : -rct.Payment_Amount__c,
                Deduction_Amount__c = rct.Deduction_Amount__c == null ? null : -rct.Deduction_Amount__c,
                Gross_Amount__c = rct.Gross_Amount__c == null ? null : -rct.Gross_Amount__c, /*Non-user-visible field for internal tracking */
                Add_Deduction__c = rct.Add_Deduction__c, /*Non-user-visible field for internal tracking */
                Receipt_Index__c = rct.Receipt_Index__c, /*Non-user-visible field for internal tracking */
                Deposit_Account__c = rct.Deposit_Account__c,
                Date_Received__c = Date.today(), //the negated record's Date Received is the original record's Date Returned
                Instrument_Number__c = 'Adjustment for Returning ' + rct.Instrument_Number__c,
                Payment_Type__c = rct.Payment_Type__c,
                Bank_Location__c = rct.Bank_Location__c,
                Payment_Exchange__c = rct.Payment_Exchange__c,
                Senior_Deputy__c = rct.Senior_Deputy__c,
                Status__c = 'Corrective Entry', 
                Office_Unit__c = rct.Office_Unit__c,
                Returned_Voided_Receipt__c = rct.Id,
                Adjustment__c = true
            );
            
            rctsToUpsertList.add(newNegativeRct);
            
            // rct.Status__c = 'Deposited-Returned'; // TODO: this status being changed here sometimes seems to interfere with a validation rule on the RCT.
                                                  //  Maybe should be updated below in separate DML? Turn off Receipt Trigger?
            // rct.Status_Date__c = Date.today();
            // rct.Returned_Date__c = Date.today();
            // rct.Hold_Date__c = null; //Any original hold date now is no longer applicable, so we null as it may prevent cutting a buyback Warrant.
            
            if(!trnMap.isEmpty() && trnMap.get(rct.Transaction__c) != null && trnMap.get(rct.Transaction__c).Transaction_Status__c == 'Pending'){ //if TRN is deposited, don't remove the RCT
                rct.Transaction__c = null;
            }
            rctsToUpsertList.add(rct);
            
        }
        upsert rctsToUpsertList;
        
        //Requery to pull in any original deduction RCTs' parent net RCT.
        rctsToUpsertList = [SELECT Id, Name, Status__c, Payment_Type__c, Returned_Item__c, Returned_Voided_Receipt__c, Returned_Voided_Receipt__r.Net_Receipt__c, Net_Receipt__c
                                FROM Receipt__c
                                WHERE Id IN :rctsToUpsertList];
        
        //Find new negative deduction RCTs and parent them to the corresponding new negative net RCTs
        for(Receipt__c negDedRct : rctsToUpsertList){
            if(negDedRct.Payment_Type__c == 'Deduction' && !negDedRct.Returned_Item__c){ //is a new negative deduction RCT
                for(Receipt__c negNetRct : rctsToUpsertList){
                    if(negNetRct.Payment_Type__c == 'Check' && !negNetRct.Returned_Item__c){ //is a new negative net RCT
                        if(negDedRct.Returned_Voided_Receipt__r.Net_Receipt__c == negNetRct.Returned_Voided_Receipt__c){
                            negDedRct.Net_Receipt__c = negNetRct.Id; 
                        }
                    }
                }
            }
        }
        upsert rctsToUpsertList;

        /* for(Receipt__c rct : allRctList){ //if either of the original RCTs don't have a CP, we need to create one for them to attach the subsequent buyback LPs.
                //TODO: which case?
            if(rct.Case_Payments__r.isEmpty()){
                Case_Payment__c newBuybackCp = new Case_Payment__c(
                    Receipt__c = rct.Id,
                    RecordTypeId = ,

                );
            }
        } */
 
        for(Case_Payment__c cp : cpList){
            for(Receipt__c rct : rctsToUpsertList){
                for(Receipt__c correctiveEntryRct : rctsToUpsertList){
                    // Create a corrective entry CP and parent that corrective entry CP to the original CP and the corrective entry RCT.
                    if((rct.Status__c == 'Deposited-Returned' || rct.Status__c == 'Deposited-Returned Deduction') && //Make sure this RCT is an original RCT
                            correctiveEntryRct.Status__c == 'Corrective Entry' && //Find a corrective entry RCT
                            correctiveEntryRct.Returned_Voided_Receipt__c == rct.Id && //Find the corrective entry RCT that's parented to this original RCT
                            cp.Receipt__c == rct.Id && //Make sure this original CP is a child of this original RCT
                            cp.Status__c == 'Posted'){ //Only create a corrective entry CP if the original CP has been posted

                        Case_Payment__c newNegativeCp = new Case_Payment__c(
                            Receipt__c = correctiveEntryRct.Id,
                            RecordTypeId = cp.RecordTypeId,
                            Case__c = cp.Case__c,
                            Payment_Amount__c = cp.Payment_Amount__c == null ? null : -cp.Payment_Amount__c,
                            Payment_Plan__c = cp.Payment_Plan__c,
                            Transmittal__c = cp.Transmittal__c, //or allow newNegativeCp to be added to a new Transmittal? or no Tr
                            Returned_Voided_Case_Payment__c = cp.Id,
                            Status__c = 'Corrective Entry',
                            Restitution_Fund__c = cp.Restitution_Fund__c,
                            Amount_Payable_to_Employees__c = cp.Amount_Payable_to_Employees__c == null ? null : -cp.Amount_Payable_to_Employees__c,
                            Deduction_Payment__c = cp.Deduction_Payment__c,
                            Public_Works_Penalties__c = cp.Public_Works_Penalties__c == null ? null : -cp.Public_Works_Penalties__c,
                            Apprenticeship_Penalties__c = cp.Apprenticeship_Penalties__c == null ? null : -cp.Apprenticeship_Penalties__c,
                            California_Apprenticeship_Council__c = cp.California_Apprenticeship_Council__c == null ? null : -cp.California_Apprenticeship_Council__c,
                            CA_Apprenticeship_Council_Craft__c = cp.CA_Apprenticeship_Council_Craft__c == null ? null : -cp.CA_Apprenticeship_Council_Craft__c,
                            CA_Apprenticeship_County__c = cp.CA_Apprenticeship_County__c == null ? null : -cp.CA_Apprenticeship_County__c,
                            CPR_Only__c = cp.CPR_Only__c == null ? null : -cp.CPR_Only__c,
                            CPR_Refund__c = cp.CPR_Refund__c == null ? null : -cp.CPR_Refund__c,
                            CMU_Reimbursement__c = cp.CMU_Reimbursement__c == null ? null : -cp.CMU_Reimbursement__c,
                            Amounts_Due_to_DIR__c = cp.Amounts_Due_to_DIR__c == null ? null : -cp.Amounts_Due_to_DIR__c,
                            Amounts_Due_to_DIR_Explanation__c = cp.Amounts_Due_to_DIR_Explanation__c,
                            Hold_Amount__c = cp.Hold_Amount__c == null ? null : -cp.Hold_Amount__c,
                            CPR_Only_Pay_Business__c = cp.CPR_Only_Pay_Business__c,
                            CPR_Refund_Pay_Business__c = cp.CPR_Refund_Pay_Business__c,
                            Other_Refund__c = cp.Other_Refund__c == null ? null : -cp.Other_Refund__c, //This field is deprecated, will be deleted after deployment and data is migrated
                            Other_Amount__c = cp.Other_Amount__c == null ? null : -cp.Other_Amount__c,
                            Refund_Amount__c = cp.Refund_Amount__c == null ? null : -cp.Refund_Amount__c
                        );
                        cpsToUpsertList.add(newNegativeCp);
                    }
                }

                if(cp.Receipt__c == rct.Id){
                    if(rct.Status__c == 'Deposited-Returned'){
                        cp.Status__c = 'Deposited-Returned';
                    }else if(rct.Status__c == 'Deposited-Returned Deduction'){
                        cp.Status__c = 'Deposited-Returned Deduction';
                    }
                    cpsToUpsertList.add(cp);
                }
            }
        }
        upsert cpsToUpsertList;

        
        for(Liability_Payment__c lp : lpList){
            for(Case_Payment__c newNegativeCp : cpsToUpsertList){
                if(newNegativeCp.Status__c != 'Deposited-Returned' && newNegativeCp.Status__c != 'Deposited-Returned Deduction'){ //original CP was added to cpsToUpsertList for DML convenience, so we're filtering it out here
                    if(lp.Case_Payment__c == newNegativeCp.Returned_Voided_Case_Payment__c){
                        Liability_Payment__c newNegativeLp = new Liability_Payment__c(
                            Case_Payment__c = newNegativeCp.Id,
                            Liability__c = lp.Liability__c,
                            Assessment__c = lp.Assessment__c,
                            Case_Violation__c = lp.Case_Violation__c,
                            Posted_Amount__c = lp.Posted_Amount__c == null ? null : -lp.Posted_Amount__c,
                            Payment_Applied_To__c = lp.Payment_Applied_To__c,
                            Payment_On_Behalf_Of__c = lp.Payment_On_Behalf_Of__c,
                            Payment_Type__c = lp.Payment_Type__c,
                            Recommended_Amount__c = lp.Recommended_Amount__c == null ? null : -lp.Recommended_Amount__c,
                            Returned_Voided_Liability_Payment__c = lp.Id,
                            Status__c = 'Corrective Entry'
                        );
                        lpsToUpsertList.add(newNegativeLp);
                    }
                }/* else{ //the LP under a 'Deposited-Returned' CP (the original CP) is the original LP.
                       // TODO: for now, we're leaving the Status as is ('New', 'Recommended', or 'Posted').
                       // Maybe a different Status is warranted, in which case we would update that here.
                } */
            }
            if(lp.Case_Payment__r.Status__c == 'Deposited-Returned'){
                lp.Status__c = 'Deposited-Returned';
            }else if(lp.Case_Payment__r.Status__c == 'Deposited-Returned Deduction'){
                lp.Status__c = 'Deposited-Returned Deduction';
            }
            lpsToUpsertList.add(lp);
        }

        //For each original CP, create a Buyback LP in the full POSITIVE amount of the CP. This will show the CP being overpaid, which is the accepted convention.
        for(Case_Payment__c cp : cpsToUpsertList){
            /* if(cp.Status__c == 'Deposited-Returned' || cp.Status__c == 'Deposited-Returned Deduction'){ */
            if(cp.Status__c == 'Deposited-Returned'){ //Deposited-Returned Deduction funds do not need a Buyback LP or PR because they're never actually deposited.
                Liability_Payment__c buybackLp = new Liability_Payment__c(
                    Case_Payment__c = cp.Id,
                    Posted_Amount__c = cp.Payment_Amount__c,
                    Payment_Applied_To__c = 'Buyback',
                    Payment_On_Behalf_Of__c = null, //Null because a Buyback LP could be the only LP under a CP, in which case there could be no previous POBO to refer to to populate this field.
                    Payment_Type__c = null, //TODO: needed?
                    Status__c = 'Posted' //TODO: new status?, equal to original LPs original Status?
                );
                lpsToUpsertList.add(buybackLp);
            }
        }

        upsert lpsToUpsertList;
        
        for(Applied_Accounting_Code__c aeac : aeacList){
            for(Liability_Payment__c newNegativeLp : lpsToUpsertList){
                if(newNegativeLp.Status__c != 'Deposited-Returned' && 
                    newNegativeLp.Status__c != 'Deposited-Returned Deduction'){ //Original LPs and Buyback LPs were added to lpsToUpsertList for
                                                                                // DML convenience. Buyback LPs at this point have no children AeACs,
                                                                                // so we only need to filter out the original LPs.
                                                                                // TODO: do Buyback LPs need AeACs? 
                    if(aeac.Liability_Payment__c == newNegativeLp.Returned_Voided_Liability_Payment__c){
                        Applied_Accounting_Code__c newNegativeAeac = new Applied_Accounting_Code__c(
                            Accounting_Code__c = aeac.Accounting_Code__c,
                            Added_Manually__c = aeac.Added_Manually__c,
                            Amount__c = aeac.Amount__c == null ? null : -aeac.Amount__c,
                            Check_Count__c = aeac.Check_Count__c == null ? null : aeac.Check_Count__c, //TODO: verify this with business
                            Liability_Payment__c = newNegativeLp.Id,
                            Payment_Type__c = aeac.Payment_Type__c,
                            Returned_Voided_Applied_Accounting_Code__c = aeac.Id,
                            Violation_Accounting_Code__c = aeac.Violation_Accounting_Code__c
                        );
                        aeacsToInsertList.add(newNegativeAeac);
                    }
                }
            }
        }
        insert aeacsToInsertList;
        
        
        for(Judgment_Payment__c jp : jpList){
            for(Case_Payment__c newNegativeCp : cpsToUpsertList){
                if(newNegativeCp.Status__c != 'Deposited-Returned' && newNegativeCp.Status__c != 'Deposited-Returned Deduction'){ //original CP was added to cpsToUpsertList for DML convenience, so we're filtering it out here
                    if(jp.Case_Payment__c == newNegativeCp.Returned_Voided_Case_Payment__c){
                        Judgment_Payment__c newNegativeJp = new Judgment_Payment__c(
                            Case_Payment__c = newNegativeCp.Id,
                            Judgment__c = jp.Judgment__c,
                            Posted_Amount__c = jp.Posted_Amount__c == null ? null : -jp.Posted_Amount__c,
                            Payment_Applied_To__c = jp.Payment_Applied_To__c,
                            Payment_On_Behalf_Of__c = jp.Payment_On_Behalf_Of__c,
                            Recommended_Amount__c = jp.Recommended_Amount__c == null ? null : -jp.Recommended_Amount__c,
                            Status__c = 'Corrective Entry', 
                            Returned_Voided_Judgment_Payment__c = jp.Id
                        );
                        jpsToUpsertList.add(newNegativeJp);
                    }
                }
            }
            if(jp.Case_Payment__r.Status__c == 'Deposited-Returned'){
                jp.Status__c = 'Deposited-Returned';
            }else if(jp.Case_Payment__r.Status__c == 'Deposited-Returned Deduction'){
                jp.Status__c = 'Deposited-Returned Deduction';
            }
            jpsToUpsertList.add(jp);
        }
        upsert jpsToUpsertList;

        
        // For Buyback LPs, create Buyback PRs for the full positive amount of the LP.
        // Query for Bank Payees on all cases
        Set<Id> caseIds = new Set<Id>();
        for(Case_Payment__c cp : cpsToUpsertList){
            caseIds.add(cp.Case__r.Id);
        }

        List<DIR_Case__c> caseList = [SELECT Id, Name,
                                            (SELECT Id, Name, Role__c, Case_Management__c, Payee_Name__c
                                                FROM Payees__r
                                                WHERE Role__c = 'Bank'
                                                LIMIT 1)
                                        FROM DIR_Case__c
                                        WHERE Id IN :caseIds];

        for(DIR_Case__c dirCase : caseList){
            Payee__c bankPayee;
            for(Case_Payment__c cp : cpsToUpsertList){
                for(Liability_Payment__c lp : lpsToUpsertList){
                    if(lp.Payment_Applied_To__c == 'Buyback' && lp.Case_Payment__c == cp.Id && cp.Case__c == dirCase.Id){
                        if(bankPayee == null){
                            if(dirCase.Payees__r.isEmpty()){
                                bankPayee = CashValidatePayees.createBankPayee(cp);
                            }else{
                                bankPayee = dirCase.Payees__r[0];
                            }
                        }
                        
                        if(!cp.Deduction_Payment__c){ //Deduction payments aren't deposited, so we don't want Buyback PRs created under them.
                            Payment_Record__c buybackPr = new Payment_Record__c(
                                Liability_Payment__c = lp.Id,
                                Payee__c = bankPayee.Id,
                                Payee_Name__c = bankPayee.Payee_Name__c,
                                Payment_Amount__c = lp.Posted_Amount__c,
                                Payment_Applied_To__c = 'Buyback'
                            );
                            prsToInsertList.add(buybackPr);
                        }
                    }
                }
            }
        }
        insert prsToInsertList;
            
        //Existing PRs: delete if not batched under a Warrant, otherwise no need to create Corrective Entry PRs.
        List<Payment_Record__c> prsToDelete = new List<Payment_Record__c>();
        for(Payment_Record__c pr : prList){
            if(!pr.Batched_Under_Warrant__c){
                prsToDelete.add(pr);
            }
        }
        delete prsToDelete;

        //Turn back on the Trigger Settings turned off above
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = true;
        }
        update triggerSettings;

    }
    
    
    
    
//Chatter methods, if needed. See original ReturnedItemAutomation.cls for use
/*      

    private static void postChatterReturnToChatter(List<ConnectApi.BatchInput> posts){
        system.debug('@@@Chatter Posts: '+posts);
        if( test.isRunningTest() ) return;
        ConnectApi.ChatterFeeds.postFeedElementBatch(null, posts);
    }

    private static ConnectApi.BatchInput generateReturnToChatter(Id userToMentionId, String postText, Id objId){ 

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        if(!String.isBlank(userToMentionId)){
            mentionSegmentInput.id = userToMentionId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
        }
        
        textSegmentInput.text = ' - '+postText;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = objId;
        
        return new ConnectApi.BatchInput(feedItemInput);
    } */
}