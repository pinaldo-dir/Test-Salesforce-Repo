import { LightningElement, api,wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { radioOptions, customLabelValues, acceptedFileFormat } from 'c/owcUtils';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import owcFrequencyMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData';
import paymentTypeOptions from '@salesforce/apex/OWCPaymentOfWagesController.fetchOptionsMetaData';
//import insertUploadedFiles from '@salesforce/apex/OWCMultipleFileUploadController.insertUploadedFiles';
import deleteMultipleFiles from '@salesforce/apex/OWCMultipleFileDeleteController.deleteMultipleFiles';
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource
import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class OwcPaymentOfWagesCmp extends LightningElement {

@api isLargeDevice = false;
@api isMediumDevice = false;
@api isSmallDevice = false;
@api empPaymentType //Storing the Value of payment type
@track value = []
@api isOneHourlyRate = false //boolean var for onehourly rate section and it's get true when the section is selected
@api isDifferentHourRate = false //boolean var for Different hour rate section and it's get true when the section is selected
@api isSalaryRateForEachDay = false //boolean var for salary rate for each day section and it's get true when the section is selected
@api isCommissionRate = false////boolean var for commision rate section and it's get true when the section is selected
@api isPieceRate = false//boolean var for piece rate section and it's get true when the section is selected
@api paidAmountPerHour //Store the value of Amount paid per hour
@api promisedAmountPerHour//Store the value of Amount promised per hour
@api hourlyRateBegDate//Store the value of Begining date of hourly rate
@api hourlyRateEndDate//Store the value of ending date of hourly rate
@api differentHourlyRateBegDate //Store the value of Begining date of different hourly rate
@api forActivity //Store the value of for activity
@api differentHourlyRateEndDate//Store the value of ending date of different hourly rate
@api paidAmountDifferentHour //Store the value of Amount paid different hour
@api paidAmountDifferentHourAdditional //Store the value of Amount paid different hour additional section
@api promisedAmountDifferentHour //Store the value of Amount promised different hour
@api promisedAmountDifferentHourAdditional //Store the value of Amount promised different hour additional section
@api forActivityAdditional //Store the value of for activity additional section
@api differentHourlyRateBegDateAdditional //Store the value of Begining date of different hourly rate Additional section
@api paidAmountForEachDay //Store the value of Amount paid each day
@api paidFrequencyOfEachDay //Store the value of frequency  each day
@api promisedAmountForEachDay//Store the value of Amount promised each day
@api promisedAmountForEachDayAdditional//Store the value of Amount promised each day additional section
@api frequencyOfEachDay //Store the value of frequency each day
@api frequencyOfEachDayAdditional //Store the value of frequency each day additonal section
@api eachPayRateBegDate //Store the value of begining date of each pay rate 
@api eachPayRateBegDateAdditional //Store the value of Begining date of each pay rate Additional section
@api eachPayRateEndDateAdditional//Store the value of ending date of each pay rate Additional section
@api eachPayRateEndDate //Store the value of ending date of each pay rate 
@api paidCommissionRate //Store the value of Amount paid commission rate
@api promisedCommissionRate//Store the value of Amount promised commission rate
@api commissionRateBegDate//Store the value of Begining date of commission rate
@api commissionRateEndDate//Store the value of ending date of commission rate 
@api writtenCommission //Store the value of written commission
@api isWrittenCommission = false //boolean var for written commission and it's get true when the section is selected
@api paidPieceRate //Store the value of paid piece rate
@api promisedPieceRate //Store the value of promised piece rate
@api paidMiniumWage //Store the value of paid minium wage


@api frequency_list_type //Store the value of frequency list
@track isHelpText = false //bool var for help text
@track helpText //Store the val of help text
isRenderedCallback = false   // bool var for rendercallback
@api options
@api isProvidePriceRate =  false; //bool var for provided piece rate and is get true when the provided piece rate is selected
@api perUnitPaymentOfWages // store the value of per unit
@api isPerUnitOther = false // bool var for other and get true when the other is selected in perunit
@api isGrament = false //bool var to garment user and gets true when the user is a garment user under few condition
@api differentHourlyRateEndDateAdditional //Store the value of ending date of different hourly rate additonal section
@api other // Store the value of other 
@api numberOfUnits // store the value of number of units
@api pieceRateBegDate //Store the value of Begining date of piece rate
@api pieceRateEndDate//Store the value of ending date of piece rate
@api pieceRateTotalEarned //store the value of total earned in piece rate
@api pieceRateTotalPaid //store the value of total paid in piece rate
@api paidPieceRateAdditional//store the value of total paid in piece rate additonal section
@api promisedPieceRateAdditional//store the value of promised rate  in piece rate additional section
@api perUnitPaymentOfWagesAdditional // store the value of perunit additional section
@api otherAdditional //store the value of other additional section
@api numberOfUnitsAdditional//store the number of units additional section
@api pieceRateBegDateAdditional //Store the value of Begining date of piece rate Additional section
@api pieceRateEndDateAdditional //Store the value of ending date of piece rate Additional section
isPerUnitOtherAdditional = false //bool val get true when the per unit additional section gets clicked



@api paidAmountPerHourAdditional    // store the paid amount per hour additional section
@api promisedAmountPerHourAdditional    // store the promised amount per hour additional section
@api hourlyRateBegDateAdditional    //Store the value of Begining date of hourly rate Additional section
@api hourlyRateEndDateAdditional //Store the value of ending date of hourly rate Additional section

@api paymentOfWagesForGarmentSectionValues //store the data of garment section
@api paymentOfWagesForGarmentDetails = []
@api differentHourAddDetails

@api HourlyOption
@api isMultipleRequiredCheck = false //for multiple input requirement validation message


//Upload agreement attributes
@api isAgreementFileUpload = false
@api agreementDocsSize // doc size
@api agreementDocs = []
@api isCommissionReciptFileUpload = false
@api commissionReciptDocsSize // doc size
@api commissionReciptDocs
@api isSelectedFileDeleted = false //gets true when a file deleted
intRegrex =  /^\$?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{1,2})?$/; //Pattern to check the number value
//Regrex Expression for phone number
regExpPhone = /^((\\+[1-9]{1,4}[ \\-]*)|(\\([0-9]{2,3}\\)[ \\-]*)|([0-9]{2,4})[ \\-]*)*?[0-9]{3,4}?[ \\-]*[0-9]{3,4}?$/;
customLabelValues = customLabelValues // stores all the custom labels which we are importing from owcUtils
YesOrNoOptions = radioOptions //stores the yes and no options which we are importing from owcUtils

//ConnectedCall back Method 
    connectedCallback(){
        switch(FORM_FACTOR) {
            case 'Large':
                this.isLargeDevice = true;
                break;
            case 'Medium':
                this.isMediumDevice = true;
                break;
            case 'Small':
                this.isSmallDevice = true;
                break;
        }
        // don’t forget to load static resources in connectedCallback . 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
            console.log( 'Files loaded' );
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error')
            console.log( error.body.message );
    });
    }

    //Methods for accepted files format's which we are importing from owcUtils
    get acceptedFormats(){
        return acceptedFileFormat
    }

    //Fetching Frequency List
    @wire(owcFrequencyMetaData)
    wiredfetchdata({ data,error}) {
            if(data){
                
            }else{
                this.errorMsg = error;
            }
    }

    @api dateFormatLabel = `(${customLabelValues.OWC_date_format_label})`

    @api differentHourOption
    @api salaryRateOption
    @api commissionRateOption
    @api pieceRateOption
    //
    @wire(paymentTypeOptions)
    wiredOptiondata({ data,error}) {
            if(data){
                this.options = data;
                this.HourlyOption = this.options[0].label
                this.differentHourOption =  this.options[1].label
                this.salaryRateOption = this.options[2].label
                this.commissionRateOption = this.options[3].label
                this.pieceRateOption = this.options[4].label
                console.log('new list'+JSON.stringify(this.options));
            }else{
                this.errorMsg = error;
            }
    }

    //Fetching Units list
    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data, error }){
        if(data){
            this.frequency_list_type = data[0].owcPOWSalaryRateOptions;
            this.perUnitPaymentOfWagesValue = data[0].perUnitPaymentOfWages;
        }
        else if(error){
            this.error = error;
        }
    }

    //Method to handle Draft
    handleSaveAsDraft(){
        this.owcPaymentOfWagesFromParent();
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "6"
            }
        });
        this.dispatchEvent(validateEvent);
    }

    @api isOneHourlyRateClicked =  false
    handleOneHourlyRateClick(){
        this.isOneHourlyRateClicked = true
    }

    @api isDifferentHourRateClicked =  false
    handleDifferentHourRateClick(){
        this.isDifferentHourRateClicked = true
    }
    @api isEachPayClicked = false
    handleEachPayClick(){
        this.isEachPayClicked = true
    }

    @api isPieceOfRateClicked = false
    handlePieceOfRateClick(){
        this.isPieceOfRateClicked = true
    }

    @api HourlyOptionValue = false
    @api pieceRateOptionValue = false
    @api commissionRateOptionValue = false
    @api salaryRateOptionValue = false
    @api differentHourOptionValue = false

    //Handle Change method
    handleChange(event){
        // let hourlyRateBegDate = this.template.querySelector('[data-id="hourlyRateBegDate"]');
        // let hourlyRateEndDate = this.template.querySelector('[data-id="hourlyRateEndDate"]');
        event.preventDefault();
        this.isRenderedCallback = false 
        switch ( event.target.name ) {  

            // case "empPaymentType":            
            // this.empPaymentType = event.target.value;
            // this.value = event.target.value
            // this.handleempPaymentTypeFocus()
            // console.log('empPaymentTypevalue>>>>>>>>>', this.value);
            //     if(!this.value.includes(this.options[0].value)){
            //         this.isOneHourlyRateReset()
            //         console.log('1st Option is not selected',this.paidAmountPerHour,this.promisedAmountPerHour);
            //     }
            //     if(!this.value.includes(this.options[1].value)){
            //         this.isDifferentHourRateReset()
            //         console.log('2nd Option is not selected',this.paidAmountDifferentHour,this.promisedAmountDifferentHour);
            //         }
            //     if(!this.value.includes(this.options[2].value)){
            //         this.isSalaryRateForEachDayReset()
            //         console.log('3rd Option is not selected',this.paidAmountForEachDay,this.paidFrequencyOfEachDay, this.promisedAmountForEachDay, this.frequencyOfEachDay);
            //         }
            //     if(!this.value.includes(this.options[3].value)){
            //         this.isCommissionRateReset()
            //         console.log('4th Option is not selected',this.paidCommissionRate,this.promisedCommissionRate, this.writtenCommission);
            //         }
            //     if(!this.value.includes(this.options[4].value)){
            //         this.isPieceRateReset()
            //         console.log('5th Option is not selected',this.paidPieceRate,this.promisedPieceRate, this.paidMiniumWage, this.recRestPeriod);
            //         }
            // break;
            case "HourlyOption":
                this.HourlyOptionValue = event.target.checked
                console.log("HourlyOptionValue",event.target.checked)
                if(this.HourlyOptionValue === true)
                    {
                        this.isOneHourlyRate = true
                        this.isOneHourlyRateReset()
                        this.isempPaymentTypeErrorMessage = false;
                    console.log("this.isOneHourlyRate",this.isOneHourlyRate)}
                    else{
                        this.isOneHourlyRate = false
                        this.isempPaymentTypeErrorMessage = false;
                    }
            
            break;
            case "differentHourOption":
                this.differentHourOptionValue = event.target.checked
                console.log("differentHourOptionValue",event.target.checked)
                if(this.differentHourOptionValue === true)
                    {
                        this.isDifferentHourRate = true
                        this.isDifferentHourRateReset()
                        this.isempPaymentTypeErrorMessage = false;
                    console.log("this.isDifferentHourRate",this.isDifferentHourRate)
                }else{
                        this.isDifferentHourRate = false
                        this.isempPaymentTypeErrorMessage = false;
                    }
            
            break;
            case "salaryRateOption":
                this.salaryRateOptionValue = event.target.checked
                console.log("salaryRateOptionValue",event.target.checked)
                if(this.salaryRateOptionValue === true)
                    {
                        this.isSalaryRateForEachDay = true
                        this.isSalaryRateForEachDayReset()
                        this.isempPaymentTypeErrorMessage = false;
                    console.log("this.isSalaryRateForEachDay",this.isSalaryRateForEachDay)
                }else{
                        this.isSalaryRateForEachDay = false
                        this.isempPaymentTypeErrorMessage = false;
                    }
            
            break;
            case "commissionRateOption":
                this.commissionRateOptionValue = event.target.checked
                console.log("commissionRateOptionValue",event.target.checked)
                if(this.commissionRateOptionValue === true)
                    {
                        this.isCommissionRate = true
                        this.isCommissionRateReset()
                        this.isempPaymentTypeErrorMessage = false;
                    console.log("this.isCommissionRate",this.isCommissionRate)
                }else
                    {
                        this.isCommissionRate = false
                        this.isempPaymentTypeErrorMessage = false;
                    }
            
            break;
            case "pieceRateOption":
                this.pieceRateOptionValue = event.target.checked
                console.log("pieceRateOptionValue",event.target.checked)
                if(this.pieceRateOptionValue === true)
                    {
                        this.isPieceRate  = true
                        this.isPieceRateReset()
                        this.isempPaymentTypeErrorMessage = false;
                    console.log("this.isPieceRate ",this.isPieceRate )
                }else{
                        this.isPieceRate  = false
                        this.isempPaymentTypeErrorMessage = false;
                    }
            break;
            case "paidAmountPerHour":            
                this.paidAmountPerHour = event.target.value;
                this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountPerHour"]'),this.template.querySelector('[data-id="promisedAmountPerHour"]'))
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidAmountPerHour"]'))
                console.log('paidAmountPerHour ::: ', this.paidAmountPerHour);
            break;
            case "promisedAmountPerHour":            
                this.promisedAmountPerHour = event.target.value;
                this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountPerHour"]'),this.template.querySelector('[data-id="promisedAmountPerHour"]'))
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedAmountPerHour"]'))
                console.log('promisedAmountPerHour ::: ', this.promisedAmountPerHour);
            break;
            case "hourlyRateBegDate":
                this.hourlyRateBegDate = event.target.value;
                this.hourlyRateBegDate === null ? this.template.querySelector('[data-id="hourlyRateBegDate"]').value = '' : ''
                this.handleRequiredField(this.template.querySelector('[data-id="hourlyRateBegDate"]'))
                this.handlePOWDateValidity(this.template.querySelector('[data-id="hourlyRateBegDate"]'), this.template.querySelector('[data-id="hourlyRateEndDate"]'), this.template.querySelector('[data-id="hourlyRateBegDate"]').value, this.template.querySelector('[data-id="hourlyRateEndDate"]').value)
                console.log('hourlyRateBegDate ::: ', this.hourlyRateBegDate);
            break;    
            case "hourlyRateEndDate":
                this.hourlyRateEndDate = event.target.value
                this.hourlyRateEndDate === null ? this.template.querySelector('[data-id="hourlyRateEndDate"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="hourlyRateBegDate"]'), this.template.querySelector('[data-id="hourlyRateEndDate"]'), this.template.querySelector('[data-id="hourlyRateBegDate"]').value, this.template.querySelector('[data-id="hourlyRateEndDate"]').value)
                console.log('hourlyRateEndDate ::: ', this.hourlyRateEndDate);
            break;
            
            case "paidAmountPerHourAdditional":            
                this.paidAmountPerHourAdditional = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidAmountPerHourAdditional"]'))
                console.log('paidAmountPerHourAdditional ::: ', this.paidAmountPerHourAdditional);
            break;
            case "promisedAmountPerHourAdditional":            
                this.promisedAmountPerHourAdditional = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedAmountPerHourAdditional"]'))
                console.log('promisedAmountPerHourAdditional ::: ', this.promisedAmountPerHourAdditional);
            break;
            case "hourlyRateBegDateAdditional":
                this.hourlyRateBegDateAdditional = event.target.value;
                this.hourlyRateBegDateAdditional === null ? this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]'), this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]'), this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]').value, this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]').value)
                console.log('hourlyRateBegDateAdditional ::: ', this.hourlyRateBegDateAdditional);
            break;    
            case "hourlyRateEndDateAdditional":
                this.hourlyRateEndDateAdditional = event.target.value;
                this.hourlyRateEndDateAdditional === null ? this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]'), this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]'), this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]').value, this.template.querySelector('[data-id="hourlyRateEndDateAdditional"]').value)
                console.log('hourlyRateEndDateAdditional ::: ', this.hourlyRateEndDateAdditional);
            break;
            
            case "forActivity":
                this.forActivity = event.target.value;
                this.handleforActivityFocus()
                console.log('forActivity ::: ', this.forActivity);
            break;
            case "forActivityAdditional":
                this.forActivityAdditional = event.target.value;                    
                this.handleforActivityFocusAdditional()
                console.log('forActivityAdditional ::: ', this.forActivityAdditional);
            break;                
            case "differentHourlyRateBegDateAdditional":
                this.differentHourlyRateBegDateAdditional = event.target.value;
                this.differentHourlyRateBegDateAdditional === null ? this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]'), this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]'), this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]').value, this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]').value)
                console.log('differentHourlyRateBegDateAdditional ::: ', this.differentHourlyRateBegDateAdditional);
            break;
            case "differentHourlyRateEndDateAdditional":
                this.differentHourlyRateEndDateAdditional = event.target.value;
                this.differentHourlyRateEndDateAdditional === null ? this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]'), this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]'), this.template.querySelector('[data-id="differentHourlyRateBegDateAdditional"]').value, this.template.querySelector('[data-id="differentHourlyRateEndDateAdditional"]').value)
                console.log('differentHourlyRateEndDateAdditional ::: ', this.differentHourlyRateEndDateAdditional);
            break;
            case "differentHourlyRateBegDate":
                this.differentHourlyRateBegDate = event.target.value;
                this.differentHourlyRateBegDate === null ? this.template.querySelector('[data-id="differentHourlyRateBegDate"]').value = '' : ''
                this.handleRequiredField(this.template.querySelector('[data-id="differentHourlyRateBegDate"]'))
                this.handlePOWDateValidity(this.template.querySelector('[data-id="differentHourlyRateBegDate"]'), this.template.querySelector('[data-id="differentHourlyRateEndDate"]'), this.template.querySelector('[data-id="differentHourlyRateBegDate"]').value, this.template.querySelector('[data-id="differentHourlyRateEndDate"]').value)
                console.log('differentHourlyRateBegDate ::: ', this.differentHourlyRateBegDate);
            break;
            case "differentHourlyRateEndDate":
                this.differentHourlyRateEndDate = event.target.value;
                this.differentHourlyRateEndDate === null ? this.template.querySelector('[data-id="differentHourlyRateEndDate"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="differentHourlyRateBegDate"]'), this.template.querySelector('[data-id="differentHourlyRateEndDate"]'), this.template.querySelector('[data-id="differentHourlyRateBegDate"]').value, this.template.querySelector('[data-id="differentHourlyRateEndDate"]').value)
                console.log('differentHourlyRateEndDate ::: ', this.differentHourlyRateEndDate);
            break;
            case "paidAmountDifferentHour":            
                this.paidAmountDifferentHour = event.target.value;
                this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountDifferentHour"]'),this.template.querySelector('[data-id="promisedAmountDifferentHour"]'))
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidAmountDifferentHour"]'))
                console.log('paidAmountDifferentHour ::: ', this.paidAmountDifferentHour);
            break;
            case "paidAmountDifferentHourAdditional":            
                this.paidAmountDifferentHourAdditional = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidAmountDifferentHourAdditional"]'))
                console.log('paidAmountDifferentHourAdditional ::: ', this.paidAmountDifferentHourAdditional);
            break;
            case "promisedAmountDifferentHour":            
                this.promisedAmountDifferentHour = event.target.value;
                this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountDifferentHour"]'),this.template.querySelector('[data-id="promisedAmountDifferentHour"]'))
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedAmountDifferentHour"]'))
                console.log('promisedAmountDifferentHour ::: ', this.promisedAmountDifferentHour);
            break;
            case "promisedAmountDifferentHourAdditional":            
                this.promisedAmountDifferentHourAdditional = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedAmountDifferentHourAdditional"]'))
                console.log('promisedAmountDifferentHourAdditional ::: ', this.promisedAmountDifferentHourAdditional);
            break;
            case "paidAmountForEachDay":            
                this.paidAmountForEachDay = event.target.value;
                this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountForEachDay"]'),this.template.querySelector('[data-id="promisedAmountForEachDay"]'))
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidAmountForEachDay"]'))
                console.log('paidAmountForEachDay ::: ', this.paidAmountForEachDay);
            break;
            
            case "frequencyOfEachDay":            
                this.frequencyOfEachDay = event.target.value;
                if(this.frequencyOfEachDay == this.frequencyOfEachDay[0].value){
                    this.handleRequiredDropDown(this.template.querySelector('[data-id="frequencyOfEachDay"]'))
                }
                console.log('frequencyOfEachDay ::: ', this.frequencyOfEachDay);
            break;
            case "frequencyOfEachDayAdditional":            
                this.frequencyOfEachDayAdditional = event.target.value;
                console.log('frequencyOfEachDayAdditional ::: ', this.frequencyOfEachDayAdditional);
            break;
            
            case "promisedAmountForEachDay":            
                this.promisedAmountForEachDay = event.target.value;
                this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidAmountForEachDay"]'),this.template.querySelector('[data-id="promisedAmountForEachDay"]'))
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedAmountForEachDay"]'))
                console.log('promisedAmountForEachDay ::: ', this.promisedAmountForEachDay);
            break;
            case "promisedAmountForEachDayAdditional":            
                this.promisedAmountForEachDayAdditional = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedAmountForEachDayAdditional"]'))
                console.log('promisedAmountForEachDayAdditional ::: ', this.promisedAmountForEachDayAdditional);
            break;
            
            case "eachPayRateBegDate":     
                this.eachPayRateBegDate = event.target.value;
                this.eachPayRateBegDate === null ? this.template.querySelector('[data-id="eachPayRateBegDate"]').value = '' : ''
                this.handleRequiredField(this.template.querySelector('[data-id="eachPayRateBegDate"]'))
                this.handlePOWDateValidity(this.template.querySelector('[data-id="eachPayRateBegDate"]'), this.template.querySelector('[data-id="eachPayRateEndDate"]'), this.template.querySelector('[data-id="eachPayRateBegDate"]').value, this.template.querySelector('[data-id="eachPayRateEndDate"]').value)       
                console.log('eachPayRateBegDate ::: ', this.eachPayRateBegDate);
            break;
            case "eachPayRateBegDateAdditional":    
                this.eachPayRateBegDateAdditional = event.target.value;
                this.eachPayRateBegDateAdditional === null ? this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]'), this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]'), this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]').value, this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]').value)
                console.log('eachPayRateBegDateAdditional ::: ', this.eachPayRateBegDateAdditional);
            break;
            
            case "eachPayRateEndDate":            
                this.eachPayRateEndDate = event.target.value;
                this.eachPayRateEndDate === null ? this.template.querySelector('[data-id="eachPayRateEndDate"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="eachPayRateBegDate"]'), this.template.querySelector('[data-id="eachPayRateEndDate"]'), this.template.querySelector('[data-id="eachPayRateBegDate"]').value, this.template.querySelector('[data-id="eachPayRateEndDate"]').value)
                console.log('eachPayRateEndDate ::: ', this.eachPayRateEndDate);
            break;
            case "eachPayRateEndDateAdditional":            
                this.eachPayRateEndDateAdditional = event.target.value;
                this.eachPayRateEndDateAdditional === null ? this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]'), this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]'), this.template.querySelector('[data-id="eachPayRateBegDateAdditional"]').value, this.template.querySelector('[data-id="eachPayRateEndDateAdditional"]').value)
                console.log('eachPayRateEndDateAdditional ::: ', this.eachPayRateEndDateAdditional);
            break;
            case "paidCommissionRate":            
                this.paidCommissionRate = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidCommissionRate"]'))
                console.log('paidCommissionRate ::: ', this.paidCommissionRate);
            break;
            case "promisedCommissionRate":            
                this.promisedCommissionRate = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedCommissionRate"]'))
                console.log('promisedCommissionRate ::: ', this.promisedCommissionRate);
            break; 
            case "commissionRateBegDate":   
                this.commissionRateBegDate = event.target.value;
                this.commissionRateBegDate === null ? this.template.querySelector('[data-id="commissionRateBegDate"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="commissionRateBegDate"]'), this.template.querySelector('[data-id="commissionRateEndDate"]'), this.template.querySelector('[data-id="commissionRateBegDate"]').value, this.template.querySelector('[data-id="commissionRateEndDate"]').value)         
                console.log('commissionRateBegDate ::: ', this.commissionRateBegDate);
            break;
            case "commissionRateEndDate":   
                this.commissionRateEndDate = event.target.value;
                this.commissionRateEndDate === null ? this.template.querySelector('[data-id="commissionRateEndDate"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="commissionRateBegDate"]'), this.template.querySelector('[data-id="commissionRateEndDate"]'), this.template.querySelector('[data-id="commissionRateBegDate"]').value, this.template.querySelector('[data-id="commissionRateEndDate"]').value)         
                console.log('commissionRateEndDate ::: ', this.commissionRateEndDate);
            break;
            case "writtenCommission":
                this.writtenCommission = event.target.value;
                console.log('writtenCommission::',this.writtenCommission);
                this.handleRequiredCheckbox(this.template.querySelector('[data-id="writtenCommission"]'))
                if(this.writtenCommission == this.YesOrNoOptions[0].value){
                    this.isWrittenCommission = true;
                }else{
                    this.isWrittenCommission =  false;
                    this.agreementDocs.length = 0;
                }
            break; 
            
            case "providePriceRate":
                console.log('isProvidePriceRate true ::: ', event.target.checked)
                const isProvidePriceRate = event.target.checked
                if(isProvidePriceRate){
                    this.isProvidePriceRate = true
                }
                else{
                    this.isProvidePriceRate = false
                }
            break;   
            case "paidPieceRate":            
                this.paidPieceRate = event.target.value;
                this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidPieceRate"]'),this.template.querySelector('[data-id="promisedPieceRate"]'))
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidPieceRate"]'))
                console.log('paidPieceRate ::: ', this.paidPieceRate);
            break;
            
            
            case "promisedPieceRate":            
                this.promisedPieceRate = event.target.value;
                this.handleRequiredSetValidation(this.template.querySelector('[data-id="paidPieceRate"]'),this.template.querySelector('[data-id="promisedPieceRate"]'))
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedPieceRate"]'))
                console.log('promisedPieceRate ::: ', this.promisedPieceRate);
            break;
            case "perUnitPaymentOfWages":            
                this.perUnitPaymentOfWages = event.target.value;

                console.log('perUnitPaymentOfWagesvalue>>>>>>>>>', this.perUnitPaymentOfWages);
                    if(this.perUnitPaymentOfWages == this.perUnitPaymentOfWagesValue[10].value){
                        this.isPerUnitOther = true
                    }
                    else if(this.perUnitPaymentOfWages == this.perUnitPaymentOfWagesValue[0].value){
                        this.handleRequiredDropDown(this.template.querySelector('[data-id="perUnitPaymentOfWages"]'))
                    }
                    else{
                        this.isPerUnitOther = false
                    }
                    console.log('isPerUnitOther ::: ', this.isPerUnitOther)
            break;
            case "other":            
                this.other = event.target.value;
                this.handleotherFocus()
                console.log('other ::: ', this.other);
            break;
            case "numberOfUnits":
                this.numberOfUnits = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="numberOfUnits"]'))
                console.log('numberOfUnits ::' , this.numberOfUnits);
            break;
            case "pieceRateBegDate":
                this.pieceRateBegDate = event.target.value;
                this.pieceRateBegDate === null ? this.template.querySelector('[data-id="pieceRateBegDate"]').value = '' : ''
                this.handleRequiredField(this.template.querySelector('[data-id="pieceRateBegDate"]'))
                this.handlePOWDateValidity(this.template.querySelector('[data-id="pieceRateBegDate"]'), this.template.querySelector('[data-id="pieceRateEndDate"]'), this.template.querySelector('[data-id="pieceRateBegDate"]').value, this.template.querySelector('[data-id="pieceRateEndDate"]').value)         
                console.log('pieceRateBegDate ::' , this.pieceRateBegDate);
            break;
            case "pieceRateTotalEarned":
                this.pieceRateTotalEarned = event.target.value;
                this.handleRequiredField(this.template.querySelector('[data-id="pieceRateTotalEarned"]'))
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="pieceRateTotalEarned"]'))
                console.log('pieceRateTotalEarned ::' , this.pieceRateTotalEarned);
            break;
            case "pieceRateEndDate":
                this.pieceRateEndDate = event.target.value;
                this.pieceRateEndDate === null ? this.template.querySelector('[data-id="pieceRateEndDate"]').value = '' : ''
                this.handleRequiredField(this.template.querySelector('[data-id="pieceRateEndDate"]'))
                this.handlePOWDateValidity(this.template.querySelector('[data-id="pieceRateBegDate"]'), this.template.querySelector('[data-id="pieceRateEndDate"]'), this.template.querySelector('[data-id="pieceRateBegDate"]').value, this.template.querySelector('[data-id="pieceRateEndDate"]').value)         
                console.log('pieceRateEndDate ::' , this.pieceRateEndDate);
            break;
            case "pieceRateTotalPaid":
                this.pieceRateTotalPaid = event.target.value;
                this.handleRequiredField(this.template.querySelector('[data-id="pieceRateTotalPaid"]'))
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="pieceRateTotalPaid"]'))
                console.log('pieceRateTotalPaid ::' , this.pieceRateTotalPaid);
            break;
            case "pieceRateBegDateAdditional":
                this.pieceRateBegDateAdditional = event.target.value;
                this.pieceRateBegDateAdditional === null ? this.template.querySelector('[data-id="pieceRateBegDateAdditional"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="pieceRateBegDate"]'), this.template.querySelector('[data-id="pieceRateEndDateAdditional"]'), this.template.querySelector('[data-id="pieceRateBegDate"]').value, this.template.querySelector('[data-id="pieceRateEndDateAdditional"]').value)         
                console.log('pieceRateBegDateAdditional ::' , this.pieceRateBegDateAdditional);
            break;
            case "pieceRateEndDateAdditional":
                this.pieceRateEndDateAdditional = event.target.value;
                this.pieceRateEndDateAdditional === null ? this.template.querySelector('[data-id="pieceRateEndDateAdditional"]').value = '' : ''
                this.handlePOWDateValidity(this.template.querySelector('[data-id="pieceRateBegDate"]'), this.template.querySelector('[data-id="pieceRateEndDateAdditional"]'), this.template.querySelector('[data-id="pieceRateBegDate"]').value, this.template.querySelector('[data-id="pieceRateEndDateAdditional"]').value)         
                console.log('pieceRateEndDateAdditional ::' , this.pieceRateEndDateAdditional);
            break;
            case "paidPieceRateAdditional":            
                this.paidPieceRateAdditional = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="paidPieceRateAdditional"]'))
                console.log('paidPieceRateAdditional ::: ', this.paidPieceRateAdditional);
            break;
            case "promisedPieceRateAdditional":            
                this.promisedPieceRateAdditional = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="promisedPieceRateAdditional"]'))
                console.log('promisedPieceRateAdditional ::: ', this.promisedPieceRateAdditional);
            break;
            case "perUnitPaymentOfWagesAdditional":            
                this.perUnitPaymentOfWagesAdditional = event.target.value;
                console.log('perUnitPaymentOfWagesAdditionalvalue>>>>>>>>>', this.perUnitPaymentOfWagesAdditional);
                    if(this.perUnitPaymentOfWagesAdditional == this.perUnitPaymentOfWagesValue[10].value){
                        this.isPerUnitOtherAdditional = true
                    }else{
                        this.isPerUnitOtherAdditional = false
                    }
            break;
            case "otherAdditional":            
                this.otherAdditional = event.target.value;
                this.handleotherAdditionalFocus()
                console.log('otherAdditional ::: ', this.otherAdditional);
            break;
            case "numberOfUnitsAdditional":
                this.numberOfUnitsAdditional = event.target.value;
                this.handlePOWAmountValidity(this.template.querySelector('[data-id="numberOfUnitsAdditional"]'))
                console.log('numberOfUnitsAdditional ::' , this.numberOfUnitsAdditional);
            break; 
                                 
        }  
   
    }
    isNotChangedCurrentStep = false

    /**Starting One Hour Additional Section Work here */
    @api renderOneHourlyAdditonalSection = []
    oneHourlyFlag = 0
    hourlyAddValues
   
    @api hourlyAdditionalSectionValues
    @api hourlyAdditionalDetails = []
    @api isOneHourlyAdditionalSection = false
    isHourlyAddSectionDeleted = false
    @api hourlyAddSectionDataAfterDelete = []
    // One Hour Section Validity event handler
    handleHourlyAddSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }

    //Add More One Hour Info
    addMoreHourly(){
        this.isOneHourlyAdditionalSection = false
        const oneHourlyFlag = this.oneHourlyFlag + 1
        this.oneHourlyFlag = oneHourlyFlag
        this.renderOneHourlyAdditonalSection.push({heading : this.customLabelValues.Owc_Additional, button : true, oneHourSectionId : this.oneHourlyFlag})
        this.isOneHourlyAdditionalSection = true
    }

    handleOneHourlyAddSectionInfoEvent(event){
        const hourlyAdditionalSectionData = event.detail
        this.hourlyAdditionalSectionValues = hourlyAdditionalSectionData
        this.hourlyAdditionalDetails.push(this.hourlyAdditionalSectionValues)
        console.log('hourlyAdditionalDetails :::: ', JSON.stringify(this.hourlyAdditionalDetails))
        console.log('hourlyAdditionalSectionValues:', JSON.stringify(this.hourlyAdditionalSectionValues))
    }

    handleOneHourlySectionDeletion(event){
        var oneHourlyFlag = 0
        const hourlyAddInfoAfterDelete = []
        this.isOneHourlyAdditionalSection = false
        this.hourlyAddSectionDataAfterDelete.length = 0
        this.deleteHourlyAddSectionId = event.detail.oneHourSectionId
        const hourlyAdditionalSectionDetails = this.template.querySelectorAll('c-owc-One-Hour-Additional-Cmp')
        for (let i = 0; i < hourlyAdditionalSectionDetails.length; i++){
            hourlyAdditionalSectionDetails[i].handleOneHourlyAddSectionData()
        }
        const deleteHourlyAddSectionDataIndex = this.hourlyAddSectionDataAfterDelete.findIndex(sec => sec.oneHourSectionId === this.deleteHourlyAddSectionId)
        console.log('deleteHourlyAddSectionDataIndex ::: ', deleteHourlyAddSectionDataIndex)
        this.hourlyAddSectionDataAfterDelete.splice(deleteHourlyAddSectionDataIndex, 1);
        console.log('After delete successor ::: ', JSON.stringify(this.hourlyAddSectionDataAfterDelete))
        const deletedSectionIndex = this.renderOneHourlyAdditonalSection.findIndex(sec => sec.oneHourSectionId === this.deleteHourlyAddSectionId)
        this.renderOneHourlyAdditonalSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderOneHourlyAdditonalSection.length ;i++){
            oneHourlyFlag = i + 1
            if(this.renderOneHourlyAdditonalSection[i].heading === this.customLabelValues.OWC_successoraddinfo_heading){
                hourlyAddInfoAfterDelete.push(this.renderOneHourlyAdditonalSection[i])
            }
            else{
                hourlyAddInfoAfterDelete.push({heading : this.customLabelValues.Owc_Additional, button : true, oneHourSectionId : oneHourlyFlag })
            }
        }
        this.renderOneHourlyAdditonalSection.length = 0
        for (var i of hourlyAddInfoAfterDelete){
            this.renderOneHourlyAdditonalSection.push(i)
        }
        this.oneHourlyFlag = this.renderOneHourlyAdditonalSection.length
        this.isOneHourlyAdditionalSection = true
        this.isHourlyAddSectionDeleted = true
        this.showToast(customLabelValues.OWC_success_label,this.customLabelValues.OWC_section_delete_toastmsg,'success')
    }

    handleOneHourlySectionData(event){
        const hourlyAddInformationSectionData = event.detail
        this.hourlyAddSectionDataAfterDelete.push(hourlyAddInformationSectionData)
        console.log('hourlyAddInformationSectionData ::: ', JSON.stringify(this.hourlyAddSectionDataAfterDelete))
    }

 hourlyAdditionaldata;
 isRenderhourlyAdd

    handleOneHourlyAddSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }
    

    /**Starting Different Hour Additional Section Work here */
    @api renderDifferentHourAdditonalSection = []
    sFlag1 = 0
    differentHourAddValues
    
    @api differentHourAdditionalSectionValues
    @api differentHourAdditionalDetails = []
    isDifferentHourAdditionalInfoSection = false
    @api differentHourAddSectionDataAfterDelete =[]
    @api isDifferentHourAddSectionDeleted = false
    // Different Hour Section Validity event handler
    handleDifferentHourAddSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }

    //Add More Different Hour Info
    addMoreDifferentHour(){
        this.isDifferentHourAdditionalInfoSection = false
        const sFlag1 = this.sFlag1 + 1
        this.sFlag1 = sFlag1
        this.renderDifferentHourAdditonalSection.push({heading : this.customLabelValues.Owc_Additional, button : true, sectionId : this.sFlag1})
        this.isDifferentHourAdditionalInfoSection = true
    }

    handleDifferentHourAddSectionInfoEvent(event){
        const differentHourAdditionalSectionData = event.detail
        this.differentHourAdditionalSectionValues = differentHourAdditionalSectionData
        this.differentHourAdditionalDetails.push(this.differentHourAdditionalSectionValues)
        console.log('differentHourAdditionalDetails :::: ', JSON.stringify(this.differentHourAdditionalDetails))
        console.log('differentHourAdditionalSectionValues:', JSON.stringify(this.differentHourAdditionalSectionValues))
    }

    handleDifferentHourAdditionalSectionDelete(event){
        var sflag1 = 1
        const differentHourAddInfoAfterDelete = []
        this.isDifferentHourAdditionalInfoSection = false 
        this.differentHourAddSectionDataAfterDelete.length = 0
        this.deleteDifferentHourAddSectionId = event.detail.sectionId
        const differentHourAdditionalSectionDetails = this.template.querySelectorAll('c-Owc-Different-Hour-Rate-Additional')
        for (let i = 0; i < differentHourAdditionalSectionDetails.length; i++){
            differentHourAdditionalSectionDetails[i].handleDifferentHourAddSectionData()
        }
        const deleteDifferentHourAddSectionDataIndex = this.differentHourAddSectionDataAfterDelete.findIndex(sec => sec.sectionId === this.deleteDifferentHourAddSectionId)
        console.log('deleteDifferentHourAddSectionDataIndex ::: ', deleteDifferentHourAddSectionDataIndex)
        this.differentHourAddSectionDataAfterDelete.splice(deleteDifferentHourAddSectionDataIndex, 1);
        console.log('After delete successor ::: ', JSON.stringify(this.differentHourAddSectionDataAfterDelete))
        const deletedSectionIndex = this.renderDifferentHourAdditonalSection.findIndex(sec => sec.sectionId === this.deleteDifferentHourAddSectionId)
        this.renderDifferentHourAdditonalSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderDifferentHourAdditonalSection.length ;i++){
            sflag1 = 1 + i
            if(this.renderDifferentHourAdditonalSection[i].heading === this.customLabelValues.Owc_Additional){
                differentHourAddInfoAfterDelete.push(this.renderDifferentHourAdditonalSection[i])
            }
            else{
                differentHourAddInfoAfterDelete.push({heading : this.customLabelValues.Owc_Additional, button : true, sectionId : sflag1 })
            }
        }
        this.renderDifferentHourAdditonalSection.length = 0
        for (var i of differentHourAddInfoAfterDelete){
            this.renderDifferentHourAdditonalSection.push(i)
        }
        this.sFlag1 = this.renderDifferentHourAdditonalSection.length
        this.isDifferentHourAdditionalInfoSection = true
        this.isDifferentHourAddSectionDeleted = true
        this.showToast(customLabelValues.OWC_success_label,this.customLabelValues.OWC_section_delete_toastmsg,'success')
    }

    handleDifferentHourAddSectionDeletedData(event){
        const differentHourAddInformationSectionData = event.detail
        this.differentHourAddSectionDataAfterDelete.push(differentHourAddInformationSectionData)
    }

 differentHourAdditionaldata;
 isRenderDifferentHourAdd
    
    handleDifferentAdditional(differentHourAdditionalvalue, differentHourAdditionalCount){
        this.differentHourAdditionaldata = differentHourAdditionalvalue
        this.differentHourAdditionalSectionValues = differentHourAdditionalvalue
        this.renderDifferentHourAdditonalSection.length = 0
        this.isDifferentHourAdditionalInfoSection = true
                for(let i = 0;i < differentHourAdditionalCount.length;i++){
            this.isDifferentHourAdditionalInfoSection = false
            this.renderDifferentHourAdditonalSection.push(differentHourAdditionalCount[i])
        }
        this.sFlag1 = this.renderDifferentHourAdditonalSection.length
        this.isDifferentHourAdditionalInfoSection = true
        this.isRenderDifferentHourAdd = true
    }


     /**Starting Salary Rate Additional Section Work here */
     @api renderSalaryRateAdditonalSection = []
     salaryRateFlag = 0
     hourlyAddValues
    
     @api salaryRateAdditionalSectionValues
     @api salaryRateAdditionalDetails = []
     @api isSalaryRateAdditionalSection = false
     isSalaryRateAddSectionDeleted = false
     @api salaryRateAddSectionDataAfterDelete = []
     // Salary Rate Section Validity event handler
     salaryRateAddSectionValidity(event){
         const val = event.detail
         this.isNotChangedCurrentStep = val.currentStep
         console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
     }
 
     //Add More Salary Rate Info
     addMoreSalaryRate(){
         this.isSalaryRateAdditionalSection = false
         const salaryRateFlag = this.salaryRateFlag + 1
         this.salaryRateFlag = salaryRateFlag
         this.renderSalaryRateAdditonalSection.push({heading : this.customLabelValues.Owc_Additional, button : true, salaryRateSectionId : this.salaryRateFlag})
         this.isSalaryRateAdditionalSection = true
     }
 
     handleSalaryRateAddSectionInfoEvent(event){
         const salaryRateAdditionalSectionData = event.detail
         this.salaryRateAdditionalSectionValues = salaryRateAdditionalSectionData
         this.salaryRateAdditionalDetails.push(this.salaryRateAdditionalSectionValues)
         console.log('salaryRateAdditionalDetails :::: ', JSON.stringify(this.salaryRateAdditionalDetails))
         console.log('salaryRateAdditionalSectionValues:', JSON.stringify(this.salaryRateAdditionalSectionValues))
     }
 
     handleSalaryRateSectionDeletion(event){
         var salaryRateFlag = 0
         const salaryRateAddInfoAfterDelete = []
         this.isSalaryRateAdditionalSection = false
         this.salaryRateAddSectionDataAfterDelete.length = 0
         this.deleteSalaryRateAddSectionId = event.detail.salaryRateSectionId
         const salaryRateAdditionalSectionDetails = this.template.querySelectorAll('c-owc-Salary-Rate-Additional-Cmp')
         for (let i = 0; i < salaryRateAdditionalSectionDetails.length; i++){
             salaryRateAdditionalSectionDetails[i].handleSalaryRateAddSectionData()
         }
         const deleteSalaryRateAddSectionDataIndex = this.salaryRateAddSectionDataAfterDelete.findIndex(sec => sec.salaryRateSectionId === this.deleteSalaryRateAddSectionId)
         console.log('deleteSalaryRateAddSectionDataIndex ::: ', deleteSalaryRateAddSectionDataIndex)
         this.salaryRateAddSectionDataAfterDelete.splice(deleteSalaryRateAddSectionDataIndex, 1);
         console.log('After delete Salary Rate ::: ', JSON.stringify(this.salaryRateAddSectionDataAfterDelete))
         const deletedSectionIndex = this.renderSalaryRateAdditonalSection.findIndex(sec => sec.salaryRateSectionId === this.deleteSalaryRateAddSectionId)
         this.renderSalaryRateAdditonalSection.splice(deletedSectionIndex, 1);
         for(let i = 0; i < this.renderSalaryRateAdditonalSection.length ;i++){
             salaryRateFlag = i + 1
             if(this.renderSalaryRateAdditonalSection[i].heading === this.customLabelValues.OWC_successoraddinfo_heading){
                 salaryRateAddInfoAfterDelete.push(this.renderSalaryRateAdditonalSection[i])
             }
             else{
                 salaryRateAddInfoAfterDelete.push({heading : this.customLabelValues.Owc_Additional, button : true, salaryRateSectionId : salaryRateFlag })
             }
         }
         this.renderSalaryRateAdditonalSection.length = 0
         for (var i of salaryRateAddInfoAfterDelete){
             this.renderSalaryRateAdditonalSection.push(i)
         }
         this.salaryRateFlag = this.renderSalaryRateAdditonalSection.length
         this.isSalaryRateAdditionalSection = true
         this.isSalaryRateAddSectionDeleted = true
         this.showToast(customLabelValues.OWC_success_label,this.customLabelValues.OWC_section_delete_toastmsg,'success')
     }
 
     handleSalaryRateSectionData(event){
         const salaryRateAddInformationSectionData = event.detail
         this.salaryRateAddSectionDataAfterDelete.push(salaryRateAddInformationSectionData)
         console.log('salaryRateAddInformationSectionData ::: ', JSON.stringify(this.salaryRateAddSectionDataAfterDelete))
     }
 
  salaryRateAdditionaldata;
  isRenderSalaryRateAdd
    
     salaryRateAdditionalSectionValues
     handleSalaryRateAdditional(salaryRateAdditionalvalue, salaryRateAdditionalCount){
         this.salaryRateAdditionaldata = salaryRateAdditionalvalue
         this.salaryRateAdditionalSectionValues = salaryRateAdditionalvalue
         this.renderSalaryRateAdditonalSection.length = 0
         this.isSalaryRateAdditionalSection = true
         if(salaryRateAdditionalCount !== undefined || salaryRateAdditionalCount !== null)
         {
             for(var i = 0;i < salaryRateAdditionalCount.length;i++){
             this.isSalaryRateAdditionalSection = false
             this.renderSalaryRateAdditonalSection.push(salaryRateAdditionalCount[i])
            }
        }
         this.salaryRateFlag = this.renderSalaryRateAdditonalSection.length
         this.isSalaryRateAdditionalSection = true
         this.isRenderDifferentHourAdd = true
     }
 
     handleSalaryRateAddSectionValidity(event){
         const val = event.detail
         this.isNotChangedCurrentStep = val.currentStep
         console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
     }

     /**Starting Piece Rate Additional Section Work here */
    @api renderPieceRateAdditonalSection = []
    pieceRateFlag = 0
    pieceRateAddValues
   
    @api pieceRateAdditionalSectionValues
    @api pieceRateAdditionalDetails = []
    @api isPieceRateAdditionalSection = false
    isPieceRateAddSectionDeleted = false
    @api pieceRateAddSectionDataAfterDelete = []
    // Piece Rate Section Validity event handler
    pieceRateAddSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }

    //Add More Piece Rate Info
    addMorePieceRate(){
        this.isPieceRateAdditionalSection = false
        const pieceRateFlag = this.pieceRateFlag + 1
        this.pieceRateFlag = pieceRateFlag
        this.renderPieceRateAdditonalSection.push({heading : this.customLabelValues.Owc_Additional, button : true, pieceRateSectionId : this.pieceRateFlag})
        this.isPieceRateAdditionalSection = true
    }

    handlePieceRateAddSectionInfoEvent(event){
        const pieceRateAdditionalSectionData = event.detail
        this.pieceRateAdditionalSectionValues = pieceRateAdditionalSectionData
        this.pieceRateAdditionalDetails.push(this.pieceRateAdditionalSectionValues)
        console.log('pieceRateAdditionalDetails :::: ', JSON.stringify(this.pieceRateAdditionalDetails))
        console.log('pieceRateAdditionalSectionValues:', JSON.stringify(this.pieceRateAdditionalSectionValues))
    }

    handlePieceRateSectionDeletion(event){
        var pieceRateFlag = 0
        const pieceRateAddInfoAfterDelete = []
        this.isPieceRateAdditionalSection = false
        this.pieceRateAddSectionDataAfterDelete.length = 0
        this.deletePieceRateAddSectionId = event.detail.pieceRateSectionId
        const pieceRateAdditionalSectionDetails = this.template.querySelectorAll('c-owc-Piece-Rate-Additional-Cmp')
        for (let i = 0; i < pieceRateAdditionalSectionDetails.length; i++){
            pieceRateAdditionalSectionDetails[i].handlePieceRateAddSectionData()
        }
        const deletePieceRateAddSectionDataIndex = this.pieceRateAddSectionDataAfterDelete.findIndex(sec => sec.pieceRateSectionId === this.deletePieceRateAddSectionId)
        console.log('deletePieceRateAddSectionDataIndex ::: ', deletePieceRateAddSectionDataIndex)
        this.pieceRateAddSectionDataAfterDelete.splice(deletePieceRateAddSectionDataIndex, 1);
        console.log('After delete successor ::: ', JSON.stringify(this.pieceRateAddSectionDataAfterDelete))
        const deletedSectionIndex = this.renderPieceRateAdditonalSection.findIndex(sec => sec.pieceRateSectionId === this.deletePieceRateAddSectionId)
        this.renderPieceRateAdditonalSection.splice(deletedSectionIndex, 1);
        for(let i = 0; i < this.renderPieceRateAdditonalSection.length ;i++){
            pieceRateFlag = i + 1
            if(this.renderPieceRateAdditonalSection[i].heading === this.customLabelValues.OWC_successoraddinfo_heading){
                pieceRateAddInfoAfterDelete.push(this.renderPieceRateAdditonalSection[i])
            }
            else{
                pieceRateAddInfoAfterDelete.push({heading : this.customLabelValues.Owc_Additional, button : true, pieceRateSectionId : pieceRateFlag })
            }
        }
        this.renderPieceRateAdditonalSection.length = 0
        for (var i of pieceRateAddInfoAfterDelete){
            this.renderPieceRateAdditonalSection.push(i)
        }
        this.pieceRateFlag = this.renderPieceRateAdditonalSection.length
        this.isPieceRateAdditionalSection = true
        this.isPieceRateAddSectionDeleted = true
        this.showToast(customLabelValues.OWC_success_label,this.customLabelValues.OWC_section_delete_toastmsg,'success')
    }

    handlePieceRateSectionData(event){
        const pieceRateAddInformationSectionData = event.detail
        this.pieceRateAddSectionDataAfterDelete.push(pieceRateAddInformationSectionData)
        console.log('pieceRateAddInformationSectionData ::: ', JSON.stringify(this.pieceRateAddSectionDataAfterDelete))
    }

 pieceRateAdditionaldata;
 isRenderPieceRateAdd
   
    pieceRateAdditionaldata
    pieceRateAdditionalSectionValues
    handlePieceRateAdditional(pieceRateAdditionalvalue, pieceRateAdditionalCount){
        this.pieceRateAdditionaldata = pieceRateAdditionalvalue
        this.pieceRateAdditionalSectionValues = pieceRateAdditionalvalue
        this.renderPieceRateAdditonalSection.length = 0
        this.isPieceRateAdditionalSection = true
                for(let i = 0;i < pieceRateAdditionalCount.length;i++){
            this.isPieceRateAdditionalSection = false
            this.renderPieceRateAdditonalSection.push(pieceRateAdditionalCount[i])
        }
        this.pieceRateFlag = this.renderPieceRateAdditonalSection.length
        this.isPieceRateAdditionalSection = true
        this.isRenderPieceRateAdd = true
    }

    handlePieceRateAddSectionValidity(event){
        const val = event.detail
        this.isNotChangedCurrentStep = val.currentStep
        console.log('isNotChangedCurrentStep:', this.isNotChangedCurrentStep);
    }
     
 
    //Method to reset OneHourly Fields value
    isOneHourlyRateReset(){
        this.paidAmountPerHour = null
        this.promisedAmountPerHour = null
        this.hourlyRateBegDate = null
        this.hourlyRateEndDate = null
        this.isOneHourlyRateClicked  = false
        this.paidAmountPerHourAdditional = null
        this.promisedAmountPerHourAdditional = null
        this.hourlyRateBegDateAdditional = null
        this.hourlyRateEndDateAdditional = null
        this.isDifferentHourAdditionalInfoSection = false
        this.renderDifferentHourAdditonalSection.length = 0
    }
    


    //Method to reset different hour rate Fields value
    isDifferentHourRateReset(){
        this.paidAmountDifferentHour = null
        this.promisedAmountDifferentHour = null
        this.forActivity = null
        this.differentHourlyRateBegDate = null
        this.differentHourlyRateEndDate = null
        this.isDifferentHourRateClicked = false
        this.paidAmountDifferentHourAdditional = null
        this.promisedAmountDifferentHourAdditional = null
        this.forActivityAdditional = null
        this.differentHourlyRateBegDateAdditional = null
        this.differentHourlyRateEndDateAdditional = null
        this.isOneHourlyAdditionalSection = false
        this.renderOneHourlyAdditonalSection.length = 0
    }
    // get isDifferentHourRate(){
    //     return this.value.includes('Different hourly rates.' || 'Diferentes tarifas por hora.')
    // }
    //Method to reset salary rate Fields value
    isSalaryRateForEachDayReset(){
        console.log('SLary::',JSON.stringify(this.salaryRateAdditionalDetails))
        
        this.paidAmountForEachDay = null
        this.promisedAmountForEachDay = null
        this.frequencyOfEachDay = null
        this.eachPayRateBegDate = null
        this.eachPayRateEndDate = null
        this.isEachPayClicked  = false
        this.promisedAmountForEachDayAdditional = null
        this.frequencyOfEachDayAdditional = null
        this.eachPayRateBegDateAdditional = null
        this.eachPayRateEndDateAdditional = null
        this.renderSalaryRateAdditonalSection.length = 0
        this.isSalaryRateAdditionalSection = false
        console.log('renderSalaryRateAdditonalSectionReset',this.renderSalaryRateAdditonalSection.length)
    }
    // get isSalaryRateForEachDay(){
    //     return this.value.includes('Salary rate for each pay period.' || 'Tasa de salario para cada período de pago.')
    // }
    //Method to reset commission rate Fields value
    isCommissionRateReset(){
        this.paidCommissionRate = null
        this.promisedCommissionRate = null
        this.commissionRateBegDate = null
        this.commissionRateEndDate = null
        this.writtenCommission = null
    }
    // get isCommissionRate(){
    //     return this.value.includes('Commission rate' || 'porcentaje de comision')
    // }
    //Method to reset piece rate Fields value
    isPieceRateReset(){
        this.providePriceRate = null
        this.paidPieceRate = null
        this.promisedPieceRate = null
        this.perUnitPaymentOfWages = null
        this.other = null
        this.numberOfUnits = null
        this.pieceRateBegDate = null
        this.pieceRateEndDate = null
        this.pieceRateTotalEarned = null
        this.pieceRateTotalPaid = null
        this.isPieceOfRateClicked = false
        this.isPerUnitOther = false
        this.isProvidePriceRate = false

        this.paidPieceRateAdditional = null
        this.promisedPieceRateAdditional = null
        this.perUnitPaymentOfWagesAdditional = null
        this.otherAdditional = null
        this.numberOfUnitsAdditional = null
        this.pieceRateBegDateAdditional = null
        this.pieceRateEndDateAdditional = null
        this.isPerUnitOtherAdditional = false
        this.isPieceRateAdditionalSection = false
        this.renderPieceRateAdditonalSection.length = 0
    }
    //  get isPieceRate(){
    //     return this.value.includes('Piece rate' || 'Precio por pieza')
    // }

    get selectedValues() {
        return this.value.join(',');
    }

    //Evnt for handling all the data
    handleEvent(){
        const selectEvent = new CustomEvent('paymentofwagesevent', {
            detail: {
                isOneHourlyAdditionalSection : this.isOneHourlyAdditionalSection,
                isDifferentHourAdditionalInfoSection : this.isDifferentHourAdditionalInfoSection,
                isPieceRateAdditionalSection : this.isPieceRateAdditionalSection,
                differentHourAddDetails : this.differentHourAddDetails,
                isSalaryRateAdditionalSection : this.isSalaryRateAdditionalSection,
                isCommissionReciptFileUpload : this.isCommissionReciptFileUpload,
                commissionReciptDocsSize : this.commissionReciptDocsSize,
                commissionReciptDocs :  this.commissionReciptDocs,
                isAgreementFileUpload : this.isAgreementFileUpload,
                agreementDocsSize : this.agreementDocsSize,
                agreementDocs : this.agreementDocs,
                isSelectedFileDeleted : this.isSelectedFileDeleted,
                empPaymentType : this.empPaymentType,
                value : this.value,
                isOneHourlyRate : this.isOneHourlyRate,
                paidAmountPerHour : this.paidAmountPerHour,
                promisedAmountPerHour : this.promisedAmountPerHour,
                hourlyRateBegDate : this.hourlyRateBegDate,
                hourlyRateEndDate : this.hourlyRateEndDate,
                isOneHourlyRateClicked : this.isOneHourlyRateClicked,
                paidAmountPerHourAdditional : this.paidAmountPerHourAdditional,
                promisedAmountPerHourAdditional : this.promisedAmountPerHourAdditional,
                hourlyRateBegDateAdditional : this.hourlyRateBegDateAdditional,
                hourlyRateEndDateAdditional : this.hourlyRateEndDateAdditional,

                isDifferentHourRate : this.isDifferentHourRate,
                paidAmountDifferentHour : this.paidAmountDifferentHour,
                paidAmountDifferentHourAdditional : this.paidAmountDifferentHourAdditional,
                promisedAmountDifferentHour : this.promisedAmountDifferentHour,
                promisedAmountDifferentHourAdditional : this.promisedAmountDifferentHourAdditional,
                forActivity : this.forActivity,
                forActivityAdditional : this.forActivityAdditional,
                differentHourlyRateBegDate : this.differentHourlyRateBegDate,
                differentHourlyRateEndDate : this.differentHourlyRateEndDate,
                isDifferentHourRateClicked : this.isDifferentHourRateClicked,
                differentHourlyRateBegDateAdditional : this.differentHourlyRateBegDateAdditional,
                differentHourlyRateEndDateAdditional : this.differentHourlyRateEndDateAdditional,

                isSalaryRateForEachDay : this.isSalaryRateForEachDay,
                paidAmountForEachDay : this.paidAmountForEachDay,
                paidFrequencyOfEachDay : this.paidFrequencyOfEachDay,
                promisedAmountForEachDay : this.promisedAmountForEachDay ,
                promisedAmountForEachDayAdditional : this.promisedAmountForEachDayAdditional,
                frequencyOfEachDay : this.frequencyOfEachDay  ,
                frequencyOfEachDayAdditional : this.frequencyOfEachDayAdditional,
                eachPayRateBegDate : this.eachPayRateBegDate,
                eachPayRateBegDateAdditional : this.eachPayRateBegDateAdditional,
                eachPayRateEndDate : this.eachPayRateEndDate,
                eachPayRateEndDateAdditional : this.eachPayRateEndDateAdditional,
                isEachPayClicked : this.isEachPayClicked,
                
                isCommissionRate : this.isCommissionRate ,
                paidCommissionRate : this.paidCommissionRate ,
                promisedCommissionRate : this.promisedCommissionRate,
                writtenCommission : this.writtenCommission ,
                isWrittenCommission : this.isWrittenCommission,
                commissionRateBegDate : this.commissionRateBegDate,
                commissionRateEndDate : this.commissionRateEndDate,
                uploadLabelSection : this.uploadLabelSection,
                isFileUploaded : this.isFileUploaded ,
                isPieceRate : this.isPieceRate ,
                paidPieceRate : this.paidPieceRate ,
                
                promisedPieceRate : this.promisedPieceRate,
                
                paidMiniumWage : this.paidMiniumWage ,
                
                fileUploader : this.fileUploader,
                uploadFileSize : this.uploadFileSize ,
                uploadUnionContractDocument : this.uploadUnionContractDocument, 
                perUnitPaymentOfWages : this.perUnitPaymentOfWages,
                other : this.other,
                numberOfUnits : this.numberOfUnits,
                pieceRateBegDate : this.pieceRateBegDate,
                pieceRateEndDate : this.pieceRateEndDate,
                pieceRateTotalEarned : this.pieceRateTotalEarned,
                pieceRateTotalPaid : this.pieceRateTotalPaid,
                ispieceRateEndDate : this.ispieceRateEndDate,
                isProvidePriceRate : this.isProvidePriceRate,
                paidPieceRateAdditional :  this.paidPieceRateAdditional,
                promisedPieceRateAdditional : this.promisedPieceRateAdditional,
                perUnitPaymentOfWagesAdditional :   this.perUnitPaymentOfWagesAdditional,
                otherAdditional : this.otherAdditional,
                numberOfUnitsAdditional : this.numberOfUnitsAdditional,
                pieceRateBegDateAdditional : this.pieceRateBegDateAdditional,
                pieceRateEndDateAdditional : this.pieceRateEndDateAdditional,
                isPerUnitOtherAdditional  : this.isPerUnitOtherAdditional,
                isPerUnitOther : this.isPerUnitOther,
                isPieceOfRateClicked : this.isPieceOfRateClicked,

                paymentOfWagesForGarmentDetails : this.paymentOfWagesForGarmentDetails,
                paymentOfWagesForGarmentSectionValues : this.paymentOfWagesForGarmentSectionValues,

                differentHourAdditionalDetails : this.differentHourAdditionalDetails,                
                renderDifferentHourAdditonalSection :  this.renderDifferentHourAdditonalSection,

                hourlyAdditionalDetails : this.hourlyAdditionalDetails,
                renderOneHourlyAdditonalSection : this.renderOneHourlyAdditonalSection,

                salaryRateAdditionalDetails : this.salaryRateAdditionalDetails,
                renderSalaryRateAdditonalSection : this.renderSalaryRateAdditonalSection,

                pieceRateAdditionalDetails :  this.pieceRateAdditionalDetails,
                renderPieceRateAdditonalSection : this.renderPieceRateAdditonalSection,

                HourlyOptionValue : this.HourlyOptionValue,
                pieceRateOptionValue : this.pieceRateOptionValue,
                commissionRateOptionValue  : this.commissionRateOptionValue,
                salaryRateOptionValue : this.salaryRateOptionValue,
                differentHourOptionValue : this.differentHourOptionValue,
                contentVersionIds : this.contentVersionIds,
                totalUploadFiles : this.totalUploadFiles,
                flag : this.flag

            }
        });
        this.dispatchEvent(selectEvent);
    }

    isempPaymentType = false
    isuploadLabel = false
    ispaidSepartly = false
    @api isAgreementRequired = false
    @api ValidationMsg = ''
    isCommissionDoc = false

    /* Define attribute to store the boolean values for One hourly rate of pay for all regular hours. */
    ispaidAmountPerHour = false
    ispromisedAmountPerHour = false
    isPaidOrPromisedAmount = false
    isPOWDateAcceptable = false
    isNotAdditionalPaidAmountPerHour = false
    isNotAdditionalpromisedAmountPerHour = false
    isPOWDateAcceptableAdditional = false
    isHourlyRateBegDate = false

    /* Define attribute to store the boolean values for Different Hourly rate */
    ispaidAmountDifferentHour = false
    ispromisedAmountDifferentHour = false
    isPaidOrPromisedAmountDifferentHour = false
    isDifferentHourRateDateAcceptable = false
    isNotAdditionalPaidAmountDifferentHour = false
    isNotAdditionalPromisedAmountDifferentHour = false
    isDNotAdditionalHourRateDateAcceptable = false
    isDifferentHourRateBegDate = false

    /* Define attribute to store the boolean values for Salary Rate for each pay period */
    isNotpaidAmountForEachDay = false
    isNotpromisedAmountForEachDay = false
    isPaidOrPromisedAmountForEachDay = false
    isNotEachPayRateDateAcceptable = false
    isNotAdditionalpaidAmountForEachDay = false
    isNotAdditionalpromisedAmountForEachDay = false
    isNotAdditionaleachPayRateBegDate = false
    isSalaryEachDayBegDate = false
    isNotSalaryPeriod = false

    /* Define attribute to store the boolean values for Commission Rate */
    isNotPaidCommissionRate = false
    isNotpromisedCommissionRate = false
    isNotCommissionRateDateAcceptable = false

    /* Define attribute to store the boolean values for Piece Rate */
    isNotpaidPieceRate = false
    isNotpromisedPieceRate = false
    isNotPaidorPromisedPIeceRate = false
    isNotpieceRateTotalEarned = false
    isNotpieceRateTotalEarnedMissing = false
    isNotpieceRateTotalPaidMissing = false
    isNotpieceRateBegDateMissing = false
    isNotpieceRateUnitPaymentMissing = false
    isNotpieceRateTotalPaid = false
    isNotnumberOfUnits = false
    isNotpieceRateBegDate = false
    isNotpaidPieceRateAdditional = false
    isNotpromisedPieceRateAdditional = false
    isNotperUnitPaymentOfWagesAdditional = false
    isNotpieceRateBegDateAdditional = false
    
    /* This method is used to verify at least one of two required fields is populated */
    handleRequiredSetValidation(FirstId,SecondId){
        var FirstId = FirstId
        var SecondId = SecondId
        let paidAmountPerHourMissing = (FirstId.value === undefined || FirstId.value === null || FirstId.value.trim() === '')
        let promisedAmountPerHourMissing = (SecondId.value === undefined || SecondId.value === null || SecondId.value.trim() === '')
        if(paidAmountPerHourMissing && promisedAmountPerHourMissing){
            FirstId.setCustomValidity(customLabelValues.OWC_Paid_or_Promised);
            SecondId.setCustomValidity(customLabelValues.OWC_Paid_or_Promised);
            FirstId.reportValidity()
            SecondId.reportValidity()
            console.log('Paid or promised',this.customLabelValues.OWC_Paid_or_Promised)
            return true;
        }
        else{
            FirstId.setCustomValidity('');
            SecondId.setCustomValidity('');
            FirstId.reportValidity();
            SecondId.reportValidity();
            return false
        }
    }

    handleRequiredCheckbox(FieldId){
        if( FieldId.value === null || FieldId.value === undefined){
            FieldId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            FieldId.reportValidity()
            return true;
        }
        else{
            FieldId.setCustomValidity('')
            FieldId.reportValidity()
            return false
        }
    }

    handleRequiredField(FieldId){
        if( FieldId.value.trim() === '' || FieldId.value === null || FieldId.value === undefined){
            FieldId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            FieldId.reportValidity()
            return true;
        }
        else{
            FieldId.setCustomValidity('')
            FieldId.reportValidity()
            return false
        }
    }
    handleRequiredDropDown(FieldId){
        if( FieldId.value === null || FieldId.value === undefined){
            FieldId.setCustomValidity(customLabelValues.OWC_required_field_error_msg)
            FieldId.reportValidity()
            return true;
        }
        else{
            FieldId.setCustomValidity('')
            FieldId.reportValidity()
            return false
        }
    }


    /* This method is used to check all types of validation on the date fields. */
    handlePOWDateValidity(startDateId, endDateId, startDate, endDate){
        var startDateId = startDateId
        var endDateId = endDateId
        var startDate = startDate
        var endDate = endDate
        var today = new Date();

        startDate !== '' ? startDate = new Date(startDate.toString()) : ''

        endDate !== '' ? endDate = new Date(endDate.toString()) : ''
        if(startDate === '' && endDate === ''){
            startDateId.setCustomValidity('')
            endDateId.setCustomValidity('')
            startDateId.reportValidity();
            endDateId.reportValidity();
            return false;
        }

        else if((startDate === '' && endDate !== '') || (startDate !== '' && endDate === '')){
            startDateId.setCustomValidity(customLabelValues.Owc_fillBothDate_Fields)
            endDateId.setCustomValidity(customLabelValues.Owc_fillBothDate_Fields)
            startDateId.reportValidity();
            endDateId.reportValidity();
            return true;
        }
        
        // Check startDate is greater than today's date
        else if(startDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            startDateId.setCustomValidity(customLabelValues.OWC_pastdate_error_msg)
            startDateId.reportValidity()
            return true;
        }

        // Check endDate is greater than today's date
        else if(endDate.setHours(0,0,0,0) >= today.setHours(0,0,0,0)){
            endDateId.setCustomValidity(customLabelValues.OWC_pastdate_error_msg)
            endDateId.reportValidity()
            return true;
        }

        // check startDate is greater than endDate
        else if(startDate > endDate){
            startDateId.setCustomValidity(customLabelValues.OWC_begdate_error_msg)
            endDateId.setCustomValidity(customLabelValues.OWC_begdate_error_msg)
            endDateId.reportValidity()
            startDateId.reportValidity()
            return true;
        }

        else{
            startDateId.setCustomValidity('')
            endDateId.setCustomValidity('')
            startDateId.reportValidity();
            endDateId.reportValidity();
            return false;
        }

    }

    /* This method is used to check all the amount fields validation */
    handlePOWAmountValidity(fieldId){
            if(fieldId.value == undefined || fieldId.value == null || fieldId.value.trim() == ''){
                fieldId.setCustomValidity("");
                fieldId.reportValidity();
                return false;
            }
            else if(fieldId.value.match(this.intRegrex)){
                fieldId.setCustomValidity("");
                fieldId.reportValidity()
                return false;
            }
            else{
                fieldId.setCustomValidity(customLabelValues.OWC_EnterValidAmount);
                fieldId.reportValidity();
                return true;
            }
        }

    /* This method is used to fire the custom event if any validation occurs on this section
    ** This event is handled by parent component i.e onlineWageClaimContainer.cmp
    */
    handleCustomValidityEvent(){
        const selectEvent = new CustomEvent('paymentofwagesvalidityevent', {
            detail: {
                currentStep : true
            }
        });
        this.isNotChangedCurrentStep = false
        this.dispatchEvent(selectEvent);
    }

    
    @api isempPaymentTypeSelected = false;
    @api isempPaymentTypeErrorMessage = false;
    /* This method is called from parent component when user click on continue button on this section. */
    @api 
    owcPaymentOfWagesFromParent(){

        /* check the validity for question 1 */
        // if(this.value.length === 0){
        //     let empPaymentType = this.template.querySelector('[data-id="empPaymentType"]');
        //     let empPaymentTypeValue = this.empPaymentType
        //     this.isempPaymentType = this.paymentOfWagesValidityChecker(empPaymentType, empPaymentTypeValue);
        //     this.isempPaymentType === true ? Payment.focus() : ''
        //     this.isempPaymentType === true ? this.handleCustomValidityEvent() : this.handleEvent();
        // }


        if(this.HourlyOptionValue === true || this.differentHourOptionValue === true || this.salaryRateOptionValue === true
            || this.commissionRateOptionValue === true || this.pieceRateOptionValue === true){
                this.isempPaymentTypeSelected = true;
                this.isempPaymentTypeErrorMessage = false;
                console.log("isValid",this.isempPaymentTypeSelected)
            }else{
                this.isempPaymentTypeSelected = false;
                this.isempPaymentTypeErrorMessage = true;
                console.log("isValid",this.isempPaymentTypeSelected)
            }

        /* check the validity for Commission rate fields */
        // if(this.isWrittenCommission === true){
        //     let uploadAgreementDocs = this.template.querySelector('[data-id="uploadAgreementDocs"]');
        //     if(this.agreementDocs == null || this.agreementDocs == undefined || this.agreementDocs == ''){
        //         this.isAgreementRequired = true
        //         this.isAgreementRequired === true ? uploadAgreementDocs.focus() : ''
        //         this.isAgreementRequired === true ? this.handleCustomValidityEvent() : this.handleEvent();
        //     }
        // }

        /* check the validity for One hourly rate of pay for all regular hours option fields. */
        if(this.isOneHourlyRate === true){
            let paidAmountPerHourId = this.template.querySelector('[data-id="paidAmountPerHour"]')
            let promisedAmountPerHourId = this.template.querySelector('[data-id="promisedAmountPerHour"]')
            this.ispaidAmountPerHour = this.handlePOWAmountValidity(paidAmountPerHourId)
            this.ispromisedAmountPerHour = this.handlePOWAmountValidity(promisedAmountPerHourId)
            this.isPaidOrPromisedAmount = this.handleRequiredSetValidation(paidAmountPerHourId,promisedAmountPerHourId)

            let hourlyRateBegDate = this.template.querySelector('[data-id="hourlyRateBegDate"]')
            let hourlyRateEndDate = this.template.querySelector('[data-id="hourlyRateEndDate"]')
            this.isPOWDateAcceptable = this.handlePOWDateValidity(hourlyRateBegDate, hourlyRateEndDate, hourlyRateBegDate.value, hourlyRateEndDate.value)
            this.isHourlyRateBegDate = this.handleRequiredField(hourlyRateBegDate)
            
            const additionalHourlyTemplate = this.template.querySelectorAll('c-owc-One-Hour-Additional-Cmp')
            console.log('Addional Hourly Size',additionalHourlyTemplate.length)
            for(var i=0; i<additionalHourlyTemplate.length; i++){
                additionalHourlyTemplate[i].owcOneHourAdditionalFromParent()
            }

            // Add focus to the validation field
            this.ispaidAmountPerHour === true ? paidAmountPerHourId.focus() : ''
            this.ispromisedAmountPerHour === true ? promisedAmountPerHourId.focus() : ''
            this.isPOWDateAcceptable === true ? hourlyRateBegDate.focus() : ''
            this.isNotAdditionalPaidAmountPerHour === true ? this.template.querySelector('[data-id="paidAmountPerHourAdditional"]').focus() : ''
            this.isNotAdditionalpromisedAmountPerHour === true ? this.template.querySelector('[data-id="promisedAmountPerHourAdditional"]').focus() : ''
            this.isPOWDateAcceptableAdditional === true ? this.template.querySelector('[data-id="hourlyRateBegDateAdditional"]').focus() : ''
            this.isHourlyRateBegDate === true ? hourlyRateBegDate.focus() : ''
            this.isPaidOrPromisedAmount === true ? (promisedAmountPerHourId.focus() && paidAmountPerHourId.focus()) : ''


        }
        
        
        /* check the validity for Different Hourly rate field */
        if(this.isDifferentHourRate === true){
            const paidAmountDifferentHourId = this.template.querySelector('[data-id="paidAmountDifferentHour"]')
            const promisedAmountDifferentHourId = this.template.querySelector('[data-id="promisedAmountDifferentHour"]');
            this.ispaidAmountDifferentHour = this.handlePOWAmountValidity(paidAmountDifferentHourId)
            this.ispromisedAmountDifferentHour = this.handlePOWAmountValidity(promisedAmountDifferentHourId)
            this.isPaidOrPromisedAmountDifferentHour = this.handleRequiredSetValidation(paidAmountDifferentHourId,promisedAmountDifferentHourId)


            let differentHourlyRateBegDateId = this.template.querySelector('[data-id="differentHourlyRateBegDate"]')
            let differentHourlyRateEndDateId = this.template.querySelector('[data-id="differentHourlyRateEndDate"]')
            this.isDifferentHourRateDateAcceptable = this.handlePOWDateValidity(differentHourlyRateBegDateId, differentHourlyRateEndDateId, differentHourlyRateBegDateId.value, differentHourlyRateEndDateId.value)
            this.isDifferentHourRateBegDate = this.handleRequiredField(differentHourlyRateBegDateId)

            const additionalTemplate = this.template.querySelectorAll('c-Owc-Different-Hour-Rate-Additional')
            console.log('Addional Size',additionalTemplate.length)
            for(var i=0; i<additionalTemplate.length; i++){
                additionalTemplate[i].owcDifferentHourAdditionalFromParent()
            }

            // Add focus to the validation field
            this.ispaidAmountDifferentHour === true ? paidAmountDifferentHourId.focus() : ''
            this.ispromisedAmountDifferentHour === true ? promisedAmountDifferentHourId.focus() : ''
            this.isDifferentHourRateDateAcceptable === true ? differentHourlyRateBegDateId.focus() : ''
            this.isPaidOrPromisedAmountDifferentHour === true ? (promisedAmountDifferentHourId.focus() && paidAmountDifferentHourId.focus()) : ''
            this.isDifferentHourRateBegDate === true ? differentHourlyRateBegDateId.focus() : ''

    
        }

        /* check the validity for Salary rate for each pay period. */
        if(this.isSalaryRateForEachDay === true){
            const paidAmountForEachDayId = this.template.querySelector('[data-id="paidAmountForEachDay"]')
            const promisedAmountForEachDayId = this.template.querySelector('[data-id="promisedAmountForEachDay"]')
            this.isNotpaidAmountForEachDay = this.handlePOWAmountValidity(paidAmountForEachDayId)
            this.isNotpromisedAmountForEachDay = this.handlePOWAmountValidity(promisedAmountForEachDayId)
            this.isPaidOrPromisedAmountForEachDay = this.handleRequiredSetValidation(paidAmountForEachDayId,promisedAmountForEachDayId)



            let eachPayRateBegDateId = this.template.querySelector('[data-id="eachPayRateBegDate"]')
            let eachPayRateEndDateId = this.template.querySelector('[data-id="eachPayRateEndDate"]')
            this.isNotEachPayRateDateAcceptable = this.handlePOWDateValidity(eachPayRateBegDateId, eachPayRateEndDateId, eachPayRateBegDateId.value, eachPayRateEndDateId.value)
            this.isSalaryEachDayBegDate = this.handleRequiredField(eachPayRateBegDateId)

            const salaryRatePeriod = (this.template.querySelector('[data-id="frequencyOfEachDay"]'))
            this.isNotSalaryPeriod = this.handleRequiredDropDown(salaryRatePeriod)

            const additionalSalaryRateTemplate = this.template.querySelectorAll('c-owc-Salary-Rate-Additional-Cmp')
            console.log('Addional Salary Rate Size',additionalSalaryRateTemplate.length)
            for(var i=0; i<additionalSalaryRateTemplate.length; i++){
                additionalSalaryRateTemplate[i].owcSalaryRateAdditionalFromParent()
            }

            // Add focus to the validation field
            this.isNotpaidAmountForEachDay === true ? paidAmountForEachDayId.focus() : ''
            this.isNotpromisedAmountForEachDay === true ? promisedAmountForEachDayId.focus() : ''
            this.isNotEachPayRateDateAcceptable === true ? eachPayRateBegDateId.focus() : ''
            this.isPaidOrPromisedAmountForEachDay === true ? (promisedAmountForEachDayId.focus() && paidAmountForEachDayId.focus()) : ''
            this.isSalaryEachDayBegDate === true ? eachPayRateBegDateId.focus() : ''
        }

        /* check the validity for Commission rate */
        if(this.isCommissionRate === true){
            const commissionRateId = this.template.querySelector('[data-id="writtenCommission"]')
            this.isNotCommissionRateResponse = this.handleRequiredCheckbox(commissionRateId)
        }


        // if(this.isCommissionRate === true){
        //     this.handleSaveFiles();
        // }
        

        /* check the valifity for commission rate */
        // if(this.isCommissionRate === true){
        //     const paidCommissionRateId = this.template.querySelector('[data-id="paidCommissionRate"]');
        //     const promisedCommissionRateId = this.template.querySelector('[data-id="promisedCommissionRate"]');
        //     this.isNotPaidCommissionRate = this.handlePOWAmountValidity(paidCommissionRateId);
        //     this.isNotpromisedCommissionRate = this.handlePOWAmountValidity(promisedCommissionRateId);


        //     let commissionRateBegDateId = this.template.querySelector('[data-id="commissionRateBegDate"]');
        //     let commissionRateEndDateId = this.template.querySelector('[data-id="commissionRateEndDate"]');
        //     this.isNotCommissionRateDateAcceptable = this.handlePOWDateValidity(commissionRateBegDateId, commissionRateEndDateId, commissionRateBegDateId.value, commissionRateEndDateId.value);

            
        //     let uploadCommissionDocs = this.template.querySelector('[data-id="uploadCommissionDocs"]');
            

        //     // Add focus to the validation field
        //     this.isNotPaidCommissionRate === true ? paidCommissionRateId.focus() : ''
        //     this.isNotpromisedCommissionRate === true ? promisedCommissionRateId.focus() : ''
        //     this.isNotCommissionRateDateAcceptable === true ? commissionRateBegDateId.focus() : ''
        //     this.isCommissionDoc === true ? uploadCommissionDocs.focus() : ''
        // }

        if(this.isPieceRate === true){
            if(this.isProvidePriceRate === false){
                const paidPieceRateId = this.template.querySelector('[data-id="paidPieceRate"]')
                const promisedPieceRateId = this.template.querySelector('[data-id="promisedPieceRate"]')
                this.isNotpaidPieceRate = this.handlePOWAmountValidity(paidPieceRateId);
                this.isNotpromisedPieceRate = this.handlePOWAmountValidity(promisedPieceRateId);
                this.isNotPaidorPromisedPIeceRate =this.handleRequiredSetValidation(paidPieceRateId,promisedPieceRateId)
 
                const pieceRateUnitPaymentId = this.template.querySelector('[data-id="perUnitPaymentOfWages"]')
                const numberOfUnitsId = this.template.querySelector('[data-id="numberOfUnits"]');
                this.isNotnumberOfUnits = this.handlePOWAmountValidity(numberOfUnitsId);
                this.isNotpieceRateUnitPaymentMissing = this.handleRequiredDropDown(pieceRateUnitPaymentId)

            }

            const pieceRateTotalEarnedId = this.template.querySelector('[data-id="pieceRateTotalEarned"]');
            const pieceRateTotalPaidId = this.template.querySelector('[data-id="pieceRateTotalPaid"]');
            this.isNotpieceRateTotalEarned = this.handlePOWAmountValidity(pieceRateTotalEarnedId);
            this.isNotpieceRateTotalEarnedMissing = this.handleRequiredField(pieceRateTotalEarnedId);
            this.isNotpieceRateTotalPaid = this.handlePOWAmountValidity(pieceRateTotalPaidId);
            this.isNotpieceRateTotalPaidMissing = this.handleRequiredField(pieceRateTotalPaidId);


            let pieceRateBegDateId = this.template.querySelector('[data-id="pieceRateBegDate"]');
            let pieceRateEndDateId = this.template.querySelector('[data-id="pieceRateEndDate"]');
            this.isNotpieceRateBegDate = this.handlePOWDateValidity(pieceRateBegDateId, pieceRateEndDateId, pieceRateBegDateId.value, pieceRateEndDateId.value);
            this.isNotpieceRateBegDateMissing = this.handleRequiredField(pieceRateBegDateId)

            const additionalPieceRateTemplate = this.template.querySelectorAll('c-owc-Piece-Rate-Additional-Cmp')
            console.log('Addional Salary Rate Size',additionalPieceRateTemplate.length)
            for(var i=0; i<additionalPieceRateTemplate.length; i++){
                additionalPieceRateTemplate[i].owcPieceRateAdditionalFromParent()
            }


            // Add focus to the validation field
            if(this.isProvidePriceRate === false){
                const paidPieceRateId = this.template.querySelector('[data-id="paidPieceRate"]');
                const promisedPieceRateId = this.template.querySelector('[data-id="promisedPieceRate"]');
                const pieceRateUnitPaymentId = this.template.querySelector('[data-id="perUnitPaymentOfWages"]')
                this.isNotpaidPieceRate === true ? paidPieceRateId.focus() : ''
                this.isNotpromisedPieceRate === true ? promisedPieceRateId.focus() : ''
                this.isNotnumberOfUnits === true ? numberOfUnitsId.focus() : ''
                this.isNotPaidorPromisedPIeceRate === true ? (paidPieceRateId.focus() && promisedPieceRateId.focus()) : ''
                this.isNotpieceRateTotalEarnedMissing === true ? (pieceRateTotalEarnedId.focus()) : ''
                this.isNotpieceRateTotalPaidMissing === true ? (pieceRateTotalPaidId.focus()) : ''
                this.isNotpieceRateUnitPaymentMissing === true ? (pieceRateUnitPaymentId).focus() : ''

            }
            this.isNotpieceRateTotalEarned === true ? pieceRateTotalEarnedId.focus() : ''
            this.isNotpieceRateTotalPaid === true ? pieceRateTotalPaidId.focus() : ''
            this.isNotpieceRateBegDate === true ? pieceRateBegDateId.focus() : ''
            this.isNotpieceRateBegDateMissing === true ? (pieceRateBegDateId).focus() : ''

            this.isNotpaidPieceRateAdditional === true ? this.template.querySelector('[data-id="paidPieceRateAdditional"]').focus() : ''
            this.isNotpromisedPieceRateAdditional === true ? this.template.querySelector('[data-id="promisedPieceRateAdditional"]').focus() : ''
            this.isNotperUnitPaymentOfWagesAdditional === true ? this.template.querySelector('[data-id="perUnitPaymentOfWagesAdditional"]').focus() : ''
            this.isNotpieceRateBegDateAdditional === true ? this.template.querySelector('[data-id="pieceRateBegDateAdditional"]').focus() : ''
        }
        
    //     if(this.isPieceRate === true && this.isGrament ===  true){
    //         this.template.querySelector('c-owc-payment-of-wages-for-garment-cmp').owcPaymentOfWagesForGarmentFromParent()
    //            if(this.isNotChangedCurrentStep === true){
    //                const selectEvent = new CustomEvent('paymentofwagesvalidityevent', {
    //                    detail: {
    //                        currentStep : true
    //                    }
    //                });
    //                this.isNotChangedCurrentStep = false
    //                this.dispatchEvent(selectEvent);
    //                return;
    //            }
    //    }
    //    else{
    //     this.handleEvent();
    //    }

        return (this.isempPaymentTypeSelected === false || this.isNotSalaryPeriod === true || this.isSalaryEachDayBegDate === true || this.isDifferentHourRateBegDate === true || this.isHourlyRateBegDate === true || this.isPOWDateAcceptable === true || this.ispaidAmountPerHour === true || this.isPaidOrPromisedAmountForEachDay === true || this.isPaidOrPromisedAmountDifferentHour === true || this.isPaidOrPromisedAmount === true || this.ispromisedAmountPerHour === true || this.isNotAdditionalPaidAmountPerHour === true || this.isNotAdditionalpromisedAmountPerHour === true || this.isPOWDateAcceptableAdditional === true
                 || this.ispaidAmountDifferentHour === true || this.ispromisedAmountDifferentHour === true || this.isDifferentHourRateDateAcceptable === true || this.isNotAdditionalPromisedAmountDifferentHour === true || this.isDNotAdditionalHourRateDateAcceptable === true
                 || this.isNotpaidAmountForEachDay === true || this.isNotCommissionRateResponse === true || this.isNotpromisedAmountForEachDay === true || this.isNotEachPayRateDateAcceptable === true || this.isNotAdditionalpaidAmountForEachDay === true || this.isNotAdditionalpromisedAmountForEachDay === true || this.isNotAdditionaleachPayRateBegDate === true
                 || this.isNotPaidCommissionRate === true || this.isNotpromisedCommissionRate === true || this.isNotCommissionRateDateAcceptable === true
                 || this.isNotpaidPieceRate === true || this.isNotPaidorPromisedPIeceRate === true || this.isNotpromisedPieceRate === true || this.isNotpieceRateTotalEarned === true || this.isNotpieceRateTotalEarnedMissing === true || this.isNotpieceRateTotalPaid === true || this.isNotpieceRateTotalPaidMissing === true || this.isNotpieceRateBegDate === true || this.isNotnumberOfUnits === true || this.isNotpieceRateUnitPaymentMissing === true
                 || this.isNotpaidPieceRateAdditional === true || this.isNotpromisedPieceRateAdditional === true || this.isNotperUnitPaymentOfWagesAdditional === true || this.isNotpieceRateBegDateAdditional === true 
                 || this.isNotChangedCurrentStep === true) ? this.handleCustomValidityEvent() : this.handleEvent();    
    }

    @api isFormPreviewMode = false
    @api paymentWagesDetailPreview
    @api HourlyEmplyeeSelectAnyOne = false
    @api ProvideDifferentRatesSelectAnyOne = false
    @api FixedAmountWagesSelectanyone = false
    @api AmountWagesSelectanyone = false
    @api FixedAmountWagesSelectfromFour = false
    @api ProvideCommissionRateSelectAnyOne = false
    @api ProvidePriceRateSelectAnyOne = false

    //Method for importing comp values from parent comp
    @api 
    owcPaymentOfWagesForChild(strString, isFormPreviewMode){
        this.paymentWagesDetailPreview = strString
        this.isFormPreviewMode = isFormPreviewMode
        console.log("this.isFormPreviewMode",this.isFormPreviewMode)
        this.differentHourAddDetails = strString.differentHourAddDetails
        if(this.paymentWagesDetailPreview.paidAmountPerHour != null || this.paymentWagesDetailPreview.promisedAmountPerHour != null){
            this.HourlyEmplyeeSelectAnyOne = true;
        }
        if(this.paymentWagesDetailPreview.paidAmountDifferentHour != null || this.paymentWagesDetailPreview.promisedAmountDifferentHour != null || this.paymentWagesDetailPreview.paidAmountDifferentHourAdditional != null || this.paymentWagesDetailPreview.promisedAmountDifferentHourAdditional != null ){
            this.ProvideDifferentRatesSelectAnyOne = true;
        }
        if(this.paymentWagesDetailPreview.paidAmountForEachDay != null || this.paymentWagesDetailPreview.paidFrequencyOfEachDay != null ){
            this.FixedAmountWagesSelectanyone = true;
        }
        if(this.paymentWagesDetailPreview.promisedAmountForEachDay != null || this.paymentWagesDetailPreview.frequencyOfEachDay != null ){
            this.AmountWagesSelectanyone = true;
        }
        if(this.FixedAmountWagesSelectanyone === true || this.AmountWagesSelectanyone === true ){
            this.FixedAmountWagesSelectfromFour = true;
        }
        if(this.paymentWagesDetailPreview.paidCommissionRate != null || this.paymentWagesDetailPreview.promisedCommissionRate != null || this.paymentWagesDetailPreview.writtenCommission != null ){
            this.ProvideCommissionRateSelectAnyOne = true;
        }
        if(this.paymentWagesDetailPreview.paidPieceRate != null || this.paymentWagesDetailPreview.currency != null ){
            this.ProvidePriceRateSelectAnyOne = true;
        }

        console.log('Child data >>>>>>>>>> ',JSON.stringify(strString))
        this.empPaymentType = strString.empPaymentType
        this.value = strString.value 
        
        this.isOneHourlyRate = strString.isOneHourlyRate 
        this.paidAmountPerHour = strString.paidAmountPerHour 
        this.promisedAmountPerHour = strString.promisedAmountPerHour
        this.hourlyRateBegDate = strString.hourlyRateBegDate
        this.hourlyRateEndDate = strString.hourlyRateEndDate
        this.isOneHourlyRateClicked = strString.isOneHourlyRateClicked
        this.paidAmountPerHourAdditional = strString.paidAmountPerHourAdditional
        this.promisedAmountPerHourAdditional = strString.promisedAmountPerHourAdditional
        this.hourlyRateBegDateAdditional = strString.hourlyRateBegDateAdditional
        this.hourlyRateEndDateAdditional = strString.hourlyRateEndDateAdditional

        this.isDifferentHourRate = strString.isDifferentHourRate 
        this.paidAmountDifferentHour = strString.paidAmountDifferentHour 
        this.paidAmountDifferentHourAdditional = strString.paidAmountDifferentHourAdditional
        this.promisedAmountDifferentHour = strString.promisedAmountDifferentHour 
        this.promisedAmountDifferentHourAdditional = strString.promisedAmountDifferentHourAdditional
        this.forActivity = strString.forActivity
        this.forActivityAdditional = strString.forActivityAdditional
        this.differentHourlyRateBegDate = strString.differentHourlyRateBegDate
        this.differentHourlyRateEndDate = strString.differentHourlyRateEndDate
        this.isDifferentHourRateClicked = strString.isDifferentHourRateClicked
        this.differentHourlyRateBegDateAdditional = strString.differentHourlyRateBegDateAdditional
        this.differentHourlyRateEndDateAdditional = strString.differentHourlyRateEndDateAdditional
        
        this.isSalaryRateForEachDay = strString.isSalaryRateForEachDay 
        this.paidAmountForEachDay = strString.paidAmountForEachDay 
        this.paidFrequencyOfEachDay = strString.paidFrequencyOfEachDay
        this.promisedAmountForEachDay = strString.promisedAmountForEachDay 
        this.promisedAmountForEachDayAdditional = strString.promisedAmountForEachDayAdditional
        this.frequencyOfEachDay = strString.frequencyOfEachDay  
        this.frequencyOfEachDayAdditional = strString.frequencyOfEachDayAdditional
        this.eachPayRateBegDate  = strString.eachPayRateBegDate
        this.eachPayRateBegDateAdditional = strString.eachPayRateBegDateAdditional
        this.eachPayRateEndDate = strString.eachPayRateEndDate
        this.eachPayRateEndDateAdditional = strString.eachPayRateEndDateAdditional
        this.isEachPayClicked = strString.isEachPayClicked
        
        this.isCommissionRate = strString.isCommissionRate 
        this.paidCommissionRate = strString.paidCommissionRate 
        this.promisedCommissionRate = strString.promisedCommissionRate
        this.writtenCommission = strString.writtenCommission 
        this.commissionRateBegDate = strString.commissionRateBegDate
        this.commissionRateEndDate = strString.commissionRateEndDate
        
        this.isWrittenCommission = strString.isWrittenCommission
        this.uploadLabelSection = strString.uploadLabelSection
        this.isFileUploaded = strString.isFileUploaded 
        
        this.isPieceRate = strString.isPieceRate 
        this.paidPieceRate = strString.paidPieceRate 
        this.promisedPieceRate = strString.promisedPieceRate 
        this.paidMiniumWage = strString.paidMiniumWage 
        
        
        this.isRecRestPeriod = strString.isRecRestPeriod
        
        this.fileUploader = strString.fileUploader         
        this.uploadFileSize = strString.uploadFileSize 
        this.uploadUnionContractDocument = strString.uploadUnionContractDocument 

        this.isCommissionReciptFileUpload = strString.isCommissionReciptFileUpload
        this.commissionReciptDocsSize = strString.commissionReciptDocsSize
        this.commissionReciptDocs = strString.commissionReciptDocs
        this.isAgreementFileUpload = strString.isAgreementFileUpload
        this.agreementDocsSize = strString.agreementDocsSize
        this.agreementDocs = strString.agreementDocs === undefined ? [] :  strString.agreementDocs
        this.isSelectedFileDeleted = strString.isSelectedFileDeleted
        this.other = strString.other
        this.perUnitPaymentOfWages = strString.perUnitPaymentOfWages
        this.numberOfUnits = strString.numberOfUnits
        this.pieceRateBegDate = strString.pieceRateBegDate
        this.pieceRateEndDate = strString.pieceRateEndDate
        this.pieceRateTotalEarned = strString.pieceRateTotalEarned
        this.pieceRateTotalPaid = strString.pieceRateTotalPaid
        this.ispieceRateEndDate = strString.ispieceRateEndDate
        this.isProvidePriceRate = strString.isProvidePriceRate
        this.paidPieceRateAdditional =  strString.paidPieceRateAdditional,
        this.promisedPieceRateAdditional = strString.promisedPieceRateAdditional,
        this.perUnitPaymentOfWagesAdditional =   strString.perUnitPaymentOfWagesAdditional,
        this.otherAdditional = strString.otherAdditional,
        this.numberOfUnitsAdditional = strString.numberOfUnitsAdditional,
        this.pieceRateBegDateAdditional = strString.pieceRateBegDateAdditional,
        this.pieceRateEndDateAdditional = strString.pieceRateEndDateAdditional,
        this.isPerUnitOtherAdditional  = strString.isPerUnitOtherAdditional
        this.isPerUnitOther = strString.isPerUnitOther
        this.isPieceOfRateClicked = strString.isPieceOfRateClicked,
        this.paymentOfWagesForGarmentDetails = strString.paymentOfWagesForGarmentDetails,
        this.paymentOfWagesForGarmentSectionValues = strString.paymentOfWagesForGarmentSectionValues,
        this.isOneHourlyAdditionalSection = strString.isOneHourlyAdditionalSection
        this.isDifferentHourAdditionalInfoSection = strString.isDifferentHourAdditionalInfoSection
        this.isSalaryRateAdditionalSection = strString.isSalaryRateAdditionalSection
        this.isPieceRateAdditionalSection = strString.isPieceRateAdditionalSection

        this.HourlyOptionValue = strString.HourlyOptionValue,
        this.pieceRateOptionValue = strString.pieceRateOptionValue,
        this.commissionRateOptionValue  = strString.commissionRateOptionValue,
        this.salaryRateOptionValue = strString.salaryRateOptionValue,
        this.differentHourOptionValue = strString.differentHourOptionValue,
        this.flag = strString.flag,
        this.contentVersionIds = strString.contentVersionIds
        this.totalUploadFiles = strString.totalUploadFiles === undefined ? [] : strString.totalUploadFiles
        
        console.log('pdifferentHourAddDetails >>>>>>>>>> ',JSON.stringify(strString.differentHourAdditionalDetails))
        this.handleDifferentAdditional(strString.differentHourAdditionalDetails, strString.renderDifferentHourAdditonalSection)
        this.handleHourlyAdditional(strString.hourlyAdditionalDetails, strString.renderOneHourlyAdditonalSection)
        this.handleSalaryRateAdditional(strString.salaryRateAdditionalDetails, strString.renderSalaryRateAdditonalSection)
        this.handlePieceRateAdditional(strString.pieceRateAdditionalDetails, strString.renderPieceRateAdditonalSection)
        
        

        this.isRenderedCallback = true
    }

    oneHourlyAdditionalData
    oneHourlyAdditionalSectionValues
    handleHourlyAdditional(oneHourlyAdditionalvalue, OneHourlyAdditionalCount){
        this.oneHourlyAdditionalData = oneHourlyAdditionalvalue
        this.oneHourlyAdditionalSectionValues = oneHourlyAdditionalvalue
        this.renderOneHourlyAdditonalSection.length = 0
        this.isOneHourlyAdditionalSection = true
                for(let i = 0;i < OneHourlyAdditionalCount.length;i++){
            this.isOneHourlyAdditionalSection = false
            this.renderOneHourlyAdditonalSection.push(OneHourlyAdditionalCount[i])
        }
        this.oneHourlyFlag = this.renderOneHourlyAdditonalSection.length
        this.isOneHourlyAdditionalSection = true
        this.isRenderDifferentHourAdd = true
    }

    //rendercallback 
    renderedCallback(){
        if(this.isRenderedCallback === true){
            const templateArray = this.template.querySelectorAll('c-owc-Multiple-File-Upload-Details-Cmp')
            for (let i = 0; i < templateArray.length; i++){
                if(templateArray[i].name === 'summaryDoc'){
                        templateArray[i].getDocInfos(this.commissionReciptDocs, this.isFormPreviewMode);
                }
                else if(templateArray[i].name === 'additionalDoc'){
                        templateArray[i].getDocInfos(this.agreementDocs, this.isFormPreviewMode);
                }
            }
        }

        if(this.isRenderedCallback === true && this.isFormPreviewMode === true){
            this.template.querySelector('c-owc-Payment-Of-Wages-Preview-Cmp').handlePreview(this.paymentWagesDetailPreview,this.isFormPreviewMode)
        }

        if(this.isRenderedCallback === true && this.isOneHourlyRate === true && this.isOneHourlyAdditionalSection === true){
            const hourlyAdditionalSectionDetails = this.template.querySelectorAll('c-owc-One-Hour-Additional-Cmp')
            console.log('hourlyAdditionalSectionDetails::',hourlyAdditionalSectionDetails.length)
            if(hourlyAdditionalSectionDetails.length > 0){
            for (var i = 0; i < hourlyAdditionalSectionDetails.length; i++){
                hourlyAdditionalSectionDetails[i].owcHourlyAdditionalFromForChild(this.oneHourlyAdditionalData[i],this.isFormPreviewMode)
            }
            this.isRenderhourlyAdd = false
            }
        }

        if(this.isHourlyAddSectionDeleted === true){
            const hourlyDetails = this.hourlyAddSectionDataAfterDelete
            console.log('hourlyDetails ::: ', JSON.stringify(hourlyDetails))
            const hourlyDetailsSectionDetails = this.template.querySelectorAll('c-owc-One-Hour-Additional-Cmp')
            for (var i = 0; i < hourlyDetailsSectionDetails.length; i++){
                hourlyDetailsSectionDetails[i].owcHourlyAdditionalFromForChild(this.hourlyAddSectionDataAfterDelete[i],this.isFormPreviewMode)
            }
        }

        if(this.isRenderedCallback === true && this.isDifferentHourRate === true && this.isRenderDifferentHourAdd === true){
            const differentHourAdditionalSectionDetails = this.template.querySelectorAll('c-Owc-Different-Hour-Rate-Additional')
            console.log('differentHourAdditionalSectionDetails::',differentHourAdditionalSectionDetails.length)
            for (let i = 0; i < differentHourAdditionalSectionDetails.length; i++){
                differentHourAdditionalSectionDetails[i].owcDifferentHourAdditionalFromForChild(this.differentHourAdditionaldata[i],this.isFormPreviewMode)
          
            this.isRenderDifferentHourAdd = false
            }
        }

        if(this.isDifferentHourAddSectionDeleted === true){
            const differentHourDetails = this.differentHourAddSectionDataAfterDelete
            const differentHourDetailsSectionDetails = this.template.querySelectorAll('c-Owc-Different-Hour-Rate-Additional')
            for (let i = 0; i < differentHourDetailsSectionDetails.length; i++){
                differentHourDetailsSectionDetails[i].owcDifferentHourAdditionalFromForChild(differentHourDetails[i])
            }
        }

        if(this.isRenderedCallback === true && this.isSalaryRateForEachDay === true && this.isSalaryRateAdditionalSection === true){
            const salaryRateAdditionalSectionDetails = this.template.querySelectorAll('c-owc-Salary-Rate-Additional-Cmp')
            console.log('salaryRateAdditionalSectionDetails::',salaryRateAdditionalSectionDetails.length)
            if(salaryRateAdditionalSectionDetails.length > 0){
            for (var i = 0; i < salaryRateAdditionalSectionDetails.length; i++){
                salaryRateAdditionalSectionDetails[i].owcSalaryRateAdditionalFromForChild(this.salaryRateAdditionaldata[i],this.isFormPreviewMode)
            }
            this.isRenderSalaryRateAdd = false
            }
        }

        if(this.isSalaryRateAddSectionDeleted === true){
            const salaryRateDetails = this.salaryRateAddSectionDataAfterDelete
            console.log('salaryRateDetails ::: ', JSON.stringify(salaryRateDetails))
            const salaryRateDetailsSectionDetails = this.template.querySelectorAll('c-owc-Salary-Rate-Additional-Cmp')
            for (var i = 0; i < salaryRateDetailsSectionDetails.length; i++){
                salaryRateDetailsSectionDetails[i].owcSalaryRateAdditionalFromForChild(this.salaryRateAddSectionDataAfterDelete[i])
            }
        }

        if(this.isRenderedCallback === true && this.isPieceRate === true && this.isPieceRateAdditionalSection === true){
            const pieceRateAdditionalSectionDetails = this.template.querySelectorAll('c-owc-Piece-Rate-Additional-Cmp')
            console.log('pieceRateAdditionalSectionDetails::',pieceRateAdditionalSectionDetails.length)
            if(pieceRateAdditionalSectionDetails.length > 0){
            for (var i = 0; i < pieceRateAdditionalSectionDetails.length; i++){
                pieceRateAdditionalSectionDetails[i].owcPieceRateAdditionalFromForChild(this.pieceRateAdditionaldata[i],this.isFormPreviewMode)
            }
            this.isRenderPieceRateAdd = false
            }
        }

        if(this.isPieceRateAddSectionDeleted === true){
            const pieceRateDetails = this.pieceRateAddSectionDataAfterDelete
            console.log('pieceRateDetails ::: ', JSON.stringify(pieceRateDetails))
            const pieceRateDetailsSectionDetails = this.template.querySelectorAll('c-owc-Piece-Rate-Additional-Cmp')
            for (var i = 0; i < pieceRateDetailsSectionDetails.length; i++){
                pieceRateDetailsSectionDetails[i].owcPieceRateAdditionalFromForChild(this.pieceRateAddSectionDataAfterDelete[i])
            }
        }
        
        if(this.value === null && this.isRenderedCallback === true ){
            this.template.querySelector('[data-id="empPaymentType"]').value = this.value
        }
            if(this.recRestPeriod === null  && this.isRenderedCallback === true && this.isPieceRate === true){
                this.template.querySelector('[data-id="recRestPeriod"]').value = this.recRestPeriod
            }
            if(this.paidSepartlyForRestPeriod === null  && this.isRenderedCallback === true && this.isRecRestPeriod === true){
                this.template.querySelector('[data-id="paidSepartlyForRestPeriod"]').value = this.paidSepartlyForRestPeriod
            }
            if(this.paidFrequencyOfEachDay === null  && this.isRenderedCallback === true && this.isSalaryRateForEachDay === true){
                this.template.querySelector('[data-id="paidFrequencyOfEachDayId"]').value = this.paidFrequencyOfEachDay 
            }
            if(this.frequencyOfEachDay === null  && this.isRenderedCallback === true && this.isSalaryRateForEachDay === true){
                this.template.querySelector('[data-id="frequencyOfEachDay"]').value = this.frequencyOfEachDay
            }
            if(this.frequencyOfEachDayAdditional === null  && this.isRenderedCallback === true && this.isEachPayClicked === true){
                this.template.querySelector('[data-id="frequencyOfEachDayAdditional"]').value = this.frequencyOfEachDayAdditional
            }
            
            
            if(this.writtenCommission === null  && this.isRenderedCallback === true && this.isCommissionRate === true){
                this.template.querySelector('[data-id="writtenCommission"]').value = this.writtenCommission
            }
            if(this.isPieceRate === true && this.isGrament === true  && this.isRenderedCallback === true && this.paymentOfWagesForGarmentSectionValues != undefined){
                this.template.querySelector('c-owc-payment-of-wages-for-garment-cmp').owcPaymentOfWagesForGarmentForChild(this.paymentOfWagesForGarmentSectionValues,this.isFormPreviewMode)
                    
            }
        this.isRenderedCallback = false
    } 

  
    //Validity checker method
    paymentOfWagesValidityChecker(ids, values){
        let id = ids
        let value = values
        console.log('Value:', value);
        const val = value == undefined || value == null ? '' : value
        if(val.trim() == ""){
            id.setCustomValidity(customLabelValues.OWC_required_field_error_msg);
            id.reportValidity();
            return true;
        } 
    }

    // @api fileData = []

    // calculateFileSize(files){
    //     let i,j;
  
    //         if(this.fileData.length>0){
    //             console.log('sdsds');
    //                     this.fileData.splice(0,this.fileData.length);
    //                     fileSize = 0;
    //         }
    //         console.log(this.fileData);
    //         for(i=0;i<files.length;i++){
    //                 this.fileData.push(files[i]);
    //         }
    //         console.log(this.fileData);
  
    //         for(j=0;j<parseInt(this.fileData.length);j++){
    //                 fileSize = fileSize+parseInt(JSON.stringify(JSON.parse(this.fileData[j].size)));
    //         }
    //         console.log('????');
    //         console.log(fileSize);
  
    // }
    
    // @api isFileInserted = false;
    // @track flag = 0;
    // handleAgreementUploadChange(event){
    //     this.calculateFileSize(event.target.files);
    //     if(fileSize<MAX_FILE_SIZE){
    //     let files = event.target.files;
    //     for(var i=0; i<files.length; i++){
    //         this.flag += 1;
    //         files[i].recordId = this.flag;
    //     }
    //     this.handleAgreementUpload(files);
    //     console.log('selecred fiels ::: ',files);
    //     if (files.length > 0) {
    //            let filesName = '';
 
    //            for (let i = 0; i < files.length; i++) {
    //                    let file = files[i];
 
    //                    filesName = filesName + file.name + ',';
 
    //                    var flag=this;
    //                    let freader = new FileReader();
    //                    console.log('freader');
    //                    freader.onload = f => {
                          
    //                        let base64 = 'base64,';
    //                        let content = freader.result.indexOf(base64) + base64.length;
    //                        let fileContents = freader.result.substring(content);    
    //                        flag.filesUploaded.push({
    //                            Title: file.name,
    //                            VersionData: fileContents
    //                        });
    //                    };
    //                    console.log(freader);
    //                    console.log(JSON.stringify(this.filesUploaded));
    //                  //  console.log('check',freader.readAsDataURL(file));
    //                    freader.readAsDataURL(file);
                      
    //            }
              
    //                this.fileNames = filesName.slice(0, -1);
 
    //    }
    //    }
    //    else{
    //        this.showToast('File Size Limit Exceeded','Upload files of size less than 20MB','error');
    //    }
    // }

    // @track contentVersionIds;
    // handleSaveFiles() {
    //     this.showLoadingSpinner = true;
    //     insertUploadedFiles({
    //         uploadedFiles : this.filesUploaded,
    //         contentVersionId : this.contentVersionIds
    //     })
    //     .then(data => {
    //         this.showLoadingSpinner = false;
    //         this.contentVersionIds = data;
    //         this.fileNames = undefined;
    //     })
    //     .catch(error => {
            
    //     });
    // }

    //Upload Document variables
    @api uploadFileSize;
    @api isFileUploaded = false
    @api toastFileUploadMsg = customLabelValues.OWC_fileupload_success_toast_msg
    @api toastFileDeleteMsg = customLabelValues.OWC_multiple_file_delete_toast_msg
    @api uploadUnionContractDocument
   
    
    handleCommissionReciptUpload(event) {
        // Get the list of uploaded files
        const uploadedCommissionFiles = event.detail.files;
        this.commissionReciptDocs = uploadedCommissionFiles;
        if(uploadedCommissionFiles != null){
            this.isCommissionReciptFileUpload = false;
            this.commissionReciptDocsSize = this.commissionReciptDocs.length;
            this.template.querySelector('[data-id="summaryDocId"]').getDocData(this.commissionReciptDocs);
            this.isRenderedCallback = false;
            this.showToast(customLabelValues.OWC_success_label,this.toastFileUploadMsg, 'success');
        }
        else{
            this.isCommissionReciptFileUpload = true
        }
    }
   
    handleCommissionReciptDocsUpload(event){
        console.log('event.detail:', JSON.stringify(event.detail));
        this.commissionReciptDocs = event.detail.uploadcontractdoc
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast(this.toastFileDeleteMsg) : ''
        this.commissionReciptDocsSize = this.commissionReciptDocs.length
    }


    @track contentVersionIds = []
    deleteExtraFiles(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            this.contentVersionIds.push(uploadedFiles[i].documentId);
        }
        deleteMultipleFiles({ contentVersionIds : JSON.stringify(this.contentVersionIds) })
           .then(result => {
               if(result){
                   
               }
           })
           .catch(error => {
               console.log('Error: ', error);
           })
    }

    @api get isFileUploadDisabled(){
        return this.agreementDocs.length >= 10 && this.isRenderedCallback === false;
    }

    @api totalUploadFiles = [];

    handleAgreementUpload(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        for(var i=0; i<uploadedFiles.length; i++){
            this.totalUploadFiles.push(uploadedFiles[i]);
        }
        if(this.totalUploadFiles.length <= 10){
            this.agreementDocs = uploadedFiles;
            if(uploadedFiles != null){
                this.isAgreementFileUpload = false;
                this.agreementDocsSize = this.agreementDocs.length;
                this.template.querySelector('[data-id="additionalDocId"]').getDocData(this.agreementDocs);
                this.isRenderedCallback = false;
                this.showToast(customLabelValues.OWC_success_label,this.toastFileUploadMsg,'success');
            }
            else{
                this.isAgreementFileUpload = true
            }
        }
        else{
            this.deleteExtraFiles(uploadedFiles);
            this.handleFileLimit(uploadedFiles);
            this.showToast('Error!', this.customLabelValues.OWC_file_size_error,'error');
        }
    }

    handleFileLimit(uploadedFiles){
        for(var i=0; i<uploadedFiles.length; i++){
            for(var j=0; j<this.totalUploadFiles.length; j++){
                if(uploadedFiles[i].documentId === this.totalUploadFiles[j].documentId){
                    this.totalUploadFiles.splice(j , 1)
                }
            }
        }
    }

    updateFileVariables(){
        if(this.agreementDocs !== undefined && this.agreementDocs.length > 0){
            this.totalUploadFiles.length = 0;
            this.totalUploadFiles = this.agreementDocs;
        }
    }
   
    handleAgreementDocsUpload(event){
        console.log('event.detail:', JSON.stringify(event.detail));
        this.agreementDocs = event.detail.uploadcontractdoc
        this.updateFileVariables();
        this.isSelectedFileDeleted = event.detail.isSelectedFileDeleted
        this.isSelectedFileDeleted === true ? this.showToast(customLabelValues.OWC_success_label,this.toastFileDeleteMsg,'success') : ''
        this.agreementDocsSize = this.agreementDocs.length
    }
   
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
   
    handleHelpText(event){
        const learnMoreName = event.target.name;
        if(learnMoreName === 'multiFileUploadHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_multiplefileupload_helptext;
        }
        else if(learnMoreName === "ProvideComissionRate"){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_payement_commission_agreement_helptext;
        }
        else if(learnMoreName === 'oneHourlyOptionsHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_one_hourly_rate_text;
        }
        else if(learnMoreName === 'differentHourlyOptionsHelpText'){
            this.isHelpText = true;
            this.helpText = customLabelValues.OWC_different_hourly_rate_text;
        }
        
    }
  
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        console.log('helpTextValue:', JSON.stringify(helpTextValue));
        this.isHelpText = helpTextValue.isClosedHelpText
    }





    // handlePaymentOfWagesForGarmentSectionEvent(event){
    //     const paymentOfWagesForGarmentSectionValues = event.detail
    //     this.paymentOfWagesForGarmentSectionValues = paymentOfWagesForGarmentSectionValues
    //     console.log('paymentOfWagesForGarmentSectionValues ::: ', JSON.stringify(paymentOfWagesForGarmentSectionValues));
    // }

    // handlePaymentOfWagesForGramentSectionValidity(event){
    //     const currentStep = event.detail.currentStep
    //     console.log('handlePaymentOfWagesForGramentSectionValidity ::::: ', currentStep)
    //     this.isNotChangedCurrentStep = currentStep
    //     console.log('isNotChangedCurrentStep ::: ', this.isNotChangedCurrentStep)
    // }   
}