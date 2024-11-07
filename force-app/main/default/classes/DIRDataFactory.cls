@isTest
public class DIRDataFactory {
    public static List<Account> createAccount(){
        List<Account> listOfAccount = new List<Account>();
        listOfAccount.add(new Account(Name='William Hasbro'));
        listOfAccount.add(new Account(Name='Nina KalKat'));
        insert listOfAccount; 
        return listOfAccount; 
        
    }
    public static Trigger_Settings__c createTriggerCustomSettingRecord(){
        Trigger_Settings__c triggerSettingObj = new Trigger_Settings__c();
        triggerSettingObj.Is_Active__c = true;
        triggerSettingObj.Name = 'dlrs_JudgementTrigger';
        insert triggerSettingObj;
        return triggerSettingObj;
    }
    public static Trigger_Settings__c createTriggerCustomSettingRecord1(){
        Trigger_Settings__c triggerSettingObj = new Trigger_Settings__c();
        triggerSettingObj.Is_Active__c = true;
        triggerSettingObj.Name = 'GenerateFieldHistoryAction';
        insert triggerSettingObj;
        return triggerSettingObj;
    }
    public static Case_Role__c caseRoleRecord(Id accountId){
        Id recTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId();
        DIR_Case__c caseManagement = new DIR_Case__c(Employer__c=accountId,RecordTypeId=recTypeId);
        insert caseManagement; 
        
        Id caseRoleRecTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        Case_Role__c caseRole = new Case_Role__c( Case__c=caseManagement.Id,Entity__c=accountId,Role__c='Defendant',Case_Role_Status__c='Active',RecordTypeId=caseRoleRecTypeId); 
        insert caseRole;
        return caseRole; 
    }
    public static DIR_Case__c createCaseManagement(Id accountId){
        Id recTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId();
        DIR_Case__c caseManagement = new DIR_Case__c(Employer__c=accountId,RecordTypeId=recTypeId);
        insert caseManagement; 
        return caseManagement; 
    }
    public static Related_Businesses__c relatedBusinessesRecord(String businessName, List<Account> listOfAccount){
        Related_Businesses__c relatedBusinessesObj = new Related_Businesses__c(Name__c=businessName, Business__c=listOfAccount[1].Id,Related_Business__c=listOfAccount[0].Id,Type__c='Successor');
        return relatedBusinessesObj;
    }
    public static Liability_Judgement__c createJudgmentPartyRecForLookup(){
        List<Account> accountList = DIRDataFactory.createAccount();
        Judgement__c judObj = DIRDataFactory.createTestJudgmentRecord();
        Related_Businesses__c relatedBusinessObj = DIRDataFactory.relatedBusinessesRecord('Test Account - BPAAS',accountList);
        Liability_Judgement__c liableObj = new Liability_Judgement__c();
        liableObj.Related_Business__c = relatedBusinessObj.id;
        liableObj.Judgement__c = judObj.id;
        insert liableObj;
        return liableObj;
    }
    public static List<NAICS_Code__c> createNaicsCodeTestData(){
        List<NAICS_Code__c> naicsCodeList = new List<NAICS_Code__c>();
        for(Integer i=0 ;i<9;i++){
            NAICS_Code__c naicsCode = new NAICS_Code__c();
            naicsCode.Name = '90' + i;
            naicsCode.NAICS_Title__c = 'testTitle' + i;
            naicsCodeList.add(naicsCode);
        }
        insert naicsCodeList;
        return naicsCodeList;
    }
    public static List<Account> craeteAccountRecords(){
        List<Account> accObjList = new List<Account>();
        for(Integer i=0;i<2;i++){
            Account accObj = new Account();
            accObj.Name = 'test' + i;
            accObj.ShippingCity = 'testCity';
            accObj.ZIP_PostalCode1__c = '250001';
            accObj.ZIP_PostalCode2__c = '250001';
            accObj.ShippingCountry = 'testCountry';
            accObjList.add(accObj);
        }
        insert accObjList;
        return accObjList;
    }
    //Create Business Record for test
    public static List<Account> createBusinessTestRecord(){
        List<Account> accObjList = new List<Account>();
        for(Integer i=0;i<12;i++){
            Account accObj = new Account();
            accObj.Name = 'busineesAccount' + i;
            accObj.ShippingCity = 'testCity';
            accObj.ZIP_PostalCode1__c = '250001';
            accObj.ZIP_PostalCode2__c = '250001';
            accObj.ShippingCountry = 'testCountry';
            accObjList.add(accObj);
        }
        insert accObjList;
        return accObjList;
    }
    
