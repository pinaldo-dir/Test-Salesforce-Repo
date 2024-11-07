public with sharing class position_Methods {
    public static void beforeInsert(List<Position__c> newlist){
        Set<String> unitNumbers = new Set<String>();
        for(Position__c p : newlist) {
            if(!p.Serial_Number__c.isNumeric()) {
                p.addError('Serial Number must be numeric');
                continue;
            }
            if(Integer.valueOf(p.Serial_Number__c) >= 900) {
                p.Manual_Entry__c = false;
                p.PY__c = null;
            }
            if(p.Manual_Entry__c == true) {
                p.addError('Cannot create Position without a 607 if serial number is less than 900');
            }
            if(p.Reporting_Unit_CodeNo__c != null && p.Reporting_Unit_CodeNo__c != '') {
                unitNumbers.add(p.Reporting_Unit_CodeNo__c);
            }
        }
        
        Map<String, String> unitNumberToDivision = new Map<String, String>();
        //10/19/2022 Removed Division__c and replaced it with Unit_Name__c in query (per HR CR SR-013912 )
        for(Unit__c unit : [select Id, Name, Unit_Name__c from Unit__c where Name in :unitNumbers]) {
            unitNumberToDivision.put(unit.Name, unit.Unit_Name__c);
        }
        
        for(Position__c p : newlist) {
            if(unitNumberToDivision.containsKey(p.Reporting_Unit_CodeNo__c)) {
                p.Division_Name__c = unitNumberToDivision.get(p.Reporting_Unit_CodeNo__c);
            }
        }
        
        Map<String, String> unitNumberToDivision1 = new Map<String, String>();
        for(Unit__c unit : [select Id, Name, Location__c from Unit__c where Name in :unitNumbers]) {
            unitNumberToDivision1.put(unit.Name, unit.Location__c);
        } 

        for(Position__c p : newlist) {
            if(unitNumberToDivision1.containsKey(p.Reporting_Unit_CodeNo__c)) {
                p.Location__c = unitNumberToDivision1.get(p.Reporting_Unit_CodeNo__c);
            }
        }
        
        
        
        Map<String, String> unitNumberToDivision2 = new Map<String, String>();
        for(Unit__c unit : [select Id, Name, Division_Unit__c from Unit__c where Name in :unitNumbers]) {
            unitNumberToDivision1.put(unit.Name, unit.Division_Unit__c);
        } 

        for(Position__c p : newlist) {
            if(unitNumberToDivision1.containsKey(p.Reporting_Unit_CodeNo__c)) {
                p.Division_Unit__c = unitNumberToDivision1.get(p.Reporting_Unit_CodeNo__c);
            }
        }
        
        
        
    }
    
    public static void beforeUpdate(List<Position__c> oldlist, List<Position__c> newlist){
        Set<String> unitNumbers = new Set<String>();
        for(Position__c p : newlist) {
            if(p.Reporting_Unit_CodeNo__c != null && p.Reporting_Unit_CodeNo__c != '') {
                unitNumbers.add(p.Reporting_Unit_CodeNo__c);
            }
        }
        
        Map<String, String> unitNumberToDivision = new Map<String, String>();
         //10/19/2022 Removed Division__c and replaced it with Unit_Name__c in query (per HR CR SR-013912 )
         for(Unit__c unit : [select Id, Name, Unit_Name__c from Unit__c where Name in :unitNumbers]) {
            unitNumberToDivision.put(unit.Name, unit.Unit_Name__c);
        }
        
        for(Position__c p : newlist) {
            if(unitNumberToDivision.containsKey(p.Reporting_Unit_CodeNo__c)) {
                p.Division_Name__c = unitNumberToDivision.get(p.Reporting_Unit_CodeNo__c);
            }
            if(p.Status__c =='Closed' || p.Status__c =='Abolished')
            {
                p.Position_Closed_Abolished__c = True;
            }
            else
                p.Position_Closed_Abolished__c = False;
        }
        
        
        
        Map<String, String> unitNumberToDivision2 = new Map<String, String>();
        for(Unit__c unit : [select Id, Name, Division_Unit__c from Unit__c where Name in :unitNumbers]) {
            unitNumberToDivision2.put(unit.Name, unit.Division_Unit__c);
        }
        
        for(Position__c p : newlist) {
            if(unitNumberToDivision.containsKey(p.Reporting_Unit_CodeNo__c)) {
                p.Division_Unit__c = unitNumberToDivision2.get(p.Reporting_Unit_CodeNo__c);
            }
        }
        
        
        
    }
    /*
    @isTest
    public static void position_Methods_UnitTest() {
        Unit__c unit = new Unit__c();
        unit.Division__c = 'TEST';
        unit.Name = '999';
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
        p.Serial_Number__c = '909';
        p.Reporting_Unit_CodeNo__c = unit.Name;
        insert p;
        
        update p;
    } */
    /*public static void updatePositionVacancy() {
        List<Position__c> positionsToUpdate = new List<Position__c>();
        for(Position__c p : [select Id, Status__c, Serial_Number__c, Separation_Date__c, (select Temporarily_Vacant__c, Start_Date__c, End_Date__c from Appointments__r) from Position__c where isActive__c = true]) {
            if(p.Appointments__r.size() == 0 && p.Status__c == 'Filled') {
                p.Status__c = 'Vacant';
            }
            if(p.Appointments__r.size() > 0) {
                Appointment__c lastAppointment = p.Appointments__r.get(p.Appointments__r.size() - 1);
                if(lastAppointment.End_Date__c != null && lastAppointment.End_Date__c <= system.today()) {
                    p.Status__c = 'Vacant';
                }
            }
            
            positionsToUpdate.add(p);
        }
        update positionsToUpdate;
    }*/
}