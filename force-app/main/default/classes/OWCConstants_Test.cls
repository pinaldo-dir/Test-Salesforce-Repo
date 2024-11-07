@isTest
public class OWCConstants_Test {
    @istest
    public static void testWithSettingData(){
        //create custom setting records
        Online_Claim_email_configuration__c cSet = new Online_Claim_email_configuration__c();
        cSet.Name = 'ReplyTo';   
        cSet.ReplyTo__c = 'Salesforce@jkahdjsfhalkfjkfdjabfjkfuiafafjbahfbiueembwheb'; 
        insert cSet;
        String ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID = OWCConstants.ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID;
        String EMPLOYEE_RELATED_PARTY_RECORD_TYPE_ID = OWCConstants.EMPLOYEE_RELATED_PARTY_RECORD_TYPE_ID;
        String ADVOCATE_RELATED_PARTY_RECORD_TYPE_ID = OWCConstants.ADVOCATE_RELATED_PARTY_RECORD_TYPE_ID;
        String EMPLOYER_RELATED_PARTY_RECORD_TYPE_ID = OWCConstants.EMPLOYER_RELATED_PARTY_RECORD_TYPE_ID;
        String CLAIMANT_RELATED_PARTY_RECORD_TYPE_ID = OWCConstants.CLAIMANT_RELATED_PARTY_RECORD_TYPE_ID;
        String PERSON_ACCOUNT_RECORD_TYPE_ID = OWCConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
        String BUSINESS_ACCOUNT_RECORD_TYPE_ID = OWCConstants.BUSINESS_ACCOUNT_RECORD_TYPE_ID;
        String LAW_FIRM_ACCOUNT_RECORD_TYPE_ID = OWCConstants.LAW_FIRM_ACCOUNT_RECORD_TYPE_ID;
        String WCA_CASE_RECORD_TYPE_ID = OWCConstants.WCA_CASE_RECORD_TYPE_ID;
        String PRE_DOCKETING_CASE_RECORD_TYPE_ID = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
        String WCA_CASE_ROLE_RECORD_TYPE_ID = OWCConstants.WCA_CASE_ROLE_RECORD_TYPE_ID;
        String orgWideDefaultId = OWCConstants.orgWideDefaultId;
        OWCConstants.orgWideDefaultId = 'sdjfhasjfkdhajfdjkafjk';
        orgWideDefaultId = OWCConstants.orgWideDefaultId;
        String replyToAddress = OWCConstants.replyToAddress;
        OWCConstants.replyToAddress = 'sdjfhasjfkdhajfdjkafjk';
        replyToAddress = OWCConstants.replyToAddress;
        String INTEGRATION_USER_ID = OWCConstants.INTEGRATION_USER_ID;  
        List<String> personAccountFieldsToCompare = OWCConstants.personAccountFieldsToCompare;
    }
    @istest
    public static void testWithSettingNoData(){
        
        String ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID = OWCConstants.ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID;
        String EMPLOYEE_RELATED_PARTY_RECORD_TYPE_ID = OWCConstants.EMPLOYEE_RELATED_PARTY_RECORD_TYPE_ID;
        String ADVOCATE_RELATED_PARTY_RECORD_TYPE_ID = OWCConstants.ADVOCATE_RELATED_PARTY_RECORD_TYPE_ID;
        String EMPLOYER_RELATED_PARTY_RECORD_TYPE_ID = OWCConstants.EMPLOYER_RELATED_PARTY_RECORD_TYPE_ID;
        String CLAIMANT_RELATED_PARTY_RECORD_TYPE_ID = OWCConstants.CLAIMANT_RELATED_PARTY_RECORD_TYPE_ID;
        String PERSON_ACCOUNT_RECORD_TYPE_ID = OWCConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
        String BUSINESS_ACCOUNT_RECORD_TYPE_ID = OWCConstants.BUSINESS_ACCOUNT_RECORD_TYPE_ID;
        String LAW_FIRM_ACCOUNT_RECORD_TYPE_ID = OWCConstants.LAW_FIRM_ACCOUNT_RECORD_TYPE_ID;
        String WCA_CASE_RECORD_TYPE_ID = OWCConstants.WCA_CASE_RECORD_TYPE_ID;
        String PRE_DOCKETING_CASE_RECORD_TYPE_ID = OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID;
        String WCA_CASE_ROLE_RECORD_TYPE_ID = OWCConstants.WCA_CASE_ROLE_RECORD_TYPE_ID;
        String orgWideDefaultId = OWCConstants.orgWideDefaultId;
        String replyToAddress = OWCConstants.replyToAddress;
        String INTEGRATION_USER_ID = OWCConstants.INTEGRATION_USER_ID;  
        List<String> personAccountFieldsToCompare = OWCConstants.personAccountFieldsToCompare;
    }
}