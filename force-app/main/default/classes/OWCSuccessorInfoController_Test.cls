@isTest
public class OWCSuccessorInfoController_Test {
    @isTest static void fetchOwnershipMetaDataTest(){
        Test.startTest();
        OWCSuccessorInfoController.fetchOwnershipMetaData();
        OWCSuccessorInfoController.fetchHoursWorkedMetaData();
        Test.stopTest();
     }
    @isTest static void fetchOwnershipMetaDataTest1(){
      User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];        
         currentUserInfo.LanguageLocaleKey = 'es';
        update currentUserInfo; 
        
        Test.startTest();
        OWCSuccessorInfoController.fetchOwnershipMetaData();
        OWCSuccessorInfoController.fetchHoursWorkedMetaData();
        Test.stopTest();
     }
    
    
}