    public static Related_Businesses__c createRelatedBusinessesRecTestData(){
        Related_Businesses__c rboObj = new Related_Businesses__c();
        List<Account> accObjList = DIRDataFactory.createBusinessTestRecord();
        rboObj.Business__c = accObjList[0].Id;
            rboObj.Related_Business__c = accObjList[1].Id;
            rboObj.Type__c = 'Single Enterprise';
            rboObj.Name__c = 'test';
        insert rboObj;
        return rboObj;
    }
    
    public static List<Related_Businesses__c> createRelatedBusinessesTestData(){
        List<Related_Businesses__c> relatedBusinessList = new List<Related_Businesses__c>();
        List<Account> accObjList = DIRDataFactory.createBusinessTestRecord();
        for(Integer i=0;i<4;i++){
            Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
            relatedBusinessObj.Business__c = accObjList[i].Id;
            relatedBusinessObj.Related_Business__c = accObjList[3-i].Id;
            relatedBusinessObj.Type__c = 'Single Enterprise';
            relatedBusinessObj.Name__c = 'test' + i;
            relatedBusinessList.add(relatedBusinessObj);
        }
        insert relatedBusinessList;
        return relatedBusinessList;
    }
    public static List<Related_Businesses__c> createRelatedBusinessRec(){
        List<Related_Businesses__c> relatedBusinessList = new List<Related_Businesses__c>();
        List<Account> accObjList = DIRDataFactory.createBusinessTestRecord();
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = accObjList[0].Id;
        relatedBusinessObj.Related_Business__c = accObjList[1].Id;
        relatedBusinessObj.Type__c = 'Single Enterprise';
        relatedBusinessObj.Name__c = 'test';
        Related_Businesses__c relatedBusinessObj1 = new Related_Businesses__c();
        relatedBusinessObj1.Business__c = accObjList[2].Id;
        relatedBusinessObj1.Related_Business__c = accObjList[3].Id;
        relatedBusinessObj1.Type__c = 'Single Enterprise';
        relatedBusinessObj1.Name__c = 'test';
        relatedBusinessList.add(relatedBusinessObj1);
        insert relatedBusinessList;
        return relatedBusinessList;
    }
    public static DIR_Employee__c createDirEmployeeRec(){
        DIR_Employee__c employeeObj = new DIR_Employee__c();
        employeeObj.Active__c = true;
        employeeObj.Email__c = 'test@gmail.com';
        employeeObj.Name = 'test';
        insert employeeObj;
        return employeeObj;
    }
    public static DIR_Case__c createCaseManagementRecList(){
        DIR_Employee__c dirEmployeeObj = DIRDataFactory.createDirEmployeeRec();
        DIR_Case__c dirCaseObj = new DIR_Case__c();
        dirCaseObj.Status__c = 'Open';
        dirCaseObj.Assigned_Deputy__c = dirEmployeeObj.Id;
        insert dirCaseObj;
        return dirCaseObj;
    }
    public static List<Case_Role__c> createCaseRoleRecord(){
        List<Account> accObjList = DIRDataFactory.createBusinessTestRecord();
        DIR_Case__c caseObj = DIRDataFactory.createCaseManagementRecList();
        List<Case_Role__c> caseRoleList = new List<Case_Role__c>();
        Case_Role__c caseRoleObj = new Case_Role__c();
        caseRoleObj.Case_Role_Status__c = 'Active';
        caseRoleObj.Entity__c = accObjList[0].Id;
        caseRoleObj.Role__c = 'Bank';
        caseRoleObj.Case__c = caseObj.Id;
        caseRoleList.add(caseRoleObj);
        Case_Role__c caseRoleObj1 = new Case_Role__c();
        caseRoleObj1.Case_Role_Status__c = 'Active';
        caseRoleObj1.Entity__c = accObjList[1].Id;
        caseRoleObj1.Role__c = 'Bank';
        caseRoleObj1.Case__c = caseObj.Id;
        caseRoleList.add(caseRoleObj1);
        Case_Role__c caseRoleObj2 = new Case_Role__c();
        caseRoleObj2.Case_Role_Status__c = 'Active';
        caseRoleObj2.Entity__c = accObjList[2].Id;
        caseRoleObj2.Role__c = 'Bank';
        caseRoleObj2.Case__c = caseObj.Id;
        caseRoleList.add(caseRoleObj2);
        insert caseRoleList;
        return caseRoleList;
    }
    public static Map<string,Set<string>> createBusinessWithRbMap(){
        Set<Id> allAccountIdsSet = new Set<Id>();
        Set<Id> businessIdsSet = new Set<Id>();
        Set<Id> relatedBusinessIdSet = new Set<Id>();
        Map<string,Set<string>> businessWithRbMap = new Map<string,Set<string>>();
        List<Related_Businesses__c> relatedBusinessObjList = DIRDataFactory.createRelatedBusinessRec();
        for(Related_Businesses__c relatedBusiness : relatedBusinessObjList){
            relatedBusinessIdSet.add(relatedBusiness.Related_Business__c);
            if(businessWithRbMap.containsKey(relatedBusiness.Related_Business__c)){
                businessWithRbMap.get(relatedBusiness.Related_Business__c).add(relatedBusiness.Business__c);
            }else{
                businessWithRbMap.put(relatedBusiness.Related_Business__c,new Set<String>{relatedBusiness.Business__c});
            }
            allAccountIdsSet.add(relatedBusiness.Related_Business__c);
            allAccountIdsSet.add(relatedBusiness.Business__c);
        }
        return businessWithRbMap;
    }
    
