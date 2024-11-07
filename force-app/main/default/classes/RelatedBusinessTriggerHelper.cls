/*
* Class Name :- RelatedBusinessTriggerHelper
* Description :- This class is used to check the duplicacy of Related Business record, used to assign addition notes and to create related party object when a new record is created.
**/
public class RelatedBusinessTriggerHelper {
    public static void beforeInsert(List<Related_Businesses__c> relatedBusinessesList){
        checkDuplicateRelatedBusinesses(relatedBusinessesList);
    }
    public static void afterInsert(List<Related_Businesses__c> relatedBusinessesList){
        System.debug('relatedBusinessesList::'+relatedBusinessesList);
        if(DirUtils.isFirstTime){
            DirUtils.isFirstTime = false;
            createInverseRelatedBusinesses(relatedBusinessesList);
        }
        createRelatedParty(relatedBusinessesList);
    }
    /*
*   Method Name : afterUpdate
*   Description : it would update the type or corresponding Related business record(inverse)
**/
    public static void afterUpdate(List<Related_Businesses__c> newRelatedBusinessesList, Map<Id,Related_Businesses__c> oldRelatedBusinessMap){
        if(DirUtils.isFirstTime){
                DirUtils.isFirstTime = false;
            updateRelatedBusinessRecords(newRelatedBusinessesList, oldRelatedBusinessMap);
        }
    }
    public static void updateRelatedBusinessRecords(List<Related_Businesses__c> newRelatedBusinessesList, Map<Id,Related_Businesses__c> oldRelatedBusinessMap){
        Set<Id> businessIdSet = new Set<Id>();
        Set<Id> relatedBusinessIdSet = new Set<Id>();
        for(Related_Businesses__c relatedBusinessObj : newRelatedBusinessesList){
            if(relatedBusinessObj.Type__c != oldRelatedBusinessMap.get(relatedBusinessObj.Id).Type__c){
                businessIdSet.add(relatedBusinessObj.Business__c);
                relatedBusinessIdSet.add(relatedBusinessObj.Related_Business__c);
            }
        }
        if(businessIdSet.size() > 0 || relatedBusinessIdSet.size() > 0 ){
            Map<Id,Related_Businesses__c> relatedBusinessesMap = new Map<Id,Related_Businesses__c>([SELECT Business__c, Related_Business__c, Type__c FROM Related_Businesses__c
                                                                                                    WHERE Business__c =: relatedBusinessIdSet AND Related_Business__c =: businessIdSet]);
            if(relatedBusinessesMap.size() > 0){
                Map<String,String> relatedBusinessInverseMap = new Map<String,String>();
                for(Related_Business_Type_Inverse__c inverseMap : Related_Business_Type_Inverse__c.getall().values()){
                    relatedBusinessInverseMap.put(inverseMap.Current_Type__c,inverseMap.Inverse_Type__c);
                }
                for(Related_Businesses__c relatedBusiness : newRelatedBusinessesList){
                    if(relatedBusiness.Type__c != oldRelatedBusinessMap.get(relatedBusiness.Id).Type__c){
                        for(Id rbMap : relatedBusinessesMap.keySet()){
                            if(relatedBusinessesMap.get(rbMap).Business__c == relatedBusiness.Related_Business__c && relatedBusinessesMap.get(rbMap).Related_Business__c == relatedBusiness.Business__c){
                                relatedBusinessesMap.get(rbMap).Type__c = relatedBusinessInverseMap.get(relatedBusiness.Type__c);
                            }
                        }
                    }
                }
                update relatedBusinessesMap.values();
            }
        }
    }
    
    
    /*
*   Method Name : checkDuplicateRelatedBusinesses
*   Description : it would check for the duplicate related business record and update the name and additionalInformation field on newly created RBO
**/
    public static void checkDuplicateRelatedBusinesses(List<Related_Businesses__c> relatedBusinessesList){
        Set<Id> businessIdsSet = new Set<Id>();
        Set<Id> relatedBusinessIdsSet = new Set<Id>();
        Set<Id> allAccountIdsSet = new Set<Id>();
        Map<Id,Id> businessWithRelatedBusinessMap = new Map<Id,Id>();
        for(Related_Businesses__c relatedBusiness : relatedBusinessesList){
            if(relatedBusiness.Business__c != null && relatedBusiness.Related_Business__c != null){
                businessIdsSet.add(relatedBusiness.Business__c);
                relatedBusinessIdsSet.add(relatedBusiness.Related_Business__c);
                allAccountIdsSet.add(relatedBusiness.Business__c);
                allAccountIdsSet.add(relatedBusiness.Related_Business__c);
            }
        }
        
        //checking for duplicate RBO
        List<Related_Businesses__c> relatedBusinessDuplicateList = DirQuerySelector.getDuplicateRelatedBusinessRecord(businessIdsSet,relatedBusinessIdsSet);
        for(Related_Businesses__c relatedBusiness : relatedBusinessesList){
            for(Related_Businesses__c duplicateRelatedBusiness : relatedBusinessDuplicateList){
                if(duplicateRelatedBusiness.Business__c == relatedBusiness.Business__c && duplicateRelatedBusiness.Related_Business__c == relatedBusiness.Related_Business__c){
                    relatedBusiness.addError('Related Business Record Already Exists');
                }
            }
        }
        
        // updating the Name 
        Map<Id,Account> accountNameMap = DirQuerySelector.getAccountNames(allAccountIdsSet);
        for(Related_Businesses__c relatedBusiness : relatedBusinessesList){
            relatedBusiness.Name__c = accountNameMap.get(relatedBusiness.Business__c).Name +' - '+ accountNameMap.get(relatedBusiness.Related_Business__c).Name;
        } 
    }
    
