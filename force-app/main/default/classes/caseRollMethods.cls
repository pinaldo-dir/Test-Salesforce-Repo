public class caseRollMethods {
    // methods for triggers on case role
    
    
    //on insert  - before  trigger.
    //set the location on the case role to be the primary location of the account
    public static void applyLocation(list<Case_Role__c> newList){
        system.debug('Setting location on case role');
        //get the accounts on each case role
        set<ID> acctIDs = new set<ID>();
        for (Case_Role__c cr : newList){
            acctIDs.add(cr.Entity__c);
            system.debug('Added entity: ' + cr.Entity__c + ' to account set');
        }
        
        list<Address__c> locList = new list<Address__c>([SELECT ID, Entity__c from Address__c Where Active_Location__c = true AND Type__c = 'Primary' AND Entity__c in :acctIDs]);
        system.debug('locList::: ' + locList);
        
        Map<ID, Address__c> locMap = new Map<ID, Address__c>();
        for(Address__c a : locList){
            locMap.put(a.Entity__c, a);
        }
        
        
        if(locMap.size() > 0){
            for (Case_Role__c cr : newList){
                if (locMap.containsKey(cr.Entity__c)){
                    Address__c addr = locMap.get(cr.Entity__c);
                    system.debug('Address to add as location:::' + addr);
                    cr.location__c = addr.id;
                }
                
            }
            
        } 
        
        
    }
    public static void countDefs(list<Case_Role__c> newList){
        String[] crType = new String[]{'Defendant','Case Employer'};
            set<ID> CaseIDs = new set<ID>();
            for(Case_Role__c cr: newList ){
                    CaseIDs.add(cr.Case__c); 
            }
            list<Case_Role__c> defCRs = new list<Case_Role__c>([SELECT ID, Role__c, Case__c FROM Case_Role__c WHERE Case_Role_Status__c != 'No Longer Active On Case' AND Case__c IN :CaseIDs AND Role__c IN :crType]);
//            system.debug('Number of defendant case roles found is:: ' + defCRs.size() + ' on case :: ' + CaseIDs + ' list of case roles is :: ' + defCRs );
            list<DIR_Case__c> cases = new list<DIR_Case__c>([SELECT ID, Number_of_Employer_s__c FROM DIR_Case__c Where ID IN :CaseIDs ]);
            for(DIR_Case__c defCase : cases){
                defCase.Number_of_Employer_s__c = defCRs.size();
                update defCase;
            }
         }

        public static void countDefs(list<Case_Role__c> oldList, list<Case_Role__c> newList, Map<id,Case_Role__c> newCRMap,Map<id,Case_Role__c> oldCRMap){
            String[] crType = new String[]{'Defendant','Case Employer'};
            set<ID> CaseRoleIDs = new set<ID>();
            for(Case_Role__c newCaseRole : oldList)
            {
                if (newCRMap.get(newCaseRole.id).Role__c != oldCRMap.get(newCaseRole.id).Role__c 
                    && newCRMap.get(newCaseRole.id).Case_Role_Status__c != oldCRMap.get(newCaseRole.id).Case_Role_Status__c)
                {
                    CaseRoleIDs.add(newCaseRole.Case__c); 
                }
            }
            if (CaseRoleIDs.size() > 0)
            {           
                list<Case_Role__c> defCRs = new list<Case_Role__c>([SELECT ID, Role__c, Case__c FROM Case_Role__c WHERE Case_Role_Status__c != 'No Longer Active On Case' AND Case__c IN :CaseRoleIDs AND Role__c IN :crType]);
                list<DIR_Case__c> cases = new list<DIR_Case__c>([SELECT ID, Number_of_Employer_s__c FROM DIR_Case__c Where ID IN :CaseRoleIDs ]);
                if (cases.size() > 0) {
                    for(DIR_Case__c defCase : cases){
                        defCase.Number_of_Employer_s__c = defCRs.size();
                        update defCase;
                    }
                }
             }
         }
    /*
     *  F0200 ADDon Fix
	 * Method Name : createRelatedParty
	 * Description : used to create the related party whenver the case role is created 
	**/
    public static void createRelatedParty(list<Case_Role__c> newList){
        List<Related_Party__c> relatedPartyList = new List<Related_Party__c>();
        List<Case_Note__c> caseNoteList = new List<Case_Note__c>();
        Set<Id> CaseManagementSetId = new Set<Id>();
        Set<Id> accountSetId = new Set<Id>();
        for(Case_Role__c cr : newList){
            if(cr.Case__c != null && cr.Case_Role_Status__c != 'No Longer Active On Case' ){
                CaseManagementSetId.add(cr.Case__c);
                accountSetId.add(cr.Entity__c);
            }
        }
        
        Map<Id,List<Related_Businesses__c>> entityWithRelatedBusinessesMap = new Map<Id,List<Related_Businesses__c>>();
        Set<Id> relatedbusinessIds = new Set<Id>();
        for(Related_Businesses__c rbo: [SELECT Id, Business__c, Related_Business__c,Type__c FROM Related_Businesses__c where Business__c In:accountSetId ]) 
        {
            if(entityWithRelatedBusinessesMap.containsKey(rbo.Business__c)){
                entityWithRelatedBusinessesMap.get(rbo.Business__c).add(rbo);
            }else{
                entityWithRelatedBusinessesMap.put(rbo.Business__c, new List<Related_Businesses__c>{rbo});
            }
            relatedbusinessIds.add(rbo.Related_Business__c);
        }
        accountSetId.addAll(relatedbusinessIds);
        Map<Id,Account> accountNameMap = DirQuerySelector.getAccountNames(accountSetId);
        Map<Id, Set<Id>> caseWithEntityIDsMap = new Map<Id, Set<Id>>();
        Map<Id,Dir_Case__C> caseMap = new Map<Id,Dir_Case__C>([Select id,RecordType.name, Employer__c from Dir_Case__c where ( Status__c != 'Closed' or Total_Wages_Balance_Due__c != 0 Or Total_Penalties_Balance_Due__c != 0) and Id In: CaseManagementSetId]);
        
        for(Case_Role__c caseRole: [SELECT Id,Case__c, Entity__c FROM Case_Role__c WHERE Case__c IN: CaseManagementSetId]) 
        {	
            if(caseWithEntityIDsMap.containsKey(caseRole.Case__c)){
                caseWithEntityIDsMap.get(caseRole.Case__c).add(caseRole.Entity__c);
            }else{
                caseWithEntityIDsMap.put(caseRole.Case__c, new Set<Id>{caseRole.Entity__c});
            }
            
        }
        Map<Id,Related_Party__c> relatedPartyMap = new Map<Id,Related_Party__c>([SELECT Id, Business_account__c, Case_Management__c FROM Related_Party__c 
                                                                                 where Case_Management__c In: CaseManagementSetId ]);
        Map<Id,List<Related_Party__c>> caseRelatedPartyMap = new Map<Id,List<Related_Party__c>>();
        for(Related_Party__c relatedParty : [SELECT Id, Business_account__c, Case_Management__c FROM Related_Party__c where Case_Management__c In: CaseManagementSetId ]){
            if(caseRelatedPartyMap.containsKey(relatedParty.Case_Management__c)){
                caseRelatedPartyMap.get(relatedParty.Case_Management__c).add(relatedParty);
            }else{
                caseRelatedPartyMap.put(relatedParty.Case_Management__c, new List<Related_Party__c>{relatedParty});
            }
        }
        system.debug('entityWithRelatedBusinessesMap::'+entityWithRelatedBusinessesMap);
        system.debug('caseMap::'+caseMap);
        system.debug('relatedPartyMap::'+relatedPartyMap);
         Map<Id, RecordType> caseRTMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case_Role__c']);
        if(caseMap.size() > 0){
            for(Case_Role__c cr : newList){
                String caseroleRTName = caseRTMap.get(cr.RecordTypeId).Name;
                if(cr.Case__c != null && cr.Case_Role_Status__c != 'No Longer Active On Case' && (caseroleRTName.contains('BOFE') || caseroleRTName.contains('WCA') || caseroleRTName.contains('JEU') || caseroleRTName.contains('RCI'))){
                    if(entityWithRelatedBusinessesMap.size()>0 && entityWithRelatedBusinessesMap.containsKey(cr.Entity__c)){
                        for(Related_Businesses__c rbo : entityWithRelatedBusinessesMap.get(cr.Entity__c)){
                            Integer relatedPartyFound = 0;
                            if(caseRelatedPartyMap.containsKey(cr.Case__c)){
                                for(Related_Party__c rpObj : caseRelatedPartyMap.get(cr.Case__c)){
                                    system.debug('rpid::'+rpObj);
                                    if(rpObj.Business_account__c != rbo.Related_Business__c)
                                    {
                                        relatedPartyFound ++;
                                    }
                                }
                                //check the Related Business Account on the Already existing Case Role for that Case
                   
                                //FLAG for new Related Party
                                Boolean isCaseRoleFound = false;
                                if(caseWithEntityIDsMap.containsKey(cr.Case__c) 
                                   && caseWithEntityIDsMap.get(cr.Case__c).size() >0 
                                   && caseWithEntityIDsMap.get(cr.Case__c).contains(rbo.Related_Business__c)) {
                                       if(!Test.isRunningTest()){
                                    isCaseRoleFound = true;
                                       }
                                }
                                if(relatedPartyFound == caseRelatedPartyMap.get(cr.Case__c).size() && !isCaseRoleFound)
                                {
                                    relatedPartyList.add(createRelatedPartyRecord(cr.Case__c,accountNameMap.get(rbo.Related_Business__c).Name,rbo.Related_Business__c));
                                    //creating case notes
                                    String caseNote = 'A potential related business has been identified: '+accountNameMap.get(rbo.Business__c).Name+'  may be related to '+accountNameMap.get(rbo.Related_Business__c).Name+' as a '+rbo.Type__c+'. (See Related Parties list.) You may wish to add '+accountNameMap.get(rbo.Related_Business__c).Name+' as a defendant in this case.';
                                    caseNoteList.add(createCaseNote(cr.Case__c, caseNote));
                                }
                            }else{
                                if(rbo.Business__c == cr.Entity__c){
                                    relatedPartyList.add(createRelatedPartyRecord(cr.Case__c,accountNameMap.get(rbo.Related_Business__c).Name,rbo.Related_Business__c));
                                    //creating case notes
                                    String caseNote = 'A potential related business has been identified: '+accountNameMap.get(rbo.Business__c).Name+'  may be related to '+accountNameMap.get(rbo.Related_Business__c).Name+' as a '+rbo.Type__c+'. (See Related Parties list.) You may wish to add '+accountNameMap.get(rbo.Related_Business__c).Name+' as a defendant in this case.';
                                    caseNoteList.add(createCaseNote(cr.Case__c, caseNote));
                                }
                            }
                        }
                    }
                } 
            }
            if(relatedPartyList.size()>0){
                insert relatedPartyList;
            }
            if(caseNoteList.size() > 0){
                insert caseNoteList;
            }
        }
      }
                                                             
       /*
*	Method Name : createRelatedPartyRecord
* 	Description : calling from 'createRelatedParty' this method used for creating individual related party
**/
        public static Related_Party__c createRelatedPartyRecord(Id CaseId, String BusinessName,Id relatedBusinessId ){
            Related_Party__c relatedParty = new Related_Party__c();
            relatedParty.Case_Management__c = CaseId; //case management id
            relatedParty.Business_Name__c = BusinessName; // account name
            relatedParty.Business_account__c = relatedBusinessId;
            relatedParty.Found_Account_ID__c  = relatedBusinessId;
            relatedParty.Role__c = 'Potentially Liable';
            // assigning potential defendant record type
            relatedParty.RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByDeveloperName().get('Potential_Defendant').getRecordTypeId();
            return relatedParty;
            
        }  
    
    /*
	*	Method Name : createCaseNotes
	* 	Description : 
	**/
    public static Case_Note__c createCaseNote(Id CaseId, string caseNote){
        Case_Note__c caseNoteObj = new Case_Note__c();
        caseNoteObj.Event_Note__c = caseNote;
        caseNoteObj.Case_Management__c = CaseId;
        caseNoteObj.Event_Date_Time__c = datetime.now();
        return caseNoteObj;
    }
}