    public static List<Related_Businesses__c> createRelatedBusinessesTestData1(){
        List<Related_Businesses__c> relatedBusinessList = new List<Related_Businesses__c>();
        List<Account> accObjList = DIRDataFactory.createBusinessTestRecord();
        for(Integer i=5;i<10;i++){
            Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
            relatedBusinessObj.Business__c = accObjList[i].Id;
            relatedBusinessObj.Related_Business__c = accObjList[9-i].Id;
            relatedBusinessObj.Type__c = 'Single Enterprise';
            relatedBusinessObj.Name__c = 'test' + i;
            relatedBusinessList.add(relatedBusinessObj);
        }
        insert relatedBusinessList;
        return relatedBusinessList;
    }
    public static Liable_Party__c createTestLiablePartyRecord(){
        Liability__c liabilityObj = new Liability__c();
        liabilityObj.Industry__c = 'testLiability';
        Assessments__c assessmentObj = DIRDataFactory.createAssessmentTestRecord();
        liabilityObj.Assessment__c = assessmentObj.id;
        liabilityObj.Appeal_Deadline__c = System.today();
        insert liabilityObj;
        List<Account> accObj = DIRDataFactory.createBusinessTestRecord();
        Liable_Party__c liablePartyObj = new Liable_Party__c();
        liablePartyObj.sfxId__c = 'testLiableParty';
        liablePartyObj.Liability__c = liabilityObj.Id;
        liablePartyObj.Entity__c = accObj[0].id;
        insert liablePartyObj;
        return liablePartyObj;
    }
    public static Liable_Party__c createTestLiablePartyRecords(){
        Liability__c liabilityObj = new Liability__c();
        liabilityObj.Industry__c = 'testLiability';
        Assessments__c assessmentObj = DIRDataFactory.createAssessmentTestRecord();
        liabilityObj.Assessment__c = assessmentObj.id;
        liabilityObj.Appeal_Deadline__c = System.today();
        insert liabilityObj;
        List<Account> accObj = DIRDataFactory.createBusinessTestRecord();
        Liable_Party__c liablePartyObj = new Liable_Party__c();
        liablePartyObj.sfxId__c = 'testLiableParty';
        liablePartyObj.Liability__c = liabilityObj.Id;
        liablePartyObj.Entity__c = accObj[0].id;
        insert liablePartyObj;
        return liablePartyObj;
    }
    public static DIR_Case__c caseManagementTestData(){
        List<Account> accObj = DIRDataFactory.createBusinessTestRecord();
        DBA__c dbaObj = new DBA__c();
        dbaObj.Name = 'test';
        dbaObj.Account__c = accObj[0].Id;
        insert dbaObj;
        
        DIR_Case__c dirCaseMangementObj = new DIR_Case__c();
        dirCaseMangementObj.Employer__c = accObj[0].id;
        insert dirCaseMangementObj;
        /*Case_Role__c caseRoleObj = new Case_Role__c();
        caseRoleObj.Entity__c = accObj[0].id;
        caseRoleObj.Role__c = 'Claimant';
        caseRoleObj.Case__c = dirCaseMangementObj.Id;
        insert caseRoleObj;
        Case_Role__c caseRoleObj1 = new Case_Role__c();
        caseRoleObj1.Entity__c = accObj[0].id;
        caseRoleObj1.Role__c = 'Claimant';
        caseRoleObj1.Case__c = dirCaseMangementObj.Id;
        insert caseRoleObj1;*/
        return dirCaseMangementObj;
    }
    public static DBA__c createBDARec(){
        List<Account> accObj = DIRDataFactory.createBusinessTestRecord();
        DBA__c dbaObj = new DBA__c();
        dbaObj.Name = 'test';
        dbaObj.Account__c = accObj[0].Id;
        insert dbaObj;
        return dbaObj;
    }
    public static List<Case_Role__c> createCaseRoleRec(){
        List<Account> accObj = DIRDataFactory.createBusinessTestRecord();
        DIR_Case__c caseManagementObj = DIRDataFactory.caseManagementTestData();  
        List<Case_Role__c> caseRoleList = new List<Case_Role__c>();
        Case_Role__c caseRoleObj = new Case_Role__c();
        caseRoleObj.Case__c = caseManagementObj.Id;
        caseRoleObj.Role__c = 'Claimant';
        caseRoleObj.Entity__c = accObj[0].id;
        caseRoleList.add(caseRoleObj);
        Case_Role__c caseRoleObj1 = new Case_Role__c();
        caseRoleObj1.Case__c = caseManagementObj.Id;
        caseRoleObj1.Role__c = 'Plaintiff';
        caseRoleObj1.Entity__c = accObj[0].id;
        caseRoleList.add(caseRoleObj1);
        insert caseRoleList;
        return caseRoleList;
    }
    public static List<Judgement__c> createJudgmentSearchRecords(){
        DIR_Case__c caseManagementObj = DIRDataFactory.caseManagementTestData();
        List<Judgement__c> judgmentRecordList = new List<Judgement__c>();
        for(Integer i=0;i<5;i++){
            Judgement__c judgmentRecordObj = new Judgement__c();
            judgmentRecordObj.X2810_4_List_Status__c = 'Confirmed-On List';
            judgmentRecordObj.Judgement_Date__c = System.today();
            judgmentRecordObj.Case_Management__c = caseManagementObj.id;
            judgmentRecordObj.Status__c = 'Open';
            judgmentRecordList.add(judgmentRecordObj);
        }
        insert judgmentRecordList;
        return judgmentRecordList;
    }
    public static List<Liability_Judgement__c> createLiabilityTestData(){
        List<Judgement__c> judgementObj = DIRDataFactory.createJudgmentSearchRecords();
        List<Liability_Judgement__c> liabilityJudgmentList = new List<Liability_Judgement__c>();
        Liable_Party__c liablePartyObj = DIRDataFactory.createTestLiablePartyRecord();
        List<Account> accObj = DIRDataFactory.createBusinessTestRecord();
        for(Integer i=0;i<4;i++){
            Liability_Judgement__c liabilityObj = new Liability_Judgement__c();
            liabilityObj.X2810_4_List_Status__c = 'Confirmed-On List';
            liabilityObj.Judgement__c = judgementObj[0].id;
            liabilityObj.Liable_Party__c = liablePartyObj.id;
            liabilityObj.Liable_Party__r.Entity__c = liablePartyObj.Entity__c;
            liabilityJudgmentList.add(liabilityObj);
        }
        insert liabilityJudgmentList;
        return liabilityJudgmentList;
    }
    public static DIR_Case__c createCaseManagementTestRecord(){
        DIR_Case__c dirCaseMangementObj = new DIR_Case__c();
        dirCaseMangementObj.Deputy_Notes__c = 'Test';
        insert dirCaseMangementObj;
        return dirCaseMangementObj;
    }
    public static Assessments__c createAssessmentTestRecord(){
        DIR_Case__c dirCaseMangementObj = DIRDataFactory.createCaseManagementTestRecord();
        Assessments__c assessmentObj = new Assessments__c();
        assessmentObj.Industry__c = 'testAssessmentIndustry';
        assessmentObj.Case_Management__c = dirCaseMangementObj.Id;
        insert assessmentObj;
        return assessmentObj;
    }
    public static Judgement__c createTestJudgmentRecord(){
        DIR_Case__c dirCaseMangementObj = DIRDataFactory.createCaseManagementTestRecord();
        Judgement__c judgmentObj = new Judgement__c();
        judgmentObj.Description__c = 'test1';
        judgmentObj.Case_Management__c = dirCaseMangementObj.id;
        judgmentObj.Status__c = 'Open';
        insert judgmentObj;
        return judgmentObj;
    }
    
