({
	showHints : function(component, event, helper) {
        console.log('3 v.selectedRecordId: ', component.get("v.selectedRecordId"));
		
        if(event.which == 13){

            var inputTxt = component.get("v.inputTxtAttr");
            console.log('5 inputTxt: ', inputTxt);
            var noPayor = document.getElementById("noPayorFound");
            noPayor.classList.replace("slds-show","slds-hide");
            var spinnerDiv = document.getElementById("loadSpinner");
            spinnerDiv.classList.replace("slds-hide","slds-show");
            if(inputTxt){
                
            }else{
                component.set("v.selectedRecordId", '');
            }
            var objName = component.get("v.objNameAttr");
    
            var action = component.get('c.getRecords');
            
            action.setParams({
                inputTxt : inputTxt,
                objName : objName
            })        
            
            action.setCallback(this, function(response){
                var recordsList = [];
                if(inputTxt){
                    recordsList = response.getReturnValue();
                }else{
                    recordsList = [];  
                }
                console.log('21 recordsList: '+JSON.stringify(recordsList));
                component.set("v.recordsList", recordsList);
                if(recordsList.length > 0){
                    var spinnerDiv = document.getElementById("loadSpinner");
                    spinnerDiv.classList.replace("slds-show","slds-hide");
                }
                else{
                    console.log("no payor found error");
                    var spinnerDiv = document.getElementById("loadSpinner");
                    spinnerDiv.classList.replace("slds-show","slds-hide");
                    var noPayor = document.getElementById("noPayorFound");
                    noPayor.classList.replace("slds-hide","slds-show");
                }
                
            })
            $A.enqueueAction(action);
        }

	},
    selectRecord : function(component, event, helper) {
        console.log('24 component: ', component);
		var idString = event.currentTarget.dataset.value;
        console.log('25 idString: ', idString);
        var recordName = event.currentTarget.innerHTML;
        
        // use browser inbuilt dom html parser to avoid encoding such as &amp; for & in record name
        var parser = new DOMParser;
		var dom = parser.parseFromString('<!doctype html><body>' + recordName,'text/html');
        recordName = dom.body.textContent;
        console.log('33 recordName: ', recordName);
        
        component.set("v.selectedRecordId", idString);
        component.set("v.inputTxtAttr", recordName);
        /* $('.records').hide(); */
        component.set("v.recordsList", []);

        var compEvent = component.getEvent("inputLookupFieldEvent");
        compEvent.setParams({
            "payorIdString" : idString
        });
        console.log('41 compEvent: ', compEvent);
        compEvent.fire();
    },
    handleMouseOver : function(component, event, helper){
        console.log('58 handleMouseOver');

        var selectedItem = event.currentTarget;
        var id = selectedItem.dataset.id;

        var Elements = component.find('resultItem');

        for(var i = 0; i < Elements.length; i++){
            var val = Elements[i].getElement().getAttribute('data-id');

            if(val == id){
                $A.util.removeClass(Elements[i], 'record');
                $A.util.addClass(Elements[i], 'recordhighlight');
            }

            /* if(val != id){
                $A.util.removeClass(Elements[i], 'recordhighlight');
                $A.util.addClass(Elements[i], 'record');
            }else{
                $A.util.removeClass(Elements[i], 'record');
                $A.util.addClass(Elements[i], 'recordhighlight');
            } */
        }
    },
    handleMouseOut : function(component, event, helper){
        console.log('78 handleMouseOut');

        var selectedItem = event.currentTarget;
        var id = selectedItem.dataset.id;

        var Elements = component.find('resultItem');

        for(var i = 0; i < Elements.length; i++){
            var val = Elements[i].getElement().getAttribute('data-id');

            $A.util.removeClass(Elements[i], 'recordhighlight');
            $A.util.addClass(Elements[i], 'record');

            /* if(val == id){
                $A.util.removeClass(Elements[i], 'recordhighlight');
                $A.util.addClass(Elements[i], 'record');
            }else{
                $A.util.removeClass(Elements[i], 'record');
                $A.util.addClass(Elements[i], 'recordhighlight');
            } */
        }
    }

})