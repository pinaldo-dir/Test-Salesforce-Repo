public class CaseRoleTriggerHandler {
    public static boolean runAfterInsert = true;
    public static void afterInsertOperation(Map<Id, Case_Role__c> newCaseRolesMap){
        createCaseRoleForAssociatedAcounts(newCaseRolesMap);
    }
    private static void createCaseRoleForAssociatedAcounts(Map<Id, Case_Role__c> newCaseRolesMap){
        List<Associated_Agent_Case_Role_Types__mdt > mcs = Associated_Agent_Case_Role_Types__mdt.getAll().values();
        Set<String> validCaseRoleTypes = new Set<String>();
        for(Associated_Agent_Case_Role_Types__mdt mdt: mcs){
            validCaseRoleTypes.add(mdt.Case_Role__c);
        }
        system.debug('validCaseRoleTypes: '+validCaseRoleTypes);
        
        List<Case_Role__c> caseRolesToInsert = new List<Case_Role__c>();
        //List<Case_Note__c> caseNoteList = new List<Case_Note__c>();
        Map<Id, Set<Id>> CaseManagementWithAccountsMap = new Map<Id, Set<Id>>();
        Set<Id> CaseRoleIds = new Set<Id>();
        Set<Id> accountSetId = new Set<Id>();
        for(Case_Role__c cr : newCaseRolesMap.values()){
            if(cr.Case__c != null && cr.Case_Role_Status__c != 'No Longer Active On Case' && validCaseRoleTypes.contains(cr.Role__c)){
                CaseRoleIds.add(cr.Id);
                //CaseManagementSetId.add(cr.Case__c);
                if(CaseManagementWithAccountsMap.containsKey(cr.Case__c)){
                    CaseManagementWithAccountsMap.get(cr.Case__c).add(cr.Entity__c);
                }else{
                    CaseManagementWithAccountsMap.put(cr.Case__c, new Set<Id>{cr.Entity__c});
                } 
                accountSetId.add(cr.Entity__c);
            }
        }
        /*
        for(Case_Role__c cr: [SELECT Id,Case__c,Case_Role_Status__c,Entity__c,Case__r.Employer__c FROM Case_Role__c
                             WHERE Id IN: CaseRoleIds])
        {
            if(cr.Entity__c == cr.Case__r.Employer__c){
               if(CaseManagementWithAccountsMap.containsKey(cr.Case__c)){
                    CaseManagementWithAccountsMap.get(cr.Case__c).add(cr.Entity__c);
                }else{
                    CaseManagementWithAccountsMap.put(cr.Case__c, new Set<Id>{cr.Entity__c});
                } 
                accountSetId.add(cr.Entity__c);
            }
        }	*/
        
        //create Map for Associate Agents by Account Id
        Map<Id,List<Associated_Agents__c>> entityWithAssociatedAgentsMap = new Map<Id,List<Associated_Agents__c>>();
		for(Associated_Agents__c agent: [SELECT Id, Account__c, Associated_Account__c,Type__c FROM Associated_Agents__c 
                                       where Account__c In:accountSetId 
                                        AND Relationship_Status__c = true AND Type__c IN ('Agent for Service','Attorney','Employer Representative')]) 
        {
            if(entityWithAssociatedAgentsMap.containsKey(agent.Account__c)){
                entityWithAssociatedAgentsMap.get(agent.Account__c).add(agent);
            }else{
                entityWithAssociatedAgentsMap.put(agent.Account__c, new List<Associated_Agents__c>{agent});
            }
        }
        
        //get Other Case Roles for the Case Id
        Map<Id,Set<Id>> caseWithOtherCaseRoleEntityMap = new Map<Id,Set<Id>>();
        
        Map<Id,Dir_Case__C> activeCaseMap = new Map<Id,Dir_Case__C>([Select id,RecordType.name, Employer__c from Dir_Case__c  where ( Status__c != 'Closed' and Id In: CaseManagementWithAccountsMap.keySet())]);
        
        for(Dir_Case__C caseRecord: [Select id,RecordType.name, Employer__c,
                                     (SELECT Id,Case__c, Entity__c FROM Case_Roles__r 
                                      WHERE Case_Role_Status__c != 'No Longer Active On Case' AND Id Not IN: CaseRoleIds) 
                                     from Dir_Case__c  
                                     where ( Status__c != 'Closed' and Id In: CaseManagementWithAccountsMap.keySet())])
        {
            //check if there is no Case Role
            if(caseRecord.Case_Roles__r.isEmpty()){
                if(CaseManagementWithAccountsMap.containsKey(caseRecord.Id)){
                    for(Id accountId: CaseManagementWithAccountsMap.get(caseRecord.Id)){
                        if(entityWithAssociatedAgentsMap.containsKey(accountId)){
                            for(Associated_Agents__c agent: entityWithAssociatedAgentsMap.get(accountId)){
                                //create the new Case Role for the Case record
                                caseRolesToInsert.add(createCaseRole(caseRecord.Id, agent));
                            }
                        }
                    }
                }
            }else{
                for(Case_Role__c caseRole: caseRecord.Case_Roles__r){
                    if(caseWithOtherCaseRoleEntityMap.containsKey(caseRole.Case__c)){
                        caseWithOtherCaseRoleEntityMap.get(caseRole.Case__c).add(caseRole.Entity__c);
                    }else{
                        caseWithOtherCaseRoleEntityMap.put(caseRole.Case__c, new Set<Id>{caseRole.Entity__c});
                    }
                }
            }
        }
        
        
        //iterate on Case And ignore the process if Associated Account is already added on the Case Record
        for(Id caseId: caseWithOtherCaseRoleEntityMap.keySet()){
            if(CaseManagementWithAccountsMap.containsKey(caseId)){
                for(Id accountId: CaseManagementWithAccountsMap.get(caseId)){
                    if(entityWithAssociatedAgentsMap.containsKey(accountId)){
                        for(Associated_Agents__c agent: entityWithAssociatedAgentsMap.get(accountId)){
                            if(!caseWithOtherCaseRoleEntityMap.get(caseId).contains(agent.Associated_Account__c)){
                                //create the new Case Role for the Case record
                                caseRolesToInsert.add(createCaseRole(caseId, agent));
                            }
                        }
                    }
                }
            }
        }
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
        return caseRole;
    }
    
}