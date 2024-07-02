/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 12-07-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   12-07-2022   Kev Cadger (Wipro)   Initial Version
 **/
// * LWC Imports
import { LightningElement, api } from "lwc";
// * Apex Imports
import processPayment from "@salesforce/apex/PaymentProcessorController.processPaymentDirectDebit";
import { updateRecord } from "lightning/uiRecordApi";

export default class CmpPaymentProcessorDebit extends LightningElement {
  // * Component Properies
  // * * Public
  @api amount = 0;
  @api recordId = null;
  @api source;
  // * * Private
  paymentDetails = null;

  // * Apex Functions

  @api
  process() {
    // Call the process payment method.
    processPayment({})
      .then((results) => {
        this.paymentDetails = results;
      })
      .catch((error) => {
        console.error(`Error: ${error}`);
        this.paymentDetails.error = error;
      })
      .finally(() => {
        this.dispatchPaymentProcessed();
      });
  }

  // * Event Dispatchers

  dispatchPaymentProcessed() {
    this.dispatchEvent(
      new CustomEvent("paymentprocessed", {
        detail: this.paymentDetails
      })
    );
  }

  dispatchPaymentDetailValidityUpdate(valid) {
    // Dispatch the card updated event.
    this.dispatchEvent(
      new CustomEvent("paymentdetailvalidityupdate", {
        detail: valid
      })
    );
  }

  // * Event (Custom) Handlers

  handleDetailsValidated(event) {
    this.account = JSON.parse(JSON.stringify(event.detail));

    // Update the lead record.
    updateRecord({
      apiName: "Lead",
      fields: {
        Id: this.recordId,
        Bank_Account_Name__c: this.account.holder,
        Bank_Account_Number__c: this.account.Number,
        Sort_Code__c: this.account.sortCode
      }
    });

    this.dispatchPaymentDetailValidityUpdate(this.account);
  }
}