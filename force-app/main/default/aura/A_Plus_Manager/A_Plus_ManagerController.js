({
    formDataTypeSections: function (component, event, helper) {                               
        component.set('v.currentRecordId', component.get('v.recordId'));
        helper.formDataTypeSections(component);           
    },
    onSearchClear: function (component, event, helper) {                
        var searchKey = component.get('v.searchKey').trim();
        if($A.util.isUndefined(searchKey) || $A.util.isEmpty(searchKey)){
            helper.formDataTypeSections(component);
        }
    },
    handleAttPlusRecord : function(component, event, helper){
        var attachPlusIds = event.getParam("attachPlusIds");
        component.set("v.attachPlusIds", attachPlusIds);
        if(Boolean(attachPlusIds) && attachPlusIds.length > 0){
            component.set('v.isButtonDisabled', false);
        }
        else{
            component.set('v.isButtonDisabled', true);
        }
    },
    handleMulptipleDownload : function(component, event, helper){
        var attachPlusIds = component.get("v.attachPlusIds");
        console.log('attachPlusIds :::: in parent ::: ', attachPlusIds);
        if(Boolean(attachPlusIds) && attachPlusIds.length > 0){
            helper.downloadMultipleFile(component, event);
        }
    }
})