/*
* Class Name :- DirQuerySelector
* Description :- This class is used for getting query results related to particular scenario
**/
public class DirQuerySelector {
    public static List<Related_Businesses__c> getDuplicateRelatedBusinessRecord(Set<Id> businessIdsSet, Set<Id> relatedBusinessIdsSet){
        List<Related_Businesses__c> releatedBusinessesList = [Select id,Business__c,Related_Business__c from Related_Businesses__c where Business__c IN: businessIdsSet and Related_Business__c IN: relatedBusinessIdsSet];
        return releatedBusinessesList;
    }
    
    /*
* Method Name :- getRelatedBusinessRecord
* Description :- used to return boolean value if the related business already exist.
**/
    public static Boolean getRelatedBusinessRecord(ID relatedBusinessId, Id BusinessId){
        Boolean recordExist = false;
        List<Related_Businesses__c> duplicateRelatedBusiness = [SELECT Business__c, Related_Business__c FROM Related_Businesses__c WHERE Related_Business__c =: relatedBusinessId AND Business__c =: BusinessId limit 1];
        if(duplicateRelatedBusiness.size()>0){
            recordExist = true;
        }else{
            recordExist = false;
        }
        return recordExist;
    }
    
    /*
* Method Name :- getValidBusiness
* Description :- used to check the valid business entered while creating the rbo from case management
**/
    public static Boolean getValidBusiness(Id BusinessId){
        Boolean isValidBusiness = false;
        List<Account> validAccount = [SELECT id FROM Account WHERE id =: BusinessId limit 1];
        if(validAccount.size()>0){
            isValidBusiness = true;
        }else{
            isValidBusiness = false;
        }
        return isValidBusiness;
    }
    
    /*
* Method Name :- checkCaseRoleForNotes
* Description :- it would return the case role map related to the accounts on rbo 
**/
    public static Map<Id, Case_Role__c> checkCaseRoleForNotes(Set<Id> allAccountIdsSet){
        Map<Id, Case_Role__c> caseRoleMap = new Map<Id, Case_Role__c>([Select id,Entity__c,case__c from Case_Role__c where Entity__c IN: allAccountIdsSet and Role__c !=null  and (Case__r.Status__c != 'Closed' or Case__r.Total_Wages_Balance_Due__c != 0 or Case__r.Total_Penalties_Balance_Due__c != 0 ) and Case_Role_Status__c != 'No Longer Active On Case' ]);
        return caseRoleMap;
    }
    
    /*
* Method Name :- getAccountNames
* Description :- it would return the map of account ,which later used to get the name of the account 
**/
    public static Map<Id, Account> getAccountNames(Set<Id> allAccountIdsSet){
        Map<Id, Account> AccountNameMap = new Map<Id, Account>([Select id,Name from Account where Id IN: allAccountIdsSet]);
        return AccountNameMap;
    }
    
