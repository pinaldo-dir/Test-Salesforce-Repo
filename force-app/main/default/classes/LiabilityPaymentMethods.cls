// Called by LiabilityPaymentTrigger.
public without sharing class LiabilityPaymentMethods {
    public LiabilityPaymentMethods() { }

    public static void liabilityPaymentRollups(List<Liability_Payment__c> triggerLps){
        //Rolls up to Case Issues, Case Payments, and Liable Parties.
        
        /****************************
            Rollup to Case Issues
        ****************************/

        Set<Id> ciIds = new Set<Id>();
        for(Liability_Payment__c lp : triggerLps){
            ciIds.add(lp.Case_Violation__c);
        }
        //triggerLps will not necessarily contain all the LPs under all the CIs, so we query them here
        List<DIR_Violation__c> ciList = [SELECT Id, Name, Penalty_Payments_Received__c, Interest_Payments_Received__c, Wage_Payments_Received__c, Wage_Interest_Payments_Received__c,
                                                (SELECT Id, Case_Violation__c, Case_Payment__c, Case_Payment__r.Voided_Item__c, Posted_Amount__c, Payment_Applied_To__c
                                                    FROM Liability_Payments__r)
                                                FROM DIR_Violation__c
                                                WHERE Id IN: ciIds];
                                                
        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
        for(DIR_Violation__c ci : ciList){
            lpList.addAll(ci.Liability_Payments__r);
        }        

        //Map of CI.Id to a map of LP.Payment_Applied_To__c (Penalties, Interest [WCA EE Interest? or BOFE Pentalty Interest], Wages, Wage Interest [BOFE Wage Interest]) to Posted_Amount__c
        Map<Id, Map<String, Decimal>> ciToLpMap = new Map<Id, Map<String, Decimal>>();
        
        for(Liability_Payment__c lp : lpList){
            //if(lp.Case_Payment__r.Voided_Item__c != TRUE){ //Voided LPs do not roll up to the CI
                if(!ciToLpMap.containsKey(lp.Case_Violation__c)) {
                    Map<String, Decimal> newMap = new Map<String, Decimal>();
                    newMap.put('Penalties', 0.00);
                    newMap.put('Interest', 0.00);
                    newMap.put('Wages', 0.00);
                    newMap.put('Wage Interest', 0.00);

                    if(lp.Posted_Amount__c != null){ //This should filter out LPs that are not in Posted status.
                        newMap.put(lp.Payment_Applied_To__c, lp.Posted_Amount__c);
                    }
                    ciToLpMap.put(lp.Case_Violation__c, newMap);
                }else{
                    if(lp.Posted_Amount__c != null){
                        Map<String, Decimal> retrievedMap = ciToLpMap.get(lp.Case_Violation__c);
                        retrievedMap.put(lp.Payment_Applied_To__c, retrievedMap.get(lp.Payment_Applied_To__c) + lp.Posted_Amount__c);
                        ciToLpMap.put(lp.Case_Violation__c, retrievedMap);
                    }
                }
            //}
        }

        for(DIR_Violation__c ci: ciList) {
            if(ciToLpMap.containsKey(ci.Id)) {
                Map<String, Decimal> lpToAmountMap = ciToLpMap.get(ci.Id);
                ci.Penalty_Payments_Received__c = lpToAmountMap.get('Penalties'); // "Civil Penalty Payments Rec'd"
                ci.Interest_Payments_Received__c = lpToAmountMap.get('Interest');
                ci.Wage_Payments_Received__c = lpToAmountMap.get('Wages'); // "EE Payments Rec'd"
                ci.Wage_Interest_Payments_Received__c = lpToAmountMap.get('Wage Interest');
            }
        }
        System.debug('63 ciList: ' + ciList);

        update ciList;


        /********************************
            Rollup to Case Payments
        *********************************/

        Set<Id> cpIds = new Set<Id>();
        for(Liability_Payment__c lp : triggerLps){
            cpIds.add(lp.Case_Payment__c);
        }
        //triggerLps will not necessarily contain all the LPs under all the CPs, so we query them here
        List<Case_Payment__c> cpList = [SELECT Id, Name, Amount_Payable_to_Employees__c, Amount_Payable_to_State__c, Voided_Item__c,
                                            (SELECT Id, Name, Status__c, Posted_Amount__c, Payment_Applied_To__c, Case_Payment__c
                                                FROM Liability_Payments__r)
                                            FROM Case_Payment__c
                                            WHERE Id IN :cpIds];
        
        lpList = new List<Liability_Payment__c>();
        for(Case_Payment__c cp : cpList){
            lpList.addAll(cp.Liability_Payments__r);
        }
        
        //Map of CP.Id to a map of LP.Payment_Applied_To__c (Penalties, Interest [WCA EE Interest? or BOFE Pentalty Interest], Wages, Wage Interest [BOFE Wage Interest]) to Posted_Amount__c
        Map<String, Map<String, Decimal>> cpToLpMap = new Map<String, Map<String, Decimal>>();
        
        for(Liability_Payment__c lp : lpList){
            if(!cpToLpMap.containsKey(lp.Case_Payment__c)) {
                Map<String, Decimal> newMap = new Map<String, Decimal>();
                //Not all of the following buckets roll up to the CP; only 'Penalties' and 'Wages'.
                newMap.put('Wages', 0.00);
                newMap.put('Wage Interest', 0.00);
                newMap.put('Penalties', 0.00);
                newMap.put('Interest', 0.00);
                newMap.put('Amounts Due to DIR', 0.00);
                newMap.put('Refund Amount', 0.00);
                newMap.put('Buyback', 0.00);
                newMap.put('Other Amount', 0.00);
                newMap.put('Hold Amount', 0.00); //TODO: deprecated, this line should be deletable after deployment.
                
                if(lp.Posted_Amount__c != null){ //This should filter out LPs that are not in Posted status.
                    newMap.put(lp.Payment_Applied_To__c, lp.Posted_Amount__c);
                }
                cpToLpMap.put(lp.Case_Payment__c, newMap);
            }else{
                if(lp.Posted_Amount__c != null){
                    Map<String, Decimal> retrievedMap = cpToLpMap.get(lp.Case_Payment__c);
                    retrievedMap.put(lp.Payment_Applied_To__c, retrievedMap.get(lp.Payment_Applied_To__c) + lp.Posted_Amount__c);
                    cpToLpMap.put(lp.Case_Payment__c, retrievedMap);
                }
            }
        }

        for(Case_Payment__c cp : cpList) {
            if(cpToLpMap.containsKey(cp.Id)) {
                Map<String, Decimal> lpToAmountMap = cpToLpMap.get(cp.Id);
                cp.Amount_Payable_to_State__c = lpToAmountMap.get('Penalties');
                cp.Amount_Payable_to_Employees__c = lpToAmountMap.get('Wages');

                //TODO: other categories? BOFE Wage Interest -> employee? 'Regular' Interest -> state?
            }
        }
        
        System.debug('128 cpList: ' + cpList);

        update cpList;


        /********************************
            Rollup to Liable Parties
        *********************************/

        Set<Id> liablePartyIds = new Set<Id>();
        for(Liability_Payment__c lp : triggerLps){
            liablePartyIds.add(lp.Payment_On_Behalf_Of__c);
        }
        //triggerLps will not necessarily contain all the LPs under all the Liable Parties, so we query them here
        List<Liable_Party__c> liablePartyList = [SELECT Id, Name, Interest_Amount_Collected__c, Penalty_Amount_Collected__c, Wage_Amount_Collected__c, Wage_Interest_Amount_Collected__c,
                                                    (SELECT Id, Name, Status__c, Posted_Amount__c, Payment_Applied_To__c, Payment_On_Behalf_Of__c
                                                    FROM Liability_Payments__r)
                                                FROM Liable_Party__c
                                                WHERE Id IN :liablePartyIds];
        
        lpList = new List<Liability_Payment__c>();
        for(Liable_Party__c liableParty: liablePartyList){
            lpList.addAll(liableParty.Liability_Payments__r);
        }
        
        //Map of Liable Party.Id to a map of LP.Payment_Applied_To__c (Penalties, Interest [WCA EE Interest? or BOFE Pentalty Interest], Wages, Wage Interest [BOFE Wage Interest])
        // to LP.Posted_Amount__c
        Map<String, Map<String, Decimal>> liablePartyToLpMap = new Map<String, Map<String, Decimal>>();
        
        for(Liability_Payment__c lp : lpList){
            if(lp.Payment_Applied_To__c == 'Penalties' || lp.Payment_Applied_To__c == 'Interest' || lp.Payment_Applied_To__c == 'Wages' || lp.Payment_Applied_To__c == 'Wage Interest'){
                //^Filters out CU1 records
                if(!liablePartyToLpMap.containsKey(lp.Payment_On_Behalf_Of__c)) {
                    Map<String, Decimal> newMap = new Map<String, Decimal>();
                    newMap.put('Penalties', 0.00);
                    newMap.put('Interest', 0.00);
                    newMap.put('Wages', 0.00);
                    newMap.put('Wage Interest', 0.00);
                    
                    if(lp.Posted_Amount__c != null){ //This should filter out LPs that are not in Posted status.
                        newMap.put(lp.Payment_Applied_To__c, lp.Posted_Amount__c);
                    }
                    liablePartyToLpMap.put(lp.Payment_On_Behalf_Of__c, newMap);
                }else{
                    if(lp.Posted_Amount__c != null){
                        Map<String, Decimal> retrievedMap = liablePartyToLpMap.get(lp.Payment_On_Behalf_Of__c);
                        retrievedMap.put(lp.Payment_Applied_To__c, retrievedMap.get(lp.Payment_Applied_To__c) + lp.Posted_Amount__c);
                        liablePartyToLpMap.put(lp.Payment_On_Behalf_Of__c, retrievedMap);
                    }
                }
            }
        }

        for(Liable_Party__c liableParty : liablePartyList) {
            if(liablePartyToLpMap.containsKey(liableParty.Id)) {
                Map<String, Decimal> lpToAmountMap = liablePartyToLpMap.get(liableParty.Id);
                liableParty.Penalty_Amount_Collected__c = lpToAmountMap.get('Penalties');
                liableParty.Wage_Amount_Collected__c = lpToAmountMap.get('Wages');
                liableParty.Interest_Amount_Collected__c = lpToAmountMap.get('Interest');
                liableParty.Wage_Interest_Amount_Collected__c = lpToAmountMap.get('Wage Interest');
            }
        }
        
        System.debug('191 liablePartyList: ' + liablePartyList);

        update liablePartyList;

    }    


    // Create Applied Accounting Codes (aeac) on the LP.
    public static void createAppliedAccountingCodes(List<Liability_Payment__c> lps) {
        System.debug('200 Entered LiabilityPaymentMethods.createAppliedAccountingCodes');

        //Key_Value_Store__c vtcwKVS = Key_Value_Store__c.getInstance('Violation Type Car Wash');
        
        //Requery LPs to bring in parent Case Issue data:
        List<Liability_Payment__c> liabilityPayments = [SELECT Id, Payment_Applied_To__c, Posted_Amount__c,
                                                            Case_Violation__c, Case_Violation__r.Id, Case_Violation__r.Violation_Type__c,
                                                            Case_Violation__r.Case__r.Employer__r.Low_wage_Industry_Selection__c,
                                                            Case_Violation__r.Case__r.DIR_Accounting_Program__c,
                                                            Case_Payment__r.Transmittal_Unit__c
                                                        FROM Liability_Payment__c
                                                        WHERE Id IN: lps];
        
        Set<Id> caseIssueIds = new Set<Id>();
        Set<Id> violationTypeIds = new Set<Id>();
        List<String> accountIndustry = new List<String>();
        List<String> dlseProgram = new List<String>();
        
        System.debug('218 liabilityPayments = ' + liabilityPayments);
        
        for(Liability_Payment__c lp: liabilityPayments){
            if(lp.Posted_Amount__c != null && 
                    (lp.Case_Payment__r.Transmittal_Unit__c == 'CCU 32' || lp.Case_Payment__r.Transmittal_Unit__c == 'JEU' || lp.Case_Payment__r.Transmittal_Unit__c == 'RCI')){
                caseIssueIds.add(lp.Case_Violation__c);
                violationTypeIds.add(lp.Case_Violation__r.Violation_Type__c);
                accountIndustry.add(lp.Case_Violation__r.Case__r.Employer__r.Low_wage_Industry_Selection__c);
                dlseProgram.add(lp.Case_Violation__r.Case__r.DIR_Accounting_Program__c);
            }
        }
        System.debug('229 caseIssueIds = ' + caseIssueIds);
        System.debug('230 violationTypeIds = ' + violationTypeIds);
        System.debug('231 accountIndustry = ' + accountIndustry);
        System.debug('232 dlseProgram = ' + dlseProgram);
        // Get the Applicable Accounting Codes (acac) associated to the Violation Type of each Case Issue.
        List<Applicable_Accounting_Code__c> acacList = [SELECT Id, Violation_Type__c, Split_Percentage__c, Active__c,
                                                            Accounting_Code__c, Accounting_Code__r.Payment_Type__c, Accounting_Code__r.Fund__c
                                                        FROM Applicable_Accounting_Code__c
                                                        WHERE Active__c = true
                                                            AND Industry__c IN :accountIndustry
                                                            AND Program__c IN :dlseProgram
                                                            AND Violation_Type__c IN :violationTypeIds];
        
        System.debug('242 acacList = ' + acacList);
        
        Set<String> fundCodes = new Set<String>();
        
        for(Applicable_Accounting_Code__c acac : acacList){
            fundCodes.add(acac.Accounting_Code__r.Fund__c);
        }
        System.debug('249 fundCodes = ' + fundCodes);
        
        List<Violation_Accounting_Code__c> vacList = [SELECT Id, Fund_Code__c, Case_Violation__c, Case_Violation__r.Id
                                                        FROM Violation_Accounting_Code__c
                                                        WHERE Fund_Code__c IN :fundCodes
                                                            AND Case_Violation__r.Id IN :caseIssueIds];
        
        System.debug('256 vacList = ' +  vacList);

        //@TestVisible
        Map<String, List<Applicable_Accounting_Code__c>> acacMap = new Map<String, List<Applicable_Accounting_Code__c>>();

        for(Applicable_Accounting_Code__c acac : acacList) {
            System.debug('262 Applicable Accounting Code ID: ' + acac.Id);
            if(!acacMap.containsKey(acac.Accounting_Code__r.Payment_Type__c)) {
                List<Applicable_Accounting_Code__c> newAcacList = new List<Applicable_Accounting_Code__c>();
                newAcacList.add(acac);
                acacMap.put(acac.Accounting_Code__r.Payment_Type__c, newAcacList);

            }else{
                List<Applicable_Accounting_Code__c> existingAcacList = acacMap.get(acac.Accounting_Code__r.Payment_Type__c);
                existingAcacList.add(acac);
                acacMap.put(acac.Accounting_Code__r.Payment_Type__c, existingAcacList);
            }
        }
        
        List<Applied_Accounting_code__c> aeacsToInsert = new List<Applied_Accounting_code__c>();
        String pmtType; //Penalty or Interest
        String lastCP; //Populates aeac.Check_Count__c field. Only 1 aeac under a CP will have a "1" in this field, all other aeacs will have null in this field.
        Decimal firstAeacAmount = 0; //For amounts not divisible by 2
        
        for(Liability_Payment__c lp: LiabilityPayments) {
            if(lp.Payment_Applied_To__c == 'Penalties'){
                pmtType = 'Penalty';
            }
            else {
                pmtType = lp.Payment_Applied_To__c;
            }
            
            System.debug('288 pmtType = '+pmtType);
            System.debug('289 acacMap = '+acacMap);
            
            if(acacMap.containsKey(pmtType)) {
                
                List<Applicable_Accounting_Code__c> acacListByPaymentType = acacMap.get(pmtType);
                if(acacListByPaymentType.size() > 0){
                    for(Applicable_Accounting_Code__c acac: acacListByPaymentType){
                        System.debug('296 acacListByPaymentType = '+acacListByPaymentType);
                        
                        //Only add an Applied Accounting Code to the LP if the Violation Type is a match.
                        if(acac.Violation_Type__c == lp.Case_Violation__r.Violation_Type__c) {
                            Applied_Accounting_Code__c newAeac = new Applied_Accounting_Code__c();
                            newAeac.Liability_Payment__c = lp.Id;
                            newAeac.Accounting_Code__c = acac.Accounting_Code__c;
                            newAeac.Amount__c = lp.Posted_Amount__c * acac.Split_Percentage__c * .01;
                            
                            
                            for(Violation_Accounting_Code__c vac : vacList){
                                if(pmtType == 'Penalty' && vac.Case_Violation__c == lp.Case_Violation__c && vac.Fund_Code__c == acac.Accounting_Code__r.Fund__c){
                                    newAeac.Violation_Accounting_Code__c = vac.Id;
                                    System.debug('309 vac = ' + vac);
                                }
                            }
                            
                            
                            //Fix computation when split percentage is 50% and amount is not divisible by 2 
                            if(acac.Split_Percentage__c == 50){
                                //if (firstAeacAmount == 0 && lp.Case_Violation__r.Violation_Type__c == vtcwKVS.Value__c) {
                                if(firstAeacAmount == 0){
                                    firstAeacAmount = newAeac.Amount__c.setScale(2, RoundingMode.HALF_UP);
                                    newAeac.Amount__c = firstAeacAmount;
                                }else{
                                    //if (firstAeacAmount != 0 && lp.Case_Violation__r.Violation_Type__c == vtcwKVS.Value__c) {
                                    if(firstAeacAmount != 0){
                                        if(lp.Posted_Amount__c < (firstAeacAmount + newAeac.Amount__c)){
                                            newAeac.Amount__c = lp.Posted_Amount__c - firstAeacAmount;
                                        }
                                        firstAeacAmount = 0;
                                    }
                                }
                            }
                            aeacsToInsert.add(newAeac);
                            
                            //Need payment type on the Applied Accounting Code object for reporting penalties and interest in separate columns on the collections report.
                            newAeac.Payment_Type__c = lp.Payment_Applied_To__c;

                            if(lp.Case_Payment__c != lastCP){
                                newAeac.Check_Count__c = 1;
                            }
                            lastCP = lp.Case_Payment__c;
                        }
                    }
                }
            }
        }
        insert aeacsToInsert;
    }
}