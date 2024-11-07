import { LightningElement,api, track,wire } from 'lwc';
import { customLabelValues} from 'c/owcUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOWCPreliminaryMetaData from '@salesforce/apex/OwcPreliminarySectionController.getOWCPreliminaryMetaData'
import { loadStyle } from 'lightning/platformResourceLoader';  // Run time style loader
import OWCStyleSheet from '@salesforce/resourceUrl/OWCStyleSheet';  // Import static resource

export default class OwcOnlineDemographicCmp extends LightningElement {

    @track genderOptions
    @track raceOptions
    @track ethnicOriginOptions
    @track ethnicityOptions
    @track sexualOrientationOptions

    //Varaibles 
    @track isRenderedCallback = false
    @track DemographicGenderIdentity
    @track DemographicSexualOrientation
    @track DemographicRace
    @track DemographicEthnicity
    @track DemographicEthnicOrigin

    @track OnlineDemographicDetails
    @track isFormPreviewMode = false

    @track GenderOther
    @track SexualOrientationOther
    @track DemographicRaceOther
    @track DemographicEthnicOriginOther

    @track isGenderOther = false
    @track isSexualOrientationOther = false
    @track isDemographicRaceOther = false
    @track isDemographicEthnicOriginOther = false


    @api isHelpText = false;
    @api helpText;
    //custom labels
    customLabelValues = customLabelValues;

    //Connected Callback
    connectedCallback(){
        // don’t forget to load static resources in connectedCallback . 
        Promise.all([ loadStyle(this, OWCStyleSheet ) ])
        .then(() => {
            console.log( 'Files loaded' );
        })
        .catch(error => {
            this.showToast('Error!', error.body.message, 'error');
            console.log( error.body.message );
    });
    }

    //Wire  for fetching the metadata
    @wire(getOWCPreliminaryMetaData)
    getOWCPreliminaryMetaData({ data,error}) {
            if(data){
                console.log('data::',data)
                console.log('genderOptions::',data[0].owcDemographicGenderOptions)
                this.genderOptions = data[0].owcDemographicGenderOptions;

                console.log('raceOptions::',data[0].owcDemographicRaceOptions)
                this.raceOptions = data[0].owcDemographicRaceOptions;

                console.log('ethnicOriginOptions::',data[0].owcDemographicEthnicOriginOptions)
                this.ethnicOriginOptions = data[0].owcDemographicEthnicOriginOptions;

                console.log('ethnicityOptions::',data[0].owcDemographicEthnicityOptions)
                this.ethnicityOptions = data[0].owcDemographicEthnicityOptions;

                console.log('sexualOrientationOptions::',data[0].owcDemographicSexualOrientationOptions)
                this.sexualOrientationOptions = data[0].owcDemographicSexualOrientationOptions;
            }else{
                this.errorMsg = error;
            }
    } 

    /**sort(function (a, b) {
                    return a.label - b.label;
                  }); */

    //Handle Change
    handleChange(event){
        event.preventDefault();
        this.isRenderedCallback = false
        switch ( event.target.name ) { 
            case "DemographicGenderIdentity":
                this.DemographicGenderIdentity = event.target.value
                console.log('DemographicGenderIdentity::',this.DemographicGenderIdentity);
                if(this.DemographicGenderIdentity === 'Other'){
                    this.isGenderOther = true;
                    this.GenderOther = ''
                }else{
                    this.isGenderOther = false;
                    this.GenderOther = ''
                } 
            break ;
            case "DemographicSexualOrientation":
                this.DemographicSexualOrientation = event.target.value
                console.log('DemographicSexualOrientation::',this.DemographicSexualOrientation);
                if(this.DemographicSexualOrientation === 'Other'){
                    this.isSexualOrientationOther = true;
                    this.SexualOrientationOther = ''
                }else{
                    this.isSexualOrientationOther = false;
                    this.SexualOrientationOther = ''
                }  
            break ;
            case "DemographicRace":
                this.DemographicRace = event.target.value
                console.log('DemographicRace::',this.DemographicRace); 
                if(this.DemographicRace === 'Other'){
                    this.isDemographicRaceOther = true;
                    this.DemographicRaceOther = ''
                }else{
                    this.isDemographicRaceOther = false;
                    this.DemographicRaceOther = ''
                } 
            break ;
            case "DemographicEthnicity":
                this.DemographicEthnicity = event.target.value
                console.log('DemographicEthnicity::',this.DemographicEthnicity); 
            break ;
            case "DemographicEthnicOrigin":
                this.DemographicEthnicOrigin = event.target.value
                console.log('DemographicEthnicOrigin::',this.DemographicEthnicOrigin); 
                if((this.DemographicEthnicOrigin === 'Other') || (this.DemographicEthnicOrigin === 'Other African')
                || (this.DemographicEthnicOrigin === 'Other Asian')  || (this.DemographicEthnicOrigin === 'Other Caribbean')
                || (this.DemographicEthnicOrigin === 'Other European')  || (this.DemographicEthnicOrigin === 'Other Hispanic/Latino')
                || (this.DemographicEthnicOrigin === 'Other Middle Eastern') ){
                    this.isDemographicEthnicOriginOther = true;
                    this.DemographicEthnicOriginOther = ''
                }else{
                    this.isDemographicEthnicOriginOther = false;
                    this.DemographicEthnicOriginOther = ''
                } 
            break ; 
            case "GenderOther":
                this.GenderOther = event.target.value
                console.log('GenderOther::',this.GenderOther); 
            break ;
            case "SexualOrientationOther":
                this.SexualOrientationOther = event.target.value
                console.log('SexualOrientationOther::',this.SexualOrientationOther); 
            break ;
            case "DemographicRaceOther":
                this.DemographicRaceOther = event.target.value
                console.log('DemographicRaceOther::',this.DemographicRaceOther); 
            break ;
            case "DemographicEthnicOriginOther":
                this.DemographicEthnicOriginOther = event.target.value
                console.log('DemographicEthnicOriginOther::',this.DemographicEthnicOriginOther); 
            break ;                  
        }       
            
    }

