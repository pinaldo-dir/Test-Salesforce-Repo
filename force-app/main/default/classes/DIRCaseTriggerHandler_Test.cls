@isTest
public class DIRCaseTriggerHandler_Test {
    
    
    static testMethod void testDirCaseTrigger()
    {
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        insert triggerSettings;
        
        OwcVioltaionController.vtMap();
        Record_Type_Mapping__c custSet=new Record_Type_Mapping__c();
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        custset.Case_Rec_Type__c='BOFE_Investigation';
        custset.Name='BOFE';
        custset.Violation_Type_Rec_Type__c='BOFE';
        insert custset;
        
        Office__c office = new Office__c();
        office.Name = 'WCA - OUT OF STATE';
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '234889';
        insert zip;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
        map1.Zip_Code__c = zip.Id;
        map1.Office__c = office.Id;
        insert map1;
        
        Account mainA = new Account();
        mainA.Name = 'name';
        mainA.ShippingPostalCode = '10019';
        mainA.ShippingCity = 'New York';
        mainA.ShippingState = 'CA';
        mainA.ShippingStreet = 'P.O. Box 542026 test';
        //mainA.ShippingAddress = 'P.O. Box 542026 test New York, CA 10019';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert affA;
        
        Address__c locObj = new Address__c();
        locObj.Address__c = 'P.O. Box 542026 test';
        locObj.City__c = 'New York';
        locObj.State__c = 'CA';
        locObj.Zip_Code__c = '100191232';
        locObj.Type__c = 'Home';
        locObj.Active_Location__c = true;
        locObj.Entity__c = mainA.Id;
        insert locObj;
        
     
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Case_Accepted__c = false;
        c.Office__c = office.Id;
        c.Work_Location__c = locObj.Id;
        c.Status__c = 'Not Confirmed';
        c.Purge_Date__c = Date.Today();
        c.RecordTypeId =caseRecordTypeId ;
        insert c;
        
        /*Report_Of_Labor_Code_Violation__c reportViolationObj = new Report_Of_Labor_Code_Violation__c();
        reportViolationObj.Case_Accepted__c = true;
        reportViolationObj.DIR_Case__c = c.Id;
        insert reportViolationObj;*/
        
        Address__c addObj = new Address__c();
        addObj.Entity__c = affA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        insert addObj;
        
        Report_of_Labor_Code_Violation__c reportVObj = new Report_of_Labor_Code_Violation__c();
        reportVObj.Account__c = affA.Id;
        reportVObj.DIR_Case__c = c.Id;
        insert reportVObj;
        
        Associated_Agents__c agent =new Associated_Agents__c();
        agent.Account__c=mainA.Id;
        agent.Type__c='Attorney';
        agent.Associated_Account__c=affA.Id;
        agent.Relationship_Status__c=true;
        insert agent;
        
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = affA.Id;
        relatedBusinessObj.Related_Business__c = mainA.Id;
        relatedBusinessObj.Type__c = 'Alter Ego';
        relatedBusinessObj.Case_Management_Id__c=c.Id;
        insert relatedBusinessObj;
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = c.Id;
        System.debug(c.Id);
        cr.Entity__c = affA.Id;
        cr.Role__c = 'Advocate';
        cr.Case_Role_Status__c = 'Active';
        cr.Reason_No_Longer_Active__c='longer active';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        cr.Role__c = 'Owner';
        update cr;
        List<DIR_Case__c>d=new List<DIR_Case__c>();
        c.Status__c = 'Closed';
        //c.Case_accepted__c = true;
        c.Closure_Disposition__c = 'Lack of Jurisdiction - Other';
        d.add(c);
        update d;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            
            delete c;
        }
       
        
        DIRCaseTriggerHandler.deleteOWCDraftJson(d);
    }
    
    static testMethod void testDirCaseTrigger1()
    {
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        insert triggerSettings;
        
        OwcVioltaionController.vtMap();
        Record_Type_Mapping__c custSet=new Record_Type_Mapping__c();
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        custset.Case_Rec_Type__c='BOFE_Investigation';
        custset.Name='BOFE';
        custset.Violation_Type_Rec_Type__c='BOFE';
        insert custset;
        
        Office__c office = new Office__c();
        office.Name = 'Lucian832474';
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '234889';
        insert zip;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
        map1.Zip_Code__c = zip.Id;
        map1.Office__c = office.Id;
        insert map1;
        
        Account mainA = new Account();
        mainA.Name = 'name';
        mainA.ShippingPostalCode = '234889';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert affA;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = affA.Id;
        c.Status__c = 'New';
        c.RecordTypeId =caseRecordTypeId ;
        insert c;
        
        
        Address__c addObj = new Address__c();
        addObj.Entity__c = affA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        insert addObj;
        
        Associated_Agents__c agent =new Associated_Agents__c();
        agent.Account__c=mainA.Id;
        agent.Type__c='Attorney';
        agent.Associated_Account__c=affA.Id;
        agent.Relationship_Status__c=true;
        insert agent;
        
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = affA.Id;
        relatedBusinessObj.Related_Business__c = mainA.Id;
        relatedBusinessObj.Type__c = 'Alter Ego';
        relatedBusinessObj.Case_Management_Id__c=c.Id;
        insert relatedBusinessObj;
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = c.Id;
        System.debug(c.Id);
        cr.Entity__c = affA.Id;
        cr.Role__c = 'Employer';
        cr.Case_Role_Status__c = 'No Longer Active On Case';
        cr.Reason_No_Longer_Active__c='its no longer active on case';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        Report_of_Labor_Code_Violation__c report =new Report_of_Labor_Code_Violation__c();
        report.DIR_Case__c =c.Id;
        report.Account__c=affA.Id;
        insert report;
        
        
        
        cr.Role__c = 'Owner';
        update cr;
        List<DIR_Case__c>d=new List<DIR_Case__c>();
        c.Status__c = 'Not Confirmed';
        d.add(c);
        update d;
        DIRCaseTriggerHandler.deleteOWCDraftJson(d);
    }
    
    @IsTest
    public static void testSendOfficeChangeEmailAlertForNegative(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        insert triggerSettings;
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        
        Account mainA = new Account();
        mainA.Name = 'name';
        mainA.ShippingPostalCode = '234889';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert affA;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId =caseRecordTypeId ;
        insert c;
        
        Related_Party__c relatedPartyObj = new Related_Party__c();
        relatedPartyObj.Account__c = mainA.id;
        relatedPartyObj.Case_Management__c = c.Id;
        relatedPartyObj.Role__c = 'Advocate';
        relatedPartyObj.Email__c = 'test@gmail.com';
        insert relatedPartyObj;
        
        Test.startTest();
        DIRCaseTriggerHandler.sendOfficeChangeEmailAlert(c);
        Test.stopTest();
    }
    
    @IsTest
    public static void testSendOfficeChangeEmailAlert(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        insert triggerSettings;
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        
        Account mainA = new Account();
        mainA.Name = 'name';
        mainA.ShippingPostalCode = '234889';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert affA;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId =caseRecordTypeId ;
        insert c;
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = c.Id;
        cr.Entity__c = mainA.Id;
        cr.Role__c = 'Advocate';
        cr.Case_Role_Status__c = 'No Longer Active On Case';
        cr.Reason_No_Longer_Active__c='its no longer active on case';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        Related_Party__c relatedPartyObj = new Related_Party__c();
        relatedPartyObj.Account__c = mainA.id;
        relatedPartyObj.Case_Management__c = c.Id;
        relatedPartyObj.Role__c = 'Advocate';
        relatedPartyObj.Email__c = 'test@gmail.com';
        insert relatedPartyObj;
        
        Test.startTest();
        DIRCaseTriggerHandler.sendOfficeChangeEmailAlert(c);
        Test.stopTest();
    }
    
    private static testMethod void testUpdateCase(){
        Record_Type_Mapping__c custSet=new Record_Type_Mapping__c();
        
        custset.Case_Rec_Type__c='BOFE_Investigation';
        custset.Name='BOFE';
        custset.Violation_Type_Rec_Type__c='BOFE';
        custset.Office_Rec_Type__c ='BOFE';
        insert custset;
        
        Trigger_Settings__c ts = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        insert ts;
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        
        Office__c office = new Office__c();	 
        office.Name = 'Lucian832474';
        office.RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '23488';
        insert zip;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
        map1.Zip_Code__c = zip.Id;
        map1.Office__c = office.Id;
        insert map1;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '23488';
        insert acc;
        
        test.startTest();
        
        //BOFE Intake Case(Status = New)
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRecordTypeId;
        insert c;
        
        DIR_Case__c c2 = [SELECT Id, Office__c FROM DIR_Case__c WHERE Id =: c.Id];
        system.assertEquals(office.Id, c2.Office__c);
        
        test.stopTest();
    }

    private static testMethod void testUpdateCaseReferToJEU(){
        Record_Type_Mapping__c custSet=new Record_Type_Mapping__c();
        
        custset.Case_Rec_Type__c='BOFE_Investigation';
        custset.Name='BOFE';
        custset.Violation_Type_Rec_Type__c='BOFE';
        custset.Office_Rec_Type__c ='BOFE';
        
        insert custset;
        
        Trigger_Settings__c ts = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        insert ts;
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        
        Office__c office = new Office__c();
        office.Name = 'Lucian832474';
        office.RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '23488';
        insert zip;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
        map1.Zip_Code__c = zip.Id;
        map1.Office__c = office.Id;
        insert map1;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '23488';
        insert acc;
        
        test.startTest();
        
        //BOFE Intake Case(Status = New)
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRecordTypeId;
        c.Refer_to_JEU__c = 'Referred';
        insert c;
        
        DIR_Case__c c2 = [SELECT Id, Office__c FROM DIR_Case__c WHERE Id =: c.Id];
        system.assertEquals(office.Id, c2.Office__c);
        
        test.stopTest();
    }

    private static testMethod void testUpdateCaseExistingEmployer(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        insert triggerSettings;
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        
        Office__c office = new Office__c();
        office.Name = 'Lucian832474';
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '234889';
        insert zip;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
        map1.Zip_Code__c = zip.Id;
        map1.Office__c = office.Id;
        insert map1;
        
        Account acc1 = new Account();
        acc1.Name = 'name';
        acc1.ShippingPostalCode = '234889';
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'name2';
        acc2.ShippingPostalCode = '234889';
        insert acc2;
        
        //BOFE Intake Case(Status = New)
        DIR_Case__c existingCase = new DIR_Case__c();
        existingCase.Employer__c = acc1.Id;
        existingCase.Status__c = 'New';
        existingCase.RecordTypeId = caseRecordTypeId;
        insert existingCase;
        
        Report_of_Labor_Code_Violation__c rllv = new Report_of_Labor_Code_Violation__c();
        rllv.DIR_Case__c = existingCase.Id;
        rllv.Account__c = acc1.Id;
        insert rllv;

        test.startTest();
        
        existingCase.Employer__c = acc2.Id;
        update existingCase;
        
        rllv.Account__c = acc2.Id;
        update rllv;
		
        //BOFE Intake Case(Status = New)
        DIR_Case__c newCase = new DIR_Case__c();
        newCase.Employer__c = acc2.Id;
        newCase.Status__c = 'New';
        newCase.RecordTypeId = caseRecordTypeId;
        insert newCase;
        

        existingCase = [SELECT Id, Employer__c, Office__c FROM DIR_Case__c WHERE Id =: existingCase.Id];
        newCase = [SELECT Id, Employer__c, Office__c FROM DIR_Case__c WHERE Id =: newCase.Id];
        
        system.debug('existingCase: ' + existingCase);
        system.debug('newCase: ' + newCase);
        system.assertEquals(existingCase.Employer__c, newCase.Employer__c);
        system.assertEquals(existingCase.Office__c, newCase.Office__c);
        
        test.stopTest();
    }
    
    /*
    private static testMethod void testUpdateCaseOwner(){
                
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='alex@testorg.com');
        insert u;
        
        User u2 = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='alexa@testorg.com');
        insert u2;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.Name = 'name';
        de.Position__c = 'Deputy';
        de.User__c = u.Id;
        de.Manager__c = ma.Id;
        insert de;
        
        DIR_Employee__c de2 = new DIR_Employee__c();
        de2.Name = 'name';
        de2.Position__c = 'Deputy';
        de2.User__c = u2.Id;
        de2.Manager__c = ma.Id;
        insert de2;
        
        DIR_Case__c c = new DIR_Case__c();
        c.RecordTypeId = caseRecordTypeId;
        c.Assigned_Deputy__c = de.Id;
        insert c;
        
        c.Assigned_Deputy__c = de2.Id;
        update c;
        
        //DIR_Case__c c2 = [SELECT Id, OwnerId FROM DIR_Case__c WHERE Id =: c.Id];
        //DIR_Employee__c de3 = [SELECT Id, User__c FROM DIR_Employee__c WHERE Id =: de.Id];
        
        
    }
    */
    
    private static testMethod void testUpdateLaborCodeViolations(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        insert triggerSettings;
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        //Id caseRecordTypeId2 = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();

        Key_Value_Store__c kvs = new Key_Value_Store__c();
        kvs.Name = 'BOFE Open Case RT';
        kvs.Value__c = 'BOFE';
        insert kvs;
        
        Profile p = [select id from profile where name='BOFE User'];
        
         User u = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='testuser@ca-dir.com');
        insert u;

        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.Name = 'name';
        de.Position__c = 'Deputy';
        de.User__c = u.Id;
        de.Manager__c = ma.Id;
        
        
        DIR_Employee__c de2 = de.clone();
        insert de2;
        insert de;

        Account acc = new Account();
        acc.Name = 'name';
        Account acc2 = new Account();
        acc2.Name = 'name2';
        Account acc3 = new Account();
        acc3.Name = 'name3';
        insert new List<Account> { acc, acc2, acc3 };
        
        //BOFE Intake Case(Status = New)
        DIR_Case__c c1 = new DIR_Case__c();
        c1.RecordTypeId = caseRecordTypeId;
        c1.Status__c = 'New';
        c1.Employer__c = acc.Id;
        c1.Assigned_Deputy__c = de.Id;
        insert c1;
        
        //BOFE Intake Case(Status = New)
        DIR_Case__c c = new DIR_Case__c();
        c.RecordTypeId = caseRecordTypeId;
        c.Status__c = 'New';
        c.Employer__c = acc.Id;
        c.Assigned_Deputy__c = de.Id;
        
        //BOFE Intake Case(Status = New)
        DIR_Case__c c2 = new DIR_Case__c();
        c2.RecordTypeId = caseRecordTypeId;
        c2.Status__c = 'New';
        c2.Employer__c = acc2.Id;
        c2.Assigned_Deputy__c = de.Id;
        
        //BOFE Investigation(Status = Open)
        DIR_Case__c c3 = new DIR_Case__c();
        c3.RecordTypeId = caseRecordTypeId;
        c3.Status__c = 'Open';
        c3.Employer__c = acc3.Id;
        c3.Assigned_Deputy__c = de.id;
        insert new List<DIR_Case__c> { c, c2, c3 };
           
        
        Report_of_Labor_Code_Violation__c v = new Report_of_Labor_Code_Violation__c();
        v.DIR_Case__c = c.Id;
        v.Account__c = acc.Id;
        v.Source__c = 'Community Group Referral';
        v.Child_Labor_Violations__c = 'No valid work permit(s)';
        v.No_number_of_minors_affected__c = 5;
        Report_of_Labor_Code_Violation__c v2 = new Report_of_Labor_Code_Violation__c();
        v2.DIR_Case__c = c2.Id;
        v2.Account__c = acc2.Id;
        v2.Source__c = 'Community Group Referral';
        v2.Child_Labor_Violations__c = 'No valid work permit(s)';
        v2.No_number_of_minors_affected__c = 5;
        Report_of_Labor_Code_Violation__c v3 = new Report_of_Labor_Code_Violation__c();
        v3.DIR_Case__c = c3.Id;
        v3.Account__c = acc3.Id;
        v3.Source__c = 'Community Group Referral';
        v3.Child_Labor_Violations__c = 'No valid work permit(s)';
        v3.No_number_of_minors_affected__c = 5;
        insert new List<Report_of_Labor_Code_Violation__c> { v, v2, v3 };
        
        test.startTest();
        
        checkRecursive.run2 = true;
        c.Employer__c = acc2.Id;
        update c;
        
        insert new Assignment_History__c(Case_Management__c = c1.id);
        c1.Status__c = 'Closed - No further action';
        update c1;
        
        DIRCaseTriggerHandler.preventDuplicateHistoryCreations = true;
        c1.Status__c = 'Reopened with Senior Approval';
        update c1;

        DIR_Case__c c4 = [SELECT Id FROM DIR_Case__c WHERE Id =: c2.Id];
        Report_of_Labor_Code_Violation__c v4 = [SELECT Id, DIR_Case__c FROM Report_of_Labor_Code_Violation__c WHERE Id =: v.Id];
        //system.assertEquals(v4.DIR_Case__c, c4.Id);

        c3.Employer__c = acc2.Id;
        update c3;
        
        test.stopTest();
    }

    private static testMethod void testUpdateLaborCodeViolations2(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        insert triggerSettings;
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        Id caseRecordTypeId2 = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        
        Key_Value_Store__c kvs = new Key_Value_Store__c();
        kvs.Name = 'BOFE Open Case RT';
        kvs.Value__c = 'BOFE';
        insert kvs;
        
        Profile p = [select id from profile where name='BOFE User'];
        User u = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='testuser1@ca-dir.com');
        insert u;

        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.Name = 'name';
        de.Position__c = 'Deputy';
        de.User__c = u.Id;
        de.Manager__c = ma.Id;
        insert de;
        
        DIR_Employee__c de2 = de.clone();
        insert de2;

        Account acc = new Account();
        acc.Name = 'name';
        Account acc2 = new Account();
        acc2.Name = 'name2';
        Account acc3 = new Account();
        acc3.Name = 'name3';
        insert new List<Account> { acc, acc2, acc3 };
        
        //BOFE Intake Case(Status = New)
        DIR_Case__c c = new DIR_Case__c();
        c.RecordTypeId = caseRecordTypeId;
        c.Status__c = 'New';
        c.Employer__c = acc.Id;
        c.Assigned_Deputy__c = de.Id;
        DIR_Case__c c2 = new DIR_Case__c();
        
        //BOFE Investigation(Status = New)
        c2.RecordTypeId = caseRecordTypeId2;
        c2.Status__c = 'Open';
        c2.Employer__c = acc2.Id;
        c2.Assigned_Deputy__c = de.id;
        DIR_Case__c c3 = new DIR_Case__c();
        c3.RecordTypeId = caseRecordTypeId2;
        
        //BOFE Investigation(Status = New)
        c3.Status__c = 'Open';
        c3.Employer__c = acc3.Id;
        c3.Assigned_Deputy__c = de.id;
        DIRCaseTriggerHandler.preventDuplicateHistoryCreations = true;
        insert new List<DIR_Case__c> { c, c2, c3 };
        
        Report_of_Labor_Code_Violation__c v = new Report_of_Labor_Code_Violation__c();
        v.DIR_Case__c = c.Id;
        v.Account__c = acc.Id;
        v.Source__c = 'Community Group Referral';
        v.Child_Labor_Violations__c = 'No valid work permit(s)';
        v.No_number_of_minors_affected__c = 5;
        Report_of_Labor_Code_Violation__c v2 = new Report_of_Labor_Code_Violation__c();
        
        v2.DIR_Case__c = c2.Id;
        v2.Account__c = acc2.Id;
        v2.Source__c = 'Community Group Referral';
        v2.Child_Labor_Violations__c = 'No valid work permit(s)';
        v2.No_number_of_minors_affected__c = 5;
        Report_of_Labor_Code_Violation__c v3 = new Report_of_Labor_Code_Violation__c();
        
        v3.DIR_Case__c = c3.Id;
        v3.Account__c = acc3.Id;
        v3.Source__c = 'Community Group Referral';
        v3.Child_Labor_Violations__c = 'No valid work permit(s)';
        v3.No_number_of_minors_affected__c = 5;
        
        insert new List<Report_of_Labor_Code_Violation__c> { v, v2, v3 };

        DIR_Inspection__c insp = new DIR_Inspection__c();
        insp.DIR_Case__c = c3.Id;
        insert insp;
        
        test.startTest();
        
        checkRecursive.run2 = true;
        c2.Employer__c = acc3.Id;
        c2.Assigned_Deputy__c = de2.id;
        DIRCaseTriggerHandler.preventDuplicateHistoryCreations = true;
        update c2;
        
        DIR_Case__c c4 = [SELECT Id FROM DIR_Case__c WHERE Id =: c2.Id];
        Report_of_Labor_Code_Violation__c v4 = [SELECT Id, DIR_Case__c FROM Report_of_Labor_Code_Violation__c WHERE Id =: v.Id];
        //system.assertEquals(v4.DIR_Case__c, c4.Id);
        
        
        test.stopTest();
        
        try{
            delete c;
        }
        catch(exception ex){
            
        }
    }
    
    public void testUpdateCaseOwnerManager(){
        Trigger_Settings__c ts = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        insert ts;
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='alex@testorg.com');
        insert u;
        User u2 = new User(alias = 'standt', email='alex2@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='alex2@testorg.com', ManagerId = u.Id);
        insert u2;
        
        Account acc = new Account();
        acc.Name = 'name';
        insert acc;
        
        test.startTest();
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        c.OwnerId = u2.Id;
        insert c;
        
        DIR_Case__c c2 = [SELECT Id, Owner_s_Manager__c FROM DIR_Case__c WHERE Id =: c.Id];
        system.assertEquals(c2.Owner_s_Manager__c, u.Id);
        
        test.stopTest();
    }
    
}