    public static List<Liability_Judgement__c> createLiabilityJudgmentTestRecords(){
        List<Liability_Judgement__c> liabilityObjList = new List<Liability_Judgement__c>();
        List<Judgement__c> judgmentObj = DIRDataFactory.createJudgmentSearchRecords();
        for(Integer i=0;i<4;i++){
            Liability_Judgement__c liableJudgmentObj = new Liability_Judgement__c();
            liableJudgmentObj.Judgement__c = judgmentObj[i].Id;
            liableJudgmentObj.X2810_4_List_Status__c = 'Confirmed-on List';
            liabilityObjList.add(liableJudgmentObj);
        }
        insert liabilityObjList;
        return liabilityObjList;
    }
    
    public static List<Liability_Judgement__c> createLiabilityJudgmentTestRecord(){
        List<Liability_Judgement__c> liabilityObjList = new List<Liability_Judgement__c>();
        List<Judgement__c> judgmentObj = DIRDataFactory.createJudgmentSearchRecords();
        Liable_Party__c liablePartyObj = DIRDataFactory.createTestLiablePartyRecord();
        for(Integer i=0;i<4;i++){
            Liability_Judgement__c liableJudgmentObj = new Liability_Judgement__c();
            liableJudgmentObj.Judgement__c = judgmentObj[i].Id;
            liableJudgmentObj.Liable_Party__c = liablePartyObj.Id;
            liableJudgmentObj.X2810_4_List_Status__c = 'Confirmed-on List';
            liabilityObjList.add(liableJudgmentObj);
        }
        insert liabilityObjList;
        return liabilityObjList;
    }
    public static Office__c createOfficeTestRecord(){
        Id officeRecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        Office__c officeObj = new Office__c();
        officeObj.Name = 'RCI South';
        officeObj.RecordTypeId = officeRecordTypeId;
        insert officeObj;
        return officeObj;
    }
    public static List<DIR_Case__c> createWageClaimDetailsTestData(){
        List<DIR_Case__c> wageClaimDetailsTestRecordsList = new List<DIR_Case__c>();
        Office__c officeObj = DIRDataFactory.createOfficeTestRecord();
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        for(Integer i=0;i<4;i++){
            System.debug('name in office record '+officeObj.Name);
            DIR_Case__c caseObj = new DIR_Case__c();
            caseObj.Office__c = officeObj.Id;
            caseObj.RecordTypeId = caseRecordTypeId;
            caseObj.Case_Number__c = 'JEU-CM Test';
            caseObj.Docketed_Date__c = System.today();
            caseObj.Case_Closed_Date__c = System.today();
            caseObj.Date_of_Docket__c = System.today();
            caseObj.Status__c = 'New';
            caseObj.X2810_4_Applies__c = 'Yes';
            caseObj.Low_Wage_Occupation__c = 'Port';
            wageClaimDetailsTestRecordsList.add(caseObj);
        }
        insert wageClaimDetailsTestRecordsList;
        return wageClaimDetailsTestRecordsList;
        
    }
    public static Case_role__c createCaseRoleTestRecord(){
        List<Account> accountObj = DIRDataFactory.createAccount();
        List<DIR_Case__c> dirCase = DIRDataFactory.createWageClaimDetailsTestData();
        Case_role__c CaseRoleObj = new Case_role__c();
        CaseRoleObj.Case__c = dirCase[0].id;
        CaseRoleObj.Entity__c = accountObj[0].id;
        CaseRoleObj.Role__c = 'Plaintiff';
        CaseRoleObj.Case_Role_Status__c = 'Active';
        insert CaseRoleObj;
        return CaseRoleObj;
    }
    
