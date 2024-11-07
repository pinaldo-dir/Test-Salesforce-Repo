import { LightningElement,api } from 'lwc';
import { radioOptions, acceptedFileFormat, customLabelValues } from 'c/owcUtils';

export function showToastMsg(message, variant){
    const evt = new ShowToastEvent({
        message: message,
        variant: variant,
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}

const Utils = (superclass) => class extends superclass {

    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false 
        switch ( event.target.name) {
            case "retaliationComplain":
                    const retaliationComplain = event.target.value;
                    this.retaliationComplain = retaliationComplain;
                    if(this.retaliationComplain === this.options[0].value){
                        this.isRetaliationComplain = true
                        this.isRetaliationComplainFalse = false
                    }
                    else{
                        this.isRetaliationComplainFalse = true
                        this.isRetaliationComplain = false
                        this.complainFiledDate = undefined;
                        this.complainCaseNumber = undefined
                    }
                    break;
            case "workForThisComp":
                this.workForThisComp = event.target.value
            break;  
            case "complainFiledDate":
                this.complainFiledDate = event.target.value
                this.handleComplainFiledDateValidation();
            break; 
            case "complainCaseNumber":
                this.complainCaseNumber = event.target.value
            break; 
            case "ownershipOfCompRelated":
                this.ownershipOfCompRelated = event.target.value
            break;
            case "workWithSameWorokers":
                this.workWithSameWorokers = event.target.value
            break;
            case "signCardName":
                this.signCardName = event.target.value
            break;
            case "employerChangedNameAfterEmployement":
                this.employerChangedNameAfterEmployement = event.target.value
                if(this.employerChangedNameAfterEmployement === this.options[0].value){
                    this.isEmployerChangedNameAfterEmployement = true;
                }
                else{
                    this.isEmployerChangedNameAfterEmployement = false;
                }
            break;
            case "startingDate":
                this.startingDate = event.target.value;
                this.startingDate === null ? this.template.querySelector('[data-id="startingDate"]').value = '' : ''
                this.handleEmployerDateValidation(this.template.querySelector('[data-id="startingDate"]'), this.template.querySelector('[data-id="endingDate"]'), this.template.querySelector('[data-id="startingDate"]').value, this.template.querySelector('[data-id="endingDate"]').value)         
            break;
            case "endingDate":
                this.endingDate = event.target.value
                this.endingDate === null ? this.template.querySelector('[data-id="endingDate"]').value = '' : ''
                this.handleEmployerDateValidation(this.template.querySelector('[data-id="startingDate"]'), this.template.querySelector('[data-id="endingDate"]'), this.template.querySelector('[data-id="startingDate"]').value, this.template.querySelector('[data-id="endingDate"]').value)         
            break;
            case 'employerChangedName':
                this.employerChangedName = event.target.value
                if(this.employerChangedName === this.options[0].value){
                    this.isEmployerChangedName = true
                }
                else{
                    this.isEmployerChangedName = false
                }
                break;
            case 'claimantRelatedRoleActions':
                this.claimantRelatedRoleActions = event.target.value
                break;
            case "mailOfficeLocator":
                this.mailOfficeLocator = event.target.value;
                if(this.mailOfficeLocator === this.options[0].value){
                    this.isOfficeLocatorMail = true;
                }
                else{
                    this.isOfficeLocatorMail = false;
                }
            break;
            case "unionContractCovering":
                this.unionContractCovering = event.target.value.trim();
                //making changes here
                this.handleUnionContractCoveringFocus();
                if(this.unionContractCovering === OWC_Yes){
                    this.isUnionContractCovered = true
                }
                else{
                    this.isUnionContractCovered = false
                }
                
                break;
            case 'unionContractCovered':
                this.unionContractCovered = event.target.value
                this.handleUnionContractCovered();
                if(this.unionContractCovered === this.unionContractCoverOptions[0].value){
                    this.isUnionContractDocumentUpload = true;
                    this.isUrlAddress = false;
                    this.isMailToOfficeLocator = false;
                    this.urlAddress = null
                }
                else if(this.unionContractCovered === this.unionContractCoverOptions[1].value){
                    this.isUnionContractDocumentUpload = false;
                    this.isUrlAddress = true;
                    this.isMailToOfficeLocator = false;
                    this.uploadUnionContractDocument = null
                }
                else if(this.unionContractCovered === this.unionContractCoverOptions[2].value){
                    this.isUnionContractDocumentUpload = false;
                    this.isUrlAddress = false;
                    this.isMailToOfficeLocator = true;
                    this.uploadUnionContractDocument = null
                    this.urlAddress = null
                }
                else{
                    this.isUnionContractDocumentUpload = false;
                    this.isUrlAddress = false;
                    this.isMailToOfficeLocator = false;
                    this.uploadUnionContractDocument = null
                    this.urlAddress = null
                }
                break;
            case "urlAddress":
                this.urlAddress = event.target.value.trim();
                this.handleUrlAddressValidity();
                break;
            case "coversheetDocument":
                this.coversheetDocument = event.target.value.trim();
                break;
            case "filingWageClaim":
                this.filingWageClaim = event.target.value.trim();
                break;
            case "countryCodeindividualBusinessPhone":
                this.countryCodeindividualBusinessPhone = event.target.value.trim();
                break;
            case "countryCodeindividualCellPhone":
                this.countryCodeindividualCellPhone = event.target.value.trim();
                break;
            case "countryCodeOtherIndividualPhone":
                    this.countryCodeOtherIndividualPhone = event.target.value.trim();
                    break;
            case "specifyFilingWageClaim":
                this.specifyFilingWageClaim = event.target.value.trim();
                if(this.specifyFilingWageClaim === 'Other – please explain'){
                    this.isEmployeeFilingWageClaimOther = true
                }
                else{
                    this.isEmployeeFilingWageClaimOther = false
                }
                break;
            case "owcWorkRecordList":
                this.owcWorkRecordList = event.target.value.trim();
                break;
            case "additionalWHOPaidYou":
                this.additionalWHOPaidYou = event.target.value.trim();
                break;
            case "additionalPersonInchargeName":
                this.additionalPersonInchargeName = event.target.value.trim();
                break;
            case "additionalBankName":
                this.additionalBankName = event.target.value.trim();
                break;
            case "employer_Business_Type":
                this.representativeEmployerType = event.target.value;
                this.handleEmployer_Business_TypeFocus();
                if(this.representativeEmployerType === 'Other'){
                    this.isIndividualStatePicklist = false
                    this.isOtherIndividualPicklist = true
                    this.IsOther = true;
                    this.IsIndividual  = false;
                    this.IsOtherIndividual = true;
                    this.isEmpBusinessType = true;
                    this.isDontKnow = false;
                    
                    this.resetIndividualSoleAttributes();
                    this.resetOtherAttributes();
                }else if(this.representativeEmployerType === 'Individual/Sole Proprietor'){
                    this.resetOtherAttributes();
                    this.IsOther = false;
                    this.IsIndividual  = true;
                    
                    this.IsOtherIndividual = false;
                    this.isEmpBusinessType = true;
                    this.isDontKnow = false;
                }else if(this.representativeEmployerType === 'Corporation' || this.representativeEmployerType === 'General Partnership' || this.representativeEmployerType === 'LLC' ){                        
                    this.isIndividualStatePicklist = false
                    this.isOtherIndividualPicklist = true
                    this.IsOther = false;
                    this.IsIndividual  = false;
                    this.IsOtherIndividual = true;
                    this.isEmpBusinessType = true;
                    this.isDontKnow = false;
                    this.resetIndividualSoleAttributes();
                    this.resetOtherAttributes();
                }
                    else{
                        this.isIndividualStatePicklist = false
                    this.isOtherIndividualPicklist = true
                    this.IsIndividual  = false;
                    this.IsOtherIndividual = true;
                    this.isEmpBusinessType = true;
                    this.isDontKnow = false;
                    this.isIndividualStatePicklist = false
                    this.isOtherIndividualPicklist = true
                    this.IsOther = false;
                    this.IsOtherIndividual = true;
                    this.isEmpBusinessType = true;
                    this.isDontKnow = false;
                    this.resetIndividualSoleAttributes();
                    this.resetOtherAttributes();
                    this.IsOther = false;
                    this.isDontKnow = false;
                    this.IsOtherIndividual = false;
                    this.isEmpBusinessType = false;
                }
            break;
            case "otherPleaseExplain":            
                this.otherPleaseExplain = event.detail.value.trim();
                this.handleOtherBusinessReasonFocus();
            break;
            case "empName":
                this.empName = event.target.value.trim();
                this.handleEmpNameDontKnowFocus();
            break;
            
            case "individualLastName":
                this.individualLastName = event.target.value.trim();
                this.handleIndividualLastNameFocus();
            break;
            case "individualFirstName":
                this.individualFirstName = event.target.value.trim();
                this.handleIndividualFirstNameFocus()
            break;
            case "individualStreetAddress":
                this.individualStreetAddress = event.target.value.trim();
                this.handleindividualStreetAddressFocus();
            break;
            case "individualCity":
                this.individualCity = event.target.value.trim();
                this.handleindividualCityFocus();
            break;
            case "individualState":
                this.individualState = event.target.value.trim();
                this.handleindividualStateFocus();
            break;
            case "individualZipCode":
                this.individualZipCode = event.target.value;
                if(event.target.value.length >= 5 && this.individualZipCode.includes('-')){
                    this.template.querySelector('[data-id="individualZipCode"]').value = event.target.value;
                }
                else if(event.target.value.length === 6){
                    this.template.querySelector('[data-id="individualZipCode"]').value = event.target.value.replace(/(\d{5})/, "$1-");
                }
                this.individualZipCode = event.target.value;
                this.handleIndividualZipCodeFocus();
            break;
            case "individualBusinessPhone":
                this.individualBusinessPhone = event.target.value.trim();
                this.handleIndividualBusinessPhoneFocus();
            break;
            case "individualCellPhone":
                this.individualCellPhone = event.target.value.trim();
                this.handleIndividualCellPhoneFocus();
            break;
            case "individualEmail":
                this.individualEmail = event.target.value.trim();
                this.handleIndividualEmailFocus();
            break;
            case "individualVehicleLicense":
                this.individualVehicleLicense = event.target.value.trim();
                if(this.individualVehicleLicense === null||this.individualVehicleLicense === ''){
                    this.isIndiVehi=true
                    this.IndividualFirstNamerequired = false;
                    this.IndividualStreetAddressrequired = false;
                    this.IndividualCityrequired = false;
                    this.IndividualStaterequired = false;
                    this.IndividualZipCoderequired = false;
                    this.IndividualBusinessPhonerequired = false;

                }else{
                    this.isIndiVehi=false
                    this.IndividualFirstNamerequired = true
                this.IndividualStreetAddressrequired = true
                this.IndividualCityrequired = true
                this.IndividualStaterequired = true
                this.IndividualZipCoderequired = true
                this.IndividualBusinessPhonerequired = true
                this.handleIndividualFirstNameFocus()
                this.handleindividualStreetAddressFocus()
                this.handleindividualCityFocus()
                this.handleindividualStateFocus()
                this.handleIndividualBusinessPhoneFocus()
                this.handleIndividualZipCodeFocus()
                }
            break;
            case "individualWebsite":
                this.individualWebsite = event.target.value.trim();
                this.handleIndividualWebsiteFocus();
            break;
            case "OtherIndividualBusinessName":
                this.OtherIndividualBusinessName = event.target.value.trim();
                this.handleOtherIndividualBusinessNameFocus();
            break;
            case "OtherIndividualStreetAddress":
                this.OtherIndividualStreetAddress = event.target.value.trim();
                this.handleOtherIndividualStreetAddressfocus();
            break;
            case "OtherIndividualCity":
                this.OtherIndividualCity = event.target.value.trim();
                this.handleOtherIndividualCityfocus();
            break;
            case "OtherIndividualState":
                this.OtherIndividualState = event.target.value.trim();
                this.handleOtherIndividualStatefocus();
            break;
            case "OtherIndividualZipCode":
                this.OtherIndividualZipCode = event.target.value;
                if(event.target.value.length >= 5 && this.OtherIndividualZipCode.includes('-')){
                    this.template.querySelector('[data-id="OtherIndividualZipCode"]').value = event.target.value;
                }
                else if(event.target.value.length === 6){
                    this.template.querySelector('[data-id="OtherIndividualZipCode"]').value = event.target.value.replace(/(\d{5})/, "$1-");
                }
                this.OtherIndividualZipCode = event.target.value;
                this.handleOtherIndividualZipCodeFocus();
            break;
            case "OtherIndividualPhone":       
                this.OtherIndividualPhone = event.target.value.trim();
                this.handleOtherIndividualPhoneFocus();
            break;
            case "OtherIndividualEmail":
                this.OtherIndividualEmail = event.target.value.trim();
                this.handleOtherIndividualEmail();
            break;
            case "OtherIndividualVehicleLicense":
                this.OtherIndividualVehicleLicense = event.target.value.trim();
                if(this.OtherIndividualVehicleLicense === null||this.OtherIndividualVehicleLicense === ''||this.OtherIndividualVehicleLicense === undefined){
                    this.OtherStreetAddressrequired = false;
                    this.OtherCityrequired = false;
                    this.OtherStaterequired = false;
                    this.OtherZipCoderequired = false;
                    this.OtherBusinessPhonerequired = false;

                }else{
                    this.OtherStreetAddressrequired = true;
                    this.OtherCityrequired = true;
                    this.OtherStaterequired = true;
                    this.OtherZipCoderequired = true;
                    this.OtherBusinessPhonerequired = true;
                }
                this.handleOtherIndividualStreetAddressfocus();
                this.handleOtherIndividualCityfocus();
                this.handleOtherIndividualStatefocus();
                this.handleOtherIndividualZipCodeFocus();
                this.handleOtherIndividualPhoneFocus();
            break;
            case "OtherIndividualWebsite":
                this.OtherIndividualWebsite = event.target.value.trim();
                this.handleOtherWebsiteFocus();
            break;
            case "OtherIndividualConstructionTrades":
                this.OtherIndividualConstructionTrades = event.target.value.trim();
            break;
            case "additionalName":
                this.additionalName = event.target.value.trim();
            break;
            case "additionalJobTitle":
                this.additionalJobTitle = event.target.value.trim();
            break;
            case "additionalDifferentPerson":
                this.additionalDifferentPerson = event.target.value.trim();
            break;
            case "additionalWorkRecord":
                this.additionalWorkRecord = event.target.value.trim();
            break;
            case "additionalSignTimeCard":
                this.additionalSignTimeCard = event.target.value.trim();
                if(this.additionalSignTimeCard === this.options[0].value){
                    this.isSignCard = true;
                }
                else{
                    this.isSignCard = false;
                }
            break;
            case "additionalSomeoneElse":
                this.additionalSomeoneElse = event.target.value.trim();
            break;  
            case "additionalTotalEmployees":
                this.additionalTotalEmployees = event.target.value.trim();
                this.handleadditionalTotalEmployeesFocus();
            break;
            case "additionalEmpBusiness":
                this.additionalEmpBusiness = event.target.value.trim();
                if(this.additionalEmpBusiness === this.options[0].value){
                    this.handleadditionalEmpBusinessFocus();
                }
            break;
            case "additionalCompEmployed":
                this.additionalCompEmployed = event.target.value.trim();
            break;
            case "additionalChangeOrSold":
                this.additionalChangeOrSold = event.target.value.trim();
            break;
            case "additionalBankruptcy":
                this.additionalBankruptcy = event.target.value.trim();
                if(this.additionalBankruptcy ===  this.customLabelValues.OWC_Yes){
                    this.isEmployerSellingAssets = true;
                }
                else{
                    this.isEmployerSellingAssets = false;
                }
            break;
            case "uploadAdditionalDocuments":
                this.uploadAdditionalDocuments = event.target.value.trim();
            break;
            case "covid19Claim":
                this.covid19Claim = event.target.value.trim();
                this.handlecovid19ClaimFocus();
                if(this.covid19Claim === this.customLabelValues.OWC_Yes){
                    this.isEmployeeFilingWageClaim = true
                    this.isEmployeeFilingWageClaimOther = false
                }
                else{
                    this.isEmployeeFilingWageClaim = false
                    this.isEmployeeFilingWageClaimOther = false
                } 
                break;
            case "specifyOtherReason":
                this.specifyOtherReason = event.target.value.trim();
                this.handleOtherReasonFocus();
                break;
            default: 
            
        }
    }


}

export { Utils }