public class RsLightningLoginFormController {
    public RsLightningLoginFormController() {
        
    }
    
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try{
            //Add the community suffix.
          
            list <Key_Value_Store__c> kvs = new list<Key_Value_Store__c>([SELECT Name, Value__c from Key_Value_Store__c]);
                    map<String, String> values = new map<string,string>();
                    String profileID;
                    for ( Key_Value_Store__c k : kvs ){
                        values.put(k.name, k.Value__c);
                    }
                    String CommunitySuffix = '';
                    //Organization myOrg = [SELECT ID, NamespacePrefix FROM Organization];
                    if ( values.ContainsKey('Community UserID Suffix')){
                        CommunitySuffix = values.get('Community UserID Suffix');
                        System.debug('CommunitySuffix '+ CommunitySuffix);
                    }
            ApexPages.PageReference lgn = Site.login(username + CommunitySuffix, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    public static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    } 
}