    /*
* Method Name :- getAccountNames
* Description :- it would check if any account is related to case role for creating related party
**/
    public static Map<Id,Set<Id>> checkCaseRoleForRelatedParty(Map<string,Set<string>> businessWithRbMap){
        Set<String> businessIdsSet = new Set<String>();
        for(Set<String> idSet : businessWithRbMap.Values()){
            for(string bId : idSet){
                businessIdsSet.add(bId);
            }
            
        }        
        Map<Id, set<Id>> businessCaseIdMap= new Map<Id,set<Id>>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> relatedBusinessOnCaseRoleIdSet = new Set<Id>();
        for(Case_Role__c  caseRole : [select Id,Case__c ,Entity__c from Case_Role__c  
                                      where Role__c != null 
                                      and Entity__c In:businessIdsSet 
                                      and (Case__r.Status__c != 'Closed' or Case__r.Total_Wages_Balance_Due__c != 0 or Case__r.Total_Penalties_Balance_Due__c != 0 )  
                                      and Case_Role_Status__c != 'No Longer Active On Case']){
                                          
                                          caseIds.add(caseRole.Case__c);
                                          system.debug('caseRole.Entity__c:::'+caseRole.Entity__c);
                                          system.debug('caseRole.Case__c:::'+caseRole.Case__c);
                                          if(businessCaseIdMap.containsKey(caseRole.Entity__c)){
                                              businessCaseIdMap.get(caseRole.Entity__c).add(caseRole.Case__c);
                                          }else{
                                              businessCaseIdMap.put(caseRole.Entity__c,new set<id>{caseRole.Case__c});
                                          }
                                      }    
        for(Case_Role__c  caseRole : [select Id,Case__c ,Entity__c from Case_Role__c 
                                      WHERE Entity__c IN: businessWithRbMap.keySet() AND Case__c IN : caseIds]) {
                                          relatedBusinessOnCaseRoleIdSet.add(caseRole.Case__c);
                                      }
        system.debug('relatedBusinessOnCaseRoleIdSet: '+relatedBusinessOnCaseRoleIdSet);
        
        Set<Id> businessAccountIdSet = new Set<Id>();
        Map<Id,set<Id>> relatedBusinessWithCaseMap = new Map<Id,set<Id>>();
        
        for(Related_Party__c rp : [SELECT Id, Business_account__c, Case_Management__c FROM Related_Party__c where Case_Management__c In: caseIds and Business_account__c In:businessWithRbMap.keyset()]){
            if(relatedBusinessWithCaseMap.containsKey(rp.Case_Management__c)){
                relatedBusinessWithCaseMap.get(rp.Case_Management__c).add(rp.Business_account__c);
            }else{
                relatedBusinessWithCaseMap.put(rp.Case_Management__c,new set<Id>{rp.Business_account__c});
            }
            businessAccountIdSet.add(rp.Business_account__c);
        }
        Map<Id, set<Id>> relatedBusinessWithCases = new Map<Id,set<Id>>();
        for(String rbId : businessWithRbMap.keyset()){
            //check for existing Related Party if not existing, then continue else break
            if(!businessAccountIdSet.contains(rbId) ){
                for(string busId : businessWithRbMap.get(rbId)){
                    if(businessCaseIdMap.containsKey(busId))  //byme
                        for(string caseId : businessCaseIdMap.get(busId)){
                            //check for existing Case Role with business if not existing, then continue else break
                            if(!relatedBusinessOnCaseRoleIdSet.contains(caseId)){
                                if(relatedBusinessWithCases.containsKey(rbId)){
                                    relatedBusinessWithCases.get(rbId).add(caseId);
                                }else{
                                    relatedBusinessWithCases.put(rbId,new set<Id>{caseId});
                                }
                                
                            }
                        }
                }
                
            }
        }
        return relatedBusinessWithCases;
    }
    
