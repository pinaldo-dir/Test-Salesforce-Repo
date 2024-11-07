@isTest
public with sharing class CashCustomExceptionTest {
    @isTest
    static void testCashCustomException(){
        Test.startTest();

        CashCustomException cce = new CashCustomException('test');
        System.assertEquals('test', cce.getMessage(), '');

        Test.stopTest();
    }
}