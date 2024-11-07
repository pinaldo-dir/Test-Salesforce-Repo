@isTest
public class ReceiptLogFormControllerTest {
    static testmethod void testPkList(){
        ReceiptLogFormController.getBankLocation();
        ReceiptLogFormController.getPaymentTypes();
        ReceiptLogFormController.getDepositAccount();
        ReceiptLogFormController.getPaymentExchange();
        ReceiptLogFormController.getOfficeUnit();
    }
    
    static testmethod void testPayorName(){
        
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.Bankruptcy_Status_Date__c = Date.today();
        insert acc;
        
        System.assertEquals(acc.name, ReceiptLogFormController.getPayorName(String.valueOf(acc.Id)));        
    }
    
    static testmethod void testDeputyName(){
        
        DIR_Employee__c deputy = new DIR_Employee__c();
        deputy.Name = UserInfo.getName();
        deputy.User__c = UserInfo.getUserId();
        deputy.Position__c = 'Senior Deputy';
        deputy.Title__c = 'Senior Deputy Labor Commissioner';    
        insert deputy;
        
        System.assertEquals(deputy.name, ReceiptLogFormController.getDeputyName(String.valueOf(deputy.Id)));
        
    }
    
    
    static testmethod void testGetFields(){
        ReceiptLogFormController.getFields('Receipt__c','ReceiptFieldSet');
    }
    
}