    //Custom event
    handleOnlineDemographicEvent(){  
        const selectEvent = new CustomEvent('onlinedemographiccustomevent', {
            detail: {
                DemographicGenderIdentity : this.DemographicGenderIdentity,
                DemographicSexualOrientation : this.DemographicSexualOrientation,
                DemographicRace : this.DemographicRace,
                DemographicEthnicity : this.DemographicEthnicity,
                DemographicEthnicOrigin : this.DemographicEthnicOrigin,
                GenderOther : this.GenderOther,
                SexualOrientationOther : this.SexualOrientationOther,
                DemographicRaceOther : this.DemographicRaceOther,
                DemographicEthnicOriginOther : this.DemographicEthnicOriginOther,
                isGenderOther : this.isGenderOther,
                isSexualOrientationOther : this.isSexualOrientationOther,
                isDemographicRaceOther : this.isDemographicRaceOther,
                isDemographicEthnicOriginOther : this.isDemographicEthnicOriginOther,
            }
        });
        this.dispatchEvent(selectEvent);
    }  

    @api
    owcOnlineDemographicForParent(){
        this.handleOnlineDemographicEvent();
    }

    @api
    owcOnlineDemographicForChild(strString,isFormPreviewMode){
        console.log('Details ::: ',JSON.stringify(strString))
        this.OnlineDemographicDetails = strString
        this.isFormPreviewMode = isFormPreviewMode

        if(isNaN(strString.DemographicGenderIdentity)){
            this.template.querySelector('[data-id="DemographicGenderIdentity"]').value = strString.DemographicGenderIdentity
            this.DemographicGenderIdentity = strString.DemographicGenderIdentity
        }
        if(isNaN(strString.DemographicSexualOrientation)){
            this.template.querySelector('[data-id="DemographicSexualOrientation"]').value = strString.DemographicSexualOrientation
            this.DemographicSexualOrientation = strString.DemographicSexualOrientation
        }
        if(isNaN(strString.DemographicRace)){
            this.template.querySelector('[data-id="DemographicRace"]').value = strString.DemographicRace
            this.DemographicRace = strString.DemographicRace
        }
        // if(isNaN(strString.DemographicEthnicity)){
        //     this.template.querySelector('[data-id="DemographicEthnicity"]').value = strString.DemographicEthnicity
        //     this.DemographicEthnicity = strString.DemographicEthnicity
        // }
        // if(isNaN(strString.DemographicEthnicOrigin)){
        //     this.template.querySelector('[data-id="DemographicEthnicOrigin"]').value = strString.DemographicEthnicOrigin
        //     this.DemographicEthnicOrigin = strString.DemographicEthnicOrigin
        // }
        this.GenderOther = strString.GenderOther
        this.SexualOrientationOther = strString.SexualOrientationOther
        this.DemographicRaceOther = strString.DemographicRaceOther
        this.DemographicEthnicOriginOther = strString.DemographicEthnicOriginOther 

        this.isGenderOther = strString.isGenderOther
        this.isSexualOrientationOther = strString.isSexualOrientationOther
        this.isDemographicRaceOther = strString.isDemographicRaceOther
        this.isDemographicEthnicOriginOther = strString.isDemographicEthnicOriginOther 

        this.isRenderedCallback = true
    }

    //Draft method
    handleSaveAsDraft(){
        this.handleOnlineDemographicEvent();
        const validateEvent = new CustomEvent('owcdraftversionevent', {
            detail: {
                isSaveAsDraft : true,
                sectionId : "12"
            }
        });
        this.dispatchEvent(validateEvent);
    }


    // Toast msg
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    @api isDemograhicText = false;
    @api isRaceDemograhicText = false;

    handleHelpText(event){
        const learnMoreName = event.target.name;
        this.isHelpText = true;
         if(learnMoreName === 'demoGraphicInstruction'){
            this.isHelpText = true;
            this.isDemograhicText = true;
            this.isRaceDemograhicText = false;
            this.helpText = this.customLabelValues.OWC_workweek_helptext;
        }
        else if(learnMoreName === 'raceAndEthinicityHelptext'){
            this.isHelpText = true;
            this.isRaceDemograhicText = true;
            this.isDemograhicText = false;
            this.helpText = this.customLabelValues.OWC_workweek_helptext;
        }
        else{
            this.isDemograhicText = false;
            this.isRaceDemograhicText = false;
        }
    }

    // Handle Help text Event
    handleHelpTextEvent(event){
        const helpTextValue = event.detail;
        this.isHelpText = helpTextValue.isClosedHelpText
    }
}