public class OWCcaseIssueUtility {
    public static Boolean ldCreated = false;
    public static RecordType violRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Violation__c' AND DeveloperName = 'WCA_Violations' LIMIT 1];
    @future
    public static void parseResponse(String caseIssueJson, String caseId){
        try{
            DIR_Case__c cse = [select id,Applicant_Type__c from DIR_Case__c where id =: caseId];
            /*if(cse.Applicant_Type__c == 'Representative Garment') {
return;
}*/
            CaseIssueWrapper ciWrapper = (CaseIssueWrapper)JSON.deserialize(caseIssueJson, CaseIssueWrapper.class);
            List<violationTypeJsonResponse> wrapperList = ciWrapper.caseIssues;
            Map<Id, Set<Id>> vtMap = new Map<Id, Set<Id>>();
            Set<Id> vtSet = new Set<Id>();
            Set<Id> vtvSet = new Set<Id>();
            Map<Id, Violation_Type__c> vtRecordsMap = new Map<Id, Violation_Type__c>();
            Map<String, List<Violation_Type_Variable__c>> vtvVarRecordsMap = new Map<String, List<Violation_Type_Variable__c>>();
            Map<Id, Violation_Type_Variable__c> vtvMap = new Map<Id, Violation_Type_Variable__c>();
            Map<String, List<violationTypeVariableResponse>> vtDataMap = new Map<String, List<violationTypeVariableResponse>>();
            system.debug('wrapperList: '+wrapperList.size());
            Map<Integer, List<violationTypeVariableResponse>> mapped = new Map<Integer, List<violationTypeVariableResponse>> ();
            Set<String> duplicateSetIds = new Set<String>();
            if(wrapperList != null){
                for(Integer i =0; i < wrapperList.size(); i++){	
                    violationTypeJsonResponse vtJsonResponse = wrapperList[i];
                    vtSet.add(vtJsonResponse.violationTypeId);
                    string vtIdwithIndex = vtJsonResponse.violationTypeId+':'+i;
                    for(violationTypeVariableResponse wrapper: vtJsonResponse.violationVariables){
                        //added criteria for Jira OWC-895
                        if(wrapper.name == 'VTV1697' || wrapper.name == 'VTV1706'){
                            wrapper.value = '';
                        }
                        if(wrapper.dataType == 'Date' && String.isNotBlank(wrapper.value)){
                            //'2021-08-30'  - / 2021/08/
                            List<String> dateValues = new List<String>();
                            dateValues = wrapper.value.split('-');
                            if(dateValues.size() == 3){
                                String newDate = dateValues[1]+'/'+dateValues[2]+'/'+dateValues[0];
                                wrapper.value = newDate;
                            }
                            
                        }
                        vtvSet.add(wrapper.violationId);
                        if(vtDataMap.containsKey(vtIdwithIndex)){
                            vtDataMap.get(vtIdwithIndex).add(wrapper);
                        }
                        else{
                            vtDataMap.put(vtIdwithIndex, new List<violationTypeVariableResponse>{wrapper});
                        }
                    }                                           
                }
            }
            /*
for(String key: vtDataMap.keySet()){
system.debug('vtDataMap key: '+key);
system.debug('vtDataMap key size' +vtDataMap.get(key).size());
}	*/
            system.debug('vtvSet: '+vtvSet);
            system.debug('vtSet: '+vtSet);
            for(Violation_Type__c vt: [SELECT Id, Name, Violation_Text__c, Assessment_Formula__c, Violation_Type__c, Help_Text__c, Penalty_Assessment_Description__c, 
                                       Civil_Penalty_Section__c, Wage_Assessment_Formula__c, Wage_Assessment_Description__c, RecordType.DeveloperName, Short_Description__c,
                                       Amount_Paid_Formula__c, Amount_Earned_Formula__c, Wizard_Search_Text__c, Wage_Interest_Assessment_Formula__c, Wage_Interest_Assessment_Description__c,
                                       (SELECT Id, Name, Description__c, Data_Type__c, Value__c FROM Violation_Type_Variables__r WHERE Id IN: vtvSet ORDER BY Name asc)
                                       FROM Violation_Type__c WHERE Id IN: vtSet])
            {
                vtRecordsMap.put(vt.Id, vt);
                vtvVarRecordsMap.put(vt.Id, vt.Violation_Type_Variables__r);
                for(Violation_Type_Variable__c vtv: vt.Violation_Type_Variables__r)
                {
                    vtvMap.put(vtv.Id, vtv);
                }
            }
            system.debug('vtvMap: '+vtvMap);
            
            List<ViolationTypeWrapper> finalVTwrapper = new List<ViolationTypeWrapper>();
            for(String vtIdwithIndex: vtDataMap.keySet()){
                List<violationTypeVarWrapper> vtvList = new List<violationTypeVarWrapper>();
                String vtId = vtIdwithIndex.split(':')[0];
                ViolationTypeWrapper vtWrapper = new ViolationTypeWrapper();
                if(vtRecordsMap.containsKey(vtId)) {
                    vtWrapper.vType = vtRecordsMap.get(vtId);
                    vtWrapper.vTypeVars = vtvVarRecordsMap.get(vtId);
                    for(violationTypeVariableResponse wrapper: vtDataMap.get(vtIdwithIndex)){
                        system.debug('wrapper.violationId 60:'+wrapper.violationId);
                        if(vtvMap.containsKey(wrapper.violationId)){
                            violationTypeVarWrapper vtvWrapper = 
                                new violationTypeVarWrapper(vtvMap.get(wrapper.violationId), null,wrapper.value);
                            vtvList.add(vtvWrapper);
                        }
                    }
                    system.debug('vtvList 66: '+vtvList);
                    //return vtvList;
                    vtWrapper.vtvWrapperList = vtvList;
                    finalVTwrapper.add(vtWrapper);
                    system.debug('finalVTwrapper: '+finalVTwrapper);
                }
            }
            if(finalVTwrapper.size() > 0)	{
                //OCEmailServiceUtility.sendTestEmail(json.serialize(finalVTwrapper));
                //return;
                Finalize(finalVTwrapper, caseId);
            }
            
        } catch (Exception e) {
            system.debug('e.getMessage(): '+e.getMessage());
            system.debug('Error line: '+e.getLineNumber());
            system.debug('Stack line: '+e.getStackTraceString());
            
            new OWCServiceUtility().Log(e);
            
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            throw new AuraHandledException(errorMessage+e.getStackTraceString());
        } 
        
    }
    /*public static void calculateClaimAmount(List<ViolationTypeWrapper> SelectedTypes){
for(ViolationTypeWrapper vtw: SelectedTypes){
String formulaStrA = vtw.vType.Assessment_Formula__c != null ? vtw.vType.Assessment_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min') : null;
String formulaStrW = vtw.vType.Wage_Assessment_Formula__c != null ? vtw.vType.Wage_Assessment_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min') : null;
String formulaStrIW = vtw.vType.Wage_Interest_Assessment_Formula__c != null ? vtw.vType.Wage_Interest_Assessment_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min') : null;
String formulaStrAP = vtw.vType.Amount_Paid_Formula__c != null ? vtw.vType.Amount_Paid_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min') : null;
String formulaStrAE = vtw.vType.Amount_Earned_Formula__c != null ? vtw.vType.Amount_Earned_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min') : null;
Decimal totalAP = 0;
Decimal totalAE = 0;
String paramStr = '';
for(violationTypeVarWrapper vtv: vtw.vtvWrapperList){
String vtvDataType = vtv.dataType;
String sId = vtv.vtvName;
String sVal = vtv.varValue;
if(vtvDataType == 'Currency' || vtvDataType == 'Decimal' || vtvDataType == 'Integer'){
while(sVal.indexOf(',') > -1){
sVal = sVal.replace(',', '');
}
try{
Decimal value = Decimal.valueOf(sVal);
}catch(Exception ex){
system.debug('error: '+ex.getStackTraceString());
sVal = '0';
}
while(formulaStrA != '' && formulaStrA.indexOf(sId) > -1){
formulaStrA = formulaStrA.replace(sId, sVal);
}
system.debug('next to error: ');
while(formulaStrW != '' && formulaStrW.indexOf(sId) > -1){
formulaStrW = formulaStrW.replace(sId, sVal);
}
while(formulaStrIW != '' && formulaStrIW.indexOf(sId) > -1){
formulaStrIW = formulaStrIW.replace(sId, sVal);
}
while(formulaStrAP != '' && formulaStrAP.indexOf(sId) > -1){
formulaStrAP = formulaStrAP.replace(sId, sVal);
}
while(formulaStrAE != '' && formulaStrAE.indexOf(sId) > -1){
formulaStrAE = formulaStrAE.replace(sId, sVal);
}
paramStr += vtw.indexCounter+vtv.indexCounter+':'+sVal+'::';

}
}
}
}*/
    public static Boolean Finalize(List<ViolationTypeWrapper> SelectedTypes, String caseId) {
        try{ 
            system.debug('SelectedTypes 1: '+SelectedTypes);
            Violation_Type__c sl17Type = [SELECT Id, Name, Violation_Text__c, Assessment_Formula__c, Violation_Type__c, Help_Text__c, Penalty_Assessment_Description__c, 
                                          Civil_Penalty_Section__c, Wage_Assessment_Formula__c, Wage_Assessment_Description__c, RecordType.DeveloperName, Short_Description__c,
                                          (SELECT Id, Name, Description__c, Data_Type__c, Value__c FROM Violation_Type_Variables__r  ORDER BY Name asc)
                                          FROM Violation_Type__c WHERE Help_Text__c  LIKE '%SL17%'];
            
            
            //saveVarValues(); 	vikas
            String paidByEmployer;
            Decimal amountEarned ;
            String sickLeaveType ;
            Map<String, List<ViolationTypeWrapper>> vTypeMap = new Map<String, List<ViolationTypeWrapper>>();
            for(Integer i = 0; i < SelectedTypes.size(); i++){
                ViolationTypeWrapper vTypeW = SelectedTypes[i];
                system.debug('vTypeW:i '+vTypeW+ ' '+i);
                system.debug('vTyvTypeW.vTypepeW:i '+vTypeW.vType+ ' '+i);
                String violationIdWithIndex = vTypeW.vType.Id+':'+i;
                if (!vTypeMap.containsKey(violationIdWithIndex))
                {
                    vTypeMap.put(violationIdWithIndex, new List<ViolationTypeWrapper>{vTypeW});
                }else{
                    vTypeMap.get(violationIdWithIndex).add(vTypeW);
                }
            }
            /*
for(String key: vTypeMap.keySet()){
system.debug('vTypeMap key size' +vTypeMap.get(key).size());
}	*/
            /*
for (ViolationTypeWrapper vTypeW : SelectedTypes) {
system.debug('vTypeW: '+vTypeW);
system.debug('vTyvTypeW.vTypepeW: '+vTypeW.vType);
if (!vTypeMap.containsKey(vTypeW.vType.Id))
vTypeMap.put(vTypeW.vType.Id, new List<ViolationTypeWrapper>());
vTypeMap.get(vTypeW.vType.Id).add(vTypeW);
}	*/
            system.debug('vTypeMap 1: '+vTypeMap);
            List<Assessments__c> assessList = new List<Assessments__c>();
            List<DIR_Violation__c> violList = new List<DIR_Violation__c>();
            List<Violation_Variable__c> vvList = new List<Violation_Variable__c>();
            
            List<DIR_Employee__c> employees = [SELECT Id FROM DIR_Employee__c WHERE User__c = :UserInfo.getUserId() AND (Position__c = 'Deputy' OR Position__c = 'Senior Deputy')];
            for (String key : vTypeMap.keySet()) {
                /*
Assessments__c assess = new Assessments__c(
Case_Management__c = c.Id,
Appeal_Deadline_Selector__c = 'Business Days',
Citation_Form__c = key,
Total_Wages_assessed__c = 0
);
assessList.add(assess);		*/ //	Vikas
                decimal assessTotal = 0;
                for(ViolationTypeWrapper vtw : vTypeMap.get(key)){
                    Decimal rateOfPay ;
                    Integer noOfSickLeave;
                    Decimal amoountAccrued;
                    //lets check for the SL17
                    if(vtw.vType.Help_Text__c.containsIgnoreCase('SL10')){sickLeaveType = 'SL10';
                                                                         }else if(vtw.vType.Help_Text__c.containsIgnoreCase('SL11'))	{sickLeaveType = 'SL11';
                                                                                                                                        }else if(vtw.vType.Help_Text__c.containsIgnoreCase('SL13')){sickLeaveType = 'SL13';
                                                                                                                                                                                                   }else if(vtw.vType.Help_Text__c.containsIgnoreCase('SL14')){sickLeaveType = 'SL14';
                                                                                                                                                                                                                                                              }	
                    
                    //lets check for LD issue
                    //RW10,RW11,RW12, PR10,PR11,PR12,PR21, CM10,CM11, OT19,OT10, DT10
                    if(!ldCreated){
                        if(vtw.vType.Help_Text__c.containsIgnoreCase('RW10')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('RW11')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('RW12')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('PR10')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('PR11')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('PR12')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('PR21')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('CM10')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('CM11')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT19')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT22')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT22.1')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT22.2')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT22.3')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT10')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT13.1')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT13.2')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT13.3')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT13')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('DT15')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('DT16')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('OT28')
                           || vtw.vType.Help_Text__c.containsIgnoreCase('DT10')){
                               prepareLDissues(vtw, 'VTV1262', 'VTV1263', 'VTV1267', 'VTV1266','VTV1268', caseId);
                           }
                        /*
if(vtw.vType.Help_Text__c.containsIgnoreCase('MW19')){
prepareLDissues(vtw, 'VTV1262', 'VTV1263', 
'VTV1267', 'VTV1266',
'VTV1268', caseId);
} else if(vtw.vType.Help_Text__c.containsIgnoreCase('MW21')){
prepareLDissues(vtw, 'VTV1280', 'VTV1281', 
'VTV1287', 'VTV1286',
'VTV1288', caseId);
} else if(vtw.vType.Help_Text__c.containsIgnoreCase('MW23')){
prepareLDissues(vtw, 'VTV1301', 'VTV1302', 
'VTV1304', '',
'VTV1305', caseId);
} else if(vtw.vType.Help_Text__c.containsIgnoreCase('MW10')){
prepareLDissues(vtw, 'VTV0016', 'VTV0017', 
'VTV0020', 'VTV0019',
'VTV0021', caseId);
} else if(vtw.vType.Help_Text__c.containsIgnoreCase('MW12')){
prepareLDissues(vtw, 'VTV1235', 'VTV1236', 
'VTV1241', 'VTV1240',
'VTV1242', caseId);
} else if(vtw.vType.Help_Text__c.containsIgnoreCase('MW23')){
prepareLDissues(vtw, 'VTV1252', 'VTV1253', 
'', '',
'VTV3546', caseId);
} 
*/
                    }
                    
                    system.debug('vtw 1: '+vtw);
                    system.debug('vtw.vType.Penalty_Assessment_Description__c: '+vtw.vType.Penalty_Assessment_Description__c);
                    DIR_Violation__c viol = new DIR_Violation__c(
                        //Assessment__r = assessMap.get(vt.Citation_Form__c),
                        RecordTypeId = violRT.Id,
                        Case__c = caseId,
                        Violation_Type__c = vtw.vType.Id,
                        //Penalty_Assessment_Description__c = ParseExplanation(vtw, vtw.vType.Penalty_Assessment_Description__c),
                        //Wage_Assessment_Description__c = ParseExplanation(vtw, vtw.vType.Wage_Assessment_Description__c),
                        Original_Penalty_Assessment_Amount__c = vtw.subTotalA == null ? 0 : vtw.subTotalA,
                        //viol.Citation_Amount__c = vtw.amount,
                        //viol.Original_Penalty_Assessment_Amount__c = vtw.amount
                        Citation_Amount__c = vtw.subTotalA == null ? 0 : vtw.subTotalA,
                        Original_Wage_Assessment_Amount__c = vtw.subTotalW == null ? 0 : vtw.subTotalW,
                        Wages_Due__c = vtw.subTotalW == null ? 0 : vtw.subTotalW,
                        Amount_Paid__c = vtw.amountPaid == null ? 0 : vtw.amountPaid,
                        Amount_Earned__c = vtw.amountEarned == null ? 0 : vtw.amountEarned,
                        Total_Wage_Interest_Amount__c = vtw.subTotalIW == null ? 0 : vtw.subTotalIW,
                        Status__c = 'Hold' 
                    );
                    if(employees.size() == 1){
                        viol.DIR_Employee__c = employees[0].Id;
                    }
                    
                    for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
                        if(sickLeaveType == 'SL10'){
                            system.debug('sickLeaveType ::: '+vtv.vTypeVar.Name + ':::: '+vtv.varValue);
                            if(vtv.vTypeVar.Name == 'VTV0086' && String.isNotBlank(vtv.varValue)){
                                
                                try{
                                    rateOfPay = Decimal.valueOf(vtv.varValue);
                                }catch(exception e){rateOfPay = 0;}
                            } else if(vtv.vTypeVar.Name == 'VTV0085' && String.isNotBlank(vtv.varValue)){
                                try{
                                    noOfSickLeave = Integer.valueOf(vtv.varValue);
                                }catch(exception e){noOfSickLeave = 0;}
                            } else if(vtv.vTypeVar.Name == 'VTV0090' && String.isNotBlank(vtv.varValue)){
                                paidByEmployer = vtv.varValue;
                            } 
                        } 
                        else if(sickLeaveType == 'SL11'){
                            if(vtv.vTypeVar.Name == 'VTV1832' && String.isNotBlank(vtv.varValue)){
                                try{
                                    amoountAccrued = Decimal.valueOf(vtv.varValue);
                                }catch(exception e){amoountAccrued = 0;}
                                
                            } else if(vtv.vTypeVar.Name == 'VTV1833' && String.isNotBlank(vtv.varValue)){
                                paidByEmployer = vtv.varValue;
                            }
                        } 
                        else if(sickLeaveType == 'SL13'){
                            if(vtv.vTypeVar.Name == 'VTV2112' && String.isNotBlank(vtv.varValue)){
                                try{
                                    rateOfPay = Decimal.valueOf(vtv.varValue);
                                }catch(exception e){rateOfPay = 0;}
                                
                            } else if(vtv.vTypeVar.Name == 'VTV2111' && String.isNotBlank(vtv.varValue)){
                                try{
                                    noOfSickLeave = Integer.valueOf(vtv.varValue);
                                }catch(exception e){noOfSickLeave = 0;}
                            } else if(vtv.vTypeVar.Name == 'VTV2114' && String.isNotBlank(vtv.varValue)){
                                paidByEmployer = vtv.varValue;
                            }
                        } 
                        else if(sickLeaveType == 'SL14'){
                            if(vtv.vTypeVar.Name == 'VTV1856' && String.isNotBlank(vtv.varValue)){
                                
                                try{
                                    amoountAccrued = Decimal.valueOf(vtv.varValue);
                                }catch(exception e){amoountAccrued = 0;}
                            } else if(vtv.vTypeVar.Name == 'VTV1857' && String.isNotBlank(vtv.varValue)){
                                paidByEmployer = vtv.varValue;
                            }
                        }
                        
                        system.debug('vtv 186'+vtv);
                        Violation_Variable__c vv = new Violation_Variable__c(
                            Case_Violation__r = viol,
                            Violation_Type_Variable__c = vtv.vTypeVar.Id,
                            Value__c = vtv.varValue
                        ); 
                        vvList.add(vv);
                    }
                    system.debug('line 360');
                    if(sickLeaveType == 'SL10'){
                        if(rateOfPay != null && noOfSickLeave != null){
                            system.debug('line 363');
                            try{
                                system.debug('line 365');
                                Integer sickLeave = Integer.valueOf(noOfSickLeave);
                                amountEarned = rateOfPay * noOfSickLeave;
                            }
                            catch(exception e){amountEarned = 0;}
                            
                        } 
                    } else if(sickLeaveType == 'SL11'){
                        system.debug('line 376');
                        amountEarned = amoountAccrued;
                    } else if(sickLeaveType == 'SL13'){
                        if(rateOfPay != null && noOfSickLeave != null){
                            system.debug('line 380');
                            try{
                                system.debug('line 383');
                                Integer.valueOf(noOfSickLeave);
                                amountEarned = rateOfPay * noOfSickLeave;
                            }
                            catch(exception e){ //isNaN or Infinity
                                system.debug('line 387');
                                amountEarned = 0;
                            }
                        } 
                    } else if(sickLeaveType == 'SL14'){
                        system.debug('line 392');
                        amountEarned = amoountAccrued;
                    }
                    violList.add(viol);
                }
            }
            
            if(sickLeaveType != null && sickLeaveType.containsIgnoreCase('sl')){
                //lets create the record for SL17
                DIR_Violation__c violSL17 = new DIR_Violation__c(
                    RecordTypeId = violRT.Id,
                    Case__c = caseId,
                    Violation_Type__c =sl17Type.Id,
                    Status__c = 'Hold' );
                insert violSL17;
                //create the Variables for violSL17
                List<Violation_Variable__c> vvListSL17 = new List<Violation_Variable__c>();
                for(Violation_Type_Variable__c vtv: sl17Type.Violation_Type_Variables__r){
                    Violation_Variable__c vVar = new Violation_Variable__c();
                    vVar.Case_Violation__c = violSL17.Id;
                    vVar.Violation_Type_Variable__c = vtv.Id;
                    if(vtv.Name == 'VTV1861'){
                        if(amountEarned != null){
                            //vVar.Value__c = String.valueOf(amountEarned);
                            //As per Jira OWC-687
                            vVar.Value__c = '0';
                        }
                    }else if(vtv.Name == 'VTV1862'){
                        //vVar.Value__c = paidByEmployer;
                        //As per Jira OWC-687
                        vVar.Value__c = '0';
                    }
                    vvListSL17.add(vVar);
                }
                insert vvListSL17;
                //violList.add(violSL17);
            }
            
            /*insert assessList;
for (DIR_Violation__c viol : violList) {
viol.Assessment__c = viol.Assessment__r.Id;
}		*/ 		//Vikas
            system.debug('vvList'+vvList);
            try{
                insert violList; 
            }catch(exception ex){
                system.debug('error msg: '+ex.getStackTraceString() + ' : '+ex.getMessage() );
            }
            
            List<Violation_Variable__c> violationVarList = new List<Violation_Variable__c>();
            for (Violation_Variable__c vv : vvList) {
                Violation_Variable__c violationVar = new Violation_Variable__c();
                violationVar.Case_Violation__c = vv.Case_Violation__r.Id;
                violationVar.Violation_Type_Variable__c = vv.Violation_Type_Variable__c;
                violationVar.Value__c = vv.Value__c;
                violationVarList.add(violationVar);
            }
            insert violationVarList;
            /* if(1 == 1){
OCEmailServiceUtility.sendTestEmail(json.serialize(violList)); 
return true;
}	*/
            return true;
        }catch (Exception e) {
            system.debug('e.getMessage(): '+e.getMessage());
            system.debug('Error line: '+e.getLineNumber());
            system.debug('Stack line: '+e.getStackTraceString());
            
            new OWCServiceUtility().Log(e);
            
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            throw new AuraHandledException(errorMessage+e.getStackTraceString());
        }
        
    }
    
    @auraEnabled
    public static void saveVarValues(String valueString, List<ViolationTypeWrapper> SelectedTypes){
        system.debug('Inside Save Var Values - valueString');
        system.debug(valueString);
        try{
            if(valueString != null && valueString.trim().length() != 0){
                List<String> strList = valueString.split('::');
                for(String s : strList){
                    List<String> itemList = s.split(':');
                    if(!itemList[0].Contains('TOTAL') && !itemList[0].Contains('AMT')){
                        String pString;
                        String cString;
                        for(ViolationTypeWrapper vt  : selectedTypes){
                            Integer counterLength = string.valueOf(vt.indexCounter).length();
                            pString = itemList[0].subString(0,counterLength);
                            cString = itemList[0].subString(counterLength,itemList[0].length());
                            if(vt.indexCounter == integer.valueOf(pString)){
                                for(violationTypeVarWrapper vtv : vt.vtvWrapperList){
                                    if(vtv.indexCounter == integer.valueOf(cString)){
                                        vtv.varValue = (itemList[1] == null || itemList[1].trim() == '') ? '0' : itemList[1] != vtv.varValue ? itemList[1] : vtv.varValue;
                                    }
                                }
                            }
                        }
                    }
                    else{
                        String n;
                        boolean isW = false;
                        boolean isIW = false;
                        boolean isA = false;
                        boolean isAP = false;
                        boolean isAE = false;
                        if(itemList[0].Contains('TOTALA')){
                            n = itemList[0].replace('TOTALA', '');
                            isA = true;
                        }
                        else if(itemList[0].Contains('TOTALW')){
                            n = itemList[0].replace('TOTALW', '');
                            isW = true;
                        }
                        else if(itemList[0].Contains('TOTALIW')){
                            n = itemList[0].replace('TOTALIW', '');
                            isIW = true;
                        }
                        else if(itemList[0].Contains('AMTP')){
                            n = itemList[0].replace('AMTP', '');
                            isAP = true;
                        }
                        else if(itemList[0].Contains('AMTE')){
                            n = itemList[0].replace('AMTE', '');
                            isAE = true;
                        }
                        for(ViolationTypeWrapper vt  : selectedTypes){
                            if(vt.indexCounter == integer.valueOf(n)){
                                Decimal amt;
                                try{
                                    amt = Decimal.valueOf(itemList[1]);
                                }
                                catch(exception e){ //isNaN or Infinity
                                    system.debug('error: '+e.getStackTraceString());
                                    amt = 0;
                                }
                                if(isA){
                                    vt.subTotalA = amt;
                                }
                                else if(isW){
                                    vt.subTotalW = amt;
                                }
                                else if(isIW){
                                    vt.subTotalIW = amt;
                                }
                                else if(isAP){
                                    vt.amountPaid = amt;
                                }
                                else if(isAE){
                                    vt.amountEarned = amt;
                                }
                                system.debug('next to error: ');
                            }
                        }
                    }
                }
            }
        }catch (Exception e) {
            system.debug('e.getMessage(): '+e.getMessage());
            system.debug('Error line: '+e.getLineNumber());
            system.debug('Stack line: '+e.getStackTraceString());
            
            new OWCServiceUtility().Log(e);
            
            String errorMessage = e.getMessage() +' And '+e.getLineNumber() + ' And '+e.getStackTraceString();
            throw new AuraHandledException(errorMessage+e.getStackTraceString());
        }
    }
    
    public static string ParseExplanation(ViolationTypeWrapper vtw, String assessDesc) {
        string retValue = assessDesc;
        if (retValue == null)
            return null;
        
        while (retValue.contains('{') && retValue.contains('}')) {
            
            System.debug('retValue:' + retValue);
            
            string toCalculate = retValue.subString(retValue.indexOf('{') + 1, retValue.indexOf('}'));
            
            System.debug('toCalculate:' + toCalculate);
            
            decimal valuesofar;
            
            decimal operand;
            string operator;
            
            integer position = 0;
            
            while (position < toCalculate.length()) {
                System.debug('testScoty ::: '+toCalculate.subString(position, position + 1));
                if(toCalculate.subString(position, position + 1) == '~'){
                    string var = toCalculate.subString(position, position + 9);
                    
                    for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
                        var = var.replace('~', '');
                        System.debug('vtvWrapperList ::: '+vtv.vtvName + ':::' +var);
                        if(var == vtv.vtvName){
                            if(vtv.varValue == null ){
                                vtv.varValue = '0';
                            }
                            operand = Decimal.valueOf(vtv.varValue);
                            String identifier = String.valueOf(vtw.indexCounter) + String.valueOf(vtv.indexCounter);
                            
                            if (valuesofar == null) {
                                valuesofar = operand;
                            } 
                            else {
                                if (operator == '*')
                                    valuesofar *= operand;
                                if (operator == '-')
                                    valuesofar -= operand;
                                if (operator == '+')
                                    valuesofar += operand;
                                if (operator == '/')
                                    valuesofar /= operand;
                            }
                            position += 9;
                        }
                    }
                } 
                else {
                    operator = toCalculate.subString(position, position + 1);
                    position += 1;
                }
            }
            retValue = retValue != null ? retValue.substring(0, retValue.indexOf('{')) + valuesofar.setScale(2, system.RoundingMode.HALF_UP).format() + retValue.substring(retValue.indexOf('}') + 1): '';
        }
        for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
            String var = '~'+vtv.vtvName+'~';
            retValue = retValue.Replace(var, string.valueOf(vtv.varValue));
        }
        return retValue;
        
    }
    
    public class ViolationTypeWrapper {
        public decimal subTotalA { get; set; }
        public decimal subTotalW { get; set; }
        public decimal subTotalIW { get; set; }
        public decimal amountPaid { get; set; }
        public decimal amountEarned { get; set; }
        public Integer indexCounter { get; set; }
        public Violation_Type__c vType { get; set; }
        public List<Violation_Type_Variable__c> vTypeVars { get; set; }
        public List<violationTypeVarWrapper> vtvWrapperList { get; set; }
        public boolean selected { get; set; }
        public decimal amount { get; set; }
        public decimal wage { get; set; }
        public decimal wageinterest { get; set; }
        public Integer varWrapperIndex;
        public ViolationTypeWrapper(Violation_Type__c vType, List<Violation_Type_Variable__c> vTypeVars, List<violationTypeVarWrapper> vtvWrapperList){
            
        }
        public string wageformula;
        public string wageinterestformula;
        public string formula;
        public string amountPaidFormula;
        public string amountEarnedFormula;
        
        public ViolationTypeWrapper(){
            
        }
        
    }
    public class violationTypeVarWrapper{
        public Integer indexCounter { get; set; }
        public Violation_Type_Variable__c vTypeVar { get; set; }
        public String varValue { get; set; }
        public boolean isUserInput { get; set; }
        public String dataType { get; set; }
        public String vtvName { get; set; }
        public violationTypeVarWrapper(Violation_Type_Variable__c vtv, Integer wIndex, String vtvValue){
            isUserInput = false;
            indexCounter = wIndex;
            vTypeVar = vtv;
            vtvName = vtv.Name;
            dataType = vtv.Data_Type__c;
            if(vtvValue != null){
                varValue = vtvValue;
                
            }
            else {
                isUserInput = true;   
            }
        }
    }
    public class violationTypeResponse{
        @AuraEnabled
        public String violationId{get;set;}
        @AuraEnabled
        public List<vtVarModel> vtVarModelList{get;set;}
        
    }
    public class vtVarModel {
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String dataType{get;set;}
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public String violationId{get;set;}
    }
    public class CaseIssueWrapper{
        public violationTypeJsonResponse[] caseIssues;
    }
    class violationTypeJsonResponse {
        public String violationTypeId;	//VID
        public violationTypeVariableResponse[] violationVariables;
    }
    public class violationTypeVariableResponse{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String dataType{get;set;}
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public String violationId{get;set;}
        @AuraEnabled
        public String violationTypeId{get;set;}
    }
    
    //create the LD issue 
    public static void prepareLDissues(ViolationTypeWrapper vtw, String startDateCode, String endDateCode, 
                                       String numberofhoursCode, String minimumWageRateCode,
                                       String totalAmountPaidCode, String caseId)
    {	
        ldCreated = true;
        try{
            
            Violation_Type__c ld10Type = [SELECT Id, Name, Violation_Text__c, Assessment_Formula__c, Violation_Type__c, Help_Text__c, Penalty_Assessment_Description__c, 
                                          Civil_Penalty_Section__c, Wage_Assessment_Formula__c, Wage_Assessment_Description__c, RecordType.DeveloperName, Short_Description__c,
                                          (SELECT Id, Name, Description__c, Data_Type__c, Value__c FROM Violation_Type_Variables__r  ORDER BY Name asc)
                                          FROM Violation_Type__c WHERE Help_Text__c  LIKE '%LD10%'];
            
            //lets create the record for LD10
            DIR_Violation__c violLD10 = new DIR_Violation__c(
                RecordTypeId = violRT.Id,
                Case__c = caseId,
                Violation_Type__c =ld10Type.Id,
                Status__c = 'Hold' );
            insert violLD10;
            //create the Variables for violLD14
            List<Violation_Variable__c> vvListLD10 = new List<Violation_Variable__c>();
            for(Violation_Type_Variable__c vtv: ld10Type.Violation_Type_Variables__r){
                Violation_Variable__c vVar = new Violation_Variable__c();
                vVar.Case_Violation__c = violLD10.Id;
                vVar.Violation_Type_Variable__c = vtv.Id;
                vVar.Value__c = null;
                vvListLD10.add(vVar);
            }
            insert vvListLD10;
        }catch (Exception e) {new OWCServiceUtility().Log(e); throw new AuraHandledException(e.getStackTraceString());
        }
        
        /* Comment for Case Issue simplification as per Jira OWC-446
* 
String numberofhours ;
String minimumWageRate;
String totalAmountPaid;
String startDate;
String endDate;
Boolean createLD14 = false;
ldCreated = true;
for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
if(vtv.vTypeVar.Name == startDateCode && String.isNotBlank(vtv.varValue)){
startDate = vtv.varValue;
} else if(vtv.vTypeVar.Name == endDateCode){
endDate = vtv.varValue;
} else if(vtv.vTypeVar.Name == endDateCode){
endDate = vtv.varValue;
} else if(vtv.vTypeVar.Name == numberofhoursCode){
system.debug('vtv.varValue: '+vtv);
if(vtv.varValue != null && String.isBlank(vtv.varValue)){
createLD14 = true; 
} else if((Decimal.valueOf(vtv.varValue)) == 0){
createLD14 = true;
}
numberofhours = vtv.varValue;
} else if(vtv.vTypeVar.Name == minimumWageRateCode){
minimumWageRate = vtv.varValue;
} else if(vtv.vTypeVar.Name == totalAmountPaidCode){
totalAmountPaid = vtv.varValue;
if(String.isBlank(vtv.varValue)){
createLD14 = true; 
} else if((Decimal.valueOf(vtv.varValue)) == 0){
createLD14 = true;
}
}
}

if(createLD14){
//create LD14
Violation_Type__c ld14Type = [SELECT Id, Name, Violation_Text__c, Assessment_Formula__c, Violation_Type__c, Help_Text__c, Penalty_Assessment_Description__c, 
Civil_Penalty_Section__c, Wage_Assessment_Formula__c, Wage_Assessment_Description__c, RecordType.DeveloperName, Short_Description__c,
(SELECT Id, Name, Description__c, Data_Type__c, Value__c FROM Violation_Type_Variables__r  ORDER BY Name asc)
FROM Violation_Type__c WHERE Help_Text__c  LIKE '%LD14%'];
//lets create the record for SL17
DIR_Violation__c violLD14 = new DIR_Violation__c(
RecordTypeId = violRT.Id,
Case__c = caseId,
Violation_Type__c =ld14Type.Id,
Status__c = 'Hold' );
insert violLD14;
//create the Variables for violLD14
List<Violation_Variable__c> vvListLD14 = new List<Violation_Variable__c>();
for(Violation_Type_Variable__c vtv: ld14Type.Violation_Type_Variables__r){
Violation_Variable__c vVar = new Violation_Variable__c();
vVar.Case_Violation__c = violLD14.Id;
vVar.Violation_Type_Variable__c = vtv.Id;
if(vtv.Name == 'VTV1846'){
vVar.Value__c = '0';
}else if(vtv.Name == 'VTV1847'){
vVar.Value__c = '0';
}
vvListLD14.add(vVar);
}
insert vvListLD14;
} else {
// Create LD10
Violation_Type__c ld10Type = [SELECT Id, Name, Violation_Text__c, Assessment_Formula__c, Violation_Type__c, Help_Text__c, Penalty_Assessment_Description__c, 
Civil_Penalty_Section__c, Wage_Assessment_Formula__c, Wage_Assessment_Description__c, RecordType.DeveloperName, Short_Description__c,
(SELECT Id, Name, Description__c, Data_Type__c, Value__c FROM Violation_Type_Variables__r  ORDER BY Name asc)
FROM Violation_Type__c WHERE Help_Text__c  LIKE '%LD10%'];

//lets create the record for LD10
DIR_Violation__c violLD10 = new DIR_Violation__c(
RecordTypeId = violRT.Id,
Case__c = caseId,
Violation_Type__c =ld10Type.Id,
Status__c = 'Hold' );
insert violLD10;
//create the Variables for violLD14
List<Violation_Variable__c> vvListLD10 = new List<Violation_Variable__c>();
for(Violation_Type_Variable__c vtv: ld10Type.Violation_Type_Variables__r){
Violation_Variable__c vVar = new Violation_Variable__c();
vVar.Case_Violation__c = violLD10.Id;
vVar.Violation_Type_Variable__c = vtv.Id;
if(vtv.Name == 'VTV1009'){
vVar.Value__c = startDate;
}else if(vtv.Name == 'VTV1010'){
vVar.Value__c = endDate;
}
else if(vtv.Name == 'VTV1011'){
vVar.Value__c = minimumWageRate;
}
else if(vtv.Name == 'VTV1012'){
vVar.Value__c = numberofhours;
}
else if(vtv.Name == 'VTV1013'){
vVar.Value__c = totalAmountPaid;
}
vvListLD10.add(vVar);
}
insert vvListLD10;
**********************************************/
    }
}