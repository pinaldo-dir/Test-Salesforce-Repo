@isTest(SeeAllData=false)
public class RequestWBandWRlwcControllerTest {
   
    @isTest 
    static void testRequestWBandWRlwcControllerTest(){

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
        
        List<String> caseIdList = new List<String>();
        DIR_Case__c cm = new DIR_Case__c();
        cm.Employer__c = acc.Id;
        cm.Assigned_Deputy__c = emp.Id;
        insert cm;
        caseIdList.add(cm.Id);

        Case_Role__c caseRole = new Case_Role__c(
            Entity__c = payeeAccount.Id,
            Case__c = cm.Id,
            IsPersonAccount__c = true,
            Role__c = 'Claimant'
        );
        insert caseRole;

        List<Case_Role__c> caseRoleList = new List<Case_Role__c>();
        Case_Role__c caseRole2 = new Case_Role__c(
            Entity__c = payeeAccount.Id,
            Case__c = cm.Id,
            IsPersonAccount__c = true,
            Role__c = 'Claimant'
        );
        caseRoleList.add(caseRole2);

        List<String> payeeIdList = new List<String>();
        Payee__c payee = new Payee__c(
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole.Id
        );
        insert payee;
        payeeIdList.add(payee.Id);

        List<Payee__c> payeeList = new List<Payee__c>();
        Payee__c payee2 = new Payee__c(
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole.Id
        );
        payeeList.add(payee2);

        Office__c office = new Office__c(
            Name = 'Sacramento CCU',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        insert office;

        List<String> officeAccIdList = new List<String>();
        Office_Account__c officeAcc = new Office_Account__c(
            Name = '01-112',
            Account__c = 'test',
            Office__c = office.Id); 
        insert officeAcc;
        officeAccIdList.add(officeAcc.Id);
        
        List<Warrant_Batch__c> warrantBatchList = new List<Warrant_Batch__c>();
        Warrant_Batch__c warrantBatch = new Warrant_Batch__c(
            Status__c = 'Pending Approval',
            office_Account__c = officeAcc.Id);
        insert warrantBatch;
        warrantBatchList.add(warrantBatch);

        List<Warrant_Batch__c> warrantBatchList2 = new List<Warrant_Batch__c>();
        Warrant_Batch__c warrantBatch2 = new Warrant_Batch__c(
            Status__c = 'New',
            office_Account__c = officeAcc.Id);
        warrantBatchList2.add(warrantBatch2);

        List<Warrant_Batch__c> warrantBatchList3 = new List<Warrant_Batch__c>();
        Warrant_Batch__c warrantBatch3 = new Warrant_Batch__c(
            Status__c = 'New',
            office_Account__c = officeAcc.Id);
        warrantBatchList3.add(warrantBatch3);

        List<Warrant_Batch__c> warrantBatchList4 = new List<Warrant_Batch__c>();
        Warrant_Batch__c warrantBatch4 = new Warrant_Batch__c(
            Status__c = 'New',
            office_Account__c = officeAcc.Id);
        warrantBatchList4.add(warrantBatch4);
        
        List<Warrant__c> warrantList = new List<Warrant__c>();
        Warrant__c warrant = new Warrant__c(
            Warrant_Batch__c = warrantBatch.Id,
            Amount__c = 2.22,
            Case__c = cm.Id,
            Payee__c = payee.Id,
            Status__c = 'New',
            Office_Account__c = officeAcc.Id);
        insert warrant;
        warrantList.add(warrant);

        List<Warrant__c> warrantList2 = new List<Warrant__c>();
        Warrant__c warrant2 = new Warrant__c(
            Warrant_Batch__c = warrantBatch.Id,
            Amount__c = 10.22,
            Case__c = cm.Id,
            Payee__c = payee.Id,
            Status__c = 'New',
            Office_Account__c = officeAcc.Id);
        warrantList2.add(warrant2);

        List<Warrant__c> warrantList3 = new List<Warrant__c>();
        Warrant__c warrant3 = new Warrant__c(
            Warrant_Batch__c = warrantBatch.Id,
            Amount__c = 25,
            Case__c = cm.Id,
            Payee__c = payee.Id,
            Status__c = 'New',
            Office_Account__c = officeAcc.Id);
        warrantList3.add(warrant3);

        List<Warrant__c> warrantList4 = new List<Warrant__c>();
        Warrant__c warrant4 = new Warrant__c(
            Warrant_Batch__c = warrantBatch.Id,
            Amount__c = 50,
            Case__c = cm.Id,
            Payee__c = payee.Id,
            Status__c = 'New',
            Office_Account__c = officeAcc.Id);
        warrantList4.add(warrant4);
        
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
 
        //Testing RequestWarrantsLWCcontroller
        RequestWarrantsLWCcontroller.getUserInfo(adminUser.Id);
        RequestWarrantsLWCcontroller.getInternalEmployeeInfo(adminUser.Id);
        RequestWarrantsLWCcontroller.getPayeeDetails(payeeIdList);
        RequestWarrantsLWCcontroller.getOAowner(officeAccIdList);
        RequestWarrantsLWCcontroller.insertWarrantBatch(warrantBatchList2);
        RequestWarrantsLWCcontroller.insertWrsUpdatePrs(warrantList2, prList, 'RequestWR', 'Link to Warrant Batch');
        //RequestWarrantsLWCcontroller.insertWarrants(warrantList2);
        //RequestWarrantsLWCcontroller.updatePaymentRecord(prList);
        RequestWarrantsLWCcontroller.sendEmailToController('Test test class email for RequestWBandWRlwcControllerTest', 'schandrasekar@dir.ca.gov', 'Test Class');
    
        //Testing RequestBofePenaltyWarrantController
        RequestBofePenaltyWarrantController.getUserInfo(adminUser.Id);
        RequestBofePenaltyWarrantController.getInternalEmployeeInfo(adminUser.Id);
        RequestBofePenaltyWarrantController.getPayeeDetails(payeeIdList);
        RequestBofePenaltyWarrantController.getCaseDetails(caseIdList);
        RequestBofePenaltyWarrantController.getOAowner(officeAccIdList);
        RequestBofePenaltyWarrantController.insertWarrantBatch(warrantBatchList3);
        RequestBofePenaltyWarrantController.insertWrsUpdatePrs(warrantList3, prList, 'reqBOFEwr', 'Link to Warrant Batch');
        RequestBofePenaltyWarrantController.sendEmailToController('Test test class email for RequestWBandWRlwcControllerTest', 'schandrasekar@dir.ca.gov', 'Test Class');
    
        //Testing RequestCourtPayeeWarrantsLWCcontroller
        RequestCourtPayeeWarrantsLWCcontroller.getUserInfo(adminUser.Id);
        RequestCourtPayeeWarrantsLWCcontroller.getInternalEmployeeInfo(adminUser.Id);
        RequestCourtPayeeWarrantsLWCcontroller.getPayeeDetails(payeeIdList);
        RequestCourtPayeeWarrantsLWCcontroller.getOAowner(officeAccIdList);
        RequestCourtPayeeWarrantsLWCcontroller.insertWarrantBatch(warrantBatchList4);
        RequestCourtPayeeWarrantsLWCcontroller.insertWarrants(warrantList4);
        RequestCourtPayeeWarrantsLWCcontroller.updatePaymentRecord(prList);
        RequestCourtPayeeWarrantsLWCcontroller.sendEmailToController('Test test class email for RequestWBandWRlwcControllerTest', 'schandrasekar@dir.ca.gov', 'Test Class');


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

    }
}