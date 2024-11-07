@isTest
public class OWCDeleteAplusDataBatchTest {
	@isTest
    public static void testDeleteAlusDataBatch() {
        Attachments_New__c aPlus = new Attachments_New__c(File_Type__c = 'Intake',File_Name__c ='Test');
        insert aPlus;
        Attachments_Data__c aData = new Attachments_Data__c(Field_API_Name__c = 'Test_Api',
                                                            Value__c = 'Test_value',
                                                           Attachments__c = aPlus.Id);
        insert aData;
        
        Test.startTest();
        OWCDeleteAplusDataBatch batch = new OWCDeleteAplusDataBatch();
        database.executeBatch(batch, 10);
        Test.stopTest();
         
    }
}