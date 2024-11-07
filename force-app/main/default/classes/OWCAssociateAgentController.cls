public with sharing class OWCAssociateAgentController {
    @AuraEnabled
    public static  ResponseModal saveValues( String agentAssociatedName, String associatedAgent, String type, Boolean status, String reason) {
        system.debug('type-->' + type +' status: '+status);
        system.debug('associatedAgent-->' + associatedAgent);
        system.debug('agentAssociatedName-->' + agentAssociatedName);
        List<Associated_Agents__c> acclist = new List<Associated_Agents__c>();
        acclist = [SELECT Id,Account__c,Associated_Account__c,Type__c FROM Associated_Agents__c 
                   WHERE Account__c=:associatedAgent and Associated_Account__c =: agentAssociatedName 
                   and Type__c =: type ];
        system.debug('agentAssociatedName: '+agentAssociatedName + ' associatedAgent: '+associatedAgent + ' type: '+type);
        if( acclist.size() > 0){  
            ResponseModal modal = new ResponseModal();
            modal.isSuccess = false;
            modal.message = 'System do not allow the user to create more than one record between the same two Accounts with the same type. ';
            return modal;
        }
        else{     
            ResponseModal modal = createAgentRecord(agentAssociatedName, associatedAgent, type,status, reason);
            return modal;
        }
    }
    public static  ResponseModal createAgentRecord( String agentAssociatedName, String associatedAgent, String type,  Boolean status, String reason) {
        system.debug('type-->' + type);
        system.debug('associatedAgent-->' + associatedAgent);
        system.debug('agentAssociatedName-->' + agentAssociatedName);
        if(String.isNotBlank(agentAssociatedName) &&  String.isNotBlank(associatedAgent) && String.isNotBlank(type)){  
            Associated_Agents__c agent = new Associated_Agents__c();
            agent.Account__c = associatedAgent;
            agent.Associated_Account__c = agentAssociatedName;
            agent.Type__c = type; 
            agent.Relationship_Status__c = status;
            agent.Reason__c = reason;
            ResponseModal modal = new ResponseModal();
            try{
                insert agent;
                modal.isSuccess = true;
                modal.message = agent.Id;
                return modal;
            }catch(Exception ex){
                modal.isSuccess = false;
                modal.message = ex.getMessage();
                return modal;
            }
            
        }
        else{     
            return null;
        }
    }

    public class ResponseModal{
        @auraEnabled
        public  String message;
        @auraEnabled
        public Boolean isSuccess;
    }
}