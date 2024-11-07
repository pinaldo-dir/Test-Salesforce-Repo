({	
    doInit: function(component) {
        component.set('v.isOWCTabHidden', false);
        var urlString = window.location.href;
        console.log('urlString: '+urlString);
        var pageName = urlString.split ("/s/");
        debugger;
        if(pageName.length > 0&& pageName[1] == 'new-online-claim'){
            component.set('v.isOWCTabHidden', true);
        }
        console.log('pageName: '+pageName);
    },
    reInit: function(component) {
        var urlString = window.location.href;
        console.log('urlString: '+urlString);
        var pageName = urlString.split ("/s/");
        debugger;
        if(pageName.length > 0&& pageName[1] == 'new-online-claim'){
            component.set('v.isOWCTabHidden', true);
        }
        console.log('pageName: '+pageName);
    },
    onClick : function(component, event, helper) {
        var id = event.target.dataset.menuItemId;
        console.log('id: '+id);
        if(id == "1"){
            component.set('v.isOWCTabHidden', true);
        }
        else{
            component.set('v.isOWCTabHidden', false);
        }
        if (id) {
            component.getSuper().navigate(id);
         }
   }
})