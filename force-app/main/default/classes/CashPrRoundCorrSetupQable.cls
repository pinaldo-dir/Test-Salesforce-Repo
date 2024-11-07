public with sharing class CashPrRoundCorrSetupQable implements Queueable {

    Map<Id, List<Payment_Record__c>> payeeIdToPrListMap;
    List<Payee__c> allPayeeList;
    List<Liability_Payment__c> allLpList; //Does not include CU-1s
    List<Judgment_Payment__c> allJpList;
    Case_Payment__c casePayment;
    Map<String, List<Id>> qableJobIdMap;

    public CashPrRoundCorrSetupQable(Case_Payment__c cp, Map<Id, List<Payment_Record__c>> payeeToPrList, List<Payee__c> allPayees,
                    List<Liability_Payment__c> allLps, List<Judgment_Payment__c> allJps, Map<String, List<Id>> qJobIdMap){
        payeeIdToPrListMap = payeeToPrList;
        allPayeeList = allPayees;
        allLpList = allLps;
        allJpList = allJps;
        casePayment = cp;
        qableJobIdMap = qJobIdMap;
    }

    public void execute(QueueableContext qc){

        try{
            
            //Only Payees with NetWages__c != null get to have their PRs rounding corrected.
            List<Payee__c> allNetWagesPayeeList = new List<Payee__c>();
            while(!allPayeeList.isEmpty()){
                Payee__c payee = allPayeeList.remove(0);
                if(payee.NetWages__c != null){
                    allNetWagesPayeeList.add(payee);
                }
            }
    
            //Determine if any of the PRs created belong to a net wages Payee. If not, we can skip the rounding setup.
            // E.g., a CP is allocated all to the Refund Amount, even though the case has net wages Payees.
            Boolean netWagesPrFound = false;
            Set<Id> prPayeeIds = payeeIdToPrListMap.keySet();
            for(Id prPayeeId : prPayeeIds){
                if(netWagesPrFound){
                    break;
                }
                for(Payee__c netWagesPayee : allNetWagesPayeeList){
                    if(prPayeeId == netWagesPayee.Id){
                        netWagesPrFound = true;
                        break;
                    }
                }
            }
    
            if(!allNetWagesPayeeList.isEmpty() && netWagesPrFound){
    
                //Map of LP, JP, and CU-1 IDs to their Posted Amount (Yea, we're throwing LP and JP Ids together,
                //  but they will still be unique from each other).
                Map<Id, Decimal> lpJpIdToAmountRemainingMap = new Map<Id, Decimal>();
                for(Liability_Payment__c lp : allLpList){
                    lpJpIdToAmountRemainingMap.put(lp.Id, lp.Posted_Amount__c);
                }

                for(Judgment_Payment__c jp : allJpList){
                    if(jp.Payment_Applied_To__c != 'Judgment Amount'){ //Judgment Amount JPs will never have PRs
                        lpJpIdToAmountRemainingMap.put(jp.Id, jp.Posted_Amount__c);
                    }
                }
    
                //Map of Payee IDs and their amounts owed, which is their NetWages__c amount - the sum of all their existing PRs
                //  already in the database (payee.NetWages__c - payee.Sum_Of_All_Payment_Records__c).
                Map<Id, Decimal> payeeIdToExistingAmountOwedMap = new Map<Id, Decimal>();
    
                //This map is similar to payeeIdToExistingAmountOwedMap above, except that it also takes into account
                //  the new PRs we've just created in CashCreatePrsQable and are about to insert.
                //  Used primarily to tell if we've over- or under-paid the Payee.
                Map<Id, Decimal> payeeIdToNewAmountOwedMap = new Map<Id, Decimal>();
    
                // Integer count = 0;
                for(Payee__c payee : allNetWagesPayeeList){
                    payeeIdToExistingAmountOwedMap.put(payee.Id, payee.NetWages__c - payee.Sum_Of_All_Payment_Records__c);
    
                    payeeIdToNewAmountOwedMap.put(payee.Id, payee.NetWages__c - payee.Sum_Of_All_Payment_Records__c);

                }
    
                //Subtract PR amounts from Payee amounts owed and LP/JP amount remaining
                for(Payee__c payee : allNetWagesPayeeList){

                    //For each PR under each Payee
                    for(Payment_Record__c pr : payeeIdToPrListMap.get(payee.Id)){  //******* for all PRs */
    
                        //Subtract the PR.Amount from the amount remaining on the LP or JP...
                        // System.debug('57 lp amount remaining before: ' + lpJpIdToAmountRemainingMap.get(pr.Liability_Payment__c));
                        lpJpIdToAmountRemainingMap.put(getPrParentId(pr), lpJpIdToAmountRemainingMap.get(getPrParentId(pr)) - pr.Payment_Amount__c);
                        // System.debug('59 lp amount remaining after: ' + lpJpIdToAmountRemainingMap.get(pr.Liability_Payment__c));
                        
                        // ...and also subtract it from the amount owed each Payee
                        // System.debug('82 payee amount owed before: ' + payeeIdToNewAmountOwedMap.get(payee.Id));
                        payeeIdToNewAmountOwedMap.put(payee.Id, payeeIdToNewAmountOwedMap.get(payee.Id) - pr.Payment_Amount__c);
                        // System.debug('84 payee amount owed after: ' + payeeIdToNewAmountOwedMap.get(payee.Id));
                    }
                }
    
                //For each LP or JP, if the sum of their PRs != their Posted_Amount__c, add that whole difference (whether it's + or -) to the
                //  1st Payee's PR under that LP or JP. "1st Payee" means the Payee, or one of the Payees, with the highest NetWages__c amount,
                //  as returned by the SOQL query in CashValidatePayees.cls.
    
                List<Id> lpOrJpIdList = new List<Id>(lpJpIdToAmountRemainingMap.keySet());

                for(Id lpOrJpId : lpOrJpIdList){
                    Decimal amountToAdd = lpJpIdToAmountRemainingMap.get(lpOrJpId);
                    // System.debug('82 amountToAdd: ' + amountToAdd);
                    if(amountToAdd != 0){
    
                        //Grab 1st net wages Payee returned by the SOQL query in CashValidatePayees.cls, who should be the, or one of the, Payees with the highest
                        //  NetWages__c amount.
                        Payee__c payee = allNetWagesPayeeList[0];

                        //This next line is for debugging only
                        // Decimal payeeNewAmountOwedOld = payeeIdToNewAmountOwedMap.get(payee.Id);
                        for(Payment_Record__c pr : payeeIdToPrListMap.get(payee.Id)){
                            
                            //Find that Payee's PR under this LP/JP
                            if(getPrParentId(pr) == lpOrJpId){
                                pr.Payment_Amount__c += amountToAdd;
                                lpJpIdToAmountRemainingMap.put(lpOrJpId, lpJpIdToAmountRemainingMap.get(lpOrJpId) - amountToAdd);
                                // System.debug('96 lpAmountRemaining should be 0: ' + lpJpIdToAmountRemainingMap.get(lpOrJpId));
                                payeeIdToNewAmountOwedMap.put(payee.Id, payeeIdToNewAmountOwedMap.get(payee.Id) - amountToAdd);
                                // System.debug('97 payeeNewAmountOwedOld: ' + payeeNewAmountOwedOld + ' should be ' + amountToAdd + '> payeeNewAmountOwedNew: ' + payeeIdToNewAmountOwedMap.get(payee.Id));
                                break;
                            }
                        }
                    }
                }
    
                // System.debug('105 lpJpIdToAmountRemainingMap: ' + lpJpIdToAmountRemainingMap);
    
                //Now that the LPs and JPs are exactly spent, we sum their Posted_Amounts and compare that to the sum
                //  of the existing Payee amounts owed (i.e., owed without these new PRs we're creating).
                /* Any changes to the filtering of the different types of LPs/JPs need to be also reflected in when PRs are generated in CashCreatePrsQable.cls */
                Decimal sumOfNewEmployeeLpsAndJps = 0.00;
                for(Liability_Payment__c lp : allLpList){
                    if(lp.Payment_Applied_To__c == 'Wages' ||
                            lp.Payment_Applied_To__c == 'Wage Interest' ||
                            (lp.Payment_Applied_To__c == 'Interest' && lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId())){
                        sumOfNewEmployeeLpsAndJps += lp.Posted_Amount__c;
                    }
                }
                for(Judgment_Payment__c jp : allJpList){
                    if(jp.Payment_Applied_To__c == 'Post-Hearing Interest' || jp.Payment_Applied_To__c == 'Post-Judgment Interest'){
                        sumOfNewEmployeeLpsAndJps += jp.Posted_Amount__c;
                    }
                }
                
                Decimal sumOfPayeeExistingAmountsOwed = 0.00;
                List<Id> netWagesPayeeIdList = new List<Id>(); //TODO: no need to declare a new List<Id> here, just call each Payee.Id
                for(Payee__c netWagesPayee : allNetWagesPayeeList){
                    netWagesPayeeIdList.add(netWagesPayee.Id);
                }
                for(Id netWagesPayeeId : netWagesPayeeIdList){
                    sumOfPayeeExistingAmountsOwed += payeeIdToExistingAmountOwedMap.get(netWagesPayeeId);
                }
    
                //Grab Id of the LP or JP with the largest Posted_Amount__c. Assumes at this point that all NetWages payees will have a PR under all LPs/JPs, even if it's $0.
                //  First, grab LP and JP Ids of 1st (largest NewWages__c amount) Payee's PRs.
                List<Id> netWagesLpIdList = new List<Id>();
                List<Id> netWagesJpIdList = new List<Id>();
                for(Payment_Record__c pr : payeeIdToPrListMap.get(allNetWagesPayeeList[0].Id)){
                    if(pr.Liability_Payment__c != null){
                        netWagesLpIdList.add(pr.Liability_Payment__c);
                    }else{
                        netWagesJpIdList.add(pr.Judgment_Payment__c);
                    }
                }
    
                //  Then determine which of these has the largest Posted_Amount__c value.
                Id largestAmountPrParentId;
                Id largestAmountLpId;
                Decimal lpLargestAmount = 0.00;
                for(Liability_Payment__c lp : allLpList){
                    for(Id netWagesLpId : netWagesLpIdList){
                        if(lp.Id == netWagesLpId){
                            if(largestAmountLpId == null){
                                largestAmountLpId = lp.Id;
                                lpLargestAmount = lp.Posted_Amount__c;
                            }else{
                                if(lp.Posted_Amount__c > lpLargestAmount){
                                    largestAmountLpId = lp.Id;
                                    lpLargestAmount = lp.Posted_Amount__c;
                                }
                            }
                        }
                    }
                }
                Id largestAmountJpId;
                Decimal jpLargestAmount = 0.00;
                for(Judgment_Payment__c jp : allJpList){
                    for(Id netWagesJpId : netWagesJpIdList){
                        if(jp.Id == netWagesJpId){
                            if(largestAmountJpId == null){
                                largestAmountJpId = jp.Id;
                                jpLargestAmount = jp.Posted_Amount__c;
                            }else{
                                if(jp.Posted_Amount__c > jpLargestAmount){
                                    largestAmountJpId = jp.Id;
                                    jpLargestAmount = jp.Posted_Amount__c;
                                }
                            }
                        }
                    }
                }
                if(jpLargestAmount > lpLargestAmount){
                    largestAmountPrParentId = largestAmountJpId;
                }else{
                    largestAmountPrParentId = largestAmountLpId;
                }
                // System.debug('207 largestAmountPrParentId ' + largestAmountPrParentId);
    
                qableJobIdMap.put('PR Rounding Correction Setup', new List<Id>{qc.getJobId()});
    
                if(!Test.isRunningTest()){
                    System.enqueueJob(new CashPrRoundCorrBalancingQable(allNetWagesPayeeList, payeeIdToNewAmountOwedMap, payeeIdToPrListMap, lpJpIdToAmountRemainingMap,
                                                                                largestAmountPrParentId, sumOfNewEmployeeLpsAndJps, sumOfPayeeExistingAmountsOwed, casePayment, qableJobIdMap));
                }
    
    
            }else{ //No rounding correction needed, break payeeIdToPrListMap into a list of PRs for insert.
    
                List<Payment_Record__c> prsToInsert = new List<Payment_Record__c>();
                Set<Id> payeeIds = payeeIdToPrListMap.keySet();

                for(Id payeeId : payeeIds){
    
                    for(Payment_Record__c pr : payeeIdToPrListMap.remove(payeeId)){
                        if(pr.Payment_Amount__c > 0.00){
                            prsToInsert.add(pr);
                        }
                    }
                }

                qableJobIdMap.put('PR Rounding Correction Setup', new List<Id>{qc.getJobId()});
                System.enqueueJob(new CashInsertPrsQable(prsToInsert, casePayment, qableJobIdMap));
            }


        }catch(Exception e){

            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();
            qableJobIdMap.put('PR Rounding Correction Setup', new List<Id>{qc.getJobId()});
            System.attachFinalizer(new CashPrFinalizer(casePayment.Id, casePayment.Name, qableJobIdMap, errorMessage));
        }

    }

    private static Id getPrParentId(Payment_Record__c pr){
        if(pr.Liability_Payment__c != null){
            return pr.Liability_Payment__c;
        }else{
            return pr.Judgment_Payment__c;
        }
    }
}