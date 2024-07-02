/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 17-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   11-07-2022   Kev Cadger (Wipro)   Initial Version
 **/
// * LWC Imports
import {LightningElement, api, track, wire} from "lwc";
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {getRecord} from "lightning/uiRecordApi";
import processMembership from "@salesforce/apex/PaymentProcessorController.processMembership";

export default class CmpPaymentProcessor extends NavigationMixin(
    LightningElement
) {
    // * Component Properties
    // * * Public
    @api recordId = null;
    @api source = null;
    @api paymentMethods = [];
    @api amount = 0;
    // * * Private
    isLoading = false;
    // amount = 0;
    @track paymentDetails = {
        method: "",
        token: null,
        valid: false
    };

    directDebitDetails = {
        bank: "",
        holder: "",
        number: "",
        sortCode: "",
        valid: true,
    }

    @wire(getRecord, {recordId: "$recordId", fields: ["Lead.Amount__c"]})
    leadRecord({data, error}) {
        if (data) {
            this.amount = data.fields.Amount__c.value;
        } else if (error) {
            // console.error(`Lead not found: ${error}`);
        }
    }

    // * Apex Functions

    processMembership() {
        this.switchLoading();

        processMembership({
            recordId: this.recordId,
            paymentMethod: this.paymentDetails.method,
            paymentToken: this.paymentDetails.token,
            amount: this.amount
        })
            .then((result) => {
                this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                        actionName: "view",
                        recordId: result
                    }
                });
            })
            .catch((error) => {
                this.switchLoading();
                console.error(error);
                this.dispatchToastMessage(
                    "Membership Processing Failed",
                    error.body.message,
                    "error"
                );
            });
    }

    // * Event Dispatchers

    dispatchToastMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    // * Event Handlers

    handleChange_Amount(event) {
        // Set the amount.
        this.amount = parseFloat(event.target.value);
    }

    handleChange_Method(event) {
        this.switchLoading();

        // Set the method type.
        this.paymentDetails.method = event.target.value;
        this.paymentDetails.valid = false;

        this.switchLoading();
    }

    handleClick_Process(event) {
        this.switchLoading();

        let component = null;

        if (this.displayCard) {
            component = this.template
                .querySelector("c-cmp-payment-processor-card")
                .process();
        } else if (this.displayCash) {
            component = this.template
                .querySelector("c-cmp-payment-processor-cash")
                .process();
            this.paymentDetails.valid = true;
        } else if (this.displayDebit) {
            component = this.template
                .querySelector("c-cmp-payment-processor-debit")
                .process();
        }

        if (component) component.process();
    }

    // * Event (Custom) Handlers

    handlePaymentProcessed(event) {
        console.log("-cmpPaymentProcessor-");

        this.paymentDetails.token = event.detail.token;

        this.switchLoading();

        if(this.source == "Renew" || this.source == "ChangeMembership" || this.source == "ChangeAssociateMemberSectionsPayment") {
            this.template.querySelector('c-cmp-toast').showToast(
                event.detail.title,
                event.detail.message,
                event.detail.variant,
            );
        } else {
            this.dispatchToastMessage(
                event.detail.title,
                event.detail.message,
                event.detail.variant
            );
        }
        if (this.paymentDetails.token) {

            if(this.source == "Renew" || this.source == "Reinstate" || this.source == "ChangeMembership" || this.source == "ChangeAssociateMemberSectionsPayment") {
                this.dispatchEvent(new CustomEvent('successfulpayment', {detail: {paymentDetails: this.paymentDetails, directDebitDetails: this.directDebitDetails}}));
            } else {
                this.processMembership();
            }
        }
    }

    handlePaymentDetailValidityUpdate(event) {

        // Set the payment details are valid.
        this.paymentDetails.valid = event.detail.valid;

        // Set the payment details are valid.
        this.directDebitDetails.bank = event.detail.bank;
        this.directDebitDetails.holder = event.detail.holder;
        this.directDebitDetails.number = event.detail.number;
        this.directDebitDetails.sortCode = event.detail.sortCode;
        this.directDebitDetails.valid = event.detail.valid;
    }

    handleHidePaymentButton() {
        this.paymentDetails.valid = false;
    }

    // * Template Functions

    get displayCard() {
        return this.paymentDetails.method === "Debit/Credit Card";
    }

    get displayCash() {
        return this.paymentDetails.method === "Cash/Cheque";
    }

    get displayDebit() {
        return this.paymentDetails.method === "Direct Debit";
    }

    get displayProcessPaymentButton() {
        return this.paymentDetails.method !== "" && this.paymentDetails.valid;
    }

    get amountReadOnly() {
        return (this.source === "Renew" || this.source === "ChangeMembership" || this.source === "ChangeAssociateMemberSectionsPayment");
    }

    get getMethods() {
        let paymentMethods = [];

        if((this.source === "Renew" || this.source === "ChangeMembership") && this.paymentMethods) {
            this.paymentMethods.forEach(element => {
                paymentMethods.push({label: element, value: element})
            });
        } else if(this.source === "ChangeAssociateMemberSectionsPayment" && this.paymentMethods) {
            paymentMethods.push({label: "Debit/Credit Card", value: "Debit/Credit Card"});
            paymentMethods.push({label: "Cash/Cheque", value: "Cash/Cheque"});
        } else {
            paymentMethods.push({label: "Debit/Credit Card", value: "Debit/Credit Card"});
            paymentMethods.push({label: "Cash/Cheque", value: "Cash/Cheque"});
            paymentMethods.push({label: "Direct Debit", value: "Direct Debit"});
        }

        return paymentMethods;
    }

    switchLoading() {
        this.isLoading = !this.isLoading;
    }
}