@isTest
public class OWCAssociateAgentController_Test {
    @isTest
     public static void saveValuesTest(){
          Trigger_Settings__c ts = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        insert ts;
     Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        Record_Type_Mapping__c custSet=new Record_Type_Mapping__c();
        custset.Case_Rec_Type__c='BOFE'; 
        custset.Name='BOFE';
        custset.Violation_Type_Rec_Type__c='BOFE';
        insert custset;
        
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
        insert AffA;
       
         
         Associated_Agents__c agent =new Associated_Agents__c();
         agent.Account__c=mainA.Id;
         agent.Type__c='Client';
         agent.Associated_Account__c=affA.Id;
         insert agent;
         OWCAssociateAgentController.saveValues(affA.Id,mainA.Id,agent.Type__c,true,null);
         OWCAssociateAgentController.saveValues(mainA.Id,affA.Id,agent.Type__c,false,'Please enter valid reason for Inactive relationship');
         
         
     }
    

}