({
    doInit : function(component, event, helper) {
        component.set("v.isLoading", true);
        helper.getWageClaimRecords(component, event);
        
    },
    handleDownloadPdf : function(component, event, helper) {
        helper.getDownloadPdfStatus(component, event, helper);
    },
    handleDownloadCsv : function(component, event, helper) {
        // get the Records [contact] list from 'ListOfContact' attribute
        var stockData; 
        var wageClaimRecordList = component.get("v.wageClaimRecordCsvList");
        var sortedCsvFileForWageClaim = component.get("v.sortedCsvFileForWageClaim");
        if(sortedCsvFileForWageClaim.length > 0){
            stockData = sortedCsvFileForWageClaim;
            var csv = helper.convertArrayOfWageClaimToCsv(component,stockData);
        }
        else if(wageClaimRecordList.length > 0){
            stockData = wageClaimRecordList;
            var csv = helper.convertArrayOfWageClaimToCsv(component,stockData); 
        }
        
        // call the helper function which "return" the CSV data as a String   
        if (csv == null){return;} 
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:application/csv;charset=utf-8,' + encodeURIComponent(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'WageClaimDataExport.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    },
    backToSearch : function(component, event, helper) {
        //get the selected filters
        var urlParamsForFilters = component.get("v.urlParamsForFilters") || '';
        //redirect to the Search Page
        var url = (urlParamsForFilters != '') ? "/wcsearch/s/?"+urlParamsForFilters : '/s';
        console.log('URL=====' + url);
        window.open(url,'_self');
    },
})