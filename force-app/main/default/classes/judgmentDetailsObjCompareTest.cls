@IsTest
public class judgmentDetailsObjCompareTest {
    @IsTest static void testJudgmentDetailsObjCompareForClaimantAscOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = ' Claimant / Plaintiff Name';
        judgmentDetailsObjCompare.sortedOrder = 'asc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForClaimantDescOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = ' Claimant / Plaintiff Name';
        judgmentDetailsObjCompare.sortedOrder = 'desc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForJudgementNameAscOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        judgmentDetailsObjCompare.sortBy = 'Judgment Name';
        judgmentDetailsObjCompare.sortedOrder = 'asc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForJudgementNameDescOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Judgment Name';
        judgmentDetailsObjCompare.sortedOrder = 'desc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForCourtAscOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Court';
        judgmentDetailsObjCompare.sortedOrder = 'asc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForCourtDescOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        judgmentDetailsObjCompare.sortBy = 'Court';
        judgmentDetailsObjCompare.sortedOrder = 'desc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForDefanmdantNameAscOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Defendant / Employer Name';
        judgmentDetailsObjCompare.sortedOrder = 'asc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForDefanmdantNameDescOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Defendant / Employer Name';
        judgmentDetailsObjCompare.sortedOrder = 'desc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForJudgmentTotalAscOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Judgment Total*';
        judgmentDetailsObjCompare.sortedOrder = 'asc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForJudgmentTotalDescOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Judgment Total*';
        judgmentDetailsObjCompare.sortedOrder = 'desc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForDefandantAddressAscOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Defendant Address';
        judgmentDetailsObjCompare.sortedOrder = 'asc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForDefandantAddressDescOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Defendant Address';
        judgmentDetailsObjCompare.sortedOrder = 'desc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForAsSuccessorToAscOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'As Successor To';
        judgmentDetailsObjCompare.sortedOrder = 'asc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForAsSuccessorToDescOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'As Successor To';
        judgmentDetailsObjCompare.sortedOrder = 'desc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForConfirmedOnListDateAscOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Confirmed ON List Date';
        judgmentDetailsObjCompare.sortedOrder = 'asc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForConfirmedOnListDateDescOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Confirmed ON List Date';
        judgmentDetailsObjCompare.sortedOrder = 'desc';
        wrapperList.sort();
    }
     @IsTest static void testJudgmentDetailsObjCompareForConfirmedOffListDateAscOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Confirmed OFF List Date';
        judgmentDetailsObjCompare.sortedOrder = 'asc';
        wrapperList.sort();
    }
    @IsTest static void testJudgmentDetailsObjCompareForConfirmedOffListDateDescOrder(){
        List<JudgmentDetailsObjCompare> wrapperList = new List<JudgmentDetailsObjCompare>();
        for(Integer i=0;i<10;i++){
            JudgmentDetailsObjCompare judgmentdetailObj = new JudgmentDetailsObjCompare();
            judgmentdetailObj.PortDrayageMotorCarrierJudgmentStatus = 'test' + i;
            judgmentdetailObj.Court = 'testCourt' + i;
            judgmentdetailObj.JudgmentName = 'testJudgment' + i;
            judgmentdetailObj.cliamantPlaintiffName = 'testCliamant' + i;
            judgmentdetailObj.JudgmentStatus = 'testStatus' + i;
            judgmentdetailObj.JudgmentTotal = i;
            judgmentdetailObj.PrimaryAddress = 'testAddress' + i;
            judgmentdetailObj.Defendant_EmployerName = 'testDefandant' + i;
            judgmentdetailObj.confirmedOnListDate = System.today();
            judgmentdetailObj.confirmedOffListDate = System.today();
            judgmentdetailObj.asSuccessorTo = 'testAsSuccessorTo' + i;
            judgmentdetailObj.compareTo(i);
            wrapperList.add(judgmentdetailObj);
        }
        
        judgmentDetailsObjCompare.sortBy = 'Confirmed OFF List Date';
        judgmentDetailsObjCompare.sortedOrder = 'desc';
        wrapperList.sort();
    }
}