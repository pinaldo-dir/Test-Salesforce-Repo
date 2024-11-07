({
    getJudgmentRecords : function(component, event, helper) {
        
        component.set("v.isLoading", true);
        
        /*Refresh Page
        var filtersParams ;
        filtersParams = 'liststatus='+liststatus +'&naics='+naics+'&accountName='+accountName +
            			'&city='+city+'&zipCode='+zipCode+'&judgmentdatefrom='+judgmentdatefrom+
            			'&judgmentdateto='+judgmentdateto+'&court='+court+'&judgmentstatus='+judgmentstatus+
            			'&defandantemployer='+defandantemployer+'&judgmenttotal='+judgmenttotal+
            			'&citationnumber='+citationnumber+'&diroffice='+diroffice;
        component.set('v.urlParamsForFilters', filtersParams);
        Refresh Page */
        //const queryString = window.location.search;
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        if(paramValue.searchtype == 'portdrayage'){
            component.set("v.searchType",true);
            component.set("v.searchName" ,'Search Results');
            this.getPortDrayageRecords(component,event,paramValue);
        }else if(paramValue.searchtype == 'judgmentsearch'){ 
            component.set("v.searchName" ,'Search Results');
            component.set("v.searchType",false);
            
            this.getJudgmentSearchRecords(component,event,paramValue);
        }
        
    },
    showJudgmentRecordsPerPage : function(component, helper) {
        var Judgmentdata = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var judgmentRecordsList = component.get("v.judgmentRecordsList");
        var x = (pageNumber-1)*pageSize;
        component.set("v.judgmentRecordStart",parseInt(x) + 1);
        var i = parseInt((pageNumber-1)*pageSize);
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
            if(judgmentRecordsList[x]){
                Judgmentdata.push(judgmentRecordsList[x]);
                i++;
            }
        }
        component.set("v.judgmentRecordEnd",i);
        component.set("v.judgmentRecordsPerPage", Judgmentdata);
        
        this.generatePageList(component, pageNumber);
    },
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    },
    getJudgmentSearchRecords : function(component, event, paramValue){
        
        //Get the event message attributes
        var liststatus ;
        var naics ;
        var accountName ;
        var city ;
        var zipCode ;
        var judgmentdatefrom ;
        var judgmentdateto ;
        var court;
        var judgmentstatus;
        var defandantemployer;
        var judgmentTotalFrom;
        var judgmentTotalTo;
        var citationnumber;
        var diroffice;
        
        var county;
        var naicsCodeTitle;
        var naicsCodeId;
        var courtId;
        var citationNumberId;
        var dirOfficeId;
        /*
        if(paramValue.liststatus != null){
            liststatus = paramValue.liststatus.split('+').join(' ');
        }
        */
        if(paramValue.naics != null){
            naics = paramValue.naics.split('+').join(' ');
        }
        if(paramValue.accountName != null){
            accountName = paramValue.accountName.split('+').join(' ');
        }
        if(paramValue.city != null){
            city = paramValue.city.split('+').join(' ');
        }
        if(paramValue.zipCode != null){
            zipCode = paramValue.zipCode.split('+').join(' ');
        }
        if(paramValue.judgmentdatefrom != null){
            var dateForm = paramValue.judgmentdatefrom.split('+').join(' ') || null;
            judgmentdatefrom = (dateForm != null) ? dateForm : null;
        }
        if(paramValue.judgmentdateto != null){
            var dateTo = paramValue.judgmentdateto.split('+').join(' ') || null;
            judgmentdateto = (dateTo != null) ? dateTo : null;
        }
        if(paramValue.court != null){
            court = paramValue.court.split('+').join(' ');
        }
        if(paramValue.judgmentstatus != null){
            judgmentstatus = paramValue.judgmentstatus.split('+').join(' ') || null;
        }
        if(paramValue.defandantemployer != null){
            defandantemployer = paramValue.defandantemployer.split('+').join(' ');
        }
        if(paramValue.judgmentTotalFrom != null){
            var totalAmount = paramValue.judgmentTotalFrom.split('+').join(' ') || '';
            judgmentTotalFrom = (totalAmount != null && totalAmount != '') ? parseFloat(totalAmount) : 0.00;
        }
        if(paramValue.judgmentTotalTo != null){
            var totalAmount = paramValue.judgmentTotalTo.split('+').join(' ') || '';
            judgmentTotalTo = (totalAmount != null && totalAmount != '') ? parseFloat(totalAmount) : 0.00;
        }
        if(paramValue.citationnumber != null){
            citationnumber = paramValue.citationnumber.split('+').join(' ');
        }
        if(paramValue.diroffice != null){
            diroffice = paramValue.diroffice.split('+').join(' ');
        }
        
        if(paramValue.citationNumberId != null){
            citationNumberId = paramValue.citationNumberId;
        }
        if(paramValue.dirOfficeId != null){
            dirOfficeId = paramValue.dirOfficeId;
        }
        if(paramValue.courtId != null){
            courtId = paramValue.courtId;
            
        }
        if(paramValue.naicsCodeId != null){
            naicsCodeId = paramValue.naicsCodeId;
            
        }
        if(paramValue.county != null){
            county = paramValue.county.split('+').join(' ');
            
        }
        if(paramValue.naicsCodeTitle != null){
            naicsCodeTitle = paramValue.naicsCodeTitle;
            
        }
        
        var filtersParams ;
        filtersParams = 'searchtype=judgmentsearch&naics='+naics+'&accountName='+accountName +
            '&city='+city+'&zipCode='+zipCode+'&judgmentdatefrom='+judgmentdatefrom+
            '&judgmentdateto='+judgmentdateto+'&court='+court+'&judgmentstatus='+judgmentstatus+
            '&defandantemployer='+defandantemployer+'&judgmentTotalFrom='+judgmentTotalFrom+'&judgmentTotalTo='+judgmentTotalTo+
            '&citationnumberId='+citationNumberId+'&diroffice='+diroffice+'&dirOfficeId='+dirOfficeId+'&naicsCodeId='+naicsCodeId+'&citationnumber='+citationnumber+
            '&courtId='+courtId+'&naicsCodeId='+naicsCodeId+
            '&county='+county+'&naicsCodeTitle='+naicsCodeTitle;
        component.set('v.urlParamsForFilters', filtersParams);
        //const urlParams = new URLSearchParams(queryString);
        var action = component.get("c.getJudgmentRecords");
        action.setParams({
            "listStatus2810": liststatus,
            "naicsCode" : naics,
            "accountName" : accountName, 
            "City" : city,
            "ZipCode" : zipCode, 
            "judgmentEntryDateFrom" : judgmentdatefrom,
            "judgmentEntryDateTo" : judgmentdateto,
            "court" : court, 
            "judgmentStatus" : judgmentstatus, 
            "defandantEmployerName" : defandantemployer,
            "judgmentTotalFrom" : judgmentTotalFrom, 
            "judgmentTotalTo" : judgmentTotalTo,
            "citationNumber" : citationnumber,
            "dirOffice": diroffice,
            "county": county
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //hide the spiner
                component.set("v.isLoading", false);
                //component.set("v.judgmentRecordsList",response.getReturnValue());
                var result = response.getReturnValue();
                var resultSize = response.getReturnValue().length;
                component.set("v.totalPages", Math.ceil(response.getReturnValue().length/component.get("v.pageSize")));
                component.set("v.totalJudgmentRecordsSize",response.getReturnValue().length);
                component.set("v.judgmentRecordsListForCsv", response.getReturnValue());
                var tableMessage = '';
                //lets check for the Records greater than 2000;
                if(response.getReturnValue().length >2000) { 
                    //show an validation message to reduce the records in result
                    //var errorMessage ="More than 2000 records to display – please narrow the search criteria by adding another search component to obtain a shorter list";
                    //this.showToastMessage(component,'sticky', 'error', 'Warning!', errorMessage);
                    //show the JudgmentSearch cmp
                    //component.set("v.showSearchFilters", true);
                    tableMessage = "More than 2,000 records found – please narrow your search criteria to obtain a shorter list or click the ‘Download to Excel’ button above to download result for the most recent 5,000 records.";
                    component.set("v.showPdfButtons", true);
                } else if(response.getReturnValue().length > 0){
                    component.set("v.judgmentRecordsList", response.getReturnValue());
                    component.set("v.showPdfButtons", true);
                } else{
                    tableMessage = "No Matching Records Found";
                }
                //display the Disclaimer message
                component.set("v.displayDisclaimerContent", true);
                component.set("v.currentPageNumber",1);
                setTimeout(function() {
                    $('#lightningDataTable').DataTable({
                        "columnDefs": [
                            {"className": "dt-right", "targets": 7}
                        ],
                        "ordering": true,
                        "dom": '<"top"f>rt<"bottom"ilp><"clear">',
                        "paging":true,
                        "search":true,
                        "searching": false,
                        "lengthMenu": [25, 50, 100],
                        "order": [ 2, 'asc' ],
                        "preDrawCallback": function( settings ) {
                            //$('.odd').remove();
                            //$('.even').remove();
                        },
                        "oLanguage": {
                            "sEmptyTable": tableMessage
                        },
                        initComplete: function () {
                            this.api().on( 'draw', function () {
                                var table = $('#lightningDataTable').DataTable();
                                var order = table.order();
                                var sortedOrder = order[0][1];
                                var title = table.column(order[0][0]).header();
                                var sortedHeader = $("<div>").html($(title).html()).text();
                                component.set("v.sortingOrder", sortedOrder);
                                component.set("v.selectedHeader", sortedHeader);
                                if(resultSize == 0 || resultSize >= 2000){
                                    $("tr:eq(1)").remove(); 
                                }
                            });
                        }
                    });
                    $('div.dataTables_length').addClass("DTSelectLenghtStyle");
                    component.set("v.isLoading",false);
                }, 1000);
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
                        }
                    } else {
                        this.showToastMessage(component,'sticky', 'error', 'Error!', "Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    getPortDrayageRecords : function(component, event, paramValue){
        var asOfDate = paramValue.asofdate;
        var fromDate = paramValue.fromdate;
        var toDate = paramValue.todate
        var filtersParams ;
        filtersParams = 'asofdate='+asOfDate+'&fromdate='+fromDate+'&todate='+toDate;
        component.set('v.urlParamsForFilters', filtersParams);
        //const urlParams = new URLSearchParams(queryString);
        var action = component.get("c.getPortDrayageRecords");
        action.setParams({
            "asOfDate": asOfDate,
            "fromDate" : fromDate,
            "toDate": toDate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //hide the spiner
                component.set("v.isLoading", false);
                //component.set("v.judgmentRecordsList",response.getReturnValue());
                var resultSize = response.getReturnValue().length;
                component.set("v.totalPages", Math.ceil(response.getReturnValue().length/component.get("v.pageSize")));
                component.set("v.totalJudgmentRecordsSize",response.getReturnValue().length);
                component.set("v.portDrayageRecordsListForCsv", response.getReturnValue());
                var tableMessage = '';
                //lets check for the Records greater than 2000;
                if(response.getReturnValue().length >2000) { 
                    //show an validation message to reduce the records in result
                    // var errorMessage ="More than 2000 records to display – please narrow the search criteria by adding another search component to obtain a shorter list";
                    // this.showToastMessage(component,'sticky', 'error', 'Warning!', errorMessage);
                    //show the JudgmentSearch cmp
                    //component.set("v.showSearchFilters", true);
                    tableMessage = "More than 2,000 records found – please narrow your search criteria to obtain a shorter list or click the ‘Download to Excel’ button above to download result for the most recent 5,000 records.";
                    component.set("v.showPdfButtons", true);
                } else if(response.getReturnValue().length > 0){
                    component.set("v.portDrayageRecordsList", response.getReturnValue());
                    component.set("v.showPdfButtons", true);
                } else{
                    tableMessage = "No Matching Records Found";
                }
                component.set("v.currentPageNumber",1);
                setTimeout(function() {
                    $('#lightningDataTable').DataTable({
                        "ordering": true,
                        "paging":true,
                        "columnDefs": [
                            {"className": "dt-right", "targets": 5},
                            {"className": "dt-center", "targets": 6}
                        ],
                        "search":true,
                        "dom": '<"top"f>rt<"bottom"ilp><"clear">',
                        "searching": false,
                        "lengthMenu": [25, 50, 100],
                        "order": [ 1, 'asc' ],
                        "preDrawCallback": function( settings ) {
                            //$('.odd').remove();
                            //$('.even').remove();
                        },
                        "oLanguage": {
                            "sEmptyTable": tableMessage
                        },
                        initComplete: function () {
                            this.api().on( 'draw', function () {
                                var table = $('#lightningDataTable').DataTable();
                                var order = table.order();
                                var sortedOrder = order[0][1];
                                var title = table.column(order[0][0]).header();
                                var sortedHeader = $("<div>").html($(title).html()).text();
                                component.set("v.sortingOrder", sortedOrder);
                                component.set("v.selectedHeader", sortedHeader);
                                if(resultSize == 0 || resultSize >= 2000){
                                    $("tr:eq(1)").remove(); 
                                }
                            });
                        }           
                    });
                    $('div.dataTables_length').addClass("DTSelectLenghtStyle");
                    component.set("v.isLoading",false);
                }, 1000);
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
                            
                        }
                    } else {
                        this.showToastMessage(component,'sticky', 'error', 'Error!', "Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    getDownloadPdfStatus : function(component, event, helper){
        var paramValue = component.get('v.urlParamsForFilters');
        var selectedHeader = component.get("v.selectedHeader");
        var sortingOrder = component.get("v.sortingOrder");
        var paramValue = paramValue + '&selectedHeader=' + selectedHeader + '&sortingOrder=' + sortingOrder;
        if(paramValue.includes("asofdate") || paramValue.includes("fromdate") || paramValue.includes("todate")){
            var vfPageUrl = '/apex/PortDrayageSearchResultsPage?'+paramValue;
            window.open(vfPageUrl,"_blank");
        }
        else{
            var vfPageUrl = '/apex/JudgmentSearchResultPage?'+paramValue;
            window.open(vfPageUrl,"_blank");
        }
    },
    convertArrayOfJudgmentRecordToCSV : function(component,event, helper,objectRecords){
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
        keys = ['PortDrayageMotorCarrierJudgmentStatus','JudgmentName','JudgmentStatus','Court','Defendant_EmployerName','PrimaryAddress','JudgmentTotal','judgmentEntryDate','citationNumber','totalDueEmployee','totalDueState','totalDueToOthers','industryNAICS','naicsCode','dirOffice' ];
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
                if(skey == 'judgmentEntryDate'){
                    if(objectRecords[i][skey] != null){
                        var dates1 = objectRecords[i][skey].split('-');
                        csvStringResult += '"'+ dates1[1] + '/' + dates1[2] + '/' + dates1[0] +'"';
                    }
                    else{
                        csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                    }
                }
                else if(skey == 'totalDueEmployee'){
                    if(objectRecords[i][skey] != null){
                        csvStringResult += '"' + $A.localizationService.formatCurrency(objectRecords[i][skey]) +'"';
                    }
                    else{
                        csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                    }
                }
                    else if(skey == 'totalDueState'){
                        if(objectRecords[i][skey] != null){
                            csvStringResult += '"' + $A.localizationService.formatCurrency(objectRecords[i][skey]) +'"';
                        }
                        else{
                            csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                        }
                    }
                        else if(skey == 'totalDueToOthers'){
                            if(objectRecords[i][skey] != null){
                                csvStringResult += '"' + $A.localizationService.formatCurrency(objectRecords[i][skey]) +'"';
                            }
                            else{
                                csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                            }
                        }
                            else if(skey == 'JudgmentTotal'){
                                if(objectRecords[i][skey] != null){
                                    csvStringResult += '"' + $A.localizationService.formatCurrency(objectRecords[i][skey]) +'"';
                                }
                                else{
                                    csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                                }
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
        csvStringResult = csvStringResult.split('PortDrayageMotorCarrierJudgmentStatus').join('Labor Code & 2810.4');
        //csvStringResult = csvStringResult.split('ClaimantPlaintiffName').join('Claimant/Plaintiff Name');
        csvStringResult = csvStringResult.split('PrimaryAddress').join('Defendant Address');
        csvStringResult = csvStringResult.split('JudgmentName').join('Judgment Name');
        csvStringResult = csvStringResult.split('JudgmentStatus').join('Judgment Status');
        csvStringResult = csvStringResult.split('Defendant_EmployerName').join('Defendant/Employer Name');
        csvStringResult = csvStringResult.split('JudgmentTotal').join('Judgment Total');
        csvStringResult = csvStringResult.split('judgmentEntryDate').join('Judgment Entry Date');
        csvStringResult = csvStringResult.split('citationNumber').join('Citation Number');
        csvStringResult = csvStringResult.split('totalDueEmployee').join('Total Due Employee');
        csvStringResult = csvStringResult.split('totalDueState').join('Total Due State');
        csvStringResult = csvStringResult.split('totalDueToOthers').join('Total Due to Other(s)');
        csvStringResult = csvStringResult.split('industryNAICS').join('Industry (NAICS)');
        csvStringResult = csvStringResult.split('naicsCode').join('NAICS Code');
        csvStringResult = csvStringResult.split('dirOffice').join('DIR Office');
        return csvStringResult;        
    },
    convertArrayOfPortDrayageRecordToCSV : function(component,event, helper,objectRecords){
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
        keys = ['JudgmentName','Defendant_EmployerName','PrimaryAddress','asSuccessorTo','JudgmentTotal','confirmedOnListDate','confirmedOffListDate','Court','judgmentEntryDate','citationNumber','totalDueEmployee','totalDueState','totalDueToOthers','industryNAICS','naicsCode','dirOffice'];
        
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
                if(skey == 'judgmentEntryDate'){
                    if(objectRecords[i][skey] != null){
                        var dates1 = objectRecords[i][skey].split('-');
                        csvStringResult += '"'+ dates1[1] + '/' + dates1[2] + '/' + dates1[0] +'"';
                    }
                    else{
                        csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                    }
                }
                else if(skey == 'totalDueEmployee'){
                    if(objectRecords[i][skey] != null){
                        csvStringResult += '"' + $A.localizationService.formatCurrency(objectRecords[i][skey]) +'"';
                    }
                    else{
                        csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                    }
                }
                    else if(skey == 'totalDueState'){
                        if(objectRecords[i][skey] != null){
                            csvStringResult += '"' + $A.localizationService.formatCurrency(objectRecords[i][skey]) +'"';
                        }
                        else{
                            csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                        }
                    }
                        else if(skey == 'totalDueToOthers'){
                            if(objectRecords[i][skey] != null){
                                csvStringResult += '"' + $A.localizationService.formatCurrency(objectRecords[i][skey]) +'"';
                            }
                            else{
                                csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                            }
                        }
                            else if(skey == 'confirmedOnListDate'){
                                if(objectRecords[i][skey] != null){
                                    var dates1 = objectRecords[i][skey].split('-');
                                    csvStringResult += '"'+ dates1[1] + '/' + dates1[2] + '/' + dates1[0] +'"';
                                }
                                else{
                                    csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                                }
                            }
                                else if(skey == 'confirmedOffListDate'){
                                    if(objectRecords[i][skey] != null){
                                        var dates2 = objectRecords[i][skey].split('-');
                                        csvStringResult += '"'+ dates2[1] + '/' + dates2[2] + '/' + dates2[0] +'"';
                                    }
                                    else{
                                        csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                                    }
                                }
                
                                    else if(skey == 'JudgmentTotal'){
                                        if(objectRecords[i][skey] != null){
                                            csvStringResult += '"' + $A.localizationService.formatCurrency(objectRecords[i][skey]) +'"';
                                        }
                                        else{
                                            csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                                        }
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
        csvStringResult = csvStringResult.split('Invalid Date').join(' ');
        //csvStringResult = csvStringResult.split('ClaimantPlaintiffName').join('Claimant/Plaintiff Name');
        csvStringResult = csvStringResult.split('JudgmentName').join('Judgment Name');
        csvStringResult = csvStringResult.split('Defendant_EmployerName').join('Defendant/Employer Name');
        csvStringResult = csvStringResult.split('PrimaryAddress').join('Defendant Address');
        csvStringResult = csvStringResult.split('asSuccessorTo').join('As Successor To');
        csvStringResult = csvStringResult.split('JudgmentTotal').join('Judgment Total');
        csvStringResult = csvStringResult.split('judgmentEntryDate').join('Judgment Entry Date');
        csvStringResult = csvStringResult.split('citationNumber').join('Citation Number');
        csvStringResult = csvStringResult.split('totalDueEmployee').join('Total Due Employee');
        csvStringResult = csvStringResult.split('totalDueState').join('Total Due State');
        csvStringResult = csvStringResult.split('totalDueToOthers').join('Total Due to Other(s)');
        csvStringResult = csvStringResult.split('industryNAICS').join('Industry (NAICS)');
        csvStringResult = csvStringResult.split('naicsCode').join('NAICS Code');
        csvStringResult = csvStringResult.split('dirOffice').join('DIR Office');
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