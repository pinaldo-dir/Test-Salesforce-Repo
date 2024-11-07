public class WageClaimSearchResultPageWrapperCtrl implements Comparable{
    public string accountName{get;set;}
    public string caseRole{get;set;}
    public string caseNumber{get;set;}
    public string caseRoleId{get;set;}
    public string id{get;set;}
    public string naicsCode{get;set;}
    public string naicsTitle{get;set;}
    public date dateofDocket{get;set;}
    public string assignedDeputy{get;set;}
    public string dirOffice{get;set;}
    public string caseStatus{get;set;}
    public string applies{get;set;}
    
    public static String sortBy;
    public static String sortedOrder;
    
    public Integer compareTo(Object objToCompare){
        if(sortBy == 'Party Name'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(accountName) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).accountName )){return 0;}
                else if(String.isEmpty(accountName)){return -1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).accountName )){return 1;}
                else{
                    return accountName.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).accountName);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(accountName) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).accountName )){return 0;}
                else if(String.isEmpty(accountName)){return 1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).accountName )){return -1;}
                else{
                    return -1 * accountName.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).accountName) ;
                }
            }
        }
        if(sortBy == 'Party Type'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(caseRole) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseRole )){return 0;}
                else if(String.isEmpty(caseRole)){return -1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseRole )){return 1;}
                else{
                    return caseRole.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseRole);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(caseRole) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseRole )){return 0;}
                else if(String.isEmpty(caseRole)){return 1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseRole )){return -1;}
                else{
                    return -1 * caseRole.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseRole) ;
                }
            }
        }
        if(sortBy == 'Case Number'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(caseNumber) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseNumber )){return 0;}
                else if(String.isEmpty(caseNumber)){return -1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseNumber )){return 1;}
                else{
                    return caseNumber.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseNumber);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(caseNumber) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseNumber )){return 0;}
                else if(String.isEmpty(caseNumber)){return 1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseNumber )){return -1;}
                else{
                    return -1 * caseNumber.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseNumber) ;
                }
            }
        }
        if(sortBy == 'NAICS Code'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(naicsCode) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsCode )){return 0;}
                else if(String.isEmpty(naicsCode)){return -1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsCode )){return 1;}
                else{
                    return naicsCode.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsCode);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(naicsCode) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsCode )){return 0;}
                else if(String.isEmpty(naicsCode)){return 1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsCode )){return -1;}
                else{
                    return -1 * naicsCode.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsCode) ;
                }
            }
        }
        if(sortBy == 'NAICS Industry'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(naicsTitle) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsTitle )){return 0;}
                else if(String.isEmpty(naicsTitle)){return -1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsTitle )){return 1;}
                else{
                    return naicsTitle.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsTitle);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(naicsTitle) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsTitle )){return 0;}
                else if(String.isEmpty(naicsTitle)){return 1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsTitle )){return -1;}
                else{
                    return -1 * naicsTitle.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).naicsTitle) ;
                }
            }
        }
        if(sortBy == 'Date Filed'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(String.valueOf(dateofDocket)) && String.isEmpty(String.valueOf( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).dateofDocket ))){return 0;}
                else if(String.isEmpty(String.valueOf(dateofDocket))){return -1;}
                else if(String.isEmpty(String.valueOf( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).dateofDocket ))){return 1;}
                else{
                    return String.valueOf(dateofDocket).compareTo(String.valueOf(((WageClaimSearchResultPageWrapperCtrl)objToCompare).dateofDocket));
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(String.valueOf(dateofDocket)) && String.isEmpty(String.valueOf( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).dateofDocket ))){return 0;}
                else if(String.isEmpty(String.valueOf(dateofDocket))){return 1;}
                else if(String.isEmpty(String.valueOf( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).dateofDocket ))){return -1;}
                else{
                    return -1 * String.valueOf(dateofDocket).compareTo(String.valueOf(((WageClaimSearchResultPageWrapperCtrl)objToCompare).dateofDocket)) ;
                }
            }
        }
        if(sortBy == 'Assigned Deputy'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(assignedDeputy) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).assignedDeputy )){return 0;}
                else if(String.isEmpty(assignedDeputy)){return -1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).assignedDeputy )){return 1;}
                else{
                    return assignedDeputy.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).assignedDeputy);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(assignedDeputy) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).assignedDeputy )){return 0;}
                else if(String.isEmpty(assignedDeputy)){return 1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).assignedDeputy )){return -1;}
                else{
                    return -1 * assignedDeputy.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).assignedDeputy) ;
                }
            }
        }
        if(sortBy == 'Dir Office'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(dirOffice) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).dirOffice )){return 0;}
                else if(String.isEmpty(dirOffice)){return -1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).dirOffice )){return 1;}
                else{
                    return dirOffice.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).dirOffice);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(dirOffice) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).dirOffice )){return 0;}
                else if(String.isEmpty(dirOffice)){return 1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).dirOffice )){return -1;}
                else{
                    return -1 * dirOffice.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).dirOffice) ;
                }
            }
        }
        if(sortBy == 'Case Status'){
            if(sortedOrder == 'asc'){
                if(String.isEmpty(caseStatus) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseStatus )){return 0;}
                else if(String.isEmpty(caseStatus)){return -1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseStatus )){return 1;}
                else{
                    return caseStatus.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseStatus);
                }
            }
            else if(sortedOrder == 'desc'){
                if(String.isEmpty(caseStatus) && String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseStatus )){return 0;}
                else if(String.isEmpty(caseStatus)){return 1;}
                else if(String.isEmpty( ((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseStatus )){return -1;}
                else{
                    return -1 * caseStatus.compareTo(((WageClaimSearchResultPageWrapperCtrl)objToCompare).caseStatus) ;
                }
            }
        }
        return 0;
    }
}