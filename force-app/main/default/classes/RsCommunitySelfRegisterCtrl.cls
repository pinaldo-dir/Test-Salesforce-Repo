public class RsCommunitySelfRegisterCtrl {
    private map<String, String> values;

    

    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean verified { get; private set; }
    private String privateKey;
    // The API endpoint for the reCAPTCHA service
    private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify';
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
    public static String recaptchaSecretKey = '6LftnNsaAAAAAI8IiySL5eTfN_MIhevenuugg2rW';
    //public static String recaptchaSecretKey = '6LfD604UAAAAAAyj2VzMcyUP0bbYj20zZ_vSiPdg';// private key
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
        System.debug('request body' + request);
        System.debug('response body' + response.getBody());
        if (response.getStatusCode() == 200) {
            System.debug('after resonse body'+ response.getBody());
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if (result.containsKey('success') && result.get('success') == true) { 
                if (result.containsKey('score')) 
                { String action = (String)result.get('action'); 
                Decimal threshold = .4; 
                Decimal score = (Decimal)result.get('score'); 
                if (score > threshold) {return 'Success - v3';
                    }
                } else {
                    system.debug('entry V2');
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

                                   DateTime currentTime = System.now();
                                   Long timeInMili = currentTime.getTime()/1000; 
                                       //system.debug('checkValue'+checkValue);
                                       //System.debug('firstname:: '+firstName);
                                       //System.debug('lastname:: '+lastName);
                                       //System.debug('email:: '+email);
                                      //System.debug('confirmEmail:: '+confirmEmail);
                                       //System.debug('phone:: '+phone); 
                                                                             
                                      Savepoint sp = Database.setSavepoint();
                                      //String success = getValueFromJson(responseBody, 'success');
                                      ResultWrapper result = new ResultWrapper();
                                        Account accObj =  new Account();
                                       Map<String, String> accountData = new Map<String, String>();
                                      String address = '';
                                      String accountId = '';
                                      if(firstName != Null && lastName != Null && (email != Null || phone != Null)){
                                          System.debug('firstname lastname email Not Null');
                                          List<User> existingUser = [SELECT Id FROM User WHERE username =: email];   
  
                                              //create account for user
                                              string rt = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
                                              accObj.RecordTypeId = rt;
                                              accObj.LastName = lastName;
                                              accObj.FirstName = firstName;
                                              accObj.MiddleName = MiddleName;
                                              accObj.PersonEmail = email;
                                              accObj.Cell_Phone__c = Phone;
                                          }
         
                                           String nkName = email.substringBefore('@')+timeInMili;
                                      
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
                                            
                                                                         
                                      
                                      User u = new User();
                                      u.Username = email + CommunitySuffix;
                                      u.CommunityNickname = nkName;
                                      u.Email = email;
                                      u.FirstName = firstName;
                                      u.LastName = lastName;
                                      u.Phone = phone;
                                                                           
                                          String userId;
                                          try {
                                              userId = Site.createExternalUser(u, accountId, null); //password
                                              
                                              //String id = System.UserManagement.initSelfRegistration(Auth.VerificationMethod.Email, u);
                                             /* Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                                              String[] sendingTo = new String[]{'DIRSalesforceSupportTeam@dir.ca.gov'};
                                                  semail.setToAddresses(sendingTo);
                                              semail.setSubject('Community Success Registration '+CommunitySuffix);
                                              semail.setPlainTextBody('UserId::: '+userId);
                                              Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); */
                                          } catch(Site.ExternalUserCreateException ex) {
                                              Database.rollback(sp);
                                              Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                                              String[] sendingTo = new String[]{'DIRSalesforceSupportTeam@dir.ca.gov'};
                                              semail.setToAddresses(sendingTo);
                                              semail.setSubject('Community Error '+CommunitySuffix);
                                              semail.setPlainTextBody(ex.getMessage()+' '+email);
                                              Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
                                              List<String> errors = ex.getDisplayMessages();
                                              String errorMsg = '';
                                              for (String error : errors)  {
                                                  errorMsg += error +'\n';
                                              }
                                              result.isError = true;
                                              result.errorMessage = errorMsg;
                                              if(ex.getMessage().contains('User already exists')){
                                                  result.errorMessage = System.Label.OWC_SelfRegister_Email_Already_Exist ;
                                              }
                                              
                                              // This message is used for debugging. Do not display this in the UI to the end user.
                                              // It has the information around why the user creation failed.
                                              System.debug(ex.getMessage());
                                          }
                                          
                                          if (userId != null) { 
                                              result.PageName = 's/CheckPasswordResetEmail';
                                              result.isError = false;
                                          }
                                          System.debug('result::'+result);
                                     
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