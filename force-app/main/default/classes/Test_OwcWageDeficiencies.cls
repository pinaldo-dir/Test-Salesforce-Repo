@isTest
public class Test_OwcWageDeficiencies {
    static testMethod void test_fetchseverancePayOfferedOption()
    {
        OwcWageDeficiencies.fetchseverancePayOfferedOption();
        List<User> userToUpdate = new List<User>();
        for(User acc: [SELECT id, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()]){
            acc.LanguageLocaleKey = 'es';
            userToUpdate.add(acc);
        }
        update userToUpdate;
        OwcWageDeficiencies.fetchseverancePayOfferedOption();
    }
    
}