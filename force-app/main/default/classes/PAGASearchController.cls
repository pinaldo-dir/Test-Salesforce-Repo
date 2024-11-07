/********************************************************************************************************
Name:  PAGASearchController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  08/08/2017
VF Page: PAGASearch.page
Test class: PAGASearchControllerTest.cls


Behavior:
Filter cases search by case attributes so that it can narrow down to particular cases user is looking for. 
Case attributes include Date Range of PAGA Notice Filed, employer city, employer zip code, court name, 
court case number, and the type of violation.

********************************************************************************************************/

global class PAGASearchController {
    
    // dummy DIR Case Record
    public DIR_Case__c dummyCase {get; set;}
    public String searchString {get; set;}
    public String employeeCity {get; set;}
    public String employeeZipCode {get; set;}
    public Date startAttachDate {get; set;}
    public Date endAttachDate {get; set;}
    public String selectedsubmissiontype {get; set;}
    public String submissiontypeError{get; set;}
    public Boolean shwErrorSubmissionType{get; set;}
    public String dateError{get; set;}
    public Boolean shwErrorDates{get; set;}
	public Boolean isMaintenanceMsg {get; set;}

    
    // class constructor, executes first, as soon as the class is invoked
    global PAGASearchController() {
        Id pagaRTId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        if(dummyCase == null) {
            dummyCase = new DIR_Case__c();
            dummyCase.recordTypeId = pagaRTId;
        }
        
        selectedsubmissiontype = '';
        searchString = '';
       
        
        if(!Label.Reg_Maintenance_Msg.equalsIgnorecase('off')){
            isMaintenanceMsg = true;
        } 
    }
    
    //Added as part of Paga Search 2 project to populate all of the submission types into the {!items} selectOptions picklist on line 116 of the PagaSearch.vfp page.
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Select One...','Select One...'));
        options.add(new SelectOption('PAGA Notice','PAGA Notice'));
        options.add(new SelectOption('Amended Notice','Amended Notice'));
        options.add(new SelectOption('Employer Response/Cure','Employer Response/Cure'));
        options.add(new SelectOption('Cure Dispute','Cure Dispute'));
        options.add(new SelectOption('Court Complaint','Court Complaint'));
        options.add(new SelectOption('Proposed Settlement','Proposed Settlement'));
        options.add(new SelectOption('Court Order/Judgment','Court Order/Judgment'));
        options.add(new SelectOption('Other PAGA Document','Other PAGA Document'));
        return options;
    }
    
    // clears all the fields on Search page
    public void ClearFields() {
        dummyCase = new DIR_Case__c();
        searchString = '';
        employeeCity = '';
        employeeZipCode = '';
        startAttachDate = null;
        endAttachDate = null;
    } 
    
    
    
    // sends all inserted values as parameters and rediredcts to PAGASearchResults.page
    public PageReference SearchCases() {
        PageReference resultsPage = new PageReference('/apex/PAGASearchResults');
        //System.debug('****startAttachDate :' + startAttachDate + '****endAttachDate :' + endAttachDate );
             
        //Added as part of the Paga Search 2 project.  Displays one global error message when a start/end date and submission type aren't entered.  Tied to line 153 (<apex:pageMessages id="showmsg"></apex:pageMessages>) in the PagaSearch.vfp.  Displays error message when the user clicks on the Search button and when either From (startAttachDate variable) or To (endAttachDate variable) field is blank or the submission type picklist (selectedsubmissiontype) = Select One... . 
       /* if((startAttachDate == null || endAttachDate == null) || selectedsubmissiontype.contains('Select One...')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select one (1) Submission Type.'));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter a Start Date and an End Date.'));
            resultsPage.setRedirect(false);
            return NULL;
        }
     */
        /* Added for Paga search 2 project PS-001-A.  Seperate error message under the submission type field and Date Range of Submission when fields are blank in the PAGASearch.vfp.  Code below goes through all the different conditions of user selection of date range of submission fields and submission type.  It then displays the correct error message. */
        
           if(startAttachDate == null && endAttachDate == null && selectedsubmissiontype.contains('Select One...'))
           {
		     	shwErrorDates = false;
				dateError ='Please enter a date into the From and To fields.';
				shwErrorDates = True;
               	shwErrorSubmissionType = false;
				submissiontypeError ='Please select a submission type.';
				shwErrorSubmissionType = True;
                resultsPage.setRedirect(false);
        		return null;
           
           }
        
        //Either start date or end date is null and a submission type is not selected
        if((startAttachDate == null || endAttachDate == null) && selectedsubmissiontype.contains('Select One...') )
           {
                shwErrorDates = false;
				dateError ='Please enter a date into the From and To fields.';
				shwErrorDates = True;
               	shwErrorSubmissionType = false;
				submissiontypeError ='Please select a submission type.';
				shwErrorSubmissionType = True;
                resultsPage.setRedirect(false);
        		return null;
			}
                  
        
        //Either start date or end date is null and a submission type is not selected
        if((startAttachDate == null || endAttachDate == null) && !selectedsubmissiontype.contains('Select One...') )
           {
                shwErrorDates = false;
				dateError ='Please enter a date into the From and To fields.';
				shwErrorDates = True;
                resultsPage.setRedirect(false);
        		return null;
			}
                 
        
        //Either submission type is null or date fields both have values         
        if(selectedsubmissiontype.contains('Select One...') || ((startAttachDate != null && endAttachDate != null) && selectedsubmissiontype.contains('Select One...')))
           {
           		shwErrorSubmissionType = false;
				submissiontypeError ='Please select a submission type.';
				shwErrorSubmissionType = True;
                resultsPage.setRedirect(false);
        		return null;
           }
        
        //end of Paga Search 2 project PS-001-A addition
        
        else{
            
            if(!String.isEmpty(searchString)) 
                resultsPage.getParameters().put('ss', searchString);
            if(!String.isEmpty(dummyCase.LWDA_Number__c)) 
                resultsPage.getParameters().put('lwn', dummyCase.LWDA_Number__c);
            if(startAttachDate != null) 
                resultsPage.getParameters().put('sd', String.valueof(startAttachDate));
            if(endAttachDate != null)
                resultsPage.getParameters().put('ed', String.valueof(endAttachDate));
            if(!String.isEmpty(employeeCity)) 
                resultsPage.getParameters().put('ec', employeeCity);
            if(!String.isEmpty(employeeZipCode)) 
                resultsPage.getParameters().put('ezc', employeeZipCode);
            if(!String.isEmpty(dummyCase.PAGA_Court_Case_Number__c)) 
                resultsPage.getParameters().put('ccn', dummyCase.PAGA_Court_Case_Number__c);
            if(!String.isEmpty(dummyCase.Court_Type__c)) 
                resultsPage.getParameters().put('ct', dummyCase.Court_Type__c);
            if(!String.isEmpty(dummyCase.Court_Name__c)) 
                resultsPage.getParameters().put('cn', dummyCase.Court_Name__c);
            if(!String.isEmpty(dummyCase.Violation_Type__c)) 
                resultsPage.getParameters().put('vt', dummyCase.Violation_Type__c);
            if(!String.isEmpty(selectedsubmissiontype)) {
                resultsPage.getParameters().put('st', selectedsubmissiontype);
                //system.debug('***selectedsubmissiontype'+selectedsubmissiontype);
            }
            resultsPage.setRedirect(true);
            return resultsPage;
        }
    }
}