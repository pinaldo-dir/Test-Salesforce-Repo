public class OWCESignFlowActionToCountDefIds {
    
    @invocableMethod(label='Get Count of Selected Defendants')
    public static List<Integer> getNoOfDefendants(List<String> defendantIds){
        List<Id> defendantIdList = defendantIds[0].split(';');
        List<Integer> countOfDefendantsId = new List<Integer>();
        countOfDefendantsId.add(defendantIdList.size());
        return countOfDefendantsId;
    }
}