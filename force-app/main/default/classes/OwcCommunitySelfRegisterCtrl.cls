public class OwcCommunitySelfRegisterCtrl {
    private map<String, String> values;
    
    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean verified { get; private set; }
    private String privateKey;
    // The API endpoint for the reCAPTCHA service
    public static String cResponse ='';
    
    @AuraEnabled(cacheable= true)
    public static InitializeWrapper initializeComponent(){
        InitializeWrapper wrapper = new InitializeWrapper();
        List<String> pickListValuesList= new List<String>();
        List<userStateWrapper> stateWrapObjList = new List<userStateWrapper>();
		Schema.DescribeFieldResult fieldResult = User.State__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
        
        for(String stateObj : pickListValuesList){
            userStateWrapper stateWrapObj = new userStateWrapper();
        	stateWrapObj.label = stateObj;
            stateWrapObj.value = stateObj;
            stateWrapObjList.add(stateWrapObj);
        }
        wrapper.stateList = stateWrapObjList;
         
        List<Key_Value_Store__c> keyValue =  [SELECT Name, Value__c from Key_Value_Store__c where Name = 'OC Recaptcha Public Key' LIMIT 1];
        wrapper.publicKey = KeyValue != null ? keyValue[0].Value__c : '';
		return wrapper;
    }
    public static boolean checkValue = false;    
    @AuraEnabled
    public static String verifyCaptcha(String recaptchaResponse){
        List<Key_Value_Store__c> keyValue =  [SELECT Name, Value__c from Key_Value_Store__c where Name = 'OC Recaptcha Private Key' LIMIT 1];
        system.Debug(recaptchaResponse);
        cResponse = recaptchaResponse;
        //https://developers.google.com/recaptcha/docs/verify
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        request.setMethod('POST');
        request.setBody('secret=' + (KeyValue != null ? keyValue[0].Value__c : '') + '&response=' + recaptchaResponse);
        HttpResponse response = http.send(request);
		System.debug(response.getBody());
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if (result.containsKey('success') && result.get('success') == true) { if (result.containsKey('score')) { String action = (String)result.get('action'); Decimal threshold = .4; Decimal score = (Decimal)result.get('score'); if (score > threshold) {return 'Success - v3';
                    }
                } else {
                    //TODO: perform action on record
                    checkValue = true;
                    return 'Success - v2';}} else { return 'Invalid Verification';
            }
        }
        //consider letting this through
        return 'Invalid Verification Request';
    }
    @AuraEnabled 
    Public static ResultWrapper createUser(String firstName, String middleName, String lastName, String email, String confirmEmail,
                                  String phone){
                                   
                                      Savepoint sp = Database.setSavepoint();
                                      //String success = getValueFromJson(responseBody, 'success');
                                      ResultWrapper result = new ResultWrapper();
                                        Account accObj =  new Account();
                                       Map<String, String> accountData = new Map<String, String>();
                                      String address = '';
                                      String accountId = '';
                                      if(firstName != Null && lastName != Null && (email != Null || phone != Null)){
                                          List<Account> listOfExistingAccount =[SELECT Id,LastName, FirstName, Phone, PersonEmail,PersonMailingStreet ,(select id from Case_Roles__r) FROM Account
                                                                                where RecordType.name ='Person Account' AND ((FirstName =:firstName AND LastName =:lastName AND PersonEmail =: email) OR
                                                                                                                             (FirstName =:firstName AND LastName =:lastName AND Phone =:phone))
                                                                                ORDER BY lastmodifieddate DESC];
                                          
                                          
                                          Integer count =0;
                                          /**if(address1 != null || address2 != null){
                                              address = address1 + '\n' + address2;
                                          }*/
                                          if(listOfExistingAccount != null && !listOfExistingAccount.isEmpty() && listOfExistingAccount.size() > 1){
                                              System.debug('More Than one Account Found'+listOfExistingAccount.size());
                                              for(Account obj : listOfExistingAccount){
                                                  if(obj.Case_Roles__r != null && obj.Case_Roles__r.size() > count){
                                                      System.debug('Have Case Role');
                                                      count = obj.Case_Roles__r.size(); 
                                                      accObj.Id = obj.Id;
                                                      accountData.put('Id', obj.Id);
                                                      /*accObj.PersonMailingStreet = address;
                                                      accObj.PersonMailingCity = city;
                                                      accObj.PersonMailingPostalCode = postalCode;
                                                      accObj.PersonMailingState = state;
                                                      accountData.put('Id', obj.Id);
                                                      accountData.put('street', address);
                                                      accountData.put('city', city);
                                                      accountData.put('state', state);
                                                      accountData.put('postalCode', postalCode);*/
                                                      //updateAccount(accountData);
                                                      
                                                  } 
                                              }
                                              if(count == 0){
                                                  accObj.Id = listOfExistingAccount[0].Id;
                                                  System.debug('No case role exist');
                                                  // No account has case roll
                                              }
                                          } 
                                          else if(listOfExistingAccount != null && !listOfExistingAccount.isEmpty() && listOfExistingAccount.size() == 1){
                                              for(Account acc : listOfExistingAccount){
                                                  if(acc.PersonMailingStreet != address){
                                                      accObj.Id = acc.Id;
                                                      /*accObj.PersonMailingStreet = address;
                                                      accObj.PersonMailingCity = city;
                                                      accObj.PersonMailingState = state;
                                                      accObj.PersonMailingPostalCode = postalCode;*/
                                                  } else {
                                                      accObj.Id = acc.Id;
                                                  }
                                              }
                                          }
                                          else {
                                              //create account for user
                                              string rt = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
                                              accObj.RecordTypeId = rt;
                                              accObj.LastName = lastName;
                                              accObj.FirstName = firstName;
                                              accObj.MiddleName = MiddleName;
                                              /*accObj.PersonMailingStreet = address1 + '\n' + address2;
                                              accObj.PersonMailingCity = city;
                                              accObj.PersonMailingState = state;
                                              accObj.PersonMailingPostalCode = postalCode;*/
                                              //a.PersonMailingCountry = cUser.Country__c;
                                              accObj.PersonEmail = email;
                                              accObj.Cell_Phone__c = Phone;
                                          }
                                          
                                      } else{
                                          System.debug('firstname lastname email Null');
                                          //create account for user
                                          string rt = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
                                          accObj.RecordTypeId = rt;
                                          accObj.LastName = lastName;
                                          accObj.FirstName = firstName;
                                          accObj.MiddleName = MiddleName;
                                          /*accObj.PersonMailingStreet = address1 + '\n' + address2;
                                          accObj.PersonMailingCity = city;
                                          accObj.PersonMailingState = state;
                                          accObj.PersonMailingPostalCode = postalCode;*/
                                          //a.PersonMailingCountry = cUser.Country__c;
                                          accObj.PersonEmail = email;
                                          accObj.Cell_Phone__c = Phone;
                                      }
                                      upsert accObj;
                                      accountId = accObj.Id;
                                          System.debug('accountId:: '+accountId);
                                      String nkName = ((firstName != null && firstName.length() > 0) ? firstName.substring(0,1) : '' ) + lastName.substring(0,1);
                                      nkName += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
                                      
                                      OWC_Self_Register_Config__mdt  self_Register_config = OWC_Self_Register_Config__mdt.getInstance('Online_Claim_Community');
                                      //System.debug('----->'+self_Register_config.UserName_suffix__c );
                                      
                                      User u = new User();
                                      u.Username = String.isNotBlank(self_Register_config.UserName_suffix__c) ? email + '.'+ self_Register_config.UserName_suffix__c : email;
                                      u.CommunityNickname = nkName;
                                      u.Email = email;
                                      u.FirstName = firstName;
                                      u.LastName = lastName;
                                      u.Phone = phone;
                                      /*u.Street = address1 + '\n' + address2;
                                      u.City = city;
                                      u.State = state;
                                      u.PostalCode = postalCode;*/
                                      // u.state = cUser.State__c;
                                      //u.State__c = cUser.State__c;
                                      
                                          String userId;
                                          try {
                                              userId = Site.createExternalUser(u, accountId, null); //password
                                              
                                          } catch(Site.ExternalUserCreateException ex) {
                                              Database.rollback(sp);
                                              Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                                              String[] sendingTo = new String[]{'DIRSalesforceSupportTeam@dir.ca.gov'};
                                                  semail.setToAddresses(sendingTo);
                                              semail.setSubject('Community Self-Register Error');
                                              semail.setPlainTextBody(ex.getMessage());
                                              List<String> errors = ex.getDisplayMessages();
                                              String errorMsg = '';
                                              for (String error : errors)  {
                                                  errorMsg += error +'\n';
                                              }
                                              result.isError = true;
                                              result.errorMessage = errorMsg;
                                              if(ex.getMessage().contains('User already exists')){
                                                  result.errorMessage = System.Label.OWC_SelfRegister_Email_Already_Exist ;
                                              } else {
                                                  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
                                              }
                                              
                                              // This message is used for debugging. Do not display this in the UI to the end user.
                                              // It has the information around why the user creation failed.
                                              System.debug(ex.getMessage());
                                          }
                                          
                                          if (userId != null) { 
                                              result.PageName = 'OCCheckPasswordResetEmail';
                                              result.isError = false;
                                          }
                                     
                            return result;          
        
    }
    
     /**
* Make request to verify captcha
* @return      response message from google
*/
    public static String makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        
        try {
            Http http = new Http();
            response = http.send(req);
            return response.getBody();
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return '{"success":false}';
    }

    /**
* to get value of the given json string
* @params      
*  - strJson       json string given
*  - field         json key to get the value from
* @return          string value
*/
    public static string getValueFromJson ( String strJson, String field ){
        JSONParser parser = JSON.createParser(strJson);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                if(parser.getText() == field){
                    // Get the value.
                    parser.nextToken();
                    return parser.getText();
                }
            }
        }
        return null;
    }
    
    public class InitializeWrapper{
        @AuraEnabled
        public List<userStateWrapper> stateList;
        @AuraEnabled 
        public String publicKey;
    }
    
    public class ResultWrapper{
        @AuraEnabled
        Public String errorMessage;
        @AuraEnabled
        Public Boolean isError;
        @AuraEnabled 
        Public String pageName;
    }
    
    public class userStateWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled 
        public string value{get;set;}
    }
    
}