@IsTest(SeeAllData = true)
public with sharing class RSLightningLoginFormControllerTest {
    
    @IsTest
    static void RSLightningLoginFormControllerInstantiation() {
        RSLightningLoginFormController controller = new RSLightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, RSLightningLoginFormController.getIsUsernamePasswordEnabled());
    }
    
    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, RSLightningLoginFormController.getIsSelfRegistrationEnabled());
    }
    
    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, RSLightningLoginFormController.getSelfRegistrationUrl());
    }
    
    @IsTest
    static void testGetForgotPasswordUrl() {
        String url = RSLightningLoginFormController.getForgotPasswordUrl();
        System.assertEquals(null, url);
    }
    
    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = RSLightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
    
    @IsTest
    static void testSetExperienceId() {
        String xId = RSLightningLoginFormController.setExperienceId('12345');
        System.assertNotEquals(null, xId);
    }
    
    @IsTest
    static void testLogin() {
        // call method with unexistant username
        
        String username = 'testuser123@dir.ca.gov'; 
        String password = 'abc123';
        String startUrl = 'https://regsvcstd-mycadir.cs32.force.com/registrations/s/';
        String loggedIn = RSLightningLoginFormController.login(username, password, starturl);
        System.assertEquals(null, loggedIn);
        
        // create user
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Alias = 'tstu';
        u.Username = 'testuser123@dir.ca.gov';
        u.Email = 'testuser123@dir.ca.gov';
        u.CommunityNickname = 'testuser123';
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        loggedIn = RSLightningLoginFormController.login(u.Username, password, StartUrl);
        System.assertEquals(null, loggedIn);
    }
}