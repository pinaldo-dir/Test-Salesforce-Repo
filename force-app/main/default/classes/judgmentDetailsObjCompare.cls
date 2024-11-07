public class judgmentDetailsObjCompare implements Comparable {
    public String PortDrayageMotorCarrierJudgmentStatus{get;set;}
    public String cliamantPlaintiffName{get;set;}
    public String PrimaryAddress{get;set;}
    public String JudgmentName{get;set;}
    public String JudgmentStatus{get;set;}
    public String Court{get;set;}
    public String Defendant_EmployerName{get;set;}
    public Decimal JudgmentTotal{get;set;}
    public Date confirmedOnListDate{get;set;}
    public Date confirmedOffListDate{get;set;}
    public String asSuccessorTo{get;set;} 
    
    public static String sortBy;
    public static String sortedOrder;
    
    public Integer compareTo(Object objToCompare){
        if(sortBy == ' Claimant / Plaintiff Name'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(cliamantPlaintiffName) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).cliamantPlaintiffName )){return 0;}
                else if(String.isEmpty(cliamantPlaintiffName)){return -1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).cliamantPlaintiffName )){return 1;}
                else{
                    return cliamantPlaintiffName.compareTo(((judgmentDetailsObjCompare)objToCompare).cliamantPlaintiffName);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(cliamantPlaintiffName) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).cliamantPlaintiffName )){return 0;}
                else if(String.isEmpty(cliamantPlaintiffName)){return 1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).cliamantPlaintiffName )){return -1;}
                else{
                    return -1 * cliamantPlaintiffName.compareTo(((judgmentDetailsObjCompare)objToCompare).cliamantPlaintiffName) ;
                }
            }            
        }
        else if(sortBy == 'Judgment Status'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(JudgmentStatus) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).JudgmentStatus )){return 0;}
                else if(String.isEmpty(JudgmentStatus)){return -1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).JudgmentStatus )){return 1;}
                else{
                    return JudgmentStatus.compareTo(((judgmentDetailsObjCompare)objToCompare).JudgmentStatus);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(JudgmentStatus) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).JudgmentStatus )){return 0;}
                else if(String.isEmpty(JudgmentStatus)){return 1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).JudgmentStatus )){return -1;}
                else{
                    return -1 * JudgmentStatus.compareTo(((judgmentDetailsObjCompare)objToCompare).JudgmentStatus) ;
                }
            }            
        }
        else if(sortBy == 'Judgment Name'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(JudgmentName) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).JudgmentName )){return 0;}
                else if(String.isEmpty(JudgmentName)){return -1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).JudgmentName )){return 1;}
                else{
                    return JudgmentName.compareTo(((judgmentDetailsObjCompare)objToCompare).JudgmentName);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(JudgmentName) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).JudgmentName )){return 0;}
                else if(String.isEmpty(JudgmentName)){return 1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).JudgmentName )){return -1;}
                else{
                    return -1 * JudgmentName.compareTo(((judgmentDetailsObjCompare)objToCompare).JudgmentName) ;
                }
            }
        }
        else if(sortBy == 'Court'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(Court) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).Court )){return 0;}
                else if(String.isEmpty(Court)){return -1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).Court )){return 1;}
                else{
                    return Court.compareTo(((judgmentDetailsObjCompare)objToCompare).Court);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(Court) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).Court )){return 0;}
                else if(String.isEmpty(Court)){return 1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).Court )){return -1;}
                else{
                    return -1 * Court.compareTo(((judgmentDetailsObjCompare)objToCompare).Court) ;
                }
            }
        }
        else if(sortBy == 'Defendant / Employer Name'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(Defendant_EmployerName) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).Defendant_EmployerName )){return 0;}
                else if(String.isEmpty(Defendant_EmployerName)){return -1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).Defendant_EmployerName )){return 1;}
                else{
                    return Defendant_EmployerName.compareTo(((judgmentDetailsObjCompare)objToCompare).Defendant_EmployerName);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(Defendant_EmployerName) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).Defendant_EmployerName )){return 0;}
                else if(String.isEmpty(Defendant_EmployerName)){return 1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).Defendant_EmployerName )){return -1;}
                else{
                    return -1 * Defendant_EmployerName.compareTo(((judgmentDetailsObjCompare)objToCompare).Defendant_EmployerName) ;
                }
            }
        }
        else if(sortBy == 'Judgment Total*'){
            if(sortedOrder == 'asc'){
                if(JudgmentTotal == 0.0 &&  ((judgmentDetailsObjCompare)objToCompare).JudgmentTotal == 0.0){return 0;}
                else if(JudgmentTotal == 0.0){return -1;}
                else if( ((judgmentDetailsObjCompare)objToCompare).JudgmentTotal == 0.0){return 1;}
                else{return Integer.valueOf(JudgmentTotal - ((judgmentDetailsObjCompare)objToCompare).JudgmentTotal);}
            }
            else if(sortedOrder == 'desc'){
                if( JudgmentTotal == 0.0 && ((judgmentDetailsObjCompare)objToCompare).JudgmentTotal == 0.0){return 0;}
                else if(JudgmentTotal == 0.0){return 1;}
                else if(((judgmentDetailsObjCompare)objToCompare).JudgmentTotal == 0.0){return -1;}
                else{
                    return -1 * Integer.valueOf(JudgmentTotal - ((judgmentDetailsObjCompare)objToCompare).JudgmentTotal);
                }
            }
        }
        else if(sortBy == 'Defendant Address'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(PrimaryAddress) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).PrimaryAddress )){return 0;}
                else if(String.isEmpty(PrimaryAddress)){return -1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).PrimaryAddress )){return 1;}
                else{
                    return PrimaryAddress.compareTo(((judgmentDetailsObjCompare)objToCompare).PrimaryAddress);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(PrimaryAddress) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).PrimaryAddress )){return 0;}
                else if(String.isEmpty(PrimaryAddress)){return 1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).PrimaryAddress )){return -1;}
                else{
                    return -1 * PrimaryAddress.compareTo(((judgmentDetailsObjCompare)objToCompare).PrimaryAddress) ;
                }
            }
        }
        else if(sortBy == 'As Successor To'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(asSuccessorTo) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).asSuccessorTo )){return 0;}
                else if(String.isEmpty(asSuccessorTo)){return -1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).asSuccessorTo )){return 1;}
                else{
                    return asSuccessorTo.compareTo(((judgmentDetailsObjCompare)objToCompare).asSuccessorTo);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(asSuccessorTo) && String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).asSuccessorTo )){return 0;}
                else if(String.isEmpty(asSuccessorTo)){return 1;}
                else if(String.isEmpty( ((judgmentDetailsObjCompare)objToCompare).asSuccessorTo )){return -1;}
                else{
                    return -1 * asSuccessorTo.compareTo(((judgmentDetailsObjCompare)objToCompare).asSuccessorTo) ;
                }
            }
        }
        else if(sortBy == 'Confirmed ON List Date'){
            if(sortedOrder == 'asc'){
                if(confirmedOnListDate == null &&  ((judgmentDetailsObjCompare)objToCompare).confirmedOnListDate == null){return 0;}
                else if(confirmedOnListDate == null){return -1;}
                else if(((judgmentDetailsObjCompare)objToCompare).confirmedOnListDate == null){return 1;}
                else{
                    return String.valueOf(confirmedOnListDate).compareTo(String.valueOf(((judgmentDetailsObjCompare)objToCompare).confirmedOnListDate)) ;
                }
            }
            else if(sortedOrder == 'desc'){
                if(confirmedOnListDate == null &&  ((judgmentDetailsObjCompare)objToCompare).confirmedOnListDate == null){return 0;}
                else if(confirmedOnListDate == null){return 1;}
                else if(((judgmentDetailsObjCompare)objToCompare).confirmedOnListDate == null){return -1;}
                else{
                    return -1 * String.valueOf(confirmedOnListDate).compareTo(String.valueOf(((judgmentDetailsObjCompare)objToCompare).confirmedOnListDate)) ;
                }
            }
        }
        else if(sortBy == 'Confirmed OFF List Date'){
            if(sortedOrder == 'asc'){
                if(confirmedOffListDate == null &&  ((judgmentDetailsObjCompare)objToCompare).confirmedOffListDate == null){return 0;}
                else if(confirmedOffListDate == null){return -1;}
                else if(((judgmentDetailsObjCompare)objToCompare).confirmedOffListDate == null){return 1;}
                else{
                    return String.valueOf(confirmedOffListDate).compareTo(String.valueOf(((judgmentDetailsObjCompare)objToCompare).confirmedOffListDate)) ;
                }
            }
            else if(sortedOrder == 'desc'){
                if(confirmedOffListDate == null &&  ((judgmentDetailsObjCompare)objToCompare).confirmedOffListDate == null){return 0;}
                else if(confirmedOffListDate == null){return 1;}
                else if(((judgmentDetailsObjCompare)objToCompare).confirmedOffListDate == null){return -1;}
                else{
                    return -1 * String.valueOf(confirmedOffListDate).compareTo(String.valueOf(((judgmentDetailsObjCompare)objToCompare).confirmedOffListDate)) ;
                }
            }
        }
        return 0;
    }
}