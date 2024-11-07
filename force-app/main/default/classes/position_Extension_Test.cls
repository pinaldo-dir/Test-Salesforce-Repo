@isTest
(SeeAllData = true)
public with sharing class position_Extension_Test 
{
    public static testMethod void position_extension_UnitTest()
    {
        Position__c p = new Position__c();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(p);
        position_Extension pe = new position_Extension(sc);
        pe.save();
        pe.searchUnit();
        pe.searchClassification();
        
        pe.position.Reporting_Unit_CodeNo__c = 'xxx';
        pe.position.Class_Title_CodeNo__c = 'xxxx';
        pe.searchUnit();
        pe.searchClassification();
        
        pe.position.Reporting_Unit_CodeNo__c = '152';
        pe.position.Class_Title_CodeNo__c = '1441';
        pe.position.Serial_Number__c = '909';
        pe.searchUnit();
        pe.searchClassification();
        
        pe.createForm1Onload();
        position_Extension.formatString('0', 4);
        
        //coverage for lines 13-14  public position_Extension(apexPages.standardController controller) method inside If statement
        Position__c p1 = new Position__c();
        p1.Reporting_Unit_CodeNo__c = '152';
        p1.Class_Title_CodeNo__c = '1441';
        p1.Serial_Number__c = '909';
        insert p1;
        ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(p1);
        position_Extension p1e = new position_Extension(sc1);
        
        
        //coverage for lines 28-32 public PageReference createForm1OnLoad() method inside If statement
        Position__c p2 = new Position__c();
        p2.Reporting_Unit_CodeNo__c = '152';
        p2.Class_Title_CodeNo__c = '1441';
        p2.Serial_Number__c = '909';
        insert p2;
         ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(p2);
        position_Extension p2e = new position_Extension(sc2);
       
        PageReference pageRef = ApexPages.currentPage();
        String form = 'form';
        pageRef.getParameters().put('id',p2.id);
        pageRef.getParameters().put('form',form);
        pageRef = p2e.createForm1OnLoad();
        

	}
}