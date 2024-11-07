// TODO: remove empty if/else blocks? good for organization though...
public with sharing class CashCreatePrsQable implements Queueable {

    Case_Payment__c casePayment;
    List<Payee__c> allPayeeList;
    List<Liability_Payment__c> allCu1List;
    List<Liability_Payment__c> allLpList;
    List<Judgment_Payment__c> allJpList;

    public CashCreatePrsQable(Case_Payment__c cp, List<Payee__c> allPayees, List<Liability_Payment__c> allCu1s, List<Liability_Payment__c> allLps, List<Judgment_Payment__c> allJps) {
        casePayment = cp;
        allPayeeList = allPayees;
        allCu1List = allCu1s;
        allLpList = allLps;
        allJpList = allJps;
    }

    public void execute(QueueableContext qc){

        try{
        
            Map<Id, List<Payment_Record__c>> payeeIdToPrListMap = new Map<Id, List<Payment_Record__c>>();
            for(Payee__c payee : allPayeeList){
    
                //Any changes done here to when different types of PRs are created per LP/JP and Payee type need to also be reflected in
                //  CashPrRoundCorrSetupQable.cls.
    
                //--> Employee Payees : LP.Wages, LP.Wage Interest, LP.WCA-type Interest, JP.Post-Hearing Interest, JP.Post-Judgment Interest.
                if(payee.Payee_Type__c == 'Employee' || payee.Payee_Type__c == 'Employee - Net Wages'){ //TODO: Net Wages type should be deprecated if it hasn't already.
                    for(Liability_Payment__c lp : allLpList){
                        if(lp.Payment_Applied_To__c == 'Wages' || lp.Payment_Applied_To__c == 'Wage Interest'){
                            Decimal prAmount = (lp.Posted_Amount__c * (payee.Factor__c == null ? 0 : payee.Factor__c / 100)).setScale(2, RoundingMode.HALF_UP);
                            Payment_Record__c pr = new Payment_Record__c(
                                Liability_Payment__c = lp.Id,
                                Payee__c = payee.Id,
                                Payee_Name__c = payee.Payee_Name__c,
                                Payment_Amount__c = prAmount,
                                Receipt_Hold_Date_New__c = casePayment.Receipt__r.Hold_Date__c,
                                Payment_Applied_To__c = lp.Payment_Applied_To__c
                            );
                            if(payeeIdToPrListMap.containsKey(payee.Id)){
                                payeeIdToPrListMap.get(payee.Id).add(pr);
                            }else{
                                payeeIdToPrListMap.put(payee.Id, new List<Payment_Record__c>{pr});
                            }
                        }else if(lp.Payment_Applied_To__c == 'Interest'){
                            if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()){
                                Decimal prAmount = (lp.Posted_Amount__c * (payee.Factor__c == null ? 0 : payee.Factor__c / 100)).setScale(2, RoundingMode.HALF_UP);
                                Payment_Record__c pr = new Payment_Record__c(
                                    Liability_Payment__c = lp.Id,
                                    Payee__c = payee.Id,
                                    Payee_Name__c = payee.Payee_Name__c,
                                    Payment_Amount__c = prAmount,
                                    Receipt_Hold_Date_New__c = casePayment.Receipt__r.Hold_Date__c,
                                    Payment_Applied_To__c = lp.Payment_Applied_To__c
                                );
                                if(payeeIdToPrListMap.containsKey(payee.Id)){
                                    payeeIdToPrListMap.get(payee.Id).add(pr);
                                }else{
                                    payeeIdToPrListMap.put(payee.Id, new List<Payment_Record__c>{pr});
                                }
                            }else if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()){
                                //This goes exclusively to the BOFE Penalty Payee
                            }
                        }else if(lp.Payment_Applied_To__c == 'Penalties'){
                            //This goes exclusively to the BOFE Penalty Payee
                        }
                    }
    
                    for(Judgment_Payment__c jp : allJpList){
                        if(jp.Payment_Applied_To__c != 'Judgment Amount'){
                            if(jp.Payment_Applied_To__c == 'Post-Hearing Interest' || jp.Payment_Applied_To__c == 'Post-Judgment Interest'){
                                Decimal prAmount = (jp.Posted_Amount__c * (payee.Factor__c == null ? 0 : payee.Factor__c / 100)).setScale(2, RoundingMode.HALF_UP);
                                Payment_Record__c pr = new Payment_Record__c(
                                    Judgment_Payment__c = jp.Id,
                                    Payee__c = payee.Id,
                                    Payee_Name__c = payee.Payee_Name__c,
                                    Payment_Amount__c = prAmount,
                                    Receipt_Hold_Date_New__c = casePayment.Receipt__r.Hold_Date__c,
                                    Payment_Applied_To__c = jp.Payment_Applied_To__c
                                );
                                if(payeeIdToPrListMap.containsKey(payee.Id)){
                                    payeeIdToPrListMap.get(payee.Id).add(pr);
                                }else{
                                    payeeIdToPrListMap.put(payee.Id, new List<Payment_Record__c>{pr});
                                }
                            }else if(jp.Payment_Applied_To__c == 'Attorney Fees'){
                                //This goes exclusively to the DIR Accounting Payee
                            }else if(jp.Payment_Applied_To__c == 'Filing Fees'){
                                //This goes exclusively to the Court Payee
                            }
                        }
                    }
    
                    for(Liability_Payment__c cu1 : allCu1List){
                        if(cu1.Payment_Applied_To__c == 'Refund Amount'){
                            //This goes exclusively to the Payor Payee
                        }else if(cu1.Payment_Applied_To__c == 'Amounts Due to DIR'){
                            //This goes exclusively to the 'DIR Accounting' Payee
                        }else if(cu1.Payment_Applied_To__c == 'Other Amount'){
                            //This is intended to have PRs manually created by a Cashiering Super User or SysAd
                        }
                    }
                
                //--> DIR Accounting Payee : JP.Attorney Fees, CU-1.Amounts Due to DIR
                }else if(payee.Payee_Type__c == 'State' && payee.Payee_Name__c == 'DIR Accounting'){
                    for(Liability_Payment__c lp : allLpList){
                        if(lp.Payment_Applied_To__c == 'Wages'){
                            //This goes exclusively to the Employee Payees
                        }else if(lp.Payment_Applied_To__c == 'Wage Interest'){
                            //This goes exclusively to the Employee Payees
                        }else if(lp.Payment_Applied_To__c == 'Interest'){
                            if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()){
                                //This goes exclusively to the Employee Payees
                            }else if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()){
                                //This goes exclusively to the BOFE Penalty Payee
                            }
                        }else if(lp.Payment_Applied_To__c == 'Penalties'){
                            //This goes exclusively to the BOFE Penalty Payee
                        }
                    }
                    for(Judgment_Payment__c jp : allJpList){
                        if(jp.Payment_Applied_To__c != 'Judgment Amount'){
                            if(jp.Payment_Applied_To__c == 'Post-Hearing Interest' || jp.Payment_Applied_To__c == 'Post-Judgment Interest'){
                                //This goes exclusively to the Employee Payees
                            }else if(jp.Payment_Applied_To__c == 'Attorney Fees'){
                                Decimal prAmount = (jp.Posted_Amount__c * (payee.Factor__c == null ? 0 : payee.Factor__c / 100)).setScale(2, RoundingMode.HALF_UP);
                                Payment_Record__c pr = new Payment_Record__c(
                                    Judgment_Payment__c = jp.Id,
                                    Payee__c = payee.Id,
                                    Payee_Name__c = payee.Payee_Name__c,
                                    Payment_Amount__c = prAmount,
                                    Receipt_Hold_Date_New__c = casePayment.Receipt__r.Hold_Date__c,
                                    Payment_Applied_To__c = jp.Payment_Applied_To__c
                                );
                                if(payeeIdToPrListMap.containsKey(payee.Id)){
                                    payeeIdToPrListMap.get(payee.Id).add(pr);
                                }else{
                                    payeeIdToPrListMap.put(payee.Id, new List<Payment_Record__c>{pr});
                                }
                                
                            }else if(jp.Payment_Applied_To__c == 'Filing Fees'){
                                //This goes exclusively to the Court Payee
                            }
                        }
                    }
                    for(Liability_Payment__c cu1 : allCu1List){
                        if(cu1.Payment_Applied_To__c == 'Refund Amount'){
                            //This goes exclusively to the Payor Payee
                        }else if(cu1.Payment_Applied_To__c == 'Amounts Due to DIR'){
                            Decimal prAmount = (cu1.Posted_Amount__c * (payee.Factor__c == null ? 0 : payee.Factor__c / 100)).setScale(2, RoundingMode.HALF_UP);
                            Payment_Record__c pr = new Payment_Record__c(
                                Liability_Payment__c = cu1.Id,
                                Payee__c = payee.Id,
                                Payee_Name__c = payee.Payee_Name__c,
                                Payment_Amount__c = prAmount,
                                Receipt_Hold_Date_New__c = casePayment.Receipt__r.Hold_Date__c,
                                Payment_Applied_To__c = cu1.Payment_Applied_To__c
                            );
                            if(payeeIdToPrListMap.containsKey(payee.Id)){
                                payeeIdToPrListMap.get(payee.Id).add(pr);
                            }else{
                                payeeIdToPrListMap.put(payee.Id, new List<Payment_Record__c>{pr});
                            }

                        }else if(cu1.Payment_Applied_To__c == 'Other Amount'){
                            //This is intended to have PRs manually created by a Cashiering Super User or SysAd
                        }
                    }
                
                //--> BOFE Penalty Payee : LP.BOFE-type Interest, LP.Penalties
                }else if(payee.Payee_Type__c == 'State' && payee.Payee_Name__c == 'DLSE - Centralized Cashiering Unit'){
                    for(Liability_Payment__c lp : allLpList){
                        if(lp.Payment_Applied_To__c == 'Wages'){
                            //This goes exclusively to the Employee Payees
                        }else if(lp.Payment_Applied_To__c == 'Wage Interest'){
                            //This goes exclusively to the Employee Payees
                        }else if(lp.Payment_Applied_To__c == 'Interest'){
                            if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()){
                                //This goes exclusively to the Employee Payees
                            }else if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()){
                                Decimal prAmount = (lp.Posted_Amount__c * (payee.Factor__c == null ? 0 : payee.Factor__c / 100)).setScale(2, RoundingMode.HALF_UP);
                                Payment_Record__c pr = new Payment_Record__c(
                                    Liability_Payment__c = lp.Id,
                                    Payee__c = payee.Id,
                                    Payee_Name__c = payee.Payee_Name__c,
                                    Payment_Amount__c = prAmount,
                                    Receipt_Hold_Date_New__c = casePayment.Receipt__r.Hold_Date__c,
                                    Payment_Applied_To__c = lp.Payment_Applied_To__c
                                );
                                if(payeeIdToPrListMap.containsKey(payee.Id)){
                                    payeeIdToPrListMap.get(payee.Id).add(pr);
                                }else{
                                    payeeIdToPrListMap.put(payee.Id, new List<Payment_Record__c>{pr});
                                }
                                
                            }
                        }else if(lp.Payment_Applied_To__c == 'Penalties'){
                            Decimal prAmount = (lp.Posted_Amount__c * (payee.Factor__c == null ? 0 : payee.Factor__c / 100)).setScale(2, RoundingMode.HALF_UP);
                            Payment_Record__c pr = new Payment_Record__c(
                                Liability_Payment__c = lp.Id,
                                Payee__c = payee.Id,
                                Payee_Name__c = payee.Payee_Name__c,
                                Payment_Amount__c = prAmount,
                                Receipt_Hold_Date_New__c = casePayment.Receipt__r.Hold_Date__c,
                                Payment_Applied_To__c = lp.Payment_Applied_To__c
                            );
                            if(payeeIdToPrListMap.containsKey(payee.Id)){
                                payeeIdToPrListMap.get(payee.Id).add(pr);
                            }else{
                                payeeIdToPrListMap.put(payee.Id, new List<Payment_Record__c>{pr});
                            }
                        }
                    }
                    for(Judgment_Payment__c jp : allJpList){
                        if(jp.Payment_Applied_To__c != 'Judgment Amount'){
                            if(jp.Payment_Applied_To__c == 'Post-Hearing Interest' || jp.Payment_Applied_To__c == 'Post-Judgment Interest'){
                                //This goes exclusively to the Employee Payees
                            }else if(jp.Payment_Applied_To__c == 'Attorney Fees'){
                                //This goes exclusively to the DIR Accounting Payee
                            }else if(jp.Payment_Applied_To__c == 'Filing Fees'){
                                //This goes exclusively to the Court Payee
                            }
                        }
                    }
                    for(Liability_Payment__c cu1 : allCu1List){
                        if(cu1.Payment_Applied_To__c == 'Refund Amount'){
                            //This goes exclusively to the Payor Payee
                        }else if(cu1.Payment_Applied_To__c == 'Amounts Due to DIR'){
                            //This goes exclusively to the 'DIR Accounting' Payee
                        }else if(cu1.Payment_Applied_To__c == 'Other Amount'){
                            //This is intended to have PRs manually created by a Cashiering Super User or SysAd
                        }
                    }
                
                //--> Court Payee : JP.Filing Fees
                }else if(payee.Payee_Type__c == 'Court'){
                    for(Liability_Payment__c lp : allLpList){
                        if(lp.Payment_Applied_To__c == 'Wages'){
                            //This goes exclusively to the Employee Payees
                        }else if(lp.Payment_Applied_To__c == 'Wage Interest'){
                            //This goes exclusively to the Employee Payees
                        }else if(lp.Payment_Applied_To__c == 'Interest'){
                            if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()){
                                //This goes exclusively to the Employee Payees
                            }else if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()){
                                //This goes exclusively to the BOFE Penalty Payee
                            }
                        }else if(lp.Payment_Applied_To__c == 'Penalties'){
                            //This goes exclusively to the BOFE Penalty Payee
                        }
                    }
                    for(Judgment_Payment__c jp : allJpList){
                        if(jp.Payment_Applied_To__c != 'Judgment Amount'){
                            if(jp.Payment_Applied_To__c == 'Post-Hearing Interest' || jp.Payment_Applied_To__c == 'Post-Judgment Interest'){
                                //This goes exclusively to the Employee Payees
                            }else if(jp.Payment_Applied_To__c == 'Attorney Fees'){
                                //This goes exclusively to the DIR Accounting Payee
                            }else if(jp.Payment_Applied_To__c == 'Filing Fees'){
                                Decimal prAmount = (jp.Posted_Amount__c * (payee.Factor__c == null ? 0 : payee.Factor__c / 100)).setScale(2, RoundingMode.HALF_UP);
                                Payment_Record__c pr = new Payment_Record__c(
                                    Judgment_Payment__c = jp.Id,
                                    Payee__c = payee.Id,
                                    Payee_Name__c = payee.Payee_Name__c,
                                    Payment_Amount__c = prAmount,
                                    Receipt_Hold_Date_New__c = casePayment.Receipt__r.Hold_Date__c,
                                    Payment_Applied_To__c = jp.Payment_Applied_To__c
                                );
                                if(payeeIdToPrListMap.containsKey(payee.Id)){
                                    payeeIdToPrListMap.get(payee.Id).add(pr);
                                }else{
                                    payeeIdToPrListMap.put(payee.Id, new List<Payment_Record__c>{pr});
                                }
                            }
                        }
                    }
                    for(Liability_Payment__c cu1 : allCu1List){
                        if(cu1.Payment_Applied_To__c == 'Refund Amount'){
                            //This goes exclusively to the Payor Payee
                        }else if(cu1.Payment_Applied_To__c == 'Amounts Due to DIR'){
                            //This goes exclusively to the 'DIR Accounting' Payee
                            
                            /* Decimal prAmount = (cu1.Posted_Amount__c * (payee.Factor__c == null ? 0 : payee.Factor__c / 100)).setScale(2, RoundingMode.HALF_UP);
                            Payment_Record__c pr = new Payment_Record__c(
                                Liability_Payment__c = cu1.Id,
                                Payee__c = payee.Id,
                                Payment_Amount__c = prAmount,
                                Receipt_Hold_Date_New__c = casePayment.Receipt__r.Hold_Date__c,
                                Payment_Applied_To__c = cu1.Payment_Applied_To__c
                            );
                            if(payeeIdToPrListMap.containsKey(payee.Id)){
                                payeeIdToPrListMap.get(payee.Id).add(pr);
                            }else{
                                payeeIdToPrListMap.put(payee.Id, new List<Payment_Record__c>{pr});
                            } */
                        }else if(cu1.Payment_Applied_To__c == 'Other Amount'){
                            //This is intended to have PRs manually created by a Cashiering Super User or SysAd
                        }
                    }
                
                //--> Payor Payee : CU-1.Refund
                }else if(payee.Payee_Type__c == 'Payor'){
                    for(Liability_Payment__c lp : allLpList){
                        if(lp.Payment_Applied_To__c == 'Wages'){
                            //This goes exclusively to the Employee Payees
                        }else if(lp.Payment_Applied_To__c == 'Wage Interest'){
                            //This goes exclusively to the Employee Payees
                        }else if(lp.Payment_Applied_To__c == 'Interest'){
                            if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()){
                                //This goes exclusively to the Employee Payees
                            }else if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()){
                                //This goes exclusively to the BOFE Penalty Payee
                            }
                        }else if(lp.Payment_Applied_To__c == 'Penalties'){
                            //This goes exclusively to the BOFE Penalty Payee
                        }
                    }
                    for(Judgment_Payment__c jp : allJpList){
                        if(jp.Payment_Applied_To__c != 'Judgment Amount'){
                            if(jp.Payment_Applied_To__c == 'Post-Hearing Interest' || jp.Payment_Applied_To__c == 'Post-Judgment Interest'){
                                //This goes exclusively to the Employee Payees
                            }else if(jp.Payment_Applied_To__c == 'Attorney Fees'){
                                //This goes exclusively to the DIR Accounting Payee
                            }else if(jp.Payment_Applied_To__c == 'Filing Fees'){
                                //This goes exclusively to the Court Payee
                            }
                        }
                    }
                    for(Liability_Payment__c cu1 : allCu1List){
                        if(cu1.Payment_Applied_To__c == 'Refund Amount' &&
                                cu1.Case_Payment__r.Receipt__r.Payor__c == payee.Case_Role__r.Entity__c){ //A Case could have multiple Payor Payees, we verify that this payee is the RCT's Payor.
                            Decimal prAmount = (cu1.Posted_Amount__c * (payee.Factor__c == null ? 0 : payee.Factor__c / 100)).setScale(2, RoundingMode.HALF_UP);
                            Payment_Record__c pr = new Payment_Record__c(
                                Liability_Payment__c = cu1.Id,
                                Payee__c = payee.Id,
                                Payee_Name__c = payee.Payee_Name__c,
                                Payment_Amount__c = prAmount,
                                Receipt_Hold_Date_New__c = casePayment.Receipt__r.Hold_Date__c,
                                Payment_Applied_To__c = cu1.Payment_Applied_To__c
                            );
                            if(payeeIdToPrListMap.containsKey(payee.Id)){
                                payeeIdToPrListMap.get(payee.Id).add(pr);
                            }else{
                                payeeIdToPrListMap.put(payee.Id, new List<Payment_Record__c>{pr});
                            }
                        }else if(cu1.Payment_Applied_To__c == 'Amounts Due to DIR'){
                            //This goes exclusively to the 'DIR Accounting' Payee
                        }else if(cu1.Payment_Applied_To__c == 'Other Amount'){
                            //This is intended to have PRs manually created by a Cashiering Super User or SysAd
                        }
                    }
                }
            }
    
            Map<String, List<Id>> qableJobIdMap = new Map<String, List<Id>>();
            qableJobIdMap.put('Create PRs', new List<Id>{qc.getJobId()});
            
            if(!Test.isRunningTest()){
                System.enqueueJob(new CashPrRoundCorrSetupQable(casePayment, payeeIdToPrListMap, allPayeeList, allLpList, allJpList, qableJobIdMap));
            }

        }catch(Exception e){

            String errorMessage = e.getTypeName() + ': [' + e.getLineNumber() + '] ' + e.getMessage() + '<br/>Stack trace:<br/>' + e.getStackTraceString();
            Map<String, List<Id>> qableJobIdMap = new Map<String, List<Id>>();
            qableJobIdMap.put('Create PRs', new List<Id>{qc.getJobId()});
            System.attachFinalizer(new CashPrFinalizer(casePayment.Id, casePayment.Name, qableJobIdMap, errorMessage));
        }
    
    }

}