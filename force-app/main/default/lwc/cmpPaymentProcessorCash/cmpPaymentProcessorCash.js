/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 17-08-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   12-07-2022   Kev Cadger (Wipro)   Initial Version
 **/
// * LWC Imports
import { LightningElement, api } from "lwc";
// * Apex Imports
import processPayment from "@salesforce/apex/PaymentProcessorController.processPaymentCash";

export default class CmpPaymentProcessor_Cash extends LightningElement {
  // * Component Properies
  // * * Public
  @api amount = 0;
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
        // TODO Check when this happens.
        console.error(`Processor - Cash\nError: ${error}`);
        this.paymentDetails.error = error;
      })
      .finally(() => {
        this.dispatchPaymentProcessed();
      });
  }

  // * Callback Functions

  renderedCallback() {
    this.dispatchPaymentDetailValidityUpdate();
  }

  // * Event Dispatchers

  dispatchPaymentProcessed() {
    this.dispatchEvent(
      new CustomEvent("paymentprocessed", {
        detail: this.paymentDetails
      })
    );
  }

  dispatchPaymentDetailValidityUpdate() {
    // Dispatch the card updated event.
    this.dispatchEvent(
      new CustomEvent("paymentdetailvalidityupdate", {
        detail: {"valid": true}
      })
    );
  }
}