/********************************************************************************************************
Name:  PAGAResultsController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  08/08/2017

VF Page: PAGASearchResults.page
Test class: PAGAResultsControllerTest.cls

Behavior:
Filter cases search by case attributes so that it can narrow down to particular cases user is looking for. 
Case attributes include Date Range of PAGA Notice Filed, employer city, employer zip code, court name, 
court case number, and the type of violation.

********************************************************************************************************/

global class PAGAResultsController {
    
    // dummy DIR Case Record
    public DIR_Case__c dummyCase {get; set;}
    
    public String searchString {get; set;}
    public String employeeCity {get; set;}
    public String employeeZipCode {get; set;}
    public String employerName {get; set;}
    public String employerFilerName {get; set;}
    public String lawFirmPAGACase {get; set;}
    public String attorneyFilerName {get; set;}
    public List <DIR_Case__c> allCases {get; set;}
    public Date startAttachmentDate {get; set;}    
    public Date endAttachmentDate {get; set;}
    public String selectedsubmissiontype {get; set;}
    public Integer totalResults;
    
    
    public String filterField {get; set;}
    // this is used to know which field to show in page - show only the fields that have a value or that were added from "Filters" picklist
    public Map<String, Boolean> filtersMap {get; set;}
    
    // class constructor, executes first, as soon as the class is invoked
    global PAGAResultsController() {
        
        
        Id pagaRTId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        // initialize dummy case record and specify the record type so that the Submission_Detail_Type__c and 
        // Violation_Type__c fields display only the values for that record type
        if(dummyCase == null) {
            dummyCase = new DIR_Case__c();
            dummyCase.recordTypeId = pagaRTId;
        }
        
        if(startAttachmentDate == null)
        {
            startAttachmentDate = null;
        }
        
        if(endAttachmentDate == null)
        {
            endAttachmentDate = null;
        }
        
        selectedsubmissiontype = '';
  
          
        // initialize filtersMap
        
        filtersMap = new Map<String, Boolean>();
        filtersMap.put('Employer__r.Name', false);
        filtersMap.put('Employer_Filer__r.Name', false);
        filtersMap.put('Law_Firm_for_PAGA_Case__c', false);
        filtersMap.put('Attachment_Created_Date', false);
        //filtersMap.put('Date_Case_Received__c', false);
        filtersMap.put('Employer__r.ShippingCity', false);
        filtersMap.put('Employer__r.ShippingPostalCode', false);
        filtersMap.put('PAGA_Court_Case_Number__c', false);
        filtersMap.put('Court_Type__c', false);
        filtersMap.put('Violation_Type__c', false);
        filtersMap.put('LWDA_Number__c', false);
        filtersMap.put('Submission_Detail_Type__c', false);
        filtersMap.put('Filer_Attorney_for_PAGA_Case__r.Name', false);
        // add the values received from url parameter, remove them from the "Filters" and add them on page
        searchString = ApexPages.currentPage().getParameters().get('ss');
        
        dummyCase.LWDA_Number__c = ApexPages.currentPage().getParameters().get('lwn');
        if(!String.isEmpty(dummyCase.LWDA_Number__c)) {
            filtersMap.put('LWDA_Number__c', true);
        }
        employeeCity = ApexPages.currentPage().getParameters().get('ec');
        if(!String.isEmpty(employeeCity)) {
            filtersMap.put('Employer__r.ShippingCity', true);
        }
        employeeZipCode = ApexPages.currentPage().getParameters().get('ezc');
        if(!String.isEmpty(employeeZipCode)) { 
            filtersMap.put('Employer__r.ShippingPostalCode', true);
        }   
        dummyCase.PAGA_Court_Case_Number__c = ApexPages.currentPage().getParameters().get('ccn');
        if(!String.isEmpty(dummyCase.PAGA_Court_Case_Number__c)) { 
            filtersMap.put('PAGA_Court_Case_Number__c', true);
        }    
        dummyCase.Court_Type__c = ApexPages.currentPage().getParameters().get('ct');
        if(!String.isEmpty(dummyCase.Court_Type__c)) { 
            filtersMap.put('Court_Type__c', true);
        }
        dummyCase.Court_Name__c = ApexPages.currentPage().getParameters().get('cn');
        if(!String.isEmpty(dummyCase.Court_Name__c)) {
            filtersMap.put('Court_Name__c', true);
        }  
        dummyCase.Violation_Type__c = ApexPages.currentPage().getParameters().get('vt');
        if(!String.isEmpty(dummyCase.Violation_Type__c )) { 
            filtersMap.put('Violation_Type__c', true);
        }   
        selectedsubmissiontype = ApexPages.currentPage().getParameters().get('st');
        if(!String.isEmpty(selectedsubmissiontype)) {
            
            System.debug('***Selectedsubmissiontype=' + selectedsubmissiontype);
            filtersMap.put('Submission_Detail_Type__c', true);
            
        }
        //Modified to make it work with native salesforce date pickers and the javascript valid date function
        String startDate = ApexPages.currentPage().getParameters().get('sd');
        if(!String.isEmpty(startDate)) {
            List<String> startStringDate = startDate.split('-');
            String sD = startStringDate[0] + '-' + startStringDate[1] + '-' + startStringDate[2];
            startAttachmentDate = Date.valueOf(sD);
            
            filtersMap.put('Attachment_Created_Date', true);
        }
        //Modified to make it work with native salesforce date pickers and the javascript valid date function
        String endDate = ApexPages.currentPage().getParameters().get('ed');
        if(!String.isEmpty(endDate)) {
            List<String> endStringDate = endDate.split('-');
            String eD = endStringDate[0] + '-' + endStringDate[1] + '-' + endStringDate[2];
            endAttachmentDate = Date.valueOf(eD);
            filtersMap.put('Attachment_Created_Date', true);
        }
        
        
    }
    //Added as part of the Paga Search 2 project user story PS2-66.  Outputs the total number of records and passes it to line 330 in the PAGASearchResults.vfp to display the  Total No. of Results Found:.  Took the logic and the getAllCases() static javascript method on line 349 and added it here since having difficulty in passing controller parameters to a static method.  When this application gets refactored or re-architected this method can be removed & integrated to the getAllCases() method.

    public Integer getTotalResults() {
        
        String totalResultsQuery ='SELECT COUNT() FROM DIR_Case__c WHERE RecordType.Name = \'PAGA Case\' AND PAGA_Status__c != \'Pending - Incomplete\'';
        
             if(!String.isEmpty(searchString)) 
         {
                String searchStringTotalResults = '';
             	searchStringTotalResults = string.escapeSingleQuotes(searchString);
                String sn = '%'+searchStringTotalResults.replace('\'','\'')+'%';
                system.debug('searchString ====>' + sn);
                totalResultsQuery += ' AND ((Employer__r.Name LIKE  \'' + sn + '\') OR (Plaintiff_for_PAGA__r.Name LIKE \'' + sn + '\') OR (Plaintiff_for_PAGA_Case_Text__c LIKE \'' + sn + '\') OR (Filer_Attorney_for_PAGA_Case__r.Name LIKE \'' + sn + '\') OR (Law_Firm_for_PAGA_Case__c LIKE \'' + sn + '\') OR (Employer_Filer__r.Name LIKE \'' + sn + '\') OR (Employer_Filer_Firm__c LIKE \'' + sn + '\') OR (Filer_for_Employer__r.Name LIKE \'' + sn + '\') ) ';
         }

         if(!String.isEmpty(dummyCase.LWDA_Number__c)) 
         {
                String ln = '%'+dummyCase.LWDA_Number__c+'%';
                totalResultsQuery += ' AND (Name LIKE \'' + ln + '\' OR Case_Number__c LIKE \'' + ln + '\') ';
         }
            
            
            if(!String.isEmpty(employerName)) { 
                String empNameTotalResults = '';
                empNameTotalResults = '%' + employerName + '%';
                totalResultsQuery += ' AND Employer__r.Name LIKE  \'' + empNameTotalResults + '\' ';
            }
        
            if(!String.isEmpty(employerFilerName)) {
                String empFilerNameTotalResults = '';
                empFilerNameTotalResults = '%' + employerFilerName + '%';
                totalResultsQuery += ' AND Employer_Filer__r.Name LIKE  \'' + empFilerNameTotalResults + '\' ';
            }
            if(!String.isEmpty(lawFirmPAGACase)) {
                String lawFirmPAGACaseTotalResults = '';
                lawFirmPAGACaseTotalResults = '%' + lawFirmPAGACase + '%';
                totalResultsQuery += ' AND Law_Firm_for_PAGA_Case__c LIKE  \'' + lawFirmPAGACaseTotalResults + '\' ';
            }
            if(!String.isEmpty(attorneyFilerName)) {
                String attorneyFilerNameTotalResults = '';
                attorneyFilerNameTotalResults = '%' + attorneyFilerName + '%';
                totalResultsQuery += ' AND Filer_Attorney_for_PAGA_Case__r.Name LIKE  \'' + attorneyFilerNameTotalResults + '\' ';
            }
            
       		if(!String.isEmpty(employeeCity)) {
               String employeeCityTotalResults = '';
        	   employeeCityTotalResults = employeeCity;
               totalResultsQuery += ' AND Employer__r.ShippingCity = :employeeCityTotalResults ';
        	}
            if(!String.isEmpty(employeeZipCode)) {
                String employeeZipCodeTotalResults = '';
                employeeZipCodeTotalResults = employeeZipCode+'%';
                totalResultsQuery += ' AND Employer__r.ShippingPostalCode LIKE \'' + employeeZipCodeTotalResults + '\'';
            }
        	if(!String.isEmpty(dummyCase.PAGA_Court_Case_Number__c)) {
                String pagacourtcasenumberTotalResults = '';
                pagacourtcasenumberTotalResults = dummyCase.PAGA_Court_Case_Number__c;
                totalResultsQuery += ' AND PAGA_Court_Case_Number__c = :pagacourtcasenumberTotalResults ';

            }
        
           if(!String.isEmpty(dummyCase.Court_Type__c)) {
                String pagacourttypeTotalResults = '';
                pagacourttypeTotalResults = dummyCase.Court_Type__c;
                totalResultsQuery += ' AND Court_Type__c = :pagacourttypeTotalResults ';

            }
        
        
        if(!String.isEmpty(dummyCase.Court_Name__c)) {
                String pagacourtnameTotalResults = '';
                pagacourtnameTotalResults = dummyCase.Court_Name__c;
                totalResultsQuery += ' AND Court_Name__c = :pagacourtnameTotalResults ';
        }
        
		//System.debug('***beforeQuery:' +totalResultsQuery);
        totalResultsQuery += 'AND Id IN (SELECT Case_Management__c FROM Attachments_Plus__c WHERE Type__c = :selectedsubmissiontype AND (CreatedDate >= :startAttachmentDate AND CreatedDate <= :endAttachmentDate))';
        //System.debug('***afterQuery:' +totalResultsQuery);
        totalResults =  Integer.valueOf(Database.countquery(totalResultsQuery));
        return totalResults;

    }
      
      
    
    //
    public List<SelectOption> getItems() {
        //Added as part of the Paga Search 2 project
        //Create two different sets.  One set will contain only the selected submission type value, the other will have all submission type values.  Compare the two sets and remove the selected value from the all submission type set.  After the comparison add all remaing values from the all submission type set to the selected value set.  That way the selected value is at the front of the set and will be value visible on the picklist by default.  Take the final selected values set and go through each one add them as select options to the submission type picklist.
        
        selectedsubmissiontype = ApexPages.currentPage().getParameters().get('st');
        //create a set that will contain the selected submission type string.  We want the selected value at the top/front of the set. 
        Set <String> selsubmissionTypeSet = new Set <String>();
        //Add the selected value to the selsubmissionTypeSet
        selsubmissionTypeSet.add(selectedsubmissiontype);
        //Create a set of all the different submission detail types.    
        Set <String> allsubmissionTypeSet = new Set <String>{'Select One...', 'PAGA Notice', 'Amended Notice', 'Employer Response/Cure', 'Cure Dispute', 'Court Complaint', 'Proposed Settlement', 'Court Order/Judgment', 'Other PAGA Document'};
 		
            //Attempt to add the selectedsubmission type to allsubmissionTypeSet
       
                Boolean result = allsubmissionTypeSet.add(selectedsubmissiontype);
                
                //if the string value that is being added to the set already exists than the boolean result will be false.  Therefore, remove the current string value item since it is present in the selectedSubmissionType/Chosen picklist.
                if(result == false)
                {
					allsubmissionTypeSet.remove(selectedsubmissiontype);
                }
        //The selected submission type should now be at the front/top of the set, all other values should be below.  Add all other values after selected value in the selsubmissionTypeSet.     
        selsubmissionTypeSet.addAll(allsubmissionTypeSet);
            
        //The submissionTypeSet should now have all the correct submission detail type values that we want to put into the allSubmissionType list/Submission Detail Availible picklist that exclude the values in selectedSubmissionType/Chosen picklist.  Add all values from the submissionttype set to the allSubmissionType list/Submission Detail Availible picklist.
        List<SelectOption> options = new List<SelectOption>();
        for(String item : selsubmissionTypeSet)
            {
                    options.add(new SelectOption(item, item));
            }

        return options;
    }
    
    public String getSelectedSubmissionType() {
      
        return selectedsubmissiontype;
    }
    
    public void setSelectedSubmissionType(String selectedsubmissiontype) {
      
        this.selectedsubmissiontype = selectedsubmissiontype;
    }    
    
    // action called from "Remove Filter Fields" link (PAGASearchResults.page)(PAGASearchResults.page)
    public void RemoveFilter() {
        if(!String.isEmpty(filterField)) {
            filtersMap.put(filterField, false);
            
            if(filterField == 'LWDA_Number__c') {
                dummyCase.LWDA_Number__c = '';
            }
            
/*
			//No longer using as part of Paga Search 2 project since these references are for date fields on case management.
			if(filterField == 'Date_Case_Received__c') {
				dummyCase.PAGA_Investigation_Decision_Date__c  = null;
				dummyCase.Court_Filing_Date_for_PAGA_Cases__c = null;
			}  
*/
            if(filterField == 'Attachment_Created_Date') {
                startAttachmentDate  = null;
                endAttachmentDate = null; 
            }
            
            if(filterField == 'Employer__r.Name')
                employerName = '';
            if(filterField == 'Employer_Filer__r.Name')
                employerFilerName = '';
            if(filterField == 'Law_Firm_for_PAGA_Case__c')
                lawFirmPAGACase = '';
            
            if(filterField == 'Employer__r.ShippingCity')
                employeeCity = '';
            if(filterField == 'Employer__r.ShippingPostalCode')
                employeeZipCode = '';
            //if(filterField == 'PAGA_Court_Case_Number__c')
              //  dummyCase.PAGA_Court_Case_Number__c = ''; 
            if(filterField == 'Court_Type__c')
                dummyCase.Court_Type__c = '';
            if(filterField == 'Court_Name__c')
                dummyCase.Court_Name__c = ''; 
            if(filterField == 'Violation_Type__c')
                dummyCase.Violation_Type__c = '';  
            if(filterField == 'Submission_Detail_Type__c')
                selectedsubmissiontype = ''; 
            if(filterField == 'Filer_Attorney_for_PAGA_Case__r.Name')
                attorneyFilerName = '';   
            
            
        }
    }
    
    
    // List with all the filters (all options shown in "Filters" picklist)
    public List<SelectOption> getPAGASearchFields() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('', '-- Select --'));
        options.add(new SelectOption('Court_Type__c', 'Court Type / Court Name'));
        options.add(new SelectOption('PAGA_Court_Case_Number__c', 'Court Case Number'));
        options.add(new SelectOption('Attachment_Created_Date', 'Submission Date'));
        // options.add(new SelectOption('Date_Case_Received__c', 'Submission Date'));
        
        options.add(new SelectOption('Employer__r.Name', 'Employer Name'));
        options.add(new SelectOption('Employer_Filer__r.Name', 'Employer Filer'));
        options.add(new SelectOption('Law_Firm_for_PAGA_Case__c', 'Law Firm for PAGA Plaintiff'));
        
        
        options.add(new SelectOption('Employer__r.ShippingCity', 'Employer City'));
        options.add(new SelectOption('Employer__r.ShippingPostalCode', 'Employer Zip Code'));
        options.add(new SelectOption('LWDA_Number__c', 'LWDA #'));
        //        options.add(new SelectOption('Violation_Type__c', 'Violation Type'));
        options.add(new SelectOption('Submission_Detail_Type__c', 'Submission Type'));
        options.add(new SelectOption('Filer_Attorney_for_PAGA_Case__r.Name', 'Filer/Attorney for PAGA Case'));
        return options;
    }
    
    
    // END get filter fields from case PAGASearch fieldset ==========
    
    
    
    // Remote action called from PAGASearchResults.page via javascript function getRemoteCases()
    @RemoteAction
    global static List<DIR_Case__c> getAllCases(String searchName, String lwNumber, String startDate, String endDate, String empName, String empFirmName, String lawFirm, String sAttFirmName, String employerCity, String employerZipCode, String countCaseNumber, String cType, String cName, String vType, String sType) {
        List<DIR_Case__c> allCases = new List<DIR_Case__c>();
        List<DIR_Case__c> allCases2 = new List<DIR_Case__c>();
        
        if(String.isEmpty(searchName) && String.isEmpty(lwNumber) && (String.isEmpty(startDate) || String.isEmpty(endDate))  
           && String.isEmpty(employerCity) && String.isEmpty(employerZipCode) && String.isEmpty(countCaseNumber) && String.isEmpty(cType) 
           && String.isEmpty(cName) && String.isEmpty(vType) && String.isEmpty(sType) ) {
               
           }
        else if(String.isBlank(startDate) && String.isBlank(endDate)){
            
        }
        else {
            
            Date sDate = NULL;
            Date eDate = NULL;
            
            if(!String.isEmpty(startDate)) {
                //String startStringDate = String.valueof(startDate);
                //List<String> startStringDate = startDate.split('/');
                //String sD = startStringDate[2] + '-' + startStringDate[0] + '-' + startStringDate[1];
                sDate = Date.valueOf(startDate);
                // query += ' AND CreatedDate >= :sDate';               
            }
            if(!String.isEmpty(endDate)) {
                //String endStringDate = String.valueof(endDate);
                //List<String> endStringDate = endDate.split('/');
                //String eD = endStringDate[2] + '-' + endStringDate[0] + '-' + endStringDate[1];
                eDate = Date.valueOf(endDate);
                // query += ' AND CreatedDate <= :eDate';
            }
            
            //Changed query to include a join with the Attachments__r/submission detail object
            String query = 'SELECT Id, Name, Case_Number__c, PAGA_LWDA_Number__c, Notice_Filing_Date__c,  Plaintiff_for_PAGA__c, Plaintiff_for_PAGA__r.Name, LWDA_Number__c, Legacy_PAGA_LWDA_Number__c, PAGA_Court_Case_Number__c,  Employer_Filer__r.Name, Employer_Filer_Firm__c, Filer_for_Employer__c, Filer_for_Employer__r.Name, Law_Firm_for_PAGA_Case__c, Employer__c, Employer__r.Name, Employer__r.ShippingCity, Employer__r.ShippingPostalCode, Violation_Type__c, Plaintiff_for_PAGA_Case_Text__c, Filer_Attorney_for_PAGA_Case__c, Filer_Attorney_for_PAGA_Case__r.Name, PAGA_Impacted_Employees__c, (SELECT Id, Name, Type__c, CreatedDate from Attachments__r WHERE CreatedDate > :sDate AND CreatedDate < :eDate AND Type__c =:sType) FROM DIR_Case__c WHERE RecordType.Name = \'PAGA Case\' AND PAGA_Status__c != \'Pending - Incomplete\'  AND Id IN (SELECT Case_Management__c FROM Attachments_Plus__c WHERE CreatedDate > :sDate AND CreatedDate < :eDate AND Type__c =:sType)';
            
            //Moved the submission type query (stype) statement up top compared to original code since need to add a statement on the type field on Attachments_Plus__c.
            //If a string sType is being passed from the PagaSearch home page, take the substring of the query and remove the end ')'.  Add the string 'AND Type__c = :sType' to the end of the subquery string and assign it back to the query string. 
            //system.debug('**stype=' +sType); 
            
            /*
            if(!String.isEmpty(sType)) {
                String subquery = query.substring(0,query.length()-1);
                subquery += ' AND Type__c = :sType)';
                query = subquery;
            }
            */
            
            if(!String.isEmpty(searchName)) {
                searchName = string.escapeSingleQuotes(searchName);
                String sn = '%'+searchName.replace('\'','\'')+'%';
                system.debug('searchName ====>' + sn);
                query += ' AND ((Employer__r.Name LIKE  \'' + sn + '\') OR (Plaintiff_for_PAGA__r.Name LIKE \'' + sn + '\') OR (Plaintiff_for_PAGA_Case_Text__c LIKE \'' + sn + '\') OR (Filer_Attorney_for_PAGA_Case__r.Name LIKE \'' + sn + '\') OR (Law_Firm_for_PAGA_Case__c LIKE \'' + sn + '\') OR (Employer_Filer__r.Name LIKE \'' + sn + '\') OR (Employer_Filer_Firm__c LIKE \'' + sn + '\') OR (Filer_for_Employer__r.Name LIKE \'' + sn + '\') ) ';
            }
            if(!String.isEmpty(lwNumber)) {
                String ln = '%'+lwNumber+'%';
                query += ' AND (Name LIKE \'' + ln + '\' OR Case_Number__c LIKE \'' + ln + '\') ';
            }
            
            
            if(!String.isEmpty(empName)) { 
                empName = '%' + empName + '%';
                query += ' AND Employer__r.Name LIKE  \'' + empName + '\' ';
            }
            if(!String.isEmpty(empFirmName)) {
                empFirmName = '%' + empFirmName + '%';
                query += ' AND Employer_Filer__r.Name LIKE  \'' + empFirmName + '\' ';
            }
            if(!String.isEmpty(lawFirm)) {
                lawFirm = '%' + lawFirm + '%';
                query += ' AND Law_Firm_for_PAGA_Case__c LIKE  \'' + lawFirm + '\' ';
            }
            if(!String.isEmpty(sAttFirmName)) {
                sAttFirmName = '%' + sAttFirmName + '%';
                query += ' AND Filer_Attorney_for_PAGA_Case__r.Name LIKE  \'' + sAttFirmName + '\' ';
            }
            
            if(!String.isEmpty(employerCity)) 
                query += ' AND Employer__r.ShippingCity = :employerCity ';
            if(!String.isEmpty(employerZipCode)) {
                employerZipCode = employerZipCode+'%';
                query += ' AND Employer__r.ShippingPostalCode LIKE \'' + employerZipCode + '\'';
            }
            if(!String.isEmpty(countCaseNumber)) 
                query += ' AND PAGA_Court_Case_Number__c = :countCaseNumber ';
            if(!String.isEmpty(cType)) 
                query += ' AND Court_Type__c = :cType';
            if(!String.isEmpty(cName)) 
                query += ' AND Court_Name__c = :cName';
            if(!String.isEmpty(vType)) {
                List<String> allVTypes = vType.split(';');
                
                query += ' AND Violation_Type__c INCLUDES (';
                Integer i = 0;
                for(String s: allVTypes) {
                    if(i < allVTypes.size()-1)
                        query += '\'' + s + '\',';
                    else 
                        query += '\'' + s + '\'';
                    i++;
                }
                query += ' )';
            }
    
            /*
            if(!String.isEmpty(sType)) {
                List<String> allSTypes = sType.split(';');
                
                query += ' AND Submission_Detail_Type__c INCLUDES (';
                Integer i = 0;
                for(String s: allSTypes) {
                    if(i < allSTypes.size()-1)
                        query += '\'' + s + '\',';
                    else 
                        query += '\'' + s + '\'';
                    i++;
                }
                query += ' )';
            }
            */
            query += ' ORDER BY Name DESC LIMIT 2001';
            System.debug('Query:' +query);
            
            allCases = Database.query(query);
            
            
            
            for(integer i=0; i < allCases.size(); i++)
            {
                //System.debug('allCases =' +allCases[i]);
                
                for(integer j=0; j< allCases[i].Attachments__r.size(); j++)
                {
                    //System.debug('Attachments__r=' +allCases[i].Attachments__r[j]);
                    
                    // loop through non null attachments and add them to the allCases2 list
                    //System.debug('sType=' +sType);
                    //System.debug('allCases[i].Attachments__r[j].Type__c =' + allCases[i].Attachments__r[j].Type__c);
                    if(allCases[i].Attachments__r[j].Name != NULL) //&& allCases[i].Attachments__r[j].Type__c == sType)
                    {
                       
                        //System.debug('Attachments__r=' +allCases[i].Attachments__r[j]);
                        allCases2.add(allCases[i]);
                    } 
                }
            }
            
 //Debug statement 
/*
for(integer k=0; k < allCases2.size(); k++)
{
System.debug('allCases2 =' +allCases2[k]);

for(integer l=0; l< allCases[k].Attachments__r.size(); l++)
{
System.debug('Attachments__r-2=' +allCases2[k].Attachments__r[l]);
}

}
*/
        }
        // convert to map to remove duplicates
        MAP<Id, DIR_Case__c> casesMap = new MAP<Id, DIR_Case__c>();
        casesMap.putAll(allCases2);
        return casesMap.values();
        //        return allCases2;
    }
    
    public void SearchCases() {
        //filtersMap.put('Date_Case_Received__c', false);
        filtersMap.put('Attachment_Created_Date', false);
        filtersMap.put('Employer__r.Name', false);
        filtersMap.put('Employer_Filer__r.Name', false);
        filtersMap.put('Law_Firm_for_PAGA_Case__c', false);
        filtersMap.put('Employer__r.ShippingCity', false);
        filtersMap.put('Employer__r.ShippingPostalCode', false);
        filtersMap.put('Court_Type__c', false);
        filtersMap.put('PAGA_Court_Case_Number__c', false);
        filtersMap.put('Violation_Type__c', false);
        filtersMap.put('LWDA_Number__c', false);
        filtersMap.put('Submission_Detail_Type__c', false);
        filtersMap.put('Filer_Attorney_for_PAGA_Case__r.Name', false);
        
    }
    
    // action called from "Add Filter Fields" link (PAGASearchResults.page)(PAGASearchResults.page)
    public void AddFilter() {
        if(!String.isEmpty(filterField)) {
            filtersMap.put(filterField, true);
        }
    }
    
    
    // action called from "Print PDF" btn (PAGASearchResults.page)
    public PageReference PrintResultsToPDF() {
        
        PageReference printPage = new PageReference('/apex/PAGAPrint');
        if(!String.isEmpty(searchString)) 
            printPage.getParameters().put('ss', searchString);
        if(!String.isEmpty(dummyCase.LWDA_Number__c)) 
            printPage.getParameters().put('lwn', dummyCase.LWDA_Number__c);
        if(startAttachmentDate != null) 
            printPage.getParameters().put('sd', String.valueof(startAttachmentDate));
        if(endAttachmentDate != null)
            printPage.getParameters().put('ed', String.valueof(endAttachmentDate));
        
        if(!String.isEmpty(employerName)) 
            printPage.getParameters().put('en', employerName);
        if(!String.isEmpty(employerFilerName)) 
            printPage.getParameters().put('ef', employerFilerName);
        if(!String.isEmpty(lawFirmPAGACase)) 
            printPage.getParameters().put('lf', lawFirmPAGACase);
        
        if(!String.isEmpty(employeeCity)) 
            printPage.getParameters().put('city', employeeCity);
        if(!String.isEmpty(employeeZipCode)) 
            printPage.getParameters().put('zip', employeeZipCode);
        if(!String.isEmpty(dummyCase.PAGA_Court_Case_Number__c)) 
            printPage.getParameters().put('cc', dummyCase.PAGA_Court_Case_Number__c);
        if(!String.isEmpty(dummyCase.Court_Type__c)) 
            printPage.getParameters().put('ct', dummyCase.Court_Type__c);
        if(!String.isEmpty(dummyCase.Court_Name__c)) 
            printPage.getParameters().put('cn', dummyCase.Court_Name__c);
        if(!String.isEmpty(dummyCase.Violation_Type__c)) 
            printPage.getParameters().put('vt', dummyCase.Violation_Type__c);
        if(!String.isEmpty(selectedsubmissiontype)) 
        	printPage.getParameters().put('st', selectedsubmissiontype);
        printPage.setRedirect(true);
        return printPage;
    }
    
    // action called from "Return to Search" btn (PAGASearchResults.page)
    public PageReference BackToSearch() {
        PageReference searchPage = new PageReference('/apex/PAGASearch');
        searchPage.setRedirect(true);
        
        return searchPage;
        
    }
    
    
    // action called from "Print to Excel" btn (PAGASearchResults.page)
    public PageReference PrintResultsToExcel() {
        
        PageReference printPage = new PageReference('/apex/PAGAPrintExcel');
        if(!String.isEmpty(searchString)) 
            printPage.getParameters().put('ss', searchString);
        if(!String.isEmpty(dummyCase.LWDA_Number__c)) 
            printPage.getParameters().put('lwn', dummyCase.LWDA_Number__c);
        if(startAttachmentDate != null) 
            printPage.getParameters().put('sd', String.valueof(startAttachmentDate));
        if(endAttachmentDate != null)
            printPage.getParameters().put('ed', String.valueof(endAttachmentDate));
        if(!String.isEmpty(employerName)) 
            printPage.getParameters().put('en', employerName);
        if(!String.isEmpty(employerFilerName)) 
            printPage.getParameters().put('ef', employerFilerName);
        if(!String.isEmpty(lawFirmPAGACase)) 
            printPage.getParameters().put('lf', lawFirmPAGACase);
        if(!String.isEmpty(employeeCity)) 
            printPage.getParameters().put('city', employeeCity);
        if(!String.isEmpty(employeeZipCode)) 
            printPage.getParameters().put('zip', employeeZipCode);
        if(!String.isEmpty(dummyCase.PAGA_Court_Case_Number__c)) 
            printPage.getParameters().put('cc', dummyCase.PAGA_Court_Case_Number__c);
        if(!String.isEmpty(dummyCase.Court_Type__c)) 
            printPage.getParameters().put('ct', dummyCase.Court_Type__c);
        if(!String.isEmpty(dummyCase.Court_Name__c)) 
            printPage.getParameters().put('cn', dummyCase.Court_Name__c);
        if(!String.isEmpty(dummyCase.Violation_Type__c)) 
            printPage.getParameters().put('vt', dummyCase.Violation_Type__c);
        if(!String.isEmpty(selectedsubmissiontype)) 
            printPage.getParameters().put('st', selectedsubmissiontype);
        printPage.setRedirect(true);
        return printPage;
    }
}