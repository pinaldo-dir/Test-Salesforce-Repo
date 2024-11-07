@isTest
public with sharing class CashCreateCU1sTest{
    //Tests CashCreateCU1s class Recommend functionality.
    //Also tests CashCU1Wrapper and CashUpdateMatchedCu1s classes.

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
        
        triggerSettings.add(new Trigger_Settings__c(
            Name = 'DIR_EmployeeTrigger',
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
        
        /*
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
            RecordTypeId = businessAccountId,
            Name = 'DIR',
            ShippingStreet = '456 Almighty Capitalism Dr',
            ShippingCity = 'Scrotamento',
            ShippingState = 'CA',
            ShippingPostalCode = '98765'
        );
        accounts.add(statePayeeAccount);
                    
        Account courtPayeeAccount = new Account(
            RecordTypeId = businessAccountId,
            Name = 'The Superior Inferior Court Jester',
            ShippingStreet = '666 Hubba Hubba Dr',
            ShippingCity = 'National City',
            ShippingState = 'CA',
            ShippingPostalCode = '91545'
        );
        accounts.add(courtPayeeAccount);
        */
        insert accounts;
                        
        Address__c employerAccountLocation = [SELECT Id, Name FROM Address__c WHERE Entity__c = :employerAccount.Id];

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
        Office__c bofeOffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        offices.add(bofeOffice);
        
        Office__c ccuOffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        offices.add(ccuOffice);
        
        insert offices;

        DIR_Case__c bofeCase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employerAccount.Id,
            Office__c = bofeOffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert bofeCase;
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Id bofeCaseRoleRecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        Case_Role__c bofeDefendantCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = employerAccount.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(bofeDefendantCaseRole);

        /*        
        Case_Role__c bofeEmployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(bofeEmployeePayeeCaseRole);
                
        Case_Role__c statePayeeCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(statePayeeCaseRole);

        Case_Role__c courtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = bofeCaseRoleRecordTypeId,
            Case__c = bofeCase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(courtPayeeCaseRole);
        */
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
        Violation_Type__c bofeViolationType = new Violation_Type__c(
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            //Even though the method is "getRecordTypeInfosByName()", it actually gets the info by the Label.
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Active__c = true
        );
        violationTypes.add(bofeViolationType);

        /*
        Violation_Type__c wcaViolationType = new Violation_Type__c(
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            //Even though the method is "getRecordTypeInfosByName()", it actually gets the info by the Label.
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - Active').getRecordTypeId(),
            Active__c = true
        );
        violationTypes.add(wcaViolationType);
        */
        
        insert violationTypes;
                
        Assessments__c bofeAssessment = new Assessments__c(
            Case_Management__c = bofeCase.Id,
            Appeal_Deadline_Days__c = 14,
            Appeal_Deadline_Selector__c = 'Business Days',
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert bofeAssessment;

        List<DIR_Violation__c> caseIssues = new List<DIR_Violation__c>();
        Id bofeCaseIssueRecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        //Id wcaCaseIssueRecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId();
        DIR_Violation__c bofeCaseIssue = new DIR_Violation__c(
            Violation_Type__c = bofeViolationType.Id,
            Case__c = bofeCase.Id,
            Assessment__c = bofeAssessment.Id,
            Citation_Amount__c = 6666,
            Wages_Due__c = 4999.50,
            Total_Interest_Amount__c = 1666.50,
            Status__c = 'Open',
            RecordTypeId = bofeCaseIssueRecordTypeId
        );
        caseIssues.add(bofeCaseIssue);

        /*
        DIR_Violation__c wcaCaseIssue = new DIR_Violation__c(
            Violation_Type__c = wcaViolationType.Id,
            Case__c = bofeCase.Id,
            Assessment__c = bofeAssessment.Id,
            Citation_Amount__c = 7777,
            Wages_Due__c = 1999.50,
            Total_Interest_Amount__c = 5777.50,
            Status__c = 'Open',
            RecordTypeId = wcaCaseIssueRecordTypeId
        );
        caseIssues.add(wcaCaseIssue);
        */
        insert caseIssues;

        /*
        Judgement__c wcaJudgment = new Judgement__c(
            Case_Management__c = wcaCase.Id,
            Type__c = 'ODA',
            Status__c = 'New',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert wcaJudgment;
        */
        Liability__c bofeLiability = new Liability__c(
            Case_Management__c = bofeCase.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = bofeAssessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );            
        insert bofeLiability;
        /*
        Liability__c wcaLiability = new Liability__c(
            Case_Management__c = wcaCase.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = WCAassessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert wcaLiability;
        */
        Liable_Party__c bofeLiableParty = new Liable_Party__c(
            Liability__c = bofeLiability.Id,
            Entity__c = employerAccount.Id,
            Liable_Party_Account_Name__c = employerAccount.Name,
            Case_Role__c = bofeDefendantCaseRole.Id
        );
        insert bofeLiableParty;
        /*
        Liable_Party__c wcaLiableParty = new Liable_Party__c(
            Liability__c = wcaLiability.Id,
            Entity__c = employerAccount.Id,
            Case_Role__c = wcaDefendantCaseRole.Id
        );
        insert wcaLiableParty;
        */
        Liable_Party_Case_Issue__c bofeLpci = new Liable_Party_Case_Issue__c(
            Liable_Party__c = bofeLiableParty.Id,
            Case_Issue__c = bofeCaseIssue.Id
        );
        insert bofeLpci;

        /*        
        Liability_Judgement__c wcaJudgmentParty = new Liability_Judgement__c(
            Judgement__c = WCAjudgment.Id,
            Liable_Party__c = wcaLiableParty.Id
        );
        insert wcaJudgmentParty;
        */

        Office_Account__c ccuOfficeAccount = new Office_Account__c(
            Name = '32-117',
            Office__c = ccuOffice.Id
        );
        insert ccuOfficeAccount;
        
        Transaction__c bofeTrn = new Transaction__c(
            Office_Account__c = ccuOfficeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-7),
            Business_Unit__c = 'CCU',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 55.55,
            Check_Count__c = 1,
            Checks_Amount__c = 55.55,
            Treasury_Deposit_Number__c = '😜😲😅'
        );
        insert bofeTrn;
    
        Receipt__c bofeRct = new Receipt__c(
            Payor__c = employerAccount.Id,
            Created_Via_PartyPaymentVFP__c = false,
            Deposit_Account__c = '32-117',
            Date_Received__c = Date.today().addDays(-14),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 55.55,
            Transaction__c = bofeTrn.Id,
            Instrument_Number__c = '🍺🍻🍸🍹🍷',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Senior_Deputy__c = manager.Id
        );
        insert bofeRct;

        Case_Payment__c bofeCp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = bofeCase.Id,
            Receipt__c = bofeRct.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'New'
        );
        insert bofeCp;


        List<Liability_Payment__c> cu1List = new List<Liability_Payment__c>();
        cu1List.add(
            new Liability_Payment__c(
                Case_Payment__c = bofeCp.Id,
                Payment_on_Behalf_of__c = bofeLiableParty.Id,
                Recommended_Amount__c = 33.33,
                Payment_Applied_To__c = 'Refund Amount',
                Assessment__c = bofeAssessment.Id,
                Liability__c = bofeLiability.Id,
                Case_Violation__c = bofeCaseIssue.Id,
                Status__c = 'Posted',
                Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
            )
        );
        cu1List.add(
            new Liability_Payment__c(
                Case_Payment__c = bofeCp.Id,
                Payment_on_Behalf_of__c = bofeLiableParty.Id,
                Recommended_Amount__c = 33.33,
                Payment_Applied_To__c = 'Amounts Due to DIR',
                Assessment__c = bofeAssessment.Id,
                Liability__c = bofeLiability.Id,
                Case_Violation__c = bofeCaseIssue.Id,
                Status__c = 'Posted',
                Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
            )
        );
        cu1List.add(
            new Liability_Payment__c(
                Case_Payment__c = bofeCp.Id,
                Payment_on_Behalf_of__c = bofeLiableParty.Id,
                Recommended_Amount__c = 33.33,
                Payment_Applied_To__c = 'Other Amount',
                Assessment__c = bofeAssessment.Id,
                Liability__c = bofeLiability.Id,
                Case_Violation__c = bofeCaseIssue.Id,
                Status__c = 'Posted',
                Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
            )
        );
        /* lpList.add(
            new Liability_Payment__c(
                Case_Payment__c = bofeCp.Id,
                Payment_on_Behalf_of__c = bofeLiableParty.Id,
                Recommended_Amount__c = 33.33,
                Payment_Applied_To__c = 'Penalties',
                Assessment__c = bofeAssessment.Id,
                Liability__c = bofeLiability.Id,
                Case_Violation__c = bofeCaseIssue.Id,
                Status__c = 'Posted',
                Case_Issue_RecordTypeId__c = bofeCaseIssueRecordTypeId
            )
        ); */
        insert cu1List;
        
        /*
        List<Judgment_Payment__c> jpList = new List<Judgment_Payment__c>();
        
        Judgment_Payment__c phiJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCp.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Allocated_Amount__c = 22.22,
            Apply_Payment_To__c = 'Post-Hearing Interest'
        );
        jpList.add(phiJP);
        
        Judgment_Payment__c afJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCp.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Allocated_Amount__c = 22.22,
            Apply_Payment_To__c = 'Attorney Fees'
        );
        jpList.add(afJP);
        
        Judgment_Payment__c ffJP = new Judgment_Payment__c(
            Judgment__c = judgment.Id,
            Case_Payment__c = bofeCp.Id,
            Payment_On_Behalf_Of__c = bofeLiableParty.Id,
            Allocated_Amount__c = 22.22,
            Apply_Payment_To__c = 'Filing Fees'
        );
        jpList.add(ffJP);
        
        insert jpList;
        */
    }


    @isTest
    static void testCashCreateCU1s(){
        /* List<DIR_Violation__c> ciList = 
            [SELECT Id, Name, Status__c,
                    Assessment__c, Assessment__r.Citation_Number__c, Assessment__r.JEU_Case_Number__c, 
                    RecordTypeId, Wage_Assessment_Description__c, Violation_Type__r.Name,
                    Wages_Due__c, Non_Interest_Wage_Balance_Due__c, Total_Wage_Interest_Amount__c, Wage_Interest_Balance_Due__c,
                    Citation_Amount__c, Penalty_Balance_Due__c, Total_Interest_Amount__c, Interest_Balance_Due__c
                FROM DIR_Violation__c]; */
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Payment_Applied_To__c, Recommended_Amount__c, Posted_Amount__c, Payment_On_Behalf_Of__c, 
                                                    Case_Violation__c, Case_Violation__r.Assessment__r.Citation_Number__c, Case_Violation__r.Assessment__r.JEU_Case_Number__c,
                                                    Refund_Amount_Details__c, Amounts_Due_to_DIR_Explanation__c, Other_Amount_Details__c
                                                FROM Liability_Payment__c];
        List<Liable_Party__c> liablePartyList = [SELECT Id, Name, Case_Role__r.Id, Liability__r.Assessment__c FROM Liable_Party__c];
        Case_Payment__c cp = [SELECT Id, Name FROM Case_Payment__c][0];
        /* Liability__c liability = [SELECT Id, Name FROM Liability__c][0]; */

        System.debug('507 lpList: ' + lpList);

        Test.startTest();
        
        ////////
        List<CashCu1Wrapper> cu1WrapperList = CashCu1Wrapper.createCu1WrapperList(lpList, liablePartyList, liablePartyList[0].Case_Role__c);
        System.assertEquals(6, cu1WrapperList.size());
        ////////

        ////////
        for(CashCu1Wrapper cu1w : cu1WrapperList){
            if(cu1w.typeIsRefund){
                cu1w.refundAmount = 66.66;
            }
            if(cu1w.typeIsAmtDueToDIR){
                cu1w.amtDueToDir = 77.77;
            }
            if(cu1w.typeIsOther){
                cu1w.otherAmount = 88.88;
            }
        }

        CashUpdateMatchedCU1s.updateMatchedCU1s(cu1WrapperList, 'Recommend');
        Decimal newOtherLpRecommendedAmount;
        for(CashCu1Wrapper cu1w : cu1WrapperList){
            if(cu1w.typeIsOther){
                newOtherLpRecommendedAmount = cu1w.matchingLp.Recommended_Amount__c;
            }
        }
        System.assertEquals(88.88, newOtherLpRecommendedAmount);
        /////////

        ////////
        for(CashCu1Wrapper cu1w : cu1WrapperList){
            if(cu1w.typeIsRefund){
                cu1w.refundAmount = 99.99;
            }
            if(cu1w.typeIsAmtDueToDIR){
                cu1w.amtDueToDir = 111.11;
            }
            if(cu1w.typeIsOther){
                cu1w.otherAmount = 222.22;
            }
        }

        CashUpdateMatchedCU1s.updateMatchedCU1s(cu1WrapperList, 'Posted');
        String newRefundLpStatus;
        for(CashCu1Wrapper cu1w : cu1WrapperList){
            if(cu1w.typeIsRefund){
                newRefundLpStatus = cu1w.matchingLp.Status__c;
            }
        }
        System.assertEquals('Posted', newRefundLpStatus);
        ////////

        ////////
        for(CashCu1Wrapper cu1w : cu1WrapperList){
            cu1w.matchingLp = null;
        }

        List<Liability_Payment__c> createdCU1s = CashCreateCU1s.createCU1s(cu1WrapperList, cp, 'Recommend');
        System.assertEquals(3, createdCU1s.size());
        ////////

        Test.stopTest();
    }
}