({
    handleOnSubmit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
        var type = component.get("v.type");
        var reason = component.get("v.reason") || ''; 
        var status = component.get("v.status");
        var associatedAgent = component.get("v.recordId");
        var agentAssociatedName= component.get("v.agentAssociatedName");
        console.log('type>>>'+type+': : associatedAgent>>>>'+associatedAgent+': : agentAssociatedName>>>>'+agentAssociatedName);
        console.log('status>>>'+status);
        //check for same account
        if(associatedAgent == agentAssociatedName){
            var errorMsg = 'System do not allow the user to select same record for Account and Associate Account fields. ';
            helper.showSameAccountAlert(component, event, helper, errorMsg);
            component.set("v.showSpinner", false);
            return;
        }
        //check for Inactive status and No Reason
        if(status === false && reason === ''){
            var errorMsg = 'Please provide the inactive relationship reason.';
            helper.showSameAccountAlert(component, event, helper, errorMsg);
            component.set("v.showSpinner", false);
            return;
        }
        var action = component.get("c.saveValues");
        // set the parameters to method
        action.setParams({
            "type": type,
            "associatedAgent":associatedAgent,
            "agentAssociatedName":agentAssociatedName,
            "status": status,
            "reason": reason

        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ---->' + response.getReturnValue());
            var modal = response.getReturnValue();
            if( modal != null && modal.isSuccess === true){
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": modal.message,
                    "slideDevName": "related"
                });
                navEvt.fire();
                helper.showToast(component, event, helper);
            }
            else{
                component.set("v.showSpinner", false);
                //alert("Entered Duplicate Value");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: modal.message,
                    type: 'error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
        
    },
    handleSuccess: function(component, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        navEvt.fire();
        helper.showToast(component, event, helper);
        
    },
    handleError: function(component, event, helper){
        console.log('error: '+JSON.stringify(event.getParams()) );
        
    },
    handleCancel: function(component, event, helper){
        console.log('record id: '+ component.get("v.recordId"));
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        navEvt.fire();
        //helper.showToast(component, event, helper);
        
    },
    doInit : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var newContext;
        if(value !== null){
            var context = JSON.parse(window.atob(value));
            if(context !== undefined || context !== null){
                newContext = JSON.stringify(context);
            }
            if(newContext.indexOf("attributes")>0){
                component.set('v.recordId', context.attributes.recordId);
            }
            else{
                console.log('##Its not a Salesforce1 App');
            }
        }
    },
    
})