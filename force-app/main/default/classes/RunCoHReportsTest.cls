/*************************************************************************************************
Class     :  RunCoHReportsTest.cls
Created   :  Mar 9, 2020
Modified  :  
Objective :  Obvious test class is obvious.

*************************************************************************************************/
@isTest(SeeAllData=true)
public class RunCoHReportsTest{
    
    static testmethod void test(){

        Office__c o = new Office__c(
            Name = 'Fake Office'
        );
        insert o;

        Office_Account__c oa = new Office_Account__c(
            Name = '66-666',
            Office__c = o.Id
        );
        insert oa;
        
        Test.startTest();
        
        RunCoHReports rcr = new RunCoHReports();
        rcr.RunCoHReports();
        
        // System.assertEquals(20, rcr.emailsToSend.size()); //reports for 19 Office Accounts (in PROD!) plus one for "Other"
        
        Test.stopTest();
        
    }
}