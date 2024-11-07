/*Name:
 * Description: This is the centralized class to keep the Constants values used throughout the project and need to updated 
 * at one place only to reflect the changes.
 */
public class OWCConstants {		
    public static final String ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID {get 
    {
        List<Profile> listData = [SELECT Id FROM Profile WHERE Name = 'Customer Online Claim User'];
        if(listData != null && listData.size() >0){
            return listData[0].Id;
        } else {
            return null; 
        }
    } set;}
        
    public static final String EMPLOYEE_RELATED_PARTY_RECORD_TYPE_ID = 
        Schema.SObjectType.Related_Party__c.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId();
    public static final String ADVOCATE_RELATED_PARTY_RECORD_TYPE_ID = 
        Schema.SObjectType.Related_Party__c.getRecordTypeInfosByDeveloperName().get('Advocate').getRecordTypeId();
    public static final String EMPLOYER_RELATED_PARTY_RECORD_TYPE_ID = 
        Schema.SObjectType.Related_Party__c.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId();
    public static final String CLAIMANT_RELATED_PARTY_RECORD_TYPE_ID {get 
    {
        return Schema.SObjectType.Related_Party__c.getRecordTypeInfosByDeveloperName().get('Claimant').getRecordTypeId();
        
    } set;}
        
    public static final String PERSON_ACCOUNT_RECORD_TYPE_ID = 
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    public static final String BUSINESS_ACCOUNT_RECORD_TYPE_ID = 
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
    public static final String LAW_FIRM_ACCOUNT_RECORD_TYPE_ID = 
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Law_Firm').getRecordTypeId();
    public static final String WCA_CASE_RECORD_TYPE_ID = 
        Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByDeveloperName().get('WCA').getRecordTypeId();
    public static final String Garment_CASE_RECORD_TYPE_ID = 
    Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByDeveloperName().get('Garment').getRecordTypeId();
    public static final String PRE_DOCKETING_CASE_RECORD_TYPE_ID  {get 
    {
            return Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByDeveloperName().get('Pre_Docketing_Case').getRecordTypeId();
    } set;}
        
    public static final String WCA_CASE_ROLE_RECORD_TYPE_ID = 
        Schema.SObjectType.Case_Role__c.getRecordTypeInfosByDeveloperName().get('WCA').getRecordTypeId();

    public static final String Garment_CASE_ROLE_RECORD_TYPE_ID = 
    Schema.SObjectType.Case_Role__c.getRecordTypeInfosByDeveloperName().get('Garment').getRecordTypeId();
    
    public static string orgWideDefaultId
    {get 
    {
        if(orgWideDefaultId != null){
            return orgWideDefaultId;
        }
        else {
            List<OrgWideEmailAddress> listData = [select Id from OrgWideEmailAddress where Address = 'lconline@dir.ca.gov'];
            if(listData != null && listData.size() >0){
                return listData[0].Id;
            } else {
                return null;
            }
        }
        
    } set;}
    public static string replyToAddress
    {get 
    {
        if(replyToAddress != null){
            return replyToAddress;
        }
        else {
            Online_Claim_email_configuration__c cSet = Online_Claim_email_configuration__c.getValues('ReplyTo');
            if(cSet != null){
                return cSet.ReplyTo__c;
            } else{
                return null;
            }
        }
    } set;}
    public static final String INTEGRATION_USER_ID {get 
    {
        List<User> listData = [SELECT Id FROM User WHERE Name = 'Online Claim'];
        if(listData != null && listData.size() >0){
            return listData[0].Id;
        } else {
            return null;
        }
    } set;}
        
    public static final List<String> personAccountFieldsToCompare = new List<String>{'firstName', 'middleName','lastName','PersonHomePhone','Cell_Phone__c',
        					'PersonBirthdate','PersonEmail','shippingStreet','shippingCity','shippingState','shippingPostalCode'};
                                
    public static final String Garment_Office_Los_Angeles {get 
    {
        List<Office__c> listData = [SELECT Id, Name FROM Office__c where Name = 'Los Angeles GARMENT' limit 1];
        if(listData != null && listData.size() >0){
            return listData[0].Id;
        } else {
            return null;
        }
    } set;}
    
    /* Apex Trigger constants *********************************/
    public static Boolean FIRST_RUN_ON_ACCOUNT_INSERT = true;
    public static Boolean FIRST_RUN_ON_ACCOUNT_UPDATE = true;
    public static Boolean FIRST_RUN_ON_SMS_CONSENT_INSERT = true;
    public static Boolean FIRST_RUN_ON_SMS_CONSENT_UPDATE = true;
    public static Boolean STOP_TRIGGER_ON_CONSENT_UPDATE = false;
}