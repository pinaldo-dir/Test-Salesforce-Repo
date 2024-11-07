public without sharing class MeetingDetailsController {
    @AuraEnabled 
    public static Map<String,Object> getMeetingDetails(){
        Map<String,Object> response = new Map<String,Object>();
        String communityAccountId;
        //User user = [SELECT Id,AccountId FROM User WHERE Id=:UserInfo.getUserId()];
        if(OWCConstants.ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID != null && userInfo.getProfileId() == OWCConstants.ONLINE_CLAIM_COMMUNITY_USER_PROFILE_ID){
                communityAccountId = [SELECT Id, ContactId, AccountId, Profile.Name FROM User 
                                      WHERE Id =: userInfo.getUserId() LIMIT 1].AccountId;
            }
        Set<Id> meetingIds = new Set<Id>();
        for(Meeting_Participant__c participant : [SELECT Meeting__c 
                                                FROM Meeting_Participant__c 
                                                WHERE Case_Role__r.Community_User_Account__c =:communityAccountId
                                                AND Meeting__r.Status__c!= 'New' 
                                                AND Meeting__r.Meeting_Start_Date_Time__c!= NULL
                                                ]){
            meetingIds.add(participant.Meeting__c);
        } 
        system.debug('meetingIds: '+meetingIds);
        if(meetingIds.size() > 0){
            String queryString = 'SELECT Id';
            for(Schema.FieldSetMember fld :SObjectType.Hearing__c.FieldSets.Details.getFields()) {
                queryString += ', ' + fld.getFieldPath();
            } 
            queryString += ', Video_Meeting_Information__c, Audio_telephone__c, Video_Meeting_URL__c';
            queryString += ' FROM Hearing__c WHERE Id IN :meetingIds ORDER BY Meeting_Start_Date_Time__c';
            response.put('records',Database.query(queryString));
        }
        system.debug('response:'+response);
        return response;
    }
}