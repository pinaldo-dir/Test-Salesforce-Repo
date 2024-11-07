({
    loadJudgmentMetadata : function(component, event, helper) {
        var action = component.get("c.getAllPicklist");
        var selectedCounty = component.get("v.county");
        console.log('selectedCounty :::: '+selectedCounty);
        action.setParams({ 
            selectedCounty : selectedCounty 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //hide the spiner
            component.set("v.isLoading", false);
            if (state === "SUCCESS") {
                var judgmentStatusOptions = [];
                var listStatusOptions = [];
                var dirOfficeOptions = [];
                var countyOptions = [];
                var courtHouseOptions = [];
                var courtHouseList = [];
                var results = response.getReturnValue();
                var listStatusPicklist = results.listStatus;
                var courtHouseMap = results.courtHouseMap;
                var judgmentStatusPicklist = results.judgmentStatusPicklist;
                var dirOfficePicklist = results.dirOffice;
                var countyPicklist = results.countyList;
                
                listStatusOptions.push({class: "optionClass",label: "--- Select one ---",value: ""});
                for(var i=0;i<listStatusPicklist.length;i++){
                    listStatusOptions.push({class: "optionClass",label:listStatusPicklist[i],value:listStatusPicklist[i]})
                }
                component.set("v.listStatusPicklistValues",listStatusOptions);
                
                courtHouseOptions.push({class: "optionClass",label: "--- Select one ---",value: ""});
                for(var i=0;i<courtHouseMap.length;i++){
                    courtHouseOptions.push({class: "optionClass",label:courtHouseMap[i],value:courtHouseMap[i]})
                }
                component.set("v.courtHousePicklistValues",courtHouseOptions);
                
                //judgmentStatusOptions.push({class: "optionClass",label: "--- Select one ---",value: ""});
                for(var i=0;i<judgmentStatusPicklist.length;i++){
                    judgmentStatusOptions.push({class: "optionClass",label:judgmentStatusPicklist[i],value:judgmentStatusPicklist[i]})
                }
                component.set("v.judgmentStatusPicklistValues",judgmentStatusOptions);
                
                dirOfficeOptions.push({class: "optionClass",label: "--- Select one ---",value: "",selected: false});
                for(var i=0;i<dirOfficePicklist.length;i++){
                    dirOfficeOptions.push({class: "optionClass",label:dirOfficePicklist[i],value:dirOfficePicklist[i],selected: false})
                }
                component.set("v.dirOfficePicklistValues",dirOfficeOptions);
                
                countyOptions.push({class: "optionClass",label: "--- Select one ---",value: "",selected: false});
                for(var i=0;i<countyPicklist.length;i++){
                    countyOptions.push({class: "optionClass",label:countyPicklist[i],value:countyPicklist[i],selected: false})
                }
                component.set("v.countyPicklistValues",countyOptions);
                //load the History data back into search filter...
                this.getFieldValuesFromUrl(component, event); 
            }
        });
        $A.enqueueAction(action);
        
        //check for the Existing filters:
        this.getURLparams(component, event);
    },
    searchHelper : function(component,event,getInputkeyWord) {
        var action = component.get("c.fetchLookUpValues");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName")
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
    searchJudgment : function(component,event) {
        console.log('::::::: '+component.get("v.naicsCodeTitle"));
        console.log('judgmnentStatus ::: '+component.get("v.selectedJudgmentStatusOptions"));
        //check if the ListStatus is selected
        /*var inputStatusCmp = component.find("listStatus");
        if(liststatus === '') {
            //hide the spiner
            component.set("v.isLoading", false);
            inputStatusCmp.set("v.errors", [{message:"List Status field is required."}]);
            inputStatusCmp.focus();
            return;
        }*/
        var inputCmp = component.find("judgmentEntryToDate");
        var judgmentEntryDateFrom = component.get("v.judgmentEntryDateFrom");
        var judgmentEntryDateTo = component.get("v.judgmentEntryDateTo");
        if(judgmentEntryDateFrom != null){
            if(judgmentEntryDateTo == null || judgmentEntryDateTo == "" || judgmentEntryDateTo == undefined){
                judgmentEntryDateTo = component.get("v.currentListAsOfDate");
            }
        }
        // is input valid text?
        if (judgmentEntryDateFrom > judgmentEntryDateTo) {
            //hide the spiner
            component.set("v.isLoading", false);
            inputCmp.setCustomValidity("To Date is less than From Date.");
            inputCmp.reportValidity(); 
            return;  
        }
        // Tells lightning:input to show the error right away without needing interaction
        /* var judgmentEntryDateFrom = component.get("v.judgmentEntryDateFrom");
        var judgmentEntryDateTo = component.get("v.judgmentEntryDateTo");
        if(judgmentEntryDateFrom > judgmentEntryDateTo){
            //hide the spinner
            component.set("v.isLoading", false);
            //component.set("v.dateValidationError" , true);
            var judgmentEntryFromDateCmp = component.find("judgmentEntryFromDate")
            judgmentEntryFromDateCmp.set("v.errors", [{message:"From Date is greater than To Date..."}]);
            return;
        }
        else{
            component.set("v.dateValidationError" , false);
        } */
        var judgmentTotalFromId = component.find("judgmentTotalFrom");
        var judgmentTotalTo = component.get("v.judgmentTotalTo");
        var judgmentTotalFrom = component.get("v.judgmentTotalFrom");
        if(judgmentTotalFrom > judgmentTotalTo){
            //hide the spinner
            component.set("v.isLoading", false);
            judgmentTotalFromId.set("v.errors", [{message:"From value is greater than To value..."}]);
            judgmentTotalFromId.focus();
            return;
        }
        var judgmentEntryDateFrom = new Date();
        //judgmentEntryDateTo = new Date();
        var naicsCode = component.get("v.naicsCode") || '';
        var naicsCodeId = component.get("v.selectedLookUpRecordForNaicsCode").id  || '';
        var accountName = component.get("v.accountName")  || '';
        var city = component.get("v.city") || '';
        var zipCode = component.get("v.zipCode") || '';
        judgmentEntryDateFrom = component.get("v.judgmentEntryDateFrom") || '';
        judgmentEntryDateTo = component.get("v.judgmentEntryDateTo") || '';
        var court = component.get("v.court") || '';
        var courtId = component.get("v.selectedLookUpRecordForCourt").id || '';
        var judgmentStatus = component.get("v.selectedJudgmentStatusOptions") || '';
        var defandantEmployerName = component.get("v.defandantEmployerName") || '';
        var judgmentTotalFrom = component.get("v.judgmentTotalFrom") || '';
        var judgmentTotalTo = component.get("v.judgmentTotalTo") || '';
        var citationNumber = component.get("v.selectedLookUpRecordForCitationNumber").label || '';
        var citationNumberId = component.get("v.selectedLookUpRecordForCitationNumber").id || '';
        var dirOffice = component.get("v.selectedLookUpRecordForOfficeName").label || '';
        var dirOfficeId = component.get("v.selectedLookUpRecordForOfficeName").id || '';
        
        var naicsCodeTitle = component.get("v.naicsCodeTitle") || '';
        var county = component.get("v.county") || '';
        
        console.log('naicsCode:::: '+component.get("v.selectedLookUpRecordForNaicsCode").label);
        console.log('accountName:::: '+component.get("v.accountName"));
        console.log('city:::: '+component.get("v.city"));
        console.log('zipCode:::: '+component.get("v.zipCode"));
        console.log('judgmentEntryDate:::: '+component.get("v.judgmentEntryDate"));
        console.log('court:::: '+component.get("v.court"));
        console.log('judgmentStatus:::: '+component.get("v.judgmentStatus"));
        console.log('defandantEmployerName:::: '+component.get("v.defandantEmployerName"));
        console.log('judgmentTotalFrom:::: '+component.get("v.judgmentTotalFrom"));
        console.log('citationNumber:::: '+component.get("v.selectedLookUpRecordForCitationNumber").label);
        console.log('dirOffice:::: '+component.get("v.dirOffice"));
        if(naicsCode.length == 0 && naicsCodeId.length == 0 && accountName.length == 0 && city.length == 0 && zipCode.length == 0 
           && courtId.length == 0 && (judgmentStatus == '' || judgmentStatus.length == 0) && defandantEmployerName.length == 0 && citationNumberId.length == 0 
           && dirOffice.length == 0 && dirOfficeId.length == 0 && judgmentTotalTo == 0 && county.length == 0 && judgmentEntryDateTo.length == 0 && judgmentEntryDateFrom.length == 0){
            console.log(defandantEmployerName.length);
            
            //alert('select atleast one filter criteria from Judgment Search !');
            component.set("v.isLoading", false);
            component.set("v.errorMsg", true);
            return null;
        }
        console.log(defandantEmployerName.length);
        /*For Refresh 
        //Hide the JudgmentSearch Cmp
        component.set("v.showSearchFilters", false);
        //Get the event using event name. 
        var appEvent = $A.get("e.c:JudgmentRecordsRetrieve"); 
        //Set event attribute value
        appEvent.setParams({
            "listStatus2810" : liststatus,
            "naicsCode" : naicsCode,
            "accountName" : accountName,
            "city" : city,
            "zipCode" : zipCode,
            "judgmentEntryDateFrom" : judgmentEntryDateFrom,
            "judgmentEntryDateTo" : judgmentEntryDateTo,
            "judgmentStatus" : judgmentStatus,
            "defandantEmployerName" : defandantEmployerName,
            "judgmentTotal" : judgmentTotal,
            "citationNumber" : citationNumber,
            "dirOffice" : dirOffice
        }); 
        appEvent.fire();
        for Refresh */
        var param = '';
        
        if(naicsCode != null){
            param += '&naics='+naicsCode;
        }
        if(accountName != null){
            param += '&accountName='+accountName;
        }
        if(city != null){
            param += '&city='+city;
        }
        if(zipCode != null){
            param += '&zipCode='+zipCode;
        }
        if(judgmentEntryDateFrom != null){
            param += '&judgmentdatefrom='+judgmentEntryDateFrom;
        }
        if(judgmentEntryDateTo != null){
            param += '&judgmentdateto='+judgmentEntryDateTo;
        }
        if(court != null){
            param += '&court='+court;
        }
        if(judgmentStatus != null){
            param += '&judgmentstatus='+judgmentStatus;
        }
        if(defandantEmployerName != null){
            param += '&defandantemployer='+defandantEmployerName;
        }
        if(judgmentTotalFrom != null){
            param += '&judgmentTotalFrom='+judgmentTotalFrom;
        }
        if(judgmentTotalTo != null){
            param += '&judgmentTotalTo='+judgmentTotalTo;
        }
        if(citationNumber != null){
            param += '&citationnumber='+citationNumber;
        }
        if(dirOffice != null){
            param += '&diroffice='+dirOffice;
        }
        if(dirOfficeId != null){
            param += '&dirOfficeId='+dirOfficeId;
        }
        if(naicsCodeId != null){
            param += '&naicsCodeId='+naicsCodeId; 
        }
        if(courtId != null){
            param += '&courtId='+courtId;
        }
        if(citationNumberId != null){
            param += '&citationNumberId='+citationNumberId;
        }
        if(county != null){
            param += '&county='+county;
        }
        if(naicsCodeTitle != null){
            param += '&naicsCodeTitle='+naicsCodeTitle;
        }
        console.log('citationNumberId:::: '+citationNumberId);
        
        var url = "/s/judgmentsearchresult?searchtype=judgmentsearch"+param;
        window.open(url,'_self');
    },
    clearAllfields : function(component,event) {
        var picklistValues = component.get("v.listStatusPicklistValues");
        component.set("v.listStatusPicklistValues","");
        component.set("v.listStatusPicklistValues",picklistValues);
        var picklistValues = component.get("v.judgmentStatusPicklistValues");
        component.set("v.judgmentStatusPicklistValues","");
        component.set("v.judgmentStatusPicklistValues",picklistValues);
        var picklistValues = component.get("v.dirOfficePicklistValues");
        component.set("v.dirOfficePicklistValues","");
        component.set("v.dirOfficePicklistValues",picklistValues);
        
        component.set("v.listStatus2810","");
        component.set("v.selectedLookUpRecordForNaicsCode","");
        component.set("v.naicsCodeTitle","");
        component.set("v.naicsCode","");
        component.set("v.selectedRecord.Name","");
        component.set("v.accountName","");
        component.set("v.city","");
        component.set("v.county","");
        component.set("v.court","");
        //component.set("v.county",component.find("county").get("v.value"))
        component.set("v.judgmentTotalFrom","");
        component.set("v.judgmentTotalTo","");
        component.set("v.zipCode","");
        component.set("v.judgmentEntryDateFrom","");
        component.set("v.judgmentEntryDateTo","");
        component.set("v.selectedLookUpRecordForCourt","");
        component.set("v.selectedLookUpRecordForCourt","");
        component.set("v.selectedJudgmentStatusOptions","");
        component.set("v.defandantEmployerName","");
        component.set("v.judgmentTotal","");
        component.set("v.citationNumber","");
        component.set("v.selectedLookUpRecordForCourt","");
        component.set("v.clearPills", false);
        this.clearLookupValues(component,event);
    },
    
    getFieldValuesFromUrl : function (component, event)
    {
        try{
            var querystring = location.search.substr(1);
            var paramValue = {};
            
            querystring.split("&").forEach(function(part) {
                var param = part.split("=");
                paramValue[param[0]] = decodeURIComponent(param[1]);
                console.log(param[0] + '===' + decodeURIComponent(param[1]));
            });
            
            if(paramValue.liststatus != null){
                component.set("v.listStatus2810", paramValue.liststatus.split('+').join(' '));
                component.find("listStatus").set("v.value", paramValue.liststatus.split('+').join(' '));
            }
            
            if(paramValue.naics != null && paramValue.naics.length > 0){
                component.set("v.naicsCode", paramValue.naics.split('+').join(' '));
            }
            
            if(paramValue.naicsCodeId != null && paramValue.naicsCodeId.length > 0){
                var naicsCmp = component.find("naicsCmp");
                naicsCmp.getLookupValueById(paramValue.naicsCodeId);
            }
            
            if(paramValue.accountName != null){
                component.set("v.accountName", paramValue.accountName.split('+').join(' '));
            }
            
            if(paramValue.city != null){
                component.set("v.city", paramValue.city.split('+').join(' '));
            }
            
            if(paramValue.zipCode != null){
                component.set("v.zipCode", paramValue.zipCode.split('+').join(' '));
            }
            
            if(paramValue.judgmentdatefrom != null && paramValue.judgmentdatefrom.length > 0 && paramValue.judgmentdatefrom != 'undefined'  && paramValue.judgmentdatefrom != 'null'){
                var dateForm = paramValue.judgmentdatefrom.split('+').join(' ') || null;
                var judgmentdatefrom = (dateForm != null) ? new Date(dateForm) : null;
                component.set("v.judgmentEntryDateFrom", this.prepareDate(judgmentdatefrom));
            }
            
            if(paramValue.judgmentdateto !=null && paramValue.judgmentdateto.length > 0 && paramValue.judgmentdateto != 'undefined' && paramValue.judgmentdateto != 'null'){
                console.log('==>'+ paramValue.judgmentdateto);
                var dateTo = paramValue.judgmentdateto.split('+').join(' ') || null;
                var judgmentdateto = (dateTo != null) ?  new Date(dateTo) : null;
                component.set("v.judgmentEntryDateTo", this.prepareDate(judgmentdateto));
            }
            
            if(paramValue.asofdate !=null && paramValue.asofdate.length > 0 && paramValue.asofdate != 'undefined'){
                var asofdate = paramValue.asofdate.split('+').join(' ') || null;
                var asofdateValue = (asofdate != null) ?  new Date(asofdate) : null;
                component.set("v.currentListAsOfDate", this.prepareDate(asofdateValue));
                component.set("v.currentListAsOfDateLabel", this.prepareDateLabel(asofdateValue));
            }
            
            if(paramValue.county != null){
                //component.set("v.county", paramValue.county.split('+').join(' '));
                component.find("county").set("v.value", paramValue.county.split('+').join(' '));
                var court = '';
                if(paramValue.court != null){
                    //component.set("v.court", paramValue.court.split('+').join(' '));
                    console.log('court url ::: '+paramValue.court.split('+').join(' '));
                    court =  paramValue.court.split('+').join(' ');
                    
                }
                this.getCountyChangeResult(component, event, court);
                //component.find("court").set("v.value", paramValue.court.split('+').join(' '));
            }
            
            
            
            
            if(paramValue.courtId != null){
                var courtCmp = component.find("courtCmp");
                if(paramValue.courtId){
                    courtCmp.getLookupValueById(paramValue.courtId);     
                }
            }
             if(paramValue.dirOfficeId != null && paramValue.dirOfficeId.length > 0){
                var dirOffice = component.find("dirOffice");
                dirOffice.getLookupValueById(paramValue.dirOfficeId);
            }
            
            if(paramValue.judgmentstatus != null){
                console.log('statusList::'+paramValue.judgmentstatus.split('+').join(' '));
                var statusList = paramValue.judgmentstatus.split('+').join(' ');
                var resStatusList = statusList.split(',');
                console.log('resStatusList::'+resStatusList);
                component.set("v.selectedJudgmentStatusOptions",resStatusList);
                component.find("judgmentStatus").set("v.value", resStatusList);
            }
            
            if(paramValue.defandantemployer != null){
                component.set("v.defandantEmployerName", paramValue.defandantemployer.split('+').join(' '));
            }
            
            if(paramValue.judgmentTotalFrom != null){
                component.set("v.judgmentTotalFrom", paramValue.judgmentTotalFrom.split('+').join(' '));
            }
            
            if(paramValue.judgmentTotalTo != null){
                component.set("v.judgmentTotalTo", paramValue.judgmentTotalTo.split('+').join(' '));
            }
            
            if(paramValue.citationnumber != null){
                component.set("v.citationNumber", paramValue.citationnumber.split('+').join(' '));
            }
            
            if(paramValue.citationnumberId != null){
                var citationNumber = component.find("citationNumber");
                if(paramValue.citationnumberId){
                    citationNumber.getLookupValueById(paramValue.citationnumberId);    
                }
            }
            
            /*if(paramValue.diroffice != null){
                
                component.set("v.selectedLookUpRecordForCourt", paramValue.diroffice.split('+').join(' '));
               // component.find("dirOffice").set("v.value", paramValue.diroffice.split('+').join(' '));
            }*/
            if(paramValue.naicsCodeTitle != null){
                component.set("v.naicsCodeTitle", paramValue.naicsCodeTitle.split('+').join(' '));
            }
            
            if(paramValue.county != null){
                component.set("v.county", paramValue.county.split('+').join(' '));
            }
            if(paramValue.fromdate !=null && paramValue.fromdate.length > 0 && paramValue.fromdate != 'undefined'){
                var fromDate = paramValue.fromdate.split('+').join(' ') || null;
                var fromDate = (fromDate != null) ?  new Date(fromDate) : null;
                component.set("v.previousListFromDate", this.prepareDate(fromDate));
            }
            if(paramValue.todate !=null && paramValue.todate.length > 0 && paramValue.todate != 'undefined'){
                var toDate = paramValue.todate.split('+').join(' ') || null;
                var toDate = (toDate != null) ?  new Date(toDate) : null;
                component.set("v.previousListToDate", this.prepareDate(toDate));
            }
            
        }catch(excp){
            console.log(excp);
        }
        
        window.history.pushState('',document.title,'/s');  
    },
    
    checkRedirectingFromSearchResult : function(component,event) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        
        //Split by & so that you get the key value pairs separately in a list
        var sURLVariables = sPageURL.split('&'); 
        var sParameterName;
        var idx;
        
        for (idx = 0; idx < sURLVariables.length; idx++) 
        {
            sParameterName = sURLVariables[idx].split('='); 
            if(sParameterName[0] === 'isRedirectingFromSearchResult'){
                return sParameterName[1];
            }
        }
        return false;
    },
    
    clearLookupValues : function(component,event) {
        
        //clear Dir Office lookup 
        var dirOffice = component.find("dirOffice");
        dirOffice.clearLookupPill();
        /*
        //clear Court lookup 
        var courtCmp = component.find("courtCmp");
        courtCmp.clearLookupPill();
        */
        //clear Citation Number Lookup
        var citatioNumberCmp = component.find("citationNumber");
        citatioNumberCmp.clearLookupPill();
    },
    getURLparams: function(component, event) {
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
        var judgmenttotal;
        var citationnumber;
        var diroffice;
        var fromDate;
        var toDate;
        //const queryString = window.location.search;
        var querystring = location.search.substr(1);
        console.log('querystring::'+querystring);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        console.log('paramValue:: '+JSON.stringify(paramValue));
        if(paramValue.liststatus != null){
            liststatus = paramValue.liststatus.split('+').join(' ');
        }
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
            judgmentdatefrom = (dateForm != null) ? Date.valueOf(dateForm) : null;
        }
        if(paramValue.judgmentdateto !=null){
            var dateTo = paramValue.judgmentdateto.split('+').join(' ') || null;
            judgmentdateto = (dateTo != null) ? Date.valueOf(dateTo) : null;
        }
        if(paramValue.court != null){
            court = paramValue.court.split('+').join(' ');
        }
        if(paramValue.judgmentstatus != null){
            judgmentstatus = paramValue.judgmentstatus.split('+').join(' ');
        }
        if(paramValue.defandantemployer != null){
            defandantemployer = paramValue.defandantemployer.split('+').join(' ');
        }
        if(paramValue.judgmenttotal != null){
            var totalAmount = paramValue.judgmenttotal.split('+').join(' ') || null;
            judgmenttotal = (totalAmount != null) ? parseFloat(totalAmount) : null;
        }
        if(paramValue.citationnumber != null){
            citationnumber = paramValue.citationnumber.split('+').join(' ');
        }
        if(paramValue.diroffice != null){
            diroffice = paramValue.diroffice.split('+').join(' ');
        }
        if(paramValue.citationNumberId != null){ 
        }
        if(paramValue.fromdate != null){
            var dateForm = paramValue.fromdate.split('+').join(' ') || null;
            fromDate = (dateForm != null) ? Date.valueOf(dateForm) : null;
        }
        if(paramValue.todate != null){
            var dateForm = paramValue.todate.split('+').join(' ') || null;
            toDate = (dateForm != null) ? Date.valueOf(dateForm) : null;
        }
    },
    validateEntryDate: function(component, event) {
        //get 
    },
    searchPortDrayage: function(component, event) { 
        //check for the required Date
        var asOfDateCmp = component.find("currentListAsOfDate");
        var currentListAsOfDate = component.get("v.currentListAsOfDate") || '';
        // is input valid text?
        if (currentListAsOfDate == '') {
            //hide the spiner
            component.set("v.isLoading", false);
            asOfDateCmp.setCustomValidity("As of Date is required...");
            asOfDateCmp.reportValidity(); 
            return;  
        }
        
        var url = "/s/judgmentsearchresult?searchtype=portdrayage&asofdate="+currentListAsOfDate;
        window.open(url,'_self');
        console.log('after ::'+currentListAsOfDate);
    },
    prepareDateLabel : function(processingDate){
        //add the TimeZone offset if the User TimeZone is behind the GMT.
        if(new Date().getTimezoneOffset() > 0) {
            processingDate = new Date(new Date(processingDate).getTime() + (new Date().getTimezoneOffset()+30) *60*1000);
        }
        var dd = processingDate.getDate();
        var mm = processingDate.getMonth()+1; 
        var yyyy = processingDate.getFullYear();
        
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        
        if(mm<10) 
        {
            mm='0'+mm;
        } 
        return (mm+'/'+dd+'/'+yyyy);
    },
    prepareDateLabel : function(processingDate){
        
        var dd = processingDate.getDate();
        var mm = processingDate.getMonth()+1; 
        var yyyy = processingDate.getFullYear();
        
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        
        if(mm<10) 
        {
            mm='0'+mm;
        } 
        return (mm+'/'+dd+'/'+yyyy);
    },
    prepareDate : function(processingDate){
        //add the TimeZone offset if the User TimeZone is behind the GMT.
        if(new Date().getTimezoneOffset() > 0) {
            processingDate = new Date(new Date(processingDate).getTime() + (new Date().getTimezoneOffset()+30) *60*1000);
        }
        var dd = processingDate.getDate();
        var mm = processingDate.getMonth()+1; 
        var yyyy = processingDate.getFullYear();
        
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        
        if(mm<10) 
        {
            mm='0'+mm;
        } 
        return (yyyy+'-'+mm+'-'+dd);
    },
    prepareAsOfDate : function(processingDate){
        
        var dd = processingDate.getDate();
        var mm = processingDate.getMonth()+1; 
        var yyyy = processingDate.getFullYear();
        
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        
        if(mm<10) 
        {
            mm='0'+mm;
        } 
        return (yyyy+'-'+mm+'-'+dd);
    },
    searchPreviousList : function(component, event){
        var inputCmp = component.find("previousListFromDate");
        var previousListFromDate = component.get("v.previousListFromDate") || '';
        var previousListToDate = component.get("v.previousListToDate") || '';
        var toDateinputCmp = component.find("previousListToDate");
        
        var isError = false;
        
        
        
        if(previousListFromDate == ''){
            
            this.addError(inputCmp, "Please select the From Date.", component);
            isError = true;
            
        }
        
        if(previousListToDate == ''){
            
            this.addError(toDateinputCmp, "Please select the To Date.", component);
            isError = true;
        }
        
        if(isError){
            return;
        }else{
            inputCmp.setCustomValidity('');
            toDateinputCmp.setCustomValidity('');
        }
        
        // is input valid text?
        if (previousListFromDate > previousListToDate) {
            
            this.addError(inputCmp, "From Date is greater than To Date...", component);
            return;
        }
        
        
        var url = "/s/judgmentsearchresult?searchtype=portdrayage&fromdate="+previousListFromDate+"&todate="+previousListToDate;
        window.open(url,'_self');
    },
    
    addError : function(inputComp, errorMessage, component){
        component.set("v.isLoading", false);
        inputComp.setCustomValidity(errorMessage);
        inputComp.reportValidity(); 
    },
    
    getCountyChangeResult : function(component, event, court){
        var selectedCounty = component.get("v.county");
        var action = component.get("c.getCourtHouse");
        action.setParams({ 
            selectedCounty : selectedCounty 
        });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var courtHouseOptions = [];
                var result = response.getReturnValue();
                courtHouseOptions.push({class: "optionClass",label: "--- Select one ---",value: ""});
                for(var i=0;i<result.length;i++){
                    courtHouseOptions.push({class: "optionClass",label:result[i],value:result[i]})
                }
                component.set("v.courtHousePicklistValues",courtHouseOptions);
                if(court != '') {
                    component.find("court").set("v.value", court);
                }
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    placeHolderDatePrepare : function(processingDate){
        //add the TimeZone offset if the User TimeZone is behind the GMT.
        if(new Date().getTimezoneOffset() > 0) {
            processingDate = new Date(new Date(processingDate).getTime() + (new Date().getTimezoneOffset()+30) *60*1000);
        }
        var dd = processingDate.getDate();
        var mm = processingDate.getMonth()+1; 
        var yyyy = processingDate.getFullYear();
        
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        
        if(mm<10) 
        {
            mm='0'+mm;
        } 
        return (mm+'/'+dd+'/'+yyyy);
    },
    placeHolderDatePrepare : function(processingDate){
        
        var dd = processingDate.getDate();
        var mm = processingDate.getMonth()+1; 
        var yyyy = processingDate.getFullYear();
        
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        
        if(mm<10) 
        {
            mm='0'+mm;
        } 
        return (mm+'/'+dd+'/'+yyyy);
    }
})