@isTest
public class owcNewWageIntakeFormController_Test{
    static testMethod void Test(){  
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
      
        Trigger_Settings__c caseTriggerSetting = new Trigger_Settings__c(
            Name = 'CaseManagementHistoryConfig',
            Is_Active__c = false
        );
        triggerSettings.add(caseTriggerSetting);

        Trigger_Settings__c caseRoleTriggerSetting = new Trigger_Settings__c(
            Name = 'CaseRoleAll',
            Is_Active__c = false
        );
        triggerSettings.add(caseRoleTriggerSetting);
        
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
            );
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
        
        Trigger_Settings__c dlrs_Related_PartyTriggersetting = new Trigger_Settings__c(
            Name = 'dlrs_Related_PartyTrigger',
            Is_Active__c = false
        );
        triggerSettings.add(dlrs_Related_PartyTriggersetting);
        insert triggerSettings;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND DeveloperName = 'WCA' AND IsActive = true LIMIT 1];
        
        Id wcaOfficeRtId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        
        Office__c office = new Office__c(
            Name = 'Lucian832474',
            RecordTypeId = wcaOfficeRtId
        );
        insert office;

        Office__c oosOffice = new Office__c(
            Name = 'WCA Out of State',
            RecordTypeId = wcaOfficeRtId
        );
        insert oosOffice;

        Zip_Code__c zip00000 = new Zip_Code__c(
            Name = '00000'
        );
        insert zip00000;
        
        Zip_Code__c zip234889 = new Zip_Code__c(
            Name = '234889'
        );
        insert zip234889;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c(
            Zip_Code__c = zip234889.Id,
            Office__c = office.Id
        );
        insert map1;

        Office_Zip_Code_Map__c map2 = new Office_Zip_Code_Map__c(
            Zip_Code__c = zip00000.Id,
            Office__c = oosOffice.Id
        );
        insert map2;
        
        NAICS_Code__c naics = new NAICS_Code__c(
            Name = '666',
            Level__c = '1',
            Naics_Title__c = 'Hot Dogs and Other Cylindrically-Shaped Foods',
            Structure_Order__c = 1
        );
        insert naics;

        Account mainA = new Account();
        mainA.Name = 'name';
        mainA.ShippingPostalCode = '234889';
        mainA.NAICS_Code__c = naics.Id;
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        affA.NAICS_Code__c = naics.Id;
        insert affA;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
        c.Docketing_Staff__c='Morfine';
        c.Date_Case_Received__c=  Date.newInstance(2016, 12, 9);
        c.Intake_Origin__c='Online';
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
        cr.Reason_No_Longer_Active__c = 'It\'s no longer active on case, duh.';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        
        cr.Role__c = 'Owner';
        update cr;
        List<DIR_Case__c>d=new List<DIR_Case__c>();
        c.Status__c = 'Not Confirmed';
        d.add(c);
        update d;        
     	 Profile profileId = [SELECT Id FROM Profile WHERE Name = 'WCA User' LIMIT 1];

        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JAS',
                           Alias = 'jliv',
                           Email = 'javeston@asdf.com',
                           Username = 'jasonston@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
            
        Blob bodyBlob=Blob.valueOf('Unit'); 
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Sample', 
            PathOnClient ='Title.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                        FROM ContentVersion WHERE Id = :contentVersion_1.Id AND Title = 'Sample' LIMIT 1];
        
        /* ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = affA.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;*/
        
        string intakedata='{"yourselfFirstName":"Dishant","yourselfLastName":"Yadav","yourselfHomePhone":"1234567890",' +
            '"yourselfCellPhone":"1234567811","countryCodeyourselfCellPhone":"+1","countryCodeyourselfHomePhone":"+1",' +
            '"yourselfBirthDate":"2021-11-01","yourselfEmail":"demo@demo.com","yourselfStreetAddress":"UnKnown",' +
            '"yourselfCity":"New Delhi","yourselfState":"CA","yourselfZipCode":"11005","needLanguageInterpreter":"Yes",' +
            '"isPrefferedLanguage":true,"isOtherPrefferedLanguage":true,"prefferedLanguageSelection":"Other","otherPrefferedLanguage":"Sanskrit",' +
            '"caseRecDate":"2021-11-15","workLocationZipCode":"246762","intakeOrigin":"Fax","dockingDate":"2021-11-16T09:36:53.800Z",' +
            '"name":"Vikas Singh","recordId":"'+affA.Id +'","employerName":"pu ja","isAdditionalClaimDocUpload":false,"additonalClaimDocSize":1}';
        string addDocdata='[{"name":"abc.png","documentId":"'+contentVersion_2.contentdocumentid+'","contentVersionId":"'+contentVersion_2.Id+'"}]';
           
        Test.startTest();
        String accId = [SELECT Id from Account LIMIT 1].Id;
        owcNewWageIntakeFormController.getRelatedAccount(accId);
        owcNewWageIntakeFormController.employerData(affA.Id);
        owcNewWageIntakeFormController.intakeOrigin();
        owcNewWageIntakeFormController.search('name','Account');
        owcNewWageIntakeFormController.empDetails();
        //owcNewWageIntakeFormController.mainMethod(intakedata,mainA.Id,addDocdata);
        owcNewWageIntakeFormController.mainMethod(intakedata,'',addDocdata);
            
        Test.stopTest();
    }    
}