/* Used by the ICL aura component, NOT by the CashPartyToParty LWC, which uses CashCustomLookupController.cls
    and LookupSearchResult.cls */
public with sharing class inputLookupFieldController {
    @auraEnabled
    public static List<sObject> getRecords(string inputTxt, string objName) {

        if(inputTxt.length() > 3){
            inputTxt = String.escapeSingleQuotes(inputTxt);

            inputTxt = '\'%'+inputTxt+'%\'';
    
            String query = 
                'SELECT Id, Name, LastName, ShippingStreet, ShippingCity, Community_User__pc ' +
                    'FROM ' + objName + ' ' +
                    'WHERE Community_User__pc = FALSE ' +
                        'AND (Name LIKE ' + inputTxt + ' ' +
                                    'OR ShippingStreet LIKE ' + inputTxt + ') ' +
                    'ORDER BY LastName ASC NULLS FIRST, Name ASC NULLS FIRST ' +
                    'LIMIT 400';
    
    
            /* String query = 
                'Select Id, Name, ShippingStreet, ShippingCity, Community_User__pc ' +
                    ' FROM ' + objName +
                    ' WHERE Community_User__pc = FALSE ' +
                        'AND (Name LIKE ' + inputTxt +
                            ' OR ShippingStreet LIKE ' + inputTxt + ')' +
                    'LIMIT 300'; */
    
    
            return Database.Query(query);
        }else{
            return new List<sObject>();
        }

    }

}