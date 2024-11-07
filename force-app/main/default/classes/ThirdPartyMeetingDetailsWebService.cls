/*
* Name: ThirdPartyMeetingDetailsWebService
* Description: Used to get the meeting or hearing details to send third party.
* Primary Record: Meeting
* Related Records: Meeting Participants, Hearing
*/ 
@RestResource(urlMapping='/HearingDetails/*')
global class ThirdPartyMeetingDetailsWebService {
    public static String communityUserId;
    public static String caseNumber;
    public static String claimantLastName;
    public static String fieldValidationError;
    @HttpPost
    global static void getHearingDetails(){
        OWCThirdPartyModel.MeetingDetailResponseWrapper responseWrapObj = new OWCThirdPartyModel.MeetingDetailResponseWrapper();
        RestRequest responseObj = RestContext.request;
        String requestBody = responseObj.requestBody.toString();
        try{
            if(String.isNotBlank(requestBody)){
                //Deserialize the third party response here.
                Map<String, Object> responseWrapper = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
                caseNumber = (String) responseWrapper.get('caseNumber');
                claimantLastName = (String) responseWrapper.get('claimantLastName');
                communityUserId = (String) responseWrapper.get('communityUserId');
                
                //Validate third party response
                OWCThirdPartyValidationCheckerController.validateMeetingAPIResponse(caseNumber, claimantLastName, communityUserId);
                if(String.isNotBlank(fieldValidationError)){
                    responseWrapObj.isSuccess = false;
                    responseWrapObj.message = fieldValidationError;
                }
                else{
                    List<OWCThirdPartyModel.MeetingDetailsWrapper> hearingDetails = ThirdPartyMeetingDetailsController.getMeetingDetails(communityUserId, claimantLastName, caseNumber);
                    if(hearingDetails == null || hearingDetails.size() == 0){
                        responseWrapObj.isSuccess = false;
                        responseWrapObj.message = ThirdPartyErrorMsgConstants.meetingsAndHearingMsg(caseNumber);
                    }
                    else{
                        responseWrapObj.isSuccess = true;
                        responseWrapObj.message = 'Success';
                        responseWrapObj.hearingDetails = hearingDetails;
                    }
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