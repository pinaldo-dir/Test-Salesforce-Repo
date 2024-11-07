@isTest
public class Test_OWCContainerController {
 @isTest
    public static void test_OWCContainer()
    {
        Test.startTest(); 
        String a=OWCContainerController.changedUserLanguage('es'); 
        OWCContainerController.getLanguagesData();
        String b=OWCContainerController.changedUserLanguage('en_US'); 
        OWCContainerController.getLanguagesData();
        OWCContainerController.getUserCurrentLanguage(true);
       // String c=OWCContainerController.changedUserLanguage(''); 
      
        Test.stopTest();
    }
}