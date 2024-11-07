@isTest
public class Test_OwcVioltaionController {
    @isTest
    public static void testvioltaion0(){

        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
       
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_DIR_ViolationTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_JudgementTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'LiabilityPaymentTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'Receipt Trigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'DIR_EmployeeTrigger', Is_Active__c = false));
        insert triggerSettings;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
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
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();            
        c.Assigned_Deputy__c = de.Id;
        //c.Case_Number__c = 'WC-CM-834315';
        //c.DLSE_Program__c = ;
        //c.Record_Type_Text__c = ;
        //c.Violation_Type__c = vt.id;
        System.debug('DIR_Case__c::'+c);
        insert c;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByDeveloperName().get('BOFE_Violations').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Name='BOFE_Investigation L.C. 238(f) – Subsequent Violations';
        //vt.Name = 'UNREIMBURSED BUSINESS EXPENSES: Reasonable costs';
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        //vt.Name= 'UNREIMBURSED BUSINESS EXPENSES';
        vt.Help_Text__c= '(BE10) Expenses other than mileage';
        vt.Wage_Assessment_Formula__c= 'VTV0106-VTV0107';
        vt.Wage_Interest_Assessment_Formula__c = '';
        vt.Assessment_Formula__c = '';
        vt.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt.Amount_Paid_Formula__c= 'VTV0107';
        vt.Amount_Earned_Formula__c= 'VTV0106';
        vt.Wizard_Search_Text__c= '( BE10 - 2802 )';
        vt.Civil_Penalty_Section__c = 'L.C. 3722(a)';
        system.debug('vt::'+vt);
        insert vt;
        System.debug('vt.RecordType.DeveloperName>>>'+vt.RecordType.DeveloperName);
        
        DIR_Violation__c cI = new DIR_Violation__c();
        //cI.RecordTypeId = caseRecordTypeId;
        //cI.Name = 'V-867062';
        cI.Case__c = c.Id; 
        cI.Wage_Assessment_Description__c = 'The amount of wages to be cashiered is 400.'; 
        cI.Original_Penalty_Assessment_Amount__c = 0.00; 
        cI.Citation_Amount__c = 0.00;
        cI.Original_Wage_Assessment_Amount__c = 400.00; 
        cI.Wages_Due__c = 400.00;
        cI.Amount_Paid__c = 0.00;
        cI.Amount_Earned__c = 0.00; 
        cI.Total_Wage_Interest_Amount__c = 0.00; 
        cI.Status__c = 'Hold';
        cI.Violation_Type__c = vt.id;
        Insert cI; 
        
        Violation_Type_Variable__c vtv = new Violation_Type_Variable__c();
        vtv.Violation_Type__c= vt.id;
        //vtv.Name= 'VTV0104';
        vtv.Description__c= '$ TOTAL AMOUNT PAYABLE TO PLAINTIFF. Multiply TOTAL NUMBER OF DAYS THAT VIOLATION OCCURRED AND CONTINUED by $50 for each day. Total cannot exceed $4000. Ex: 90 days of violation X $50 per day = $4500.  Enter $4000.';
        vtv.Data_Type__c= 'Currency';
        vtv.value__c= '200';
        system.debug('vtv::'+vtv);
        insert vtv;
        
        Violation_Variable__c vv = new Violation_Variable__c();
        vv.Case_Violation__c = cI.Id;
        vv.Violation_Type_Variable__c = vtv.Id;
        insert vv;
        
        Violation_Type__c vt1 = new Violation_Type__c();
        vt1.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByDeveloperName().get('BOFE_Violations').getRecordTypeId();
        vt1.Appeal_Deadline_Days__c = 12;
        vt1.Active__c = true;
        vt1.Wage_Interest_Assessment_Formula__c = 'VTV4260';
        //vt1.Name='BOFE_Investigation L.C. 238(f) – Subsequent Violations';
        vt1.Name = 'UNREIMBURSED BUSINESS EXPENSES: Reasonable costs';
        vt1.Appeal_Deadline_Selector__c = 'Business Days';
        //vt.Name= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Help_Text__c= '(BE10) Expenses other than mileage';
        vt1.Wage_Assessment_Formula__c= '';
        vt1.Wage_Interest_Assessment_Formula__c = '';
        vt1.Assessment_Formula__c = '';
        vt1.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt1.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Amount_Paid_Formula__c= '';
        vt1.Amount_Earned_Formula__c= '';
        vt1.Wizard_Search_Text__c= '( BE10 - 2802 )';
        vt1.Civil_Penalty_Section__c = 'L.C. 3710.1';
        system.debug('vt1::'+vt1);
        insert vt1;
        
        DIR_Violation__c cI1 = new DIR_Violation__c();
        //cI.RecordTypeId = caseRecordTypeId;
        //cI.Name = 'V-867062';
        cI1.Case__c = c.Id; 
        cI1.Wage_Assessment_Description__c = '{The amount of wages to be cashiered is 400.}'; 
        cI1.Original_Penalty_Assessment_Amount__c = 0.00; 
        cI1.Citation_Amount__c = 0.00;
        cI1.Original_Wage_Assessment_Amount__c = 400.00; 
        cI1.Wages_Due__c = 400.00;
        cI1.Amount_Paid__c = 0.00;
        cI1.Amount_Earned__c = 0.00; 
        cI1.Total_Wage_Interest_Amount__c = 0.00; 
        cI1.Status__c = 'Hold';
        cI1.Penalty_Assessment_Description__c = '{ABC}';
        cI1.Violation_Type__c = vt1.id;
        Insert cI1; 
        
        Violation_Type_Variable__c vtv1 = new Violation_Type_Variable__c();
        vtv1.Violation_Type__c= vt1.id;
        //vtv.Name= 'VTV0104';
        vtv1.Description__c= '$ TOTAL AMOUNT PAYABLE TO PLAINTIFF. Multiply TOTAL NUMBER OF DAYS THAT VIOLATION OCCURRED AND CONTINUED by $50 for each day. Total cannot exceed $4000. Ex: 90 days of violation X $50 per day = $4500.  Enter $4000.';
        vtv1.Data_Type__c= 'Currency';
        vtv1.value__c= '400';
        system.debug('vtv1::'+vtv1);
        insert vtv1;
        
        Violation_Variable__c vv1 = new Violation_Variable__c();
        vv1.Case_Violation__c = cI1.Id;
        vv1.Violation_Type_Variable__c = vtv1.Id;
        insert vv1;
        
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
        
        List<Record_Type_Mapping__c> recType = new List<Record_Type_Mapping__c>();
        
        Record_Type_Mapping__c setting =  new Record_Type_Mapping__c(        
            Name = 'WCA',
            Case_Rec_Type__c = 'WCA',
            Case_Violation_Rec_Type__c = 'WCA_Violations',
            Liability_Rec_Type__c = 'WCA',
            Liable_Party_Rec_Type__c = 'WCA',
            Office_Rec_Type__c = 'WCA',
            Payment_Record_Type__c = 'WCA',
            Violation_Type_Rec_Type__c = 'WCA_Violations');
        
        Record_Type_Mapping__c setting1 =  new Record_Type_Mapping__c(        
            Name = 'BOFE Investigation',
            Case_Rec_Type__c = 'BOFE_Investigation',
            Case_Violation_Rec_Type__c = 'BOFE_Violations',
            Liability_Rec_Type__c = 'BOFE',
            Liable_Party_Rec_Type__c = 'BOFE',
            Office_Rec_Type__c = 'BOFE',
            Payment_Record_Type__c = 'BOFE',
            Violation_Type_Rec_Type__c = 'BOFE_Violations');
        recType.add(setting);
        recType.add(setting1);        
        insert recType;       
        
        Test.startTest(); 
        
        OwcVioltaionController.vtMap();
        OwcVioltaionController.LoadCase(c.Id);
        OwcVioltaionController.caseIssue(c.Id);
        
        
        OwcVioltaionController.SearchedViolationsTypes(c.id,'L.C.');
        OwcVioltaionController.SearchedViolationsTypes(c.id,'Amb');
        
        OwcVioltaionController.addViolation(c.Id,vt.Id);        
        OwcVioltaionController.Liabilities(c.Id);
        
        String liabRctId = [Select Id, Name, sObjectType FROM RecordType where sObjectType = 'Liability__c' AND Name = 'WCA' limit 1].Id;
        String liableRecId = [Select Id, Name, sObjectType FROM RecordType where sObjectType = 'Liable_Party__c' AND Name = 'WCA' limit 1].Id;
        String violationRecId = [Select Id, Name, sObjectType FROM RecordType where sObjectType = 'Violation_Type__c' AND Name = 'WCA Issues - Active' limit 1].Id;
        String valueString = '2:400::1TOTALW:400.00::1TOTALIW:0::1TOTALA:0.00::1AMTP:0::1AMTE:0::';
        String SelTypesList = '{"ViolationTypeWrap":[{"formula":"0","indexCounter":193,"selected":false,"varWrapperIndex":2,"vtvWrapperList":[{"dataType":"Number","indexCounter":1,"isUserInput":true,"vtvName":"VTV2630","vTypeVar":{"Violation_Type__c":"'+vt.Id+'","Id":"'+vtv.Id+'","Name":"VTV2630","Description__c":"Restitution Passthrough Amount","Data_Type__c":"Currency","value__c":"200"},"varValue":"200"}],"vType":{"Id":"'
            +vt.Id+'","Name":"Restitution Fund Passthrough (WCA)","Violation_Text__c":"Used to pay employees from a restitution fund.","Assessment_Formula__c":"0","Wage_Assessment_Formula__c":"VTV2630","Wage_Assessment_Description__c":"The amount of wages to be cashiered is ~VTV2630~.","RecordTypeId":"'+violationRecId+'","Short_Description__c":"Used to pay employees from a restitution fund.","Wizard_Search_Text__c":"( Rest Fund Pass WCA )","Violation_Type_Variables__r":{"totalSize":1,"done":true,"records":[{"Violation_Type__c":"'
            +vt.Id+'","Id":"'+vtv.Id+'","Name":"VTV2630","Description__c":"Restitution Passthrough Amount","Data_Type__c":"Currency","value__c":"200"}]},"RecordType":{"DeveloperName":"WCA_Violations","Id":"'+violationRecId+'"}},"vTypeVars":[{"Violation_Type__c":"'+vt.Id+'","Id":"'+vtv.Id+'","Name":"VTV2630","Description__c":"Restitution Passthrough Amount","Data_Type__c":"Currency","value__c":"200"}],"wageformula":"VTV2630","indexNumber":0,"a":"0.00","b":"200.00","c":0,"subTotalA":0,"subTotalW":200,"subTotalIW":0}]}';
        String LiabStringfy = '{"LiabilityWrap":[{"acc":{"Name":"demo Account Business","Id":"'+mainA.Id+'"},"AccountId":"'+mainA.Id+'","Affiliation":"Defendant","Name":"demo Account Business","propShare":"100","selected":true,"thisCR":{"Id":"'+cr.Id+'","Name":"CR-2010616","Role__c":"Defendant","Entity__c":"'+mainA.Id+'","Case__c":"'
            +c.Id+'","Entity__r":{"Name":"demo Account Business","Id":"'+mainA.Id+'"},"Case__r":{"Name":"CM-834315","Id":"'+c.Id+'"}},"thisLiab":{"RecordTypeId":"'+liabRctId+'"},"thisLiabParty":{"RecordTypeId":"'+liableRecId+'"}}]}';
        String SelectedCitation = 'Single Citation One Number';
        OwcVioltaionController.Finalize(c.Id,valueString,SelTypesList,LiabStringfy,SelectedCitation);        
        OwcVioltaionController.Finalize(c.Id,valueString,SelTypesList,LiabStringfy,'');
        OwcVioltaionController.saveVarValues(valueString);
        
        String SelTypesList1 = '{"ViolationTypeWrap":[{"formula":"0","indexCounter":193,"selected":false,"varWrapperIndex":2,"vtvWrapperList":[{"dataType":"Number","indexCounter":1,"isUserInput":true,"vtvName":"VTV2630","vTypeVar":{"Violation_Type__c":"'+vt.Id+'","Id":"'+vtv.Id+'","Name":"VTV2630","Description__c":"Restitution Passthrough Amount","Data_Type__c":"Currency","value__c":"200"},"varValue":"200"}],"vType":{"Id":"'
            +vt.Id+'","Name":"Restitution Fund Passthrough (WCA)","Violation_Text__c":"Used to pay employees from a restitution fund.","Assessment_Formula__c":"0","Wage_Assessment_Formula__c":"VTV2630","Wage_Assessment_Description__c":"{~VTV2630~.}","RecordTypeId":"'+violationRecId+'","Short_Description__c":"Used to pay employees from a restitution fund.","Wizard_Search_Text__c":"( Rest Fund Pass WCA )","Violation_Type_Variables__r":{"totalSize":1,"done":true,"records":[{"Violation_Type__c":"'+vt.Id+'","Id":"'
            +vtv.Id+'","Name":"VTV2630","Description__c":"Restitution Passthrough Amount","Data_Type__c":"Currency","value__c":"200"}]},"RecordType":{"DeveloperName":"WCA_Violations","Id":"'+violationRecId+'"}},"vTypeVars":[{"Violation_Type__c":"'+vt.Id+'","Id":"'+vtv.Id+'","Name":"VTV2630","Description__c":"Restitution Passthrough Amount","Data_Type__c":"Currency","value__c":"200"}],"wageformula":"VTV2630","indexNumber":0,"a":"0.00","b":"200.00","c":0,"subTotalA":0,"subTotalW":200,"subTotalIW":0}]}';
        OwcVioltaionController.addViolation(c.Id,vt1.Id);
        OwcVioltaionController.Finalize(c.Id,valueString,SelTypesList1,LiabStringfy,SelectedCitation);
        Contact conObj = new Contact(); 
        RecordType liabilityRecObj = [SELECT Id, Name, DeveloperName FROM RecordType Where Name = 'WCA' limit 1];
        //RecordType liabilityPartyRecObj = [SELECT Id, Name, DeveloperName FROM RecordType Where Name = 'WCA' limit 1];
        Map<String, RecordType> mapObj = new Map<String, RecordType>();
        mapObj.put('Liable_Party__c', liabilityRecObj);
        mapObj.put('Liability__c', liabilityRecObj);
        OwcVioltaionController.LiabilityWrapper liablityWrapObj = new OwcVioltaionController.LiabilityWrapper(conObj, 'test', mapObj);
        //liablityWrapObj
        Test.stopTest();
        
    }
    @isTest
    public static void testvioltaion1(){
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_DIR_ViolationTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_JudgementTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'LiabilityPaymentTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'Receipt Trigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'DIR_EmployeeTrigger', Is_Active__c = false));
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
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();            
        c.Assigned_Deputy__c = de.Id;
        c.Date_Case_Received__c = Date.today();
        c.Intake_Origin__c = 'In Person';
        //c.Case_Number__c = 'WC-CM-834315';
        //c.DLSE_Program__c = ;
        //c.Record_Type_Text__c = ;
        //c.Violation_Type__c = vt.id;
        System.debug('DIR_Case__c::'+c);
        insert c;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByDeveloperName().get('WCA_Violations').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Name='BOFE_Investigation L.C. 238(f) – Subsequent Violations';
        //vt.Name = 'UNREIMBURSED BUSINESS EXPENSES: Reasonable costs';
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        //vt.Name= 'UNREIMBURSED BUSINESS EXPENSES';
        vt.Help_Text__c= '(BE10) Expenses other than mileage';
        vt.Wage_Assessment_Formula__c= 'VTV0106-VTV0107';
        vt.Wage_Interest_Assessment_Formula__c = '';
        vt.Assessment_Formula__c = '';
        vt.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt.Amount_Paid_Formula__c= 'VTV0107';
        vt.Amount_Earned_Formula__c= 'VTV0106';
        vt.Wizard_Search_Text__c= '( BE10 - 2802 )';
        vt.Civil_Penalty_Section__c = 'L.C. 3722(a)';
        system.debug('vt::'+vt);
        insert vt;
        System.debug('vt.RecordType.DeveloperName>>>'+vt.RecordType.DeveloperName);
        
        DIR_Violation__c cI = new DIR_Violation__c();
            //cI.RecordTypeId = caseRecordTypeId;
            //cI.Name = 'V-867062';
            cI.Case__c = c.Id; 
            cI.Wage_Assessment_Description__c = 'The amount of wages to be cashiered is 400.'; 
            cI.Original_Penalty_Assessment_Amount__c = 0.00; 
            cI.Citation_Amount__c = 0.00;
            cI.Original_Wage_Assessment_Amount__c = 400.00; 
            cI.Wages_Due__c = 400.00;
            cI.Amount_Paid__c = 0.00;
            cI.Amount_Earned__c = 0.00; 
            cI.Total_Wage_Interest_Amount__c = 0.00; 
            cI.Status__c = 'Hold';
            
            cI.Violation_Type__c = vt.id;
        Insert cI; 
        
        Violation_Type_Variable__c vtv = new Violation_Type_Variable__c();
            vtv.Violation_Type__c= vt.id;
            //vtv.Name= 'VTV0104';
            vtv.Description__c= '$ TOTAL AMOUNT PAYABLE TO PLAINTIFF. Multiply TOTAL NUMBER OF DAYS THAT VIOLATION OCCURRED AND CONTINUED by $50 for each day. Total cannot exceed $4000. Ex: 90 days of violation X $50 per day = $4500.  Enter $4000.';
            vtv.Data_Type__c= 'Currency';
            vtv.value__c= '200';
            system.debug('vtv::'+vtv);
        insert vtv;
        
        Violation_Variable__c vv = new Violation_Variable__c();
            vv.Case_Violation__c = cI.Id;
            vv.Violation_Type_Variable__c = vtv.Id;
        insert vv;
        
        Violation_Type__c vt1 = new Violation_Type__c();
        vt1.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByDeveloperName().get('BOFE_Violations').getRecordTypeId();
        vt1.Appeal_Deadline_Days__c = 12;
        vt1.Active__c = true;
        //vt1.Name='BOFE_Investigation L.C. 238(f) – Subsequent Violations';
        vt1.Name = 'UNREIMBURSED BUSINESS EXPENSES: Reasonable costs';
        vt1.Appeal_Deadline_Selector__c = 'Business Days';
        //vt.Name= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Help_Text__c= '(BE10) Expenses other than mileage';
        vt1.Wage_Assessment_Formula__c= '';
        vt1.Wage_Interest_Assessment_Formula__c = '';
        vt1.Assessment_Formula__c = '';
        vt1.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt1.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Amount_Paid_Formula__c= '';
        vt1.Amount_Earned_Formula__c= '';
        vt1.Wizard_Search_Text__c= '( BE10 - 2802 )';
        vt1.Civil_Penalty_Section__c = 'L.C. 3710.1';
        system.debug('vt1::'+vt1);
        insert vt1;
        
        DIR_Violation__c cI1 = new DIR_Violation__c();
            //cI.RecordTypeId = caseRecordTypeId;
            //cI.Name = 'V-867062';
            cI1.Case__c = c.Id; 
            cI1.Wage_Assessment_Description__c = '{The amount of wages to be cashiered is 400.}'; 
            cI1.Original_Penalty_Assessment_Amount__c = 0.00; 
            cI1.Citation_Amount__c = 0.00;
            cI1.Original_Wage_Assessment_Amount__c = 400.00; 
            cI1.Wages_Due__c = 400.00;
            cI1.Amount_Paid__c = 0.00;
            cI1.Amount_Earned__c = 0.00; 
            cI1.Total_Wage_Interest_Amount__c = 0.00; 
            cI1.Status__c = 'Hold';
            cI1.Penalty_Assessment_Description__c = '{ABC}';
            cI1.Violation_Type__c = vt1.id;
        Insert cI1; 
        
        Violation_Type_Variable__c vtv1 = new Violation_Type_Variable__c();
            vtv1.Violation_Type__c= vt1.id;
            //vtv.Name= 'VTV0104';
            vtv1.Description__c= '$ TOTAL AMOUNT PAYABLE TO PLAINTIFF. Multiply TOTAL NUMBER OF DAYS THAT VIOLATION OCCURRED AND CONTINUED by $50 for each day. Total cannot exceed $4000. Ex: 90 days of violation X $50 per day = $4500.  Enter $4000.';
            vtv1.Data_Type__c= 'Currency';
            vtv1.value__c= '400';
            system.debug('vtv1::'+vtv1);
        insert vtv1;
        
        Violation_Variable__c vv1 = new Violation_Variable__c();
            vv1.Case_Violation__c = cI1.Id;
            vv1.Violation_Type_Variable__c = vtv1.Id;
        insert vv1;
        
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
        
        List<Record_Type_Mapping__c> recType = new List<Record_Type_Mapping__c>();
        
        Record_Type_Mapping__c setting =  new Record_Type_Mapping__c(        
            Name = 'WCA',
            Case_Rec_Type__c = 'WCA',
            Case_Violation_Rec_Type__c = 'WCA_Violations',
            Liability_Rec_Type__c = 'WCA',
            Liable_Party_Rec_Type__c = 'WCA',
            Office_Rec_Type__c = 'WCA',
            Payment_Record_Type__c = 'WCA',
            Violation_Type_Rec_Type__c = 'WCA_Violations');
        Record_Type_Mapping__c setting1 =  new Record_Type_Mapping__c(        
            Name = 'BOFE Investigation',
            Case_Rec_Type__c = 'BOFE_Investigation',
            Case_Violation_Rec_Type__c = 'BOFE_Violations',
            Liability_Rec_Type__c = 'BOFE',
            Liable_Party_Rec_Type__c = 'BOFE',
            Office_Rec_Type__c = 'BOFE',
            Payment_Record_Type__c = 'BOFE',
            Violation_Type_Rec_Type__c = 'BOFE_Violations');
        recType.add(setting);
        recType.add(setting1);        
        insert recType;       
        
        Test.startTest(); 
        
        
        OwcVioltaionController.SearchedViolationsTypes(c.id,'L.C.');
        OwcVioltaionController.SearchedViolationsTypes(c.id,'Amb');
        
        
        Test.stopTest();
        
    }
    @isTest
    public static void testvioltaion2(){
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('Garment').getRecordTypeId();
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_DIR_ViolationTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_JudgementTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'LiabilityPaymentTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'Receipt Trigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'DIR_EmployeeTrigger', Is_Active__c = false));
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
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('Garment').getRecordTypeId();            
        c.Assigned_Deputy__c = de.Id;
        c.Case_Number__c = 'WC-CM-834315';
        //c.DLSE_Program__c = ;
        //c.Record_Type_Text__c = ;
        //c.Violation_Type__c = vt.id;
        System.debug('DIR_Case__c::'+c);
        insert c;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByDeveloperName().get('WCA_Violations').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Name='BOFE_Investigation L.C. 238(f) – Subsequent Violations';
        //vt.Name = 'UNREIMBURSED BUSINESS EXPENSES: Reasonable costs';
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        //vt.Name= 'UNREIMBURSED BUSINESS EXPENSES';
        vt.Help_Text__c= '(BE10) Expenses other than mileage';
        vt.Wage_Assessment_Formula__c= 'VTV0106-VTV0107';
        vt.Wage_Interest_Assessment_Formula__c = '';
        vt.Assessment_Formula__c = '';
        vt.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt.Amount_Paid_Formula__c= 'VTV0107';
        vt.Amount_Earned_Formula__c= 'VTV0106';
        vt.Wizard_Search_Text__c= '( BE10 - 2802 )';
        vt.Civil_Penalty_Section__c = 'L.C. 3722(a)';
        system.debug('vt::'+vt);
        insert vt;
        System.debug('vt.RecordType.DeveloperName>>>'+vt.RecordType.DeveloperName);
        
        DIR_Violation__c cI = new DIR_Violation__c();
            //cI.RecordTypeId = caseRecordTypeId;
            //cI.Name = 'V-867062';
            cI.Case__c = c.Id; 
            cI.Wage_Assessment_Description__c = 'The amount of wages to be cashiered is 400.'; 
            cI.Original_Penalty_Assessment_Amount__c = 0.00; 
            cI.Citation_Amount__c = 0.00;
            cI.Original_Wage_Assessment_Amount__c = 400.00; 
            cI.Wages_Due__c = 400.00;
            cI.Amount_Paid__c = 0.00;
            cI.Amount_Earned__c = 0.00; 
            cI.Total_Wage_Interest_Amount__c = 0.00; 
            cI.Status__c = 'Hold';
            
            cI.Violation_Type__c = vt.id;
        Insert cI; 
        
        Violation_Type_Variable__c vtv = new Violation_Type_Variable__c();
            vtv.Violation_Type__c= vt.id;
            //vtv.Name= 'VTV0104';
            vtv.Description__c= '$ TOTAL AMOUNT PAYABLE TO PLAINTIFF. Multiply TOTAL NUMBER OF DAYS THAT VIOLATION OCCURRED AND CONTINUED by $50 for each day. Total cannot exceed $4000. Ex: 90 days of violation X $50 per day = $4500.  Enter $4000.';
            vtv.Data_Type__c= 'Currency';
            vtv.value__c= '200';
            system.debug('vtv::'+vtv);
        insert vtv;
        
        Violation_Variable__c vv = new Violation_Variable__c();
            vv.Case_Violation__c = cI.Id;
            vv.Violation_Type_Variable__c = vtv.Id;
        insert vv;
        
        Violation_Type__c vt1 = new Violation_Type__c();
        vt1.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByDeveloperName().get('BOFE_Violations').getRecordTypeId();
        vt1.Appeal_Deadline_Days__c = 12;
        vt1.Active__c = true;
        //vt1.Name='BOFE_Investigation L.C. 238(f) – Subsequent Violations';
        vt1.Name = 'UNREIMBURSED BUSINESS EXPENSES: Reasonable costs';
        vt1.Appeal_Deadline_Selector__c = 'Business Days';
        //vt.Name= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Help_Text__c= '(BE10) Expenses other than mileage';
        vt1.Wage_Assessment_Formula__c= '';
        vt1.Wage_Interest_Assessment_Formula__c = '';
        vt1.Assessment_Formula__c = '';
        vt1.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt1.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt1.Amount_Paid_Formula__c= '';
        vt1.Amount_Earned_Formula__c= '';
        vt1.Wizard_Search_Text__c= '( BE10 - 2802 )';
        vt1.Civil_Penalty_Section__c = 'L.C. 3710.1';
        system.debug('vt1::'+vt1);
        insert vt1;
        
        DIR_Violation__c cI1 = new DIR_Violation__c();
            //cI.RecordTypeId = caseRecordTypeId;
            //cI.Name = 'V-867062';
            cI1.Case__c = c.Id; 
            cI1.Wage_Assessment_Description__c = '{The amount of wages to be cashiered is 400.}'; 
            cI1.Original_Penalty_Assessment_Amount__c = 0.00; 
            cI1.Citation_Amount__c = 0.00;
            cI1.Original_Wage_Assessment_Amount__c = 400.00; 
            cI1.Wages_Due__c = 400.00;
            cI1.Amount_Paid__c = 0.00;
            cI1.Amount_Earned__c = 0.00; 
            cI1.Total_Wage_Interest_Amount__c = 0.00; 
            cI1.Status__c = 'Hold';
            cI1.Penalty_Assessment_Description__c = '{ABC}';
            cI1.Violation_Type__c = vt1.id;
        Insert cI1; 
        
        Violation_Type_Variable__c vtv1 = new Violation_Type_Variable__c();
            vtv1.Violation_Type__c= vt1.id;
            //vtv.Name= 'VTV0104';
            vtv1.Description__c= '$ TOTAL AMOUNT PAYABLE TO PLAINTIFF. Multiply TOTAL NUMBER OF DAYS THAT VIOLATION OCCURRED AND CONTINUED by $50 for each day. Total cannot exceed $4000. Ex: 90 days of violation X $50 per day = $4500.  Enter $4000.';
            vtv1.Data_Type__c= 'Currency';
            vtv1.value__c= '400';
            system.debug('vtv1::'+vtv1);
        insert vtv1;
        
        Violation_Variable__c vv1 = new Violation_Variable__c();
            vv1.Case_Violation__c = cI1.Id;
            vv1.Violation_Type_Variable__c = vtv1.Id;
        insert vv1;
        
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
        
        List<Record_Type_Mapping__c> recType = new List<Record_Type_Mapping__c>();
        
        Record_Type_Mapping__c setting =  new Record_Type_Mapping__c(        
            Name = 'WCA',
            Case_Rec_Type__c = 'Garment',
            Case_Violation_Rec_Type__c = 'WCA_Violations',
            Liability_Rec_Type__c = 'WCA',
            Liable_Party_Rec_Type__c = 'WCA',
            Office_Rec_Type__c = 'WCA',
            Payment_Record_Type__c = 'WCA',
            Violation_Type_Rec_Type__c = 'WCA_Violations');
        Record_Type_Mapping__c setting1 =  new Record_Type_Mapping__c(        
            Name = 'BOFE Investigation',
            Case_Rec_Type__c = 'BOFE_Investigation',
            Case_Violation_Rec_Type__c = 'BOFE_Violations',
            Liability_Rec_Type__c = 'BOFE',
            Liable_Party_Rec_Type__c = 'BOFE',
            Office_Rec_Type__c = 'BOFE',
            Payment_Record_Type__c = 'BOFE',
            Violation_Type_Rec_Type__c = 'BOFE_Violations');
        recType.add(setting);
        recType.add(setting1);        
        insert recType; 
        
        
        
        Test.startTest(); 
        
        OwcVioltaionController.ViolationsTypes(c.Id); 
        
        Map<String,String> caseIssueMap = new Map<String,String>();
        Map<String,String> caseIssueVarMap = new Map<String,String>();
        OwcVioltaionController.ViolationTypeWrapper vTW = new OwcVioltaionController.ViolationTypeWrapper(vt1,1,caseIssueMap,caseIssueVarMap);
        
        vTW.amount = 0.1;
        vTW.wage = 0.1;
        vTW.wageinterest = 0.1;
        /*vTW.wageformula  = '';
        vTW.wageinterestformula  = '';
        vTW.formula = '';
        vTW.amountPaidFormula = '';
        vTW.amountEarnedFormula = '';*/
        
        Test.stopTest();
        
    }
    
    /* 
    @IsTest
    public static void testWCARecordTypes(){

        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_DIR_ViolationTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_JudgementTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'LiabilityPaymentTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'Receipt Trigger', Is_Active__c = false));
        insert triggerSettings;
                    
        RecordType caseRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND Name = 'WCA' AND DeveloperName = 'WCA' LIMIT 1];
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de;
        
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
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();            
        c.Assigned_Deputy__c = de.Id;
        c.Case_Number__c = 'WC-CM-834315';
        //c.DLSE_Program__c = ;
        //c.Record_Type_Text__c = ;
        //c.Violation_Type__c = vt.id;
        System.debug('DIR_Case__c::'+c);
        insert c;
    
        Test.startTest();
        DIR_Case__c caseObj = [SELECT Id, RecordType.DeveloperName FROM DIR_Case__c Where Id =: c.Id];
        OwcVioltaionController.getRecordTypes(caseObj);
        Test.stopTest();
    }
     */
    /*
    @IsTest
    public static void testGarmentRecordTypes(){
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_DIR_ViolationTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_JudgementTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'LiabilityPaymentTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'Receipt Trigger', Is_Active__c = false));
        insert triggerSettings;
            
        RecordType caseRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND Name = 'Garment' AND DeveloperName = 'Garment' LIMIT 1];
        
        Account mainA = new Account();
        mainA.Name = 'name';
        mainA.ShippingPostalCode = '234889';
        insert mainA;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = caseRT.Id;            
        insert c;
    
        Test.startTest();
        DIR_Case__c caseObj = [SELECT Id, RecordType.DeveloperName FROM DIR_Case__c Where Id =: c.Id];
        OwcVioltaionController.getRecordTypes(caseObj);
        Test.stopTest();
    }

    */
    @IsTest
    public static void testPASSRecordTypes(){

        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_DIR_ViolationTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_JudgementTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'LiabilityPaymentTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'Receipt Trigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'DIR_EmployeeTrigger', Is_Active__c = false));
        insert triggerSettings;
            
        RecordType caseRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND Name = 'PASS' AND DeveloperName = 'PASS' LIMIT 1];
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de;
        
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
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PASS').getRecordTypeId();            
        c.Assigned_Deputy__c = de.Id;
        c.Case_Number__c = 'WC-CM-834315';
        //c.DLSE_Program__c = ;
        //c.Record_Type_Text__c = ;
        //c.Violation_Type__c = vt.id;
        System.debug('DIR_Case__c::'+c);
        insert c;
        
    
        Test.startTest();
        DIR_Case__c caseObj = [SELECT Id, RecordType.DeveloperName FROM DIR_Case__c Where Id =: c.Id];
        OwcVioltaionController.getRecordTypes(caseObj);
        Test.stopTest();
    }

    @IsTest
    public static void testRCIRecordTypes(){

        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_DIR_ViolationTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_JudgementTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'LiabilityPaymentTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'Receipt Trigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'DIR_EmployeeTrigger', Is_Active__c = false));
        insert triggerSettings;
            
        RecordType caseRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND Name = 'RCI' AND DeveloperName = 'RCI' LIMIT 1];
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de;
        
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
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();            
        c.Assigned_Deputy__c = de.Id;
        c.Case_Number__c = 'WC-CM-834315';
        //c.DLSE_Program__c = ;
        //c.Record_Type_Text__c = ;
        //c.Violation_Type__c = vt.id;
        System.debug('DIR_Case__c::'+c);
        insert c;
            
        Test.startTest();
        DIR_Case__c caseObj = [SELECT Id, RecordType.DeveloperName FROM DIR_Case__c Where Id =: c.Id];
        OwcVioltaionController.getRecordTypes(caseObj);
        Test.stopTest();
    }

    @IsTest
    public static void testJEURecordTypes(){

        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_DIR_ViolationTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_JudgementTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'LiabilityPaymentTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'Receipt Trigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'DIR_EmployeeTrigger', Is_Active__c = false));
        insert triggerSettings;
            
        RecordType caseRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND Name = 'JEU' AND DeveloperName = 'JEU' LIMIT 1];
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de;
        
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
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId();            
        c.Assigned_Deputy__c = de.Id;
        c.Case_Number__c = 'WC-CM-834315';
        //c.DLSE_Program__c = ;
        //c.Record_Type_Text__c = ;
        //c.Violation_Type__c = vt.id;
        System.debug('DIR_Case__c::'+c);
        insert c;
        
        Test.startTest();
        DIR_Case__c caseObj = [SELECT Id, RecordType.DeveloperName FROM DIR_Case__c Where Id =: c.Id];
        OwcVioltaionController.getRecordTypes(caseObj);
        Test.stopTest();
    }

    @IsTest
    public static void testRegistrationRecordTypes(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        triggerSettings.add(new Trigger_Settings__c(Name = 'CaseRoleAll', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_DIR_ViolationTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'dlrs_JudgementTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'GenerateFieldHistoryAction', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'LiabilityPaymentTrigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'Receipt Trigger', Is_Active__c = false));
        triggerSettings.add(new Trigger_Settings__c(Name = 'DIR_EmployeeTrigger', Is_Active__c = false));
        insert triggerSettings;
                    
        RecordType caseRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND Name = 'Registration' AND DeveloperName = 'Registration' LIMIT 1];
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de;
        
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
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('Registration').getRecordTypeId();            
        c.Assigned_Deputy__c = de.Id;
        c.Case_Number__c = 'WC-CM-834315';
        //c.DLSE_Program__c = ;
        //c.Record_Type_Text__c = ;
        //c.Violation_Type__c = vt.id;
        System.debug('DIR_Case__c::'+c);
        insert c;
        
        Test.startTest();
        DIR_Case__c caseObj = [SELECT Id, RecordType.DeveloperName FROM DIR_Case__c Where Id =: c.Id];
        OwcVioltaionController.getRecordTypes(caseObj);
        
        OwcVioltaionController owcCtrl = new OwcVioltaionController();
        Boolean selectAll = OwcVioltaionController.selectAll;
        boolean rtError = OwcVioltaionController.rtError;
        boolean getRTError = owcCtrl.getRTError;
        Map<String, RecordType> rtMap = owcCtrl.rtMap;
        OwcVioltaionController.SelectedTypes = new List<OwcVioltaionController.ViolationTypeWrapper>();
        Violation_Type__c vT1 = new Violation_Type__c();
        OwcVioltaionController.ViolationTypeWrapper vtWrapper = new OwcVioltaionController.ViolationTypeWrapper(vT1, 0);
        vtWrapper.vType = new Violation_Type__c();
        string wageformula = vtWrapper.wageformula;
        string wageinterestformula = vtWrapper.wageinterestformula;
        string formula = vtWrapper.formula;
        string amountPaidFormula = vtWrapper.amountPaidFormula;
        string amountEarnedFormula = vtWrapper.amountEarnedFormula;
        Boolean SelectTypeExis = owcCtrl.SelectTypeExist;
        
        Case_Role__c cr = new Case_Role__c();
        RecordType liabilityRecObj = [SELECT Id, Name, DeveloperName FROM RecordType Where Name = 'WCA' limit 1];
        //RecordType liabilityPartyRecObj = [SELECT Id, Name, DeveloperName FROM RecordType Where Name = 'WCA' limit 1];
        Map<String, RecordType> mapObj = new Map<String, RecordType>();
        mapObj.put('Liable_Party__c', liabilityRecObj);
        mapObj.put('Liability__c', liabilityRecObj);
        OwcVioltaionController.LiabilityWrapper lWrapper = new OwcVioltaionController.LiabilityWrapper(cr, mapObj);
        
        Id AccountId = lWrapper.AccountId;
        string Name = lWrapper.Name;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByDeveloperName().get('BOFE_Violations').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Name='BOFE_Investigation L.C. 238(f) – Subsequent Violations';
        //vt.Name = 'UNREIMBURSED BUSINESS EXPENSES: Reasonable costs';
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        //vt.Name= 'UNREIMBURSED BUSINESS EXPENSES';
        vt.Help_Text__c= '(BE10) Expenses other than mileage';
        vt.Wage_Assessment_Formula__c= 'VTV0106-VTV0107';
        vt.Wage_Interest_Assessment_Formula__c = '';
        vt.Assessment_Formula__c = '';
        vt.Wage_Assessment_Description__c= 'UNREIMBURSED BUSINESS EXPENSES  -- From ~VTV0104~ through ~VTV0105~, plaintiff claims reimbursable business expenses (see Labor Code Section 2802), which were incurred for the following: ~VTV0108~. Reasonable costs including attorney’s fees may also be applicable. (See Labor Code Section 2802(c))';
        vt.Short_Description__c= 'UNREIMBURSED BUSINESS EXPENSES';
        vt.Amount_Paid_Formula__c= 'VTV0107';
        vt.Amount_Earned_Formula__c= 'VTV0106';
        vt.Wizard_Search_Text__c= '( BE10 - 2802 )';
        vt.Civil_Penalty_Section__c = 'L.C. 3722(a)';
        system.debug('vt::'+vt);
        insert vt;
        Violation_Type_Variable__c vtv = new Violation_Type_Variable__c();
        vtv.Violation_Type__c= vt.id;
        //vtv.Name= 'VTV0104';
        vtv.Description__c= '$ TOTAL AMOUNT PAYABLE TO PLAINTIFF. Multiply TOTAL NUMBER OF DAYS THAT VIOLATION OCCURRED AND CONTINUED by $50 for each day. Total cannot exceed $4000. Ex: 90 days of violation X $50 per day = $4500.  Enter $4000.';
        vtv.Data_Type__c= 'Currency';
        vtv.value__c= '{!Input}';
        system.debug('vtv::'+vtv);
        insert vtv;

        DIR_Violation__c cI = new DIR_Violation__c();
        //cI.RecordTypeId = caseRecordTypeId;
        //cI.Name = 'V-867062';
        cI.Case__c = c.Id; 
        cI.Wage_Assessment_Description__c = 'The amount of wages to be cashiered is 400.'; 
        cI.Original_Penalty_Assessment_Amount__c = 0.00; 
        cI.Citation_Amount__c = 0.00;
        cI.Original_Wage_Assessment_Amount__c = 400.00; 
        cI.Wages_Due__c = 400.00;
        cI.Amount_Paid__c = 0.00;
        cI.Amount_Earned__c = 0.00; 
        cI.Total_Wage_Interest_Amount__c = 0.00; 
        cI.Status__c = 'Hold';
        cI.Violation_Type__c = vt.id;

        //Insert cI; 
        Violation_Type__c vtRec = [SELECT Id, (SELECT id, Name,Data_Type__c,Value__c FROM Violation_Type_Variables__r) FROM Violation_Type__c
                                  WHERE Id =: vt.id];
        Map<String,String> caseIssueVarMap = new Map<String,String>();
        Map<String,String> caseIssueVarMap1 = new Map<String,String>();
        OwcVioltaionController.ViolationTypeWrapper vtWrapper1 = new OwcVioltaionController.ViolationTypeWrapper(
            vtRec,1,cI.Id,caseIssueVarMap);
        OwcVioltaionController.ViolationTypeWrapper vtWrapper2 = new OwcVioltaionController.ViolationTypeWrapper(
            vtRec,1,caseIssueVarMap1,caseIssueVarMap1);
        
        Test.stopTest();
    }
}