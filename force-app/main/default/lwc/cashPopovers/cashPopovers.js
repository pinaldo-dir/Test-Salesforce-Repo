import { LightningElement, api, track } from 'lwc';

export default class CashDevBoxPopover extends LightningElement {
    @track caseId;
    @track caseStatus;
    @track caseEmployerUrl;
    @track caseEmployerName;
    @track caseAssignedDeputyUrl;
    @track caseAssignedDeputyName;
    @track caseDirOfficeUrl;
    @track caseDirOfficeName;
    
    @track ciId;
    @track ciAssessmentDescription;
    @track ciStatus;
    
    @track jId;
    @track jType;
    @track jCourtName;
    @track jCourtUrl;
    @track jCourtCaseNumber;
    @track jPartyName;
    @track jPartyUrl;
    
    @track top = 50;
    @track left = 50;
    
    @api
    get pocaseid(){
        return this.caseId;
    }
    set pocaseid(value) {
        this.caseId = value;
    }

    @api
    get pocasedirofficeurl(){
        return this.caseDirOfficeUrl;
    }
    set pocasedirofficeurl(value){
        this.caseDirOfficeUrl = value;
    }

    @api
    get pocasedirofficename(){
        return this.caseDirOfficeName;
    }
    set pocasedirofficename(value){
        this.caseDirOfficeName = value;
    }

    @api
    get pocaseassigneddeputyurl(){
        return this.caseAssignedDeputyUrl;
    }
    set pocaseassigneddeputyurl(value){
        this.caseAssignedDeputyUrl = value;
    }

    @api
    get pocaseassigneddeputyname(){
        return this.caseAssignedDeputyName;
    }
    set pocaseassigneddeputyname(value){
        this.caseAssignedDeputyName = value;
    }
    
    @api
    get pocasestatus(){
        return this.caseStatus;
    }
    set pocasestatus(value){
        this.caseStatus = value;
    }

    @api
    get pocaseemployerurl(){
        return this.popupcaseemployerurl;
    }
    set pocaseemployerurl(value){
        this.caseEmployerUrl = value;
    }

    @api
    get pocaseemployername(){
        return this.caseEmployerName;
    }
    set pocaseemployername(value){
        this.caseEmployerName = value;
    }

    @api
    get pociid(){
        return this.ciId;
    }
    set pociid(value){
        this.ciId = value;
    }

    @api
    get pociassessmentdescription(){
        return this.ciAssessmentDescription;
    }
    set pociassessmentdescription(value){
        this.ciAssessmentDescription = value;
    }

    @api
    get pocistatus(){
        return this.ciStatus;
    }
    set pocistatus(value){
        this.ciStatus = value;
    }

    @api
    get pojid(){
        return this.jId;
    }
    set pojid(value){
        this.jId = value;
    }

    @api
    get pojtype(){
        return this.jType;
    }
    set pojtype(value){
        this.jType = value;
    }

    @api
    get pojcourtname(){
        return this.jCourtName;
    }
    set pojcourtname(value){
        this.jCourtName = value;
    }

    @api
    get pojcourturl(){
        return this.jCourtUrl;
    }
    set pojcourturl(value){
        this.jCourtUrl = value;
    }

    @api
    get pojcourtcasenumber(){
        return this.jCourtCaseNumber;
    }
    set pojcourtcasenumber(value){
        this.jCourtCaseNumber = value;
    }

    @api
    get pojpartyname(){
        return this.jPartyName;
    }
    set pojpartyname(value){
        this.jPartyName = value;
    }

    @api
    get pojpartyurl(){
        return this.jPartyUrl;
    }
    set pojpartyurl(value){
        this.jPartyUrl = value;
    }


    @api
    get topmargin(){
        return this.top;
    }
    set topmargin(value) {
        this.top = value;
    }

    @api
    get leftmargin(){
        return this.left;
    }
    set leftmargin(value) {
        this.left = value;
    }

    @api // TODO: Does this need to be api?
    get poStyle() { 
        /* return `top:${this.top}px; left:${this.left}px; z-index:5; width:fit-content; background-color:white; border:2px solid #f3f3f3`; */
        return `top:${this.top}px; left:${this.left}px; z-index:5; max-width:350px; background-color:white; border:2px solid #f3f3f3`;
    }

    @api // TODO: Does this need to be api?
    get poClass() {
        return `slds-is-absolute slds-popover slds-popover_panel slds-box slds-nubbin_left-top-corner`;
    }
}