({
    getParameterByName: function(component, event, name, url) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    showToast : function(component, event, helper){
        component.set("v.showSpinner", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
           title : 'Success',
            message: 'Record has been successfully created.',
            type: 'success',
        });
        toastEvent.fire();
    },
    showSameAccountAlert : function(component, event, helper, errorMsg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
           title : 'Error',
            message: errorMsg,
            type: 'error'
        });
        toastEvent.fire();
    }
    
})