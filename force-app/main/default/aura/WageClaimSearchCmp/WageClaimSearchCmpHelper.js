({
    wageClaimMetadata : function(component, event){
        var action = component.get("c.getAllPicklist");
        /*action.setParams({ 
            selectedCounty : selectedCounty 
        });*/
        action.setCallback(this, function(response) {
            var state = response.getState();
            //hide the spiner
            component.set("v.isLoading", false);
            if (state === "SUCCESS") {
                
                var dirOfficeOptions = [];
                var lowWageOptions = [];
                var results = response.getReturnValue();
                
                var dirOfficePicklist = results.dirOffice;
                var lowWagePicklist = results.lowWage;
                console.log('appliesOptions:::: '+dirOfficePicklist.length);
                console.log('appliesOptions:::: '+JSON.stringify(lowWagePicklist));
                
                dirOfficeOptions.push({class: "optionClass",label: "--- Select one ---",value: "",selected: false});
                for(var i=0;i<dirOfficePicklist.length;i++){
                    dirOfficeOptions.push({class: "optionClass",label:dirOfficePicklist[i],value:dirOfficePicklist[i],selected: false})
                }
                component.set("v.dirOfficePicklistValues",dirOfficeOptions);
                
                lowWageOptions.push({class: "optionClass",label: "--- Select one ---",value: "",selected: false});
                for(var i=0; i<lowWagePicklist.length;i++){
                    lowWageOptions.push({class: "optionClass",label:lowWagePicklist[i],value:lowWagePicklist[i],selected: false})
                }
                
                component.set("v.lowWagePicklistValues",lowWageOptions);
                //load the History data back into search filter...
                this.getFieldValuesFromUrl(component, event); 
            }
        });
        $A.enqueueAction(action);
        
    },
    searchWageClaim : function(component, event){
        var docketFromDate = new Date();
        var docketToDate = new Date();
        var caseclosedfromdate = new Date();
        var caseclosedtodate = new Date();
        var accountName = component.get("v.accountName") || '';
        var caseNumber = component.get("v.caseNumber") || '';
        docketFromDate = component.find("docketDateFrom").get("v.value") || '';
        docketToDate = component.find("docketDateTo").get("v.value") || '';
        caseclosedfromdate = component.find("caseCloseDateFrom").get("v.value") || '';
        caseclosedtodate = component.find("caseCloseDateTo").get("v.value") || '';
        var naicsCode = component.get("v.naicsCode") || '';
        var naicsCodeId = component.get("v.selectedLookUpRecordForNaicsCode").id || '';
        var NAICSIndustry = component.get("v.NAICSIndustry") || '';
        var dirOffice = component.get("v.selectedLookUpRecordForOfficeName").label || '';
        var dirOfficeId = component.get("v.selectedLookUpRecordForOfficeName").id || '';
        var naicsCodeTitle = component.get("v.naicsCodeTitle") || '';
        var caseLowWage = component.find("lowwage").get("v.value") || '';
        console.log('caseclosedfromdate ::: '+caseclosedfromdate);
        console.log('caseclosedtodate ::: '+caseclosedtodate);
        console.log('accountName ::: '+accountName);
        console.log('caseNumber ::: '+caseNumber);
        console.log('docketFromDate ::: '+docketFromDate);
        console.log('docketToDate ::: '+docketToDate);
        console.log('NAICSIndustry ::: '+NAICSIndustry);
        console.log('dirOffice ::: '+dirOffice);
        console.log('caseLowWage ::: '+caseLowWage);
        console.log('naicsCodeTitle ::: '+naicsCodeTitle);
        var inputCmp = component.find("docketDateTo");
        if(docketFromDate != ""){
            if(docketToDate == null || docketToDate == "" || docketToDate == undefined){
                docketToDate = component.get("v.today");
            }
        }
        if(caseclosedfromdate != ""){
            if(caseclosedtodate == null || caseclosedtodate == "" || caseclosedtodate == undefined){
                caseclosedtodate = component.get("v.today");
            }
        }
        if(docketFromDate > docketToDate){
            //hide the spinner
            component.set("v.isLoading", false);
            inputCmp.setCustomValidity("To Date is less than From Date.");
            inputCmp.reportValidity(); 
            return;  
        }
        var inputCmp = component.find("caseCloseDateTo");
        if(caseclosedfromdate > caseclosedtodate){
            //hide the spinner
            component.set("v.isLoading", false);
            inputCmp.setCustomValidity("To Date is less than From Date.");
            inputCmp.reportValidity(); 
            return; 
        }
        
        console.log('naicsCode name:::'+component.get("v.selectedLookUpRecordForNaicsCode").label);
        console.log('naicsCode:::'+JSON.stringify(component.get("v.selectedLookUpRecordForNaicsCode")));
        if(accountName.length == 0 && dirOfficeId.length == 0 && caseLowWage.length == 0 && dirOffice.length == 0 && caseNumber.length == 0 && docketFromDate.length == 0 && docketToDate.length == 0 && naicsCode.length == 0 && caseLowWage.length == 0 && caseclosedfromdate.length == 0 && caseclosedtodate.length == 0){
            component.set("v.isLoading", false);
            component.set("v.errorMsg", true);
            return null;
            
        }
        var param = '';
        
        if(naicsCode != null){
            param += '&naics='+naicsCode;
        }
        if(naicsCodeTitle != null){
            param += '&naicsCodeTitle='+naicsCodeTitle;
        }
        if(accountName != null){
            param += '&accountName='+accountName;
        }
        if(docketFromDate != null){
            param += '&docketfromdate='+docketFromDate;
        }
        if(docketToDate != null){
            param += '&dockertodate='+docketToDate;
        }
        if(caseclosedfromdate != null){
            param += '&caseclosedfromdate='+caseclosedfromdate;
        }
        if(caseclosedtodate != null){
            param += '&caseclosedtodate='+caseclosedtodate;
        }
        if(dirOffice != null){
            param += '&diroffice='+dirOffice;
        }
        if(dirOfficeId != null){
            param += '&dirOfficeId='+dirOfficeId;
        }
        if(caseLowWage != null){
            param += '&caselowwage='+caseLowWage; 
        }
        if(caseNumber != null){
            param += '&casenumber='+caseNumber;
        }
        if(naicsCodeId != null){
            param += '&naicsCodeId='+naicsCodeId;
        }
        console.log('naicsCode:::'+param);
        console.log('naicsCode:::'+naicsCode);
        var url = "/wcsearch/s/wageclaimsearchresult?searchtype=wagesearch"+param;
        window.open(url,'_self');
        
    },
    clearAllFields : function(component, event) {
        component.set("v.accountName", "");
        component.set("v.caseNumber", "");
        component.set("v.naicsCode", "");
        component.set("v.docketFromDate", "");
        component.set("v.docketToDate", "");
        component.set("v.caseClosedFromDate", "");
        component.set("v.caseClosedToDate", "");
        component.set("v.naicsCodeTitle", "");
        component.set("v.dirOffice", "");
        component.set("v.caseLowWage", "");
        component.find("lowwage").set("v.value", "");
        this.clearLookupValues(component, event);
    },
    clearLookupValues : function(component, event){
        var dirOffice = component.find("dirOffice");
        dirOffice.clearLookupPill();
    },
    getFieldValuesFromUrl : function(component, event){
        try{
            var accountName;
            var caseNumber;
            var fromDate;
            var toDate;
            var naicsCode;
            var lowWage;
            var dirOffice;
            var naicsCodeId;
            //const queryString = window.location.search;
            var querystring = location.search.substr(1);
            console.log('querystring::'+querystring);
            var paramValue = {};
            querystring.split("&").forEach(function(part) {
                var param = part.split("=");
                paramValue[param[0]] = decodeURIComponent(param[1]);
            });
            console.log('paramValueget:: '+JSON.stringify(paramValue));
            if(paramValue.dirOffice != null){
                dirOffice = paramValue.dirOffice.split('+').join(' ');
                component.set("v.dirOffice", dirOffice);
                component.find("dirOffice").set("v.value", dirOffice);
            }
            if(paramValue.accountName != null){
                accountName = paramValue.accountName.split('+').join(' ');
                component.set("v.accountName", accountName);
            }
            if(paramValue.dirOfficeId != null && paramValue.dirOfficeId.length > 0){
                var dirOffice = component.find("dirOffice");
                dirOffice.getLookupValueById(paramValue.dirOfficeId);
            }
            if(paramValue.caseNumber != null && paramValue.caseNumber != 'undefined'){
                caseNumber = paramValue.caseNumber.split('+').join(' ') || null;
                component.set("v.caseNumber", caseNumber);
            }
            if(paramValue.lowWage != null){
                lowWage = paramValue.lowWage.split('+').join(' ');
                component.find("lowwage").set("v.value", paramValue.lowWage.split('+').join(' '));
            }
            if(paramValue.naicsCodeTitle != null && paramValue.naicsCodeTitle != 'null'){
                console.log('naicsTitleCode ::::: '+paramValue.naicsCodeTitle.split('+').join(' '));
                component.set("v.naicsCodeTitle", paramValue.naicsCodeTitle.split('+').join(' '));
            }
            if(paramValue.naicsCode != null && paramValue.naicsCode.length > 0){
                component.set("v.naicsCode", paramValue.naicsCode.split('+').join(' '));
            }
            console.log('fromDate :: '+paramValue.fromDate.split('+').join(' '));
            console.log('toDate :: '+paramValue.toDate.split('+').join(' '));
            if(paramValue.fromDate != 'null' && paramValue.fromDate.length > 0 && paramValue.fromDate != 'undefined'){
                var fromDate = paramValue.fromDate.split('+').join(' ') || null;
                var fromDate = (fromDate != null) ?  new Date(fromDate) : null;
                component.set("v.docketFromDate", this.prepareDate(fromDate));
            }
            if(paramValue.toDate != 'null' && paramValue.toDate.length > 0 && paramValue.toDate != 'undefined'){
                var toDate = paramValue.toDate.split('+').join(' ') || null;
                var toDate = (toDate != null) ?  new Date(toDate) : null;
                component.set("v.docketToDate", this.prepareDate(toDate));
            }
            if(paramValue.caseclosedfromdate != 'null' && paramValue.caseclosedfromdate.length > 0 && paramValue.caseclosedfromdate != 'undefined'){
                var caseclosedfromdate = paramValue.caseclosedfromdate.split('+').join(' ') || null;
                var caseclosedfromdate = (caseclosedfromdate != null) ?  new Date(caseclosedfromdate) : null;
                component.set("v.caseClosedFromDate", this.prepareDate(caseclosedfromdate));
            }
            if(paramValue.caseclosedtodate != 'null' && paramValue.caseclosedtodate.length > 0 && paramValue.caseclosedtodate != 'undefined'){
                var caseclosedtodate = paramValue.caseclosedtodate.split('+').join(' ') || null;
                var caseclosedtodate = (caseclosedtodate != null) ?  new Date(caseclosedtodate) : null;
                component.set("v.caseClosedToDate", this.prepareDate(caseclosedtodate));
            }
            if(paramValue.naicsCode != null){
                naicsCode = paramValue.naicsCode.split('+').join(' ');
            }
        }
        catch(excp){
            console.log(excp);
        }
        
        window.history.pushState('',document.title,'/wcsearch/s/');  
    },
    prepareDate : function(processingDate){
        //add the TimeZone offset if the User TimeZone is behind the GMT.
        if(new Date().getTimezoneOffset() > 0) {
            processingDate = new Date(new Date(processingDate).getTime() + (new Date().getTimezoneOffset()+120) *60*1000);
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
        //return (mm+'/'+dd+'/'+yyyy);
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