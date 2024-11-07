public class DIRNewRelatedBusinessesCreateController {
    public Id parentId {get; set;}
    public Related_Businesses__c relatedBusinesses {get; set;}
    public string businessName {get; set;}
    public Id businessId {get; set;}
    public Boolean accountExist {get; set;}
    public DIRNewRelatedBusinessesCreateController(ApexPages.StandardController controller) {
        accountExist = false;
        relatedBusinesses = new Related_Businesses__c();
        Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
        for(String paramKey : pageParameters.KeySet()){
            if(paramKey.contains('_lkid')){
                parentId = pageParameters.get(paramKey);
                break;
            }
        }
        if(parentId != null && (parentId.getSObjectType().getDescribe().getName().equalsIgnoreCase('Account'))){
              Account currentAccount = [SELECT Id, Name FROM Account WHERE Id =: parentId];
                    relatedBusinesses.Business__c = parentId;
                    businessName = currentAccount.Name;
                    businessId = currentAccount.id;
                    accountExist = true;
        }
    }
    
    public PageReference saveRelatedBusinessesRecord() {
        //create the Related Businesses record
        try {
           Boolean relatedBusinessExist = DirQuerySelector.getRelatedBusinessRecord(relatedBusinesses.Related_Business__c,relatedBusinesses.Business__c);
            if(relatedBusinessExist){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error , 'Related Business Record Already Exists'));
                return null;
            }
            else{
                insert relatedBusinesses;
            }
        }
        
        catch(Exception ex) {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error , 'Something Went Wrong. Please Contact your System Administrator.'));
                return null;
        }
        PageReference pageRef;
            if(accountExist){
                pageRef = new PageReference('/'+parentId);
            }else{
                pageRef = new PageReference('/'+relatedBusinesses.id);
            }
        pageRef.setRedirect(true);
        return pageRef;
    }
}