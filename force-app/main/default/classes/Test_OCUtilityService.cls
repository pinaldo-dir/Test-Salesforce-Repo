@isTest
public class Test_OCUtilityService {
static testMethod void TestcreateLogs()
{
   String clsName='Testing';
    String errorMessage='test failed';
       String stackTrace='check logs';
    Integer lineNo=7;
    OCUtilityService.createLogs(clsName,errorMessage,stackTrace,lineNo);
}
}