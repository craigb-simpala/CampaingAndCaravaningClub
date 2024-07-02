/**
 * @description       :
 * @author            : Kev Cadger (Wipro)
 * @group             :
 * @last modified on  : 25-05-2022
 * @last modified by  : Kev Cadger (Wipro)
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   19-05-2022   Kev Cadger (Wipro)   Initial Version
 **/
// * LWC Imports * //
import { LightningElement, api, track, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
// * Apex Imports * //
import createReport from "@salesforce/apex/Ctrl_BACSReports.createReport";
// * Constants * //
const BACS_REPORT_API_NAME = "BACS_Report__c";

export default class CmpBacsReportType extends LightningElement {
  // * -------------------------------------------------- * //
  // * Public Properties
  @api report = null;

  // * Private Properties
  @track _objReport_RecordTypes = [];
  @track _report = {
    id: null,
    contentVersionId: null,
    data: null,
    type: null,
    recordTypeId: null
  };
  _showModal = false;

  // * -------------------------------------------------- * //
  // * Event Functions
  handleChange_ReportType(event) {
    this.cloneReport();

    // Update the report object.
    this._report.id = null;
    this._report.contentVersionId = null;
    this._report.data = null;
    this._report.type = event.target.value;
    this._report.recordTypeId = this._objReport_RecordTypes.find(
      (recordType) => recordType.name === this._report.type
    ).id;

    this.dispatchEvent_ReportUpdated();
  }

  handleClick_btnReportCreate(event) {
    event.preventDefault();
    // Call the createReport method.
    createReport({
      reportType: this._report.type,
      recordTypeId: this._report.recordTypeId
    })
      .then((reportId) => {
        // Update the report object.
        this._report.id = reportId;

        this.dispatchEvent_ReportUpdated();

        this.switchShowModal();
      })
      .catch((e) => {
        console.error(e);
      });
  }

  handleUploadFinished(event) {
    this.cloneReport();

    // Update the report object.
    this._report.contentVersionId = event.detail.files[0].contentVersionId;
    console.log(event.detail.files);

    this.dispatchEvent_ReportUpdated();

    this.switchShowModal();
  }

  // * -------------------------------------------------- * //
  // * Event (Custom) Functions

  // Dispatches the report updated event.
  dispatchEvent_ReportUpdated() {
    // Dispatch the event.
    this.dispatchEvent(
      // Create the custom event.
      new CustomEvent("reportupdated", {
        detail: this._report
      })
    );
  }

  // * -------------------------------------------------- * //
  // * Helper Functions

  // Clones the report into an editable object.
  cloneReport() {
    // Clone the public report object.
    this._report = Object.assign(this._report, this.report);
  }

  // Switches the modal display value.
  switchShowModal() {
    // Switch the value of the modal display.
    this._showModal = !this._showModal;
  }

  // * -------------------------------------------------- * //
  // * Template Functions

  get isCreated_Report() {
    // Returns whether the report has been created.
    return this.report.id != null;
  }

  get isSelected_ReportType() {
    // Return whether the type has been selected.
    return this.report.type != null;
  }

  get isUploaded_Report() {
    // Returns whether the report has been uploaded.
    return this.report.contentVersionId != null;
  }

  get getOptions_ReportType() {
    // Return the report type options.
    return this._objReport_RecordTypes.map((recordType) => {
      // Get the record type name.
      let recordTypeName = recordType.name;
      // Return the report type object.
      return {
        label: recordTypeName,
        value: recordTypeName
      };
    });
  }

  // * -------------------------------------------------- * //
  // * Wire Functions
  // Gets the Report object information.
  @wire(getObjectInfo, { objectApiName: BACS_REPORT_API_NAME })
  getBacsReportInfo({ data, error }) {
    // If data is returned.
    if (data) {
      // For each key in the record type info.
      Object.keys(data.recordTypeInfos).forEach((recordTypeId) => {
        // Get the record type info.
        let recordType = data.recordTypeInfos[recordTypeId];

        // If the record type is available
        // && NOT the master.
        if (recordType.available && !recordType.master) {
          // Add the record type to the Report Record Types.
          this._objReport_RecordTypes.push({
            id: recordTypeId,
            name: recordType.name
          });
        }
      });
    }
    // Else if error is returned.
    else if (error) {
      console.error(error);
    }
  }
}