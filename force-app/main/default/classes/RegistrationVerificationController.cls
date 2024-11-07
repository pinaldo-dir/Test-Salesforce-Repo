public without sharing class RegistrationVerificationController {
    
    public Id regId {get;set;}
    public String businessName{get;set;}
    public String emailAddress{get;set;}
    public static RegistrationVerificationController classInstance = null;
    
    private static Boolean stopEWPRecursion {get; set;}
    
    public RegistrationVerificationController() {
        regId = apexpages.currentpage().getparameters().get('id');
        //emailAddress = apexpages.currentpage().getparameters().get('emailAddr');
        
        stopEWPRecursion = false;
    }
    
    public static RegistrationVerificationController getInstance(){
        if (null == classInstance) {
            classInstance = new RegistrationVerificationController ();
        }
        return classInstance;
    }
    
    public void sendLicenseRegistrationPermitPDF() {
        System.debug('************* start sendLicenseRegistrationPermitPDF');
        
        Registration_Verification__c vr = new Registration_Verification__c();
        vr.Registration__c = regid;
        vr.Business_Entity__c = businessName;
        vr.Requestor_Email__c = emailAddress;
        vr.Requested_Date_Time__c = DateTime.now();
        insert vr;
        
        Registration_Verification__c newVr = [
            SELECT Id, Name, Requested_Date_Time__c
            FROM Registration_Verification__c
            WHERE Id =: vr.Id
        ];
        
        License_Registration__c lrSendPDF = [
            SELECT Id, Approved__c, Record_Type_Name__c
            FROM License_Registration__c
            WHERE Id =: regId
        ];
        
        lrSendPDF.Last_Verification_Number__c = newVr.Name;
        lrSendPDF.Last_Verification_Business__c = businessName;
        lrSendPDF.Last_Verification_Email__c = emailAddress;
        lrSendPDF.Last_Verification_Date_Time__c = newVr.Requested_Date_Time__c;
        
        update lrSendPDF;
        
        if (lrSendPDF.Record_Type_Name__c == 'Farm_Labor_Contractor') 
        {
            lrSendPDF.Send_FLC_Verification_Boolean__c = true;
        }
        
        update lrSendPDF;
    }
}