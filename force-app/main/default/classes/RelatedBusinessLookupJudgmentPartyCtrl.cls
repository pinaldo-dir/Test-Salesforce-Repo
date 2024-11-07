public class RelatedBusinessLookupJudgmentPartyCtrl {
        public String name{get;set;}
        public String jid{get;set;}
        public String bid{get;set;}
        public String rbname{get;set;}
        Set<Id> accountId = new Set<Id>();
        Set<Id> relatedBusinessId = new Set<Id>();
        public List<Related_Businesses__c> relatedBusinessList{get;set;}
        public RelatedBusinessLookupJudgmentPartyCtrl(){
            try{
                name = '';
                jid = '';
                bid = '';
                rbname = '';
                String relatedBusinessName = ApexPages.currentPage().getParameters().get('rbname');
                if(String.isNotBlank(relatedBusinessName)){
                    rbname = ApexPages.currentPage().getParameters().get('rbname').replaceAll('%',' ');}
                String lookupName = ApexPages.currentPage().getParameters().get('name');
                if(String.isNotBlank(lookupName)){
                    name = ApexPages.currentPage().getParameters().get('name').replaceAll('%',' ');
                }
                String judgmentId = ApexPages.currentPage().getParameters().get('jid');
                if(String.isNotBlank(judgmentId)){
                    jid = ApexPages.currentPage().getParameters().get('jid').replaceAll('%',' ');
                }
                String relatedBusinessIds = ApexPages.currentPage().getParameters().get('bid');
                if(String.isNotBlank(relatedBusinessIds)){
                    bid = ApexPages.currentPage().getParameters().get('bid').replaceAll('%',' ');
                }
                onGo();
            }
            catch(Exception e){
                
            }
        }
        public PageReference onGo(){
            try{
                for(Liability_Judgement__c judgmentParty  : [SELECT Id, EntityAccountId__c,Liable_Party_Name__c,Related_Business__c
                                                             FROM Liability_Judgement__c 
                                                             where Judgement__c =: jid])
                {
                    accountId.add(judgmentParty.EntityAccountId__c);
                    relatedBusinessId.add(judgmentParty.Related_Business__c);  
                }
                List<Related_Businesses__c> relatedBusinessesOnJudgment = new List<Related_Businesses__c>(); 
                List<Related_Businesses__c> inverseRBOList = new List<Related_Businesses__c>();
                    Set<String> RelatedBusinessMappingSet = new Set<String>();
                relatedBusinessList = new List<Related_Businesses__c>(); 
                name = String.isNotBlank(name.trim()) ? String.escapeSingleQuotes(name.trim()) : '';
                String nameStr = '%' + name + '%';
                if(name != '' && name != NULL){
                    relatedBusinessesOnJudgment = [SELECT Name,Id,Business__c, Business__r.Name, Related_Business__c ,Related_Business__r.Name ,Type__c
                                           FROM Related_Businesses__c where Related_Business__r.Name like: nameStr AND Business__c IN :accountId 
                                           And Id NOT IN : relatedBusinessId
                                           AND Related_Business__c NOT IN :accountId];
                }else{
                    relatedBusinessesOnJudgment = [SELECT Name,Id,Business__c, Business__r.Name, Related_Business__c ,Related_Business__r.Name ,Type__c
                                           FROM Related_Businesses__c where Business__c IN :accountId 
                                           And Id NOT IN : relatedBusinessId
                                           AND Related_Business__c NOT IN :accountId];
                }
                Set<Id> rbIds = new Set<Id>(); 
                //get all the RBOs whos are in Related Businesses section on Judgment.
                for(Related_Businesses__c rbo: relatedBusinessesOnJudgment){
                    rbIds.add(rbo.Related_Business__c);
                    RelatedBusinessMappingSet.add(rbo.Related_Business__c+''+rbo.Business__c);
                }
                inverseRBOList = [SELECT Name,Id,Business__c, Business__r.Name, Related_Business__c ,Related_Business__r.Name ,Type__c
                                           FROM Related_Businesses__c where Business__c IN :rbIds ];
                for(Related_Businesses__c rbo: inverseRBOList){
                    if(RelatedBusinessMappingSet.contains(rbo.Business__c+''+rbo.Related_Business__c)){
                       relatedBusinessList.add(rbo); 
                    }
                }
            }
            catch(Exception e){ 
                system.debug('error: '+e.getMessage());
                //Logger.logMessage('CallScriptLookupCtlr', 'onGo', e);
            }
            return null;
        }
    }