@isTest
public class OWCESignFlowActionToUpdateDocsNameTest {
    
    @isTest static void updateSelectedDefsAndDocsTest(){
        List<String> selectedDefendantsAndDocuments = new List<String>();
        Test.startTest();
        selectedDefendantsAndDocuments.add('5/WCA 026A-1');
        OWCESignFlowActionToUpdateDocsName.updateSelectedDefsAndDocs(selectedDefendantsAndDocuments);
        OWCESignFlowActionToUpdateDocsName.updateSelectedDefsAndDocs(new List<String>{'5/WCA 026B-1'});
        Test.stopTest();
    }
    
    @isTest static void updateSelectedDefsAndDocsTest1(){
        List<String> selectedDefendantsAndDocuments = new List<String>();
        Test.startTest();
        selectedDefendantsAndDocuments.add('4/WCA 026A-1');
        OWCESignFlowActionToUpdateDocsName.updateSelectedDefsAndDocs(selectedDefendantsAndDocuments);
        OWCESignFlowActionToUpdateDocsName.updateSelectedDefsAndDocs(new List<String>{'4/WCA 026B-1'});
        Test.stopTest();
    }
    
    @isTest static void updateSelectedDefsAndDocsTest2(){
        List<String> selectedDefendantsAndDocuments = new List<String>();
        Test.startTest();
        selectedDefendantsAndDocuments.add('3/WCA 026A-1');
        OWCESignFlowActionToUpdateDocsName.updateSelectedDefsAndDocs(selectedDefendantsAndDocuments);
        OWCESignFlowActionToUpdateDocsName.updateSelectedDefsAndDocs(new List<String>{'3/WCA 026B-1'});
        Test.stopTest();
    }
    
    @isTest static void updateSelectedDefsAndDocsTest3(){
        List<String> selectedDefendantsAndDocuments = new List<String>();
        Test.startTest();
        selectedDefendantsAndDocuments.add('2/WCA 026A-1');
        OWCESignFlowActionToUpdateDocsName.updateSelectedDefsAndDocs(selectedDefendantsAndDocuments);
        OWCESignFlowActionToUpdateDocsName.updateSelectedDefsAndDocs(new List<String>{'2/WCA 026B-1'});
        Test.stopTest();
    }
    
    @isTest static void updateSelectedDefsAndDocsTest4(){
        List<String> selectedDefendantsAndDocuments = new List<String>();
        Test.startTest();
        selectedDefendantsAndDocuments.add('1/WCA 026A-1');
        OWCESignFlowActionToUpdateDocsName.updateSelectedDefsAndDocs(selectedDefendantsAndDocuments);
        OWCESignFlowActionToUpdateDocsName.updateSelectedDefsAndDocs(new List<String>{'1/WCA 026B-1'});
        Test.stopTest();
    }
}