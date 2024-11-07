trigger OWCMultipleFileUploadTrigger on ContentVersion (after insert, after update) {
    OWCMultipleFileUploadHandler multipleFileUploadObj = new OWCMultipleFileUploadHandler(); 
    if(trigger.isafter && trigger.isinsert){
        multipleFileUploadObj.validateOWCFiles(Trigger.new);
    }
}