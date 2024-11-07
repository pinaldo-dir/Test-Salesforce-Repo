public class OWCEsignFlowActionToGetDefendantsError {
    
    @invocableMethod(label='Get Defendants with Error')
    public static List<String> getDefendantsWithError(List<String> selectedDefendants){
        List<String> defendantsWithError = new List<String>();
        List<Case_Role__c> selectedDefendantRoles = [SELECT Id, Entity__r.Signer_Email__c, Entity__r.Signer_Phone__c, Entity__r.Name FROM Case_Role__c WHERE Id IN :selectedDefendants];
        for(Case_Role__c selectedDefendantRole : selectedDefendantRoles){
            if(String.isBlank(selectedDefendantRole.Entity__r.Signer_Email__c) && String.isBlank(selectedDefendantRole.Entity__r.Signer_Phone__c)){
                defendantsWithError.add(selectedDefendantRole.Entity__r.Name);
            }
        }
        
        return defendantsWithError;
    }
}