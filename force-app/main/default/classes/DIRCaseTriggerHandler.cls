public class DIRCaseTriggerHandler {
    
    public static boolean stopAffiliationCreation = false;
    public static boolean preventDuplicateHistoryCreations = true;
    public static final String PRE_DOCKETING_CASE_RECORD_TYPE_ID = 
        Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByDeveloperName().get('Pre_Docketing_Case').getRecordTypeId();
    
    // Delete DraftJSON record after successfully record creation
    public static void deleteOWCDraftJson(List<DIR_Case__c> caseObjList){
        if(caseObjList.size() > 0){
            //delete [SELECT Id FROM Online_Claim_Draft__c WHERE CreatedById =: userInfo.getUserId()];
        }
    }
    
    // ldavala 06.20.2018 - added newMapIn parameter
    public static void triggerHandler(List<DIR_Case__c> newListIn, Map<Id, DIR_Case__c> oldMapIn, Map<Id, DIR_Case__c> newMapIn, Boolean isUpdate, Boolean isInsert, Boolean isBefore, Boolean isAfter){
        if(isInsert){
            if(isBefore){
                //                updateCase(newListIn);
                assignOffice(newListIn, null);
                System.debug('1recordType - '+ newListIn[0].recordTypeId  + '1Status__c -'+newListIn[0].Status__c);
            }
            if(isAfter){
                try{
                    createCaseRole(newListIn);
                }
                catch(Exception ex){
                    System.debug('Line number  :::: '+ex.getLineNumber());
                    System.debug('Message :::: '+ex.getMessage());
                }
                // ldavala changes 06.20.2018
                // remove
                //createLinkedCases(newListIn);
                //add
                //createLinkedCasesFuture(new List<Id>(newMapIn.keySet()));
                //createLinkedCasesFuture(JSON.serialize(newListIn));
                // end ldavala changes 
                if(DIRCaseTriggerHandler.preventDuplicateHistoryCreations){
                    
                    createAssignmentHistory(newListIn,null);
                    DIRCaseTriggerHandler.preventDuplicateHistoryCreations = false;
                }
            }
            
            
        }
        if(isUpdate){
            // ldavala - added logic here to use a field set to determine a collection of fields that if changed  will not fire the "Update" trigger to reduce additional processing that does not
            // need to occur for Declare Rollups.
            Set<String> fieldsToMonitor = new Set<String>();
            //dynamically get the fields from the field set and then use the same for comparison in the trigger. 
            
            SObjectType sType = Schema.getGlobalDescribe().get('DIR_Case__c');
            for(Schema.FieldSetMember fields :sType.getDescribe().fieldSets.getMap().get('IgnoreChangesInTrigger').getFields()){
                fieldsToMonitor.add(fields.getFieldPath());
            }
            
            for(DIR_Case__c dc: newListIn) {
                if(isBefore){
                    System.debug('recordType - '+ dc.recordTypeId  + 'Status__c -'+dc.Status__c);
                    if(dc.recordTypeId == OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID
                       && dc.Status__c != 'Closed'
                       && oldMapIn.get(dc.Id).Status__c == 'Not Confirmed' && dc.Status__c != oldMapIn.get(dc.Id).Status__c)
                    {	
                        //Check for garment record type
                        if(dc.Applicant_Type__c == 'Representative Garment'){
                            dc.recordTypeId = OWCConstants.Garment_CASE_RECORD_TYPE_ID;
                            dc.Office__c = OWCConstants.Garment_Office_Los_Angeles;
                            //Send Office change notification to Claimant and Advocate
                            OCEmailServiceUtility.sendOfficeChangeEmailToClaimant('Office_Assignment_change_notification', dc.Id);
                            OCEmailServiceUtility.sendOfficeChangeEmailToAdvocate('Office_Assignment_change_notification',dc.Id);
                        } 
                        else {
                            dc.recordTypeId = OWCConstants.WCA_CASE_RECORD_TYPE_ID;
                        }
                        dc.Case_Number__c = 'WC-' + dc.Name;
                        //Fix Jira OWC-765
                        //get Current Time as per Org Time Zone
                        dc.Date_of_Docket__c = OWCOnlineClaimFormService.nextBusinessDate();
                        /*
                        CalculateBusinessDays cbd= new CalculateBusinessDays();
                        dc.Date_of_Docket__c = cbd.addBusinessDays(Date.today(), 0);
						*/
                    }
                    //Remove dc.Intake_Origin__c == 'Online' criteria to allow third party claims.
                    else if(dc.RecordTypeId == PRE_DOCKETING_CASE_RECORD_TYPE_ID && dc.Status__c == 'Closed' && oldMapIn.get(dc.id).Status__c != dc.Status__c){
                        dc.Closure_Disposition__c = 'Not confirmed by Claimant';
                    }
                }
                
                Set<String> changedFieldSet = new Set<String>();
                for(string s: fieldsToMonitor){ 
                    if(dc.get(s) !=  oldMapIn.get(dc.Id).get(s)){
                        changedFieldSet.add(s);
                    }
                }
                if(changedFieldSet.isEmpty()){
                    if(isBefore){
                        AddErrorsToCase(newListIn, oldMapIn);
                        assignOffice(newListIn, oldMapIn);
                    }
                    if(isAfter){
                        updateLaborCodeViolations(newListIn, oldMapIn);
                        updateRLLV(newListIn, oldMapIn);
                        updateDeputyOnMeeting(newListIn, oldMapIn);
                        //updateFieldHistory(newListIn, oldMapIn);
                        //updateLinkedCases(newListIn, oldMapIn);
                        
                        if(DIRCaseTriggerHandler.preventDuplicateHistoryCreations){
                            createAssignmentHistory(newListIn,oldMapIn);
                            DIRCaseTriggerHandler.preventDuplicateHistoryCreations = false;
                        }
                        
                        List<DIR_Case__c> caseRolestoInsert = new List<DIR_Case__c>();
                        for(DIR_Case__c c : newListIn){
                            //check if the Claimant comunity account is updated on Case.
                            if(c.Online_Claim_Account__c != null && c.Online_Claim_Account__c != oldMapIn.get(c.id).Online_Claim_Account__c){
                                populateClaimantCommuntyAccountOnCaseRoles(c);
                            }
                            if(c.Employer__c != null && c.Employer__c != oldMapIn.get(c.id).Employer__c){
                                caseRolestoInsert.add(c);
                            }
                            if((c.Intake_Origin__c == 'online' || c.Intake_Origin__c == '3rd Party API') && c.RecordTypeId == PRE_DOCKETING_CASE_RECORD_TYPE_ID && c.Status__c == 'Closed' && oldMapIn.get(c.id).Status__c != c.Status__c && c.Sent_Confirmation_Email__c == false){
                                //vikas calling this from controller
                                OCEmailServiceUtility.sendEmailtoAdvocateOnClosed(c);
                            }
                            if((c.Intake_Origin__c == 'online' || c.Intake_Origin__c == '3rd Party API') && c.Office__c != oldMapIn.get(c.id).Office__c && c.Office__c != null && oldMapIn.get(c.id).Office__c != null ){
                                //sendOfficeChangeEmailAlert(c);
                                //Send Office change notification to Claimant and Advocate
                                OCEmailServiceUtility.sendOfficeChangeEmailToClaimant('Office_Assignment_change_notification', c.Id);
                                OCEmailServiceUtility.sendOfficeChangeEmailToAdvocate('Office_Assignment_change_notification', c.Id);
                            }
                        }
                        if(GlobalFlagClass.preventDuplicateCaseRoles && caseRolestoInsert.size() > 0){
                            GlobalFlagClass.preventDuplicateCaseRoles = false;
                            createCaseRole(caseRolestoInsert);
                        }
                        
                    }
                }
                System.debug('dc - '+ dc);
                //OCEmailServiceUtility.sendConfirmationEmailtoClaimant(dc);
            }
        }
    }
    
    public static void populateClaimantCommuntyAccountOnCaseRoles(DIR_Case__c caseRecord){
        List<Case_Role__c> rolesToUpdate = new List<Case_Role__c>();
        for(Case_Role__c cr: [SELECT Id,Community_User_Account__c FROM Case_Role__c 
                              WHERE Case__c =: caseRecord.Id and Role__c = 'Claimant']){
                                  cr.Community_User_Account__c = caseRecord.Online_Claim_Account__c;
                                  rolesToUpdate.add(cr);
                              }
        update rolesToUpdate;
    }
    
    public static void createCaseRole(List<DIR_Case__c> newList) {
        List<DIR_Case__c> filteredList = new List<DIR_Case__c>();
        for(DIR_Case__c c : newList){
            if(!c.CreatedFromFA__c){
                filteredList.add(c);
            }
        }
        if(filteredList.isEmpty()){
            return;
        }
        List<Case_Role__c> roles = new List<Case_Role__c>();
        Map<String, RecordType> rtMap = new Map<String, RecordType>();
        //List<RecordType> crRTList = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case_Role__c'];
        Map<Id, RecordType> caseRTMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE sObjectType = 'DIR_Case__c']);
        for(RecordType r : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case_Role__c']){
            rtMap.put(r.Name, r);
        }
        
        for (DIR_Case__c cs : filteredList) {
            if (cs.Employer__c != null) {
                Case_Role__c cr = new Case_Role__c();
                cr.Case__c = cs.Id;
                cr.Entity__c = cs.Employer__c;
                cr.Role__c = 'Case employer';
                cr.IsPersonAccount__c = cs.Employer__r.IsPersonAccount == true ? true : false;
                String caseRTName = caseRTMap.get(cs.RecordTypeId).Name;
                if(caseRTName.contains('PAGA')){
                    return;
                }
                if(caseRTName.contains('BOFE')){
                    cr.RecordTypeId = rtMap.get('BOFE').Id;
                }
                else if(caseRTName.contains('WCA')){
                    cr.RecordTypeId = rtMap.get('WCA').Id;
                }
                else if(caseRTName.contains('Garment')){
                    cr.RecordTypeId = rtMap.get('Garment').Id;
                }
                if( caseRTName.contains('WCA') || caseRTName.contains('Garment')) {
                    cr.Role__c = 'Defendant';
                }
                roles.add(cr);
            }
        }
        
        stopAffiliationCreation = true;
        if(roles != null && roles.size() > 0){
            insert roles;
        }
        
        stopAffiliationCreation = false;
    }
    
    public static void assignOffice(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap){
        List<Record_Type_Mapping__c> rtMapping = Record_Type_Mapping__c.getall().values();
        List<DIR_Case__c> updateList = new List<DIR_Case__c>();
        for(DIR_Case__c c : newList){
            //lets ignore the Non-Claimant Confirm Cases
            if(c.RecordTypeId == PRE_DOCKETING_CASE_RECORD_TYPE_ID){
                continue;
            }
            
            // Start with the work location first
            if(oldmap == null && c.Work_Location__c != null && c.Imported_From__c ==NULL){
                updateList.add(c);
            }
            else if (oldMap != NULL && c.Work_Location__c != null && c.Work_Location__c != oldmap.get(c.id).Work_Location__c && c.Imported_From__c == NULL){
                updateList.add(c);
            }
            else if(oldMap == null && c.Employer__c != null && c.Imported_From__c == NULL){
                updateList.add(c);
            }
            else if(oldMap != null && c.Employer__c != oldMap.get(c.Id).Employer__c && c.Imported_From__c == NULL){
                updateList.add(c);
            }
        }
        if(!updateList.isEmpty()){
            Record_Type_Mapping__c thisMapping;
            List<Office__c> officeList = [SELECT Id, Name, RecordType.DeveloperName, Address_1__c, Address_2__c, City__c, County__c, Fax__c, Office_Location__c, Phone__c, State__c, Zip_Code__c,
                                          (SELECT Id, Office__c, Zip_Code__c, Zip_Code__r.Name,County__c FROM Office_Zip_Code_Maps__r)
                                          FROM Office__c];
            if(officeList != null){
                Map<Office__c, List<Office_Zip_Code_Map__c>> zipMap = new Map<Office__c, List<Office_Zip_Code_Map__c>>();
                for(Office__c o : officeList){
                    if(!o.Office_Zip_Code_Maps__r.isEmpty()){
                        zipMap.put(o, o.Office_Zip_Code_Maps__r);
                    }
                }
                List<Id> acctIds = new List<Id>();
                List<Id> locIds = new List<Id>();
                for(DIR_Case__c c : updateList){
                    locIds.add(c.Work_Location__c);
                    acctIds.add(c.Employer__c);
                }
                Map<Id, Address__c> locMap = new Map<Id, Address__c>([SELECT Id, Zip_Code__c, Name FROM Address__c WHERE Id IN: locIds]);
                MAP<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, ShippingPostalCode, Name FROM Account WHERE Id IN: acctIds]);
                Map<Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'DIR_Case__c']);           
                for(DIR_Case__c c : updateList){
                    for(Record_Type_Mapping__c r : rtMapping){
                        system.debug('c rt name: '+rtMap.get(c.RecordTypeId).DeveloperName);
                        if(r.Case_Rec_Type__c == rtMap.get(c.RecordTypeId).DeveloperName){
                            thisMapping = r;
                            break;
                        }
                    }
                    system.debug('thisMapping: '+thisMapping);
                    String workLocation ;
                    if(locMap != null && locMap.containsKey(c.Work_Location__c) && locMap.get(c.Work_Location__c).Zip_Code__c != null){
                        workLocation = locMap.get(c.Work_Location__c).Zip_Code__c;
                    }else if(accountMap.get(c.Employer__c) != null && accountMap.get(c.Employer__c).ShippingPostalCode != null){
                        workLocation = accountMap.get(c.Employer__c).ShippingPostalCode;
                    }
                    if(workLocation != null ){
                        if(workLocation.length() >5)
                        {
                            workLocation = workLocation.substring(0, 5);
                            
                        }
                    } 
                    system.debug('workLocation: '+workLocation);
                    
                    //assign office for all record type ID including RCI
                    if(thisMapping != null /*&& c.recordtypeid!=Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId()*/){
                        for(Office__c o : zipMap.keySet()){
                            if(o.RecordType.DeveloperName == thisMapping.Office_Rec_Type__c){
                                system.debug('office id: '+o.id);
                                String locId;
                                String acctId;
                                String county;
                                
                                for(Office_Zip_Code_Map__c z : zipMap.get(o)){
                                    system.debug('z.Zip_Code__r.Name: '+z.Zip_Code__r.Name);
                                    //system.debug('workLocation: '+ workLocation);
                                    
                                    if(workLocation != null && z.Zip_Code__r.Name == workLocation )
                                    {
                                        system.debug('o.RecordType.DeveloperName: '+o.RecordType.DeveloperName);
                                        system.debug('thisMapping.Office_Rec_Type__c: '+thisMapping.Office_Rec_Type__c);
                                        locId = o.Id;
                                        county = z.County__c;
                                        break;
                                    }
                                    
                                    /*
if(locMap != null && workLocation != null && z.Zip_Code__r.Name == workLocation){
locId = o.Id;
county = z.County__c;
}
else if(accountMap.get(c.Employer__c) != null && z.Zip_Code__r.Name == accountMap.get(c.Employer__c).ShippingPostalCode ){
acctId = o.Id;
county = z.County__c;
}	*/
                                }
                                system.debug('locId: '+ locId);
                                if(c.Office__c == null){
                                    if(locId != null){
                                        c.Office__c = locId;
                                        c.County__c = county;
                                    }
                                    else if(acctId != null){
                                        c.Office__c = acctId;
                                        c.County__c = county;
                                    }
                                }
                                system.debug('office is populated here '+c.Office__c);
                                system.debug('county is populated here '+c.county__c);
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void updateRLLV(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap){
        
        //initialize a Set with BOFE Case Status which are equalvilent of BOFE Intake, BOFE Investigation, and BOFE Closed
        Set<String> bofeIntake = new Set<String>{'New', 'Awaiting Approval', 'Pending', null};
            Set<String> bofeInvestigation = new Set<String> {'Pre-investigation', 'Under Investigation', 'Conf Scheduled','Hearing Scheduled', 'Documents Received', 'NOF Issued', 'Under Writ', 'Referred to DA', 'Eligible for Closure', 'Open', 'Reopened with Senior Approval'};    
                Set<String> bofeClose = new Set<STring>{'Closed','Duplicate Case'};  
                    
                    // get all DIR cases    
                    Id caseRecordType2Id = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        
        set<id> caseSet = new set<id>();
        //set<id>accountSet = new Set<id>();
        for (DIR_Case__c c : newList){
            if ((!bofeClose.contains(c.status__c) && c.RecordTypeId == caseRecordType2Id) && (c.Case_accepted__c == true) && (oldMap.get(c.Id).Case_accepted__c == false))
                caseSet.add(c.ID);
        }
        system.debug('caseSet: ' + caseSet);
        
        
        // get Cases that have been accepted
        //list<DIR_Case__c> caseList = [SELECT ID, Case_accepted__c FROM DIR_Case__c Where ID in :caseSet and Case_accepted__c = True ];
        //system.debug('caseList: ' + caseList);
        //Set<Id> acceptedCases = new Set<Id>();
        //for (DIR_Case__c dc  : caseList)
        //  acceptedCases.add(dc.Id);
        // Get RLLVs that belong to the accepted cases
        if(caseSet.size() > 0){
            list<Report_Of_Labor_Code_Violation__c> acceptedList = [SELECT ID, Case_accepted__c FROM Report_Of_Labor_Code_Violation__c Where DIR_Case__c in : caseSet];
            if(acceptedList.size() > 0){
                for(Report_Of_Labor_Code_Violation__c RLCV : acceptedList){
                    RLCV.Case_Accepted__c = true;
                }
                update acceptedList;
            }
        }
        
    }
    /*   
public static void updateCase(List<DIR_Case__c> newList){
// updates case fields when a new case is created
// caseRecortType1 and 2 define that these tasks only take place for BOFE cases

Id caseRecordType2Id = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
Id caseRecordType3Id = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Inspection Request').getRecordTypeId();
Set<Id> accountSet = new Set<Id>();
for (DIR_Case__c c : newList){
//update the Case Number for the 'Not Submitted'(Unconfirm Case from Online Community) case
if(c.RecordTypeId == OWCConstants.PRE_DOCKETING_CASE_RECORD_TYPE_ID){
//c.Case_Number__c = 'WC-' + c.Name;
}
if ( (c.RecordTypeId == caseRecordType2Id) || (c.RecordTypeId == caseRecordType3Id)) 
accountSet.add(c.Employer__c);
}

Map<Id, Account> accountList = new Map<Id, Account>([SELECT Id, ShippingPostalCode FROM Account WHERE Id IN : accountSet]);
Set<String> postalCodes = new Set<String>();
for (Account account : accountList.values())
postalCodes.add(account.ShippingPostalCode);

List<Office_Zip_Code_Map__c> junctions = [SELECT Zip_Code__r.Name, Office__c FROM Office_Zip_Code_Map__c WHERE Zip_Code__r.Name IN :postalCodes];
Map<String, String> junctionMap = new Map<String, String>();
for (Office_Zip_Code_Map__c junction : junctions) {
junctionMap.put(junction.Zip_Code__r.Name, junction.Office__c);
}
//String RICRecTypeId=Schema.getGlobalDescribe().get('DIR_Case__c').getDescribe().getRecordTypeInfosByName().get('RIC').getRecordTypeId();
for (DIR_Case__c c : newList) {
if (accountList.containsKey(c.Employer__c) && junctionMap.containsKey(accountList.get(c.Employer__c).ShippingPostalCode)) {
if(c.Office__c == null){
// only populate the office if the office is not set manually
c.Office__c = junctionMap.get(accountList.get(c.Employer__c).ShippingPostalCode);
}
}
}

}
*/
    //method that handles the re-allocation of RLCVs in case the Employer on a case changes
    public static void updateLaborCodeViolations(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap){
        
        //class with static variable is used to make sure the trigger does not run in an infinite loop
        if (checkRecursive.runOnce2()){
            
            //initialize a Set with BOFE Case Status which are equalvilent of BOFE Intake, BOFE Investigation, and BOFE Closed
            
            Set<String> bofeIntake = new Set<String>{'New', 'Awaiting Approval', 'Pending', null};
                Set<String> bofeInvestigation = new Set<String> {'Pre-investigation', 'Under Investigation', 'Conf Scheduled','Hearing Scheduled', 'Documents Received', 'NOF Issued', 'Under Writ', 'Referred to DA', 'Eligible for Closure', 'Open', 'Reopened with Senior Approval'};    
                    Set<String> bofeClose = new Set<STring>{'Closed','Duplicate Case'};  
                        
                        //get record types
                        //String intakeRecordType = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
                        String investigationRecordType = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
            //String closedRecordType = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Closed').getRecordTypeId();
            
            //get the BOFE Open Case RT record from the Key Value Store custom setting
            List<String> recordTypeNameList = new List<String>();
            List<Key_Value_Store__c> keyValueStoreList = new List<Key_Value_Store__c>();
            keyValueStoreList = [SELECT Id, Value__c FROM Key_Value_Store__c WHERE Name = 'BOFE Open Case RT'];
            //split the values from the Value__c field and add them to a list
            if (keyValueStoreList.size() != 0)
                recordTypeNameList = keyValueStoreList.get(0).Value__c.split(',', 0);
            
            //add values from list to a set 
            Set<String> recordTypeNameSet = new Set<String>();
            for (String s : recordTypeNameList)
                recordTypeNameSet.add(s.trim());
            
            //get the record types based on the values found in the Key Value Store custom setting
            List<RecordType> recordTypeList = new List<RecordType>();
            recordTypeList = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and Name IN : recordTypeNameSet];
            
            //add the record types to a set
            Set<Id> recordTypeSet = new Set<Id>();
            for (RecordType rt : recordTypeList)
                recordTypeSet.add(rt.Id);
            
            //create sets of Ids and Employers for the updated cases
            Set<Id> accountSet = new Set<Id>(); 
            Set<Id> caseSet = new Set<Id>();
            for (DIR_Case__c dc : newList){
                if(!test.isRunningTest() && GlobalFlagClass.preventBOFEEmployerChange && oldMap.get(dc.Id).Employer__c != dc.Employer__c && recordTypeSet.contains(dc.RecordTypeId)){
                    dc.addError('You cannot change Employer for BOFE cases.');
                }else if ((oldMap.get(dc.Id).Employer__c != dc.Employer__c) &&(dc.Employer__c != null)){
                    accountSet.add(dc.Employer__c);
                    caseSet.add(dc.Id);
                }
            }
            
            //put the updated cases in a list
            List<DIR_Case__c> caseList = new List<DIR_Case__c>();
            caseList = [SELECT Id, Related_Case__c, Status__c, Employer__c, RecordTypeId FROM DIR_Case__c WHERE Id IN : caseSet];
            
            //get a list of all cases: the updated ones and the ones found on the new employer
            List<DIR_Case__c> allCaseList = new List<DIR_Case__c>();
            allCaseList = [SELECT Id, Employer__c, RecordTypeId, Status__c, Related_Case__c FROM DIR_Case__c WHERE Employer__c IN : accountSet AND RecordTypeId IN :recordTypeSet];
            
            //create a map between the new employer and the existing cases
            Map<Id, List<DIR_Case__c>> accountToCase = new Map<Id, List<DIR_Case__c>>();
            Set<Id> foundCases = new Set<Id>();
            system.debug('allcases:' + allCaseList);
            system.debug('caseset:' + caseset);
            for (DIR_Case__c dc : allCaseList){
                if (!caseSet.contains(dc.Id)){
                    if (!accountToCase.containsKey(dc.Employer__c))
                        accountToCase.put(dc.Employer__c, new List<DIR_Case__c>{dc});
                    else
                        accountToCase.get(dc.Employer__c).add(dc);
                    foundCases.add(dc.Id);
                }
            }
            
            //get list of inspections for the existing cases
            List<DIR_Inspection__c> inspectionList = new List<DIR_Inspection__c>();
            inspectionList = [SELECT Id, DIR_Case__c FROM DIR_Inspection__c WHERE DIR_Case__c IN : foundCases];
            
            //get list of inspections for the updated cases
            List<DIR_Inspection__c> inspectionListForUpdatedCases = new List<DIR_Inspection__c>();
            inspectionListForUpdatedCases = [SELECT Id, DIR_Case__c FROM DIR_Inspection__c WHERE DIR_Case__c IN : caseSet];
            
            //if the existing cases have inspections, add them to a set
            Set<Id> caseWithInspections = new Set<Id>();
            for (DIR_Inspection__c insp : inspectionList)
                caseWithInspections.add(insp.DIR_Case__c);
            
            //if the updated cases have inspections, add them to a set  
            Set<Id> updatedCaseWithInspections = new Set<Id>();
            for (DIR_Inspection__c insp : inspectionListForUpdatedCases)
                updatedCaseWithInspections.add(insp.DIR_Case__c);
            
            //get list of RLCVs for both updated and existing cases
            List<Report_of_Labor_Code_Violation__c> rlcvList = new List<Report_of_Labor_Code_Violation__c>();
            rlcvList = [SELECT Id, DIR_Case__c, Account__c FROM Report_of_Labor_Code_Violation__c WHERE DIR_Case__c IN : caseSet OR DIR_Case__c IN : foundCases];
            
            //create two maps between the case and a list of the associated RLCVs, for both updated and existing cases
            Map<Id, List<Report_of_Labor_Code_Violation__c>> caseToRLCV = new Map<Id, List<Report_of_Labor_Code_Violation__c>>();
            Map<Id, List<Report_of_Labor_Code_Violation__c>> foundCaseToRLCV = new Map<Id, List<Report_of_Labor_Code_Violation__c>>();
            for (Report_of_Labor_Code_Violation__c rlcv : rlcvList){
                //create map for the updated cases
                if (caseSet.contains(rlcv.DIR_Case__c)){
                    if (!caseToRLCV.containsKey(rlcv.DIR_Case__c))
                        caseToRLCV.put(rlcv.DIR_Case__c, new List<Report_of_Labor_Code_Violation__c>{rlcv});
                    else
                        caseToRLCV.get(rlcv.DIR_Case__c).add(rlcv);
                }
                //create map for existing cases
                if (foundCases.contains(rlcv.DIR_Case__c)){
                    if (!foundCaseToRLCV.containsKey(rlcv.DIR_Case__c))
                        foundCaseToRLCV.put(rlcv.DIR_Case__c, new List<Report_of_Labor_Code_Violation__c>{rlcv});
                    else
                        foundCaseToRLCV.get(rlcv.DIR_Case__c).add(rlcv);
                }
            }
            
            //re-assign the RLCVs
            Set<Id> errorSet = new Set<Id>();
            List<Report_of_Labor_Code_Violation__c> rlcvToUpdate = new List<Report_of_Labor_Code_Violation__c>();
            List<DIR_Case__c> caseToUpdate = new List<DIR_Case__c>();
            system.debug('casemap:' + accountToCase);
            for (DIR_Case__c dc : caseList){
                //if the new Employer has existing cases
                if (accountToCase.containsKey(dc.Employer__c)) {
                    //if the new Employer has only one open case
                    if (accountToCase.get(dc.Employer__c).size() == 1){
                        //if the updated case is Intake(Case Status = New) and the existing cases are Intake or Investigation
                        if ((dc.recordTypeID == investigationRecordType && bofeIntake.contains(dc.Status__c)) && 
                            ((accountToCase.get(dc.Employer__c).get(0).recordTypeID == investigationRecordType && bofeIntake.contains(accountToCase.get(dc.Employer__c).get(0).status__c)) || 
                             (accountToCase.get(dc.Employer__c).get(0).RecordTypeId == investigationRecordType && bofeInvestigation.contains(accountToCase.get(dc.Employer__c).get(0).status__c)))){
                                 //if the case has RLCVs
                                 if (caseToRLCV.containsKey(dc.Id)){
                                     //re-assign the RLCvs
                                     for (Report_of_Labor_Code_Violation__c rlcv : caseToRLCV.get(dc.Id)){
                                         rlcv.DIR_Case__c = accountToCase.get(dc.Employer__c).get(0).Id;
                                         rlcvToUpdate.add(rlcv);
                                     }
                                 }
                                 //update case
                                 dc.Status__c = 'Duplicate Case';
                                 //dc.RecordTypeId = closedRecordType;
                                 dc.Related_Case__c = accountToCase.get(dc.Employer__c).get(0).Id;
                                 caseToUpdate.add(dc);
                             }
                        //if the updated case is Investigation
                        if (dc.RecordTypeId == investigationRecordType && bofeInvestigation.contains(dc.Status__c)){
                            //if the existing case is Investigation 
                            if (accountToCase.get(dc.Employer__c).get(0).RecordTypeId == investigationRecordType && bofeInvestigation.contains(accountToCase.get(dc.Employer__c).get(0).status__c)){
                                //if the updated case has inspections
                                if (updatedCaseWithInspections.contains(dc.Id)){
                                    //if the existing case has RLCVs
                                    if (foundCaseToRLCV.containsKey(accountToCase.get(dc.Employer__c).get(0).Id)){
                                        //re-assign the RLCVs from existing case to the new case 
                                        for (Report_of_Labor_Code_Violation__c rlcv : foundCaseToRLCV.get(accountToCase.get(dc.Employer__c).get(0).Id)){
                                            rlcv.DIR_Case__c = dc.Id;
                                            rlcvToUpdate.add(rlcv);
                                        }
                                    }
                                    //update existing case
                                    accountToCase.get(dc.Employer__c).get(0).Status__c = 'Duplicate Case';
                                    //accountToCase.get(dc.Employer__c).get(0).RecordTypeId = closedRecordType;
                                    accountToCase.get(dc.Employer__c).get(0).Related_Case__c = dc.Id;
                                    caseToUpdate.add(accountToCase.get(dc.Employer__c).get(0)); 
                                }
                                else{
                                    //if the existing case has inspections
                                    if (caseWithInspections.contains(accountToCase.get(dc.Employer__c).get(0).Id)){
                                        //if the case has RLCVs
                                        if (caseToRLCV.containsKey(dc.Id)){
                                            //re-assign the RLCvs
                                            for (Report_of_Labor_Code_Violation__c rlcv : caseToRLCV.get(dc.Id)){
                                                rlcv.DIR_Case__c = accountToCase.get(dc.Employer__c).get(0).Id;
                                                rlcvToUpdate.add(rlcv);
                                            }
                                        }
                                        //update case
                                        dc.Status__c = 'Duplicate Case';
                                        //dc.RecordTypeId = closedRecordType;
                                        dc.Related_Case__c = accountToCase.get(dc.Employer__c).get(0).Id;
                                        caseToUpdate.add(dc);
                                    }
                                    //if the existing case does not have inspections
                                    else{
                                        //if the existing case has RLCVs
                                        if (foundCaseToRLCV.containsKey(accountToCase.get(dc.Employer__c).get(0).Id)){
                                            //re-assign the RLCVs from existing case to the new case 
                                            for (Report_of_Labor_Code_Violation__c rlcv : foundCaseToRLCV.get(accountToCase.get(dc.Employer__c).get(0).Id)){
                                                rlcv.DIR_Case__c = dc.Id;
                                                rlcvToUpdate.add(rlcv);
                                            }
                                        }
                                        //update existing case
                                        accountToCase.get(dc.Employer__c).get(0).Status__c = 'Duplicate Case';
                                        //accountToCase.get(dc.Employer__c).get(0).RecordTypeId = closedRecordType;
                                        accountToCase.get(dc.Employer__c).get(0).Related_Case__c = dc.Id;
                                        caseToUpdate.add(accountToCase.get(dc.Employer__c).get(0)); 
                                    }
                                }
                            }
                            //if the found case is intake
                            else{
                                //if the existing case has RLCVs
                                if (foundCaseToRLCV.containsKey(accountToCase.get(dc.Employer__c).get(0).Id)){
                                    //re-assign the RLCVs from existing case to the new case 
                                    for (Report_of_Labor_Code_Violation__c rlcv : foundCaseToRLCV.get(accountToCase.get(dc.Employer__c).get(0).Id)){
                                        rlcv.DIR_Case__c = dc.Id;
                                        rlcvToUpdate.add(rlcv);
                                    }
                                }
                                //update existing case
                                accountToCase.get(dc.Employer__c).get(0).Status__c = 'Duplicate Case';
                                //accountToCase.get(dc.Employer__c).get(0).RecordTypeId = closedRecordType;
                                accountToCase.get(dc.Employer__c).get(0).Related_Case__c = dc.Id;
                                caseToUpdate.add(accountToCase.get(dc.Employer__c).get(0)); 
                            }
                        }
                    }
                    //if the new Employer has more than one open case, an error must be shown
                    /*else{
errorSet.add(dc.Id);
}*/
                }
                //if the new Employer does not have any existing cases, just update the RLCVs to the new Employer
                else{
                    if (caseToRLCV.containsKey(dc.Id)){
                        for (Report_of_Labor_Code_Violation__c rlcv : caseToRLCV.get(dc.Id)){
                            rlcv.Account__c = dc.Employer__c;
                            rlcvToUpdate.add(rlcv);
                        }
                    }
                }
            }
            system.debug('errset:' + errorset);
            //add error
            /*for (DIR_Case__c dc : newList){
if (errorSet.contains(dc.Id))
dc.addError('More than one open case has been located for this employer. Please contact your Senior Deputy or a System Administrator for further instructions');
}*/
            
            update rlcvToUpdate;
            
            update caseToUpdate;
            
        }
    }
    
    
    public static void AddErrorsToCase(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap) {
        
        Set<Id> caseIds = new Set<Id>();
        for (DIR_Case__c cs : newList) {
            if (cs.Refer_to_JEU__c == 'Referred') {
                caseIds.add(cs.Id);
            }
        }
        
        if(caseIds.isEmpty()) return;
        
        Map<Id, AggregateResult> PaymentPlans = new Map<Id, AggregateResult>([SELECT Case__c Id, COUNT(Id) Number FROM Payment_Plan__c WHERE Case__c IN :caseIds AND Payment_Plan_Status__c = 'Not Current' GROUP BY Case__c]);
        system.debug('PaymentPlans::: ' + PaymentPlans);
        
        //Map<Id, AggregateResult> Hearings = new Map<Id, AggregateResult>([SELECT Case__c Id, MAX(Hearing_Date__c) MaxDate FROM Hearing__c WHERE Case__c IN :caseIds  GROUP BY Case__c]);
        
        integer noDays = 0;
        List<Key_Value_Store__c> keyValueStoreList = [SELECT Id, Value__c FROM Key_Value_Store__c WHERE Name = 'BOFE JEU Referral Hearing Timeframe'];
        if (keyValueStoreList.size() != 0)
            noDays = integer.valueOf(keyValueStoreList.get(0).Value__c);
        
        for (DIR_Case__c cs : newList) {
            if (cs.Refer_to_JEU__c == 'Referred') {
                if (!PaymentPlans.containsKey(cs.Id) & PaymentPlans.size() > 0) {
                    cs.addError('All Payment Plans are current for this case, it cannot be referred to JEU');
                }
                /*
// performing this via flow and standard valication rule now
if (Hearings.containsKey(cs.Id)) {
if (Date.today().daysbetween(((DateTime)Hearings.get(cs.Id).get('MaxDate')).Date()) < noDays) {
cs.addError('A hearing has been scheduled too recently to refer this case to JEU.');
}
}
*/
            }
        }
    }
    //@Future
    /*public static void createLinkedCasesFuture(Id[] caseIds) {
//List<Dir_Case__c> dirCaseList = [SELECT Id, Employer__c FROM Dir_Case__c WHERE Id in :caseIds];
//Map<String,Object> dirCaseMap = (Map<String,Object>)JSON.deserializeUntyped(jsonStr);
//List<Dir_Case__c> dirCaseList = (List<Dir_Case__c>)JSON.deserializeStrict(jsonStr, Dir_Case__c.class);
//List<Dir_Case__c> dirCaseList = (List<Dir_Case__c>)dirCaseMap.values();
//createLinkedCases(dirCaseList);

List<CreateLinkedCases__e> linkedCaseEvents = new List<CreateLinkedCases__e>();
for(Id caseId : caseIds){
linkedCaseEvents.add(new CreateLinkedCases__e(CaseId__c = caseId));
}


// Call method to publish events
List<Database.SaveResult> results = EventBus.publish(linkedCaseEvents);

// Inspect publishing result for each event
for (Database.SaveResult sr : results) {
if (sr.isSuccess()) {
System.debug('Successfully published event.');
} else {
for(Database.Error err : sr.getErrors()) {
System.debug('Error returned: ' +
err.getStatusCode() +
' - ' +
err.getMessage());
}
}       
}
}*/
    
    //public static void createLinkedCases(List<DIR_Case__c> newList){
    /*Map<String,List<DIR_Case__c>> empMap = new Map<String,List<DIR_Case__c>>();
List<Linked_Case__c> linkedCases = new List<Linked_Case__c>();
for(DIR_Case__c c : newList){
if(empMap.containsKey(c.Employer__c)){
List<DIR_Case__c> tempLst = empMap.get(c.Employer__c);
tempLst.add(c);
empMap.put(c.Employer__c, tempLst);
}else{
empMap.put(c.Employer__c, new DIR_Case__c[]{c});
}
}*/
    
    //B-25243 changes
    /*EmailTemplate et = [Select Id, HtmlValue, Body, subject from EmailTemplate where DeveloperName = 'Linked_case_created' LIMIT 1];
List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

String baseURL = system.URL.getSalesforceBaseUrl().toExternalForm();

Map<Id,List<String>> emailsMap = new Map<Id,List<String>>();
for(Account acc : [select id, (select id, Assigned_Deputy_Email__c from DIR_Cases__r
WHERE ID NOT IN :newList AND Open_Case__c = 'True' AND Assigned_Deputy_Email__c != null)
from Account WHERE Id IN :empMap.keySet()]){
if(acc.DIR_Cases__r != null && acc.DIR_Cases__r.size() > 0){
List<String> emailList = new List<String>();
for(DIR_Case__c dc : acc.DIR_Cases__r){
emailList.add(dc.Assigned_Deputy_Email__c);
}
emailsMap.put(acc.id, emailList);
}
}*/
    
    /*List<Task> tasks = new List<Task>();
String standardTaskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard Task').getRecordTypeId();
Set<Id> deputyIdSet = new Set<Id>();
for(Account acc : [select id, (select id, Assigned_Deputy__c,Assigned_Deputy__r.name, Assigned_Deputy__r.User__c,
Case_Number__c, Employer__c, Status__c, Record_Type_Name__c, Employer__r.name
from DIR_Cases__r WHERE ID NOT IN :newList AND Open_Case__c = 'True' AND Employer__c != null AND Assigned_Deputy__c != null ORDER BY LastModifiedDate DESC)
from Account WHERE Id IN :empMap.keySet()]){
if(acc.DIR_Cases__r != null && acc.DIR_Cases__r.size() > 0){
for(DIR_Case__c c : empMap.get(acc.id)){
for(DIR_Case__c cs : acc.DIR_Cases__r){
Linked_Case__c lc = new Linked_Case__c();
lc.Assigned_Deputy__c = cs.Assigned_Deputy__r.name;
lc.Case_Number__c = cs.Case_Number__c;
lc.CM_Case__c = c.id;
lc.Linked_Case__c = cs.id;
lc.Employer__c = acc.id;
linkedCases.add(lc);

//if(cs.Assigned_Deputy__r.User__c != Null){
if(!deputyIdSet.contains(cs.Assigned_Deputy__r.User__c)){
deputyIdSet.add(cs.Assigned_Deputy__r.User__c);
tasks.add(new Task(OwnerId = cs.Assigned_Deputy__r.User__c, 
WhatId = c.id,
RecordTypeId = standardTaskRT,
Subject = 'New Case Opened',
Description = 'A new case has been opened for the same employer.\n Employer: '+cs.Employer__r.name,
ActivityDate = Date.today(),
Due_Date__c = Date.today(),
Status = 'Not Started',
Priority =  'Normal'));
}*/
    //}
    
    /*if(emailsMap.containsKey(acc.id)){
Messaging.SingleEmailMessage emsg = new Messaging.SingleEmailMessage();
emsg.setTemplateId(et.Id);
emsg.setToAddresses(emailsMap.get(acc.id));
emsg.setTargetObjectId(cs.Assigned_Deputy__r.User__c);
emsg.saveAsActivity = false;
String htmlBody = et.htmlValue;
htmlBody = htmlBody.replace('{!DIR_Case__c.Employer__c}', cs.Employer__r.name);
htmlBody = htmlBody.replace('{!DIR_Case__c.Record_Type_Name__c}', cs.Record_Type_Name__c);
htmlBody = htmlBody.replace('{!DIR_Case__c.Link}',  + baseURL + '/' + cs.id);
htmlBody = htmlBody.replaceAll(']]>','');
emsg.setHtmlBody(htmlBody);
emsg.setSubject(et.Subject);
emails.add(emsg);
}*/
    /* }
}
}
}

if(linkedCases.size() > 0){
insert linkedCases;
}

if(tasks.size() > 0){
insert tasks;
}
*/
    
    /*if(emails.size() > 0){
Messaging.sendEmail(emails);
}*/
    //}
    
    /*public static void updateLinkedCases(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap){
Map<String,String> oldEmp = new Map<String,String>();
Map<String,List<DIR_Case__c>> newEmp = new Map<String,List<DIR_Case__c>>();
Set<ID> closedCaseIDs = new Set<ID>();
List<Linked_Case__c> delLC = new List<Linked_Case__c>();
List<Linked_Case__c> addLC = new List<Linked_Case__c>();
for(DIR_Case__c c : newList){
if(c.Employer__c != oldMap.get(c.id).Employer__c){
if(newEmp.containsKey(c.Employer__c)){
List<DIR_Case__c> tempLst = newEmp.get(c.Employer__c);
tempLst.add(c);
newEmp.put(c.Employer__c, tempLst);
}else{
newEmp.put(c.Employer__c, new DIR_Case__c[]{c});
}

oldEmp.put(c.id, oldMap.get(c.id).Employer__c);
}

if(c.Status__c != oldMap.get(c.id).Status__c && c.Closed__c){
closedCaseIDs.add(c.id);
}
}

for(Linked_Case__c lc : [select id,Employer__c,CM_Case__c,Linked_Case__c from Linked_Case__c WHERE Linked_Case__c IN :closedCaseIDs OR (CM_Case__c IN :oldEmp.keySet() AND Employer__c IN :oldEmp.values())]){
if(lc.Employer__c == oldEmp.get(lc.CM_Case__c) || closedCaseIDs.contains(lc.Linked_Case__c)){
delLC.add(lc);
}
}

for(Account acc : [select id, (select id, Assigned_Deputy__c,Assigned_Deputy__r.name, Case_Number__c, Employer__c, Status__c from DIR_Cases__r WHERE ID NOT IN :newList AND Open_Case__c = 'True' AND Assigned_Deputy__c != null) from Account WHERE Id IN :newEmp.keySet()]){
if(acc.DIR_Cases__r != null && acc.DIR_Cases__r.size() > 0){
for(DIR_Case__c c : newEmp.get(acc.id)){
for(DIR_Case__c cs : acc.DIR_Cases__r){
Linked_Case__c lc = new Linked_Case__c();
lc.Assigned_Deputy__c = cs.Assigned_Deputy__r.name;
lc.Case_Number__c = cs.Case_Number__c;
lc.CM_Case__c = c.id;
lc.Linked_Case__c = cs.id;
lc.Employer__c = acc.id;
addLC.add(lc);
}
}
}
}

if(delLc.size() > 0){
delete delLC;
}

if(addLc.size() > 0){
insert addLC;
}
}*/
    
    private static void createAssignmentHistory(List<DIR_Case__c> newCases,Map<Id, DIR_Case__c> oldCases){
        
        List<Assignment_History__c> histories = new List<Assignment_History__c>();
        Set<String> setCaseIds = new Set<String>();
        Map<String, String> mapCaseIdToNewDeputy = new Map<String, String>();
        
        for(DIR_Case__c objCase : newCases){
            
            if(objCase.Assigned_Deputy__c != Null && 
               (oldCases == Null || (objCase.Assigned_Deputy__c != oldCases.get(objCase.Id).Assigned_Deputy__c || 
                                     (objCase.Status__c == 'Reopened with Senior Approval'  && objCase.Status__c != oldCases.get(objCase.Id).Status__c &&
                                      Boolean.valueOf(oldCases.get(objCase.Id).Closed__c))))){
                                          
                                          
                                          if(oldCases != Null && oldCases.get(objCase.Id).Assigned_Deputy__c != Null){
                                              setCaseIds.add(objCase.Id);
                                          }
                                          
                                          mapCaseIdToNewDeputy.put(objCase.Id,objCase.Assigned_Deputy__c);
                                      }
        }
        
        
        for(Assignment_History__c objAH : [SELECT Id,End_Date__c
                                           FROM Assignment_History__c
                                           WHERE End_Date__c = Null
                                           AND Case_Management__c =: setCaseIds]){
                                               
                                               objAH.End_Date__c = Date.today();
                                               histories.add(objAH);                                 
                                           }
        
        map<Id,DIR_Employee__c> mapEmployees =  new map<Id,DIR_Employee__c>([SELECT Id,User__c
                                                                             FROM DIR_Employee__c
                                                                             WHERE Id =: mapCaseIdToNewDeputy.values()
                                                                             AND User__c != Null]);
        for(String caseId : mapCaseIdToNewDeputy.keyset()){
            
            if(mapEmployees.containsKey(mapCaseIdToNewDeputy.get(caseId))){ 
                
                histories.add(new Assignment_History__c(Start_Date__c = Date.today(),
                                                        Case_Management__c = caseId,
                                                        OwnerId = mapEmployees.get(mapCaseIdToNewDeputy.get(caseId)).User__c));
            }
        }
        
        upsert histories;
    }
    //-----------------------------
    // @param: Map<Id, DIR_Case__c> cases
    // @description: Method to prevent non admins from deleting cases considering purge date
    // @return: void
    //-----------------------------
    public static void validateBeforeCaseDelete(Map<Id, DIR_Case__c> cases){
        
        Boolean isSystemAdmin = false;
        
        List<Profile> sysAdminList = [SELECT Id FROM Profile WHERE Name  like 'System Administrator%'];
        
        if (sysAdminList.size() > 1)
        {
            for (Integer i = 0; i < sysAdminList.size(); i++)
            {
                if (Userinfo.getProfileId() == sysAdminList[i].Id)
                {
                    isSystemAdmin = true;
                }
            }
        }                
        
        if(!isSystemAdmin || Test.isRunningTest()){
            
            for(DIR_Case__c objCase : cases.values()){
                
                if(objCase.Purge_Date__c == Null || objCase.Purge_Date__c < Date.Today()){
                    
                    objCase.addError('Only system administrators can delete historical cases.');
                }
                
            }
        }
    }
    
    public static void updateDeputyOnMeeting(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap){
        
        set<id> caseSet = new set<id>();
        //compare if assigned deputy or senior deputy has changed
        for (DIR_Case__c c : newList){
            if (((c.Assigned_Deputy__c != oldMap.get(c.Id).Assigned_Deputy__c) || (c.Assigned_Deputies_Senior__c != oldMap.get(c.Id).Assigned_Deputies_Senior__c)) && (c.Assigned_Deputy__c != null))
                caseSet.add(c.ID);
        }
        
        
        if(caseSet.size() > 0){
            list<Hearing__c> acceptedList = [SELECT ID, Case__c, Case_Deputy__c, Sr_Case_Deputy__c,Case__r.Assigned_Deputy__r.User__c,
                                             Case__r.Assigned_Deputy__r.Manager__r.User__c FROM Hearing__c Where Case__c in : caseSet];
            if(acceptedList.size() > 0){
                for(Hearing__c hearing : acceptedList){
                    hearing.Case_Deputy__c = hearing.Case__r.Assigned_Deputy__r.User__c;
                    hearing.Sr_Case_Deputy__c = hearing.Case__r.Assigned_Deputy__r.Manager__r.User__c;
                }
                System.debug('updated Deputy');
                update acceptedList;
            }
        }
        
    }
    
    public static void updateClosedCaseAssignedHistory(List<DIR_Case__c> caseList){
        List<Assignment_History__c> ahList = new List<Assignment_History__c>();
        for(DIR_Case__c c : [SELECT id,(SELECT id, End_Date__c FROM Assignment_History__r WHERE End_Date__c = null ORDER BY LastModifiedDate DESC LIMIT 1) FROM DIR_Case__c WHERE id IN :caseList]){
            if(c.Assignment_History__r != null && c.Assignment_History__r.size() > 0){
                c.Assignment_History__r[0].End_Date__c = system.today();
                ahList.add(c.Assignment_History__r[0]);
            }
        }
        if(ahList.size() > 0){
            update ahList;
        }
    }
    //@InvocableMethod(label='Send Office Change Alert confirmation')
    public static void sendOfficeChangeEmailAlert(DIR_Case__c dirCase){
        System.debug('dirCase'+dirCase);
        System.debug('dircase query'+ [SELECT Id,Entity__r.PersonEmail,Case_Role_Account_Name__c,Case_Employer__c,Case_Number__c, Case__r.Office__r.Name,Case__r.DIR_WCA_Office_Address__c,Case__r.DIR_Office_Phone_Number__c,
                                       Case__r.Name , Case__r.Employer__r.Name 
                                       FROM Case_Role__c
                                       WHERE (Role__c = 'Advocate' OR Role__c = 'Claimant') AND Case__c =: dirCase.Id]);
        List<Case_Role__c> caseRoles = [SELECT Id,Entity__r.PersonEmail,Case_Role_Account_Name__c,Case_Employer__c,Case_Number__c,
                                        Case__r.Office__r.Name,Case__r.DIR_WCA_Office_Address__c,Case__r.DIR_Office_Phone_Number__c,
                                        Case__r.Name , Case__r.Employer__r.Name 
                                        FROM Case_Role__c
                                        WHERE (Role__c = 'Advocate' OR Role__c = 'Claimant')
                                        AND Case__c =: dirCase.Id];
        if(!caseRoles.isEmpty() && caseRoles.size() >0){
            for(Case_Role__c cr: caseRoles){
                String officeName ;	
                if(cr.Case__r.Office__r.Name == 'WCA - OUT OF STATE'){
                    officeName = 'Pending Assignment';
                }else {
                    officeName = cr.Case__r.Office__r.Name+'';
                }
                sendEmailNotification('OC_Office_Notification_Email', 
                                      cr.Entity__r.PersonEmail,
                                      cr.Case_Role_Account_Name__c,
                                      cr.Case__r.Employer__r.Name,
                                      cr.Case__r.Name,
                                      officeName, 
                                      cr.Case__r.DIR_WCA_Office_Address__c,
                                      cr.Case__r.DIR_Office_Phone_Number__c);
            }
        } else {
            //lets check for the related parties
            List<Related_Party__c> relatedParties = [SELECT Id,Email__c,Business_Name__c,Combined_First_and_Last_Name__c,
                                                     Case_Management__r.Office__r.Name,Case_Management__r.DIR_WCA_Office_Address__c,
                                                     Case_Management__r.DIR_Office_Phone_Number__c,Case_Management__r.Name,
                                                     Case_Management__r.Employer__c,Case_Management__r.Employer_Name_in_Text__c
                                                     FROM Related_Party__c
                                                     WHERE (Role__c = 'Advocate' OR Role__c = 'Claimant')
                                                     AND Case_Management__c =: dirCase.Id];
            for(Related_Party__c rp: relatedParties)
            {
                String officeName ;	
                if(rp.Case_Management__r.Office__r.Name == 'WCA - OUT OF STATE'){
                    officeName = 'Pending Assignment';
                }else {
                    officeName = rp.Case_Management__r.Office__r.Name;
                }
                String recipientName;
                if(String.isNotBlank(rp.Business_Name__c)){
                    recipientName =  rp.Business_Name__c;
                } else{
                    recipientName = rp.Combined_First_and_Last_Name__c;
                }
                sendEmailNotification('OC_Office_Notification_Email',
                                      rp.Email__c,
                                      recipientName,
                                      rp.Case_Management__r.Employer_Name_in_Text__c,
                                      rp.Case_Management__r.Name ,
                                      officeName, 
                                      rp.Case_Management__r.DIR_WCA_Office_Address__c,
                                      rp.Case_Management__r.DIR_Office_Phone_Number__c);
            }
        }
    }
    
    public static void sendEmailNotification(String emailTemplateName, 
                                             String toAddress, 
                                             String recipientName,
                                             String employerName,
                                             String caseName, 
                                             String office, 
                                             String officeAdd, 
                                             String officePhone){
                                                 List<EmailTemplate> emailTemplateList = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                                                                          FROM EmailTemplate WHERE developerName=: emailTemplateName];
                                                 List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                                                 
                                                 Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                                                 emailMessage.setTemplateId(emailTemplateList[0].Id);
                                                 
                                                 emailMessage.setToAddresses(new list<String>{toAddress});
                                                 emailMessage.saveAsActivity = true;
                                                 String htmlBody = emailTemplateList[0].Body; 
                                                 htmlBody = htmlBody.replace('{!User}',recipientName+'<br></br><br></br>');
                                                 Date todayDate = Date.today();
                                                 htmlBody = htmlBody.replace('{!Today}',todayDate.year() + '/' + todayDate.month() + '/' + todayDate.day());
                                                 system.debug('employerName: '+employerName);
                                                 if(String.isNotBlank(employerName)){
                                                     htmlBody = htmlBody.replace('{!DIR_Case__c.Employer_Name_in_Text__c}', employerName);
                                                 }
                                                 
                                                 
                                                 if(office == 'Pending Assignment'){
                                                     htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', '<br></br><br></br>'+office+'<br></br><br></br>');
                                                     htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', '');
                                                     htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', '');
                                                 } else{
                                                     htmlBody = htmlBody.replace('{!DIR_Case__c.Office__c }', '<br></br><br></br>'+office+'<br></br>');
                                                     htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_WCA_Office_Address__c}', officeAdd+'<br></br>');
                                                     htmlBody = htmlBody.replace('{!DIR_Case__c.DIR_Office_Phone_Number__c}', officePhone+'<br></br><br></br>');
                                                 }
                                                 htmlBody = htmlBody.replace('{!DIR_Case__c.Name}', caseName);
                                                 //htmlBody = htmlBody.replace('{!Case.Office}', recipientName);
                                                 emailMessage.setHtmlBody(htmlBody);
                                                 String subject = emailTemplateList[0].Subject;
                                                 
                                                 emailMessage.setSubject(subject);
                                                 emailList.add(emailMessage);
                                                 
                                                 if(!emailList.isEmpty()){
                                                     try{
                                                         Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);    
                                                     }
                                                     catch(Exception e){
                                                         System.debug('error : '+ e.getMessage());
                                                     }
                                                 }
                                             }
    
    //Delete all records of APlus records releted to CaseManagement
    public static void deleteAllAplusRecoreds(List<DIR_Case__c> deleteAllAplusRecoreds){
        Set<Id> cmIdsList = new Set<Id>();//caseManagementIds Set
        Map<String,List<Map<String,String>>> finalMapData = new Map<String,List<Map<String,String>>>();
        List<Map<String,String>> cmNameMapList = new List<Map<String,String>>();
        
        if(deleteAllAplusRecoreds.size()>0){
            List<Id> attachPlusIdsList = new List<Id>(); //aPlusIds to Delete 
            for(DIR_Case__c cmObj : deleteAllAplusRecoreds){
                Map<String,String> cmNameMap = new Map<String,String>();
                cmIdsList.add(cmObj.Id);
                cmNameMap.put('folderName',cmObj.Name);
                cmNameMapList.add(cmNameMap);
            }
            finalMapData.put('folder',cmNameMapList );
            
            if(cmIdsList.size() > 0){
                List<Attachments_New__c> aplusList = [SELECT Id,Related_Id__c  FROM Attachments_New__c 
                                                      WHERE Related_Id__c IN : cmIdsList];
                if(aplusList.size() > 0 && !Test.isRunningTest()){
                    //Delete on SharePoint File
                    OWCSharepointAPIService.deleteFolderOnSharepoint(JSON.serialize(finalMapData));
                }
                for(Attachments_New__c aPlusObj : aplusList){
                    attachPlusIdsList.add(aPlusObj.Id);
                }
                //Delete all the aPlusRecords Releted to that CaseRecords
                Database.Delete(attachPlusIdsList);
            }   
        }
    }
    
    public static void updateAccountPriorOffender(List<DIR_Case__c> newList){
        System.debug('*****newList[0].Low_Wage_Occupation__c:' + newList[0].Low_Wage_Occupation__c);
        if(newList[0].Low_Wage_Occupation__c == 'Port'){
            
            List<Account> acctListToUpdate = new List<Account>();
            Account newAccount = new Account();
            
			// SCR-315, Touk Ken, BOFE rarely investigates Port cases so users can edit the Prior Offender field manually.
/*            List<Liability__c> liabilityList = [SELECT Id, (SELECT Id, Entity__r.Id FROM Liable_Parties__r WHERE RecordType.Name = 'BOFE') FROM Liability__c WHERE Case_Management__c IN : newList AND Citation_Number__c != ''];
            //System.debug('*****liabilityList:' + liabilityList);
            
            for(Liability__c liab : liabilityList){
                List<Liable_Party__c> liablPartyList = liab.Liable_Parties__r;
                for(Liable_Party__c eachLiablParty:liablPartyList){
                    newAccount = eachLiablParty.Entity__r;
                    newAccount.X2810_4_Prior_Offender__c = '<span style="color: red;">Prior Offender</span>';
                    acctListToUpdate.add(newAccount);
                    //System.debug('*****newAccount:' + newAccount);
                }
            }		
*/
            // SCR-315, Touk Ken
            List<ODAS__c> odasList = [SELECT Id, ODA_Amount__c, (SELECT Id, Entity__r.Id FROM Liable_Parties__r WHERE RecordType.Name = 'WCA') FROM ODAS__c WHERE Case_Management__r.Id IN : newList AND ODA_Amount__c > 0];
            //System.debug('*****odas:' + odasList);
            
            if(odasList.size() > 0){
                for(ODAS__c eachODAS : odasList){
                    List<Liable_Party__c> liablePartyList = eachODAS.Liable_Parties__r;
                    for(Liable_Party__c eachLiableParty:liablePartyList){
                        newAccount = eachLiableParty.Entity__r;
                        newAccount.X2810_4_Prior_Offender__c = '<span style="color: red;">Prior Offender</span>';
                        
                        acctListToUpdate.add(newAccount);
                        System.debug('*****newAccount2:' + newAccount);
                    }
                }
            }
            MAP<Id, Account> acctMap = new MAP<Id, Account>();
            // convert to map to remove duplicates
            acctMap.putAll(acctListToUpdate);
            
            if(acctMap.size() > 0) {
                update acctMap.values();
            }
        }
    }
}