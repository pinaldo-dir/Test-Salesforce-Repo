@isTest
public class OWCClaimantEmployeeInfoControllerTest{
    @testSetup static void setUpMethod() {
        Account demoAccount = new Account();
        demoAccount.Name = 'TestDemo';
        insert demoAccount;
    }
    @istest 
    public static void getCurrentUserDetailsTest(){
        Account getDemoAccount = [SELECT Id, Name, FirstName, LastName, ParentId FROM Account];
        Test.startTest();
        OWCClaimantEmployeeInfoController.claimantDetailObj claimantObj = new OWCClaimantEmployeeInfoController.claimantDetailObj();
        claimantObj.birthDate = System.today().addDays(-20);
        claimantObj.streetAddress = 'test';
        claimantObj.city = 'test';
        claimantObj.state = 'test';
        claimantObj.zipCode = '12345';
        OWCClaimantEmployeeInfoController.claimantDetailObj getDemoAccountRecord = OWCClaimantEmployeeInfoController.getCurrentUserDetails();
        Test.stopTest();
    }
}