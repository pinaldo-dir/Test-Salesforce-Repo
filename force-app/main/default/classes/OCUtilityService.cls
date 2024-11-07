public class OCUtilityService {
    public static void createLogs(String clsName,String errorMessage, String stackTrace, Integer lineNo){
        Online_Claim_Error_Log__c log = new Online_Claim_Error_Log__c (
        Class_Name__c = clsName,Error_Message__c = errorMessage,Error_Stack_Trace__c = stackTrace,
            Line_number__c = String.valueOf(lineNo)
        );
        insert log;
    }
}