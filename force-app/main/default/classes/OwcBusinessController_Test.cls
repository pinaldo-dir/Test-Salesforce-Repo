@isTest
public class OwcBusinessController_Test {
    @isTest static void fetchOwcEmployerBussinessTest(){
    Test.startTest();
        OwcBusinessController.fetchOwcEmployerBussiness();
        OwcBusinessController.fetchOwcWorkRecorded();
        Test.stopTest();
    }
     @isTest static void fetchOwcEmployerBussinessTest1(){
          User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId() limit 1];        
         currentUserInfo.LanguageLocaleKey = 'es';
        update currentUserInfo;
         Test.startTest();
        OwcBusinessController.fetchOwcEmployerBussiness();
        OwcBusinessController.fetchOwcWorkRecorded();
        Test.stopTest();
     }
    
   
}