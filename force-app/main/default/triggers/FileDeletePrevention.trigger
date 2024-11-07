trigger FileDeletePrevention on ContentDocument (after delete) {
    if(Label.runRegistrationTrigger=='true'){    
        // Get the current user's profile name
        Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
        Boolean hasPermission = FeatureManagement.checkPermission('HR_Division_Form_1_PS');
        
        // If current user is HR staff or division user, do not allow Attachments to be deleted
        if ((prof.Name.contains('HR') || hasPermission == TRUE)
           ) {
               for (ContentDocument ConD : Trigger.old) {
                   ConD.addError('You do not have permission to delete file. Please submit a ServiceNow Incident to request for file deletion.');
               }   
           }
    }
}