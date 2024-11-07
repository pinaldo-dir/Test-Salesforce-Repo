public class DIRNewRelatedBusinessesCreateOnCM {
    public String caseManagementId {get; set;}
    public Related_Businesses__c relatedBusinesses{get;set;}
    public string businessName {get; set;}
    public Boolean relatedBusinessExist{get;set;}
    public DIRNewRelatedBusinessesCreateOnCM(ApexPages.StandardController controller){
        caseManagementId = controller.getId();
        relatedBusinesses = new Related_Businesses__c();
        if(caseManagementId != null){
            relatedBusinesses.Case_Management_Id__c = caseManagementId;
        }
    }
    public PageReference saveRelatedBusinessesRecord() {
        //create the Related Businesses record
        try {
            boolean isValidBusiness = DirQuerySelector.getValidBusiness(relatedBusinesses.Business__c);
            if(!isValidBusiness){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error , 'Please select valid Business Record'));
                return null;
            }
            relatedBusinessExist = DirQuerySelector.getRelatedBusinessRecord(relatedBusinesses.Related_Business__c,relatedBusinesses.Business__c);
            if(relatedBusinessExist){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error , 'Related Business Record Already Exists'));
                return null;
            }
            else{
                insert relatedBusinesses;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM , 'Record Saved Successfully'));
            }
        }
        catch(Exception ex) {  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Review the error'));
                            }
        PageReference pageRef = new PageReference('/'+caseManagementId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}