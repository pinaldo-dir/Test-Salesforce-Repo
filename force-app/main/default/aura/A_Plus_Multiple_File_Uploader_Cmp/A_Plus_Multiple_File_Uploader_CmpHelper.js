({
    submitFileDetails: function (component) {
        component.set("v.spinner", true); 
        var action = component.get('c.uploadMultipleFiles');
        var fileInfo = component.get("v.fileInfo");
        
        action.setParams({
            selectedOption: component.find("moveOptions").get("v.value"),
            fileInfo: JSON.stringify(fileInfo),
            relatedRecordId: component.get('v.currentRecordId'),
            configDetails: JSON.stringify(component.get('v.configDetails'))
        });
        
        action.setCallback(this, $A.getCallback(function (response) {   
            var state = response.getState();
            if (state === "SUCCESS") { 
                var result = response.getReturnValue();
                if(Boolean(result) && result.isSuccess == true){
                    this.resetAuraAttributes(component);
                    //Show the toast message
                    this.showToastMsg('Success', result.message, 'success');
                    
                    //Refresh the lightning page
                    var fetchAttachmentinfo = $A.get("e.c:A_Plus_FetchAttachmentInfo");
                    fetchAttachmentinfo.setParams({
                        "fileType": component.get('v.fileType')
                    });
                    fetchAttachmentinfo.fire();
                }
                else if(Boolean(result) && result.isSuccess == false){
                    //Show the toast message
                    this.showToastMsg('Error', result.message, 'error');
                    component.set("v.spinner", false);
                    this.deleteMultipleFiles(component);
                }
                else{
                    this.showToastMsg('Error', 'An error occured. Please reach out to administrator.', 'error');
                    this.deleteMultipleFiles(component);
                }
            } else if (state === "ERROR") {
                //Delete files 
                this.deleteMultipleFiles(component);
                //Hide the spinner
                component.set("v.spinner", false);
                this.showToastMsg('Error', 'An error occured. Please reach out to administrator.', 'error');
                var errors = response.getError();
                console.error(errors);
            }
            $A.util.addClass(component.find("loadspinner"), "slds-hide");
        }));
        
        $A.enqueueAction(action);
    },
    
    showToastMsg : function(title, message, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message:message,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    deleteMultipleFiles : function(component){
        var fileInfo = component.get("v.fileInfo");
        if(Boolean(fileInfo) && fileInfo.length > 0){
            component.set("v.spinner", true); 
            var action = component.get('c.deleteMultipleFiles');
            var fileInfo = component.get("v.fileInfo");
            
            action.setParams({
                fileInfo: JSON.stringify(fileInfo)
            });
            
            action.setCallback(this, $A.getCallback(function (response) {   
                var state = response.getState();
                if (state === "SUCCESS") {  
                    if(response.getReturnValue()){
                        this.resetAuraAttributes(component);
                        //Refresh the lightning page
                        var fetchAttachmentinfo = $A.get("e.c:A_Plus_FetchAttachmentInfo");
                        fetchAttachmentinfo.setParams({
                            "fileType": component.get('v.fileType')
                        });
                        fetchAttachmentinfo.fire();
                    }
                    else{
                        this.showToastMsg('Error', 'An error occured. Please reach out to administrator.', 'error');
                    }
                } else if (state === "ERROR") {
                    //Hide the spinner
                    component.set("v.spinner", false);
                    this.showToastMsg('Error', 'An error occured. Please reach out to administrator.', 'error');
                    var errors = response.getError();
                    console.error(errors);
                }
                $A.util.addClass(component.find("loadspinner"), "slds-hide");
            }));
            
            $A.enqueueAction(action);
        }
    },
    
    resetAuraAttributes : function (component){
        component.set("v.spinner", false); 
        component.set('v.fileInfo', []);
        component.set('v.fileSize', 0);
        component.set("v.isModalOpen", false);
        component.set('v.isButtonDisabled', true);
        component.set('v.isDisabled', false);
    }
})