({
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
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
        console.log('clearing field');
        component.set("v.naicsCodeTitle"," ");
        helper.clearLookupValues(component,event);   
    },
    
    fetchLookupValueById : function (component, event, helper){
        var params = event.getParam('arguments');
        console.log('JSON==', JSON.stringify(params));
        if (params) {
            var recordId = params.recordId;
            
            console.log('recordId==', params);
            // add your code here
            helper.fetchLookupValueById(component, event, recordId);  
        }
         
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected NaicsCodeRecord record from the COMPONETN event 	 
        var selectedNaicsCodeRecordGetFromEvent = event.getParam("recordByEvent");
        var objectAPIName = event.getParam("objectType");
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
        
        //check if the NAICS Code is selected
        if(objectAPIName == 'NAICS_Code__c' ) {
            var action = component.get("c.getSelectedNaicsTitle");
            action.setParams({ 
                selectedNaicsCode : selectedNaicsCodeRecordGetFromEvent.label
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
        }
        
    },
    onSearchButton : function(component,event,helper){
        helper.searchJudgment(component,event);   
    },
})