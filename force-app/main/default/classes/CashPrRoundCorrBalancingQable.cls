//TODO: this class is highly refactorable.
public with sharing class CashPrRoundCorrBalancingQable implements Queueable {
    
    // We need to perform rounding correction balancing between the very last and very first Payees, to 'bridge the gap,' particularly
    //  in the case of a partial payment.
    //We wish to process Payees in groups of 250:
    //  500 Payees: netWagesPayeeList[249] will be the last Payee in the list we process (i.e. the 'nextPayee'), no need to fill overflow list.
    //  501 Payees: netWagesPayeeList[250] will be the last Payee in the list we process (i.e. the 'nextPayee'), no need to fill overflow list.
    //  502 Payees: netWagesPayeeList[250] will be the last Payee in the list we process (i.e. the 'nextPayee'), but also needs to be the first Payee in the overflow list.
    List<Payee__c> netWagesPayeeList;
    List<Payee__c> overflowNetWagesPayeeList = new List<Payee__c>();
    
    Map<Id, Decimal> payeeIdToNewAmountOwedMap = new Map<Id, Decimal>();
    Map<Id, List<Payment_Record__c>> payeeIdToPrListMap = new Map<Id, List<Payment_Record__c>>();
    Map<Id, Decimal> lpJpIdToAmountRemainingMap = new Map<Id, Decimal>();
    Id largestAmountPrParentId;
    Decimal sumOfNewEmployeeLpsAndJps;
    Decimal sumOfPayeeExistingAmountsOwed;
    Map<String, List<Id>> qableJobIdMap;
    Case_Payment__c casePayment;

    //We're processing 500 Payees at a time, but we'll also need the 'nextPayee', so the currently processing
    //  Payee list will need to be of size MAX_PAYEES_PER_BATCH + 1
    Integer MAX_PAYEES_PER_BATCH = 250; 
    
    
    public CashPrRoundCorrBalancingQable(List<Payee__c> netWagesPayees, Map<Id, Decimal> pitnaom, Map<Id, List<Payment_Record__c>> pitprlm, Map<Id, Decimal> ljitarm,
                                                    Id laprpid, Decimal sonelaj, Decimal sopeao, Case_Payment__c cp, Map<String, List<Id>> qJobIdMap) {
        netWagesPayeeList = netWagesPayees;
        // System.debug('30 netWagesPayeeList.size(): ' + netWagesPayeeList.size());
        
        if(netWagesPayeeList.size() > MAX_PAYEES_PER_BATCH + 1){
            overflowNetWagesPayeeList.add(netWagesPayeeList[MAX_PAYEES_PER_BATCH]);
            while(netWagesPayeeList.size() > MAX_PAYEES_PER_BATCH + 1){
                overflowNetWagesPayeeList.add(netWagesPayeeList.remove(MAX_PAYEES_PER_BATCH + 1));
            }
        }

        payeeIdToNewAmountOwedMap = pitnaom;
        payeeIdToPrListMap = pitprlm;
        lpJpIdToAmountRemainingMap = ljitarm;
        largestAmountPrParentId = laprpid;
        sumOfNewEmployeeLpsAndJps = sonelaj;
        sumOfPayeeExistingAmountsOwed = sopeao;
        casePayment = cp;
        qableJobIdMap = qJobIdMap;
    }

    public void execute(QueueableContext qc){

        try{

            //If the LP sum < the Payees owed sum, it means payments are still due. Underpaid Payees should stay that way,
            //  but we still check for any possible Payee overpayments and adjust.
            if(sumOfNewEmployeeLpsAndJps < sumOfPayeeExistingAmountsOwed){

                System.debug('57 netwagespayeelist.size: ' + netWagesPayeeList.size());
    
                for(Integer i = 0; i < netWagesPayeeList.size() - 1; i++){
                    Payee__c currentPayee = netWagesPayeeList[i];
                    Payee__c nextPayee = netWagesPayeeList[i + 1];
    
                    Decimal amountCurrentPayeeNotBalanced = payeeIdToNewAmountOwedMap.get(currentPayee.Id);
                    if(amountCurrentPayeeNotBalanced < 0.00){ //current Payee overpaid
    
                        for(Payment_Record__c currentPayeePr : payeeIdToPrListMap.get(currentPayee.Id)){
                            if(getPrParentId(currentPayeePr) == largestAmountPrParentId){
                                currentPayeePr.Payment_Amount__c += amountCurrentPayeeNotBalanced;
    
                                //This next line is for debugging and should be deletable eventually.
                                // Decimal lpAmountRemainingOld = lpJpIdToAmountRemainingMap.get(getPrParentId(currentPayeePr));
                                lpJpIdToAmountRemainingMap.put(getPrParentId(currentPayeePr), lpJpIdToAmountRemainingMap.get(getPrParentId(currentPayeePr)) + amountCurrentPayeeNotBalanced);
                                // System.debug('204 lpAmountRemainingOld: ' + lpAmountRemainingOld + ' should be zero and ' + amountCurrentPayeeNotBalanced + ' more than new amount: ' + lpJpIdToAmountRemainingMap.get(getPrParentId(currentPayeePr)));
    
                                //This next line is for debugging and should be deletable eventually.
                                // Decimal payeeAmountOwedOld = payeeIdToNewAmountOwedMap.get(currentPayee.Id);
                                payeeIdToNewAmountOwedMap.put(currentPayee.Id, payeeIdToNewAmountOwedMap.get(currentPayee.Id) - amountCurrentPayeeNotBalanced);
                                // System.debug('209 current payeeAmountOwedOld: ' + payeeAmountOwedOld + 'should be ' + amountCurrentPayeeNotBalanced + ' less than new amount: ' + payeeIdToNewAmountOwedMap.get(currentPayee.Id) + ' which should be zero.');
    
                                break;
                            }
                        }
                        for(Payment_Record__c nextPayeePr : payeeIdToPrListMap.get(nextPayee.Id)){
                            if(getPrParentId(nextPayeePr) == largestAmountPrParentId){
                                nextPayeePr.Payment_Amount__c -= amountCurrentPayeeNotBalanced;
    
                                //This next line is for debugging and should be deletable eventually.
                                // Decimal lpAmountRemainingOld = lpJpIdToAmountRemainingMap.get(getPrParentId(nextPayeePr));
                                lpJpIdToAmountRemainingMap.put(getPrParentId(nextPayeePr), lpJpIdToAmountRemainingMap.get(getPrParentId(nextPayeePr)) - amountCurrentPayeeNotBalanced);
                                // System.debug('221 lpAmountRemainingOld: ' + lpAmountRemainingOld + ' should be ' + amountCurrentPayeeNotBalanced + ' less than new amount: ' + lpJpIdToAmountRemainingMap.get(getPrParentId(nextPayeePr)) + ' which should be zero.');
    
                                //This next line is for debugging and should be deletable eventually.
                                // Decimal payeeAmountOwedOld = payeeIdToNewAmountOwedMap.get(nextPayee.Id);
                                payeeIdToNewAmountOwedMap.put(nextPayee.Id, payeeIdToNewAmountOwedMap.get(nextPayee.Id) + amountCurrentPayeeNotBalanced);
                                // System.debug('226 next payeeAmountOwedOld: ' + payeeAmountOwedOld + 'should be ' + amountCurrentPayeeNotBalanced + ' more than new amount: ' + payeeIdToNewAmountOwedMap.get(currentPayee.Id));
    
                                break;
                            }
                        }
                    }
    
                    if(overflowNetWagesPayeeList.isEmpty() && i == netWagesPayeeList.size() - 2){ //nextPayee is the very last Payee
                        Payee__c lastPayee = nextPayee;
                        Decimal amountLastPayeeNotBalanced = payeeIdToNewAmountOwedMap.get(lastPayee.Id);
                        if(amountLastPayeeNotBalanced < 0.00){  //payee overpaid. here we're simply subtracting the amount from both the PR and the LP
                            for(Payment_Record__c lastPayeePr : payeeIdToPrListMap.get(lastPayee.Id)){
                                if(getPrParentId(lastPayeePr) == largestAmountPrParentId){
                                    lastPayeePr.Payment_Amount__c += amountLastPayeeNotBalanced;
        
                                    //This next line is for debugging and should be deletable eventually.
                                    // Decimal lpAmountRemainingOld = lpJpIdToAmountRemainingMap.get(getPrParentId(lastPayeePr));
                                    lpJpIdToAmountRemainingMap.put(getPrParentId(lastPayeePr), lpJpIdToAmountRemainingMap.get(getPrParentId(lastPayeePr)) + amountLastPayeeNotBalanced);
                                    // System.debug('142 lpAmountRemainingOld: ' + lpAmountRemainingOld + ' should be zero and ' + amountLastPayeeNotBalanced + ' more than new amount: ' + lpJpIdToAmountRemainingMap.get(getPrParentId(lastPayeePr)));
        
                                    //This next line is for debugging and should be deletable eventually.
                                    // Decimal payeeAmountOwedOld = payeeIdToNewAmountOwedMap.get(lastPayee.Id);
                                    payeeIdToNewAmountOwedMap.put(lastPayee.Id, payeeIdToNewAmountOwedMap.get(lastPayee.Id) - amountLastPayeeNotBalanced);
                                    // System.debug('147 last payeeAmountOwedOld: ' + payeeAmountOwedOld + 'should be ' + amountLastPayeeNotBalanced + ' less than new amount: ' + payeeIdToNewAmountOwedMap.get(lastPayee.Id) + ' which should be zero.');
        
                                    break;
                                }
                            }
                        }
                    }
    
                    // System.debug('93 at the end of this for loop, lp should still be balanced (0): ' + lpJpIdToAmountRemainingMap.get(largestAmountPrParentId));
                }
    
    
            // if the LP sum == the sum off all Payees owed, this means the wage portion of the case is paid off,
            //  so we check for both Payee under- and overpayments.
            }else if(sumOfNewEmployeeLpsAndJps == sumOfPayeeExistingAmountsOwed){
    
                for(Integer i = 0; i < netWagesPayeeList.size() - 1; i++){
                    Payee__c currentPayee = netWagesPayeeList[i];
                    Payee__c nextPayee = netWagesPayeeList[i + 1];
    
                    Decimal amountCurrentPayeeNotBalanced = payeeIdToNewAmountOwedMap.get(currentPayee.Id);
                    if(amountCurrentPayeeNotBalanced != 0.00){ //current Payee overpaid or underpaid
    
                        for(Payment_Record__c currentPayeePr : payeeIdToPrListMap.get(currentPayee.Id)){
                            if(getPrParentId(currentPayeePr) == largestAmountPrParentId){
                                currentPayeePr.Payment_Amount__c += amountCurrentPayeeNotBalanced;
    
                                // This next line is for debugging and should be deletable eventually.
                                // Decimal lpAmountRemainingOld = lpJpIdToAmountRemainingMap.get(getPrParentId(currentPayeePr));
                                lpJpIdToAmountRemainingMap.put(getPrParentId(currentPayeePr), lpJpIdToAmountRemainingMap.get(getPrParentId(currentPayeePr)) + amountCurrentPayeeNotBalanced);
                                // System.debug('254 lpAmountRemainingOld: ' + lpAmountRemainingOld + ' should be zero and ' + amountCurrentPayeeNotBalanced + ' more than new amount: ' + lpJpIdToAmountRemainingMap.get(getPrParentId(currentPayeePr)));
    
                                // This next line is for debugging and should be deletable eventually.
                                // Decimal payeeAmountOwedOld = payeeIdToNewAmountOwedMap.get(currentPayee.Id);
                                payeeIdToNewAmountOwedMap.put(currentPayee.Id, payeeIdToNewAmountOwedMap.get(currentPayee.Id) - amountCurrentPayeeNotBalanced);
                                // System.debug('259 current payeeAmountOwedOld: ' + payeeAmountOwedOld + 'should be ' + amountCurrentPayeeNotBalanced + ' less than new amount: ' + payeeIdToNewAmountOwedMap.get(currentPayee.Id) + ' which should be zero.');
    
                                break;
                            }
                        }
                        for(Payment_Record__c nextPayeePr : payeeIdToPrListMap.get(nextPayee.Id)){
                            if(getPrParentId(nextPayeePr) == largestAmountPrParentId){
                                nextPayeePr.Payment_Amount__c -= amountCurrentPayeeNotBalanced;
    
                                // This next line is for debugging and should be deletable eventually.
                                // Decimal lpAmountRemainingOld = lpJpIdToAmountRemainingMap.get(getPrParentId(nextPayeePr));
                                lpJpIdToAmountRemainingMap.put(getPrParentId(nextPayeePr), lpJpIdToAmountRemainingMap.get(getPrParentId(nextPayeePr)) - amountCurrentPayeeNotBalanced);
                                // System.debug('271 lpAmountRemainingOld: ' + lpAmountRemainingOld + ' should be ' + amountCurrentPayeeNotBalanced + ' less than new amount: ' + lpJpIdToAmountRemainingMap.get(getPrParentId(nextPayeePr)) + ' which should be zero.');
    
                                // This next line is for debugging and should be deletable eventually.
                                // Decimal payeeAmountOwedOld = payeeIdToNewAmountOwedMap.get(nextPayee.Id);
                                payeeIdToNewAmountOwedMap.put(nextPayee.Id, payeeIdToNewAmountOwedMap.get(nextPayee.Id) + amountCurrentPayeeNotBalanced);
                                // System.debug('276 next payeeAmountOwedOld: ' + payeeAmountOwedOld + 'should be ' + amountCurrentPayeeNotBalanced + ' more than new amount: ' + payeeIdToNewAmountOwedMap.get(currentPayee.Id));
                                break;
                            }
                        }
                    }
    
                    if(overflowNetWagesPayeeList.isEmpty() && i == netWagesPayeeList.size() - 2){ //nextPayee is the very last Payee
                        Payee__c lastPayee = nextPayee;
                        Decimal amountLastPayeeNotBalanced = payeeIdToNewAmountOwedMap.get(lastPayee.Id);
                        if(amountLastPayeeNotBalanced != 0.00){  //payee overpaid or underpaid. here we're simply subtracting the amount from both the PR and the LP.
                                                                 // TODO: compare amountLastPayeeNotBalanced == lpJpIdAmountRemainingMap--should be same value--before making changes.
                            for(Payment_Record__c lastPayeePr : payeeIdToPrListMap.get(lastPayee.Id)){
                                if(getPrParentId(lastPayeePr) == largestAmountPrParentId){
                                    lastPayeePr.Payment_Amount__c += amountLastPayeeNotBalanced;
        
                                    //This next line is for debugging and should be deletable eventually.
                                    // Decimal lpAmountRemainingOld = lpJpIdToAmountRemainingMap.get(getPrParentId(lastPayeePr));
                                    lpJpIdToAmountRemainingMap.put(getPrParentId(lastPayeePr), lpJpIdToAmountRemainingMap.get(getPrParentId(lastPayeePr)) + amountLastPayeeNotBalanced);
                                    // System.debug('142 lpAmountRemainingOld: ' + lpAmountRemainingOld + ' should be zero and ' + amountLastPayeeNotBalanced + ' more than new amount: ' + lpJpIdToAmountRemainingMap.get(getPrParentId(lastPayeePr)));
        
                                    //This next line is for debugging and should be deletable eventually.
                                    // Decimal payeeAmountOwedOld = payeeIdToNewAmountOwedMap.get(lastPayee.Id);
                                    payeeIdToNewAmountOwedMap.put(lastPayee.Id, payeeIdToNewAmountOwedMap.get(lastPayee.Id) - amountLastPayeeNotBalanced);
                                    // System.debug('147 last payeeAmountOwedOld: ' + payeeAmountOwedOld + 'should be ' + amountLastPayeeNotBalanced + ' less than new amount: ' + payeeIdToNewAmountOwedMap.get(lastPayee.Id) + ' which should be zero.');
        
                                    break;
                                }
                            }
                        }
                    }
    
                    // System.debug('143 at the end of this for loop, lp should still be balanced (0): ' + lpJpIdToAmountRemainingMap.get(largestAmountPrParentId));
                }
    
    
            // if the LP sum > the sum of all Payees owed, it means more funds came in on the case and the Case Issues/Judgments were likely overallocated.
            //  There's no way to balance this situation.
            //  (Case Issue.EE(s) Amt Assessed' [DIR_Violation__c.Wages_Due__c] Payee.Net Wages Assessed [Payee__c.NetWages__c]' incorrect?) and the payor is likely due a refund.
            }else{
    
                String errorMessage = 'Error in Payment Record rounding correction: ' +
                                        'Sum of Liability Payments, $' + sumOfNewEmployeeLpsAndJps +
                                        ', greater than sum of amount owed to Payees, $' + sumOfPayeeExistingAmountsOwed + ',' +
                                        'Was a Case Issue or Judgment overallocated? Case Issue or Judgment assessment too low? Is the Payor due a refund?';
    
                System.attachFinalizer(new CashPrFinalizer(casePayment.Id, casePayment.Name, qableJobIdMap, errorMessage));
    
                // throw new CashCustomException('Error in Payment Record rounding correction: ' +
                //                 'Sum of Liability Payments, $' + sumOfNewEmployeeLpsAndJps + ', greater than sum of amount owed to Payees, $' + sumOfPayeeExistingAmountsOwed + ',' +
                //                 'Was a Case Issue or Judgment overallocated? Case Issue or Judgment assessment too low? Is the Payor due a refund?');
            }
    
            if(qableJobIdMap.containsKey('PR Rounding Correction Balancing')){
                List<Id> tempList = qableJobIdMap.get('PR Rounding Correction Balancing');
                tempList.add(qc.getJobId());
                qableJobIdMap.put('PR Rounding Correction Balancing', tempList);
            }else{
                qableJobIdMap.put('PR Rounding Correction Balancing', new List<Id>{qc.getJobId()});
            }
    
            //If there are overflow Payees, recurse this class on them
            if(!overflowNetWagesPayeeList.isEmpty()){
                // System.debug('168 overflowPayees: ' + overflowNetWagesPayeeList.size());
                System.enqueueJob(new CashPrRoundCorrBalancingQable(overflowNetWagesPayeeList, payeeIdToNewAmountOwedMap, payeeIdToPrListMap, lpJpIdToAmountRemainingMap,
                                                                        largestAmountPrParentId, sumOfNewEmployeeLpsAndJps, sumOfPayeeExistingAmountsOwed, casePayment, qableJobIdMap));
            }else{
                //Rounding correction done on the PRs that need it, now break payeeIdToPrListMap into just a list of PRs ready for insert.
                //  Filter out any PRs that may be $0
                List<Payment_Record__c> prsToInsert = new List<Payment_Record__c>();
                for(Id payeeId : payeeIdToPrListMap.keySet()){
                    for(Payment_Record__c pr : payeeIdToPrListMap.remove(payeeId)){
                        if(pr.Payment_Amount__c > 0.00){
                            prsToInsert.add(pr);
                        }
                    }
                }
                if(!Test.isRunningTest()){
                    System.enqueueJob(new CashInsertPrsQable(prsToInsert, casePayment, qableJobIdMap));
                }
            }


        }catch(Exception e){

            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();

            if(qableJobIdMap.containsKey('PR Rounding Correction Balancing')){
                List<Id> tempList = qableJobIdMap.get('PR Rounding Correction Balancing');
                tempList.add(qc.getJobId());
                qableJobIdMap.put('PR Rounding Correction Balancing', tempList);
            }else{
                qableJobIdMap.put('PR Rounding Correction Balancing', new List<Id>{qc.getJobId()});
            }

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