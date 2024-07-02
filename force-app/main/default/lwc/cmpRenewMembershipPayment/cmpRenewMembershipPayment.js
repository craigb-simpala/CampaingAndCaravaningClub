import {LightningElement, api, wire} from 'lwc';
import getPaymentOptions from "@salesforce/apex/RenewMembershipPaymentController.getPaymentOptions";
import createLead from "@salesforce/apex/RenewMembershipPaymentController.createLead";


export default class RenewMembershipPayment extends LightningElement {

    @api totalCostString;
    @api totalCost;
    @api recordId;
    @api membershipCode;
    @api leadToUpdate;
    @api closeDate;

    displaySpinner;
    paymentMethods;


    connectedCallback() {
        this.totalCost = Number(this.totalCostString);
    }

    @wire(getPaymentOptions, { membershipCodes: '$membershipCode'})
    getMemberShipRecord({ error, data }) {
        if (data) {

            let paymentMethods = data;

            // Renewal Payments cannot be made via Direct Debit from  this form
            if(this.isOpportunityCloseDateMonthAgo && paymentMethods.includes("Direct Debit")) {
                paymentMethods = paymentMethods.filter(thisPaymentMethod => thisPaymentMethod !== "Direct Debit");
            }

            this.paymentMethods = paymentMethods;

        } else if(error) {
            alert(error.body.message);
        }
    }

    isOpportunityCloseDateMonthAgo() {
        let closeDate = Date.parse(this.closeDate);

        let today = new Date();
        let todayMinus30Days = new Date();

        todayMinus30Days.setDate(today.getDate() - 30);

        return closeDate > todayMinus30Days;
    }

    async handleSuccessfulPayment(event) {

        if(event.detail.paymentDetails.token) {
            this.displaySpinner = true;

            const leadToCreate = {...this.leadToUpdate};
            leadToCreate.Payment_Method__c = event.detail.paymentDetails.method;

            if(leadToCreate.Payment_Method__c === 'Direct Debit') {
                leadToCreate.Bank_Account_Name__c = event.detail.directDebitDetails.holder;
                leadToCreate.Bank_Account_Number__c = event.detail.directDebitDetails.number.replaceAll('-', '');
                leadToCreate.Sort_Code__c = event.detail.directDebitDetails.sortCode.replaceAll('-', '');
            }

            const leadId = await createLead({leadJson: JSON.stringify(leadToCreate)});

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

        const leadToCreate = {...this.leadToUpdate};
        leadToCreate.Payment_Method__c = 'Direct Debit';

        const leadId = await createLead({leadJson: JSON.stringify(leadToCreate)});

        window.location.href = '/apex/PaymentSuccess?ref=' + leadId + '&result=SUCCESS';
    }

    cancel() {
        window.location.href = '/' + this.recordId;
    }
}