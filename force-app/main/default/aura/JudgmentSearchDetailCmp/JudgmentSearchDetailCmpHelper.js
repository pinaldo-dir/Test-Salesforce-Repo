({
    getJudgmentDetails : function(component, event, helper) {
        /*var querystring = location.search.substr(1);
        console.log('querystring::'+querystring);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        console.log('paramValue:: '+JSON.stringify(paramValue));
        component.set("v.selectedJudgmentRecordId", paramValue.id);*/
        var action = component.get("c.getJudgmentDetails");
        action.setParams({ 
            "selectedJudgmentRecordId" : component.get("v.recordId"),
            "judgmentPartyId" : component.get("v.jpId") || null
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('data ::: '+result);
                component.set("v.selectedJudgmentDetailObj", response.getReturnValue());
                var downloadContentUrl = result.downloadContentUrl;
                var downloadContentUrlList = [];
                for ( var key in downloadContentUrl ) {
                    downloadContentUrlList.push({value:downloadContentUrl[key], key:key});
                }
                component.set("v.selectedJudgementDocumentContentList", downloadContentUrlList);
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
        var selectedJudgmentRecordId = component.get("v.recordId");
        var judgmentPartyId = component.get("v.jpId");
        var dbaName = component.get("v.dbaName");
        var vfPageUrl = '/apex/JudgmentSearchDetailPage?id='+selectedJudgmentRecordId+'&jpid='+judgmentPartyId;
        window.open(vfPageUrl,"_blank");
    }
})