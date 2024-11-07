({
    viewInfoRecord : function(component, event, helper) {
        /*
        var selectedRecordId = component.get("v.JudgmentObj");
        console.log('selectedRecordId ::: '+selectedRecordId.recordId);
        var jpid = '';
        if(selectedRecordId.judgmentPartyId != null && selectedRecordId.judgmentPartyId != 'undefined'){
            jpid = selectedRecordId.judgmentPartyId;
        }
        var detailPageUrl = '/s/judgmentdetails/?id='+selectedRecordId.recordId+'&jpid='+jpid;
        window.open(detailPageUrl,"_blank");
        */
        var selectedRecordId = component.get("v.JudgmentObj");
        if(selectedRecordId.dbaName != null){
            component.set("v.dbaName", selectedRecordId.dbaName);
        }
        var jpid = '';
        if(selectedRecordId.judgmentPartyId != null && selectedRecordId.judgmentPartyId != 'undefined'){
            jpid = selectedRecordId.judgmentPartyId;
        }
        console.log('selectedRecordId ::: '+selectedRecordId.recordId);
        component.set("v.recordId", selectedRecordId.recordId);
        component.set("v.jpId", jpid);
        component.set("v.isPopOpen", true);
    }
})