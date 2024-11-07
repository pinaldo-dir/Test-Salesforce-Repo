public class JudgmentSearchController {
    @AuraEnabled
    public static JudgmentWrapperClass getAllPicklist(String selectedCounty){
        JudgmentWrapperClass wrapperObj = new JudgmentWrapperClass();
        wrapperObj.listStatus = getListStatus2810();
        wrapperObj.judgmentStatusPicklist = getJudgmentStatusPicklist();
        wrapperObj.dirOffice = getJudgmentDirOffice();
        wrapperObj.countyList = getCountyList();
        wrapperObj.courtHouseMap = getCourtHouse(selectedCounty);
        return wrapperObj;
    }
    public static List<String> getListStatus2810() 
    {
        List<String> options = new List<String>();
        for(Judgment_List_Status_2810__mdt mdtObj : [SELECT Label, Name__c FROM Judgment_List_Status_2810__mdt]){
            options.add(mdtObj.Name__c);
        }
        options.add('Not Applicable');
        return options;
    }
    @AuraEnabled
    public static List<String> getCourtHouse(String selectedCounty){
        List<String> listOfSelectedCourtHouseCounty = new List<String>();
        List<Office__c> officeList = [SELECT Id, Name, County__c FROM Office__c WHERE County__c =: selectedCounty AND RecordType.Name = 'CourtHouse'];
        for(Office__c officeObj : officeList){
            listOfSelectedCourtHouseCounty.add(officeObj.Name);
        }
        listOfSelectedCourtHouseCounty.sort();
        return listOfSelectedCourtHouseCounty;
    }
    public static List<String> getCountyList() 
    {
        List<String> options = new List<String>();
        for(AggregateResult county : [SELECT County__c FROM Office__c group by county__c]){
            options.add(String.ValueOf(county.get('County__c')));
        }
        return options;
    }
    
    public static List<String> getJudgmentStatusPicklist() 
    {
        List<String> options = new List<String>();
        string fieldName = 'Status__c';
        String objectName = 'Judgement__c';
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.getValue() == 'Pending/Open'){
                
            }
            else{
                options.add(pickListVal.getValue());
            }
        } 
        return options;
    }
    
    public static List<String> getJudgmentDirOffice() 
    {
        List<String> options = new List<String>();
        for(Judgment_Dir_Office__mdt mdtObj : [SELECT Label FROM Judgment_Dir_Office__mdt Order By Label ASC]){
            options.add(mdtObj.Label);
        }
        return options;
    }
    
    @AuraEnabled
    public static List<resultWrapper> fetchLookUpValues(String searchType,String searchKeyWord, String ObjectName, String fieldAPIName, String filter) {
        String searchKey;
        String sQuery;
        List<String> RecordType;
        if(ObjectName == 'NAICS_Code__c'){
            searchKey = searchKeyWord + '%';
        }
        else{
            searchKey = '%' + searchKeyWord + '%';
        }
        
        if(searchType == 'JudgmentSearch'){
            RecordType = new List<String>{'BOFE','Garment','JEU','RCI','WCA','License/Registration'};
                }
        else if(searchType == 'WageClaimSearch'){
            RecordType = new List<String>{'Garment','WCA'};
                }
        List <sObject> returnList = new List <sObject> ();
        sQuery =  'select id,'+fieldAPIName+' from ' +ObjectName + ' where '+fieldAPIName+' LIKE: searchKey';
        if(String.isNotEmpty(filter)){
            sQuery+= ' And county__c =\'' + filter + '\' ';
        }
        if(ObjectName == 'Office__c'){
            sQuery += ' AND RecordType.Name =: RecordType ';
        }
        if(ObjectName == 'NAICS_Code__c'){
            sQuery += ' order by Name ASC limit 9';
        }
        else{
            sQuery += ' order by createdDate DESC limit 9';
        }
        
        system.debug('sQuery: '+sQuery);
        List <sObject> lstOfRecords = Database.query(sQuery);
        
        List<resultWrapper> wrapperList = new List<resultWrapper>();
        for (sObject obj: lstOfRecords) {
            wrapperList.add(new resultWrapper((String) obj.id, (String) obj.get(fieldAPIName))); 
        }
        return wrapperList;
    }
    
    @AuraEnabled
    public static ResultWrapper fetchLookUpValuesById(String recordId, String ObjectName, String fieldAPIName) 
    {
        ResultWrapper wrapperObj = new ResultWrapper();
        String sQuery =  'SELECT Id,'+fieldAPIName+' FROM ' +ObjectName + ' WHERE Id = :recordId';
        
        List <sObject> lstOfRecords = Database.query(sQuery);
        if(!lstOfRecords.isEmpty()){
            wrapperObj = new ResultWrapper((String) lstOfRecords[0].id, (String) lstOfRecords[0].get(fieldAPIName));    
        }
        return wrapperObj;
    }
    
    
    public Class resultWrapper {
        @AuraEnabled 
        public String id { get; set; }
        @AuraEnabled 
        public String label { get; set; }
        public resultWrapper(String id, String label) {
            this.id = id;
            this.label = label;
        }
        
        public resultWrapper(){
            
        }
    }
    @AuraEnabled
    public static String getSelectedNaicsTitle(String selectedNaicsCode){
        String naicsCodeTitle = [SELECT Id, Name, NAICS_Title__c FROM NAICS_Code__c WHERE Name =: selectedNaicsCode].NAICS_Title__c;
        return naicsCodeTitle;
    }
    
    public class JudgmentWrapperClass{
        @AuraEnabled
        public List<String> listStatus;
        @AuraEnabled
        public List<String> judgmentStatusPicklist;
        @AuraEnabled
        public List<String> dirOffice;
        @AuraEnabled
        public List<String> countyList;
        @AuraEnabled
        public List<String> courtHouseMap;
    }
}