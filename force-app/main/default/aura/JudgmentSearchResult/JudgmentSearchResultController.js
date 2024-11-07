({
	viewInfoRecord : function(component, event, helper) {
        /*
        var selectedRecordId = component.get("v.JudgmentObj");
        console.log('selectedRecordId ::: '+selectedRecordId.recordId);
         console.log('judgmentPartyId ::: '+selectedRecordId.judgmentPartyId);
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
        console.log('selectedRecordId ::judgmentPartyId: '+jpid);
        component.set("v.recordId", selectedRecordId.recordId);
        //component.set("v.jpid", selectedRecordId.jpid);
        component.set("v.jpid", jpid)
        component.set("v.isPopOpen", true);
	}
})