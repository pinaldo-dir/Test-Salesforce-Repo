@isTest 
public class Test_OWCDuplicateAccountHanlder {
    @testSetup static void methodName() {
        Id personAccountRTid  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Id businessAccountRTid  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(
            	RecordTypeId = personAccountRTid,
        		//Name = 'Demo1',
            	FirstName = 'Person',
            	LastName = '1',
            	ShippingStreet = 'Sample Street es Side Person'
            	//PersonBirthdate = 11/2/2021
          		);
        accList.add(acc1);
        
        Account acc2 = new Account(
            	RecordTypeId = businessAccountRTid,
        		Name = 'business',
            	//FirstName = 'Demo',
            	//LastName = '1',
            	ShippingStreet = 'Sample Street es Side business'
            	//PersonBirthdate = 11/2/2021
          		);
        accList.add(acc2);
        insert accList;
    }
    @isTest
    public static void duplicateCheckOnInsertPerson(){
		Id personAccountRTid  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Id businessAccountRTid  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(
            	RecordTypeId = personAccountRTid,
        		//Name = 'Demo1',
            	FirstName = 'Person',
            	LastName = '1',
            	ShippingStreet = 'Sample Street es Side Person'
            	//PersonBirthdate = 11/2/2021
          		);
        accList.add(acc1);
        //insert accList;
        
        Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        List<Database.SaveResult> sr = Database.insert(accList, dml);
            /*OWCDuplicateAccountHanlder.sendDuplicateOnInsert(accList);
            OWCDuplicateAccountHanlder.sendDuplicateOnUpdate(accList);
         	OWCDuplicateAccountHanlder.sendEmailNotification(accList,false);	*/
        
        Test.stopTest();
    }
    @isTest
    public static void duplicateCheckOnInsertBusiness(){
        Id businessAccountRTid  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        Account acc2 = new Account(
            	RecordTypeId = businessAccountRTid,
        		Name = 'business',
            	//FirstName = 'Demo',
            	//LastName = '1',
            	ShippingStreet = 'Sample Street es Side business'
            	//PersonBirthdate = 11/2/2021
          		);
        accList.add(acc2);
        //insert accList;
        
        Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        List<Database.SaveResult> sr = Database.insert(accList, dml);
            /*OWCDuplicateAccountHanlder.sendDuplicateOnInsert(accList);
            OWCDuplicateAccountHanlder.sendDuplicateOnUpdate(accList);
         	OWCDuplicateAccountHanlder.sendEmailNotification(accList,false);	*/
        
        Test.stopTest();
    }
    @isTest
    public static void duplicateCheckOnUpdatePerson(){
		Id personAccountRTid  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Id businessAccountRTid  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(
            	RecordTypeId = personAccountRTid,
        		//Name = 'Demo1',
            	FirstName = 'Person',
            	LastName = '1',
            	ShippingStreet = 'Sample Street es Side'
            	//PersonBirthdate = 11/2/2021
          		);
        accList.add(acc1);
        insert accList;
        acc1.ShippingStreet = 'Sample Street es Side Person';
        Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        List<Database.SaveResult> sr = Database.update(accList, dml);
        	/*
            OWCDuplicateAccountHanlder.sendDuplicateOnInsert(accList);
            OWCDuplicateAccountHanlder.sendDuplicateOnUpdate(accList);
         	OWCDuplicateAccountHanlder.sendEmailNotification(accList,false);
			*/        
        Test.stopTest();
    }
    @isTest
    public static void duplicateCheckOnUpdateBusiness(){
        Id businessAccountRTid  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
        List<Account> accList = new List<Account>();
        Account acc2 = new Account(
            	RecordTypeId = businessAccountRTid,
        		Name = 'business',
            	//FirstName = 'Demo',
            	//LastName = '1',
            	ShippingStreet = 'Sample Street es Side'
            	//PersonBirthdate = 11/2/2021
          		);
        accList.add(acc2);
        insert accList;
        acc2.ShippingStreet = 'Sample Street es Side business';
        
        Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        List<Database.SaveResult> sr = Database.update(accList, dml);
        Test.stopTest();
        
    }
    
}