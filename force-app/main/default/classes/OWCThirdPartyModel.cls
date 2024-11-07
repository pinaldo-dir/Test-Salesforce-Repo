public class OWCThirdPartyModel {
    public class NewClaimResponseWrapper{
        public String message;
        public Boolean isSuccess;
        public String caseNumber;
    }
    public class ClaimantConfirmUploadResponseWrapper{
        public String message;
        public Boolean isSuccess;
        public String documentId;
        public String districtOffice;
        public String officeEmail;
    }
    public class MeetingDetailResponseWrapper{ 
        public String message;
        public Boolean isSuccess;
        public List<OWCThirdPartyModel.MeetingDetailsWrapper> hearingDetails;
    } 
    public class MeetingDetailsWrapper{
        public String caseNumber;
        public String meeting;
        public String meetingTime;
        public string type;
        public String status;
        public String videoUrl;
        public String passcodeAndMeetingId;
        public String audioTelephone;
    }
    public class createFileResponseWrapper{
        public Boolean isSuccess;
        public String documentId;
        public String message;
    }
}