import {LightningElement, api, wire} from 'lwc';
import getPaymentOptions from "@salesforce/apex/ChangeMembershipPaymentController.getPaymentOptions";
import updateLead from "@salesforce/apex/ChangeMembershipPaymentController.updateLead";

export default class CmpChangeMembershipPayment extends LightningElement {

    @api totalCostString;
    @api totalCost;
    @api accountId;
    @api leadId;
    @api membershipCode;

    displaySpinner;
    paymentMethods;

    connectedCallback() {
        this.totalCost = Number(this.totalCostString);
    }

    @wire(getPaymentOptions, { membershipCodes: '$membershipCode'})
    getMemberShipRecord({ error, data }) {
        if (data) {

            let paymentMethods = data;
            this.paymentMethods = paymentMethods;

        } else if(error) {
            alert(error.body.message);
        }
    }

    async handleSuccessfulPayment(event) {

        if(event.detail.paymentDetails.token) {
            this.displaySpinner = true;

            const leadToUpdate = {
                Id: this.leadId,
                Payment_Method__c: event.detail.paymentDetails.method
            };

            if(leadToUpdate.Payment_Method__c === 'Direct Debit') {
                leadToUpdate.Bank_Account_Name__c = event.detail.directDebitDetails.holder;
                leadToUpdate.Bank_Account_Number__c = event.detail.directDebitDetails.number.replaceAll('-', '');
                leadToUpdate.Sort_Code__c = event.detail.directDebitDetails.sortCode.replaceAll('-', '');
            }

            const leadId = await updateLead({leadJson: JSON.stringify(leadToUpdate)});

            window.location.href = '/apex/PaymentSuccess?ref=' + leadId + '&tokenid=' + event.detail.paymentDetails.token + '&result=SUCCESS';
        }
    }

    get displayNegativeCostError() {

        if(this.totalCost == 0) {
            return true;
        }
    }

    get displayPaymentBlock() {
        return !this.displayNegativeCostError;
    }

    async submit() {
        this.displaySpinner = true;

        const leadToUpdate = {
            Id: this.leadId,
            Payment_Method__c: "Cash/Cheque"
        };

        const leadId = await updateLead({leadJson: JSON.stringify(leadToUpdate)});
        window.location.href = '/apex/PaymentSuccess?ref=' + leadId + '&result=SUCCESS';
    }

    cancel() {
        window.location.href = '/' + this.recordId;
    }
}