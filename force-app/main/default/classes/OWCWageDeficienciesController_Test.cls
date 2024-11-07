@isTest
public class OWCWageDeficienciesController_Test {
    @isTest
    public static void getViolationTypeVariablestest()
    {  
        Trigger_Settings__c caseTriggerSetting = new Trigger_Settings__c(
            Name = 'CaseManagementHistoryConfig',
            Is_Active__c = false
        );
        insert caseTriggerSetting;
          List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c GenerateFieldHistoryActionTriggerSetting = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        
        Trigger_Settings__c dlrs_Related_PartyTriggersetting = new Trigger_Settings__c(
            Name = 'dlrs_Related_PartyTrigger',
            Is_Active__c = false
        );
         triggerSettings.add(dlrs_Related_PartyTriggersetting);
        triggerSettings.add(GenerateFieldHistoryActionTriggerSetting);
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
        
        
        
        
        
        Office__c office = new Office__c();
        office.Name = 'Lucian832474';
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '93504';
        zip.City__c='';
        zip.County__c='Imperial';
        
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
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        c.Assigned_Deputy__c = de.Id;
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
        
        cr.Role__c = 'Owner';
        update cr;
        List<DIR_Case__c>d=new List<DIR_Case__c>();
        c.Status__c = 'Not Confirmed';
        d.add(c);
        update d;
           
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        vt.Civil_Penalty_Section__c = '';
        vt.Wizard_Search_Text__c = 'any text';
        vt.Name = 'L.C. 238(f) – Subsequent Violations';
        insert vt;
        
        Violation_Type_Variable__c vtv = new Violation_Type_Variable__c();
        vtv.Violation_Type__c = vt.Id;
        vtv.Data_Type__c = 'Text';
        vtv.Description__c = 'test';
        vtv.value__c = '100';
        insert vtv;
        
        vtv = [SELECT Id, Name, Violation_Type__c, Data_Type__c, Description__c, value__c FROM Violation_Type_Variable__c WHERE Id =: vtv.Id];
        
        vt.Assessment_Formula__c = vtv.Name + '+' + vtv.Name;
        vt.Penalty_Assessment_Description__c = 'test Assess desc {~'+vtv.Name +'~+~'+vtv.Name + '~}';
        vt.Wage_Assessment_Formula__c = vtv.Name + '+' + vtv.Name;
        vt.Wage_Assessment_Description__c = 'test Wage desc ~'+vtv.Name + '~';
        
        update vt;
        
        Wage_Deficiency_Type__c wdt =new Wage_Deficiency_Type__c();
        wdt.Order__c=' ';
        wdt.Option_Label_English__c='hello';
        wdt.Option_Label_Spanish__c='holla';
        wdt.Option_Code__c='es';
        wdt.OwnerId=UserInfo.getUserId();
        insert wdt;
        
        Wage_Deficiency_Violation_Type__c wdvt=new Wage_Deficiency_Violation_Type__c();
        wdvt.Violation_Type__c =vt.Id;
        wdvt.Wage_Deficiency_Code__c='zxcvb';
        wdvt.Wage_Deficiency_Type__c=wdt.Id;
        insert wdvt;
        
        Minimum_Wage_Rate__c mwr=new Minimum_Wage_Rate__c();
        mwr.Min_Employee__c=5;
        mwr.Max_Employee__c=15;
        mwr.Min_Wage_Rate__c=25;
        mwr.Effective_Date_From__c=Date.newInstance(2016, 12, 9);
        mwr.Effective_Date_To__c=Date.newInstance(2017, 12, 9);
        mwr.Zip_Code__c=zip.Id;
        mwr.OwnerId=UserInfo.getUserId();
        insert mwr;
        
        NAICS_Code__c nc=new NAICS_Code__c();
        nc.Change_Note__c='abc';
        nc.External_ID__c='avc';
        nc.OwnerId=UserInfo.getUserId();
        nc.IWC_Corder__c=3;
        nc.NAICS_Title__c='title';
        insert nc;
        Test.startTest();
        OWCWageDeficienciesController.getViolationTypeVariables('zxcvb');
        OWCWageDeficienciesController.getMinimumWageRec('93504','9/12/2016');
        OWCWageDeficienciesController.getIWCInfo('title');
        Test.stopTest();
        
    }
    
}