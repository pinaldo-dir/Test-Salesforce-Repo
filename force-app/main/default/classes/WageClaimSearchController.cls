public class WageClaimSearchController {
	 //public searchClass searchClassObj {get; set;}
    @AuraEnabled
    public static WageClaimWrapperClass getAllPicklist(){
        WageClaimWrapperClass wrapperObj = new WageClaimWrapperClass();
        wrapperObj.dirOffice = getJudgmentDirOffice();
        wrapperObj.lowWage = getLowWageOccupationPicklist();
        return wrapperObj;
    }
    public static List<String> getJudgmentDirOffice() 
    {
        List<String> options = new List<String>();
        for(Judgment_Dir_Office__mdt mdtObj : [SELECT Label FROM Judgment_Dir_Office__mdt Order By Label ASC]){
            options.add(mdtObj.Label);
        }
        return options;
    }
    
    
    public static List<String> getLowWageOccupationPicklist() 
    {
        List<String> options = new List<String>();
        string fieldName = 'Low_Wage_Occupation__c';
        String objectName = 'DIR_Case__c';
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            options.add(pickListVal.getValue());
        } 
        return options;
    }
    
    public class WageClaimWrapperClass{
       
        @AuraEnabled
        public List<String> dirOffice;
        @AuraEnabled
        public List<String> lowWage;
       
    }
}