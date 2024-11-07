({
	viewInfoRecord : function(component, event, helper) {
		/*
        var selectedRecordId = component.get("v.WageObj");
        console.log('wageClaimObj::'+JSON.stringify(selectedRecordId));
        console.log('selectedRecordId ::: '+selectedRecordId.id);
         console.log('caseRoleId ::: '+selectedRecordId.caseRoleId);
        var crid = '';
        if(selectedRecordId.caseRoleId != null && selectedRecordId.caseRoleId != 'undefined'){
            crid = selectedRecordId.caseRoleId;
        }
        var detailPageUrl = '/s/wageclaimdetails/?id='+selectedRecordId.id+'&crid='+crid;
        window.open(detailPageUrl,"_blank");
        */
        var selectedRecordId = component.get("v.WageObj");
        console.log('wageClaimObj::'+JSON.stringify(selectedRecordId));
        console.log('selectedRecordId ::: '+selectedRecordId.id);
         console.log('caseRoleId ::: '+selectedRecordId.caseRoleId);
        var crid = '';
        if(selectedRecordId.caseRoleId != null && selectedRecordId.caseRoleId != 'undefined'){
            crid = selectedRecordId.caseRoleId;
        }
        component.set("v.selectedCaseId", selectedRecordId.id);
        component.set("v.selectedCaseRoleId", crid);
        component.set("v.isPopOpen", true);
	}
})