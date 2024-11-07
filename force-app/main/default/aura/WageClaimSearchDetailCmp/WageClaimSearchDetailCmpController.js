({
    hideWageClaimDetailModal : function(component) {
        var isPopOpen = component.get("v.isPopOpen");
        component.set("v.isPopOpen", false);
    },
	doInit : function(component, event, helper) {
		helper.getWageClaimDetails(component,event)
	},
    handleDownloadPdf : function(component, event, helper){
        helper.getDownloadPdfStatus(component, event, helper);
    },
    backToSearch : function(component, event, helper) {
        //get the selected filters
        var urlParamsForFilters = component.get("v.urlParamsForFilters") || '';
        //redirect to the Search Page
        var url = (urlParamsForFilters != '') ? "/s/wageclaimsearch?"+urlParamsForFilters : '/s';
        console.log('URL=====' + url);
        window.open(url,'_self');
    }
})