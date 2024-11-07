@isTest
public class OWCLightningLoginFormController_Test {
    @isTest static void LightningLoginFormControllermethodTest0(){
          //Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = 'oc' LIMIT 1];

       //String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
        Account acc = new Account();
		acc.Name ='mecrin';
		acc.sic = '12345';
		insert acc;
         Test.startTest();
       OWCLightningLoginFormController.getAuthConfig();
        OWCLightningLoginFormController.setExperienceId('zxcvbnm');
        OWCLightningLoginFormController.getForgotPasswordUrl();
        OWCLightningLoginFormController.getIsSelfRegistrationEnabled();
        OWCLightningLoginFormController.getSelfRegistrationUrl();
        OWCLightningLoginFormController.getIsUsernamePasswordEnabled();
        OWCLightningLoginFormController oLogin = new OWCLightningLoginFormController();
        OWCLightningLoginFormController.login(acc.Name,acc.sic,'communityUrl');
       Test.stopTest();
   
    }

}