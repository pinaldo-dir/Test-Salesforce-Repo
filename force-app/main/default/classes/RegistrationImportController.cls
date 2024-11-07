public without sharing class RegistrationImportController 
{
    public transient string nameFile{get;set;}
    public transient string name {get;set;}
    public transient Blob contentFile{get;set;}
    public Boolean showProcessButton {get; set;}
    private String[] fileLines = new String[]{};
        public String recordType  {get; set;}
    //private List<Account> accsToUpload;
    //private List<Payee__c> payeesToUpload;
    //public String CaseId;
    //public DIR_Case__c dirCase;
    //public List<recordWrapper> accPayeeList;
    //public Map<String,recordWrapper> accPayeeMap;
    //
    private List<Registration_Account__c> growersToUpload;
    public Id regId;
    //public List<License_Registration__c> reg;
    public Registration_Account__c regAcct;
    
    public static Decimal lineNumber {get; set;}
    public static Boolean invalidFileFormat {get; set;}
    
    
    public RegistrationImportController()
    {
        showProcessButton = true;
        
        if(ApexPages.currentPage().getParameters().containsKey('msg'))
        {
            if('success'.equalsIgnoreCase(ApexPages.currentPage().getParameters().get('status')))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ApexPages.currentPage().getParameters().get('msg')));
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ApexPages.currentPage().getParameters().get('msg')));
            }
            
        }
        regId = ApexPages.currentPage().getParameters().get('id');
        
        //reg = [SELECT id, name FROM License_Registration__c WHERE id = : regId];
        
        //accPayeeList = new List<recordWrapper>();
        //accPayeeMap = new Map<String, recordWrapper>();
        
    }
    
    public Pagereference Close()
    {
        regId = ApexPages.currentPage().getParameters().get('id');
        License_Registration__c registration = [SELECT id FROM License_Registration__c WHERE id = :regId];
        
        PageReference RegPage = new ApexPages.StandardController(registration).view();
        RegPage.setRedirect(true);
        return RegPage;
    }
    
    public Pagereference ImportGrower(){         
        return ImportFile('grower');
    }
    
    public Pagereference ImportDriver(){
        return ImportFile('driver');
    }
    
    public Pagereference ImportSubcontractor(){
        return ImportFile('subcontractor');
    }
    
    public Pagereference ImportCustomerBusiness(){
        return ImportFile('customerBusiness');
    }
    
     public Pagereference ImportVehicle(){
        return ImportFile('vehicle');
    }
    /***This function reads the CSV file and inserts records into the Registration Account object. ***/
    public Pagereference ImportFile(String recordType)
    {
        String pageMsg = '';        
        invalidFileFormat = false;
        List<Registration_Account__c> allCSVRecords = new List<Registration_Account__c>();
        pageReference pr = Page.RegistrationImport;
        pr.getParameters().put('id', regId);
        pr.setRedirect(false);
        
        try
        {
            //Validate file is csv
            if(!nameFile.endsWith('.csv')){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The file uploaded is not a CSV file type.');
                ApexPages.addMessage(errormsg);
                return pr;
            }
            //Convert the uploaded file which is in BLOB format into a string
            nameFile =blobToString( contentFile,'ISO-8859-1');
            
            //Now seperate every row of the excel file
            filelines = nameFile.split('\r');
            
            //Iterate through every line and create a Registration Account record for each row
            growersToUpload = new List<Registration_Account__c>();
            //payeesToUpload = new List<Payee__c>();                
            
            System.debug('calling parseGrowerCSV(): recordType=' + recordType);
            if(recordType == 'grower'){
                allCSVRecords = parseGrowerCSV(contentFile.toString(),true, regId);
            }
            else if(recordType == 'driver'){
                allCSVRecords = parseDriverCSV(contentFile.toString(),true, regId);
                
            }
            else if(recordType == 'subcontractor'){
                allCSVRecords = parseSubcontractorCSV(contentFile.toString(),true, regId);
            }
            else if(recordType == 'customerBusiness'){
                allCSVRecords = parseCustomerBusinessCSV(contentFile.toString(),true, regId);
            }
            else if(recordType == 'vehicle'){
                allCSVRecords = parseVehicleCSV(contentFile.toString(),true, regId);
            }
            
            if(invalidFileFormat == false)
            {
                
                if(String.isNotBlank(pageMsg)){
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR, pageMsg);
                    ApexPages.addMessage(errormsg);
                    return pr;
                }
                insert allCSVRecords;
            }
            else
            {
                allCSVRecords = new List<Registration_Account__c>();
            }
            
            if(allCSVRecords.size() <= 0)
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file 1: Invalid File Format at line: \n' + (lineNumber + 1));
                ApexPages.addMessage(errormsg);
                
                return pr;
            }
            
        }
        catch(Exception e)
        {
            /*pr.getParameters().put('status', 'error');
            pr.getParameters().put('msg', 'An error has occured reading the CSV file'+e.getMessage());*/
            
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file 2: '+e.getMessage());
            ApexPages.addMessage(errormsg);
            
            return pr;
        }
        finally
        {
            fileLines = null;
            nameFile = null;
            name = null;
            contentFile = null;
        }     
        
        if(String.isBlank(pageMsg) && String.isBlank(pr.getParameters().get('msg'))){
            
            /*pr.getParameters().put('status', 'success');
pr.getParameters().put('msg', 'The file has been successfully imported, click the \'Process File\' button to start processing the import.!');*/
            ApexPages.Message successMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'The file has been successfully processed.');
            ApexPages.addMessage(successMsg);
        }
        return pr;
    }
    
    
    /**
This function convers the input CSV file in BLOB format into a string
@param input    Blob data representing correct string in @inCharset encoding
@param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
*/
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }  
    
    ////////////////////
    public static List<Registration_Account__c> parseGrowerCSV(String contents,Boolean skipHeaders, String regId) 
    {       
        System.debug('***********parseCSV()');
        List<Registration_Account__c> allCSVRecords = new List<Registration_Account__c>();
        
        Id growerRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        
        Integer num = 0;
        //remove the firt line containing the csv column headers
        lines.remove(0);         
        lineNumber = 0;
        
        for(String line : lines) 
        {
            System.debug('**********lineNumber a:' + lineNumber);
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');             
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            Registration_Account__c csvRecord = new Registration_Account__c();
            
            for(String field : fields) 
            {
                if (field.startsWith('"') && field.endsWith('"')) 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } 
                else if (field.startsWith('"')) 
                {
                    makeCompositeField = true;
                    compositeField = field;
                } 
                else if (field.endsWith('"')) 
                {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } 
                else if (makeCompositeField) 
                {
                    compositeField +=  ',' + field;
                } 
                else 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            System.debug('*********end if');
            
            if(cleanFields.size() != 13)
            {
                system.debug('**********************cleanFields.size()' + cleanFields.size());
                system.debug('**********************cleanFields' + cleanFields);
                invalidFileFormat = true;
                break;
            }
            System.debug('*********csvRecord 1:' + csvRecord);
            csvRecord.Registration__c = regId;
            System.debug('*********csvRecord 2:' + csvRecord);
            
            
            csvRecord.RecordTypeId = growerRecordTypeId;
            
            if(cleanFields[0].contains(','))
            {
                csvRecord.Business_Name__c = cleanFields[0].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.Business_Name__c = cleanFields[0].trim();
            }
            
            if(cleanFields[1].contains(','))
            {
                csvRecord.Business_Contact_Name__c = cleanFields[1].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.Business_Contact_Name__c = cleanFields[1].trim();
            }
            
            if(!String.isEmpty(cleanFields[2])) { csvRecord.Physical_Business_Street__c = cleanFields[2]; }
            if(!String.isEmpty(cleanFields[3])) { csvRecord.Physical_Business_Line_2__c = cleanFields[3]; }
            if(!String.isEmpty(cleanFields[4])) { csvRecord.Physical_Business_City__c = cleanFields[4]; }
            if(!String.isEmpty(cleanFields[5])) { csvRecord.Physical_Business_State__c = cleanFields[5]; }
            if(!String.isEmpty(cleanFields[6])) { csvRecord.Physical_Business_Zip_Code__c = cleanFields[6]; }

            
            Boolean mailingSame = FALSE;
            if(!String.isEmpty(cleanFields[7])) {
                if(cleanFields[7] == 'Yes'){ 
                    csvRecord.Mailing_Address_Same_as_Physical__c = TRUE; 
                }
                //csvRecord.Mailing_Address_Same_as_Physical__c = mailingSame; 
            }
            
            if(!mailingSame){
                if(!String.isEmpty(cleanFields[8])) { csvRecord.Mailing_Street__c = cleanFields[8]; }
                if(!String.isEmpty(cleanFields[9])) { csvRecord.Mailing_Address_Line_2__c = cleanFields[9]; }
                if(!String.isEmpty(cleanFields[10])) { csvRecord.Mailing_City__c = cleanFields[10]; }
                if(!String.isEmpty(cleanFields[11])) { csvRecord.Mailing_State__c = cleanFields[11]; }
                if(!String.isEmpty(cleanFields[12])) { csvRecord.Mailing_Zip_Code__c = cleanFields[12]; }

            }
            
            System.debug('**********csvRecord:' + csvRecord);
            allCSVRecords.add(csvRecord);
            
            lineNumber++;
        }
        
        System.debug('**********allCSVRecords:' + allCSVRecords);
        return allCSVRecords;       
    }
    
    ////////////////////
    public static List<Registration_Account__c> parseDriverCSV(String contents,Boolean skipHeaders, String regId) 
    {       
        System.debug('***********parseCSV()');
        List<Registration_Account__c> allCSVRecords = new List<Registration_Account__c>();
        
        
        Id driverRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        
        Integer num = 0;
        //remove the firt line containing the csv column headers
        lines.remove(0);         
        lineNumber = 0;
        
        for(String line : lines) 
        {
            System.debug('**********lineNumber a:' + lineNumber);
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');             
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            Registration_Account__c csvRecord = new Registration_Account__c();
            
            for(String field : fields) 
            {
                if (field.startsWith('"') && field.endsWith('"')) 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } 
                else if (field.startsWith('"')) 
                {
                    makeCompositeField = true;
                    compositeField = field;
                } 
                else if (field.endsWith('"')) 
                {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } 
                else if (makeCompositeField) 
                {
                    compositeField +=  ',' + field;
                } 
                else 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            System.debug('*********end if');
            
            if(cleanFields.size() != 8)
            {
                system.debug('**********************cleanFields.size()' + cleanFields.size());
                system.debug('**********************cleanFields' + cleanFields);
                invalidFileFormat = true;
                break;
            }
            System.debug('*********csvRecord 1:' + csvRecord);
            csvRecord.Registration__c = regId;
            System.debug('*********csvRecord 2:' + csvRecord);
            
            
            csvRecord.RecordTypeId = driverRecordTypeId;
            
            if(cleanFields[0].contains(','))
            {
                csvRecord.First_Name__c = cleanFields[0].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.First_Name__c = cleanFields[0].trim();
            }
            
            if(cleanFields[1].contains(','))
            {
                csvRecord.Middle_Name__c = cleanFields[1].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.Middle_Name__c = cleanFields[1].trim();
            }
            
            if(cleanFields[2].contains(','))
            {
                csvRecord.Last_Name__c = cleanFields[2].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.Last_Name__c = cleanFields[2].trim();
            }
            
            if(!String.isEmpty(cleanFields[3])) { csvRecord.Residential_Street__c = cleanFields[3]; }
            if(!String.isEmpty(cleanFields[4])) { csvRecord.Residential_Address_Line_2__c = cleanFields[4]; }
            if(!String.isEmpty(cleanFields[5])) { csvRecord.Residential_City__c = cleanFields[5]; }
            if(!String.isEmpty(cleanFields[6])) { csvRecord.Residential_State__c = cleanFields[6]; }
            if(!String.isEmpty(cleanFields[7])) { csvRecord.Residential_Zip_Code__c = cleanFields[7]; }
            
            System.debug('**********csvRecord:' + csvRecord);
            allCSVRecords.add(csvRecord);
            
            lineNumber++;
        }       
        
        System.debug('**********allCSVRecords:' + allCSVRecords);
        return allCSVRecords;       
    }
    
    ////////////////////
    public static List<Registration_Account__c> parseCustomerBusinessCSV(String contents,Boolean skipHeaders, String regId) 
    {       
        System.debug('***********parseCSV()');
        List<Registration_Account__c> allCSVRecords = new List<Registration_Account__c>();

        Id customerBusinessRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Customer/Business').getRecordTypeId();
        
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        
        Integer num = 0;
        //remove the firt line containing the csv column headers
        lines.remove(0);         
        lineNumber = 0;
        
        for(String line : lines) 
        {
            System.debug('**********lineNumber a:' + lineNumber);
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');             
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            Registration_Account__c csvRecord = new Registration_Account__c();
            
            for(String field : fields) 
            {
                if (field.startsWith('"') && field.endsWith('"')) 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } 
                else if (field.startsWith('"')) 
                {
                    makeCompositeField = true;
                    compositeField = field;
                } 
                else if (field.endsWith('"')) 
                {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } 
                else if (makeCompositeField) 
                {
                    compositeField +=  ',' + field;
                } 
                else 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            System.debug('*********end if');
            
            if(cleanFields.size() != 14)
            {
                system.debug('**********************cleanFields.size()' + cleanFields.size());
                system.debug('**********************cleanFields' + cleanFields);
                invalidFileFormat = true;
                break;
            }
            System.debug('*********csvRecord 1:' + csvRecord);
            csvRecord.Registration__c = regId;
            System.debug('*********csvRecord 2:' + csvRecord);
            
            
            csvRecord.RecordTypeId = customerBusinessRecordTypeId;
            
            if(cleanFields[0].contains(','))
            {
                csvRecord.Customer_Name__c = cleanFields[0].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.Customer_Name__c = cleanFields[0].trim();
            }
                                  
            if(!String.isEmpty(cleanFields[1])) { csvRecord.Physical_Business_Street__c = cleanFields[1]; }
            if(!String.isEmpty(cleanFields[2])) { csvRecord.Physical_Business_Line_2__c = cleanFields[2]; }
            if(!String.isEmpty(cleanFields[3])) { csvRecord.Physical_Business_City__c = cleanFields[3]; }
            if(!String.isEmpty(cleanFields[4])) { csvRecord.Physical_Business_State__c = cleanFields[4]; }
            if(!String.isEmpty(cleanFields[5])) { csvRecord.Physical_Business_Zip_Code__c = cleanFields[5]; }
            
            Boolean mailingSame = FALSE;
            if(!String.isEmpty(cleanFields[6])) {
                if(cleanFields[6] == 'Yes'){ 
                    csvRecord.Mailing_Address_Same_as_Physical__c = TRUE; 
                }
            }
            
            if(!mailingSame){
                if(!String.isEmpty(cleanFields[7])) { csvRecord.Mailing_Street__c = cleanFields[7]; }
                if(!String.isEmpty(cleanFields[8])) { csvRecord.Mailing_Address_Line_2__c = cleanFields[8]; }
                if(!String.isEmpty(cleanFields[9])) { csvRecord.Mailing_City__c = cleanFields[9]; }
                if(!String.isEmpty(cleanFields[10])) { csvRecord.Mailing_State__c = cleanFields[10]; }
                if(!String.isEmpty(cleanFields[11])) { csvRecord.Mailing_Zip_Code__c = cleanFields[11]; }
                if(!String.isEmpty(cleanFields[12])) { csvRecord.Business_Phone__c = cleanFields[12]; }
                if(!String.isEmpty(cleanFields[13])) { csvRecord.Email_Address__c = cleanFields[13]; }
            }
                        
            System.debug('**********csvRecord:' + csvRecord);
            allCSVRecords.add(csvRecord);
            
            lineNumber++;
        }       
        
        System.debug('**********allCSVRecords:' + allCSVRecords);
        return allCSVRecords;       
    }
    
    ////////////////////
    public static List<Registration_Account__c> parseSubcontractorCSV(String contents,Boolean skipHeaders, String regId) 
    {       
        System.debug('***********parseCSV()');
        List<Registration_Account__c> allCSVRecords = new List<Registration_Account__c>();

        Id subContractorRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Subcontractors Franchises').getRecordTypeId();
        
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        
        Integer num = 0;
        //remove the firt line containing the csv column headers
        lines.remove(0);         
        lineNumber = 0;
        
        for(String line : lines) 
        {
            System.debug('**********lineNumber a:' + lineNumber);
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');             
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            Registration_Account__c csvRecord = new Registration_Account__c();
            
            for(String field : fields) 
            {
                if (field.startsWith('"') && field.endsWith('"')) 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } 
                else if (field.startsWith('"')) 
                {
                    makeCompositeField = true;
                    compositeField = field;
                } 
                else if (field.endsWith('"')) 
                {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } 
                else if (makeCompositeField) 
                {
                    compositeField +=  ',' + field;
                } 
                else 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            System.debug('*********end if');
            
            if(cleanFields.size() != 10)
            {
                system.debug('**********************cleanFields.size()' + cleanFields.size());
                system.debug('**********************cleanFields' + cleanFields);
                invalidFileFormat = true;
                break;
            }
            System.debug('*********csvRecord 1:' + csvRecord);
            csvRecord.Registration__c = regId;
            System.debug('*********csvRecord 2:' + csvRecord);
            
            
            csvRecord.RecordTypeId = subContractorRecordTypeId;
            
            if(cleanFields[0].contains(','))
            {
                csvRecord.Subcontract_Franchisee_Registration_Num__c = cleanFields[0].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.Subcontract_Franchisee_Registration_Num__c = cleanFields[0].trim();
            }
            
            if(cleanFields[1].contains(','))
            {
                csvRecord.Subcontractor_Franchisee_Name__c = cleanFields[1].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.Subcontractor_Franchisee_Name__c = cleanFields[1].trim();
            }

            if(!String.isEmpty(cleanFields[2])) { csvRecord.Subcontractor_Type__c = cleanFields[2]; }    
            if(!String.isEmpty(String.valueOf(cleanFields[3]))) { csvRecord.Number_of_individuals_perform_Janitorial__c = integer.valueof(cleanFields[3]); }
            if(!String.isEmpty(cleanFields[4])) { csvRecord.Mailing_Street__c = cleanFields[4]; }
            if(!String.isEmpty(cleanFields[5])) { csvRecord.Mailing_Address_Line_2__c = cleanFields[5]; }
            if(!String.isEmpty(cleanFields[6])) { csvRecord.Mailing_City__c = cleanFields[6]; }
            if(!String.isEmpty(cleanFields[7])) { csvRecord.Mailing_State__c = cleanFields[7]; }
            if(!String.isEmpty(cleanFields[8])) { csvRecord.Mailing_Zip_Code__c = cleanFields[8]; }         
            if(!String.isEmpty(cleanFields[9])) { csvRecord.Email_Address__c = cleanFields[9]; }  
            
            System.debug('**********csvRecord:' + csvRecord);
            allCSVRecords.add(csvRecord);
            
            lineNumber++;
        }       
        
        System.debug('**********allCSVRecords:' + allCSVRecords);
        return allCSVRecords;       
    }
    
