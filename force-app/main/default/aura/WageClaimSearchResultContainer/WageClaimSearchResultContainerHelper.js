({
    getWageClaimRecords : function(component, event) {
        var querystring = location.search.substr(1);
        console.log('querystring::'+querystring);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        console.log('paramValue:: '+JSON.stringify(paramValue));
        
        var accountName;
        var caseNumber;
        var fromDate;
        var toDate;
        var closedFromDate;
        var closedToDate;
        var naicsCode;
        var lowWage;
        var dirOffice;
        var dirOfficeId;
        var naicsCodeId;
        var naicsCodeTitle;
        
        if(paramValue.accountName != null){
            accountName = paramValue.accountName.split('+').join(' ');
        }
        if(paramValue.naicsCodeTitle != null){
            naicsCodeTitle = paramValue.naicsCodeTitle.split('+').join(' ') || null;
            console.log('naicsCodeTitle :::::::::: '+naicsCodeTitle);
        }
        if(paramValue.naics != null){
            naicsCode = paramValue.naics.split('+').join(' ');
            console.log('naics ::::: '+naicsCode);
        }
        if(paramValue.docketfromdate != null){
            var dateFrom = paramValue.docketfromdate.split('+').join(' ') || null;
            fromDate = (dateFrom != null) ? dateFrom : null;
        }
        if(paramValue.dockertodate != null){
            var dateTo = paramValue.dockertodate.split('+').join(' ') || null;
            toDate = (dateTo != null) ? dateTo : null;
        }
        if(paramValue.caseclosedfromdate != null){
            var caseclosedfromdate = paramValue.caseclosedfromdate.split('+').join(' ') || null;
            closedFromDate = (caseclosedfromdate != null) ? caseclosedfromdate : null;
            console.log('caseclosedfromdate :::: '+closedFromDate);
        }
        if(paramValue.caseclosedtodate != null){
            var caseclosedtodate = paramValue.caseclosedtodate.split('+').join(' ') || null;
            closedToDate = (caseclosedtodate != null) ? caseclosedtodate : null;
            console.log('caseclosedtodate :::: '+closedToDate);
        }
        if(paramValue.diroffice != null){
            dirOffice = paramValue.diroffice.split('+').join(' ');
        }
        if(paramValue.dirOfficeId != null){
            dirOfficeId = paramValue.dirOfficeId.split('+').join(' ');
        }
        if(paramValue.casenumber != null){
            caseNumber = paramValue.casenumber.split('+').join(' ');
            console.log('caseNumber ::::::::: > '+caseNumber);
        }
        if(paramValue.naicsCodeId != null){
            naicsCodeId = paramValue.naicsCodeId.split('+').join(' ');
            console.log('naicsId :: '+naicsCodeId);
        }
        console.log('caselowwage::'+paramValue.caselowwage);
        if(paramValue.caselowwage != null){
            lowWage = paramValue.caselowwage.split('+').join(' ');
        }
        var filtersParams ;
        filtersParams = '&accountName=' + accountName + '&naicsCodeId=' + naicsCodeId + '&naicsCodeTitle=' + naicsCodeTitle + '&naicsCode=' + naicsCode + '&fromDate=' + fromDate + '&toDate=' + toDate + '&caseclosedfromdate=' + closedFromDate + '&caseclosedtodate=' + closedToDate + '&dirOffice=' + dirOffice + '&dirOfficeId='+ dirOfficeId +'&caseNumber=' + caseNumber + '&lowWage=' +lowWage;
        console.log('filtersParams: '+filtersParams);
        component.set('v.urlParamsForFilters', filtersParams);
        console.log('naicsCodeTitle &&&&&::'+naicsCodeTitle);
        var action = component.get("c.getWageClaimRecords");
        action.setParams({
            "naicsCode" : naicsCode,
            "accountName" : accountName,  
            "docketDateFrom" : dateFrom,
            "docketDateTo" : toDate,
            "caseClosedFrom" : closedFromDate,
            "caseClosedTo" : closedToDate,
            "caseNumber" : caseNumber,
            "lowWage" : lowWage,
            "dirOffice": dirOffice
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tableMessage = '';
                //hide the spiner
                component.set("v.isLoading", false);
                //component.set("v.judgmentRecordsList",response.getReturnValue());
                console.log('response.getReturnValue()::'+response.getReturnValue());
                var resultSize = response.getReturnValue().length;
                var result = response.getReturnValue();
                component.set("v.isLoading", false);
                component.set("v.totalPages", Math.ceil(response.getReturnValue().length/component.get("v.pageSize")));
                component.set("v.totalWageRecordsSize",response.getReturnValue().length);
                component.set("v.wageClaimRecordCsvList", result);
                //lets check for the Records greater than 2000;
                if(response.getReturnValue().length > 2000) { 
                    //show an validation message to reduce the records in result
                    tableMessage ="More than 2,000 records found – please narrow your search criteria to obtain a shorter list or click the ‘Download to Excel’ button above to download result for the most recent 5,000 records.";
                    component.set("v.isShowExcelButton", true);
                    //this.showToastMessage(component,'sticky', 'error', 'Warning!', errorMessage);
                    //show the JudgmentSearch cmp
                    //component.set("v.showSearchFilters", true);
                }
                else if(response.getReturnValue().length > 0){
                    component.set("v.wageClaimRecordList", response.getReturnValue());
                }
                    else{
                        tableMessage = "No Matching Records Found";
                    }
                //display the Disclaimer message
                //component.set("v.displayDisclaimerContent", true);
                component.set("v.currentPageNumber",1);
                
                setTimeout(function() {
                    var currData = [];
                    $('#lightningDataTable').DataTable({
                        "ordering": true,
                        "paging":true,
                        "search":true,
                        "searching": false,
                        "dom": '<"top"f>rt<"bottom"ilp><"clear">',
                        "lengthMenu": [25, 50, 100],
                        "order": [ 3, 'asc' ],
                        "oLanguage": {
                            "sEmptyTable": tableMessage
                        },
                        initComplete: function () {
                            this.api().on( 'draw', function () {
                                if(resultSize == 0 || resultSize >= 2000){
                                    $("tr:eq(1)").remove(); 
                                }
                                var table = $('#lightningDataTable').DataTable();
                                var order = table.order();
                                var sortedOrder = order[0][1];
                                var title = table.column(order[0][0]).header();
                                var sortedHeader = $("<div>").html($(title).html()).text();
                                component.set("v.sortingOrder", sortedOrder);
                                component.set("v.selectedHeader", sortedHeader);
                                console.log('sortedOrder ::: '+sortedOrder);
                                console.log('sortedHeader ::: '+sortedHeader);
                                //Prepare sorted dataTable data for csv and pdf functionality.
                                var sortedObject = [];
                                var WrapperApiName = ['','accountName','caseRole','caseNumber','naicsCode','naicsTitle','dateofDocket','assignedDeputy','dirOffice','caseStatus' ];
                                var myTable = $('#lightningDataTable').DataTable();
                                var sortedData = myTable.rows().data().toArray();
                                for(var i=0;i<resultSize;i++){
                                    var sortedList = sortedData[i];
                                    var object = {};
                                    for(var j=1;j<sortedList.length;j++){
                                        switch (WrapperApiName[j]) {
                                            case "accountName":
                                                object.accountName = $("<div>").html(sortedList[j]).text();
                                                break;
                                            case "caseRole":
                                                object.caseRole = $("<div>").html(sortedList[j]).text();
                                                break;
                                            case "caseNumber":
                                                object.caseNumber = $("<div>").html(sortedList[j]).text();
                                                break;
                                            case "naicsCode":
                                                object.naicsCode = $("<div>").html(sortedList[j]).text();
                                                break;
                                            case "naicsTitle":
                                                object.naicsTitle = $("<div>").html(sortedList[j]).text();
                                                break;
                                            case "dateofDocket":
                                                object.dateofDocket = $("<div>").html(sortedList[j]).text();
                                                break;
                                            case "assignedDeputy":
                                                object.assignedDeputy = $("<div>").html(sortedList[j]).text();
                                                break;
                                            case "dirOffice":
                                                object.dirOffice = $("<div>").html(sortedList[j]).text();
                                                break;
                                            case "caseStatus":
                                                object.caseStatus = $("<div>").html(sortedList[j]).text();
                                                break;
                                        }
                                    }
                                    sortedObject.push(object);
                                }
                                component.set("v.sortedCsvFileForWageClaim", sortedObject);
                            });
                        }
                    });
                    $('div.dataTables_length').addClass("DTSelectLenghtStyle");
                    component.set("v.isLoading",false);
                }, 1000);
                //var table = $('#lightningDataTable').DataTable();
                //var order = table.order();
                //console.log('sorting ::: '+order);
                //helper.showJudgmentRecordsPerPage(component, helper);
            }
            else if (state === "INCOMPLETE") {
                // do something
                //hide the spiner
                component.set("v.isLoading", false);
            }
                else if (state === "ERROR") {
                    //hide the spiner
                    component.set("v.isLoading", false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.showToastMessage(component,'sticky', 'error', 'Error!', errors[0].message);
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        this.showToastMessage(component,'sticky', 'error', 'Error!', "Unknown error");
                        console.log();
                    }
                }
        });
        $A.enqueueAction(action);
    },
    getDownloadPdfStatus : function(component, event, helper){
        var paramValue = component.get('v.urlParamsForFilters');
        console.log('urlParamsForFilters ::: '+paramValue);
        var selectedHeader = component.get("v.selectedHeader");
        var sortingOrder = component.get("v.sortingOrder");
        var paramValue = paramValue + '&selectedHeader=' + selectedHeader + '&sortingOrder=' + sortingOrder;
        console.log('selectedHeader ::::: '+selectedHeader);
        console.log('sortingOrder ::::: '+sortingOrder);
        var vfPageUrl = '/apex/WageClaimSearchResultPage?'+paramValue;
        window.open(vfPageUrl,"_blank");
    },
    convertArrayOfWageClaimToCsv : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        
        keys = ['accountName','caseRole','caseNumber','naicsCode','naicsTitle','dateofDocket','assignedDeputy','dirOffice','caseStatus' ];
        
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }  
                if(skey == 'dateofDocket'){
                    csvStringResult += '"'+ $A.localizationService.formatDate(objectRecords[i][skey], "MM/DD/YYYY") +'"';
                }
                else{
                    csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                }
                counter++;
                
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        // return the CSV formate String 
        csvStringResult = csvStringResult.split('undefined').join(' ');
        //csvStringResult = csvStringResult.split('accountName').join('Party Name');
        csvStringResult = csvStringResult.split('accountName').join('Defendant Name');
        csvStringResult = csvStringResult.split('caseRole').join('Party Type');
        csvStringResult = csvStringResult.split('caseNumber').join('Case Number');
        csvStringResult = csvStringResult.split('naicsCode').join('NAICS Code');
        csvStringResult = csvStringResult.split('naicsTitle').join('NAICS Industry');
        csvStringResult = csvStringResult.split('dateofDocket').join('Date Filed');
        csvStringResult = csvStringResult.split('assignedDeputy').join('Assigned Deputy');
        csvStringResult = csvStringResult.split('dirOffice').join('DIR Office');
        csvStringResult = csvStringResult.split('caseStatus').join('Case Status');
        return csvStringResult; 
    },
    showToastMessage : function(component,mode, type, title, errorMessage) { 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "type": type,
            "title": title,
            "message": errorMessage
        });
        toastEvent.fire();
    }
})