    /*
*   Method Name : createInverseRelatedBusinesses
*   Description : it would create the inverse RBO whenever the rbo is created.
**/
    public static void createInverseRelatedBusinesses(List<Related_Businesses__c> relatedBusinessesList){
        List<Related_Businesses__c> inverseRelatedBusinessesList = new List<Related_Businesses__c>();
        for(Related_Businesses__c relatedBusiness : relatedBusinessesList){
            inverseRelatedBusinessesList.add(createInverseRelatedBusinessRecord(relatedBusiness));
        }
        if(inverseRelatedBusinessesList.size() > 0){
            insert inverseRelatedBusinessesList;
        }
    }
    
    /*
*   Method Name : createInverseRelatedBusinessRecord
*   Description : calling from the 'createInverseRelatedBusinesses' which will create the individual inverse relationship. 
**/
    public static Related_Businesses__c createInverseRelatedBusinessRecord(Related_Businesses__c relatedBusiness){
        Map<String,String> relatedBusinessInverseMap = new Map<String,String>();
        for(Related_Business_Type_Inverse__c inverseMap : Related_Business_Type_Inverse__c.getall().values()){
            relatedBusinessInverseMap.put(inverseMap.Current_Type__c,inverseMap.Inverse_Type__c);
        }
        Related_Businesses__c rbo = new Related_Businesses__c();
        rbo.Name__c = relatedBusiness.Name__c;
        rbo.Related_Business__c = relatedBusiness.Business__c;
        rbo.Business__c = relatedBusiness.Related_Business__c;
        rbo.Additional_information__c = relatedBusiness.Additional_information__c;
        if(relatedBusinessInverseMap.containskey(relatedBusiness.Type__c)){
            rbo.Type__c = relatedBusinessInverseMap.get(relatedBusiness.Type__c);
        } 
        return rbo;
    }
    
    /*
*   Method Name : createRelatedParty
*   Description : it would create the Relaed party once any of account having case role,then it would create related party with 
case management id of the case role account that has role and business name of that account that doesn't have case role
and with the type potentialy liable and record type potential defendant.
**/
    public static void createRelatedParty(List<Related_Businesses__c> relatedBusinessesList){
        Set<Id> allAccountIdsSet = new Set<Id>();
        Set<Id> businessIdsSet = new Set<Id>();
        Set<Id> relatedBusinessIdSet = new Set<Id>();
        Map<string,Set<string>> businessWithRbMap = new Map<string,Set<string>>();
        for(Related_Businesses__c relatedBusiness : relatedBusinessesList){
            relatedBusinessIdSet.add(relatedBusiness.Related_Business__c);
            //businessWithRbMap.put(relatedBusiness.Business__c+'+'+relatedBusiness.Related_Business__c,relatedBusiness.Related_Business__c);
            if(businessWithRbMap.containsKey(relatedBusiness.Related_Business__c)){
                businessWithRbMap.get(relatedBusiness.Related_Business__c).add(relatedBusiness.Business__c);
            }else{
                businessWithRbMap.put(relatedBusiness.Related_Business__c,new Set<String>{relatedBusiness.Business__c});
            }
            allAccountIdsSet.add(relatedBusiness.Related_Business__c);
            allAccountIdsSet.add(relatedBusiness.Business__c);
        }
        //used to store the Account name(Business and related Business)
        Map<Id,Account> accountNameMap = DirQuerySelector.getAccountNames(allAccountIdsSet);
        //used to store the caseid related to case role acccount
        Map<ID,Set<ID>> caseRoleMap = DirQuerySelector.checkCaseRoleForRelatedParty(businessWithRbMap);
        // system.debug('relatedPartyMap:::'+relatedPartyMap);
        List<Related_Party__c> relatedPartyList = new List<Related_Party__c>();
        List<Case_Note__c> caseNoteList = new List<Case_Note__c>();
        
        for(Related_Businesses__c relatedBusiness : relatedBusinessesList){
            Related_Party__c relatedParty = new Related_Party__c();
            //checking if related business is created from case management then created related party against it.
            if(caseRoleMap.size() > 0 && caseRoleMap.containsKey(relatedBusiness.Related_Business__c)){
                for(Id accId : caseRoleMap.keySet()){
                    for(Id caseId : caseRoleMap.get(accId)){
                        relatedPartyList.add(createRelatedPartyRecord(caseId ,accountNameMap.get(relatedBusiness.Related_Business__c).Name , relatedBusiness.Related_Business__c));
                        //creating case notes
                        String caseNote = 'A potential related business has been identified: '+accountNameMap.get(relatedBusiness.Business__c).Name+'  may be related to '+accountNameMap.get(relatedBusiness.Related_Business__c).Name+' as a '+relatedBusiness.Type__c+'. (See Related Parties list.) You may wish to add '+accountNameMap.get(relatedBusiness.Related_Business__c).Name+' as a defendant in this case.';
                        caseNoteList.add(createCaseNote(caseId, caseNote));
                    }
                    
                }
            }
            if(relatedPartyList.size() > 0){
                insert relatedPartyList;
            }
            if(caseNoteList.size() > 0){
                insert caseNoteList;
            }
        }
    }
    
    /*
*   Method Name : createRelatedPartyRecord
*   Description : calling from 'createRelatedParty' this method used for creating individual related party
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