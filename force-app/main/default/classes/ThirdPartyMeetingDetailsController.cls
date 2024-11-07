public class ThirdPartyMeetingDetailsController {
    public static List<OWCThirdPartyModel.MeetingDetailsWrapper> getMeetingDetails(String communityUserId, String claimantLastName, String caseNumber){
        List<OWCThirdPartyModel.MeetingDetailsWrapper> meetingDetails = new List<OWCThirdPartyModel.MeetingDetailsWrapper>();
        Map<String,Object> response = new Map<String,Object>();
        User user = [SELECT Id,AccountId FROM User WHERE Id=:communityUserId];
        Set<Id> meetingIds = new Set<Id>();
        System.debug('user accountId ::: '+user.AccountId);
        System.debug('claimantLastName ::: '+claimantLastName);
        for(Meeting_Participant__c participant : [SELECT Meeting__c 
                                                  FROM Meeting_Participant__c 
                                                  WHERE Case_Role__r.Community_User_Account__c =:user.AccountId
                                                  AND Case_Role__r.Entity__r.LastName =: claimantLastName
                                                  AND Meeting__r.Status__c!= 'New'
                                                  AND Meeting__r.Meeting_Start_Date_Time__c!= NULL
                                                 ]){
            meetingIds.add(participant.Meeting__c);
        } 
        if(meetingIds.size() > 0){
            String queryString = 'SELECT Id';
            for(Schema.FieldSetMember fld :SObjectType.Hearing__c.FieldSets.Details.getFields()) {
                queryString += ', ' + fld.getFieldPath();
            } 
            queryString += ', Video_Meeting_Information__c, Audio_telephone__c, Video_Meeting_URL__c';
            queryString += ' FROM Hearing__c WHERE Id IN :meetingIds AND Case__r.Case_Number__c =: caseNumber ORDER BY Meeting_Start_Date_Time__c';
            List<Hearing__c> hearingRecs = Database.query(queryString);
            for(Hearing__c hearingObj : hearingRecs){
                OWCThirdPartyModel.MeetingDetailsWrapper meetingDetailObj = new OWCThirdPartyModel.MeetingDetailsWrapper();
                meetingDetailObj.caseNumber = hearingObj.Case__r.Case_Number__c;
                meetingDetailObj.meeting = hearingObj.RecordType.Name;
                meetingDetailObj.meetingTime = hearingObj.Calendar_Date_Time_Start__c.indexOf('-') >0? hearingObj.Meeting_Start_Date__c +' '+hearingObj.Meeting_Start_Time_OC__c : hearingObj.Calendar_Date_Time_Start__c;
                meetingDetailObj.type = hearingObj.Meeting_Type__c;
                meetingDetailObj.status = hearingObj.Status__c;
                meetingDetailObj.videoUrl = hearingObj.Video_Meeting_URL__c;
                meetingDetailObj.passcodeAndMeetingId = hearingObj.Video_Meeting_Information__c;
                meetingDetailObj.audioTelephone = hearingObj.Audio_telephone__c;
                meetingDetails.add(meetingDetailObj);
            }
        }
        return meetingDetails;
    }
}