@isTest
public class OWCESignFlowActionToCountDefIdsTest {
    
    @isTest static void getNoOfDefendantsTest(){
        List<String> defendantIds = new List<String>();
        Test.startTest();
        defendantIds.add('a16d00000055PxzAAE;a16d00000055Py9AAE');
        OWCESignFlowActionToCountDefIds.getNoOfDefendants(defendantIds);
        Test.stopTest();
    }

}