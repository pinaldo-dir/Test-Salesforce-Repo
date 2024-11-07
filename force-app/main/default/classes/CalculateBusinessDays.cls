/*********************************************************************
Usage   : This class is used to calculate a date based on number of days from a given start date and the BusinessHours object.
            Currently only called by AccountingDepositBatch to set the Receipt__c.Hold_Date__c when depositing.
*********************************************************************/

public with sharing class CalculateBusinessDays {
    
    BusinessHours businessHoursInstance;
    public CalculatebusinessDays(){
        businessHoursInstance = [SELECT Id, IsActive, IsDefault FROM BusinessHours WHERE IsActive = true AND IsDefault = true
                                    WITH SECURITY_ENFORCED];        
    }
    
    public Date addBusinessDays(Date startDate, Integer days){        
        
        Datetime newDatetime = Datetime.newInstance(startDate.year(), startDate.month(),startDate.day());
        system.debug('newDatetime: ' + newDatetime);
        system.debug('days: ' + days);

        Integer hours = 24;
        Integer minutes = 60;
        Integer seconds = 60;
        Integer milliseconds = 1000;
        Integer millisecondsInADay = hours * minutes * seconds * milliseconds;
        
        newDatetime = BusinessHours.add(businessHoursInstance.Id, newDatetime, days * millisecondsInADay);

        // If newDatetime falls on a holiday, advance a day or until newDatetime is within working hours (i.e., not Saturday nor Sunday).
        // ** As of Sept 2021, no holidays have been configured for our Org. Until there are holidays, this while loop will do nothing.
        while(!BusinessHours.isWithin(businessHoursInstance.Id, newDatetime)){            
            newDatetime = newDatetime.addDays(1);
            system.debug(newDatetime);
            
        }
        
        return newDatetime.date();
    }
}