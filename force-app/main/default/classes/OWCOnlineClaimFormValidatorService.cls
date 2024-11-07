public class OWCOnlineClaimFormValidatorService {
	// create general method to validate the Custom metadata values
    public static ValidatorResponseWrapper validateValuesByMetadata(List<Sobject> result, String value, Boolean isIndustry){
        System.debug('result ::: '+result);
        String errorMessage ; 
        Boolean isValid = false;
        String validValues;
        String fieldAPIName = (isIndustry != null && isIndustry == true) ? 'Value__c' : 'Value__c';
        System.debug('fieldAPIName ::: '+fieldAPIName);
        System.debug('value ::: '+value);
        //List<OWC_Employer_Business_Type__mdt> mdtList = OWC_Employer_Business_Type__mdt.getAll().values();
        ValidatorResponseWrapper wrapper = new ValidatorResponseWrapper();
        if(result.size() > 6){
            for(Sobject mdt: result){
                if((String) mdt.get(fieldAPIName) == value && String.isNotBlank((String) mdt.get(fieldAPIName))){
                    System.debug('mdt ::: '+mdt);
                    wrapper.isValid = true;
                    isValid = true;
                    return wrapper;
                } 
            }
        } else {
            for(Sobject mdt: result){
                if(String.isNotBlank((String) mdt.get(fieldAPIName))){
                    if((String) mdt.get(fieldAPIName) == value ) {
                        wrapper.isValid = true;
                        isValid = true;
                        return wrapper;
                    }  else{
                        if(String.isNotBlank(validValues)){
                            validValues += ', '+(String) mdt.get(fieldAPIName);
                        } else{
                            validValues = (String) mdt.get(fieldAPIName);
                        }
                    }
                }
            }
        }
        
        //when value not found in metadata
        if(!isValid){
            if(String.isNotBlank(validValues)){
                wrapper.isValid = false;
                wrapper.message = 'Invalid value: '+value+'. Valid values are '+validValues + '.';
            } else{
                wrapper.isValid = false;
                wrapper.message = 'Invalid value: '+value+'.  Refer to 3rd Party API Technical Specifications for allowed values.';
            }
        }
        System.debug('wrapper ::: '+wrapper);
        return wrapper;
    }
    public class ValidatorResponseWrapper {
        public Boolean isValid ;
        public String message;
    }
}