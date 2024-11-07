public class Attachment_Widget_Controller{
    String Id;
    String sectionId;
    String componentId;
    public License_Registration__c reg;
    public List<AttachmentTable> attTable {get; set;}
    
    
    public Attachment_Widget_Controller(){
        this.Id = ApexPages.currentPage().getParameters().get('id');
        this.sectionId = ApexPages.currentPage().getParameters().get('sectionId');
        this.componentId = ApexPages.currentPage().getParameters().get('componentId');
        //System.debug(ApexPages.currentPage().getParameters().get('id') + ':');
        //System.debug(ApexPages.currentPage().getParameters().get('sectionId') + ':');
        //System.debug(ApexPages.currentPage().getParameters().get('componentId') + ':');
        
        if(this.Id != null && this.sectionId != null){
            loadTable();
        }
    }
    
    
    
    public void loadTable(){
        
        VIPForm__VIP_Category__c obj = [SELECT Name, Id,VIPForm__Name_Displayed__c FROM VIPForm__VIP_Category__c WHERE Id=:sectionId ];
        
        reg = [select id, name, (select id, name, Type__c,  Attachment_Name__c , Instructions__c, Expiration_Date__c,VIP_Form_Section__c, Attachment_Required__c, VIP_Form_Section_Name_Display__c from Submission_Detail__r where VIP_Form_Section_Name_Display__c = :obj.VIPForm__Name_Displayed__c Order by Attachment_Name__c ASC ) from License_Registration__c where id = :this.Id];
        if(reg.Submission_Detail__r != null && reg.Submission_Detail__r.size() > 0){
            Map<Id,Attachments_Plus__c> attPMap = new Map<Id,Attachments_Plus__c>([select id, Attachment_Required__c, Attachment_Name__c ,(select id from Attachments), (select id,ContentDocumentId from ContentDocumentLinks), VIP_Form_Section_Name_Display__c from Attachments_Plus__c where Id IN :reg.Submission_Detail__r]);
            Set<Id> contentDocumentIdSet = new Set<Id>();
            Map<Id,ContentVersion> contentDocVersionMap = new Map<Id,ContentVersion>();
            attTable = new List<AttachmentTable>();
            
            for(Attachments_Plus__c attP : reg.Submission_Detail__r){
                if(attPMap.containsKey(attP.id) && attPMap.get(attP.id).ContentDocumentLinks != null && attPMap.get(attP.id).ContentDocumentLinks.size() > 0){
                    for(ContentDocumentLink cdl : attPMap.get(attP.id).ContentDocumentLinks){
                        contentDocumentIdSet.add(cdl.ContentDocumentId);
                    }
                }
            }
            
            
            if(contentDocumentIdSet.size() > 0){
                for(ContentVersion cv : [select id, ContentDocumentId from ContentVersion WHERE ContentDocumentId IN :contentDocumentIdSet AND IsLatest = true]){
                    contentDocVersionMap.put(cv.ContentDocumentId, cv);
                }
            }
            
            for(Attachments_Plus__c attP : reg.Submission_Detail__r){
                system.debug('***SubmissionDetails.size() =' + reg.Submission_Detail__r.size());
                if(attPMap.containsKey(attP.id) && attPMap.get(attP.id).ContentDocumentLinks != null && attPMap.get(attP.id).ContentDocumentLinks.size() > 0){
                    attTable.add(new AttachmentTable(true, attp, attPMap.get(attP.id).ContentDocumentLinks[0].ContentDocumentId, contentDocVersionMap.get(attPMap.get(attP.id).ContentDocumentLinks[0].ContentDocumentId).id));
                    system.debug('***' + attP.id + '***ContentDocumentId****' + attPMap.get(attP.id).ContentDocumentLinks[0].ContentDocumentId);
                    
                }else{
                    attTable.add(new AttachmentTable(false, attp, null, null));
                    
                }
                
            }
            
            
        }
        
    }
    
    public class AttachmentTable{
        public Boolean hasAttachment {get; set;}
        public Attachments_Plus__c attP {get; set;}
        public Attachment att {get; set;}
        public string ContentDocumentId {get; set;}
        public string ContentVersionId {get; set;}
        
        public attachmentTable(Boolean hasAttachment, Attachments_Plus__c attP, Id ContentDocumentId, Id ContentVersionId){
            this.hasAttachment = hasAttachment;
            this.attP = attP;
            this.att = new Attachment();
            this.ContentDocumentId = ContentDocumentId;
            this.ContentVersionId = ContentVersionId;
        }
    }
    
    public void attachPDF2(){
        Logger.push('loadTable','Attachment_Widget_Controller');
        
        String attPId = ApexPages.CurrentPage().getParameters().get('attPId');
        //System.debug('***upload attachment id attPId***:' + attPId);
        
        try{
            List<Attachments_Plus__c> attPlus = new List<Attachments_Plus__c>();
            for(AttachmentTable attTab : attTable)
            {
                //System.debug('attTab' + attTab);
                if(attTab.attP.id == attPId && attTab.att.body != null)
                {
                    //system.debug('NEW CODE for RSS-598 IS HERE');
                    //system.debug(attTab.attP.VIP_Form_Section_Name_Display__c);
                    // This is for FLC Card Photo section only
                    if(attTab.attP.VIP_Form_Section_Name_Display__c == 'FLC Card Photo'){
                        if(!attTab.att.Name.containsIgnoreCase('.jpg') && !attTab.att.Name.containsIgnoreCase('.jpeg')){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You can only upload files with .jpg or .jpeg type.');
                            ApexPages.addMessage(myMsg);
                            attTab.att = new Attachment();
                            return;
                        }
                        
                        //System.debug('*****attTab.att' + attTab.att);
                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S';
                        conVer.PathOnClient = attTab.att.Name;
                        conVer.Title = attTab.att.Name;
                        conVer.VersionData = attTab.att.body;
                        conVer.Origin = 'C';
                        insert conVer;
                        
                        ContentDocumentLink cDe = new ContentDocumentLink();
                        cDe.ContentDocumentId = [select id, ContentDocumentId from ContentVersion where id = :conVer.id].ContentDocumentId;
                        cDe.LinkedEntityId = attTab.attP.id;
                        cDe.ShareType = 'I';
                        cDe.Visibility = 'AllUsers';
                        insert cDe;
                        system.debug('entering inside**');
                        attTab.hasAttachment = true;
                        attTab.ContentDocumentId = cDe.ContentDocumentId;
                        attTab.attP.Number_of_Attachments__c = 1;
                        ContentVersion file = [SELECT Id, Title, VersionData 
                                               FROM ContentVersion 
                                               WHERE ContentDocumentId = :cDe.ContentDocumentId AND Title LIKE '%.jpg' LIMIT 1];
                        
                        if (file != null) {
                            // Check file size
                            if (file.VersionData.size() < 54000) {
                                delete cDe;
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'File size must be greater than 54Kb.');
                                ApexPages.addMessage(myMsg);                        
                            }
                            
                            
                        }                        
                        
                    } else{
                        if(!attTab.att.Name.containsIgnoreCase('.pdf') && !attTab.att.Name.containsIgnoreCase('.jpg') && !attTab.att.Name.containsIgnoreCase('.tif') && !attTab.att.Name.containsIgnoreCase('.doc') && !attTab.att.Name.containsIgnoreCase('.docx') && !attTab.att.Name.containsIgnoreCase('.png') && !attTab.att.Name.containsIgnoreCase('.gif') && !attTab.att.Name.containsIgnoreCase('.csv') && !attTab.att.Name.containsIgnoreCase('.xls') && !attTab.att.Name.containsIgnoreCase('.xlsx')){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You can only upload files with .pdf, .jpg, .tif, png, .doc, .docx, .gif, .xls,.xlsx types.');
                            ApexPages.addMessage(myMsg);
                            attTab.att = new Attachment();
                            return;
                        }                 
                        //System.debug('*****attTab.att' + attTab.att);
                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S';
                        conVer.PathOnClient = attTab.att.Name;
                        conVer.Title = attTab.att.Name;
                        conVer.VersionData = attTab.att.body;
                        conVer.Origin = 'C';
                        insert conVer;
                        
                        ContentDocumentLink cDe = new ContentDocumentLink();
                        cDe.ContentDocumentId = [select id, ContentDocumentId from ContentVersion where id = :conVer.id].ContentDocumentId;
                        cDe.LinkedEntityId = attTab.attP.id;
                        cDe.ShareType = 'I';
                        cDe.Visibility = 'AllUsers';
                        insert cDe;
                        system.debug('entering inside**');
                        attTab.hasAttachment = true;
                        attTab.ContentDocumentId = cDe.ContentDocumentId;
                        attTab.attP.Number_of_Attachments__c = 1;
                        //System.debug('attTab.attP.Number_of_Attachments__c***'+attTab.attP.Number_of_Attachments__c);
                    }
                    
                    break;
                }
                attPlus.add(attTab.attP);
                // System.debug('attTab.attP*****'+attTab.attP);
            }
            
            System.debug('attPlus*****'+attPlus);
            update attPlus;
            attTable.clear();
            loadTable();
            
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            return;
        }
    }
    
    public void deleteAttachment(){
        Logger.push('loadTable','Attachment_Widget_Controller');
        String delID = ApexPages.CurrentPage().getParameters().get('delID');
        system.debug('***delete attachment id***' + delID);
        Attachments_Plus__c attP = [select id, (select id,ContentDocumentId from ContentDocumentLinks) from Attachments_Plus__c where id = :delID];
        list<Attachments_Plus__c> attPlus = new list<Attachments_Plus__c>();
        if(attP.ContentDocumentLinks != null && attP.ContentDocumentLinks.size() > 0){
            for(AttachmentTable attTab : attTable){
                if(delID == attTab.attP.id){
                    String conDocId = attP.ContentDocumentLinks[0].ContentDocumentId;
                    delete attP.ContentDocumentLinks[0];
                    delete new ContentDocument(id = conDocId);
                    attTab.hasAttachment = false;
                    //attTab.attP.Number_of_Attachments__c = 0;
                    attPlus.add(attTab.attP);
                    break;
                    
                }
            }
            update attPlus;
            attTable.clear();
            loadTable();
        }
        Logger.pop();
    }
    
    public void updateAttTable(){
        Logger.push('loadTable','Attachment_Widget_Controller');
        List<Attachments_Plus__c> attPlus = new List<Attachments_Plus__c>();
        for(AttachmentTable attTab : attTable){
            attPlus.add(attTab.attP);
        }
        update attPlus;
        Logger.pop();
    }
}