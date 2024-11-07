/********************************************************************************************************
Name:  PAGAPrintController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  08/14/2017
VF Page: PAGAPrint.page
Test class: PAGAPrintControllerTest.cls

Behavior:
    Display PAGA Case as pdf (print document)
       
********************************************************************************************************/

public without sharing class PAGAPrintController {
    public DIR_Case__c currentCase {get; set;}
    private String currentCaseId;
    public List<DIR_Case__c> allResultCases {get; set;}
    
     // class constructor, executes first, as soon as the class is invoked
    public PAGAPrintController(){
        // get values from url parameters
        currentCaseId = ApexPages.currentPage().getParameters().get('Id');
        String eSearch = ApexPages.currentPage().getParameters().get('ss');
        String lwNumber = ApexPages.currentPage().getParameters().get('lwn');
        String sDate = ApexPages.currentPage().getParameters().get('sd');
        String eDate = ApexPages.currentPage().getParameters().get('ed');
        String eName = ApexPages.currentPage().getParameters().get('en');
        String eFiler = ApexPages.currentPage().getParameters().get('ef');
        String lawFirm = ApexPages.currentPage().getParameters().get('lf');
        String attFirmName = ApexPages.currentPage().getParameters().get('fn');
        String eCity = ApexPages.currentPage().getParameters().get('city');
        String eZipCode = ApexPages.currentPage().getParameters().get('zip');
        String eCourtCode = ApexPages.currentPage().getParameters().get('cc');
        String eCourtType = ApexPages.currentPage().getParameters().get('ct');
        String eCourtName = ApexPages.currentPage().getParameters().get('cn');
        
        String eViolationType = ApexPages.currentPage().getParameters().get('vt');
        String eSubmissionType = ApexPages.currentPage().getParameters().get('st');
        
        System.debug('***** sDate : ' + sDate);
        System.debug('***** eDate : ' + eDate);
        
        
        
        // calls getCurrentCases() method to retrieve the results (a list of DIR_Case__c records)  
        allResultCases = getCurrentCases(eSearch, lwNumber, sDate, eDate, eName, eFiler, lawFirm, attFirmName, eCity, eZipCode, eCourtCode, eCourtType, eCourtName, eViolationType, eSubmissionType);

    }
    
    public List<DIR_Case__c> getCurrentCases(String searchName, String lwNumber, String startDate, String endDate, String empName, String empFirmName, String lawFirm, String sAttFirmName, String employerCity, String employerZipCode, String courtCaseNumber, String cType, String cName, String vType, String sType) {
//     global static List<DIR_Case__c> getAllCases(String searchName, String lwNumber, String startDate, String endDate, String empName, String empFirmName, String lawFirm, String sAttFirmName, String employerCity, String employerZipCode, String courtCaseNumber, String cType, String cName, String vType, String sType) {

        List<DIR_Case__c> allCases = new List<DIR_Case__c>();
        List<DIR_Case__c> allCases2 = new List<DIR_Case__c>();
        
        if(String.isEmpty(searchName) && String.isEmpty(lwNumber) && (String.isEmpty(startDate) || String.isEmpty(endDate))  
        && String.isEmpty(employerCity) && String.isEmpty(employerZipCode) && String.isEmpty(courtCaseNumber) && String.isEmpty(cType) 
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
                System.debug('***** sDate: ' + sDate);
                // query += ' AND CreatedDate >= :sDate';               
            }
            if(!String.isEmpty(endDate)) {
                //String endStringDate = String.valueof(endDate);
                //List<String> endStringDate = endDate.split('/');
                //String eD = endStringDate[2] + '-' + endStringDate[0] + '-' + endStringDate[1];
                eDate = Date.valueOf(endDate);
                System.debug('***** eDate: ' + eDate);
                // query += ' AND CreatedDate <= :eDate';
            }
            
            //Changed query to include a join with the Attachments__r/submission detail object
            String query = 'SELECT Id, Name, Case_Number__c, Court_Case_Number_for_PAGA_Case__c,  PAGA_LWDA_Number__c, Notice_Filing_Date__c, Plaintiff_for_PAGA__c, Plaintiff_for_PAGA__r.Name, LWDA_Number__c, Legacy_PAGA_LWDA_Number__c, PAGA_Court_Case_Number__c,  Employer_Filer__r.Name, Employer_Filer_Firm__c, Filer_for_Employer__c, Filer_for_Employer__r.Name, Law_Firm_for_PAGA_Case__c, Employer__c, Employer__r.Name, Employer__r.ShippingCity, Employer__r.ShippingPostalCode, Violation_Type__c, Plaintiff_for_PAGA_Case_Text__c, Filer_Attorney_for_PAGA_Case__c, Filer_Attorney_for_PAGA_Case__r.Name, PAGA_Impacted_Employees__c, (SELECT Id, Name, Type__c, CreatedDate from Attachments__r WHERE CreatedDate > :sDate AND CreatedDate < :eDate AND Type__c =: sType) FROM DIR_Case__c WHERE RecordType.Name = \'PAGA Case\' AND PAGA_Status__c != \'Pending - Incomplete\'  AND Id IN (SELECT Case_Management__c FROM Attachments_Plus__c WHERE CreatedDate > :sDate AND CreatedDate < : eDate AND Type__c =: sType)';

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
            if(!String.isEmpty(courtCaseNumber)) 
                query += ' AND PAGA_Court_Case_Number__c = :courtCaseNumber ';
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
            
/*            if(!String.isEmpty(sType)) {
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
            query += ' ORDER BY Name DESC, Employer__r.Name DESC LIMIT 10000';
            System.debug('*****Query:' +query);
            
            allCases = Database.query(query);
            
            for(integer i=0; i < allCases.size(); i++)
            {
                //System.debug('allCases =' +allCases[i]);
                if(allCases[i] != NULL){
                    for(integer j=0; j< allCases[i].Attachments__r.size(); j++)
                    {
                        //System.debug('Attachments__r=' +allCases[i].Attachments__r[j]);
                        
                        // loop through non null attachments and add them to the allCases2 list
                        if(allCases[i].Attachments__r[j].Name != NULL)
                        {
                            allCases2.add(allCases[i]);
                        } 
                    }
                }
            }
        }
        // convert to map to remove duplicates
        MAP<Id, DIR_Case__c> casesMap = new MAP<Id, DIR_Case__c>();
//        if(allCases2.size() > 0){
            casesMap.putAll(allCases2);
//        }
        return casesMap.values();
    }
    
}