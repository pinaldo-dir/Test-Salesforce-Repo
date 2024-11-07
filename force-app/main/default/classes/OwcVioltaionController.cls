public with sharing class OwcVioltaionController {
    
    public static Integer wrapperIndex = 1;
    @AuraEnabled
    public static Boolean selectAll {get;set;}
    @AuraEnabled
    public static boolean rtError {get;set;}
    public static boolean isLoad = false;
    //public ApexPages.StandardController controller;
    
    public Map<String, RecordType> rtMap = new Map<String, RecordType>();
    private static Record_Type_Mapping__c thisMapping;
    
    public static List<ViolationTypeWrapper> selectedTypes = new List<ViolationTypeWrapper>();
    
    public integer selectedSize{
        get{
            return selectedTypes.size();
        }
    }

    public OwcVioltaionController() {
        //selectedTypes = new List<ViolationTypeWrapper>();
        rtError = false;
    }
	
    @AuraEnabled(cacheable=true)
    public static List<Record_Type_Mapping__c> vtMap(){
       List<Record_Type_Mapping__c> vtMapList = Record_Type_Mapping__c.getAll().values(); 
       return vtMapList;
    }
   
    @AuraEnabled(cacheable=true)
    public static List<DIR_Case__c> LoadCase(String caseId){
        try{
            List<DIR_Case__c> dirCase = [SELECT Employer__c, Id, Case_Number__c, Status__c , NAICS_Code__c, DLSE_Program__c, Employer_Industry__c,
                                                IC_Determination__c,Total_Number_of_Misclassified_Employees__c, Record_Type_Text__c,
                                                Employer__r.Name, RecordType.DeveloperName,Violation_Type__c 
                                            FROM DIR_Case__c 
                                            WHERE Id = :caseId];

            return dirCase;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public boolean getRTError{
        get{
            return rtError;
        }
        set;
    }   
      
    public static List<ViolationTypeWrapper> violationTypesP;

    private static Record_Type_Mapping__c getRecordTypeMapping(DIR_Case__c dirCase){
        List<Record_Type_Mapping__c> rtMappings = Record_Type_Mapping__c.getAll().values();
        for(Record_Type_Mapping__c rtMapping : rtMappings){
            if(rtMapping.Case_Rec_Type__c == dirCase.RecordType.DeveloperName){
                    return rtMapping;
            }
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<ViolationTypeWrapper> SearchedViolationsTypes(String caseId, String key) {
        String tempVar = key.toLowercase();
        String searchKey = '%' + tempVar + '%';
        List<Record_Type_Mapping__c> rtMappings = Record_Type_Mapping__c.getAll().values();
        
        DIR_Case__c dirCase = [SELECT Employer__c, Case_Number__c, NAICS_Code__c, DLSE_Program__c, Employer_Industry__c,
                                    Record_Type_Text__c, Employer__r.Name, RecordType.DeveloperName, Violation_Type__c
                                FROM DIR_Case__c
                                WHERE Id = :caseId];

        if(violationTypesP == null){
            for(Record_Type_Mapping__c rtMapping : rtMappings){
                if(rtMapping.Case_Rec_Type__c == dirCase.RecordType.DeveloperName){
                    thisMapping = rtMapping;
                    break;
                }
            }

            if(thisMapping == null){
                rtError = true;
                return null;
            }

            violationTypesP = new List<ViolationTypeWrapper>();

            for(Violation_Type__c vType : [SELECT Id, Name, Violation_Text__c, Assessment_Formula__c, Violation_Type__c, Help_Text__c, Penalty_Assessment_Description__c,
                                                Civil_Penalty_Section__c, Wage_Assessment_Formula__c, Wage_Assessment_Description__c, RecordType.DeveloperName, Short_Description__c,
                                                Amount_Paid_Formula__c, Amount_Earned_Formula__c, Wizard_Search_Text__c, Wage_Interest_Assessment_Formula__c, Wage_Interest_Assessment_Description__c,
                                                Assessment_Variable_A__c, Variable_A_Description__c, Assessment_Variable_B__c, Variable_B_Description__c,
                                                Assessment_Variable_C__c, Variable_C_Description__c, Assessment_Variable_D__c, Variable_D_Description__c,
                                                Assessment_Variable_E__c, Variable_E_Description__c, Assessment_Variable_F__c, Variable_F_Description__c,
                                                Assessment_Variable_G__c, Variable_G_Description__c, Assessment_Variable_H__c, Variable_H_Description__c,
                                                Assessment_Variable_I__c, Variable_I_Description__c, Assessment_Variable_J__c, Variable_J_Description__c,
                                                (SELECT Id, Name, Description__c, Data_Type__c, Value__c 
                                                    FROM Violation_Type_Variables__r 
                                                    ORDER BY Name ASC)
                                            FROM Violation_Type__c
                                            WHERE Active__c = TRUE
                                                AND (Name LIKE :searchKey OR Wizard_Search_Text__c LIKE :searchKey)
                                            ORDER BY Help_Text__c]){
                if(vType.RecordType.DeveloperName == thisMapping.Violation_Type_Rec_Type__c){
                    violationTypesP.add(new ViolationTypeWrapper(vType, wrapperIndex++));
                }
            }
        }
        
        return violationTypesP;
    }

    public static Map<String, RecordType> getRecordTypes(DIR_Case__c dirCase){
        Map<String, RecordType> rtMap = new Map<String, RecordType>();
        List<String> rtIdentifier = new List<String>();

        if(dirCase.RecordType.DeveloperName.contains('BOFE')){
            rtIdentifier.add('BOFE');
        }else if(dirCase.RecordType.DeveloperName.contains('WCA')){
            rtIdentifier.add('WCA');
        }else if(dirCase.RecordType.DeveloperName.contains('Garment')){
            rtIdentifier.add('Garment');
        }else if(dirCase.RecordType.DeveloperName.contains('PASS')){
            rtIdentifier.add('BOFE');
        }else if(dirCase.RecordType.DeveloperName.contains('RCI')){
            rtIdentifier.add('RCI');
        }else if(dirCase.RecordType.DeveloperName.contains('JEU')){
            rtIdentifier.add('JEU');
            rtIdentifier.add('BOFE');
        }else if(dirCase.RecordType.DeveloperName.contains('Registration')){
            rtIdentifier.add('Registration');
        }

        for(RecordType rt : [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType IN ('Liability__c', 'Liable_Party__c') AND DeveloperName IN :rtIdentifier]){
            if(!rtMap.containsKey(rt.SobjectType)){
                rtMap.put(rt.SobjectType, rt);
            }
        }

        return rtMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<ViolationTypeWrapper> ViolationsTypes(String caseId) {
        // List<Record_Type_Mapping__c>  rtMappings = Record_Type_Mapping__c.getAll().values();
        
        if(violationTypesP == null){
            DIR_Case__c dirCase = [SELECT Employer__c, Case_Number__c, NAICS_Code__c, DLSE_Program__c, Employer_Industry__c,
                                        Record_Type_Text__c, Employer__r.Name, RecordType.DeveloperName, Violation_Type__c 
                                    FROM DIR_Case__c 
                                    WHERE Id = :caseId];

            // getRecordTypes(dirCase);
            
            thisMapping = [SELECT Id, Name, Case_Rec_Type__c, Violation_Type_Rec_Type__c
                            FROM Record_Type_Mapping__c
                            WHERE Case_Rec_Type__c = :dirCase.RecordType.DeveloperName
                            LIMIT 1];

            if(thisMapping == null){
                rtError = true;
                return null;
            }

            violationTypesP = new List<ViolationTypeWrapper>();

            for(Violation_Type__c violationType : [SELECT Id, Name, Violation_Text__c, Assessment_Formula__c, Violation_Type__c, Help_Text__c,
                                                            Penalty_Assessment_Description__c, Wage_Assessment_Formula__c, Civil_Penalty_Section__c,
                                                            Wage_Assessment_Description__c, RecordType.DeveloperName, Short_Description__c,
                                                            Amount_Paid_Formula__c, Amount_Earned_Formula__c, Wizard_Search_Text__c,
                                                            Wage_Interest_Assessment_Formula__c, Wage_Interest_Assessment_Description__c,
                                                            Assessment_Variable_A__c, Variable_A_Description__c, Assessment_Variable_B__c, Variable_B_Description__c,
                                                            Assessment_Variable_C__c, Variable_C_Description__c, Assessment_Variable_D__c, Variable_D_Description__c,
                                                            Assessment_Variable_E__c, Variable_E_Description__c, Assessment_Variable_F__c, Variable_F_Description__c,
                                                            Assessment_Variable_G__c, Variable_G_Description__c, Assessment_Variable_H__c, Variable_H_Description__c,
                                                            Assessment_Variable_I__c, Variable_I_Description__c, Assessment_Variable_J__c, Variable_J_Description__c,
                                                        (SELECT Id, Name, Description__c, Data_Type__c, Value__c
                                                            FROM Violation_Type_Variables__r
                                                            ORDER BY Name ASC)
                                                    FROM Violation_Type__c
                                                    WHERE Active__c = TRUE
                                                        AND RecordType.DeveloperName = :thisMapping.Violation_Type_Rec_Type__c
                                                    ORDER BY Help_text__c]){
                violationTypesP.add(new ViolationTypeWrapper(violationType, wrapperIndex++));
            }
        }
        return violationTypesP;
    }

    public class violationTypeVarWrapper{
        @AuraEnabled
        public Integer indexCounter { get; set; }
        @AuraEnabled
        public Violation_Type_Variable__c vTypeVar { get; set; }
        @AuraEnabled
        public String varValue { get; set; }
        @AuraEnabled
        public boolean isUserInput { get; set; }
        @AuraEnabled
        public String dataType { get; set; }
        @AuraEnabled
        public String vtvName { get; set; }
        @AuraEnabled
        public String caseIssueVarId {get; set;}
        
        public violationTypeVarWrapper(Violation_Type_Variable__c vtv, Integer wIndex){
            isUserInput = false;
            indexCounter = wIndex;
            vTypeVar = vtv;
            vtvName = vtv.Name;
            dataType = vtv.Data_Type__c;
            if(isLoad == true){
                isUserInput = true;
            }
            if(vtv.Value__c == '{!Input}'){
                    isUserInput = true;
            }
            else if(vtv.Value__c != null){
                    varValue = vtv.Value__c;
            }
        }

        public violationTypeVarWrapper(Violation_Type_Variable__c vtv, Integer wIndex, String caseIssueVarId){
            isUserInput = false;
            indexCounter = wIndex;
            vTypeVar = vtv;
            vtvName = vtv.Name;
            dataType = vtv.Data_Type__c;
            this.caseIssueVarId = caseIssueVarId;
            if(isLoad == true){
                if(vtvName== 'VTV1462' || vtvName== 'VTV1035' || vtvName== 'VTV1034' 
                  || vtvName== 'VTV0056' || vtvName== 'VTV1862' || vtvName== 'VTV1861'
                  || vtvName== 'VTV1036' || vtvName== 'VTV1038' || vtvName== 'VTV1207'
                  || vtvName== 'VTV1037' || vtvName== 'VTV1208' || vtvName== 'VTV1039'
                  || vtvName == 'VTV4316' || vtvName == 'VTV4355' || vtvName == 'VTV4394' 
                  || vtvName == 'VTV0050' || vtvName == 'VTV1611' || vtvName == 'VTV1612' 
                  || vtvName == 'VTV4343' || vtvName == 'VTV4344' || vtvName == 'VTV4382' 
                  || vtvName == 'VTV4383' || vtvName == 'VTV4421' || vtvName == 'VTV4422' 
                  || vtvName == 'VTV1688' || vtvName == 'VTV1503'){
                    isUserInput = false;
                }else{
                    isUserInput = true;
                }
            }
            if(vtv.Value__c == '{!Input}'){
                isUserInput = true;
            }else if(vtv.Value__c != null){
                varValue = vtv.Value__c;
            }
        }
    }

    public class VtModelWrap{
        public List<ViolationTypeWrapper> ViolationTypeWrap;
    }

    public class ViolationTypeWrapper{
        @AuraEnabled
        public decimal subTotalA { get; set; }
        @AuraEnabled
        public decimal subTotalW { get; set; }
        @AuraEnabled
        public decimal subTotalIW { get; set; }
        @AuraEnabled
        public decimal amountPaid = 0;
        @AuraEnabled
        public decimal amountEarned = 0;
        @AuraEnabled
        public Integer indexCounter { get; set; }
        @AuraEnabled
        public String caseIssueId {get; set;}
        @AuraEnabled
        public Violation_Type__c vType { get; set; }
        @AuraEnabled
        public List<Violation_Type_Variable__c> vTypeVars { get; set; }
        @AuraEnabled
        public List<violationTypeVarWrapper> vtvWrapperList { get; set; }
        @AuraEnabled
        public boolean selected { get; set; }
        @AuraEnabled
        public decimal amount { get; set; }
        @AuraEnabled
        public decimal wage { get; set; }
        @AuraEnabled
        public decimal wageinterest { get; set; }
        @AuraEnabled
        public Integer varWrapperIndex;

        @AuraEnabled       
        public string wageformula{
            get{
                if(vType.Wage_Assessment_Formula__c == null){
                    return null;
                }
                return vType.Wage_Assessment_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
            }
        }

        @AuraEnabled
        public string wageinterestformula{
            get{
                if(vType.Wage_Interest_Assessment_Formula__c == null){
                    return null;
                }
                return vType.Wage_Interest_Assessment_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
            }
        }
       
        @AuraEnabled
        public string formula{
            get{
                if(vType.Assessment_Formula__c == null){
                    return null;
                }
                return vType.Assessment_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
            }
        }
        
        @AuraEnabled
        public string amountPaidFormula{
            get{
                if(vType.Amount_Paid_Formula__c == null){
                    return null;
                }
                return vType.Amount_Paid_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
            }
        }
        
        @AuraEnabled
        public string amountEarnedFormula{
            get{
                if(vType.Amount_Earned_Formula__c == null){
                    return null;
                }
                return vType.Amount_Earned_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
            }
        }        
        
        public ViolationTypeWrapper(Violation_Type__c vT, Integer wIndex){
            varWrapperIndex = 1;
            vType = vT;
            indexCounter = wIndex;
            if(!vT.Violation_Type_Variables__r.isEmpty()){
                vTypeVars = vT.Violation_Type_Variables__r;
                if(vtvWrapperList == null){
                    vtvWrapperList = new List<violationTypeVarWrapper>();
                } 
                for(Violation_Type_Variable__c v : vTypeVars){
                    vtvWrapperList.add(new violationTypeVarWrapper(v, varWrapperIndex++));
                }
            }
            if(Test.isRunningTest()){
                selected = true;
            }else{
                selected = false;
            }
        }

        public ViolationTypeWrapper(Violation_Type__c vT, Integer wIndex, Map<String,String> caseIssueMap, Map<String,String> caseIssueVarMap){
            varWrapperIndex = 1;
            vType = vT;
            indexCounter = wIndex;
            this.caseIssueId = caseIssueMap.get(vT.Id);
            if(!vT.Violation_Type_Variables__r.isEmpty()){
                vTypeVars = vT.Violation_Type_Variables__r;
                if(vtvWrapperList == null){
                    vtvWrapperList = new List<violationTypeVarWrapper>();
                }
                for(Integer i = 0; i < vTypeVars.size(); i++){
                    vtvWrapperList.add(new violationTypeVarWrapper(vTypeVars[i], varWrapperIndex++, caseIssueVarMap.get(vTypeVars[i].Id)));
                }
            }

            if(Test.isRunningTest()){
                selected = true;
            }else{
                selected = false;
            }
        }

        public ViolationTypeWrapper(Violation_Type__c vT, Integer wIndex, String caseIssueId, Map<String,String> caseIssueVarMap){
            varWrapperIndex = 1;
            vType = vT;
            indexCounter = wIndex;
            this.caseIssueId = caseIssueId;
            if(!vT.Violation_Type_Variables__r.isEmpty()){
                vTypeVars = vT.Violation_Type_Variables__r;
                if(vtvWrapperList == null){
                    vtvWrapperList = new List<violationTypeVarWrapper>();
                    for(Integer i=0;i<vTypeVars.size();i++){
                        vtvWrapperList.add(new violationTypeVarWrapper(vTypeVars[i], varWrapperIndex++, caseIssueVarMap.get(vTypeVars[i].Id)));   
                    }
                }
            }
            if(Test.isRunningTest()){
                selected = true;
            }else{
                selected = false;
            }
        }
    }
    
    @AuraEnabled
    public Boolean SelectTypeExist {get;set;}


    @AuraEnabled
    public static List<ViolationTypeWrapper> addViolation(String caseId, String violationId){

        List<ViolationTypeWrapper> ViolationsTypes = ViolationsTypes(caseId);

        if(violationId == 'LC 3710.1'){
            for(ViolationTypeWrapper vtw : ViolationsTypes){
                if(vtw.vType.RecordType.DeveloperName.contains('BOFE') && 
                        vtw.vType.Civil_Penalty_Section__c == 'LC 3710.1' && 
                        vtw.vType.Violation_Type__c == 'BOFE 336'){
                    selectedTypes.add(new ViolationTypeWrapper(vtw.vType, wrapperIndex++));
                }
            }
        }else{
            for(ViolationTypeWrapper vtw : ViolationsTypes){
                if(violationId == vtw.vType.Id){
                    selectedTypes.add(new ViolationTypeWrapper(vtw.vType, wrapperIndex++));
                }
            }
        }
        return selectedTypes;
    }


    public class LiabilityWrapper {
        @AuraEnabled
        public Contact cnt { get; set; }
        @AuraEnabled
        public Account acc { get; set; }
        @AuraEnabled
        public boolean selected { get; set; }
        @AuraEnabled
        public string Affiliation { get; set; }
        @AuraEnabled
        public string propShare { get; set; }
        @AuraEnabled
        public Liability__c thisLiab { get; set; }
        @AuraEnabled
        public Liable_Party__c thisLiabParty { get; set; }
        @AuraEnabled
        public Case_Role__c thisCR {get;set;}
        
        @AuraEnabled
        public Id AccountId{
            get{
                if(acc != null){
                    return acc.Id;
                }
                if(cnt != null){
                    return cnt.AccountId;
                }
                return null;
            }
        }
        @AuraEnabled
        public string Name {
            get{
                if(acc != null){
                    return acc.Name;
                }
                if(cnt != null){
                    return cnt.Name;
                }
                return null;
            }
        }
    
        public LiabilityWrapper(Contact cnt1, string aff, Map<String, RecordType> rtMap){
            propShare = '100';
            cnt = cnt1;

            if(Test.isRunningTest()){
                selected = true;
            }else{
                selected = false;
            }
            
            Affiliation = aff;
            thisLiab = new Liability__c(
                recordTypeId = rtMap.get('Liability__c').Id
            );
            thisLiabParty = new Liable_Party__c(
                recordTypeId = rtMap.get('Liable_Party__c').Id
            );
        }
        
        public LiabilityWrapper(Case_Role__c cr, Map<String, RecordType> rtMap){
            propShare = '100';
            thisCR = cr;
            acc = cr.Entity__r;

            if(Test.isRunningTest()){
                selected = true;
            }else{
                selected = false;
            }
            
            Affiliation = cr.Role__c;
            thisLiab = new Liability__c(
                recordTypeId = rtMap.get('Liability__c').Id
            );
            thisLiabParty = new Liable_Party__c(
                recordTypeId = rtMap.get('Liable_Party__c').Id
            );
        }
    }
    

    //OnLoad Cases method
    @AuraEnabled(cacheable=true)
    public static List<ViolationTypeWrapper> caseIssue(String caseId){
       //saveVarValues();
       
       List<Record_Type_Mapping__c>  rtMappings = Record_Type_Mapping__c.getAll().values();
        
        DIR_Case__c dirCase = [SELECT Employer__c, Case_Number__c,NAICS_Code__c,DLSE_Program__c,Employer_Industry__c,
                                Record_Type_Text__c, Employer__r.Name, RecordType.DeveloperName, Violation_Type__c
                            FROM DIR_Case__c 
                            WHERE Id = :caseId];

        if(violationTypesP == null){
            for(Record_Type_Mapping__c v : rtMappings){
                if(v.Case_Rec_Type__c == dirCase.RecordType.DeveloperName){
                        thisMapping = v;
                        break;
                }
            }

            if(thisMapping == null){
                rtError = true;
                return null;
            }
            
            List<DIR_Violation__c> viol = [SELECT Id,RecordTypeId, Name, Case__c,Penalty_Assessment_Description__c,
                                                Wage_Assessment_Description__c,Original_Penalty_Assessment_Amount__c,
                                                Citation_Amount__c,Original_Wage_Assessment_Amount__c,Wages_Due__c,
                                                Amount_Paid__c,Amount_Earned__c,Total_Wage_Interest_Amount__c,Status__c,
                                                Violation_Type__c,
                                                (SELECT Id, Violation_Type_Variable__r.Description__c, Value__c, Violation_Type_Variable__c
                                                    FROM Violation_Variables__r ) 
                                            FROM DIR_Violation__c 
                                            WHERE Status__c = 'Hold' 
                                                AND Case__c = :caseId];
        
            Map<String,Violation_Variable__c> vMap = new Map<String,Violation_Variable__c>();
            Map<String,String> caseIssueMap = new Map<String,String>();
            Set<String> vtIdSet = new Set<String>();                        
            //for(DIR_Violation__c vio : viol){  
            for(Integer i = 0; i < viol.size(); i++){
                caseIssueMap.put(viol[i].Violation_Type__c + ':' + i,viol[i].Id); 
                vtIdSet.add(viol[i].Violation_Type__c);       
                //for(Violation_Variable__c vVar : viol[i].Violation_Variables__r ){
                for(Integer j = 0; j < viol[i].Violation_Variables__r.size(); j++){  
                    vMap.put(viol[i].Violation_Variables__r[j].Violation_Type_Variable__c + ':' + i + '' + j,viol[i].Violation_Variables__r[j]);                
                }
            }     
        
            Map<String,Violation_Type__c> vTypes = 
                new Map<String, Violation_Type__c>([SELECT Id, Name, Violation_Text__c, Assessment_Formula__c, Violation_Type__c, Help_Text__c, Penalty_Assessment_Description__c, 
                                                            Civil_Penalty_Section__c, Wage_Assessment_Formula__c, Wage_Assessment_Description__c, RecordType.DeveloperName, Short_Description__c,
                                                            Amount_Paid_Formula__c, Amount_Earned_Formula__c, Wizard_Search_Text__c, Wage_Interest_Assessment_Formula__c, Wage_Interest_Assessment_Description__c,
                                                            Assessment_Variable_A__c, Variable_A_Description__c, Assessment_Variable_B__c, Variable_B_Description__c,
                                                            Assessment_Variable_C__c, Variable_C_Description__c, Assessment_Variable_D__c, Variable_D_Description__c,
                                                            Assessment_Variable_E__c, Variable_E_Description__c, Assessment_Variable_F__c, Variable_F_Description__c,
                                                            Assessment_Variable_G__c, Variable_G_Description__c, Assessment_Variable_H__c, Variable_H_Description__c,
                                                            Assessment_Variable_I__c, Variable_I_Description__c, Assessment_Variable_J__c, Variable_J_Description__c,
                                                            (SELECT Id, Name, Description__c, Data_Type__c, Value__c
                                                                FROM Violation_Type_Variables__r
                                                                ORDER BY Name ASC)
                                                        FROM Violation_Type__c 
                                                        WHERE Id = :vtIdSet 
                                                        ORDER BY Help_Text__c]);

            violationTypesP = new List<ViolationTypeWrapper>();

            for(DIR_Violation__c vtw : viol){            
                Map<String, Violation_Variable__c> violationVarMap = new Map<String, Violation_Variable__c>();
                Map<String, String> caseIssueTypeMap = new Map<String, String>();
                Map<String, String> caseIssueTypeVarMap = new Map<String, String>();
                String vTId = vtw.Violation_Type__c;
                if(vTypes != null){
                    if(vTypes.containsKey(vTId)){
                        String caseIssueId = vtw.Id;

                        for(Violation_Variable__c vVar : vtw.Violation_Variables__r ){
                            caseIssueTypeVarMap.put(vVar.Violation_Type_Variable__c,vVar.Id);
                            violationVarMap.put(vVar.Violation_Type_Variable__c,vVar);
                        }

                        /*
                        //Dishant
                        for(Violation_Type_Variable__c vtv : vTypes.get(vTId).Violation_Type_Variables__r ){
                            String caseIssueVarId;
                            if(vMap.containsKey(vtv.IdvTId + ':' + i + '' + j)){
                                vtv.Value__c  = vMap.get(vtv.Id + ':' + i + '' + j).Value__c;
                                caseIssueVarId = vMap.get(vtv.Id + ':' + i + '' + j).Id;
                                caseIssueTypeVarMap.put(vtv.Id + ':' + i + '' + j,caseIssueVarId);
                            }else{
                                vtv.Value__c  = '';
                                //caseIssueVarId = vMap.get(vtv.Id).Id;
                            }
                        } */

                        for(Violation_Type_Variable__c vtv : vTypes.get(vTId).Violation_Type_Variables__r ){
                            
                            String caseIssueVarId;
                            if(caseIssueTypeVarMap.containsKey(vtv.Id)){
                                vtv.Value__c  = violationVarMap.get(vtv.Id).Value__c;
                                caseIssueVarId = violationVarMap.get(vtv.Id).Id;
                                //caseIssueTypeVarMap.put(vtv.Id,caseIssueVarId);
                            }else{
                                vtv.Value__c  = '';
                                //caseIssueVarId = vMap.get(vtv.Id).Id;
                            }
                        }

                        if(vTypes.get(vTId).RecordType.DeveloperName == thisMapping.Violation_Type_Rec_Type__c){
                            isLoad = true;
                            String vTypeJson = Json.serialize(vTypes.get(vTId));
                            Violation_Type__c vType = (Violation_Type__c)Json.deserialize(vTypeJson, Violation_Type__c.Class);
                            violationTypesP.add(new ViolationTypeWrapper(vType, wrapperIndex++,caseIssueId,caseIssueTypeVarMap));
                        }
                    }
                }
            }
        }   
        return violationTypesP;
    } 

    //Liablility
    public static List<LiabilityWrapper> liabilitiesP;
    @AuraEnabled(cacheable=true)
    public static List<LiabilityWrapper> Liabilities(String caseId){
        DIR_Case__c dirCase = [SELECT Employer__c, Id, Case_Number__c, NAICS_Code__c, DLSE_Program__c, Employer_Industry__c,
                                    Record_Type_Text__c, Employer__r.Name, RecordType.DeveloperName, Violation_Type__c 
                                FROM DIR_Case__c 
                                WHERE Id = :caseId];
            
        if(liabilitiesP == null){
            liabilitiesP = new List<LiabilityWrapper>();

            List<Case_Role__c> liableCaseRoles = [SELECT Id, Name, Role__c, Entity__c, Entity__r.Name, Case__c, Case__r.Name
                                                    FROM Case_Role__c 
                                                    WHERE Case__c = :dirCase.Id 
                                                        AND Eligible_for_Liability__c = True];
            for (Case_Role__c liableCaseRole : liableCaseRoles) {
                if (liableCaseRole.Entity__c != null)
                    liabilitiesP.add(new LiabilityWrapper(liableCaseRole, getRecordTypes(dirCase)));
            }
        }
        return liabilitiesP;
    }


    //Save Value method
    @AuraEnabled(cacheable=true)
    public static String saveVarValues(String valueString){
        String paramStr = '';
        if(valueString != null && valueString.trim().length() != 0){
            List<String> strList = valueString.split('::');
            for(String s : strList){
                List<String> itemList = s.split(':');
                if(!itemList[0].Contains('TOTAL') && !itemList[0].Contains('AMT')){
                    String pString;
                    String cString;
                    for(ViolationTypeWrapper vt : selectedTypes){
                        Integer counterLength = string.valueOf(vt.indexCounter).length();
                        pString = itemList[0].subString(0,counterLength);
                        cString = itemList[0].subString(counterLength,itemList[0].length());
                        if(vt.indexCounter == integer.valueOf(pString)){
                            for(violationTypeVarWrapper vtv : vt.vtvWrapperList){
                                if(vtv.indexCounter == integer.valueOf(cString)){
                                    vtv.varValue = (itemList[1] == null || itemList[1].trim() == '') ? '0' : itemList[1] != vtv.varValue ? itemList[1] : vtv.varValue;
                                    paramStr += vtv.varValue;
                                }
                            }
                        }
                    }
                }else{
                    String n;
                    boolean isW = false;
                    boolean isIW = false;
                    boolean isA = false;
                    boolean isAP = false;
                    boolean isAE = false;
                    if(itemList[0].Contains('TOTALA')){
                        n = itemList[0].replace('TOTALA', '');
                        isA = true;
                    }else if(itemList[0].Contains('TOTALW')){
                        n = itemList[0].replace('TOTALW', '');
                        isW = true;
                    }else if(itemList[0].Contains('TOTALIW')){
                        n = itemList[0].replace('TOTALIW', '');
                        isIW = true;
                    }else if(itemList[0].Contains('AMTP')){
                        n = itemList[0].replace('AMTP', '');
                        isAP = true;
                    }else if(itemList[0].Contains('AMTE')){
                        n = itemList[0].replace('AMTE', '');
                        isAE = true;
                    }

                    for(ViolationTypeWrapper vt : selectedTypes){
                        if(vt.indexCounter == integer.valueOf(n)){
                            Decimal amt;
                            try{
                                amt = Decimal.valueOf(itemList[1]);
                            }catch(exception e){ //isNaN or Infinity
                                amt = 0;
                            }
                            
                            if(isA){
                                vt.subTotalA = amt;
                            }else if(isW){
                                vt.subTotalW = amt;
                            }else if(isIW){
                                vt.subTotalIW = amt;
                            }else if(isAP){
                                vt.amountPaid = amt;
                            }else if(isAE){
                                vt.amountEarned = amt;
                            }
                        }
                    }
                }
            }
        }

        return paramStr;
    }

    
    public static string ParseExplanation(ViolationTypeWrapper vtw, String assessDesc){
        string retValue = assessDesc;
        if(retValue == null){
            return null;
        }
            
        while(retValue.contains('{') && retValue.contains('}')){
            string toCalculate = retValue.subString(retValue.indexOf('{') + 1, retValue.indexOf('}'));
            
            decimal valuesofar;
            decimal operand;
            string operator;
            
            integer position = 0;
            
            while(position < toCalculate.length()){
                if(toCalculate.subString(position, position + 1) == '~'){
                    string var = toCalculate.subString(position, position + 9);
                    for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
                        var = var.replace('~', '');
                        if(var == vtv.vtvName){
                            if(String.isBlank(vtv.varValue)){
                                    vtv.varValue = '0';
                            }
                            operand = Decimal.valueOf(vtv.varValue);
                            String identifier = String.valueOf(vtw.indexCounter) + String.valueOf(vtv.indexCounter);
                            
                            if(valuesofar == null){
                                valuesofar = operand;
                            }else{
                                if(operator == '*'){
                                    valuesofar *= operand;
                                }
                                if(operator == '-'){
                                    valuesofar -= operand;

                                }
                                if(operator == '+'){
                                    valuesofar += operand;
                                }
                                if(operator == '/'){
                                    valuesofar /= operand;
                                }
                            }
                            position += 9;
                        }
                    }
                }else{
                    operator = toCalculate.subString(position, position + 1);
                    position += 1;
                }
            }
            retValue = retValue.substring(0, retValue.indexOf('{')) + valuesofar.setScale(2, system.RoundingMode.HALF_UP).format() + retValue.substring(retValue.indexOf('}') + 1);
        }
        for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
            if(vtv.varValue != null){
                String var = '~'+vtv.vtvName+'~';
                retValue = retValue.Replace(var, string.valueOf(vtv.varValue));
            }
        }
        return retValue;
    }

    public class LiabModelWrap{
        public List<LiabilityWrapper> LiabilityWrap;
    }

    //Final Method
    @AuraEnabled
    public static List<Violation_Variable__c> Finalize(String caseId, String valueString, String SelTypesList, String LiabStringfy, String SelectedCitation){
        
        DIR_Case__c dirCase = [SELECT Employer__c,Id,Case_Number__c,NAICS_Code__c,DLSE_Program__c,Employer_Industry__c,
                                    Record_Type_Text__c, Employer__r.Name, RecordType.DeveloperName,Violation_Type__c 
                                FROM DIR_Case__c 
                                WHERE Id = :caseId];
        
        Record_Type_Mapping__c rtMapping = getRecordTypeMapping(dirCase);
        
        RecordType violRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Violation__c' AND DeveloperName = :rtMapping.Case_Violation_Rec_Type__c LIMIT 1];
        Integer counter = 0;

        VtModelWrap selData = (VtModelWrap)JSON.deserialize(SelTypesList, VtModelWrap.class);

        LiabModelWrap Liab = (LiabModelWrap)JSON.deserialize(LiabStringfy, LiabModelWrap.class);
        
        for(LiabilityWrapper lw : Liab.LiabilityWrap){
            if(lw.selected){
                counter++;
            }
        }

        Map<String, List<ViolationTypeWrapper>> vTypeMap = new Map<String, List<ViolationTypeWrapper>>();
        for(ViolationTypeWrapper vTypeW : selData.ViolationTypeWrap){
            if(!vTypeMap.containsKey(vTypeW.vType.Violation_Type__c)){
                vTypeMap.put(vTypeW.vType.Violation_Type__c, new List<ViolationTypeWrapper>{vTypeW});
            }else{
                vTypeMap.get(vTypeW.vType.Violation_Type__c).add(vTypeW);
            }
        }

        List<Assessments__c> assessList = new List<Assessments__c>();
        List<DIR_Violation__c> violList = new List<DIR_Violation__c>();
        List<Violation_Variable__c> vvList = new List<Violation_Variable__c>();
        List<DIR_Employee__c> employees = [SELECT Id FROM DIR_Employee__c WHERE User__c = :UserInfo.getUserId() AND (Position__c = 'Deputy' OR Position__c = 'Senior Deputy')];
        DIR_Violation__c violRec = new DIR_Violation__c();
        
        Map<Integer, List<Violation_Variable__c> > vtvIndexMap = new Map<Integer, List<Violation_Variable__c> >();
        Map<Integer, DIR_Violation__c > vtIndexMap = new Map<Integer, DIR_Violation__c >();
        
        for(String key : vTypeMap.keySet()){
            Assessments__c assess = new Assessments__c(
                    Case_Management__c = dirCase.Id,
                    Appeal_Deadline_Selector__c = 'Business Days',
                    Citation_Form__c = key,
                    Total_Wages_assessed__c = 0
            );
            assessList.add(assess);
            decimal assessTotal = 0;
            Integer i = 0;
            for(ViolationTypeWrapper vtw : vTypeMap.get(key)){
                i++;

                DIR_Violation__c viol = new DIR_Violation__c(
                   Assessment__r = assess,
                    //Assessment__r = assessMap.get(vt.Citation_Form__c),
                    RecordTypeId = violRT.Id,
                    Status__c = 'Open',
                    Case__c = dirCase.Id,
                    Violation_Type__c = vtw.vType.Id,
                    Penalty_Assessment_Description__c = ParseExplanation(vtw, vtw.vType.Penalty_Assessment_Description__c),
                    Wage_Assessment_Description__c = ParseExplanation(vtw, vtw.vType.Wage_Assessment_Description__c),
                    Original_Penalty_Assessment_Amount__c = vtw.subTotalA == null ? 0 : vtw.subTotalA,
                    //viol.Citation_Amount__c = vtw.amount,
                    //viol.Original_Penalty_Assessment_Amount__c = vtw.amount
                    Citation_Amount__c = vtw.subTotalA == null ? 0 : vtw.subTotalA,
                    Original_Wage_Assessment_Amount__c = vtw.subTotalW == null ? 0 : vtw.subTotalW,
                    Wages_Due__c = vtw.subTotalW == null ? 0 : vtw.subTotalW,
                    Amount_Paid__c = vtw.amountPaid == null ? 0 : vtw.amountPaid,
                    Amount_Earned__c = vtw.amountEarned == null ? 0 : vtw.amountEarned,
                    Total_Wage_Interest_Amount__c = vtw.subTotalIW == null ? 0 : vtw.subTotalIW
                );
                if(vtw.caseIssueId != null){
                    viol.Id = vtw.caseIssueId;
                }
                if(employees.size() == 1){
                    viol.DIR_Employee__c = employees[0].Id;
                }
                Set<String> existingvvset = new Set<String>();

                for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
                    
                    /*
                    if(vtv.caseIssueVarId != null && existingvvset.contains(vtv.caseIssueVarId)){
                        continue;
                    } */

                    Violation_Variable__c vv = new Violation_Variable__c(                      
                        Case_Violation__r = viol,
                        Violation_Type_Variable__c = vtv.vTypeVar.Id,
                        Value__c = vtv.varValue   
                    );
                    //vvList.add(vv);

                    if(vtw.caseIssueId != null){
                        vv.Case_Violation__c = vtw.caseIssueId;
                    }
                    if(vtv.caseIssueVarId != null){
                        vv.Id = vtv.caseIssueVarId;existingvvset.add(vv.Id);
                    }
                    if(vtvIndexMap.containsKey(i)){
                        vtvIndexMap.get(i).add(vv);
                    }else{
                        vtvIndexMap.put(i, new List<Violation_Variable__c>{vv});
                    }
                }
                vtIndexMap.put(i, viol);
                violList.add(viol);
            }
        }
        upsert assessList;

        for(DIR_Violation__c viol : violList){
            viol.Assessment__c = viol.Assessment__r.Id;
        }
        upsert violList;
        
        for(Violation_Variable__c vv : vvList){
            vv.Case_Violation__c = vv.Case_Violation__r.Id;
        }
        for(Integer index : vtvIndexMap.keyset()){
            for(Violation_Variable__c vtv: vtvIndexMap.get(index)){
                vtv.Case_Violation__c = vtIndexMap.get(index).id;
                vvList.add(vtv);
            }
        }
        upsert vvList;

        if(SelectedCitation == 'Single Citation One Number'){
            List<Liability__c> liabList = new List<Liability__c>();
            for(Assessments__c assesss : assessList){
                Liability__c newLiab = new Liability__c();
                newLiab.Assessment__c = assesss.Id;
                newLiab.Case_Management__c = dirCase.Id;
                //newLiab.Legal_Consult__c = dirCase.Employer__c;
                newLiab.RecordTypeId = getRecordTypes(dirCase).get('Liability__c').Id;
                liabList.add(newLiab);
            }
            upsert liabList;

            List<Liable_Party__c> liablePartyList = new List<Liable_Party__c>();
            for (Liability__c liability : liabList) {
                for (LiabilityWrapper lw : Liab.LiabilityWrap) {
                    if (lw.selected) {
                        Liable_Party__c liableParty = new Liable_Party__c();
                        liableParty.RecordTypeId = lw.thisLiabParty.RecordTypeId;
                        liableParty.Basis_for_Liability__c = lw.thisLiabParty.Basis_for_Liability__c;
                        liableParty.Liability__c = liability.Id;
                        liableParty.Proportionate_Share__c = lw.propShare == null ? 100 : Decimal.valueOf(lw.propShare);
                        liableParty.Entity__c = lw.AccountId;
                        liableParty.Case_Role__c = lw.thisCR.Id;
                        liablePartyList.add(liableParty);
                    }
                }
            }
            upsert liablePartyList;
        }else{
            List<Liability__c> liabList = new List<Liability__c>();
            List<Liable_Party__c> liablePartyList = new List<Liable_Party__c>();
            for (Assessments__c assesssss : assessList) {
                for (LiabilityWrapper lw : Liab.LiabilityWrap) {
                    if (lw.selected) {
                        Liability__c lia = new Liability__c();
                        lia.RecordTypeId = lw.thisLiab.RecordTypeId;
                        lia.Assessment__c = assesssss.Id;
                        lia.Case_Management__c = dirCase.Id;
                        //lia.Legal_Consult__c = dirCase.Employer__c;
                        liabList.add(lia);
                        Liable_Party__c liableParty = new Liable_Party__c();
                        liableParty.RecordTypeId = lw.thisLiabParty.RecordTypeId;
                        liableParty.Basis_for_Liability__c = lw.thisLiabParty.Basis_for_Liability__c;
                        liableParty.Liability__r = lia;
                        liableParty.Entity__c = lw.AccountId;
                        liableParty.Case_Role__c = lw.thisCR.Id;
                        liableParty.Proportionate_Share__c = lw.propShare == null ? 100 : Decimal.valueOf(lw.propShare);
                        liablePartyList.add(liableParty);
                    }
                }
            }
            upsert liabList;

            for(Liable_Party__c liableParty : liablePartyList){
                liableParty.Liability__c = liableParty.Liability__r.Id;
            }
            upsert liablePartyList;
        }        
        return vvList;
    }
}