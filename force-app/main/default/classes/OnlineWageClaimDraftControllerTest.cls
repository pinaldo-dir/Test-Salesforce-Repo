@isTest
public class OnlineWageClaimDraftControllerTest {
    @testSetup static void setUpMethod() {
        Online_Claim_Draft__c owcDraftList = new Online_Claim_Draft__c();
        owcDraftList.Section_Id__c = '1';
        insert owcDraftList;
    }
    @istest 
    public static void getDraftRecordsTest(){
        List<Online_Claim_Draft__c>  owcDraftListGetRecord  = [SELECT Id, Name, Draft_JSON__c, Section_Id__c, Case_Management__c FROM Online_Claim_Draft__c];
        Test.startTest();
        List<OnlineWageClaimDraftController.owcDraftWrapper>  getReturnList = OnlineWageClaimDraftController.getDraftRecords();
        Test.stopTest();
        System.assert(getReturnList.size()>0);
        System.assertEquals(getReturnList.size(), owcDraftListGetRecord.size());
    }
}