    public static judgmentSearchRecordWrapper getJudgmentRecords(String listStatus2810,String naicsCode,String accountName, String City, String ZipCode, 
                                                                 Date judgmentEntryDateFrom,Date judgmentEntryDateTo,String court, List<String> judgmentStatus, String defandantEmployerName,
                                                                 double judgmentTotalFrom, double judgmentTotalTo, String citationNumber ,String dirOffice,String county )
    {
        Map<Id, String> caseWithRoleMap = new Map<Id, String>();
        String defendantName = '';
        List<Liability_Judgement__c> judgmentRecordsList;
        Set<String> judgmentPartyRejectSet = new Set<String>();
        List<Liability_Judgement__c> judgmentObjList = new List<Liability_Judgement__c>();
        String query = 'SELECT Id,Liable_Party__r.Case_Role_Entity_Full_Output__c, Name,Judgement__r.Case_Management__r.Office__r.Name, Judgement__r.Case_Management__r.Naics_code__c, Judgement__r.Case_Management__r.NAICS_Code_Title__c, Judgement__r.Judgement_Date__c, Judgement__r.Liability__c, Judgement__r.Total_Penalties_Due__c, Judgement__r.Total_Wage_Balance_Due__c, Judgement__r.Liability__r.Citation_Number__c, Judgement__r.Judgment_Total__c, Judgement__r.RecordType.Name, Judgement__r.Total_Amount_Due__c, Judgement__r.Total_Due_to_Other_s__c, Judgement__r.Name, Judgement__r.Court__r.Name, Judgement__r.Case_Management__r.Employer__r.Name, Judgement__r.Case_Management__r.RecordType.Name, Judgement__r.Status__c, Judgement__r.X2810_4_List_Status__c,X2810_4_List_Status__c, Liable_Party__c, Liable_Party__r.Entity__c,Liable_Party__r.Entity__r.Name, Liable_Party__r.Entity__r.ShippingStreet,Liable_Party__r.Entity__r.ShippingPostalCode,Liable_Party__r.Entity__r.ShippingCity,Liable_Party__r.Entity__r.ShippingCountry,Liable_Party__r.Entity__r.ShippingState, Related_Business__r.business__r.Name,Related_Business__r.business__r.ShippingPostalCode,Related_Business__r.business__r.ShippingCity,Related_Business__r.business__r.ShippingCountry ,Related_Business__r.business__r.ShippingState,Related_Business__r.business__r.ShippingStreet,Liable_Party_Related_Business_Link__c  FROM Liability_Judgement__c WHERE CreatedDate != null';
        
        Set<Id> ids = new Set<id>();
        //checking the dba's for defendant employer
        if(String.isNotBlank(defandantEmployerName)){
            string employerName = '%' + String.escapeSingleQuotes(defandantEmployerName) + '%';
            List<DBA__c> dbaList =  [SELECT Id,Name,Account__c FROM DBA__c where Name Like: employerName];
            for(DBA__c dba : dbaList){
                if(dba.Account__c != null){
                    ids.add(dba.Account__c);
                }
            }
        }
        String judgmentPartQuery = createJudgmentPartyQuery(City, ZipCode,defandantEmployerName, ids);
        query += judgmentPartQuery;
        if(String.isNotBlank(naicsCode)){
            query += ' AND Judgement__r.Case_Management__r.NAICS_Code__c like \'' + naicsCode + '%\' ';
        }
        if(String.isNotBlank(accountName)){
            string accName = '%' + String.escapeSingleQuotes(accountName) + '%';
            List<Case_Role__c> caseMgt = [SELECT Case__c,Entity__r.Name,Role__c FROM Case_Role__c where (Role__c = 'Claimant' or Role__c= 'plaintiff') And Entity__r.Name Like: accName];
            ids = new Set<id>();
            for(Case_Role__c cr : caseMgt){
                if(cr.Case__c != null){
                    ids.add(cr.Case__c);
                }
                if(cr.Role__c == 'Claimant'){
                    caseWithRoleMap.put(cr.Case__c, cr.Entity__r.Name);
                } 
                else if(cr.Role__c == 'plaintiff' && caseWithRoleMap.containsKey(cr.Case__c)){
                    caseWithRoleMap.put(cr.Case__c, cr.Entity__r.Name);
                } 
            }
            query += ' And ( Judgement__r.Case_Management__r.Employer__r.Name like \'%' + String.escapeSingleQuotes(accountName) + '%\' Or Judgement__r.Case_Management__c IN :ids )';
        }
        if(judgmentEntryDateFrom != null){
            query += ' And Judgement__r.Judgement_Date__c >=:judgmentEntryDateFrom ';
        }
        if(judgmentEntryDateTo != null){
            query += ' And Judgement__r.Judgement_Date__c <=:judgmentEntryDateTo ';
        }                                                         
        if(String.isNotBlank(court)){
            query += ' And Judgement__r.Court__r.name = \'' + court + '\' ';
        }
        if(String.isNotBlank(county)){
            query += ' And Judgement__r.Court__r.County__c = \'' + county + '\' ';
        }
        System.debug('final Query:::'+query);
        if(judgmentStatus.size() > 0 && judgmentStatus != null && !judgmentStatus.contains('null')){
            String judgmentString = string.join(judgmentStatus,',');
            List<String> judgmentStatusList = judgmentString.split(',');
            query += ' AND Judgement__r.Status__c IN :judgmentStatusList ';
        }
        if(judgmentTotalFrom > 0){
            query += ' And Judgement__r.Judgment_Total__c >=:judgmentTotalFrom';
        }
        if(judgmentTotalTo > 0){
            query += ' And Judgement__r.Judgment_Total__c <=:judgmentTotalTo';
        }
        if(String.isNotBlank(citationNumber)){
            ids = new Set<id>();
            
            List<Liability__c> liablityCm = [SELECT Id, Citation_Number__c, Case_Management__c FROM Liability__c where Citation_Number__c = :citationNumber];
            for(Liability__c cm : liablityCm){
                if(cm.Case_Management__c != null){
                    ids.add(cm.Case_Management__c);
                }
            }
            query += ' And Judgement__r.Case_Management__c IN :ids';
            query += ' And Judgement__r.Liability__r.Citation_Number__c  =:citationNumber';
        }
        if(String.isNotBlank(dirOffice)){
            if(dirOffice.equals('Los Angeles')){
                query += ' And (Judgement__r.Case_Management__r.Office__r.RecordType.Name = \'BOFE\' OR Judgement__r.Case_Management__r.Office__r.RecordType.Name = \'WCA\' ) ';
            }
            query += ' And Judgement__r.Case_Management__r.Office__r.Name =\'' + dirOffice + '\' ';
        }
        
        judgmentRecordsList = database.query(query + ' order by Judgement__r.Judgement_Date__c DESC NULLS LAST LIMIT 5000');
        if(judgmentRecordsList != null){
            for(Liability_Judgement__c judgmentPartyObj : judgmentRecordsList){
                //judgmentIdsRejectForSoql.add(judgmentPartyObj.Id);
                if(judgmentPartyObj != null){
                    //judgmentIdsRejectForSoql.add(judgmentPartyObj.Id);
                    if(judgmentPartyObj.Liable_Party__c != null && judgmentPartyObj.Liable_Party__r.entity__c != null){
                        defendantName = judgmentPartyObj.Liable_Party__r.Case_Role_Entity_Full_Output__c;
                    }
                    else{
                        defendantName = judgmentPartyObj != null ? judgmentPartyObj.Related_Business__r.business__r.Name : '';
                    }
                }
                if(!judgmentPartyRejectSet.contains(defendantName + judgmentPartyObj.Judgement__r.Id)){
                    judgmentObjList.add(judgmentPartyObj);
                    judgmentPartyRejectSet.add(defendantName + judgmentPartyObj.Judgement__r.Id);
                }
            }
        }
        if((judgmentRecordsList.size() == 5000 && judgmentObjList.size() < 5000) || Test.isRunningTest()){
            List<Liability_Judgement__c> judgmentRecordsLists = database.query(query + ' AND Id NOT IN: judgmentObjList order by Judgement__r.Judgement_Date__c DESC NULLS LAST LIMIT 15000');
            for(Liability_Judgement__c judgmentPartyObj : judgmentRecordsLists){
                if(judgmentPartyObj != null){
                    //judgmentIdsRejectForSoql.add(judgmentPartyObj.Id);
                    if(judgmentPartyObj.Liable_Party__c != null && judgmentPartyObj.Liable_Party__r.entity__c != null){
                        defendantName = judgmentPartyObj.Liable_Party__r.Case_Role_Entity_Full_Output__c;
                    }
                    else{
                        defendantName = judgmentPartyObj != null ? judgmentPartyObj.Related_Business__r.business__r.Name : '';
                    }
                }
                
                if(judgmentObjList.size() == 5000){
                    break;
                }
                if(!judgmentPartyRejectSet.contains(defendantName + judgmentPartyObj.Judgement__r.Id)){
                    judgmentObjList.add(judgmentPartyObj);
                    judgmentPartyRejectSet.add(defendantName + judgmentPartyObj.Judgement__r.Id);
                }
            }
        }
        
        if(String.isNotBlank(accountName)){
            Set<Id> caseMgtIds = new Set<Id>();
            for(Liability_Judgement__c liabilityObj : judgmentObjList){
                caseMgtIds.add(liabilityObj.Judgement__r.Case_Management__c);
            }
            string accName = '%' + String.escapeSingleQuotes(accountName) + '%';
            List<DIR_Case__c> caseMgtList = [SELECT id,Employer__r.Name, (SELECT Case__c,Entity__r.Name,Role__c FROM Case_Roles__r where (Role__c = 'Claimant' or Role__c= 'plaintiff') And Entity__r.Name Like: accName) FROM DIR_Case__c WHERE id IN :caseMgtIds];
            for(DIR_Case__c dirCaseObj : caseMgtList){
                for(Case_Role__c caseRoleObj : dirCaseObj.Case_Roles__r){
                    if(caseRoleObj.Role__c == 'Claimant'){
                        caseWithRoleMap.put(caseRoleObj.Case__c, caseRoleObj.Entity__r.Name);
                    } 
                    else if(caseRoleObj.Role__c == 'plaintiff' && caseWithRoleMap.containsKey(caseRoleObj.Case__c)){
                        caseWithRoleMap.put(caseRoleObj.Case__c, caseRoleObj.Entity__r.Name);
                    }																																																									
                }
                if(! caseWithRoleMap.containsKey(dirCaseObj.Id)){
                    caseWithRoleMap.put(dirCaseObj.Id, dirCaseObj.Employer__r.Name);
                }
            }
        }
        judgmentSearchRecordWrapper judgmentSearchRecordObj = new judgmentSearchRecordWrapper();
        judgmentSearchRecordObj.judgmentPartyList = judgmentObjList;
        judgmentSearchRecordObj.caseRoleMap = caseWithRoleMap;
        return judgmentSearchRecordObj;
        
    }
    public class judgmentSearchRecordWrapper{
        public List<Liability_Judgement__c> judgmentPartyList;
        public Map<Id, String> caseRoleMap;
    }
    public static judgmentSearchRecordWrapper getPortDrayageRecords(Date asOfDate, Date fromDate, Date toDate){
        Map<Id, String> caseWithRoleMap = new Map<Id, String>();
        List<Liability_Judgement__c> judgmentObjList = new List<Liability_Judgement__c>();
        Date nextDate;
        String defendantName = '';
        List<Liability_Judgement__c> judgmentRecordsList;
        Set<String> judgmentPartyRejectSet = new Set<String>();
        string judgmentParty = 'select Id,Liable_Party__r.Case_Role_Entity_Full_Output__c,Liable_Party_Related_Business_Link__c, Liable_Party_Name__c,Judgement__r.Court__r.Name,Judgement__r.Total_Wage_Balance_Due__c, Judgement__r.Total_Penalties_Due__c, Judgement__r.Total_Due_to_Other_s__c, Judgement__r.Case_Management__r.NAICS_Code_Title__c, Judgement__r.Case_Management__r.Naics_code__c, Judgement__r.Case_Management__r.Office__r.Name, Judgement__r.Name, Judgement__r.Case_Management__r.Employer__r.Name, Judgement__r.RecordType.Name, Judgement__r.Case_Management__r.RecordType.Name, Judgement__r.Liability__r.Citation_Number__c, Judgement__r.Judgement_Date__c, Judgement__r.Judgment_Total__c,Judgement__r.Liability__c, Liable_Party__c, Liable_Party__r.Entity__c,Liable_Party__r.Entity__r.Name, Liable_Party__r.Entity__r.ShippingStreet,Liable_Party__r.Entity__r.ShippingPostalCode,Liable_Party__r.Entity__r.ShippingCity,Liable_Party__r.Entity__r.ShippingCountry,Liable_Party__r.Entity__r.ShippingState, Related_Business__r.business__r.ShippingState,Related_Business__r.business__r.ShippingStreet, Related_Business__r.Related_Business__r.Name,Related_Business__r.business__r.Name,Related_Business__r.business__r.ShippingPostalCode,Related_Business__r.business__r.ShippingCity,Related_Business__r.business__r.ShippingCountry, X2810_4_Date_added_to_the_list__c,X2810_4_Date_Removed_from_the_list__c,CreatedDate from Liability_Judgement__c ';
        String judgmentPartyCriteria = '';
        if(asOfDate != null){
            //nextDate = asOfDate.addDays(1);
            judgmentParty += ' where X2810_4_Date_added_to_the_list__c <=: asOfDate and X2810_4_List_Status__c =\'Confirmed-On List\' ';
            judgmentPartyCriteria = ' where X2810_4_Date_added_to_the_list__c <=: asOfDate and X2810_4_List_Status__c =\'Confirmed-On List\' ';
        }else{
            judgmentParty += ' where X2810_4_Date_added_to_the_list__c >=: fromDate and X2810_4_Date_added_to_the_list__c <=: toDate and X2810_4_List_Status__c =\'Confirmed-On List\' ';
            judgmentPartyCriteria = ' where X2810_4_Date_added_to_the_list__c >=: fromDate and X2810_4_Date_added_to_the_list__c <=: toDate and X2810_4_List_Status__c =\'Confirmed-On List\' ';
        }
        judgmentRecordsList = database.query( +judgmentParty+ 'order by Judgement__r.Judgement_Date__c DESC NULLS LAST LIMIT 5000');
        
        if(judgmentRecordsList != null){
            for(Liability_Judgement__c judgmentPartyObj : judgmentRecordsList){
                if(judgmentPartyObj != null){
                    if(judgmentPartyObj.Liable_Party__c != null && judgmentPartyObj.Liable_Party__r.Entity__c != null){
                        defendantName = judgmentPartyObj.Liable_Party__r.Case_Role_Entity_Full_Output__c;
                    }
                    else{
                        defendantName = ((judgmentPartyObj != null) ? judgmentPartyObj.Related_Business__r.business__r.Name : '') ;
                    }
                }
                if(!judgmentPartyRejectSet.contains(judgmentPartyObj.Judgement__r.Name + defendantName + judgmentPartyObj.Judgement__r.Id)){
                    judgmentObjList.add(judgmentPartyObj);
                    judgmentPartyRejectSet.add(judgmentPartyObj.Judgement__r.Name + defendantName + judgmentPartyObj.Judgement__r.Id);
                }
            }
        }
        
        if((judgmentRecordsList.size() == 5000 && judgmentObjList.size() < 5000) || Test.isRunningTest()){
            List<Liability_Judgement__c> judgmentRecordsLists = database.query(+judgmentParty+ ' AND Id NOT IN: judgmentRecordsList order by Judgement__r.Judgement_Date__c DESC NULLS LAST LIMIT 5000');
            for(Liability_Judgement__c judgmentPartyObj : judgmentRecordsLists){
                if(judgmentPartyObj != null){
                    if(judgmentPartyObj.Liable_Party__c != null && judgmentPartyObj.Liable_Party__r.Entity__c != null){
                        defendantName = judgmentPartyObj.Liable_Party__r.Case_Role_Entity_Full_Output__c;
                    }
                    else{
                        defendantName = ((judgmentPartyObj != null) ? judgmentPartyObj.Related_Business__r.business__r.Name : '') ;
                    }
                }
                if(judgmentObjList.size() == 5000){
                    break;
                }
                if(!judgmentPartyRejectSet.contains(judgmentPartyObj.Judgement__r.Name + defendantName + judgmentPartyObj.Judgement__r.Id)){
                    judgmentObjList.add(judgmentPartyObj);
                    judgmentPartyRejectSet.add(judgmentPartyObj.Judgement__r.Name + defendantName + judgmentPartyObj.Judgement__r.Id);
                }
            }
        }
        
        Set<Id> caseMgtIds = new Set<Id>();
        for(Liability_Judgement__c liabilityObj : judgmentObjList){
            caseMgtIds.add(liabilityObj.Judgement__r.Case_Management__c);
        }
        
        List<DIR_Case__c> caseMgtList = [SELECT id,Employer__r.Name, (SELECT Case__c,Entity__r.Name,Role__c FROM Case_Roles__r where (Role__c = 'Claimant' or Role__c= 'plaintiff')) FROM DIR_Case__c WHERE Id IN :caseMgtIds];
        for(DIR_Case__c dirCaseObj : caseMgtList){
            for(Case_Role__c caseRoleObj : dirCaseObj.Case_Roles__r){
                if(caseRoleObj.Role__c == 'Claimant'){
                    caseWithRoleMap.put(caseRoleObj.Case__c, caseRoleObj.Entity__r.Name);
                } 
                else if(caseRoleObj.Role__c == 'plaintiff' && caseWithRoleMap.containsKey(caseRoleObj.Case__c)){
                    caseWithRoleMap.put(caseRoleObj.Case__c, caseRoleObj.Entity__r.Name);
                }																																																									
            }
            if(! caseWithRoleMap.containsKey(dirCaseObj.Id)){
                caseWithRoleMap.put(dirCaseObj.Id, dirCaseObj.Employer__r.Name);
            }
        }
        judgmentSearchRecordWrapper judgmentSearchRecordObj = new judgmentSearchRecordWrapper();
        judgmentSearchRecordObj.judgmentPartyList = judgmentObjList;
        judgmentSearchRecordObj.caseRoleMap = caseWithRoleMap;
        return judgmentSearchRecordObj;
    }
    
