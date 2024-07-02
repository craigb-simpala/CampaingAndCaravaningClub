// * LWC Imports
import { getRecord } from "lightning/uiRecordApi";
import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// * Apex Imports
import updateDirectDebitDetails from "@salesforce/apex/DirectDebitCheckerController.updateDirectDebitDetails";
import validateDirectDebitDetails from "@salesforce/apex/DirectDebitCheckerController.validateDirectDebitDetails";

export default class CmpDirectDebitChecker extends LightningElement {
  // * Component Properies
  // * * Public
  @api recordId = null;
  @api source;
  // * * Private
  @track account = {
    bank: "",
    holder: "",
    number: "",
    sortCode: "",
    valid: false
  };

  paymentButtonDisplayed = false;

  // * Event Dispatchers

  dispatchDetailsValidated() {
    // Dispatch the card updated event.
    this.dispatchEvent(
      new CustomEvent("detailsvalidated", {
        detail: this.account
      })
    );
  }

  dispatchToastMessage(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title,
        message,
        variant
      })
    );
  }

  dispatchHidePaymentButton() {
    this.paymentButtonDisplayed = false;

    this.dispatchEvent(
        new CustomEvent("hidepaymentbutton", { bubbles: true, composed: true })
    );
  }

  // * Event Handlers

  handleChange_Holder(event) {
    // Set the account holder.
    this.account.holder = event.target.value;

    // Validate the account details.
    this.validate();
  }

  handleChange_Number(event) {
    // Intiialise any variables.
    let number = event.target.value;
    // Remove any non-digits.
    number = number.replace(/[^0-9]/gi, "");

    // Group the account number into four digits.
    let matches = number.match(/\d{4,8}/g);
    let match = (matches && matches[0]) || "";
    let groups = [];
    // For the number of matches.
    for (let i = 0; i < match.length; i += 4) {
      groups.push(match.substring(i, i + 4));
    }

    // Set the account number.
    this.account.number = groups.length > 1 ? groups.join("-") : number;

    // Validate the account details.
    this.validate();
  }

  handleChange_SortCode(event) {
    // Intiialise any variables.
    let sortcode = event.target.value;
    // Remove any non-digits.
    sortcode = sortcode.replace(/[^0-9]/gi, "");

    // Group the account sort code into two digits.
    let matches = sortcode.match(/\d{2,6}/g);
    let match = (matches && matches[0]) || "";
    let groups = [];
    // For the number of matches.
    for (let i = 0; i < match.length; i += 2) {
      groups.push(match.substring(i, i + 2));
    }

    // Set the account sort code.
    this.account.sortCode = groups.length > 1 ? groups.join("-") : sortcode;

    // Validate the account details.
    this.validate();
  }

  handleClick_Validate(event) {

    validateDirectDebitDetails({
      account: this.account
    })
      .then((result) => {
        this.account.valid = result.valid;

        if (this.account.valid) {
          this.showToast(
            "Valid Direct Debit Details",
            "",
            "Success"
          );
          updateDirectDebitDetails({
            recordId: this.recordId,
            account: this.account
          });
        } else {
          this.showToast(
            "Invalid Direct Debit Details",
            result.message,
            "error"
          );
        }

        this.dispatchDetailsValidated();
        this.paymentButtonDisplayed = true;
      })
      .catch((error) => {
        console.error(error);
        this.showToast(
          "There was an Error",
          error.body.message,
          "error"
        );
      });
  }

  showToast(title, message, variation) {
    if(this.source == "Renew" || this.source == "ChangeMembership" || this.source == "ChangeAssociateMemberSectionsPayment") {
      this.template.querySelector('c-cmp-toast').showToast(
          title,
          message,
          variation,
      );
    } else {
      this.dispatchToastMessage(
          title,
          message,
          variation
      );
    }
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
    let number = this.account.number;
    let sortcode = this.account.sortCode;
    let fieldNumber = this.template.querySelector("[data-name='txtNumber']");
    let fieldSortCode = this.template.querySelector(
      "[data-name='txtSortCode']"
    );

    // If the account number is not the correct length.
    if (number.length >= 0 && number.length < 9) {

      if(this.paymentButtonDisplayed) this.dispatchHidePaymentButton();

      fieldNumber.setCustomValidity("The account number is not valid.");
    } else {

      fieldNumber.setCustomValidity("");
    }

    // If the account sort code is not the correct length.
    if (sortcode.length >= 0 && sortcode.length < 8) {

      if(this.paymentButtonDisplayed) this.dispatchHidePaymentButton();

      fieldSortCode.setCustomValidity("The sort code is not valid.");
    } else {
      fieldSortCode.setCustomValidity("");
    }
  }

  // * Template Functions

  get displayValidateButton() {
    return (
      this.account.number.length === 9 && this.account.sortCode.length === 8
    );
  }
}