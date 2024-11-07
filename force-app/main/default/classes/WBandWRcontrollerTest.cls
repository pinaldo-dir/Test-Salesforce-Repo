@isTest(SeeAllData=false)
public class WBandWRcontrollerTest {
   
    @isTest 
    static void testWBandWRcontroller(){

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
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        acc.Bankruptcy_Status_Date__c = Date.today();
        insert acc;

        Account payeeAccount = new Account(
            Name = 'payeeAccount'
        );
        insert payeeAccount;

        Account payorAccount = new Account(
            Name = 'payorAccount'
        );
        insert payorAccount;
        
        DIR_Case__c cm = new DIR_Case__c();
        cm.Employer__c = acc.Id;
        cm.Assigned_Deputy__c = emp.Id;
        cm.Deposited_Funds__c = 500.00;
        cm.Funds_Drawn_on_Deposits__c = 400.00;
        cm.Warrants_Pending__c = 0.00;
        insert cm;
        
        List<Id> caseId = new List<Id>();
        caseId.add(cm.Id);

        Case_Role__c caseRole = new Case_Role__c(
            Entity__c = payeeAccount.Id,
            Case__c = cm.Id,
            IsPersonAccount__c = true,
            Role__c = 'Claimant'
        );
        insert caseRole;

        Payee__c payee = new Payee__c(
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole.Id
        );
        insert payee;

        Office__c office = new Office__c(
            Name = 'Sacramento CCU',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        insert office;

        Office_Account__c officeAcc = new Office_Account__c(
            Name = '01-112',
            Account__c = 'test',
            Office__c = office.Id); 
        insert officeAcc;
        
        List<Warrant_Batch__c> warrantBatchList = new List<Warrant_Batch__c>();
        Warrant_Batch__c warrantBatch = new Warrant_Batch__c(
            Status__c = 'Pending Approval',
            office_Account__c = officeAcc.Id);
        insert warrantBatch;
        warrantBatchList.add(warrantBatch);
        
        List<Warrant__c> warrantList = new List<Warrant__c>();
        Warrant__c warrant = new Warrant__c(
            Warrant_Batch__c = warrantBatch.Id,
            //Warrant_Number__c = '777',
            Amount__c = 2.22,
            Case__c = cm.Id,
            Payee__c = payee.Id,
            Status__c = 'Approved',
            Office_Account__c = officeAcc.Id);
        insert warrant;
        warrantList.add(warrant);
        
        Receipt__c rctjp = new Receipt__c(
            Payment_Amount__c = 4.44,
            Payment_Type__c = 'Check',
            Bank_Location__c = 'CA Bank',
            Instrument_Number__c = 'doIamuseyou',
            Payment_Exchange__c = 'Division Payment',
            Date_Received__c = Date.today(),
            Payor__c = payorAccount.Id,
            Status__c = 'New'
        );
        insert rctjp;

        Case_Payment__c cpjp = new Case_Payment__c(
            Case__c = CM.Id,
            Receipt__c = rctjp.Id,
            Payment_Amount__c = 4.44
        );
        insert cpjp;
        
        Judgement__c judgment = new Judgement__c(
            Case_Management__c = CM.Id,
            Type__c = 'ODA');
        insert judgment;

        Judgment_Payment__c judgmentPmt = new Judgment_Payment__c(
            Case_Payment__c = cpjp.Id,
            Judgment__c = judgment.Id,
            Posted_Amount__c = 4.44,
            Status__c = 'Posted');
        insert judgmentPmt;

        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        Payment_Record__c paymentRecord = new Payment_Record__c(
            Payee__c = payee.Id,
            Judgment_Payment__c = judgmentPmt.Id,
            Payment_Amount__c = 4.44,
            Warrant_Issued__c = TRUE,
            Warrant__c = warrant.Id);
        insert paymentRecord;
        prList.add(paymentRecord);

        List<DIR_Case__c> caseWarrantList =  new List<DIR_Case__c>([SELECT Id, Name, Cash_Balance_on_Case__c, Deposited_Funds__c, 
                                                                    Funds_Drawn_on_Deposits__c, Warrants_Pending__c, Status__c,
                                                                    (SELECT Id, Name, Warrant_Number__c, Amount__c, Status__c, Case__c, 
                                                                    Case__r.Id, Case__r.Name FROM Warrants__r 
                                                                    WHERE Status__c IN ('New','Pending Approval','Approved','Not Approved','Secondary Approval Needed','Printed')) 
                                                                  FROM DIR_Case__c WHERE Id IN :caseId]);
        
        Map<String, List<Id>> qJobId = new Map<String, List<Id>>();
        qJobId.put('Update Payment Records', new List<Id>{'101000001fakeid'});
        
        Map<String, List<Id>> qJobId1 = new Map<String, List<Id>>();
        qJobId1.put('Update Warrant Pending', new List<Id>{'101000001fakeid'});
        
        Map<String, List<Id>> qJobId2 = new Map<String, List<Id>>();
        qJobId2.put('Insert Warrants', new List<Id>{'101000001fakeid'});

        //Testing WarrantBatchProcessController
        WarrantBatchProcessController.getWBid(warrantBatch.Id);
        WarrantBatchProcessController.getWarrantBatchDetails(warrantBatch.Id);

        //Testing WarrantsProcessController
        WarrantsProcessController.getUserInfo(adminUser.Id);
        WarrantsProcessController.getWarrantsCaseDetails(warrantBatch.Id);
        WarrantsProcessController.getWarrantBatchDetails(warrantBatch.Id);
        Boolean updateWrProcess = WarrantsProcessController.updateWRandPRstatus(warrantList, prList);
        Boolean updWB = WarrantsProcessController.updatedWarrantBatch(warrantBatchList, caseId, 'Warrant Batch URL Link');

        //Testing WBSubmitApprovalController
        WBSubmitApprovalController.getUserInfo(adminUser.Id);
        WBSubmitApprovalController.getWarrantsCaseDetails(warrantBatch.Id);
        Boolean updateSubmitApp = WBSubmitApprovalController.updateWBandWRstatus(warrantBatchList, warrantList, 'Warrant Batch URL Link');
        WBSubmitApprovalController.getInternalEmployeeInfo(adminUser.Id);
        
        //Testing WBApprovalController
        WBApprovalController.getUserInfo(adminUser.Id);
        WBApprovalController.getWarrantsCaseDetails(warrantBatch.Id);
        Boolean updateWRapproval = WBApprovalController.updatedWarrants(warrantList, warrantBatchList, 'Warrant Batch URL Link');
        //Boolean updateWBapproval = WBApprovalController.updatedWarrantBatch(warrantBatchList);
        WBApprovalController.getInternalEmployeeInfo(adminUser.Id);

        //Testing WBSecondaryApprovalController
        WBSecondaryApprovalController.getUserInfo(adminUser.Id);
        WBSecondaryApprovalController.getWarrantsCaseDetails(warrantBatch.Id);
        Boolean updateWRsecApproval = WBSecondaryApprovalController.updatedWarrants(warrantList, warrantBatchList, 'Warrant Batch URL Link');
        //Boolean updateWBsecApproval = WBSecondaryApprovalController.updatedWarrantBatch(warrantBatchList);
        WBSecondaryApprovalController.getInternalEmployeeInfo(adminUser.Id);
        
        //Testing WBVoidController
        WBVoidController.getUserInfo(adminUser.Id);
        WBVoidController.getWarrantsCaseDetails(warrantBatch.Id);
        Boolean updateWBVoid = WBVoidController.updateWBandWRstatus(warrantBatchList, warrantList, prList, 'Warrant Batch URL Link');

        //Testing WRVoidController
        WRVoidController.getUserInfo(adminUser.Id);
        WRVoidController.getWarrantsCaseDetails(warrantBatch.Id);
        WRVoidController.getWarrantBatchDetails(warrantBatch.Id);
        Boolean updateWRVoid = WRVoidController.updateWRandPRstatus(warrantList, prList);
        Boolean updateWB = WRVoidController.updatedWarrantBatch(warrantBatchList, caseId, 'Warrant Batch URL Link');

        //Testing WBPrintUpdateController
        WBPrintUpdateController.getUserInfo(adminUser.Id);
        WBPrintUpdateController.getWarrantsCaseDetails(warrantBatch.Id);
        Boolean updateWBprint = WBPrintUpdateController.updateWBandWRstatus(warrantBatchList, warrantList, prList, 'Warrant Batch URL Link');


        test.startTest();
        warrant.Status__c = 'Voided';
        update warrant;

        warrant.Status__c = 'Approved';
        update warrant;
        
        warrant.Status__c = 'NotApproved';
        update warrant;

        warrantBatch.Status__c = 'Review Complete';
        update warrantBatch;
         
        system.enqueueJob(new PaymentRecordUpdateQable(prList, caseWarrantList, 'Warrant Batch URL Link', qJobId, 'Update'));
        system.enqueueJob(new WarrantPendingUpdateQable(caseWarrantList, 'Warrant Batch URL Link', qJobId1, 'Update'));
        system.enqueueJob(new WarrantPendingUpdateQable(caseWarrantList, 'Warrant Batch URL Link', qJobId2, 'Insert'));
        
        DIR_Case__c cm2 = new DIR_Case__c();
        cm2.Employer__c = acc.Id;
        cm2.Assigned_Deputy__c = emp.Id;
        cm2.Deposited_Funds__c = 500.00;
        cm2.Funds_Drawn_on_Deposits__c = 400.00;
        cm2.Warrants_Pending__c = 0.00;
        cm2.Status__c = 'Pending';
        //insert cm2;
        caseWarrantList.add(cm2);
        system.enqueueJob(new WarrantPendingUpdateQable(caseWarrantList, 'Warrant Batch URL Link', qJobId2, 'Insert'));

        test.stopTest();
        
        

    }
}