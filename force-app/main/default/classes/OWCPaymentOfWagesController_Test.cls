@isTest
public class OWCPaymentOfWagesController_Test {
    @isTest
    public static void testOWCPaymentOfWagesController(){
         Test.startTest();

        OWCPaymentOfWagesController.fetchFrequencyMetaData();
         OWCPaymentOfWagesController.fetchOptionsMetaData();
        

         Test.stopTest();   
    }

}