    public static List<DIR_Case__c> createCaseManagement(){
        List<DIR_Case__c> dirObjList = new List<DIR_Case__c>();
        for(Integer i=0;i<2;i++){
            DIR_Case__c dirObj = new DIR_Case__c();
            dirObj.Low_Wage_Occupation__c = 'Port';
            dirObjList.add(dirObj);
        }
        insert dirObjList;
        return dirObjList;
    }
    public static Case_Role__c createCaseRoleRecs(){
        List<Account> accObj = DIRDataFactory.createBusinessTestRecord();
        List<DIR_Case__c> caseManagementObj = DIRDataFactory.createCaseManagement();  
        Case_Role__c caseRoleObj = new Case_Role__c();
        caseRoleObj.Case__c = caseManagementObj[0].Id;
        caseRoleObj.Role__c = 'Claimant';
        caseRoleObj.Entity__c = accObj[0].id;
        insert caseRoleObj;
        return caseRoleObj;
    }
    public static Attachments_New__c createAttachmentNewRecord(){
        List<DIR_Case__c> caseManagementObj = DIRDataFactory.createCaseManagement();
        Attachments_New__c attachNewObj = new Attachments_New__c();
        attachNewObj.Related_Id__c = caseManagementObj[0].Id;
        attachNewObj.Release_to_Public__c = true;
        attachNewObj.File_Name__c = 'test doc';
        insert attachNewObj;
        return attachNewObj;
    }
    
