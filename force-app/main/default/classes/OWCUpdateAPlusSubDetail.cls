public class OWCUpdateAPlusSubDetail {
    public static List<Attachments_New__c> attachPlusObj;
    
    @InvocableMethod
    public static void updateAPlusSubDetail(List<Attachments_Plus__c> attachmentObj){
        // Rollback to here if any errors occuring in the following
        System.Savepoint sp = Database.setSavepoint();
        try{
            List<OWCServiceUtility.attachmentPlusWrapperObj> attPlusObj;
            Set<Id> contentDocIds = new Set<Id>();
            Set<Id> attachPlusIds = new Set<Id>();
            List<Attachments_New__c> updatedAttachRecs = new List<Attachments_New__c>();
            List<OWCServiceUtility.attachmentPlusWrapperObj> attachPlusDataCreate = new List<OWCServiceUtility.attachmentPlusWrapperObj>();
            List<Attachments_New__c> attachPlusToBeUpdated = new List<Attachments_New__c>();
            A_Configuration__mdt aConfigurations;
            A_Config_Details__mdt aConfigConfidentialObj;
            A_Config_Details__mdt aConfigPrivilegeObj;
            A_Config_Details__mdt aConfigPRAObj;
            List<ContentDocumentLink> allCDLs;
            
            List<ContentDocumentLink> cdls = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink
                                              WHERE LinkedEntityId =: attachmentObj[0].Id LIMIT 1];
            
            if(cdls != null && cdls.size() > 0){
                allCDLs = [SELECT Id, LinkedEntityId, ContentDocumentId 
                           FROM ContentDocumentLink 
                           WHERE ContentDocumentId =: cdls[0].ContentDocumentId];
            }
            
            for(ContentDocumentLink cdlObj : allCDLs){
                if(((String) cdlObj.LinkedEntityId).startsWith('a4C')){
                    attachPlusIds.add(cdlObj.LinkedEntityId);
                }
            }
            
            Map<Id, Attachments_New__c> attachNewMap = new Map<Id, Attachments_New__c>([SELECT Id, Name, File_Name__c, File_Type__c, Related_Id__c, Date_Submitted__c, 
                                                                                        Primary_Document__c, APlus_Json__c, Short_Description__c, 
                                                                                        Release_to_Public__c, Share_Point_Item_Id__c, 
                                                                                        Sharepoint_File_Status__c, Sharepoint_File_Upload_Error__c 
                                                                                        FROM Attachments_New__c WHERE Id IN: attachPlusIds]);
                        
            for(ContentDocumentLink cdlObj : allCDLs){
                if(((String) cdlObj.LinkedEntityId).startsWith('a4C')){
                    Attachments_New__c attachObj = attachNewMap.get(cdlObj.LinkedEntityId);
                    
                    if(String.isNotBlank(attachObj.APlus_Json__c)){
                        //Update A+ data record for PAGA
                        attPlusObj = (List<OWCServiceUtility.attachmentPlusWrapperObj>) JSON.deserialize(attachObj.APlus_Json__c, List<OWCServiceUtility.attachmentPlusWrapperObj>.class);
                        for(OWCServiceUtility.attachmentPlusWrapperObj attData : attPlusObj){
                            if(attData.fieldAPIName == 'File_Name' || attData.fieldAPIName == 'Description' || attData.fieldAPIName == 'Private'){
                                attachPlusDataCreate.add(new OWCServiceUtility.attachmentPlusWrapperObj(attData.fieldAPIName, attData.fieldAPIName, attData.value, ''));
                            }
                        }
                    }
                    
                    //Create A+ data record for PAGA
                    Map<String, A_Configuration__mdt> aConfigutaionMap = A_Configuration__mdt.getAll();
                    for(A_Configuration__mdt aConfigObj : aConfigutaionMap.values()){
                        if(aConfigObj.Record_Type_API_Names__c.contains('PAGA') && aConfigObj.File_Type__c == attachObj.File_Type__c){
                            aConfigurations = aConfigObj;
                            break;
                        }
                    }
                    System.debug('attachObj.File_Type__c ::: '+attachObj.File_Type__c);
                    System.debug('attachObj ::: '+attachObj);
                    System.debug('aConfigurations ::: '+aConfigurations);
                    Map<String, A_Config_Details__mdt> aConfigDetailsMap = A_Config_Details__mdt.getAll();
                    System.debug('aConfigurations ::: '+aConfigurations);
                    for(A_Config_Details__mdt aCongiDetailObj : aConfigDetailsMap.values()){
                        System.debug('aCongiDetailObj ::: '+aCongiDetailObj);
                        if((aConfigurations != null) && (aCongiDetailObj.A_Configuration__c == aConfigurations.Id) && (aCongiDetailObj.Field_Name__c.contains('Confidential'))){
                            aConfigConfidentialObj = aCongiDetailObj;
                            break;
                        }
                    }
                    
                    for(A_Config_Details__mdt aCongiDetailObj : aConfigDetailsMap.values()){
                        if((aConfigurations != null) && (aCongiDetailObj.A_Configuration__c == aConfigurations.Id) && (aCongiDetailObj.Field_Name__c.contains('Privilege'))){
                            aConfigPrivilegeObj = aCongiDetailObj;
                            break;
                        }
                    }
                    
                    for(A_Config_Details__mdt aCongiDetailObj : aConfigDetailsMap.values()){
                        if((aConfigurations != null) && (aCongiDetailObj.A_Configuration__c == aConfigurations.Id) && (aCongiDetailObj.Field_Name__c.contains('PRA'))){
                            aConfigPRAObj = aCongiDetailObj;
                            break;
                        }
                    }
                    
                    //Create A + Data for Privileged doc
                    if(aConfigPrivilegeObj != null){
                        attachPlusDataCreate.add(new OWCServiceUtility.attachmentPlusWrapperObj(aConfigPrivilegeObj.QualifiedApiName, aConfigPrivilegeObj.QualifiedApiName, (attachmentObj[0].Attorney_Client_Privilege__c) ? 'true' : 'false', ''));
                    }
                    
                    //Create A + Data for PRA doc
                    if(aConfigConfidentialObj != null){
                        attachPlusDataCreate.add(new OWCServiceUtility.attachmentPlusWrapperObj(aConfigConfidentialObj.QualifiedApiName, aConfigConfidentialObj.QualifiedApiName, (attachmentObj[0].Confidential__c) ? 'true' : 'false', ''));
                    }
                    
                    //Create A + Data for Confidential doc
                    if(aConfigPRAObj != null){
                        attachPlusDataCreate.add(new OWCServiceUtility.attachmentPlusWrapperObj(aConfigPRAObj.QualifiedApiName, aConfigPRAObj.QualifiedApiName, (attachmentObj[0].Not_Subject_to_PRA__c) ? 'true' : 'false', ''));
                    }
                    
                    attachObj.APlus_Json__c = (attachPlusDataCreate != null && attachPlusDataCreate.size() > 0) ? JSON.serialize(attachPlusDataCreate) : '';
                    attachPlusToBeUpdated.add(attachObj);
                }
            }
            
            if(attachPlusToBeUpdated != null && attachPlusToBeUpdated.size() > 0){
                update attachPlusToBeUpdated;
            }
            
            for(ContentDocumentLink cdlObj : allCDLs){
                if(((String) cdlObj.LinkedEntityId).startsWith('a4C')){
                    System.debug('attachmentObj ::: '+attachmentObj[0]);
                    Attachments_New__c attachObj = new Attachments_New__c();
                    attachObj.Date_Submitted__c = attachmentObj[0].Date_Submitted__c;
                    attachObj.File_Type__c = attachmentObj[0].Type__c;
                    attachObj.Primary_Document__c = attachmentObj[0].Primary_document__c;
                    attachObj.Related_Id__c = attachmentObj[0].Record_ID__c;
                    attachObj.Id = cdlObj.LinkedEntityId;
                    updatedAttachRecs.add(attachObj);
                }
            }
            
            if(updatedAttachRecs != null && updatedAttachRecs.size() > 0){
                update updatedAttachRecs;
            }
        }
        catch(Exception ex){
            System.debug('Exception ::: '+ex.getMessage() + 'Line Number ::: '+ex.getLineNumber());
            // Rollback everything done up until this point
            Database.rollback(sp);  
        }
    }
    
}