//Scheduled by the ScheduleCreateOAMTRecords class, q.v. Should be run on the 1st of each month for the month previous.
public class CreateOAMTRecords{
    // TODO: change this to a batch class if RCT and Warrant record amounts get too large
    public List<Office_Account_Monthly_Totals__c> oamtsToInsert = new List<Office_Account_Monthly_Totals__c>();
    
    public void CreateOAMTRecords(){
        Date today = Date.today(); //Date this class is scheduled to run, which should be the 1st of each month for the month just previous
        if(Test.isRunningTest()){
            today = Date.parse('08/01/2019'); //test class has hard-coded dates
        }
        Date firstOfPreviousMonth = today.addMonths(-1).toStartOfMonth(); //first day of the month that the OAMT records are created FOR
        Date lastOfPreviousMonth = Date.newInstance(firstOfPreviousMonth.year(), firstOfPreviousMonth.month(), Date.daysInMonth(firstOfPreviousMonth.year(), firstOfPreviousMonth.month()));
        Date firstOf2MonthsPrevious = firstOfPreviousMonth.addMonths(-1).toStartOfMonth();
        Date lastOf2MonthsPrevious = Date.newInstance(firstOf2MonthsPrevious.year(), firstOf2MonthsPrevious.month(), Date.daysInMonth(firstOf2MonthsPrevious.year(), firstOf2MonthsPrevious.month()));
        
        List<Office_Account__c> oas = [SELECT Id, Name, Deprecated__c
                                        FROM Office_Account__c
                                        WHERE Deprecated__c = FALSE];

        /* OAMT.Prior_Month_Starting_Balance__c: derived from OAMT.Ending_Balance__c of the last OAMT record for a particular Office Account. */

        /* OAMT.Deposited_Receipts__c: Receipts where Status = 'Deposited', 'Returned', or 'Deposited-Returned' and Deposit Date is in the previous month. */
        List<Receipt__c> depositedRcts = [SELECT Id, Name, Deposit_Date__c, Deposit_Account__c, Returned_Item__c, Returned_Date__c, Voided_Item__c, Status__c, Payment_Amount__c,
                                                Transaction__c, Transaction__r.Id, Transaction__r.Deposit_Date__c, Transaction__r.Transaction_Type__c,
                                                Transaction__r.Office_Account__c, Transaction__r.Office_Account__r.Id, Transaction__r.Office_Account__r.Name
                                            FROM Receipt__c
                                            WHERE (Deposit_Date__c >= :firstOfPreviousMonth AND Deposit_Date__c <= :lastOfPreviousMonth)
                                                AND (Status__c = 'Deposited'
                                                        OR Status__c = 'Returned'
                                                        OR Status__c = 'Deposited-Returned')];
                                                        
        System.debug('30 depositedRcts = ' + depositedRcts);

        /* OAMT.Voided_Canceled_and_Stopped_Warrants__c: Issued Warrants where the Status was changed to 'Voided', 'Canceled', or 'Stopped' in the previous month. */
        List<Warrant__c> voidedCanceledStoppedWarrs = [SELECT Id, Name, Status__c, Status_Date__c, Issue_Date__c, Amount__c, Office_Account__c, Office_Account__r.Id, Office_Account__r.Name
                                                        FROM Warrant__c
                                                        WHERE (Status_Date__c >= :firstOfPreviousMonth AND Status_Date__c <= :lastOfPreviousMonth)
                                                            AND (Status__c = 'Voided' OR Status__c = 'Canceled' OR Status__c = 'Stopped')
                                                            AND Issue_Date__c != NULL];

        /* OAMT.Adjustments__c: Adjustment-type Transactions deposited in the previous month. */
        List<Transaction__c> adjustmentTrns = [SELECT Id, Name, Deposit_Date__c, Transaction_Type__c, Transaction_Sum__c, Office_Account__c
                                                FROM Transaction__c
                                                WHERE (Deposit_Date__c >= :firstOfPreviousMonth AND Deposit_Date__c <= :lastOfPreviousMonth)
                                                        AND Transaction_Type__c = 'Adjustment'];
        
        /* OAMT.Prior_Month_Returned_Receipts__c: As of Sept 2023, this field is no longer queried, but user editable as needed. 
            Before Sept 2023, was 'RCTs returned in the previous month that were deposited prior to the previous month':
            (Deposit_Date__c <= :lastOf2MonthsPrevious) AND (Returned_Date__c >= :firstOfPreviousMonth AND Returned_Date__c <= :lastOfPreviousMonth) AND Returned_Item__c = TRUE */
        
        /* OAMT.Disbursements__c:  Warrants where Issue Date is in the previous month, regardless of current Status. */
        List<Warrant__c> disbursements = [SELECT Id, Name, Status__c, Status_Date__c, Issue_Date__c, Amount__c, Office_Account__c, Office_Account__r.Id, Office_Account__r.Name
                                            FROM Warrant__c
                                            WHERE (Issue_Date__c >= :firstOfPreviousMonth AND Issue_Date__c <= :lastOfPreviousMonth)];
        
        //Assumes previous OAMT records were created by this code on the 1st of the previous month
        List<Office_Account_Monthly_Totals__c> oamts = [SELECT Id, Name, CreatedDate, Office_Account__c, Date__c, Ending_Balance__c, Adjustments__c, Prior_Month_Returned_Receipts__c,
                                                            Prior_Month_Voided_Canceled_Warrants__c, Deposited_Receipts__c, Disbursements__c, Month_Year__c
                                                        FROM Office_Account_Monthly_Totals__c
                                                        WHERE (Date__c = :lastOf2MonthsPrevious)];
        
        for(Office_Account__c oa : oas){
            for(Office_Account_Monthly_Totals__c oamt : oamts){
                
                if(oa.Id == oamt.Office_Account__c){
                    Decimal sumOfDepositedRcts = 0.00;
                    Decimal sumOfVoidedCanceledStoppedWarrs = 0.00;
                    Decimal sumOfAdjustmentTrns = 0.00;
                    Decimal sumOfReturnedRcts = 0.00;
                    Decimal sumOfDisbursements = 0.00;

                    for(Receipt__c rct : depositedRcts){
                        if(rct.Transaction__r.Office_Account__c == oamt.Office_Account__c){
                                sumOfDepositedRcts += rct.Payment_Amount__c;
                                System.debug('72 sumOfDepositedRcts: ' + sumOfDepositedRcts);
                        }
                    }
                    for(Warrant__c warr : voidedCanceledStoppedWarrs){
                        if(warr.Office_Account__c == oamt.Office_Account__c){
                            sumOfVoidedCanceledStoppedWarrs += warr.Amount__c;
                        }
                    }
                    for(Transaction__c trn : adjustmentTrns){
                        if(trn.Office_Account__c == oamt.Office_Account__c){
                            sumOfAdjustmentTrns += trn.Transaction_Sum__c;
                        }
                    }
                    for(Warrant__c warr : disbursements){
                        if(warr.Office_Account__c == oamt.Office_Account__c){
                            sumOfDisbursements += warr.Amount__c;
                        }
                    }

                    Office_Account_Monthly_Totals__c newOamt = new Office_Account_Monthly_Totals__c(
                        Office_Account__c = oa.Id,
                        Date__c = lastOfPreviousMonth,
                        Prior_Month_Starting_Balance__c = oamt.Ending_Balance__c,
                        Deposited_Receipts__c = sumOfDepositedRcts,
                        Voided_Canceled_and_Stopped_Warrants__c = sumOfVoidedCanceledStoppedWarrs,
                        Adjustments__c = sumOfAdjustmentTrns,
                        Prior_Month_Returned_Receipts__c = sumOfReturnedRcts,
                        Disbursements__c = sumOfDisbursements
                    );
                    oamtsToInsert.add(newOamt);
                }
            }
        }
        insert oamtsToInsert;
    }
}