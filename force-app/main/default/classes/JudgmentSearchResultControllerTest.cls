@IsTest
public class JudgmentSearchResultControllerTest {
    @IsTest
    public static void testGetJudgmentRecords(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        System.debug('judgmentRecordsLists ::::::: '+judgmentRecordsLists);
        String listStatus2810 = '';
        String naicsCode = '';
        String accountName = '';
        String City = '';
        String ZipCode = '';
        Date judgmentEntryDateFrom = System.today();
        Date judgmentEntryDateTo = System.today();
        String court = '';
        String status = 'Open';
        List<String> judgmentStatus = status.split(',');
        String defandantEmployerName = '';
        Double judgmentTotalTo = 0;
        Double judgmentTotalFrom = 0;
        String citationNumber = '';
        String dirOffice = '';
        String county = '';
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        List<JudgmentSearchResultController.judgmentDetailsObj> judgmentRecList = JudgmentSearchResultController.getJudgmentRecords(listStatus2810, naicsCode, accountName, City, ZipCode, judgmentEntryDateFrom, judgmentEntryDateTo, court, judgmentStatus, defandantEmployerName, judgmentTotalFrom , judgmentTotalTo ,citationNumber, dirOffice, county);
        Test.stopTest();
        System.assertEquals(4, judgmentRecList.size());  
    }
    
     @IsTest
    public static void testGetJudgmentRecord(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecords();
        String listStatus2810 = '';
        String naicsCode = '';
        String accountName = '';
        String City = '';
        String ZipCode = '';
        Date judgmentEntryDateFrom = System.today();
        Date judgmentEntryDateTo = System.today();
        String court = '';
        String status = 'Open';
        List<String> judgmentStatus = status.split(',');
        String defandantEmployerName = '';
        Double judgmentTotalTo = 0;
        Double judgmentTotalFrom = 0;
        String citationNumber = '';
        String dirOffice = '';
        String county = '';
        Test.startTest();
        List<JudgmentSearchResultController.judgmentDetailsObj> judgmentRecList = JudgmentSearchResultController.getJudgmentRecords(listStatus2810, naicsCode, accountName, City, ZipCode, judgmentEntryDateFrom, judgmentEntryDateTo, court, judgmentStatus, defandantEmployerName, judgmentTotalFrom , judgmentTotalTo ,citationNumber, dirOffice, county);
        Test.stopTest();
        System.assertEquals(4, judgmentRecList.size());  
    }
   
    @IsTest
    public static void testGetPortDrayageRecords(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecords();
        Date asOfDate = System.today();
        Date fromDate = System.today();
        Date toDate = System.today();
        Test.startTest();
        List<JudgmentSearchResultController.judgmentDetailsObj> portDrayageRecList = JudgmentSearchResultController.getPortDrayageRecords(asOfDate, fromDate, toDate);
        Test.stopTest();
        System.assertEquals(4, portDrayageRecList.size());
    }
    @IsTest
    public static void testGetPortDrayageRecord(){
        List<Judgement__c> judgmentRecordsLists = DIRDataFactory.createJudgmentSearchRecords();
        Date asOfDate = System.today();
        Date fromDate = System.today();
        Date toDate = System.today();
        Test.startTest();
        List<Liability_Judgement__c> liabilityJudgmentList = DIRDataFactory.createLiabilityJudgmentTestRecord();
        List<JudgmentSearchResultController.judgmentDetailsObj> portDrayageRecList = JudgmentSearchResultController.getPortDrayageRecords(asOfDate, fromDate, toDate);
        Test.stopTest();
        System.assertEquals(4, portDrayageRecList.size());
    }
}