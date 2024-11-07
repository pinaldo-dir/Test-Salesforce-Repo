({
    doInit : function(component, event, helper) {
        //show the spiner
        component.set("v.isLoading", true);
        //set the default AsOfDate to today
        var today = helper.prepareDate(new Date());
        var todayDateLabel = helper.prepareDateLabel(new Date());
        component.set("v.currentListAsOfDateLabel", todayDateLabel);
        var placeHolderDate = helper.placeHolderDatePrepare(new Date());
        component.set("v.placeHolderDate", placeHolderDate);
        component.set("v.currentListAsOfDate", today);
        console.log('v.currentListAsOfDate'+component.get("v.currentListAsOfDate"));
        helper.loadJudgmentMetadata(component, event, helper);
    },
    onNaicsCodeChange : function(component, event, helper) {
        var naicsCode = component.get("v.naicsCode");
        if(naicsCode != null && naicsCode.length > 0){
            component.set("v.errorMsg", false);
        }
    },
    onClearFields : function(component, event, helper) {
        helper.clearAllfields(component, event, helper);
    },
     onClearPreviousListFields : function(component, event, helper) {
        component.set("v.previousListFromDate",null);
         component.set("v.previousListToDate",null);
    },
    onJudgmentEntryToDate : function(component, event, helper){
        component.set("v.errorMsg", false);
        var inputCmp = component.find("judgmentEntryToDate");
        var judgmentEntryDateFrom = component.get("v.judgmentEntryDateFrom");
        var judgmentEntryDateTo = component.get("v.judgmentEntryDateTo");
        if(judgmentEntryDateFrom != null || judgmentEntryDateFrom != "" || judgmentEntryDateFrom != undefined){
            if(judgmentEntryDateTo == null || judgmentEntryDateTo == "" || judgmentEntryDateTo == undefined){
                judgmentEntryDateTo = component.get("v.currentListAsOfDate");
            }
        }
        if (judgmentEntryDateFrom > judgmentEntryDateTo){
            inputCmp.setCustomValidity("To Date is less than From Date.");
        }
        else {
            inputCmp.setCustomValidity("");
        }
        inputCmp.reportValidity();
    },
    onJudgmentEntryFromDate : function(component, event, helper){
        component.set("v.errorMsg", false);
        var inputCmp = component.find("judgmentEntryToDate");
        var judgmentEntryDateFrom = component.get("v.judgmentEntryDateFrom");
        var judgmentEntryDateTo = component.get("v.judgmentEntryDateTo");
        if(judgmentEntryDateFrom != null || judgmentEntryDateFrom != "" || judgmentEntryDateFrom != undefined){
            if(judgmentEntryDateTo == null || judgmentEntryDateTo == "" || judgmentEntryDateTo == undefined){
                judgmentEntryDateTo = component.get("v.currentListAsOfDate");
            }
        }
        if (judgmentEntryDateFrom > judgmentEntryDateTo){
            inputCmp.setCustomValidity("To Date is less than From Date.");
        }
        else {
            inputCmp.setCustomValidity("");
        }
        inputCmp.reportValidity();
    },
    onListStatusChange : function(component, event, helper) {
        component.set("v.errorMsg", false);
        var listStatusPicklistValues = component.get('v.listStatusPicklistValues');
        console.log('listStatusPicklistValues' , listStatusPicklistValues);
        var inputStatusCmp = component.find("listStatus");
        var listStatus = inputStatusCmp.get("v.value") || '';
        if(listStatus !== '') {
            // Clear error
            inputStatusCmp.set("v.errors", null);
        }
        component.set("v.listStatus2810",component.find("listStatus").get("v.value"))
    },
    onJudgmentTotalFromChange : function(component, event, helper){
        component.set("v.errorMsg", false);
    },
    onJudgmentTotalToChange : function(component, event, helper){
        component.set("v.errorMsg", false);
    },
    onDefandantEmployerNameChange : function(component, event, helper){
        component.set("v.errorMsg", false);
    },
     onClaimantPlaintiffChange : function(component, event, helper){
        component.set("v.errorMsg", false);
    },
    onAddressCityChange : function(component, event, helper){
        component.set("v.errorMsg", false);
    },
    onAddresszipCodeChange : function(component, event, helper){
        component.set("v.errorMsg", false);
    },
    onJudgmentStatusChange : function(component, event, helper) {
        component.set("v.errorMsg", false);
        var judgmentStatusValue = [];
        judgmentStatusValue = component.find("judgmentStatus").get("v.value");
      //  var js = "'" + judgmentStatusValue.join("','") + "'";
        console.log('judgmentStatusValue::;'+judgmentStatusValue);
        component.set("v.selectedJudgmentStatusOptions",judgmentStatusValue);
        component.set("v.judgmentStatus",component.find("judgmentStatus").get("v.value"));
    },
    onDirOfficeChange : function(component, event, helper) {
        component.set("v.errorMsg", false);
        console.log(component.find("dirOffice").get("v.value"));
        component.set("v.dirOffice",component.find("dirOffice").get("v.value"))
    },
    onCountyChnage : function(component, event, helper) {
        component.set("v.errorMsg", false);
        //component.set("v.county",component.find("county").get("v.value"));
        helper.getCountyChangeResult(component, event); 
    },
    onPreviousListFromDate : function(component, event, helper){
        component.set("v.errorMsg", false);
         var inputCmp = component.find("previousListFromDate");
        var previousListFromDate = component.get("v.previousListFromDate");
        var previousListToDate = component.get("v.previousListToDate");
        if (previousListFromDate > previousListToDate){
            inputCmp.setCustomValidity("From Date is greater than To Date.");
        }
        else {
            inputCmp.setCustomValidity("");
        }
        inputCmp.reportValidity();
    },
    onPreviousListToDate : function(component, event, helper){
        component.set("v.errorMsg", false);
         var inputCmp = component.find("previousListToDate");
        var previousListToDate = component.get("v.previousListToDate");
        if (previousListToDate == ''){
            inputCmp.setCustomValidity("Please select the To Date.");
        }
        else {
            inputCmp.setCustomValidity("");
        }
        inputCmp.reportValidity();
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        component.set("v.errorMsg", false);
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 1 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,helper){
        helper.clearLookupValues(component,event);   
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected NaicsCodeRecord record from the COMPONETN event 	 
        var selectedNaicsCodeRecordGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedNaicsCodeRecordGetFromEvent);
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show'); 
        
        var action = component.get("c.getSelectedNaicsTitle");
        action.setParams({ 
            selectedNaicsCode : selectedNaicsCodeRecordGetFromEvent.Name
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.naicsCodeTitle",response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
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
    onSearchButton : function(component,event,helper){
        //show the spiner
        component.set("v.isLoading", true);
        helper.searchJudgment(component,event);   
    },
     onSearchAsOfButton : function(component,event,helper){
        //show the spiner
      //  component.set("v.isLoading", true);
        helper.searchPortDrayage(component,event);   
    },
    onSearchPreviousListButton : function(component, event, helper){
        helper.searchPreviousList(component, event);
    },
    onCourtHouseChange : function(component,event,helper){
        //show the spiner
        component.set("v.errorMsg", false);
        component.set("v.court",component.find("courtHouse").get("v.value"));
        console.log('court value:::'+component.get("v.court"));
    },
    
})