////////////////////
    public static List<Registration_Account__c> parseVehicleCSV(String contents,Boolean skipHeaders, String regId) 
    {       
        System.debug('***********parseCSV()');
        List<Registration_Account__c> allCSVRecords = new List<Registration_Account__c>();

        Id vehicleRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        
        Integer num = 0;
        //remove the firt line containing the csv column headers
        lines.remove(0);         
        lineNumber = 0;
        
        for(String line : lines) 
        {
            System.debug('**********lineNumber a:' + lineNumber);
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');             
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            Registration_Account__c csvRecord = new Registration_Account__c();
            
            for(String field : fields) 
            {
                if (field.startsWith('"') && field.endsWith('"')) 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } 
                else if (field.startsWith('"')) 
                {
                    makeCompositeField = true;
                    compositeField = field;
                } 
                else if (field.endsWith('"')) 
                {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } 
                else if (makeCompositeField) 
                {
                    compositeField +=  ',' + field;
                } 
                else 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            System.debug('*********end if');
            
            if(cleanFields.size() != 27)
            {
                system.debug('**********************cleanFields.size()' + cleanFields.size());
                system.debug('**********************cleanFields' + cleanFields);
                invalidFileFormat = true;
                break;
            }
            System.debug('*********csvRecord 1:' + csvRecord);
            csvRecord.Registration__c = regId;
            System.debug('*********csvRecord 2:' + csvRecord);
            
            
            csvRecord.RecordTypeId = vehicleRecordTypeId;
            
           if(cleanFields[0].contains(','))
            {
                csvRecord.First_Name__c = cleanFields[0].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.First_Name__c = cleanFields[0].trim();
            }
              
            if(cleanFields[1].contains(','))
            {
                csvRecord.Last_Name__c = cleanFields[1].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.Last_Name__c = cleanFields[1].trim();
            }

            if(!String.isEmpty(cleanFields[2])) { csvRecord.Vehicle_Year__c = cleanFields[2]; }    
            if(!String.isEmpty(String.valueOf(cleanFields[3]))) { csvRecord.Vehicle_Make__c = cleanFields[3]; }
            if(!String.isEmpty(cleanFields[4])) { csvRecord.Vehicle_Model__c = cleanFields[4]; }
            if(!String.isEmpty(cleanFields[5])) { csvRecord.Vehicle_License_Plate_Number__c = cleanFields[5]; }
            if(!String.isEmpty(cleanFields[6])) { csvRecord.Vehicle_Identification_Number__c = cleanFields[6]; }
            if(!String.isEmpty(cleanFields[7])) { csvRecord.Vehicle_Body_Type__c = cleanFields[7]; }
            if(!String.isEmpty(cleanFields[8])) { csvRecord.Vehicle_Seating_Capacity__c = integer.valueof(cleanFields[8]); }
            if(!String.isEmpty(cleanFields[9])) { csvRecord.Insurance_Carrier_Name__c = cleanFields[9]; }            
            if(!String.isEmpty(cleanFields[10])) { csvRecord.Insurance_Policy_Number__c = cleanFields[10]; } 
            if(!String.isEmpty(cleanFields[11])) { csvRecord.Insurance_Policy_Effective_Date__c = date.parse(cleanFields[11]); } 
            if(!String.isEmpty(cleanFields[12])) { csvRecord.Insurance_Policy_Expiration_Date__c = date.parse(cleanFields[12]); } 
            if(!String.isEmpty(cleanFields[13])) { csvRecord.Insurance_Policy_Coverage_Limits__c = cleanFields[13]; } 
            if(!String.isEmpty(cleanFields[14])) { csvRecord.Insurance_Policy_Medical_Coverage__c = integer.valueof(cleanFields[14]); }
            if(!String.isEmpty(cleanFields[15])) { csvRecord.Residential_Street__c = cleanFields[15]; }
            if(!String.isEmpty(cleanFields[16])) { csvRecord.Residential_Address_Line_2__c = cleanFields[16]; }
            if(!String.isEmpty(cleanFields[17])) { csvRecord.Residential_City__c = cleanFields[17]; }
            if(!String.isEmpty(cleanFields[18])) { csvRecord.Residential_State__c = cleanFields[18]; }
            if(!String.isEmpty(cleanFields[19])) { csvRecord.Residential_Zip_Code__c = cleanFields[19]; }
            if(!String.isEmpty(cleanFields[20])) { csvRecord.Residential_Phone__c = cleanFields[20]; }
            
            Boolean mailingSame = FALSE;
            if(!String.isEmpty(cleanFields[21])) {
                if(cleanFields[21] == 'Yes'){ 
                    csvRecord.Mailing_Address_Same_as_Residential__c = TRUE; 
                }
            }
            if(!mailingSame){
                if(!String.isEmpty(cleanFields[22])) { csvRecord.Mailing_Street__c = cleanFields[22]; }
                if(!String.isEmpty(cleanFields[23])) { csvRecord.Mailing_Address_Line_2__c = cleanFields[23]; }
                if(!String.isEmpty(cleanFields[24])) { csvRecord.Mailing_City__c = cleanFields[24]; }
                if(!String.isEmpty(cleanFields[25])) { csvRecord.Mailing_State__c = cleanFields[25]; }
                if(!String.isEmpty(cleanFields[26])) { csvRecord.Mailing_Zip_Code__c = cleanFields[26]; }
            }
            System.debug('**********csvRecord:' + csvRecord);
            allCSVRecords.add(csvRecord);
            
            lineNumber++;
        }       
        
        System.debug('**********allCSVRecords:' + allCSVRecords);
        return allCSVRecords;       
    }    
}