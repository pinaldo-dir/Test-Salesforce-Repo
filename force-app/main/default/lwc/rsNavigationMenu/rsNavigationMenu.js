import { LightningElement, api,wire} from 'lwc';
import RS_dashboard_label from '@salesforce/label/c.RS_dashboard_label';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { CurrentPageReference } from 'lightning/navigation';
import pubsub from 'c/pubsub';
import communityBasePath from '@salesforce/community/basePath';
 
export default class rsNavigationMenu extends LightningElement {

    @api selectedItem;
      //  @wire(CurrentPageReference) pageRef;

     label = {
        RS_dashboard_label
    };

    @api communityBasePath = communityBasePath

    handleDasboardClick(event){
        window.open(this.communityBasePath, '_self');
    }

    @api isLargeDevice = false;
    @api isMediumDevice = false;
    @api isSmallDevice = false;
  
    connectedCallback() {
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
    }

 handleSelect(event){

     this.selectedItem = event.detail.value;
     pubsub.fire('selectedmenuitem', this.selectedItem );

            
 }
}