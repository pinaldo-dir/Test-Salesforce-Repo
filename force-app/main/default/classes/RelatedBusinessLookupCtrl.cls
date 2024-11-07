public class RelatedBusinessLookupCtrl {
    public String name{get; set;}
    public String rbname{get; set;}
    public String casemgtid{get;set;}
    public String bid{get;set;}
    public list<Case_Role__c> listAccountFromCaseRole{get;set;}
    public RelatedBusinessLookupCtrl(){
        try{
            casemgtid    ='';
            rbname  ='';
            name='';
            bid='';
            listAccountFromCaseRole = new List<Case_Role__c>();
            String lookupName = ApexPages.currentPage().getParameters().get('rbname');
            if(String.isNotBlank(lookupName)){
                rbname = ApexPages.currentPage().getParameters().get('rbname').replaceAll('%',' ');}
            
            String lookupId = ApexPages.currentPage().getParameters().get('bid');
            if(String.isNotBlank(lookupId)){
                bid = ApexPages.currentPage().getParameters().get('bid').replaceAll('%',' ');}
            
            String caseId = ApexPages.currentPage().getParameters().get('casemgtid');
            if(String.isNotBlank(caseId)){
                casemgtid = ApexPages.currentPage().getParameters().get('casemgtid').replaceAll('%',' ');}
            
            String lookupSearch = ApexPages.currentPage().getParameters().get('name');
            if(String.isNotBlank(lookupSearch)){
                name = ApexPages.currentPage().getParameters().get('name').replaceAll('%',' ');
            }
            onGo();
        }catch(Exception e){
            
        }
    }
    public PageReference onGo(){
        try{
            String queryStr;
            name = String.isNotBlank(name.trim()) ? String.escapeSingleQuotes(name.trim()) : '';
            if(name != '' && name != NULL){
                queryStr = 'SELECT Id,Entity__r.Name,Entity__c FROM Case_Role__c WHERE Entity__r.Name like \'%' + String.escapeSingleQuotes(name) + '%\' and Case__c =:casemgtid';
            }else{
                queryStr = 'SELECT Id,Entity__r.Name,Entity__c,Entity__r.Entity_Type__c FROM Case_Role__c WHERE Case__c =:casemgtid';
            }
            queryStr+= (name=='' ? ' ORDER BY CreatedDate DESC LIMIT 10 ' : ' ORDER BY CreatedDate DESC LIMIT 1000 ' );
            listAccountFromCaseRole.clear();
            List<Case_Role__c> allCaseRollAccount = Database.query(queryStr);
            Map<Id,Case_Role__c> caseRollMap = new Map<Id,Case_Role__c>();
            for(Case_Role__c caseRoll : allCaseRollAccount){
                if(!caseRollMap.containsKey(caseRoll.Entity__c)){
                    caseRollMap.put(caseRoll.Entity__c,caseRoll);
                } 
            }
            listAccountFromCaseRole = caseRollMap.values();
            
        }catch(Exception e){
            //Logger.logMessage('CallScriptLookupCtlr', 'onGo', e);
        }
        return null;
    }
    
}