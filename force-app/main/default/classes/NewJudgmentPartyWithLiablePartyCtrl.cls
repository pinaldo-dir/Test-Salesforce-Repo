public class NewJudgmentPartyWithLiablePartyCtrl {
    Public String judgementId{get;set;}
    Public Liability_Judgement__c judgmentParty{get;set;}
    public NewJudgmentPartyWithLiablePartyCtrl(ApexPages.StandardController controller) { 
        judgementId = (Id)controller.getId();   
        judgmentParty = new Liability_Judgement__c();
        judgmentParty.Judgement__c = judgementId;
    }
     public PageReference saveRecord(){
        String redirectId = '';
        try{
            insert judgmentParty;
            redirectId = judgmentParty.Id;
        }catch(Exception ex){redirectId =judgementId;
            System.debug(ex.getMessage());
        }
        PageReference pageRef = new PageReference('/'+redirectId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}