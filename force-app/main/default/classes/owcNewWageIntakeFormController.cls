public with sharing class owcNewWageIntakeFormController {


    public static String wca_Case_Role_RecordType_Id = OWCConstants.WCA_CASE_ROLE_RECORD_TYPE_ID;
    public static String wca_Case_RecordType_Id = OWCConstants.WCA_CASE_RECORD_TYPE_ID;
    public static String personAccounRTid =  OWCConstants.PERSON_ACCOUNT_RECORD_TYPE_ID;
    public static String zipCode{get;set;}
    public static String prefLanguage{get;set;}



    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject) {
        String myQuery = null;
        if(searchTerm == null || searchTerm == ''){
            myQuery = 'Select Id, Name,FirstName,LastName,PersonBirthdate,PersonMobilePhone ,'
            +'Primary_Street_Placeholder__c,PersonHomePhone,PersonEmail, shippingStreet, shippingCity,'
            +' shippingState, shippingPostalCode from '+myObject+' Where RecordTypeId =: personAccounRTid AND IsCustomerPortal = false AND LastViewedDate != NULL ORDER BY LastViewedDate  DESC LIMIT 10 ';
        }
        else {
            myQuery = 'Select Id, Name,FirstName, LastName, MiddleName,PersonBirthdate,PersonMobilePhone ,'
                +'Primary_Street_Placeholder__c,PersonHomePhone,PersonEmail, shippingStreet, shippingCity,'
                +' shippingState, shippingPostalCode from '+myObject+' Where( Name Like  \'%' + searchTerm
                + '%\' OR FirstName Like  \'%' + searchTerm + '%\'  OR  LastName Like  \'%' + searchTerm
                //+ '%\' OR PersonBirthdate =:  \'' + searchTerm + '\'
                +'%\' OR  ShippingStreet Like  \'%' + searchTerm
                + '%\' OR ShippingCity Like  \'%' + searchTerm + '%\'  OR  ShippingPostalCode Like  \'%' + searchTerm
                + '%\'  OR  PersonMobilePhone Like  \'%' + searchTerm + '%\' ) AND IsCustomerPortal = false AND  RecordTypeId =: personAccounRTid LIMIT 200';
        }
        system.debug(':myQuery'+myQuery);
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }

    @AuraEnabled(cacheable=true)
    public static Account getRelatedAccount(String recordId){
        Account acc = [SELECT Id, Name,FirstName, LastName, MiddleName,PersonBirthdate,PersonMobilePhone,Primary_Street_Placeholder__c,PersonHomePhone,PersonEmail, shippingStreet, shippingCity, shippingState, shippingPostalCode FROM Account where id=: recordId];
        return acc;
    }

    @AuraEnabled(cacheable=true)
    public static Account employerData(String employerId){
        Account acc = [SELECT Id, Name, FirstName, LastName, MiddleName, NAICS_Code__c, NAICS_Code__r.Name, NAICS_Code_Title__c FROM Account where id=: employerId];
        return acc;
    }


    @AuraEnabled(cacheable=true)
    public static List<inTakeOriginPickerWrapper>  intakeOrigin(){
        try {
            List<inTakeOriginPickerWrapper> inTakeOriginPickerWrapperList = new List<inTakeOriginPickerWrapper>();
            List<owcIntakeOrigin__mdt> owcIntakeOriginList =  [SELECT Label, Value__c FROM owcIntakeOrigin__mdt ORDER BY Order__c ASC];
            for(owcIntakeOrigin__mdt owcIntakeOriginObj : owcIntakeOriginList){
                inTakeOriginPickerWrapper industryPickerObj = new inTakeOriginPickerWrapper();
                industryPickerObj.label = owcIntakeOriginObj.label;
                industryPickerObj.value = owcIntakeOriginObj.Value__c;
                inTakeOriginPickerWrapperList.add(industryPickerObj);
            }
            return inTakeOriginPickerWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class inTakeOriginPickerWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public string value{get;set;}
    }

    @AuraEnabled
    public static String mainMethod(String inTakeData,String claimentId,String addDocData){
        System.debug('New Case Managment Data::: ' + inTakeData);
        DIR_Case__c dir = newCaseManagement(claimentId, inTakeData,addDocData);
        System.debug('Dir Data ' + dir);
        //populate the Claimant info when existing selected
        if(String.ISNotBlank(claimentId)){
            //populate Claimant data on Case
            Account Claimant = [SELECT firstName,middleName,LastName FROM Account WHERE Id =: claimentId];
            //populate Employee data on Case;
            dir.Claimant__c = claimentId;
            dir.Employee_First_Name__c = Claimant.firstName;
            dir.Employee_Last_Name__c = Claimant.LastName;
        }

		if(String.ISBlank(claimentId)){
            //create a new instance a DIR Case record to prevent override of fields set by another process after Case creation.
            //DIR_Case__c caseToUpdate = new DIR_Case__c (Id = dir.Id);
            Account acc = claimantAccount(inTakeData);
            System.debug('New Account:: ' + acc);
            //insert acc;
            //insert mapAccountsToInsert.values();
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            List<Database.SaveResult> sr = Database.insert(new List<Account>{acc}, dml);
            claimentId = acc.Id;

            //populate Employee data on Case;
            dir.Claimant__c = acc.Id;
            dir.Employee_First_Name__c = acc.firstName;
            dir.Employee_Last_Name__c = acc.LastName;
            //dir.Online_Claim_Account__c = acc.Id;
            /*
            if(addDocData != null ){
                createDocuments(caseToUpdate.Id, addDocData);
            }
            update caseToUpdate;	*/
        }
        insert dir;
         if(addDocData != null ){
             System.debug('addDocData ::: '+addDocData);
            createDocuments(dir.Id, addDocData);
        }
        createCaseRole(dir,claimentId,'Claimant',wca_Case_Role_RecordType_Id);

        //send confirmation to claimant for internal
        List<DIR_Case__c> cseList = new List<DIR_Case__c>{dir};
        OCEmailServiceUtility.sendConfirmationEmailtoClaimant(cseList);

        return 'Success';
    }



   //New Case Management
   private static DIR_Case__c newCaseManagement(String claimentId, String newRecord,String addDocData){
    caseManagementWrapper obj = (caseManagementWrapper) System.JSON.deserialize(newRecord, caseManagementWrapper.class);
    //addDocList addDoc = (addDocList) System.JSON.deserialize(addDocData, addDocList.class);
    system.debug('caseManagementWrapper: '+obj);
    //system.debug('addtionalClaimDocs: '+addDoc);

        if(obj.prefferedLanguageSelection == 'Other'){
            prefLanguage = obj.otherPrefferedLanguage;
        }else{
            prefLanguage = obj.prefferedLanguageSelection;
        }
		/*
       if(obj.workLocationZipCode !=null){
            zipCode = obj.workLocationZipCode;
        }else{
            zipCode = obj.yourselfZipCode;
        } */
       String defendantZipCode ;
       Account employer;
       if(String.isNotBlank(obj.recordId)){
           employer = [SELECT Id,  shippingPostalCode, PersonEmail, Email__c FROM Account where id=: obj.recordId];
           defendantZipCode = employer.shippingPostalCode;
       }

       //Assign office based on the priority order (Fix for )
       zipCode = OWCServiceUtility.validateOfficeAssignment(obj.yourselfZipCode, defendantZipCode, obj.workLocationZipCode);
       /*if(String.isNotBlank(obj.workLocationZipCode)){
            if(defendantZipCode != null && defendantZipCode == obj.yourselfZipCode){
                zipCode = obj.yourselfZipCode;
            } else{
                if(OWCServiceUtility.getOfficeLocationByZIPCode(obj.workLocationZipCode)){
                    zipCode = obj.workLocationZipCode;
                } else{
                    zipCode = obj.yourselfZipCode;
                }
            }
        } else{
            zipCode = obj.yourselfZipCode;
        }*/

       //reset the default value to null
       Dir_Case__c cse = new Dir_Case__c();
       Map<String, Schema.SobjectField> caseFields = Schema.SObjectType.Dir_Case__c.fields.getMap();
       Schema.DescribeSObjectResult caseSchema = Dir_Case__c.sObjectType.getDescribe();
       Map<String, Schema.SObjectField> caseMap = caseSchema.fields.getmap();

       for(String key : caseFields.keySet()) {
           Schema.DescribeFieldResult fieldDescribe  = caseMap.get(key).getDescribe();
           System.debug('Key123 '+ key + ' ' + fieldDescribe.getDefaultValue());
           if(fieldDescribe.isUpdateable() && fieldDescribe.isNillable() && fieldDescribe.getDefaultValue() != null){
               System.debug('Key '+ key + ' ' + fieldDescribe.getDefaultValue());
               cse.put(key, null);
           }
       }
       cse.Status__c = 'New';
       cse.Were_you_paid_more_than_one_hourly_rate__c = null;
       cse.Were_you_paid_by_PIECE_RATE__c = null;
       cse.Were_you_paid_by_COMMISION__c = null;
       cse.Date_of_Docket__c = System.today(); //Date.valueOf(obj.dockingDate),
       cse.Docketing_Staff__c = obj.name;
       cse.Date_Case_Received__c = Date.valueOf(obj.caseRecDate);
       cse.Intake_Origin__c = obj.intakeOrigin;
       cse.Employer__c = obj.recordId;
       cse.Office_Location_Zip_Code__c = zipCode;
       cse.Claimant_Name_in_Text__c = (obj.yourselfFirstName == null ? '' : obj.yourselfFirstName) + ' ' + (obj.yourselfLastName == null ? '' : obj.yourselfLastName) + (obj.yourselfMiddleName == null ? '' : obj.yourselfMiddleName);
       cse.Related_Party_Employee_Email__c = obj.yourselfEmail;
       cse.Related_Party_Employer_Name__c = obj.employerName;
       cse.recordTypeId = wca_Case_RecordType_Id;
       cse.Interpreter_Needed__c  = obj.needLanguageInterpreter;
       cse.Language__c = prefLanguage;
       cse.Union_contract_covering_your_employment__c = null;
       //populate office on case record
       cse.Office__c = getOffice(zipCode);
       //Send confirm email for Claimant on Internal Intake
       cse.Referred_From__c = 'Claimant';
    return cse;
    }

    public static Id getOffice(String zipCode){
        if(String.isBlank(zipCode)){
            zipCode = '00000';
        }

        List<String> zipCodeNameList = new List<String>();
        for(Zip_Code__c zc : [SELECT Id, Name FROM Zip_Code__c]){
            zipCodeNameList.add(zc.Name);
        }
        
        if(!zipCodeNameList.contains(zipCode)){
            zipCode = '00000'; //"Out of state" zip code
        }

        List<Office_Zip_Code_Map__c> ozcmList = [SELECT Id, Office__c, Office__r.Name, Office__r.RecordType.Name, Zip_Code__r.Name
                                                    FROM Office_Zip_Code_Map__c
                                                    WHERE Zip_Code__r.Name =: zipCode
                                                        AND Office__r.RecordType.Name =: Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getname()
                                                    LIMIT 1];
        
        return ozcmList[0].Office__c;
    }

    //New Claimant Account
    public static Account claimantAccount(String newRecord){
        caseManagementWrapper obj = (caseManagementWrapper) System.JSON.deserialize(newRecord, caseManagementWrapper.class);
        Account acc = new Account(
            FirstName = obj.yourselfFirstName,
            LastName = obj.yourselfLastName,
            MiddleName = obj.yourselfMiddleName,
            PersonBirthdate = Date.valueOf(obj.yourselfBirthDate),
            PersonEmail = obj.yourselfEmail,
            ShippingStreet = obj.yourselfStreetAddress,
            ShippingCity = obj.yourselfCity,
            ShippingState = obj.yourselfState,
            ShippingPostalCode = obj.yourselfZipCode,
            PersonMobilePhone  = obj.yourselfCellPhone,
            PersonHomePhone = obj.yourselfHomePhone
        );
        // As per OWC_439, The Phone field should auto-populate with either the Mobile Phone or Home Phone values,
        //  if both values are entered, Mobile Phone should populate into the Phone field.
        if(String.isNotBlank(acc.PersonMobilePhone)){
            acc.Phone = acc.PersonMobilePhone;
        }else if(String.isNotBlank(acc.PersonHomePhone)){
            acc.Phone = acc.PersonHomePhone;
        }

        return acc;
    }

    //New Case Role
    public static void createCaseRole(DIR_Case__c dirCase,String accId,String role,String caseRolerecTypeId){
        Case_Role__c caseRole = new Case_Role__c();
        caseRole.RecordTypeId = caseRolerecTypeId;
        caseRole.Role__c = role;
        caseRole.Case__c = dirCase.Id;
        caseRole.Entity__c = accId;
        caseRole.Interpreter_Language__c = dirCase.Language__c;
        if(String.isNotBlank(dirCase.Online_Claim_Account__c)){
            caseRole.Community_User_Account__c = dirCase.Online_Claim_Account__c;
        }
        insert caseRole;
    }

    public class caseManagementWrapper{
        public String yourselfFirstName;
        public String yourselfMiddleName;	//Pooja
        public String yourselfLastName;	//Rani
        public String yourselfHomePhone;	//01234567890
        public String yourselfCellPhone;
        public String yourselfStreetAddress;	//9811884713
        public String countryCodeyourselfCellPhone;	//+1
        public String countryCodeyourselfHomePhone;	//+1
        public String yourselfBirthDate;	//2021-06-27
        public String yourselfEmail;	//prani@cloudsciencelabs.com
        public String yourselfState;	//CA
        public boolean isPrefferedLanguage;
        public String yourselfCity;
        public String yourselfZipCode;
        public boolean isOtherPrefferedLanguage;
        public String dockingDate;
        public String name;
        public String caseRecDate;
        public String intakeOrigin;
        public String recordId;
        public String workLocationZipCode;
        public String employerName;
        public string prefferedLanguageSelection;
        public string needLanguageInterpreter;
        public String otherPrefferedLanguage;
    }

    public class addDocList{
        public List<addtionalClaimDocs> addtionalClaimDocs;
    }
    public class addtionalClaimDocs {
		public String name;	//sample.pdf
		public String documentId;	//06935000001ZOF5AAO
		public String contentVersionId;	//06835000001ZKqTAAW
	}

    @AuraEnabled(cacheable=true)
    public static List<Employee__c> empDetails(){
        List<Employee__c> emp = [SELECT Name, Id, First_Name__c, Last_Name__c FROM Employee__c];
        return emp;
    }

    public static void createDocuments(String dirId, String files){
        List<docWrapper> uploadedFiles = (List<docWrapper>) JSON.deserialize(files, List<docWrapper>.class);
       	System.debug('addDocData ::: '+uploadedFiles);
        List<ContentDocumentLink> conList = new List<ContentDocumentLink>();
        List<String> docsId = new List<String>();
         for(docWrapper fileObj : uploadedFiles){
             //System.debug('fileObj ::: '+fileObj.get('documentId'));
             ContentDocumentLink conObj = new ContentDocumentLink();
             conObj.LinkedEntityId = dirId;
             conObj.ContentDocumentId = fileObj.documentId;
             conObj.ShareType = 'V';
             conList.add(conObj);
             docsId.add(fileObj.documentId);
         }
        System.debug('conList ::: '+conList);
        //Database.insert(conList, false);
        createDocumentLinks(docsId, Json.serialize(conList));
     }

    //@future
    private static void createDocumentLinks(List<String> ContentDocumentIdList, String documentLinksJson){
        List<ContentVersion> ContentVersionToUpdate = new List<ContentVersion>();
        for(ContentVersion contentVersion_2 : [SELECT Id, Title, ContentDocumentId
                                               FROM ContentVersion WHERE ContentDocumentId IN :ContentDocumentIdList])
        {
            contentVersion_2.title = contentVersion_2.title + '- Intake Claim';
            Integer extraLength = contentVersion_2.title.length() - 80 ;
            if(extraLength > 0){
               contentVersion_2.title = contentVersion_2.title.substring(extraLength);
            }
            ContentVersionToUpdate.add(contentVersion_2);
        }
        //update ContentVersionToUpdate;
        database.update(ContentVersionToUpdate,false);
        //create Document Links

        List<ContentDocumentLink> documentLinks = (List<ContentDocumentLink>)JSON.deserialize(documentLinksJson, List<ContentDocumentLink>.class);
        if(documentLinks != null){
           // insert documentLinks;
           database.insert(documentLinks,false);
        }
    }

    public class docListWrapper{
        public List<docWrapper> docWrapper;
    }

    public class docWrapper {
		public String name;	//menuTile.png
		public String documentId;	//06935000001ZOSPAA4
		public String contentVersionId;	//06835000001ZL3nAAG
	}
	public static docWrapper parse(String json){
		return (docWrapper) System.JSON.deserialize(json, docWrapper.class);
	}
}