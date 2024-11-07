@isTest(SeeAllData=false)
public class RequestUnpaidWageFundControllerTest {
   
    @isTest 
    public static void testRequestUnpaidWageFundControllerTest(){

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
            Is_Active__c = true
        ));

        insert triggerSettings;
        
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        DIR_Employee__c mgr = new DIR_Employee__c(
            Active__c = true,
            User__c = adminUser.Id,
            Position__c = 'Cashiering'
        );
        insert mgr;
        
        DIR_Employee__c emp = new DIR_Employee__c(
            Active__c = true,
            User__c = adminUser.Id,
            Manager__c = mgr.Id
        );
        insert emp;

        Id personRECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();

        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        acc.Bankruptcy_Status_Date__c = Date.today();
        acc.RecordTypeId = personRECORDTYPEID;
        insert acc;

        Account payeeAccount = new Account(
            Name = 'payeeAccount'
        );
        insert payeeAccount;

        Account payorAccount = new Account(
            Name = 'payorAccount'
        );
        insert payorAccount;

        Account uwfAccount = new Account(
            Name = 'DIR Accounting-Unpaid Wage Fund'
        );
        insert uwfAccount;

        Office__c officeWCA = new Office__c(
            Name = 'Sacramento WCA',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert officeWCA;

        Office__c officeWCA2 = new Office__c(
            Name = 'Bakersfield WCA',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert officeWCA2;

        List<String> wcaOfficeList = new List<String>();
        wcaOfficeList.add(officeWCA2.Name);

        Office__c bofeOffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert bofeOffice;

        List<DIR_Case__c> insertCaseList = new List<DIR_Case__c>();
        DIR_Case__c wcaCase1 = new DIR_Case__c(
            Employer__c = acc.Id,
            Assigned_Deputy__c = emp.Id,
            Office__c = officeWCA2.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00,
            Deposited_Funds__c = 986482.58
        );
        //insert wcaCase1;
		insertCaseList.add(wcaCase1);
        
        DIR_Case__c wcaCase2 = new DIR_Case__c(
            Employer__c = acc.Id,
            Assigned_Deputy__c = emp.Id,
            Office__c = officeWCA2.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00,
            Deposited_Funds__c = 864824.80
        );
        //insert wcaCase2;
        insertCaseList.add(wcaCase2);

        DIR_Case__c wcaCase3 = new DIR_Case__c(
            Employer__c = acc.Id,
            Assigned_Deputy__c = emp.Id,
            Office__c = officeWCA2.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00,
            Deposited_Funds__c = 648247.86
        );
        //insert wcaCase3;
        insertCaseList.add(wcaCase3);

        DIR_Case__c bofeCase = new DIR_Case__c(
            Assigned_Deputy__c = emp.Id,
            Employer__c = acc.Id,
            Office__c = bofeOffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00,
            Deposited_Funds__c = 648247.94
        );
        //insert bofeCase;
        insertCaseList.add(bofeCase);
        insert insertCaseList;

        List<String> bofeCaseList = new List<String>();
        bofeCaseList.add(bofeCase.Name);

        List<Case_Role__c> insertCRList = new List<Case_Role__c>();
        Case_Role__c caseRole1 = new Case_Role__c(
            Entity__c = payeeAccount.Id,
            Case__c = wcaCase1.Id,
            IsPersonAccount__c = true,
            Role__c = 'Claimant'
        );
        //insert caseRole1;
        insertCRList.add(caseRole1);

        Case_Role__c uwfCR1 = new Case_Role__c(
            Entity__c = uwfAccount.Id,
            Case__c = wcaCase1.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Account_Name__c = 'DIR Accounting-Unpaid Wage Fund'
        );
        //insert uwfCR1;
        insertCRList.add(uwfCR1);
        
        Case_Role__c caseRole2 = new Case_Role__c(
            Entity__c = payeeAccount.Id,
            Case__c = wcaCase2.Id,
            IsPersonAccount__c = true,
            Role__c = 'Claimant'
        );
        //insert caseRole2;
		insertCRList.add(caseRole2);
        
        Case_Role__c uwfCR2 = new Case_Role__c(
            Entity__c = uwfAccount.Id,
            Case__c = wcaCase2.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Account_Name__c = 'DIR Accounting-Unpaid Wage Fund'
        );
        //insert uwfCR2;
		insertCRList.add(uwfCR2);
        
        Case_Role__c caseRole3 = new Case_Role__c(
            Entity__c = payeeAccount.Id,
            Case__c = wcaCase3.Id,
            IsPersonAccount__c = true,
            Role__c = 'Claimant'
        );
        //insert caseRole3;
		insertCRList.add(caseRole3);
        insert insertCRList;
        
        List<Case_Role__c> uwfCaseRoleList = new List<Case_Role__c>();
        Case_Role__c uwfCR3 = new Case_Role__c(
            Entity__c = uwfAccount.Id,
            Case__c = wcaCase3.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Account_Name__c = 'DIR Accounting-Unpaid Wage Fund'
        );
        uwfCaseRoleList.add(uwfCR3);

        List<Payee__c> insertPayeeList = new List<Payee__c>();
        Payee__c payee11 = new Payee__c(
            Case_Management__c = wcaCase1.Id,
            Case_Role__c = caseRole1.Id,
            Payee_Type__c = 'Employee'
        );
        insertPayeeList.add(payee11);
        //insert payee11;

        Payee__c payee12 = new Payee__c(
            Case_Management__c = wcaCase1.Id,
            Case_Role__c = caseRole1.Id,
            Payee_Type__c = 'Employee'
        );
        insertPayeeList.add(payee12);
        //insert payee12;

        Payee__c payee13 = new Payee__c(
            Case_Management__c = wcaCase1.Id,
            Case_Role__c = caseRole1.Id,
            Payee_Type__c = 'Employee'
        );
        insertPayeeList.add(payee13);
        //insert payee13;

        Payee__c uwfPayee1 = new Payee__c(
            Verification_Letter_Sent__c = true,
            Status__c = 'Verified',
            Payee_Type__c = 'UWF',
            Case_Management__c = wcaCase1.Id,
            Factor__c = 100.00000,
            Case_Role__c = uwfCR1.Id
        );
        insertPayeeList.add(uwfPayee1);
        //insert uwfPayee1;

        Payee__c payee21 = new Payee__c(
            Case_Management__c = wcaCase2.Id,
            Case_Role__c = caseRole2.Id,
            Payee_Type__c = 'Employee'
        );
        insertPayeeList.add(payee21);
        //insert payee21;

        Payee__c payee22 = new Payee__c(
            Case_Management__c = wcaCase2.Id,
            Case_Role__c = caseRole2.Id,
            Payee_Type__c = 'Employee'
        );
        insertPayeeList.add(payee22);
        //insert payee22;

        Payee__c payee31 = new Payee__c(
            Case_Management__c = wcaCase2.Id,
            Case_Role__c = caseRole2.Id,
            Payee_Type__c = 'Employee'
        );
        insertPayeeList.add(payee31);
        //insert payee31;

        Payee__c payee32 = new Payee__c(
            Case_Management__c = wcaCase2.Id,
            Case_Role__c = caseRole2.Id,
            Payee_Type__c = 'Employee'
        );
        insertPayeeList.add(payee32);
        //insert payee32;
        insert insertPayeeList;

        List<String> payeeIdList = new List<String>();
        payeeIdList.add(payee11.Id);
        payeeIdList.add(payee12.Id);
        payeeIdList.add(payee13.Id);
        payeeIdList.add(payee21.Id);
        payeeIdList.add(payee22.Id);
        payeeIdList.add(payee31.Id);
        payeeIdList.add(payee32.Id);

        List<Payee__c> uwfPayeeList = new List<Payee__c>();
        Payee__c uwfPayee2 = new Payee__c(
            Verification_Letter_Sent__c = true,
            Status__c = 'Verified',
            Payee_Type__c = 'UWF',
            Case_Management__c = wcaCase2.Id,
            Factor__c = 100.00000,
            Case_Role__c = uwfCR2.Id
        );
        uwfPayeeList.add(uwfPayee2);
        Payee__c uwfPayee3 = new Payee__c(
            Verification_Letter_Sent__c = true,
            Status__c = 'Verified',
            Payee_Type__c = 'UWF',
            Case_Management__c = wcaCase3.Id,
            Factor__c = 100.00000
        );
        uwfPayeeList.add(uwfPayee3);

        List<String> officeAccIdList = new List<String>();
        Office_Account__c officeAcc = new Office_Account__c(
            Name = '01-112',
            Account__c = 'test',
            Office__c = officeWCA2.Id); 
        insert officeAcc;
        officeAccIdList.add(officeAcc.Id);

        Receipt__c rct= new Receipt__c(
            Payment_Amount__c = 225.44,
            Payment_Type__c = 'Check',
            Bank_Location__c = 'CA Bank',
            Instrument_Number__c = 'InstNumber',
            Payment_Exchange__c = 'Division Payment',
            Date_Received__c = Date.today(),
            Payor__c = payorAccount.Id,
            Status__c = 'New'
        );
        insert rct;

        List<Case_Payment__c> insertCPList = new List<Case_Payment__c>();
        Case_Payment__c cp1 = new Case_Payment__c(
            Case__c = wcaCase1.Id,
            Receipt__c = rct.Id,
            Payment_Amount__c = 34.44
        );
        //insert cp1;
        insertCPList.add(cp1);

        Case_Payment__c cp2 = new Case_Payment__c(
            Case__c = wcaCase2.Id,
            Receipt__c = rct.Id,
            Payment_Amount__c = 42.44
        );
        //insert cp2;
        insertCPList.add(cp2);

        Case_Payment__c cp3 = new Case_Payment__c(
            Case__c = wcaCase3.Id,
            Receipt__c = rct.Id,
            Payment_Amount__c = 62.44
        );
        //insert cp3;
        insertCPList.add(cp3);
        
        List<Judgement__c> insertJudgeList = new List<Judgement__c>();
        Judgement__c judgment1 = new Judgement__c(
            Case_Management__c = wcaCase1.Id,
            Type__c = 'ODA');
        //insert judgment1;
        insertJudgeList.add(judgment1);

        Judgement__c judgment2 = new Judgement__c(
            Case_Management__c = wcaCase2.Id,
            Type__c = 'ODA');
        //insert judgment2;
        insertJudgeList.add(judgment2);

        Judgement__c judgment3 = new Judgement__c(
            Case_Management__c = wcaCase3.Id,
            Type__c = 'ODA');
        //insert judgment3;
        insertJudgeList.add(judgment3);
        insert insertJudgeList;

        List<Judgment_Payment__c> insertJPList = new List<Judgment_Payment__c>();
        Judgment_Payment__c judgmentPmt11 = new Judgment_Payment__c(
            Case_Payment__c = cp1.Id,
            Judgment__c = judgment1.Id,
            Posted_Amount__c = 10.75,
            Status__c = 'Posted');
        //insert judgmentPmt11;
        insertJPList.add(judgmentPmt11);

        Judgment_Payment__c judgmentPmt12 = new Judgment_Payment__c(
            Case_Payment__c = cp1.Id,
            Judgment__c = judgment1.Id,
            Posted_Amount__c = 10.75,
            Status__c = 'Posted');
        //insert judgmentPmt12;
        insertJPList.add(judgmentPmt12);

        Judgment_Payment__c judgmentPmt13 = new Judgment_Payment__c(
            Case_Payment__c = cp1.Id,
            Judgment__c = judgment1.Id,
            Posted_Amount__c = 10.75,
            Status__c = 'Posted');
        //insert judgmentPmt13;
        insertJPList.add(judgmentPmt13);

        Judgment_Payment__c judgmentPmt21 = new Judgment_Payment__c(
            Case_Payment__c = cp2.Id,
            Judgment__c = judgment2.Id,
            Posted_Amount__c = 20.75,
            Status__c = 'Posted');
        //insert judgmentPmt21;
        insertJPList.add(judgmentPmt21);

        Judgment_Payment__c judgmentPmt22 = new Judgment_Payment__c(
            Case_Payment__c = cp2.Id,
            Judgment__c = judgment2.Id,
            Posted_Amount__c = 20.75,
            Status__c = 'Posted');
        //insert judgmentPmt22;
        insertJPList.add(judgmentPmt22);

        Judgment_Payment__c judgmentPmt31 = new Judgment_Payment__c(
            Case_Payment__c = cp3.Id,
            Judgment__c = judgment3.Id,
            Posted_Amount__c = 30.75,
            Status__c = 'Posted');
        //insert judgmentPmt31;
        insertJPList.add(judgmentPmt31);

        Judgment_Payment__c judgmentPmt32 = new Judgment_Payment__c(
            Case_Payment__c = cp3.Id,
            Judgment__c = judgment3.Id,
            Posted_Amount__c = 30.75,
            Status__c = 'Posted');
        //insert judgmentPmt32;
        insertJPList.add(judgmentPmt32);
        insert insertJPList;

        List<Payment_Record__c> insertPRList = new List<Payment_Record__c>();
        Payment_Record__c pr11 = new Payment_Record__c(
            Payee__c = payee11.Id,
            Judgment_Payment__c = judgmentPmt11.Id,
            Payment_Amount__c = 10.75);
        //insert pr11;
        insertPRList.add(pr11);

        Payment_Record__c pr12 = new Payment_Record__c(
            Payee__c = payee12.Id,
            Judgment_Payment__c = judgmentPmt12.Id,
            Payment_Amount__c = 10.75);
        //insert pr12;
        insertPRList.add(pr12);

        Payment_Record__c pr13 = new Payment_Record__c(
            Payee__c = payee13.Id,
            Judgment_Payment__c = judgmentPmt13.Id,
            Payment_Amount__c = 10.75);
        //insert pr13;
        insertPRList.add(pr13);

        Payment_Record__c pr21 = new Payment_Record__c(
            Payee__c = payee21.Id,
            Judgment_Payment__c = judgmentPmt21.Id,
            Payment_Amount__c = 20.75);
        //insert pr21;
        insertPRList.add(pr21);

        Payment_Record__c pr22 = new Payment_Record__c(
            Payee__c = payee22.Id,
            Judgment_Payment__c = judgmentPmt22.Id,
            Payment_Amount__c = 20.75);
        //insert pr22;
        insertPRList.add(pr22);

        Payment_Record__c pr31 = new Payment_Record__c(
            Payee__c = payee31.Id,
            Judgment_Payment__c = judgmentPmt31.Id,
            Payment_Amount__c = 30.75);
        //insert pr31;
        insertPRList.add(pr31);

        Payment_Record__c pr32 = new Payment_Record__c(
            Payee__c = payee32.Id,
            Judgment_Payment__c = judgmentPmt32.Id,
            Payment_Amount__c = 30.75);
        //insert pr32;
        insertPRList.add(pr32);
        insert insertPRList;
        
        List<Warrant_Batch__c> warrantBatchList = new List<Warrant_Batch__c>();
        Warrant_Batch__c warrantBatch = new Warrant_Batch__c(
            Status__c = 'New',
            office_Account__c = officeAcc.Id,
            WB_Instructions__c = 'UWF');
        warrantBatchList.add(warrantBatch);

        List<Warrant__c> warrantList = new List<Warrant__c>();
        Warrant__c warrant1 = new Warrant__c(
            Warrant_Batch__c = warrantBatch.Id,
            Amount__c = 32.25,
            Case__c = wcaCase1.Id,
            Status__c = 'New',
            Disbursement_Type__c = 'Unpaid Wage Fund',
            Office_Account__c = officeAcc.Id);
        warrantList.add(warrant1);

        Warrant__c warrant2 = new Warrant__c(
            Warrant_Batch__c = warrantBatch.Id,
            Amount__c = 41.50,
            Case__c = wcaCase2.Id,
            Status__c = 'New',
            Disbursement_Type__c = 'Unpaid Wage Fund',
            Office_Account__c = officeAcc.Id);
        warrantList.add(warrant2);

        Warrant__c warrant3 = new Warrant__c(
            Warrant_Batch__c = warrantBatch.Id,
            Amount__c = 61.50,
            Case__c = wcaCase3.Id,
            Status__c = 'New',
            Disbursement_Type__c = 'Unpaid Wage Fund',
            Office_Account__c = officeAcc.Id);
        warrantList.add(warrant3);
        
        String jobStr = 'CRinsert';
        //List<id> crJobId = new List<id>();
        //crJobId.add(cr123456789);
        //Map<String, List<Id>> crQjobid = new Map<String, List<Id>>();
        //crQjobid.put(jobStr, crJobId);

        //Testing RequestUnpaidWageFundController
        RequestUnpaidWageFundController.getUserInfo(adminUser.Id);
        RequestUnpaidWageFundController.getInternalEmployeeInfo(adminUser.Id);
        RequestUnpaidWageFundController.getPayeeDetails(payeeIdList);
        RequestUnpaidWageFundController.getWCAOfficeDetails();
        RequestUnpaidWageFundController.getWCACaseDetails(wcaOfficeList);
        RequestUnpaidWageFundController.getBOFECaseDetails(bofeCaseList);
        RequestUnpaidWageFundController.getOAowner(officeAccIdList);
        RequestUnpaidWageFundController.insertWarrantBatch(warrantBatchList);
        RequestUnpaidWageFundController.sendEmailToController('Test test class email for RequestUnpaidWageFundControllerTest', 'schandrasekar@dir.ca.gov', 'Test Class');
        RequestUnpaidWageFundController.getuwfAccountID();
        RequestUnpaidWageFundController.insertUwfCaseRole(uwfCaseRoleList, uwfPayeeList, warrantList, payeeIdList, 'reqUWF', 'Link to Warrant Batch');
        RequestUnpaidWageFundController.insertUwfPayee(uwfPayeeList, warrantList, payeeIdList, 'reqUWF', 'Link to Warrant Batch');
        RequestUnpaidWageFundController.insertWrsUpdatePrs(warrantList, payeeIdList, 'reqUWF', 'Link to Warrant Batch'); 

        /*
        //UWFCaseRoleInsertQable - Queuable Test Without Start & Stop
        Id jobId0 = System.enqueueJob(new UWFCaseRoleInsertQable(uwfCaseRoleList, uwfPayeeList, warrantList, insertPRList, 'reqUWF', 'Link to Warrant Batch'));
        System.debug('queuableTestWithoutStartStop [jobId0]: ' + jobId0);
        System.assertNotEquals('Completed' , [SELECT Id , Status FROM AsyncApexJob WHERE Id=:jobId0][0].Status);
        
        //UWFDirectPayeeInsertQable - Queuable Test Without Start & Stop
        Id jobId1 = System.enqueueJob(new UWFDirectPayeeInsertQable(uwfPayeeList, warrantList, insertPRList, 'reqUWF', 'Link to Warrant Batch'));
        System.debug('queuableTestWithoutStartStop [jobId1]: ' + jobId1);
        System.assertNotEquals('Completed' , [SELECT Id , Status FROM AsyncApexJob WHERE Id=:jobId1][0].Status);
		*/
        
        /*
        //UWFPayeeInsertQable - Queuable Test Without Start & Stop
        Id jobId2 = System.enqueueJob(new UWFPayeeInsertQable(uwfPayeeList, warrantList, insertPRList, 'reqUWF', 'Link to Warrant Batch',crQjobid));
        System.debug('queuableTestWithoutStartStop [jobId2]: ' + jobId2);
        System.assertNotEquals('Completed' , [SELECT Id , Status FROM AsyncApexJob WHERE Id=:jobId2][0].Status);
		*/
		

        /*
        //Queuable Test With Start & Stop
        Test.startTest();
        Id jobId_DP = System.enqueueJob(new UWFDirectPayeeInsertQable(uwfPayeeList, warrantList, insertPRList, 'reqUWF', 'Link to Warrant Batch'));
        System.debug('queuableTestWithStartStop [jobId]: ' + jobId_DP);
        Test.stopTest();

        System.assertEquals('Completed' , [SELECT Id , Status FROM AsyncApexJob WHERE Id=:jobId_DP][0].Status);
		*/
     
         /*
        test.startTest();
        warrant.Status__c = 'Voided';
        update warrant;

        warrant.Status__c = 'Approved';
        update warrant;
        
        warrant.Status__c = 'NotApproved';
        update warrant;

        warrantBatch.Status__c = 'Review Complete';
        update warrantBatch;

        test.stopTest();
        */

    }
}