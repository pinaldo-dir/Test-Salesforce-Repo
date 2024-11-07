@isTest
public class RsLightningForgotPasswordControllerTest {
   
        static testMethod void testForgotPassword()
        {
              //Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = 'oc' LIMIT 1];
    
           //String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
            Account acc = new Account();
            acc.Name ='mecrin';
            acc.sic = '12345';
            insert acc;
            
            Test.startTest();
                RSLightningForgotPasswordController Rs = new RSLightningForgotPasswordController();
                string Forgotpass= RSLightningLoginFormController.getForgotPasswordUrl();
                System.debug('Forgotpass:::'+Forgotpass);
                RSLightningForgotPasswordController.forgotPassword(acc.Name,Forgotpass);
                RSLightningForgotPasswordController.setExperienceId('zxcvbnm');
                RSLightningForgotPasswordController.setExperienceId(null);
            Test.stopTest();
        }

    
}