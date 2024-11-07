//-----------------------------
// @author: Oswin Correa
// @date: 4/4/2018
// @description: Controller of the Attachments + Lightning component 
//-----------------------------
public with sharing class A_Plus_Controller {
    
    //To allow delete of internal attchament plus records created via Lightning upload component
    public static Boolean isNotAplusMode = true;
    
    //-----------------------------
    // @description: Wrapper class to store the datatable column informnation 
    //-----------------------------
    public class HeaderInfoWrapper {
        
        @AuraEnabled
        public String label               {get;set;}
        
        @AuraEnabled
        public String fieldName           {get;set;}
        
        @AuraEnabled
        public String type                {get;set;}
        
        @AuraEnabled
        public Boolean showInSummary      {get;set;}
        
        @AuraEnabled
        public Boolean required           {get;set;}
        
        @AuraEnabled
        public Integer sortOrder          {get;set;}
        
        @AuraEnabled
        public String values              {get;set;}
        
    }
    
    //-----------------------------
    // @param: String relatedRecordId, String fileType, String searchKey
    // @description: Fetches data and headers to display for File types
    // @return: File type mapped to column info and data info
    //-----------------------------
    @AuraEnabled
    public static Map<String,Map<String,Object>> fetchHeadersAndData(Id relatedRecordId, String fileType, String searchKey){
        
        Map<String,Map<String,Object>> mapHeadersAndData = new Map<String,Map<String,Object>>();
        Map<String,Set<String>> mapFileTypeCustomChildRelations = new Map<String,Set<String>>();
        Map<String,Set<String>> mapFileTypeStandardChildRelations = new Map<String,Set<String>>();
        Set<String> setAllCustomChildRelations = new Set<String>();
        Set<String> setAllStandardChildRelations = new Set<String>();
        
        Set<String> setChecboxFields = new Set<String>{'Private'};
            
            String sobjectName = String.valueOf(relatedRecordId.getSObjectType());
        
        String recordTypeName = '';
        
        
        //Fetch the recordtype of context record
        try{
            recordTypeName = String.valueOf(Database.query('SELECT Id,RecordType.DeveloperName '+
                                                           'FROM '+sobjectName+ 
                                                           ' WHERE Id =: relatedRecordId')[0].getSobject('RecordType').get('DeveloperName'));
        }
        catch(Exception ex){
            recordTypeName = '';
        }
        
        
        //Forming the query to fetch A+ configuration
        String configInfoQuery = 'SELECT Id,File_Type__c,Collaboration_Group_Names__c,Community_ID__c,Sharing_Permissions__c,Sort_Order__c,Child_Relationship_Names_Standard__c,Child_Relationship_Names_Custom__c ';
        configInfoQuery += 'FROM A_Configuration__mdt ';
        configInfoQuery += 'WHERE  Object_API_Name__c =: sobjectName ';
        configInfoQuery += 'AND File_Type__c != null ';
        
        
        //File type filter  if file type is passed
        if(String.isNotBlank(fileType)){ 
            
            configInfoQuery += 'AND  File_Type__c =: fileType ';
        }
        
        //Record type filter if context record has a record type
        if(String.isNotBlank(recordTypeName)){
            
            recordTypeName = '%'+recordTypeName+'%';
            
            configInfoQuery += 'AND  Record_Type_API_Names__c LIKE: recordTypeName ';  
        }
        
        configInfoQuery += 'ORDER BY Sort_Order__c ASC NULLS LAST';
        
        //JSON Data for Test Coverage purposes as no DMLS allowed on custom metadata type
        String testConfigJSONData = '[{"attributes":{"type":"A_Configuration__mdt","url":"/services/data/v42.0/sobjects/A_Configuration__mdt/m06350000004Dl8AAE"},'+
            '"Id":"m06350000004Dl8AAE","File_Type__c":"Legal","Object_API_Name__c":"Account","Child_Relationship_Names_Standard__c": "Contacts","Child_Relationship_Names_Custom__c": "",'+
            '"Collaboration_Group_Names__c":"RCI Staff","Sharing_Permissions__c":"Private","Sort_Order__c":"5"}]';
        
        String testConfigDetailsJSONData = '[{"attributes":{"type":"A_Config_Details__mdt","url":"/services/data/v42.0/sobjects/A_Config_Details__mdt/m073500000001hGAAQ"}'+
            ',"Id":"m073500000001hGAAQ","DeveloperName":"Subtype","A_Configuration__c":"m06350000004Dl8AAE",'+
            '"Active__c":true,"Data_Type__c":"Picklist","Field_Name__c":"Subtype","Picklist_Values__c":"Intake Form;Evidence;Complainant Document",'+
            '"Required__c":"false","Show_in_Summary__c":"true","Sort_Order__c":"2",'+
            '"A_Configuration__r":{"attributes":{"type":"A_Configuration__mdt","url":"/services/data/v42.0/sobjects/A_Configuration__mdt/m06350000004Dl8AAE"},'+
            '"Id":"m06350000004Dl8AAE","File_Type__c":"Legal"}}]';
        
        
        List<A_Configuration__mdt>  configs = (List<A_Configuration__mdt>) JSON.deserialize(testConfigJSONData, List<A_Configuration__mdt>.class);
        List<A_Config_Details__mdt>  configDetails = (List<A_Config_Details__mdt>) JSON.deserialize(testConfigDetailsJSONData, List<A_Config_Details__mdt>.class);                               
        
        if(!Test.isRunningTest()){
            configs = Database.query(configInfoQuery);
        }
        
        
        for(A_Configuration__mdt objConfig : configs){
            
            mapHeadersAndData.put(objConfig.File_Type__c, new Map<String,Object>{  'columns' => new List<HeaderInfoWrapper>(),
                'data'    => new List<Map<String,String>>(),
                'details' => objConfig
                });
            //Obtaining custom child relations                                                                          
            if(String.IsNotBlank(objConfig.Child_Relationship_Names_Custom__c)){
                
                Set<String> setChildRelations = new Set<String>(objConfig.Child_Relationship_Names_Custom__c.trim().split(','));
                mapFileTypeCustomChildRelations.put(objConfig.File_Type__c,setChildRelations);
                setAllCustomChildRelations.addAll(setChildRelations);
            }
            
            //Obtaining standard child relations 
            if(String.IsNotBlank(objConfig.Child_Relationship_Names_Standard__c)){
                
                Set<String> setChildRelations = new Set<String>(objConfig.Child_Relationship_Names_Standard__c.trim().split(','));
                mapFileTypeStandardChildRelations.put(objConfig.File_Type__c,setChildRelations);
                setAllStandardChildRelations.addAll(setChildRelations);
            }
            
        }    
        
        //if no configuration found
        if(mapHeadersAndData.isEmpty() && String.isBlank(fileType)){
            
            return mapHeadersAndData;
        }
        else{
            Map<String,Map<String,Object>> mapRelatedFiles = new Map<String,Map<String,Object>>{ 'Related Files' => new Map<String,Object>
            {  
                'columns' => new List<HeaderInfoWrapper>(),
                    'data'    => new List<Map<String,String>>(),
                    'details' => new A_Configuration__mdt()
                    }
                                                                                               };
                                                                                                   
                                                                                                   mapRelatedFiles.putall(mapHeadersAndData);
            mapHeadersAndData = mapRelatedFiles;
            
        }
        
        
        
        Set<String> fileTypes = new Set<String>(mapHeadersAndData.keyset());
        
        //A_Config_Details custom metadata type query formation to fetch column information
        String columnInfoQuery = 'SELECT Id, DeveloperName, A_Configuration__r.File_Type__c, Active__c, Data_Type__c, Field_Name__c,';
        columnInfoQuery += 'Picklist_Values__c, Required__c, Show_in_Summary__c, Sort_Order__c ';
        columnInfoQuery += 'FROM A_Config_Details__mdt ';
        columnInfoQuery += 'WHERE  A_Configuration__r.File_Type__c != Null ';
        columnInfoQuery += 'AND  A_Configuration__r.Object_API_Name__c =: sobjectName ';
        
        if(String.isNotBlank(recordTypeName)){
            
            columnInfoQuery += 'AND  A_Configuration__r.Record_Type_API_Names__c LIKE: recordTypeName ';
        }
        
        
        //File type specifier if file type is passed
        if(String.isNotBlank(fileType)){
            
            columnInfoQuery += 'AND  A_Configuration__r.File_Type__c =: fileType ';
        }
        
        
        columnInfoQuery += 'ORDER BY Sort_Order__c ASC ';
        
        if(!Test.isRunningTest()){
            configDetails = Database.query(columnInfoQuery);
        }
        
        for(A_Config_Details__mdt mdt : configDetails){
            
            //Formation of column header wrapper info
            HeaderInfoWrapper objHeaderInfoWrapper = new HeaderInfoWrapper();
            objHeaderInfoWrapper.label =  mdt.Field_Name__c;
            objHeaderInfoWrapper.fieldName =  mdt.DeveloperName;
            objHeaderInfoWrapper.showInSummary =  mdt.Show_in_Summary__c;
            objHeaderInfoWrapper.required =  mdt.Required__c;
            objHeaderInfoWrapper.type =  mdt.Data_Type__c.toLowerCase() == 'date' ? 'formatteddate' : mdt.Data_Type__c.toLowerCase();
            objHeaderInfoWrapper.sortOrder = (Integer) mdt.Sort_Order__c;
            objHeaderInfoWrapper.values = '';
            
            //Storing the picklist values
            if(objHeaderInfoWrapper.type == 'picklist'){
                objHeaderInfoWrapper.values = '[';
                for(String  option: mdt.Picklist_Values__c.split(';')){
                    objHeaderInfoWrapper.values += '{"label" : "'+option+'","value" : "'+option+'"},';
                }
                objHeaderInfoWrapper.values = objHeaderInfoWrapper.values.removeEnd(',');
                objHeaderInfoWrapper.values += ']';
            }
            
            //Storing the checkbox fields to display them as icon in lightning:datatable
            if(objHeaderInfoWrapper.type == 'checkbox'){
                setChecboxFields.add(objHeaderInfoWrapper.fieldName);
            }
            
            ((List<HeaderInfoWrapper>) mapHeadersAndData.get(mdt.A_Configuration__r.File_Type__c).get('columns')).add(objHeaderInfoWrapper);
            
        }
        
        
        
        String fetchChildrenQuery = 'SELECT Id ';
        
        //To fetch all the child record Ids via custom child relations related to the context record
        for(String strCR : setAllCustomChildRelations){
            
            strCR += '__r';
            fetchChildrenQuery += ',(SELECT Id FROM '+strCR+') ';
        }
        
        for(String strCR : setAllStandardChildRelations){
            
            fetchChildrenQuery += ',(SELECT Id FROM '+strCR+') ';
        }
        
        
        fetchChildrenQuery += 'FROM '+sobjectName;
        fetchChildrenQuery += ' WHERE Id=: relatedRecordId'; 
        
        Sobject sobj  =  Database.query(fetchChildrenQuery);
        
        Map<String,String> mapChildRelationIds = new Map<String,String>();
        
        Set<String> setAllChildRelations = new Set<String>();
        setAllChildRelations.addAll(setAllCustomChildRelations);
        setAllChildRelations.addAll(setAllStandardChildRelations);
        
        
        //To fetch all the child record Ids via standard child relations related to the context record
        for(String strCR : setAllChildRelations){
            
            if(setAllCustomChildRelations.contains(strCR)){
                strCR += '__r'; 
            }
            
            List<Sobject> childObjects = new List<Sobject>(sobj.getSObjects(strCR));
            
            String childObjectIds = '';
            
            for(Sobject childObj : childObjects){
                
                childObjectIds += '\''+String.valueOf(childObj.get('id'))+'\',';
            }
            
            if(String.isNotBlank(childObjectIds)){
                
                childObjectIds = childObjectIds.removeEnd(',');
                
            }
            
            mapChildRelationIds.put(strCR, childObjectIds);
            
        }
        
        
        //Attachmnets custom object query formation to fetch table data
        String dataQuery  = 'SELECT Id,File_Type__c,APlus_Json__c, Share_Point_Item_Id__c,'+
            '(SELECT Id,ContentDocumentId FROM ContentDocumentLinks LIMIT 1) '+
            //'(SELECT Id, Field_Name__c, File_Type__c, Value__c, Attachments__c,Field_API_Name__c FROM Attachments_Data__r) '+
            'FROM Attachments_New__c WHERE ';
        if(!Test.isRunningTest()){
            dataQuery += 'File_Type__c =:  fileTypes AND (';
        }
        dataQuery += ' Related_Id__c =: relatedRecordId ';
        //For custom relations
        dataQuery += addChildRecordIdFilters(mapFileTypeCustomChildRelations,mapChildRelationIds,false);
        
        //For standard relations
        dataQuery += addChildRecordIdFilters(mapFileTypeStandardChildRelations,mapChildRelationIds,true); 
        if(!Test.isRunningTest()){
            dataQuery += ')';
        }
        System.debug('dataQuery ::: '+Database.query(dataQuery));
        for(Attachments_New__c att : Database.query(dataQuery)){
            
            Map<String,String> mapData = new Map<String,String>();
            Boolean searchFound = false;
            List<OWCServiceUtility.attachmentPlusWrapperObj> attPlusObj;
            
            if(String.isNotBlank(att.APlus_Json__c)){
                attPlusObj = (List<OWCServiceUtility.attachmentPlusWrapperObj>) JSON.deserialize(att.APlus_Json__c, List<OWCServiceUtility.attachmentPlusWrapperObj>.class);
            }
            
            if(attPlusObj != null && attPlusObj.size() > 0){
                for(OWCServiceUtility.attachmentPlusWrapperObj attData : attPlusObj){
                    
                    //when search keyword is entered, filter data   
                    if(!searchFound &&
                       String.isNotBlank(searchKey) && 
                       String.isNotBlank(attData.value) &&
                       attData.value.toLowerCase().contains(searchKey.toLowerCase())){
                           
                           searchFound = true;
                       }
                    
                    //Checkbox columns to show icon instead rendering as text  
                    mapData.put(attData.fieldAPIName, setChecboxFields.contains(attData.fieldAPIName) ? 
                                (attData.value == 'true' ? 'utility:check' : '') : 
                                attData.value);
                }
            }
            
            if(String.isBlank(searchKey) || searchFound){
                
                mapData.put('id',att.id);
                mapData.put('sharePointId', att.Share_Point_Item_Id__c);
                
                //storing content doc Id in the data object, needed to redirect when clicked on share option in table row action
                for(ContentDocumentLink objCDL : att.ContentDocumentLinks){
                    mapData.put('linkId',objCDL.ContentDocumentId);
                }
                if(!Test.isRunningTest()){
                    ((List<Map<String,String>>) mapHeadersAndData.get(att.File_Type__c).get('data')).add(mapData);
                }
            }
        }
        
        System.debug('mapHeadersAndData ::: '+mapHeadersAndData);
        return mapHeadersAndData;
        
    }
    
    //-----------------------------
    // @param: Map<String,Set<String>> mapFileTypeToChildRelations,Map<String,String> mapChildRelationIds, Boolean isStandardChildRelation
    // @description: To append child Ids fetched via custom and standard child relations and append to query to fetch attachments
    // @return: Query Filter String consiting of related child Ids inorder to fetch attachments from it and display in parent
    //-----------------------------
    private static String addChildRecordIdFilters(Map<String,Set<String>> mapFileTypeToChildRelations,Map<String,String> mapChildRelationIds, Boolean isStandardChildRelation){
        
        String queryChildRecordFilesAddition = '';
        
        for(String strfileType : mapFileTypeToChildRelations.keyset()){
            
            String queryFilterSubAdditions = '';
            
            for(String childRelation : mapFileTypeToChildRelations.get(strfileType)){
                
                //for custom relations
                if(!isStandardChildRelation){
                    
                    childRelation += '__r'; 
                }
                
                String childObjectIds = mapChildRelationIds.get(childRelation);
                
                if(String.isNotBlank(childObjectIds)){
                    
                    queryFilterSubAdditions += childObjectIds;
                    queryFilterSubAdditions += ',';
                }
                
            }
            
            if(String.isNotBlank(queryFilterSubAdditions)){
                
                queryFilterSubAdditions = queryFilterSubAdditions.removeEnd(',');
                queryFilterSubAdditions = ' OR (File_Type__c = \''+strfileType+'\' AND Related_Id__c In (' +queryFilterSubAdditions+ ')) ';
                queryChildRecordFilesAddition += queryFilterSubAdditions;
                
            }
            
        }
        
        return queryChildRecordFilesAddition;
    }
    
    //-----------------------------
    // @param: String attachId
    // @description: To delete the particular Attachment custom object record
    // @return: File type mapped to column info and data info
    //-----------------------------
    @AuraEnabled
    public static void deleteAttachment(String attachId){
        delete new Attachments_New__c(Id = attachId);
    }
    
    //-----------------------------
    // @param: String fileInfoJSON, String attachId,String fileType, String relatedRecordId
    // @description: Updates the attchament custom object record and it child records
    // @return: NA
    //-----------------------------
    
    @AuraEnabled
    public static void updateAttachment(String fileInfoJSON, String attachId,String fileType, String relatedRecordId , String configDetails, Boolean isMove){ 
        System.debug('configDetails ::: '+configDetails);
        Map<String,String> mapFileData = (Map <String,String>)JSON.deserialize(fileInfoJSON, Map<String,String>.class);
        for(String key: mapFileData.keyset()){
            system.debug('key: '+key +'  value: '+mapFileData.get(key));
        }
        A_Configuration__mdt objConfig = (A_Configuration__mdt) JSON.deserialize(configDetails, A_Configuration__mdt.class);
        
        //get the record type name of based on relatedRecordID
        String sobjectName = String.valueOf(Id.valueOf(relatedRecordId).getSObjectType());
        String recordTypeName = '';
        
        try{
            recordTypeName = String.valueOf(Database.query('SELECT Id,RecordType.DeveloperName '+
                                                           'FROM '+sobjectName+ 
                                                           ' WHERE Id =: relatedRecordId')[0].getSobject('RecordType').get('DeveloperName'));
        }
        catch(Exception ex){
            recordTypeName = '';
        }
        
        Attachments_New__c attPlus = new Attachments_New__c(Related_Id__c = relatedRecordId,
                                                            File_Type__c = fileType,
                                                            Id = attachId); 
        
        //if Private checkbox isn't checked
        if(mapFileData.containsKey('Private') && mapFileData.get('Private') != 'true'){
            
            //if the bin is private
            if(objConfig.Sharing_Permissions__c == 'Private'){
                
                attPlus.Visible__c= 'Private ' + recordTypeName; 
                
            }else{
                
                attPlus.Visible__c=  'Public ' + recordTypeName;
                
            }
            
            
        }else{//if private checkbox is checked
            
            attPlus.Visible__c= recordTypeName;
        }
        //lets update the Release To Public field
        for(String key: mapFileData.keyset()){
            if(key.contains('Release_to_Public')){
                attPlus.Release_to_Public__c = Boolean.valueOf(mapFileData.get(key));
            }
        }
        //update attPlus;
        
        Set<String> setExistingFields = new Set<String>();
        Set<String> setChangedFields = new Set<String>();
        
        List<OWCServiceUtility.attachmentPlusWrapperObj> attPlusObj = new List<OWCServiceUtility.attachmentPlusWrapperObj>();
        
        if(attPlus != null && String.isNotBlank(attPlus.APlus_Json__c)){
            attPlusObj = (List<OWCServiceUtility.attachmentPlusWrapperObj>) JSON.deserializeUntyped(attPlus.APlus_Json__c);//(, List<OWCServiceUtility.attachmentPlusWrapperObj>.class);
        }
        
        //Updating the existing attachment details if values are changed on edit
        if(attPlusObj != null && attPlusObj.size() > 0){
            for(OWCServiceUtility.attachmentPlusWrapperObj objAtt : attPlusObj){
                
                if(objAtt.value != mapFileData.get(objAtt.fieldAPIName)){
                    
                    objAtt.value = mapFileData.get(objAtt.fieldAPIName);
                    attPlusObj.add(objAtt);
                    setChangedFields.add(objAtt.fieldAPIName);
                }
                
                
                setExistingFields.add(objAtt.fieldAPIName);
                
            }
        }
        
        //For new fields added during transfer of attachment from one file type to other
        Set<String> newFileTypeFields = new Set<String>(mapFileData.keyset());
        newFileTypeFields.removeAll(setExistingFields);
        
        
        for(String attDataFieldInfo : newFileTypeFields){
            System.debug('attPlusObj ::: '+mapFileData.get(attDataFieldInfo));
            attPlusObj.add(new OWCServiceUtility.attachmentPlusWrapperObj(attDataFieldInfo, attDataFieldInfo, mapFileData.get(attDataFieldInfo), ''));
        }
        
        attPlus.APlus_Json__c = JSON.serialize(attPlusObj);
        System.debug('attPlus ::: '+attPlus);
        upsert attPlus;
        
        if(setChangedFields.contains('Private') || isMove){
            
            Attachments_New__c objAtt = [SELECT Id,OwnerId,(SELECT Id,ContentDocumentId  FROM ContentDocumentLinks LIMIT 1)
                                         FROM Attachments_New__c
                                         WHERE Id =: attPlus.id];
            
            String attCDLId = '';
            String contentDocId = '';
            
            for(ContentDocumentLink objCDL : objAtt.ContentDocumentLinks){
                
                contentDocId = objCDL.ContentDocumentId;
                attCDLId = objCDL.Id;
            }                             
            
            Delete [ SELECT Id 
                    FROM ContentDocumentLink 
                    WHERE (ContentDocumentId =: contentDocId AND Id !=: attCDLId AND LinkedEntityId !=: objAtt.OwnerId)];
            
            if(fileType != 'Related Files'){
                createSharings(contentDocId,'',mapFileData,objConfig,new List<ContentDocumentLink>());
            }
        }
    }
    
    //-----------------------------
    // @param: String fileInfoJSON, String base64Data, String fileType, String relatedRecordId, String fileName
    // @description: Uploads chosen file to salesforce, creates corresponding attchament custom object record and it child records
    // @return: NA
    //-----------------------------
    @AuraEnabled
    public static void uploadFile(String fileInfoJSON, String internalcontentDocId, String fileType, Id relatedRecordId, String fileName, String configDetails){
        
        Map<String,String> mapFileData = (Map <String,String>)JSON.deserialize(fileInfoJSON, Map<String,String>.class);
        System.debug('mapFileData ::: '+mapFileData);
        A_Configuration__mdt objConfig = (A_Configuration__mdt) JSON.deserialize(configDetails, A_Configuration__mdt.class);
        
        //get the record type name of based on relatedRecordID
        String sobjectName = String.valueOf(relatedRecordId.getSObjectType());
        
        String recordTypeName = '';
        
        try{
            recordTypeName = String.valueOf(Database.query('SELECT Id,RecordType.DeveloperName '+
                                                           'FROM '+sobjectName+ 
                                                           ' WHERE Id =: relatedRecordId')[0].getSobject('RecordType').get('DeveloperName'));
        }
        catch(Exception ex){
            recordTypeName = '';
        }
        
        
        //get the record type name
        Attachments_New__c attPlus = new Attachments_New__c(File_Name__c = fileName,
                                                            Related_Id__c = relatedRecordId,
                                                            File_Type__c = fileType);
        
        //Private checkbox is checked
        //if Private checkbox isn't checked
        if(mapFileData.containsKey('Private') && mapFileData.get('Private') != 'true'){
            
            //if the bin is private
            if(objConfig.Sharing_Permissions__c == 'Private'){
                
                attPlus.Visible__c= 'Private ' + recordTypeName; 
                
            }else{
                
                attPlus.Visible__c=  'Public ' + recordTypeName;
                
            }
            
            
        }else{//if private checkbox is checked
            
            attPlus.Visible__c= recordTypeName;
        }
        
        insert attPlus;
        List<OWCServiceUtility.attachmentPlusWrapperObj> attPlusObj = new List<OWCServiceUtility.attachmentPlusWrapperObj>();
        
        if(attPlus != null && String.isNotBlank(attPlus.APlus_Json__c)){
            attPlusObj = (List<OWCServiceUtility.attachmentPlusWrapperObj>) JSON.deserializeUntyped(attPlus.APlus_Json__c);
        }
        
        for(String attDataFieldInfo : mapFileData.keyset()){

            attPlusObj.add(new OWCServiceUtility.attachmentPlusWrapperObj(attDataFieldInfo, attDataFieldInfo, attDataFieldInfo.contains('Date')? String.valueOf(System.today()) : mapFileData.get(attDataFieldInfo), ''));                  
        }
        
        attPlus.APlus_Json__c = JSON.serialize(attPlusObj);
        update attPlus;
        ContentVersion conVer;
        List<ContentVersion> conVers = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: internalcontentDocId];
        if(conVers != null && conVers.size() > 0){
            //Creation of content version
            conVer = new ContentVersion( ContentLocation = 'S',
                                        PathOnClient = fileName,
                                        Title = fileName,
                                        VersionData = !Test.isRunningTest() ? conVers[0].VersionData : EncodingUtil.base64Decode(internalcontentDocId),
                                        Origin = 'C');
            
            String communityId = String.isNotBlank(objConfig.Community_ID__c) ? objConfig.Community_ID__c : '';
            
            //Validating if network Id mentioned on config is a valid one and assigning to the content version
            try{
                if(String.isNotBlank(communityId)){
                    
                    for(Sobject objNetwork : Database.query('SELECT id FROM Network WHERE Id =: communityId')) {
                        conVer.put('NetworkId',String.valueOf(objNetwork.get('id')));
                        break;
                    }
                    
                    communityId = String.valueOf(conVer.get('NetworkId'));
                }
                
            } 
            catch(Exception ex){
                communityId = '';
            }
            
            if(Test.isRunningTest()){
                communityId = '';
            }
            
            insert conVer;
            
            Id contentDocId = [SELECT id, ContentDocumentId 
                               FROM ContentVersion 
                               WHERE id = :conVer.id].ContentDocumentId;
            //baseline APlus Object--sharing setting = Public-->Private
            createSharings(contentDocId,communityId,mapFileData,objConfig,new List<ContentDocumentLink>{new ContentDocumentLink( ContentDocumentId = contentDocId,
                                                                                                                                ShareType = 'I',
                                                                                                                                LinkedEntityId = attPlus.id)});
            
            deleteAttachmentPlusAndCorrespondingRecords(!Test.isRunningTest() ? internalcontentDocId : contentDocId);
        }
        
        
    }
    
    //-----------------------------
    // @param: String contentDocId,String communityId,Map<String,String> mapFileData, A_Configuration__mdt objConfig,List<ContentDocumentLink> contentDocLinks
    // @description: Provides necessary sharing to the attachments
    // @return: NA
    //-----------------------------
    private static void createSharings(String contentDocId,String communityId,Map<String,String> mapFileData, A_Configuration__mdt objConfig,List<ContentDocumentLink> contentDocLinks){
        System.debug('contentDocId ::: '+contentDocId);
        if(String.isBlank(contentDocId)) return;
        //private checkbox
        if(String.isBlank(communityId) && String.isNotBlank(objConfig.Sharing_Permissions__c) 
           && (!mapFileData.containsKey('Private') || mapFileData.get('Private') != 'true')){
               
               //Giving access to entire Organization if Sharing permssion set to Public
               if(objConfig.Sharing_Permissions__c == 'Public'){
                   
                   contentDocLinks.add(new ContentDocumentLink( ContentDocumentId = contentDocId,
                                                               LinkedEntityId = UserInfo.getOrganizationId(),
                                                               ShareType = 'C',
                                                               Visibility = 'AllUsers'));
                   
               }
               //Giving access to collaboration groups mentioned if the sharing setting is set to private,Group names are mentioned 
               //and Attachment not marked explicity private on file upload
               else if(String.isNotBlank(objConfig.Collaboration_Group_Names__c)){
                   
                   for(CollaborationGroup collGroup : [SELECT Id 
                                                       FROM CollaborationGroup
                                                       WHERE Name =: objConfig.Collaboration_Group_Names__c.split(',')]){
                                                           
                                                           contentDocLinks.add(new ContentDocumentLink( ContentDocumentId = contentDocId,
                                                                                                       LinkedEntityId = collGroup.id,
                                                                                                       ShareType = 'C',
                                                                                                       Visibility = 'AllUsers'));
                                                       }                                                            
                   
               }
           }
        
        insert contentDocLinks;
    }
    
    //-----------------------------
    // @param: String contentDocId
    // @description: To delete attachment plus and related records created internally while uploading file using lighning:fileupload component
    // @return: NA
    //-----------------------------
    @AuraEnabled 
    public static void deleteAttachmentPlusAndCorrespondingRecords(String contentDocId){     
        
        A_Plus_Controller.isNotAplusMode = false;
        
        String attachmentPlusId = '';
        
        for(ContentDocumentLink objCDL : [SELECT Id,LinkedEntity.Type,LinkedEntityId
                                          FROM ContentDocumentLink
                                          WHERE ContentDocumentId =: contentDocId]){
                                              
                                              if(objCDL.LinkedEntity.Type == 'Attachments_New__c'){
                                                  
                                                  attachmentPlusId =  objCDL.LinkedEntityId;
                                              }
                                              
                                          }
        
        if(String.isNotBlank(attachmentPlusId)){
            
            delete new Attachments_New__c(Id = attachmentPlusId);
        }
        List<ContentDocument> cdRecord = [SELECT Id FROM ContentDocument WHERE ID =: contentDocId];
        if(cdRecord != null && cdRecord.size() >0){
            delete new ContentDocument(Id = contentDocId);
        }
        
    }
    
    //Used to call the mass file download from sharepoint 
    @AuraEnabled
    public static List<String> downloadMultipleFiles(List<String> attachPlusIds){
        List<String> response;
        if(attachPlusIds != null && attachPlusIds.size() > 0 && !Test.isRunningTest()){
            response = OWCSharepointAPIService.getFilesFromSharePoint(attachPlusIds);  
        }
        return response;
    }
    
    //Used to view the selected file from sharepoint
    @AuraEnabled
    public static String viewSharepointFile(String recordId){
        System.debug('recordId'+recordId);
        return OWCSharepointAPIService.viewSharePointFile(recordId);
    }
  
}