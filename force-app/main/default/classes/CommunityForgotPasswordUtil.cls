public without sharing class CommunityForgotPasswordUtil {
    
    public Boolean isExistingUser(String userName){
        List<User> existingUser = [SELECT Id FROM User WHERE username =: userName];
        if( existingUser.size() == 0 ) {
            return FALSE;
        }
        return TRUE;
    }
}