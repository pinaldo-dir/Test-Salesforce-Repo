public class AssociatedAgentsTriggerHandler {
    Public static Boolean isFirstTime = true;
    public static void beforeInsertOperation(List<Associated_Agents__c> newRecords){
        Set<Id> accountIsSet = new Set<Id>();
        //pupulate the description on the new records
        for(Associated_Agents__c agent: newRecords){
            if(agent.Account__c != null && agent.Associated_Account__c != null){
                accountIsSet.add(agent.Account__c);
                accountIsSet.add(agent.Associated_Account__c);
                
            }
        }
       	Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN: accountIsSet]);
        //pupulate the description on the new records
        for(Associated_Agents__c agent: newRecords){
            if(agent.Account__c != null && agent.Associated_Account__c != null){
                agent.Description__c = accountMap.get(agent.Associated_Account__c ).Name + ' is the '+agent.Type__c +' for '+accountMap.get(agent.Account__c).Name;
            }
        }
    }
    
    public static void afterInsertOperation(List<Associated_Agents__c> newRecords){
        List<Associated_Agents__c> AssociatedAgentsList = new List<Associated_Agents__c>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> associatedAccountIds = new Set<Id>();
        Map<Id, Set<Id>> associatedAccountWithAccountId = new Map<Id, Set<Id>>();
        createInverseAssociatedAgents(newRecords);
        for(Associated_Agents__c agent: newRecords){
            if(agent.Relationship_Status__c && (agent.Type__c == 'Agent for Service' || agent.Type__c == 'Attorney' || agent.Type__c == 'Employer Representative')){
                AssociatedAgentsList.add(agent);
                accountIds.add(agent.Account__c);
                if(associatedAccountWithAccountId.containsKey(agent.Associated_Account__c)){
                    associatedAccountWithAccountId.get(agent.Associated_Account__c).add(agent.Account__c);
                }else{
                    associatedAccountWithAccountId.put(agent.Associated_Account__c, new Set<Id>{agent.Account__c});
                }
                associatedAccountIds.add(agent.Associated_Account__c);
            }
        }
        if(AssociatedAgentsList.size() >0)	{
            creteCaseRoleForAssociatedAccount(AssociatedAgentsList, accountIds,associatedAccountWithAccountId, associatedAccountIds);
        }		
    }
    /**********************************************************
    *Method Name : createInverseAssociatedAgents
    *Description : it would create the inverse RBO whenever the rbo is created.
    **/
    public static void createInverseAssociatedAgents(List<Associated_Agents__c> associatedAgentsList){
        List<Associated_Agents__c> inverseAssociatedAgentsList = new List<Associated_Agents__c>();
        for(Associated_Agents__c associatedAgents : associatedAgentsList){
            inverseAssociatedAgentsList.add(createInverseAssociatedAgentsRecord(associatedAgents));
        }
        if(inverseAssociatedAgentsList.size() > 0){
            insert inverseAssociatedAgentsList;
        }
    }
    
    /***********************************************************
	*Method Name : createInverseAssociatedAgentsRecord
	*Description : calling from the 'createInverseAssociatedAgents' which will create the individual inverse relationship. 
	**/
    public static Associated_Agents__c createInverseAssociatedAgentsRecord(Associated_Agents__c associatedAgents){
        Map<String,String> associatedAgentsInverseMap = new Map<String,String>();
       
        for(Associated_Agents_Type_Inverse__mdt inverseMap : Associated_Agents_Type_Inverse__mdt.getall().values()){
            associatedAgentsInverseMap.put(inverseMap.Current_Type__c,inverseMap.Inverse_Type__c);
        }
        Associated_Agents__c aa = new Associated_Agents__c();
        //aa.Name__c = associatedAgents.Name__c;
        aa.Associated_Account__c = associatedAgents.Account__c;
        aa.Account__c = associatedAgents.Associated_Account__c;
        //aa.Additional_information__c = associatedAgents.Additional_information__c;
        if(associatedAgentsInverseMap.containskey(associatedAgents.Type__c)){
            aa.Type__c = associatedAgentsInverseMap.get(associatedAgents.Type__c);
        } 
        return aa;
    }
    //creteCaseRoleForAssociatedAccount
    private static void creteCaseRoleForAssociatedAccount(List<Associated_Agents__c> AssociatedAgentsList,Set<Id> accountIds, Map<Id, Set<Id>> associatedAccountWithAccountId, set<Id> associatedAccountIds){
        List<Case_Role__c> caseRolesToInsert = new List<Case_Role__c>();
        List<Case_Note__c> caseNotesToInsert = new List<Case_Note__c>(); 
        Set<String> CasewithAccountId = new Set<String>();
        Set<String> agentsToIgnore = new Set<String>();
        Map<Id, Set<Id>> CaseWithAccountMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> caseWithAssociatedMap = new Map<Id, Set<Id>>();
        
        for(Case_Role__c  caseRole : [select Id,Case__c ,Entity__c from Case_Role__c  
                                      where Role__c != null
                                      and Entity__c In:accountIds 
                                      and (Case__r.Status__c != 'Closed' and Case_Role_Status__c != 'No Longer Active On Case')])
        {	
            CasewithAccountId.add(caseRole.Case__c+''+caseRole.Entity__c);
            if(CaseWithAccountMap.containsKey(caseRole.Entity__c)){
                CaseWithAccountMap.get(caseRole.Entity__c).add(caseRole.Case__c);
            }else{
                CaseWithAccountMap.put(caseRole.Entity__c, new Set<Id>{caseRole.Case__c});
            } 
        }
        system.debug('CaseWithAccountMap: '+CaseWithAccountMap);
        //identify the case where the Associated Account is already added as Case Role
        for(Case_Role__c  caseRole : [select Id,Case__c ,Entity__c from Case_Role__c  
                                      where Case__c Not IN: CaseWithAccountMap.keySet()
                                      and Entity__c In:associatedAccountIds 
                                      and (Case__r.Status__c != 'Closed' and Case_Role_Status__c != 'No Longer Active On Case')])
        {
            for(String accountId: associatedAccountWithAccountId.get(caseRole.Entity__c))
            {
                if(CasewithAccountId.contains(caseRole.Case__c+accountId)){
                    agentsToIgnore.add(accountId+''+caseRole.Entity__c+''+caseRole.Case__c);
                }
            }                             
        }
        system.debug('agentsToIgnore: '+agentsToIgnore);
        for(Associated_Agents__c agent: AssociatedAgentsList){
            if(CaseWithAccountMap.containsKey(agent.Account__c)){
                for(String caseId: CaseWithAccountMap.get(agent.Account__c)){
                    if(!agentsToIgnore.contains(agent.Account__c+''+agent.Associated_Account__c+''+caseId)){
                        //create the Case Role and Case Note for the Associated Account
                        caseRolesToInsert.add(createCaseRole(caseId, agent));
                        //String notes = 'caseId';
                        //caseNotesToInsert.add(createCaseNote(caseId, notes));
                    }
                }
            }
        }
        system.debug('caseRolesToInsert: '+caseRolesToInsert);
        if(caseRolesToInsert.size() >0) 	insert caseRolesToInsert;
    }
    
    private static Case_Role__c createCaseRole(String CaseId, Associated_Agents__c agent){
        Map<String, String> roleValuesMap = new Map<String, String>{'Agent for Service'=>'Agent for Service of Process','Attorney'=> 'Defendant Attorney','Employer Representative'=> 'Defendant Representative'};          
        Case_Role__c caseRole = new Case_Role__c();
        caseRole.Entity__c = agent.Associated_Account__c;
        caseRole.Case__c = CaseId;
        caseRole.Role__c  = roleValuesMap.get(agent.Type__c);
        caseRole.Also_Related_To__c = agent.Account__c;
        caseRole.Relationship_to_Claimant__c = roleValuesMap.get(agent.Type__c) + ' for';
        caserole.RecordTypeId = OWCConstants.WCA_CASE_ROLE_RECORD_TYPE_ID;
        return caseRole;
    }
    /*
	*   Method Name : createCaseNotes
	*   Description : 
	**/
    public static Case_Note__c createCaseNote(Id CaseId, string caseNote){
        Case_Note__c caseNoteObj = new Case_Note__c();
        caseNoteObj.Event_Note__c = caseNote;
        caseNoteObj.Case_Management__c = CaseId;
        caseNoteObj.Event_Date_Time__c = datetime.now();
        return caseNoteObj;
    }
}