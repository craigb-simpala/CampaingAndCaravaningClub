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
import { LightningElement, api, track } from "lwc";
// import { getRecord } from 'lightning/uiRecordApi';
// * Apex Imports * //
import processPayment from "@salesforce/apex/PaymentProcessorController.processPaymentCard";

export default class CmpPaymentProcessor_Card extends LightningElement {
  // * Component Properies
  // * * Public
  @api amount = 0;
  @api recordId;

  // * * Private
  @track card = {
    card_number: "",
    expiry_month: "",
    expiry_year: "",
    cvv: ""
  };
  paymentDetails = null;


  // * Apex Functions

  connectedCallback() {
    this.card.expiry_month = "01"

    let current = new Date().getFullYear();
    this.card.expiry_year = current.toString().substring(2);
  }

  @api
  process() {
    // Remove the formatting for the process.
    let cardDetails = {
      ...this.card,
      card_number: this.card.card_number.replaceAll("-", "")
    };

    let amount = this.amount.toFixed(2).replace(/[,.]/g, "");

    // Call the process payment method.
    processPayment({
      cardDetails,
      amount,
      recordId: this.recordId
    })
        .then((results) => {
          this.paymentDetails = results;
        })
        .catch((error) => {
          // TODO Check when this happens.
          console.error(`Processor - Card\nError: ${error}`);
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

  // * Event Handlers

  handleChange_Number(event) {
    // Intiialise any variables.
    let cardNumber = event.target.value;
    // Remove any non-digits.
    cardNumber = cardNumber.replace(/[^0-9]/gi, "");

    // Group the card card_number into four digits.
    let matches = cardNumber.match(/\d{4,16}/g);
    let match = (matches && matches[0]) || "";
    let groups = [];
    // For the card_number of matches.
    for (let i = 0; i < match.length; i += 4) {
      groups.push(match.substring(i, i + 4));
    }

    // Set the card detail.
    this.card.card_number = groups.length > 1 ? groups.join("-") : cardNumber;

    // Validate the card details.
    this.validate();
  }

  handleChange_Month(event) {
    // Set the card detail.
    this.card.expiry_month = event.target.value;

    // Validate the card details.
    this.validate();
  }

  handleChange_Year(event) {
    // Set the card detail.
    this.card.expiry_year = event.target.value;

    // Validate the card details.
    this.validate();
  }

  handleChange_CVV(event) {
    // Set the card detail.
    this.card.cvv = event.target.value;

    // Validate the card details.
    this.validate();
  }

  handleKeyDown_NumbersOnly(event) {
    // Get the keycode.
    let keyCode = event.keycode ? event.keycode : event.which;
    // If the key is not a:
    if (
        // "Functional keys"? lol
        keyCode < 31 ||
        // General key (digits).
        (keyCode >= 48 && keyCode <= 57) ||
        // Number pad key (digits).
        (keyCode >= 96 && keyCode <= 105)
    ) {
      return;
    }

    // Stop additional processing.
    event.preventDefault();
  }

  // * Helper Functions

  validate() {
    // Initialise any variables.
    let valid = true;
    let card_number = this.card.card_number;
    let cvv = this.card.cvv;
    let fieldNumber = this.template.querySelector("[data-name='txtNumber']");
    let fieldCVV = this.template.querySelector("[data-name='txtCVV']");

    // If the card card_number is not the correct length.
    if (card_number.length >= 0 && card_number.length < 19) {
      valid = false;
      fieldNumber.setCustomValidity("The card number is not valid.");
    } else {
      fieldNumber.setCustomValidity("");
    }

    // If the card CVV is not the correct length.
    if (cvv.length >= 0 && cvv.length < 3) {
      valid = false;
      fieldCVV.setCustomValidity("The cvv is not valid.");
    } else {
      fieldCVV.setCustomValidity("");
    }

    this.dispatchPaymentDetailValidityUpdate({"valid": valid});
  }

  // * Template Functions

  get getMonths() {
    return [
      { label: "01", value: "01" },
      { label: "02", value: "02" },
      { label: "03", value: "03" },
      { label: "04", value: "04" },
      { label: "05", value: "05" },
      { label: "06", value: "06" },
      { label: "07", value: "07" },
      { label: "08", value: "08" },
      { label: "09", value: "09" },
      { label: "10", value: "10" },
      { label: "11", value: "11" },
      { label: "12", value: "12" }
    ];
  }

  get getYears() {
    // Intitialise any variables.
    let years = [];
    let current = new Date().getFullYear();

    // For 1 to 5.
    for (let i = 0; i < 6; i++) {
      let year = current + i;
      years.push({
        label: year,
        value: year.toString().substring(2)
      });
    }

    return years;
  }
}