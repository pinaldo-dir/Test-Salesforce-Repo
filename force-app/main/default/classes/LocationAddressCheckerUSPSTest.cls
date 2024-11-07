@isTest
public with sharing class LocationAddressCheckerUSPSTest {
    
    @isTest static void getAccountAddressTest(){
        Trigger_Settings__c ts = new Trigger_Settings__c(
            Name = 'GenerateFieldHistoryAction',
            Is_Active__c = false
        );
        insert ts;
        String addressJson = '{ "Address2": "250 HEMSTED DR","CarrierRoute": "C050","CentralDeliveryPoint": "N","City": "REDDING","DPVConfirmation": "D","DPVFootnotes": "AAN1","DeliveryPoint": "99","Footnotes": "H","ReturnText": "Default address: The address you entered was found but more information is needed (such as an apartment, suite, or box number) to match to a specific address.","State": "CA","Zip4": "0940","Zip5": "96002-0940",}';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('USPSDemoResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mock);
        Record_Type_Mapping__c custSet=new Record_Type_Mapping__c();
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        custset.Case_Rec_Type__c='BOFE_Investigation';
        custset.Name='BOFE';
        custset.Violation_Type_Rec_Type__c='BOFE L.C. 238(f) – Subsequent Violations';
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
        mainA.ShippingCity='REDDING';
        mainA.ShippingState='CA';
        mainA.ShippingStreet='250 HEMSTED DR';
        mainA.ShippingPostalCode = '234889';
        insert mainA;

        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert AffA;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = mainA.Id;
        c.Status__c = 'New';
        c.RecordTypeId =caseRecordTypeId ;
        insert c;
        OwcVioltaionController.LoadCase(c.Id);
        
        System.debug('Test Violation'+ c.Id);
        
        Address__c addObj = new Address__c();
        addObj.Entity__c = mainA.Id;
        addObj.Active_Location__c = true;
        addObj.Type__c = 'Primary';
        insert addObj;
        string tempvar= addObj.id;

        System.debug('before case role4');
        
        Related_Businesses__c relatedBusinessObj = new Related_Businesses__c();
        relatedBusinessObj.Business__c = affA.Id;
        relatedBusinessObj.Related_Business__c = mainA.Id;
        relatedBusinessObj.Type__c = 'Alter Ego';
        insert relatedBusinessObj;
        System.debug('before case role5');  
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = c.Id;
        System.debug(c.Id);
        cr.Entity__c = affA.Id;
        cr.Role__c = 'Employer';
        cr.Case_Role_Status__c = 'Active On Case';
        cr.Account_Name__c = mainA.Name;
        insert cr;
        System.debug('before case role6');
        
        
        Related_Party__c party = new Related_Party__c();
        party.Account__c=mainA.Id;
        party.Case_Management__c=c.Id;
        party.Business_account__c=affA.Id;
        party.City__c='REDDING';
        party.State__c='CA';
        party.Street_Address__c='250 HEMSTED DR';
        party.Zip_Code__c='96002';
        insert party;
     
        Related_Party__c part = new Related_Party__c();
        part.Account__c=mainA.Id;
        part.Case_Management__c=c.Id;
        part.Business_account__c=affA.Id;
        insert part;
        Test.startTest();
        LocationAddressCheckerUSPS.verifyAddressByUSPS(addressJson);
        //accountAddressCheckerUSPS.getAccountAddress(tempvar);
        LocationAddressCheckerUSPS.getLocationAddress(addObj.Id);
        LocationAddressCheckerUSPS.updateLocationAddress('{"Address":[{"Address2":"250 HEMSTED DR","CarrierRoute":"C050","CentralDeliveryPoint":"N","City":"REDDING","DPVConfirmation":"D","DPVFootnotes":"AAN1","DeliveryPoint":"99","Footnotes":"H","ReturnText":"Default address: The address you entered was found but more information is needed (such as an apartment, suite, or box number) to match to a specific address.","State":"CA","Zip4":"0940","Zip5":"96002-0940"}]}',tempvar);
        
        Test.stopTest();
        
   }
}