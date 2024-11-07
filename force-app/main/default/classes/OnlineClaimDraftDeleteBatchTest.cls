@isTest
public class OnlineClaimDraftDeleteBatchTest {
    static testMethod void testMethod1() 
    {
        // List<Online_Claim_Draft__c> lstAccount= new List<Online_Claim_Draft__c>();
        Online_Claim_Draft__c ocd = new Online_Claim_Draft__c();
        ocd.Section_Id__c = 'Id:8281636358469';
        
        Date myDate = Date.newInstance(2016, 12, 9);
        Time myTime = Time.newInstance(8, 0, 0, 0);
        DateTime dt1 = DateTime.newInstanceGMT(myDate, myTime);
        ocd.CreatedDate=dt1;
        ocd.LastModifiedDate=dt1;
        String objectJSON=JSON.serialize(ocd);
        Online_Claim_Draft__c claimObj = (Online_Claim_Draft__c) JSON.deserialize(objectJSON, Online_Claim_Draft__c.class );
        insert claimObj;
        Test.startTest();
        OnlineClaimDraftDeleteBatch obj = new OnlineClaimDraftDeleteBatch(10);
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }
}