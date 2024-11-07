({
    getWageClaimDetails : function(component, event, helper) {
        /*
        var querystring = location.search.substr(1);
        console.log('querystring::'+querystring);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        console.log('paramValue:: '+JSON.stringify(paramValue));
        component.set("v.selectedCaseId", paramValue.id);
        var crid = '';
        if(paramValue.crid != null && paramValue.crid != 'undefined'){
            crid = paramValue.crid;
        }
         console.log('paramValue jp id:: '+crid);
        component.set("v.selectedCaseRoleId", paramValue.crid);
        */
        var action = component.get("c.getWageClaimDetails");
        console.log('selectedCaseId ::: '+component.get("v.selectedCaseId"));
        console.log('selectedCaseRoleId ::: '+component.get("v.selectedCaseRoleId"));
        action.setParams({ 
            "selectedCaseId" : component.get("v.selectedCaseId"),
            "selectedCaseRoleId" : component.get("v.selectedCaseRoleId") || null
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var downloadContentUrl = result.downloadContentUrl;
                var downloadContentUrlList = [];
                console.log('data ::: '+result);
                component.set("v.selectedWageClaimObj", response.getReturnValue());
                for ( var key in downloadContentUrl ) {
                    downloadContentUrlList.push({value:downloadContentUrl[key], key:key});
                }
                component.set("v.selectedWageClaimDocumentUrl", downloadContentUrlList);
                console.log('result:::'+JSON.stringify(component.get("v.selectedWageClaimObj")));
            }
            else if (state === "INCOMPLETE") {
                // do something
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
    getDownloadPdfStatus : function(component, event, helper){
        var selectedCaseRoleId = component.get("v.selectedCaseRoleId");
        var selectedCaseId = component.get("v.selectedCaseId");
        console.log('selectedCaseRoleId ::: '+selectedCaseRoleId); 
        console.log('selectedCaseId ::: '+selectedCaseId);
        var vfPageUrl = '/apex/WageClaimSearchDetailPage?crid='+selectedCaseRoleId+'&id='+selectedCaseId;
        window.open(vfPageUrl,"_blank");
    }
})