public with sharing class OWCClaimantEmployeeInfoController {
    @AuraEnabled(Cacheable=true)
    public static claimantDetailObj getCurrentUserDetails(){
        try {
            User currentUser = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId() limit 1];
            System.debug('currentUserAccountId ::: '+currentUser.AccountId);
            User accObj = [SELECT Id, LastName, FirstName, MiddleName, Phone, Email FROM User LIMIT 1];
            claimantDetailObj claimantObj = new claimantDetailObj();
            claimantObj.firstName = accObj.FirstName;
            claimantObj.lastName = accObj.LastName;
            claimantObj.middleName = accObj.MiddleName;
            //claimantObj.birthDate = accObj.PersonBirthdate;
            claimantObj.cellPhone = accObj.Phone;
            claimantObj.homePhone = accObj.Phone;
            claimantObj.email = accObj.Email;
            //claimantObj.streetAddress = accObj.PersonMailingStreet;
            //claimantObj.city = accObj.PersonMailingCity;
            //claimantObj.state = accObj.PersonMailingState;
            //claimantObj.zipCode = accObj.PersonMailingPostalCode;
            System.debug('claimantObj :::: '+claimantObj);
            return claimantObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Wrapper class to store values of claimant account
    public class claimantDetailObj{
        @AuraEnabled
        public String firstName {get;set;}
        @AuraEnabled
        public String middleName {get;set;}
        @AuraEnabled
        public String lastName {get;set;}
        @AuraEnabled
        public Date birthDate {get;set;}
        @AuraEnabled
        public String cellPhone {get;set;}
        @AuraEnabled
        public String homePhone {get;set;}
        @AuraEnabled
        public String email {get;set;}
        @AuraEnabled
        public String streetAddress {get;set;}
        @AuraEnabled
        public String city {get;set;}
        @AuraEnabled
        public String state {get;set;}
        @AuraEnabled
        public String zipCode {get;set;}
    }
}