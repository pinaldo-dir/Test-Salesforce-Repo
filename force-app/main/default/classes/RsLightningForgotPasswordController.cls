public class RsLightningForgotPasswordController {
    public RsLightningForgotPasswordController() {
        
    }
    
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        try {
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
            Site.forgotPassword(username+CommunitySuffix);
            
            
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
            if(!Site.isValidUsername(username)) {
                return Label.Site.invalid_email;
            }
            aura.redirect(checkEmailRef);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
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