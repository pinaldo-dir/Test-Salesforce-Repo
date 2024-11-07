({
    doInit : function(component, event, helper) {
        helper.getJudgmentRecords(component, event, helper);
    },
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.showJudgmentRecordsPerPage(component, helper);
    },
    openListLaborCode : function(component, event, helper) {        
        var url = 'https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=LAB&sectionNum=2810.4';
        window.open(url,"_blank");
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.showJudgmentRecordsPerPage(component, helper);
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.showJudgmentRecordsPerPage(component, helper);
    },
    onSelectChange : function(component, event, helper){
        var recordsPerPage = component.find("recordSize").get("v.value");
        var judgmentRecordsList = component.get("v.judgmentRecordsList");
        if(judgmentRecordsList.length > 0){
            component.set("v.pageSize", recordsPerPage);
            component.set("v.totalPages", Math.ceil(judgmentRecordsList.length/component.get("v.pageSize")));
            component.set("v.totalJudgmentRecordsSize",judgmentRecordsList.length);
            component.set("v.currentPageNumber",1);
            helper.showJudgmentRecordsPerPage(component, recordsPerPage);
        }
    },
    handleDownloadPdf : function(component, event, helper){
        helper.getDownloadPdfStatus(component, event, helper);
    },
    backToSearch : function(component, event, helper){
        //get the selected filters
        var urlParamsForFilters = component.get("v.urlParamsForFilters") || '';
        //redirect to the Search Page
        var url = (urlParamsForFilters != '') ? "/s?"+urlParamsForFilters : '/s';
        
        window.open(url,'_self');
    },
    handleDownloadCsv : function(component, event, helper){
        // get the Records [contact] list from 'ListOfContact' attribute
        var stockData; 
        var judgmentRecordsList = component.get("v.judgmentRecordsListForCsv");
        var portDrayageRecordsList = component.get("v.portDrayageRecordsListForCsv");
        if(judgmentRecordsList.length > 0){
            stockData = judgmentRecordsList;
            var csv = helper.convertArrayOfJudgmentRecordToCSV(component,event, helper,stockData);  
        }
        else if(portDrayageRecordsList.length > 0){
            stockData = portDrayageRecordsList;
            var csv = helper.convertArrayOfPortDrayageRecordToCSV(component,event, helper,stockData);  
        }
        
        // call the helper function which "return" the CSV data as a String   
        if (csv == null){
            {return;} 
        }
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:application/csv;charset=utf-8,' + encodeURIComponent(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
})