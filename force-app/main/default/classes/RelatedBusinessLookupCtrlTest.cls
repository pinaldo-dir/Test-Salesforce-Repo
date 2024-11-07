@isTest
public class RelatedBusinessLookupCtrlTest {
    @isTest public static void onGoTest(){
        List<Account> accountList = DIRDataFactory.createAccount();
        PageReference pageRef = Page.RelatedBusinessLookup;
        Related_Businesses__c relatedBusiness = DIRDataFactory.relatedBusinessesRecord('Test Account - BPAAS',accountList);
        DIR_Case__c caseManagement = DIRDataFactory.createCaseManagement(accountList[0].id);
        pageRef.getParameters().put('rbname',relatedBusiness.Name);
        pageRef.getParameters().put('bid',relatedBusiness.Id);
        pageRef.getParameters().put('casemgtid',caseManagement.Id);
        pageRef.getParameters().put('name',accountList[0].Name);
        Test.setCurrentPage(pageRef);
        RelatedBusinessLookupCtrl controller = new RelatedBusinessLookupCtrl();
        Test.startTest();
        PageReference returnValue =controller.onGo();
        Test.stopTest();
        System.assert(returnValue == null);
    }
}