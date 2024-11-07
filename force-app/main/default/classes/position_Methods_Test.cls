@isTest
(SeeAllData = true)
public with sharing class position_Methods_Test {
    public static testMethod void position_Methods_UnitTest() {
        Unit__c unit = new Unit__c();
        unit.Division__c = 'DLSE';
        unit.Name = '999';
        unit.Division_Unit__c = 'DWC/LBI';
        unit.Location__c = 'TestLoc';
        insert unit;
        
        Position__c p = new Position__c();
        p.Reporting_Unit_CodeNo__c = unit.Name;
        try {
            p.Serial_Number__c = 'asdf';
            insert p;
            p = new Position__c();
            p.Reporting_Unit_CodeNo__c = unit.Name;
        }
        catch (Exception e) {}
        try {
            p.Serial_Number__c = '123';
            insert p;
            p = new Position__c();
            p.Reporting_Unit_CodeNo__c = unit.Name;
        }
        catch (Exception e) {}
        try {
            p.Serial_Number__c = '123';
            p.Status__c = 'Abolished';
            insert p;
        }
        catch (Exception e) {}
        
        p.Serial_Number__c = '909';
        p.Reporting_Unit_CodeNo__c = unit.Name;
        insert p;        
        update p;
        Position__c p2 = new Position__c();
        p2.Serial_Number__c = '988';
        insert p2;
        update p2;
        
    }
}