    public static judgmentDetailModel getJudgmentDetails(String selectedJudgmentRecordId , String judgmentPartyId){
        String claimantPlaintiffName = '';
        Judgement__c judObj = [SELECT Id, Court__r.Name, Name, Status__c, Total_Due_to_Other_s__c,Judgement_Date__c,Judgment_Total__c,RecordType.Name,
                               Total_Amount_Due__c, Court_Case_Number__c , Case_Management__r.id, Case_Management__c, Case_Management__r.Name, Case_Management__r.Employer__r.Name,Case_Management__r.RecordType.Name, 
                               Case_Management__r.Naics_code__c,Case_Management__r.Office__r.Name,Case_Management__r.NAICS_Code_Title__c, Case_Number__c, 
                               X2810_4_List_Status__c, Total_Penalties_Due__c, Total_Wage_Balance_Due__c,Liability__c,Liability__r.Citation_Number__c,
                               (select Id,Liable_Party__c, Liable_Party__r.Case_Role_Entity_Full_Output__c, Liable_Party__r.Entity__c,Liable_Party__r.Entity__r.Name, 
                                Liable_Party__r.Entity__r.ShippingStreet,Liable_Party__r.Entity__r.ShippingPostalCode,
                                Liable_Party__r.Entity__r.ShippingCity,Liable_Party__r.Entity__r.ShippingCountry,
                                Liable_Party__r.Entity__r.ShippingState, X2810_4_List_Status__c, X2810_4_Date_added_to_the_list__c,X2810_4_Date_Removed_from_the_list__c,
                                Related_Business__r.business__c,Related_Business__r.business__r.Name,Related_Business__r.business__r.ShippingPostalCode,
                                Related_Business__r.business__r.ShippingState,Related_Business__r.business__r.ShippingStreet,
                                Related_Business__r.business__r.ShippingCity,Related_Business__r.business__r.ShippingCountry, 
                                createdDate FROM Liability_Judgements__r where Id =:judgmentPartyId LIMIT 1 ) 
                               FROM Judgement__c WHERE Id =: selectedJudgmentRecordId limit 1];
        
        if(judObj.Case_Management__c != null){
            try{
                Case_Role__c caseRoleObj = [SELECT Case__c,Entity__r.Name,Role__c FROM Case_Role__c where (Role__c = 'Claimant' or Role__c= 'plaintiff') AND Case__c =: judObj.Case_Management__c LIMIT 1];
                if(caseRoleObj.Role__c == 'Claimant' || caseRoleObj.Role__c == 'plaintiff'){
                    claimantPlaintiffName = caseRoleObj.Entity__r.Name;
                }
            }
            catch(System.QueryException e)
            {
                claimantPlaintiffName = judObj.Case_Management__r.Employer__r.Name;
                system.debug('===error===>'+e);
            }
        }
        else{
            claimantPlaintiffName = '';
        }
        judgmentDetailModel judgmentDetailModelObj = new judgmentDetailModel();
        judgmentDetailModelObj.judgmentDetail = judObj;
        judgmentDetailModelObj.claimantPlaintiffName = claimantPlaintiffName;
        return judgmentDetailModelObj;
    }
    public class judgmentDetailModel{
        public Judgement__c judgmentDetail;
        public String claimantPlaintiffName;
    }
    public static string createJudgmentPartyQuery(String City, String ZipCode, String defandantEmployerName, Set<Id> ids) { 
        String relatedBusinessCriteria = '';
        String liablePartyCriteria = '';
        Boolean isCriteriaAdded = false;
        String judgmentPartyQuery = '';
        if(!String.isEmpty(City) && !String.isEmpty(ZipCode)){
            relatedBusinessCriteria = ' Related_Business__r.business__r.ShippingCity =\'' + City + '\' and Related_Business__r.business__r.ShippingPostalCode =\''+ZipCode+'\' ';
            liablePartyCriteria = ' Liable_Party__r.Entity__r.ShippingCity =\'' + City + '\' and Liable_Party__r.Entity__r.ShippingPostalCode =\''+ZipCode+'\' ';
            isCriteriaAdded = true;
        }
        else if(!String.isEmpty(City) && String.isEmpty(ZipCode)){
            relatedBusinessCriteria = ' Related_Business__r.business__r.ShippingCity =\'' + City + '\'';
            liablePartyCriteria = ' Liable_Party__r.Entity__r.ShippingCity =\'' + City + '\'';
            isCriteriaAdded = true;
        }
        else if(!String.isEmpty(ZipCode) && String.isEmpty(City)){
            relatedBusinessCriteria += ' Related_Business__r.business__r.ShippingPostalCode =\'' + ZipCode + '\'';
            liablePartyCriteria = ' Liable_Party__r.Entity__r.ShippingPostalCode =\'' + ZipCode + '\'';
            isCriteriaAdded = true;
        }
        if(!String.isEmpty(defandantEmployerName)){
            if(isCriteriaAdded){
                relatedBusinessCriteria += ' and ( Related_Business__r.business__r.Name Like \'%' + String.escapeSingleQuotes(defandantEmployerName) + '%\' Or Related_Business__r.business__c In: ids )';
                liablePartyCriteria += ' and ( Liable_Party__r.Entity__r.Name Like \'%' + String.escapeSingleQuotes(defandantEmployerName) + '%\' Or Liable_Party__r.Entity__c In: ids )';
            }else{
                relatedBusinessCriteria = ' ( Related_Business__r.business__r.Name Like \'%' + String.escapeSingleQuotes(defandantEmployerName) + '%\' Or Related_Business__r.business__c In: ids )';
                liablePartyCriteria = ' ( Liable_Party__r.Entity__r.Name Like \'%' + String.escapeSingleQuotes(defandantEmployerName) + '%\' Or Liable_Party__r.Entity__c In: ids )';
            }
        }
        
        if(relatedBusinessCriteria != '' ){
            // add the closing brackets to the related business criteria
            relatedBusinessCriteria = '('+ relatedBusinessCriteria +')';
            // add the closing brackets to the liable party  criteria
            liablePartyCriteria = '('+ liablePartyCriteria +')';
            //preparing the final judgment party query
            judgmentPartyQuery += ' AND '+ '(' + relatedBusinessCriteria + 'OR' +liablePartyCriteria + ')';
        }
        return judgmentPartyQuery;
    }
}