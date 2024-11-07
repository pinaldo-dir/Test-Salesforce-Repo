@IsTest
public class JudgmentSearchControllerTest {
    @IsTest
    static void testGetListStatus2810(){
        List<Judgment_List_Status_2810__mdt> judgmentListStatus2810List = [SELECT Label, Name__c FROM Judgment_List_Status_2810__mdt];
        Test.startTest();
        List<String> judgementStatusList = JudgmentSearchController.getListStatus2810();
        Test.stopTest();
        System.assertEquals(4, judgementStatusList.size());
    }
    @IsTest
    static void testGetJudgmentStatusPicklist(){ 
        List<Judgment_List_Status_2810__mdt	> judgmentStatusPicklist = [SELECT Label FROM Judgment_List_Status_2810__mdt	];
        Test.startTest();
        List<String> judgmentStatusPicklistList = JudgmentSearchController.getJudgmentStatusPicklist();
        Test.stopTest();
        System.assert(judgmentStatusPicklistList.size() > 0);
    }
    @IsTest
    static void testGetJudgmentDirOffice(){
        List<Judgment_Dir_Office__mdt> judgmentDirOffice = [SELECT Label FROM Judgment_Dir_Office__mdt];
        Test.startTest();
        List<String> judgmentDirOfficeMdtList = JudgmentSearchController.getJudgmentDirOffice();
        Test.stopTest();
    }
    @IsTest
    static void testFetchLookUpValues(){
        List<NAICS_Code__c> getNaicsCodeList = DIRDataFactory.createNaicsCodeTestData();
        String searchKeyword = '90';
        String ObjectName = 'NAICS_Code__c';
        String Name = 'Name';
        String filter = '';
        Test.startTest();
        List<JudgmentSearchController.resultWrapper> returnList = JudgmentSearchController.fetchLookUpValues('JudgmentSearch',searchKeyword, ObjectName, Name, filter);
        Test.stopTest();
        System.assert(returnList.size()>0);
    }
    @IsTest
    static void testGetAllPicklist(){
        Test.startTest();
        JudgmentSearchController.JudgmentWrapperClass JudgmentSearchWrapperObj = new JudgmentSearchController.JudgmentWrapperClass();
        JudgmentSearchWrapperObj = JudgmentSearchController.getAllPicklist('Germany');
        Test.stopTest();
    }
    @IsTest
    static void testFetchLookUpValuesById(){
        List<NAICS_Code__c> getNaicsCodeList = DIRDataFactory.createNaicsCodeTestData();
        String recordId = getNaicsCodeList[0].id;   
        String ObjectName = 'NAICS_Code__c';
        String Name = 'Name';
        Test.startTest();
        JudgmentSearchController.resultWrapper returnRecords = JudgmentSearchController.fetchLookUpValuesById(recordId, ObjectName, Name);
        Test.stopTest();
        System.assert(returnRecords != null);
    }
    @IsTest
    static void testGetSelectedNaicsTitle(){
        List<NAICS_Code__c> getNaicsCodeList = DIRDataFactory.createNaicsCodeTestData();
        String selectedNaicsCode = getNaicsCodeList[0].Name;
        Test.startTest();
        String NaicsTitle = JudgmentSearchController.getSelectedNaicsTitle(selectedNaicsCode);
        Test.stopTest();
        System.assertEquals('testTitle0', NaicsTitle);
    }
}