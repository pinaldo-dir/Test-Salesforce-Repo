@IsTest
public class DirQuerySelectorTest {
    @IsTest static void testGetDuplicateRelatedBusinessRecord(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord(); 
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Related_Businesses__c> relatedBusinessRec = DIRDataFactory.createRelatedBusinessesTestData1();
        Set<Id> businessIdsSet = new Set<Id>();
        Set<Id> relatedBusinessIdsSet = new Set<Id>();
        for(Related_Businesses__c relObj : relatedBusinessRec){
            businessIdsSet.add(relObj.Business__c);
            relatedBusinessIdsSet.add(relObj.Related_Business__c);
        }
        Test.startTest();
        List<Related_Businesses__c> result = DirQuerySelector.getDuplicateRelatedBusinessRecord(businessIdsSet, relatedBusinessIdsSet);
        Test.stopTest();
        System.assertEquals(5, result.size());
    }
    @IsTest static void testGetRelatedBusinessRecord(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Related_Businesses__c> relatedBusinessRec = DIRDataFactory.createRelatedBusinessesTestData1();
        Test.startTest();
        Boolean result = DirQuerySelector.getRelatedBusinessRecord(relatedBusinessRec[0].Related_Business__c, relatedBusinessRec[0].Business__c);
        Test.stopTest();
        System.assertEquals(true, result);
    }
    @IsTest static void testGetValidBusinessForPositiveCase(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Account> accList = DIRDataFactory.createBusinessTestRecord();
        Test.startTest();
        Boolean result = DirQuerySelector.getValidBusiness(accList[0].id);
        Test.stopTest();
        System.assertEquals(true, result);
    }
    @IsTest static void testCheckCaseRoleForNotes(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Account> accList = DIRDataFactory.createBusinessTestRecord();
        Case_Role__c caseRoleObj = DIRDataFactory.caseRoleRecord(accList[0].id);
        Set<Id> accIds = new Set<Id>();
        for(Account accObj : accList){
            accIds.add(accObj.id);
        }
        Test.startTest();
        Map<Id, Case_Role__c> result = DirQuerySelector.checkCaseRoleForNotes(accIds);
        Test.stopTest();
        System.debug('testCheckCaseRoleForNotes ::: '+result);
    }
    @IsTest static void testCheckCaseRoleForRelatedParty(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        Map<string,Set<string>> businessWithRbMap = DIRDataFactory.createCheckCaseRoleForRelatedPartyRecord();
        Test.startTest();
        Map<Id,Set<Id>> result = DirQuerySelector.checkCaseRoleForRelatedParty(businessWithRbMap);
        Test.stopTest();
        System.debug('testCheckCaseRoleForRelatedParty ::: '+result);
    }
    @IsTest static void testGetJudgmentRecordWithZipCode(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        String listStatus2810 = 'test';
        String naicsCode = 'test';
        String accountName = '';
        String City = 'test';
        String ZipCode = '250001';
        Date judgmentEntryDateFrom = System.today() + 1;
        Date judgmentEntryDateTo = System.today();
        String court = 'test';
        String status = 'Open';
        List<String> judgmentStatus = status.split(',');
        String defandantEmployerName = 'test';
        Double judgmentTotalTo = 1;
        Double judgmentTotalFrom = 1;
        String citationNumber = 'test';
        String dirOffice = 'test';
        String county = 'test';
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        DirQuerySelector.judgmentSearchRecordWrapper judgmentRecList = DirQuerySelector.getJudgmentRecords(listStatus2810, naicsCode, accountName, City, ZipCode, judgmentEntryDateFrom, judgmentEntryDateTo, court, judgmentStatus, defandantEmployerName, judgmentTotalFrom , judgmentTotalTo ,citationNumber, dirOffice, county);
        Test.stopTest();
        System.debug('testGetJudgmentRecordWithZipCode ::: '+judgmentRecList);
    }
   @IsTest static void testGetJudgmentRecordWithCity(){
       Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
       Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        String listStatus2810 = 'test';
        String naicsCode = 'test';
        String accountName = '';
        String City = 'test';
        String ZipCode = '';
        Date judgmentEntryDateFrom = System.today() + 1;
        Date judgmentEntryDateTo = System.today();
        String court = 'test';
        String status = 'Open';
        List<String> judgmentStatus = status.split(',');
        String defandantEmployerName = 'test';
        Double judgmentTotalTo = 1;
        Double judgmentTotalFrom = 1;
        String citationNumber = 'test';
        String dirOffice = 'test';
        String county = 'test';
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        DirQuerySelector.judgmentSearchRecordWrapper judgmentRecList = DirQuerySelector.getJudgmentRecords(listStatus2810, naicsCode, accountName, City, ZipCode, judgmentEntryDateFrom, judgmentEntryDateTo, court, judgmentStatus, defandantEmployerName, judgmentTotalFrom , judgmentTotalTo ,citationNumber, dirOffice, county);
        Test.stopTest();
        System.debug('testGetJudgmentRecordWithCity ::: '+judgmentRecList);
    }
    @IsTest static void testGetJudgmentRecordWithCityAndZipCode(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        String listStatus2810 = 'test';
        String naicsCode = 'test';
        String accountName = '';
        String City = '';
        String ZipCode = 'test';
        Date judgmentEntryDateFrom = System.today() + 1;
        Date judgmentEntryDateTo = System.today();
        String court = 'test';
        String status = 'Open';
        List<String> judgmentStatus = status.split(',');
        String defandantEmployerName = 'test';
        Double judgmentTotalTo = 1;
        Double judgmentTotalFrom = 1;
        String citationNumber = 'test';
        String dirOffice = 'test';
        String county = 'test';
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        DirQuerySelector.judgmentSearchRecordWrapper judgmentRecList = DirQuerySelector.getJudgmentRecords(listStatus2810, naicsCode, accountName, City, ZipCode, judgmentEntryDateFrom, judgmentEntryDateTo, court, judgmentStatus, defandantEmployerName, judgmentTotalFrom , judgmentTotalTo ,citationNumber, dirOffice, county);
        Test.stopTest();
        System.debug('testGetJudgmentRecordWithCityAndZipCode ::: '+judgmentRecList);
    }
    @IsTest static void testGetJudgmentRecordWithoutCityAndZipCode(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        String listStatus2810 = 'test';
        String naicsCode = 'test';
        String accountName = '';
        String City = '';
        String ZipCode = '';
        Date judgmentEntryDateFrom = System.today() + 1;
        Date judgmentEntryDateTo = System.today();
        String court = 'test';
        String status = 'Open';
        List<String> judgmentStatus = status.split(',');
        String defandantEmployerName = 'test';
        Double judgmentTotalTo = 1;
        Double judgmentTotalFrom = 1;
        String citationNumber = 'test';
        String dirOffice = 'test';
        String county = 'test';
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        DirQuerySelector.judgmentSearchRecordWrapper judgmentRecList = DirQuerySelector.getJudgmentRecords(listStatus2810, naicsCode, accountName, City, ZipCode, judgmentEntryDateFrom, judgmentEntryDateTo, court, judgmentStatus, defandantEmployerName, judgmentTotalFrom , judgmentTotalTo ,citationNumber, dirOffice, county);
        Test.stopTest();
        System.debug('testGetJudgmentRecordWithoutCityAndZipCode ::: '+judgmentRecList);
    }
    @IsTest static void testGetJudgmentRecordWithAccountName(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        String listStatus2810 = 'test';
        String naicsCode = 'test';
        String accountName = 'test';
        String City = '';
        String ZipCode = '';
        Date judgmentEntryDateFrom = System.today() + 1;
        Date judgmentEntryDateTo = System.today();
        String court = 'test';
        String status = 'Open';
        List<String> judgmentStatus = status.split(',');
        String defandantEmployerName = 'test';
        Double judgmentTotalTo = 1;
        Double judgmentTotalFrom = 1;
        String citationNumber = 'test';
        String dirOffice = 'test';
        String county = 'test';
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        DirQuerySelector.judgmentSearchRecordWrapper judgmentRecList = DirQuerySelector.getJudgmentRecords(listStatus2810, naicsCode, accountName, City, ZipCode, judgmentEntryDateFrom, judgmentEntryDateTo, court, judgmentStatus, defandantEmployerName, judgmentTotalFrom , judgmentTotalTo ,citationNumber, dirOffice, county);
        Test.stopTest();
        System.debug('testGetJudgmentRecordWithAccountName ::: '+judgmentRecList);
    }
    @IsTest
    public static void testGetPortDrayageRecord(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecords();
        Date asOfDate = System.today();
        Date fromDate = System.today();
        Date toDate = System.today();
        Test.startTest();
        DirQuerySelector.judgmentSearchRecordWrapper portDrayageRecList = DirQuerySelector.getPortDrayageRecords(asOfDate, fromDate, toDate);
        Test.stopTest();
        System.debug('testGetPortDrayageRecord :::: '+portDrayageRecList);
    }
    @IsTest
    public static void testGetPortDrayageRecordWithoutAsOfDate(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecords();
        Date asOfDate;
        Date fromDate = System.today();
        Date toDate = System.today();
        Test.startTest();
        DirQuerySelector.judgmentSearchRecordWrapper portDrayageRecList = DirQuerySelector.getPortDrayageRecords(asOfDate, fromDate, toDate);
        Test.stopTest();
        System.debug('testGetPortDrayageRecordWithoutAsOfDate :::: '+portDrayageRecList);
    }
    @IsTest
    public static void testGetPortDrayageRecordWithCaseRole(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecords();
        Date asOfDate;
        Date fromDate = System.today();
        Date toDate = System.today();
        Test.startTest();
        List<Case_Role__c> caseRoleList = DIRDataFactory.createCaseRoleRec();
        DirQuerySelector.judgmentSearchRecordWrapper portDrayageRecList = DirQuerySelector.getPortDrayageRecords(asOfDate, fromDate, toDate);
        Test.stopTest();
        System.debug('testGetPortDrayageRecordWithCaseRole :::: '+portDrayageRecList);
    }
    @IsTest public static void testGetJudgmentDetails(){
        Trigger_Settings__c triggerSettingObj = DIRDataFactory.createTriggerCustomSettingRecord();
        Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1(); 
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        Map<Id,Related_Businesses__c> relatedBusinessMap = DIRDataFactory.createRelatedBusinessRecord();
        Liability_Judgement__c liableJudgmentObj = new Liability_Judgement__c();
        liableJudgmentObj.Related_Business__c = relatedBusinessMap.values()[0].Id;
        liableJudgmentObj.X2810_4_List_Status__c = 'Confirmed-on List';
        liableJudgmentObj.Judgement__c = judgmentRecordsLists[0].Id;
        insert liableJudgmentObj;
        Test.startTest();
        //Case_Role__c caseRoleList = DIRDataFactory.createCaseRoleRecs();
        DirQuerySelector.judgmentDetailModel result = DirQuerySelector.getJudgmentDetails(judgmentRecordsLists[0].Id, liableJudgmentObj.Id);
        Test.stopTest();
        System.debug('testGetJudgmentDetails :::: >?>>> '+result);
    }
    /*@IsTest(seeAllData=true) static void testGetJudgmentDetails(){
        //Trigger_Settings__c triggerSettingObj1 = DIRDataFactory.createTriggerCustomSettingRecord1();
        Account mainA = new Account(); 
        mainA.Name = 'Lucian459487';
        insert mainA;
        
        DIR_Case__c caseObj = DIRDataFactory.createCaseManagement(mainA.Id);
        
        
        Judgement__c judgmentRecordObj = new Judgement__c();
        judgmentRecordObj.X2810_4_List_Status__c = 'Confirmed-On List';
        judgmentRecordObj.Judgement_Date__c = System.today();
        judgmentRecordObj.Case_Management__c = caseObj.Id;
        judgmentRecordObj.Status__c = 'Open';
        insert judgmentRecordObj;
        
        //Liable_Party__c liablePartyObj = DIRDataFactory.createTestLiablePartyRecords();
        Map<Id,Related_Businesses__c> relatedBusinessMap = DIRDataFactory.createRelatedBusinessRecord();
        Liability_Judgement__c liableJudgmentObj = new Liability_Judgement__c();
        liableJudgmentObj.Related_Business__c = relatedBusinessMap.values()[0].Id;
        liableJudgmentObj.X2810_4_List_Status__c = 'Confirmed-on List';
        liableJudgmentObj.Judgement__c = judgmentRecordObj.Id;
        insert liableJudgmentObj;
        Test.startTest();
        //Case_Role__c caseRoleList = DIRDataFactory.createCaseRoleRecs();
        DirQuerySelector.judgmentDetailModel result = DirQuerySelector.getJudgmentDetails(judgmentRecordObj.Id, liableJudgmentObj.Id);
        Test.stopTest();
        System.debug('testGetJudgmentDetails :::: >?>>> '+result);
    }*/
}