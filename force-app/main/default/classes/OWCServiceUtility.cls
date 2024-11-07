/*Name: OWCServiceUtility
* Description: Used to keep the comman utility services for the project and ensure the reusability of the code as possible
*/
public with sharing class OWCServiceUtility {
    public String StackTrace {get; set;}
    public String ClassName {get; set;}
    public static boolean isDeletedErrorClaim = false;
    public static Map<String, Object> getdeserializeUntypedMap(String jsonInput){
        return (Map<String, object>) json.deserializeUntyped (jsonInput);
    }

    //Get the existing account
    public static Account getDuplicateAccount(Account acc){
        List<Account> existingAccounts;
        if(acc.RecordTypeId == OWCConstants.PERSON_ACCOUNT_RECORD_TYPE_ID){
            existingAccounts = [SELECT Id, Name FROM Account
                                WHERE PersonEmail=: acc.PersonEmail AND firstName=: acc.firstName AND lastName=: acc.lastName];
        }else{
            existingAccounts = [SELECT Id, Name FROM Account
                                WHERE Email__c=: acc.Email__c AND Name=: acc.Name];
        }
        if(existingAccounts != null && existingAccounts.size() >0){
            return existingAccounts[0];
        }
        return null;
    }

    //SCR-853
    public static String validateOfficeAssignment(String claimantZipCode, String defendantZipCode, String otherLocationZipCode){
        String claimantOfficeName = getOfficeNameByZipCode(claimantZipCode);
        String defendantOfficeName = getOfficeNameByZipCode(defendantZipCode);
        String otherLocationOfficeName = getOfficeNameByZipCode(otherLocationZipCode);

        // 1.	Assign to office where at least two of the three zip codes are in the same California WCA Office (not the Out of State Office);
        if(String.isNotBlank(claimantOfficeName) && String.isNotBlank(defendantOfficeName) && claimantOfficeName == defendantOfficeName && !claimantOfficeName.contains('OUT OF STATE')){
            return claimantZipCode;
        }else if(String.isNotBlank(claimantOfficeName) && String.isNotBlank(otherLocationOfficeName) && claimantOfficeName == otherLocationOfficeName && !claimantOfficeName.contains('OUT OF STATE')){
            return claimantZipCode;
        }else if(String.isNotBlank(defendantOfficeName) && String.isNotBlank(otherLocationOfficeName) && defendantOfficeName == otherLocationOfficeName && !defendantOfficeName.contains('OUT OF STATE')){
            return defendantZipCode;
        // 2.   If there is not a 2 out of 3 in-state office match, then
		//   a.   1st priority: assign to in-state office handling claimant’s zip code;
        }else if(String.isNotBlank(claimantOfficeName) && !claimantOfficeName.contains('OUT OF STATE')){
            return claimantZipCode;
        //   b.   2nd priority: assign to in-state office handling zip code where work was performed;
        }else if(String.isNotBlank(otherLocationOfficeName) && !otherLocationOfficeName.contains('OUT OF STATE')){
            return otherLocationZipCode;
        // 3.   If the only CA zip code is the address of the employer, then assign to out of state
        // 4.	where there is no California zip code for claimant, employer, or where the work was performed then assign to out of state
        // 5.   No zip code code mapping should be treated as an out of state
        }else{
            return '00000';
        }
        // We need to make sure the caller handles '00000' correctly.
    }

    public static String getOfficeNameByZipCode(String zipCode){
        if(String.isBlank(zipCode)){
            return null;
        }else{
            List<String> zipCodeNameList = new List<String>();
            for(Zip_Code__c zc : [SELECT Id, Name FROM Zip_Code__c]){
                zipCodeNameList.add(zc.Name);
            }
            
            if(!zipCodeNameList.contains(zipCode)){
                zipCode = '00000'; //"Out of state" zip code
            }
            
            List<Office_Zip_Code_Map__c> ozcmList = [SELECT Id, Office__r.Name, Office__r.RecordType.Name, Zip_Code__r.Name
                                                        FROM Office_Zip_Code_Map__c
                                                        WHERE Zip_Code__r.Name =: zipCode
                                                            AND Office__r.RecordType.Name =: Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getname()
                                                        LIMIT 1];
            
            if(!ozcmList.isEmpty()){
                return ozcmList[0].Office__r.Name;
            }else{
                return null;
            }
        }
        // Need to verify caller handles null return and Office named 'WCA - OUT OF STATE' correctly
    }


    /* This method with this signature doesn't seem to be used anywhere, so commenting out for better test coverage
    public static Boolean getOfficeLocationByZIPCode(String zipCode){
        String recordTypeName_Office = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('RCI').getname();
        String recordTypeName_WCA_Office = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getname();

        Map<String,Id> zipCodes = new Map<String,Id>();
        Id officePrimaryId ;
        String countyPrimary;

        for(Zip_Code__c zcode: [Select Id, Name from Zip_Code__c WHERE Name =: zipCode]){
            zipCodes.put(zcode.Name,zcode.Id);
        }

        for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c
                                           from Office_Zip_Code_Map__c
                                           where Zip_Code__c =: zipCodes.get(zipCode)])
        {

            if(zcode.Office__r.RecordType.Name.equals(recordTypeName_WCA_Office)){
                officePrimaryId = zcode.Office__c;
                countyPrimary = zcode.County__c;
            }

        }

        //B-000977 Fix
        if(string.isBlank(officePrimaryId))
        {
            return false;

        } else {
            return true;
        }
    } */

    /* This method with this signature doesn't seem to be used anywhere, so commenting out for better test coverage
    public static Map<String, String> getOfficeLocationByZIPCode(list<String> zipCodes){

        String recordTypeName_WCA_Office = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getname();
        Map<String, String> officeZipCodes = new Map<String,String>();

        for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c, Office__r.Name, Office__r.RecordType.Name, Zip_Code__c, Zip_Code__r.Name, County__c
                                           from Office_Zip_Code_Map__c
                                           where Zip_Code__r.Name =: zipCodes])
        {

            if(zcode.Office__r.RecordType.Name.equals(recordTypeName_WCA_Office))
            {

                officeZipCodes.put(zcode.Zip_Code__r.Name, zcode.office__r.Name);
            }

        }


        return officeZipCodes;

    } */


    //Exception handler
    public void log(Exception ex)
    {
        try
        {
            System.debug('ex:::::'+ex);
            writeExToObject(ex);
            System.debug('This is a debug message');
        }
        catch(Exception e)
        {
            System.debug('log catch Exception ex:::::'+e);
            new OWCServiceUtility().log(e);
        }
    }

    //Writting Exception data to excpetion object
    public void writeExToObject(Exception ex)
    {
       // DML statement
        stackTrace = ex.getStackTraceString()
                .substringBefore('\n');

            className = stackTrace.substringAfter('.')
                .substringBefore('.');

            System.debug('writeExToObject ex:::::'+ex);
            System.debug('writeExToObject stackTrace:::::'+stackTrace);
            System.debug('writeExToObject className:::::'+className);
            System.debug('writeExToObject Error_Stack_Trace__c:::::'+ex.getStackTraceString());
            System.debug('writeExToObject getLineNumber:::::'+ex.getLineNumber());
            System.debug('writeExToObject getMessage:::::'+ex.getMessage());

            Online_Claim_Error_Log__c logger = new Online_Claim_Error_Log__c();
            logger.Error_Stack_Trace__c = ex.getStackTraceString();
            logger.Class_Name__c = className;
            logger.Line_number__c = ex.getLineNumber();
        	logger.Error_Message__c  = ex.getMessage();
            system.debug('logger::::'+logger);

        	Database.SaveResult srList = Database.insert(logger, false);

        // Iterate through each returned result
            if (srList.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + srList.getId());
            }
            else {
                // Operation failed, so get all errors
                for(Database.Error err : srList.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }

    }

    // To generate JSON response
    public static string generateJSON(String Status,String Content,String error){
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeStringField('Status',Status);
        jsGen.writeStringField('ContentID', Content);
        jsGen.writeStringField('Error', error);
        jsGen.writeEndObject();
        return jsGen.getAsString();
    }

    /*****************************
* @description: Create wrapper object to store the Attachment + Data records.
* @Class Name: AttachmentPlusWrapperObj
* ***************************/
    public class attachmentPlusWrapperObj{
        @AuraEnabled
        public String fieldAPIName{get;set;}
        @AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String fileType{get;set;}
        @AuraEnabled
        public String value{get;set;}

        public attachmentPlusWrapperObj(String fieldAPIName, String fieldName, String value, String fileType){
            this.fieldAPIName = fieldAPIName;
            this.fieldName = fieldName;
            this.value = value;
            this.fileType = fileType;
        }
    }
    public static DIR_Case__c populateOfficeOnCM(DIR_Case__c cseRecord){
        Map<Id,Related_Party__c> newRelatedParties ;
        String recordTypeName_Office = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('RCI').getname();
        String recordTypeName_WCA_Office = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getname();
        Id recordTypeId_RC = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Id recordTypeId_WCA = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        Id recordTypeId_RCI_Case = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Id recordTypeId_WCA_Case = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        Id recordTypeId_Pre_Docketing_Case_Case = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('Pre Docketing Case').getRecordTypeId();

        Map<String,Id> zipCodes = new Map<String,Id>();
        Map<String,DIR_Case__c> casesToUpdate = new Map<String,DIR_Case__c>();
        Id officePrimaryId;
        String countyPrimary;
        Map<Id,Related_Party__c> filteredRelatedParties = new Map<Id,Related_Party__c>();
        Map<String,Related_Party__c> mapFilteredRelatedParties = new Map<String,Related_Party__c>();
        for(Zip_Code__c zcode: [Select Id, Name from Zip_Code__c]){
            zipCodes.put(zcode.Name,zcode.Id);
        }
        for(Related_Party__c objnewRP : [SELECT Id,Case_Management__c,Case_Management__r.recordTypeId,Case_Management__r.Advocate__c,Case_Management__r.Assigned_Screener__c,
                                         Case_Management__r.Assigned_Screener__r.Office__c,Case_Management__r.Employer__c,Case_Management__r.Claimant__c,
                                         Case_Management__r.Work_Location__c,Still_in_business__c,Case_Management__r.Office__c, Zip_Code__c,Role__c
                                         FROM Related_Party__c
                                         WHERE (Case_Management__c =: cseRecord.Id AND Role__c = 'Defendant')]) {
                                             if(objnewRP.Case_Management__c != null && String.isNotBlank(objnewRP.Role__c) && (objnewRP.Role__c == 'Defendant')){
                                                 mapFilteredRelatedParties.put(objnewRP.Id, objnewRP);
                                                 system.debug('objRP.Zip_Code__c: '+objnewRP.Zip_Code__c);
                                             }
                                         }
        system.debug('casesToUpdate: '+mapFilteredRelatedParties);

        for(Related_Party__c objRP : [SELECT Id,Case_Management__c,Case_Management__r.recordTypeId,Case_Management__r.Advocate__c,
                                      Case_Management__r.Assigned_Screener__c,Case_Management__r.Assigned_Screener__r.Office__c,
                                      Case_Management__r.Intake_Origin__c,Case_Management__r.Employer__c,Case_Management__r.Claimant__c,
                                      Case_Management__r.Work_Location__c,Still_in_business__c,Case_Management__r.Office__c, Zip_Code__c,
                                      Role__c, Case_Management__r.Office_Location_Zip_Code__c
                                      FROM Related_Party__c
                                      WHERE (Case_Management__r.Employer__c = Null AND Role__c = 'Defendant')
                                      AND Id IN: mapFilteredRelatedParties.keyset()])
        {
            if(objRP.Role__c == 'Defendant'){
                String zipCode = objRP.Case_Management__r.Office_Location_Zip_Code__c;
                if(zipCode != null){
                    if(zipCode.length() > 5){
                        zipCode = zipCode.subString(0, 5);
                    }
                }
                for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c
                                                   from Office_Zip_Code_Map__c
                                                   where Zip_Code__c =: zipCodes.get(zipCode)])
                {

                    if(zcode.Office__r.RecordType.Name.equals(recordTypeName_WCA_Office)){
                        officePrimaryId = zcode.Office__c;
                        countyPrimary = zcode.County__c;
                    }

                }

                //B-000977 Fix
                if(string.isBlank(officePrimaryId))
                {
                    for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c from Office_Zip_Code_Map__c where Office__r.Name =:'WCA - OUT OF STATE']){

                        officePrimaryId = zcode.Office__c ;
                        countyPrimary = 'Outside CA';
                    }
                }

                //B-27763 Fix
                if(objRP.Case_Management__r.Office__c == Null && mapFilteredRelatedParties.get(objRP.id).Role__c == 'Defendant'){
                    if(objRP.Case_Management__r.Office__c == Null){
                        //casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c,County__c = countyPrimary, Office__c = officePrimaryId));
                        cseRecord.County__c = countyPrimary;
                        cseRecord.Office__c = officePrimaryId;
                        return cseRecord;
                    }
                }
            }
        }
        return cseRecord;
    }
}