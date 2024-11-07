/**
 * Developer: Sathya Chandrasekar
 * Created: August, 2019
 **/ 

public class ReceiptCasesDialogController {
    @AuraEnabled
    public static List<DIR_Case__c> searchCases(String searchKey){
        
        if(String.isEmpty(searchKey)){            
            return null;
        }else{
            string s = '%'+searchKey+'%';

            return [SELECT Id, Case_Number__c, Assigned_Deputy__c, Total_Amount_Paid__c, Assigned_Deputy__r.Name, Employer__c, Employer__r.Name, RecordType.Name, Office__c, Office__r.Name
                        FROM DIR_Case__c
                        WHERE (Case_Number__c LIKE :s
                                OR Employer__r.Name LIKE :s)
                            AND Assigned_Deputy__r.Name != null
                            AND Office__c != null
                            AND (NOT Office__r.Name LIKE '%OUT OF STATE')
                        ORDER BY Case_Number__c
                        LIMIT 10];
        }
    }
    
    @AuraEnabled
    public static List<EditCases> getgridCases(String ids){
        Set<String> caseIds = new Set<String>();
        for(String s : ids.split(',')){
            caseIds.add(s);
        }
        
        List<DIR_Case__c> caseL = [Select Id, Case_Number__c, RecordType.Name, Employer__c, Employer__r.Name from DIR_Case__c where id in: caseIds];
        Decimal amount = 0;
        
        List<EditCases> eCases = new List<EditCases>();
        for(DIR_Case__c c : caseL){
            EditCases ec = new EditCases(c.Id, c.Case_Number__c, c.RecordType.Name ,c.Employer__r.Name, amount);
            eCases.add(ec);
        }
        
        return eCases;
    }
    
    public class EditCases{
        
        public EditCases(String IdCase, String caseNo, String recType,String employer, Decimal allocatedAmount){
            this.IdCase = IdCase;
            this.caseNo = caseNo;
            this.recType = recType;
            this.employer = employer;
            this.allocatedAmount = allocatedAmount;
        }
        
        @AuraEnabled
        public String IdCase {get;set;}
        @AuraEnabled
        public String caseNo {get;set;}
        @AuraEnabled
        public String recType {get;set;}
        @AuraEnabled
        public String employer {get;set;}
        @AuraEnabled
        public Decimal allocatedAmount {get;set;}
    }
    
}