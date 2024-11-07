public class OWCESignFlowActionToUpdateDocsName {

    @invocableMethod(label='Update Documents Name based on Defendants Count')
    public static List<String> updateSelectedDefsAndDocs(List<String> selectedDefendantsAndDocuments){
        List<String> DefendantAndDocuments = selectedDefendantsAndDocuments[0].split('/');
        Integer defendantCounts = Integer.valueOf(DefendantAndDocuments[0]);
        String selectedDocuments = DefendantAndDocuments[1];
        if(defendantCounts == 4){
            if(selectedDocuments.containsIgnoreCase('WCA 026A-1')){
                selectedDocuments = selectedDocuments.replace('WCA 026A-1', 'WCA 026A-4');
            }
            if(selectedDocuments.containsIgnoreCase('WCA 026B-1')){
                selectedDocuments = selectedDocuments.replace('WCA 026B-1', 'WCA 026B-4');
            }
            if(selectedDocuments.containsIgnoreCase('WCA 026C-1')){
                selectedDocuments = selectedDocuments.replace('WCA 026C-1', 'WCA 026C-4');
            }
        }else if(defendantCounts == 3){
            if(selectedDocuments.containsIgnoreCase('WCA 026A-1')){
                selectedDocuments = selectedDocuments.replace('WCA 026A-1', 'WCA 026A-3');
            }
            if(selectedDocuments.containsIgnoreCase('WCA 026B-1')){
                selectedDocuments = selectedDocuments.replace('WCA 026B-1', 'WCA 026B-3');
            }
            if(selectedDocuments.containsIgnoreCase('WCA 026C-1')){
                selectedDocuments = selectedDocuments.replace('WCA 026C-1', 'WCA 026C-3');
            }
        }else if(defendantCounts == 2){
            if(selectedDocuments.containsIgnoreCase('WCA 026A-1')){
                selectedDocuments = selectedDocuments.replace('WCA 026A-1', 'WCA 026A-2');
            }
            if(selectedDocuments.containsIgnoreCase('WCA 026B-1')){
                selectedDocuments = selectedDocuments.replace('WCA 026B-1', 'WCA 026B-2');
            }
            if(selectedDocuments.containsIgnoreCase('WCA 026C-1')){
                selectedDocuments = selectedDocuments.replace('WCA 026C-1', 'WCA 026C-2');
            }
        }else{
            //Do nothing
        }
        List<String> selectedDocumentsList = new List<String>();
        selectedDocumentsList.add(selectedDocuments);
        return selectedDocumentsList;
    }
}