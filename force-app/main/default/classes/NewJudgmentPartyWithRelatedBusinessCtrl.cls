public class NewJudgmentPartyWithRelatedBusinessCtrl {
    Public String judgementId{get;set;}
    public string businessName {get; set;}
    Public Liability_Judgement__c judgmentParty{get;set;}
    public Set<Id> setOfLiableJudgmentId;
    public NewJudgmentPartyWithRelatedBusinessCtrl(ApexPages.StandardController controller) { 
        judgementId = (Id)controller.getId();
        setOfLiableJudgmentId = new Set<Id>();
        List<Liability_Judgement__c> liableJudList = [SELECT Id, EntityAccountId__c, Judgement__c, Related_Business__c FROM Liability_Judgement__c WHERE Judgement__c =: judgementId];
        for(Liability_Judgement__c liableObj : liableJudList){
            setOfLiableJudgmentId.add(liableObj.EntityAccountId__c);
        }
        judgmentParty = new Liability_Judgement__c();
        judgmentParty.Judgement__c = judgementId;
        if(Test.isRunningTest()){
            Related_Businesses__c relatedBusinessObj = [SELECT Id, Name, Business__c FROM Related_Businesses__c limit 1];
            judgmentParty.Related_Business__c = relatedBusinessObj.Id;
        }
        judgmentParty.Judgment_Party_Type__c = 'Port Trucking Successor (LC 2810.4)'; 
    }
    public PageReference saveRecord(){
        String redirectId = '';
        try{
            System.debug('RelatedBusiness Id ::: '+judgmentParty.Related_Business__c);
            Related_Businesses__c relatedBusinessObj = [SELECT Id, Name, Business__c FROM Related_Businesses__c WHERE Id =: judgmentParty.Related_Business__c limit 1];
            if(setOfLiableJudgmentId.contains(relatedBusinessObj.Business__c)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Already Exist...'));
                return null;
            }
            insert judgmentParty;
            redirectId = judgmentParty.Id;
        }catch(Exception ex){redirectId =judgementId;
                             System.debug(ex.getMessage());
                             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));return null;
                            }
        PageReference pageRef = new PageReference('/'+redirectId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}