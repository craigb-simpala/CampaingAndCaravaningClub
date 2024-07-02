import {wire, LightningElement, track} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {getRecord} from 'lightning/uiRecordApi';
import {CloseActionScreenEvent} from 'lightning/actions';


import MEMBERSHIP_STATUS_FIELD from "@salesforce/schema/Account.Membership_Status__c";
import getMembershipInfo from "@salesforce/apex/ReinstatePaymentController.getMembershipInfo";
import createLead from "@salesforce/apex/ReinstatePaymentController.createLead";
import {ShowToastEvent} from "lightning/platformShowToastEvent";


const FIELDS = [
    MEMBERSHIP_STATUS_FIELD
];

export default class CmpReinstatePayment extends LightningElement {

    recordId;
    displayInitSpinner = true;
    displaySpinner = false;
    displayErrorBlock = false;
    errorMessage;

    membershipInfo;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    async connectedCallback() {
        this.membershipInfo = await getMembershipInfo({recordId: this.recordId});
        this.displayInitSpinner = false;
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    getMemberShipRecord({ error, data }) {
        if (data) {
            const membershipStatus = data.fields.Membership_Status__c.value;

            if (membershipStatus !== 'Lapsed' && membershipStatus !== 'Ex-Member' &&
                membershipStatus !== 'Non-Renewer' && membershipStatus !== 'Cancelled') {
                this.displayErrorBlock = true;
                this.errorMessage = 'This Membership has not been cancelled';
            }
        }
    }

    async handleSuccessfulPayment(event) {

        if(event.detail.paymentDetails.token) {
            this.displaySpinner = true;

            const leadToCreate = {...this.membershipInfo.lead};

            leadToCreate.Payment_Method__c = event.detail.paymentDetails.method;

            if(leadToCreate.Payment_Method__c === 'Direct Debit') {
                leadToCreate.Bank_Account_Name__c = event.detail.directDebitDetails.holder;
                leadToCreate.Bank_Account_Number__c = event.detail.directDebitDetails.number.replaceAll('-', '');
                leadToCreate.Sort_Code__c = event.detail.directDebitDetails.sortCode.replaceAll('-', '');
            }

            let leadId;

            try {
                leadId = await createLead({leadJson: JSON.stringify(leadToCreate)});
            } catch (error) {
                this.displaySpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                return;
            }

            window.location.href = '/apex/PaymentSuccess?ref=' + leadId + '&tokenid=' + event.detail.paymentDetails.token + '&result=SUCCESS';
        }
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}