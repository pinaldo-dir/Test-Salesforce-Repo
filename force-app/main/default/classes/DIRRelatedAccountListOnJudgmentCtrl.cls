public class DIRRelatedAccountListOnJudgmentCtrl {
    public String judgmentId {get; set;}
    public List<judgmentPartyWrapper> wrapper {get; set;}
    Set<Id> accountId = new Set<Id>();
    Set<Id> relatedBusinessId = new Set<Id>();
    public DIRRelatedAccountListOnJudgmentCtrl(ApexPages.StandardController controller){
        try{
            wrapper = new List<judgmentPartyWrapper>();
            judgmentId = controller.getId();
            for(Liability_Judgement__c judgmentParty  : [SELECT Id, EntityAccountId__c,Liable_Party_Name__c,Related_Business__c
                                                         FROM Liability_Judgement__c 
                                                         where Judgement__c =: judgmentId])
            {
                accountId.add(judgmentParty.EntityAccountId__c);
                relatedBusinessId.add(judgmentParty.Related_Business__c);  
            }
            for(Related_Businesses__c rbo  : [ SELECT Id,Business__c, Business__r.Name, Related_Business__c ,Related_Business__r.Name ,Type__c
                                              FROM Related_Businesses__c
                                              where Business__c IN :accountId 
                                              And Id NOT IN : relatedBusinessId
                                              AND Related_Business__c NOT IN :accountId]){
                                                  wrapper.add(new judgmentPartyWrapper(rbo.Business__c,rbo.Business__r.Name,rbo.Related_Business__r.Id,rbo.Related_Business__r.Name,rbo.Type__c));
                                              }
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    public class judgmentPartyWrapper {
        public String entityId {get; set;}
        public String entityName {get; set;}
        public String relatedBusinessId {get; set;}
        public String relatedBusinessName {get; set;}
        public String rboType {get; set;}
        public judgmentPartyWrapper(String entityId, String entityName, String relatedBusinessId, String relatedBusinessName, String rboType ) {
            this.entityId = entityId;
            this.entityName = entityName;
            this.relatedBusinessId = relatedBusinessId;
            this.relatedBusinessName = relatedBusinessName;
            this.rboType = rboType;
        }
    }
}