({
    doInIt: function (component, event, helper){
        console.log('Result ::: '+JSON.stringify(component.get("v.headersAndDataInfo")));
    },
    
	handleShowModal: function (component, event, helper) { 
        var fileTypeOptionsToMove = {};
        var options = [{label: "Select one", value: ""}];
        component.set("v.isModalOpen", true);
        var headersAndDataInfo = component.get("v.headersAndDataInfo");
        for (var filetypeOption in headersAndDataInfo) {
            if(fileType != filetypeOption && filetypeOption != 'Related Files'){ 
                fileTypeOptionsToMove[filetypeOption] = headersAndDataInfo[filetypeOption];
            }
        }
        component.set('v.fileTypeOptionsToMove', fileTypeOptionsToMove);
        for(var fileType in fileTypeOptionsToMove){
            options.push({label : fileType, value : fileType});
        }
        component.find("moveOptions").set("v.options", options);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        helper.deleteMultipleFiles(component);
    },
    
    onMoveOptionSelect : function(component, event, helper) {
        var selectedoption = component.find("moveOptions").get("v.value");
        var fileSize = component.get("v.fileSize");
        if(Boolean(fileSize) && fileSize > 0 && Boolean(selectedoption)){
            component.set('v.isButtonDisabled', false);
        }
        else{
            component.set('v.isButtonDisabled', true);
        }
        component.set('v.fileType', selectedoption);
        var fileTypeOptionsToMove = component.get("v.fileTypeOptionsToMove");
        console.log('result ::: ', JSON.stringify(fileTypeOptionsToMove));
        if(Boolean(selectedoption)){
            component.set('v.configDetails',fileTypeOptionsToMove[selectedoption].details);
        }
    },
    
    handleUploadFinished: function (component, event) {
        var fileSize = component.get('v.fileSize');
        var fileInfo = component.get('v.fileInfo');//{File_Name : '',Private : false,Description : ''};
        var files = event.getParam("files");
        var selectedOption = component.find("moveOptions").get('v.value');
        var contentDocumentIds = [];
        for(var i=0; i<files.length; i++){
            fileSize = fileSize + 1;
            fileInfo.push({name : files[i].name,fileExtension : files[i].name.split('.').pop(),documentId : files[i].documentId, File_Name : files[i].name.substring(0, files[i].name.lastIndexOf('.')),Private : false,Description : '',Upload_Date : '' });
            //contentDocumentIds.push({File_Name : files[i].name, documentId : files[i].documentId});
        }
        component.set('v.fileSize', fileSize);
        if(Boolean(selectedOption) && component.get('v.fileSize') == 10){
            component.set('v.isButtonDisabled', false);
            component.set('v.isDisabled', true);
            component.set('v.fileInfo', fileInfo);
        }
        else if(Boolean(selectedOption) && component.get('v.fileSize') < 10){
            component.set('v.isButtonDisabled', false);
            component.set('v.fileInfo', fileInfo);
        }
        else if(component.get('v.fileSize') > 10){
            component.set('v.isButtonDisabled', true);
            component.set('v.isDisabled', false);
        }
        else{
            component.set('v.isDisabled', false);
            component.set('v.isButtonDisabled', true);
        }
        console.log('files ::: ', component.get("v.fileInfo"));
    },
    
    submitDetails: function(component, event, helper) {
        //Add your code to call apex method or do some processing
        var selectedOption = component.find("moveOptions").get('v.value');
        var fileSize = component.get("v.fileSize");
        //Add your code to call apex method or do some processing
        if(Boolean(selectedOption) && fileSize > 0){
            component.set("v.isModalOpen", false);
            helper.submitFileDetails(component); 
        }
    }
})