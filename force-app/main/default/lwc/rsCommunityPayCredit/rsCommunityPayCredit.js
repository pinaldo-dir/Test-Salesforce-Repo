import { LightningElement, track, wire, api } from 'lwc';
import getPaymentConfirm from '@salesforce/apex/RsCommunityPayCreditConfirm.getPaymentConfirm';
import { NavigationMixin  } from 'lightning/navigation';
import cancelButton from '@salesforce/apex/RsCommunityPayCreditConfirm.cancelButton';


export default class RsCommunityPayCredit extends NavigationMixin(LightningElement) {

    @track contacts;
    @track error;
    @track result;
    @track boolVisible = false;
    @track displayResults = '';
    disabled = false; 


    handleBack() {

        //Get the Chargent Order Id from the URL
        var passRecordId = location.search.match(/recordId=([^&]*)/i)[1];
        var urlBack = '/community-pay-credit?recordId=' + passRecordId;

        //Navigate to previous page
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: urlBack
                        }
        });
    }

    handleCancel() {

        //Get the Chargent Order Id from the URL
        var passRecordId = location.search.match(/recordId=([^&]*)/i)[1];

        //Update registration status to pending payment.
        cancelButton({coId: passRecordId}) 
            .then(result => {
                console.log('result: ', result);
            })
            .catch(error => {
                console.log('error: ', error);
            });

        //Navigate to dashboard page
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/'
                        }
        });
    }

    handleNext() {

        this.disabled = true;
        this.boolVisible = true;

        var passRecordId = location.search.match(/recordId=([^&]*)/i)[1];
        console.log('passRecordId: '+passRecordId);
           
        getPaymentConfirm({coId: passRecordId}) 
            .then(result => {

                console.log('result: ', result);
                this.boolVisible = false;

                if (result == '') {

                    //Navigate to Registration dashboard page
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: '/community-pay-after-submission/'
                                    }
                    });
                } else {

                    this.disabled = false;
                    this.displayResults = result;
                }

            })
            .catch(error => {
                console.log('error: ', error);
            });
            
    }
}