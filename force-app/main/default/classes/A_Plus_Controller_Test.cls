//-----------------------------
// @author: Oswin Correa 
// @date: 4/4/2018
// @description: Test Class of A_Plus_Controller (Controller of the Attachments + Lightning component)
//-----------------------------
@isTest
private class A_Plus_Controller_Test {

    private static testMethod void testController() {
        
        
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        Contact objContact =  new Contact(LastName = 'Test', AccountId = objAccount.Id);
        insert objContact;
        List<String> attachPlusIds = new List<String>();
        Attachments_New__c objAttachment1 = new Attachments_New__c(File_Name__c = 'Test',
                                                                  File_Type__c = 'Test',
                                                                  Related_Id__c = objAccount.Id,
                                                                  APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"Legal","fieldName":"File_Name","fieldAPIName":"File_Name"},{"value":"Third Party","fileType":"Legal","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"Legal","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"Legal","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]');
                                                                  
        Attachments_New__c objAttachment2 = new Attachments_New__c(File_Name__c = 'Test',
                                                                  File_Type__c = 'Test', 
                                                                  Release_to_Public__c = true,
                                                                  Share_Point_Item_Id__c = '1234567',
                                                                  Related_Id__c = objContact.Id,
                                                                  APlus_Json__c = '[{"value":"Wage Claim Summary Report","fileType":"Legal","fieldName":"File_Name","fieldAPIName":"File_Name"},{"value":"Third Party","fileType":"Legal","fieldName":"Description","fieldAPIName":"Description"},{"value":"false","fileType":"Legal","fieldName":"Private","fieldAPIName":"Private"},{"value":"Intake","fileType":"Legal","fieldName":"File_Type__c","fieldAPIName":"File_Type__c"}]');
                                                                  
        insert new List<Attachments_New__c> {objAttachment1,objAttachment2};
        attachPlusIds.add(objAttachment1.id);
        attachPlusIds.add(objAttachment2.id);
        
        Attachments_New__c attachPlus = [SELECT Id,Related_Id__c FROM Attachments_New__c WHERE Related_Id__c =: objAccount.Id LIMIT 1];
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Wage Claim Summary Report'; 
        content.PathOnClient='/' + content.Title + '.pdf'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=attachPlus.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        String contentDocId = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        insert contentlink;
        
        A_Plus_Controller.fetchHeadersAndData(objAccount.id,'Test','');
        
        
        //Public Sharing
        A_Plus_Controller.uploadFile('{"Test" : "Test"}',contentDocId,'Test',objAccount.id,'Test', '{"Id":"m06350000004Dl8AAE","Community_ID__c":"","File_Type__c":"Legal","Object_API_Name__c":"Account","Child_Relationship_Names_Standard__c": "Contacts","Child_Relationship_Names_Custom__c": "",'+
                                                                                                                                      '"Collaboration_Group_Names__c":"","Sharing_Permissions__c":"Public","Sort_Order__c":"5"}');
        
        //Private Sharing
        A_Plus_Controller.uploadFile('{"Test" : "Test"}',contentDocId,'Test',objAccount.id,'Test', '{"Id":"m06350000004Dl8AAE","Community_ID__c":"","File_Type__c":"Legal","Object_API_Name__c":"Account","Child_Relationship_Names_Standard__c": "Contacts","Child_Relationship_Names_Custom__c": "",'+
                                                                                                                    '"Collaboration_Group_Names__c":"Test,Test1","Sharing_Permissions__c":"Private","Sort_Order__c":"5"}');
        
        //Move/Edit Sharing
        A_Plus_Controller.updateAttachment('{"Test" : "Test2","Test1" : "Test2"}',attachPlus.id,'Test',objAccount.Id, '{"Id":"m06350000004Dl8AAE","Community_ID__c":"","File_Type__c":"Legal","Object_API_Name__c":"Account","Child_Relationship_Names_Standard__c": "Contacts","Child_Relationship_Names_Custom__c": "",'+
                                                                                                                                      '"Collaboration_Group_Names__c":"","Sharing_Permissions__c":"Private","Sort_Order__c":"5"}', true);
                
        String jsonString = '[{"name":"3rdpartyclaim.png","fileExtension":"png","documentId":"06935000001o2sOAAQ","File_Name":"3rdpartyclaim","Private":false,"Description":""},{"name":"Case1.png","fileExtension":"png","documentId":"06935000001o2sTAAQ","File_Name":"Case1","Private":false,"Description":""},{"name":"caseRole1.png","fileExtension":"png","documentId":"06935000001o2sYAAQ","File_Name":"caseRole1","Private":false,"Description":""}]';
        String configDetails = '{"Id":"m0Ct0000000XZSIEA4","File_Type__c":"Hearing","Sharing_Permissions__c":"Public","Sort_Order__c":30}';
        Test.startTest();
            A_Plus_Multiple_File_Uploader_ctrl.uploadMultipleFiles('Hearing', jsonString, objAccount.Id, configDetails);
            A_Plus_Multiple_File_Uploader_ctrl.deleteMultipleFiles(jsonString);
        Test.stopTest();
        
        
        
        
        String attchId = objAttachment1.id;
        A_Plus_Controller.deleteAttachment(attchId);
        
        system.assertEquals(false, [SELECT Id 
                                    FROM Attachments_Data__c
                                    WHERE Id =: attchId ].size() ==  1);
        
        A_Plus_Controller.downloadMultipleFiles(attachPlusIds);

        
    }

}