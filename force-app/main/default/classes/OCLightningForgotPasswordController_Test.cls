@isTest
public class OCLightningForgotPasswordController_Test {
    static testMethod void testForgotPassword()
    {
          //Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = 'oc' LIMIT 1];

       //String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
        Account acc = new Account();
		acc.Name ='mecrin';
		acc.sic = '12345';
		insert acc;
        
        Test.startTest();
        	OCLightningForgotPasswordController Oc = new OCLightningForgotPasswordController();
            string Forgotpass= OWCLightningLoginFormController.getForgotPasswordUrl();
        	System.debug('Forgotpass:::'+Forgotpass);
            OCLightningForgotPasswordController.forgotPassword(acc.Name,Forgotpass);
         	OCLightningForgotPasswordController.setExperienceId('zxcvbnm');
        	OCLightningForgotPasswordController.setExperienceId(null);
        Test.stopTest();
    }

}