    public static ContentVersion createContentVersionRecord(){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;   
        return contentVersion;
    }
    public static ContentDocumentLink createContentDocumentLinks(){
        Attachments_New__c attachnewObj = DIRDataFactory.createAttachmentNewRecord();
        ContentVersion conDocObj = DIRDataFactory.createContentVersionRecord();
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
        conDocLinkObj.LinkedEntityId = attachnewObj.Id;
        conDocLinkObj.ContentDocumentId = documents[0].id;
        insert conDocLinkObj;
        return conDocLinkObj;
    }
    public static List<Account> accForRelatedBusinessUpdateTrigger(){
        List<Account> accList = new List<Account>();
        for(Integer i=0; i<3 ;i++){
            Account accObj = new Account();
            accObj.Name = 'test' + i;
            accList.add(accObj);
        }
        insert accList;
        return accList;
    }
    
    public static List<Related_Businesses__c> createRelatedBusinessInverseRecord(){
        List<Account> accList = DIRDataFactory.accForRelatedBusinessUpdateTrigger();
        List<Related_Businesses__c> relatedBusinessList = new List<Related_Businesses__c>();
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = accList[1].id;
        relatedBusinessObj.Related_Business__c = accList[0].id;
        relatedBusinessObj.Type__c = 'Predecessor';
        relatedBusinessObj.Name__c = 'businessName';
        relatedBusinessList.add(relatedBusinessObj);
        insert relatedBusinessList;
        return relatedBusinessList;
    }
    public static Map<Id,Related_Businesses__c> createRelatedBusinessRecord(){
        List<Account> accList = DIRDataFactory.accForRelatedBusinessUpdateTrigger();
        List<Related_Businesses__c> relatedBusinessList = DIRDataFactory.createRelatedBusinessInverseRecord();
        Map<Id,Related_Businesses__c> relatedBusinessMap = new Map<Id,Related_Businesses__c>();
        relatedBusinessList[0].Type__c = 'Alter Ego'; 
        relatedBusinessMap.put(relatedBusinessList[0].Id, relatedBusinessList[0]);
        return relatedBusinessMap;
    }
    public static Liability_Judgement__c createRelatedBusinessObj(){
        Judgement__c judgmentObj = DIRDataFactory.createTestJudgmentRecord();
        List<Account> accList = DIRDataFactory.createBusinessTestRecord();
        Liable_Party__c liablePartyObj = DIRDataFactory.createTestLiablePartyRecord();
        Liability_Judgement__c liableJudgmentObj = new Liability_Judgement__c();
        liableJudgmentObj.Liable_Party__c = liablePartyObj.Id;
        liableJudgmentObj.X2810_4_List_Status__c = 'Confirmed-on List';
        liableJudgmentObj.Judgement__c = judgmentObj.Id;
        insert liableJudgmentObj;
        return liableJudgmentObj;
    }
    public static Judgement__c createJudgmentRecord(){
        List<DIR_Case__c> caseManagementObj = DIRDataFactory.createCaseManagement();
        Judgement__c judgmentRecordObj = new Judgement__c();
        judgmentRecordObj.X2810_4_List_Status__c = 'Confirmed-On List';
        judgmentRecordObj.Judgement_Date__c = System.today();
        judgmentRecordObj.Case_Management__c = caseManagementObj[0].id;
        judgmentRecordObj.Status__c = 'Open';
        insert judgmentRecordObj;
        return judgmentRecordObj;
    }
    public static Liability_Judgement__c createRelatedBusinessObjs(){
        Judgement__c judgmentObj = DIRDataFactory.createJudgmentRecord();
        List<Account> accList = DIRDataFactory.createBusinessTestRecord();
        Liable_Party__c liablePartyObj = DIRDataFactory.createTestLiablePartyRecord();
        Liability_Judgement__c liableJudgmentObj = new Liability_Judgement__c();
        liableJudgmentObj.Liable_Party__c = liablePartyObj.Id;
        liableJudgmentObj.X2810_4_List_Status__c = 'Confirmed-on List';
        liableJudgmentObj.Judgement__c = judgmentObj.Id;
        insert liableJudgmentObj;
        return liableJudgmentObj;
    }
    public static DIR_Case__c createCaseForContentLink(){
        DIR_Case__c caseObj = new DIR_Case__c();
        caseObj.Low_Wage_Occupation__c = 'Port';
        insert caseObj;
        return caseObj;
    }
    
