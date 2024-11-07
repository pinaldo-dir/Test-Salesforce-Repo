/********************************************************************************************************
Name:  RegistrationResultsController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  11/01/2017

VF Page: RegistrationSearchResults.page
Test class: RegistrationResultsControllerTest.cls

Behavior:
Filter Registration search by attributes so that it can narrow down to particular Registrations user is looking for. 

Changes
Touk Ken 06/27/2018 - add car wash and janitorial as parameters      
********************************************************************************************************/

global class RegistrationEWPResultsController {

    public String searchString {get; set;}
    public License_Registration__c dummyLicenseRegistration {get; set;}
    public RegistrationEWPSearchController.searchClass searchClassObj {get; set;}
    public String selectedRecordType {get; set;}

    // class constructor, executes first, as soon as the class is invoked
    global RegistrationEWPResultsController() {      

        searchClassObj = new RegistrationEWPSearchController.searchClass();
        searchClassObj.selectedRecordType = ApexPages.currentPage().getParameters().get('selectedRecordType');
        searchClassObj.registrationNumberStr = ApexPages.currentPage().getParameters().get('registrationNumberStr');
        searchClassObj.locationZipStr  = ApexPages.currentPage().getParameters().get('locationZipStr'); 
    }
    
    // Remote action called from RegistrationEWPResults.page via javascript function getAllRegistrations()
    @RemoteAction
    global static List<wrapRegistrationLicenses> getAllRegistrations(String registrationNumberStr, String selectedRecordType, String locationZipStr) {
        //List<Registration_Account__c> allReg = new List<Registration_Account__c>();
        //List<wrapRegistrationAccounts> wrapRALists = new List<wrapRegistrationAccounts>();
        List<License_Registration__c> allReg = new List<License_Registration__c>();
        List<wrapRegistrationLicenses> wrapLRLists = new List<wrapRegistrationLicenses>();
        if(String.isEmpty(registrationNumberStr) && String.isEmpty(selectedRecordType) && String.isEmpty(locationZipStr) ) {
            
        } else {
            Date todaydate = Date.Today();
            String query = 'SELECT'
                + ' Id'
                + ' ,  First_Name__c'
                + ' ,  Middle_Name__c'
                + ' ,  Last_Name__c'
                + ' ,  Stage_Name__c'
                + ' ,  RecordType.Name'
                + ' ,  License_Registration_Number__c'
                + ' ,  Effective_Date__c'
                + ' ,  Expiration_Date__c'
                + ' ,  Status__c'
                + ' FROM License_Registration__c'
                + ' WHERE ( (Status__c = \'Approved\')'
                + '  OR ( Status__c = \'Closed - Renewed\')' 
                + '  OR ( Status__c = \'Renewed\' ) )'
                + ' AND License_Registration_Number__c like ' + '\'%' + registrationNumberStr + '\''
                + ' AND 	Residential_Postal_Code__c = ' + '\'' + locationZipStr + '\''
                + ' AND Expiration_Date__c >=: todaydate ';

            //System.debug('*********selectedRecordType:' + selectedRecordType);
            if(!String.isEmpty(selectedRecordType)) {
                //System.debug('*********selectedRecordType:' + selectedRecordType);
                query += ' AND License_Registration_Type__c = \'' + selectedRecordType + '\' ';
            }
            
            query += ' ORDER BY Name DESC';
            System.debug('Query=======>'+query);
                allReg = Database.query(query);
        }

        String RegistrationNum = '';
        String Status = '';
        String MinorNm = '';
        String StageNm = '';
        Date EffectiveDate = NULL;
        Date ExpirationDate = NULL;

        for(License_Registration__c eachRegistration: allReg){
            RegistrationNum = eachRegistration.License_Registration_Number__c;
            Status = eachRegistration.Status__c;
            EffectiveDate  = eachRegistration.Effective_Date__c;
            ExpirationDate = eachRegistration.Expiration_Date__c;

            //if(eachRegistration.RecordType.Name == 'Individual Permit'){
                eachRegistration.First_Name__c = eachRegistration.First_Name__c == NULL ? '' : eachRegistration.First_Name__c;
                eachRegistration.Middle_Name__c = eachRegistration.Middle_Name__c == NULL ? '' : eachRegistration.Middle_Name__c;
                eachRegistration.Last_Name__c = eachRegistration.Last_Name__c == NULL ? '' : eachRegistration.Last_Name__c;
                StageNm = eachRegistration.Stage_Name__c == NULL ? '' : eachRegistration.Stage_Name__c;
                MinorNm = eachRegistration.First_Name__c + ' ' + eachRegistration.Middle_Name__c + ' ' + eachRegistration.Last_Name__c;
            //}
            wrapLRLists.add(new wrapRegistrationLicenses(RegistrationNum, Status, MinorNm, StageNm, EffectiveDate, ExpirationDate));
        }
        return wrapLRLists;
    }
    
    // action called from "Return to Search" btn (RegistrationEWPResults.page)
    public PageReference BackToSearch() {
        PageReference searchPage = new PageReference('/apex/RegistrationEWPSearch');
        searchPage.setRedirect(true);
        return searchPage;
    }

    global class wrapRegistrationLicenses{
        public String RegistrationNum {get;set;}
        public String Status {get;set;}
        public String MinorName {get;set;}
        public String StageName {get;set;}
        public Date EffectiveDte {get;set;}
        public Date ExpirationDte {get;set;}
        
        public wrapRegistrationLicenses(String sRegistrationNum, String sStatus, String sMinorName, String sStageName, Date sEffectiveDte, Date sExpirationDte){
            RegistrationNum = sRegistrationNum;
            Status = sStatus;
            MinorName = sMinorName;
            StageName = sStageName;
            EffectiveDte = sEffectiveDte;
            ExpirationDte = sExpirationDte;
        }
    }
}