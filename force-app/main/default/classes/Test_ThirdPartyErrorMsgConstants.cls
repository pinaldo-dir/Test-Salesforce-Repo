@istest 
public class Test_ThirdPartyErrorMsgConstants {
    
    @istest public static void testThirdPartyErrorMsgConstants(){
        Test.startTest();
        ThirdPartyErrorMsgConstants.caseNumberErrorMsg('123');
        ThirdPartyErrorMsgConstants.claimantLastNameErrorMsg('123','test');
        ThirdPartyErrorMsgConstants.meetingsAndHearingMsg('123');
        ThirdPartyErrorMsgConstants.contentDataErrorMsg('test');
        Test.stopTest();
    }
}