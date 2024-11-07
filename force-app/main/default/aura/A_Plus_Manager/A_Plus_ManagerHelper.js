({
    formDataTypeSections: function (component) {
        
		$A.util.removeClass(component.find("loadspinner"), "slds-hide");
        var action = component.get('c.fetchHeadersAndData');
        var relatedRecId = component.get('v.recordId');
		var isLEX = component.get('v.isLEX');
        
        action.setParams({
            relatedRecordId: relatedRecId,
            fileType: '',
            searchKey: component.get('v.searchKey')
        });

        action.setCallback(this, $A.getCallback(function (response) {   
            var state = response.getState();
            if (state === "SUCCESS") {

                var headersAndDataInfo = response.getReturnValue();  
                component.set("v.headersAndDataInfo", headersAndDataInfo);
                console.log('Result ::: '+JSON.stringify(headersAndDataInfo))
                var isNotConfigured = $A.util.isUndefined(headersAndDataInfo) || $A.util.isEmpty(headersAndDataInfo);
                component.set('v.isNotConfigured',isNotConfigured);  
                
                if(isNotConfigured){
                    return;
                }
                
                var counter = 0;
				
                var accordionAndchildComponents = [["lightning:accordion",{}]];     
                
                for (var filetype in headersAndDataInfo) {
                    counter = counter + 1;
                    accordionAndchildComponents.push(['c:A_Plus_TypeSection', {
                                                        recordId: relatedRecId,
                                                        fileType: filetype,
                                                        index: counter,
                                                        searchKey: '',
                                                        filesInfoWrapper: headersAndDataInfo[filetype],
                        								headersAndDataInfo : headersAndDataInfo,
                        								isLEX: isLEX
                                                    }]);
                }
                
                $A.createComponents(
                        accordionAndchildComponents,
                         function(components, status, errorMessage){
                             if (status === "SUCCESS") {
                                 
                                 var acccordion = components[0];
                                 var accordionBody = []; 
                                 for(var index = 1; index < components.length; index = index + 1){     
                                     accordionBody.push(components[index]);
                                 }
                                 acccordion.set("v.body", accordionBody);     
                                 component.set("v.body", '');
                                 component.set("v.body", acccordion);                    
                                 
                             }
                         }
                 );
                

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
            $A.util.addClass(component.find("loadspinner"), "slds-hide");
        }));
        
        $A.enqueueAction(action);
    },
    downloadMultipleFile: function (component, event) {
        $A.util.removeClass(component.find("loadspinner"), "slds-hide");
        var action = component.get('c.downloadMultipleFiles');
        
        action.setParams({
            attachPlusIds: component.get("v.attachPlusIds")
        });

        action.setCallback(this, $A.getCallback(function (response) {   
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(Boolean(result)){
                    for(var i=0; i<result.length; i++){
                        //window.open(result[i]);
                        event.preventDefault(); 
                        window.open(result[i]) ;
                    }
                    //Zip folder of the multiple files
                    //this.zipFileFolder(result);
                    //Show the toast message
                    this.showToastMsg('Success', 'Your files has been successfully downloaded.', 'success');
                    //Reset aura attributes
                    this.resetAuraAttributes(component);
                }
                else{
                    this.showToastMsg('Error', 'An error occured. Please reach out to administrator.', 'error');
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                this.showToastMsg('Error', errors, 'error');
            }
            $A.util.addClass(component.find("loadspinner"), "slds-hide");
        }));
        
        $A.enqueueAction(action);
    },
    
    zipFileFolder : function(result){
        var zip = new JSZip();
        var count = 0;
        var zipFilename = "zipFilename.zip";
        var urls = result;
        
        urls.forEach(function(url){
            var filename = "filename";
            // loading a file and add it in a zip file
            JSZipUtils.getBinaryContent(url, function (err, data) {
                if(err) {
                    throw err; // or handle the error
                }
                zip.file(filename, data, {binary:true});
                count++;
                if (count == urls.length) {
                    zip.generateAsync({type:'blob'}).then(function(content) {
                        saveAs(content, zipFilename);
                    });
                }
            });
        });
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
    
    resetAuraAttributes : function (component){
        //$A.get('e.force:refreshView').fire();
    }
})