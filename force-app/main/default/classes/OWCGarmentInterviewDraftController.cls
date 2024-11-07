public class OWCGarmentInterviewDraftController {
    @AuraEnabled
    public static garmentWrapperObj updateCaseRecWithJSON(String recordId, String onlineClaimDetails){
        garmentWrapperObj serverWrapObj = new garmentWrapperObj();
        try{
            if(String.isNotBlank(recordId)){
                serverWrapObj.recordId = recordId;
                DIR_Case__c caseObj = [SELECT Id, Garment_Interview_JSON__c FROM DIR_Case__c WHERE Id =: recordId LIMIT 1];
                if(String.isNotBlank(caseObj.Garment_Interview_JSON__c)){
                    serverWrapObj.serverMsg = 'Your Draft has been successfully updated.';
                }
                else{
                    serverWrapObj.serverMsg = 'Your Draft has been successfully created.';
                }
                caseObj.Garment_Interview_JSON__c = onlineClaimDetails;
                serverWrapObj.isSuccess = true;
                System.debug('caseObj ::: '+caseObj.Garment_Interview_JSON__c);
                update caseObj;
            }
            else{
                serverWrapObj.isSuccess = false;
                serverWrapObj.recordId = recordId;
            }
            return serverWrapObj;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* this method is being used for getting the garment json response */
    @AuraEnabled(cacheable=true)
    public static garmentWrapperObj getOWCGarmentJSONResponse(String recordId){
        try {
            garmentWrapperObj garmentObj = new garmentWrapperObj();
            
            DIR_Case__c garmentResponse = [SELECT Id, Name, OWC_JSON__c, Garment_Interview_JSON__c FROM DIR_Case__c WHERE Id =: recordId LIMIT 1];
            
            garmentObj.recordId = recordId;
            if(String.isNotBlank(garmentResponse.Garment_Interview_JSON__c)){
                garmentObj.jsonObj = garmentResponse.Garment_Interview_JSON__c;
                garmentObj.isSuccess = true;
            }else if(String.isNotBlank(garmentResponse.OWC_JSON__c)){
                garmentObj.jsonObj = garmentResponse.OWC_JSON__c;
                garmentObj.isSuccess = true;
            }else{
                garmentObj.isSuccess = false;
            }
            System.debug('garmentObj ::: '+garmentObj);
            return garmentObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class garmentWrapperObj{
        @AuraEnabled
        public String serverMsg{get;set;}
        @AuraEnabled
        public boolean isSuccess{get;set;}
        @AuraEnabled
        public String recordId{get;set;}
        @AuraEnabled
        public String jsonObj{get;set;}
    }
}