    public static ContentVersion createContentDocument(){
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        return cv;
    }
    public static ContentDocumentLink createContentDocumentLink(){
        DIR_Case__c caseObj = DIRDataFactory.createCaseForContentLink();
        ContentVersion cv = DIRDataFactory.createContentDocument();
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = caseObj.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        return cdl;
    }
    public static Set<Id> createContentdocumentIdList(){
        ContentDocumentLink conDocLink = DIRDataFactory.createContentDocumentLink();
        Set<Id> contentdocumentIdList = new Set<Id>();
        contentdocumentIdList.add(conDocLink.Id);
        return contentdocumentIdList;
    }
    public static Attachments_New__c createAttachmentRec(){
        DIR_Case__c caseObj = DIRDataFactory.createCaseForContentLink();
        Attachments_New__c attachObj = new Attachments_New__c();
        attachObj.Related_Id__c = caseObj.Id;
        attachObj.File_Type__c = 'Related Files';
        attachObj.File_Name__c = 'Test Document';
        attachObj.Release_to_Public__c = true;
        insert attachObj;
        return attachObj;
    }
    public static ContentVersion createContentDocumentForAttachmentObj(){
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        return cv;
    }
    public static ContentDocumentLink createContentDocumentLinkForAttachmentObj(String conDocId){
        Attachments_New__c attachObj = DIRDataFactory.createAttachmentRec();
        //ContentVersion cv = DIRDataFactory.createContentDocumentForAttachmentObj();
        //Get Content Documents
        //Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = attachObj.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        return cdl;
    }
    public static Map<string,Set<string>> createCheckCaseRoleForRelatedPartyRecord(){
        Set<Id> allAccountIdsSet = new Set<Id>();
        Set<Id> businessIdsSet = new Set<Id>();
        Set<Id> relatedBusinessIdSet = new Set<Id>();
        Map<string,Set<string>> businessWithRbMap = new Map<string,Set<string>>();
        List<Related_Businesses__c> relatedBusinessList = new List<Related_Businesses__c>();
        List<Account> accObjList = DIRDataFactory.createBusinessTestRecord();
        DIR_Case__c caseObj = DIRDataFactory.caseManagementTestData();
        List<Case_Role__c> caseRoleList = new List<Case_Role__c>();
        Case_Role__c caseRoleObj = new Case_Role__c();
        caseRoleObj.Case_Role_Status__c = 'Active';
        caseRoleObj.Entity__c = accObjList[0].Id;
        caseRoleObj.Role__c = 'Bank';
        caseRoleObj.Case__c = caseObj.Id;
        caseRoleList.add(caseRoleObj);
        Case_Role__c caseRoleObj1 = new Case_Role__c();
        caseRoleObj1.Case_Role_Status__c = 'Active';
        caseRoleObj1.Entity__c = accObjList[1].Id;
        caseRoleObj1.Role__c = 'Bank';
        caseRoleObj1.Case__c = caseObj.Id;
        caseRoleList.add(caseRoleObj1);
        Case_Role__c caseRoleObj2 = new Case_Role__c();
        caseRoleObj2.Case_Role_Status__c = 'Active';
        caseRoleObj2.Entity__c = accObjList[2].Id;
        caseRoleObj2.Role__c = 'Bank';
        caseRoleObj2.Case__c = caseObj.Id;
        caseRoleList.add(caseRoleObj2);
        insert caseRoleList;
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = accObjList[0].Id;
        relatedBusinessObj.Case_Management_Id__c = caseObj.Id;
        relatedBusinessObj.Related_Business__c = accObjList[1].Id;
        relatedBusinessObj.Type__c = 'Single Enterprise';
        relatedBusinessObj.Name__c = 'test';
        Related_Businesses__c relatedBusinessObj1 = new Related_Businesses__c();
        relatedBusinessObj1.Business__c = accObjList[2].Id;
        relatedBusinessObj1.Related_Business__c = accObjList[3].Id;
        relatedBusinessObj1.Case_Management_Id__c = caseObj.Id;
        relatedBusinessObj1.Type__c = 'Single Enterprise';
        relatedBusinessObj1.Name__c = 'test';
        relatedBusinessList.add(relatedBusinessObj1);
        insert relatedBusinessList;
        for(Related_Businesses__c relatedBusiness : relatedBusinessList){
            relatedBusinessIdSet.add(relatedBusiness.Related_Business__c);
            if(businessWithRbMap.containsKey(relatedBusiness.Related_Business__c)){
                businessWithRbMap.get(relatedBusiness.Related_Business__c).add(relatedBusiness.Business__c);
            }else{
                businessWithRbMap.put(relatedBusiness.Related_Business__c,new Set<String>{relatedBusiness.Business__c});
            }
            allAccountIdsSet.add(relatedBusiness.Related_Business__c);
            allAccountIdsSet.add(relatedBusiness.Business__c);
        }
        return businessWithRbMap;
    }
}