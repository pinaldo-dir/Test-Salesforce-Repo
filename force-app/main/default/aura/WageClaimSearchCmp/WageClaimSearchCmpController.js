({
    doInit : function(component, event, helper) {
        component.set("v.isLoading", true);
        //set the default AsOfDate to today
        var today = helper.prepareDate(new Date());
        component.set("v.today", today);
        var placeHolderDate = helper.placeHolderDatePrepare(new Date());
        component.set("v.placeHolderDate", placeHolderDate);
        helper.wageClaimMetadata(component, event);
    },
    onNaicsCodeChange : function(component, event, helper) {
        var naicsCode = component.get("v.naicsCode");
        if(naicsCode != null && naicsCode.length > 0){
            component.set("v.errorMsg", false);
        }
    },
    onDocketFromDate : function(component, event, helper){
        component.set("v.errorMsg", false);
        var inputCmp = component.find("docketDateTo");
        var docketFromDate = component.get("v.docketFromDate");
        var docketToDate = component.get("v.docketToDate");
        if(docketFromDate != null || docketFromDate != "" || docketFromDate != undefined){
            if(docketToDate == null || docketToDate == "" || docketToDate == undefined){
                docketToDate = component.get("v.today");
            }
        }
        if (docketFromDate > docketToDate){
            inputCmp.setCustomValidity("To Date is less than From Date.");
        }
        else {
            inputCmp.setCustomValidity("");
        }
        inputCmp.reportValidity();
    },
    onDocketToDate : function(component, event, helper){
        component.set("v.errorMsg", false);
        var inputCmp = component.find("docketDateTo");
        var docketFromDate = component.get("v.docketFromDate");
        var docketToDate = component.get("v.docketToDate");
        if (docketFromDate > docketToDate){
            inputCmp.setCustomValidity("To Date is less than From Date.");
        }
        else {
            inputCmp.setCustomValidity("");
        }
        inputCmp.reportValidity();
    },
    onCaseClosedFromDate : function(component, event, helper){
        component.set("v.errorMsg", false);
        var inputCmp = component.find("caseCloseDateTo");
        var caseClosedFromDate = component.get("v.caseClosedFromDate");
        var caseClosedToDate = component.get("v.caseClosedToDate");
        if(caseClosedFromDate != null || caseClosedFromDate != "" || caseClosedFromDate != undefined){
            if(caseClosedToDate == null || caseClosedToDate == "" || caseClosedToDate == undefined){
                caseClosedToDate = component.get("v.today");
            }
        }
        if (caseClosedFromDate > caseClosedToDate){
            inputCmp.setCustomValidity("To Date is less than From Date.");
        }
        else {
            inputCmp.setCustomValidity("");
        }
        inputCmp.reportValidity();
    },
    onCaseClosedToDate : function(component, event, helper){
        component.set("v.errorMsg", false);
        var inputCmp = component.find("caseCloseDateTo");
        var closedFromDate = component.get("v.caseClosedFromDate");
        var closedToDate = component.get("v.caseClosedToDate");
        if (closedFromDate > closedToDate){
            inputCmp.setCustomValidity("To Date is less than From Date.");
        }
        else {
            inputCmp.setCustomValidity("");
        }
        inputCmp.reportValidity();
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
                var result = response.getReturnValue();
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
    onLowWageValueChange : function(component, event, helper){
        component.set("v.errorMsg", false);
        console.log(':::wage value'+component.find("lowwage").get("v.value"));
        component.set("v.caseLowWage",component.find("lowwage").get("v.value"))
    },
    onDirOfficeChange : function(component, event, helper){
        component.set("v.errorMsg", false);
        console.log(component.find("dirOffice").get("v.value"));
        component.set("v.dirOffice",component.find("dirOffice").get("v.value"))
    },
    onClearFields : function(component, event, helper){
        helper.clearAllFields(component, event);
    },
    onSearchButton : function(component, event, helper){
        helper.searchWageClaim(component, event);
    }
})