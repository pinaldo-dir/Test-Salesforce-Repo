public class OWCDuplicateAccountHanlder {
    public static String personAccountRTid = OWCConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
    public static void sendDuplicateOnInsert(List<Account> accList){
        sendEmailNotification(accList, false);
    }
    public static void sendDuplicateOnUpdate(List<Account> accList){
        sendEmailNotification(accList, true);
    }
    public static void sendEmailNotification(List<Account> accList, Boolean isUpdate){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        sendTo.add('MergeRequest@dir.ca.gov');
       //sendTo.add('vikas@cloudsciencelabs.com');
        //sendTo.add('akash.som@cloudsciencelabs.com');
        List<Account> duplicateAcc = new List<Account>();
        if(isUpdate){
            //commented full addres as per Jira 
            /*AND
                                   ShippingCity =: accList[0].ShippingCity
                                   AND
                                   ShippingCountry =: accList[0].ShippingCountry
                                   AND
                                   ShippingPostalCode =: accList[0].ShippingPostalCode
			*/
            if(accList[0].recordTypeId == personAccountRTid){
                duplicateAcc = [SELECT Id, Name FROM Account WHERE 
                                ( (FirstName =: accList[0].FirstName AND LastName =: accList[0].LastName AND recordTypeId =: personAccountRTid )
                                 AND
                                 ((ShippingStreet =: accList[0].ShippingStreet
                                   AND ShippingStreet != null) 
                                  OR (PersonBirthdate =: accList[0].PersonBirthdate  AND PersonBirthdate != null)
                                  OR (Phone =: accList[0].Phone AND Phone != null) )
                                  AND Id != : accList[0].Id )
                                 ];
            } else {
                duplicateAcc = [SELECT Id, Name FROM Account WHERE 
                                      ( (Name =: accList[0].Name AND recordTypeId !=: personAccountRTid)
                                       AND
                                       ShippingStreet =: accList[0].ShippingStreet
                                       AND ShippingStreet != null
                                       AND Id != : accList[0].Id )
                                     ];
            }
            
        } else {
            if(accList[0].recordTypeId == personAccountRTid){
                duplicateAcc  = [SELECT Id, Name FROM Account WHERE 
                                 ( (FirstName =: accList[0].FirstName AND LastName =: accList[0].LastName AND recordTypeId =: personAccountRTid )
                                  AND
                                  ((ShippingStreet =: accList[0].ShippingStreet
                                   AND ShippingStreet != null) 
                                   OR (PersonBirthdate =: accList[0].PersonBirthdate  AND PersonBirthdate != null)
                                   OR (Phone =: accList[0].Phone AND Phone != null))
                                  )
                                  
                                  ];
            } 
            else {
                duplicateAcc  = [SELECT Id, Name FROM Account WHERE 
                                      ( (Name =: accList[0].Name AND recordTypeId !=: personAccountRTid)
                                       AND
                                       ShippingStreet =: accList[0].ShippingStreet
                                       AND ShippingStreet != null)
                                     ];
            }
           
        }
           
        System.debug('duplicateAcc ::: '+duplicateAcc.size());
        if(duplicateAcc.size() > 0){
            for(Account sr : AccList){            
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                mail.setToAddresses(sendTo);
                mail.setSubject('Found Duplicate Account(s)');
                String body = 'Hi,' + '<br><br/>';
                body += 'The following duplicate account(s) have been found:';
                body += '<br><br/>';
                for(Integer i=0;i<duplicateAcc.size();i++){
                    body += URL.getSalesforceBaseUrl().toExternalForm() + '/' + duplicateAcc[i].Id  + '<br/>';
                }
                body += '<br/>' + 'Labor Commissioners Office' + '<br/>';
                mail.setHtmlBody(body);
                mails.add(mail);
            }
            Messaging.sendEmail(mails);
        }
    }
}