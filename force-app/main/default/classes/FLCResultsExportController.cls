global class FLCResultsExportController{
    
    public List<String> regIdList {get;set;}
    public List<License_Registration__c> regList {get;set;}
    public List<wrapLRClass> wrapLRLists {get;set;}
    
    public FLCResultsExportController() 
    {
        wrapLRLists = new List<wrapLRClass>() ;
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
                       , Legal_Entity_Name__c
                       , License_Registration_Number__c
                       , Physical_Business_Address_Line_1__c
                       , Physical_Business_Address_Line_2__c
                       , Physical_Business_City__c
                       , Physical_Business_State__c
                       , Physical_Business_Postal_Code__c
                       , Effective_Date__c
                       , Expiration_Date__c
                       , (SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c FROM Ownership__r WHERE Request_FLC_Card__c = TRUE)
                       , (SELECT Id, Registration__c, Bond_Amount__c FROM Bonds__r WHERE Bond_Status__c = 'Active')
                       , (SELECT Id, Registration__c, Name, Active__c FROM DBAS__r WHERE Active__c = 'Yes')
                       from License_Registration__c where id in : regIdList];
            
             //System.debug('*************regList'+regList);
             //System.debug('*************regList.dbas__r.name'+regList[0].dbas__r[0].name);
        }
        

        
        for(License_Registration__c eachReg : regList)
        {
            String DBA1 = '';
            String DBA2 = '';
            String DBA3 = '';
            
            //for(Integer i = 0; i < eachReg.DBAS__r.size(); i++)
            if(eachReg.DBAS__r.size() < 1){
                DBA1 = eachReg.Legal_Entity_Name__c;
            }
            else{
                for(Integer i = 0; i < eachReg.DBAS__r.size(); i++)
                {
                    if(eachReg.DBAS__r[i].Registration__c == eachReg.id){
                        if(i == 0){
                            DBA1 = eachReg.DBAS__r[i].Name;
                        }
                        if(i == 1){
                            DBA2 = eachReg.DBAS__r[i].Name;
                        }
                        if(i == 2){
                            DBA3 = eachReg.DBAS__r[i].Name;
                        }
                    }
                }
            }
                
            Decimal BondAmount = 0;
            for(Bond__c eachBond : eachReg.Bonds__r){
                BondAmount = BondAmount + eachBond.Bond_Amount__c;
            }
            
            if(eachReg.Ownership__r != Null && eachReg.Ownership__r.size() > 0){
                for(Ownership__c eachOwner : eachReg.Ownership__r)
                {
                    eachOwner.First_Name__c = eachOwner.First_Name__c == NULL ? '' : eachOwner.First_Name__c;
                    eachOwner.Middle_Name__c = eachOwner.Middle_Name__c == NULL ? '' : eachOwner.Middle_Name__c;
                    eachOwner.Last_Name__c = eachOwner.Last_Name__c == NULL ? '' : eachOwner.Last_Name__c;
                    eachReg.Physical_Business_Address_Line_1__c = eachReg.Physical_Business_Address_Line_1__c == NULL ? '' : eachReg.Physical_Business_Address_Line_1__c;                
                    eachReg.Physical_Business_Address_Line_2__c = eachReg.Physical_Business_Address_Line_2__c == NULL ? '' : eachReg.Physical_Business_Address_Line_2__c;
                    eachReg.Physical_Business_City__c = eachReg.Physical_Business_City__c == NULL ? '' : eachReg.Physical_Business_City__c;
                    eachReg.Physical_Business_State__c = eachReg.Physical_Business_State__c == NULL ? '' : eachReg.Physical_Business_State__c;
                    eachReg.Physical_Business_Postal_Code__c = eachReg.Physical_Business_Postal_Code__c == NULL ? '' : eachReg.Physical_Business_Postal_Code__c;
                    //eachReg.Effective_Date__c = eachReg.Effective_Date__c == NULL ? '' : eachReg.Effective_Date__c;
                    //eachReg.Expiration_Date__c = eachReg.Expiration_Date__c == NULL ? '' : eachReg.Expiration_Date__c;
                   //DBAnames = DBAnames == NULL ? '' : DBAnames;
                    DBA1 = DBA1 == NULL ? '' : DBA1;
                    DBA2 = DBA2 == NULL ? '' : DBA2;
                    DBA3 = DBA3 == NULL ? '' : DBA3;
                        
                    wrapLRLists.add(new wrapLRClass( String.valueOf(eachReg.Id)
                                                    , eachReg.License_Registration_Number__c
                                                    , eachOwner.First_Name__c
                                                    , eachOwner.Middle_Name__c
                                                    , eachOwner.Last_Name__c
                                                    , eachReg.Physical_Business_Address_Line_1__c
                                                    , eachReg.Physical_Business_Address_Line_2__c
                                                    , eachReg.Physical_Business_City__c
                                                    , eachReg.Physical_Business_State__c
                                                    , eachReg.Physical_Business_Postal_Code__c
                                                    , eachReg.Effective_Date__c
                                                    , eachReg.Expiration_Date__c
                                                    , BondAmount
                                                    , DBA1
                                                    , DBA2
                                                    , DBA3
                                                   ));                 
                }
            }
        }
    } 
    
    global class wrapLRClass{
        public String SystemId {get;set;}
        public String RegistrationNum {get;set;}
        public String FirstName {get;set;}
        public String MiddleName {get;set;}
        public String LastName {get;set;}
        public String AddressLine1 {get;set;}
        public String AddressLine2 {get;set;}
        public String City {get;set;}
        public String State {get;set;}
        public String Zip {get;set;}        
        public Date EffectiveDte {get;set;}
        public Date ExpirationDte {get;set;}
        public Decimal BondAmount {get;set;}
        public String DBA1 {get;set;}
        public String DBA2 {get;set;}
        public String DBA3 {get;set;}
        
        public wrapLRClass(String sSystemId
                           , String sRegistrationNum
                           , String sFirstName
                           , String sMiddleName
                           , String sLastName
                           , String sAddressLine1
                           , String sAddressLine2
                           , String sCity
                           , String sState
                           , String sZip
                           , Date sEffectiveDte
                           , Date sExpirationDte
                           , Decimal sBondAmount
                           , String sDBA1
                          , String sDBA2
                          , String sDBA3)
        {
            RegistrationNum = sRegistrationNum;
            SystemId = sSystemId;
            FirstName = sFirstName;
            MiddleName = sMiddleName;
            LastName = sLastName;
            AddressLine1 = sAddressLine1;
            AddressLine2 = sAddressLine2;
            City = sCity;
            State = sState;
            Zip = sZip;                       
            EffectiveDte = sEffectiveDte;
            ExpirationDte = sExpirationDte;
            BondAmount = sBondAmount;
            DBA1 = sDBA1;
            DBA2 = sDBA2;
            DBA3 = sDBA3;
        }
    }
}