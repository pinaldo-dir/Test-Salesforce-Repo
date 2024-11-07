@IsTest
public class WageClaimSearchResultPageWrapperCtrlTest {
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForAccountNameAscOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.caseRole = 'testCaseRoleId' + i;
            wageClaimObj.caseRoleId = 'test' + i;
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Party Name';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'asc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForAccountNameDescOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Party Name';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'desc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForPartyTypeAscOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.caseRole = 'testCaseRoleId' + i;
            wageClaimObj.caseRoleId = 'test' + i;
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Party Type';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'asc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForPartyTypeDescOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Party Type';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'desc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForCaseNumberAscOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.caseRole = 'testCaseRoleId' + i;
            wageClaimObj.caseRoleId = 'test' + i;
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Case Number';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'asc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForCaseNumberDescOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Case Number';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'desc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForNAICSTitleAscOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.caseRole = 'testCaseRoleId' + i;
            wageClaimObj.caseRoleId = 'test' + i;
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'NAICS Title';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'asc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForNAICSTitleDescOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'NAICS Title';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'desc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForNAICSCodeAscOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.caseRole = 'testCaseRoleId' + i;
            wageClaimObj.caseRoleId = 'test' + i;
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'NAICS Code';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'asc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForNAICSCodeDescOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'NAICS Code';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'desc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForDateFiledAscOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.caseRole = 'testCaseRoleId' + i;
            wageClaimObj.caseRoleId = 'test' + i;
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Date Filed';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'asc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForDateFiledDescOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Date Filed';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'desc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForAssignedDeputyAscOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.caseRole = 'testCaseRoleId' + i;
            wageClaimObj.caseRoleId = 'test' + i;
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Assigned Deputy';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'asc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForAssignedDeputyDescOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Assigned Deputy';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'desc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForDirOfficeAscOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.caseRole = 'testCaseRoleId' + i;
            wageClaimObj.caseRoleId = 'test' + i;
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Dir Office';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'asc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForDirOfficeDescOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Dir Office';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'desc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForCaseStatusAscOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.caseRole = 'testCaseRoleId' + i;
            wageClaimObj.caseRoleId = 'test' + i;
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Case Status';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'asc';
        wageClaimList.sort();
    }
    @IsTest static void WageClaimSearchResultPageWrapperCtrlForCaseStatusDescOrder(){
        List<WageClaimSearchResultPageWrapperCtrl> wageClaimList = new List<WageClaimSearchResultPageWrapperCtrl>();
        for(Integer i=0;i<10;i++){
            WageClaimSearchResultPageWrapperCtrl wageClaimObj = new WageClaimSearchResultPageWrapperCtrl();
            wageClaimObj.accountName = 'testaccount' + i;
            wageClaimObj.caseRole = 'testcaserole' + i;
            wageClaimObj.caseNumber = 'testcasenumber' + i;
            wageClaimObj.naicsCode = 'testnaicscode' + i;
            wageClaimObj.naicsTitle = 'testnaicstitile' + i;
            wageClaimObj.dateofDocket = System.today();
            wageClaimObj.assignedDeputy = 'testAssignedDeputy' + i;
            wageClaimObj.caseStatus = 'testCaseStatus' + i;
            wageClaimObj.applies = 'testApplies' + i;
            wageClaimObj.dirOffice = 'testOffice '+ i;
            wageClaimList.add(wageClaimObj);
        }
        
        WageClaimSearchResultPageWrapperCtrl.sortBy = 'Case Status';
        WageClaimSearchResultPageWrapperCtrl.sortedOrder = 'desc';
        wageClaimList.sort();
    }
}