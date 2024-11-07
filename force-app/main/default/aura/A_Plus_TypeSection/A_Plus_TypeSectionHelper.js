({
    fetchData : function(component, event) {
        
        $A.util.removeClass(component.find("sectionSpinner"), "slds-hide");
        if(event.getParam("fileType") === component.get('v.fileType')){  
            component.set('v.searchKey','');
        }
        
        var action = component.get('c.fetchHeadersAndData'); 
        action.setParams({ relatedRecordId: component.get('v.recordId'), 
                          fileType: component.get('v.fileType'),
                          searchKey : component.get('v.searchKey')});
        
        action.setCallback(this, $A.getCallback(function (response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var fileType =  component.get('v.fileType');
                var fileTypeInfo = response.getReturnValue();
                component.set("v.filesInfoWrapper", fileTypeInfo[fileType]); 
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
            $A.util.addClass(component.find("sectionSpinner"), "slds-hide");
        }));
        $A.enqueueAction(action); 
    },
    deleteInternalRecords: function (component) {
        
        var internalcontentDocId = component.get("v.internalcontentDocId");
        
        if(!$A.util.isUndefined(internalcontentDocId) && !$A.util.isEmpty(internalcontentDocId)) {
            
            var action = component.get('c.deleteAttachmentPlusAndCorrespondingRecords');
            action.setParams({contentDocId: internalcontentDocId});
            
            action.setCallback(this, $A.getCallback(function (response) {
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    component.set("v.internalcontentDocId", '');   
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
                
            }));
            $A.enqueueAction(action);
        }
    },
    
    collectAttPlusRecords : function(component){
        var attachPlusIds = component.get("v.attachPlusIds");
        //Get the event using event name. 
        var appEvent = $A.get("e.c:collectAttPlusRecords"); 
        //Set event attribute value
        appEvent.setParams({
            "attachPlusIds" : attachPlusIds
        }); 
        appEvent.fire(); 
    },
    
    viewSharePointFile : function(component, rowId){
        console.log('rowId',rowId);
        var action = component.get('c.viewSharepointFile'); 
        action.setParams({ 
            recordId : rowId
        });
        
        action.setCallback(this, $A.getCallback(function (response) { 
            var state = response.getState();
            console.log('>>>>'+response);
            if (state === "SUCCESS") {
                console.log('>>>>'+response.getReturnValue());
                window.open(response.getReturnValue(),'_blank');
               
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
            $A.util.addClass(component.find("sectionSpinner"), "slds-hide");
        }));
        $A.enqueueAction(action); 
    }
    
})