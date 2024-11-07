trigger enhancedNoteEditDeleteRules on ContentDocument (before update, before delete) {

    // Get current user's profile name
    Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];

    // If current user is not System Admin or Sys Admin LTD, prevent user from deleting note.
    if (!prof.Name.contains('System Administrator')) {  
        if(Trigger.isDelete){    
            Map<Id, ContentDocument> mapContentDocument = new Map<Id, ContentDocument>([Select Id, FileExtension from ContentDocument where Id in: trigger.oldMap.keyset()]);
            for(ContentDocument cd : Trigger.Old){
                if(mapContentDocument.containsKey(cd.Id) && mapContentDocument.get(cd.Id).FileExtension == 'snote' ){
                    cd.adderror('Notes cannot be deleted.');
                }
            }
        }
    }
}