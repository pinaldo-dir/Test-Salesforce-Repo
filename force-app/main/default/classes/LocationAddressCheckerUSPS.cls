public with sharing class LocationAddressCheckerUSPS {
    @AuraEnabled
    public static LocationAddressCheckerUSPS.MulesoftAddressResponse verifyAddressByUSPS(String addressJson){
        System.debug('addressJson ::: '+addressJson);
        //call USPS API to verify address
        
        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Mulesoft_USPS_Credential/api/validate');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('client_id', '{!$Credential.UserName}');
        req.setHeader('client_secret', '{!$Credential.Password}');
        req.setBody(addressJson);
        req.setMethod('POST');
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        System.debug('response body:::::::::::'+res.getBody());
        MulesoftAddressResponse responseObj = MulesoftAddressResponse.parse(res.getBody());
        System.debug('responseObj ::: '+responseObj);
        
        return responseObj;
    }

    @AuraEnabled
    public static LocationAddressCheckerUSPS.MulesoftAddressResponse getLocationAddress(String recordId){
        addressJSON addressObj = new addressJSON();
        LocationAddressCheckerUSPS.MulesoftAddressResponse responseObj;
        try{
            System.debug('recordId ::: '+recordId);
            if(String.isNotBlank(recordId)){
                Address__c loc = [SELECT Id, Name, Address__c, City__c, State__c, Zip_Code__c FROM Address__c
                                                    WHERE Id =: recordId LIMIT 1];
                if(loc != null){
                    addressObj.address2 = loc.Address__c != null ? loc.Address__c : '';
                    addressObj.City = loc.City__c != null ? loc.City__c : '';
                    addressObj.state = loc.State__c != null ? loc.State__c : '';
                    if(String.isNotBlank(loc.Zip_Code__c)){
                         if(loc.Zip_Code__c.length() == 9){
                            addressObj.zip5 =  loc.Zip_Code__c.substring(0, 5);
                            addressObj.zip4 =  loc.Zip_Code__c.substring(5);
                         }else{
                            addressObj.zip5 =  loc.Zip_Code__c;
                            addressObj.zip4 = '';
                         }   
                    }else{
                        addressObj.zip5 =  '';
                        addressObj.zip4 = '';
                    }
                    //addressObj.zip5 =  loc.Zip_Code__c != null ? loc.Zip_Code__c : '';
                }
                responseObj = LocationAddressCheckerUSPS.verifyAddressByUSPS(JSON.serialize(addressObj));
                if(responseObj.Address != null){
                    for(Address add: responseObj.Address){
                        if(String.isNotBlank(add.Zip4)){
                            add.Zip5 += +'-'+add.Zip4;
                        }
                    }
                }
                
                System.debug('responseObj ::: '+responseObj);
            }
            return responseObj;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateLocationAddress(String selectedRecords, String recordId){
        System.debug('selectedRecords ::: '+selectedRecords);
        AddressJSON addWrapper = (AddressJSON)JSON.deserialize(selectedRecords, AddressJSON.class);
        if(addWrapper != null && recordId != null){
            Address__c locationObj = [SELECT Id, Address__c, City__c, State__c, Zip_Code__c  FROM Address__c
                                                    WHERE Id =: recordId LIMIT 1];
            locationObj.Address__c = addWrapper.address2;
            locationObj.City__c = addWrapper.City;
            locationObj.State__c = addWrapper.state;
            
            if(addWrapper.zip5 != null && addWrapper.zip5.contains('-')){
                //addWrapper.zip5 = addWrapper.zip5.remove('-');
              locationObj.Zip_Code__c = addWrapper.zip5;  
            }
            locationObj.Zip_Code__c = addWrapper.zip5; 
            if(locationObj != null){
                System.debug('locationObj ::: '+locationObj);
                update locationObj;
                return true;
            }
        }
        return false;
    }
    public class MulesoftAddressResponse {
        @auraEnabled public List<Address> Address;
        @auraEnabled public String message;
    }
    public class Address {
		@auraEnabled public String Address1;
		@auraEnabled public String Address2;
		@auraEnabled public String City;
		@auraEnabled public String CityAbbreviation;
		@auraEnabled public String State;
		@auraEnabled public String Zip5;
		@auraEnabled public String Zip4;
		@auraEnabled public String DeliveryPoint;
		@auraEnabled public String ReturnText;
		@auraEnabled public String CarrierRoute;
		@auraEnabled public String Footnotes;
		@auraEnabled public String DPVConfirmation;
		@auraEnabled public String DPVFootnotes;
		@auraEnabled public String CentralDeliveryPoint;
	}
    public class AddressWrapper{
        public AddressJSON updatedAddress;
    }
    public class AddressJSON{
        public String City;
        public String state;
        public String address2;
        public String zip5;
        public String zip4;
    }
   
    class addressResponse {
		public String Address2;	//MEERUT
		public String CarrierRoute;	//C000
		public String CentralDeliveryPoint;	//N
		public String City;	//SCHENECTADY
		public String state;	//99
		public String zip5;	//Y
		public String DPVFootnotes;	//AAU1
		public String Footnotes;	//QX
	}
	public static addressResponse parseResponse(String json){
		return (addressResponse) System.JSON.deserialize(json, addressResponse.class);
	}
	
	public static MulesoftAddressResponse parse(String json) {
		return (MulesoftAddressResponse) System.JSON.deserialize(json, MulesoftAddressResponse.class);
	}
}