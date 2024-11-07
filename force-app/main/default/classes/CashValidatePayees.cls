public with sharing class CashValidatePayees{
    public static List<Payee__c> validatePayees(List<CashCu1Wrapper> cu1WrapperList,
                                            List<CashCaseIssueWrapper> caseIssueWrapperList,
                                            List<CashJudgmentWrapper> judgmentWrapperList,
                                            Case_Payment__c casePayment){
        
        /* Employee Payees: LP.Wages ('Non-Interest EE(s) Amounts Assessed'), LP.Wage Interest, LP.Interest (on WCA Cases), JP.Post-Hearing Interest, JP.Post-Judgment Interest
            Created through uploading a Form 40, creating them here is out of scope. Validate their existence and factor sum. Bubble up any errors to the UI. */
        List<Payee__c> employeePayees = new List<Payee__c>();
        Decimal employeePayeesFactorSum = 0.00000;

        /* State Payee 'DIR Accounting': JP.Attorney Fees, CU1.Amounts Due to DIR, NSF Fee (via 'Other' allocation).
            If non-existent, use most recently modified Account named 'DIR Accounting' to create Case Role and Payee. */
        List<Payee__c> dirAccountingPayees = new List<Payee__c>();
        Decimal dirAccountingPayeesFactorSum = 0.00000;

        /* State Payee 'DLSE - Centralized Cashiering Unit': LP.Penalties (on BOFE cases only), LP.Interest (on BOFE Cases, aka "Penalty Interest").
            If non-existent, use most recently modified Account named 'DLSE - Centralized Cashiering Unit' to create Case Role and Payee. */
        List<Payee__c> bofePenaltyPayees = new List<Payee__c>();
        Decimal bofePenaltyPayeesFactorSum = 0.00000;

        /* Court Payee: JP.Filing Fees, Other Court Fees?
            If non-existent, verify if Court Account record exists that matches the Judgment's Court Office__c record (Office__c.Court_Account__c). If not,
            create that Court Account record off of the data in that Court Office record, then Case Role and Payee. */
        List<Payee__c> courtPayees = new List<Payee__c>();
        Decimal courtPayeesFactorSum = 0.00000;

        /* Payor Payee: CU1.Refund
            If non-existent, create Case Role and Payee off of the RCT.Payor's Account record. */
        List<Payee__c> payorPayees = new List<Payee__c>();
        Decimal payorPayeesFactorSum = 0.00000;

        /* UWF warrants are cut from 'recycled' PRs, so testing for/creating a UWF Payee is done in disbursing automation. */

        /* Buyback warrants are cut from 'returned' PRs, so testing for a Bank Payee is done in returning automation, ReturnedVoidedReceipt.cls, which calls
            createBankPayee() below if needed. */

        List<Payee__c> allPayeeList = [SELECT Id, Name, Status__c, Factor__c, Role__c, Payee_Type__c, Payee_Name__c, NetWages__c, Sum_Of_All_Payment_Records__c,
                                            Case_Management__c, Case_Management__r.Id,
                                            Case_Role__c, Case_Role__r.Entity__c, Case_Role__r.Account_Name__c
                                        FROM Payee__c
                                        WHERE Case_Management__r.Id = :casePayment.Case__c
                                        WITH SECURITY_ENFORCED
                                        ORDER BY NetWages__c DESC];

        for(Payee__c payee : allPayeeList){
            if(payee.Payee_Type__c == 'Employee' || payee.Payee_Type__c == 'Employee - Net Wages'){
                employeePayees.add(payee);
                employeePayeesFactorSum += payee.Factor__c;
            }else if(payee.Payee_Type__c == 'State' && payee.Payee_Name__c == 'DIR Accounting'){
                dirAccountingPayees.add(payee);
                dirAccountingPayeesFactorSum += payee.Factor__c;
            }else if(payee.Payee_Type__c == 'State' && payee.Payee_Name__c == 'DLSE - Centralized Cashiering Unit'){
                bofePenaltyPayees.add(payee);
                bofePenaltyPayeesFactorSum += payee.Factor__c;
            }else if(payee.Payee_Type__c == 'Court'){
                courtPayees.add(payee);
                courtPayeesFactorSum += payee.Factor__c;
            }else if(payee.Payee_Type__c == 'Payor'){
                payorPayees.add(payee);
                // payorPayeesFactorSum += payee.Factor__c; //It's possible to have multiple Payor Payees on one Case. Each should have a Factor of 100, so their Factors' sums don't matter.
            }
        }


        for(CashCaseIssueWrapper ciw : caseIssueWrapperList){
            if(ciw.wageAllocation > 0){
                if(employeePayees.isEmpty()){
                    throw new CashCustomException('There must be Employee or Claimant Case Role and Payee records on the Case to post to Wages.');
                }else if(employeePayeesFactorSum != 100.00000){
                    throw new CashCustomException('Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors.');
                }
            }
            if(ciw.wageInterestAllocation > 0){
                if(employeePayees.isEmpty()){
                    throw new CashCustomException('There must be Employee or Claimant Case Role and Payee records on the Case to post to Wage Interest.');
                }else if(employeePayeesFactorSum != 100.00000){
                    throw new CashCustomException('Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors.');
                }
            }
            if(ciw.interestAllocation > 0){
                if(ciw.caseIssueRecordTypeId == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()){
                    if(employeePayees.isEmpty()){
                        throw new CashCustomException('There must be Employee or Claimant Case Role and Payee records on the Case to post to WCA Interest.');
                    }else if(employeePayeesFactorSum != 100.00000){
                        throw new CashCustomException('Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors.');
                    }
                }else if(ciw.caseIssueRecordTypeId == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()){
                    if(bofePenaltyPayees.isEmpty()){
                        try{
                            Payee__c newBofePenaltyPayee = createBofePenaltyPayee(casePayment);
                            allPayeeList.add(newBofePenaltyPayee);
                            bofePenaltyPayeesFactorSum = newBofePenaltyPayee.Factor__c;
                            bofePenaltyPayees.add(newBofePenaltyPayee);
                        }catch(Exception e){
                            throw new CashCustomException('Unable to create \'DLSE - Centralized Cashiering Unit\' Payee needed to post to BOFE Interest.⚪' + e.getMessage() + '⚪' + e.getStackTraceString());
                        }
                    }else if(bofePenaltyPayeesFactorSum != 100.00000){
                        throw new CashCustomException('The \'DLSE - Centralized Cashiering Unit\' Payee\'s factor equals ' + bofePenaltyPayeesFactorSum + ', not 100.00000. Please adjust factors.');
                    }
                }
            }
            if(ciw.penaltyAllocation > 0 && casePayment.Receipt__r.Deposit_Account__c == '32-117'){ //Penalty funds deposited to 32-117 need a 'DLSE - Centralized Cashiering Unit' Payee. 
                                                                                                    // Penalty funds deposited to other Office Accounts do not need Payees since no Payment Records are needed.
                if(bofePenaltyPayees.isEmpty()){
                    try{
                        Payee__c newBofePenaltyPayee = createBofePenaltyPayee(casePayment);
                        allPayeeList.add(newBofePenaltyPayee);
                        bofePenaltyPayeesFactorSum = newBofePenaltyPayee.Factor__c;
                        bofePenaltyPayees.add(newBofePenaltyPayee);
                    }catch(Exception e){
                        throw new CashCustomException('Unable to create \'DLSE - Centralized Cashiering Unit\' Payee needed to post to BOFE Penalties.⚪' + e.getMessage() + '⚪' + e.getStackTraceString());
                    }
                }else if(bofePenaltyPayeesFactorSum != 100.00000){
                    throw new CashCustomException('The \'DLSE - Centralized Cashiering Unit\' Payee\'s factor equals ' + bofePenaltyPayeesFactorSum + ', not 100.00000. Please adjust factors.');
                }
            }
        }
        
        for(CashJudgmentWrapper jw : judgmentWrapperList){
            if(jw.postHearingInterestAllocation > 0){
                if(employeePayees.isEmpty()){
                    throw new CashCustomException('There must be Employee or Claimant Case Role and Payee records on the Case to post to Post-Hearing Interest.');
                }else if(employeePayeesFactorSum != 100.00000){
                    throw new CashCustomException('Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors.');
                }
            }
            if(jw.postJudgmentInterestAllocation > 0){
                if(employeePayees.isEmpty()){
                    throw new CashCustomException('There must be Employee or Claimant Case Role and Payee records to post to Post-Judgment Interest.');
                }else if(employeePayeesFactorSum != 100.00000){
                    throw new CashCustomException('Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors.');
                }
            }
            if(jw.attorneyFeesAllocation > 0){
                if(dirAccountingPayees.isEmpty()){
                    try{
                        Payee__c newDirAccountingPayee = createDirAccountingPayee(casePayment);
                        allPayeeList.add(newDirAccountingPayee);
                        dirAccountingPayeesFactorSum = newDirAccountingPayee.Factor__c;
                        dirAccountingPayees.add(newDirAccountingPayee);
                    }catch(Exception e){
                        throw new CashCustomException('Unable to create \'DIR Accounting\' Payee needed to post to Attorney Fees.⚪' + e.getMessage() + '⚪' + e.getStackTraceString());
                    }
                }else if(dirAccountingPayeesFactorSum != 100.00000){
                    throw new CashCustomException('The \'DIR Accounting\' Payee\'s factor equals ' + dirAccountingPayeesFactorSum + ', not 100.00000. Please adjust factors.');
                }
            }
            if(jw.filingFeesAllocation > 0){
                if(casePayment.Deposited__c){
                    if(courtPayees.isEmpty()){ //Direct Payment funds are never deposited, thus never disbursed, thus no Payees needed. TODO: why do we only test for the funds being deposited here and not elsewhere?
                        try{
                            Payee__c newCourtPayee = createCourtPayee(casePayment);
                            allPayeeList.add(newCourtPayee);
                            courtPayeesFactorSum = newCourtPayee.Factor__c;
                            courtPayees.add(newCourtPayee);
                        }catch(Exception e){
                            throw new CashCustomException('Unable to create Court Payee needed to post to Filing Fees.⚪' + e.getMessage() + '⚪' + e.getStackTraceString());
                        }
                    }else if(courtPayeesFactorSum != 100.00000){ //Direct Payments are never deposited nor disbursed, no court Payees needed. Only deposited RCTs will need Payees to generate Warrants.
                        throw new CashCustomException('The Court Payee\'s factor equals ' + courtPayeesFactorSum + ', not 100.00000. Please adjust factors.');
                    }
                }
            }
        }

        for(CashCu1Wrapper cu1w : cu1WrapperList){            
            if(cu1w.typeIsRefund && cu1w.refundAmount > 0){ //There could be more than one Payor Payee on a case, e.g. 2 RCTs paid by different entities, and thus the sum of the Factors 
                                                            // could be > 100.00000, so we can't validate that sum.
                Boolean relevantPayorPayeeFound = false;
                
                for(Payee__c payorPayee : payorPayees){
                    if(payorPayee.Case_Role__r.Entity__c == casePayment.Receipt__r.Payor__c){ //Verify that a Payor Payee exists that is actually the Payor on the RCT.
                        relevantPayorPayeeFound = true;
                        break;
                    }
                }
                
                if(!relevantPayorPayeeFound){
                    try{
                        Payee__c newPayorPayee = createPayorPayee(casePayment);
                        allPayeeList.add(newPayorPayee);
                        payorPayeesFactorSum = newPayorPayee.Factor__c; //this line for consistency, not really needed since we don't check against sum.
                        payorPayees.add(newPayorPayee); //this line for consistency, not really needed since we don't check against a payorPayee list.
                    }catch(Exception e){
                        throw new CashCustomException('Unable to create Payor Payee needed to post to Refund Amount.⚪' + e.getMessage() + '⚪' + e.getStackTraceString());
                    }
                }
            }
            if(cu1w.typeIsAmtDueToDIR && cu1w.amtDueToDir > 0){
                if(dirAccountingPayees.isEmpty()){
                    try{
                        Payee__c newDirAccountingPayee = createDirAccountingPayee(casePayment);
                        allPayeeList.add(newDirAccountingPayee);
                        dirAccountingPayeesFactorSum = newDirAccountingPayee.Factor__c;
                        dirAccountingPayees.add(newDirAccountingPayee);
                    }catch(Exception e){
                        throw new CashCustomException('Unable to create DIR Accounting Payee needed to post to Amounts Due to DIR.⚪' + e.getMessage() + '⚪' + e.getStackTraceString());
                    }
                }else if(dirAccountingPayeesFactorSum != 100.00000){
                    throw new CashCustomException('The \'DIR Accounting\' Payee\'s factor equals ' + dirAccountingPayeesFactorSum + ', not 100.00000. Please adjust factors.');
                }
                
                /* if(courtPayees.isEmpty()){
                    try{
                        Payee__c newCourtPayee = createCourtPayee(casePayment);
                        allPayeeList.add(newCourtPayee);
                        courtPayeesFactorSum = newCourtPayee.Factor__c;
                        courtPayees.add(newCourtPayee);
                    }catch(Exception e){
                        throw new CashCustomException('Unable to create Court Payee needed to post to Amounts Due to DIR.⚪' + e.getMessage() + '⚪' + e.getStackTraceString());
                    }
                }else if(courtPayeesFactorSum != 100.00000){
                    throw new CashCustomException('The Court Payee\'s factor equals ' + courtPayeesFactorSum + ', not 100.00000. Please adjust factors.');
                } */
            }
            if(cu1w.typeIsOther && cu1w.otherAmount > 0){ 
                //"Other Amount" is for fringe cases not entirely automatable. Cashiering Super User permission set allows for creating, editing, and deleting PRs.
                //TODO: after Phase II idea, new field on CP Allocation LWC CU-1 'Other Amount' that looks up to an Account record. Automation generates PR with that Account as the Payee.
            }
            //if(cu1w.typeIsHold && cu1w.holdAmount > 0){} //Hold Amount field deprecated in Phase II.
        }

        return allPayeeList;
    }


    private static Payee__c createPayorPayee(Case_Payment__c casePayment){
        // Unlike the other create***Payee automation, the Payor could already, but not always, have a Defendant (or similar) Case Role on a Case.
        //  If so, that Case Role should be used to create the Payor Payee.
        //  If not, create that Case Role too.
        // Assumes that the Payor's Account DOES exist because it's required on the Receipt and ICL.
        System.debug('233 entered createPayorPayee');
        
        Case_Role__c payorCaseRole;
        //Query for a Case Role parented to the CP.RCT.Payor's Account
        List<Case_Role__c> payorCaseRoleList = [SELECT Id, Name, Case__c, Entity__c, Account_Name__c
                                                    FROM Case_Role__c
                                                    WHERE (Case__c = :casePayment.Case__c
                                                            AND Entity__c = :casePayment.Receipt__r.Payor__c)
                                                        AND (Role__c LIKE '%Employer%'
                                                                OR Role__c LIKE '%Defendant%')
                                                ORDER BY LastModifiedDate DESC];
                                                
        //Turn off certain Triggers to reduce SOQL CPU time overhead. Trigger Settings managed in Setup->Custom Settings->Trigger Settings->Manage.
        List<Trigger_Settings__c> triggerSettings = [SELECT Id, Name, Is_Active__c
                                                            FROM Trigger_Settings__c
                                                            WHERE Is_Active__c = TRUE];
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = false;
        }
        update triggerSettings;

        //If no such Case Role exists, we create one.
        if(payorCaseRoleList.isEmpty()){
            //Query for the CP.RCT.Payor's Account
            Account payorAccount = [SELECT Id, Name,
                                        (SELECT Id, Name
                                            FROM Addresses__r
                                            WHERE Active_Location__c = TRUE
                                                AND (Type__c = 'Primary'
                                                    OR Type__c = 'Home'
                                                    OR Type__c = 'Business Location'
                                                    OR Type__c = 'Mailing Address')
                                            ORDER BY LastModifiedDate DESC
                                            LIMIT 1)
                                    FROM Account
                                    WHERE Id = :casePayment.Receipt__r.Payor__c];
            
            Id payorAccountLocationId = payorAccount.Addresses__r[0].Id;
            
            payorCaseRole = new Case_Role__c(
                RecordTypeId = getCaseRoleRecordTypeId(casePayment),
                Case__c = casePayment.Case__c,
                Entity__c = casePayment.Receipt__r.Payor__c,
                Account_Name__c = casePayment.Receipt__r.Payor__r.Name,
                Role__c = 'Payor',
                Case_Role_Status__c = 'Active',
                Location__c = payorAccountLocationId
            );
            insert payorCaseRole;

            //Requery for this Payor case role Id.
            payorCaseRoleList = [SELECT Id, Name, Case__c, Entity__c, Account_Name__c
                                    FROM Case_Role__c
                                    WHERE Case__c = :casePayment.Case__c
                                        AND Entity__c = :casePayment.Receipt__r.Payor__c
                                    ORDER BY LastModifiedDate DESC];
        }

        payorCaseRole = payorCaseRoleList[0];

        //Now create Payor Payee from either the existing, or new, Payor Case Role.
        Payee__c newPayorPayee = new Payee__c(
            Status__c = 'Verified',
            Payee_Type__c = 'Payor',
            Factor__c = 100.00000,
            NetWages__c = null,  //Specifically set to NULL so subsequent automation won't use this field to calculate PR amounts.
                                 //  TODO: change the name of this field on the Payee, or create new field, to proper capitalized snake case.
            Case_Management__c = casePayment.Case__c, //TODO: replaceable with Case__c?
            Case_Role__c = payorCaseRole.Id
        );  
        insert newPayorPayee;

        //Turn back on the Trigger Settings turned off above
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = true;
        }
        update triggerSettings;

        //Requery to grab Payee_Name__c needed for later processing.
        newPayorPayee = [SELECT Id, Name, Status__c, Factor__c, Role__c, Payee_Type__c, Payee_Name__c, NetWages__c, Sum_Of_All_Payment_Records__c,
                                Case_Management__c, Case_Management__r.Id,
                                Case_Role__c, Case_Role__r.Entity__c, Case_Role__r.Entity__r.Id, Case_Role__r.Entity__r.Name
                            FROM Payee__c
                            WHERE Id = :newPayorPayee.Id
                            LIMIT 1];
        
        return newPayorPayee;
    }


    private static Payee__c createCourtPayee(Case_Payment__c casePayment){
        //Assumes if a Court Payee does not exist on a Case, then neither would the Court Case Role, so we need to create that too.
        System.debug('286 entered createCourtPayee');
        Office__c courtOffice;
        Account courtAccount;

        System.debug('291 cp.Case__c: ' + casePayment.Case__c);
        //Assumes all Judgments on a Case will look up to the same Court Office record.
        Judgement__c judgment = [SELECT Id, Name, Case_Management__c, Court__c, Court__r.Court_Account__c, Court__r.Court_Account__r.Id
                                                FROM Judgement__c
                                                WHERE Case_Management__c = :casePayment.Case__c
                                                /* AND Court__c != NULL */
                                                LIMIT 1];

        //If there is no Court Account record related to the Judgment's Court Office record, create new Court Account record based on data in the Court Office record.
        if(judgment.Court__r.Court_Account__c == NULL){
            courtOffice = [SELECT Id, Name, Address_1__c, Address_2__c, City__c, State__c, Zip_Code__c, Phone__c, County__c, Judicial__c
                            FROM Office__c
                            WHERE Id = :judgment.Court__c];

            courtAccount = new Account(
                RecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
                Name = courtOffice.Name,
                County__c = courtOffice.County__c,
                ShippingStreet = courtOffice.Address_2__c == NULL ? courtOffice.Address_1__c : courtOffice.Address_1__c + '\n' + courtOffice.Address_2__c,
                ShippingCity = courtOffice.City__c,
                ShippingState = courtOffice.State__c,
                ShippingPostalCode = courtOffice.Zip_Code__c,
                Court_District__c = '', //TODO: how is this determined? Picklist: North, South, East, West, Central - Business didn't seem to know off-hand, maybe it'll come up at some point.
                Court_Division__c = courtOffice.Judicial__c,
                Phone = courtOffice.Phone__c,
                Imported_From__c = 'Cashiering Case Payment Allocation automation'
            );
            insert courtAccount; //Inserting an Account record should automatically create a Location (Address__c) record.

            System.debug('327 courtAccount: ' + courtAccount);
            
            /* Address__c newCourtLocation = new Address__c(
                Entity__c = courtAccount.Id,
                Address__c = 'addr created via location: ' + courtOffice.Address_1__c,
                Address_2__c = courtOffice.Address_2__c,
                City__c = courtOffice.City__c,
                State__c = courtOffice.State__c,
                Zip_Code__c = courtOffice.Zip_Code__c,
                Type__c = 'Primary',
                Active_Location__c = TRUE,
                Phone__c = courtOffice.Phone__c
            );
            insert newCourtLocation;
            courtAccountLocationId = newCourtLocation.Id; */

            System.debug('343 courtAccount.Id: ' + courtAccount.Id);
            courtOffice.Court_Account__c = courtAccount.Id;
            update courtOffice;

            //Requery the Judgment to bring in this new Court Account
            judgment = [SELECT Id, Name, Case_Management__c, Court__c, Court__r.Court_Account__c, Court__r.Court_Account__r.Id
                                                FROM Judgement__c
                                                WHERE Case_Management__c = :casePayment.Case__c
                                                /* AND Court__c != NULL */
                                                LIMIT 1];

            System.debug('346 courtOffice: ' + courtOffice);
            System.debug('347 courtOffice.Court_Account__c: ' + courtOffice.Court_Account__c);
            judgment.Court__r.Court_Account__c = courtAccount.Id;
            System.debug('348 judgment.Court__r.Court_Account__r.Id: ' + judgment.Court__r.Court_Account__r.Id);

        }
        
        //Query the already-existing, or requery the newly-created court account record
        courtAccount = [SELECT Id, Name, County__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Court_District__c,
                                Court_Division__c, Phone,
                                    (SELECT Id, Name, Address_1__c, Address_2__c, City__c, State__c, Zip_Code__c, Phone__c, County__c, Judicial__c
                                        FROM Court_Office__r
                                        LIMIT 1),
                                    (SELECT Id, Name, Address__c, Address_2__c, City__c, State__c, Zip_Code__c, Type__c, Active_Location__c, Phone__c
                                        FROM Addresses__r
                                        WHERE Active_Location__c = TRUE
                                            AND Type__c = 'Primary'
                                        ORDER BY LastModifiedDate DESC
                                        LIMIT 1)
                                    FROM Account
                                    WHERE Id = :judgment.Court__r.Court_Account__r.Id
                                    LIMIT 1];

        courtOffice = courtAccount.Court_Office__r[0];
        Id courtAccountLocationId = courtAccount.Addresses__r[0].Id;

        String courtOfficeShippingStreet = 
            courtOffice.Address_2__c == NULL ? courtOffice.Address_1__c : courtOffice.Address_1__c + '\n' + courtOffice.Address_2__c;

        //Verify the court account and court office data match. Update if not, as we're the only one's maintaining these court account records, then requery.
        if(courtAccount.Name != courtOffice.Name
                || courtAccount.ShippingStreet != courtOfficeShippingStreet
                || courtAccount.ShippingCity != courtOffice.City__c
                || courtAccount.ShippingPostalCode != courtOffice.Zip_Code__c
                || courtAccount.Court_Division__c != courtOffice.Judicial__c
                || courtAccount.Phone != courtOffice.Phone__c){
            courtAccount.Name = courtOffice.Name;
            courtAccount.ShippingStreet = courtOfficeShippingStreet;
            courtAccount.ShippingCity = courtOffice.City__c;
            courtAccount.ShippingPostalCode = courtOffice.Zip_Code__c;
            courtAccount.Court_Division__c = courtOffice.Judicial__c;
            courtAccount.Phone = courtOffice.Phone__c;

            update courtAccount;

            //Requery to catch this latest data.
            courtAccount = [SELECT Id, Name, County__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Court_District__c,
                                Court_Division__c, Phone,
                            (SELECT Id, Name, Address_1__c, Address_2__c, City__c, State__c, Zip_Code__c, Phone__c, County__c, Judicial__c
                                FROM Court_Office__r
                                LIMIT 1),
                            (SELECT Id, Name, Address__c, Address_2__c, City__c, State__c, Zip_Code__c, Type__c, Active_Location__c, Phone__c
                                FROM Addresses__r
                                WHERE Active_Location__c = TRUE
                                    AND Type__c = 'Primary'
                                ORDER BY LastModifiedDate DESC
                                LIMIT 1)
                            FROM Account
                            WHERE Id = :judgment.Court__r.Court_Account__r.Id
                            LIMIT 1];
            
            courtOffice = courtAccount.Court_Office__r[0];
            courtAccountLocationId = courtAccount.Addresses__r[0].Id;
        }

        //Now, create new court Case Role and court Payee.
        Case_Role__c newCourtCaseRole = new Case_Role__c(
            Account_Name__c = courtAccount.Name,
            RecordTypeId = getCaseRoleRecordTypeId(casePayment),
            Case__c = casePayment.Case__c,
            Entity__c = courtAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtAccountLocationId
        );

        //Turn off certain Triggers to reduce SOQL CPU time overhead. Trigger Settings managed in Setup->Custom Settings->Trigger Settings->Manage.
        List<Trigger_Settings__c> triggerSettings = [SELECT Id, Name, Is_Active__c
                                                            FROM Trigger_Settings__c
                                                            WHERE Is_Active__c = TRUE];
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = false;
        }
        update triggerSettings;

        insert newCourtCaseRole;

        Payee__c newCourtPayee = new Payee__c(
            Status__c = 'Verified',
            Payee_Type__c = 'Court',
            Factor__c = 100.00000,
            NetWages__c = null, //Specifically set to NULL so subsequent automation won't use this field to calculate PR amounts.
                                //  TODO: change the name of this field on the Payee, or create new field.
            Case_Management__c = casePayment.Case__c,
            Case_Role__c = newCourtCaseRole.Id
        );
        insert newCourtPayee;
        
        //Turn back on the Trigger Settings turned off above
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = true;
        }
        update triggerSettings;

        //Requery to grab Payee_Name__c needed for later processing.
        newCourtPayee = [SELECT Id, Name, Status__c, Factor__c, Role__c, Payee_Type__c, Payee_Name__c, NetWages__c, Sum_Of_All_Payment_Records__c,
                                Case_Management__c, Case_Management__r.Id,
                                Case_Role__c, Case_Role__r.Entity__c, Case_Role__r.Entity__r.Id, Case_Role__r.Entity__r.Name
                            FROM Payee__c
                            WHERE Id = :newCourtPayee.Id
                            LIMIT 1];

        return newCourtPayee;
    }


    private static Payee__c createDirAccountingPayee(Case_Payment__c casePayment){
        //Assumes if a State Payee does not exist on a Case, then neither would the State Case Role, so we need to create that too.
        System.debug('450 entered createDirAccountingPayee');

        //Query for the most recently updated DIR Account
        Account dirAccountingAccount = [SELECT Id, Name,
                                                (SELECT Id, Name
                                                    FROM Addresses__r
                                                    WHERE Active_Location__c = TRUE
                                                    ORDER BY LastModifiedDate DESC
                                                    LIMIT 1)                                        
                                            FROM Account
                                            WHERE Name = 'DIR Accounting'
                                            ORDER BY LastModifiedDate DESC
                                            LIMIT 1];

        //Create State Case Role and child Payee.
        /* Address__c stateAccountLocation = [SELECT Id, Name
                                            FROM Address__c
                                            WHERE Active_Location__c = TRUE
                                            ORDER BY LastModifiedDate DESC
                                            LIMIT 1];

        System.debug('460 stateAccountLocation: ' + stateAccountLocation); */
        Id dirAccountingAccountLocationId = dirAccountingAccount.Addresses__r[0].Id;

        Case_Role__c newDirAccountingCaseRole = new Case_Role__c(
            Account_Name__c = dirAccountingAccount.Name,
            RecordTypeId = getCaseRoleRecordTypeId(casePayment),
            Case__c = casePayment.Case__c,
            Entity__c = dirAccountingAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = dirAccountingAccountLocationId
        );

        //Turn off certain Triggers to reduce SOQL CPU time overhead.
        // Trigger Settings managed in Setup->Custom Settings->Trigger Settings->Manage.
        List<Trigger_Settings__c> triggerSettings = [SELECT Id, Name, Is_Active__c
                                                            FROM Trigger_Settings__c
                                                            WHERE Is_Active__c = TRUE];
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = false;
        }
        update triggerSettings;

        insert newDirAccountingCaseRole;

        Payee__c newDirAccountingPayee = new Payee__c(
            Status__c = 'Verified',
            Payee_Type__c = 'State',
            Factor__c = 100.00000,
            NetWages__c = null, //Specifically set to NULL so subsequent automation won't use this field to rounding correct PR amounts.
                                //  TODO: change the name of this field on the Payee, or create new field.
            Case_Management__c = casePayment.Case__c,
            Case_Role__c = newDirAccountingCaseRole.Id
        );        
        insert newDirAccountingPayee;

        //Turn back on the Trigger Settings turned off above
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = true;
        }
        update triggerSettings;

        //Requery to grab Payee_Name__c needed for later processing.
        newDirAccountingPayee = [SELECT Id, Name, Status__c, Factor__c, Role__c, Payee_Type__c, Payee_Name__c, NetWages__c, Sum_Of_All_Payment_Records__c,
                                        Case_Management__c, Case_Management__r.Id,
                                        Case_Role__c, Case_Role__r.Entity__c
                                    FROM Payee__c
                                    WHERE Id = :newDirAccountingPayee.Id
                                    LIMIT 1];
    
        return newDirAccountingPayee;
    }

    private static Payee__c createBofePenaltyPayee(Case_Payment__c casePayment){
        //Assumes if a 'DLSE - Centralized Cashiering Unit' Payee does not exist on a Case, then neither would the same Case Role, so we need to create that too.
        System.debug('571 entered createBofePenaltyPayee');

        //Query for the most recently updated DIR Account
        Account bofePenaltyAccount = [SELECT Id, Name,
                                        (SELECT Id, Name
                                            FROM Addresses__r
                                            WHERE Active_Location__c = TRUE
                                            ORDER BY LastModifiedDate DESC
                                            LIMIT 1)                                        
                                    FROM Account
                                    WHERE Name = 'DLSE - Centralized Cashiering Unit'
                                    ORDER BY LastModifiedDate DESC
                                    LIMIT 1];

        //Create Case Role and child Payee.
        /* Address__c stateAccountLocation = [SELECT Id, Name
                                            FROM Address__c
                                            WHERE Active_Location__c = TRUE
                                            ORDER BY LastModifiedDate DESC
                                            LIMIT 1];

        System.debug('460 stateAccountLocation: ' + stateAccountLocation); */
        Id bofePenaltyAccountLocationId = bofePenaltyAccount.Addresses__r[0].Id;

        Case_Role__c newBofePenaltyCaseRole = new Case_Role__c(
            Account_Name__c = bofePenaltyAccount.Name,
            RecordTypeId = getCaseRoleRecordTypeId(casePayment),
            Case__c = casePayment.Case__c,
            Entity__c = bofePenaltyAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = bofePenaltyAccountLocationId
        );

        //Turn off certain Triggers to reduce SOQL CPU time overhead.
        // Trigger Settings managed in Setup->Custom Settings->Trigger Settings->Manage.
        List<Trigger_Settings__c> triggerSettings = [SELECT Id, Name, Is_Active__c
                                                            FROM Trigger_Settings__c
                                                            WHERE Is_Active__c = TRUE];
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = false;
        }
        update triggerSettings;

        insert newBofePenaltyCaseRole;

        Payee__c newBofePenaltyPayee = new Payee__c(
            Status__c = 'Verified',
            Payee_Type__c = 'State',
            Factor__c = 100.00000,
            NetWages__c = null, //Specifically set to NULL so subsequent automation won't use this field to calculate PR amounts.
                                //  TODO: change the name of this field on the Payee, or create new field, for better representation of its true function.
            Case_Management__c = casePayment.Case__c,
            Case_Role__c = newBofePenaltyCaseRole.Id
        );        
        insert newBofePenaltyPayee;

        //Turn back on the Trigger Settings turned off above
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = true;
        }
        update triggerSettings;

        //Requery to grab Payee_Name__c needed for later processing.
        newBofePenaltyPayee = [SELECT Id, Name, Status__c, Factor__c, Role__c, Payee_Type__c, Payee_Name__c, NetWages__c, Sum_Of_All_Payment_Records__c,
                                    Case_Management__c, Case_Management__r.Id,
                                    Case_Role__c, Case_Role__r.Entity__c
                                FROM Payee__c
                                WHERE Id = :newBofePenaltyPayee.Id
                                LIMIT 1];
    
        return newBofePenaltyPayee;
    }


    //For Buyback Warrants, only called by ReturnedVoidedReceipt.cls. Create Bank Case Role and Bank Payee.
    //Assumes if a Bank Payee does not exist on a Case, then neither would the Bank Case Role, so we need to create that too.
    public static Payee__c createBankPayee(Case_Payment__c casePayment){
        System.debug('509 entered createBankPayee, casePayment: ' + casePayment);

        //Query for the most recently updated DIR Accounting Account and any relevant Case Role.
        Account stateBuybackAccount = [SELECT Id, Name,
                                        (SELECT Id, Name
                                            FROM Addresses__r
                                            WHERE Active_Location__c = TRUE
                                            ORDER BY LastModifiedDate DESC
                                            LIMIT 1)
                                        FROM Account
                                        WHERE Name = 'Department of Industrial Relations'
                                        ORDER BY LastModifiedDate DESC
                                        LIMIT 1];

        Id stateBuybackAccountLocationId = stateBuybackAccount.Addresses__r[0].Id;

        Case_Role__c newStateBuybackCaseRole = new Case_Role__c(
            Account_Name__c = stateBuybackAccount.Name,
            RecordTypeId = getCaseRoleRecordTypeId(casePayment),
            Case__c = casePayment.Case__c,
            Entity__c = stateBuybackAccount.Id,
            Role__c = 'Bank',
            Case_Role_Status__c = 'Active',
            Location__c = stateBuybackAccountLocationId
        );

        //Turn off certain Triggers to reduce SOQL CPU time overhead.
        // Trigger Settings managed in Setup->Custom Settings->Trigger Settings->Manage.
        List<Trigger_Settings__c> triggerSettings = [SELECT Id, Name, Is_Active__c
                                                        FROM Trigger_Settings__c
                                                        WHERE Is_Active__c = TRUE];
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = false;
        }
        update triggerSettings;

        insert newStateBuybackCaseRole;

        Payee__c newStateBuybackPayee = new Payee__c(
            Status__c = 'Verified',
            Payee_Type__c = 'Bank',
            Factor__c = 100.00000,
            NetWages__c = null, //Specifically set to NULL so subsequent automation won't use this field to calculate PR amounts.
                                //  TODO: change the name of this field on the Payee, or create new field.
            Case_Management__c = casePayment.Case__c,
            Case_Role__c = newStateBuybackCaseRole.Id
        );
        insert newStateBuybackPayee;
        
        //Turn back on the Trigger Settings turned off above
        for(Trigger_Settings__c triggerSetting : triggerSettings){
            triggerSetting.Is_Active__c = true;
        }
        update triggerSettings;

        //Requery to grab Payee_Name__c needed for later processing.
        newStateBuybackPayee = [SELECT Id, Name, Status__c, Factor__c, Role__c, Payee_Type__c, Payee_Name__c, NetWages__c, Sum_Of_All_Payment_Records__c,
                                    Case_Management__c, Case_Management__r.Id,
                                    Case_Role__c, Case_Role__r.Entity__c, Case_Role__r.Entity__r.Id, Case_Role__r.Entity__r.Name
                                FROM Payee__c
                                WHERE Id = :newStateBuybackPayee.Id
                                LIMIT 1];

        return newStateBuybackPayee;
    }


    public static Id getCaseRoleRecordTypeId (Case_Payment__c casePayment){
        if(casePayment.Case__r.RecordType.Name.contains('BOFE')){
            return Schema.SobjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        }else if(casePayment.Case__r.RecordType.Name.contains('Garment')){
            return Schema.SobjectType.Case_Role__c.getRecordTypeInfosByName().get('Garment').getRecordTypeId();
        }else if(casePayment.Case__r.RecordType.Name.contains('PAGA')){
            return Schema.SobjectType.Case_Role__c.getRecordTypeInfosByName().get('PAGA').getRecordTypeId();
        }else if(casePayment.Case__r.RecordType.Name.contains('RCI')){
            return Schema.SobjectType.Case_Role__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        }else if(casePayment.Case__r.RecordType.Name.contains('Registration')){
            return Schema.SobjectType.Case_Role__c.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        }else{ //Case RecordTypeName contains 'JEU', 'PASS', or 'WCA'.
            return Schema.SobjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        }
    }
}