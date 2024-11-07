global class RegistrationResultsExportController{
    
    public List<String> regIdList {get;set;}
    public List<License_Registration__c> regList {get;set;}
    
    public RegistrationResultsExportController() 
    {
        regIdList = new List<String>();
        String listReg = apexpages.currentpage().getparameters().get('myList');
        system.debug('reg list is '+listReg);
        if(String.isNotBlank(listReg) && listReg.contains(','))
            regIdList =  listReg.split(',');
        else{
            list<String> lis=new List<String>();
            lis.add(listReg);
            regIdList=lis;
        }

		for(Integer i = 0; i < regIdList.size(); i++)
        {
            //System.debug('*****regIdList[i1]'+regIdList[i]);
            if(regIdList[i] == 'undefined')
            {
                //System.debug('*****regIdList[i2]'+regIdList[i]);
                regIdList.remove(i);
            }
        }

        
        //System.debug('*****regIdList--'+regIdList);
        if(regIdList!=null && regIdList.size()>0){
            regList = [SELECT Id
                       , Status__c
                       , Name
                       , Account__c
                       , Account__r.Name
                       , Account__r.Legal_Entity_Name__c
                       , License_Registration_Number__c
                       , License_Registration_Type__c
                       , Mailing_Address_Line_1__c
                       , Mailing_City__c
                       , Mailing_State__c
                       , Mailing_Postal_Code__c
                       , Submitted_Date__c
                       , Effective_Date__c
                       , Expiration_Date__c
                       , Payment_Status__c
                       , Amount_Paid__c
                       , Legal_Entity_Name__c
                       , Workers_Compensation_Carrier__c
                       , WCI_Effective_Date__c
                       , WCI_Expiration_Date__c
                       , Workers_Comp_Selection__c,
                       (select Id, Name, Active__c from DBAS__r)
                       from License_Registration__c where id in : regIdList];
            
            
            
            // System.debug('*************regList'+regList);
            // System.debug('*************regList.dbas__r'+regList[0].dbas__r);
        }
    }
}