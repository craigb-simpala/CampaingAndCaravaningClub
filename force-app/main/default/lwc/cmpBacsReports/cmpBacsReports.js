/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 30-05-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   19-05-2022   Kev Cadger (Wipro)   Initial Version
 **/
// * LWC Imports * //
import { LightningElement, track } from "lwc";
// * Apex Imports * //
import extractReportData from "@salesforce/apex/Ctrl_BACSReports.extractReportData";
import getReportData from "@salesforce/apex/Ctrl_BACSReports.getReportData";
import processReportData from "@salesforce/apex/Ctrl_BACSReports.processReportData";
// * Constants
const REPORT_COLUMNS_ADDACS = [
  {
    label: "Membership",
    fieldName: "MembershipURL",
    type: "url",
    typeAttributes: {
      label: { fieldName: "Membership_Number__c" },
      target: "_blank"
    }
  },
  { label: "Code", fieldName: "Reason_Code__c" },
  { label: "Effective Date", fieldName: "Effective_Date__c", type: "date" },
  { label: "Payer", fieldName: "Name__c" },
  { label: "Payer (New)", fieldName: "Name_New__c" },
  { label: "Sort Code", fieldName: "Sort_Code__c" },
  { label: "Sort Code (New)", fieldName: "Sort_Code_New__c" },
  { label: "Account Number", fieldName: "Account_Number__c" },
  { label: "Account Number (New)", fieldName: "Account_Number_New__c" },
  { label: "Status", fieldName: "Status__c" },
  { label: "Message", fieldName: "Message__c", wrapText: true }
];
const REPORT_COLUMNS_ARUDD = [
  {
    label: "Membership",
    fieldName: "MembershipURL",
    type: "url",
    typeAttributes: {
      label: { fieldName: "Membership_Number__c" },
      target: "_blank"
    }
  },
  { label: "Code", fieldName: "Reason_Code__c" },
  { label: "Status", fieldName: "Status__c" },
  { label: "Message", fieldName: "Message__c", wrapText: true }
];
const REPORT_COLUMNS_AUDDIS = [
  {
    label: "Membership",
    fieldName: "MembershipURL",
    type: "url",
    typeAttributes: {
      label: { fieldName: "Membership_Number__c" },
      target: "_blank"
    }
  },
  { label: "Code", fieldName: "Reason_Code__c" },
  { label: "Effective Date", fieldName: "Effective_Date__c", type: "date" },
  { label: "Payer", fieldName: "Name__c" },
  { label: "Payer (New)", fieldName: "Name_New__c" },
  { label: "Sort Code", fieldName: "Sort_Code__c" },
  { label: "Sort Code (New)", fieldName: "Sort_Code_New__c" },
  { label: "Account Number", fieldName: "Account_Number__c" },
  { label: "Account Number (New)", fieldName: "Account_Number_New__c" },
  { label: "Status", fieldName: "Status__c" },
  { label: "Message", fieldName: "Message__c", wrapText: true }
];

export default class CmpBacsReports extends LightningElement {
  // * Private Properties
  _showLoading = false;
  @track _report = {
    id: null,
    columns: null,
    contentVersionId: null,
    data: null,
    type: null,
    recordTypeId: null
  };

  // * -------------------------------------------------- * //
  // * Event Functions

  handleClick_btnReportGetData(event) {
    event.preventDefault();

    this.switchShowLoading();

    this.getReportData();
  }

  handleClick_btnReportProcessData(event) {
    event.preventDefault();

    this.processReportData();
  }
  // * -------------------------------------------------- * //
  // * Event (Custom) Functions

  handleReportUpdated(event) {
    // Get the report object passed.
    let reportObj = JSON.parse(JSON.stringify(event.detail));
    // Update the report object with the details passed.
    this._report = Object.assign(this._report, reportObj);

    if (this._report.type != null) {
      // TODO Move this
      switch (this._report.type) {
        case "ADDACS":
          this._report.columns = REPORT_COLUMNS_ADDACS;
          break;
        case "ARUDD":
          this._report.columns = REPORT_COLUMNS_ARUDD;
          break;
        case "AUDDIS":
          this._report.columns = REPORT_COLUMNS_AUDDIS;
          break;
        default:
          break;
      }
    }
    // If the report has been uploaded
    // && there is no data.
    if (this._report.contentVersionId != null && this._report.data == null) {
      // Extract the data from the file.
      this.extractReportData();
    }
  }

  // * -------------------------------------------------- * //
  // * Helper Functions

  extractReportData() {
    this.switchShowLoading();

    // Call the extractReportData method.
    extractReportData({
      reportType: this._report.type,
      reportId: this._report.id,
      contentVersionId: this._report.contentVersionId
    })
      .then(() => {
        // Get the report data.
        this.getReportData();
      })
      .catch((e) => {
        console.error(e);

        this.switchShowLoading();
      });
  }

  getReportData() {
    console.log(this._report.id);
    // Call the getReportData method.
    getReportData({
      reportId: this._report.id
    })
      .then((results) => {
        console.info(results);
        results = results.map((result) => {
          return { ...result, MembershipURL: `/${result.Account__c}` };
        });
        console.info(results);
        this._report.data = results;

        this.switchShowLoading();
      })
      .catch((e) => {
        console.error(e);

        this.switchShowLoading();
      });
  }

  processReportData() {
    this.switchShowLoading();

    processReportData({
      reportType: this._report.type,
      reportId: this._report.id
    })
      .then(() => {
        console.info("Successfully processed report data.");
        this.getReportData();
      })
      .catch((e) => {
        console.error(e);

        this.switchShowLoading();
      });
  }

  // Switches the loading display value.
  switchShowLoading() {
    // Switch the value of the loading display.
    this._showLoading = !this._showLoading;
  }
}