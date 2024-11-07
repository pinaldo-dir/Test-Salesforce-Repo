@RestResource(urlMapping='/Owcwebserviceapi/*')
global with sharing class OnlineWageClaimThirdPartyWebService {
    public static String fieldValidationError;
    @HttpPost
    global static void getResponce(){
        OWCThirdPartyModel.NewClaimResponseWrapper responseWrapObj = new OWCThirdPartyModel.NewClaimResponseWrapper();
        RestRequest responseObj = RestContext.request;
        String requestBody = responseObj.requestBody.toString();
        
        try{
            String caseId = OnlineWageClaimThirdPartyAPIController.onlineClaimSubmit(requestBody);
            System.debug('caseId::::::'+caseId);
            System.debug('fieldValidationError::::::'+fieldValidationError);
            if(String.isNotBlank(fieldValidationError)){
                responseWrapObj.message = fieldValidationError;
                responseWrapObj.isSuccess = false;
            }
            else{
                DIR_Case__c caseObj = [SELECT Id, Office__r.Name, Office__r.Office_Email__c, Case_Number__c FROM DIR_Case__c
                                       WHERE Id =: caseId LIMIT 1];
                if(String.isNotBlank(caseId)){
                    responseWrapObj.isSuccess = true;
                    responseWrapObj.message = 'Success';
                    responseWrapObj.caseNumber = caseObj.Case_Number__c;
                    //responseWrapObj.districtOffice = caseObj.Office__r.Name;
                    //responseWrapObj.officeEmail = caseObj.Office__r.Office_Email__c;
                }
                else{
                    responseWrapObj.isSuccess = false;
                    responseWrapObj.message = 'Something went wrong...';
                }
            }
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseWrapObj));
        }
        catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'text/plain');
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}