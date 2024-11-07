@isTest
public with sharing class CashCreateJPsTest1{
    //Tests CashCreateJPs class Recommend functionality.
    //Also tests CashJudgmentWrapper and CashUpdateMatchedJps classes.
    
    @TestSetup
    static void makeData(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(
            Name = 'CaseRoleAll',
            Is_Active__c = false
        ));
            
        triggerSettings.add(new Trigger_Settings__c(
            Name = 'dlrs_DIR_ViolationTrigger',
            Is_Active__c = false
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'dlrs_JudgementTrigger',
            Is_Active__c = false
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'LiabilityPaymentTrigger',
            Is_Active__c = false
        ));

        triggerSettings.add(new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = false
        ));

        insert triggerSettings;

        List<Account> accounts = new List<Account>();
        Id businessAccountRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        Account employerAccount = new Account(
            RecordTypeId = businessAccountRtId,
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employerAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = businessAccountRtId,
            Name = 'DIR',
            ShippingStreet = '456 Almighty Capitalism Dr',
            ShippingCity = 'Scrotamento',
            ShippingState = 'CA',
            ShippingPostalCode = '98765'
        );
        accounts.add(statePayeeAccount);

        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Superior Inferior Court Jester',
            ShippingStreet = '666 Hubba Hubba Dr',
            ShippingCity = 'National City',
            ShippingState = 'CA',
            ShippingPostalCode = '91545'
        );
        accounts.add(courtPayeeAccount);
        insert accounts;
                        
        Address__c employerAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employerAccount.Id];
        Address__c employeePayeeAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employeePayeeAccount.Id];
        Address__c statePayeeAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :statePayeeAccount.Id];
        Address__c courtPayeeAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :courtPayeeAccount.Id];
                    

        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );            
        insert manager;
            
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
        
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        
        List<Office__c> offices = new List<Office__c>();
        Office__c courtOffice = new Office__c(
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('Courthouse').getRecordTypeId(),
            Name = 'The Superior Inferior Court Jester',
            Address_1__c = '666 Hubba Hubba Dr',
            City__c = 'National City',
            State__c = 'CA',
            Zip_Code__c = '91545',
            County__c = 'Coleslaus',
            Office_Location__c = 'Oakland'
        );
        offices.add(courtOffice);

        Office__c wcaOffice = new Office__c(
            Name = 'Bakersfield WCA',
            Office_Number__c = 'WCA 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        offices.add(wcaOffice);
        insert offices;
        
        DIR_Case__c wcaCase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employerAccount.Id,
            Office__c = wcaOffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
            );
        insert wcaCase;
            
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Id wcaCaseRoleRtId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        Case_Role__c wcaDefendantCaseRole = new Case_Role__c(
            RecordTypeId = wcaCaseRoleRtId,
            Case__c = wcaCase.Id,
            Entity__c = employerAccount.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(wcaDefendantCaseRole);
                        
        /* Case_Role__c wcaEmployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = wcaCaseRoleRtId,
            Entity__c = employeePayeeAccount.Id,
            Case__c = wcaCase.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(wcaEmployeePayeeCaseRole); */

        Case_Role__c wcaStatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = wcaCaseRoleRtId,
            Entity__c = statePayeeAccount.Id,
            Case__c = wcaCase.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(wcaStatePayeeCaseRole);

        Case_Role__c wcaCourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = wcaCaseRoleRtId,
            Entity__c = courtPayeeAccount.Id,
            Case__c = wcaCase.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(wcaCourtPayeeCaseRole);

        /* Case_Role__c wcaPayorPayeeCaseRole = new Case_Role__c(
            RecordTypeId = wcaCaseRoleRtId,
            Entity__c = payorPayeeAccount.Id,
            Case__c = wcaCase.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = payorPayeeAccountLocation.Id
        );
        caseRoles.add(wcaPayorPayeeCaseRole); */
        insert caseRoles;
        
        /*
        List<Payee__c> payees = new List<Payee__c>();
        /*Payee__c bofeEmployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = bofeEmployeePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(bofeEmployeePayee);
        */
        /*
        Payee__c statePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = statePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(statePayee);

        Payee__c courtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = bofeCase.Id,
            Case_Role__c = courtPayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(courtPayee);
        insert payees;
        */        
        
        List<Violation_Type__c> violationTypes = new List<Violation_Type__c>();
        /* Violation_Type__c bofeViolationType = new Violation_Type__c(
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            //Even though the method is "getRecordTypeInfosByName()", it actually gets the info by the Label.
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Active__c = true
        );
        violationTypes.add(bofeViolationType); */
        
        Violation_Type__c wcaViolationType = new Violation_Type__c(
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            //Even though the method is "getRecordTypeInfosByName()", it actually gets the info by the Label.
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - Active').getRecordTypeId(),
            Active__c = true
        );
        violationTypes.add(wcaViolationType);
        insert violationTypes;

        Assessments__c bofeAssessment = new Assessments__c(
            Case_Management__c = wcaCase.Id,
            Appeal_Deadline_Days__c = 14,
            Appeal_Deadline_Selector__c = 'Business Days',
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert bofeAssessment;



        List<DIR_Violation__c> caseIssues = new List<DIR_Violation__c>();
        // Id bofeCaseIssueRecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        Id wcaCaseIssueRecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId();
        /* DIR_Violation__c bofeCaseIssue = new DIR_Violation__c(
            Violation_Type__c = bofeViolationType.Id,
            Case__c = bofeCase.Id,
            Assessment__c = bofeAssessment.Id,
            Citation_Amount__c = 6666,
            Wages_Due__c = 4999.50,
            Total_Interest_Amount__c = 1666.50,
            Status__c = 'Open',
            RecordTypeId = bofeCaseIssueRecordTypeId
        );
        caseIssues.add(bofeCaseIssue); */        

        DIR_Violation__c wcaCaseIssue = new DIR_Violation__c(
            Violation_Type__c = wcaViolationType.Id,
            Case__c = wcaCase.Id,
            Assessment__c = bofeAssessment.Id,
            Citation_Amount__c = 7777,
            Wages_Due__c = 1999.50,
            Total_Interest_Amount__c = 5777.50,
            Status__c = 'Open',
            RecordTypeId = wcaCaseIssueRecordTypeId
        );
        caseIssues.add(wcaCaseIssue);
        insert caseIssues;
        
        Judgement__c judgment = new Judgement__c(
            Case_Management__c = wcaCase.Id,
            Type__c = 'ODA',
            Status__c = 'Pending/Open',
            Interest_Due__c = 666.66,
            Post_Judgement_Interest__c = 666.66,
            Attorney_Fees__c = 666.66,
            Filing_Fee__c = 666.66,
            Court__c = courtOffice.Id,
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert judgment;

        Liability__c wcaLiability = new Liability__c(
            Case_Management__c = wcaCase.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = bofeAssessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );            
        insert wcaLiability;

        Liable_Party__c wcaLiableParty = new Liable_Party__c(
            Liability__c = wcaLiability.Id,
            Entity__c = employerAccount.Id,
            Liable_Party_Account_Name__c = employerAccount.Name,
            Case_Role__c = wcaDefendantCaseRole.Id
        );
        insert wcaLiableParty;
        
        Liable_Party_Case_Issue__c wcaLPCI = new Liable_Party_Case_Issue__c(
            Liable_Party__c = wcaLiableParty.Id,
            Case_Issue__c = wcaCaseIssue.Id
        );
        insert wcaLPCI;
        
        
        Liability_Judgement__c wcaJudgmentParty = new Liability_Judgement__c(
            Judgement__c = judgment.Id,
            Liable_Party__c = wcaLiableParty.Id
        );
        insert wcaJudgmentParty;
        

        Office_Account__c wcaOfficeAccount = new Office_Account__c(
            Name = '01-112',
            Office__c = wcaOffice.Id
        );
        insert wcaOfficeAccount;
        
        Transaction__c bofeTRN = new Transaction__c(
            Office_Account__c = wcaOfficeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-7),
            Business_Unit__c = 'WCA',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 55.55,
            Check_Count__c = 1,
            Checks_Amount__c = 55.55,
            Treasury_Deposit_Number__c = '😜😲😅'
        );
        insert bofeTRN;
    
        Receipt__c bofeRCT = new Receipt__c(
            Payor__c = employerAccount.Id,
            Created_Via_PartyToPartyLWC__c = false,
            Deposit_Account__c = '01-112',
            Date_Received__c = Date.today().addDays(-14),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 55.55,
            Transaction__c = bofeTRN.Id,
            Instrument_Number__c = '🍺🍻🍸🍹🍷',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'WCA 1',
            Senior_Deputy__c = manager.Id
        );
        insert bofeRCT;

        Case_Payment__c bofeCP = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = wcaCase.Id,
            Receipt__c = bofeRCT.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'New'
        );
        insert bofeCP;
        
        /*
        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
                
        Liability_Payment__c bofeWageLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Payment_Amount__c = 33.33,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofeWageLP);
            
        Liability_Payment__c bofeInterestLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Payment_Amount__c = 33.33,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofeInterestLP);
        */
        /*            
        Liability_Payment__c bofePentaltyLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Payment_Amount__c = 33.33,
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = bofeCaseIssue.Id,
            Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
        );
        lpList.add(bofePentaltyLP);
        */
        /*
        Liability_Payment__c wcaInterestLP = new Liability_Payment__c(
            Case_Payment__c = bofeCP.Id,
            Payment_on_Behalf_of__c = bofeLiableParty.Id,
            Payment_Amount__c = 33.33,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = bofeAssessment.Id,
            Liability__c = bofeLiability.Id,
            Case_Violation__c = wcaCaseIssue.Id,
            Case_Issue_RecordTypeId__c = wcaCaseIssueRecordTypeId
        );
        lpList.add(wcaInterestLP);
        */
        /*
        insert lpList;
        */
        
        List<Judgment_Payment__c> jpList = new List<Judgment_Payment__c>();
        Judgment_Payment__c pjiJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = wcaLiableParty.Id,
            Posted_Amount__c = 22.22,
            Payment_Applied_To__c = 'Post-Judgment Interest'
        );
        jpList.add(pjiJP);
     
        Judgment_Payment__c phiJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = wcaLiableParty.Id,
            Posted_Amount__c = 22.22,
            Payment_Applied_To__c = 'Post-Hearing Interest'
        );
        jpList.add(phiJP);       
        
        Judgment_Payment__c afJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = wcaLiableParty.Id,
            Posted_Amount__c = 22.22,
            Payment_Applied_To__c = 'Attorney Fees'
        );
        jpList.add(afJP);
       
        
        Judgment_Payment__c ffJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCP.Id,
            Payment_On_Behalf_Of__c = wcaLiableParty.Id,
            Posted_Amount__c = 22.22,
            Payment_Applied_To__c = 'Filing Fees'
        );
        jpList.add(ffJP);
        insert jpList;
    }
        
        
    @isTest
    static void testCashCreateJPs(){
        List<Judgement__c> judgmentList = [SELECT Id, Name, Type__c, Court_Case_Number__c, Court__r.Name, Status__c, Post_hearing_Interest_Balance_Due__c,
                                    Post_judgment_Interest_Balance_Due__c, Attorney_Fees_Balance_Due__c, Filing_Fees_Balance_Due__c FROM Judgement__c];
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Judgment__c, Payment_Applied_To__c, Posted_Amount__c FROM Judgment_Payment__c];
        List<Liability_Judgement__c> judgmentPartyList = [SELECT Id, Name, Judgement__c, Liable_Party__r.Case_Role__r.Account_Name__c FROM Liability_Judgement__c];
        Liable_Party__c liableParty = [SELECT Id, Name FROM Liable_Party__c][0];
        Case_Payment__c cp = [SELECT Id, Name FROM Case_Payment__c][0];
        
        Test.startTest();

        ////////
        List<CashJudgmentWrapper> jwList = CashJudgmentWrapper.createJudgmentWrapperList(judgmentList, jpList, judgmentPartyList, liableParty.Id);
        System.assertEquals(1, jwList.size());
        ////////

        ////////
        for(CashJudgmentWrapper jw : jwList){
            jw.postHearingInterestAllocation = 33.33;
            jw.postJudgmentInterestAllocation = 44.44;
            jw.attorneyFeesAllocation = 55.55;
            jw.filingFeesAllocation = 66.66;
        }

        CashUpdateMatchedJPs.updateMatchedJPs(jwList, judgmentPartyList, 'Recommend');
        Decimal newFilingFeesJpRecommendedAmount;
        for(CashJudgmentWrapper jw : jwList){
            newFilingFeesJpRecommendedAmount = jw.matchingFilingFeeJP.Recommended_Amount__c;
        }
        System.assertEquals(66.66, newFilingFeesJpRecommendedAmount);
        /////////

        ////////
        for(CashJudgmentWrapper jw : jwList){
            jw.postHearingInterestAllocation = 77.77;
            jw.postJudgmentInterestAllocation = 88.88;
            jw.attorneyFeesAllocation = 99.99;
            jw.filingFeesAllocation = 111.11;
        }

        CashUpdateMatchedJPs.updateMatchedJPs(jwList, judgmentPartyList, 'Posted');
        String newAttorneyFeeJpStatus;
        for(CashJudgmentWrapper jw : jwList){
            newAttorneyFeeJpStatus = jw.matchingAttorneyFeeJP.Status__c;
        }
        System.assertEquals('Posted', newAttorneyFeeJpStatus);
        ////////

        ////////
        for(CashJudgmentWrapper jw : jwList){
            jw.matchingAttorneyFeeJP = null;
            jw.matchingPostJudgmentInterestJP = null;
            jw.matchingPostHearingInterestJP = null;
            jw.matchingFilingFeeJP = null;
        }
 
        List<Judgment_Payment__c> createdJPs = CashCreateJPs.createJPs(jwList, cp, 'Recommend');
        System.assertEquals(4, createdJPs.size());
        ////////
 
        Test.stopTest();
    }
}