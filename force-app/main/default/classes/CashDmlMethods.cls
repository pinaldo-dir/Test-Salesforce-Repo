public with sharing class CashDmlMethods {

    @AuraEnabled(cacheable=true)
    public static DIR_Case__c queryCase(String caseId){
        return [SELECT Id, Name, Case_Number__c, Assigned_Deputy__c, Assigned_Deputy__r.Name, RecordType.Name, Office__r.Office_Number__c, Assigned_Deputy__r.Manager__c
                FROM DIR_Case__c
                WHERE Id = :caseId];

    }

    @AuraEnabled(cacheable=true)
    public static Case_Payment__c queryCP(String cpId){
        Case_Payment__c cp = 
          [SELECT Id, Name, Status__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Payment_Amount__c, Deposited__c, Payment_Exchange__c,

                //CU-1 wrapper fields remaining on the CP
                Payment_Classification__c, Special_Instructions__c, Payment_Terms__c, Payment_Terms_Other__c, //TODO: rename Special_Instructions__c to Payment_Classification_Special_Instructions__c ?
                Date_Funds_Mailed_to_Employee__c, Mailing_Instructions__c,

                //TODO: CU-1 wrapper fields moved to the LP. Would be nice to replace with rollups somehow, but schema limitations (the CP being a junction object for one) prevent this.
                //Hold_Amount__c, Hold_Review_Date__c, Hold_Explanation__c, Hold_For__c, Hold_For_Other__c, //TODO: these fields no longer used by the business - delete eventually.                         
                Refund_Amount__c, Refund_Amount_Details__c, 
                Amounts_Due_to_DIR__c, Amounts_Due_to_DIR_Explanation__c, 
                Other_Amount__c, Other_Amount_Details__c,
                
                //TODO: replaced by separate "Other" and "Refund" fields--delete
                //Other_Refund__c, Other_Refund_Specify__c,
                
                //TODO: CU-1 fields remaining on the CP detail, but not on the CP allocation LWC. Removing from this query because currently they're not involved in any automation.
                //Public_Works_Penalties__c, Apprenticeship_Penalties__c, California_Apprenticeship_Council__c, 
                //CA_Apprenticeship_Council_Craft__c, CA_Apprenticeship_County__c, 
                //CPR_only__c, CPR_Only_Pay_Business__c,CPR_Refund__c, CPR_Refund_Pay_Business__c,
                //CMU_Reimbursement__c, 

                Case__c, Case__r.RecordType.DeveloperName, Case__r.Name, Case__r.RecordType.Name, Case__r.Case_Number__c, Case__r.Status__c,
                Case__r.Assigned_Deputy__c, Case__r.Assigned_Deputy__r.Id, Case__r.Assigned_Deputy__r.Name,
                Case__r.Employer__r.Name, Case__r.Office__r.Name,

                Receipt__r.Name, Receipt__r.Deposit_Account__c, Receipt__r.Instrument_Number__c, Receipt__r.Date_Received__c, Receipt__r.Hold_Date__c, Receipt__r.Status__c, 
                Receipt__r.Payor__c, Receipt__r.Payor__r.Name,

                Payment_Plan__c, Payment_Plan__r.Payment_Plan_Balance__c, 

                (SELECT Id, Name, Posted_Amount__c, Payment_Applied_To__c,  Recommended_Amount__c, Case_Issue_RecordTypeId__c, Status__c,

                    //CU-1 wrapper fields moved from the CP.
                    //  The amount field related to these fields is just the LP.Recommended_Amount__c and LP.Posted_Amount__c fields.
                    //Hold_Review_Date__c, Hold_Explanation__c, Hold_For__c, Hold_For_Other__c, //TODO: deprecated, delete
                    Refund_Amount_Details__c, Amounts_Due_to_DIR_Explanation__c, Other_Amount_Details__c, Payment_On_Behalf_Of__c, Payment_On_Behalf_Of__r.Case_Role__c,
                    Case_Violation__c, Case_Payment__c
                FROM Liability_Payments__r),

                (SELECT Id, Name, Posted_Amount__c, Payment_Applied_To__c, Recommended_Amount__c, Payment_On_Behalf_Of__c, Payment_On_Behalf_Of__r.Case_Role__c,
                    Funds_Redundant_With__c, Judgment__c
                FROM Judgment_Payments__r)

            FROM Case_Payment__c
            WHERE Id = :cpId];

            System.debug('59 lp.size(): ' + cp.Liability_Payments__r.size());
            System.debug('60 jp.size(): ' + cp.Judgment_Payments__r.size());

            return cp;
    }

    @AuraEnabled(cacheable=true)
    public static List<Payment_Plan__c> queryPPs(String caseId){
        return [SELECT Id, Name, Case__c, Responsible_Party__c, Payment_Plan_Balance__c
                        FROM Payment_Plan__c
                        WHERE Case__c = :caseId];
    }

    @AuraEnabled(cacheable=true)
    public static List<DIR_Violation__c> queryCIs(String caseId) {
        return [SELECT Id, Name, RecordTypeId,
                    Wages_Due__c, Non_Interest_Wage_Balance_Due__c,
                    Total_Wage_Interest_Amount__c, Wage_Interest_Balance_Due__c,
                    Citation_Amount__c, Penalty_Balance_Due__c,
                    Total_Interest_Amount__c, Interest_Balance_Due__c,
                    Status__c, Wage_Assessment_Description__c,

                    Assessment__c, Assessment__r.Citation_Number__c, Assessment__r.JEU_Case_Number__c,

                    Case__c, Case__r.Id,
                                    
                    Violation_Type__c, Violation_Type__r.Name, 

                (SELECT Id, Name, Case_Issue__c, Liable_Party__c, Liable_Party__r.Id
                    FROM Liable_Party_Case_Issues__r),
        
                (SELECT Id, Name, Case_Violation__c, Liability_Judgement__c
                    FROM Judgement_Case_Violations__r)
    
                FROM DIR_Violation__c
                WHERE Case__c = :caseId
                
                    //AND Status__c != 'Canceled'
                    AND Status__c != 'Canceled - Invalid'
                    AND Status__c != 'Canceled/Invalid'
                    //AND Status__c != 'Dismissed'
                    //AND Status__c != 'Administrative Dismissal'
                    //AND Status__c != 'Dismissed at Conference'
                    //AND Status__c != 'Dismissed at Hearing'

            ORDER BY Violation_Type__r.Name ASC];
    }

    @AuraEnabled(cacheable=true)
    public static List<Judgement__c> queryJudgments(String caseId) {
        return [SELECT Id, Name, Case_Management__c, Case_Management__r.Id, Court__c, Court__r.Name, Court_Case_Number__c, Status__c, Type__c,
                        Post_hearing_Interest_Balance_Due__c, Post_judgment_Interest_Balance_Due__c, Attorney_Fees_Balance_Due__c, Filing_Fees_Balance_Due__c,
                    (SELECT Id, Name, Judgement__c, Liable_Party__c, Liable_Party__r.Case_Role__c, Liable_Party__r.Case_Role__r.Id
                        FROM Liability_Judgements__r) //Liability_Judgements__r aka Judgment Parties
                FROM Judgement__c
                WHERE Case_Management__c = :caseId
                ORDER BY Post_judgment_Interest_Balance_Due__c DESC];
    }

    @AuraEnabled(cacheable=true)
    public static List<Payee__c> queryPayees(String caseId) {
        return [SELECT Id, Name, Case_Management__c, Case_Management__r.Id, Case_Role__c, Case_Role__r.Entity__c, Factor__c, Role__c, Payee_Type__c
                FROM Payee__c
                WHERE Case_Management__r.Id = :caseId];

    }

    @AuraEnabled(cacheable=true)
    public static List<Liable_Party__c> queryLiableParties(String caseId) {
        return [SELECT Id, Name, 
        
                    Case_Role__c, Case_Role__r.Id, Case_Role__r.Name, Case_Role__r.Role__c,
                    Case_Role__r.Case__c, Case_Role__r.Case__r.Id, Case_Role__r.Case_Role_Account_Name__c,
                    Case_Role__r.Entity__c, Case_Role__r.Entity__r.Id, Case_Role__r.Entity__r.Name,

                    Liability__c, Liability__r.Id, Liability__r.Assessment__c, Liability__r.Assessment__r.Id,

                (SELECT Id, Name, Judgement__c, Judgement__r.Id, Liable_Party__c, Liable_Party__r.Id, Liable_Party__r.Case_Role__c
                    FROM Liability_Judgements__r)

                // TODO: this subquery likely removeable
                //(SELECT Id, Name, Case_Issue__c, Liable_Party__c, Liable_Party__r.Id, Liable_Party__r.Case_Role__c, Liable_Party__r.Case_Role__r.Id
                //    FROM Liable_Party_Case_Issues__r)

                FROM Liable_Party__c
                WHERE Case_Role__r.Case__c = :caseId];
    }
}