@istest
public class CommunityPayCreditTest {

    public static testMethod void testCommunityPayCredit(){
        
        
        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
       
        Account acc = new Account(
            Name = 'test acct 123',
            Legal_Entity_Name__c = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
       
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Email='testdirlnr.test@dirlnr.com');
        insert con;  
                  
        
        
        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        id lrRecordTypeId = Schema.sObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeID();
        
        /*DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        ///dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1; */ // commented due to no PAGA code in class
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = acc.Id;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Car Wash';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = con.Id;
        newLR.RecordTypeId = lrRecordTypeID;
        insert newLR;
        
        Fee_Summary__c feeSummary = new Fee_Summary__c();
        feeSummary.Registration__c = newLR.Id;
        insert feeSummary;
        
        Fee__c newFee = new Fee__c();
        newFee.Fee__c = 100;
        newFee.Registration__c = newLR.Id;
        newFee.Fee_Summary__c = feeSummary.Id;
        newFee.Description__c = 'Fee description';
        insert newFee;
        
        ChargentOrders__ChargentOrder__c newChargentOrder = new ChargentOrders__ChargentOrder__c();
        newChargentOrder.ChargentOrders__Payment_Method__c = 'Credit Card';
        newChargentOrder.Registration__c  = newLR.Id;
        newChargentOrder.Fee_Summary__c = feeSummary.Id;
        newChargentOrder.ChargentOrders__Billing_Email__c = newLR.Applicant__r.Email;
        newChargentOrder.ChargentOrders__Subtotal__c = 0;
        insert newChargentOrder;
        
        test.startTest();
            ApexPages.CurrentPage().getParameters().put('id', newChargentOrder.Id);
            CommunityPayCredit CCACH = new CommunityPayCredit();  
            
            CCACH.NextPayment();
            CCACH.CancelPayment();
        test.stopTest();
    }
    
    public static testMethod void testCommunityPayCreditConfirm(){
        
        
        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
       
        Account acc = new Account(
            Name = 'test acct 123',
            Legal_Entity_Name__c = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
       
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Email='testdirlnr.test@dirlnr.com');
        insert con;  
                  
        /*User communityuser = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert communityuser ;*/
        
        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        id lrRecordTypeId = Schema.sObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeID();
        
        /*DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1; */ // commented due to no PAGA code in class
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = acc.Id;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Car Wash';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = con.Id;
        newLR.RecordTypeId = lrRecordTypeID;
        insert newLR;
        
        Fee_Summary__c feeSummary = new Fee_Summary__c();
        feeSummary.Registration__c = newLR.Id;
        insert feeSummary;
        
        Fee__c newFee = new Fee__c();
        newFee.Fee__c = 100;
        newFee.Registration__c = newLR.Id;
        newFee.Fee_Summary__c = feeSummary.Id;
        newFee.Description__c = 'Fee description';
        insert newFee;
        test.startTest();
        ChargentOrders__ChargentOrder__c newChargentOrder = new ChargentOrders__ChargentOrder__c();
        newChargentOrder.ChargentOrders__Payment_Method__c = 'Credit Card';
        newChargentOrder.Registration__c  = newLR.Id;
        newChargentOrder.Fee_Summary__c = feeSummary.Id;
        newChargentOrder.ChargentOrders__Billing_Email__c = newLR.Applicant__r.Email;
        newChargentOrder.ChargentOrders__Subtotal__c = 10;
        insert newChargentOrder;
        
        List<Chargent_Error_Code__mdt> usrMsg = new List<Chargent_Error_Code__mdt>([SELECT MasterLabel, Error_ID__c, Technical_Message__c,User_Message__c 
                                                                                        FROM Chargent_Error_Code__mdt 
                                                                                        ]);        
        //ChargentOrders.TChargentOperations.TChargentResult ChargentResult = ChargentOrders.TChargentOperations.ChargeOrder_Click(newChargentOrder.Id);
        
        
        
            ApexPages.CurrentPage().getParameters().put('id', newChargentOrder.Id);
            CommunityPayCreditConfirm CCACH = new CommunityPayCreditConfirm();  
            CCACH.ChargentOrder = newChargentOrder;
            
            CCACH.ConfirmSubmitPayment();
            CCACH.CancelPayment();
        test.stopTest();
    }
}