({
    searchCases: function(component, search){
        console.log("H----------searchCases----------H");
        var action = component.get("c.searchCases");
        action.setParams({
            "searchKey" : search
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue().length > 0){
                    component.set("v.cases", response.getReturnValue());
                    console.log("Search Cases => Response > 0");
                    console.log(response.getReturnValue());
                    var spinnerDiv = document.getElementById("loadSpinner");
                    spinnerDiv.classList.replace("slds-show","slds-hide");
                }
                else{
                    console.log("Search Cases => Response = 0");
                    console.log(response.getReturnValue());
                    var spinnerDiv = document.getElementById("loadSpinner");
                    spinnerDiv.classList.replace("slds-show","slds-hide");
                    var noCase = document.getElementById("noCaseFound");
                    noCase.classList.replace("slds-hide","slds-show");
                }
            }

        });
        $A.enqueueAction(action);	
    },
    
    getCases: function(component, cases) {
        console.log("H----------getCases----------H");
        var action = component.get("c.getgridCases");
        console.log("cases");
        console.log(cases);
        
        action.setParams({
            "ids": cases
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var newCaseList = response.getReturnValue();
                var caseMap = component.get("v.casesMap");
                var caseMapArr = JSON.parse(JSON.stringify(caseMap));
                var CaseListMap = [];
                if(caseMapArr != null){
                    for(i=0; i<caseMapArr.length; i++){
                        CaseListMap.push(caseMapArr[i].caseDetail);
                    }
                }
                var ApndCaseList = [];
                var newCaseIndex = 0;
                   
                if(CaseListMap != null && CaseListMap.length > 0){
                    if(cases.length != newCaseList.length){
                        var casesArr = cases.split(",");
                        for(var i=0; i<casesArr.length; i++){
                            for(var j=0; j<newCaseList.length; j++){
                                if(casesArr[i] == newCaseList[j].IdCase){
                                    ApndCaseList.push(newCaseList[j]);
                                }
                            }
                        }
                    }
                    else{
                        ApndCaseList = newCaseList;
                    }
                    
                    CaseListMap = ApndCaseList;
                }
                else{
                    CaseListMap = newCaseList;
                }
                var caseMapArr = [];
                console.log("CaseListMap", CaseListMap);
                if(CaseListMap.length>0){
                    for(var i=0; i<CaseListMap.length; i++){
                        console.log(CaseListMap[i].recType);
                        if(CaseListMap[i].recType == "JEU"){
                            //alert("Warning: Cannot log payments to JEU cases");
                            window.alert("Warning: Cannot log payments to JEU cases");
                        }
                        else{
                            caseMapArr.push({
                            	index: i,
                            	caseDetail: CaseListMap[i]
                        	});
                        }
                        
                    }
                	console.log(caseMapArr);
                }
                
                component.set("v.casesMap", caseMapArr);
            }
        });
        $A.enqueueAction(action);
    }
    
})